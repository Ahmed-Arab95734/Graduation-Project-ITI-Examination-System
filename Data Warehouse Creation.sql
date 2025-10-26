/*
================================================================================
SCRIPT: Create ITI_DW_v2 Database and Tables (Comprehensive)
DESCRIPTION: Creates the full OLAP star schema, capturing all OLTP data.
================================================================================
*/

-- Drop the database if it already exists
IF DB_ID('ITI_DW') IS NOT NULL
BEGIN
    ALTER DATABASE ITI_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ITI_DW;
END
GO

CREATE DATABASE ITI_DW;
GO

USE ITI_DW;
GO

/*
================================================================================
SECTION 1: DIMENSION TABLES
================================================================================
*/

-- 1.1. DimDate (Populated by stored procedure)
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,              -- e.g., 20251026
    FullDate DATE NOT NULL,
    DayNameOfWeek NVARCHAR(10) NOT NULL,
    MonthName NVARCHAR(10) NOT NULL,
    MonthNumberOfYear TINYINT NOT NULL,
    CalendarQuarter TINYINT NOT NULL,
    CalendarYear SMALLINT NOT NULL
);
GO

-- 1.2. DimStudent (MODIFIED: Added social links and graduation date)
CREATE TABLE DimStudent (
    StudentKey INT IDENTITY(1,1) PRIMARY KEY,
    Student_ID INT NOT NULL,                  
    Student_FullName NVARCHAR(101) NOT NULL,
    Student_Gender NVARCHAR(10),
    Student_Marital_Status NVARCHAR(50),
    Student_Faculty NVARCHAR(100),
    Student_Faculty_Grade NVARCHAR(50),
    Student_ITI_Status NVARCHAR(50),
    Track_Name NVARCHAR(200),
    Branch_Name NVARCHAR(200),
    Intake_Name NVARCHAR(200),
    Expected_Graduation_Date DATE, -- From Intake.Intake_End_Date
    Social_Facebook NVARCHAR(400),   -- Pivoted
    Social_LinkedIn NVARCHAR(400), -- Pivoted
    Social_GitHub NVARCHAR(400),   -- Pivoted
    Social_X NVARCHAR(400),        -- Pivoted
    Social_Instagram NVARCHAR(400) -- Pivoted
);
GO

-- 1.3. DimInstructor
CREATE TABLE DimInstructor (
    InstructorKey INT IDENTITY(1,1) PRIMARY KEY,
    Instructor_ID INT NOT NULL,
    Instructor_FullName NVARCHAR(101) NOT NULL,
    Instructor_Gender NVARCHAR(10),
    Instructor_Contract_Type NVARCHAR(50),
    Department_Name NVARCHAR(200)
);
GO

-- 1.4. DimCourse
CREATE TABLE DimCourse (
    CourseKey INT IDENTITY(1,1) PRIMARY KEY,
    Course_ID INT NOT NULL,
    Course_Name NVARCHAR(200) NOT NULL
);
GO

-- 1.5. DimTopic (NEW - Snowflaked to DimCourse)
CREATE TABLE DimTopic (
    TopicKey INT IDENTITY(1,1) PRIMARY KEY,
    Topic_ID INT NOT NULL,
    Topic_Name NVARCHAR(200) NOT NULL,
    CourseKey INT NOT NULL, -- Foreign Key to DimCourse
    CONSTRAINT FK_Topic_Course FOREIGN KEY (CourseKey) REFERENCES DimCourse(CourseKey)
);
GO

-- 1.6. DimExam
CREATE TABLE DimExam (
    ExamKey INT IDENTITY(1,1) PRIMARY KEY,
    Exam_ID INT NOT NULL,
    Exam_Type NVARCHAR(50),
    Exam_Duration_Minutes INT
);
GO

-- 1.7. DimQuestion
CREATE TABLE DimQuestion (
    QuestionKey INT IDENTITY(1,1) PRIMARY KEY,
    Question_ID INT NOT NULL,
    Question_Type NVARCHAR(50),
    Question_Description NVARCHAR(1000)
);
GO

-- 1.8. DimCompany
CREATE TABLE DimCompany (
    CompanyKey INT IDENTITY(1,1) PRIMARY KEY,
    Company_ID INT NOT NULL,
    Company_Name NVARCHAR(200) NOT NULL,
    Company_Location NVARCHAR(200),
    Company_Type NVARCHAR(100)
);
GO

-- 1.9. DimFailureReason (NEW)
CREATE TABLE DimFailureReason (
    FailureReasonKey INT IDENTITY(1,1) PRIMARY KEY,
    Failure_Reason_Text NVARCHAR(255) NOT NULL
);
GO

-- 1.10. DimJobSite (NEW)
CREATE TABLE DimJobSite (
    JobSiteKey INT IDENTITY(1,1) PRIMARY KEY,
    Job_Site_Name NVARCHAR(255) NOT NULL
);
GO

-- 1.11. DimCertificate (NEW)
CREATE TABLE DimCertificate (
    CertificateKey INT IDENTITY(1,1) PRIMARY KEY,
    Certificate_Name NVARCHAR(200) NOT NULL
);
GO

-- 1.12. DimCertificateProvider (NEW)
CREATE TABLE DimCertificateProvider (
    ProviderKey INT IDENTITY(1,1) PRIMARY KEY,
    Provider_Name NVARCHAR(200) NOT NULL
);
GO

/*
================================================================================
SECTION 2: FACT TABLES
================================================================================
*/

-- 2.1. FactStudentPerformance (Unchanged)
CREATE TABLE FactStudentPerformance (
    StudentKey INT NOT NULL,
    CourseKey INT NOT NULL,
    InstructorKey INT NOT NULL,
    ExamKey INT NOT NULL,
    QuestionKey INT NOT NULL,
    ExamDateKey INT NOT NULL,
    Student_Grade DECIMAL(6,2),
    CONSTRAINT PK_FactStudentPerformance PRIMARY KEY (StudentKey, ExamKey, QuestionKey),
    CONSTRAINT FK_Perf_Student FOREIGN KEY (StudentKey) REFERENCES DimStudent(StudentKey),
    CONSTRAINT FK_Perf_Course FOREIGN KEY (CourseKey) REFERENCES DimCourse(CourseKey),
    CONSTRAINT FK_Perf_Instructor FOREIGN KEY (InstructorKey) REFERENCES DimInstructor(InstructorKey),
    CONSTRAINT FK_Perf_Exam FOREIGN KEY (ExamKey) REFERENCES DimExam(ExamKey),
    CONSTRAINT FK_Perf_Question FOREIGN KEY (QuestionKey) REFERENCES DimQuestion(QuestionKey),
    CONSTRAINT FK_Perf_ExamDate FOREIGN KEY (ExamDateKey) REFERENCES DimDate(DateKey)
);
GO

-- 2.2. FactStudentOutcomes (Unchanged, but logic to load DaysToHire is now easier)
CREATE TABLE FactStudentOutcomes (
    StudentKey INT NOT NULL,
    CompanyKey INT NOT NULL,
    HireDateKey INT NOT NULL,
    Salary DECIMAL(12,2),
    DaysToHire INT, -- Calculated in SSIS: DATEDIFF(day, DimStudent.Expected_Graduation_Date, Hire_Date)
    CONSTRAINT PK_FactStudentOutcomes PRIMARY KEY (StudentKey, CompanyKey, HireDateKey),
    CONSTRAINT FK_Outcomes_Student FOREIGN KEY (StudentKey) REFERENCES DimStudent(StudentKey),
    CONSTRAINT FK_Outcomes_Company FOREIGN KEY (CompanyKey) REFERENCES DimCompany(CompanyKey),
    CONSTRAINT FK_Outcomes_HireDate FOREIGN KEY (HireDateKey) REFERENCES DimDate(DateKey)
);
GO

-- 2.3. FactStudentRating (NEW)
CREATE TABLE FactStudentRating (
    StudentKey INT NOT NULL,
    InstructorKey INT NOT NULL,
    RatingValue TINYINT NOT NULL,
    CONSTRAINT PK_FactStudentRating PRIMARY KEY (StudentKey, InstructorKey),
    CONSTRAINT FK_Rating_Student FOREIGN KEY (StudentKey) REFERENCES DimStudent(StudentKey),
    CONSTRAINT FK_Rating_Instructor FOREIGN KEY (InstructorKey) REFERENCES DimInstructor(InstructorKey)
);
GO

-- 2.4. FactFreelanceJob (NEW)
CREATE TABLE FactFreelanceJob (
    FreelanceJobKey INT IDENTITY(1,1) PRIMARY KEY, -- Use an identity key since Student+Date isn't unique
    StudentKey INT NOT NULL,
    JobDateKey INT NOT NULL,
    JobSiteKey INT NOT NULL,
    Job_Earn DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Freelance_Student FOREIGN KEY (StudentKey) REFERENCES DimStudent(StudentKey),
    CONSTRAINT FK_Freelance_JobDate FOREIGN KEY (JobDateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_Freelance_JobSite FOREIGN KEY (JobSiteKey) REFERENCES DimJobSite(JobSiteKey)
);
GO

-- 2.5. FactCertificate (NEW)
CREATE TABLE FactCertificate (
    CertificateLogKey INT IDENTITY(1,1) PRIMARY KEY, -- Use an identity key
    StudentKey INT NOT NULL,
    CertificateDateKey INT NOT NULL,
    CertificateKey INT NOT NULL,
    ProviderKey INT NOT NULL,
    Certificate_Cost DECIMAL(12,2),
    CONSTRAINT FK_Cert_Student FOREIGN KEY (StudentKey) REFERENCES DimStudent(StudentKey),
    CONSTRAINT FK_Cert_CertDate FOREIGN KEY (CertificateDateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_Cert_Certificate FOREIGN KEY (CertificateKey) REFERENCES DimCertificate(CertificateKey),
    CONSTRAINT FK_Cert_Provider FOREIGN KEY (ProviderKey) REFERENCES DimCertificateProvider(ProviderKey)
);
GO

-- 2.6. FactStudentFailure (NEW - Factless)
CREATE TABLE FactStudentFailure (
    StudentKey INT NOT NULL,
    FailureReasonKey INT NOT NULL,
    CONSTRAINT PK_FactStudentFailure PRIMARY KEY (StudentKey, FailureReasonKey),
    CONSTRAINT FK_Failure_Student FOREIGN KEY (StudentKey) REFERENCES DimStudent(StudentKey),
    CONSTRAINT FK_Failure_Reason FOREIGN KEY (FailureReasonKey) REFERENCES DimFailureReason(FailureReasonKey)
);
GO

/*
================================================================================
SECTION 3: POPULATE DimDate TABLE
================================================================================
*/
CREATE PROCEDURE sp_PopulateDimDate
    @StartDate DATE = '2022-01-01',
    @EndDate DATE = '2026-12-31'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentDate DATE = @StartDate;
    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO DimDate (
            DateKey,
            FullDate,
            DayNameOfWeek,
            MonthName,
            MonthNumberOfYear,
            CalendarQuarter,
            CalendarYear
        )
        VALUES (
            CONVERT(INT, CONVERT(VARCHAR(8), @CurrentDate, 112)), -- YYYYMMDD
            @CurrentDate,
            DATENAME(WEEKDAY, @CurrentDate),
            DATENAME(MONTH, @CurrentDate),
            DATEPART(MONTH, @CurrentDate),
            DATEPART(QUARTER, @CurrentDate),
            DATEPART(YEAR, @CurrentDate)
        );
        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END
GO

EXEC sp_PopulateDimDate @StartDate = '2022-01-01', @EndDate = '2026-12-31';
GO

PRINT 'ITI_DW Database, Tables, and DimDate population complete.';
GO
