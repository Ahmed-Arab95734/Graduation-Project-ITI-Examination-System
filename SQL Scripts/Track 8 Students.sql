/*
================================================================================
SQL SCRIPT TO POPULATE STUDENT DATA FOR 'Software Development Fundamentals' TRACK
================================================================================
This script will:
1.  Define temporary data pools (names, addresses, faculties, etc.).
2.  Set all new primary key counters (Student, Job, Certificate) to start at 14000.
3.  Identify all 'Software Development Fundamentals' tracks.
4.  Loop through each track and generate 25 students.
5.  Apply all business logic:
    - Status ('Graduated' vs 'In Progress') based on '2025-10-19'.
    - Weighted faculty selection (CS > Eng > Others).
    - Address as just the governorate, weighted for proximity.
    - Unique phone numbers, formatted emails/social links.
    - Conditional job placement for 'Graduated' students (weighted by branch).
    - Relevant certificates, freelance jobs, and course enrollments.
================================================================================
*/
SET NOCOUNT ON;
-- Per user context, the current date is October 19, 2025
DECLARE @CurrentDate DATE = '2025-10-19'; 

-- ============================================================================
-- STEP 1: CREATE TEMPORARY DATA POOLS
-- ============================================================================

-- A. Names
CREATE TABLE #MaleNames (Fname NVARCHAR(50));
INSERT INTO #MaleNames (Fname) VALUES
(N'Ahmed'), (N'Mohamed'), (N'Mahmoud'), (N'Youssef'), (N'Mostafa'), (N'Omar'), (N'Ali'),
(N'Khaled'), (N'Ibrahim'), (N'Tarek'), (N'Hassan'), (N'Hussein'), (N'Amr'), (N'Karim');

CREATE TABLE #FemaleNames (Fname NVARCHAR(50));
INSERT INTO #FemaleNames (Fname) VALUES
(N'Fatma'), (N'Mariam'), (N'Aya'), (N'Hana'), (N'Nour'), (N'Salma'), (N'Menna'),
(N'Sarah'), (N'Yara'), (N'Mona'), (N'Hoda'), (N'Eman'), (N'Asmaa'), (N'Habiba');

CREATE TABLE #LastNames (Lname NVARCHAR(50));
INSERT INTO #LastNames (Lname) VALUES
(N'Ali'), (N'Hassan'), (N'Ibrahim'), (N'Salah'), (N'Mansour'), (N'Elsayed'), (N'Taha'),
(N'Kamel'), (N'Fathy'), (N'Adel'), (N'Rady'), (N'Gaber'), (N'Farouk'), (N'Shalaby');

-- B. Faculties (Weighted for SW Fundamentals: CS > Eng > Others)
CREATE TABLE #Faculties (FacultyName NVARCHAR(100));
INSERT INTO #Faculties (FacultyName) VALUES
(N'Faculty of Computers Sciences'), (N'Faculty of Computers Sciences'), (N'Faculty of Computers Sciences'), (N'Faculty of Computers Sciences'), (N'Faculty of Computers Sciences'), -- 5 (Most)
(N'Faculty of Engineering'), (N'Faculty of Engineering'), (N'Faculty of Engineering'), (N'Faculty of Engineering'), -- 4 (Second)
(N'Faculty of Information Systems'), (N'Faculty of Information Systems'), -- 2 (Relevant)
(N'Faculty of Science'), (N'Faculty of Commerce'), (N'Faculty of Business Administration'), (N'Faculty of Education'), 
(N'Faculty of Economics and Political Science'), (N'Faculty of Agriculture'), (N'Faculty of Fine Arts'), (N'Faculty of Applied Arts'), (N'Faculty of Arts'); -- 9 Others

-- C. Addresses (Governorates)
CREATE TABLE #AllGovernorates (Governorate NVARCHAR(100));
INSERT INTO #AllGovernorates (Governorate) VALUES
(N'Cairo'), (N'Giza'), (N'Alexandria'), (N'Dakahlia'), (N'Red Sea'), (N'Beheira'), (N'Fayoum'),
(N'Gharbia'), (N'Ismailia'), (N'Menoufia'), (N'Minya'), (N'Qalyubia'), (N'New Valley'), (N'Suez'),
(N'Aswan'), (N'Assiut'), (N'Beni Suef'), (N'Port Said'), (N'Kafr El Sheikh'), (N'Luxor'), (N'Qena'),
(N'North Sinai'), (N'Sohag'), (N'Damietta'), (N'Sharqia'), (N'Matrouh'), (N'South Sinai');

-- D. Branch to Governorate Mapping (for proximity)
CREATE TABLE #BranchGovernorates (Branch_Location NVARCHAR(100), Governorate NVARCHAR(100));
INSERT INTO #BranchGovernorates (Branch_Location, Governorate) VALUES
(N'Giza', N'Giza'), (N'Giza', N'Cairo'), (N'Giza', N'Qalyubia'),
(N'Alexandria', N'Alexandria'), (N'Alexandria', N'Beheira'), (N'Alexandria', N'Matrouh'),
(N'Assiut', N'Assiut'), (N'Assiut', N'Minya'), (N'Assiut', N'Sohag'),
(N'El Mansoura', N'Dakahlia'), (N'El Mansoura', N'Damietta'), (N'El Mansoura', N'Sharqia'),
(N'Ismailia', N'Ismailia'), (N'Ismailia', N'Port Said'), (N'Ismailia', N'Suez'), (N'Ismailia', N'North Sinai'),
(N'El Menoufia', N'Menoufia'), (N'El Menoufia', N'Gharbia'), (N'El Menoufia', N'Qalyubia'),
(N'El Minia', N'Minya'), (N'El Minia', N'Beni Suef'), (N'El Minia', N'Assiut'),
(N'Sohag', N'Sohag'), (N'Sohag', N'Qena'), (N'Sohag', N'Assiut'),
(N'Qena', N'Qena'), (N'Qena', N'Luxor'), (N'Qena', N'Red Sea'),
(N'Aswan', N'Aswan'), (N'Aswan', 'Luxor'), (N'Aswan', N'Red Sea'),
(N'New Capital', N'Cairo'), (N'New Capital', N'Giza'), (N'New Capital', N'Suez'),
(N'New Valley', N'New Valley'), (N'New Valley', N'Matrouh'), (N'New Valley', N'Assiut'),
(N'Beni Sweif', N'Beni Suef'), (N'Beni Sweif', N'Fayoum'), (N'Beni Sweif', N'Minya'), (N'Beni Sweif', N'Giza'),
(N'Benha', N'Qalyubia'), (N'Benha', N'Sharqia'), (N'Benha', N'Menoufia'), (N'Benha', N'Cairo'),
(N'El Fayoum', N'Fayoum'), (N'El Fayoum', N'Beni Suef'), (N'El Fayoum', N'Giza'),
(N'Port Said', N'Port Said'), (N'Port Said', N'Ismailia'), (N'Port Said', N'Damietta'), (N'Port Said', N'North Sinai'),
(N'Al Arish', N'North Sinai'), (N'Al Arish', N'Ismailia'),
(N'Zagazig', N'Sharqia'), (N'Zagazig', N'Dakahlia'), (N'Zagazig', N'Ismailia'), (N'Zagazig', N'Qalyubia'),
(N'Damanhour', N'Beheira'), (N'Damanhour', N'Alexandria'), (N'Damanhour', N'Kafr El Sheikh'),
(N'Tanta', N'Gharbia'), (N'Tanta', N'Menoufia'), (N'Tanta', N'Kafr El Sheikh'), (N'Tanta', N'Dakahlia');

-- E. Track-Specific Data (Software Development Fundamentals, Track_ID = 8)
CREATE TABLE #JobPositions (Position NVARCHAR(100));
INSERT INTO #JobPositions (Position) VALUES
(N'Junior Software Developer'), (N'Trainee Software Engineer'), (N'Entry-Level C# Developer'), 
(N'Junior Web Developer (Backend Focus)'), (N'Database Assistant'), (N'Entry-Level Programmer'), 
(N'Technical Support Engineer'), (N'Application Support Analyst');

CREATE TABLE #Certificates (CertName NVARCHAR(200));
INSERT INTO #Certificates (CertName) VALUES
(N'MTA: Software Development Fundamentals (98-361)'), -- Microsoft
(N'C# Basics for Beginners'), 
(N'Introduction to SQL'), 
(N'Data Structures and Algorithms Fundamentals'), 
(N'Web Development Basics (HTML, CSS, JavaScript)'), 
(N'Git Essential Training');

CREATE TABLE #Providers (ProviderName NVARCHAR(200));
INSERT INTO #Providers (ProviderName) VALUES
(N'Udemy'), (N'Coursera'), (N'Udacity'), (N'DataCamp'), (N'Microsoft'), (N'Mahara Tech'), 
(N'LinkedIn Learning'), (N'Pluralsight');

CREATE TABLE #FreelanceJobs (JobDesc NVARCHAR(1000));
INSERT INTO #FreelanceJobs (JobDesc) VALUES
(N'Build a simple C# console application for basic calculations.'),
(N'Create a static HTML/CSS webpage based on a provided image.'),
(N'Write basic SQL SELECT queries to retrieve data from a sample database.'),
(N'Debug and fix errors in a small C# code snippet.'),
(N'Implement a basic algorithm (e.g., sorting) in C#.'),
(N'Set up a Git repository for a small project and perform basic commits.'),
(N'Create a simple web form with HTML and basic JavaScript validation.'),
(N'Write documentation for a simple C# function.'),
(N'Develop a basic Windows Forms application with buttons and text boxes.'),
(N'Query a database to generate a simple report.'),
(N'Create a C# class representing a real-world object (e.g., Car, Book).'),
(N'Build a simple number guessing game in C# console.'),
(N'Design a basic database schema (ERD) for a small application.'),
(N'Write SQL INSERT and UPDATE statements.'),
(N'Explain a fundamental OOP concept (e.g., Encapsulation) with code examples.');

CREATE TABLE #FreelanceSites (SiteName NVARCHAR(255));
INSERT INTO #FreelanceSites (SiteName) VALUES
(N'Upwork'), (N'Freelancer'), (N'LinkedIn'), (N'Khamsat'), (N'Mostaql');

-- F. Relevant Companies for SW Fundamentals (Broad applicability)
CREATE TABLE #RelevantCompanies (Company_ID INT);
-- Most tech companies, consultancies, banks, and large national companies hire entry-level roles.
INSERT INTO #RelevantCompanies (Company_ID) 
SELECT Company_ID FROM Company 
WHERE Company_Type IN (N'Multinational', N'National') 
AND Company_ID NOT IN (54); -- Exclude EGAS as less relevant

-- G. Phone Number Tracking
CREATE TABLE #UsedPhones (Phone NVARCHAR(20) PRIMARY KEY);
-- This table ensures phone uniqueness across the entire script run.

-- ============================================================================
-- STEP 2: IDENTIFY TARGET INTAKE-BRANCH-TRACKS (IBTs)
-- ============================================================================

CREATE TABLE #TargetIBTs (
    Intake_Branch_Track_ID INT,
    Intake_ID INT,
    Branch_ID INT,
    Track_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    Branch_Location NVARCHAR(100),
    Branch_Name NVARCHAR(100)
);

INSERT INTO #TargetIBTs
SELECT 
    IBT.Intake_Branch_Track_ID,
    I.Intake_ID,
    B.Branch_ID,
    T.Track_ID,
    I.Intake_Start_Date,
    I.Intake_End_Date,
    B.Branch_Location,
    B.Branch_Name
FROM Intake_Branch_Track IBT
JOIN Track T ON IBT.Track_ID = T.Track_ID
JOIN Intake I ON IBT.Intake_ID = I.Intake_ID
JOIN Branch B ON IBT.Branch_ID = B.Branch_ID
WHERE T.Track_Name = N'Software Development Fundamentals'; -- Track_ID = 8

-- ============================================================================
-- STEP 3: IDENTIFY TARGET COURSES FOR THE TRACK
-- ============================================================================

CREATE TABLE #TrackCourses (
    Course_ID INT,
    Course_Name NVARCHAR(200),
    OrderNum INT
);

INSERT INTO #TrackCourses (Course_ID, Course_Name, OrderNum)
SELECT 
    C.Course_ID, 
    C.Course_Name,
    ROW_NUMBER() OVER(ORDER BY C.Course_ID) -- Order by ID to get a consistent sequence
FROM Track_Course TC
JOIN Course C ON TC.Course_ID = C.Course_ID
WHERE TC.Track_ID = 8; -- Track_ID for 'Software Development Fundamentals' is 8

-- ============================================================================
-- STEP 4: DECLARE COUNTERS & CURSOR
-- ============================================================================

-- Global counters starting at 14000
DECLARE @StudentIDCounter INT = 14000;
DECLARE @JobIDCounter INT = 14000;
DECLARE @CertIDCounter INT = 14000;

-- Cursor variables
DECLARE @IBT_ID INT;
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
DECLARE @BranchLocation NVARCHAR(100);
DECLARE @BranchName NVARCHAR(100);
DECLARE @ITI_Status_Pool NVARCHAR(50); -- 'Graduated' or 'In Progress'

DECLARE IBT_Cursor CURSOR FOR
SELECT Intake_Branch_Track_ID, Intake_Start_Date, Intake_End_Date, Branch_Location, Branch_Name
FROM #TargetIBTs;

OPEN IBT_Cursor;
FETCH NEXT FROM IBT_Cursor INTO @IBT_ID, @StartDate, @EndDate, @BranchLocation, @BranchName;

-- ============================================================================
-- STEP 5: MAIN LOOP (FOR EACH IBT)
-- ============================================================================

WHILE @@FETCH_STATUS = 0
BEGIN
    
    -- Determine if this IBT is 'Graduated' or 'In Progress' based on its end date
    IF @EndDate < @CurrentDate
        SET @ITI_Status_Pool = N'Graduated';
    ELSE
        SET @ITI_Status_Pool = N'In Progress';

    DECLARE @StudentCounter INT = 1;
    
    -- ============================================================================
    -- STEP 6: INNER LOOP (25 STUDENTS PER IBT)
    -- ============================================================================
    WHILE @StudentCounter <= 25
    BEGIN
        
        -- 1. Generate Base Student Info
        DECLARE @StudentGender NVARCHAR(10) = IIF(RAND() < 0.5, N'Male', N'Female');
        DECLARE @StudentFname NVARCHAR(50);
        DECLARE @StudentLname NVARCHAR(50) = (SELECT TOP 1 Lname FROM #LastNames ORDER BY NEWID());

        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Fname FROM #MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Fname FROM #FemaleNames ORDER BY NEWID());
        
        DECLARE @StudentMail NVARCHAR(100) = LOWER(REPLACE(@StudentFname, ' ', '')) + N'.' + LOWER(REPLACE(@StudentLname, ' ', '')) + N'.' + CAST(@StudentIDCounter AS NVARCHAR(10)) + N'@iti';
        DECLARE @StudentMaritalStatus NVARCHAR(50) = IIF(RAND() < 0.2, N'Married', N'Single');
        DECLARE @StudentBirthdate DATE = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 7300) - 1, DATEADD(YEAR, -18, @CurrentDate)); -- 18 to 38 years old

        -- 2. Generate Address (Weighted by Branch Location - Just Governorate)
        DECLARE @StudentAddress NVARCHAR(255); -- To store just governorate
        IF RAND() < 0.7 -- 70% chance to be from a "near" governorate
            SET @StudentAddress = (SELECT TOP 1 Governorate FROM #BranchGovernorates WHERE Branch_Location = @BranchLocation ORDER BY NEWID());
        ELSE -- 30% chance to be from any random governorate
            SET @StudentAddress = (SELECT TOP 1 Governorate FROM #AllGovernorates ORDER BY NEWID());
        
        -- 3. Generate Faculty (Weighted CS > Eng > Others)
        DECLARE @StudentFaculty NVARCHAR(100) = (SELECT TOP 1 FacultyName FROM #Faculties ORDER BY NEWID());
        
        DECLARE @StudentFacultyGrade NVARCHAR(50) = (SELECT TOP 1 G FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS T(G) ORDER BY NEWID());

        -- 4. Determine Final ITI Status
        DECLARE @StudentStatus NVARCHAR(50);
        IF @ITI_Status_Pool = N'Graduated'
            SET @StudentStatus = IIF(RAND() < 0.08, N'Failed to Graduate', N'Graduated'); -- 8% fail rate
        ELSE
            SET @StudentStatus = N'In Progress';

        -- 5. INSERT into Student
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, 
            Student_Faculty_Grade, Student_ITI_Status, Intake_Branch_Track_ID
        ) VALUES (
            @StudentIDCounter, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty,
            @StudentFacultyGrade, @StudentStatus, @IBT_ID
        );

        -- 6. INSERT into Student_Phone (Unique)
        DECLARE @PhoneCounter INT = 0;
        DECLARE @NumPhones INT = 1 + (ABS(CHECKSUM(NEWID())) % 2); -- 1 or 2 phones
        WHILE @PhoneCounter < @NumPhones
        BEGIN
            DECLARE @NewPhone NVARCHAR(20);
            DECLARE @IsUnique BIT = 0;
            WHILE @IsUnique = 0
            BEGIN
                SET @NewPhone = N'01' + 
                                CAST(CAST(RAND() * 3 AS INT) AS NCHAR(1)) + -- 010, 011, 012
                                FORMAT(CAST(RAND() * 100000000 AS INT), '00000000');
                IF NOT EXISTS (SELECT 1 FROM #UsedPhones WHERE Phone = @NewPhone)
                BEGIN
                    INSERT INTO #UsedPhones (Phone) VALUES (@NewPhone);
                    SET @IsUnique = 1;
                END
            END
            INSERT INTO Student_Phone (Student_ID, Phone) VALUES (@StudentIDCounter, @NewPhone);
            SET @PhoneCounter = @PhoneCounter + 1;
        END

        -- 7. INSERT into Student_Social
        DECLARE @SocialNameTag NVARCHAR(100) = LOWER(REPLACE(@StudentFname, ' ', '')) + LOWER(REPLACE(@StudentLname, ' ', '')) + CAST(@StudentIDCounter AS NVARCHAR(10));
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url) VALUES
        (@StudentIDCounter, N'LinkedIn', N'https://linkedin.com/in/' + @SocialNameTag),
        (@StudentIDCounter, N'GitHub', N'https://github.com/' + @SocialNameTag),
        (@StudentIDCounter, N'Facebook', N'https://facebook.com/' + @SocialNameTag);

        -- 8. INSERT into Student_Course (Sequentially)
        DECLARE @CourseLoopDate DATE = @StartDate;
        DECLARE @TotalDays INT = DATEDIFF(DAY, @StartDate, @EndDate);
        DECLARE @CourseCount INT = (SELECT COUNT(*) FROM #TrackCourses);
         -- Avoid division by zero, default duration to 1 day
        DECLARE @CourseDuration INT = CASE WHEN @CourseCount > 0 THEN ISNULL(NULLIF(@TotalDays / @CourseCount, 0), 1) ELSE 0 END; 
        
        DECLARE @Course_ID INT;
        DECLARE @CurrentCourseNum INT = 1;

        DECLARE course_cursor CURSOR FOR 
        SELECT Course_ID FROM #TrackCourses ORDER BY OrderNum;

        OPEN course_cursor;
        FETCH NEXT FROM course_cursor INTO @Course_ID;
        WHILE @@FETCH_STATUS = 0 AND @CourseLoopDate <= @EndDate AND @CourseDuration > 0
        BEGIN
            DECLARE @CourseEndDate DATE = DATEADD(DAY, @CourseDuration -1, @CourseLoopDate); -- Duration includes start day
            
            -- Ensure last course ends exactly on the end date
            IF @CurrentCourseNum = @CourseCount
                SET @CourseEndDate = @EndDate;

            -- Prevent course end date exceeding intake end date
            IF @CourseEndDate > @EndDate SET @CourseEndDate = @EndDate;
            
            INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
            VALUES (@StudentIDCounter, @Course_ID, @CourseLoopDate, @CourseEndDate);
            
            SET @CourseLoopDate = DATEADD(DAY, 1, @CourseEndDate); -- Next course starts the day after
            SET @CurrentCourseNum = @CurrentCourseNum + 1;
            
            FETCH NEXT FROM course_cursor INTO @Course_ID;
        END
        CLOSE course_cursor;
        DEALLOCATE course_cursor;


        -- 9. INSERT into Certificate (Randomly during intake)
        DECLARE @NumCerts INT = (ABS(CHECKSUM(NEWID())) % 3); -- 0 to 2 certs for Fundamentals
        DECLARE @CertCounter INT = 0;
        WHILE @CertCounter < @NumCerts
        BEGIN
             DECLARE @CertDate DATE = @StartDate;
             IF @TotalDays > 0 
                 SET @CertDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % @TotalDays, @StartDate);

            INSERT INTO Certificate (
                Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, 
                Certificate_Cost, Certificate_Date
            ) VALUES (
                @CertIDCounter, @StudentIDCounter,
                (SELECT TOP 1 CertName FROM #Certificates ORDER BY NEWID()),
                (SELECT TOP 1 ProviderName FROM #Providers ORDER BY NEWID()),
                CAST(RAND() * 200 + 20 AS DECIMAL(12,2)), -- 20 to 220
                @CertDate
            );
            SET @CertIDCounter = @CertIDCounter + 1;
            SET @CertCounter = @CertCounter + 1;
        END

        -- 10. INSERT into Freelance_Job (Randomly during intake)
        DECLARE @NumJobs INT = (ABS(CHECKSUM(NEWID())) % 4); -- 0 to 3 jobs for Fundamentals
        DECLARE @JobCounter INT = 0;
        WHILE @JobCounter < @NumJobs
        BEGIN
             DECLARE @JobDate DATE = @StartDate;
             IF @TotalDays > 0
                SET @JobDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % @TotalDays, @StartDate);

            INSERT INTO Freelance_Job (
                Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description
            ) VALUES (
                @JobIDCounter, @StudentIDCounter,
                CAST((RAND() * 300) + 50 AS DECIMAL(12,2)), -- 50 to 350
                @JobDate,
                (SELECT TOP 1 SiteName FROM #FreelanceSites ORDER BY NEWID()),
                (SELECT TOP 1 JobDesc FROM #FreelanceJobs ORDER BY NEWID())
            );
            SET @JobIDCounter = @JobIDCounter + 1;
            SET @JobCounter = @JobCounter + 1;
        END

        -- 11. INSERT into Student_Company (CONDITIONAL)
        IF @StudentStatus = N'Graduated'
        BEGIN
            -- Determine hiring chance based on branch (Lower base for Fundamentals)
            DECLARE @HireChance FLOAT = 0.25; -- Base chance
            IF @BranchName = N'Smart Village' SET @HireChance = 0.65;
            ELSE IF @BranchName = N'Cairo University' SET @HireChance = 0.55;
            ELSE IF @BranchName = N'New Capital' SET @HireChance = 0.45;
            ELSE IF @BranchName = N'Alexandria' SET @HireChance = 0.35;

            IF RAND() < @HireChance
            BEGIN
                DECLARE @ContractType NVARCHAR(50) = IIF(RAND() < 0.75, N'Full-Time', N'Part-Time'); -- 75% Full-Time
                DECLARE @Salary DECIMAL(12,2);
                
                IF @ContractType = N'Full-Time'
                    SET @Salary = CAST((RAND() * 7000) + 7000 AS DECIMAL(12,2)); -- 7k to 14k
                ELSE
                    SET @Salary = CAST((RAND() * 3000) + 3500 AS DECIMAL(12,2)); -- 3.5k to 6.5k

                DECLARE @Position NVARCHAR(100) = (SELECT TOP 1 Position FROM #JobPositions ORDER BY NEWID());
                -- Select from relevant companies (very broad)
                DECLARE @CompanyID INT = (SELECT TOP 1 Company_ID FROM #RelevantCompanies ORDER BY NEWID()); 
                DECLARE @HireDate DATE = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 365) + 14, @EndDate); -- 14 to 379 days after graduation

                INSERT INTO Student_Company (
                    Student_ID, Company_ID, Salary, Position, 
                    Contract_Type, Hire_Date, Leave_Date
                ) VALUES (
                    @StudentIDCounter, @CompanyID, @Salary, @Position,
                    @ContractType, @HireDate, NULL -- Leave_Date is NULL
                );
            END
        END

        -- Increment counters
        SET @StudentCounter = @StudentCounter + 1;
        SET @StudentIDCounter = @StudentIDCounter + 1;
    END

    FETCH NEXT FROM IBT_Cursor INTO @IBT_ID, @StartDate, @EndDate, @BranchLocation, @BranchName;
END

-- ============================================================================
-- STEP 7: CLEANUP
-- ============================================================================

CLOSE IBT_Cursor;
DEALLOCATE IBT_Cursor;

DROP TABLE #MaleNames;
DROP TABLE #FemaleNames;
DROP TABLE #LastNames;
DROP TABLE #Faculties;
DROP TABLE #AllGovernorates;
DROP TABLE #BranchGovernorates;
DROP TABLE #JobPositions;
DROP TABLE #Certificates;
DROP TABLE #Providers;
DROP TABLE #FreelanceJobs;
DROP TABLE #FreelanceSites;
DROP TABLE #RelevantCompanies;
DROP TABLE #UsedPhones;
DROP TABLE #TargetIBTs;
DROP TABLE #TrackCourses;

PRINT 'Successfully populated tables with 25 students for each ''Software Development Fundamentals'' track, starting IDs at 14000.';