-- =============================================
-- SQL Stored Procedures for CRUD Operations
-- =============================================
SET NOCOUNT ON;
GO

-- =============================================
-- Table: dbo.Branch
-- =============================================

-- 1.1: Select All Branches
CREATE PROCEDURE sp_GetAllBranches
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Branch_ID, Branch_Location, Branch_Name, Branch_Start_Date
        FROM dbo.Branch;
    END TRY
    BEGIN CATCH
        -- Handle error
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 1.2: Select Branch by ID
CREATE PROCEDURE sp_GetBranchByID
    @Branch_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Branch_ID, Branch_Location, Branch_Name, Branch_Start_Date
        FROM dbo.Branch
        WHERE Branch_ID = @Branch_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 1.3: Insert Branch
CREATE PROCEDURE sp_InsertBranch
    @Branch_Location NVARCHAR(200),
    @Branch_Name NVARCHAR(200),
    @Branch_Start_Date DATE,
    @Branch_ID INT OUTPUT -- Assuming Branch_ID is NOT auto-incrementing based on schema
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- If Branch_ID is an IDENTITY column, remove it from INPUT params and from INSERT list.
        -- Assuming it's manually provided as per schema (no IDENTITY keyword).
        INSERT INTO dbo.Branch (Branch_ID, Branch_Location, Branch_Name, Branch_Start_Date)
        VALUES (@Branch_ID, @Branch_Location, @Branch_Name, @Branch_Start_Date);
        
        -- If Branch_ID is an IDENTITY, use this instead:
        -- SET @Branch_ID = SCOPE_IDENTITY(); 
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 1.4: Update Branch
CREATE PROCEDURE sp_UpdateBranch
    @Branch_ID INT,
    @Branch_Location NVARCHAR(200),
    @Branch_Name NVARCHAR(200),
    @Branch_Start_Date DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Branch
        SET 
            Branch_Location = @Branch_Location,
            Branch_Name = @Branch_Name,
            Branch_Start_Date = @Branch_Start_Date
        WHERE Branch_ID = @Branch_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 1.5: Delete Branch
CREATE PROCEDURE sp_DeleteBranch
    @Branch_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.Branch
        WHERE Branch_ID = @Branch_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- Table: dbo.Certificate
-- =============================================

-- 2.1: Select All Certificates
CREATE PROCEDURE sp_GetAllCertificates
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date
        FROM dbo.Certificate;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 2.2: Select Certificate by ID
CREATE PROCEDURE sp_GetCertificateByID
    @Certificate_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date
        FROM dbo.Certificate
        WHERE Certificate_ID = @Certificate_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 2.3: Insert Certificate
CREATE PROCEDURE sp_InsertCertificate
    @Certificate_ID INT OUTPUT, -- Assuming manual PK
    @Student_ID INT,
    @Certificate_Name NVARCHAR(200),
    @Certificate_Provider NVARCHAR(200),
    @Certificate_Cost DECIMAL(12,2),
    @Certificate_Date DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
        VALUES (@Certificate_ID, @Student_ID, @Certificate_Name, @Certificate_Provider, @Certificate_Cost, @Certificate_Date);
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 2.4: Update Certificate
CREATE PROCEDURE sp_UpdateCertificate
    @Certificate_ID INT,
    @Student_ID INT,
    @Certificate_Name NVARCHAR(200),
    @Certificate_Provider NVARCHAR(200),
    @Certificate_Cost DECIMAL(12,2),
    @Certificate_Date DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Certificate
        SET 
            Student_ID = @Student_ID,
            Certificate_Name = @Certificate_Name,
            Certificate_Provider = @Certificate_Provider,
            Certificate_Cost = @Certificate_Cost,
            Certificate_Date = @Certificate_Date
        WHERE Certificate_ID = @Certificate_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 2.5: Delete Certificate
CREATE PROCEDURE sp_DeleteCertificate
    @Certificate_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.Certificate
        WHERE Certificate_ID = @Certificate_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- Table: dbo.Company
-- =============================================

-- 3.1: Select All Companies
CREATE PROCEDURE sp_GetAllCompanies
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Company_ID, Company_Name, Company_Location, Company_Type
        FROM dbo.Company;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 3.2: Select Company by ID
CREATE PROCEDURE sp_GetCompanyByID
    @Company_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Company_ID, Company_Name, Company_Location, Company_Type
        FROM dbo.Company
        WHERE Company_ID = @Company_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 3.3: Insert Company
CREATE PROCEDURE sp_InsertCompany
    @Company_ID INT OUTPUT, -- Assuming manual PK
    @Company_Name NVARCHAR(200),
    @Company_Location NVARCHAR(200),
    @Company_Type NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Company (Company_ID, Company_Name, Company_Location, Company_Type)
        VALUES (@Company_ID, @Company_Name, @Company_Location, @Company_Type);
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 3.4: Update Company
CREATE PROCEDURE sp_UpdateCompany
    @Company_ID INT,
    @Company_Name NVARCHAR(200),
    @Company_Location NVARCHAR(200),
    @Company_Type NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Company
        SET 
            Company_Name = @Company_Name,
            Company_Location = @Company_Location,
            Company_Type = @Company_Type
        WHERE Company_ID = @Company_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 3.5: Delete Company
CREATE PROCEDURE sp_DeleteCompany
    @Company_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.Company
        WHERE Company_ID = @Company_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- Table: dbo.Course
-- =============================================

-- 4.1: Select All Courses
CREATE PROCEDURE sp_GetAllCourses
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Course_ID, Course_Name
        FROM dbo.Course;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 4.2: Select Course by ID
CREATE PROCEDURE sp_GetCourseByID
    @Course_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Course_ID, Course_Name
        FROM dbo.Course
        WHERE Course_ID = @Course_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 4.3: Insert Course
CREATE PROCEDURE sp_InsertCourse
    @Course_ID INT OUTPUT, -- Assuming manual PK
    @Course_Name NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Course (Course_ID, Course_Name)
        VALUES (@Course_ID, @Course_Name);
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 4.4: Update Course
CREATE PROCEDURE sp_UpdateCourse
    @Course_ID INT,
    @Course_Name NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Course
        SET 
            Course_Name = @Course_Name
        WHERE Course_ID = @Course_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 4.5: Delete Course
CREATE PROCEDURE sp_DeleteCourse
    @Course_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.Course
        WHERE Course_ID = @Course_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- Table: dbo.Department
-- =============================================

-- 5.1: Select All Departments
CREATE PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Department_ID, Department_Name, Manager_ID
        FROM dbo.Department;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 5.2: Select Department by ID
CREATE PROCEDURE sp_GetDepartmentByID
    @Department_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Department_ID, Department_Name, Manager_ID
        FROM dbo.Department
        WHERE Department_ID = @Department_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 5.3: Insert Department
CREATE PROCEDURE sp_InsertDepartment
    @Department_ID INT OUTPUT, -- Assuming manual PK
    @Department_Name NVARCHAR(200),
    @Manager_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Department (Department_ID, Department_Name, Manager_ID)
        VALUES (@Department_ID, @Department_Name, @Manager_ID);
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 5.4: Update Department
CREATE PROCEDURE sp_UpdateDepartment
    @Department_ID INT,
    @Department_Name NVARCHAR(200),
    @Manager_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Department
        SET 
            Department_Name = @Department_Name,
            Manager_ID = @Manager_ID
        WHERE Department_ID = @Department_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 5.5: Delete Department
CREATE PROCEDURE sp_DeleteDepartment
    @Department_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.Department
        WHERE Department_ID = @Department_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- Table: dbo.Exam
-- =============================================

-- 6.1: Select All Exams
CREATE PROCEDURE sp_GetAllExams
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Exam_ID, Course_ID, Instructor_ID, Exam_Date, Exam_Duration_Minutes, Exam_Type
        FROM dbo.Exam;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 6.2: Select Exam by ID
CREATE PROCEDURE sp_GetExamByID
    @Exam_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Exam_ID, Course_ID, Instructor_ID, Exam_Date, Exam_Duration_Minutes, Exam_Type
        FROM dbo.Exam
        WHERE Exam_ID = @Exam_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 6.3: Insert Exam
CREATE PROCEDURE sp_InsertExam
    @Exam_ID INT OUTPUT, -- Assuming manual PK
    @Course_ID INT,
    @Instructor_ID INT,
    @Exam_Date DATE,
    @Exam_Duration_Minutes INT,
    @Exam_Type NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Exam (Exam_ID, Course_ID, Instructor_ID, Exam_Date, Exam_Duration_Minutes, Exam_Type)
        VALUES (@Exam_ID, @Course_ID, @Instructor_ID, @Exam_Date, @Exam_Duration_Minutes, @Exam_Type);
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 6.4: Update Exam
CREATE PROCEDURE sp_UpdateExam
    @Exam_ID INT,
    @Course_ID INT,
    @Instructor_ID INT,
    @Exam_Date DATE,
    @Exam_Duration_Minutes INT,
    @Exam_Type NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Exam
        SET 
            Course_ID = @Course_ID,
            Instructor_ID = @Instructor_ID,
            Exam_Date = @Exam_Date,
            Exam_Duration_Minutes = @Exam_Duration_Minutes,
            Exam_Type = @Exam_Type
        WHERE Exam_ID = @Exam_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- 6.5: Delete Exam
CREATE PROCEDURE sp_DeleteExam
    @Exam_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.Exam
        WHERE Exam_ID = @Exam_ID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
