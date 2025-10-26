
--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Failed_Students' (v3 - Template Applied)
-- FK Tables: [Student]
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Failed_Students_Insert]
    @Student_ID INT,
    @Failure_Reason NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks (NOT NULL, PK, FK)
    IF @Student_ID IS NULL OR @Failure_Reason IS NULL
    BEGIN
        SELECT 'Error: The composite Primary Key columns (Student_ID, Failure_Reason) cannot be NULL. Please provide valid inputs.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason)
    BEGIN
        SELECT 'Error: This combination of Student_ID and Failure_Reason already exists. This link cannot be duplicated.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [Student_ID] = @Student_ID)
    BEGIN
        SELECT 'Error: The provided Student_ID does not exist in the [Student] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Insert
    BEGIN TRY
        INSERT INTO [dbo].[Failed_Students] ([Student_ID], [Failure_Reason])
        -- 3. Output inserted data
        OUTPUT 
            inserted.[Student_ID] AS [Inserted_Student_ID],
            inserted.[Failure_Reason] AS [Inserted_Failure_Reason]
        VALUES 
            (@Student_ID, @Failure_Reason);
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

--------------------------------------------------------------------------------
-- TEST CASES FOR Failed_Students_Insert
--------------------------------------------------------------------------------
-- ASSUMPTIONS:
-- 1. You have a [Student] table with at least Student_ID = 1.
--------------------------------------------------------------------------------

PRINT '--- 1. TESTING Failed_Students_Insert ---';

-- Test 1 (Success): Add a failure reason to student 1.
PRINT 'Test 1 (Success - Adding 1, "Attendance")...';
EXEC [dbo].[Failed_Students_Insert] @Student_ID = 1, @Failure_Reason = 'Attendance';

-- Test 2 (Success): Add a second reason to student 1.
PRINT 'Test 2 (Success - Adding 1, "Grades")...';
EXEC [dbo].[Failed_Students_Insert] @Student_ID = 1, @Failure_Reason = 'Grades';

-- Test 3 (Error - Duplicate PK): Try to add 'Attendance' to 1 again.
PRINT 'Test 3 (Error - Duplicate PK)...';
EXEC [dbo].[Failed_Students_Insert] @Student_ID = 1, @Failure_Reason = 'Attendance';
-- Expected: 'Error: This failure reason is already registered for this student.'

-- Test 4 (Error - Bad FK): Try to add a reason to a non-existent student (999).
PRINT 'Test 4 (Error - Bad Student_ID FK)...';
EXEC [dbo].[Failed_Students_Insert] @Student_ID = 60000, @Failure_Reason = 'Cheating';
-- Expected: 'Error: Student_ID does not exist in the Student table.'
GO

--------------------------------------------------------------------------------

-- READ (Consolidated Select)
CREATE PROCEDURE [dbo].[Failed_Students_Select]
    @Student_ID INT = NULL,
    @Failure_Reason NVARCHAR(255) = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Student_ID AND Failure_Reason: Selects by specific Primary Key.
    -- 2. Student_ID only: Selects all reasons for one student.
    -- 3. Failure_Reason only: Selects all students for one reason.
    -- 4. NULL: Selects all records.
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Student_ID IS NOT NULL AND @Failure_Reason IS NOT NULL
        BEGIN
            -- 1. Select by Full Primary Key
            SELECT * FROM [dbo].[Failed_Students] 
            WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason;
        END
        ELSE IF @Student_ID IS NOT NULL AND @Failure_Reason IS NULL
        BEGIN
            -- 2. Select by Student_ID
            SELECT * FROM [dbo].[Failed_Students] 
            WHERE [Student_ID] = @Student_ID;
        END
        ELSE IF @Student_ID IS NULL AND @Failure_Reason IS NOT NULL
        BEGIN
            -- 3. Select by Failure_Reason
            SELECT * FROM [dbo].[Failed_Students] 
            WHERE [Failure_Reason] = @Failure_Reason;
        END
        ELSE
        BEGIN
            -- 4. Select All
            SELECT * FROM [dbo].[Failed_Students];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Failed_Students_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Failed_Students_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Failed_Students_Select (Consolidated) ---';

-- Test 5 (PK): Find link (1, 'Attendance').
PRINT 'Test 5 (Select - Finding 1, "Attendance")...';
EXEC [dbo].[Failed_Students_Select] @Student_ID = 1, @Failure_Reason = 'Attendance';
-- Expected: 1 row.

-- Test 6 (All): Call with no parameters.
PRINT 'Test 6 (Select - All rows)...';
EXEC [dbo].[Failed_Students_Select];
-- Expected: 2 rows.

-- Test 7 (By Student_ID): Find all reasons for student 1.
PRINT 'Test 7 (Select - By Student_ID 1)...';
EXEC [dbo].[Failed_Students_Select] @Student_ID = 1;
-- Expected: 2 rows ('Attendance', 'Grades').

-- Test 8 (By Reason): Find all students who failed due to 'Grades'.
PRINT 'Test 8 (Select - By Reason "Grades")...';
EXEC [dbo].[Failed_Students_Select] @Failure_Reason = 'Grades';
-- Expected: 1 row (Student 1).
GO

--------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Failed_Students_Update]
    @Student_ID INT,
    @Old_Failure_Reason NVARCHAR(255),
    @New_Failure_Reason NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks
    IF @Student_ID IS NULL OR @Old_Failure_Reason IS NULL OR @New_Failure_Reason IS NULL
    BEGIN
        SELECT 'Error: All parameters (@Student_ID, @Old_Failure_Reason, @New_Failure_Reason) are required and cannot be NULL.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Old_Failure_Reason)
    BEGIN
        SELECT 'Error: The old record (Student_ID, Old_Failure_Reason) does not exist. No update occurred.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @New_Failure_Reason)
    BEGIN
        SELECT 'Error: The new record (Student_ID, New_Failure_Reason) already exists. Cannot create a duplicate.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Transaction
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Step 1: Delete the old record and output it
        DELETE FROM [dbo].[Failed_Students]
        OUTPUT 
            deleted.[Student_ID] AS [Old_Student_ID],
            deleted.[Failure_Reason] AS [Old_Failure_Reason]
        WHERE 
            [Student_ID] = @Student_ID AND [Failure_Reason] = @Old_Failure_Reason;
        
        -- Step 2: Insert the new record and output it
        INSERT INTO [dbo].[Failed_Students] ([Student_ID], [Failure_Reason])
        OUTPUT 
            inserted.[Student_ID] AS [New_Student_ID],
            inserted.[Failure_Reason] AS [New_Failure_Reason]
        VALUES 
            (@Student_ID, @New_Failure_Reason);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
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

--------------------------------------------------------------------------------
-- TEST CASES FOR Failed_Students_Update
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Failed_Students_Update ---';

-- Test 9 (Success): Change "Grades" to "Cheating" for student 1.
PRINT 'Test 9 (Update - Success, changing "Grades" to "Cheating")...';
EXEC [dbo].[Failed_Students_Update] 
    @Student_ID = 1, 
    @Old_Failure_Reason = 'Grades', 
    @New_Failure_Reason = 'Cheating';
-- Verify:
EXEC [dbo].[Failed_Students_Select] @Student_ID = 1;
-- Expected: Rows (1, 'Attendance') and (1, 'Cheating').

-- Test 10 (Error - Old Not Found): Try to change a non-existent old reason.
PRINT 'Test 10 (Update - Error, "Grades" not found)...';
EXEC [dbo].[Failed_Students_Update] 
    @Student_ID = 1, 
    @Old_Failure_Reason = 'Grades', -- Was already changed to 'Cheating'
    @New_Failure_Reason = 'Laziness';
-- Expected: 'Error: The original record (Student_ID, Old_Failure_Reason) does not exist.'

-- Test 11 (Error - New Already Exists): Try to change "Cheating" to "Attendance".
PRINT 'Test 11 (Update - Error, "Attendance" already exists)...';
EXEC [dbo].[Failed_Students_Update] 
    @Student_ID = 1, 
    @Old_Failure_Reason = 'Cheating', 
    @New_Failure_Reason = 'Attendance'; -- 'Attendance' already exists
-- Expected: 'Error: The new failure reason is already registered for this student.'

-- Test 12 (Warning - No-op): Try to change "Attendance" to "Attendance".
PRINT 'Test 12 (Update - Warning, no change)...';
EXEC [dbo].[Failed_Students_Update] 
    @Student_ID = 1, 
    @Old_Failure_Reason = 'Attendance', 
    @New_Failure_Reason = 'Attendance';
-- Expected: 'Warning: Old and new failure reasons are the same. No update occurred.'
GO
--------------------------------------------------------------------------------

-- DELETE
CREATE PROCEDURE [dbo].[Failed_Students_Delete]
    @Student_ID INT = null,
    @Failure_Reason NVARCHAR(255)= null 
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Student_ID IS NULL OR @Failure_Reason IS NULL
        BEGIN
            SELECT 'Error: Safe delete requires the full composite key. BOTH @Student_ID and @Failure_Reason must be provided. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END
        -- 1. CRITICAL: Check for NULLs to prevent accidental mass-delete.
        IF @Student_ID IS NULL OR @Failure_Reason IS NULL
        BEGIN
            SELECT 'Error: Safe delete requires the full composite key. BOTH Student_ID and Failure_Reason must be provided. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check if the specific record exists before deleting.
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason)
        BEGIN
            SELECT 'Error: Record not found. No deletion occurred. Please provide a valid Student_ID and Failure_Reason.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Perform the specific delete.
        DELETE FROM [dbo].[Failed_Students]
        OUTPUT 
            deleted.[Student_ID] AS [Deleted_Student_ID],
            deleted.[Failure_Reason] AS [Deleted_Failure_Reason]
        WHERE 
            [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason;
        
    END TRY
    BEGIN CATCH
        -- 4. Smart CATCH Block (FK violation on DELETE is very unlikely on this table)
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this record. It is still referenced by other tables (Foreign Key violation). Please delete the child records first.' AS ErrorMessage;
            RETURN;
        END
        
        SELECT 'An unexpected error occurred in sp_DeleteFailed_Students.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Failed_Students_Delete
--------------------------------------------------------------------------------
PRINT '--- 1. TESTING sp_InsertFailed_Students ---';
-- ASSUMPTION: Student_ID 1 exists.
-- Test 1 (Success):
EXEC [dbo].[Failed_Students_Delete] @Student_ID = 1, @Failure_Reason = 'Low Attendance';
-- Test 2 (Error - PK NULL):
EXEC [dbo].[Failed_Students_Delete] @Student_ID = 1, @Failure_Reason = NULL;
-- Test 3 (Error - PK Exists):
EXEC [dbo].[Failed_Students_Delete] @Student_ID = 1, @Failure_Reason = 'Low Attendance';
-- Test 4 (Error - Bad FK):
EXEC [dbo].[Failed_Students_Delete] @Student_ID = 99, @Failure_Reason = 'Bad Grade';
GO
--------------------------------------------------------------------------------

