-- Lab 7, Part 1
-- Проверяем наличие трёх таблиц из Lab 6

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('employees', 'departments', 'projects')
ORDER BY table_name;

-- Part 2, Exercise 2.1
-- Создаём VIEW с информацией о сотрудниках и их отделах

CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id;

-- Проверяем созданное представление
SELECT * FROM employee_details;

-- Exercise 2.2
-- Создаём статистику по каждому отделу
-- LEFT JOIN сохраняет отделы без сотрудников

CREATE OR REPLACE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Проверяем результат: сначала отделы с большим числом сотрудников
SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;

-- Exercise 2.3
-- Создаём представление с информацией о проектах и командах

CREATE OR REPLACE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
INNER JOIN departments d
    ON p.dept_id = d.dept_id
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_id,
    d.dept_name,
    d.location;

-- Проверяем результат
SELECT * FROM project_overview;

-- Exercise 2.4
-- Показываем сотрудников с зарплатой выше 55000

CREATE OR REPLACE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

-- Проверяем VIEW
SELECT * FROM high_earners;
--ответ на вопрос: отображаются сотрудники с зарплатой выше $55,000, если они привязаны к существующему отделу. Из-за INNER JOIN сотрудники без отдела не попадут в VIEW.

-- Exercise 3.1
-- Обновляем VIEW и добавляем категорию зарплаты

CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id;

-- Проверяем обновлённое VIEW
SELECT * FROM employee_details;

-- Exercise 3.2
-- Переименовываем VIEW

ALTER VIEW high_earners RENAME TO top_performers;

-- Проверяем новое имя
SELECT * FROM top_performers;

-- Exercise 3.3: Drop a View
-- Создаём VIEW сотрудников с зарплатой меньше 50000

CREATE OR REPLACE VIEW temp_view AS
SELECT *
FROM employees
WHERE salary < 50000;

-- Проверяем результат
SELECT * FROM temp_view;

-- После проверки отдельно удаляем VIEW
DROP VIEW temp_view;

-- Exercise 4.1: Create an Updatable View
-- Создаём представление с данными сотрудников и зарплатами

CREATE OR REPLACE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;

-- Проверяем созданное представление
SELECT * FROM employee_salaries;

-- Exercise 4.2: Update Through a View
-- Меняем зарплату John Smith через VIEW

UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

-- Проверяем, обновилась ли исходная таблица employees
SELECT *
FROM employees
WHERE emp_name = 'John Smith';

-- Exercise 4.3: Insert Through a View
-- Добавляем Alice Johnson через VIEW

INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

-- Проверяем добавление в исходной таблице
SELECT *
FROM employees
WHERE emp_name = 'Alice Johnson';

-- Exercise 4.4: View with CHECK OPTION
-- Создаём VIEW только для сотрудников IT-отдела

CREATE OR REPLACE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- Проверяем VIEW
SELECT * FROM it_employees;

-- Проверяем ограничение: эта вставка должна завершиться ошибкой
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
--ответ на вопрос отклонит вставку, потому что dept_id = 103 не соответствует условию VIEW dept_id = 101

-- Exercise 5.1: Create a Materialized View
-- Создаём сводную статистику по отделам

CREATE MATERIALIZED VIEW dept_summary_mv AS
WITH employee_stats AS (
    -- Считаем сотрудников и их зарплаты отдельно
    SELECT
        dept_id,
        COUNT(*) AS total_employees,
        SUM(salary) AS total_salaries
    FROM employees
    GROUP BY dept_id
),
project_stats AS (
    -- Считаем проекты и их бюджеты отдельно
    SELECT
        dept_id,
        COUNT(*) AS total_projects,
        SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
)
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(e.total_employees, 0) AS total_employees,
    COALESCE(e.total_salaries, 0) AS total_salaries,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget
FROM departments d
LEFT JOIN employee_stats e ON d.dept_id = e.dept_id
LEFT JOIN project_stats p ON d.dept_id = p.dept_id
WITH DATA;

-- Проверяем результат: сначала отделы с большим числом сотрудников
SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;

-- Exercise 5.2: Refresh Materialized View
-- Добавляем нового сотрудника Charlie Brown

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

-- Проверяем VIEW ДО обновления
-- Нового сотрудника здесь пока не будет
SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;

-- Обновляем материализованное представление
REFRESH MATERIALIZED VIEW dept_summary_mv;

-- Проверяем VIEW ПОСЛЕ обновления
-- Теперь Charlie Brown должен учитываться в статистике
SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;
--ответ на вопрос до обновления материализованное представление показывает старые данные, после — актуальные.

-- Exercise 5.3: Concurrent Refresh
-- Создаём уникальный индекс по dept_id
CREATE UNIQUE INDEX idx_dept_summary_dept_id
ON dept_summary_mv (dept_id);

-- Обновляем Materialized View без блокировки чтения
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- Проверяем результат
SELECT *
FROM dept_summary_mv
ORDER BY dept_id;
--ответ на вопрос преимущество CONCURRENTLY — пользователи могут читать Materialized View во время его обновления. Для этого необходим уникальный индекс.

-- Exercise 5.4: Materialized View with NO DATA
-- Создаём представление без первоначального заполнения данными

CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM projects p
INNER JOIN departments d
    ON p.dept_id = d.dept_id
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_id,
    d.dept_name
WITH NO DATA;

-- Пробуем получить данные: ожидаем ошибку
SELECT * FROM project_stats_mv;

-- Заполняем Materialized View данными
REFRESH MATERIALIZED VIEW project_stats_mv;

-- Проверяем после обновления
SELECT * FROM project_stats_mv;
--ответ на вопрос WITH NO DATA создаёт Materialized View без заполнения. Чтобы получить данные, нужно выполнить REFRESH MATERIALIZED VIEW.

-- Part 6: Database Roles
-- Exercise 6.1: Create Basic Roles

-- Создаём роль без возможности входа
CREATE ROLE analyst NOLOGIN;

-- Создаём роль с возможностью входа
CREATE ROLE data_viewer
LOGIN PASSWORD 'viewer123';

-- Создаём пользователя с паролем
CREATE USER report_user
WITH PASSWORD 'report456';

-- Проверяем созданные роли
SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';

-- Exercise 6.2: Role with Specific Attributes

-- Роль с правом создавать базы данных
CREATE ROLE db_creator
LOGIN CREATEDB PASSWORD 'creator789';

-- Роль с правом создавать другие роли
CREATE ROLE user_manager
LOGIN CREATEROLE PASSWORD 'manager101';

-- Роль с правами суперпользователя
CREATE ROLE admin_user
LOGIN SUPERUSER PASSWORD 'admin999';

-- Проверяем созданные роли и их права
SELECT
    rolname,
    rolcanlogin,
    rolcreatedb,
    rolcreaterole,
    rolsuper
FROM pg_roles
WHERE rolname IN ('db_creator', 'user_manager', 'admin_user');

-- Exercise 6.3: Grant Privileges to Roles

-- Даём analyst право просматривать три таблицы
GRANT SELECT ON employees, departments, projects
TO analyst;

-- Даём data_viewer все права на VIEW
GRANT ALL PRIVILEGES ON employee_details
TO data_viewer;

-- Даём report_user права SELECT и INSERT
GRANT SELECT, INSERT ON employees
TO report_user;

-- Exercise 6.4: Create Group Roles

-- 1. Создаём групповые роли
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

-- 2. Создаём пользователей
CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

-- 3. Добавляем пользователей в группы
GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;

-- 4. Добавляем finance_user1 в finance_team
GRANT finance_team TO finance_user1;

-- 5. Даём HR права на employees
GRANT SELECT, UPDATE ON employees TO hr_team;

-- 6. Даём Finance право просмотра статистики
GRANT SELECT ON dept_statistics TO finance_team;

-- Exercise 6.5: Revoke Privileges

-- 1. Отзываем UPDATE
REVOKE UPDATE ON employees FROM hr_team;

-- 2. Убираем пользователя из группы
REVOKE hr_team FROM hr_user2;

-- 3. Отзываем все права на VIEW
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- Exercise 6.6: Modify Role Attributes

-- 1. Разрешаем вход analyst
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';

-- 2. Делаем user_manager суперпользователем
ALTER ROLE user_manager SUPERUSER;

-- 3. Удаляем пароль analyst
ALTER ROLE analyst PASSWORD NULL;

-- 4. Устанавливаем лимит подключений
ALTER ROLE data_viewer CONNECTION LIMIT 5;

-- Exercise 7.1: Role Hierarchies

-- 1. Создаём родительскую роль
CREATE ROLE read_only;

-- Даём SELECT на все таблицы public
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

-- 2. Создаём дочерние роли
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

-- 3. Добавляем обе роли в read_only
GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

-- 4. Дополнительные права только senior_analyst
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- Exercise 7.2: Object Ownership

-- Создаём project_manager
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

-- Передаём владение VIEW и таблицей
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;


-- Exercise 7.3: Reassign and Drop Roles

-- Создаём временную роль
CREATE ROLE temp_owner LOGIN;

-- Создаём таблицу
CREATE TABLE temp_table (
    id INT
);

-- Передаём владение таблицей
ALTER TABLE temp_table OWNER TO temp_owner;

-- Возвращаем объекты владельца postgres
REASSIGN OWNED BY temp_owner TO postgres;

-- Удаляем оставшиеся права и объекты роли
DROP OWNED BY temp_owner;

-- Удаляем роль
DROP ROLE temp_owner;

-- Exercise 7.4: Row-Level Security with Views

-- HR: только сотрудники отдела 102
CREATE OR REPLACE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

-- Finance: только три указанных столбца
CREATE OR REPLACE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;

-- Exercise 8.1: Department Dashboard View

CREATE OR REPLACE VIEW dept_dashboard AS
WITH employee_stats AS (
    SELECT
        dept_id,
        COUNT(*) AS employee_count,
        ROUND(AVG(salary), 2) AS average_salary
    FROM employees
    GROUP BY dept_id
),
project_stats AS (
    SELECT
        dept_id,
        COUNT(*) AS total_projects,
        SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
)
SELECT
    d.dept_name,
    d.location,
    COALESCE(e.employee_count, 0) AS employee_count,
    COALESCE(e.average_salary, 0) AS average_salary,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget,
    ROUND(
        COALESCE(p.total_project_budget, 0) /
        NULLIF(e.employee_count, 0), 2
    ) AS budget_per_employee
FROM departments d
LEFT JOIN employee_stats e ON d.dept_id = e.dept_id
LEFT JOIN project_stats p ON d.dept_id = p.dept_id;

SELECT * FROM dept_dashboard;
-- Exercise 8.2: Audit View

-- Добавляем дату создания
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Создаём VIEW для проектов с бюджетом больше 75000
CREATE OR REPLACE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
    END AS approval_status
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- Проверяем
SELECT * FROM high_budget_projects;

-- Exercise 8.3: Create Access Control System

-- Level 1: Viewer Role

CREATE ROLE viewer_role;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

-- Level 2: Entry Role

CREATE ROLE entry_role;

GRANT viewer_role TO entry_role;

GRANT INSERT ON employees, projects TO entry_role;

-- Level 3: Analyst Role

CREATE ROLE analyst_role;

GRANT entry_role TO analyst_role;

GRANT UPDATE ON employees, projects TO analyst_role;

-- Level 4: Manager Role

CREATE ROLE manager_role;

GRANT analyst_role TO manager_role;

GRANT DELETE ON employees, projects TO manager_role;

-- Create Users

CREATE USER alice WITH PASSWORD 'alice123';

CREATE USER bob WITH PASSWORD 'bob123';

CREATE USER charlie WITH PASSWORD 'charlie123';

-- Assign Roles

GRANT viewer_role TO alice;

GRANT analyst_role TO bob;

GRANT manager_role TO charlie;
