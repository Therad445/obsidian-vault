Ага, понял, ты хочешь не заморачиваться с флагами, а сделать по-олдскульному:

1. Сначала джоба **только считает и логирует**, вообще не трогая квоты.
    
2. Логи смотришь через Sage / обычный логовый дашборд.
    
3. Если всё ок — **раскомментируешь блок**, который:
    
    - делает `PutGroupSetting`,
        
    - шлёт аннотацию в Grafana.
        

Это абсолютно нормальный и понятный подход. Тогда `DryRun` как конфиг реально не обязателен — он просто делал бы то же самое более “цивильно”.

Давай покажу тебе **две стадии одного и того же кода**:

- версия _сейчас_ — только логирование (ничего не режет),
    
- и как её потом “апгрейднуть” раскомментированием.
    

---

## 1. Версия **сейчас**: только логируем, ничего не режем

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
    }

    protected override async Task Work(CancellationToken stoppingToken)
    {
        var quotas = await GetQuotas(stoppingToken);
        Logger.LogInformation("LogsQuotaApplyFair: got {Count} quotas (group+dc)", quotas.Count);

        var fairQuotas = await GetFairQuotas(stoppingToken);
        Logger.LogInformation("LogsQuotaApplyFair: got {Count} fair quotas (group+dc)", fairQuotas.Count);

        var fairByKey = fairQuotas.ToDictionary(
            fq => (fq.sage_group, fq.dc),
            fq => fq.value);

        var candidates = 0;

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

            // насколько сильно fair ниже текущей квоты
            var relativeDiff = 1.0 - fair / current;
            if (relativeDiff < 0.2) // пример: режем только если fair <= 80% от текущей
                continue;

            var minQuota = 104_86; // минимум 10КБ/с
            var target = Math.Max(fair, minQuota);
            if (Math.Abs(target - current) < 1)
                continue;

            candidates++;

            // 🔍 СЕЙЧАС ТОЛЬКО ЛОГИ — НИЧЕГО НЕ МЕНЯЕМ
            Logger.LogInformation(
                "FAIR_QUOTA_PLAN group={Group} dc={Dc} current={Current} fair={Fair} target={Target} rel_diff={RelDiff}",
                quota.sage_group,
                quota.dc,
                current,
                fair,
                target,
                relativeDiff);

            // ПОЗЖЕ ВОТ ЗДЕСЬ БУДЕМ РЕЗАТЬ (ПОКА ЗАКОММЕНЧЕНО):
            /*
            await ApplyQuota(
                quota.sage_group,
                quota.dc,
                (long)current,
                (long)target,
                stoppingToken);
            */
        }

        Logger.LogInformation(
            "LogsQuotaApplyFair finished: candidates={Candidates}, APPLY BLOCK DISABLED (log-only mode)",
            candidates);
    }

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

    private async Task<List<GroupDcValue>> GetFairQuotas(CancellationToken ct)
    {
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

    // пока ApplyQuota есть, но не используется (вызов закомментирован)
    private async Task ApplyQuota(string group, string dc, long current, long target, CancellationToken ct)
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

        var reason = $"group={group} dc={dc} fair_quota: {current} -> {target} bytes/s";
        await _grafanaService.AddAnnotation(
            action: "logs_quota_cut",
            reason: reason,
            app: "luna",
            host: "quota-robot",
            cluster: dc);
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

🔧 Что ты делаешь сейчас:

- Деплоишь вот такую джобу.
    
- Идёшь в логи Luna (через Sage / Grafana / Kibana — как у вас заведено) и фильтруешь по:
    
    - `FAIR_QUOTA_PLAN`
        
- Смотришь строки вида:
    
    ```text
    FAIR_QUOTA_PLAN group=foo dc=ix-m4 current=104857600 fair=20971520 target=20971520 rel_diff=0.8
    ```
    
- Решаете с командой: “Да, таким группам реально можно так срезать”.
    

---

## 2. Потом, когда всё ок — включаешь реальное срезание

На этом этапе ты просто **раскомментируешь вызов `ApplyQuota`**:

```csharp
foreach (var quota in quotas)
{
    ...
    candidates++;

    Logger.LogInformation(
        "FAIR_QUOTA_PLAN group={Group} dc={Dc} current={Current} fair={Fair} target={Target} rel_diff={RelDiff}",
        quota.sage_group,
        quota.dc,
        current,
        fair,
        target,
        relativeDiff);

    // ✅ ТЕПЕРЬ РАБОТАЕТ БОЙ: РЕЖЕМ И ШЛЁМ АННОТАЦИЮ В GRAFANA
    await ApplyQuota(
        quota.sage_group,
        quota.dc,
        (long)current,
        (long)target,
        stoppingToken);
}
```

И всё:

- Квоты реально обновляются через `PutGroupSetting`.
    
- `ApplyQuota` кидает **аннотацию в Grafana**:
    
    ```csharp
    var reason = $"group={group} dc={dc} fair_quota: {current} -> {target} bytes/s";
    await _grafanaService.AddAnnotation(
        action: "logs_quota_cut",
        reason: reason,
        app: "luna",
        host: "quota-robot",
        cluster: dc);
    ```
    

На дашбордах появятся полосочки с текстом типа:

> logs_quota_cut group=foo dc=ix-m4 fair_quota: 104857600 -> 20971520 bytes/s luna node quota-robot cluster ix-m4

---

## 3. Что значит “проверить через Sage”

Так как ты логируешь через `Logger.LogInformation`, дальше всё как обычно:

- логи уходят в вашу стандартную цепочку (Serilog / NLog → Kafka → Elastic / Loki),
    
- в Sage или Grafana есть дашборды по логам Luna,
    
- ты просто фильтруешь по:
    
    - `app="luna"` (или как она у вас называется),
        
    - `message~"FAIR_QUOTA_PLAN"` или `@message:"FAIR_QUOTA_PLAN"`.
        

И видишь “план срезания” без реальных изменений в проде.

---

Если хочешь, дальше можем:

- подобрать более точные пороги (не 0.2, а, скажем, разные для крупных и мелких групп),
    
- или добавить ещё условия (например, не трогать группы младше N дней, как в старом `quotaCut.cs`).