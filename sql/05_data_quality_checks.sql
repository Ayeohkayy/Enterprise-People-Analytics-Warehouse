/* ============================================================
   DATA QUALITY CHECKS – PEOPLE ANALYTICS WAREHOUSE
   Purpose:
   Validate data integrity across staging, dimensions, and facts
   ============================================================ */


/* ============================================================
   1. ROW COUNT VALIDATION (Sanity Checks)
   Ensure data loaded correctly from CSV into staging
   ============================================================ */

SELECT 'stg_employees' AS table_name, COUNT(*) AS row_count
FROM people_analytics.stg_employees

UNION ALL

SELECT 'stg_compensation_history', COUNT(*)
FROM people_analytics.stg_compensation_history

UNION ALL

SELECT 'stg_performance_reviews', COUNT(*)
FROM people_analytics.stg_performance_reviews

UNION ALL

SELECT 'stg_engagement_surveys', COUNT(*)
FROM people_analytics.stg_engagement_surveys

UNION ALL

SELECT 'stg_candidates', COUNT(*)
FROM people_analytics.stg_candidates

UNION ALL

SELECT 'stg_requisitions', COUNT(*)
FROM people_analytics.stg_requisitions;


/* ============================================================
   2. PRIMARY KEY DUPLICATE CHECKS
   Ensure uniqueness of business keys
   ============================================================ */

-- Employees should be unique
SELECT EmployeeID, COUNT(*) AS duplicate_count
FROM people_analytics.stg_employees
GROUP BY EmployeeID
HAVING COUNT(*) > 1;

-- Candidates should be unique
SELECT CandidateID, COUNT(*) AS duplicate_count
FROM people_analytics.stg_candidates
GROUP BY CandidateID
HAVING COUNT(*) > 1;


/* ============================================================
   3. NULL / MISSING VALUE CHECKS
   Identify critical missing fields
   ============================================================ */

-- Employees missing key identifiers
SELECT *
FROM people_analytics.stg_employees
WHERE EmployeeID IS NULL
   OR DepartmentID IS NULL
   OR JobID IS NULL;

-- Compensation records missing salary
SELECT *
FROM people_analytics.stg_compensation_history
WHERE BaseSalary IS NULL;

-- Performance records missing rating
SELECT *
FROM people_analytics.stg_performance_reviews
WHERE PerformanceRating IS NULL;


/* ============================================================
   4. REFERENTIAL INTEGRITY CHECKS
   Ensure relationships between tables are valid
   ============================================================ */

-- Compensation without matching employee
SELECT c.EmployeeID
FROM people_analytics.stg_compensation_history c
LEFT JOIN people_analytics.stg_employees e
    ON c.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;

-- Performance without matching employee
SELECT p.EmployeeID
FROM people_analytics.stg_performance_reviews p
LEFT JOIN people_analytics.stg_employees e
    ON p.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;

-- Engagement without matching employee
SELECT g.EmployeeID
FROM people_analytics.stg_engagement_surveys g
LEFT JOIN people_analytics.stg_employees e
    ON g.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;


/* ============================================================
   5. BUSINESS RULE VALIDATION
   Ensure data follows expected HR logic
   ============================================================ */

-- Termination date should not be before hire date
SELECT EmployeeID, HireDate, TerminationDate
FROM people_analytics.stg_employees
WHERE TerminationDate IS NOT NULL
  AND TerminationDate < HireDate;

-- Salary should be positive
SELECT *
FROM people_analytics.stg_compensation_history
WHERE BaseSalary < 0;

-- Engagement scores should be within expected range (0–5)
SELECT *
FROM people_analytics.stg_engagement_surveys
WHERE EngagementScore < 0
   OR EngagementScore > 5;

-- Performance ratings should be within expected range (1–5)
SELECT *
FROM people_analytics.stg_performance_reviews
WHERE PerformanceRating < 1
   OR PerformanceRating > 5;


/* ============================================================
   6. FACT TABLE VALIDATION
   Ensure transformations did not break relationships
   ============================================================ */

-- fact_compensation should align with dim_employee
SELECT f.EmployeeID
FROM people_analytics.fact_compensation f
LEFT JOIN people_analytics.dim_employee e
    ON f.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;

-- fact_performance should align with dim_employee
SELECT f.EmployeeID
FROM people_analytics.fact_performance f
LEFT JOIN people_analytics.dim_employee e
    ON f.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;

-- fact_engagement should align with dim_employee
SELECT f.EmployeeID
FROM people_analytics.fact_engagement f
LEFT JOIN people_analytics.dim_employee e
    ON f.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;


/* ============================================================
   7. KPI VALIDATION CHECKS
   Ensure views return expected results
   ============================================================ */

-- Headcount should not be negative or zero (unless test data)
SELECT *
FROM people_analytics.vw_current_headcount;

-- Attrition rates should not exceed 100%
SELECT *
FROM people_analytics.vw_attrition_rate_by_department
WHERE attrition_rate_pct > 100;

-- Salary averages should be reasonable (no extreme outliers)
SELECT *
FROM people_analytics.vw_current_salary_by_department
WHERE avg_current_base_salary < 0;