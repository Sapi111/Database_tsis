CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'John', 'Smith', 'IT');

-- 3. INSERT with DEFAULT values
INSERT INTO employees (salary, status)
VALUES (DEFAULT, DEFAULT);

-- 4. INSERT multiple rows
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('Sales', 120000, 2),
    ('HR', 80000, 3);

-- 5. INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Alice', 'Brown', 'Sales', 50000 * 1.1, CURRENT_DATE);

-- 6. INSERT from SELECT
CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';-- 7. UPDATE with arithmetic expressions
UPDATE employees
SET salary = salary * 1.10;

-- 8. UPDATE with WHERE clause and multiple conditions
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

-- 9. UPDATE using CASE expression
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

-- 10. UPDATE with DEFAULT
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11. UPDATE with subquery
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);

-- 12. UPDATE multiple columns
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- PART D: ADVANCED DELETE OPERATIONS


-- 13. DELETE with simple WHERE condition
DELETE FROM employees
WHERE status = 'Terminated';

-- 14. DELETE with complex WHERE clause
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

-- 15. DELETE with subquery
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

-- 16. DELETE with RETURNING clause
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;
--17
INSERT INTO employees (salary, department)
VALUES (NULL, NULL);

--18
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

--19
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

--20
INSERT INTO employees (first_name, last_name)
VALUES ('David', 'Wilson')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

--21
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

--22
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--23
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'David', 'Wilson', 'IT', 60000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'David'
      AND last_name = 'Wilson'
);

--24
UPDATE employees e
SET salary = salary * CASE
    WHEN (
        SELECT budget
        FROM departments d
        WHERE d.dept_name = e.department
    ) > 100000 THEN 1.10
    ELSE 1.05
END;
--25
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
    ('Alex', 'Johnson', 'IT', 50000, CURRENT_DATE),
    ('Emma', 'Brown', 'Sales', 55000, CURRENT_DATE),
    ('Michael', 'Davis', 'HR', 45000, CURRENT_DATE),
    ('Sarah', 'Wilson', 'IT', 60000, CURRENT_DATE),
    ('James', 'Taylor', 'Sales', 52000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE emp_id IN (
    SELECT emp_id
    FROM employees
    ORDER BY emp_id DESC
    LIMIT 5
);

--26
CREATE TABLE employee_archive AS
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

--27
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (
          SELECT d.dept_name
          FROM departments d
          WHERE d.dept_id = p.dept_id
      )
  ) > 3;