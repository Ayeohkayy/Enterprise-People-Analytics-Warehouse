--views_kpis
--Creating Current Headcount View
DROP VIEW IF EXISTS people_analytics.vw_current_headcount;

CREATE VIEW people_analytics.vw_current_headcount AS
SELECT
    COUNT(*) AS current_headcount
FROM people_analytics.dim_employee
WHERE HireDate <= CURRENT_DATE
  AND (
        TerminationDate IS NULL
        OR TerminationDate > CURRENT_DATE
      );


--Creating current Headcound by Department View
DROP VIEW IF EXISTS people_analytics.vw_current_headcount_by_department;

CREATE VIEW people_analytics.vw_current_headcount_by_department AS
SELECT
    d.DepartmentID,
    d.DepartmentName,
    COUNT(e.EmployeeID) AS current_headcount
FROM people_analytics.dim_department d
LEFT JOIN people_analytics.dim_employee e
    ON d.DepartmentID = e.DepartmentID
   AND e.HireDate <= CURRENT_DATE
   AND (
        e.TerminationDate IS NULL
        OR e.TerminationDate > CURRENT_DATE
       )
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY current_headcount DESC;


--Attrition summary.This gives terminated employee counts by year and month.

DROP VIEW IF EXISTS people_analytics.vw_attrition_summary;

CREATE VIEW people_analytics.vw_attrition_summary AS
SELECT
    EXTRACT(YEAR FROM TerminationDate)::INT AS year,
    EXTRACT(MONTH FROM TerminationDate)::INT AS month,
    COUNT(*) AS terminations
FROM people_analytics.dim_employee
WHERE TerminationDate IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM TerminationDate),
    EXTRACT(MONTH FROM TerminationDate)
ORDER BY year, month;


--Attrition by department
DROP VIEW IF EXISTS people_analytics.vw_attrition_by_department;

CREATE VIEW people_analytics.vw_attrition_by_department AS
SELECT
    d.DepartmentID,
    d.DepartmentName,
    COUNT(e.EmployeeID) AS terminations
FROM people_analytics.dim_department d
LEFT JOIN people_analytics.dim_employee e
    ON d.DepartmentID = e.DepartmentID
WHERE e.TerminationDate IS NOT NULL
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY terminations DESC;



--Attrition rate by department
DROP VIEW IF EXISTS people_analytics.vw_attrition_rate_by_department;

CREATE VIEW people_analytics.vw_attrition_rate_by_department AS
WITH employee_counts AS (
    SELECT
        DepartmentID,
        COUNT(EmployeeID) AS total_employees,
        COUNT(CASE WHEN TerminationDate IS NOT NULL THEN 1 END) AS terminated_employees
    FROM people_analytics.dim_employee
    GROUP BY DepartmentID
)
SELECT
    d.DepartmentID,
    d.DepartmentName,
    e.total_employees,
    e.terminated_employees,
    ROUND(
        (e.terminated_employees::NUMERIC / NULLIF(e.total_employees, 0)) * 100,
        2
    ) AS attrition_rate_pct
FROM employee_counts e
JOIN people_analytics.dim_department d
    ON e.DepartmentID = d.DepartmentID
ORDER BY attrition_rate_pct DESC;


--Avg Salary by Department
DROP VIEW IF EXISTS people_analytics.vw_avg_salary_by_department;

CREATE VIEW people_analytics.vw_avg_salary_by_department AS
SELECT
    d.DepartmentID,
    d.DepartmentName,
    ROUND(AVG(c.BaseSalary), 2) AS avg_base_salary,
    ROUND(AVG(c.AnnualBonusTarget), 2) AS avg_annual_bonus_target
FROM people_analytics.fact_compensation c
JOIN people_analytics.dim_employee e
    ON c.EmployeeID = e.EmployeeID
JOIN people_analytics.dim_department d
    ON e.DepartmentID = d.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY avg_base_salary DESC;


--Better version using latest compensation per employee
DROP VIEW IF EXISTS people_analytics.vw_current_salary_by_department;

CREATE VIEW people_analytics.vw_current_salary_by_department AS
WITH latest_comp AS (
    SELECT
        EmployeeID,
        BaseSalary,
        AnnualBonusTarget,
        EffectiveDate,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate DESC
        ) AS rn
    FROM people_analytics.fact_compensation
)
SELECT
    d.DepartmentID,
    d.DepartmentName,
    ROUND(AVG(lc.BaseSalary), 2) AS avg_current_base_salary,
    ROUND(AVG(lc.AnnualBonusTarget), 2) AS avg_current_bonus_target
FROM latest_comp lc
JOIN people_analytics.dim_employee e
    ON lc.EmployeeID = e.EmployeeID
JOIN people_analytics.dim_department d
    ON e.DepartmentID = d.DepartmentID
WHERE lc.rn = 1
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY avg_current_base_salary DESC;


--Performance Summary
DROP VIEW IF EXISTS people_analytics.vw_performance_summary;

CREATE VIEW people_analytics.vw_performance_summary AS
SELECT
    EXTRACT(YEAR FROM ReviewDate)::INT AS review_year,
    ROUND(AVG(PerformanceRating), 2) AS avg_performance_rating,
    ROUND(AVG(PotentialRating), 2) AS avg_potential_rating,
    ROUND(AVG(GoalCompletionPct), 2) AS avg_goal_completion_pct,
    ROUND(AVG(MeritIncreasePct) * 100, 2) AS avg_merit_increase_pct
FROM people_analytics.fact_performance
GROUP BY EXTRACT(YEAR FROM ReviewDate)
ORDER BY review_year;

--Perfromance by Department
DROP VIEW IF EXISTS people_analytics.vw_performance_by_department;

CREATE VIEW people_analytics.vw_performance_by_department AS
SELECT
    d.DepartmentID,
    d.DepartmentName,
    ROUND(AVG(p.PerformanceRating), 2) AS avg_performance_rating,
    ROUND(AVG(p.PotentialRating), 2) AS avg_potential_rating,
    ROUND(AVG(p.GoalCompletionPct), 2) AS avg_goal_completion_pct
FROM people_analytics.fact_performance p
JOIN people_analytics.dim_employee e
    ON p.EmployeeID = e.EmployeeID
JOIN people_analytics.dim_department d
    ON e.DepartmentID = d.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY avg_performance_rating DESC;


--Engagement Summary
DROP VIEW IF EXISTS people_analytics.vw_engagement_summary;

CREATE VIEW people_analytics.vw_engagement_summary AS
SELECT
    EXTRACT(YEAR FROM SurveyDate)::INT AS survey_year,
    ROUND(AVG(EngagementScore), 2) AS avg_engagement_score,
    ROUND(AVG(ManagerEffectivenessScore), 2) AS avg_manager_effectiveness_score,
    ROUND(AVG(InclusionScore), 2) AS avg_inclusion_score,
    ROUND(AVG(IntentToStayScore), 2) AS avg_intent_to_stay_score
FROM people_analytics.fact_engagement
GROUP BY EXTRACT(YEAR FROM SurveyDate)
ORDER BY survey_year;

--Engagement By Department
DROP VIEW IF EXISTS people_analytics.vw_engagement_by_department;

CREATE VIEW people_analytics.vw_engagement_by_department AS
SELECT
    d.DepartmentID,
    d.DepartmentName,
    ROUND(AVG(g.EngagementScore), 2) AS avg_engagement_score,
    ROUND(AVG(g.ManagerEffectivenessScore), 2) AS avg_manager_effectiveness_score,
    ROUND(AVG(g.InclusionScore), 2) AS avg_inclusion_score,
    ROUND(AVG(g.IntentToStayScore), 2) AS avg_intent_to_stay_score
FROM people_analytics.fact_engagement g
JOIN people_analytics.dim_employee e
    ON g.EmployeeID = e.EmployeeID
JOIN people_analytics.dim_department d
    ON e.DepartmentID = d.DepartmentID
GROUP BY
    d.DepartmentID,
    d.DepartmentName
ORDER BY avg_engagement_score DESC;

--Engagement vs performance
DROP VIEW IF EXISTS people_analytics.vw_engagement_vs_performance;

CREATE VIEW people_analytics.vw_engagement_vs_performance AS
WITH latest_engagement AS (
    SELECT
        EmployeeID,
        SurveyDate,
        EngagementScore,
        IntentToStayScore,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeID
            ORDER BY SurveyDate DESC
        ) AS rn
    FROM people_analytics.fact_engagement
),
latest_performance AS (
    SELECT
        EmployeeID,
        ReviewDate,
        PerformanceRating,
        PotentialRating,
        ROW_NUMBER() OVER (
            PARTITION BY EmployeeID
            ORDER BY ReviewDate DESC
        ) AS rn
    FROM people_analytics.fact_performance
)
SELECT
    e.EmployeeID,
    e.DepartmentID,
    d.DepartmentName,
    g.SurveyDate,
    g.EngagementScore,
    g.IntentToStayScore,
    p.ReviewDate,
    p.PerformanceRating,
    p.PotentialRating
FROM people_analytics.dim_employee e
LEFT JOIN latest_engagement g
    ON e.EmployeeID = g.EmployeeID
   AND g.rn = 1
LEFT JOIN latest_performance p
    ON e.EmployeeID = p.EmployeeID
   AND p.rn = 1
LEFT JOIN people_analytics.dim_department d
    ON e.DepartmentID = d.DepartmentID;
