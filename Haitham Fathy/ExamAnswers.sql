CREATE OR ALTER PROCEDURE dbo.Examanswer
    @exam_id INT,
    @question_id INT,
    @student_id INT,
    @answer NVARCHAR(1000) -- Already allows NULL by default
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @QuestionType NVARCHAR(50);
    DECLARE @IsValidQuestion BIT = 0;
    DECLARE @IsValidChoice BIT = 0; -- Default to invalid unless validated

    -- 1. Check if the question is part of the exam
    IF EXISTS (SELECT 1 FROM dbo.Exam_Questions
               WHERE Exam_ID = @exam_id AND Question_ID = @question_id)
    BEGIN
        SET @IsValidQuestion = 1;
    END
    ELSE
    BEGIN
        -- Error: Question is not part of this exam
        RAISERROR('Invalid Question ID %d for Exam ID %d.', 16, 1, @question_id, @exam_id);
        RETURN; -- Stop execution
    END

    -- 2. Check if the answer is valid (or NULL) based on the question type
    IF @answer IS NULL
    BEGIN
        -- NULL answer is allowed (student skipped)
        SET @IsValidChoice = 1;
    END
    ELSE
    BEGIN
        -- Answer is not NULL, so validate it
        SELECT @QuestionType = Question_Type
        FROM dbo.Question_Bank
        WHERE Question_ID = @question_id;

        IF @QuestionType = N'MCQ'
        BEGIN
            -- Check if the answer exists in the choices for this MCQ question
            IF EXISTS (SELECT 1 FROM dbo.Question_Choice
                       WHERE Question_ID = @question_id AND Choice_Text = @answer)
            BEGIN
                SET @IsValidChoice = 1;
            END
        END
        ELSE IF @QuestionType = N'True/False'
        BEGIN
            -- Check if the answer is 'True' or 'False' (case-insensitive)
            IF UPPER(@answer) IN (N'TRUE', N'FALSE')
            BEGIN
                SET @IsValidChoice = 1;
            END
        END
        ELSE
        BEGIN
            -- Handle potential unknown question types if necessary
            RAISERROR('Unknown Question Type for Question ID %d.', 16, 1, @question_id);
            RETURN; -- Stop execution
        END
    END -- End of non-NULL answer validation

    -- Check if the provided answer is valid for the question type (or NULL)
    IF @IsValidChoice = 0
    BEGIN
        RAISERROR('Invalid answer "%s" provided for Question ID %d of type %s.', 16, 1, @answer, @question_id, @QuestionType);
        RETURN; -- Stop execution
    END

    -- 3. If checks pass, update or insert the answer
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.Student_Exam_Answer
                   WHERE Exam_ID = @exam_id AND Student_ID = @student_id AND Question_ID = @question_id)
        BEGIN
            -- Update existing answer
            UPDATE dbo.Student_Exam_Answer
            SET Student_Answer = @answer,
                Student_Grade = NULL -- Reset grade when answer changes
            WHERE Exam_ID = @exam_id
              AND Student_ID = @student_id
              AND Question_ID = @question_id;
        END
        ELSE
        BEGIN
            -- Insert new answer if it doesn't exist
            INSERT INTO dbo.Student_Exam_Answer (Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade)
            VALUES (@exam_id, @question_id, @student_id, @answer, NULL);
        END
    END TRY
    BEGIN CATCH
        THROW; -- Re-throw any error during INSERT/UPDATE
    END CATCH

END
GO


EXEC Examanswer 97, 1, 1, 'Power BI Desktop'
