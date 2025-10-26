-- Stored Procedure to grade a specific student's answers for a given exam

CREATE OR ALTER PROCEDURE StudentExamCorrection
    @StudentID INT,
    @ExamID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update the Student_Grade for each answer based on the Question_Bank
    UPDATE sa
    SET sa.Student_Grade =
        CASE
            -- If the student didn't answer (NULL), grade is 0
            WHEN sa.Student_Answer IS NULL THEN 0

            -- If the question is True/False, compare answers case-insensitively
            WHEN qb.Question_Type = N'True/False' AND UPPER(ISNULL(sa.Student_Answer, '')) = UPPER(qb.Question_Model_Answer) THEN 1

            -- If the question is MCQ, compare answers case-sensitively (assuming choices match exactly)
            WHEN qb.Question_Type = N'MCQ' AND sa.Student_Answer = qb.Question_Model_Answer THEN 1

            -- Otherwise, the answer is incorrect
            ELSE 0
        END
    FROM
        dbo.Student_Exam_Answer AS sa
    INNER JOIN
        dbo.Question_Bank AS qb ON sa.Question_ID = qb.Question_ID
    WHERE
        sa.Student_ID = @StudentID
        AND sa.Exam_ID = @ExamID;


END
GO
