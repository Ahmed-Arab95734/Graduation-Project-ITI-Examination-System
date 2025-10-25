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
    SET NOCOUNT ON;

    -- 1. Pre-Checks (NOT NULL, PK, FK)
    IF @Instructor_ID IS NULL OR @Phone IS NULL
    BEGIN
        SELECT 'Error: The composite Primary Key columns (Instructor_ID, Phone) cannot be NULL. Please provide valid inputs.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Phone)
    BEGIN
        SELECT 'Error: This combination of Instructor_ID and Phone already exists. This link cannot be duplicated.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
    BEGIN
        SELECT 'Error: The provided Instructor_ID does not exist in the [Instructor] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Insert
    BEGIN TRY
        INSERT INTO [dbo].[Instructor_Phone] ([Instructor_ID], [Phone])
        -- 3. Output inserted data
        OUTPUT 
            inserted.[Instructor_ID] AS [Inserted_Instructor_ID],
            inserted.[Phone] AS [Inserted_Phone]
        VALUES 
            (@Instructor_ID, @Phone);
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

/* --------------------------------------------------------------------------------
-- TEST CASES FOR sp_InsertInstructor_Phone
-------------------------------------------------------------------------------- */
PRINT '--- 1. TESTING sp_InsertInstructor_Phone ---';
-- ASSUMPTION: Instructor_ID 1 exists in [Instructor].
-- Test 1 (Success):
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 1, @Phone = '01001234567';
-- Test 2 (Error - PK NULL):
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 1, @Phone = NULL;
-- Test 3 (Error - PK Exists):
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 1, @Phone = '01001234567';
-- Test 4 (Error - Bad FK):
EXEC [dbo].[Instructor_Phone_Insert] @Instructor_ID = 201, @Phone = '01111234567';
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

CREATE PROCEDURE [dbo].[Instructor_Phone_Update]
    @Old_Instructor_ID INT,
    @Old_Phone NVARCHAR(20),
    @New_Instructor_ID INT,
    @New_Phone NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks
    IF @Old_Instructor_ID IS NULL OR @Old_Phone IS NULL OR @New_Instructor_ID IS NULL OR @New_Phone IS NULL
    BEGIN
        SELECT 'Error: All parameters (@Old_Instructor_ID, @Old_Phone, @New_Instructor_ID, @New_Phone) are required and cannot be NULL.' AS ErrorMessage;
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @Old_Instructor_ID AND [Phone] = @Old_Phone)
    BEGIN
        SELECT 'Error: The OLD record (Instructor_ID = @Old_Instructor_ID, Phone = @Old_Phone) does not exist. No update occurred.' AS ErrorMessage;
        RETURN;
    END

    IF (@Old_Instructor_ID != @New_Instructor_ID OR @Old_Phone != @New_Phone) AND
       EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @New_Instructor_ID AND [Phone] = @New_Phone)
    BEGIN
        SELECT 'Error: The NEW record (Instructor_ID = @New_Instructor_ID, Phone = @New_Phone) already exists. This violates the Primary Key constraint.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @New_Instructor_ID)
    BEGIN
        SELECT 'Error: The provided New_Instructor_ID does not exist in the [Instructor] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Transaction
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Step 1: Delete the Old record
        DELETE FROM [dbo].[Instructor_Phone]
        OUTPUT 
            deleted.[Instructor_ID] AS [Old_Instructor_ID],
            deleted.[Phone] AS [Old_Phone]
        WHERE 
            [Instructor_ID] = @Old_Instructor_ID AND [Phone] = @Old_Phone;

        -- Step 2: Insert the New record
        INSERT INTO [dbo].[Instructor_Phone] ([Instructor_ID], [Phone])
        OUTPUT 
            inserted.[Instructor_ID] AS [New_Instructor_ID],
            inserted.[Phone] AS [New_Phone]
        VALUES 
            (@New_Instructor_ID, @New_Phone);

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

/* --------------------------------------------------------------------------------
-- TEST CASES FOR sp_UpdateInstructor_Phone
-------------------------------------------------------------------------------- */
PRINT '--- 3. TESTING sp_UpdateInstructor_Phone ---';
-- ASSUMPTION: Instructor 2 exists in [Instructor].
-- Test 9 (Success): Update record (1, '01001234567') to (1, '01221234567').
EXEC [dbo].[Instructor_Phone_Update] @Old_Instructor_ID = 1, @Old_Phone = '01001234567', @New_Instructor_ID = 1, @New_Phone = '01221234567';
-- Test 10 (Success): Update record (1, '01221234567') to (2, '01221234567').
EXEC [dbo].[Instructor_Phone_Update] @Old_Instructor_ID = 1, @Old_Phone = '01221234567', @New_Instructor_ID = 2, @New_Phone = '01221234567';
-- This is a test 2.
-- Test 11 (Error - Old Not Found):
EXEC [dbo].[Instructor_Phone_Update] @Old_Instructor_ID = 99, @Old_Phone = 'N/A', @New_Instructor_ID = 1, @New_Phone = 'Test';
-- Test 12 (Error - New Exists):
EXEC [dbo].[Instructor_Phone_Update] @Old_Instructor_ID = 2, @Old_Phone = '01221234567', @New_Instructor_ID = 1, @New_Phone = '01001234567'; -- Fails, (1, '01001234567') exists
-- Test 13 (Error - Bad New FK):
EXEC [dbo].[Instructor_Phone_Update] @Old_Instructor_ID = 1, @Old_Phone = '01001234567', @New_Instructor_ID = 99, @New_Phone = 'Test';
GO
--------------------------------------------------------------------------------

-- DELETE
Alter PROCEDURE [dbo].[Instructor_Phone_Delete]
    @Instructor_ID INT = null,
    @Phone NVARCHAR(20) = null
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. CRITICAL: Check for NULLs to prevent accidental mass-delete.
        IF @Instructor_ID IS NULL OR @Phone IS NULL
        BEGIN
            SELECT 'Error: Safe delete requires the full composite key. BOTH Instructor_ID and Phone must be provided. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check if the specific record exists before deleting.
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor_Phone] WHERE [Instructor_ID] = @Instructor_ID AND [Phone] = @Phone)
        BEGIN
            SELECT 'Error: Record not found. No deletion occurred. Please provide a valid Instructor_ID and Phone.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Perform the specific delete.
        DELETE FROM [dbo].[Instructor_Phone]
        OUTPUT 
            deleted.[Instructor_ID] AS [Deleted_Instructor_ID],
            deleted.[Phone] AS [Deleted_Phone]
        WHERE 
            [Instructor_ID] = @Instructor_ID AND [Phone] = @Phone;
        
    END TRY
    BEGIN CATCH
        -- 4. Smart CATCH Block (FK violation on DELETE is very unlikely on this table due to ON DELETE CASCADE)
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this record. It is still referenced by other tables (Foreign Key violation). Please delete the child records first.' AS ErrorMessage;
            RETURN;
        END
        
        SELECT 'An unexpected error occurred in sp_DeleteInstructor_Phone.' AS ErrorMessage;
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