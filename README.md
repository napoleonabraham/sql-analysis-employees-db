# 🧮 Employees SQL Analysis Project

This project showcases SQL querying and data analysis skills using the **Employees Sample Database** provided by MySQL. It includes queries that perform data inspection, explore employee trends, and extract valuable business insights from organizational data.

---

## 📦 Project Structure


---

## 🛠 Tools & Technologies

- **Database**: MySQL
- **Query Interface**: MySQL Workbench
- **Version Control**: Git & GitHub

---

## 🎯 Project Objectives

- Understand and inspect relational database structures
- Explore employee data such as gender distribution, hiring trends, and job titles
- Analyze salaries and promotions across departments
- Extract business insights using SQL JOINs, GROUP BY, and aggregate functions

---

## 📊 Analysis Topics

### 1. 🧾 Data Inspection
- List all tables
- View structure of key tables
- Sample records from `employees`, `departments`, etc.
- Hire date range and null checks

### 2. 📈 Data Exploration
- Gender distribution among employees
- Year-wise hiring trend
- Most common employee first names

### 3. 💼 Business Analysis
- Average salary by department
- Top 5 highest-paid employees
- Count of employees promoted to manager roles

---

## ✅ Sample SQL Queries

```sql
-- Total number of employees
SELECT COUNT(*) FROM employees;

-- Average salary by department
SELECT d.dept_name, ROUND(AVG(s.salary), 2) AS avg_salary
FROM salaries s
JOIN dept_emp de ON s.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name;

