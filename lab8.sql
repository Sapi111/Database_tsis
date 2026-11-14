-- Проверяем таблицы и их столбцы
SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('employees', 'departments', 'projects')
ORDER BY table_name, ordinal_position;
--tim

-- =========================================
-- PART 2: CREATING BASIC INDEXES
-- =========================================

-- Exercise 2.1: Simple B-tree Index
-- Создаём индекс для быстрого поиска по зарплате.

CREATE INDEX emp_salary_idx
ON employees(salary);

-- Проверяем индексы таблицы employees.
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Ответ:
-- Обычно здесь 2 индекса: автоматический PRIMARY KEY
-- и созданный нами emp_salary_idx.


-- Exercise 2.2: Index on a Foreign Key
-- Создаём индекс для поиска сотрудников по отделу.

CREATE INDEX emp_dept_idx
ON employees(dept_id);

-- Проверяем использование индекса в запросе.
SELECT *
FROM employees
WHERE dept_id = 101;

-- Ответ:
-- Индекс ускоряет поиск по внешнему ключу
-- и помогает при JOIN между таблицами.


-- Exercise 2.3: View Index Information
-- Показываем все индексы в схеме public.

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Ответ:
-- Автоматически создаются индексы PRIMARY KEY
-- и UNIQUE. Остальные создаются вручную.

-- =========================================
-- PART 3: MULTICOLUMN INDEXES
-- =========================================

-- Exercise 3.1: Multicolumn Index
-- Индекс сразу по отделу и зарплате.

CREATE INDEX emp_dept_salary_idx
ON employees(dept_id, salary);

-- Проверяем индекс на практике.
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101
  AND salary > 52000;

-- Ответ:
-- Для поиска только по salary индекс менее эффективен,
-- так как первым столбцом указан dept_id.


-- Exercise 3.2: Understanding Column Order
-- Создаём индекс с обратным порядком столбцов.

CREATE INDEX emp_salary_dept_idx
ON employees(salary, dept_id);

-- Query 1
SELECT *
FROM employees
WHERE dept_id = 102
  AND salary > 50000;

-- Query 2
SELECT *
FROM employees
WHERE salary > 50000
  AND dept_id = 102;

-- Ответ:
-- Да, порядок важен.
-- B-tree эффективнее использует первые столбцы индекса.

-- =========================================
-- PART 4: UNIQUE INDEXES
-- =========================================

-- Exercise 4.1: Create a Unique Index

-- Добавляем столбец email.
ALTER TABLE employees
ADD COLUMN email VARCHAR(100);

-- Заполняем email сотрудников.
UPDATE employees SET email = 'john.smith@company.com'
WHERE emp_id = 1;

UPDATE employees SET email = 'jane.doe@company.com'
WHERE emp_id = 2;

UPDATE employees SET email = 'mike.johnson@company.com'
WHERE emp_id = 3;

UPDATE employees SET email = 'sarah.williams@company.com'
WHERE emp_id = 4;

UPDATE employees SET email = 'tom.brown@company.com'
WHERE emp_id = 5;

-- Создаём уникальный индекс.
CREATE UNIQUE INDEX emp_email_unique_idx
ON employees(email);

-- Проверяем уникальность email.
-- Используем emp_id = 99, которого ещё нет.

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (99, 'New Employee', 101, 55000, 'john.smith@company.com');

-- Ожидаемая ошибка:
-- duplicate key value violates unique constraint
-- Теперь причина именно в повторяющемся email.

-- Exercise 4.2: Unique Index vs UNIQUE Constraint

-- Добавляем phone с ограничением UNIQUE.
ALTER TABLE employees
ADD COLUMN phone VARCHAR(20) UNIQUE;

-- Проверяем созданный индекс.
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'
  AND indexname LIKE '%phone%';

-- Ответ:
-- Да, PostgreSQL автоматически создал индекс.
-- Тип индекса — B-tree.

-- =========================================
-- PART 5: INDEXES AND SORTING
-- =========================================

-- Exercise 5.1: Create an Index for Sorting
-- Индекс для сортировки зарплат по убыванию.

CREATE INDEX emp_salary_desc_idx
ON employees(salary DESC);

-- Проверяем сортировку.
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Ответ:
-- Индекс помогает ускорить сортировку по зарплате.


-- Exercise 5.2: Index with NULL Handling
-- Создаём индекс, который размещает NULL в начале.

CREATE INDEX proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

-- Проверяем сортировку бюджетов.
SELECT project_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

-- Ответ:
-- NULLS FIRST помещает пустые значения в начало.

-- =========================================
-- PART 6: INDEXES ON EXPRESSIONS
-- =========================================

-- Exercise 6.1: Function-Based Index
-- Создаём индекс для поиска имён без учёта регистра.

CREATE INDEX emp_name_lower_idx
ON employees(LOWER(emp_name));

-- Проверяем поиск имени.
SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';

-- Ответ:
-- Без индекса PostgreSQL проверял бы имена
-- строка за строкой.


-- Exercise 6.2: Index on Calculated Values
-- Добавляем дату приёма на работу.

ALTER TABLE employees
ADD COLUMN hire_date DATE;

-- Заполняем даты сотрудников.

UPDATE employees SET hire_date = '2020-01-15'
WHERE emp_id = 1;

UPDATE employees SET hire_date = '2019-06-20'
WHERE emp_id = 2;

UPDATE employees SET hire_date = '2021-03-10'
WHERE emp_id = 3;

UPDATE employees SET hire_date = '2020-11-05'
WHERE emp_id = 4;

UPDATE employees SET hire_date = '2018-08-25'
WHERE emp_id = 5;

-- Создаём индекс по году найма.

CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

-- Проверяем поиск сотрудников, принятых в 2020 году.

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- =========================================
-- PART 7: MANAGING INDEXES
-- =========================================

-- Exercise 7.1: Rename an Index
-- Переименовываем индекс зарплаты.

ALTER INDEX emp_salary_idx
RENAME TO employees_salary_index;

-- Проверяем новое название.
SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';


-- Exercise 7.2: Drop Unused Indexes
-- Удаляем ненужный составной индекс.

DROP INDEX emp_salary_dept_idx;

-- Ответ:
-- Индексы занимают место и замедляют INSERT,
-- UPDATE и DELETE.


-- Exercise 7.3: Reindex
-- Перестраиваем индекс зарплаты.

REINDEX INDEX employees_salary_index;

-- Ответ:
-- REINDEX полезен при разрастании индекса
-- и после значительных изменений данных.


-- =========================================
-- PART 8: PRACTICAL SCENARIOS
-- =========================================

-- Exercise 8.1: Optimize a Slow Query

-- Индекс для зарплат выше 50000.
CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

-- Индексы для JOIN и ORDER BY уже созданы ранее:
-- emp_dept_idx и emp_salary_desc_idx.

-- JOIN здесь пропускаем: типы и значения dept_id в таблицах
-- employees (101, 102, 103) и departments (D10, D20, D30) не совпадают.
-- Для корректного JOIN сначала нужно согласовать ключи в исходной схеме.


-- Exercise 8.2: Partial Index

-- Индекс только для проектов с бюджетом выше 80000.
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

-- Проверяем проекты.
SELECT project_name, budget
FROM projects
WHERE budget > 80000;

-- Ответ:
-- Partial Index занимает меньше места,
-- так как содержит только подходящие строки.


-- Exercise 8.3: Analyze Index Usage

-- Проверяем, использует ли PostgreSQL индекс.
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;

-- Ответ:
-- Index Scan — используется индекс.
-- Seq Scan — таблица читается последовательно.
-- PostgreSQL сам выбирает подходящий способ.


-- =========================================
-- PART 9: INDEX TYPES COMPARISON
-- =========================================

-- Exercise 9.1: Hash Index

CREATE INDEX dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT *
FROM departments
WHERE dept_name = 'IT';

-- Ответ: HASH подходит для поиска по точному совпадению.


-- Exercise 9.2: Compare Index Types

-- B-tree Index
CREATE INDEX proj_name_btree_idx
ON projects(project_name);

-- Hash Index
CREATE INDEX proj_name_hash_idx
ON projects USING HASH (project_name);

-- Поиск по точному совпадению
SELECT *
FROM projects
WHERE project_name = 'Website Redesign';

-- Поиск по диапазону
SELECT *
FROM projects
WHERE project_name > 'Database';

-- Ответ:
-- B-tree поддерживает равенство и диапазоны.
-- HASH поддерживает только равенство.

-- =========================================
-- PART 10: CLEANUP AND BEST PRACTICES
-- =========================================

-- Exercise 10.1: Review All Indexes
-- Показываем все индексы и их размер.

SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(
        pg_relation_size(indexname::regclass)
    ) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Ответ:
-- Самый большой индекс зависит от количества
-- данных и структуры индекса.


-- Exercise 10.2: Drop Unnecessary Indexes
-- Удаляем ненужный HASH-индекс проектов.

DROP INDEX IF EXISTS proj_name_hash_idx;

-- Ответ:
-- Удаляем дублирующие и редко используемые индексы.


-- Exercise 10.3: Document Your Indexes
-- Создаём представление с описанием индексов зарплаты.

CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';

-- Проверяем представление.
SELECT *
FROM index_documentation;

-- SUMMARY QUESTIONS

-- 1. Default index type in PostgreSQL: B-tree.

-- 2. Create indexes for:
-- Frequently searched WHERE columns,
-- foreign keys, and JOIN columns.

-- 3. Do not create indexes on:
-- Rarely used columns and very small tables.

-- 4. INSERT, UPDATE and DELETE modify indexes,
-- which adds overhead to these operations.

-- 5. Use EXPLAIN to check whether a query uses an index.