CREATE PROCEDURE sp_GetIntakes
    @IntakeID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @IntakeID IS NULL
        BEGIN
            -- Return all intakes
            SELECT [Intake_ID]
                  ,[Intake_Name]
                  ,[Intake_Type]
                  ,[Intake_Start_Date]
                  ,[Intake_End_Date]
            FROM [ITIExaminationSystem].[dbo].[Intake]
            ORDER BY [Intake_Start_Date] DESC;
        END
        ELSE
        BEGIN
            -- Check if the specific intake exists
            IF NOT EXISTS (SELECT 1 FROM [ITIExaminationSystem].[dbo].[Intake] WHERE [Intake_ID] = @IntakeID)
            BEGIN
                RAISERROR('Intake with ID %d was not found.', 16, 1, @IntakeID);
                RETURN -1;
            END
            
            -- Return the specific intake
            SELECT [Intake_ID]
                  ,[Intake_Name]
                  ,[Intake_Type]
                  ,[Intake_Start_Date]
                  ,[Intake_End_Date]
            FROM [ITIExaminationSystem].[dbo].[Intake]
            WHERE [Intake_ID] = @IntakeID;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END
GO
------------------------------------------------------
CREATE PROCEDURE sp_InsertIntake
    @IntakeName NVARCHAR(100),
    @IntakeType NVARCHAR(50),
    @IntakeStartDate DATE,
    @IntakeEndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Input validation
        IF NULLIF(@IntakeName, '') IS NULL
        BEGIN
            RAISERROR('Intake name cannot be empty or NULL.', 16, 1);
            RETURN -1;
        END
        
        IF @IntakeStartDate IS NULL
        BEGIN
            RAISERROR('Start date is required.', 16, 1);
            RETURN -1;
        END
        
        IF @IntakeEndDate IS NULL
        BEGIN
            RAISERROR('End date is required.', 16, 1);
            RETURN -1;
        END
        
        IF @IntakeEndDate < @IntakeStartDate
        BEGIN
            RAISERROR('End date cannot be before start date.', 16, 1);
            RETURN -1;
        END
        
        BEGIN TRANSACTION;
        
        INSERT INTO [ITIExaminationSystem].[dbo].[Intake] (
            [Intake_Name],
            [Intake_Type],
            [Intake_Start_Date],
            [Intake_End_Date]
        )
        VALUES (
            @IntakeName,
            @IntakeType,
            @IntakeStartDate,
            @IntakeEndDate
        );
        
        DECLARE @NewIntakeID INT = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
        
        -- Return success with new ID
        SELECT 
            @NewIntakeID AS NewIntakeID,
            0 AS ErrorCode,
            'Intake created successfully' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        
        -- Handle specific SQL Server errors
        IF @ErrorNum = 2627 -- Unique constraint violation
        BEGIN
            RAISERROR('An intake with this name already exists.', 16, 1);
        END
        ELSE IF @ErrorNum = 515 -- Cannot insert NULL
        BEGIN
            RAISERROR('Required fields cannot be NULL.', 16, 1);
        END
        ELSE
        BEGIN
            RAISERROR(@ErrorMsg, 16, 1);
        END
        
        RETURN -1;
    END CATCH
    
    RETURN 0;
END
GO
-------------------------------------------------------
CREATE PROCEDURE sp_UpdateIntake
    @IntakeID INT,
    @IntakeName NVARCHAR(100) = NULL,
    @IntakeType NVARCHAR(50) = NULL,
    @IntakeStartDate DATE = NULL,
    @IntakeEndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if intake exists
        IF NOT EXISTS (SELECT 1 FROM [ITIExaminationSystem].[dbo].[Intake] WHERE [Intake_ID] = @IntakeID)
        BEGIN
            RAISERROR('Intake with ID %d does not exist.', 16, 1, @IntakeID);
            RETURN -1;
        END
        
        -- Validate date logic if both dates are provided
        IF @IntakeStartDate IS NOT NULL AND @IntakeEndDate IS NOT NULL 
           AND @IntakeEndDate < @IntakeStartDate
        BEGIN
            RAISERROR('End date cannot be before start date.', 16, 1);
            RETURN -1;
        END
        
        -- Validate IntakeName if provided
        IF @IntakeName IS NOT NULL AND NULLIF(@IntakeName, '') IS NULL
        BEGIN
            RAISERROR('Intake name cannot be empty.', 16, 1);
            RETURN -1;
        END
        
        BEGIN TRANSACTION;
        
        UPDATE [ITIExaminationSystem].[dbo].[Intake]
        SET 
            [Intake_Name] = ISNULL(@IntakeName, [Intake_Name]),
            [Intake_Type] = ISNULL(@IntakeType, [Intake_Type]),
            [Intake_Start_Date] = ISNULL(@IntakeStartDate, [Intake_Start_Date]),
            [Intake_End_Date] = ISNULL(@IntakeEndDate, [Intake_End_Date])
        WHERE [Intake_ID] = @IntakeID;
        
        DECLARE @RowsAffected INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        -- Return result
        SELECT 
            @RowsAffected AS RowsAffected,
            0 AS ErrorCode,
            'Intake updated successfully' AS Message;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        
        -- Handle specific SQL Server errors
        IF @ErrorNum = 547 -- Foreign key constraint violation
        BEGIN
            -- Check which table is causing the constraint violation
            DECLARE @ConstraintInfo NVARCHAR(1000);
            
            -- You can check specific tables that might reference Intake_ID
            IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID('Intake') AND name = ERROR_MESSAGE())
            BEGIN
                SET @ConstraintInfo = 'Intake is referenced in other tables. Update failed to maintain referential integrity.';
            END
            ELSE
            BEGIN
                SET @ConstraintInfo = 'Operation would violate referential integrity constraints.';
            END
            
            RAISERROR('Foreign key constraint violation: %s', 16, 1, @ConstraintInfo);
        END
        ELSE IF @ErrorNum = 2627 -- Unique constraint violation
        BEGIN
            RAISERROR('An intake with this name already exists.', 16, 1);
        END
        ELSE
        BEGIN
            RAISERROR(@ErrorMsg, 16, 1);
        END
        
        RETURN -1;
    END CATCH
    
    RETURN 0;
END
GO
--------------------------------------------------
