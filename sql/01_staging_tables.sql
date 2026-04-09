CREATE SCHEMA IF NOT EXISTS people_analytics;



CREATE TABLE people_analytics.stg_employees (
    EmployeeID INT,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Email VARCHAR(150),
    Gender VARCHAR(50),
    BirthDate DATE,
    Age INT,
    DepartmentID INT,
    JobID INT,
    JobTitle VARCHAR(150),
    JobLevel INT,
    LocationID INT,
    HireDate DATE,
    TerminationDate DATE,
    EmploymentStatus VARCHAR(50),
    TerminationType VARCHAR(50),
    WorkerType VARCHAR(50),
    EmploymentType VARCHAR(50),
    Exempt BOOLEAN,
    FTE NUMERIC(3,2),
    RemoteStatus VARCHAR(50),
    ManagerID INT,
    ManagerName VARCHAR(150),
    FullTenureYears NUMERIC(6,2),
    CurrentSalary NUMERIC(12,2),
    CurrentBonusTarget NUMERIC(12,2)
);



CREATE TABLE people_analytics.stg_employee_demographics (
    EmployeeID INT,
    GenderIdentity VARCHAR(50),
    Ethnicity VARCHAR(100),
	VerteranStatus VARCHAR(50),
	DisabilityStaus VARCHAR(50),
    MaritalStatus VARCHAR(50),
	EducationLevel VARCHAR(50)
);


CREATE TABLE people_analytics.stg_departments (
    DepartmentID INT,
    DepartmentName VARCHAR(100),
	FunctionGroup VARCHAR(100)
);


CREATE TABLE people_analytics.stg_jobs (
    JobID INT,
	DepartmentID INT,
    JobTitle VARCHAR(150),
    JobLevel VARCHAR(50),
	Exempt Boolean,
	DepartmentName VARCHAR(100),
	FunctionGroup VARCHAR(100),
    BaseSalaryMin INT,
	BaseSalaryMax INT
);


CREATE TABLE people_analytics.stg_locations (
    LocationID INT,
    LocationName VARCHAR(100),
    State VARCHAR(100),
    Region VARCHAR(100),
	CostIndex Float
);

CREATE TABLE people_analytics.stg_compensation_history (
    CompensationEventID VARCHAR(30),
    EmployeeID INT,
    EffectiveDate DATE,
    BaseSalary NUMERIC(12,2),
    BonusTargetPct NUMERIC(5,4),
    AnnualBonusTarget NUMERIC(12,2),
    PayGrade VARCHAR(20),
    CompensationChangeReason VARCHAR(100)
);

CREATE TABLE people_analytics.stg_engagement_surveys (
    SurveyResponseID VARCHAR(30),
    EmployeeID INT,
    SurveyDate DATE,
    EngagementScore NUMERIC(3,1),
    ManagerEffectivenessScore NUMERIC(3,1),
    InclusionScore NUMERIC(3,1),
    IntentToStayScore NUMERIC(3,1),
    SurveyParticipationFlag VARCHAR(10)
);


CREATE TABLE people_analytics.stg_performance_reviews (
    ReviewID VARCHAR(30),
    EmployeeID INT,
    ReviewDate DATE,
    PerformanceRating INT,
    PotentialRating INT,
    GoalCompletionPct NUMERIC(5,2),
    MeritIncreasePct NUMERIC(6,4),
    PromotionRecommended VARCHAR(10)
);


CREATE TABLE people_analytics.stg_promotions (
    PromotionEventID VARCHAR(30),
    EmployeeID INT,
    PromotionDate DATE,
    PriorJobLevel INT,
    NewJobLevel INT,
    PromotionType VARCHAR(50)
);

CREATE TABLE people_analytics.stg_candidates (
    CandidateID INT,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Gender VARCHAR(50),
    RequisitionID INT,
    ApplicationDate DATE,
    Source VARCHAR(100),
    CurrentStage VARCHAR(50),
    JobID INT,
    DepartmentID INT,
    JobTitle VARCHAR(150),
    JobLevel INT,
    Recruiter VARCHAR(100),
    InterviewScore NUMERIC(3,1),
    OfferAccepted VARCHAR(10),
    DaysToFill NUMERIC(6,1)
);

CREATE TABLE people_analytics.stg_requisitions (
    RequisitionID INT,
    JobID INT,
    OpenDate DATE,
    Recruiter VARCHAR(100),
    RequisitionStatus VARCHAR(50),
    Openings INT,
    DepartmentID INT,
    JobTitle VARCHAR(150),
    JobLevel INT,
    HiringManagerID INT,
    HiringManagerName VARCHAR(150),
    CloseDate DATE
);


CREATE TABLE people_analytics.stg_headcount_monthly (
    DepartmentID INT,
    LocationID INT,
    Headcount INT,
    SnapshotDate DATE,
    DepartmentName VARCHAR(100),
    LocationName VARCHAR(100),
    Region VARCHAR(100)
);