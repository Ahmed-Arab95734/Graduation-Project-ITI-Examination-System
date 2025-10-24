
--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Instructor_Course' (v5 - Final Template Applied)
-- FK Tables: [Instructor], [Course]
-- PK: Composite (Instructor_ID, Course_ID)
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Instructor_Course_Insert]
    @Instructor_ID INT,
    @Course_ID INT
AS
BEGIN
    -- Assigns a specific instructor to a specific course.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check Primary Key (Uniqueness)
        IF EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Course_ID)
        BEGIN
            SELECT 'Error: This instructor is already assigned to this course.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Instructor)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
        BEGIN
            SELECT 'Error: Instructor_ID does not exist in the Instructor table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Check Foreign Key (Course)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [Course_ID] = @Course_ID)
        BEGIN
            SELECT 'Error: Course_ID does not exist in the Course table.' AS ErrorMessage;
            RETURN;
        END

        -- 4. Perform Insert
        INSERT INTO [dbo].[Instructor_Course] ([Instructor_ID], [Course_ID])
        VALUES (@Instructor_ID, @Course_ID);
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Instructor_Course_Insert.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Course_Insert
--------------------------------------------------------------------------------
-- ASSUMPTIONS:
-- 1. You have an [Instructor] table with at least Instructor_ID = 201.
-- 2. You have a [Course] table with at least Course_ID = 301 and 302.
--------------------------------------------------------------------------------

PRINT '--- 1. TESTING Instructor_Course_Insert ---';

-- Test 1 (Success): Assign instructor 201 to course 301.
PRINT 'Test 1 (Success - Adding 201, 301)...';
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 201, @Course_ID = 301;

-- Test 2 (Success): Assign instructor 201 to course 302.
PRINT 'Test 2 (Success - Adding 201, 302)...';
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 201, @Course_ID = 302;

-- Test 3 (Error - Duplicate PK): Try to add (201, 301) again.
PRINT 'Test 3 (Error - Duplicate PK)...';
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 201, @Course_ID = 301;
-- Expected: 'Error: This instructor is already assigned to this course.'

-- Test 4 (Error - Bad Instructor_ID FK): Try to add a non-existent instructor (999).
PRINT 'Test 4 (Error - Bad Instructor_ID FK)...';
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 999, @Course_ID = 301;
-- Expected: 'Error: Instructor_ID does not exist in the Instructor table.'

-- Test 5 (Error - Bad Course_ID FK): Try to add a non-existent course (999).
PRINT 'Test 5 (Error - Bad Course_ID FK)...';
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 201, @Course_ID = 999;
-- Expected: 'Error: Course_ID does not exist in the Course table.'
GO
--------------------------------------------------------------------------------


-- READ (Consolidated Select)
CREATE PROCEDURE [dbo].[Instructor_Course_Select]
    @Instructor_ID INT = NULL,
    @Course_ID INT = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Both IDs: Selects by Primary Key.
    -- 2. Only Instructor_ID: Selects all courses for that instructor.
    -- 3. Only Course_ID: Selects all instructors for that course.
    -- 4. Neither ID: Selects all records.
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @Instructor_ID IS NOT NULL AND @Course_ID IS NOT NULL
        BEGIN
            -- 1. Both provided: Select the specific record by PK
            SELECT *
            FROM [dbo].[Instructor_Course]
            WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Course_ID;
        END
        ELSE IF @Instructor_ID IS NOT NULL AND @Course_ID IS NULL
        BEGIN
            -- 2. Only Instructor_ID provided: Select all courses for that instructor
            SELECT *
            FROM [dbo].[Instructor_Course]
            WHERE [Instructor_ID] = @Instructor_ID;
        END
        ELSE IF @Instructor_ID IS NULL AND @Course_ID IS NOT NULL
        BEGIN
            -- 3. Only Course_ID provided: Select all instructors for that course
            SELECT *
            FROM [dbo].[Instructor_Course]
            WHERE [Course_ID] = @Course_ID;
        END
        ELSE
        BEGIN
            -- 4. Both are NULL: Select all records
            SELECT * FROM [dbo].[Instructor_Course];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Instructor_Course_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Course_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Instructor_Course_Select (Consolidated) ---';

-- Test 6 (PK): Find link (201, 301).
PRINT 'Test 6 (Select - Finding 201, 301)...';
EXEC [dbo].[Instructor_Course_Select] @Instructor_ID = 201, @Course_ID = 301;
-- Expected: 1 row.

-- Test 7 (All): Call with no parameters.
PRINT 'Test 7 (Select - All rows)...';
EXEC [dbo].[Instructor_Course_Select];
-- Expected: 2 rows.

-- Test 8 (By Instructor_ID): Find all courses for instructor 201.
PRINT 'Test 8 (Select - By Instructor_ID 201)...';
EXEC [dbo].[Instructor_Course_Select] @Instructor_ID = 201;
-- Expected: 2 rows (301, 302).

-- Test 9 (By Course_ID): Find all instructors for course 302.
PRINT 'Test 9 (Select - By Course_ID 302)...';
EXEC [dbo].[Instructor_Course_Select] @Course_ID = 302;
-- Expected: 1 row (Instructor 201).
GO
---------------------------------------------------------------------------------

-- UPDATE (DELETE + INSERT Pattern)
/*
-- NOTE: This procedure updates the [Course_ID] part of the composite primary key.
-- This is achieved by deleting the old record and inserting a new one
-- within a single, safe transaction.
*/
CREATE PROCEDURE [dbo].[Instructor_Course_Update]
    @Instructor_ID INT,
    @Old_Course_ID INT,
    @New_Course_ID INT
AS
BEGIN
    -- Updates an instructor's course assignment by replacing the old one with a new one.
    SET NOCOUNT ON;

    -- Check 1: Old assignment must exist
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Old_Course_ID)
    BEGIN
        SELECT 'Error: The old course assignment does not exist for this instructor.' AS ErrorMessage;
        RETURN;
    END

    -- Check 2: New assignment must NOT exist
    IF EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @New_Course_ID)
    BEGIN
        SELECT 'Error: The new course assignment is already registered for this instructor.' AS ErrorMessage;
        RETURN;
    END

    -- Check 3: New Course_ID must be a valid FK
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [Course_ID] = @New_Course_ID)
    BEGIN
        SELECT 'Error: The new Course_ID does not exist in the Course table.' AS ErrorMessage;
        RETURN;
    END

    -- Start transaction to ensure atomicity (all or nothing)
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Step 1: Delete the old record
        DELETE FROM [dbo].[Instructor_Course]
        WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Old_Course_ID;
        
        -- Step 2: Insert the new record
        INSERT INTO [dbo].[Instructor_Course] ([Instructor_ID], [Course_ID])
        VALUES (@Instructor_ID, @New_Course_ID);
        
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
-- TEST CASES FOR Instructor_Course_Update
--------------------------------------------------------------------------------
-- ASSUMPTION:
-- 1. Course 303 exists in the [Course] table.
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Instructor_Course_Update ---';

-- Test 10 (Success): Update course 302 to 303 for instructor 201.
PRINT 'Test 10 (Update - Success)...';
EXEC [dbo].[Instructor_Course_Update]
    @Instructor_ID = 201,
    @Old_Course_ID = 302,
    @New_Course_ID = 303;
-- Verify:
EXEC [dbo].[Instructor_Course_Select] @Instructor_ID = 201;
-- Expected: 2 rows (301 and 303)

-- Test 11 (Error - Old Not Found): Try to update a non-existent old course (999).
PRINT 'Test 11 (Update - Error, Old Course Not Found)...';
EXEC [dbo].[Instructor_Course_Update]
    @Instructor_ID = 201,
    @Old_Course_ID = 999,
    @New_Course_ID = 303;
-- Expected: 'Error: The old course assignment does not exist for this instructor.'

-- Test 12 (Error - New Already Exists): Try to update 303 to 301 (which already exists).
PRINT 'Test 12 (Update - Error, New Course Already Exists)...';
EXEC [dbo].[Instructor_Course_Update]
    @Instructor_ID = 201,
    @Old_Course_ID = 303,
    @New_Course_ID = 301;
-- Expected: 'Error: The new course assignment is already registered for this instructor.'

-- Test 13 (Error - New FK invalid): Try to update 303 to 999 (non-existent course).
PRINT 'Test 13 (Update - Error, New Course FK invalid)...';
EXEC [dbo].[Instructor_Course_Update]
    @Instructor_ID = 201,
    @Old_Course_ID = 303,
    @New_Course_ID = 999;
-- Expected: 'Error: The new Course_ID does not exist in the Course table.'
GO
--------------------------------------------------------------------------------


-- DELETE
CREATE PROCEDURE [dbo].[Instructor_Course_Delete]
    @Instructor_ID INT,
    @Course_ID INT
AS
BEGIN
    -- Removes an instructor's assignment from a specific course.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if the record exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Course_ID)
        BEGIN
            SELECT 'Error: This instructor is not assigned to this course. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Perform Delete
        DELETE FROM [dbo].[Instructor_Course]
        WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Course_ID;
    END TRY
    BEGIN CATCH
        -- Check for specific error 547 (Foreign Key violation)
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this assignment. It is still referenced by other records.' AS ErrorMessage;
            RETURN;
        END
        
        -- Handle other errors
        SELECT 'An unexpected error occurred in Instructor_Course_Delete.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Course_Delete
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING Instructor_Course_Delete ---';

-- Test 14 (Success): Delete link (201, 301).
PRINT 'Test 14 (Delete - Removing 201, 301)...';
EXEC [dbo].[Instructor_Course_Delete] @Instructor_ID = 201, @Course_ID = 301;

-- Test 15 (Error - Not Found): Try to delete non-existent link (201, 999).
PRINT 'Test 15 (Delete - Removing non-existent 201, 999)...';
EXEC [dbo].[Instructor_Course_Delete] @Instructor_ID = 201, @Course_ID = 999;
-- Expected: 'Error: This instructor is not assigned to this course. No deletion occurred.'

-- Test 16 (Error - Already Deleted): Try to delete (201, 301) again.
PRINT 'Test 16 (Delete - Removing 201, 301 again)...';
EXEC [dbo].[Instructor_Course_Delete] @Instructor_ID = 201, @Course_ID = 301;
-- Expected: 'Error: This instructor is not assigned to this course. No deletion occurred.'

PRINT '--- 5. FINAL VERIFICATION ---';
EXEC [dbo].[Instructor_Course_Select];
-- Expected: 1 row (201, 303).
GO
--------------------------------------------------------------------------------
*/

