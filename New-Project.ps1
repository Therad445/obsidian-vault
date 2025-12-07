# New-Project.ps1
# Creates a project skeleton inside 02_Projects

function Slugify {
    param([string]$name)
    $s = $name.ToLower()
    $s = $s -replace "[^a-z0-9а-яё\- ]", ""
    $s = $s -replace "\s+", "_"
    return $s
}

$projectName = Read-Host "Project name (human readable)"
if ([string]::IsNullOrWhiteSpace($projectName)) {
    Write-Host "No project name provided. Abort."
    exit 1
}

$domainTag = Read-Host "Domain tag (e.g. sre, mlops, research) (optional)"

$slug = Slugify $projectName
$projectPath = Join-Path "02_Projects" $slug

if (Test-Path $projectPath) {
    Write-Host "Project folder already exists: $projectPath"
} else {
    New-Item -ItemType Directory -Path $projectPath | Out-Null
}

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

$tagLine = ""
if (-not [string]::IsNullOrWhiteSpace($domainTag)) {
    $tagLine = "#tags #project #" + $domainTag
} else {
    $tagLine = "#tags #project"
}

New-FileIfMissing (Join-Path $projectPath "README.md") @"
# $projectName

$tagLine

## Описание
- 

## Цели
- 

## Критерии успеха
- 

## Контекст / мотивация
- 
"@

New-FileIfMissing (Join-Path $projectPath "Roadmap.md") @"
# Roadmap — $projectName

## Q1
- 

## Q2
- 

## Q3
- 

## Q4
- 
"@

New-FileIfMissing (Join-Path $projectPath "Tasks.md") @"
# Tasks — $projectName

## Backlog
- [ ] 

## In progress
- [ ] 

## Done
- [ ] 
"@

New-FileIfMissing (Join-Path $projectPath "Diary.md") @"
# Diary — $projectName

## {{DATE}}
- 
"@

New-FileIfMissing (Join-Path $projectPath "Notes.md") @"
# Notes — $projectName

Свободные заметки по проекту.
"@

Write-Host "Project created at: $projectPath"
