# Nginx Log Analyzer

#tags #project #sre

## Статус

- **Базовый pipeline (Flink + Kafka + ClickHouse)**: **10/10** — то, что хотел, уже реализовано и лежит на GitHub.  
- **Идеи по внедрению AI / аномалий**: **0/10** — только планы.  
- **CI/CD**: примерно **1/10** — есть зачатки, но нужно доводить.

(Ссылка на репозиторий: вписать реальную ссылку)

## Описание

Учебно-исследовательский проект по анализу Nginx-логов с использованием Flink + Kafka + ClickHouse.  
Служит стендом, на котором можно безопасно отрабатывать идеи по лог-анализу, метрикам и MLOps.

## Цели

- Поддерживать чистый и воспроизводимый pipeline (Docker/Compose/Helm).  
- Использовать этот проект как источник данных и инфраструктуры для:
  - [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]],
  - экспериментов из [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]].  
- Постепенно добавить:
  - CI/CD для развёртывания,  
  - простой слой ML-анализаторов.

## Контекст / зачем мне этот проект

- Песочница, где можно пробовать идеи из Sage без риска для продакшена.  
- Витрина навыков: Flink, Kafka, ClickHouse, observability, CI/CD.  
- Мост между SRE-опытом и будущим MLOps-проектом.

## Основные результаты, которые хочу получить

- Репозиторий с понятным README, схемой архитектуры и примерами запросов.  
- Набор метрик и дашбордов, которыми можно гордиться.  
- Подложку для ML-анализаторов и A-level статьи по логам.

## Связано

- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
- [[02_Projects/sage_observability/README|Sage Observability]]
- [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]]

- [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]
