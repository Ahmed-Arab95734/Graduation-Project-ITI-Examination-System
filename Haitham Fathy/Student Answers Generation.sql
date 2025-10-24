/*This procedure works as follows:

Finds the Course_ID associated with the provided @ExamID.

Gets a list of all Student_IDs enrolled in that course via the Student_Course table.

Gets a list of all Question_IDs associated with the @ExamID from Exam_Questions, along with their correct answers and types from Question_Bank.

For each student and each question in the exam:

It checks if an answer already exists for that student/question/exam combination. If so, it skips it.

It randomly determines if the student should answer correctly based on the @CorrectChance parameter (default is 80% correct).

If correct, it inserts the Question_Model_Answer and assigns the @MaxGradePerQuestion.

If incorrect:

For True/False questions, it inserts the opposite answer.

For MCQ questions, it randomly selects one of the incorrect choices from the Question_Choice table.

It assigns a grade of 0.

All insertions are wrapped in a transaction.*/

CREATE PROCEDURE sp_GenerateExamAnswers
    @ExamID INT,
    @CorrectChance DECIMAL(3,2) = 0.80, -- Chance (0.00 to 1.00) the student answers correctly
    @MaxGradePerQuestion DECIMAL(6,2) = 10.00 -- Grade awarded for a correct answer
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CourseID INT;

    -- ===================================================================
    -- 1. VALIDATION: Check if Exam exists
    -- ===================================================================
    SELECT @CourseID = Course_ID
    FROM Exam
    WHERE Exam_ID = @ExamID;

    IF @CourseID IS NULL
    BEGIN
        RAISERROR ('Error: Exam ID %d not found.', 16, 1, @ExamID);
        RETURN;
    END

    -- ===================================================================
    -- 2. PREPARE DATA: Get Students and Questions into temporary storage
    -- ===================================================================

    -- CTE for students enrolled in the course for this exam
    ;WITH EnrolledStudents AS (
        SELECT Student_ID
        FROM Student_Course
        WHERE Course_ID = @CourseID
    ),
    -- CTE for the questions on this specific exam
    ExamQuestions AS (
        SELECT
            EQ.Question_ID,
            QB.Question_Type,
            QB.Question_Model_Answer
        FROM Exam_Questions AS EQ
        JOIN Question_Bank AS QB ON EQ.Question_ID = QB.Question_ID
        WHERE EQ.Exam_ID = @ExamID
    )
    -- ===================================================================
    -- 3. GENERATE ANSWERS (using set-based approach)
    -- ===================================================================
    SELECT
        @ExamID AS Exam_ID,
        EQ.Question_ID,
        S.Student_ID,
        CASE
            WHEN RAND() <= @CorrectChance THEN EQ.Question_Model_Answer -- Correct Answer
            ELSE -- Incorrect Answer
                CASE EQ.Question_Type
                    WHEN N'True/False' THEN
                        CASE EQ.Question_Model_Answer
                            WHEN N'True' THEN N'False'
                            ELSE N'True'
                        END
                    WHEN N'MCQ' THEN
                        -- Select a random incorrect choice for this question
                        (SELECT TOP 1 QC.Choice_Text
                         FROM Question_Choice AS QC
                         WHERE QC.Question_ID = EQ.Question_ID
                           AND QC.Choice_Text <> EQ.Question_Model_Answer
                         ORDER BY NEWID())
                    ELSE EQ.Question_Model_Answer -- Default fallback (shouldn't happen with current types)
                END
        END AS Student_Answer,
        CASE
            WHEN RAND() <= @CorrectChance THEN @MaxGradePerQuestion -- Correct Grade
            ELSE 0.00 -- Incorrect Grade
        END AS Student_Grade
    INTO #TempAnswers -- Store generated answers temporarily
    FROM EnrolledStudents AS S
    CROSS JOIN ExamQuestions AS EQ; -- Create combinations for every student and every question

    -- ===================================================================
    -- 4. INSERT ANSWERS (only if they don't already exist)
    -- ===================================================================
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Student_Exam_Answer (Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade)
        SELECT
            TA.Exam_ID,
            TA.Question_ID,
            TA.Student_ID,
            TA.Student_Answer,
            TA.Student_Grade
        FROM #TempAnswers AS TA
        LEFT JOIN Student_Exam_Answer AS SEA
            ON TA.Exam_ID = SEA.Exam_ID
            AND TA.Question_ID = SEA.Question_ID
            AND TA.Student_ID = SEA.Student_ID
        WHERE SEA.Exam_ID IS NULL; -- Only insert if no answer exists for this combo

        COMMIT TRANSACTION;

        PRINT 'Successfully generated answers for Exam ID: ' + CAST(@ExamID AS VARCHAR(10));
        PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' new answer records.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error generating answers for Exam ID: ' + CAST(@ExamID AS VARCHAR(10));
        -- Re-throw the original error
        THROW;
    END CATCH

    -- Clean up temporary table
    DROP TABLE IF EXISTS #TempAnswers;

END;
GO

/*How to Use
Make sure you have students enrolled in the course associated with the exam ID via the Student_Course table.

Use the EXEC command, providing the @ExamID.

Example:

To generate answers for Exam_ID = 1 with default settings (80% correct chance, 10 points max grade):

SQL
*/
/*
EXEC sp_GenerateExamAnswers @ExamID = 29750;
*/
/*
Example with Custom Parameters:

To generate answers for Exam_ID = 2, making students only 50% likely to be correct, and correct answers worth 5 points:

SQL

EXEC sp_GenerateExamAnswers
    @ExamID = 2,
    @CorrectChance = 0.50,
    @MaxGradePerQuestion = 5.00;*/