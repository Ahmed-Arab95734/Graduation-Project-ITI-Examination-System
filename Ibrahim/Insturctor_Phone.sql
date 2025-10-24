--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Instructor_Phone' (v4 - Final Template Applied)
-- FK Tables: [Instructor]
-- PK: Composite (Instructor_ID, Phone)
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Instructor_Phone_Insert]
    @Instructor_ID INT,
    @Phone NVARCHAR(20)
AS
BEGIN
    -- Adds a new phone number for a specific instructor.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check Primary Key (Uniqueness)
        IF EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Phone)
        BEGIN
            SELECT 'Error: This phone number is already registered for this instructor.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Instructor)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
        BEGIN
            SELECT 'Error: Instructor_ID does not exist in the Instructor table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Perform Insert
        INSERT INTO [dbo].[Instructor_Phone] ([Instructor_ID], [Phone])
        VALUES (@Instructor_ID, @Phone);
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Instructor_Phone_Insert.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Phone_Insert
--------------------------------------------------------------------------------
-- ASSUMPTIONS:
-- 1. You have an [Instructor] table with at least Instructor_ID = 1.
--------------------------------------------------------------------------------

PRINT '--- 1. TESTING Instructor_Phone_Insert ---';

-- Test 1 (Success): Add a valid phone.
PRINT 'Test 1 (Success - Adding phone 1)...';
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 1, @Phone = '01001234567';

-- Test 2 (Success): Add a second phone for the same instructor.
PRINT 'Test 2 (Success - Adding phone 2)...';
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 1, @Phone = '01117654321';

-- Test 3 (Error - Duplicate PK): Try to add phone 1 again.
PRINT 'Test 3 (Error - Duplicate PK)...';
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 1, @Phone = '01001234567';
-- Expected: 'Error: This phone number is already registered for this instructor.'

-- Test 4 (Error - Bad FK): Try to add a phone for a non-existent instructor.
PRINT 'Test 4 (Error - Bad Instructor_ID FK)...';
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 999, @Phone = '01555555555';
-- Expected: 'Error: Instructor_ID does not exist in the Instructor table.'
GO
--------------------------------------------------------------------------------


-- READ (Consolidated Select)
CREATE PROCEDURE [dbo].[Instructor_Phone_Select]
    @Instructor_ID INT = NULL,
    @Phone NVARCHAR(20) = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Both IDs: Selects by Primary Key.
    -- 2. Only Instructor_ID: Selects all phones for that instructor.
    -- 3. Neither ID: Selects all records.
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @Instructor_ID IS NOT NULL AND @Phone IS NOT NULL
        BEGIN
            -- 1. Both provided: Select the specific record by PK
            SELECT *
            FROM [dbo].[Instructor_Phone]
            WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Phone;
        END
        ELSE IF @Instructor_ID IS NOT NULL AND @Phone IS NULL
        BEGIN
            -- 2. Only Instructor_ID provided: Select all phones for that instructor
            SELECT *
            FROM [dbo].[Instructor_Phone]
            WHERE [Instructor_ID] = @Instructor_ID;
        END
        ELSE IF @Instructor_ID IS NULL AND @Phone IS NOT NULL
        BEGIN
            -- 3. Only Phone provided: Select all instructors with this phone (less common)
            SELECT *
            FROM [dbo].[Instructor_Phone]
            WHERE [Phone] = @Phone;
        END
        ELSE
        BEGIN
            -- 4. Both are NULL: Select all records
            SELECT * FROM [dbo].[Instructor_Phone];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Instructor_Phone_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Phone_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Instructor_Phone_Select (Consolidated) ---';

-- Test 5 (PK): Find link (1, '01001234567').
PRINT 'Test 5 (Select - Finding by PK)...';
EXEC [dbo].[Instructor_Phone_Select] @Instructor_ID = 1, @Phone = '01001234567';
-- Expected: 1 row.

-- Test 6 (All): Call with no parameters.
PRINT 'Test 6 (Select - All rows)...';
EXEC [dbo].[Instructor_Phone_Select];
-- Expected: 2 rows.

-- Test 7 (By Instructor_ID): Find all phones for instructor 1.
PRINT 'Test 7 (Select - By Instructor_ID 1)...';
EXEC [dbo].[Instructor_Phone_Select] @Instructor_ID = 1;
-- Expected: 2 rows.
GO
--------------------------------------------------------------------------------


-- UPDATE (DELETE + INSERT Pattern)
/*
-- NOTE: This procedure updates the [Phone] part of the composite primary key.
-- This is achieved by deleting the old record and inserting a new one
-- within a single, safe transaction.
*/
CREATE PROCEDURE [dbo].[Instructor_Phone_Update]
    @Instructor_ID INT,
    @Old_Phone NVARCHAR(20),
    @New_Phone NVARCHAR(20)
AS
BEGIN
    -- Updates an instructor's phone number by replacing the old one with a new one.
    SET NOCOUNT ON;

    -- Check 1: Old phone must exist
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Old_Phone)
    BEGIN
        SELECT 'Error: The old phone number does not exist for this instructor.' AS ErrorMessage;
        RETURN;
    END

    -- Check 2: New phone must NOT exist (for this instructor)
    IF EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @New_Phone)
    BEGIN
        SELECT 'Error: The new phone number is already registered for this instructor.' AS ErrorMessage;
        RETURN;
    END

    -- Start transaction to ensure atomicity (all or nothing)
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Step 1: Delete the old record
        DELETE FROM [dbo].[Instructor_Phone]
        WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Old_Phone;
        
        -- Step 2: Insert the new record
        INSERT INTO [dbo].[Instructor_Phone] ([Instructor_ID], [Phone])
        VALUES (@Instructor_ID, @New_Phone);
        
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
-- TEST CASES FOR Instructor_Phone_Update
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Instructor_Phone_Update ---';

-- Test 8 (Success): Update phone 2 ('0111...') to phone 3 ('0122...').
PRINT 'Test 8 (Update - Success)...';
EXEC [dbo].[Instructor_Phone_Update]
    @Instructor_ID = 1,
    @Old_Phone = '01117654321',
    @New_Phone = '01223334444';
-- Verify:
EXEC [dbo].[Instructor_Phone_Select] @Instructor_ID = 1;
-- Expected: 2 rows (0100... and 0122...)

-- Test 9 (Error - Old Not Found): Try to update a non-existent old phone.
PRINT 'Test 9 (Update - Error, Old Phone Not Found)...';
EXEC [dbo].[Instructor_Phone_Update]
    @Instructor_ID = 1,
    @Old_Phone = '999',
    @New_Phone = '123';
-- Expected: 'Error: The old phone number does not exist for this instructor.'

-- Test 10 (Error - New Already Exists): Try to update phone 3 to phone 1.
PRINT 'Test 10 (Update - Error, New Phone Already Exists)...';
EXEC [dbo].[Instructor_Phone_Update]
    @Instructor_ID = 1,
    @Old_Phone = '01223334444',
    @New_Phone = '01001234567'; -- This one already exists
-- Expected: 'Error: The new phone number is already registered for this instructor.'
GO
--------------------------------------------------------------------------------

-- DELETE
CREATE PROCEDURE [dbo].[Instructor_Phone_Delete]
    @Instructor_ID INT,
    @Phone NVARCHAR(20)
AS
BEGIN
    -- Deletes a single phone number for a specific instructor.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if the record exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Phone)
        BEGIN
            SELECT 'Error: This phone number was not found for this instructor. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Perform Delete
        DELETE FROM [dbo].[Instructor_Phone]
        WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Phone;
    END TRY
    BEGIN CATCH
        -- Check for specific error 547 (Foreign Key violation)
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this phone. It is still referenced by other records.' AS ErrorMessage;
            RETURN;
        END
        
        -- Handle other errors
        SELECT 'An unexpected error occurred in Instructor_Phone_Delete.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Phone_Delete
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING Instructor_Phone_Delete ---';

-- Test 11 (Success): Delete phone 1 ('0100...').
PRINT 'Test 11 (Delete - Success, removing phone 1)...';
EXEC [dbo].[Instructor_Phone_Delete] @Instructor_ID = 1, @Phone = '01001234567';

-- Test 12 (Error - Not Found): Try to delete non-existent phone '999'.
PRINT 'Test 12 (Delete - Error, phone 999 not found)...';
EXEC [dbo].[Instructor_Phone_Delete] @Instructor_ID = 1, @Phone = '999';
-- Expected: 'Error: This phone number was not found for this instructor. No deletion occurred.'

-- Test 13 (Error - Already Deleted): Try to delete phone 1 again.
PRINT 'Test 13 (Delete - Error, phone 1 already deleted)...';
EXEC [dbo].[Instructor_Phone_Delete] @Instructor_ID = 1, @Phone = '01001234567';
-- Expected: 'Error: This phone number was not found for this instructor. No deletion occurred.'

PRINT '--- 5. FINAL VERIFICATION ---';
EXEC [dbo].[Instructor_Phone_Select] @Instructor_ID = 1;
-- Expected: 1 row (the '0122...' one from Test 8).
GO
--------------------------------------------------------------------------------