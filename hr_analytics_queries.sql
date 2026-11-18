/* ============================================================
   HR ANALYTICS QUERIES
   Database : MySQL Employees Sample Database (test_db)
   Requires : MySQL 8.0+ (CTEs and window functions)

   Conventions
   - A record is "current" when to_date = '9999-01-01'.
   - An employee is current when they have a current dept_emp row.
   - Tenure is measured to @as_of, the snapshot date of the data,
     not to today's date.
   ============================================================ */

USE employees;

SET @as_of = (SELECT MAX(from_date) FROM salaries);   -- 2002-08-01


/* ------------------------------------------------------------
   A. WORKFORCE OVERVIEW
   ------------------------------------------------------------ */

-- 1. How many employees were ever hired, how many are still employed,
--    and how many have left?
WITH emp_status AS (
    SELECT e.emp_no,
           MAX(de.to_date = '9999-01-01') AS is_current
    FROM employees e
    JOIN dept_emp de ON de.emp_no = e.emp_no
    GROUP BY e.emp_no
)
SELECT
    COUNT(*)                                    AS ever_hired,
    SUM(is_current)                             AS current_employees,
    COUNT(*) - SUM(is_current)                  AS former_employees,
    ROUND(100 * (1 - AVG(is_current)), 1)       AS pct_left
FROM emp_status;

-- 2. How many current employees work in each department?
SELECT
    d.dept_name,
    COUNT(*) AS employees,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_workforce
FROM departments d
JOIN dept_emp de ON de.dept_no = d.dept_no
WHERE de.to_date = '9999-01-01'
GROUP BY d.dept_name
ORDER BY employees DESC;

-- 3. How many employees were hired each year?
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS employees_hired
FROM employees
GROUP BY hire_year
ORDER BY hire_year;


/* ------------------------------------------------------------
   B. WORKFORCE DEMOGRAPHICS
   ------------------------------------------------------------ */

-- 4. What is the gender split of the current workforce, by department?
SELECT
    IF(GROUPING(d.dept_name), 'All departments', d.dept_name) AS department,
    SUM(e.gender = 'M') AS men,
    SUM(e.gender = 'F') AS women,
    ROUND(100 * AVG(e.gender = 'F'), 1) AS pct_women
FROM departments d
JOIN dept_emp de ON de.dept_no = d.dept_no AND de.to_date = '9999-01-01'
JOIN employees e ON e.emp_no = de.emp_no
GROUP BY d.dept_name WITH ROLLUP;

-- 5. How are current employees distributed across job titles?
SELECT
    t.title,
    COUNT(*) AS employees,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_workforce
FROM titles t
WHERE t.to_date = '9999-01-01'
GROUP BY t.title
ORDER BY employees DESC;

-- 6. What is the average tenure of current employees, by department?
SELECT
    IF(GROUPING(d.dept_name), 'All departments', d.dept_name) AS department,
    ROUND(AVG(TIMESTAMPDIFF(MONTH, e.hire_date, @as_of)) / 12, 1) AS avg_tenure_years,
    ROUND(MIN(TIMESTAMPDIFF(MONTH, e.hire_date, @as_of)) / 12, 1) AS min_tenure_years,
    ROUND(MAX(TIMESTAMPDIFF(MONTH, e.hire_date, @as_of)) / 12, 1) AS max_tenure_years
FROM departments d
JOIN dept_emp de ON de.dept_no = d.dept_no AND de.to_date = '9999-01-01'
JOIN employees e ON e.emp_no = de.emp_no
GROUP BY d.dept_name WITH ROLLUP
ORDER BY avg_tenure_years DESC;


/* ------------------------------------------------------------
   C. COMPENSATION
   ------------------------------------------------------------ */

-- 7. What are the average salary, salary range and total payroll
--    of each department?
SELECT
    d.dept_name,
    COUNT(*)                          AS employees,
    ROUND(AVG(s.salary))              AS avg_salary,
    MIN(s.salary)                     AS min_salary,
    MAX(s.salary)                     AS max_salary,
    ROUND(SUM(s.salary) / 1e6, 1)     AS annual_payroll_millions
FROM departments d
JOIN dept_emp de ON de.dept_no = d.dept_no AND de.to_date = '9999-01-01'
JOIN salaries s  ON s.emp_no = de.emp_no   AND s.to_date  = '9999-01-01'
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

-- 8. What is the average salary for each job title?
SELECT
    t.title,
    COUNT(*)             AS employees,
    ROUND(AVG(s.salary)) AS avg_salary
FROM titles t
JOIN salaries s ON s.emp_no = t.emp_no AND s.to_date = '9999-01-01'
WHERE t.to_date = '9999-01-01'
GROUP BY t.title
ORDER BY avg_salary DESC;

-- 9. How large is the gender pay gap in each department?
--    A positive gap means men are paid more on average.
SELECT
    IF(GROUPING(d.dept_name), 'All departments', d.dept_name) AS department,
    ROUND(AVG(CASE WHEN e.gender = 'M' THEN s.salary END)) AS avg_salary_men,
    ROUND(AVG(CASE WHEN e.gender = 'F' THEN s.salary END)) AS avg_salary_women,
    ROUND(AVG(CASE WHEN e.gender = 'M' THEN s.salary END)
        - AVG(CASE WHEN e.gender = 'F' THEN s.salary END)) AS gap,
    ROUND(100 * (AVG(CASE WHEN e.gender = 'M' THEN s.salary END)
               / AVG(CASE WHEN e.gender = 'F' THEN s.salary END) - 1), 2) AS gap_pct
FROM departments d
JOIN dept_emp de ON de.dept_no = d.dept_no AND de.to_date = '9999-01-01'
JOIN employees e ON e.emp_no = de.emp_no
JOIN salaries s  ON s.emp_no = e.emp_no    AND s.to_date  = '9999-01-01'
GROUP BY d.dept_name WITH ROLLUP
ORDER BY gap DESC;

-- 10. Who are the three highest-paid employees in each department?
WITH ranked AS (
    SELECT
        d.dept_name,
        e.emp_no,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        s.salary,
        DENSE_RANK() OVER (PARTITION BY d.dept_no ORDER BY s.salary DESC) AS salary_rank
    FROM departments d
    JOIN dept_emp de ON de.dept_no = d.dept_no AND de.to_date = '9999-01-01'
    JOIN employees e ON e.emp_no = de.emp_no
    JOIN salaries s  ON s.emp_no = e.emp_no    AND s.to_date  = '9999-01-01'
)
SELECT dept_name, salary_rank, emp_no, employee_name, salary
FROM ranked
WHERE salary_rank <= 3
ORDER BY dept_name, salary_rank;

-- 11. How does each department manager's salary compare with
--     the average salary of the department they run?
WITH dept_avg AS (
    SELECT de.dept_no, AVG(s.salary) AS avg_salary
    FROM dept_emp de
    JOIN salaries s ON s.emp_no = de.emp_no AND s.to_date = '9999-01-01'
    WHERE de.to_date = '9999-01-01'
    GROUP BY de.dept_no
)
SELECT
    d.dept_name,
    CONCAT(e.first_name, ' ', e.last_name) AS manager,
    s.salary                               AS manager_salary,
    ROUND(da.avg_salary)                   AS dept_avg_salary,
    ROUND(s.salary / da.avg_salary, 2)     AS ratio_to_dept_avg
FROM dept_manager dm
JOIN departments d ON d.dept_no = dm.dept_no
JOIN employees e   ON e.emp_no  = dm.emp_no
JOIN salaries s    ON s.emp_no  = dm.emp_no AND s.to_date = '9999-01-01'
JOIN dept_avg da   ON da.dept_no = dm.dept_no
WHERE dm.to_date = '9999-01-01'
ORDER BY ratio_to_dept_avg DESC;

-- 12. How much have salaries grown from each current employee's
--     starting salary to their current salary?
WITH first_last AS (
    SELECT DISTINCT
        emp_no,
        FIRST_VALUE(salary) OVER w AS first_salary,
        LAST_VALUE(salary)  OVER w AS current_salary,
        LAST_VALUE(to_date) OVER w AS last_to_date
    FROM salaries
    WINDOW w AS (PARTITION BY emp_no ORDER BY from_date
                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)
SELECT
    COUNT(*)                                                        AS current_employees,
    ROUND(AVG(first_salary))                                        AS avg_starting_salary,
    ROUND(AVG(current_salary))                                      AS avg_current_salary,
    ROUND(AVG(100 * (current_salary - first_salary) / first_salary), 1) AS avg_growth_pct,
    ROUND(MAX(100 * (current_salary - first_salary) / first_salary), 1) AS max_growth_pct,
    SUM(current_salary < first_salary)                              AS employees_paid_less_than_at_start
FROM first_last
WHERE last_to_date = '9999-01-01';

-- 13. How did the average salary change from year to year?
WITH yearly AS (
    SELECT YEAR(from_date) AS salary_year, AVG(salary) AS avg_salary
    FROM salaries
    GROUP BY YEAR(from_date)
)
SELECT
    salary_year,
    ROUND(avg_salary) AS avg_salary,
    ROUND(avg_salary - LAG(avg_salary) OVER (ORDER BY salary_year)) AS change_vs_prior_year,
    ROUND(100 * (avg_salary / LAG(avg_salary) OVER (ORDER BY salary_year) - 1), 2) AS pct_change
FROM yearly
ORDER BY salary_year;

-- 14. Is salary related to tenure? Pearson correlation between
--     tenure and current salary for current employees.
WITH pts AS (
    SELECT
        TIMESTAMPDIFF(MONTH, e.hire_date, @as_of) / 12 AS x,
        s.salary AS y
    FROM employees e
    JOIN salaries s ON s.emp_no = e.emp_no AND s.to_date = '9999-01-01'
)
SELECT
    COUNT(*) AS employees,
    ROUND(
        (COUNT(*) * SUM(x * y) - SUM(x) * SUM(y)) /
        (SQRT(COUNT(*) * SUM(x * x) - SUM(x) * SUM(x)) *
         SQRT(COUNT(*) * SUM(y * y) - SUM(y) * SUM(y))), 3) AS tenure_salary_correlation
FROM pts;


/* ------------------------------------------------------------
   D. CAREER PROGRESSION AND RETENTION
   ------------------------------------------------------------ */

-- 15. How many titles has each employee held?
SELECT
    titles_held,
    COUNT(*) AS employees,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_employees
FROM (
    SELECT emp_no, COUNT(*) AS titles_held
    FROM titles
    GROUP BY emp_no
) AS per_employee
GROUP BY titles_held
ORDER BY titles_held;

-- 16. What are the most common title changes, and how long do
--     employees stay in a title before moving to the next one?
WITH moves AS (
    SELECT
        emp_no,
        title AS from_title,
        LEAD(title)     OVER (PARTITION BY emp_no ORDER BY from_date) AS to_title,
        from_date,
        LEAD(from_date) OVER (PARTITION BY emp_no ORDER BY from_date) AS next_from_date
    FROM titles
)
SELECT
    from_title,
    to_title,
    COUNT(*) AS employees,
    ROUND(AVG(TIMESTAMPDIFF(MONTH, from_date, next_from_date)) / 12, 1) AS avg_years_before_change
FROM moves
WHERE to_title IS NOT NULL
GROUP BY from_title, to_title
ORDER BY employees DESC;

-- 17. How many employees have changed department?
SELECT
    COUNT(*)                                  AS employees,
    SUM(depts > 1)                            AS changed_department,
    ROUND(100 * AVG(depts > 1), 1)            AS pct_changed_department
FROM (
    SELECT emp_no, COUNT(DISTINCT dept_no) AS depts
    FROM dept_emp
    GROUP BY emp_no
) AS per_employee;

-- 18. What share of the people who worked in each department have
--     left the company, and how long did leavers stay?
WITH last_assignment AS (
    SELECT
        de.emp_no,
        de.dept_no,
        de.to_date,
        ROW_NUMBER() OVER (PARTITION BY de.emp_no ORDER BY de.to_date DESC, de.from_date DESC) AS rn
    FROM dept_emp de
)
SELECT
    IF(GROUPING(d.dept_name), 'All departments', d.dept_name) AS department,
    COUNT(*)                                        AS employees_last_in_dept,
    SUM(la.to_date < '9999-01-01')                  AS left_company,
    ROUND(100 * AVG(la.to_date < '9999-01-01'), 1)  AS pct_left,
    ROUND(AVG(CASE WHEN la.to_date < '9999-01-01'
                   THEN TIMESTAMPDIFF(MONTH, e.hire_date, la.to_date) END) / 12, 1) AS avg_years_before_leaving
FROM last_assignment la
JOIN departments d ON d.dept_no = la.dept_no
JOIN employees e   ON e.emp_no  = la.emp_no
WHERE la.rn = 1
GROUP BY d.dept_name WITH ROLLUP
ORDER BY pct_left DESC;

-- 19. How many employees left in each year?
WITH last_day AS (
    SELECT emp_no, MAX(to_date) AS leave_date
    FROM dept_emp
    GROUP BY emp_no
    HAVING MAX(to_date) < '9999-01-01'
)
SELECT YEAR(leave_date) AS leave_year, COUNT(*) AS employees_left
FROM last_day
GROUP BY leave_year
ORDER BY leave_year;
