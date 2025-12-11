[[Luna Джоба по обрезанию квот 2]]

Давай разложим по полочкам: как всё жило раньше, что мы добавили, и какой сейчас получается код.

---

## 1. Как это работало раньше

### 1.1. Разовый скрипт `quotaCut.cs` (из tools)

Этот скрипт:

1. Ходил в MAGE через `ISageClient` и PQL:
    
    - искал группы, у которых **квота > quota_limit**;
        
    - отбрасывал свежие группы (`lifetime < 25 дней`);
        
    - отбрасывал группы, где за последние `days_window` дней квоту меняли (minQuota != maxQuota);
        
    - проверял, что квота **сильно недоиспользуется**: p90 рейта логов меньше половины квоты в течение `days_underutilization_window` дней из `days_window`.
        
2. Если группа стабильно недогружена:
    
    - считал «целевую квоту» по p90-рейту логов * 1.3, но не ниже `quota_min_value`;
        
    - если новая квота меньше старой — записывал `QuotaBytesPerSecond` через Sauron API (`PutGroupSetting`);
        
    - логировал, сколько квоты «освободили» по каждому DC.
        
3. Скрипт нужно было **запускать руками**, он не был частью Luna.
    

То есть это была однократная/ручная утилита по срезанию, живущая отдельно.

---

### 1.2. `LogsQuotaMetricsCreator` (только метрики, без изменения квот)

Эта джоба в Luna делает:

1. Тянет текущие квоты групп из Sauron (`GetQuotas()`).
    
2. Считает usage:
    
    - за день (p90),
        
    - за неделю (max p90[24h] за 7 дней),
        
    - за месяц (max p90[24h] за 30 дней).
        
3. Льёт в Prometheus метрики:
    
    - `sage_score_rate_p90_24h` — дневная утилизация квоты;
        
    - `sage_score_rate_p90_7d` — недельная;
        
    - `sage_score_rate_p90_30d` — месячная;
        
    - **`sage_fair_quota`** — справедливая квота, посчитанная по месячному usage.
        

Формула `fair_quota` внутри `GetFairQuota` (упрощённо):

```csharp
var usage = sum usage по (sage_group, dc);
var adjustedUsage = usage * 1.3;

var fairQuota =
    adjustedUsage > quota.value ? quota.value :                // если usage+30% > квоты — не режем
    whitelist.Contains(quota.sage_group) ? quota.value :       // если в whitelist — не режем
    adjustedUsage < 104_86 ? 104_86 :                          // минимум 10КБ/с
    adjustedUsage;                                             // иначе — usage * 1.3
```

И **на этом всё**: раньше `fair_quota` была **только метрикой** (для Grafana/аналитики), квоты по ней никто не менял.

---

### 1.3. `LogsQuotaRemoveUnused`

Отдельная джоба, которая **не оптимизирует квоты, а вычищает мёртвые группы**:

1. Ищет группы, у которых уже 90 дней только один индекс-алиас (heartbeat) для логов.
    
2. Фильтрует по:
    
    - только Elastic-хранилища;
        
    - не в whitelist;
        
    - есть логовый топик в Kafka, UsageMode содержит Logs, квота не огромная и т.п.
        
3. Проверяет, что нет других алиасов, кроме heartbeat.
    
4. Делает:
    
    - `QuotaBytesPerSecond = 0`, `UsageMode = "Metrics"` в соответствующем DC;
        
    - удаляет Kafka-топик `sage-logs-<group>`.
        

Это именно **удаление логовой квоты/потока у мёртвых групп**, не «подкрутка под fair_quota».

---

## 2. Как будет работать теперь

Мы добавляем **новую джобу** `LogsQuotaApplyFair`, которая:

1. Забирает из Sauron текущие квоты по (group, dc) — так же, как `LogsQuotaMetricsCreator.GetQuotas`.
    
2. Забирает из MAGE текущий `sage_fair_quota` по (sage_group, dc).
    
3. Для каждой пары `(group, dc)`:
    
    - Если `fair_quota >= current_quota` → **ничего не делаем** (не увеличиваем, только режем).
        
    - Считаем относительное отличие:
        
        ```csharp
        relativeDiff = 1.0 - fair / current;
        ```
        
    - Если `relativeDiff < MinRelativeDiff` (например, меньше 20%) → считаем шумом, не трогаем.
        
    - Считаем целевую квоту:
        
        ```csharp
        target = max(fair, MinQuotaBytesPerSecond);
        ```
        
    - Если `target` заметно меньше `current` → робот считает это кандидатом на срез.
        
4. Дальше есть два режима:
    

### DryRun = true (первый этап — только проверка)

- **Никаких `PutGroupSetting`**, квоты не трогаем.
    
- Пишем в логи строчку:
    
    ```text
    FAIR_QUOTA_DRY_RUN group=... dc=... current=... fair=... target=... rel_diff=...
    ```
    

По этим логам вы можете в MAGE/Elastic/Grafana посмотреть, **кого робот собирается резать, насколько сильно и в каких ДЦ**.

### DryRun = false (боевой режим)

- Для каждой такой пары робот:
    
    - тянет `GetGroup` из Sauron,
        
    - собирает `GroupSettingsByDatacenterRequest` с новой квотой,
        
    - вызывает `PutGroupSetting(group, dc, request)`,
        
    - пишет лог `FAIR_QUOTA_APPLY ...`,
        
    - кидает **аннотацию в Grafana** через `IGrafanaService.AddAnnotation`, чтобы на дашбордах была видна полоска «автоматика порезала квоту».
        

Сообщение аннотации выглядит примерно так:

```text
logs_quota_cut group=some-group dc=ix-m4 fair_quota: 104857600 -> 31457280 bytes/s luna node quota-robot cluster ix-m4
```

Теги: `["logs_quota_cut", "luna", "luna", "quota-robot", "ix-m4"]`.

---

## 3. Актуальный код (то, что ты можешь уже втыкать)

### 3.1. Конфиг джобы

```csharp
// namespace Luna.Config.BackgroundServices;

public sealed class LogsQuotaApplyFairConfig : BackgroundServiceConfig
{
    /// <summary>
    /// Минимальное относительное снижение, чтобы вообще что-то делать.
    /// Например, 0.2 = режем, если fair <= 80% от текущей квоты.
    /// </summary>
    public double MinRelativeDiff { get; set; } = 0.2;

    /// <summary>
    /// Минимальная квота, ниже которой не режем (bytes/sec).
    /// </summary>
    public long MinQuotaBytesPerSecond { get; set; } = 104_86; // ~10 KB/s

    /// <summary>
    /// Режим проверки: true — только логируем кандидатов, false — реально меняем квоты.
    /// </summary>
    public bool DryRun { get; set; } = true;
}
```

Пример настроек:

```json
"LogsQuotaApplyFair": {
  "Enabled": true,
  "PeriodSeconds": 3600,
  "DryRun": true,
  "MinRelativeDiff": 0.2,
  "MinQuotaBytesPerSecond": 10486
}
```

---

### 3.2. Джоба `LogsQuotaApplyFair`

```csharp
// namespace Luna.BackgroundServices;

using Luna.Clients;
using Luna.Config.BackgroundServices;
using Luna.Services.Grafana;
using Microsoft.Extensions.Options;

public sealed class LogsQuotaApplyFair : BackgroundServiceBase
{
    private readonly ISauronClient _sauronClient;
    private readonly IMageClient _mageClient;
    private readonly IGrafanaService _grafanaService;
    private readonly LogsQuotaApplyFairConfig _config;

    public LogsQuotaApplyFair(
        ISauronClient sauronClient,
        IMageClient mageClient,
        IGrafanaService grafanaService,
        IOptions<LogsQuotaApplyFairConfig> config,
        ILogger<LogsQuotaApplyFair> logger)
        : base(config, logger)
    {
        _sauronClient = sauronClient;
        _mageClient = mageClient;
        _grafanaService = grafanaService;
        _config = config.Value;
    }

    protected override async Task Work(CancellationToken stoppingToken)
    {
        // 1. Текущие квоты по group+dc
        var quotas = await GetQuotas(stoppingToken);
        Logger.LogInformation("LogsQuotaApplyFair: got {Count} quotas (group+dc)", quotas.Count);

        // 2. Fair quotas по group+dc
        var fairQuotas = await GetFairQuotas(stoppingToken);
        Logger.LogInformation("LogsQuotaApplyFair: got {Count} fair quotas (group+dc)", fairQuotas.Count);

        var fairByKey = fairQuotas.ToDictionary(
            fq => (fq.sage_group, fq.dc),
            fq => fq.value);

        var candidates = 0;
        var applied = 0;

        foreach (var quota in quotas)
        {
            if (!fairByKey.TryGetValue((quota.sage_group, quota.dc), out var fair))
            {
                continue; // нет fair_quota для этой пары
            }

            var current = quota.value;
            if (fair <= 0 || current <= 0)
                continue;

            // режем только вниз
            if (fair >= current)
                continue;

            var relativeDiff = 1.0 - fair / current;
            if (relativeDiff < _config.MinRelativeDiff)
                continue;

            var target = Math.Max(fair, _config.MinQuotaBytesPerSecond);
            if (Math.Abs(target - current) < 1)
                continue;

            candidates++;

            if (_config.DryRun)
            {
                // ТОЛЬКО логируем
                Logger.LogInformation(
                    "FAIR_QUOTA_DRY_RUN group={Group} dc={Dc} current={Current} fair={Fair} target={Target} rel_diff={RelDiff}",
                    quota.sage_group,
                    quota.dc,
                    current,
                    fair,
                    target,
                    relativeDiff);
            }
            else
            {
                await ApplyQuota(
                    quota.sage_group,
                    quota.dc,
                    (long)current,
                    (long)target,
                    stoppingToken);
                applied++;
            }
        }

        Logger.LogInformation(
            "LogsQuotaApplyFair finished: candidates={Candidates}, applied={Applied}, dryRun={DryRun}",
            candidates,
            applied,
            _config.DryRun);
    }

    /// <summary>
    /// Текущие квоты (по логам) в разрезе group+dc.
    /// Берём только UsageMode != "Metrics".
    /// </summary>
    private async Task<List<GroupDcValue>> GetQuotas(CancellationToken ct)
    {
        var groups = await _sauronClient.GetGroups(ct);

        var groupDcQuotas = groups
            .Select(g => g.Settings
                .Where(s => s.UsageMode != "Metrics")
                .Select(s => new GroupDcValue
                {
                    sage_group = g.Name,
                    dc = s.DatacenterName,
                    value = s.QuotaBytesPerSecond
                }))
            .SelectMany(g => g)
            .ToList();

        return groupDcQuotas;
    }

    /// <summary>
    /// Берём значение sage_fair_quota, которое уже считает LogsQuotaMetricsCreator.
    /// </summary>
    private async Task<List<GroupDcValue>> GetFairQuotas(CancellationToken ct)
    {
        // PQL под Luna / MAGE — при необходимости поправишь фильтры по env/system.
        var query = """
            pql last_over_time(sage_fair_quota{group="sage", env="prod"}[2h])
            by (sage_group, dc)
            | stats last(value) as value by sage_group, dc
            """;

        var request = new MageSearchRequest
        {
            Query = query,
            StartTime = DateTimeOffset.Now.AddHours(-2),
            EndTime = DateTimeOffset.Now,
            Size = 100000
        };

        var response = await _mageClient.Search<GroupDcValue>(request, ct);
        return response.Hits.ToList();
    }

    /// <summary>
    /// Реальное применение новой квоты + аннотация в Grafana.
    /// </summary>
    private async Task ApplyQuota(string group, string dc, long current, long target, CancellationToken ct)
    {
        try
        {
            var groupResponse = await _sauronClient.GetGroup(group, ct);
            var g = groupResponse.Content;

            var dcSetting = g.Settings.FirstOrDefault(s => s.DatacenterName == dc);
            if (dcSetting == null)
            {
                Logger.LogWarning("LogsQuotaApplyFair: no settings for group {Group} in dc {Dc}", group, dc);
                return;
            }

            var request = new GroupSettingsByDatacenterRequest
            {
                QuotaBytesPerSecond = target,
                RetentionDays = dcSetting.RetentionDays,
                MaxIndexCount = dcSetting.MaxIndexCount,
                UsageMode = dcSetting.UsageMode,
                KafkaForLogs = dcSetting.KafkaForLogs,
                TimeSeriesLimit = dcSetting.TimeSeriesLimit,
                PerTargetLimit = dcSetting.PerTargetLimit
            };

            Logger.LogInformation(
                "FAIR_QUOTA_APPLY group={Group} dc={Dc} current={Current} target={Target}",
                group, dc, current, target);

            await _sauronClient.PutGroupSetting(group, dc, request, ct);

            // Аннотация в Grafana / DemoDashboard
            var reason = $"group={group} dc={dc} fair_quota: {current} -> {target} bytes/s";
            await _grafanaService.AddAnnotation(
                action: "logs_quota_cut",
                reason: reason,
                app: "luna",
                host: "quota-robot",
                cluster: dc);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex,
                "LogsQuotaApplyFair: error applying fair quota for {Group} {Dc} ({Current} -> {Target})",
                group, dc, current, target);
        }
    }

    // Локальный тип для результатов запросов из MAGE/Sauron
    private sealed class GroupDcValue
    {
        public string sage_group { get; set; }
        public string dc { get; set; }
        public string? kafka_cluster { get; set; }
        public double value { get; set; }
    }
}
```

---

Если хочешь, дальше можем:

- подправить PQL под точные лейблы `sage_fair_quota` в вашем MAGE,
    
- придумать фильтры (например, по whitelist/blacklist групп),
    
- или сделать общий сервис `IFairQuotaCalculator`, чтобы **и `LogsQuotaMetricsCreator`, и `LogsQuotaApplyFair`** использовали одну и ту же реализацию расчёта, а не метрику.