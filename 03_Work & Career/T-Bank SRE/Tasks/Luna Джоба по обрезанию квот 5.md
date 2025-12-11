Да, ты всё правильно чувствуешь: нужно **добавить инициализацию в два места**:

1. Привязка конфига `LogsQuotaApplyFairConfig` к секции в `BackgroundServices`.
    
2. Регистрация самой джобы через `RegisterHostedServices<LogsQuotaApplyFair>` + флажок в `EnabledServices`.
    

Соберу тебе это аккуратно по шагам.

---

## 1. Привязка конфига `LogsQuotaApplyFairConfig`

В `ConfigureWebApplicationBuilder` у тебя уже есть блоки:

```csharp
builder.Services.ConfigureWithValidation<LogsQuotaMetricsCreatorConfig>(
    builder.Configuration.GetBackgroundServiceSection("LogsQuotaMetricsCreator"));

builder.Services.ConfigureWithValidation<LogsQuotaRemoveUnusedConfig>(
    builder.Configuration.GetBackgroundServiceSection("LogsQuotaRemoveUnused"));
```

Рядом туда же добавь:

```csharp
builder.Services.ConfigureWithValidation<LogsQuotaApplyFairConfig>(
    builder.Configuration.GetBackgroundServiceSection("LogsQuotaApplyFair"));
```

> ⚠️ Namespace  
> `LogsQuotaApplyFairConfig` у тебя в `Luna.Config.BackgroundServices`, этот namespace уже `using`-нут сверху, так что тут всё должно собраться без лишних using’ов.

---

## 2. Регистрация фоновой джобы

Внизу `ConfigureWebApplicationBuilder` есть огромный блок:

```csharp
var enabledServices = builder.Configuration.GetSection("EnabledServices").Get<EnabledServiceConfig>();

RegisterHostedServices<CleanEmptyIndexes>(builder, enabledServices);
...
RegisterHostedServices<LogsQuotaMetricsCreator>(builder, enabledServices);
RegisterHostedServices<LogsQuotaRemoveUnused>(builder, enabledServices);
RegisterHostedServices<RotateWhenMappingOverflow>(builder, enabledServices);
RegisterHostedServices<SageDbClickhouseMetrics>(builder, enabledServices);
```

Сюда же добавляешь:

```csharp
RegisterHostedServices<LogsQuotaApplyFair>(builder, enabledServices);
```

Я бы поставил рядом с остальными логовыми джобами, например так:

```csharp
RegisterHostedServices<LogsQuotaMetricsCreator>(builder, enabledServices);
RegisterHostedServices<LogsQuotaRemoveUnused>(builder, enabledServices);
RegisterHostedServices<LogsQuotaApplyFair>(builder, enabledServices);
RegisterHostedServices<RotateWhenMappingOverflow>(builder, enabledServices);
RegisterHostedServices<SageDbClickhouseMetrics>(builder, enabledServices);
```

Тогда `EnabledServices["LogsQuotaApplyFair"]` будет управлять, включена джоба или нет.

---

## 3. Конфиг в `EnabledServices`

В твоём конфиге `EnabledServices` сейчас есть:

```json
"EnabledServices": {
  ...
  "LogsQuotaMetricsCreator" : false,
  "LogsQuotaRemoveUnused" : false,
  "RotateWhenMappingOverflow" : false,
  "SageDbClickhouseMetrics" : false
}
```

Сюда нужно добавить новый ключ:

```json
"EnabledServices": {
  ...
  "LogsQuotaMetricsCreator": false,
  "LogsQuotaRemoveUnused": false,
  "LogsQuotaApplyFair": false,
  "RotateWhenMappingOverflow": false,
  "SageDbClickhouseMetrics": false
}
```

Пока **держи его на `false`**, чтобы джоба не стартовала, пока вы не готовы.

Когда захотите её реально запустить (даже в лог-only режиме), просто поменяешь на:

```json
"LogsQuotaApplyFair": true
```

---

## 4. Секция в `BackgroundServices` для настроек джобы

Внизу конфига у тебя уже есть:

```json
"BackgroundServices": {
  "Elastic": { ... },
  "Kafka": { ... },
  ...
  "LogsQuotaRemoveUnused": {
    "ExecuteIntervalMilliseconds": 600000,
    "WorkHours": {
      "From": 8,
      "To": 14
    },
    "NotWorkDays": [
      "Saturday",
      "Sunday"
    ]
  },
  "RotateWhenMappingOverflow": {
    "ExecuteIntervalMilliseconds": 300000
  }
}
```

Добавь сюда свою секцию `LogsQuotaApplyFair` (рядом с другими не-Elastic/Kafka сервисами):

```json
"BackgroundServices": {
  "Elastic": { ... },
  "Kafka": { ... },

  ...

  "LogsQuotaRemoveUnused": {
    "ExecuteIntervalMilliseconds": 600000,
    "WorkHours": {
      "From": 8,
      "To": 14
    },
    "NotWorkDays": [
      "Saturday",
      "Sunday"
    ]
  },

  "LogsQuotaApplyFair": {
    "ExecuteIntervalMilliseconds": 604800000,
    "MinRelativeDiff": 0.1,
    "MinQuotaBytesPerSecond": 10486
  },

  "RotateWhenMappingOverflow": {
    "ExecuteIntervalMilliseconds": 300000
  }
}
```

- `ExecuteIntervalMilliseconds = 604800000` → раз в неделю.
    
- `MinRelativeDiff = 0.1` → считаем кандидатом, если fair ≤ 90% от текущей квоты.
    
- `MinQuotaBytesPerSecond = 10486` → минимум около 10 KB/s.
    

Это ровно то, что будет читаться в конструкторе через `IOptions<LogsQuotaApplyFairConfig>`.

---

## 5. Проверка, что всё “срослось”

После этих правок:

1. Сборка должна увидеть:
    
    - `LogsQuotaApplyFairConfig` привязан через `ConfigureWithValidation`,
        
    - `LogsQuotaApplyFair` зарегистрирован через `RegisterHostedServices`.
        
2. В рантайме:
    
    - если `EnabledServices.LogsQuotaApplyFair = false` → джоба не будет зарегистрирована → всё тихо;
        
    - если `true` → джоба стартует, раз в неделю будет выполнять `Work`, и **пока** только логировать `FAIR_QUOTA_PLAN`.
        

Когда будете готовы доверить роботу ножницы — снимешь комментарий с `ApplyQuota(...)` в `Work()` и аннотации в Grafana тоже поедут автоматически.

Если хочешь, дальше можем отдельно пройтись по PQL для `sage_fair_quota`, чтобы ты мог руками в MAGE проверить пару групп до того, как доверишься автоматике.