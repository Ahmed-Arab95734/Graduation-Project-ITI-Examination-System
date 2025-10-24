
--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Freelance_Job'
--------------------------------------------------------------------------------

-- CREATE
create PROCEDURE [dbo].[Freelance_Job_Insert]
    @Job_ID INT,
    @Student_ID INT,
    @Job_Earn DECIMAL(12, 2),
    @Job_Date DATE,
    @Job_Site NVARCHAR(255) = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    -- Creates a new freelance job record for a student.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check Primary Key (Uniqueness)
        IF EXISTS (SELECT [Job_ID] FROM [dbo].[Freelance_Job] WHERE [Job_ID] = @Job_ID)
        BEGIN
            SELECT 'Error: Job_ID already exists.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Student)
        IF NOT EXISTS (SELECT @Student_ID FROM [dbo].[Student] WHERE [Student_ID] = @Student_ID)
        BEGIN
            SELECT 'Error: Student_ID does not exist in the Student table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Perform Insert
        INSERT INTO [dbo].[Freelance_Job] 
            ([Job_ID], [Student_ID], [Job_Earn], [Job_Date], [Job_Site], [Description])
        VALUES 
            (@Job_ID, @Student_ID, @Job_Earn, @Job_Date, @Job_Site, @Description);
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Freelance_Job_Insert.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

-- TEST CASES FOR Freelance_Job_Insert
--------------------------------------------------------------------------------
-- ASSUMPTIONS:
-- 1. You have a [Student] table with at least Student_ID = 70100.
--------------------------------------------------------------------------------

PRINT '--- 1. TESTING Freelance_Job_Insert ---';

-- Test 1 (Success): Add a valid job.
PRINT 'Test 1 (Success - Adding Job 1 for Student 70100)...';
EXEC [dbo].[Freelance_Job_Insert] 
    @Job_ID = 100000, 
    @Student_ID = 1, 
    @Job_Earn = 500.00, 
    @Job_Date = '2025-10-24', 
    @Job_Site = 'Upwork';

-- Test 2 (Error - Duplicate PK): Try to add job 1 again.
PRINT 'Test 2 (Error - Duplicate PK)...';
EXEC [dbo].[Freelance_Job_Insert] 
    @Job_ID = 100000, 
    @Student_ID = 1, 
    @Job_Earn = 100.00, 
    @Job_Date = '2025-10-25', 
    @Job_Site = 'Fiverr';
-- Expected: 'Error: Job_ID already exists.'

-- Test 3 (Error - Bad FK): Try to add a job for a non-existent student (999).
PRINT 'Test 3 (Error - Bad Student_ID FK)...';
EXEC [dbo].[Freelance_Job_Insert] 
    @Job_ID = 52872, 
    @Student_ID = 60000, 
    @Job_Earn = 200.00, 
    @Job_Date = '2025-10-26', 
    @Job_Site = 'Freelancer';
-- Expected: 'Error: Student_ID does not exist in the Student table.'
GO

----------------------------------------------------------------------------------------------------------------------------

-- READ (Consolidated Select)
CREATE PROCEDURE [dbo].[Freelance_Job_Select]
    @Job_ID INT = NULL,
    @Student_ID INT = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Job_ID: Selects by Primary Key.
    -- 2. Student_ID: Selects all jobs for that student.
    -- 3. Neither: Selects all records.
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Job_ID IS NOT NULL
        BEGIN
            -- 1. Select by Primary Key
            SELECT * FROM [dbo].[Freelance_Job] WHERE [Job_ID] = @Job_ID;
        END
        ELSE IF @Student_ID IS NOT NULL
        BEGIN
            -- 2. Select by Student_ID
            SELECT * FROM [dbo].[Freelance_Job] WHERE [Student_ID] = @Student_ID;
        END
        ELSE
        BEGIN
            -- 3. Select All
            SELECT * FROM [dbo].[Freelance_Job];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Freelance_Job_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Freelance_Job_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Freelance_Job_Select ---';

-- Test 4 (PK): Find job 1.
PRINT 'Test 4 (Select - Finding Job 1)...';
EXEC [dbo].[Freelance_Job_Select] @Job_ID = 1;
-- Expected: 1 row.

-- Test 5 (By Student_ID): Find all jobs for student 70100.
PRINT 'Test 5 (Select - By Student_ID 70100)...';
EXEC [dbo].[Freelance_Job_Select] @Student_ID = 1;
-- Expected: 1 row (Job 1).

-- Test 6 (All): Select all jobs.
PRINT 'Test 6 (Select - All rows)...';
EXEC [dbo].[Freelance_Job_Select];
-- Expected: 1 row.
GO
--------------------------------------------------------------------------------

-- UPDATE
CREATE PROCEDURE [dbo].[Freelance_Job_Update]
    @Job_ID INT,
    @Student_ID INT,
    @Job_Earn DECIMAL(12, 2),
    @Job_Date DATE,
    @Job_Site NVARCHAR(255) = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    -- Updates an existing freelance job record.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if PK exists
        IF NOT EXISTS (SELECT [Job_ID] FROM [dbo].[Freelance_Job] WHERE [Job_ID] = @Job_ID)
        BEGIN
            SELECT 'Error: Job_ID not found. No update occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Student)
        IF NOT EXISTS (SELECT [Student_ID] FROM [dbo].[Student] WHERE [Student_ID] = @Student_ID)
        BEGIN
            SELECT 'Error: Student_ID does not exist in the Student table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Perform Update
        UPDATE [dbo].[Freelance_Job]
        SET 
            [Student_ID] = @Student_ID,
            [Job_Earn] = @Job_Earn,
            [Job_Date] = @Job_Date,
            [Job_Site] = @Job_Site,
            [Description] = @Description
        WHERE 
            [Job_ID] = @Job_ID;
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Freelance_Job_Update.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Freelance_Job_Update
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Freelance_Job_Update ---';

-- Test 7 (Success): Update the earnings for Job 1.
PRINT 'Test 7 (Update - Success)...';
EXEC [dbo].[Freelance_Job_Update]
    @Job_ID = 100000, 
    @Student_ID = 1, 
    @Job_Earn = 550.00,  -- Changed from 500.00
    @Job_Date = '2025-10-24', 
    @Job_Site = 'Upwork',
    @Description = 'Updated description';
-- Verify:
EXEC [dbo].[Freelance_Job_Select] @Job_ID = 100000;

-- Test 8 (Error - Not Found): Try to update a non-existent job.
PRINT 'Test 8 (Update - Error, Job 999 not found)...';
EXEC [dbo].[Freelance_Job_Update]
    @Job_ID = 1000001, 
    @Student_ID = 70100, 
    @Job_Earn = 100.00,
    @Job_Date = '2025-10-24';
-- Expected: 'Error: Job_ID not found. No update occurred.'

-- Test 9 (Error - Bad FK): Try to update Job 1 to a non-existent student.
PRINT 'Test 9 (Update - Error, Student 999 not found)...';
EXEC [dbo].[Freelance_Job_Update]
    @Job_ID = 1, 
    @Student_ID = 60000,  -- Non-existent student
    @Job_Earn = 550.00,
    @Job_Date = '2025-10-24';
-- Expected: 'Error: Student_ID does not exist in the Student table.'
GO

--------------------------------------------------------------------------------------------------------

-- DELETE
CREATE PROCEDURE [dbo].[Freelance_Job_Delete]
    @Job_ID INT
AS
BEGIN
    -- Deletes a freelance job record by its Primary Key.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if the record exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Freelance_Job] WHERE [Job_ID] = @Job_ID)
        BEGIN
            SELECT 'Error: Job_ID not found. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Perform Delete
        DELETE FROM [dbo].[Freelance_Job]
        WHERE [Job_ID] = @Job_ID;
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Freelance_Job_Delete.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Freelance_Job_Delete
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING Freelance_Job_Delete ---';

-- Test 10 (Success): Delete Job 1.
PRINT 'Test 10 (Delete - Success, removing Job 1)...';
EXEC [dbo].[Freelance_Job_Delete] @Job_ID = 1;

-- Test 11 (Error - Not Found): Try to delete Job 999.
PRINT 'Test 11 (Delete - Error, Job 999 not found)...';
EXEC [dbo].[Freelance_Job_Delete] @Job_ID = 100001;
-- Expected: 'Error: Job_ID not found. No deletion occurred.'

-- Test 12 (Error - Already Deleted): Try to delete Job 1 again.
PRINT 'Test 12 (Delete - Error, Job 1 already deleted)...';
EXEC [dbo].[Freelance_Job_Delete] @Job_ID = 1;
-- Expected: 'Error: Job_ID not found. No deletion occurred.'

PRINT '--- 5. FINAL VERIFICATION ---';
EXEC [dbo].[Freelance_Job_Select];
-- Expected: 0 rows.
GO