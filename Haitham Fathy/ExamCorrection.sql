/*this procedure will simply calculate and return the results for the given exam.

Stored Procedure: sp_CorrectExam
SQL
*/
CREATE PROCEDURE sp_CorrectExam
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalExamQuestions INT;

    -- ===================================================================
    -- 1. VALIDATION: Check if Exam exists and get total questions
    -- ===================================================================
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE Exam_ID = @ExamID)
    BEGIN
        RAISERROR ('Error: Exam ID %d not found.', 16, 1, @ExamID);
        RETURN;
    END

    -- Get the total number of questions for this exam
    SELECT @TotalExamQuestions = COUNT(Question_ID)
    FROM Exam_Questions
    WHERE Exam_ID = @ExamID;

    IF @TotalExamQuestions = 0
    BEGIN
        PRINT 'Warning: Exam ID ' + CAST(@ExamID AS VARCHAR(10)) + ' has no questions associated with it.';
        -- Return an empty result set matching the expected structure
        SELECT
            Student_ID = CAST(NULL AS INT),
            TotalGrade = CAST(NULL AS DECIMAL(8,2)),
            QuestionsAnswered = CAST(NULL AS INT),
            TotalExamQuestions = 0
        WHERE 1=0; -- Ensures structure is returned but no rows
        RETURN;
    END

    -- ===================================================================
    -- 2. CALCULATION: Sum grades for each student on this exam
    -- ===================================================================
    SELECT
        SEA.Student_ID,
        ISNULL(SUM(SEA.Student_Grade), 0) AS TotalGrade, -- Calculate the total grade, defaulting to 0 if no answers exist
        COUNT(SEA.Question_ID) AS QuestionsAnswered,      -- Count how many questions the student answered
        @TotalExamQuestions AS TotalExamQuestions         -- Show the total questions on the exam
    FROM
        Student_Exam_Answer AS SEA
    WHERE
        SEA.Exam_ID = @ExamID
    GROUP BY
        SEA.Student_ID
    ORDER BY
        SEA.Student_ID;

END;
GO

/*How to Use
Simply execute the procedure and provide the @ExamID you want to correct.

Example:

To calculate the total grades for all students who took Exam_ID = 29750:

SQL
*/

/*
EXEC sp_CorrectExam @ExamID = 1;
*/

/*Output:

The procedure will return a table-like result showing each Student_ID that has answers recorded for that exam,
their calculated TotalGrade (sum of Student_Grade from the Student_Exam_Answer table),
the number of QuestionsAnswered by that student for the exam,
and the TotalExamQuestions on that exam.*/
