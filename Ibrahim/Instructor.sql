--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Instructor' (v4 - Final Template Applied)
-- FK Tables: [Department]
-- CHECK Constraints: Gender, Min Age, Marital Status, Salary, Contract Type
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Instructor_Insert]
    @Instructor_ID INT,
    @Instructor_Fname NVARCHAR(50),
    @Instructor_Lname NVARCHAR(50),
    @Instructor_Gender NVARCHAR(10) = NULL,
    @Instructor_Birthdate DATE = NULL,
    @Instructor_Marital_Status NVARCHAR(50) = NULL,
    @Instructor_Salary INT = NULL,
    @Instructor_Contract_Type NVARCHAR(50) = NULL,
    @Instructor_Email NVARCHAR(150) = NULL,
    @Department_ID INT = NULL
AS
BEGIN
    -- Creates a new instructor record.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check Primary Key (Uniqueness)
        IF EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
        BEGIN
            SELECT 'Error: Instructor_ID already exists.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Department) - Allow NULL
        IF @Department_ID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[Department] WHERE [Department_ID] = @Department_ID)
        BEGIN
            SELECT 'Error: Department_ID does not exist in the Department table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Check Unique Email - Allow NULL
        IF @Instructor_Email IS NOT NULL AND EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_Email] = @Instructor_Email)
        BEGIN
            SELECT 'Error: This email address is already in use.' AS ErrorMessage;
            RETURN;
        END

        -- 4. Perform Insert
        INSERT INTO [dbo].[Instructor]
           ([Instructor_ID], [Instructor_Fname], [Instructor_Lname], [Instructor_Gender], [Instructor_Birthdate], [Instructor_Marital_Status], [Instructor_Salary], [Instructor_Contract_Type], [Instructor_Email], [Department_ID])
        VALUES
           (@Instructor_ID, @Instructor_Fname, @Instructor_Lname, @Instructor_Gender, @Instructor_Birthdate, @Instructor_Marital_Status, @Instructor_Salary, @Instructor_Contract_Type, @Instructor_Email, @Department_ID);
    END TRY
    BEGIN CATCH
        -- Catch CHECK constraint violations (Error 547 can also be a CHECK constraint)
        IF ERROR_NUMBER() = 547 OR ERROR_MESSAGE() LIKE '%CHECK constraint%'
        BEGIN
            SELECT 'Error: Insert failed. Data violates a business rule (e.g., invalid salary, age, gender, or marital status).' AS ErrorMessage;
            RETURN;
        END

        SELECT 'An unexpected error occurred in Instructor_Insert.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Insert
--------------------------------------------------------------------------------
-- ASSUMPTIONS:
-- 1. You have a [Department] table with at least Department_ID = 10.
--------------------------------------------------------------------------------

PRINT '--- 1. TESTING Instructor_Insert ---';

-- Test 1 (Success): Add a valid instructor.
PRINT 'Test 1 (Success - Adding Instructor 201)...';
EXEC [dbo].[Instructor_Insert]
    @Instructor_ID = 201,
    @Instructor_Fname = 'Amr',
    @Instructor_Lname = 'Diab',
    @Instructor_Gender = 'Male',
    @Instructor_Birthdate = '1980-01-01',
    @Instructor_Marital_Status = 'Married',
    @Instructor_Salary = 9000,
    @Instructor_Contract_Type = 'Full-Time',
    @Instructor_Email = 'amr.diab@iti.gov.eg',
    @Department_ID = 1;

-- Test 2 (Error - Duplicate PK): Try to add 201 again.
PRINT 'Test 2 (Error - Duplicate PK)...';
EXEC [dbo].[Instructor_Insert]
    @Instructor_ID = 201, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test';
-- Expected: 'Error: Instructor_ID already exists.'

-- Test 3 (Error - Bad FK): Non-existent Department.
PRINT 'Test 3 (Error - Bad Department_ID FK)...';
EXEC [dbo].[Instructor_Insert]
    @Instructor_ID = 202, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Department_ID = 99;
-- Expected: 'Error: Department_ID does not exist in the Department table.'

-- Test 4 (Error - Duplicate Email):
PRINT 'Test 4 (Error - Duplicate Email)...';
EXEC [dbo].[Instructor_Insert]
    @Instructor_ID = 203, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Email = 'amr.diab@iti.gov.eg';
-- Expected: 'Error: This email address is already in use.'

-- Test 5 (Error - CHECK Constraint: Salary):
PRINT 'Test 5 (Error - Salary CHECK)...';
EXEC [dbo].[Instructor_Insert]
    @Instructor_ID = 204, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Salary = 7000;
-- Expected: 'Error: Insert failed. Data violates a business rule...'

-- Test 6 (Error - CHECK Constraint: Gender):
PRINT 'Test 6 (Error - Gender CHECK)...';
EXEC [dbo].[Instructor_Insert]
    @Instructor_ID = 205, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Gender = 'Other';
-- Expected: 'Error: Insert failed. Data violates a business rule...'

-- Test 7 (Error - CHECK Constraint: Age):
PRINT 'Test 7 (Error - Age CHECK)...';
EXEC [dbo].[Instructor_Insert]
    @Instructor_ID = 206, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Birthdate = '2010-01-01';
-- Expected: 'Error: Insert failed. Data violates a business rule...'
GO
--------------------------------------------------------------------------------


-- READ (Consolidated Select)
CREATE PROCEDURE [dbo].[Instructor_Select]
    @Instructor_ID INT = NULL,
    @Department_ID INT = NULL,
    @Instructor_Email NVARCHAR(150) = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Instructor_ID: Selects by Primary Key.
    -- 2. Instructor_Email: Selects by Email.
    -- 3. Department_ID: Selects all instructors in that department.
    -- 4. NULL: Selects all records.
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Instructor_ID IS NOT NULL
        BEGIN
            -- 1. Select by Primary Key
            SELECT * FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID;
        END
        ELSE IF @Instructor_Email IS NOT NULL
        BEGIN
            -- 2. Select by Email
            SELECT * FROM [dbo].[Instructor] WHERE [Instructor_Email] = @Instructor_Email;
        END
        ELSE IF @Department_ID IS NOT NULL
        BEGIN
            -- 3. Select by Department
            SELECT * FROM [dbo].[Instructor] WHERE [Department_ID] = @Department_ID;
        END
        ELSE
        BEGIN
            -- 4. Select All
            SELECT * FROM [dbo].[Instructor];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Instructor_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Instructor_Select ---';

-- Test 8 (PK): Find instructor 201.
PRINT 'Test 8 (Select - Finding 201)...';
EXEC [dbo].[Instructor_Select] @Instructor_ID = 201;
-- Expected: 1 row.

-- Test 9 (By Dept_ID): Find all for Dept 10.
PRINT 'Test 9 (Select - By Dept 10)...';
EXEC [dbo].[Instructor_Select] @Department_ID = 1;
-- Expected: 1 row.

-- Test 10 (By Email): Find by email.
PRINT 'Test 10 (Select - By Email)...';
EXEC [dbo].[Instructor_Select] @Instructor_Email = 'amr.diab@iti.gov.eg';
-- Expected: 1 row.

-- Test 11 (All): Select all instructors.
PRINT 'Test 11 (Select - All rows)...';
EXEC [dbo].[Instructor_Select];
-- Expected: 1 row.
GO
--------------------------------------------------------------------------------
*/

-- UPDATE (Standard)
CREATE PROCEDURE [dbo].[Instructor_Update]
    @Instructor_ID INT,
    @Instructor_Fname NVARCHAR(50),
    @Instructor_Lname NVARCHAR(50),
    @Instructor_Gender NVARCHAR(10) = NULL,
    @Instructor_Birthdate DATE = NULL,
    @Instructor_Marital_Status NVARCHAR(50) = NULL,
    @Instructor_Salary INT = NULL,
    @Instructor_Contract_Type NVARCHAR(50) = NULL,
    @Instructor_Email NVARCHAR(150) = NULL,
    @Department_ID INT = NULL
AS
BEGIN
    -- Updates an existing instructor's record.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if PK exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
        BEGIN
            SELECT 'Error: Instructor_ID not found. No update occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Department) - Allow NULL
        IF @Department_ID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[Department] WHERE [Department_ID] = @Department_ID)
        BEGIN
            SELECT 'Error: Department_ID does not exist in the Department table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Check Unique Email - Allow NULL and self
        IF @Instructor_Email IS NOT NULL AND EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_Email] = @Instructor_Email AND [Instructor_ID] != @Instructor_ID)
        BEGIN
            SELECT 'Error: This email address is already in use by another instructor.' AS ErrorMessage;
            RETURN;
        END
        
        -- 4. Perform Update
        UPDATE [dbo].[Instructor]
        SET 
            [Instructor_Fname] = @Instructor_Fname,
            [Instructor_Lname] = @Instructor_Lname,
            [Instructor_Gender] = @Instructor_Gender,
            [Instructor_Birthdate] = @Instructor_Birthdate,
            [Instructor_Marital_Status] = @Instructor_Marital_Status,
            [Instructor_Salary] = @Instructor_Salary,
            [Instructor_Contract_Type] = @Instructor_Contract_Type,
            [Instructor_Email] = @Instructor_Email,
            [Department_ID] = @Department_ID
        WHERE 
            [Instructor_ID] = @Instructor_ID;
    END TRY
    BEGIN CATCH
        -- Catch CHECK constraint violations (Error 547)
        IF ERROR_NUMBER() = 547 OR ERROR_MESSAGE() LIKE '%CHECK constraint%'
        BEGIN
            SELECT 'Error: Update failed. Data violates a business rule (e.g., invalid salary, age, gender, or marital status).' AS ErrorMessage;
            RETURN;
        END

        SELECT 'An unexpected error occurred in Instructor_Update.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Update
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Instructor_Update ---';

-- Test 12 (Success): Update the salary for Instructor 201.
PRINT 'Test 12 (Update - Success, changing salary)...';
EXEC [dbo].[Instructor_Update]
    @Instructor_ID = 201,
    @Instructor_Fname = 'Amr',
    @Instructor_Lname = 'Diab',
    @Instructor_Gender = 'Male',
    @Instructor_Birthdate = '1980-01-01',
    @Instructor_Marital_Status = 'Married',
    @Instructor_Salary = 9500, -- Changed from 9000
    @Instructor_Contract_Type = 'Full-Time',
    @Instructor_Email = 'amr.diab@iti.gov.eg',
    @Department_ID = 1;
-- Verify:
EXEC [dbo].[Instructor_Select] @Instructor_ID = 201;

-- Test 13 (Error - Not Found): Try to update non-existent 999.
PRINT 'Test 13 (Update - Error, 999 not found)...';
EXEC [dbo].[Instructor_Update]
    @Instructor_ID = 999, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test';
-- Expected: 'Error: Instructor_ID not found. No update occurred.'

-- Test 14 (Error - CHECK Constraint): Try to update salary to 7000.
PRINT 'Test 14 (Update - Error, Salary CHECK)...';
EXEC [dbo].[Instructor_Update]
    @Instructor_ID = 201, @Instructor_Fname = 'Amr', @Instructor_Lname = 'Diab', @Instructor_Salary = 7000;
-- Expected: 'Error: Update failed. Data violates a business rule...'
GO
--------------------------------------------------------------------------------


-- DELETE
CREATE PROCEDURE [dbo].[Instructor_Delete]
    @Instructor_ID INT
AS
BEGIN
    -- Deletes an instructor by their Primary Key.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if the record exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
        BEGIN
            SELECT 'Error: Instructor_ID not found. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Perform Delete
        DELETE FROM [dbo].[Instructor]
        WHERE [Instructor_ID] = @Instructor_ID;
    END TRY
    BEGIN CATCH
        -- Check for specific error 547 (Foreign Key violation)
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete instructor. They are still referenced by other records (e.g., Instructor_Course, Instructor_Phone).' AS ErrorMessage;
            RETURN;
        END
        
        -- Handle other errors
        SELECT 'An unexpected error occurred in Instructor_Delete.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Delete
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING Instructor_Delete ---';

-- Test 15 (Success): Delete Instructor 201.
PRINT 'Test 15 (Delete - Success, removing 201)...';
EXEC [dbo].[Instructor_Delete] @Instructor_ID = 201;

-- Test 16 (Error - Not Found): Try to delete 999.
PRINT 'Test 16 (Delete - Error, 999 not found)...';
EXEC [dbo].[Instructor_Delete] @Instructor_ID = 999;
-- Expected: 'Error: Instructor_ID not found. No deletion occurred.'

-- Test 17 (Error - Already Deleted): Try to delete 201 again.
PRINT 'Test 17 (Delete - Error, 201 already deleted)...';
EXEC [dbo].[Instructor_Delete] @Instructor_ID = 201;
-- Expected: 'Error: Instructor_ID not found. No deletion occurred.'

-- Test 18 (FK Error - How to test):
/*
-- To test the Foreign Key constraint error (Error 547), you would:
-- 1. Insert a record into [Instructor_Course] with Instructor_ID = 201.
-- 2. Run: EXEC [dbo].[Instructor_Delete] @Instructor_ID = 201;
-- 3. Expected: 'Error: Cannot delete instructor. They are still referenced by other records...'
*/

PRINT '--- 5. FINAL VERIFICATION ---';
EXEC [dbo].[Instructor_Select];
-- Expected: 0 rows (assuming Test 15 was successful and Test 18 was not run).
GO
--------------------------------------------------------------------------------