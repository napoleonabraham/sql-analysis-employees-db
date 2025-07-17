/**************************************
  DATA INSPECTION QUERIES
**************************************/

-- Database structure inspection
USE employees;

SHOW TABLES;

-- Table schema verification
DESCRIBE employees;
DESCRIBE departments;
DESCRIBE dept_emp;
DESCRIBE dept_manager;
DESCRIBE salaries;
DESCRIBE titles;

-- Record counts for all tables
SELECT 'employees' AS table_name, COUNT(*) AS record_count FROM employees
UNION ALL SELECT 'departments', COUNT(*) FROM departments
UNION ALL SELECT 'dept_emp', COUNT(*) FROM dept_emp
UNION ALL SELECT 'dept_manager', COUNT(*) FROM dept_manager
UNION ALL SELECT 'salaries', COUNT(*) FROM salaries
UNION ALL SELECT 'titles', COUNT(*) FROM titles;


/**************************************
  DATA EXPLORATION QUERIES
**************************************/

-- Date range analysis
SELECT 
    MIN(hire_date) AS earliest_hire,
    MAX(hire_date) AS latest_hire,
    DATEDIFF(MAX(hire_date), MIN(hire_date))/365 AS data_years
FROM employees;

-- Salary distribution over time
SELECT 
    YEAR(from_date) AS year,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    AVG(salary) AS avg_salary,
    COUNT(*) AS records
FROM salaries
GROUP BY YEAR(from_date)
ORDER BY year;

-- Current department assignments check
SELECT emp_no, COUNT(*) AS dept_count
FROM dept_emp
WHERE to_date > CURDATE()
GROUP BY emp_no
HAVING COUNT(*) > 1;

-- Title consistency check
SELECT title, COUNT(*) AS count
FROM titles
GROUP BY title
ORDER BY count DESC;

-- Employee without salary records
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
LEFT JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.emp_no IS NULL;

-- Department assignments without employees
SELECT de.dept_no, d.dept_name
FROM dept_emp de
LEFT JOIN employees e ON de.emp_no = e.emp_no
WHERE e.emp_no IS NULL;


/**************************************
  DATA CLEANING QUERIES
**************************************/

-- Fix date format inconsistencies (example)
UPDATE employees 
SET birth_date = STR_TO_DATE(birth_date, '%m/%d/%Y') 
WHERE birth_date LIKE '%/%';

-- Standardize title capitalization
UPDATE titles 
SET title = CONCAT(UPPER(SUBSTRING(title, 1, 1)), LOWER(SUBSTRING(title, 2)))
WHERE title NOT LIKE BINARY CONCAT(UPPER(SUBSTRING(title, 1, 1)), LOWER(SUBSTRING(title, 2)));

-- Remove exact duplicate title records
DELETE t1 FROM titles t1
INNER JOIN titles t2 
WHERE t1.emp_no = t2.emp_no 
AND t1.title = t2.title
AND t1.from_date = t2.from_date
AND t1.to_date = t2.to_date
AND t1.emp_no < t2.emp_no;

-- Correct multiple current department assignments
UPDATE dept_emp
SET to_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
WHERE emp_no IN (
    SELECT emp_no 
    FROM dept_emp
    WHERE to_date > CURDATE()
    GROUP BY emp_no
    HAVING COUNT(*) > 1
) AND to_date > CURDATE()
AND (emp_no, from_date) NOT IN (
    SELECT emp_no, MAX(from_date)
    FROM dept_emp
    WHERE to_date > CURDATE()
    GROUP BY emp_no
    HAVING COUNT(*) > 1
);

-- Fix invalid date ranges in department assignments
UPDATE dept_emp
SET to_date = DATE_ADD(from_date, INTERVAL 1 YEAR)
WHERE to_date < from_date;


/**************************************
  DATA QUALITY REPORT
**************************************/

-- Comprehensive data quality assessment
SELECT
    'Employees' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN birth_date IS NULL THEN 1 ELSE 0 END) AS missing_birth_dates,
    SUM(CASE WHEN gender NOT IN ('M','F') THEN 1 ELSE 0 END) AS invalid_genders,
    SUM(CASE WHEN hire_date > CURDATE() THEN 1 ELSE 0 END) AS future_hire_dates
FROM employees

UNION ALL

SELECT
    'Salaries',
    COUNT(*),
    SUM(CASE WHEN salary < 30000 THEN 1 ELSE 0 END) AS suspiciously_low,
    SUM(CASE WHEN salary > 300000 THEN 1 ELSE 0 END) AS suspiciously_high,
    SUM(CASE WHEN from_date > to_date THEN 1 ELSE 0 END) AS invalid_date_ranges
FROM salaries

UNION ALL

SELECT
    'Department Assignments',
    COUNT(*),
    SUM(CASE WHEN to_date < from_date THEN 1 ELSE 0 END) AS invalid_date_ranges,
    SUM(CASE WHEN emp_no NOT IN (SELECT emp_no FROM employees) THEN 1 ELSE 0 END) AS orphaned_records,
    SUM(CASE WHEN dept_no NOT IN (SELECT dept_no FROM departments) THEN 1 ELSE 0 END) AS invalid_depts
FROM dept_emp

UNION ALL

SELECT
    'Titles',
    COUNT(*),
    SUM(CASE WHEN title = '' THEN 1 ELSE 0 END) AS missing_titles,
    SUM(CASE WHEN from_date > to_date THEN 1 ELSE 0 END) AS invalid_date_ranges,
    SUM(CASE WHEN emp_no NOT IN (SELECT emp_no FROM employees) THEN 1 ELSE 0 END) AS orphaned_records
FROM titles;


/**************************************
  FINAL DATA VALIDATION
**************************************/

-- Verify cleaning operations
SELECT 'Duplicate Titles Remaining' AS check_name, COUNT(*) AS problems_found
FROM (
    SELECT emp_no, title, from_date, to_date, COUNT(*) 
    FROM titles 
    GROUP BY emp_no, title, from_date, to_date
    HAVING COUNT(*) > 1
) AS dupes

UNION ALL

SELECT 'Multiple Current Departments', COUNT(*)
FROM (
    SELECT emp_no 
    FROM dept_emp
    WHERE to_date > CURDATE()
    GROUP BY emp_no
    HAVING COUNT(*) > 1
) AS multi_dept

UNION ALL

SELECT 'Employees Without Salaries', COUNT(*)
FROM employees e
LEFT JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.emp_no IS NULL;