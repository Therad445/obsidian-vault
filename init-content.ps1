# init-content.ps1
# Adds ready-to-use files and project skeletons to the vault

function New-FileIfMissing {
    param(
        [string]$Path,
        [string]$Content
    )
    if (-not (Test-Path $Path)) {
        $dir = Split-Path $Path
        if ($dir -and -not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
        $Content | Out-File -FilePath $Path -Encoding UTF8
    }
}

# --- Helper: ensure folder ---
function Ensure-Folder {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

# ---------- 02_Projects: key projects ----------

$projects = @(
    @{ slug = "sage_observability";      title = "Sage Observability";        domain = "sre" },
    @{ slug = "nginx_log_analyzer";      title = "Nginx Log Analyzer";        domain = "sre" },
    @{ slug = "familytree_ocr_tatar";    title = "FamilyTree OCR (Tatar)";    domain = "research" },
    @{ slug = "mlops_log_anomaly_detection"; title = "MLOps: Log Anomaly Detection"; domain = "mlops" },
    @{ slug = "personal_brand_and_portfolio"; title = "Personal Brand & Portfolio";   domain = "career" }
)

foreach ($p in $projects) {
    $projectPath = Join-Path "02_Projects" $p.slug
    Ensure-Folder $projectPath

    $tagLine = "#tags #project #" + $p.domain

    New-FileIfMissing (Join-Path $projectPath "README.md") @"
# $($p.title)

$tagLine

## Описание
- 

## Цели
- 

## Контекст / зачем мне этот проект
- 

## Основные результаты, которые хочу получить
- 
"@

    New-FileIfMissing (Join-Path $projectPath "Roadmap.md") @"
# Roadmap — $($p.title)

## Ближайшие 3 месяца
- 

## 3–6 месяцев
- 

## Дальше
- 
"@

    New-FileIfMissing (Join-Path $projectPath "Tasks.md") @"
# Tasks — $($p.title)

## Backlog
- [ ] 

## In progress
- [ ] 

## Done
- [ ] 
"@

    New-FileIfMissing (Join-Path $projectPath "Diary.md") @"
# Diary — $($p.title)

## {{DATE}}
- Что сделал:
- Мысли:
- Что дальше:
"@

    New-FileIfMissing (Join-Path $projectPath "Notes.md") @"
# Notes — $($p.title)

Свободные заметки по проекту.
"@
}

# ---------- 03_Work & Career ----------

Ensure-Folder "03_Work & Career\T-Bank SRE"
Ensure-Folder "03_Work & Career\HSE AI Master"
Ensure-Folder "03_Work & Career\MIPT Blockchain"

New-FileIfMissing "03_Work & Career\T-Bank SRE\Overview.md" @"
# T-Bank — SRE (Sage)

## Роль
- 

## Команда / домен
- 

## Основные зоны ответственности
- 

## Ключевые сервисы / системы
- 
"@

New-FileIfMissing "03_Work & Career\T-Bank SRE\Tasks-Backlog.md" @"
# Backlog задач — T-Bank SRE

## Текущие задачи
- [ ] 

## Идеи улучшений
- [ ] 

## Долгосрочные инициативы
- [ ] 
"@

New-FileIfMissing "03_Work & Career\T-Bank SRE\Learning-Plan.md" @"
# План развития в SRE

## На ближайшие 3 месяца
- 

## На год
- 

## Навыки, которые хочу подтянуть
- PromQL / метрики
- OpenSearch / индексы
- Kubernetes / Helm
- MLOps / ML для логов
"@

New-FileIfMissing "03_Work & Career\HSE AI Master\Overview.md" @"
# НИУ ВШЭ — магистратура AI

## Программа
- 

## Курсы и приоритеты
- 

## Как связать учёбу с работой и проектами
- 
"@

New-FileIfMissing "03_Work & Career\MIPT Blockchain\Overview.md" @"
# МФТИ — блокчейн-направление

## Модули / курсы
- 

## Что хочу вынести из программы
- 

## Идеи проектов на стыке SRE / Blockchain / AI
- 
"@

# ---------- 04_Research ----------

Ensure-Folder "04_Research\Experiments"
Ensure-Folder "04_Research\Ideas"
Ensure-Folder "04_Research\Papers"

New-FileIfMissing "04_Research\Experiments\EXP-2025-opensearch-storage-optimization.md" @"
# EXP-2025 — Оптимизация хранения в OpenSearch

## Контекст
- Кластер / индексы:
- Текущие проблемы (объём, стоимость, latency):

## Гипотеза
- 

## План эксперимента
1) 
2) 
3) 

## Метрики
- Объём на диске
- Latency поиска
- Скорость индексации

## Результаты
- 

## Выводы и решения
- 
"@

New-FileIfMissing "04_Research\Ideas\IDEA-mlops-logs-analyzer.md" @"
# IDEA — MLOps для анализа логов

## Суть идеи
- 

## Проблема, которую решает
- 

## Ближайшие шаги
- 

## Как это может вырасти в A-level статью
- 
"@

New-FileIfMissing "04_Research\Ideas\IDEA-turkic-ocr-genealogy.md" @"
# IDEA — OCR / NER для тюркских текстов и генеалогии

## Суть идеи
- 

## Источники данных (архивы, документы)
- 

## Технологический стек
- OCR:
- NER:
- Граф родства:

## Потенциальные результаты
- 

## Риски и сложности
- 
"@

New-FileIfMissing "04_Research\Papers\PaperRoadmap-A-level-mlops.md" @"
# Roadmap — A-level статья по MLOps / логам

## Возможные направления
- Лог-анализ и аномалии
- Self-healing системы
- Drift detection в проде

## Что уже есть у меня
- Опыт в SRE / Sage
- Эксперимент с OpenSearch

## Что надо добрать
- 

## План по шагам
1) 
2) 
3) 
"@

# ---------- 05_Reading ----------

New-FileIfMissing "05_Reading\Reading-List-2025.md" @"
# Reading List 2025

## Книги
- [ ] 

## Нон-фикшн / тех
- [ ] 

## Художественное
- [ ] 
"@

New-FileIfMissing "05_Reading\Papers-To-Read.md" @"
# Papers to Read

## MLOps / SRE / Observability
- [ ] 

## AI / ML
- [ ] 

## Blockchain
- [ ] 
"@

# ---------- 06_Life ----------

Ensure-Folder "06_Life\Finance"

New-FileIfMissing "06_Life\Journal-2025.md" @"
# Журнал 2025

## {{DATE}}
- Что произошло:
- Настроение:
- Мысли:
"@

New-FileIfMissing "06_Life\Five-Year-Plan.md" @"
# План на 5 лет

## Карьера
- 

## Учёба / степени
- 

## Место жительства / страны
- 

## Деньги и капитал
- 
"@

New-FileIfMissing "06_Life\Countries-and-Relocation.md" @"
# Страны и переезд

## Куда хочу потенциально
- 

## Требования (виза, язык, карьерный уровень)
- 

## План по шагам
- 
"@

New-FileIfMissing "06_Life\Finance\Budget-2025.md" @"
# Бюджет 2025

## Доходы
- 

## Обязательные расходы
- 

## Инвестиции / накопления
- 

## Цели по капиталу
- 
"@

# ---------- 01_Knowledge: index notes ----------

New-FileIfMissing "01_Knowledge\SRE & Observability\Index.md" @"
# SRE & Observability — Index

## Основные темы
- Метрики (Prometheus, RED/USE, SLO)
- Логи (OpenSearch / Elasticsearch, Sage)
- Трейсинг
- Алерты и инциденты

## Важные ссылки / заметки
- 

## Что хочу выучить
- 
"@

New-FileIfMissing "01_Knowledge\AI & ML\Index.md" @"
# AI & ML — Index

## Темы
- Базовый ML
- Deep Learning
- LLM
- MLOps

## Связанные проекты
- 

## План обучения
- 
"@

New-FileIfMissing "01_Knowledge\Blockchain\Index.md" @"
# Blockchain — Index

## Темы
- Консенсус / game theory
- Ethereum / EVM
- DLT / L2

## Идеи проектов
- 
"@

New-FileIfMissing "01_Knowledge\Culture & History\Index.md" @"
# Culture & History — Index

## Направления
- Немецкая культура
- Античность
- Персидская / индийская традиция
- Тюркский мир

## Список того, что хочу прочитать / пересмотреть
- 
"@

Write-Host "Done. Content skeleton created."
