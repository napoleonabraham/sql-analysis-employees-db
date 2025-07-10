# 🧮 Employees SQL Analysis Project

This project explores the Employees Sample Database using SQL queries in MySQL Workbench.

## 📁 Contents

- `employees_analysis.sql`: Includes data inspection, exploration, and business analysis queries.

## ✅ Sample Query

```sql
SELECT dept_name, AVG(salary)
FROM salaries
JOIN dept_emp ON salaries.emp_no = dept_emp.emp_no
JOIN departments ON dept_emp.dept_no = departments.dept_no
GROUP BY dept_name;
