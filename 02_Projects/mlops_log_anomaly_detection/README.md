# MLOps: Log Anomaly Detection

#tags #project #mlops

## Статус

**0/10** — проект пока на уровне идеи и связок, нужен полноценный план.  
Опора: реальные логи и инфраструктура из Sage + Nginx Log Analyzer.

## Описание

Проект на стыке SRE и ML: построение пайплайна для выявления аномалий в логах и мониторинга моделей в проде.

Планируемая цепочка:

1. Сбор и подготовка логов (Sage / Nginx Log Analyzer).  
2. Обучение и валидация моделей аномалий.  
3. Деплой моделей.  
4. Мониторинг качества, drift, алерты.

## Цели

- Собрать end-to-end MLOps-пайплайн для лог-данных.  
- Сравнить несколько подходов к аномалиям (статистика, классический ML, deep).  
- Получить экспериментальную базу для [[04_Research/Papers/PaperRoadmap-A-level-mlops|A-level статьи по MLOps]].

## Контекст / зачем мне этот проект

- Логичное продолжение пути от **SRE (Sage Logs)** к **MLOps**.  
- Способ упаковать реальный продовый опыт в научный и карьерный результат.  
- Важный кусок будущего позиционирования (SRE → MLOps/ML engineer).

## Первичный план

1. Описать сценарии аномалий, которые реально болят в Sage / Nginx.  
2. Выделить несколько датасетов логов (анонимизированных) под эксперименты.  
3. Поднять минимальный ML-pipeline (offline) с метриками качества.  
4. Сделать прототип онлайн-интеграции (алерт/score).  
5. Оформить результаты в виде статьи/отчёта.

## Связано

- [[02_Projects/sage_observability/README|Sage Observability]]
- [[02_Projects/nginx_log_analyzer/README|Nginx Log Analyzer]]

- [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]

- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
