BEGIN TRANSACTION;

-- Ensure the table is clear before inserting
DELETE FROM Failed_Students;

-- =========================================================================
-- Step 1: Identify and Insert Students who failed 3 or more exams
-- =========================================================================
WITH CorrectiveExams AS (
    -- Find all (Student, Course) pairs where a corrective exam was taken
    SELECT 
        e.Course_ID, 
        sea.Student_ID
    FROM Student_Exam_Answer sea
    JOIN Exam e ON sea.Exam_ID = e.Exam_ID
    WHERE e.Exam_Type = 'Corrective'
    GROUP BY e.Course_ID, sea.Student_ID
),
FinalGrades AS (
    -- Get grades from corrective exams (this is the final attempt)
    SELECT 
        e.Course_ID, 
        sea.Student_ID, 
        SUM(sea.Student_Grade) AS FinalGrade
    FROM Student_Exam_Answer sea
    JOIN Exam e ON sea.Exam_ID = e.Exam_ID
    WHERE e.Exam_Type = 'Corrective'
    GROUP BY e.Course_ID, sea.Student_ID

    UNION ALL

    -- Get grades from normal exams *only* if no corrective was taken for that course
    SELECT 
        e.Course_ID, 
        sea.Student_ID, 
        SUM(sea.Student_Grade) AS FinalGrade
    FROM Student_Exam_Answer sea
    JOIN Exam e ON sea.Exam_ID = e.Exam_ID
    WHERE e.Exam_Type = 'Normal'
      AND NOT EXISTS (
          SELECT 1 
          FROM CorrectiveExams ce
          WHERE ce.Student_ID = sea.Student_ID 
            AND ce.Course_ID = e.Course_ID
      )
    GROUP BY e.Course_ID, sea.Student_ID
),
StudentsWith3Fails AS (
    -- Count the number of failed courses (final grade < 6) for each student
    SELECT 
        Student_ID, 
        COUNT(*) AS FailedExamCount
    FROM FinalGrades
    WHERE FinalGrade < 6
    GROUP BY Student_ID
    HAVING COUNT(*) >= 3
)
-- Insert the students who failed 3+ exams AND are marked as 'Failed to Graduate'
INSERT INTO Failed_Students (Student_ID, Failure_Reason)
SELECT 
    s.Student_ID, 
    'Corrective in 3 or more exams'
FROM Student s
JOIN StudentsWith3Fails f ON s.Student_ID = f.Student_ID
WHERE s.Student_ITI_Status = N'Failed to Graduate';

PRINT 'Step 1: Inserted students who failed 3+ exams.';

-- =========================================================================
-- Step 2: Insert remaining failed students with random reasons
-- =========================================================================
WITH RemainingFailedStudents AS (
    -- Find all 'Failed to Graduate' students not already inserted
    SELECT Student_ID
    FROM Student
    WHERE Student_ITI_Status = N'Failed to Graduate'
      AND Student_ID NOT IN (SELECT Student_ID FROM Failed_Students)
),
RandomizedReasons AS (
    -- Assign a random reason to each of them
    SELECT 
        Student_ID,
        CASE (ABS(CHECKSUM(NEWID())) % 3)
            WHEN 0 THEN N'Left the program (resigned)'
            WHEN 1 THEN N'Exceeded allowed absences'
            ELSE N'Misbehaving'
        END AS Reason
    FROM RemainingFailedStudents
)
-- Insert the remaining students
INSERT INTO Failed_Students (Student_ID, Failure_Reason)
SELECT 
    Student_ID, 
    Reason 
FROM RandomizedReasons;

PRINT 'Step 2: Inserted remaining failed students with random reasons.';

COMMIT TRANSACTION;

PRINT 'Failed_Students table populated successfully.';
GO
