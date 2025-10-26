--------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES FOR 'Instructor' (v4 - Final Template Applied)
-- FK Tables: [Department]
-- CHECK Constraints: Gender, Min Age, Marital Status, Salary, Contract Type
--------------------------------------------------------------------------------

-- CREATE
CREATE PROCEDURE [dbo].[Instructor_Insert]
    @Instructor_ID INT,
    @Instructor_Fname NVARCHAR(50),
    @Instructor_Lname NVARCHAR(50),
    @Instructor_Gender NVARCHAR(10) = NULL,
    @Instructor_Birthdate DATE = NULL,
    @Instructor_Marital_Status NVARCHAR(50) = NULL,
    @Instructor_Salary INT = NULL,
    @Instructor_Contract_Type NVARCHAR(50) = NULL,
    @Instructor_Email NVARCHAR(150) = NULL,
    @Department_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks (NOT NULL, PK, FK)
    IF @Instructor_ID IS NULL
    BEGIN
        SELECT 'Error: The Primary Key (Instructor_ID) cannot be NULL. Please provide a valid ID.' AS ErrorMessage;
        RETURN;
    END
    
    IF @Instructor_Fname IS NULL OR @Instructor_Lname IS NULL
    BEGIN
        SELECT 'Error: [Instructor_Fname] and [Instructor_Lname] cannot be NULL. Please provide all required values.' AS ErrorMessage;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
    BEGIN
        SELECT 'Error: A record with this Primary Key (Instructor_ID) already exists. Please use a different ID.' AS ErrorMessage;
        RETURN;
    END

    IF @Department_ID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[Department] WHERE [Department_ID] = @Department_ID)
    BEGIN
        SELECT 'Error: The provided Department_ID does not exist in the [Department] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Insert with CATCH block for CHECK constraints
    -- The CATCH block will automatically handle all CHECK violations:
    -- (Gender='Female' OR 'Male'), (MinAge>18), (MinAge>23), (Marital_Status='Single' OR 'Married'), (Salary>=8000), (Contract_Type='Part-Time' OR 'Full-Time')
    BEGIN TRY
        INSERT INTO [dbo].[Instructor] 
            ([Instructor_ID], [Instructor_Fname], [Instructor_Lname], [Instructor_Gender], [Instructor_Birthdate], [Instructor_Marital_Status], [Instructor_Salary], [Instructor_Contract_Type], [Instructor_Email], [Department_ID])
        -- 3. Output inserted data
        OUTPUT 
            inserted.[Instructor_ID] AS [Inserted_Instructor_ID],
            inserted.[Instructor_Fname] AS [Inserted_Instructor_Fname],
            inserted.[Instructor_Lname] AS [Inserted_Instructor_Lname],
            inserted.[Instructor_Gender] AS [Inserted_Instructor_Gender],
            inserted.[Instructor_Birthdate] AS [Inserted_Instructor_Birthdate],
            inserted.[Instructor_Marital_Status] AS [Inserted_Instructor_Marital_Status],
            inserted.[Instructor_Salary] AS [Inserted_Instructor_Salary],
            inserted.[Instructor_Contract_Type] AS [Inserted_Instructor_Contract_Type],
            inserted.[Instructor_Email] AS [Inserted_Instructor_Email],
            inserted.[Department_ID] AS [Inserted_Department_ID]
        VALUES 
            (@Instructor_ID, @Instructor_Fname, @Instructor_Lname, @Instructor_Gender, @Instructor_Birthdate, @Instructor_Marital_Status, @Instructor_Salary, @Instructor_Contract_Type, @Instructor_Email, @Department_ID);
    END TRY
    BEGIN CATCH
        -- 4. Smart CATCH Block
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        IF @ErrorNum = 547 IF @ErrorMsg LIKE '%FOREIGN KEY%' SELECT 'Error: A Foreign Key violation occurred. A value you provided (like an ID) does not exist in the parent table. Please check your IDs and try again.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details]; ELSE IF @ErrorMsg LIKE '%CHECK constraint%' SELECT 'Error: A CHECK constraint violation occurred. A value you provided is invalid (e.g., Salary < 8000, Gender not ''Male''/''Female'', or invalid Birthdate).' AS ErrorMessage, @ErrorMsg AS [Constraint_Details]; ELSE SELECT 'Error 547: ' + @ErrorMsg AS ErrorMessage;
        ELSE IF @ErrorNum = 515 SELECT 'Error: A NOT NULL violation occurred. You must provide a value for a required column.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum IN (2627, 2601) SELECT 'Error: A Unique Key or Primary Key violation occurred. The value you are trying to insert already exists.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum = 245 SELECT 'Error: A datatype conversion failed. Check that you are not putting text in a number field or an invalid date format.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE THROW;
    END CATCH
END
GO

/* --------------------------------------------------------------------------------
-- TEST CASES FOR sp_InsertInstructor
-------------------------------------------------------------------------------- */
PRINT '--- 1. TESTING sp_InsertInstructor ---';
-- ASSUMPTION: Department_ID 10 exists.
-- Test 1 (Success):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = 200, @Instructor_Fname = 'Amr', @Instructor_Lname = 'Diab', @Instructor_Gender = 'Male', @Instructor_Birthdate = '1980-01-01', @Instructor_Marital_Status = 'Married', @Instructor_Salary = 10000, @Instructor_Contract_Type = 'Full-Time', @Instructor_Email = 'amr@iti.com', @Department_ID = 7;
-- Test 2 (Error - PK NULL):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = NULL, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test';
-- Test 3 (Error - PK Exists):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = 1, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test';
-- Test 4 (Error - Bad FK):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = 200, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Department_ID = 99;
-- Test 5 (Error - NOT NULL):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = 2, @Instructor_Fname = NULL, @Instructor_Lname = 'Test';
-- Test 6 (Error - CHECK Constraint Salary):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = 2, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Salary = 5000;
-- Test 7 (Error - CHECK Constraint Gender):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = 2, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Gender = 'Other';
-- Test 8 (Error - CHECK Constraint Age):
EXEC [dbo].[Instructor_Insert] @Instructor_ID = 2, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Birthdate = '2010-01-01';
GO
--------------------------------------------------------------------------------


-- READ (Consolidated Select)
CREATE PROCEDURE [dbo].[Instructor_Select]
    @Instructor_ID INT = NULL,
    @Department_ID INT = NULL,
    @Instructor_Email NVARCHAR(150) = NULL
AS
BEGIN
    -- Selects records based on provided parameters:
    -- 1. Instructor_ID: Selects by Primary Key.
    -- 2. Instructor_Email: Selects by Email.
    -- 3. Department_ID: Selects all instructors in that department.
    -- 4. NULL: Selects all records.
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Instructor_ID IS NOT NULL
        BEGIN
            -- 1. Select by Primary Key
            SELECT * FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID;
        END
        ELSE IF @Instructor_Email IS NOT NULL
        BEGIN
            -- 2. Select by Email
            SELECT * FROM [dbo].[Instructor] WHERE [Instructor_Email] = @Instructor_Email;
        END
        ELSE IF @Department_ID IS NOT NULL
        BEGIN
            -- 3. Select by Department
            SELECT * FROM [dbo].[Instructor] WHERE [Department_ID] = @Department_ID;
        END
        ELSE
        BEGIN
            -- 4. Select All
            SELECT * FROM [dbo].[Instructor];
        END
    END TRY
    BEGIN CATCH
        SELECT 'An unexpected error occurred in Instructor_Select.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Select (Consolidated)
--------------------------------------------------------------------------------
PRINT '--- 2. TESTING Instructor_Select ---';

-- Test 8 (PK): Find instructor 201.
PRINT 'Test 8 (Select - Finding 201)...';
EXEC [dbo].[Instructor_Select] @Instructor_ID = 201;
-- Expected: 1 row.

-- Test 9 (By Dept_ID): Find all for Dept 10.
PRINT 'Test 9 (Select - By Dept 10)...';
EXEC [dbo].[Instructor_Select] @Department_ID = 1;
-- Expected: 1 row.

-- Test 10 (By Email): Find by email.
PRINT 'Test 10 (Select - By Email)...';
EXEC [dbo].[Instructor_Select] @Instructor_Email = 'amr.diab@iti.gov.eg';
-- Expected: 1 row.

-- Test 11 (All): Select all instructors.
PRINT 'Test 11 (Select - All rows)...';
EXEC [dbo].[Instructor_Select];
-- Expected: 1 row.
GO
--------------------------------------------------------------------------------
*/

-- UPDATE (Standard)
CREATE PROCEDURE [dbo].[Instructor_Update]
    @Instructor_ID INT,
    @Instructor_Fname NVARCHAR(50),
    @Instructor_Lname NVARCHAR(50),
    @Instructor_Gender NVARCHAR(10) = NULL,
    @Instructor_Birthdate DATE = NULL,
    @Instructor_Marital_Status NVARCHAR(50) = NULL,
    @Instructor_Salary INT = NULL,
    @Instructor_Contract_Type NVARCHAR(50) = NULL,
    @Instructor_Email NVARCHAR(150) = NULL,
    @Department_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Pre-Checks (PK exists, NOT NULL, FK)
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
    BEGIN
        SELECT 'Error: Record ID not found. No update occurred. Please provide a valid Instructor_ID.' AS ErrorMessage;
        RETURN;
    END

    IF @Instructor_Fname IS NULL OR @Instructor_Lname IS NULL
    BEGIN
        SELECT 'Error: [Instructor_Fname] and [Instructor_Lname] cannot be NULL. Please provide all required values.' AS ErrorMessage;
        RETURN;
    END
    
    IF @Department_ID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[Department] WHERE [Department_ID] = @Department_ID)
    BEGIN
        SELECT 'Error: The provided Department_ID does not exist in the [Department] table. Please use a valid ID.' AS ErrorMessage;
        RETURN;
    END

    -- 2. Perform Update
    BEGIN TRY
        UPDATE [dbo].[Instructor]
        SET 
            [Instructor_Fname] = @Instructor_Fname,
            [Instructor_Lname] = @Instructor_Lname,
            [Instructor_Gender] = @Instructor_Gender,
            [Instructor_Birthdate] = @Instructor_Birthdate,
            [Instructor_Marital_Status] = @Instructor_Marital_Status,
            [Instructor_Salary] = @Instructor_Salary,
            [Instructor_Contract_Type] = @Instructor_Contract_Type,
            [Instructor_Email] = @Instructor_Email,
            [Department_ID] = @Department_ID
        -- 3. Output Old and New records
        OUTPUT 
            deleted.[Instructor_ID] AS [Old_Instructor_ID],
            inserted.[Instructor_ID] AS [New_Instructor_ID],
            deleted.[Instructor_Fname] AS [Old_Instructor_Fname],
            inserted.[Instructor_Fname] AS [New_Instructor_Fname],
            deleted.[Instructor_Lname] AS [Old_Instructor_Lname],
            inserted.[Instructor_Lname] AS [New_Instructor_Lname],
            deleted.[Instructor_Gender] AS [Old_Instructor_Gender],
            inserted.[Instructor_Gender] AS [New_Instructor_Gender],
            deleted.[Instructor_Birthdate] AS [Old_Instructor_Birthdate],
            inserted.[Instructor_Birthdate] AS [New_Instructor_Birthdate],
            deleted.[Instructor_Marital_Status] AS [Old_Instructor_Marital_Status],
            inserted.[Instructor_Marital_Status] AS [New_Instructor_Marital_Status],
            deleted.[Instructor_Salary] AS [Old_Instructor_Salary],
            inserted.[Instructor_Salary] AS [New_Instructor_Salary],
            deleted.[Instructor_Contract_Type] AS [Old_Instructor_Contract_Type],
            inserted.[Instructor_Contract_Type] AS [New_Instructor_Contract_Type],
            deleted.[Instructor_Email] AS [Old_Instructor_Email],
            inserted.[Instructor_Email] AS [New_Instructor_Email],
            deleted.[Department_ID] AS [Old_Department_ID],
            inserted.[Department_ID] AS [New_Department_ID]
        WHERE 
            [Instructor_ID] = @Instructor_ID;
    END TRY
    BEGIN CATCH
        -- 4. Smart CATCH Block (Same as Insert)
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        IF @ErrorNum = 547 IF @ErrorMsg LIKE '%FOREIGN KEY%' SELECT 'Error: A Foreign Key violation occurred. A value you provided (like an ID) does not exist in the parent table. Please check your IDs and try again.' AS ErrorMessage; ELSE IF @ErrorMsg LIKE '%CHECK constraint%' SELECT 'Error: A CHECK constraint violation occurred. A value you provided is invalid (e.g., Salary < 8000, Gender not ''Male''/''Female'', or invalid Birthdate).' AS ErrorMessage, @ErrorMsg AS [Constraint_Details]; ELSE SELECT 'Error 547: ' + @ErrorMsg AS ErrorMessage;
        ELSE IF @ErrorNum = 515 SELECT 'Error: A NOT NULL violation occurred. You must provide a value for a required column.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum IN (2627, 2601) SELECT 'Error: A Unique Key or PrimaryKey violation occurred. The value you are trying to insert already exists.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE IF @ErrorNum = 245 SELECT 'Error: A datatype conversion failed. Check that you are not putting text in a number field or an invalid date format.' AS ErrorMessage, @ErrorMsg AS [Constraint_Details];
        ELSE THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR sp_UpdateInstructor
--------------------------------------------------------------------------------
PRINT '--- 3. TESTING sp_UpdateInstructor ---';
-- ASSUMPTION: Department_ID 11 exists.
-- Test 11 (Success): Update record 1.
EXEC [dbo].[Instructor_Update] @Instructor_ID = 1, @Instructor_Fname = 'Amr', @Instructor_Lname = 'Diab', @Instructor_Salary = 12000, @Department_ID = 6;
-- Test 12 (Error - Not Found):
EXEC [dbo].[Instructor_Update] @Instructor_ID = 201, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test';
-- Test 13 (Error - Bad FK):
EXEC [dbo].[Instructor_Update] @Instructor_ID = 1, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Department_ID = 99;
-- Test 14 (Error - CHECK Constraint Salary):
EXEC [dbo].[Instructor_Update] @Instructor_ID = 1, @Instructor_Fname = 'Test', @Instructor_Lname = 'Test', @Instructor_Salary = 5000;
GO
--------------------------------------------------------------------------------


-- DELETE
Create PROCEDURE [dbo].[Instructor_Delete]
    @Instructor_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Instructor_ID IS NULL 
        BEGIN
            SELECT 'Error: Cannot delete the Instructor Table. They are still referenced by other tables (e.g., Instructor_Course, Instructor_Phone). Please delete or re-assign the records in those tables first.' AS ErrorMessage;
            RETURN;
        END
        IF @Instructor_ID IS NOT NULL
        BEGIN
            -- 1. Delete by Primary Key
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Instructor] WHERE [Instructor_ID] = @Instructor_ID)
            BEGIN
                SELECT 'Error: Record ID not found. No deletion occurred. Please provide a valid Instructor_ID.' AS ErrorMessage;
                RETURN;
            END

            DELETE FROM [dbo].[Instructor]
            -- 3. Output deleted data
            OUTPUT 
                deleted.[Instructor_ID] AS [Deleted_Instructor_ID],
                deleted.[Instructor_Fname] AS [Deleted_Instructor_Fname],
                deleted.[Instructor_Lname] AS [Deleted_Instructor_Lname],
                deleted.[Instructor_Salary] AS [Deleted_Instructor_Salary],
                deleted.[Instructor_Email] AS [Deleted_Instructor_Email],
                deleted.[Department_ID] AS [Deleted_Department_ID]
            WHERE 
                [Instructor_ID] = @Instructor_ID;
        END
        ELSE
        BEGIN
            -- 2. Delete All Records (ID is NULL)
            PRINT 'Warning: Deleting all records from [Instructor]. This action cannot be undone.'
            BEGIN TRANSACTION;
            
            -- Check for FK constraints before truncating
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID('dbo.Instructor'))
            BEGIN
                -- Cannot TRUNCATE, must DELETE.
                DELETE FROM [dbo].[Instructor];
            END
            ELSE
            BEGIN
                -- Safe to TRUNCATE for performance
                TRUNCATE TABLE [dbo].[Instructor];
            END
            
            COMMIT TRANSACTION;
            SELECT 'Success: All records have been deleted from [Instructor].' AS SuccessMessage;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- 4. Smart CATCH Block
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT 'Error: Cannot delete this instructor. They are still referenced by other tables (e.g., Instructor_Course, Instructor_Phone). Please delete or re-assign the records in those tables first.' AS ErrorMessage;
            RETURN;
        END
        
        SELECT 'An unexpected error occurred in sp_DeleteInstructor.' AS ErrorMessage;
        THROW;
    END CATCH
END
GO

--------------------------------------------------------------------------------
-- TEST CASES FOR Instructor_Delete
--------------------------------------------------------------------------------
PRINT '--- 4. TESTING Instructor_Delete ---';
-- Test 15 (Success): Delete record 1.
EXEC [dbo].[Instructor_Delete] @Instructor_ID = 1;
-- Test 16 (Error - Not Found):
EXEC [dbo].[Instructor_Delete] @Instructor_ID = 99;
-- Test 17 (Delete All):
EXEC [dbo].[Instructor_Delete];
GO
--------------------------------------------------------------------------------