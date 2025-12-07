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
