/* ============================================================
   DATA INSPECTION, EXPLORATION AND QUALITY CHECKS
   Database : MySQL Employees Sample Database (test_db)
   Requires : MySQL 8.0+
   Note     : every statement here is read-only. The checks found
              no defects, so no cleaning statements are needed.
   ============================================================ */

USE employees;

/* ------------------------------------------------------------
   1. DATA INSPECTION
   ------------------------------------------------------------ */

-- 1.1 Tables in the database
SHOW TABLES;

-- 1.2 Table structures
DESCRIBE employees;
DESCRIBE departments;
DESCRIBE dept_emp;
DESCRIBE dept_manager;
DESCRIBE salaries;
DESCRIBE titles;

-- 1.3 Row counts
SELECT 'employees' AS table_name, COUNT(*) AS record_count FROM employees
UNION ALL SELECT 'departments',  COUNT(*) FROM departments
UNION ALL SELECT 'dept_emp',     COUNT(*) FROM dept_emp
UNION ALL SELECT 'dept_manager', COUNT(*) FROM dept_manager
UNION ALL SELECT 'salaries',     COUNT(*) FROM salaries
UNION ALL SELECT 'titles',       COUNT(*) FROM titles;


/* ------------------------------------------------------------
   2. DATA EXPLORATION
   ------------------------------------------------------------ */

-- 2.1 Hiring period covered by the data
SELECT
    MIN(hire_date) AS earliest_hire,
    MAX(hire_date) AS latest_hire,
    ROUND(DATEDIFF(MAX(hire_date), MIN(hire_date)) / 365.25, 1) AS hiring_span_years
FROM employees;

-- 2.2 How "current" records are marked.
--     Open-ended records use the sentinel date 9999-01-01, so
--     "current" means to_date = '9999-01-01', not to_date > today.
SELECT 'dept_emp' AS table_name,
       SUM(to_date = '9999-01-01') AS current_records,
       MAX(CASE WHEN to_date < '9999-01-01' THEN to_date END) AS latest_closed_date
FROM dept_emp
UNION ALL
SELECT 'salaries', SUM(to_date = '9999-01-01'),
       MAX(CASE WHEN to_date < '9999-01-01' THEN to_date END)
FROM salaries
UNION ALL
SELECT 'titles', SUM(to_date = '9999-01-01'),
       MAX(CASE WHEN to_date < '9999-01-01' THEN to_date END)
FROM titles;

-- 2.3 Snapshot date of the data: the last date on which anything changed.
--     All tenure calculations should be measured to this date, not CURDATE().
SELECT MAX(from_date) AS snapshot_date FROM salaries;

-- 2.4 Age at hire
SELECT
    MIN(TIMESTAMPDIFF(YEAR, birth_date, hire_date)) AS youngest_at_hire,
    MAX(TIMESTAMPDIFF(YEAR, birth_date, hire_date)) AS oldest_at_hire,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, birth_date, hire_date)), 1) AS avg_age_at_hire
FROM employees;

-- 2.5 Salary records per year
SELECT
    YEAR(from_date)  AS salary_year,
    COUNT(*)         AS records,
    MIN(salary)      AS min_salary,
    ROUND(AVG(salary)) AS avg_salary,
    MAX(salary)      AS max_salary
FROM salaries
GROUP BY YEAR(from_date)
ORDER BY salary_year;

-- 2.6 Distinct job titles and how many records each has
SELECT title, COUNT(*) AS records
FROM titles
GROUP BY title
ORDER BY records DESC;

-- 2.7 History depth: average number of records per employee
SELECT
    (SELECT ROUND(COUNT(*) / COUNT(DISTINCT emp_no), 2) FROM salaries) AS salary_records_per_employee,
    (SELECT ROUND(COUNT(*) / COUNT(DISTINCT emp_no), 2) FROM titles)   AS title_records_per_employee,
    (SELECT ROUND(COUNT(*) / COUNT(DISTINCT emp_no), 2) FROM dept_emp) AS dept_records_per_employee;


/* ------------------------------------------------------------
   3. DATA QUALITY REPORT
   One row per check. problems_found = 0 means the check passed.
   ------------------------------------------------------------ */

SELECT 'Missing birth, hire date or name' AS check_name, COUNT(*) AS problems_found
FROM employees
WHERE birth_date IS NULL OR hire_date IS NULL
   OR first_name IS NULL OR first_name = ''
   OR last_name  IS NULL OR last_name  = ''

UNION ALL
SELECT 'Hired before age 16', COUNT(*)
FROM employees
WHERE TIMESTAMPDIFF(YEAR, birth_date, hire_date) < 16

UNION ALL
SELECT 'Duplicate employees (same name, birth date, hire date)', COUNT(*)
FROM (
    SELECT first_name, last_name, birth_date, hire_date
    FROM employees
    GROUP BY first_name, last_name, birth_date, hire_date
    HAVING COUNT(*) > 1
) AS dupes

UNION ALL
SELECT 'Employees without any salary record', COUNT(*)
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM salaries s WHERE s.emp_no = e.emp_no)

UNION ALL
SELECT 'Employees without any title record', COUNT(*)
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM titles t WHERE t.emp_no = e.emp_no)

UNION ALL
SELECT 'Employees without any department record', COUNT(*)
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM dept_emp de WHERE de.emp_no = e.emp_no)

UNION ALL
SELECT 'Employees with more than one current department', COUNT(*)
FROM (
    SELECT emp_no FROM dept_emp
    WHERE to_date = '9999-01-01'
    GROUP BY emp_no HAVING COUNT(*) > 1
) AS multi_dept

UNION ALL
SELECT 'Employees with more than one current salary', COUNT(*)
FROM (
    SELECT emp_no FROM salaries
    WHERE to_date = '9999-01-01'
    GROUP BY emp_no HAVING COUNT(*) > 1
) AS multi_salary

UNION ALL
SELECT 'Current department but no current salary', COUNT(*)
FROM dept_emp de
WHERE de.to_date = '9999-01-01'
  AND NOT EXISTS (SELECT 1 FROM salaries s
                  WHERE s.emp_no = de.emp_no AND s.to_date = '9999-01-01')

UNION ALL
SELECT 'Current salary but no current department', COUNT(*)
FROM salaries s
WHERE s.to_date = '9999-01-01'
  AND NOT EXISTS (SELECT 1 FROM dept_emp de
                  WHERE de.emp_no = s.emp_no AND de.to_date = '9999-01-01')

UNION ALL
SELECT 'Salary records with from_date after to_date', COUNT(*)
FROM salaries WHERE from_date > to_date

UNION ALL
SELECT 'Title records with from_date after to_date', COUNT(*)
FROM titles WHERE from_date > to_date

UNION ALL
SELECT 'Department records with from_date after to_date', COUNT(*)
FROM dept_emp WHERE from_date > to_date

UNION ALL
SELECT 'Salary records dated before the hire date', COUNT(*)
FROM salaries s JOIN employees e ON e.emp_no = s.emp_no
WHERE s.from_date < e.hire_date

UNION ALL
SELECT 'Department records dated before the hire date', COUNT(*)
FROM dept_emp de JOIN employees e ON e.emp_no = de.emp_no
WHERE de.from_date < e.hire_date

UNION ALL
SELECT 'Zero or negative salaries', COUNT(*)
FROM salaries WHERE salary <= 0

UNION ALL
SELECT 'Blank job titles', COUNT(*)
FROM titles WHERE title IS NULL OR TRIM(title) = ''

UNION ALL
SELECT 'Departments with no current manager', COUNT(*)
FROM departments d
WHERE NOT EXISTS (SELECT 1 FROM dept_manager dm
                  WHERE dm.dept_no = d.dept_no AND dm.to_date = '9999-01-01');

-- Not checked: duplicate keys, invalid genders and orphaned rows.
-- The schema already prevents them through primary keys, the
-- ENUM('M','F') gender column and foreign key constraints.
