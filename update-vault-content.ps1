# update-vault-content.ps1
# Скрипт перезаписывает ключевые заметки в Obsidian-вольте актуальным содержимым.
# Положи файл в корень вольта (там, где README.md) и запускай из PowerShell:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\update-vault-content.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Note {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $path = Join-Path $root $RelativePath
    $dir  = Split-Path $path -Parent

    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    $Content | Set-Content -LiteralPath $path -Encoding UTF8
    Write-Host "Updated $RelativePath"
}

# =========================
# README
# =========================

Write-Note "README.md" @'
# Личный Obsidian Vault Радмира

Это моя личная «операционная система» — место, где соединяются работа, обучение, исследования, книги, проекты и долгосрочные планы.

Все знания постепенно превращаются в капитал: профессиональный, исследовательский, культурный — и жизненный.

---

## Что это решает

- расфокус в задачах и проектах  
- потерю идей и мыслей  
- хаос в разных сервисах  
- отсутствие общего направления  

Vault помогает держать **долгую траекторию**, не теряя мелких шагов.

---

## Главная цель

Собрать в одном месте всё, что я:

- изучаю  
- делаю  
- строю  
- читаю  
- исследую  
- планирую  

…и превращать это в **живую систему знаний**, а не в забытые заметки.

---

## Структура

```text
00_Inbox          — входящие заметки, черновики, быстрые мысли
01_Knowledge      — знания по темам (SRE, ML, Blockchain, культура и т.д.)
02_Projects       — личные и рабочие проекты
03_Work & Career  — работа, задачи, достижения, планы по карьере
04_Research       — исследования, статьи, эксперименты
05_Reading        — книги, статьи, конспекты, цитаты
06_Life           — дневник, цели, финансы, долгосрочные планы
Templates         — шаблоны заметок
Attachments       — вложения (картинки, pdf, схемы)
```

---

## Главные входные точки

- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[01_Knowledge/Blockchain/Index|Blockchain — Index]]
- [[01_Knowledge/Culture & History/Index|Culture & History — Index]]

- [[02_Projects/sage_observability/README|Проект: Sage Observability]]
- [[02_Projects/nginx_log_analyzer/README|Проект: Nginx Log Analyzer]]
- [[02_Projects/mlops_log_anomaly_detection/README|Проект: MLOps: Log Anomaly Detection]]
- [[02_Projects/familytree_ocr_tatar/README|Проект: FamilyTree OCR (Tatar)]]
- [[02_Projects/personal_brand_and_portfolio/README|Проект: Personal Brand & Portfolio]]
- [[02_Projects/ai/README|Проект: AI Sandbox]]

- [[03_Work & Career/T-Bank SRE/Overview|Работа: T-Bank SRE (Sage)]]
- [[03_Work & Career/HSE AI Master/Overview|Учёба: HSE AI Master]]
- [[03_Work & Career/MIPT Blockchain/Overview|Учёба: MIPT Blockchain]]

- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]
- [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|Эксперимент: оптимизация хранения в OpenSearch]]

- [[06_Life/Five-Year-Plan|План на 5 лет]]
- [[06_Life/Countries-and-Relocation|Страны и переезд]]
- [[06_Life/Journal-2025|Журнал 2025]]

---

## Ритуал использования

Каждый день:

- 3–5 быстрых заметок в **00_Inbox**  
- 1 мысль превращаю в отдельную заметку в **01_Knowledge**  
- 1 маленький шаг по работе / проекту / будущему  

Каждую неделю — ревизия активных проектов в **02_Projects**.  
Каждый месяц — ревизия планов в **03_Work & Career** и **06_Life**.

---

## Идея

Это не набор файлов.  
Это **память будущего** — траектория от SRE и AI к своим большим проектам.
'@

# =========================
# 01_Knowledge
# =========================

Write-Note "01_Knowledge/SRE & Observability/Index.md" @'
# SRE & Observability — Index

## Основные темы

- Метрики (Prometheus, RED/USE, SLO/SLI, latency/throughput/errors)
- Логи (OpenSearch / Elasticsearch, внутренняя платформа Sage)
- Трейсинг и распределённые запросы
- Алерты, инциденты, on-call, пост-мортемы
- Оптимизация хранения (sort, forcemerge, mapping, экономия места)

## Связанные проекты и заметки

- [[02_Projects/sage_observability/README|Проект: Sage Observability]]
- [[02_Projects/nginx_log_analyzer/README|Проект: Nginx Log Analyzer]]
- [[02_Projects/mlops_log_anomaly_detection/README|Проект: MLOps: Log Anomaly Detection]]

- [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE — роль и домен]]
- [[03_Work & Career/T-Bank SRE/Learning-Plan|План развития в SRE]]
- [[03_Work & Career/T-Bank SRE/Tasks-Backlog|Backlog задач T-Bank SRE]]

- [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025: оптимизация хранения в OpenSearch]]
- [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]

## Что хочу выучить

- Уверенный PromQL, построение гистограмм и дашбордов
- Практику работы с большими кластерами OpenSearch (десятки петабайт логов)
- Правильный дизайн SLO/SLI для внутренних платформ уровня банка
- Построение self-healing сценариев на базе метрик и логов

## План обучения (черновой)

- Короткий горизонт: добить базу по Prometheus, алертам и Sage.
- Средний горизонт: отточить эксперименты с OpenSearch и оформить их как статью/доклад.
- Дальше: перейти от SRE к MLOps в домене логов.
'@

Write-Note "01_Knowledge/AI & ML/Index.md" @'
# AI & ML — Index

## Темы

- Базовый ML (классификация, регрессия, валидация, метрики)
- Deep Learning, архитектуры, регуляризация
- LLM и агентные системы
- MLOps (pipelines, мониторинг моделей, drift, прод)

## Связанные проекты и заметки

- [[03_Work & Career/HSE AI Master/Overview|HSE AI Master — программа]]
- [[02_Projects/ai/README|Проект: AI Sandbox]]
- [[02_Projects/mlops_log_anomaly_detection/README|Проект: MLOps: Log Anomaly Detection]]
- [[02_Projects/familytree_ocr_tatar/README|Проект: FamilyTree OCR (Tatar)]]

- [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]]
- [[04_Research/Ideas/IDEA-turkic-ocr-genealogy|IDEA — OCR/NER для тюркских текстов и генеалогии]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]

## План обучения

- Использовать курсы HSE/MIPT как основу, а проекты из `02_Projects` как практику.
- Сфокусироваться на связке **ML для логов** и **MLOps в проде**.
- Отдельно вести список статей в [[05_Reading/Papers-To-Read|Papers to Read]].
'@

Write-Note "01_Knowledge/Blockchain/Index.md" @'
# Blockchain — Index

## Темы

- Консенсус и game theory
- Ethereum / EVM, смарт-контракты
- DLT, L2, rollups
- Экономика протоколов, токеномика

## Связанные проекты и заметки

- [[03_Work & Career/MIPT Blockchain/Overview|MIPT Blockchain — программа]]
- [[02_Projects/ai/README|AI Sandbox]]

## Идеи проектов

- LLM-агент для анализа транзакций в блокчейне на естественном языке
- Инструменты наблюдаемости для блокчейн-нод (SRE + blockchain)
'@

Write-Note "01_Knowledge/Culture & History/Index.md" @'
# Culture & History — Index

## Направления

- Немецкая культура (музыка, философия, литература)
- Античность (греческая традиция)
- Персидская и индийская традиции
- Тюркский мир, татары, тенгрианство

## Связанные проекты и заметки

- [[02_Projects/familytree_ocr_tatar/README|Проект: FamilyTree OCR (Tatar)]]
- [[04_Research/Ideas/IDEA-turkic-ocr-genealogy|IDEA — тюркский OCR и генеалогия]]
- [[06_Life/Countries-and-Relocation|Страны и переезд]]

## Список того, что хочу прочитать / пересмотреть

- Немецкая классика (музыка, философия, литература)
- Античные тексты, связанные с политией и городами
- Персидские и индийские эпосы
- Источники по истории татар и тюркских народов
'@

# =========================
# 02_Projects — READMEs
# =========================

Write-Note "02_Projects/sage_observability/README.md" @'
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
'@

Write-Note "02_Projects/nginx_log_analyzer/README.md" @'
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
'@

Write-Note "02_Projects/mlops_log_anomaly_detection/README.md" @'
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
'@

Write-Note "02_Projects/familytree_ocr_tatar/README.md" @'
# FamilyTree OCR (Tatar)

#tags #project #research

## Статус

**0/10** — концепт и желание, нет реализованного кода. Нужен внятный roadmap.

## Описание

Проект по автоматическому построению семейных деревьев татар из исторических архивов:

- OCR старых документов (в т.ч. на арабской графике);  
- транслитерация в современную орфографию;  
- NER (имена, родственные связи, топонимы);  
- record linkage и сборка графа родства;  
- визуализация семейного дерева.

## Цели

- Собрать работающий прототип: от скана до графа родства.  
- Протестировать разные подходы к OCR/NER для тюркских текстов.  
- Подготовить основу для научной работы (статья, магистерская).

## Контекст / зачем мне этот проект

- Личный корневой интерес: татары, тюркский мир, тенгрианство.  
- Возможность соединить AI/ML, NLP и историю/культуру.  
- Потенциально социально значимый проект для семей и диаспор.

## Первичный план

1. Собрать и описать источники данных (архивы, примеры документов).  
2. Сформировать минимальный набор размеченных примеров.  
3. Подобрать и протестировать OCR-модели.  
4. Сделать первый прототип NER/связей.  
5. Оформить исследовательский план в рамках [[03_Work & Career/HSE AI Master/Overview|HSE AI Master]].

## Связано

- [[04_Research/Ideas/IDEA-turkic-ocr-genealogy|IDEA — OCR/NER для тюркских текстов и генеалогии]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[01_Knowledge/Culture & History/Index|Culture & History — Index]]
- [[03_Work & Career/HSE AI Master/Overview|HSE AI Master — учёба]]
'@

Write-Note "02_Projects/personal_brand_and_portfolio/README.md" @'
# Personal Brand & Portfolio

#tags #project #career

## Статус

**3/10** — часть репозиториев уже есть, но структура и подача ещё сырые.  
Нужно оформить историю и подтянуть ключевые проекты.

## Описание

Проект про публичное лицо и техническое портфолио:

- GitHub / GitLab репозитории (SRE, MLOps, AI, Blockchain);  
- оформление README, pinned-репы, релизы;  
- CV, профиль (LinkedIn/аналог), страницы с проектами;  
- история: как из Intern SRE в Sage вырастаю в MLOps/AI-инженера.

## Цели

- Сделать портфолио, которое честно отражает уровень и траекторию.  
- Быть готовым к выходу на международный рынок (remote / релокация).  
- Связать карьерные цели, исследования и личные проекты в одну историю.

## Контекст / зачем мне этот проект

- Основа для будущих офферов (Россия / Европа / США / Азия / страны залива).  
- Витрина для проектов [[02_Projects/sage_observability/README|Sage Observability]],  
  [[02_Projects/nginx_log_analyzer/README|Nginx Log Analyzer]],  
  [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]],  
  [[02_Projects/familytree_ocr_tatar/README|FamilyTree OCR (Tatar)]].  
- Связан с планами по переезду, капиталу и семьёй.

## Основные результаты

- Обновлённое CV и профиль с фокусом на SRE/MLOps.  
- 3–5 ключевых репозиториев с грамотными README и демками.  
- Краткая «биография траектории» для About-страницы.

## Связано

- [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE — текущая роль]]
- [[03_Work & Career/HSE AI Master/Overview|HSE AI Master]]
- [[03_Work & Career/MIPT Blockchain/Overview|MIPT Blockchain]]

- [[06_Life/Five-Year-Plan|План на 5 лет]]
- [[06_Life/Countries-and-Relocation|Страны и переезд]]

- [[05_Reading/Reading-List-2025|Reading List 2025]]
'@

Write-Note "02_Projects/ai/README.md" @'
# AI Sandbox

#tags #project #ai

## Описание

Общий «песочничный» проект под эксперименты по AI/ML, которые не тянут на отдельный крупный проект:

- домашки и курсовые по HSE AI Master;  
- небольшие эксперименты с моделями, агентами, фреймворками;  
- прототипы, которые потом могут вырасти в отдельные проекты.

## Цели

- Иметь одно место, где складываются все мелкие AI-штуки.  
- Не засорять крупные проекты быстрыми экспериментами.  
- Вытаскивать удачные идеи в отдельные репозитории/проекты.

## Связано

- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[03_Work & Career/HSE AI Master/Overview|HSE AI Master — учёба]]
- [[05_Reading/Papers-To-Read|Papers to Read]]
'@

# =========================
# 03_Work & Career
# =========================

Write-Note "03_Work & Career/T-Bank SRE/Overview.md" @'
# T-Bank — SRE (Sage)

## Роль

- Intern SRE в команде Sage, **домен Logs**.

## Команда / домен

- Платформа Sage Observability для логов и метрик (внутренний аналог Splunk/Datadog).  
- Основной фокус — хранение, поиск и анализ логов, оптимизация стоимости и надёжности.

## Основные зоны ответственности

- Поддержка и развитие observability-стека (логи, метрики, дашборды, алерты).  
- Участие в on-call, диагностика инцидентов, разбор пост-мортемов.  
- Эксперименты по оптимизации хранения логов в OpenSearch (sort, forcemerge, mapping).  
- Настройка экспортеров, сбор метрик и интеграция с Kubernetes-сервисами.

## Ключевые технологии

- OpenSearch / Elasticsearch  
- Prometheus / Grafana / Sage  
- Kubernetes, Helm  
- Vector, экспортеры (MySQL и др.)  
- GitLab, CI/CD

## Связано

- [[02_Projects/sage_observability/README|Проект: Sage Observability]]
- [[03_Work & Career/T-Bank SRE/Learning-Plan|План развития в SRE]]
- [[03_Work & Career/T-Bank SRE/Tasks-Backlog|Backlog задач]]
- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
- [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025: оптимизация хранения в OpenSearch]]
'@

Write-Note "03_Work & Career/T-Bank SRE/Learning-Plan.md" @'
# План развития в SRE

## На ближайшие 3 месяца

- Добить базу по Prometheus и PromQL (гистограммы, rate, quantile, RED/USE).  
- Привести в порядок дашборды и алерты по ключевым сервисам Sage.  
- Оформить эксперимент [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025]] в читаемый документ.

## На год

- Перейти от Intern к стабильному уровню Junior SRE в домене Sage Logs.  
- Запустить минимум один серьёзный улучшайзинг (экономия места, стабилизация SLA, улучшение алертинга).  
- Начать MLOps-ветку на базе [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]].

## Навыки, которые хочу подтянуть

- PromQL / метрики / SLO.  
- OpenSearch / схема индекса, sort, forcemerge, экономия хранилища.  
- Kubernetes / Helm / деплой observability-сервисов.  
- MLOps / ML для логов.

## Связано

- [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE — обзор]]
- [[02_Projects/sage_observability/README|Sage Observability]]
- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
'@

Write-Note "03_Work & Career/T-Bank SRE/Tasks-Backlog.md" @'
# Backlog задач — T-Bank SRE

## Текущие задачи

- [ ] Доделать и задокументировать эксперименты по OpenSearch (sort + forcemerge + mapping).  
- [ ] Пересмотреть ключевые алерты по Sage: шум, чувствительность, приоритизация.  
- [ ] Навести порядок в дашбордах для основных сервисов.

## Идеи улучшений

- [ ] Сценарии self-healing на основе метрик и логов.  
- [ ] Стандартизировать подход к индексам (шаблоны, naming, срок хранения).  
- [ ] Подготовить внутренний гайд/лекцию по экономии хранилища.

## Долгосрочные инициативы

- [ ] Связать эксперимент [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025]] с продуктовыми решениями по стоимости.  
- [ ] Закладывать инфраструктуру под [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]].  
- [ ] Использовать этот опыт как базу для [[04_Research/Papers/PaperRoadmap-A-level-mlops|A-level статьи]].
'@

Write-Note "03_Work & Career/HSE AI Master/Overview.md" @'
# НИУ ВШЭ — магистратура AI (Research & Entrepreneurship in AI)

## Программа

- Магистратура по искусственному интеллекту с акцентом на исследования и предпринимательство.  
- Фокус: соединить глубину в AI/ML с умением запускать проекты и продукты.

## Курсы и приоритеты (черновой список)

- Базовый и продвинутый ML / Deep Learning.  
- Курсы по исследовательской работе (статьи, эксперименты, A-уровень).  
- Курсы по предпринимательству и управлению в IT/AI.  

Особый интерес:

- MLOps / продовый ML;  
- обработка текстов (NLP, OCR, NER);  
- связка с реальными системами (Sage, лог-анализ).

## Как связать учёбу с работой и проектами

- Использовать опыт в [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE]] как «реальный прод»:  
  - [[02_Projects/sage_observability/README|Sage Observability]],  
  - [[02_Projects/nginx_log_analyzer/README|Nginx Log Analyzer]],  
  - [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]].  

- Для текстовой/культурной части — [[02_Projects/familytree_ocr_tatar/README|FamilyTree OCR (Tatar)]] и  
  [[04_Research/Ideas/IDEA-turkic-ocr-genealogy|IDEA — тюркский OCR и генеалогия]].

## Связано

- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[02_Projects/ai/README|AI Sandbox]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]
'@

Write-Note "03_Work & Career/MIPT Blockchain/Overview.md" @'
# МФТИ — блокчейн-направление

## Модули / курсы (9–10 семестр, черновой список)

- DLT и распределённые реестры.  
- Ethereum-платформа, EVM, смарт-контракты.  
- Игровая теория и консенсус-протоколы.  

## Что хочу вынести из программы

- Понимание того, как реально устроены блокчейн-системы.  
- Навык смотреть на протоколы через призму SRE (надёжность, масштабируемость) и экономики.  
- Идеи для будущих проектов на стыке SRE / Blockchain / AI.

## Идеи проектов на стыке SRE / Blockchain / AI

- Мониторинг и алертинг для блокчейн-нод и RPC-эндпоинтов.  
- LLM-агент для анализа транзакций и контрактов на естественном языке.  

## Связано

- [[01_Knowledge/Blockchain/Index|Blockchain — Index]]
- [[02_Projects/ai/README|AI Sandbox]]
- [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]]
'@

# =========================
# 04_Research
# =========================

Write-Note "04_Research/Experiments/EXP-2025-opensearch-storage-optimization.md" @'
# EXP-2025 — Оптимизация хранения в OpenSearch

## Контекст

- Платформа Sage Observability в T-Bank.  
- Логи и метрики → десятки петабайт данных.  
- Стоит задача уменьшить объём хранилища без потери функциональности поиска.

## Гипотеза

Комбинация:

- сортировки индексов (`index.sort.field = @timestamp` или `inst + @timestamp`),  
- `_forcemerge` до 1 сегмента на shard,  
- отказа от поля `all` и `copy_to: "all"`  

должна давать заметную экономию места и лучшее поведение поиска.

## План эксперимента (черновой)

1. Взять репрезентативные группы индексов (разный объём, разная однородность данных).  
2. Сделать копии индексов с разными сценариями (чистая копия, только sort, sort+forcemerge, без `all`).  
3. Измерить:
   - объём на диске;  
   - latency поиска;  
   - скорость индексации;  
   - нагрузку на кластер при операциях sort/forcemerge.  
4. Сравнить и зафиксировать выигрыш/проигрыш по каждому сценарию.  
5. Оформить выводы в документ и связать с потенциальной экономией денег.

## Метрики

- Объём на диске (GB/TB, относительная экономия в %).  
- Latency поиска (P50/P95/P99).  
- Скорость индексации (документов в секунду).  
- Нагрузка на кластер во время операций sort/forcemerge.

## Результаты (кратко, заполнить)

- На некоторых группах уже есть наблюдение экономии до ~37% места.  
- Сильный эффект в группах с высокой однородностью и без ранее применённого forcemerge.  
- …

## Выводы и решения (заполнять по мере эксперимента)

- Где сортировка реально окупается.  
- Для каких групп индексов достаточно forcemerge.  
- Где отказ от `all` даёт существенную экономию.

## Связано

- [[02_Projects/sage_observability/README|Sage Observability]]
- [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE — роль]]
- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]

- [[04_Research/Ideas/IDEA-mlops-logs-analyzer|IDEA — MLOps для анализа логов]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]
'@

Write-Note "04_Research/Ideas/IDEA-mlops-logs-analyzer.md" @'
# IDEA — MLOps для анализа логов

## Суть идеи

Использовать опыт SRE и эксперименты с OpenSearch/Sage, чтобы построить систему:

- которая собирает логи;  
- обучает модели аномалий;  
- деплоит их в прод;  
- и мониторит качество/дрейф.

## Проблема, которую решает

- Большие объёмы логов → сложно руками заметить аномалии.  
- Классический алертинг часто шумный или слепой.  
- Нужна связка: «SRE-интуиция + ML-модели + MLOps-процессы».

## Ближайшие шаги

1. Описать основные сценарии аномалий на основе Sage.  
2. Определить кандидатов на датасеты (Sage + Nginx Log Analyzer).  
3. Сформулировать несколько подходов к моделям.  
4. Связать идею с проектом [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]].

## Как это может вырасти в A-level статью

- Бэкграунд: реальный продовый кейс (банк, платформа логов).  
- Новизна: комбинация отличной SRE-практики и внятного MLOps-подхода.  
- Эксперимент: сравнение разных моделей/метрик на реальных логах.  
- Выводы: как строить ML-слой поверх существующей observability-платформы.

## Связано

- [[02_Projects/sage_observability/README|Sage Observability]]
- [[02_Projects/nginx_log_analyzer/README|Nginx Log Analyzer]]
- [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]]

- [[04_Research/Experiments/EXP-2025-opensearch-storage-optimization|EXP-2025: OpenSearch storage optimization]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]

- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
'@

Write-Note "04_Research/Ideas/IDEA-turkic-ocr-genealogy.md" @'
# IDEA — OCR / NER для тюркских текстов и генеалогии

## Суть идеи

Создать систему, которая:

- распознаёт старые татарские/тюркские документы (в т.ч. арабская графика);  
- переводит в машиночитаемый формат и транслитерирует;  
- извлекает сущности (люди, родственные связи, места, даты);  
- строит граф родства и визуализирует его.

## Источники данных (черновой список)

- Архивные метрические книги, ревизские сказки, списки.  
- Частные семейные архивы.  
- Публикации по истории татар и тюркских народов.

## Технологический стек (первичная идея)

- OCR: современные модели (Tesseract/TrOCR/др.), дообученные на нужных шрифтах.  
- NER: модели для русско-татарских/тюркских текстов.  
- Граф: Neo4j/graph-библиотеки + визуализация.

## Потенциальные результаты

- Прототип пайплайна и датасет размеченных документов.  
- Визуальные семейные деревья.  
- Научная статья / магистерская / публичный сервис для диаспор.

## Риски и сложности

- Качество исходных документов.  
- Нехватка размеченных данных для OCR/NER.  
- Исторические варианты имён и орфографии.

## Связано

- [[02_Projects/familytree_ocr_tatar/README|Проект: FamilyTree OCR (Tatar)]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[01_Knowledge/Culture & History/Index|Culture & History — Index]]
- [[03_Work & Career/HSE AI Master/Overview|HSE AI Master]]
'@

Write-Note "04_Research/Papers/PaperRoadmap-A-level-mlops.md" @'
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
'@

# =========================
# 05_Reading
# =========================

Write-Note "05_Reading/Reading-List-2025.md" @'
# Reading List 2025

## Книги (тех / non-fiction)

- [ ] SRE / DevOps / Observability (Google SRE, Site Reliability Workbook и т.п.)  
- [ ] Книги по MLOps и продовому ML.  
- [ ] Книги по архитектуре распределённых систем.  

## Художественное / культура

- [ ] Классическая литература и пьесы из списка Ежи Сармата  
      (перенести сюда конкретные названия, когда будет время).  
- [ ] Немецкая литература / философия, которая мне заходит.  
- [ ] Античная литература (Греция).  
- [ ] Персидские и индийские тексты, эпосы.  

## Театр

- [ ] Постановки по классике из списка Ежи Сармата (записать конкретные спектакли).  
- [ ] Опера / классический театр, который хочу увидеть вживую.

## Связано

- [[01_Knowledge/Culture & History/Index|Culture & History — Index]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]]
'@

Write-Note "05_Reading/Reading-List-2025.md" @'
# Reading List 2025

## Книги (тех / non-fiction)

- [ ] SRE / DevOps / Observability (Google SRE, Site Reliability Workbook и т.п.)  
- [ ] Книги по MLOps и продовому ML.  
- [ ] Книги по архитектуре распределённых систем.  

## Художественное / культура

- [ ] Классическая литература и пьесы из списка Ежи Сармата  
      (перенести сюда конкретные названия, когда будет время).  
- [ ] Немецкая литература / философия, которая мне заходит.  
- [ ] Античная литература (Греция).  
- [ ] Персидские и индийские тексты, эпосы.  

## Театр

- [ ] Постановки по классике из списка Ежи Сармата (записать конкретные спектакли).  
- [ ] Опера / классический театр, который хочу увидеть вживую.

## Связано

- [[01_Knowledge/Culture & History/Index|Culture & History — Index]]
- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]]
'@

Write-Note "05_Reading/Papers-To-Read.md" @'
# Papers to Read

## MLOps / SRE / Observability

- [ ] Статьи про хранение логов в Elasticsearch/OpenSearch (sort, forcemerge, storage optimization).  
- [ ] Работы по anomaly detection в логах.  
- [ ] Кейсы по MLOps в больших компаниях (банки, BigTech).

## AI / ML

- [ ] Статьи по drift detection и мониторингу моделей.  
- [ ] Работы по OCR/NER для сложных языков и письменностей  
      (полезно для [[02_Projects/familytree_ocr_tatar/README|FamilyTree OCR (Tatar)]]).

## Blockchain

- [ ] Статьи по консенсусу и game-theoretic анализу протоколов.

## Связано

- [[01_Knowledge/AI & ML/Index|AI & ML — Index]]
- [[01_Knowledge/SRE & Observability/Index|SRE & Observability — Index]]
- [[01_Knowledge/Blockchain/Index|Blockchain — Index]]
- [[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]
'@

# =========================
# 06_Life
# =========================

Write-Note "06_Life/Journal-2025.md" @'
# Журнал 2025

## Пример формата записи

### {{DATE}}

* Что произошло:
* Настроение:
* Мысли:
* Маленький шаг вперёд (работа/учёба/жизнь):

---

## {{DATE}}

* Что произошло:
* Настроение:
* Мысли:
* Маленький шаг вперёд:
'@

Write-Note "06_Life/Five-Year-Plan.md" @'
# План на 5 лет

Горизонт: **3–5 лет** вперёд.  
Параллельно держу в голове цель: **к 30 годам — своя квартира и первые дети**.

## Карьера

- Закрепиться в T-Bank Sage как уверенный Middle SRE в домене Logs.  
- Постепенно сместить фокус к MLOps / ML-инженерии (на базе лог-проектов).  
- Иметь портфолио [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]], достаточное для выхода на международный рынок.

## Учёба / степени

- Закончить магистратуру [[03_Work & Career/HSE AI Master/Overview|HSE AI Master]].  
- Дотянуть исследование по логам и MLOps до **A-level статьи**  
  ([[04_Research/Papers/PaperRoadmap-A-level-mlops|Roadmap A-level статьи по MLOps]]).  
- Продвинуть:
  - [[02_Projects/familytree_ocr_tatar/README|FamilyTree OCR (Tatar)]],  
  - [[02_Projects/mlops_log_anomaly_detection/README|MLOps: Log Anomaly Detection]]  
    хотя бы до уровня рабочих прототипов.

## Место жительства / страны

- Краткосрочно: база в России (Москва / при необходимости Казань).  
- Среднесрочно: рассматривать варианты:
  - работа на США/Европу из РФ/СНГ,  
  - релокация через оффер или учёбу (Европа / США / Азия / страны залива).
- Детализация и сценарии — в [[06_Life/Countries-and-Relocation|Страны и переезд]].

## Деньги и капитал

- За 3–5 лет выйти на уровень дохода, который позволяет:
  - стабильно откладывать на капитал/квартиру,  
  - поддерживать нормальный уровень жизни и семьи.  
- Планировать накопления и расходы в [[06_Life/Finance/Budget-2025|Budget 2025]] и последующих годах.  
- Держать в голове цель: **к 30 годам — квартира + стартовый капитал для семьи и своих проектов**.

## Семья и жизнь

- К 30 годам — первые дети, устойчивый быт и базовая финансовая подушка.  
- Не превращать карьеру в единственную ось — оставлять место для жизни, культуры, путешествий.

## Связано

- [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE — работа]]
- [[03_Work & Career/HSE AI Master/Overview|HSE AI Master]]
- [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]]
- [[06_Life/Countries-and-Relocation|Страны и переезд]]
- [[06_Life/Finance/Budget-2025|Budget 2025]]
'@

Write-Note "06_Life/Countries-and-Relocation.md" @'
# Страны и переезд

## Куда хочу потенциально

- **США** — максимальный потолок дохода и карьерного роста в IT (SRE/MLOps).  
- **Европа** (Германия, Нидерланды, Северная Европа и др.) — баланс уровня жизни и работы.  
- **Страны залива** (ОАЭ и др.) — высокий доход, но сложнее с укоренением.  
- **Азия / Сингапур** — технологические центры и финансовые хабы.  
- **СНГ** (Казахстан, Кавказ) — возможная база для работы на США/Европу.

## Форматы

- Работать на США/Европу **из России/СНГ**.  
- Работать на Европу из Европы.  
- Работать на США/Европу из «нейтральной» страны (Казахстан, ОАЭ и т.п.).

## Требования (виза, язык, карьерный уровень)

- Уровень: не ниже уверенного Middle SRE / MLOps.  
- Английский: уверенный рабочий (B2+/C1).  
- Портфолио: живые проекты (Sage, Nginx, MLOps, OCR), статьи/доклады.  
- Для некоторых стран — желание/возможность получать вид на жительство и потом гражданство.

## План по шагам (черновой)

1. 3–5 лет качать карьеру и проекты в T-Bank / HSE / своих репах.  
2. Собрать портфолио [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]] и A-level статью.  
3. Подтянуть английский до стабильного уровня собеседований.  
4. Начать точечно откликаться на вакансии (remote / релокация) и/или смотреть программы учёбы/PhD.  
5. Исходя из офферов и семейных планов — выбирать страну/город.

## Связано

- [[06_Life/Five-Year-Plan|План на 5 лет]]
- [[03_Work & Career/T-Bank SRE/Overview|T-Bank SRE]]
- [[03_Work & Career/HSE AI Master/Overview|HSE AI Master]]
- [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]]
'@

Write-Note "06_Life/Finance/Budget-2025.md" @'
# Бюджет 2025

## Доходы

- Зарплата / стажировка T-Bank SRE.  
- Возможные подработки / проекты.

## Обязательные расходы

- Жильё, питание, транспорт.  
- Учёба, обучение, книги/курсы.

## Инвестиции / накопления

- Резерв на 3–6 месяцев жизни.  
- Накопления на капитал/квартиру.  
- Инвестиции (структуру можно расписать отдельно).

## Цели по капиталу

- Чётко сформулировать целевой капитал для квартиры.  
- Связать финансовые цели с карьерным ростом (Junior → Middle → Senior).

## Связано

- [[06_Life/Five-Year-Plan|План на 5 лет]]
- [[02_Projects/personal_brand_and_portfolio/README|Personal Brand & Portfolio]]
'@

# =========================
# Templates
# =========================

Write-Note "Templates/Daily Note.md" @'
# {{DATE}}

## Главное за день

*

## Работа / учёба

*

## Проекты

*

## Мысли / инсайты

*

## Самочувствие

*

## Завтра

*

#tags #daily
'@

Write-Note "Templates/Project.md" @'
# {{PROJECT_NAME}}

## Описание

Кратко, что это за проект и зачем он мне.

## Цели

*

## Контекст

*

## План / Roadmap

*

## Связано

*

#tags #project
'@

Write-Note "Templates/Book Note.md" @'
# {{BOOK_TITLE}}, {{AUTHOR}}

## О чём книга

*

## Главные идеи

*

## Цитаты

*

## Как применить в жизни / работе

*

#tags #reading #book
'@

Write-Note "Templates/Paper Note.md" @'
# {{PAPER_TITLE}}

## Базовая информация

- Авторы:
- Год:
- Где опубликовано:
- Ссылка:

## Основные идеи

*

## Полезные выводы для меня

*

## Вопросы / идеи

*

#tags #research #paper
'@

Write-Host "=== Все выбранные файлы обновлены ==="