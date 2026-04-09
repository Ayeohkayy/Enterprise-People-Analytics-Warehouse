--Dimension tables 

CREATE TABLE people_analytics.dim_department AS
SELECT DISTINCT
    DepartmentID,
    DepartmentName
FROM people_analytics.stg_departments;

CREATE TABLE people_analytics.dim_job AS
SELECT DISTINCT
    JobID,
    JobTitle,
    JobLevel,
    DepartmentID
FROM people_analytics.stg_jobs;

CREATE TABLE people_analytics.dim_location AS
SELECT DISTINCT
    LocationID,
    LocationName,
	State,
    Region
FROM people_analytics.stg_locations;

CREATE TABLE people_analytics.dim_employee AS
SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.HireDate,
    e.TerminationDate,
    e.DepartmentID,
    e.JobID,
    e.LocationID,
    e.ManagerID,
    e.EmploymentStatus,
    e.Gender,
    d.Ethnicity,
    e.BirthDate,
    d.MaritalStatus,
	d.Educationlevel
FROM people_analytics.stg_employees e
LEFT JOIN people_analytics.stg_employee_demographics d
    ON e.EmployeeID = d.EmployeeID;



DROP TABLE IF EXISTS people_analytics.dim_date;

CREATE TABLE people_analytics.dim_date AS
SELECT
    TO_CHAR(d::date, 'YYYYMMDD')::INT AS DateKey,
    d::date AS FullDate,
    EXTRACT(YEAR FROM d)::INT AS Year,
    EXTRACT(QUARTER FROM d)::INT AS Quarter,
    EXTRACT(MONTH FROM d)::INT AS Month,
    TO_CHAR(d::date, 'Month') AS MonthName,
    EXTRACT(DAY FROM d)::INT AS DayOfMonth,
    EXTRACT(WEEK FROM d)::INT AS WeekOfYear,
    TO_CHAR(d::date, 'YYYY-MM') AS YearMonth,
    TO_CHAR(d::date, 'Dy') AS DayName,
    CASE 
        WHEN EXTRACT(ISODOW FROM d) IN (6, 7) THEN TRUE
        ELSE FALSE
    END AS IsWeekend
FROM generate_series(
    DATE '2018-01-01',
    DATE '2030-12-31',
    INTERVAL '1 day'
) AS d;