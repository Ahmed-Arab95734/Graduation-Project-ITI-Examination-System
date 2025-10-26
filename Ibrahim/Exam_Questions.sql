
--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Exam_Questions' (Template: Composite Key V3)
-- FK Tables: [Exam], [Questions_Bank]
--------------------------------------------------------------------------------
-- Rules Implemented:
-- 1. Naming: TableName_Operation (e.g., Exam_Questions_Insert)
-- 2. Select/Delete: By Full PK, By partial FK, or All (if all NULL)
-- 3. Output: OUTPUT clause used for all data modifications.
-- 4. Errors: Detailed IF-checks and a smart CATCH block.
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Exam_Questions_Insert]
    @Exam_ID INT,
    @Question_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks (NOT NULL, PK, FK)
    IF @Exam_ID IS NULL OR @Question_ID IS NULL
    BEGIN
        SELECT 'Error: Both Primary Key parts (Exam_ID, Question_ID) are required and cannot be NULL.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID)
    BEGIN
        SELECT 'Error: This relationship (Exam_ID, Question_ID) already exists. Please use a different combination.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam] WHERE [Exam_ID] = @Exam_ID)
    BEGIN
        SELECT 'Error: The provided Exam_ID does not exist in [Exam] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Questions_Banks] WHERE [Question_ID] = @Question_ID)
    BEGIN
        SELECT 'Error: The provided Question_ID does not exist in [Questions_Bank] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Insert
    BEGIN TRY
        INSERT INTO [dbo].[Exam_Questions] ([Exam_ID], [Question_ID])
        -- 3. Output inserted data
        OUTPUT 
            inserted.[Exam_ID] AS [Inserted_Exam_ID],
            inserted.[Question_ID] AS [Inserted_Question_ID]
        VALUES 
            (@Exam_ID, @Question_ID);
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
-- TEST CASES FOR Exam_Questions_Insert
-------------------------------------------------------------------------------- */
PRINT '--- 1. TESTING Exam_Questions_Insert ---';
-- ASSUMPTION: Exam 101 and Questions 501, 502 exist.
-- Test 1 (Success):
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 101, @Question_ID = 501;
-- Test 2 (Success):
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 101, @Question_ID = 502;
-- Test 3 (Error - PK NULL):
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 101, @Question_ID = NULL;
-- Test 4 (Error - PK Exists):
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 101, @Question_ID = 501;
-- Test 5 (Error - Bad FK1):
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 999, @Question_ID = 501;
-- Test 6 (Error - Bad FK2):
EXEC [dbo].[Exam_Questions_Insert] @Exam_ID = 101, @Question_ID = 999;
GO

----------------------------------------------------------------------------------------------------

-- READ (Consolidated Select)
alter PROCEDURE [dbo].[Exam_Questions_Select]
    @Exam_ID INT = NULL,
    @Question_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @Exam_ID IS NOT NULL AND @Question_ID IS NOT NULL
        BEGIN
            -- 1. Select by Full Primary Key
            SELECT * FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID;
        END
        ELSE IF @Exam_ID IS NOT NULL AND @Question_ID IS NULL
        BEGIN
            -- 2. Select by first part of PK (All questions for one exam)
            SELECT * FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID;
        END
        ELSE IF @Exam_ID IS NULL AND @Question_ID IS NOT NULL
        BEGIN
            -- 3. Select by second part of PK (All exams with one question)
            SELECT * FROM [dbo].[Exam_Questions] WHERE [Question_ID] = @Question_ID;
        END
        ELSE
        BEGIN
            -- 4. Select All (All params are NULL)
            SELECT * FROM [dbo].[Exam_Questions];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Exam_Questions_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

/* --------------------------------------------------------------------------------
-- TEST CASES FOR Exam_Questions_Select
-------------------------------------------------------------------------------- */
PRINT '--- 2. TESTING Exam_Questions_Select ---';
-- Test 7 (By Full PK):
EXEC [dbo].[Exam_Questions_Select] @Exam_ID = 101, @Question_ID = 501;
-- Test 8 (By Partial PK 1):
EXEC [dbo].[Exam_Questions_Select] @Exam_ID = 101;
-- Test 9 (By Partial PK 2):
EXEC [dbo].[Exam_Questions_Select] @Question_ID = 501;
-- Test 10 (All):
EXEC [dbo].[Exam_Questions_Select];
GO

----------------------------------------------------------------------------------------------------------------

-- UPDATE (DELETE + INSERT Pattern)
alter PROCEDURE [dbo].[Exam_Questions_Update]
    @Exam_ID INT,
    @Old_Question_ID INT,
    @New_Question_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks
    IF @Exam_ID IS NULL OR @Old_Question_ID IS NULL OR @New_Question_ID IS NULL
    BEGIN
        SELECT 'Error: All parameters (@Exam_ID, @Old_Question_ID, @New_Question_ID) are required and cannot be NULL.' AS ErrorMessage;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Old_Question_ID)
    BEGIN
        SELECT 'Error: The old record (Exam_ID, Old_Question_ID) does not exist. No update occurred.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @New_Question_ID)
    BEGIN
        SELECT 'Error: The new record (Exam_ID, New_Question_ID) already exists. Cannot create a duplicate.' AS ErrorMessage;
        RETURN;
    END

        IF NOT EXISTS (SELECT 1 FROM [dbo].[Question_Bank] WHERE [Question_ID] = @New_Question_ID)
    BEGIN
        SELECT 'Error: The new Question_ID does not exist in [Questions_Bank]. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Transaction
    BEGIN TRANSACTION;
    BEGIN TRY
        
        -- Step 1: Delete the old record and output it
        DELETE FROM [dbo].[Exam_Questions]
        OUTPUT 
            deleted.[Exam_ID] AS [Old_Exam_ID],
            deleted.[Question_ID] AS [Old_Question_ID]
        WHERE 
            [Exam_ID] = @Exam_ID AND [Question_ID] = @Old_Question_ID;
        
        -- Step 2: Insert the new record and output it
        INSERT INTO [dbo].[Exam_Questions] ([Exam_ID], [Question_ID])
        OUTPUT 
            inserted.[Exam_ID] AS [New_Exam_ID],
            inserted.[Question_ID] AS [New_Question_ID]
        VALUES 
            (@Exam_ID, @New_Question_ID);
        
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
-- TEST CASES FOR Exam_Questions_Update
-------------------------------------------------------------------------------- */
PRINT '--- 3. TESTING Exam_Questions_Update ---';
-- ASSUMPTION: Question 503 exists in [Questions_Bank].
-- Test 11 (Success): Update 502 to 503 for Exam 101.
EXEC [dbo].[Exam_Questions_Update] @Exam_ID = 101, @Old_Question_ID = 502, @New_Question_ID = 503;
-- Test 12 (Error - Old Not Found):
EXEC [dbo].[Exam_Questions_Update] @Exam_ID = 101, @Old_Question_ID = 999, @New_Question_ID = 503;
-- Test 13 (Error - New Already Exists):
EXEC [dbo].[Exam_Questions_Update] @Exam_ID = 101, @Old_Question_ID = 503, @New_Question_ID = 501;
-- Test 14 (Error - New FK invalid):
EXEC [dbo].[Exam_Questions_Update] @Exam_ID = 101, @Old_Question_ID = 503, @New_Question_ID = 999;
GO

------------------------------------------------------------------------------------------------------------------------
-- DELETE
CREATE PROCEDURE [dbo].[Exam_Questions_Delete]
    @Exam_ID INT = NULL,
    @Question_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Exam_ID IS NOT NULL AND @Question_ID IS NOT NULL
        BEGIN
            -- 1. Delete by Full Primary Key
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID)
            BEGIN
                SELECT 'Error: Record not found. No deletion occurred. Please provide valid IDs.' AS ErrorMessage;
                RETURN;
            END

            DELETE FROM [dbo].[Exam_Questions]
            OUTPUT 
                deleted.[Exam_ID] AS [Deleted_Exam_ID],
                deleted.[Question_ID] AS [Deleted_Question_ID]
            WHERE 
                [Exam_ID] = @Exam_ID AND [Question_ID] = @Question_ID;
        END
        ELSE IF @Exam_ID IS NOT NULL AND @Question_ID IS NULL
        BEGIN
            -- 2. Delete by first part of PK (All questions for one exam)
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Exam_ID] = @Exam_ID)
            BEGIN
                SELECT 'Info: No records found for this Exam_ID. No deletion occurred.' AS InfoMessage;
                RETURN;
            END
            
            DELETE FROM [dbo].[Exam_Questions]
            OUTPUT 
                deleted.[Exam_ID] AS [Deleted_Exam_ID],
                deleted.[Question_ID] AS [Deleted_Question_ID]
            WHERE 
                [Exam_ID] = @Exam_ID;
        END
        ELSE IF @Exam_ID IS NULL AND @Question_ID IS NOT NULL
        BEGIN
            -- 3. Delete by second part of PK (All exams with one question)
             IF NOT EXISTS (SELECT 1 FROM [dbo].[Exam_Questions] WHERE [Question_ID] = @Question_ID)
            BEGIN
                SELECT 'Info: No records found for this Question_ID. No deletion occurred.' AS InfoMessage;
                RETURN;
            END

            DELETE FROM [dbo].[Exam_Questions]
            OUTPUT 
                deleted.[Exam_ID] AS [Deleted_Exam_ID],
                deleted.[Question_ID] AS [Deleted_Question_ID]
            WHERE 
                [Question_ID] = @Question_ID;
        END
        ELSE
        BEGIN
            -- 4. Delete All Records (All params are NULL)
            PRINT 'Warning: Deleting all records from [Exam_Questions]. This action cannot be undone.';
            BEGIN TRANSACTION;

            -- Check for FK constraints before truncating
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID('dbo.Exam_Questions'))
            BEGIN
                -- Cannot TRUNCATE, must DELETE.
                DELETE FROM [dbo].[Exam_Questions];
            END
            ELSE
            BEGIN
                -- Safe to TRUNCATE for performance
                TRUNCATE TABLE [dbo].[Exam_Questions];
            END

            COMMIT TRANSACTION;
            SELECT 'Success: All records have been deleted from [Exam_Questions].' AS SuccessMessage;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- 4. Smart CATCH Block
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete. The record(s) are still referenced by other tables (Foreign Key violation). Please delete the child records first.' AS ErrorMessage;
            RETURN;
        END
        
        SELECT 'An unexpected error occurred in Exam_Questions_Delete.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Exam_Questions_Delete
-------------------------------------------------------------------------------- */
PRINT '--- 4. TESTING Exam_Questions_Delete ---';
-- Test 15 (Success - By Full PK):
EXEC [dbo].[Exam_Questions_Delete] @Exam_ID = 101, @Question_ID = 501;
-- Test 16 (Error - Not Found):
EXEC [dbo].[Exam_Questions_Delete] @Exam_ID = 101, @Question_ID = 99;
-- Test 17 (Delete by Partial PK 1):
EXEC [dbo].[Exam_Questions_Delete] @Exam_ID = 101;
-- Test 18 (Delete All):
EXEC [dbo].[Exam_Questions_Delete];
GO

