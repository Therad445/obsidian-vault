# Roadmap — A-level статья по MLOps / логам

## Возможные направления

- Лог-анализ и аномалии (поверх существующей observability-платформы).  
- Self-healing системы с ML-слоем.  
- Drift detection и мониторинг качества моделей в проде.

## Что уже есть у меня

- Опыт в SRE / Sage Observability.  
- Эксперимент [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025 по OpenSearch]].  
- Проекты [[02_Projects/nginx_log_analyzer/README|Nginx Log Analyzer]] и [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]].

## Что надо добрать

- Структуру датасетов и метрик для ML-части.  
- Сравнение нескольких ML-подходов к аномалиям в логах.  
- Чёткую постановку задач и ограничения (продовый контекст).

## План по шагам

1. Чётко описать продовый контекст (Sage, OpenSearch, типы логов).  
2. Сформировать датасеты и метрики для экспериментов.  
3. Выбрать и реализовать несколько моделей.  
4. Сравнить, оформить результаты, связать с SRE-практикой.  
5. Подготовить статью под A-журнал / конференцию.

## Связано

- [[02_Projects/sage_observability/README|Sage Observability]]
- [[02_Projects/nginx_log_analyzer/README|Nginx Log Analyzer]]
- [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]]

- [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025: OpenSearch storage optimization]]
- [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]]

- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
