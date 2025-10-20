-- =================================================================================
-- Populate the Rating Table
-- =================================================================================
-- This script inserts a rating from each student for every instructor who taught them.
-- It covers both track-specific technical courses and common soft-skill courses.
-- A bias is introduced to give higher ratings to Department Managers and other
-- designated "favored" instructors.

BEGIN TRANSACTION;

-- To prevent errors on re-running the script, you might want to clear the table first.
-- DELETE FROM Rating;

-- Use a Common Table Expression (CTE) to define all valid Student-Instructor pairs.
-- This is more readable and efficient than temporary tables.
WITH StudentInstructorPairs AS (
    -- 1. Get pairs for track-specific technical courses
    SELECT DISTINCT
        s.Student_ID,
        ic.Instructor_ID
    FROM
        Student AS s
    JOIN
        Intake_Branch_Track AS ibt ON s.Intake_Branch_Track_ID = ibt.Intake_Branch_Track_ID
    JOIN
        Track_Course AS tc ON ibt.Track_ID = tc.Track_ID
    JOIN
        Instructor_Course AS ic ON tc.Course_ID = ic.Course_ID

    UNION -- The UNION clause automatically handles duplicates

    -- 2. Get pairs for common soft-skill courses
    -- These are courses that are associated with all tracks.
    SELECT DISTINCT
        s.Student_ID,
        ic.Instructor_ID
    FROM
        Student AS s
    CROSS JOIN -- All students take these courses
        Instructor_Course AS ic
    WHERE
        ic.Course_ID IN (
            -- Subquery to dynamically find the soft-skill courses.
            -- A course is considered a soft-skill course if it's taught in every track.
            SELECT
                Course_ID
            FROM
                Track_Course
            GROUP BY
                Course_ID
            HAVING
                COUNT(DISTINCT Track_ID) = (SELECT COUNT(*) FROM Track)
        )
)

-- 3. Insert the ratings into the Rating table
INSERT INTO Rating (Student_ID, Instructor_ID, RatingValue)
SELECT
    p.Student_ID,
    p.Instructor_ID,
    -- Use a CASE statement to generate the rating value with the required bias.
    -- The RAND() function is seeded with NEWID() to ensure a different random
    -- number is generated for each row.
    CASE
        -- BIAS 1: Department Managers.
        -- Check if the instructor is the manager of the student's department.
        WHEN p.Instructor_ID IN (
            SELECT
                d.Manager_ID
            FROM
                Student AS s
            JOIN
                Intake_Branch_Track AS ibt ON s.Intake_Branch_Track_ID = ibt.Intake_Branch_Track_ID
            JOIN
                Track AS t ON ibt.Track_ID = t.Track_ID
            JOIN
                Department AS d ON t.Department_ID = d.Department_ID
            WHERE
                s.Student_ID = p.Student_ID AND d.Manager_ID IS NOT NULL
        )
        -- Assign a high rating between 8 and 10.
        THEN CAST(RAND(CHECKSUM(NEWID())) * 3 + 8 AS TINYINT)

        -- BIAS 2: Other "favored" instructors.
        -- You can modify this list with the IDs of other instructors to receive high ratings.
        WHEN p.Instructor_ID IN (5, 12, 18, 25, 33)
        -- Assign a good rating between 7 and 10.
        THEN CAST(RAND(CHECKSUM(NEWID())) * 4 + 7 AS TINYINT)

        -- DEFAULT: All other instructors.
        ELSE
        -- Assign a standard rating between 5 and 10.
        CAST(RAND(CHECKSUM(NEWID())) * 6 + 5 AS TINYINT)
    END AS RatingValue
FROM
    StudentInstructorPairs AS p;

COMMIT TRANSACTION;

GO

PRINT 'Rating table has been successfully populated.';

