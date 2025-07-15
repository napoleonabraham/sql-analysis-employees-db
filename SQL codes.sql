USE employees;
-- ✅ BEGINNER-LEVEL QUERIES (20)

-- 1. How many employees are currently in the company?
SELECT COUNT(*) AS total_employees FROM employees;

-- 2. What is the gender distribution of the workforce?
SELECT gender, COUNT(*) AS count FROM employees GROUP BY gender;

-- 3. How many departments are in the company?
SELECT COUNT(*) AS total_departments FROM departments;

-- 4. What are the names of all departments?
SELECT dept_name FROM departments ORDER BY dept_name;

-- 5. How many employees work in each department?
SELECT d.dept_name, COUNT(de.emp_no) AS employee_count
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
WHERE de.to_date > CURDATE()
GROUP BY d.dept_name
ORDER BY employee_count DESC;

-- 6. What are the unique job titles in the company?
SELECT DISTINCT title FROM titles ORDER BY title;

-- 7. How many employees were hired each year?
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS employees_hired
FROM employees
GROUP BY hire_year
ORDER BY hire_year;

-- 8. Who are the most recently hired employees?
SELECT emp_no, first_name, last_name, hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 10;

-- 9. Who were the first employees ever hired?
SELECT emp_no, first_name, last_name, hire_date
FROM employees
ORDER BY hire_date ASC
LIMIT 10;

-- 10. How many employees have held a manager position?
SELECT COUNT(DISTINCT emp_no) AS manager_count FROM dept_manager;

-- 11. What is the salary range in the company?
SELECT MIN(salary) AS min_salary, MAX(salary) AS max_salary
FROM salaries
WHERE to_date > CURDATE();

-- 12. Which job titles are most common?
SELECT title, COUNT(*) AS count
FROM titles
WHERE to_date > CURDATE()
GROUP BY title
ORDER BY count DESC;

-- 13. What are the top 5 most common first names?
SELECT first_name, COUNT(*) AS count
FROM employees
GROUP BY first_name
ORDER BY count DESC
LIMIT 5;

-- 14. What are the top 5 most common last names?
SELECT last_name, COUNT(*) AS count
FROM employees
GROUP BY last_name
ORDER BY count DESC
LIMIT 5;

-- 15. How many male vs female engineers are there?
SELECT e.gender, COUNT(*) AS count
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Engineer' AND t.to_date > CURDATE()
GROUP BY e.gender;

-- 16. What is the average salary by gender?
SELECT e.gender, AVG(s.salary) AS avg_salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date > CURDATE()
GROUP BY e.gender;

-- 17. What are the department codes and names?
SELECT dept_no, dept_name FROM departments ORDER BY dept_no;

-- 18. How many departments has each employee worked in?
SELECT e.emp_no, CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
       COUNT(DISTINCT de.dept_no) AS dept_count
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY e.emp_no, employee_name
HAVING COUNT(DISTINCT de.dept_no) > 1
ORDER BY dept_count DESC;

-- 19. How many employees have held more than one title?
SELECT COUNT(*) AS employees_with_multiple_titles
FROM (
    SELECT emp_no
    FROM titles
    GROUP BY emp_no
    HAVING COUNT(DISTINCT title) > 1
) AS multi_title_employees;

-- 20. What is the distribution of employees by job title?
SELECT t.title, COUNT(*) AS employee_count
FROM titles t
WHERE t.to_date > CURDATE()
GROUP BY t.title
ORDER BY employee_count DESC;


-- 🟡 INTERMEDIATE-LEVEL QUERIES (20)

-- 1. What is the company-wide average salary?
SELECT AVG(salary) AS company_avg_salary
FROM salaries
WHERE to_date > CURDATE();

-- 2. What is the average salary by department?
SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date > CURDATE() AND s.to_date > CURDATE()
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

-- 3. What is the total salary expense per department?
SELECT d.dept_name, SUM(s.salary) AS total_salary_expense
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date > CURDATE() AND s.to_date > CURDATE()
GROUP BY d.dept_name
ORDER BY total_salary_expense DESC;

-- 4. How many managers are there in each department?
SELECT d.dept_name, COUNT(DISTINCT dm.emp_no) AS manager_count
FROM departments d
JOIN dept_manager dm ON d.dept_no = dm.dept_no
WHERE dm.to_date > CURDATE()
GROUP BY d.dept_name
ORDER BY manager_count DESC;

-- 5. Who are the top 5 highest-paid employees?
SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE s.to_date > CURDATE()
ORDER BY s.salary DESC
LIMIT 5;

-- 6. How many employees have received promotions?
SELECT COUNT(DISTINCT emp_no) AS promoted_employees
FROM (
    SELECT emp_no, COUNT(DISTINCT title) AS title_count
    FROM titles
    GROUP BY emp_no
    HAVING title_count > 1
) AS promotions;

-- 7. What is the average tenure of employees in years?
SELECT AVG(DATEDIFF(CURDATE(), hire_date)/365 AS avg_tenure_years
FROM employees;

-- 8. Which year had the highest number of hires?
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS hires
FROM employees
GROUP BY hire_year
ORDER BY hires DESC
LIMIT 1;

-- 9. Which department has the most employees?
SELECT d.dept_name, COUNT(*) AS employee_count
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
WHERE de.to_date > CURDATE()
GROUP BY d.dept_name
ORDER BY employee_count DESC
LIMIT 1;

-- 10. What is the gender distribution within each department?
SELECT d.dept_name, e.gender, COUNT(*) AS count
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
WHERE de.to_date > CURDATE()
GROUP BY d.dept_name, e.gender
ORDER BY d.dept_name, e.gender;

-- 11. Which employees were ever promoted to manager?
SELECT DISTINCT e.emp_no, e.first_name, e.last_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no;

-- 12. Which employees were never managers?
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
WHERE e.emp_no NOT IN (SELECT DISTINCT emp_no FROM dept_manager);

-- 13. Which department has the highest average tenure?
SELECT d.dept_name, AVG(DATEDIFF(CURDATE(), e.hire_date)/365 AS avg_tenure_years
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
WHERE de.to_date > CURDATE()
GROUP BY d.dept_name
ORDER BY avg_tenure_years DESC
LIMIT 1;

-- 14. How many employees were hired before 1990?
SELECT COUNT(*) AS employees_hired_before_1990
FROM employees
WHERE hire_date < '1990-01-01';

-- 15. What are the top 5 departments by average salary?
SELECT d.dept_name, AVG(s.salary) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date > CURDATE() AND s.to_date > CURDATE()
GROUP BY d.dept_name
ORDER BY avg_salary DESC
LIMIT 5;

-- 16. Which job title has the highest average salary?
SELECT t.title, AVG(s.salary) AS avg_salary
FROM titles t
JOIN salaries s ON t.emp_no = s.emp_no
WHERE t.to_date > CURDATE() AND s.to_date > CURDATE()
GROUP BY t.title
ORDER BY avg_salary DESC
LIMIT 1;

-- 17. What is the gender distribution across job titles?
SELECT t.title, e.gender, COUNT(*) AS count
FROM titles t
JOIN employees e ON t.emp_no = e.emp_no
WHERE t.to_date > CURDATE()
GROUP BY t.title, e.gender
ORDER BY t.title, e.gender;

-- 18. How many employees have switched departments?
SELECT COUNT(DISTINCT emp_no) AS employees_switched_depts
FROM (
    SELECT emp_no
    FROM dept_emp
    GROUP BY emp_no
    HAVING COUNT(DISTINCT dept_no) > 1
) AS dept_switchers;

-- 19. What is the total salary paid to all managers?
SELECT SUM(s.salary) AS total_manager_salary
FROM dept_manager dm
JOIN salaries s ON dm.emp_no = s.emp_no
WHERE dm.to_date > CURDATE() AND s.to_date > CURDATE();

-- 20. Who worked in both multiple titles and departments?
SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
WHERE e.emp_no IN (
    SELECT emp_no
    FROM titles
    GROUP BY emp_no
    HAVING COUNT(DISTINCT title) > 1
) AND e.emp_no IN (
    SELECT emp_no
    FROM dept_emp
    GROUP BY emp_no
    HAVING COUNT(DISTINCT dept_no) > 1
);


-- 🔴 ADVANCED-LEVEL QUERIES (10)

-- 1. Which employees earn more than their department's average salary?
WITH dept_avg AS (
    SELECT d.dept_no, AVG(s.salary) AS avg_salary
    FROM departments d
    JOIN dept_emp de ON d.dept_no = de.dept_no
    JOIN salaries s ON de.emp_no = s.emp_no
    WHERE de.to_date > CURDATE() AND s.to_date > CURDATE()
    GROUP BY d.dept_no
)
SELECT e.emp_no, e.first_name, e.last_name, d.dept_name, s.salary, da.avg_salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no AND s.to_date > CURDATE()
JOIN dept_emp de ON e.emp_no = de.emp_no AND de.to_date > CURDATE()
JOIN departments d ON de.dept_no = d.dept_no
JOIN dept_avg da ON d.dept_no = da.dept_no
WHERE s.salary > da.avg_salary
ORDER BY (s.salary - da.avg_salary) DESC;

-- 2. Who is the longest-tenured employee in each department?
WITH dept_tenure AS (
    SELECT 
        d.dept_no,
        d.dept_name,
        e.emp_no,
        e.first_name,
        e.last_name,
        e.hire_date,
        DATEDIFF(CURDATE(), e.hire_date) AS tenure_days,
        RANK() OVER (PARTITION BY d.dept_no ORDER BY e.hire_date ASC) AS tenure_rank
    FROM employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no AND de.to_date > CURDATE()
    JOIN departments d ON de.dept_no = d.dept_no
)
SELECT dept_no, dept_name, emp_no, first_name, last_name, hire_date, tenure_days
FROM dept_tenure
WHERE tenure_rank = 1
ORDER BY tenure_days DESC;

-- 3. What is the percentage growth in salary per employee?
WITH salary_changes AS (
    SELECT 
        emp_no,
        FIRST_VALUE(salary) OVER (PARTITION BY emp_no ORDER BY from_date) AS first_salary,
        LAST_VALUE(salary) OVER (PARTITION BY emp_no ORDER BY from_date 
                             RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS current_salary
    FROM salaries
)
SELECT 
    e.emp_no, 
    e.first_name, 
    e.last_name,
    sc.first_salary,
    sc.current_salary,
    ROUND(((sc.current_salary - sc.first_salary) / sc.first_salary * 100), 2) AS pct_growth
FROM employees e
JOIN salary_changes sc ON e.emp_no = sc.emp_no
WHERE sc.current_salary > 0
ORDER BY pct_growth DESC;

-- 4. Which employees had the most title changes (promotions)?
SELECT e.emp_no, e.first_name, e.last_name, COUNT(t.title) - 1 AS promotion_count
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
GROUP BY e.emp_no, e.first_name, e.last_name
HAVING COUNT(t.title) > 1
ORDER BY promotion_count DESC
LIMIT 10;

-- 5. Which department has the largest gender salary gap?
WITH gender_salaries AS (
    SELECT 
        d.dept_no,
        d.dept_name,
        e.gender,
        AVG(s.salary) AS avg_salary
    FROM departments d
    JOIN dept_emp de ON d.dept_no = de.dept_no
    JOIN employees e ON de.emp_no = e.emp_no
    JOIN salaries s ON e.emp_no = s.emp_no
    WHERE de.to_date > CURDATE() AND s.to_date > CURDATE()
    GROUP BY d.dept_no, d.dept_name, e.gender
),
gender_gaps AS (
    SELECT 
        gs1.dept_no,
        gs1.dept_name,
        ABS(gs1.avg_salary - gs2.avg_salary) AS salary_gap
    FROM gender_salaries gs1
    JOIN gender_salaries gs2 ON gs1.dept_no = gs2.dept_no
    WHERE gs1.gender = 'M' AND gs2.gender = 'F'
)
SELECT dept_no, dept_name, salary_gap
FROM gender_gaps
ORDER BY salary_gap DESC
LIMIT 1;

-- 6. Which departments have the widest salary range?
SELECT 
    d.dept_no,
    d.dept_name,
    MIN(s.salary) AS min_salary,
    MAX(s.salary) AS max_salary,
    MAX(s.salary) - MIN(s.salary) AS salary_range
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE de.to_date > CURDATE() AND s.to_date > CURDATE()
GROUP BY d.dept_no, d.dept_name
ORDER BY salary_range DESC;

-- 7. What is the correlation between tenure and salary?
SELECT 
    (COUNT(*) * SUM(xy) - SUM(x) * SUM(y)) / 
    (SQRT(COUNT(*) * SUM(x2) - SUM(x) * SUM(x)) * SQRT(COUNT(*) * SUM(y2) - SUM(y) * SUM(y))) 
    AS correlation
FROM (
    SELECT 
        DATEDIFF(CURDATE(), e.hire_date) AS x,
        s.salary AS y,
        DATEDIFF(CURDATE(), e.hire_date) * DATEDIFF(CURDATE(), e.hire_date) AS x2,
        s.salary * s.salary AS y2,
        DATEDIFF(CURDATE(), e.hire_date) * s.salary AS xy
    FROM employees e
    JOIN salaries s ON e.emp_no = s.emp_no
    WHERE s.to_date > CURDATE()
) AS stats;

-- 8. What is the average promotion frequency by department?
WITH promotion_counts AS (
    SELECT 
        de.dept_no,
        d.dept_name,
        t.emp_no,
        COUNT(t.title) - 1 AS promotion_count
    FROM titles t
    JOIN dept_emp de ON t.emp_no = de.emp_no
    JOIN departments d ON de.dept_no = d.dept_no
    WHERE de.to_date > CURDATE()
    GROUP BY de.dept_no, d.dept_name, t.emp_no
    HAVING COUNT(t.title) > 1
)
SELECT 
    dept_no,
    dept_name,
    AVG(promotion_count) AS avg_promotions,
    COUNT(emp_no) AS promoted_employees
FROM promotion_counts
GROUP BY dept_no, dept_name
ORDER BY avg_promotions DESC;

-- 9. Which job title sees the highest turnover?
WITH title_changes AS (
    SELECT 
        title,
        COUNT(*) AS total_holders,
        COUNT(DISTINCT emp_no) AS unique_holders,
        COUNT(*) / COUNT(DISTINCT emp_no) AS avg_times_held
    FROM titles
    GROUP BY title
)
SELECT 
    title,
    total_holders,
    unique_holders,
    avg_times_held,
    (total_holders - unique_holders) AS turnover_count
FROM title_changes
ORDER BY turnover_count DESC
LIMIT 1;

-- 10. Which year had the largest salary increase across the company?
WITH yearly_salaries AS (
    SELECT 
        YEAR(s.from_date) AS salary_year,
        AVG(s.salary) AS avg_salary
    FROM salaries s
    GROUP BY salary_year
),
salary_changes AS (
    SELECT 
        salary_year,
        avg_salary,
        LAG(avg_salary) OVER (ORDER BY salary_year) AS prev_avg_salary,
        avg_salary - LAG(avg_salary) OVER (ORDER BY salary_year) AS salary_increase
    FROM yearly_salaries
)
SELECT 
    salary_year,
    avg_salary,
    prev_avg_salary,
    salary_increase
FROM salary_changes
WHERE salary_increase IS NOT NULL
ORDER BY salary_increase DESC
LIMIT 1;