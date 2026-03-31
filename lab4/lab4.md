## Лабораторная работа №4  
### Базы данных  

### Состав проекта

| Файл | Назначение |
|------|-----------|
| [`Create_tables.sql`](https://github.com/mariiamonk/DB_labs/blob/main/lab4/Create_tables.sql) | SQL-скрипт создания схемы БД: таблицы, домены, первичные и внешние ключи, ограничения целостности |
| [`generate_data.py`](https://github.com/mariiamonk/DB_labs/blob/main/lab4/generate_data.py) | Скрипт генерации тестовых данных на Python. Подключается к PostgreSQL, очищает таблицы, генерирует и вставляет  данные в заданном количестве |
| [`requirements.txt`](https://github.com/mariiamonk/DB_labs/blob/main/lab4/requirements.txt) | Список зависимостей Python |

### Инструкция по запуску

#### 1. Подготовка базы данных
- Установите PostgreSQL.
- Создайте базу данных с именем `findPlace` (или измените имя в скрипте `generate_data.py` при необходимости).
- Выполните скрипт создания схемы `Create_tables.sql`.

#### 2. Установка зависимостей Python
В командной строке (терминале) выполните:

```bash
pip install -r requirements.txt
```
#### 3. Запуск генератора тестовых данных
В той же папке выполните:

```bash
python generate_data.py
```
