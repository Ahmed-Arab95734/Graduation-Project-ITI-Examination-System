/********************************************************************************
* RUN SCRIPT
* Description: Populates Student and related tables for Track 'Business Analysis and Intelligent Automation Development' (ID 26)
* Start IDs: 50000 for Student, Job, and Certificate
* Students per IBT: 25
*
* Rules Enforced:
* 1.  Only for Track_ID 26.
* 2.  25 Students per Intake_Branch_Track (IBT).
* 3.  Unique IDs starting from 50000.
* 4.  Egyptian Names (Male/Female).
* 5.  Branch-proximal Egyptian addresses (20+ governorates).
* 6.  Email format: [name][id]@iti.
* 7.  Unique Egyptian phone numbers.
* 8.  Social links include student name.
* 9.  Faculties weighted towards CompSci/Eng and Business/Comm/IS/Econ.
* 10. ITI Status ('Graduated', 'Failed to Graduate', 'In Progress') based on Intake_End_Date vs GETDATE().
* 11. 'In Progress' students have NO company data.
* 12. 'Graduated' students (and not 'Failed') have a *chance* to be hired.
* 13. Hiring priority: Smart Village > Cairo Uni > New Capital > Alex > Rest.
* 14. Hire dates are post-graduation.
* 15. Salaries: Full-Time > Part-Time.
* 16. Positions, Companies, Certs, Freelance jobs are relevant to 'BA & Intelligent Automation'.
* 17. Certs/Freelance jobs dated *during* the intake period.
* 18. Student_Course table populated sequentially for all 12 track courses.
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
-- Faculties (Weighted) - Adjusted for BA & Automation
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
-- Track-Specific Data: BA & Intelligent Automation (Track 26)
-- -- -- -- -- -- -- -- -- -- -- --
DECLARE @TrackCourses TABLE (RN INT, Course_ID INT);
INSERT INTO @TrackCourses (RN, Course_ID)
SELECT ROW_NUMBER() OVER (ORDER BY Course_ID), Course_ID
FROM Track_Course WHERE Track_ID = 26;

DECLARE @Companies_BAIA TABLE (ID INT);
INSERT INTO @Companies_BAIA VALUES
(3), (4), (6), (8), (10), (11), (13), (14), (21), (22), (23), (24), (27), (28), (29), (30), (42), (47), (48); -- Consultancies (Accenture, Big4, Capgemini), Banks (CIB, NBE, Misr), Telecom (VOIS, Orange, WE, Etisalat), Finance (e-finance), Tech Services (Kyndryl, Atos), Raya, Fawry

DECLARE @Positions_BAIA TABLE (Name NVARCHAR(100));
INSERT INTO @Positions_BAIA VALUES
(N'RPA Business Analyst'), (N'Automation Analyst'), (N'Intelligent Automation Consultant'), (N'Process Automation Specialist'),
(N'Junior RPA Developer'), (N'Business Analyst (Automation Focus)'), (N'Process Improvement Analyst'), (N'UiPath Developer');

DECLARE @CertProviders TABLE (Name NVARCHAR(200));
INSERT INTO @CertProviders VALUES (N'Udemy'), (N'Coursera'), (N'Udacity'), (N'Mahara Tech'), (N'DataCamp'), (N'Microsoft'), (N'IIBA'), (N'UiPath'), (N'Automation Anywhere'); -- Added RPA Vendors

DECLARE @CertNames_BAIA TABLE (Name NVARCHAR(200));
INSERT INTO @CertNames_BAIA VALUES
(N'UiPath Certified RPA Associate (UiRPA)'), (N'UiPath Certified Advanced RPA Developer (UiARD) Prep'), (N'IIBA ECBA Prep'),
(N'Automation Anywhere Certified Advanced RPA Professional'), (N'Business Process Analysis for Automation'), (N'Intelligent Document Processing Fundamentals');

DECLARE @FreelanceSites TABLE (Name NVARCHAR(255));
INSERT INTO @FreelanceSites VALUES (N'Upwork'), (N'Freelancer'), (N'LinkedIn'), (N'Khamsat'), (N'Mostaql');

DECLARE @FreelanceJobs_BAIA TABLE (Name NVARCHAR(1000));
INSERT INTO @FreelanceJobs_BAIA VALUES
(N'Created a Process Design Document (PDD) for automating invoice processing.'), (N'Developed a simple UiPath bot to scrape web data.'),
(N'Analyzed customer service emails to identify automation opportunities.'), (N'Documented AS-IS and TO-BE process flows for HR onboarding.'),
(N'Built an attended bot to assist data entry clerks.'), (N'Tested and debugged an existing RPA workflow.'),
(N'Calculated potential ROI for automating a finance process.'), (N'Created user stories for RPA development backlog.'),
(N'Configured UiPath Orchestrator triggers and queues.'), (N'Developed a proof-of-concept bot for PDF data extraction.'),
(N'Interviewed SMEs to understand manual process steps.'), (N'Created documentation for a deployed RPA solution.'),
(N'Used UiPath StudioX for a simple automation task.'), (N'Analyzed process bottlenecks using process mining concepts.'),
(N'Designed exception handling for an unattended bot.');


-- =============================================================================
-- 2. DECLARE CURSOR AND LOOP VARIABLES
-- =============================================================================
DECLARE @CurrentID INT = 50000;
DECLARE @CurrentJobID INT = 50000;
DECLARE @CurrentCertID INT = 50000;
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
        IBT.Track_ID = 26; -- <<<<<<< ONLY 'BA & Intelligent Automation'

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
        SET @Birthdate = DATEADD(DAY, - (7300 + (RAND() * 5475)), GETDATE());
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
        -- 4.3. Generate Weighted Faculty (Adjusted for BA/IA)
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @FacultyRand = RAND();
        IF @FacultyRand < 0.35 -- 35% chance Tech (CS/Eng)
             SET @Faculty = (SELECT TOP 1 Name FROM @TechFaculties ORDER BY NEWID());
        ELSE IF @FacultyRand < 0.65 -- 30% chance Business/Commerce/IS/Econ (total 65%)
            SET @Faculty = (SELECT TOP 1 Name FROM @BusinessFaculties ORDER BY NEWID());
        ELSE -- 35% chance Others
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
      --(@StudentID, N'GitHub', N'https://github.com/' + LOWER(REPLACE(@Fname, ' ', '')) + LOWER(REPLACE(@Lname, ' ', '')) + CAST(@StudentID % 1000 AS VARCHAR(4))), -- Maybe slightly relevant for RPA dev part
        (@StudentID, N'Facebook', N'https://facebook.com/' + LOWER(REPLACE(@Fname, ' ', '.')) + '.' + LOWER(REPLACE(@Lname, ' ', '.')) + CAST(@StudentID % 1000 AS VARCHAR(4)));

        -- -- -- -- -- -- -- -- -- -- -- --
        -- 4.9. INSERT Student_Course (Sequential)
        -- -- -- -- -- -- -- -- -- -- -- --
        SET @Course_i = 1;
        SET @CurrentCourseStart = @Intake_Start_Date;

        WHILE @Course_i <= @TotalCourses
        BEGIN
            SELECT @CurrentCourse_ID = Course_ID FROM @TrackCourses WHERE RN = @Course_i;
            
            SET @CurrentCourseEnd = DATEADD(DAY, @CourseDuration - 1, @CurrentCourseStart);
            IF @Course_i = @TotalCourses
                SET @CurrentCourseEnd = @Intake_End_Date;
            
            INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
            VALUES (@StudentID, @CurrentCourse_ID, @CurrentCourseStart, @CurrentCourseEnd);

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
            SET @CertName = (SELECT TOP 1 Name FROM @CertNames_BAIA ORDER BY NEWID());
            SET @CertProvider = (SELECT TOP 1 Name FROM @CertProviders ORDER BY NEWID());
            SET @CertCost = CAST(RAND() * 500 AS DECIMAL(12,2)); -- RPA Certs often have costs
            SET @CertDate = DATEADD(DAY, RAND() * @TotalDuration, @Intake_Start_Date);

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
            SET @JobDesc = (SELECT TOP 1 Name FROM @FreelanceJobs_BAIA ORDER BY NEWID());
            SET @JobEarn = CAST(RAND() * 1000 + 50 AS DECIMAL(12,2));
            SET @JobDate = DATEADD(DAY, RAND() * @TotalDuration, @Intake_Start_Date);

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
            SET @CompanyID = (SELECT TOP 1 ID FROM @Companies_BAIA ORDER BY NEWID());
            SET @Position = (SELECT TOP 1 Name FROM @Positions_BAIA ORDER BY NEWID());
            SET @Contract = CASE WHEN RAND() > 0.7 THEN N'Full-Time' ELSE N'Part-Time' END;
            
            -- Full-Time (9.5k-19k) > Part-Time (5k-9.5k)
            SET @Salary = CASE @Contract
                WHEN N'Full-Time' THEN CAST(RAND() * 9500 + 9500 AS DECIMAL(12,2))
                ELSE CAST(RAND() * 4500 + 5000 AS DECIMAL(12,2))
            END;
            
            SET @HireDate = DATEADD(DAY, RAND() * DATEDIFF(DAY, @Intake_End_Date, GETDATE()), @Intake_End_Date);

            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            VALUES (@StudentID, @CompanyID, @Salary, @Position, @Contract, @HireDate, NULL);
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

PRINT 'Successfully populated database for Track 26 (Business Analysis and Intelligent Automation Development).';
PRINT 'Total Students Inserted: ' + CAST((@CurrentID - 50000) AS VARCHAR(10));
PRINT 'Next Student_ID to use: ' + CAST(@CurrentID AS VARCHAR(10));
PRINT 'Next Job_ID to use: ' + CAST(@CurrentJobID AS VARCHAR(10));
PRINT 'Next Certificate_ID to use: ' + CAST(@CurrentCertID AS VARCHAR(10));