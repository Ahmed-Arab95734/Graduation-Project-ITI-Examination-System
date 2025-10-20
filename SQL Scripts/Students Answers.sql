-- =================================================================================
-- Script to Populate Exam, Exam_Questions, and Student_Exam_Answer Tables
-- =================================================================================
-- This script handles the entire exam process:
-- 1. Creates 'Normal' exams for each course in each student group (Intake_Branch_Track).
-- 2. Populates these exams with 10 random questions from the question bank.
-- 3. Generates student answers for each question with a sophisticated bias system.
-- 4. Enforces a rule that students (not marked as 'Failed to Graduate') cannot fail 3+ exams.
-- 5. Creates 'Corrective' exams for any student who failed a normal exam.
-- 6. Generates answers and grades for the corrective exams.
-- =================================================================================

BEGIN TRANSACTION;

-- For idempotency, clear the tables before running the script.
DELETE FROM Student_Exam_Answer;
DELETE FROM Exam_Questions;
DELETE FROM Exam;
GO

-- =================================================================================
-- Step 1: Create 'Normal' Exams
-- =================================================================================
-- Create one 'Normal' exam for each course offered within each Intake_Branch_Track (group).
-- We assume all students in a group take the same exam for a course.

-- Use a temporary table to hold the new exam IDs and their mapping to student groups.
CREATE TABLE #NewExams (
    Exam_ID INT,
    Intake_Branch_Track_ID INT,
    Course_ID INT,
    Instructor_ID INT,
    Exam_Date DATE
);

-- Use a MERGE statement to perform the insert. This allows us to access columns
-- from the source data in the OUTPUT clause (specifically Intake_Branch_Track_ID),
-- which is not possible with a simple INSERT statement.
-- The MERGE target is Exam, and the source is a derived table of all unique exams to be created.
DECLARE @exam_id_counter INT = 1;

MERGE INTO Exam
USING (
    -- This subquery defines the unique exams to be created for each group/course combination
    SELECT
        ibt.Intake_Branch_Track_ID,
        ic.Course_ID,
        ic.Instructor_ID,
        MAX(sc.Course_EndDate) AS Exam_Date,
        ROW_NUMBER() OVER(ORDER BY ibt.Intake_Branch_Track_ID, ic.Course_ID) as rn
    FROM
        Intake_Branch_Track AS ibt
    JOIN
        Student AS s ON ibt.Intake_Branch_Track_ID = s.Intake_Branch_Track_ID
    JOIN
        Student_Course AS sc ON s.Student_ID = sc.Student_ID
    JOIN
        Instructor_Course AS ic ON sc.Course_ID = ic.Course_ID
    GROUP BY
        ibt.Intake_Branch_Track_ID, ic.Course_ID, ic.Instructor_ID
) AS Source
ON 1 = 0 -- This condition is always false, forcing the INSERT action for all rows.
WHEN NOT MATCHED THEN
    INSERT (Exam_ID, Course_ID, Instructor_ID, Exam_Date, Exam_Duration_Minutes, Exam_Type)
    VALUES (@exam_id_counter + Source.rn - 1, Source.Course_ID, Source.Instructor_ID, Source.Exam_Date, 20, 'Normal')
OUTPUT
    inserted.Exam_ID,
    Source.Intake_Branch_Track_ID,
    inserted.Course_ID,
    inserted.Instructor_ID,
    inserted.Exam_Date
INTO #NewExams (Exam_ID, Intake_Branch_Track_ID, Course_ID, Instructor_ID, Exam_Date);

PRINT 'Step 1: Normal exams created successfully.';

-- =================================================================================
-- Step 2: Populate 'Normal' Exams with Questions
-- =================================================================================
-- For each exam created, select 10 random questions of the correct course.

INSERT INTO Exam_Questions (Exam_ID, Question_ID)
SELECT
    ne.Exam_ID,
    q.Question_ID
FROM
    #NewExams ne
CROSS APPLY (
    -- This selects 10 random questions for the given course.
    SELECT TOP 10 Question_ID
    FROM Question_Bank
    WHERE Course_ID = ne.Course_ID
    ORDER BY NEWID()
) AS q;

PRINT 'Step 2: Normal exam questions populated successfully.';

-- =================================================================================
-- Step 3: Generate Student Answers for 'Normal' Exams with Bias
-- =================================================================================
-- This is the core logic. We generate answers based on a calculated probability.

-- Create a temporary table to store initial results before adjustments.
CREATE TABLE #InitialAnswers (
    Exam_ID INT,
    Question_ID INT,
    Student_ID INT,
    Student_Answer NVARCHAR(1000),
    Student_Grade DECIMAL(6,2),
    Is_Correct BIT
);

WITH StudentPerformance AS (
    SELECT
        s.Student_ID,
        -- Calculate a base probability of answering correctly.
        CASE s.Student_Faculty_Grade
            WHEN N'Excellent' THEN 0.80
            WHEN N'Very Good' THEN 0.70
            WHEN N'Good'      THEN 0.60
            ELSE 0.50
        END +
        CASE
            WHEN i.Intake_Start_Date >= '2024-01-01' THEN 0.10 -- Bias for 2024 intakes
            ELSE 0
        END +
        CASE b.Branch_Name
            WHEN N'Smart Village'     THEN 0.15
            WHEN N'New Capital'      THEN 0.10
            WHEN N'Cairo University'  THEN 0.07
            WHEN N'Alexandria'       THEN 0.05
            ELSE 0
        END AS CorrectAnswerProbability
    FROM
        Student s
    JOIN
        Intake_Branch_Track ibt ON s.Intake_Branch_Track_ID = ibt.Intake_Branch_Track_ID
    JOIN
        Intake i ON ibt.Intake_ID = i.Intake_ID
    JOIN
        Branch b ON ibt.Branch_ID = b.Branch_ID
),
AllQuestionsForStudents AS (
    SELECT
        s.Student_ID,
        eq.Exam_ID,
        eq.Question_ID,
        qb.Question_Type,
        qb.Question_Model_Answer,
        sp.CorrectAnswerProbability
    FROM
        Student s
    JOIN
        #NewExams ne ON s.Intake_Branch_Track_ID = ne.Intake_Branch_Track_ID
    JOIN
        Exam_Questions eq ON ne.Exam_ID = eq.Exam_ID
    JOIN
        Question_Bank qb ON eq.Question_ID = qb.Question_ID
    JOIN
        StudentPerformance sp ON s.Student_ID = sp.Student_ID
)
INSERT INTO #InitialAnswers (Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade, Is_Correct)
SELECT
    a.Exam_ID,
    a.Question_ID,
    a.Student_ID,
    -- Generate an answer: if the random number is within the probability, it's correct.
    CASE
        WHEN RAND(CHECKSUM(NEWID())) < a.CorrectAnswerProbability THEN a.Question_Model_Answer -- Correct Answer
        ELSE -- Incorrect Answer
            CASE a.Question_Type
                WHEN 'True/False' THEN IIF(a.Question_Model_Answer = 'True', 'False', 'True')
                ELSE (SELECT TOP 1 Choice_Text FROM Question_Choice WHERE Question_ID = a.Question_ID AND Choice_Text <> a.Question_Model_Answer ORDER BY NEWID())
            END
    END AS Student_Answer,
    0, -- Grade will be calculated next
    IIF(RAND(CHECKSUM(NEWID())) < a.CorrectAnswerProbability, 1, 0) AS Is_Correct
FROM
    AllQuestionsForStudents a;

-- Update the grade and answer based on the Is_Correct flag.
UPDATE #InitialAnswers
SET
    Student_Grade = IIF(Is_Correct = 1, 1.00, 0.00),
    Student_Answer = CASE
        WHEN Is_Correct = 1 THEN qb.Question_Model_Answer
        ELSE
            CASE qb.Question_Type
                WHEN 'True/False' THEN IIF(qb.Question_Model_Answer = 'True', 'False', 'True')
                ELSE (SELECT TOP 1 Choice_Text FROM Question_Choice qc WHERE qc.Question_ID = ia.Question_ID AND qc.Choice_Text <> qb.Question_Model_Answer ORDER BY NEWID())
            END
    END
FROM #InitialAnswers ia
JOIN Question_Bank qb ON ia.Question_ID = qb.Question_ID;


PRINT 'Step 3: Biased answers for normal exams generated.';

-- =================================================================================
-- Step 4: Enforce Failing Constraint
-- =================================================================================
-- Students not marked as 'Failed to Graduate' cannot fail 3 or more courses.
-- We will find these students and "fix" one of their failed exam scores.

WITH FailedExams AS (
    SELECT
        Student_ID,
        Exam_ID,
        SUM(Student_Grade) as TotalGrade,
        ROW_NUMBER() OVER(PARTITION BY Student_ID ORDER BY Exam_ID) as FailRank
    FROM #InitialAnswers
    GROUP BY Student_ID, Exam_ID
    HAVING SUM(Student_Grade) < 6
),
StudentsToFix AS (
    SELECT fe.Student_ID
    FROM FailedExams fe
    JOIN Student s ON fe.Student_ID = s.Student_ID
    WHERE s.Student_ITI_Status <> N'Failed to Graduate'
    GROUP BY fe.Student_ID
    HAVING COUNT(*) >= 3
),
ExamToFix AS (
    -- Pick the 3rd failed exam to fix for each student
    SELECT Student_ID, Exam_ID
    FROM FailedExams
    WHERE Student_ID IN (SELECT Student_ID FROM StudentsToFix) AND FailRank = 3
),
QuestionsToFlip AS (
    -- Identify up to 2 incorrect answers to flip to correct
    SELECT
        ia.Student_ID,
        ia.Exam_ID,
        ia.Question_ID,
        ROW_NUMBER() OVER(PARTITION BY ia.Student_ID, ia.Exam_ID ORDER BY ia.Question_ID) as FlipRank
    FROM #InitialAnswers ia
    JOIN ExamToFix etf ON ia.Student_ID = etf.Student_ID AND ia.Exam_ID = etf.Exam_ID
    WHERE ia.Is_Correct = 0
)
UPDATE #InitialAnswers
SET
    Is_Correct = 1,
    Student_Grade = 1.00,
    Student_Answer = qb.Question_Model_Answer
FROM #InitialAnswers ia
JOIN QuestionsToFlip qtf ON ia.Student_ID = qtf.Student_ID AND ia.Exam_ID = qtf.Exam_ID AND ia.Question_ID = qtf.Question_ID
JOIN Question_Bank qb ON ia.Question_ID = qb.Question_ID
WHERE qtf.FlipRank <= 2; -- Flip up to 2 answers to make the score 6 or 7

PRINT 'Step 4: Failing constraint enforced.';

-- =================================================================================
-- Step 5: Insert Final 'Normal' Exam Answers
-- =================================================================================

INSERT INTO Student_Exam_Answer (Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade)
SELECT Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade
FROM #InitialAnswers;

PRINT 'Step 5: Normal exam answers inserted into final table.';

-- =================================================================================
-- Step 6: Create 'Corrective' Exams
-- =================================================================================
-- Find all students who still failed an exam (score < 6) and create a new corrective exam.

CREATE TABLE #CorrectiveExams (
    Exam_ID INT,
    Course_ID INT,
    Instructor_ID INT,
    Student_ID INT
);

-- Get the last used Exam_ID to continue numbering
SELECT @exam_id_counter = ISNULL(MAX(Exam_ID), 0) FROM Exam;

-- Use a MERGE statement again to handle the OUTPUT clause limitation.
-- The source combines the students who failed with the details of their failed exam.
MERGE INTO Exam
USING (
    SELECT
        fs.Student_ID,
        e.Course_ID,
        e.Instructor_ID,
        DATEADD(day, 7, e.Exam_Date) AS Exam_Date,
        ROW_NUMBER() OVER(ORDER BY fs.Student_ID, e.Course_ID) as rn
    FROM (
        -- Inner query to find students who failed the normal exam
        SELECT Student_ID, Exam_ID
        FROM #InitialAnswers
        GROUP BY Student_ID, Exam_ID
        HAVING SUM(Student_Grade) < 6
    ) AS fs
    JOIN Exam e ON fs.Exam_ID = e.Exam_ID
) AS Source
ON 1 = 0 -- Always false to force INSERT
WHEN NOT MATCHED THEN
    INSERT (Exam_ID, Course_ID, Instructor_ID, Exam_Date, Exam_Duration_Minutes, Exam_Type)
    VALUES (@exam_id_counter + Source.rn, Source.Course_ID, Source.Instructor_ID, Source.Exam_Date, 20, 'Corrective')
OUTPUT
    inserted.Exam_ID,
    inserted.Course_ID,
    inserted.Instructor_ID,
    Source.Student_ID -- Now this is a valid reference
INTO #CorrectiveExams (Exam_ID, Course_ID, Instructor_ID, Student_ID);

PRINT 'Step 6: Corrective exams created for failed students.';

-- =================================================================================
-- Step 7: Populate 'Corrective' Exams with Questions
-- =================================================================================

INSERT INTO Exam_Questions (Exam_ID, Question_ID)
SELECT
    ce.Exam_ID,
    q.Question_ID
FROM
    #CorrectiveExams ce
CROSS APPLY (
    -- Select 10 new random questions for the corrective exam
    SELECT TOP 10 Question_ID
    FROM Question_Bank
    WHERE Course_ID = ce.Course_ID
    ORDER BY NEWID()
) AS q;

PRINT 'Step 7: Corrective exam questions populated.';

-- =================================================================================
-- Step 8: Generate and Insert Answers for 'Corrective' Exams
-- =================================================================================

WITH StudentPerformance AS (
    -- Reuse the same performance calculation logic
    SELECT
        s.Student_ID,
        CASE s.Student_Faculty_Grade
            WHEN N'Excellent' THEN 0.80
            WHEN N'Very Good' THEN 0.70
            WHEN N'Good'      THEN 0.60
            ELSE 0.50
        END +
        CASE
            WHEN i.Intake_Start_Date >= '2024-01-01' THEN 0.10
            ELSE 0
        END +
        CASE b.Branch_Name
            WHEN N'Smart Village'     THEN 0.15
            WHEN N'New Capital'      THEN 0.10
            WHEN N'Cairo University'  THEN 0.07
            WHEN N'Alexandria'       THEN 0.05
            ELSE 0
        END AS CorrectAnswerProbability
    FROM
        Student s
    JOIN Intake_Branch_Track ibt ON s.Intake_Branch_Track_ID = ibt.Intake_Branch_Track_ID
    JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
    JOIN Branch b ON ibt.Branch_ID = b.Branch_ID
),
AllCorrectiveQuestions AS (
    SELECT
        s.Student_ID,
        eq.Exam_ID,
        eq.Question_ID,
        qb.Question_Model_Answer,
        qb.Question_Type,
        sp.CorrectAnswerProbability
    FROM
        Student s
    JOIN #CorrectiveExams ce ON s.Student_ID = ce.Student_ID
    JOIN Exam_Questions eq ON ce.Exam_ID = eq.Exam_ID
    JOIN Question_Bank qb ON eq.Question_ID = qb.Question_ID
    JOIN StudentPerformance sp ON s.Student_ID = sp.Student_ID
)
INSERT INTO Student_Exam_Answer (Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade)
SELECT
    a.Exam_ID,
    a.Question_ID,
    a.Student_ID,
    -- Determine the answer based on probability
    CASE
        WHEN RAND(CHECKSUM(NEWID())) < a.CorrectAnswerProbability THEN a.Question_Model_Answer
        ELSE
            CASE a.Question_Type
                WHEN 'True/False' THEN IIF(a.Question_Model_Answer = 'True', 'False', 'True')
                ELSE (SELECT TOP 1 Choice_Text FROM Question_Choice WHERE Question_ID = a.Question_ID AND Choice_Text <> a.Question_Model_Answer ORDER BY NEWID())
            END
    END AS Student_Answer,
    -- Determine the grade
    IIF(RAND(CHECKSUM(NEWID())) < a.CorrectAnswerProbability, 1.00, 0.00) AS Student_Grade
FROM
    AllCorrectiveQuestions a;


PRINT 'Step 8: Corrective exam answers generated and inserted.';


-- =================================================================================
-- Clean up temporary tables
-- =================================================================================
DROP TABLE #NewExams;
DROP TABLE #InitialAnswers;
DROP TABLE #CorrectiveExams;

COMMIT TRANSACTION;

PRINT 'Script finished successfully. All exam data has been populated.';
GO

