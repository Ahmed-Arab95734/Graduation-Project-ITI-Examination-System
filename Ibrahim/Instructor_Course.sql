
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
    SET NOCOUNT ON;

    -- 1. Pre-Checks (NOT NULL, PK, FK)
    IF @Instructor_ID IS NULL OR @Course_ID IS NULL
    BEGIN
        SELECT 'Error: The composite Primary Key columns (Instructor_ID, Course_ID) cannot be NULL. Please provide valid IDs.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Course_ID)
    BEGIN
        SELECT 'Error: This combination of Instructor_ID and Course_ID already exists. This link cannot be duplicated.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
    BEGIN
        SELECT 'Error: The provided Instructor_ID does not exist in the [Instructor] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [Course_ID] = @Course_ID)
    BEGIN
        SELECT 'Error: The provided Course_ID does not exist in the [Course] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Insert
    BEGIN TRY
        INSERT INTO [dbo].[Instructor_Course] ([Instructor_ID], [Course_ID])
        -- 3. Output inserted data
        OUTPUT 
            inserted.[Instructor_ID] AS [Inserted_Instructor_ID],
            inserted.[Course_ID] AS [Inserted_Course_ID]
        VALUES 
            (@Instructor_ID, @Course_ID);
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


PRINT '--- 1. TESTING sp_InsertInstructor_Course ---';
-- ASSUMPTION: Instructor 1 and Course 101 exist.
-- Test 1 (Success):
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 1, @Course_ID = 101;
-- Test 2 (Error - PK NULL):
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 1, @Course_ID = NULL;
-- Test 3 (Error - PK Exists):
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 1, @Course_ID = 101;
-- Test 4 (Error - Bad FK 1):
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 2020, @Course_ID = 101;
-- Test 5 (Error - Bad FK 2):
EXEC [dbo].[Instructor_Course_Insert] @Instructor_ID = 1, @Course_ID = 999;
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
    @Old_Instructor_ID INT,
    @Old_Course_ID INT,
    @New_Instructor_ID INT,
    @New_Course_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks
    IF @Old_Instructor_ID IS NULL OR @Old_Course_ID IS NULL OR @New_Instructor_ID IS NULL OR @New_Course_ID IS NULL
    BEGIN
        SELECT 'Error: All parameters (@Old_Instructor_ID, @Old_Course_ID, @New_Instructor_ID, @New_Course_ID) are required and cannot be NULL.' AS ErrorMessage;
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @Old_Instructor_ID AND [Course_ID] = @Old_Course_ID)
    BEGIN
        SELECT 'Error: The OLD record (Instructor_ID = @Old_Instructor_ID, Course_ID = @Old_Course_ID) does not exist. No update occurred.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @New_Instructor_ID AND [Course_ID] = @New_Course_ID)
    BEGIN
        SELECT 'Error: The NEW record (Instructor_ID = @New_Instructor_ID, Course_ID = @New_Course_ID) already exists. This violates the Primary Key constraint.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @New_Instructor_ID)
    BEGIN
        SELECT 'Error: The provided New_Instructor_ID does not exist in the [Instructor] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Course] WHERE [Course_ID] = @New_Course_ID)
    BEGIN
        SELECT 'Error: The provided New_Course_ID does not exist in the [Course] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Transaction
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Step 1: Delete the Old record
        DELETE FROM [dbo].[Instructor_Course]
        OUTPUT 
            deleted.[Instructor_ID] AS [Old_Instructor_ID],
            deleted.[Course_ID] AS [Old_Course_ID]
        WHERE 
            [Instructor_ID] = @Old_Instructor_ID AND [Course_ID] = @Old_Course_ID;

        -- Step 2: Insert the New record
        INSERT INTO [dbo].[Instructor_Course] ([Instructor_ID], [Course_ID])
        OUTPUT 
            inserted.[Instructor_ID] AS [New_Instructor_ID],
            inserted.[Course_ID] AS [New_Course_ID]
        VALUES 
            (@New_Instructor_ID, @New_Course_ID);

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
PRINT '--- 3. TESTING Instructor_Course_Update ---';
-- ASSUMPTION: Instructor 2 and Course 102 exist.
-- Test 10 (Success): Update record (1, 101) to (2, 102).
EXEC [dbo].[Instructor_Course_Update] @Old_Instructor_ID = 1, @Old_Course_ID = 101, @New_Instructor_ID = 2, @New_Course_ID = 102;
-- Test 11 (Error - Old Not Found):
EXEC [dbo].[Instructor_Course_Update] @Old_Instructor_ID = 99, @Old_Course_ID = 101, @New_Instructor_ID = 2, @New_Course_ID = 102;
-- Test 12 (Error - New Exists):
EXEC [dbo].[Instructor_Course_Update] @Old_Instructor_ID = 2, @Old_Course_ID = 102, @New_Instructor_ID = 1, @New_Course_ID = 101; -- Fails, (1, 101) exists
-- Test 13 (Error - Bad New FK):
EXEC [dbo].[Instructor_Course_Update] @Old_Instructor_ID = 2, @Old_Course_ID = 102, @New_Instructor_ID = 99, @New_Course_ID = 102;
GO
--------------------------------------------------------------------------------


-- DELETE
Create PROCEDURE [dbo].[Instructor_Course_Delete]
    @Instructor_ID INT = NULL,
    @Course_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
         IF @Instructor_ID IS NULL OR @Course_ID IS NULL
        BEGIN
            SELECT 'Error: Safe delete requires the full composite key. BOTH Instructor_ID and Course must be provided. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END
        IF @Instructor_ID IS NOT NULL AND @Course_ID IS NOT NULL
        BEGIN
            -- 1. Delete by Full Composite Key
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Course] WHERE [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Course_ID)
            BEGIN
                SELECT 'Error: Record not found. No deletion occurred. Please provide a valid composite key.' AS ErrorMessage;
                RETURN;
            END

            DELETE FROM [dbo].[Instructor_Course]
            OUTPUT 
                deleted.[Instructor_ID] AS [Deleted_Instructor_ID],
                deleted.[Course_ID] AS [Deleted_Course_ID]
            WHERE 
                [Instructor_ID] = @Instructor_ID AND [Course_ID] = @Course_ID;
        END
        ELSE IF @Instructor_ID IS NULL AND @Course_ID IS NULL
        BEGIN
            -- 2. Delete All Records
            PRINT 'Warning: Deleting all records from [Instructor_Course]. This action cannot be undone.'
            
            -- This is a join table, TRUNCATE is almost always safe and fast.
            TRUNCATE TABLE [dbo].[Instructor_Course];
            SELECT 'Success: All records have been deleted from [Instructor_Course].' AS SuccessMessage;
        END
        ELSE
        BEGIN
            -- 3. Error on Partial Key Delete
            SELECT 'Error: Partial key deletion is not allowed. Please provide BOTH Instructor_ID and Course_ID to delete a specific record, or provide NO IDs (both NULL) to delete all records.' AS ErrorMessage;
            RETURN;
        END
    END TRY
    BEGIN CATCH
        -- 4. Smart CATCH Block (FK violation on DELETE is unlikely with ON DELETE CASCADE)
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this record. It is still referenced by other tables (Foreign Key violation). Please delete the child records first.' AS ErrorMessage;
            RETURN;
        END
        
        SELECT 'An unexpected error occurred in sp_DeleteInstructor_Course.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Course_Delete
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING sp_DeleteInstructor_Course ---';
-- Test 14 (Success): Delete record (1, 101).
EXEC [dbo].[Instructor_Course_Delete] @Instructor_ID = 1, @Course_ID = 101;
-- Test 15 (Error - Not Found):
EXEC [dbo].[Instructor_Course_Delete] @Instructor_ID = 99, @Course_ID = 101;
-- Test 16 (Error - Partial Key):
EXEC [dbo].[Instructor_Course_Delete] @Instructor_ID = 1;
-- Test 17 (Delete All):
EXEC [dbo].[Instructor_Course_Delete];
GO
--------------------------------------------------------------------------------


