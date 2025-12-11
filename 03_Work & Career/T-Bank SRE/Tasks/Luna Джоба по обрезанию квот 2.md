[[Luna Джоба по обрезанию квот 3]]
Мне уже всего хватает 😊  
По тем кускам, что ты скинул, картинка целиком складывается:

- как вы считаете `fair_quota`,
    
- как устроены `ISauronClient`, `IMageClient`, `GrafanaService`,
    
- как выглядят живые джобы (`LogsQuotaRemoveUnused`, `SauronCheck`, `GrafanaOrganizationSync`).
    

Поэтому **досылать ещё код не обязательно** — дальше уже вопрос подгонки под реальные неймспейсы/конфиги в репо.

Давай закрепим «актуальную» реализацию, которую ты можешь втыкать и править по месту.

---

## 1. Конфиг джобы

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

Пример в `appsettings` / конфиге:

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

## 2. Джоба `LogsQuotaApplyFair`

```csharp
using Luna.Clients;
using Luna.Config.BackgroundServices;
using Luna.Services.Grafana;
using Microsoft.Extensions.Options;

namespace Luna.BackgroundServices;

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
                continue;

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
                // 🔍 только логируем, квоту не трогаем
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
        // TODO: подправь фильтры под реальные лейблы (group/env/system), если нужно.
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

            // 🔴 Аннотация в Grafana / DemoDashboard
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

### 3. Что тебе осталось сделать руками

1. **Проверить PQL `sage_fair_quota`**
    
    - Открыть MAGE / Grafana, посмотреть реальные лейблы метрики (`group`, `env`, `system`, может ещё что-то).
        
    - При необходимости подправить фильтр в `GetFairQuotas`.
        
2. **Подключить джобу в DI и конфиге**, как остальные `BackgroundServiceBase`:
    
    - зарегистрировать `LogsQuotaApplyFair` как хостед-сервис,
        
    - прописать секцию `LogsQuotaApplyFair` в конфиге.
        
3. **Погонять с `DryRun = true`**:
    
    - посмотреть логи `FAIR_QUOTA_DRY_RUN`,
        
    - убедиться, что робот не лезет не туда и не режет почти-нулевые или чувствительные группы.
        
4. Когда все будут довольны — **поставить `DryRun = false`** и дать роботу ножницы.
    

Если где-то по пути упрёшься в конкретный компил-эррор (не совпала сигнатура клиента, неймспейс, тип), просто скинь текст ошибки — подправим под реальное API.