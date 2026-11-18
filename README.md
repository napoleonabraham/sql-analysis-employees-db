# HR Analytics with SQL: MySQL Employees Database

An HR analytics project on the **MySQL Employees Sample Database**, a public dataset that simulates a company's HR system: 300,024 employees with their departments, job titles and salary history from 1985 to 2002.

The project inspects the data, checks its quality, and then answers 19 business questions about workforce structure, pay, career progression and retention using SQL.

## Key findings

All figures come from running the queries in this repository on MySQL 8.0. Full output is in the [`results/`](results) folder.

**Workforce**

- 300,024 people were ever hired; **240,124 are still employed** and 59,900 (20.0%) have left.
- Development (25.6%), Production (22.2%) and Sales (15.7%) make up almost two thirds of the current workforce.
- Hiring fell every year after 1986, from 36,150 hires that year to 13 in 2000. The workforce is therefore long-serving: current employees average **12.5 years** of tenure.
- Women are 40.0% of the workforce, with almost no variation between departments (39.5% to 40.4%).

**Compensation**

- The average current salary is about $72,000. **Sales pays the most** ($88,853 on average), followed by Marketing ($80,059) and Finance ($78,560). Human Resources pays the least ($63,922).
- Development has the largest payroll at $4.15 billion a year, because of its headcount rather than its pay level.
- **There is no meaningful gender pay gap.** Men earn 0.11% more than women overall, and the gap in every department is under 1% (largest: Marketing, 0.74% in favour of men; Human Resources, 0.57% in favour of women).
- Current employees earn on average 38.2% more than their starting salary. 260 employees are paid less today than when they started.
- Average salary rose about 1.5% to 1.8% a year until 1999, then about 3% a year from 2000 to 2002.
- Tenure and salary are moderately correlated (r = 0.306): longer service goes with higher pay, but explains only a small part of it.
- Two department managers, in Customer Service and Production, earn less than the average employee of their own department.

**Career progression and retention**

- 53.2% of employees have held only one title, 45.7% have held two, and 1.0% three.
- Almost all title changes are one of three promotions: Engineer to Senior Engineer (67,700), Staff to Senior Staff (66,261) and Assistant Engineer to Engineer (9,293). Each takes **about 6.7 to 6.8 years** on average.
- 10.5% of employees have changed department.
- Attrition is uniform: every department has lost between 19.5% and 20.5% of its people, and leavers stayed 7.3 years on average.

**A note on the data.** The dataset is synthetic, which is why many splits (gender share, tenure, attrition) are almost identical across departments. The findings demonstrate the method; they are not insights about a real company.

## Data quality

`data_exploration.sql` runs 18 read-only checks: missing values, duplicate employees, employees without salary, title or department records, conflicting "current" records, reversed date ranges, records dated before the hire date, and invalid salaries. **All 18 checks returned zero problems**, so no cleaning was required.

Two properties of the data shape every query:

- Open-ended records use the sentinel date `9999-01-01`, so "current" means `to_date = '9999-01-01'`.
- The data stops on **2002-08-01**. Tenure is measured to that date, not to today's date.

## Repository contents

| File | Description |
|---|---|
| `data_exploration.sql` | Table inspection, exploration and the data quality report |
| `hr_analytics_queries.sql` | 19 analysis queries in four sections |
| `results/data_exploration_output.txt` | Output of the exploration file |
| `results/hr_analytics_output.txt` | Output of the analytics file |

### Analysis sections

| Section | Questions | SQL techniques |
|---|---|---|
| A. Workforce overview | Headcount, department size, hiring by year | Joins, aggregation, window totals |
| B. Workforce demographics | Gender split, title mix, tenure | Conditional aggregation, `ROLLUP` |
| C. Compensation | Pay by department and title, gender pay gap, top earners, manager pay, salary growth, correlation | CTEs, `DENSE_RANK`, `FIRST_VALUE` / `LAST_VALUE`, `LAG` |
| D. Career progression and retention | Titles held, promotion paths, department moves, attrition | `LEAD`, `ROW_NUMBER`, subqueries |

## How to run

Requires **MySQL 8.0 or later** (the queries use CTEs and window functions).

1. Install the dataset from the [official repository](https://github.com/datacharmer/test_db):

   ```bash
   git clone https://github.com/datacharmer/test_db.git
   cd test_db
   mysql -u root -p < employees.sql
   ```

2. Run the project files:

   ```bash
   mysql -u root -p -t < data_exploration.sql
   mysql -u root -p -t < hr_analytics_queries.sql
   ```

## License

MIT. See [LICENSE](LICENSE).
