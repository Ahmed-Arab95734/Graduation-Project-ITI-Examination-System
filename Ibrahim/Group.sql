
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
    -- Creates a new group, linking an Intake, Branch, and Track.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check Primary Key (Uniqueness)
        IF EXISTS (SELECT 1 FROM [dbo].[Group] WHERE [Group_ID] = @Group_ID)
        BEGIN
            SELECT 'Error: Group_ID already exists.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Intake)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Intake] WHERE [Intake_ID] = @Intake_ID)
        BEGIN
            SELECT 'Error: Intake_ID does not exist in the Intake table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Check Foreign Key (Branch)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Branch] WHERE [Branch_ID] = @Branch_ID)
        BEGIN
            SELECT 'Error: Branch_ID does not exist in the Branch table.' AS ErrorMessage;
            RETURN;
        END

        -- 4. Check Foreign Key (Track)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Track] WHERE [Track_ID] = @Track_ID)
        BEGIN
            SELECT 'Error: Track_ID does not exist in the Track table.' AS ErrorMessage;
            RETURN;
        END

        -- 5. Check Uniqueness (Combination of FKs) - Assuming this should be unique
        IF EXISTS (SELECT 1 FROM [dbo].[Group] WHERE [Intake_ID] = @Intake_ID AND [Branch_ID] = @Branch_ID AND [Track_ID] = @Track_ID)
        BEGIN
            SELECT 'Error: This combination of Intake, Branch, and Track already exists.' AS ErrorMessage;
            RETURN;
        END

        -- 6. Perform Insert
        INSERT INTO [dbo].[Group]
           ([Group_ID], [Intake_ID], [Branch_ID], [Track_ID])
        VALUES
           (@Group_ID, @Intake_ID, @Branch_ID, @Track_ID);
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Group_Insert.' AS ErrorMessage;
        THROW;
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

-- Test 1 (Success): Add a valid group.
PRINT 'Test 1 (Success - Adding Group 501)...';
EXEC [dbo].[Group_Insert]
    @Group_ID = 501,
    @Intake_ID = 45,
    @Branch_ID = 1,
    @Track_ID = 101;

-- Test 2 (Error - Duplicate PK): Try to add group 501 again.
PRINT 'Test 2 (Error - Duplicate PK)...';
EXEC [dbo].[Group_Insert]
    @Group_ID = 501, @Intake_ID = 45, @Branch_ID = 1, @Track_ID = 101;
-- Expected: 'Error: Group_ID already exists.'

-- Test 3 (Error - Bad FK1): Non-existent Intake.
PRINT 'Test 3 (Error - Bad Intake_ID FK)...';
EXEC [dbo].[Group_Insert]
    @Group_ID = 502, @Intake_ID = 99, @Branch_ID = 1, @Track_ID = 101;
-- Expected: 'Error: Intake_ID does not exist in the Intake table.'

-- Test 4 (Error - Duplicate Combination): Try to add the same combo with a new PK.
PRINT 'Test 4 (Error - Duplicate Combination)...';
EXEC [dbo].[Group_Insert]
    @Group_ID = 503,
    @Intake_ID = 45, -- Same
    @Branch_ID = 1,  -- Same
    @Track_ID = 101; -- Same
-- Expected: 'Error: This combination of Intake, Branch, and Track already exists.'
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
EXEC [dbo].[Group_Select] @Intake_ID = 45, @Branch_ID = 1;
-- Expected: 1 row.

-- Test 8 (All): Select all groups.
PRINT 'Test 8 (Select - All rows)...';
EXEC [dbo].[Group_Select];
-- Expected: 1 row.
GO
--------------------------------------------------------------------------------
*/

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
    -- Updates an existing group's associated Intake, Branch, or Track.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if PK exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Group] WHERE [Group_ID] = @Group_ID)
        BEGIN
            SELECT 'Error: Group_ID not found. No update occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Check Foreign Key (Intake)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Intake] WHERE [Intake_ID] = @Intake_ID)
        BEGIN
            SELECT 'Error: Intake_ID does not exist in the Intake table.' AS ErrorMessage;
            RETURN;
        END

        -- 3. Check Foreign Key (Branch)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Branch] WHERE [Branch_ID] = @Branch_ID)
        BEGIN
            SELECT 'Error: Branch_ID does not exist in the Branch table.' AS ErrorMessage;
            RETURN;
        END

        -- 4. Check Foreign Key (Track)
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Track] WHERE [Track_ID] = @Track_ID)
        BEGIN
            SELECT 'Error: Track_ID does not exist in the Track table.' AS ErrorMessage;
            RETURN;
        END

        -- 5. Check Uniqueness (Combination of FKs) - if changing
        IF EXISTS (SELECT 1 FROM [dbo].[Group] 
                   WHERE [Intake_ID] = @Intake_ID 
                     AND [Branch_ID] = @Branch_ID 
                     AND [Track_ID] = @Track_ID
                     AND [Group_ID] != @Group_ID)
        BEGIN
            SELECT 'Error: This combination of Intake, Branch, and Track already exists for another group.' AS ErrorMessage;
            RETURN;
        END

        -- 6. Perform Update
        UPDATE [dbo].[Group]
        SET 
            [Intake_ID] = @Intake_ID,
            [Branch_ID] = @Branch_ID,
            [Track_ID] = @Track_ID
        WHERE 
            [Group_ID] = @Group_ID;
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Group_Update.' AS ErrorMessage;
        THROW;
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
PRINT 'Test 9 (Update - Success, changing track)...';
EXEC [dbo].[Group_Update]
    @Group_ID = 501,
    @Intake_ID = 1,
    @Branch_ID = 1,
    @Track_ID = 1; 

-- Verify:
EXEC [dbo].[Group_Select] @Group_ID = 501;

-- Test 10 (Error - Not Found): Try to update non-existent group 999.
PRINT 'Test 10 (Update - Error, Group 999 not found)...';
EXEC [dbo].[Group_Update]
    @Group_ID = 999, @Intake_ID = 1, @Branch_ID = 1, @Track_ID = 1;
-- Expected: 'Error: Group_ID not found. No update occurred.'

-- Test 11 (Error - Bad FK): Try to update to a non-existent track.
PRINT 'Test 11 (Update - Error, Track 999 not found)...';
EXEC [dbo].[Group_Update]
    @Group_ID = 1, @Intake_ID = 1, @Branch_ID = 1, @Track_ID = 999;
-- Expected: 'Error: Track_ID does not exist in the Track table.'
GO
--------------------------------------------------------------------------------
*/

-- DELETE
CREATE PROCEDURE [dbo].[Group_Delete]
    @Group_ID INT
AS
BEGIN
    -- Deletes a group by its Primary Key.
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Check if the record exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[Group] WHERE [Group_ID] = @Group_ID)
        BEGIN
            SELECT 'Error: Group_ID not found. No deletion occurred.' AS ErrorMessage;
            RETURN;
        END

        -- 2. Perform Delete
        DELETE FROM [dbo].[Group]
        WHERE [Group_ID] = @Group_ID;
    END TRY
    BEGIN CATCH
        -- Check for specific error 547 (Foreign Key violation)
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete group. It is still referenced by other records (e.g., students in this group).' AS ErrorMessage;
            RETURN; -- Don't THROW, just return the custom message
        END
        
        -- Handle other errors
        SELECT 'An unexpected error occurred in Group_Delete.' AS ErrorMessage;
        THROW; -- Re-throw the original error for debugging
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Group_Delete
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING Group_Delete ---';

-- Test 12 (Success): Delete Group 501.
PRINT 'Test 12 (Delete - Success, removing 501)...';
EXEC [dbo].[Group_Delete] @Group_ID = 501;

-- Test 13 (Error - Not Found): Try to delete non-existent group 999.
PRINT 'Test 13 (Delete - Error, 999 not found)...';
EXEC [dbo].[Group_Delete] @Group_ID = 999;
-- Expected: 'Error: Group_ID not found. No deletion occurred.'

-- Test 14 (Error - Already Deleted): Try to delete 501 again.
PRINT 'Test 14 (Delete - Error, 501 already deleted)...';
EXEC [dbo].[Group_Delete] @Group_ID = 501;
-- Expected: 'Error: Group_ID not found. No deletion occurred.'

-- Test 15 (FK Error - How to test):
/*
-- To test the Foreign Key constraint error (Error 547), you would:
-- 1. Have another table (e.g., [Student_Group]) with a FK to [Group_ID].
-- 2. Insert a student into [Student_Group] with Group_ID = 501.
-- 3. Run: EXEC [dbo].[Group_Delete] @Group_ID = 501;
-- 4. Expected: 'Error: Cannot delete group. It is still referenced by other records (e.g., students in this group).'
*/

PRINT '--- 5. FINAL VERIFICATION ---';
EXEC [dbo].[Group_Select];
-- Expected: 0 rows (assuming Test 12 was successful and Test 15 was not run).
GO
--------------------------------------------------------------------------------

