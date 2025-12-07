# Sage Observability

#tags #project #sre

## Статус

**7/10** — проект уже живой: есть реальные задачи в T-Bank, эксперимент с OpenSearch, документы и код (часть на GitHub). Дальше — доводка, оформление и перенос в статьи/доклады.

(Ссылка на репозиторий: вписать сюда позже)

## Описание

Рабочий проект по observability в T-Bank: внутренняя платформа Sage для логов и метрик (аналог Splunk).  
Я работаю в домене **Logs**: логирование, хранение, поиск и оптимизация.

Объём данных — десятки петабайт логов и метрик.

## Цели

- Пройти путь от Intern до уверенного Junior/Middle SRE в домене Sage Logs.  
- Довести эксперименты с OpenSearch (sort + forcemerge + отказ от `copy_to`/поля `all`) до стабильных практик.  
- Собрать репрезентативную документацию и экспериментальный отчёт (уровень A-статьи/внутреннего RFC).  
- Понимать экономику хранения (≈ сколько рублей/долларов экономит каждая оптимизация).

## Контекст / зачем мне этот проект

- Связывает текущую работу в T-Bank и будущие исследования по MLOps и лог-анализу.  
- Даёт реальные продовые кейсы для статей, докладов и портфолио.  
- Является базой для эксперимента [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025 по OpenSearch]].

## Основные результаты, которые хочу получить

- Набор best practices по хранению логов в OpenSearch (sort, forcemerge, mapping без `copy_to` и поля `all`).  
- Графики «экономия места → экономия денег» для разных групп индексов.  
- Минимум один доклад/статья на базе этих экспериментов.  
- Красиво оформленный репозиторий/страница в портфолио.

## Связано

- [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE — роль и обязанности]]
- [[03_Work & Career/T-Bank SRE/Learning-Plan|План развития в SRE]]
- [[03_Work & Career/T-Bank SRE/Tasks-Backlog|Backlog задач T-Bank SRE]]

- [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025: оптимизация хранения в OpenSearch]]
- [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]

- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
