# init-vault.ps1
# Run from the root of your Obsidian vault (git repo)

$folders = @(
    "00_Inbox",
    "01_Knowledge",
    "02_Projects",
    "03_Work & Career",
    "04_Research",
    "05_Reading",
    "06_Life",
    "Templates",
    "Attachments"
)

foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
    }
}

# Simple templates
$templates = @{
    "Templates\Daily Note.md" = @"
# {{DATE}}

## Итоги дня
- 

## Сделано
- 

## Мысли
- 

## Ссылки / заметки
- 
"@

    "Templates\Project.md" = @"
# {{PROJECT_NAME}}

## Описание
Кратко, что это за проект.

## Цели
- 

## План / Roadmap
- 

## Журнал
- 
"@

    "Templates\Paper Note.md" = @"
# {{PAPER_TITLE}}

## Базовая информация
- Авторы:
- Год:
- Где опубликовано:

## Основные идеи
- 

## Полезные выводы для меня
- 

## Вопросы / идеи
- 
"@

    "Templates\Book Note.md" = @"
# {{BOOK_TITLE}}, {{AUTHOR}}

## О чём книга
- 

## Главные идеи
- 

## Цитаты
- 

## Как применить в жизни / работе
- 
"@
}

foreach ($path in $templates.Keys) {
    if (-not (Test-Path $path)) {
        $dir = Split-Path $path
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
        $templates[$path] | Out-File -FilePath $path -Encoding UTF8
    }
}

# Basic README
if (-not (Test-Path "README.md")) {
@"
# Личный Obsidian Vault

Личная база знаний, проектов и исследований.
"@ | Out-File -FilePath "README.md" -Encoding UTF8
}

Write-Host "Done. Obsidian vault structure created."
