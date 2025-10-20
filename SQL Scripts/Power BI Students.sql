/*
================================================================================
SQL SCRIPT TO POPULATE STUDENT DATA FOR 'Power BI Development' TRACK
================================================================================
This script will:
1.  Define temporary data pools (names, addresses, faculties, etc.).
2.  Identify all 'Power BI Development' tracks across all intakes and branches.
3.  Loop through each of these tracks and generate 25 students for each.
4.  Apply all business logic:
    - Status ('Graduated' vs 'In Progress') based on GETDATE().
    - Weighted faculty selection (Computer Science, Engineering).
    - Address proximity to the branch location.
    - Unique phone numbers and formatted emails/social links.
    - Conditional job placement for 'Graduated' students with weighted hiring by branch.
    - Generation of related certificates, freelance jobs, and course enrollments.
================================================================================
*/
SET NOCOUNT ON;
DECLARE @CurrentDate DATE = GETDATE(); -- Use today's date (Oct 19, 2025) to determine status

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

-- B. Faculties (Weighted)
CREATE TABLE #Faculties (FacultyName NVARCHAR(100), Weight INT);
INSERT INTO #Faculties (FacultyName, Weight) VALUES
(N'Faculty of Computers Sciences', 1),
(N'Faculty of Computers Sciences', 1),
(N'Faculty of Computers Sciences', 1),
(N'Faculty of Computers Sciences', 1),
(N'Faculty of Engineering', 2),
(N'Faculty of Engineering', 2),
(N'Faculty of Engineering', 2),
(N'Faculty of Science', 3),
(N'Faculty of Commerce', 3),
(N'Faculty of Business Administration', 3),
(N'Faculty of Information Systems', 3),
(N'Faculty of Education', 3),
(N'Faculty of Economics and Political Science', 3),
(N'Faculty of Agriculture', 3),
(N'Faculty of Fine Arts', 3),
(N'Faculty of Applied Arts', 3),
(N'Faculty of Arts', 3);

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
(N'Aswan', N'Aswan'), (N'Aswan', N'Luxor'), (N'Aswan', N'Red Sea'),
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

-- E. Track-Specific Data (Power BI Development, Track_ID = 1)
CREATE TABLE #JobPositions (Position NVARCHAR(100));
INSERT INTO #JobPositions (Position) VALUES
(N'Power BI Developer'), (N'Data Analyst'), (N'BI Analyst'), (N'Business Intelligence Developer'),
(N'Data Visualization Specialist'), (N'Junior BI Consultant'), (N'Report Developer'), (N'BI Engineer');

CREATE TABLE #Certificates (CertName NVARCHAR(200));
INSERT INTO #Certificates (CertName) VALUES
(N'Microsoft Certified: Power BI Data Analyst Associate (PL-300)'),
(N'Data Visualization with Power BI'),
(N'Advanced DAX for Power BI'),
(N'Power Query for Data Transformation and Modeling'),
(N'Enterprise Data Analysis with Power BI'),
(N'SQL for Data Analysts');

CREATE TABLE #Providers (ProviderName NVARCHAR(200));
INSERT INTO #Providers (ProviderName) VALUES
(N'Udemy'), (N'Coursera'), (N'Udacity'), (N'DataCamp'), (N'Microsoft'), (N'Mahara Tech'), (N'LinkedIn Learning');

CREATE TABLE #FreelanceJobs (JobDesc NVARCHAR(1000));
INSERT INTO #FreelanceJobs (JobDesc) VALUES
(N'Develop an interactive sales dashboard from Excel files.'),
(N'Optimize existing DAX measures for a slow-performing report.'),
(N'Clean and model data from multiple sources using Power Query.'),
(N'Build a complete financial report (P&L, Balance Sheet) in Power BI.'),
(N'Set up Power BI workspace, security roles, and data gateway.'),
(N'Create a custom Power BI theme and visualization template.'),
(N'Migrate QlikView/Tableau reports to Power BI.'),
(N'Consult on best practices for Power BI data modeling (Star Schema).'),
(N'Embed Power BI reports into a custom web application.'),
(N'Develop a KPI dashboard for executive management.'),
(N'Analyze marketing campaign data and build a performance report.'),
(N'Create a real-time streaming dashboard using Power BI.'),
(N'Automate data refresh and distribution of Power BI reports.'),
(N'Provide 1-on-1 Power BI training for a small team.'),
(N'Build a human resources (HR) analytics dashboard.');

CREATE TABLE #FreelanceSites (SiteName NVARCHAR(255));
INSERT INTO #FreelanceSites (SiteName) VALUES
(N'Upwork'), (N'Freelancer'), (N'LinkedIn'), (N'Khamsat'), (N'Mostaql');

-- F. Phone Number Tracking
CREATE TABLE #UsedPhones (Phone NVARCHAR(20) PRIMARY KEY);

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
WHERE T.Track_Name = N'Power BI Development';

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
WHERE TC.Track_ID = 1; -- Track_ID for 'Power BI Development' is 1

-- ============================================================================
-- STEP 4: DECLARE COUNTERS & CURSOR
-- ============================================================================

-- Global counters starting at 1
DECLARE @StudentIDCounter INT = 1;
DECLARE @JobIDCounter INT = 1;
DECLARE @CertIDCounter INT = 1;

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

        -- 2. Generate Address (Weighted by Branch Location)
        DECLARE @StudentGov NVARCHAR(100);
        IF RAND() < 0.7 -- 70% chance to be from a "near" governorate
            SET @StudentGov = (SELECT TOP 1 Governorate FROM #BranchGovernorates WHERE Branch_Location = @BranchLocation ORDER BY NEWID());
        ELSE -- 30% chance to be from any random governorate
            SET @StudentGov = (SELECT TOP 1 Governorate FROM #AllGovernorates ORDER BY NEWID());
        
        DECLARE @StudentAddress NVARCHAR(255) = N'123 Random St, ' + @StudentGov;

        -- 3. Generate Faculty (Weighted)
        DECLARE @StudentFaculty NVARCHAR(100);
        DECLARE @FacultyWeight INT = 1 + (ABS(CHECKSUM(NEWID())) % 3); -- 1 (CS), 2 (Eng), 3 (Other)
        
        IF @FacultyWeight = 1
            SET @StudentFaculty = N'Faculty of Computers Sciences';
        ELSE IF @FacultyWeight = 2
            SET @StudentFaculty = N'Faculty of Engineering';
        ELSE
            SET @StudentFaculty = (SELECT TOP 1 FacultyName FROM #Faculties WHERE Weight = 3 ORDER BY NEWID());

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
                                CAST(CAST(RAND() * 100000000 AS INT) AS NVARCHAR(8));
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
        DECLARE @CourseDuration INT = CASE WHEN @CourseCount > 0 THEN @TotalDays / @CourseCount ELSE 0 END;
        
        DECLARE @Course_ID INT;
        DECLARE course_cursor CURSOR FOR 
        SELECT Course_ID FROM #TrackCourses ORDER BY OrderNum;

        OPEN course_cursor;
        FETCH NEXT FROM course_cursor INTO @Course_ID;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @CourseEndDate DATE = DATEADD(DAY, @CourseDuration, @CourseLoopDate);
            -- Ensure last course ends exactly on the end date
            IF (SELECT COUNT(*) FROM #TrackCourses WHERE OrderNum = @CourseCount) > 0 AND @Course_ID = (SELECT Course_ID FROM #TrackCourses WHERE OrderNum = @CourseCount)
                SET @CourseEndDate = @EndDate;

            INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
            VALUES (@StudentIDCounter, @Course_ID, @CourseLoopDate, @CourseEndDate);
            
            SET @CourseLoopDate = DATEADD(DAY, 1, @CourseEndDate); -- Next course starts the day after
            
            FETCH NEXT FROM course_cursor INTO @Course_ID;
        END
        CLOSE course_cursor;
        DEALLOCATE course_cursor;

        -- 9. INSERT into Certificate (Randomly during intake)
        DECLARE @NumCerts INT = 1 + (ABS(CHECKSUM(NEWID())) % 3); -- 1 to 3 certs
        DECLARE @CertCounter INT = 0;
        WHILE @CertCounter < @NumCerts
        BEGIN
            DECLARE @CertDate DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % @TotalDays, @StartDate);
            INSERT INTO Certificate (
                Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, 
                Certificate_Cost, Certificate_Date
            ) VALUES (
                @CertIDCounter, @StudentIDCounter,
                (SELECT TOP 1 CertName FROM #Certificates ORDER BY NEWID()),
                (SELECT TOP 1 ProviderName FROM #Providers ORDER BY NEWID()),
                CAST(RAND() * 500 AS DECIMAL(12,2)), -- 0 to 500
                @CertDate
            );
            SET @CertIDCounter = @CertIDCounter + 1;
            SET @CertCounter = @CertCounter + 1;
        END

        -- 10. INSERT into Freelance_Job (Randomly during intake)
        DECLARE @NumJobs INT = (ABS(CHECKSUM(NEWID())) % 5); -- 0 to 4 jobs
        DECLARE @JobCounter INT = 0;
        WHILE @JobCounter < @NumJobs
        BEGIN
            DECLARE @JobDate DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % @TotalDays, @StartDate);
            INSERT INTO Freelance_Job (
                Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description
            ) VALUES (
                @JobIDCounter, @StudentIDCounter,
                CAST((RAND() * 500) + 50 AS DECIMAL(12,2)), -- 50 to 550
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
            -- Determine hiring chance based on branch
            DECLARE @HireChance FLOAT = 0.3; -- Base chance
            IF @BranchName = N'Smart Village' SET @HireChance = 0.7;
            ELSE IF @BranchName = N'Cairo University' SET @HireChance = 0.6;
            ELSE IF @BranchName = N'New Capital' SET @HireChance = 0.5;
            ELSE IF @BranchName = N'Alexandria' SET @HireChance = 0.4;

            IF RAND() < @HireChance
            BEGIN
                DECLARE @ContractType NVARCHAR(50) = IIF(RAND() < 0.7, N'Full-Time', N'Part-Time'); -- 70% Full-Time
                DECLARE @Salary DECIMAL(12,2);
                
                IF @ContractType = N'Full-Time'
                    SET @Salary = CAST((RAND() * 8000) + 7000 AS DECIMAL(12,2)); -- 7k to 15k
                ELSE
                    SET @Salary = CAST((RAND() * 3000) + 3000 AS DECIMAL(12,2)); -- 3k to 6k

                DECLARE @Position NVARCHAR(100) = (SELECT TOP 1 Position FROM #JobPositions ORDER BY NEWID());
                DECLARE @CompanyID INT = (SELECT TOP 1 Company_ID FROM Company ORDER BY NEWID());
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
DROP TABLE #UsedPhones;
DROP TABLE #TargetIBTs;
DROP TABLE #TrackCourses;

PRINT 'Successfully populated tables with 25 students for each ''Power BI Development'' track.';