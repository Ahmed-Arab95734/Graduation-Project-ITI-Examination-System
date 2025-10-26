
--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Freelance_Job'
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Freelance_Job_Insert]
    @Job_ID INT,
    @Student_ID INT,
    @Job_Earn DECIMAL(12, 2),
    @Job_Date DATE,
    @Job_Site NVARCHAR(255) = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks (NOT NULL, PK, FK)
    IF @Job_ID IS NULL
    BEGIN
        SELECT 'Error: The Primary Key (Job_ID) cannot be NULL. Please provide a valid ID.' AS ErrorMessage;
        RETURN;
    END
    
    IF @Student_ID IS NULL OR @Job_Earn IS NULL OR @Job_Date IS NULL
    BEGIN
        SELECT 'Error: [Student_ID], [Job_Earn], and [Job_Date] cannot be NULL. Please provide all required values.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Freelance_Job] WHERE [Job_ID] = @Job_ID)
    BEGIN
        SELECT 'Error: A record with this Primary Key (Job_ID) already exists. Please use a different ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [Student_ID] = @Student_ID)
    BEGIN
        SELECT 'Error: The provided Student_ID does not exist in the [Student] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Insert with CATCH block for CHECK constraints
    BEGIN TRY
        INSERT INTO [dbo].[Freelance_Job] 
            ([Job_ID], [Student_ID], [Job_Earn], [Job_Date], [Job_Site], [Description])
        -- 3. Output inserted data
        OUTPUT 
            inserted.[Job_ID] AS [Inserted_Job_ID],
            inserted.[Student_ID] AS [Inserted_Student_ID],
            inserted.[Job_Earn] AS [Inserted_Job_Earn],
            inserted.[Job_Date] AS [Inserted_Job_Date],
            inserted.[Job_Site] AS [Inserted_Job_Site],
            inserted.[Description] AS [Inserted_Description]
        VALUES 
            (@Job_ID, @Student_ID, @Job_Earn, @Job_Date, @Job_Site, @Description);
    END TRY
    BEGIN CATCH
        -- 4. Smart CATCH Block
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        IF @ErrorNum = 547 IF @ErrorMsg LIKE '%FOREIGN KEY%' SELECT 'Error: A Foreign Key violation occurred. A value you provided (like an ID) does not exist in the parent table. Please check your IDs and try again.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details]; ELSE IF @ErrorMsg LIKE '%CHECK constraint%' SELECT 'Error: A CHECK constraint violation occurred. A value you provided is invalid (e.g., a salary below the minimum, or an invalid type string).' AS ErrorMessage, @ErrorMsg AS [Constraint_Details]; ELSE SELECT 'Error 547: ' + @ErrorMsg AS ErrorMessage;
        ELSE IF @ErrorNum = 515 SELECT 'Error: A NOT NULL violation occurred. You must provide a value for a required column.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum IN (2627, 2601) SELECT 'Error: A Unique Key or Primary Key violation occurred. The value you are trying to insert already exists.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum = 245 SELECT 'Error: A datatype conversion failed. Check that you are not putting text in a number field or an invalid date format.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE THROW;
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
    SET NOCOUNT ON;

    -- 1. Pre-Checks (PK exists, NOT NULL, FK)
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Freelance_Job] WHERE [Job_ID] = @Job_ID)
    BEGIN
        SELECT 'Error: Record ID not found. No update occurred. Please provide a valid Job_ID.' AS ErrorMessage;
        RETURN;
    END

    IF @Student_ID IS NULL OR @Job_Earn IS NULL OR @Job_Date IS NULL
    BEGIN
        SELECT 'Error: [Student_ID], [Job_Earn], and [Job_Date] cannot be NULL. Please provide all required values.' AS ErrorMessage;
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [Student_ID] = @Student_ID)
    BEGIN
        SELECT 'Error: The provided Student_ID does not exist in the [Student] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Update
    BEGIN TRY
        UPDATE [dbo].[Freelance_Job]
        SET 
            [Student_ID] = @Student_ID,
            [Job_Earn] = @Job_Earn,
            [Job_Date] = @Job_Date,
            [Job_Site] = @Job_Site,
            [Description] = @Description
        -- 3. Output Old and New records
        OUTPUT 
            deleted.[Job_ID] AS [Old_Job_ID],
            inserted.[Job_ID] AS [New_Job_ID],
            deleted.[Student_ID] AS [Old_Student_ID],
            inserted.[Student_ID] AS [New_Student_ID],
            deleted.[Job_Earn] AS [Old_Job_Earn],
            inserted.[Job_Earn] AS [New_Job_Earn],
            deleted.[Job_Date] AS [Old_Job_Date],
            inserted.[Job_Date] AS [New_Job_Date],
            deleted.[Job_Site] AS [Old_Job_Site],
            inserted.[Job_Site] AS [New_Job_Site],
            deleted.[Description] AS [Old_Description],
            inserted.[Description] AS [New_Description]
        WHERE 
            [Job_ID] = @Job_ID;
    END TRY
    BEGIN CATCH
        -- 4. Smart CATCH Block (Same as Insert)
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        IF @ErrorNum = 547 IF @ErrorMsg LIKE '%FOREIGN KEY%' SELECT 'Error: A Foreign Key violation occurred. A value you provided (like an ID) does not exist in the parent table. Please check your IDs and try again.' AS ErrorMessage; ELSE IF @ErrorMsg LIKE '%CHECK constraint%' SELECT 'Error: A CHECK constraint violation occurred. A value you provided is invalid (e.g., a salary below the minimum, or an invalid type string).' AS ErrorMessage, @ErrorMsg AS [Constraint_Details]; ELSE SELECT 'Error 547: ' + @ErrorMsg AS ErrorMessage;
        ELSE IF @ErrorNum = 515 SELECT 'Error: A NOT NULL violation occurred. You must provide a value for a required column.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum IN (2627, 2601) SELECT 'Error: A Unique Key or PrimaryKey violation occurred. The value you are trying to insert already exists.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum = 245 SELECT 'Error: A datatype conversion failed. Check that you are not putting text in a number field or an invalid date format.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE THROW;
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
create PROCEDURE [dbo].[Freelance_Job_Delete]
    @Job_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    
        IF @Job_ID IS NOT NULL
        BEGIN
            -- 1. Delete by Primary Key
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Freelance_Job] WHERE [Job_ID] = @Job_ID)
            BEGIN
                SELECT 'Error: Record ID not found. No deletion occurred. Please provide a valid Job_ID.' AS ErrorMessage;
                RETURN;
            END

            DELETE FROM [dbo].[Freelance_Job]
            -- 3. Output deleted data
            OUTPUT 
                deleted.[Job_ID] AS [Deleted_Job_ID],
                deleted.[Student_ID] AS [Deleted_Student_ID],
                deleted.[Job_Earn] AS [Deleted_Job_Earn],
                deleted.[Job_Date] AS [Deleted_Job_Date],
                deleted.[Job_Site] AS [Deleted_Job_Site],
                deleted.[Description] AS [Deleted_Description]
            WHERE 
                [Job_ID] = @Job_ID;
        END
        ELSE
        BEGIN
            -- 2. Delete All Records (ID is NULL)
            PRINT 'Warning: Deleting all records from [Freelance_Job]. This action cannot be undone.'
            BEGIN TRANSACTION;
            
            -- Check for FK constraints before truncating
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID('dbo.Freelance_Job'))
            BEGIN
                -- Cannot TRUNCATE, must DELETE.
                DELETE FROM [dbo].[Freelance_Job];
            END
            ELSE
            BEGIN
                -- Safe to TRUNCATE for performance
                TRUNCATE TABLE [dbo].[Freelance_Job];
            END
            
            COMMIT TRANSACTION;
            SELECT 'Success: All records have been deleted from [Freelance_Job].' AS SuccessMessage;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- 4. Smart CATCH Block
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this record. It is still referenced by other tables (Foreign Key violation). Please delete the child records first.' AS ErrorMessage;
            RETURN;
        END
        
        SELECT 'An unexpected error occurred in sp_DeleteFreelance_Job.' AS ErrorMessage;
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

EXEC [dbo].[Freelance_Job_Delete];
-- Expected: 0 rows.
GO