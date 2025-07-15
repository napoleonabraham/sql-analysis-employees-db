
# 🧮 HR Analytics SQL Queries,The employees database.

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

1. Clone this repository  
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

