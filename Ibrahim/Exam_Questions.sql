
--------------------------------------------------------------------------------
-- 3. CRUD STORED PROCEDURES FOR 'Exam_Questions'
--------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Exam_Questions_Insert]
    @Exam_ID INT,
    @Question_ID INT
AS
BEGIN
    -- Adds a specific question to a specific exam.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check Foreign Key (Exam)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam] WHERE [Exam_ID] = @Exam_ID)
        BEGIN
            SELECT 'Error: Exam_ID does not exist in the Exam table.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Questions_Bank)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Question_Bank] WHERE [Question_ID] = @Question_ID)
        BEGIN
            SELECT 'Error: Question_ID does not exist in the Questions_Bank table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Check Primary Key (Uniqueness)
        IF EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID)
        BEGIN
            SELECT 'Error: This question is already assigned to this exam.' AS ErrorMessage;
            RETURN;
        END

        -- 4. Perform Insert
        INSERT INTO [dbo].[Exam_Questions] ([Exam_ID], [Question_ID])
        VALUES (@Exam_ID, @Question_ID);
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Exam_Questions_Insert.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------

PRINT '--- 1. TESTING Exam_Questions_Insert ---';

-- Test 1 (Success): Add a valid question (5001) to a valid exam (1).
PRINT 'Test 1 (Success - Adding 1, 5001)...';
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 1, @Question_ID = 1;

-- Test 2 (Success): Add another valid question (5002) to the same exam (1).
PRINT 'Test 2 (Success - Adding 1, 5002)...';
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 1, @Question_ID = 2;

-- Test 3 (Error - Duplicate PK): Try to add question 5001 to exam 1 again.
PRINT 'Test 3 (Error - Duplicate PK)...';
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 1, @Question_ID = 2;
-- Expected: 'Error: This question is already assigned to this exam.'

-- Test 4 (Error - Bad FK1): Try to add a question to a non-existent exam (999).
PRINT 'Test 4 (Error - Bad Exam_ID FK)...';
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 100000, @Question_ID = 5003;
-- Expected: 'Error: Exam_ID does not exist in the Exam table.'

-- Test 5 (Error - Bad FK2): Try to add a non-existent question (9999) to a valid exam.
PRINT 'Test 5 (Error - Bad Question_ID FK)...';
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 1, @Question_ID = 100000;
-- Expected: 'Error: Question_ID does not exist in the Questions_Bank table.'
GO

--------------------------------------------------------------------------------------------------------

-- READ (Select by Primary Key)
CREATE PROCEDURE [dbo].[Exam_Questions_Select]
    @Exam_ID INT = NULL,
    @Question_ID INT = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Both IDs: Selects by Primary Key.
    -- 2. Only Exam_ID: Selects all questions for that exam.
    -- 3. Only Question_ID: Selects all exams for that question.
    -- 4. Neither ID: Selects all records.
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @Exam_ID IS NOT NULL AND @Question_ID IS NOT NULL
        BEGIN
            -- 1. Both IDs provided: Select the specific record by PK
            SELECT *
            FROM [dbo].[Exam_Questions]
            WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID;
        END
        ELSE IF @Exam_ID IS NOT NULL AND @Question_ID IS NULL
        BEGIN
            -- 2. Only Exam_ID provided: Select all questions for that exam
            SELECT *
            FROM [dbo].[Exam_Questions]
            WHERE [Exam_ID] = @Exam_ID;
        END
        ELSE IF @Exam_ID IS NULL AND @Question_ID IS NOT NULL
        BEGIN
            -- 3. Only Question_ID provided: Select all exams for that question
            SELECT *
            FROM [dbo].[Exam_Questions]
            WHERE [Question_ID] = @Question_ID;
        END
        ELSE
        BEGIN
            -- 4. Both IDs are NULL: Select all records
            SELECT * FROM [dbo].[Exam_Questions];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Exam_Questions_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO


-- TEST CASES FOR Exam_Questions_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Exam_Questions_Select (Consolidated) ---';

-- Test 6 (PK): Find a link that exists.
PRINT 'Test 6 (Select - Finding 1, 5001)...';
EXEC [dbo].[Exam_Questions_Select] @Exam_ID = 1, @Question_ID = 1;
-- Expected: 1 row returned.

-- Test 7 (PK - No Result): Find a link that does not exist.
PRINT 'Test 7 (Select - Finding 102, 5001)...';
EXEC [dbo].[Exam_Questions_Select] @Exam_ID = 102, @Question_ID = 5001;
-- Expected: 0 rows returned.

-- Test 8 (All): Call with no parameters.
PRINT 'Test 8 (Select - All rows, no params)...';
EXEC [dbo].[Exam_Questions_Select];
-- Expected: All rows (2 in this test script).

-- Test 9 (By Exam_ID): Find all questions for exam 1.
PRINT 'Test 9 (Select - By Exam_ID 1)...';
EXEC [dbo].[Exam_Questions_Select] @Exam_ID = 1;
-- Expected: 2 rows returned (5001, 5002).

-- Test 10 (By Question_ID): Find all exams using question 5001.
PRINT 'Test 10 (Select - By Question_ID 5001)...';
EXEC [dbo].[Exam_Questions_Select] @Question_ID = 5001;
-- Expected: 1 row returned (Exam 1).
GO

--------------------------------------------------------------------------------

-- UPDATE (DELETE + INSERT Pattern)
/*
-- NOTE: This procedure updates the [Question_ID] part of the composite primary key.
-- This is achieved by deleting the old record and inserting a new one
-- within a single, safe transaction.
*/

CREATE PROCEDURE [dbo].[Exam_Questions_Update]
    @Exam_ID INT,
    @Old_Question_ID INT,
    @New_Question_ID INT
AS
BEGIN
    -- Updates an exam's question assignment by replacing the old one with a new one.
    SET NOCOUNT ON;

    -- Check 1: Old assignment must exist
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Old_Question_ID)
    BEGIN
        SELECT 'Error: The old question assignment does not exist for this exam.' AS ErrorMessage;
        RETURN;
    END

    -- Check 2: New assignment must NOT exist
    IF EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @New_Question_ID)
    BEGIN
        SELECT 'Error: The new question assignment is already registered for this exam.' AS ErrorMessage;
        RETURN;
    END

    -- Check 3: New Question_ID must be a valid FK
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Questions_Bank] WHERE [Question_ID] = @New_Question_ID)
    BEGIN
        SELECT 'Error: The new Question_ID does not exist in the Questions_Bank table.' AS ErrorMessage;
        RETURN;
    END

    -- Start transaction to ensure atomicity (all or nothing)
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Step 1: Delete the old record
        DELETE FROM [dbo].[Exam_Questions]
        WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Old_Question_ID;
        
        -- Step 2: Insert the new record
        INSERT INTO [dbo].[Exam_Questions] ([Exam_ID], [Question_ID])
        VALUES (@Exam_ID, @New_Question_ID);
        
        -- If both steps succeed, commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If any step fails, roll back the entire operation
        ROLLBACK TRANSACTION;
        SELECT 'An unexpected error occurred during the update. The transaction was rolled back.' AS ErrorMessage;
        THROW; -- Re-throw the original error for debugging
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Exam_Questions_Update
--------------------------------------------------------------------------------
-- ASSUMPTION:
-- 1. Question 503 exists in the [Questions_Bank] table.
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Exam_Questions_Update ---';

-- Test 10 (Success): Update question 502 to 503 for exam 101.
PRINT 'Test 10 (Update - Success)...';
EXEC [dbo].[Exam_Questions_Update]
    @Exam_ID = 101,
    @Old_Question_ID = 502,
    @New_Question_ID = 503;
-- Verify:
EXEC [dbo].[Exam_Questions_Select] @Exam_ID = 101;
-- Expected: 2 rows (501 and 503)

-- Test 11 (Error - Old Not Found): Try to update a non-existent old question (999).
PRINT 'Test 11 (Update - Error, Old Question Not Found)...';
EXEC [dbo].[Exam_Questions_Update]
    @Exam_ID = 101,
    @Old_Question_ID = 999,
    @New_Question_ID = 503;
-- Expected: 'Error: The old question assignment does not exist for this exam.'

-- Test 12 (Error - New Already Exists): Try to update 503 to 501 (which already exists).
PRINT 'Test 12 (Update - Error, New Question Already Exists)...';
EXEC [dbo].[Exam_Questions_Update]
    @Exam_ID = 101,
    @Old_Question_ID = 503,
    @New_Question_ID = 501;
-- Expected: 'Error: The new question assignment is already registered for this exam.'

-- Test 13 (Error - New FK invalid): Try to update 503 to 999 (non-existent question).
PRINT 'Test 13 (Update - Error, New Question FK invalid)...';
EXEC [dbo].[Exam_Questions_Update]
    @Exam_ID = 101,
    @Old_Question_ID = 503,
    @New_Question_ID = 999;
-- Expected: 'Error: The new Question_ID does not exist in the Questions_Bank table.'
GO

------------------------------------------------------------------------------------------------------------------

-- DELETE
alter PROCEDURE [dbo].[Exam_Questions_Delete]
    @Exam_ID INT = null,
    @Question_ID INT = null
AS
BEGIN
    -- Removes a single question from a specific exam.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if the record exists
        IF NOT EXISTS (SELECT * FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID)
        BEGIN
            SELECT 'Error: This question is not part of this exam. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Perform Delete
        DELETE FROM [dbo].[Exam_Questions]
        WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID;
    END TRY
    BEGIN CATCH
        -- Check for specific error 547 (Foreign Key violation)
        -- This is unlikely here unless another table (e.g., Student_Answers)
        -- links directly to Exam_Questions.
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this link. It is still referenced by other records (e.g., student answers).' AS ErrorMessage;
            RETURN;
        END
        
        -- Handle other errors
        SELECT 'An unexpected error occurred in Exam_Questions_Delete.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO


-- TEST CASES FOR Exam_Questions_Delete
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Exam_Questions_Delete ---';

-- Test 11 (Success): Delete an existing link.
PRINT 'Test 11 (Delete - Removing 1, 5001)...';
EXEC [dbo].[Exam_Questions_Delete] @Exam_ID = 1, @Question_ID = 1;

-- Test 12 (Error - Not Found): Try to delete a link that does not exist.
PRINT 'Test 12 (Delete - Removing non-existent 102, 5001)...';
EXEC [dbo].[Exam_Questions_Delete] @Exam_ID = 100000, @Question_ID = 5001;
-- Expected: 'Error: This question is not assigned to this exam. No deletion occurred.'

-- Test 13 (Error - Already Deleted): Try to delete the first link again.
PRINT 'Test 13 (Delete - Removing 1, 5001 again)...';
EXEC [dbo].[Exam_Questions_Delete] @Exam_ID = 1, @Question_ID = 2;
-- Expected: 'Error: This question is not assigned to this exam. No deletion occurred.'

PRINT '--- 4. FINAL VERIFICATION ---';
-- Run SelectAll again. It should only show one row: (1, 5002).
PRINT 'Test 14 (Final Select - Should show 1 row)...';
EXEC [dbo].[Exam_Questions_Select];
--------------------------------------------------------------------------------
