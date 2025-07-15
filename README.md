HR Analytics SQL Queries - README
📌 Overview

This repository contains a comprehensive collection of 50 SQL queries for HR analytics, organized by difficulty level (Beginner, Intermediate, Advanced). These queries are designed to extract valuable insights from employee databases, covering metrics like compensation analysis, workforce demographics, tenure patterns, and promotion trends.

🗂️ Query Categories

✅ Beginner-Level (20 Queries)

Basic workforce metrics
Departmental analysis
Employee demographics
Salary ranges
Common names analysis
🟡 Intermediate-Level (20 Queries)

Compensation analytics
Managerial insights
Promotion tracking
Tenure analysis
Gender distribution metrics
🔴 Advanced-Level (10 Queries)

Salary growth patterns
Departmental pay gaps
Turnover analysis
Correlation studies
Complex career path tracking
🛠️ Technical Details

Database Compatibility: MySQL
Schema Requirements:

Employees table
Departments table
Department employee assignments
Salary records
Title histories
Key Features:

All queries filter for current employees (to_date > CURDATE())
Properly formatted currency and percentage outputs
Window functions for complex calculations
CTEs for improved readability
Performance-optimized joins
🚀 How to Use

Clone this repository
Execute queries against your employee database
Modify table/column names to match your schema
Use results for HR reporting and decision-making
📊 Sample Insights You Can Extract

Identify pay disparities across departments
Track employee career progression
Analyze gender pay gaps
Find retention risks and top performers
Optimize compensation strategies
📝 Notes

Queries assume standard HR database schema
Date filters use current date - adjust as needed
Some queries may require tuning for large datasets
Results can be exported to visualization tools
🤝 Contributing

Contributions welcome! Please submit PRs for:

Additional query optimizations
New insightful analyses
Support for other database systems
Enhanced documentation

