/********************************************************************************
* RUN SCRIPT
* Description: Populates Student and related tables for Track 'Business Analysis' (ID 25)
* Start IDs: 48000 for Student, Job, and Certificate
* Students per IBT: 25
*
* Rules Enforced:
* 1.  Only for Track_ID 25.
* 2.  25 Students per Intake_Branch_Track (IBT).
* 3.  Unique IDs starting from 48000.
* 4.  Egyptian Names (Male/Female).
* 5.  Branch-proximal Egyptian addresses (20+ governorates).
* 6.  Email format: [name][id]@iti.
* 7.  Unique Egyptian phone numbers.
* 8.  Social links include student name.
* 9.  Faculties weighted towards CompSci/Eng, but also strong weight for Commerce/Business/IS.
* 10. ITI Status ('Graduated', 'Failed to Graduate', 'In Progress') based on Intake_End_Date vs GETDATE().
* 11. 'In Progress' students have NO company data.
* 12. 'Graduated' students (and not 'Failed') have a *chance* to be hired.
* 13. Hiring priority: Smart Village > Cairo Uni > New Capital > Alex > Rest.
* 14. Hire dates are post-graduation.
* 15. Salaries: Full-Time > Part-Time.
* 16. Positions, Companies, Certs, Freelance jobs are all relevant to 'Business Analysis'.
* 17. Certs/Freelance jobs dated *during* the intake period.
* 18. Student_Course table populated sequentially for all 12 'Business Analysis' courses.
* 19. No NULLs are inserted, except for 'Leave_Date' in Student_Company.
********************************************************************************/

SET NOCOUNT ON;
BEGIN TRANSACTION;

-- =============================================================================
-- 1. DECLARE TEMP TABLES FOR RANDOM DATA
-- =============================================================================

-- -- -- -- -- -- -- -- -- -- -- --
-- Names
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames VALUES
(N'Youssef'), (N'Ahmed'), (N'Mahmoud'), (N'Mohamed'), (N'Omar'), (N'Ali'), (N'Khaled'),
(N'Mostafa'), (N'Tarek'), (N'Hassan'), (N'Hussein'), (N'Karim'), (N'Amr'), (N'Mazen'),
(N'Zeyad'), (N'Ibrahim'), (N'Sameh'), (N'Adel'), (N'Hazem'), (N'Fares');

DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames VALUES
(N'Mariam'), (N'Fatima'), (N'Habiba'), (N'Jana'), (N'Hana'), (N'Salma'), (N'Nour'),
(N'Aya'), (N'Yara'), (N'Menna'), (N'Sarah'), (N'Reem'), (N'Farida'), (N'Laila'),
(N'Dina'), (N'Amina'), (N'Nada'), (N'Rowan'), (N'Toqa'), (N'Malak');

DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames VALUES
(N'El-Masry'), (N'Hassan'), (N'Ali'), (N'Mohamed'), (N'Ibrahim'), (N'Abdel-Rahman'), (N'Said'),
(N'Taha'), (N'Mahmoud'), (N'Kamel'), (N'Fathy'), (N'El-Sayed'), (N'Gaber'), (N'Rizk'),
(N'Badawy'), (N'Hamdy'), (N'Shalaby'), (N'El-Shazly'), (N'Metwally'), (N'Amer');

-- -- -- -- -- -- -- -- -- -- -- --
-- Addresses & Governorates (21 total)
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @StreetNames TABLE (Name NVARCHAR(100));
INSERT INTO @StreetNames VALUES
(N'Tahrir St.'), (N'Ramses St.'), (N'Corniche El Nil'), (N'Abbas El Akkad St.'), (N'Makram Ebeid St.'),
(N'Talaat Harb St.'), (N'El Geish St.'), (N'Port Said St.'), (N'Fouad St.'), (N'El Horreya Rd.'),
(N'Salah Salem St.'), (N'Gomhoria St.'), (N'University St.'), (N'Pyramids St.'), (N'El Bahr St.');

DECLARE @Governorates TABLE (
    Gov_Name NVARCHAR(50),
    Branch_Locations NVARCHAR(255) -- Stores comma-separated list of Branch Locations this Gov is near
);
INSERT INTO @Governorates (Gov_Name, Branch_Locations) VALUES
(N'Cairo', ',Giza,New Capital,'),
(N'Giza', ',Giza,New Capital,'),
(N'Alexandria', ',Alexandria,Damanhour,'),
(N'Dakahlia', ',El Mansoura,Zagazig,'),
(N'Sharqia', ',Zagazig,Ismailia,Benha,'),
(N'Qalyubiyya', ',Benha,Giza,New Capital,Zagazig,'),
(N'Gharbia', ',Tanta,El Mansoura,El Menoufia,'),
(N'Menoufia', ',El Menoufia,Tanta,Benha,'),
(N'Beheira', ',Damanhour,Alexandria,'),
(N'Ismailia', ',Ismailia,Port Said,'),
(N'Port Said', ',Port Said,Ismailia,'),
(N'Suez', ',Ismailia,'),
(N'Kafr El Sheikh', ',Tanta,Damanhour,'),
(N'Fayoum', ',El Fayoum,Beni Sweif,'),
(N'Beni Suef', ',Beni Sweif,El Fayoum,El Minia,'),
(N'Minya', ',El Minia,Assiut,Beni Sweif,'),
(N'Assiut', ',Assiut,El Minia,Sohag,New Valley,'),
(N'Sohag', ',Sohag,Assiut,Qena,'),
(N'Qena', ',Qena,Sohag,Aswan,'),
(N'Aswan', ',Aswan,Qena,'),
(N'Luxor', ',Qena,Sohag,'),
(N'New Valley', ',New Valley,Assiut,'),
(N'North Sinai', ',Al Arish,Ismailia,Port Said,');

-- -- -- -- -- -- -- -- -- -- -- --
-- Faculties (Weighted) - Adjusted for Business Analysis
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @BusinessFaculties TABLE (Name NVARCHAR(100));
INSERT INTO @BusinessFaculties VALUES
(N'Faculty of Commerce'), (N'Faculty of Business Administration'), (N'Faculty of Information Systems'), (N'Faculty of Economics and Political Science');

DECLARE @TechFaculties TABLE (Name NVARCHAR(100));
INSERT INTO @TechFaculties VALUES (N'Faculty of Computers Sciences'), (N'Faculty of Engineering');

DECLARE @OtherFaculties TABLE (Name NVARCHAR(100));
INSERT INTO @OtherFaculties VALUES
(N'Faculty of Science'), (N'Faculty of Education'), (N'Faculty of Agriculture'),
(N'Faculty of Fine Arts'),(N'Faculty of Applied Arts'), (N'Faculty of Arts');

-- -- -- -- -- -- -- -- -- -- -- --
-- Track-Specific Data: Business Analysis (Track 25)
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @TrackCourses TABLE (RN INT, Course_ID INT);
INSERT INTO @TrackCourses (RN, Course_ID)
SELECT ROW_NUMBER() OVER (ORDER BY Course_ID), Course_ID
FROM Track_Course WHERE Track_ID = 25;

DECLARE @Companies_BA TABLE (ID INT);
INSERT INTO @Companies_BA VALUES
(3), (4), (6), (8), (10), (11), (13), (14), (16), (17), (21), (22), (23), (24), (27), (28), (29), (30), (41), (42), (43), (46), (47), (48), (50), (53); -- VOIS, Accenture, Orange, CIB, IBM, Capgemini, Etisalat, Fawry, Robusta, Instabug, NBE, Banque Misr, WE, Raya, PwC, Deloitte, EY, KPMG, ArabyAds, e-finance, Paymob, Talabat, Kyndryl, Atos, Jumia, EFG Hermes

DECLARE @Positions_BA TABLE (Name NVARCHAR(100));
INSERT INTO @Positions_BA VALUES
(N'Business Analyst'), (N'Junior Business Analyst'), (N'Product Analyst'), (N'Requirements Engineer'),
(N'Process Analyst'), (N'Systems Analyst'), (N'Functional Consultant'), (N'Agile Business Analyst');

DECLARE @CertProviders TABLE (Name NVARCHAR(200));
INSERT INTO @CertProviders VALUES (N'Udemy'), (N'Coursera'), (N'Udacity'), (N'Mahara Tech'), (N'DataCamp'), (N'Microsoft'), (N'IIBA'), (N'BCS'); -- Added IIBA, BCS

DECLARE @CertNames_BA TABLE (Name NVARCHAR(200));
INSERT INTO @CertNames_BA VALUES
(N'ECBA (Entry Certificate in Business Analysis) Prep'), (N'Agile Analysis Certification (IIBA-AAC) Prep'), (N'BCS Foundation Certificate in Business Analysis'),
(N'Requirements Engineering Fundamentals'), (N'Business Process Modeling with BPMN'), (N'Writing Effective User Stories');

DECLARE @FreelanceSites TABLE (Name NVARCHAR(255));
INSERT INTO @FreelanceSites VALUES (N'Upwork'), (N'Freelancer'), (N'LinkedIn'), (N'Khamsat'), (N'Mostaql');

DECLARE @FreelanceJobs_BA TABLE (Name NVARCHAR(1000));
INSERT INTO @FreelanceJobs_BA VALUES
(N'Documented requirements for a new mobile app feature.'), (N'Created process flow diagrams (As-Is & To-Be) for a client.'),
(N'Conducted stakeholder interviews to gather requirements.'), (N'Wrote 20 user stories for an upcoming sprint.'),
(N'Performed competitor analysis for a SaaS product.'), (N'Developed wireframes and mockups for a web portal.'),
(N'Created a Business Requirements Document (BRD).'), (N'Analyzed user feedback and identified improvement areas.'),
(N'Facilitated a requirements gathering workshop.'), (N'Created a traceability matrix for project requirements.'),
(N'Performed gap analysis between current and future state.'), (N'Developed use cases for a new software system.'),
(N'Defined acceptance criteria for user stories.'), (N'Created a presentation outlining project scope and objectives.'),
(N'Assisted in user acceptance testing (UAT) planning.');


-- =============================================================================
-- 2. DECLARE CURSOR AND LOOP VARIABLES
-- =============================================================================
DECLARE @CurrentID INT = 48000;
DECLARE @CurrentJobID INT = 48000;
DECLARE @CurrentCertID INT = 48000;
DECLARE @StudentCounter INT;

-- -- -- -- -- -- -- -- -- -- -- --
-- IBT-level Variables
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @IBT_ID INT;
DECLARE @Intake_ID INT;
DECLARE @Branch_ID INT;
DECLARE @Track_ID INT;
DECLARE @Intake_Start_Date DATE;
DECLARE @Intake_End_Date DATE;
DECLARE @Branch_Location NVARCHAR(100);

-- -- -- -- -- -- -- -- -- -- -- --
-- Student-level Variables
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @StudentID INT;
DECLARE @Fname NVARCHAR(50);
DECLARE @Lname NVARCHAR(50);
DECLARE @Gender NVARCHAR(10);
DECLARE @MaritalStatus NVARCHAR(50);
DECLARE @Birthdate DATE;
DECLARE @Governorate NVARCHAR(50);
DECLARE @Street NVARCHAR(100);
DECLARE @Address NVARCHAR(255);
DECLARE @Email NVARCHAR(100);
DECLARE @Phone NVARCHAR(20);
DECLARE @Faculty NVARCHAR(100);
DECLARE @FacultyGrade NVARCHAR(50);
DECLARE @FacultyRand FLOAT;
DECLARE @Status NVARCHAR(50);
DECLARE @Hired BIT;
DECLARE @HiringProb FLOAT;

-- -- -- -- -- -- -- -- -- -- -- --
-- Related Data Variables
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @NumCerts INT, @Cert_i INT, @CertID INT, @CertName NVARCHAR(200), @CertProvider NVARCHAR(200), @CertCost DECIMAL(12,2), @CertDate DATE;
DECLARE @NumJobs INT, @Job_i INT, @JobID INT, @JobSite NVARCHAR(255), @JobDesc NVARCHAR(1000), @JobEarn DECIMAL(12,2), @JobDate DATE;
DECLARE @CompanyID INT, @Position NVARCHAR(100), @Contract NVARCHAR(50), @Salary DECIMAL(12,2), @HireDate DATE;

-- -- -- -- -- -- -- -- -- -- -- --
-- Course Loop Variables
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @TotalCourses INT = (SELECT COUNT(*) FROM @TrackCourses);
DECLARE @TotalDuration INT;
DECLARE @CourseDuration INT;
DECLARE @Course_i INT;
DECLARE @CurrentCourse_ID INT;
DECLARE @CurrentCourseStart DATE;
DECLARE @CurrentCourseEnd DATE;

-- -- -- -- -- -- -- -- -- -- -- --
-- Main Cursor
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE IBT_Cursor CURSOR FOR
    SELECT
        IBT.Intake_Branch_Track_ID,
        IBT.Intake_ID,
        IBT.Branch_ID,
        IBT.Track_ID,
        I.Intake_Start_Date,
        I.Intake_End_Date,
        B.Branch_Location
    FROM
        Intake_Branch_Track AS IBT
    JOIN
        Intake AS I ON IBT.Intake_ID = I.Intake_ID
    JOIN
        Branch AS B ON IBT.Branch_ID = B.Branch_ID
    WHERE
        IBT.Track_ID = 25; -- <<<<<<< ONLY 'Business Analysis'

OPEN IBT_Cursor;
FETCH NEXT FROM IBT_Cursor INTO @IBT_ID, @Intake_ID, @Branch_ID, @Track_ID, @Intake_Start_Date, @Intake_End_Date, @Branch_Location;

-- =============================================================================
-- 3. START MAIN LOOP (Per IBT)
-- =============================================================================
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @StudentCounter = 1;
    SET @TotalDuration = DATEDIFF(day, @Intake_Start_Date, @Intake_End_Date);
    SET @CourseDuration = @TotalDuration / @TotalCourses; -- Base duration per course

    -- -- -- -- -- -- -- -- -- -- -- --
    -- 3.1. Determine Branch-specific Hiring Probability
    -- -- -- -- -- -- -- -- -- -- -- --
    SET @HiringProb = CASE
        WHEN @Branch_ID = 1  THEN 0.40 -- Smart Village
        WHEN @Branch_ID = 12 THEN 0.30 -- Cairo University
        WHEN @Branch_ID = 11 THEN 0.25 -- New Capital
        WHEN @Branch_ID = 2  THEN 0.20 -- Alexandria
        ELSE 0.10 -- Rest of branches
    END;

    -- =========================================================================
    -- 4. START INNER LOOP (Per Student, 25 times)
    -- =========================================================================
    WHILE @StudentCounter <= 25
    BEGIN
        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.1. Generate Base Student Data
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @StudentID = @CurrentID;
        SET @Gender = CASE WHEN RAND() > 0.5 THEN N'Male' ELSE N'Female' END;
        SET @MaritalStatus = CASE WHEN RAND() > 0.7 THEN N'Married' ELSE N'Single' END;
        SET @Lname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());

        IF @Gender = N'Male'
            SET @Fname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @Fname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());

        SET @Email = LOWER(REPLACE(@Fname, ' ', '')) + '.' + CAST(@StudentID AS VARCHAR(10)) + '@iti';
        
        -- Age between 20 and 35 (safe for > 18 check)
        SET @Birthdate = DATEADD(DAY, - (7300 + (RAND() * 5475)), GETDATE()); -- 7300 days = 20 years, 5475 = 15 years range
        SET @FacultyGrade = (SELECT TOP 1 V FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS Grades(V) ORDER BY NEWID());

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.2. Generate Branch-Proximal Address
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @Governorate = (
            SELECT TOP 1 Gov_Name
            FROM @Governorates
            WHERE Branch_Locations LIKE '%,' + @Branch_Location + ',%'
            ORDER BY NEWID()
        );
        SET @Street = (SELECT TOP 1 Name FROM @StreetNames ORDER BY NEWID());
        SET @Address = CAST(ABS(CHECKSUM(NEWID()) % 200) + 1 AS VARCHAR(10)) + ' ' + @Street + ', ' + @Governorate;
        
        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.3. Generate Weighted Faculty (Adjusted for BA)
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @FacultyRand = RAND();
        IF @FacultyRand < 0.30 -- 30% chance Business/Commerce/IS/Econ
            SET @Faculty = (SELECT TOP 1 Name FROM @BusinessFaculties ORDER BY NEWID());
        ELSE IF @FacultyRand < 0.60 -- 30% chance CS/Eng (total 60%)
             SET @Faculty = (SELECT TOP 1 Name FROM @TechFaculties ORDER BY NEWID());
        ELSE -- 40% chance Others
            SET @Faculty = (SELECT TOP 1 Name FROM @OtherFaculties ORDER BY NEWID());

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.4. Generate Unique Phone
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @Phone = '01' + CHAR(CAST(RAND()*3 AS INT) + 48) + RIGHT('0000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(8)), 8);
        WHILE EXISTS (SELECT 1 FROM Student_Phone WHERE Phone = @Phone)
        BEGIN
            SET @Phone = '01' + CHAR(CAST(RAND()*3 AS INT) + 48) + RIGHT('0000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS VARCHAR(8)), 8);
        END;

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.5. Determine ITI Status & Hiring Status
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @Hired = 0;
        IF @Intake_End_Date < GETDATE()
        BEGIN
            -- Intake is finished
            IF RAND() < 0.05 -- 5% fail rate
                SET @Status = N'Failed to Graduate';
            ELSE
            BEGIN
                SET @Status = N'Graduated';
                IF RAND() < @HiringProb -- Check against branch hiring probability
                    SET @Hired = 1;
            END;
        END
        ELSE
        BEGIN
            -- Intake is active
            SET @Status = N'In Progress';
        END;

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.6. INSERT Student
        -- -- -- -- -- -- -- -- -- -- -- --
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate,
            Student_Faculty, Student_Faculty_Grade, Student_ITI_Status, Intake_Branch_Track_ID
        ) VALUES (
            @StudentID, @Email, @Address, @Gender, @MaritalStatus,
            @Fname, @Lname, @Birthdate,
            @Faculty, @FacultyGrade, @Status, @IBT_ID
        );

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.7. INSERT Student_Phone
        -- -- -- -- -- -- -- -- -- -- -- --
        INSERT INTO Student_Phone (Student_ID, Phone) VALUES (@StudentID, @Phone);

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.8. INSERT Student_Social
        -- -- -- -- -- -- -- -- -- -- -- --
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url) VALUES
        (@StudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(REPLACE(@Fname, ' ', '')) + '-' + LOWER(REPLACE(@Lname, ' ', '')) + CAST(@StudentID % 1000 AS VARCHAR(4))),
      --(@StudentID, N'GitHub', N'https://github.com/' + LOWER(REPLACE(@Fname, ' ', '')) + LOWER(REPLACE(@Lname, ' ', '')) + CAST(@StudentID % 1000 AS VARCHAR(4))), -- Not very relevant for BA
        (@StudentID, N'Facebook', N'https://facebook.com/' + LOWER(REPLACE(@Fname, ' ', '.')) + '.' + LOWER(REPLACE(@Lname, ' ', '.')) + CAST(@StudentID % 1000 AS VARCHAR(4)));

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.9. INSERT Student_Course (Sequential)
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @Course_i = 1;
        SET @CurrentCourseStart = @Intake_Start_Date;

        WHILE @Course_i <= @TotalCourses
        BEGIN
            SELECT @CurrentCourse_ID = Course_ID FROM @TrackCourses WHERE RN = @Course_i;
            
            -- Calculate End Date
            SET @CurrentCourseEnd = DATEADD(DAY, @CourseDuration - 1, @CurrentCourseStart);

            -- On the last course, ensure it ends exactly on the Intake_End_Date to handle remainders
            IF @Course_i = @TotalCourses
                SET @CurrentCourseEnd = @Intake_End_Date;
            
            INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
            VALUES (@StudentID, @CurrentCourse_ID, @CurrentCourseStart, @CurrentCourseEnd);

            -- Set start for next course
            SET @CurrentCourseStart = DATEADD(DAY, 1, @CurrentCourseEnd);
            SET @Course_i = @Course_i + 1;
        END;

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.10. INSERT Certificates (Random 0-3)
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @NumCerts = CAST(RAND() * 4 AS INT);
        SET @Cert_i = 0;
        WHILE @Cert_i < @NumCerts
        BEGIN
            SET @CertID = @CurrentCertID;
            SET @CertName = (SELECT TOP 1 Name FROM @CertNames_BA ORDER BY NEWID());
            SET @CertProvider = (SELECT TOP 1 Name FROM @CertProviders ORDER BY NEWID());
            SET @CertCost = CAST(RAND() * 500 AS DECIMAL(12,2)); -- BA certs vary
            SET @CertDate = DATEADD(DAY, RAND() * @TotalDuration, @Intake_Start_Date); -- Date during intake

            INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
            VALUES (@CertID, @StudentID, @CertName, @CertProvider, @CertCost, @CertDate);

            SET @CurrentCertID = @CurrentCertID + 1;
            SET @Cert_i = @Cert_i + 1;
        END;

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.11. INSERT Freelance_Job (Random 0-4)
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @NumJobs = CAST(RAND() * 5 AS INT);
        SET @Job_i = 0;
        WHILE @Job_i < @NumJobs
        BEGIN
            SET @JobID = @CurrentJobID;
            SET @JobSite = (SELECT TOP 1 Name FROM @FreelanceSites ORDER BY NEWID());
            SET @JobDesc = (SELECT TOP 1 Name FROM @FreelanceJobs_BA ORDER BY NEWID());
            SET @JobEarn = CAST(RAND() * 1000 + 50 AS DECIMAL(12,2));
            SET @JobDate = DATEADD(DAY, RAND() * @TotalDuration, @Intake_Start_Date); -- Date during intake

            INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
            VALUES (@JobID, @StudentID, @JobEarn, @JobDate, @JobSite, @JobDesc);

            SET @CurrentJobID = @CurrentJobID + 1;
            SET @Job_i = @Job_i + 1;
        END;

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.12. INSERT Student_Company (IF Graduated & Hired)
        -- -- -- -- -- -- -- -- -- -- -- --
        IF @Status = N'Graduated' AND @Hired = 1
        BEGIN
            SET @CompanyID = (SELECT TOP 1 ID FROM @Companies_BA ORDER BY NEWID());
            SET @Position = (SELECT TOP 1 Name FROM @Positions_BA ORDER BY NEWID());
            SET @Contract = CASE WHEN RAND() > 0.7 THEN N'Full-Time' ELSE N'Part-Time' END;
            
            -- Full-Time (8k-16k) > Part-Time (4k-8k)
            SET @Salary = CASE @Contract
                WHEN N'Full-Time' THEN CAST(RAND() * 8000 + 8000 AS DECIMAL(12,2))
                ELSE CAST(RAND() * 4000 + 4000 AS DECIMAL(12,2))
            END;
            
            -- Hire date is random, between graduation and today
            SET @HireDate = DATEADD(DAY, RAND() * DATEDIFF(DAY, @Intake_End_Date, GETDATE()), @Intake_End_Date);

            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            VALUES (@StudentID, @CompanyID, @Salary, @Position, @Contract, @HireDate, NULL); -- Leave_Date is NULL
        END;

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.13. Increment Counters
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @StudentCounter = @StudentCounter + 1;
        SET @CurrentID = @CurrentID + 1;

    END; -- End Student Loop

    FETCH NEXT FROM IBT_Cursor INTO @IBT_ID, @Intake_ID, @Branch_ID, @Track_ID, @Intake_Start_Date, @Intake_End_Date, @Branch_Location;
END; -- End IBT Loop

-- =============================================================================
-- 5. CLEANUP
-- =============================================================================
CLOSE IBT_Cursor;
DEALLOCATE IBT_Cursor;

COMMIT TRANSACTION;
SET NOCOUNT OFF;

PRINT 'Successfully populated database for Track 25 (Business Analysis).';
PRINT 'Total Students Inserted: ' + CAST((@CurrentID - 48000) AS VARCHAR(10));
PRINT 'Next Student_ID to use: ' + CAST(@CurrentID AS VARCHAR(10));
PRINT 'Next Job_ID to use: ' + CAST(@CurrentJobID AS VARCHAR(10));
PRINT 'Next Certificate_ID to use: ' + CAST(@CurrentCertID AS VARCHAR(10));