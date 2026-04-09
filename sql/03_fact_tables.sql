--Fact Tables

DROP TABLE IF EXISTS people_analytics.fact_compensation;

CREATE TABLE people_analytics.fact_compensation AS
SELECT
    CompensationEventID,
    EmployeeID,
    TO_CHAR(EffectiveDate, 'YYYYMMDD')::INT AS EffectiveDateKey,
    EffectiveDate,
    BaseSalary,
    BonusTargetPct,
    AnnualBonusTarget,
    PayGrade,
    CompensationChangeReason
FROM people_analytics.stg_compensation_history;


DROP TABLE IF EXISTS people_analytics.fact_performance;

CREATE TABLE people_analytics.fact_performance AS
SELECT
    ReviewID,
    EmployeeID,
    TO_CHAR(ReviewDate, 'YYYYMMDD')::INT AS ReviewDateKey,
    ReviewDate,
    PerformanceRating,
    PotentialRating,
    GoalCompletionPct,
    MeritIncreasePct,
    PromotionRecommended
FROM people_analytics.stg_performance_reviews;


DROP TABLE IF EXISTS people_analytics.fact_engagement;

CREATE TABLE people_analytics.fact_engagement AS
SELECT
    SurveyResponseID,
    EmployeeID,
    TO_CHAR(SurveyDate, 'YYYYMMDD')::INT AS SurveyDateKey,
    SurveyDate,
    EngagementScore,
    ManagerEffectivenessScore,
    InclusionScore,
    IntentToStayScore,
    SurveyParticipationFlag
FROM people_analytics.stg_engagement_surveys;


DROP TABLE IF EXISTS people_analytics.fact_promotions;

CREATE TABLE people_analytics.fact_promotions AS
SELECT
    PromotionEventID,
    EmployeeID,
    TO_CHAR(PromotionDate, 'YYYYMMDD')::INT AS PromotionDateKey,
    PromotionDate,
    PriorJobLevel,
    NewJobLevel,
    PromotionType
FROM people_analytics.stg_promotions;


DROP TABLE IF EXISTS people_analytics.fact_recruiting;

CREATE TABLE people_analytics.fact_recruiting AS
SELECT
    c.CandidateID,
    c.RequisitionID,
    TO_CHAR(c.ApplicationDate, 'YYYYMMDD')::INT AS ApplicationDateKey,
    c.ApplicationDate,
    c.Source,
    c.CurrentStage,
    c.InterviewScore,
    c.OfferAccepted,
    c.DaysToFill,
    r.JobID,
    r.DepartmentID,
    r.JobTitle,
    r.JobLevel,
    r.Recruiter,
    r.RequisitionStatus,
    r.OpenDate,
    r.CloseDate,
    CASE
        WHEN r.OpenDate IS NOT NULL THEN TO_CHAR(r.OpenDate, 'YYYYMMDD')::INT
        ELSE NULL
    END AS OpenDateKey,
    CASE
        WHEN r.CloseDate IS NOT NULL THEN TO_CHAR(r.CloseDate, 'YYYYMMDD')::INT
        ELSE NULL
    END AS CloseDateKey
FROM people_analytics.stg_candidates c
LEFT JOIN people_analytics.stg_requisitions r
    ON c.RequisitionID = r.RequisitionID;