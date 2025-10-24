/* This procedure will:

Create a new record in the Exam table.

Randomly select the specified number of MCQ and True/False questions from the Question_Bank for the given course.

Insert those questions into the Exam_Questions link table.

Wrap the entire operation in a transaction to ensure it either completes fully or not at all.

Check to make sure enough questions exist before attempting to create the exam.
*/ 
CREATE PROCEDURE sp_GenerateExam
    -- Input Parameters for the procedure
    @CourseID INT,
    @InstructorID INT,
    @NumMCQ INT = 7,         -- Default number of Multiple-Choice questions
    @NumTF INT = 3,          -- Default number of True/False questions
    @ExamDuration INT = 60,  -- Default duration in minutes
    @ExamType NVARCHAR(50) = N'Normal' -- Default exam type
AS
BEGIN
    -- This prevents the "xx rows affected" message from being returned
    SET NOCOUNT ON;

    -- ===================================================================
    -- 1. VALIDATION: Check if enough questions exist in the bank
    -- ===================================================================
    DECLARE @AvailableMCQ INT;
    DECLARE @AvailableTF INT;

    SELECT @AvailableMCQ = COUNT(Question_ID)
    FROM Question_Bank
    WHERE Course_ID = @CourseID AND Question_Type = N'MCQ';

    SELECT @AvailableTF = COUNT(Question_ID)
    FROM Question_Bank
    WHERE Course_ID = @CourseID AND Question_Type = N'True/False';

    IF @AvailableMCQ < @NumMCQ
    BEGIN
        -- If not enough questions, raise an error and stop execution.
        RAISERROR ('Error: Not enough MCQ questions available for Course ID %d. Required: %d, Available: %d.', 16, 1, @CourseID, @NumMCQ, @AvailableMCQ);
        RETURN;
    END

    IF @AvailableTF < @NumTF
    BEGIN
        RAISERROR ('Error: Not enough True/False questions available for Course ID %d. Required: %d, Available: %d.', 16, 1, @CourseID, @NumTF, @AvailableTF);
        RETURN;
    END

    -- ===================================================================
    -- 2. TRANSACTION: Perform the insertions as a single unit of work
    -- ===================================================================
    BEGIN TRY
        -- Start a transaction. If any part fails, the whole thing will be rolled back.
        BEGIN TRANSACTION;

        -- Declare a variable to hold the ID of the new exam we're about to create.
        DECLARE @NewExamID INT;

        -- Find the next available Exam_ID. Using MAX + 1 is a common approach
        -- if the primary key is not an IDENTITY column.
        SELECT @NewExamID = ISNULL(MAX(Exam_ID), 0) + 1 FROM Exam;

        -- Insert the new exam record into the Exam table.
        INSERT INTO Exam (Exam_ID, Course_ID, Instructor_ID, Exam_Date, Exam_Duration_Minutes, Exam_Type)
        VALUES (@NewExamID, @CourseID, @InstructorID, GETDATE(), @ExamDuration, @ExamType);

        -- Insert the randomly selected questions into the Exam_Questions table.
        INSERT INTO Exam_Questions (Exam_ID, Question_ID)
        SELECT @NewExamID, Question_ID
        FROM (
            -- Subquery to get random Multiple-Choice questions
            SELECT TOP (@NumMCQ) Question_ID
            FROM Question_Bank
            WHERE Course_ID = @CourseID AND Question_Type = N'MCQ'
            ORDER BY NEWID() -- NEWID() is used to get random rows

            UNION ALL -- Combine with the True/False questions

            -- Subquery to get random True/False questions
            SELECT TOP (@NumTF) Question_ID
            FROM Question_Bank
            WHERE Course_ID = @CourseID AND Question_Type = N'True/False'
            ORDER BY NEWID()
        ) AS RandomQuestions;

        -- If all steps succeeded, commit the transaction.
        COMMIT TRANSACTION;

        -- ===================================================================
        -- 3. CONFIRMATION: Show the newly created exam and its questions
        -- ===================================================================
        PRINT 'Successfully generated Exam ID: ' + CAST(@NewExamID AS VARCHAR(10));

        SELECT
            E.Exam_ID,
            C.Course_Name,
            I.Instructor_Fname + ' ' + I.Instructor_Lname AS Instructor_Name,
            EQ.Question_ID,
            QB.Question_Type,
            QB.Question_Description
        FROM Exam AS E
        JOIN Exam_Questions AS EQ ON E.Exam_ID = EQ.Exam_ID
        JOIN Question_Bank AS QB ON EQ.Question_ID = QB.Question_ID
        JOIN Course AS C ON E.Course_ID = C.Course_ID
        JOIN Instructor AS I ON E.Instructor_ID = I.Instructor_ID
        WHERE E.Exam_ID = @NewExamID;

    END TRY
    BEGIN CATCH
        -- If an error occurred in the TRY block, roll back the transaction.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Re-throw the original error message to the caller.
        THROW;
    END CATCH
END;
GO

/*To run the procedure and generate an exam, you use the EXEC command. 

You need to provide a valid Course_ID and Instructor_ID.*/

/*Let's assume you have an Instructor with Instructor_ID = 1. 
To generate an exam for the 'Power BI Development' track's 
first course, 'Intro to Data Analytics & Power BI' (Course_ID = 1):*/


/*EXEC sp_GenerateExam
    @CourseID = 1,          -- Corresponds to 'Intro to Data Analytics & Power BI'
    @InstructorID = 1;      -- Assuming an instructor with ID 1 exists*/


/*Example with Custom Parameters:

To generate a corrective exam with 5 questions (3 MCQ, 2 T/F) that lasts 30 minutes:

EXEC sp_GenerateExam
    @CourseID = 2,          -- Corresponds to 'Data Modeling & Power Query'
    @InstructorID = 1,
    @NumMCQ = 3,
    @NumTF = 2,
    @ExamDuration = 30,
    @ExamType = N'Corrective';*/