## 📊 Introduction

The **Employees Database** is a popular open-source dataset created by MySQL that simulate real-world HR system. It contains data on over 300,000 fictional employees, including their personal details, departments, salaries, job titles, and employment history over time.

This project uses this dataset to perform **HR analytics** using SQL — extracting meaningful business insights that support decision-making in areas like compensation, workforce structure, tenure, and career progression.

---

## 🧠 General Process of Business (HR) Analysis

The SQL queries in this repository follow a structured **HR analytics processes**, including:

1. **Data Understanding**  
   - Familiarizing with table structures and relationships
   - Data inspection,exploaration and cleaning 
   - Key tables: `employees`, `salaries`, `titles`, `departments`, `dept_emp`, `dept_manager`

2. **Descriptive Analysis**  
   - Counting employees, departments, gender distribution, and hiring patterns

3. **Workforce Demographics**  
   - Analyzing age, gender, tenure, and job title distributions

4. **Compensation Analysis**  
   - Tracking salary ranges, growth, and comparisons across departments

5. **Career Progression & Retention**  
   - Investigating promotion patterns, seniority, and departmental movement

6. **Advanced Insights**  
   - Building performance metrics and HR KPIs from query results

---

## 📂 Dataset Link

You can download or install the **Employees Sample Database** from the official GitHub repository:

🔗 [MySQL Employees Sample Database](https://github.com/datacharmer/test_db)

To install it locally:
```bash
git clone https://github.com/datacharmer/test_db.git
cd test_db
mysql -u root -p < employees.sql

# 🧮 HR Analytics SQL Queries-The employees database.

## 📌 Overview

This repository contains a comprehensive collection of **50 SQL queries** for **HR analytics**, organized by difficulty level:

- ✅ Beginner (20)
- 🟡 Intermediate (20)
- 🔴 Advanced (10)

These queries are designed to extract valuable insights from employee databases, covering metrics like **compensation analysis**, **workforce demographics**, **tenure patterns**, and **promotion trends**.

---

## 🗂️ Query Categories

### ✅ Beginner-Level (20 Queries)
- Basic workforce metrics  
- Departmental analysis  
- Employee demographics  
- Salary ranges  
- Common names analysis  

### 🟡 Intermediate-Level (20 Queries)
- Compensation analytics  
- Managerial insights  
- Promotion tracking  
- Tenure analysis  
- Gender distribution metrics  

### 🔴 Advanced-Level (10 Queries)
- Salary growth patterns  
- Departmental pay gaps  
- Turnover analysis  
- Correlation studies  
- Complex career path tracking  

---

## 🛠️ Technical Details

**Database Compatibility:** MySQL  
**Schema Requirements:**
- `employees` table  
- `departments` table  
- Department-employee assignments (`dept_emp`)  
- Salary records (`salaries`)  
- Title histories (`titles`)  

### Key Features:
- Filters for **current employees** (`to_date > CURDATE()`)
- Formatted currency and percentage outputs
- Uses **window functions** for advanced logic
- Uses **CTEs** for query readability
- **Optimized joins** for performance

---

## 🚀 How to Use

1. Clone this repository  https://github.com/napoleonabraham/sql-analysis-employees-db/blob/main/README.md
2. Connect to your MySQL employee database  
3. Execute any query file based on your need  
4. Modify table/column names to match your schema  
5. Use the results in reports, dashboards, or business decisions  

---

## 📊 Sample Insights You Can Extract

- Identify **pay disparities** across departments  
- Track **employee career progression**  
- Analyze **gender pay gaps**  
- Find **retention risks** and **top performers**  
- Optimize **compensation strategies**  

---

## 📝 Notes

- Queries assume a standard HR database schema  
- `CURDATE()` is used in date filters – adjust as needed  
- For large datasets, queries may require **index tuning**  
- Output results can be exported to tools like **Tableau**, **Power BI**, or **Excel**  

---

## 🤝 Contributing

Contributions are welcome! Please submit a **Pull Request (PR)** for:
- Additional query optimizations  
- New insightful business analyses  
- Support for other database systems (PostgreSQL, SQL Server, etc.)  
- Enhanced documentation and formatting  

