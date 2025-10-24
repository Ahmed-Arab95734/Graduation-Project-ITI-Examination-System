
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
    -- Adds a failure reason to a specific student.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check Foreign Key (Student)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [Student_ID] = @Student_ID)
        BEGIN
            SELECT 'Error: Student_ID does not exist in the Student table.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Primary Key (Uniqueness)
        IF EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason)
        BEGIN
            SELECT 'Error: This failure reason is already registered for this student.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Perform Insert
        INSERT INTO [dbo].[Failed_Students] ([Student_ID], [Failure_Reason])
        VALUES (@Student_ID, @Failure_Reason);
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Failed_Students_Insert.' AS ErrorMessage;
        THROW;
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
    -- 1. Both IDs: Selects by Primary Key.
    -- 2. Only Student_ID: Selects all reasons for that student.
    -- 3. Only Failure_Reason: Selects all students for that reason.
    -- 4. Neither ID: Selects all records.
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @Student_ID IS NOT NULL AND @Failure_Reason IS NOT NULL
        BEGIN
            -- 1. Both provided: Select the specific record by PK
            SELECT *
            FROM [dbo].[Failed_Students]
            WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason;
        END
        ELSE IF @Student_ID IS NOT NULL AND @Failure_Reason IS NULL
        BEGIN
            -- 2. Only Student_ID provided: Select all reasons for that student
            SELECT *
            FROM [dbo].[Failed_Students]
            WHERE [Student_ID] = @Student_ID;
        END
        ELSE IF @Student_ID IS NULL AND @Failure_Reason IS NOT NULL
        BEGIN
            -- 3. Only Failure_Reason provided: Select all students for that reason
            SELECT *
            FROM [dbo].[Failed_Students]
            WHERE [Failure_Reason] = @Failure_Reason;
        END
        ELSE
        BEGIN
            -- 4. Both are NULL: Select all records
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

-- UPDATE (Atomic DELETE + INSERT)
CREATE PROCEDURE [dbo].[Failed_Students_Update]
    @Student_ID INT,
    @Old_Failure_Reason NVARCHAR(255),
    @New_Failure_Reason NVARCHAR(255)
AS
BEGIN
    -- Atomically "updates" a failure reason by deleting the old and inserting the new.
    SET NOCOUNT ON;

    BEGIN TRY
        -- If old and new are the same, do nothing.
        IF @Old_Failure_Reason = @New_Failure_Reason
        BEGIN
            SELECT 'Warning: Old and new failure reasons are the same. No update occurred.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- 1. Check if Old Record Exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Old_Failure_Reason)
        BEGIN
            SELECT 'Error: The original record (Student_ID, Old_Failure_Reason) does not exist.' AS ErrorMessage;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Check if New Record Already Exists (PK conflict)
        IF EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @New_Failure_Reason)
        BEGIN
            SELECT 'Error: The new failure reason is already registered for this student.' AS ErrorMessage;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 3. Check Foreign Key (Student)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Student] WHERE [Student_ID] = @Student_ID)
        BEGIN
            SELECT 'Error: Student_ID does not exist in the Student table.' AS ErrorMessage;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 4. Perform the atomic Delete and Insert
        DELETE FROM [dbo].[Failed_Students]
        WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Old_Failure_Reason;
        
        INSERT INTO [dbo].[Failed_Students] ([Student_ID], [Failure_Reason])
        VALUES (@Student_ID, @New_Failure_Reason);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 'An unexpected error occurred in Failed_Students_Update.' AS ErrorMessage;
        THROW;
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
*/

-- DELETE
CREATE PROCEDURE [dbo].[Failed_Students_Delete]
    @Student_ID INT,
    @Failure_Reason NVARCHAR(255)
AS
BEGIN
    -- Removes a specific failure reason from a specific student.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if the record exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Failed_Students] WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason)
        BEGIN
            SELECT 'Error: This failure reason is not assigned to this student. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Perform Delete
        DELETE FROM [dbo].[Failed_Students]
        WHERE [Student_ID] = @Student_ID AND [Failure_Reason] = @Failure_Reason;
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Failed_Students_Delete.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Failed_Students_Delete
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Failed_Students_Delete ---';

-- Test 9 (Success): Delete link (1, 'Attendance').
PRINT 'Test 9 (Delete - Removing 1, "Attendance")...';
EXEC [dbo].[Failed_Students_Delete] @Student_ID = 1, @Failure_Reason = 'Attendance';

-- Test 10 (Error - Not Found): Try to delete non-existent link (1, 'Cheating').
PRINT 'Test 10 (Delete - Removing non-existent 1, "Cheating")...';
EXEC [dbo].[Failed_Students_Delete] @Student_ID = 1, @Failure_Reason = 'Cheating';
-- Expected: 'Error: This failure reason is not assigned to this student. No deletion occurred.'

-- Test 11 (Error - Already Deleted): Try to delete (1, 'Attendance') again.
PRINT 'Test 11 (Delete - Removing 1, "Attendance" again)...';
EXEC [dbo].[Failed_Students_Delete] @Student_ID = 1, @Failure_Reason = 'Attendance';
-- Expected: 'Error: This failure reason is not assigned to this student. No deletion occurred.'

PRINT '--- 4. FINAL VERIFICATION ---';
EXEC [dbo].[Failed_Students_Select] ;
-- Expected: 1 row (1, 'Grades').
GO
--------------------------------------------------------------------------------

