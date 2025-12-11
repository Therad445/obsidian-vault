Окей, давай сделаем аккуратную «боевую, но пока без ножа» версию:  
✅ конфиг есть  
✅ квоты и fair_quota считаем  
✅ логируем, **кого бы порезали**  
⛔ квоты пока не трогаем, аннотации не шлём — код для этого есть, но вызов закомментирован.

---

### 1. Конфиг `LogsQuotaApplyFairConfig`

```csharp
using Luna.Config.BackgroundServices;

namespace Luna.Config.BackgroundServices;

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
}
```

Пример секции в конфиге (appsettings / Consul и т.п.):

```json
"LogsQuotaApplyFair": {
  "Enabled": true,
  "PeriodSeconds": 3600,
  "MinRelativeDiff": 0.2,
  "MinQuotaBytesPerSecond": 10486
}
```

---

### 2. Джоба `LogsQuotaApplyFair` (с закомментированным применением)

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

        // 2. Fair quotas по group+dc (из метрики sage_fair_quota)
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
            if (relativeDiff < _config.MinRelativeDiff)
                continue;

            var target = Math.Max(fair, _config.MinQuotaBytesPerSecond);
            if (Math.Abs(target - current) < 1)
                continue;

            candidates++;

            // 🔍 СЕЙЧАС — ТОЛЬКО ЛОГИ, НИЧЕГО НЕ РЕЖЕМ
            Logger.LogInformation(
                "FAIR_QUOTA_PLAN group={Group} dc={Dc} current={Current} fair={Fair} target={Target} rel_diff={RelDiff}",
                quota.sage_group,
                quota.dc,
                current,
                fair,
                target,
                relativeDiff);

            // ✅ ПОТОМ, КОГДА ПРОВЕРИТЕ ЛОГИ, МОЖНО РАСКОММЕНТИРОВАТЬ ЭТО:
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
        // TODO: при необходимости поправь фильтры под реальные лейблы env/system.
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
    /// Сейчас метод не вызывается — вызов закомментирован в Work().
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

Дальше шаги такие:

1. Подключаешь `LogsQuotaApplyFairConfig` и `LogsQuotaApplyFair` в DI так же, как другие `BackgroundServiceBase`.
    
2. Деплоишь с этим кодом — он **только пишет логи `FAIR_QUOTA_PLAN`**, квоты не трогает.
    
3. Через Sage / Grafana логов смотришь, кого он собирается резать.
    
4. Когда убедитесь, что поведение ок — просто снимаешь комментарий с вызова `ApplyQuota(...)` в `Work()` и, если нужно, чуть подстраиваешь пороги в конфиге.