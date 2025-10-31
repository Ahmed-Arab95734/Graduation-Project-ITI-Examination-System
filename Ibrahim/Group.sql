
--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Group' (v4 - Final Template Applied)
-- FK Tables: [Intake], [Branch], [Track]
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Group_Insert]
    @Group_ID INT,
    @Intake_ID INT,
    @Branch_ID INT,
    @Track_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks (NOT NULL, PK, FK)
    IF @Group_ID IS NULL
    BEGIN
        SELECT 'Error: The Primary Key (Group_ID) cannot be NULL. Please provide a valid ID.' AS ErrorMessage;
        RETURN;
    END
    
    IF @Intake_ID IS NULL OR @Branch_ID IS NULL OR @Track_ID IS NULL
    BEGIN
        SELECT 'Error: [Intake_ID], [Branch_ID], and [Track_ID] cannot be NULL. Please provide all required values.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Group] WHERE [Group_ID] = @Group_ID)
    BEGIN
        SELECT 'Error: A record with this Primary Key (Group_ID) already exists. Please use a different ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Intake] WHERE [Intake_ID] = @Intake_ID)
    BEGIN
        SELECT 'Error: The provided Intake_ID does not exist in the [Intake] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Branch] WHERE [Branch_ID] = @Branch_ID)
    BEGIN
        SELECT 'Error: The provided Branch_ID does not exist in the [Branch] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Track] WHERE [Track_ID] = @Track_ID)
    BEGIN
        SELECT 'Error: The provided Track_ID does not exist in the [Track] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Insert with CATCH block for CHECK constraints
    BEGIN TRY
        INSERT INTO [dbo].[Group] 
            ([Group_ID], [Intake_ID], [Branch_ID], [Track_ID])
        -- 3. Output inserted data
        OUTPUT 
            inserted.[Group_ID] AS [Inserted_Group_ID],
            inserted.[Intake_ID] AS [Inserted_Intake_ID],
            inserted.[Branch_ID] AS [Inserted_Branch_ID],
            inserted.[Track_ID] AS [Inserted_Track_ID]
        VALUES 
            (@Group_ID, @Intake_ID, @Branch_ID, @Track_ID);
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
-- TEST CASES FOR Group_Insert
--------------------------------------------------------------------------------
-- ASSUMPTIONS:
-- 1. You have an [Intake] table with at least Intake_ID = 45.
-- 2. You have a [Branch] table with at least Branch_ID = 1 (e.g., 'Smart Village').
-- 3. You have a [Track] table with at least Track_ID = 101 (e.g., 'Full Stack').
--------------------------------------------------------------------------------

PRINT '--- 1. TESTING Group_Insert ---';

-- ASSUMPTION: Intake 1, Branch 2, Track 3 all exist.
-- Test 1 (Success):
EXEC [dbo].[Group_Insert] @Group_ID = 10001, @Intake_ID = 1, @Branch_ID = 2, @Track_ID = 3;
-- Test 2 (Error - PK NULL):
EXEC [dbo].[Group_Insert] @Group_ID = NULL, @Intake_ID = 1, @Branch_ID = 2, @Track_ID = 3;
-- Test 3 (Error - PK Exists):
EXEC [dbo].[Group_Insert] @Group_ID = 1, @Intake_ID = 1, @Branch_ID = 2, @Track_ID = 3;
-- Test 4 (Error - Bad FK):
EXEC [dbo].[Group_Insert] @Group_ID = 10001, @Intake_ID = 99, @Branch_ID = 2, @Track_ID = 3;
-- Test 5 (Error - NOT NULL):
EXEC [dbo].[Group_Insert] @Group_ID = 2, @Intake_ID = 1, @Branch_ID = NULL, @Track_ID = 3;
GO
--------------------------------------------------------------------------------


-- READ (Consolidated Select)
CREATE PROCEDURE [dbo].[Group_Select]
    @Group_ID INT = NULL,
    @Intake_ID INT = NULL,
    @Branch_ID INT = NULL,
    @Track_ID INT = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Group_ID: Selects by Primary Key.
    -- 2. Intake_ID, Branch_ID, Track_ID: Selects by specific combination or parts.
    -- 3. NULL: Selects all records.
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Group_ID IS NOT NULL
        BEGIN
            -- 1. Select by Primary Key
            SELECT * FROM [dbo].[Group] WHERE [Group_ID] = @Group_ID;
        END
        ELSE IF @Intake_ID IS NOT NULL OR @Branch_ID IS NOT NULL OR @Track_ID IS NOT NULL
        BEGIN
            -- 2. Select by one or more Foreign Keys
            SELECT * FROM [dbo].[Group]
            WHERE (@Intake_ID IS NULL OR [Intake_ID] = @Intake_ID)
              AND (@Branch_ID IS NULL OR [Branch_ID] = @Branch_ID)
              AND (@Track_ID IS NULL OR [Track_ID] = @Track_ID);
        END
        ELSE
        BEGIN
            -- 3. Select All
            SELECT * FROM [dbo].[Group];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Group_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Group_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Group_Select ---';

-- Test 5 (PK): Find group 501.
PRINT 'Test 5 (Select - Finding Group 501)...';
EXEC [dbo].[Group_Select] @Group_ID = 501;
-- Expected: 1 row.

-- Test 6 (By Intake_ID): Find all for Intake 45.
PRINT 'Test 6 (Select - By Intake_ID 45)...';
EXEC [dbo].[Group_Select] @Intake_ID = 45;
-- Expected: 1 row.

-- Test 7 (By Combo): Find by Intake 45 and Branch 1.
PRINT 'Test 7 (Select - By Intake 45 and Branch 1)...';
EXEC [dbo].[Group_Select] @Intake_ID = 4, @Branch_ID = 1;
-- Expected: 1 row.

-- Test 8 (All): Select all groups.
PRINT 'Test 8 (Select - All rows)...';
EXEC [dbo].[Group_Select];
-- Expected: 1 row.
GO
--------------------------------------------------------------------------------


-- UPDATE (Standard)
/*
-- NOTE: This procedure uses a standard UPDATE, not the DELETE+INSERT pattern.
-- This is because [Group_ID] is a surrogate (non-data) key.
-- We are not "updating the key" (like in Failed_Students); we are just
-- updating the data columns associated with that key.
*/

CREATE PROCEDURE [dbo].[Group_Update]
 @Group_ID INT,
    @Intake_ID INT,
    @Branch_ID INT,
    @Track_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks (PK exists, NOT NULL, FK)
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Group] WHERE [Group_ID] = @Group_ID)
    BEGIN
        SELECT 'Error: Record ID not found. No update occurred. Please provide a valid Group_ID.' AS ErrorMessage;
        RETURN;
    END

    IF @Intake_ID IS NULL OR @Branch_ID IS NULL OR @Track_ID IS NULL
    BEGIN
        SELECT 'Error: [Intake_ID], [Branch_ID], and [Track_ID] cannot be NULL. Please provide all required values.' AS ErrorMessage;
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Intake] WHERE [Intake_ID] = @Intake_ID)
    BEGIN
        SELECT 'Error: The provided Intake_ID does not exist in the [Intake] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Branch] WHERE [Branch_ID] = @Branch_ID)
    BEGIN
        SELECT 'Error: The provided Branch_ID does not exist in the [Branch] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Track] WHERE [Track_ID] = @Track_ID)
    BEGIN
        SELECT 'Error: The provided Track_ID does not exist in the [Track] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Update
    BEGIN TRY
        UPDATE [dbo].[Group]
        SET 
            [Intake_ID] = @Intake_ID,
            [Branch_ID] = @Branch_ID,
            [Track_ID] = @Track_ID
        -- 3. Output Old and New records
        OUTPUT 
            deleted.[Group_ID] AS [Old_Group_ID],
            inserted.[Group_ID] AS [New_Group_ID],
            deleted.[Intake_ID] AS [Old_Intake_ID],
            inserted.[Intake_ID] AS [New_Intake_ID],
            deleted.[Branch_ID] AS [Old_Branch_ID],
            inserted.[Branch_ID] AS [New_Branch_ID],
            deleted.[Track_ID] AS [Old_Track_ID],
            inserted.[Track_ID] AS [New_Track_ID]
        WHERE 
            [Group_ID] = @Group_ID;
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
-- TEST CASES FOR Group_Update
--------------------------------------------------------------------------------
-- ASSUMPTION: We have a Track_ID = 102 (e.g., 'Data Science').
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING Group_Update ---';

-- Test 9 (Success): Update the Track for Group 501.
-- ASSUMPTION: Intake 4, Branch 5, Track 6 all exist.
-- Test 8 (Success): Update record 1.
EXEC [dbo].[Group_Update] @Group_ID = 1, @Intake_ID = 4, @Branch_ID = 5, @Track_ID = 6;
-- Test 9 (Error - Not Found):
EXEC [dbo].[Group_Update] @Group_ID = 99, @Intake_ID = 1, @Branch_ID = 2, @Track_ID = 3;
-- Test 10 (Error - Bad FK):
EXEC [dbo].[Group_Update] @Group_ID = 1, @Intake_ID = 99, @Branch_ID = 2, @Track_ID = 3;
GO
--------------------------------------------------------------------------------

-- DELETE
CREATE OR ALTER PROCEDURE [dbo].[Group_Delete]
    @Group_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Group_ID IS NOT NULL -- User wants to delete a specific group
        BEGIN
            -- Check if the specific record exists before attempting deletion
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Group] WHERE [Group_ID] = @Group_ID)
            BEGIN
                SELECT 'Error: Group ID ' + CAST(@Group_ID AS NVARCHAR(10)) + ' not found. No deletion occurred.' AS ErrorMessage;
                RETURN;
            END

            -- Perform the specific delete. ON DELETE CASCADE will handle child records in [Student].
            DELETE FROM [dbo].[Group]
            OUTPUT
                deleted.[Group_ID] AS [Deleted_Group_ID],
                deleted.[Intake_ID] AS [Deleted_Intake_ID],
                deleted.[Branch_ID] AS [Deleted_Branch_ID],
                deleted.[Track_ID] AS [Deleted_Track_ID]
            WHERE
                [Group_ID] = @Group_ID;

            SELECT 'Success: Group ID ' + CAST(@Group_ID AS NVARCHAR(10)) + ' and associated students deleted.' AS SuccessMessage;
        END
        ELSE -- @Group_ID IS NULL, user wants to delete all records (with a warning)
        BEGIN
            PRINT 'Warning: Attempting to delete ALL records from [Group] table. This action cannot be undone and will delete associated student data due to CASCADE DELETE.';

            -- Given that [Group] is referenced by [Student] (ON DELETE CASCADE),
            -- TRUNCATE is not possible. Must use DELETE.
            DELETE FROM [dbo].[Group];
            
            SELECT 'Success: All records have been deleted from [Group].' AS SuccessMessage;
        END
    END TRY
    BEGIN CATCH
        -- In case of any unhandled errors, especially Foreign Key violations (if CASCADE wasn't set or there's a different constraint)
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();

        IF @ErrorNum = 547 -- Foreign Key constraint violation
        BEGIN
            -- This catch block is less likely to be hit with ON DELETE CASCADE but good to have
            SELECT 'Error: A Foreign Key constraint prevented deletion. This group might be referenced by other tables in a way not covered by ON DELETE CASCADE, or an unexpected data integrity issue occurred.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        END
        ELSE
        BEGIN
            SELECT 'An unexpected error occurred in [dbo].[Group_Delete]. Error ' + CAST(@ErrorNum AS NVARCHAR(10)) + ': ' + @ErrorMsg AS ErrorMessage;
        END
    END CATCH
END;
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR sp_DeleteGroup
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING sp_DeleteGroup ---';
-- Test 11 (Success): Delete record 1.
EXEC [dbo].[Group_Delete] @Group_ID = 1;
-- Test 12 (Error - Not Found):
EXEC [dbo].[Group_Delete] @Group_ID = 99;
-- Test 13 (Delete All):
EXEC [dbo].[Group_Delete];
GO
--------------------------------------------------------------------------------

