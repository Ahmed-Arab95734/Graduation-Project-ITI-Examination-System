/*
============================================================================
== SCRIPT TO POPULATE DATA FOR TRACK 14: WEB DEVELOPMENT USING CMS
==
== STARTING IDs: 26000
== STUDENTS PER IBT: 25
== CURRENT DATE FOR STATUS: 2025-10-19
============================================================================
*/
BEGIN TRANSACTION;

-- Suppress row count messages
SET NOCOUNT ON;

-- ============================================
-- 1. DECLARATION & SETUP
-- ============================================

-- --- ID Counters ---
DECLARE @StudentID_Start INT = 26000;
DECLARE @JobID_Start INT = 26000;
DECLARE @CertID_Start INT = 26000;

DECLARE @CurrentStudentID INT = @StudentID_Start;
DECLARE @CurrentJobID INT = @JobID_Start;
DECLARE @CurrentCertID INT = @CertID_Start;

-- --- Current Date (for status logic) ---
DECLARE @CurrentDate DATE = '2025-10-19';

-- --- Temp Table for Unique Phones ---
DECLARE @UsedPhones TABLE (Phone NVARCHAR(20) PRIMARY KEY);

-- --- Data Pools for Randomization ---

-- First Names (M/F)
DECLARE @FirstNames TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(50), Gender NVARCHAR(10));
INSERT INTO @FirstNames (Name, Gender) VALUES
(N'Youssef', N'Male'), (N'Ahmed', N'Male'), (N'Omar', N'Male'), (N'Mohamed', N'Male'), (N'Adam', N'Male'), (N'Yassin', N'Male'), (N'Ali', N'Male'), (N'Zeyad', N'Male'), (N'Hamza', N'Male'), (N'Amr', N'Male'), (N'Eyad', N'Male'), (N'Hassan', N'Male'),
(N'Mariam', N'Female'), (N'Jana', N'Female'), (N'Salma', N'Female'), (N'Fatma', N'Female'), (N'Hana', N'Female'), (N'Nour', N'Female'), (N'Lamar', N'Female'), (N'Ganna', N'Female'), (N'Aya', N'Female'), (N'Malak', N'Female'), (N'Farida', N'Female'), (N'Habiba', N'Female');

-- Last Names
DECLARE @LastNames TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'Hassan'), (N'Mohamed'), (N'Ibrahim'), (N'Ali'), (N'Fahmy'), (N'El-Sayed'), (N'Tantawy'), (N'Shahin'), (N'Kandil'), (N'El-Shamy'), (N'Soliman'), (N'Abdel-Rahman'), (N'Osman'), (N'Nagy'), (N'Shehata'), (N'Barakat'), (N'Gad'), (N'Emad'), (N'El-Hawary'), (N'El-Sharkawy');

-- Governorates (mapped to Branch Locations from Branch Table)
DECLARE @Governorates TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(100), Near_Location NVARCHAR(100));
INSERT INTO @Governorates (Name, Near_Location) VALUES
(N'Cairo', N'Giza'), (N'Giza', N'Giza'), (N'Qalyubia', N'Giza'), (N'6th of October', N'Giza'), -- Giza (Smart Village, Cairo Uni)
(N'Alexandria', N'Alexandria'), (N'Beheira', N'Alexandria'), (N'Matrouh', N'Alexandria'), -- Alexandria
(N'Assiut', N'Assiut'), -- Assiut
(N'Dakahlia', N'El Mansoura'), (N'Damietta', N'El Mansoura'), -- El Mansoura
(N'Ismailia', N'Ismailia'), (N'Suez', N'Ismailia'), -- Ismailia
(N'Menoufia', N'El Menoufia'), (N'Gharbia', N'El Menoufia'), -- El Menoufia
(N'Minya', N'El Minia'), -- El Minia
(N'Sohag', N'Sohag'), -- Sohag
(N'Qena', N'Qena'), (N'Luxor', N'Qena'), -- Qena
(N'Aswan', N'Aswan'), (N'Red Sea', N'Aswan'), -- Aswan
(N'Cairo', N'New Capital'), (N'Giza', N'New Capital'), -- New Capital
(N'New Valley', N'New Valley'), -- New Valley
(N'Beni Suef', N'Beni Sweif'), -- Beni Sweif
(N'Qalyubia', N'Benha'), -- Benha
(N'Faiyum', N'El Fayoum'), -- El Fayoum
(N'Port Said', N'Port Said'), -- Port Said
(N'North Sinai', N'Al Arish'), -- Al Arish
(N'Sharqia', N'Zagazig'), -- Zagazig
(N'Beheira', N'Damanhour'), -- Damanhour
(N'Gharbia', N'Tanta'); -- Tanta

-- Faculties (Weighted: 4x CS, 3x Eng, 1x Others)
DECLARE @Faculties TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Computers Sciences'), (N'Faculty of Computers Sciences'), (N'Faculty of Computers Sciences'), (N'Faculty of Computers Sciences'),
(N'Faculty of Engineering'), (N'Faculty of Engineering'), (N'Faculty of Engineering'),
(N'Faculty of Science'), (N'Faculty of Commerce'), (N'Faculty of Business Administration'), (N'Faculty of Information Systems'),
(N'Faculty of Education'), (N'Faculty of Economics and Political Science'), (N'Faculty of Agriculture'), (N'Faculty of Fine Arts'),
(N'Faculty of Applied Arts'), (N'Faculty of Arts');

-- Other Random Data
DECLARE @Grades TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(50));
INSERT INTO @Grades (Name) VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass');

DECLARE @CertProviders TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(200));
INSERT INTO @CertProviders (Name) VALUES (N'Coursera'), (N'Udemy'), (N'Udacity'), (N'edX'), (N'Mahara Tech'), (N'WPBeginner'), (N'Yoast Academy'), (N'Google Skillshop');

DECLARE @FreelanceSites TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(255));
INSERT INTO @FreelanceSites (Name) VALUES (N'Upwork'), (N'Freelancer'), (N'LinkedIn'), (N'Khamsat'), (N'Mostaql'), (N'Fiverr');


-- --- Track 14 (CMS) Specific Data ---

DECLARE @CMS_Positions TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(100));
INSERT INTO @CMS_Positions (Name) VALUES
(N'WordPress Developer'), (N'CMS Specialist'), (N'Web Developer (CMS)'), (N'Frontend Developer'),
(N'PHP Developer'), (N'Junior Web Developer'), (N'Content Manager'), (N'SEO Specialist'),
(N'E-commerce Specialist');

DECLARE @CMS_Companies TABLE (Company_ID INT);
INSERT INTO @CMS_Companies (Company_ID) VALUES 
(15), -- NAGWA (likely uses CMS for educational content)
(16), -- Robusta (Digital Agency)
(24), -- Raya Holding (Diverse business, likely needs web presence)
(41), -- ArabyAds (Marketing, needs websites)
(46), -- Talabat (Needs CMS for content sections)
(50), -- Jumia (E-commerce, uses CMS extensively)
(6),  -- Orange Egypt (Telecom, large web presence)
(13); -- Etisalat by e& (Telecom, large web presence)

DECLARE @CMS_Certs TABLE (ID INT IDENTITY(1,1), Name NVARCHAR(200));
INSERT INTO @CMS_Certs (Name) VALUES
(N'WordPress Development Bootcamp (Udemy)'), (N'WooCommerce Specialist (Udemy)'),
(N'PHP for WordPress Developers (Coursera)'), (N'Headless CMS Fundamentals'),
(N'Yoast SEO for WordPress Training'), (N'Google Analytics Certification'),
(N'JAMstack Fundamentals'), (N'Mahara Tech Web Essentials');

DECLARE @CMS_Jobs TABLE (ID INT IDENTITY(1,1), Descr NVARCHAR(1000));
INSERT INTO @CMS_Jobs (Descr) VALUES
(N'Customize a WordPress theme for a client.'), (N'Install and configure essential WordPress plugins.'),
(N'Set up a WooCommerce store with basic products.'), (N'Migrate content from an old website to WordPress.'),
(N'Perform basic SEO optimization on a WordPress site.'), (N'Fix PHP errors in a custom WordPress plugin.'),
(N'Build a simple landing page using a WordPress page builder.'), (N'Implement basic security measures for a WordPress site.'),
(N'Create custom post types and fields in WordPress.'), (N'Connect a WordPress site to Mailchimp.'),
(N'Troubleshoot common WordPress errors (e.g., white screen of death).'), (N'Set up a multilingual website using WPML or Polylang.'),
(N'Optimize website speed using caching plugins.'), (N'Develop a simple contact form with validation.'),
(N'Manage user roles and permissions in WordPress.'), (N'Set up Google Analytics tracking on a site.'),
(N'Build a simple site using Gatsby.js and Contentful (JAMstack).');


-- ============================================
-- 2. IDENTIFY TARGET IBTS AND COURSES
-- ============================================

-- --- Target IBTs (Track 14) ---
DECLARE @TargetIBTs TABLE (
    Intake_Branch_Track_ID INT,
    Intake_ID INT,
    Branch_ID INT,
    Track_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    Branch_Location NVARCHAR(100),
    Branch_Name NVARCHAR(100)
);
INSERT INTO @TargetIBTs 
SELECT
    ibt.Intake_Branch_Track_ID,
    ibt.Intake_ID,
    ibt.Branch_ID,
    ibt.Track_ID,
    i.Intake_Start_Date,
    i.Intake_End_Date,
    b.Branch_Location,
    b.Branch_Name
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
JOIN Branch b ON ibt.Branch_ID = b.Branch_ID
WHERE ibt.Track_ID = 14; -- Web Development Using CMS

-- --- Target Courses (Track 14) ---
DECLARE @TrackCourses TABLE (
    Course_ID INT,
    Course_Name NVARCHAR(200),
    RN INT -- Row number for sequencing
);
INSERT INTO @TrackCourses (Course_ID, Course_Name, RN)
SELECT tc.Course_ID, c.Course_Name, ROW_NUMBER() OVER (ORDER BY tc.Course_ID)
FROM Track_Course tc
JOIN Course c ON tc.Course_ID = c.Course_ID
WHERE tc.Track_ID = 14;


-- ============================================
-- 3. MAIN DATA GENERATION LOOP
-- ============================================

PRINT 'Starting data generation for Track 14: Web Development Using CMS...';

-- --- Cursor variables ---
DECLARE @IBT_ID INT, @Intake_Start DATE, @Intake_End DATE, @Branch_ID INT, @Branch_Location NVARCHAR(100);
DECLARE @TotalDays INT;

-- --- Loop 1: Iterate over each IBT ---
DECLARE ibt_cursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_Start_Date, Intake_End_Date, Branch_ID, Branch_Location
    FROM @TargetIBTs;

OPEN ibt_cursor;
FETCH NEXT FROM ibt_cursor INTO @IBT_ID, @Intake_Start, @Intake_End, @Branch_ID, @Branch_Location;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for IBT_ID: ' + CAST(@IBT_ID AS VARCHAR(10));
    SET @TotalDays = DATEDIFF(day, @Intake_Start, @Intake_End);
    IF @TotalDays <= 0 SET @TotalDays = 1; -- Avoid division by zero

    -- --- Loop 2: Create 25 Students for this IBT ---
    DECLARE @StudentCounter INT = 1;
    WHILE @StudentCounter <= 25
    BEGIN
        
        -- --- Student Variables ---
        DECLARE @StudentID INT = @CurrentStudentID;
        DECLARE @Student_Fname NVARCHAR(50), @Student_Lname NVARCHAR(50), @Student_Gender NVARCHAR(10);
        DECLARE @FullName NVARCHAR(101), @EmailName NVARCHAR(101), @SocialName NVARCHAR(101);
        DECLARE @Student_Mail NVARCHAR(100);
        DECLARE @Student_Address NVARCHAR(255);
        DECLARE @Student_Marital_Status NVARCHAR(50);
        DECLARE @Student_Birthdate DATE;
        DECLARE @Student_Faculty NVARCHAR(100);
        DECLARE @Student_Faculty_Grade NVARCHAR(50);
        DECLARE @Student_ITI_Status NVARCHAR(50);
        DECLARE @Status_Roll FLOAT = RAND(); -- Roll once for status
        DECLARE @Phone NVARCHAR(20);
        DECLARE @IsUniquePhone BIT = 0;

        -- --- Generate Basic Info ---
        SELECT TOP 1 @Student_Fname = Name, @Student_Gender = Gender FROM @FirstNames ORDER BY NEWID();
        SELECT TOP 1 @Student_Lname = Name FROM @LastNames ORDER BY NEWID();
        SET @FullName = @Student_Fname + N' ' + @Student_Lname;
        SET @EmailName = REPLACE(LOWER(@Student_Fname), N' ', N'.') + N'.' + REPLACE(LOWER(@Student_Lname), N' ', N'');
        SET @SocialName = REPLACE(LOWER(@Student_Fname) + LOWER(@Student_Lname), N' ', N'');
        SET @Student_Mail = @EmailName + CAST(@StudentID AS NVARCHAR(10)) + N'@iti.eg';
        
        -- Marital Status
        SET @Student_Marital_Status = CASE WHEN RAND() < 0.3 THEN N'Married' ELSE N'Single' END;

        -- Birthdate (18+ years before GETDATE() to pass CHECK constraint)
        DECLARE @LatestBirthdate DATE = DATEADD(year, -18, GETDATE()); -- The latest valid birthdate
        SET @Student_Birthdate = DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 7300 + 1), @LatestBirthdate); -- Subtract 1 to 7301 days (making them 18-38 years old)

        -- Faculty (Weighted)
        SELECT TOP 1 @Student_Faculty = Name FROM @Faculties ORDER BY NEWID(); -- The weighting is built into the table inserts

        -- Faculty Grade
        SELECT TOP 1 @Student_Faculty_Grade = Name FROM @Grades ORDER BY NEWID();

        -- Address (Branch-Aware: 70% near branch, 30% any)
        IF (RAND() < 0.7 AND EXISTS(SELECT 1 FROM @Governorates WHERE Near_Location = @Branch_Location))
            SELECT TOP 1 @Student_Address = Name FROM @Governorates WHERE Near_Location = @Branch_Location ORDER BY NEWID();
        ELSE
            SELECT TOP 1 @Student_Address = Name FROM @Governorates ORDER BY NEWID();

        -- ITI Status (Graduated, In Progress, Failed) - Based on @CurrentDate
        IF @Intake_End < @CurrentDate
        BEGIN
            -- Intake is finished
            IF @Status_Roll < 0.05 -- 5% chance to fail
                SET @Student_ITI_Status = N'Failed to Graduate';
            ELSE
                SET @Student_ITI_Status = N'Graduated';
        END
        ELSE
            SET @Student_ITI_Status = N'In Progress';
        

        -- --- Generate Unique Phone ---
        SET @IsUniquePhone = 0;
        WHILE @IsUniquePhone = 0
        BEGIN
            SET @Phone = N'01' + CAST(ABS(CHECKSUM(NEWID())) % 3 AS NVARCHAR(1)) -- 010, 011, 012
                       + RIGHT(N'00000000' + CAST(ABS(CHECKSUM(NEWID())) % 100000000 AS NVARCHAR(8)), 8);
            IF NOT EXISTS (SELECT 1 FROM @UsedPhones WHERE Phone = @Phone)
            BEGIN
                INSERT INTO @UsedPhones (Phone) VALUES (@Phone);
                SET @IsUniquePhone = 1;
            END
        END

        -- ===================================
        -- 4. INSERTION
        -- ===================================

        -- --- INSERT Student ---
        INSERT INTO Student (Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status, Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade, Student_ITI_Status, Intake_Branch_Track_ID)
        VALUES (
            @StudentID, @Student_Mail, @Student_Address, @Student_Gender, @Student_Marital_Status, @Student_Fname, @Student_Lname,
            @Student_Birthdate, @Student_Faculty, @Student_Faculty_Grade, @Student_ITI_Status, @IBT_ID
        );

        -- --- INSERT Student_Phone ---
        INSERT INTO Student_Phone (Student_ID, Phone) VALUES (@StudentID, @Phone);

        -- --- INSERT Student_Social ---
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES
            (@StudentID, N'LinkedIn', N'https://linkedin.com/in/' + @SocialName + CAST(@StudentID % 1000 AS NVARCHAR(4)));
            -- GitHub might be less relevant for pure CMS, adding Facebook instead sometimes
        IF RAND() > 0.4 
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@StudentID, N'Facebook', N'https://facebook.com/' + @SocialName);
        IF RAND() > 0.7 -- Add GitHub less often
             INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
             VALUES (@StudentID, N'GitHub', N'https://github.com/' + @SocialName + CAST(@StudentID % 1000 AS NVARCHAR(4)));


        -- --- INSERT Student_Course (Sequential) ---
        DECLARE @CourseCount INT = (SELECT COUNT(*) FROM @TrackCourses);
        DECLARE @DaysPerCourse INT = CASE WHEN @CourseCount > 0 THEN @TotalDays / @CourseCount ELSE 0 END;
        DECLARE @CourseStartDate DATE = @Intake_Start;
        DECLARE @CourseEndDate DATE;

        DECLARE @CourseID INT, @RN INT;
        DECLARE course_cursor CURSOR FOR
            SELECT Course_ID, RN FROM @TrackCourses ORDER BY RN;
        OPEN course_cursor;
        FETCH NEXT FROM course_cursor INTO @CourseID, @RN;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @CourseEndDate = DATEADD(day, @DaysPerCourse, @CourseStartDate);
            -- Ensure last course ends on the intake end date
            IF @RN = @CourseCount
                SET @CourseEndDate = @Intake_End;

            INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
            VALUES (@StudentID, @CourseID, @CourseStartDate, @CourseEndDate);

            -- Set start date for next course (1 day after previous end)
            SET @CourseStartDate = DATEADD(day, 1, @CourseEndDate);
            
            FETCH NEXT FROM course_cursor INTO @CourseID, @RN;
        END
        CLOSE course_cursor;
        DEALLOCATE course_cursor;


        -- --- INSERT Certificate (Random, during intake) ---
        DECLARE @CertCount INT = ABS(CHECKSUM(NEWID())) % 4; -- 0 to 3 certs
        DECLARE @c INT = 0;
        WHILE @c < @CertCount
        BEGIN
            DECLARE @CertDate DATE = DATEADD(day, ABS(CHECKSUM(NEWID())) % @TotalDays, @Intake_Start);
            DECLARE @CertName NVARCHAR(200), @CertProvider NVARCHAR(200), @CertCost DECIMAL(12,2);
            
            SELECT TOP 1 @CertName = Name FROM @CMS_Certs ORDER BY NEWID();
            SELECT TOP 1 @CertProvider = Name FROM @CertProviders ORDER BY NEWID();
            SET @CertCost = (ABS(CHECKSUM(NEWID())) % 150) * 10; -- 0 to 1490 (CMS certs often cheaper)

            INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
            VALUES (@CurrentCertID, @StudentID, @CertName, @CertProvider, @CertCost, @CertDate);
            
            SET @CurrentCertID = @CurrentCertID + 1;
            SET @c = @c + 1;
        END

        -- --- INSERT Freelance_Job (Random, during intake) ---
        DECLARE @JobCount INT = ABS(CHECKSUM(NEWID())) % 6; -- 0 to 5 jobs (potentially more smaller jobs)
        DECLARE @j INT = 0;
        WHILE @j < @JobCount
        BEGIN
            DECLARE @JobDate DATE = DATEADD(day, ABS(CHECKSUM(NEWID())) % @TotalDays, @Intake_Start);
            DECLARE @JobSite NVARCHAR(255), @JobEarn DECIMAL(12,2), @JobDesc NVARCHAR(1000);

            SELECT TOP 1 @JobSite = Name FROM @FreelanceSites ORDER BY NEWID();
            SELECT TOP 1 @JobDesc = Descr FROM @CMS_Jobs ORDER BY NEWID();
            SET @JobEarn = (ABS(CHECKSUM(NEWID())) % 600) + 50; -- 50 to 650 (smaller freelance gigs common)

            INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
            VALUES (@CurrentJobID, @StudentID, @JobEarn, @JobDate, @JobSite, @JobDesc);
            
            SET @CurrentJobID = @CurrentJobID + 1;
            SET @j = @j + 1;
        END


        -- --- INSERT Student_Company (ONLY for 'Graduated') ---
        IF @Student_ITI_Status = N'Graduated'
        BEGIN
            -- Determine hiring probability based on Branch_ID
            -- Smart Village (1) > Cairo Uni (12) > New Capital (11) > Alexandria (2) > Rest
            DECLARE @Hiring_Roll FLOAT = RAND();
            DECLARE @Hire BIT = 0;

            IF @Branch_ID = 1 AND @Hiring_Roll < 0.75 SET @Hire = 1;  -- 75% for Smart Village
            ELSE IF @Branch_ID = 12 AND @Hiring_Roll < 0.65 SET @Hire = 1; -- 65% for Cairo Uni
            ELSE IF @Branch_ID = 11 AND @Hiring_Roll < 0.55 SET @Hire = 1; -- 55% for New Capital
            ELSE IF @Branch_ID = 2 AND @Hiring_Roll < 0.45 SET @Hire = 1;  -- 45% for Alexandria
            ELSE IF @Hiring_Roll < 0.35 SET @Hire = 1; -- 35% for all others

            IF @Hire = 1
            BEGIN
                -- Declare job variables
                DECLARE @Company_ID INT;
                DECLARE @Salary DECIMAL(12,2);
                DECLARE @Position NVARCHAR(100);
                DECLARE @Contract_Type NVARCHAR(50);
                DECLARE @Hire_Date DATE;

                -- Get random company from the CMS list
                SELECT TOP 1 @Company_ID = Company_ID FROM @CMS_Companies ORDER BY NEWID();
                
                -- Get random position
                SELECT TOP 1 @Position = Name FROM @CMS_Positions ORDER BY NEWID();

                -- Get contract type & salary (Full-Time > Part-Time)
                IF RAND() > 0.3
                BEGIN
                    SET @Contract_Type = N'Full-Time';
                    SET @Salary = (ABS(CHECKSUM(NEWID())) % 8000) + 7000; -- 7k to 15k (CMS roles might start lower)
                END
                ELSE
                BEGIN
                    SET @Contract_Type = N'Part-Time';
                    SET @Salary = (ABS(CHECKSUM(NEWID())) % 3000) + 3000;  -- 3k to 6k
                END

                -- Get Hire Date (1-90 days after intake end, but not after @CurrentDate)
                SET @Hire_Date = DATEADD(day, (ABS(CHECKSUM(NEWID())) % 90) + 1, @Intake_End);
                IF @Hire_Date > @CurrentDate
                    SET @Hire_Date = DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), @CurrentDate); -- Hire in the last 30 days

                -- INSERT into Student_Company
                INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
                VALUES (@StudentID, @Company_ID, @Salary, @Position, @Contract_Type, @Hire_Date, NULL);
            END
        END

        -- --- Increment global ID counter ---
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END -- End 25-student loop

    FETCH NEXT FROM ibt_cursor INTO @IBT_ID, @Intake_Start, @Intake_End, @Branch_ID, @Branch_Location;
END -- End IBT loop

CLOSE ibt_cursor;
DEALLOCATE ibt_cursor;

PRINT 'Data generation complete for Track 14.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - @StudentID_Start) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertID - @CertID_Start) AS VARCHAR(10));
PRINT 'Total Freelance Jobs Inserted: ' + CAST((@CurrentJobID - @JobID_Start) AS VARCHAR(10));

-- Commit the transaction
COMMIT TRANSACTION;