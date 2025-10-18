-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 36000;
DECLARE @CurrentJobID INT = 36000;
DECLARE @CurrentCertificateID INT = 36000;

-- Get the current date to determine graduation status
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Youssef'), (N'Omar'), (N'Adam'), (N'Khaled'), (N'Karim'), (N'Amr'), (N'Tarek'), 
(N'Hazem'), (N'Ziad'), (N'Mazen'), (N'Bilal'), (N'Faris'), (N'Sami'), (N'Nader');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Mariam'), (N'Hana'), (N'Salma'), (N'Aya'), (N'Nour'), (N'Yara'), (N'Lila'), 
(N'Jana'), (N'Farida'), (N'Kenzy'), (N'Malak'), (N'Reem'), (N'Dina'), (N'Lamar');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Masry'), (N'Hassan'), (N'Ali'), (N'Said'), (N'Gamal'), (N'Fathy'), (N'Adel'), 
(N'Zaki'), (N'Ibrahim'), (N'Kamel'), (N'Tawfik'), (N'Rizk'), (N'Shalaby'), (N'Diab');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'15 Abbas El Akkad, Nasr City, Cairo'), (N'27 Tahrir St, Dokki, Giza'), (N'44 Corniche El Nil, Maadi, Cairo'),
(N'10 Fouad St, Raml Station, Alexandria'), (N'88 El Geish St, El Mansoura'), (N'201 University St, Assiut'),
(N'55 El Horreya Rd, Heliopolis, Cairo'), (N'32 Gamal Abdel Nasser, Smouha, Alexandria'), (N'19 El Galaa St, Ismailia');

-- Data pool for University Faculties
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Fine Arts, Helwan University'), (N'Faculty of Applied Arts, Damietta University'), 
(N'Faculty of Art Education, Helwan University'), (N'Faculty of Engineering, Cairo University'), 
(N'Faculty of Commerce, Ain Shams University'), (N'Faculty of Arts, Alexandria University'), 
(N'Faculty of Computers and Information, Mansoura University');

-- Data pool for Concept Art related jobs
DECLARE @ArtJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @ArtJobs (Description, Site) VALUES
(N'Character concept sheet for a mobile game', N'Upwork'),
(N'Environment keyframe illustration for an indie film', N'Fiverr'),
(N'Prop designs (5 sci-fi weapons) for a 3D modeler', N'Freelancer.com'),
(N'Creature concept art (3 variations) for a fantasy novel', N'Upwork'),
(N'Vehicle design sketch for a racing game prototype', N'Fiverr'),
(N'Splash art illustration for a game marketing banner', N'PeoplePerHour');

-- Data pool for Concept Art related certificates
DECLARE @ArtCerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @ArtCerts (Name, Provider) VALUES
(N'Advanced Digital Painting', N'ArtStation Learning'),
(N'Character Design Masterclass', N'CGMA'),
(N'Environment Design with Photoshop', N'Udemy'),
(N'ZBrush for Concepting', N'Learn Squared'),
(N'World Building Workshop', N'Schoolism'),
(N'Anatomy and Figure Drawing', N'Proko'),
(N'Perspective Drawing Fundamentals', N'Coursera');

-- Data pool for Concept Art related companies (from the provided list)
DECLARE @ArtCompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @ArtCompanies (Company_ID, Position) VALUES
(15, N'Junior Illustrator'), (16, N'2D Artist'), (18, N'Visual Development Artist'),
(41, N'Concept Artist'), (46, N'UI/UX Illustrator'), (50, N'Marketing Illustrator');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Concept Art' (Track_ID = 19)
DECLARE @ConceptArtTracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @ConceptArtTracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT 
    ibt.Intake_Branch_Track_ID, 
    i.Intake_ID, 
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 19; -- Track_ID for 'Concept Art'

-- 2. Get all courses for 'Concept Art' (Track_ID = 19)
DECLARE @ConceptArtCourses TABLE (Course_ID INT);
INSERT INTO @ConceptArtCourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 19;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Concept Art (Track 19)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each Concept Art track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @ConceptArtTracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));
    
    SET @StudentCounter = 1;
    
    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.5 THEN N'Male' ELSE N'Female' END;
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.7 THEN N'Married' ELSE N'Single' END;
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());
        
        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-art.com';
        
        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);
        
        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.1 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 90% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));
        
        IF RAND() > 0.5
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn and GitHub (relevant for artists)
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));
        
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'GitHub', N'https://github.com/' + LOWER(@StudentFname) + LOWER(@StudentLname)); -- Artists use it for portfolios too

        IF RAND() > 0.5 -- Optional Facebook
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'Facebook', N'https://facebook.com/' + LOWER(@StudentFname) + '.' + LOWER(@StudentLname));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate 
        FROM @ConceptArtCourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.4 -- 60% chance to have freelance jobs
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 2 AS INT) + 1; -- 1 or 2 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT 
                    @CurrentJobID, 
                    @CurrentStudentID,
                    CAST(RAND() * 800 + 100 AS DECIMAL(12, 2)), -- Earn $100 - $900
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    A.Site,
                    A.Description
                FROM (SELECT TOP 1 * FROM @ArtJobs ORDER BY NEWID()) AS A;
                
                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.3 -- 70% chance to have certificates
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT 
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 400 + 50 AS DECIMAL(12, 2)), -- Cost $50 - $450
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert during the intake
                FROM (SELECT TOP 1 * FROM @ArtCerts ORDER BY NEWID()) AS C;
                
                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END
        
        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have a 70% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.3
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);
            
            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                AC.Company_ID,
                CAST(RAND() * 10000 + 8000 AS DECIMAL(12, 2)), -- Salary 8k - 18k
                AC.Position,
                CASE WHEN RAND() > 0.2 THEN N'Full-Time' ELSE N'Part-Time' END,
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @ArtCompanies ORDER BY NEWID()) AS AC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 36000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 36000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 36000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO


--Track 20
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 38000;
DECLARE @CurrentJobID INT = 38000;
DECLARE @CurrentCertificateID INT = 38000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Youssef'), (N'Omar'), (N'Adam'), (N'Khaled'), (N'Karim'), (N'Amr'), (N'Tarek'), 
(N'Hazem'), (N'Ziad'), (N'Mazen'), (N'Bilal'), (N'Faris'), (N'Sami'), (N'Nader');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Mariam'), (N'Hana'), (N'Salma'), (N'Aya'), (N'Nour'), (N'Yara'), (N'Lila'), 
(N'Jana'), (N'Farida'), (N'Kenzy'), (N'Malak'), (N'Reem'), (N'Dina'), (N'Lamar');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Masry'), (N'Hassan'), (N'Ali'), (N'Said'), (N'Gamal'), (N'Fathy'), (N'Adel'), 
(N'Zaki'), (N'Ibrahim'), (N'Kamel'), (N'Tawfik'), (N'Rizk'), (N'Shalaby'), (N'Diab');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'15 Abbas El Akkad, Nasr City, Cairo'), (N'27 Tahrir St, Dokki, Giza'), (N'44 Corniche El Nil, Maadi, Cairo'),
(N'10 Fouad St, Raml Station, Alexandria'), (N'88 El Geish St, El Mansoura'), (N'201 University St, Assiut'),
(N'55 El Horreya Rd, Heliopolis, Cairo'), (N'32 Gamal Abdel Nasser, Smouha, Alexandria'), (N'19 El Galaa St, Ismailia');

-- Data pool for University Faculties (UI/UX related)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Fine Arts, Helwan University'), (N'Faculty of Applied Arts, 6th of October University'),
(N'Faculty of Computers and Information, Cairo University'), (N'Faculty of Art Education, Helwan University'),
(N'Faculty of Arts, Ain Shams University'), (N'Faculty of Mass Communication, Cairo University');

-- Data pool for UI/UX related freelance jobs
DECLARE @UIUXJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @UIUXJobs (Description, Site) VALUES
(N'Mobile app wireframe design (Figma)', N'Upwork'),
(N'Usability testing report for a website', N'Fiverr'),
(N'Creating a design system for a startup', N'Freelancer.com'),
(N'Landing page redesign mockups (3 options)', N'Upwork'),
(N'User flow diagrams for a new app feature', N'PeoplePerHour'),
(N'Low-fidelity prototypes for a booking system', N'Fiverr');

-- Data pool for UI/UX related certificates
DECLARE @UIUXCerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @UIUXCerts (Name, Provider) VALUES
(N'Google UX Design Professional Certificate', N'Coursera'),
(N'UX Design Certification', N'Nielsen Norman Group'),
(N'UI Design Specialist', N'Interaction Design Foundation'),
(N'Figma for UI/UX Design', N'Udemy'),
(N'Certified UX Professional', N'BCS, The Chartered Institute for IT'),
(N'Enterprise Design Thinking Practitioner', N'IBM');

-- Data pool for UI/UX related companies (from the provided list)
DECLARE @UIUXCompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @UIUXCompanies (Company_ID, Position) VALUES
(3, N'Junior Product Designer'), (4, N'UX Analyst'), (6, N'UI Designer'),
(14, N'Product Designer'), (16, N'UI/UX Designer'), (17, N'Product Designer'),
(41, N'UI Designer'), (43, N'UX/UI Specialist'), (46, N'UX Researcher'), (50, N'Junior Product Designer');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'UI/UX Design' (Track_ID = 20)
DECLARE @UIUXTracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @UIUXTracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT 
    ibt.Intake_Branch_Track_ID, 
    i.Intake_ID, 
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 20; -- Track_ID for 'UI/UX Design'

-- 2. Get all courses for 'UI/UX Design' (Track_ID = 20)
DECLARE @UIUXCourses TABLE (Course_ID INT);
INSERT INTO @UIUXCourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 20;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for UI/UX Design (Track 20)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each UI/UX track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @UIUXTracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));
    
    SET @StudentCounter = 1;
    
    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.4 THEN N'Female' ELSE N'Male' END; -- Slightly more females in UI/UX
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.75 THEN N'Married' ELSE N'Single' END; -- 75% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());
        
        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-uiux.com';
        
        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);
        
        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.08 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 92% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));
        
        IF RAND() > 0.5
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn and GitHub (for portfolios)
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));
        
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'GitHub', N'https://github.com/' + LOWER(@StudentFname) + LOWER(@StudentLname)); -- Also used for portfolios

        IF RAND() > 0.3 -- Optional Instagram (for design)
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'Instagram', N'https://instagram.com/' + LOWER(@StudentFname) + '.' + LOWER(@StudentLname));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate 
        FROM @UIUXCourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.3 -- 70% chance to have freelance jobs
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT 
                    @CurrentJobID, 
                    @CurrentStudentID,
                    CAST(RAND() * 700 + 150 AS DECIMAL(12, 2)), -- Earn $150 - $850
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @UIUXJobs ORDER BY NEWID()) AS J;
                
                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.25 -- 75% chance to have certificates
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT 
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 300 + 40 AS DECIMAL(12, 2)), -- Cost $40 - $340
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert earned during the intake
                FROM (SELECT TOP 1 * FROM @UIUXCerts ORDER BY NEWID()) AS C;
                
                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END
        
        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have a 70% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.3
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);
            
            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                UC.Company_ID,
                CAST(RAND() * 10000 + 9000 AS DECIMAL(12, 2)), -- Salary 9k - 19k
                UC.Position,
                CASE WHEN RAND() > 0.1 THEN N'Full-Time' ELSE N'Part-Time' END,
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @UIUXCompanies ORDER BY NEWID()) AS UC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 38000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 38000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 38000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO

--Track 21
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 40000;
DECLARE @CurrentJobID INT = 40000;
DECLARE @CurrentCertificateID INT = 40000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Ahmed'), (N'Mohamed'), (N'Mahmoud'), (N'Mostafa'), (N'Yassin'), (N'Hamza'), (N'Ali'), 
(N'Omar'), (N'Khaled'), (N'Karim'), (N'Tarek'), (N'Hassan'), (N'Faris'), (N'Ramy');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Fatima'), (N'Aisha'), (N'Hana'), (N'Salma'), (N'Nour'), (N'Yara'), (N'Lojain'), 
(N'Jana'), (N'Farida'), (N'Rowan'), (N'Malak'), (N'Ganna'), (N'Dina'), (N'Sarah');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Sayed'), (N'Hassan'), (N'Ali'), (N'Mahmoud'), (N'Ibrahim'), (N'Abdel-Rahman'), (N'Taha'), 
(N'Osman'), (N'Khattab'), (N'Fawzy'), (N'Shahin'), (N'Nasser'), (N'Kamel'), (N'Ezzat');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'123 El Haram St, Giza'), (N'45 Mohi El Din Abu El Ezz, Dokki, Giza'), (N'789 Corniche El Nil, Maadi, Cairo'),
(N'10 El Gomhouria St, Assiut'), (N'88 El Geish St, El Mansoura'), (N'50 Port Said St, Alexandria'),
(N'22 Tanta St, Tanta'), (N'19 El Galaa St, Ismailia'), (N'33 El Obour Buildings, Nasr City, Cairo');

-- Data pool for University Faculties (SysAdmin related)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Computers and Information, Cairo University'), 
(N'Faculty of Engineering, Ain Shams University'), 
(N'Faculty of Computers and Data Science, Alexandria University'), 
(N'Faculty of Electronic Engineering, Menoufia University'),
(N'Faculty of Science, Mansoura University'), 
(N'Faculty of Commerce (BIS), Helwan University');

-- Data pool for Systems Administration related freelance jobs
DECLARE @SysAdminJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @SysAdminJobs (Description, Site) VALUES
(N'Linux server setup and hardening (Ubuntu 22.04)', N'Upwork'),
(N'Active Directory troubleshooting for a small office (20 users)', N'Fiverr'),
(N'Write a PowerShell script for user onboarding', N'Freelancer.com'),
(N'Configure and troubleshoot a Hyper-V virtual machine', N'Upwork'),
(N'Migrate 10 user mailboxes to Office 365', N'PeoplePerHour'),
(N'Basic network configuration for a new router (MikroTik)', N'Fiverr');

-- Data pool for Systems Administration related certificates
DECLARE @SysAdminCerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @SysAdminCerts (Name, Provider) VALUES
(N'Microsoft Certified: Azure Administrator Associate (AZ-104)', N'Microsoft'),
(N'CompTIA Linux+', N'CompTIA'),
(N'Red Hat Certified System Administrator (RHCSA)', N'Red Hat'),
(N'VMware VCP-DCV', N'VMware'),
(N'CompTIA Security+', N'CompTIA'),
(N'Windows Server Hybrid Administrator Associate', N'Microsoft'),
(N'CompTIA Network+', N'CompTIA');

-- Data pool for Systems Administration related companies (from the provided list)
DECLARE @SysAdminCompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @SysAdminCompanies (Company_ID, Position) VALUES
(3, N'IT Operations Specialist'), (6, N'Junior System Administrator'), (8, N'IT Infrastructure Engineer'),
(10, N'Infrastructure Specialist'), (11, N'Cloud Support Engineer'), (12, N'Technical Support Engineer'),
(23, N'NOC Engineer'), (24, N'System Administrator'), (47, N'Junior Infrastructure Specialist');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Systems Administration' (Track_ID = 21)
DECLARE @SysAdminTracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @SysAdminTracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT 
    ibt.Intake_Branch_Track_ID, 
    i.Intake_ID, 
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 21; -- Track_ID for 'Systems Administration'

-- 2. Get all courses for 'Systems Administration' (Track_ID = 21)
DECLARE @SysAdminCourses TABLE (Course_ID INT);
INSERT INTO @SysAdminCourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 21;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Systems Administration (Track 21)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each Systems Administration track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @SysAdminTracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));
    
    SET @StudentCounter = 1;
    
    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.2 THEN N'Male' ELSE N'Female' END; -- More males in SysAdmin
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.8 THEN N'Married' ELSE N'Single' END; -- 80% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());
        
        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-sys.com';
        
        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);
        
        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.1 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 90% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));
        
        IF RAND() > 0.6
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn and GitHub (essential for tech)
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));
        
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'GitHub', N'https://github.com/' + LOWER(@StudentFname) + LOWER(@StudentLname)); -- For PowerShell/Bash scripts

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate 
        FROM @SysAdminCourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.7 -- 30% chance to have freelance jobs (less common for SysAdmins)
        BEGIN
            DECLARE @JobCount INT = 1; -- Usually just one job
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT 
                    @CurrentJobID, 
                    @CurrentStudentID,
                    CAST(RAND() * 600 + 150 AS DECIMAL(12, 2)), -- Earn $150 - $750
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @SysAdminJobs ORDER BY NEWID()) AS J;
                
                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.2 -- 80% chance to have certificates
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT 
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 500 + 150 AS DECIMAL(12, 2)), -- Cost $150 - $650
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert earned during the intake
                FROM (SELECT TOP 1 * FROM @SysAdminCerts ORDER BY NEWID()) AS C;
                
                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END
        
        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have a 75% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.25
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);
            
            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                SC.Company_ID,
                CAST(RAND() * 11000 + 9000 AS DECIMAL(12, 2)), -- Salary 9k - 20k
                SC.Position,
                N'Full-Time', -- Most tech jobs are full-time
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @SysAdminCompanies ORDER BY NEWID()) AS SC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 40000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 40000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 40000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO

--Track22
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 42000;
DECLARE @CurrentJobID INT = 42000;
DECLARE @CurrentCertificateID INT = 42000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Ahmed'), (N'Mohamed'), (N'Mahmoud'), (N'Mostafa'), (N'Yassin'), (N'Hamza'), (N'Ali'), 
(N'Omar'), (N'Khaled'), (N'Karim'), (N'Tarek'), (N'Hassan'), (N'Faris'), (N'Ramy');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Fatima'), (N'Aisha'), (N'Hana'), (N'Salma'), (N'Nour'), (N'Yara'), (N'Lojain'), 
(N'Jana'), (N'Farida'), (N'Rowan'), (N'Malak'), (N'Ganna'), (N'Dina'), (N'Sarah');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Sayed'), (N'Hassan'), (N'Ali'), (N'Mahmoud'), (N'Ibrahim'), (N'Abdel-Rahman'), (N'Taha'), 
(N'Osman'), (N'Khattab'), (N'Fawzy'), (N'Shahin'), (N'Nasser'), (N'Kamel'), (N'Ezzat');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'123 El Haram St, Giza'), (N'45 Mohi El Din Abu El Ezz, Dokki, Giza'), (N'789 Corniche El Nil, Maadi, Cairo'),
(N'10 El Gomhouria St, Assiut'), (N'88 El Geish St, El Mansoura'), (N'50 Port Said St, Alexandria'),
(N'22 Tanta St, Tanta'), (N'19 El Galaa St, Ismailia'), (N'33 El Obour Buildings, Nasr City, Cairo');

-- Data pool for University Faculties (Cybersecurity related)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Computers and Information, Cairo University'), 
(N'Faculty of Engineering, Ain Shams University'), 
(N'Faculty of Computers and Data Science, Alexandria University'), 
(N'Faculty of Electronic Engineering, Menoufia University'),
(N'Faculty of Science, Mansoura University'), 
(N'Faculty of Commerce (BIS), Helwan University');

-- Data pool for Cybersecurity related freelance jobs
DECLARE @CybersecurityJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @CybersecurityJobs (Description, Site) VALUES
(N'Vulnerability assessment for a small e-commerce website', N'Upwork'),
(N'Penetration testing report for a mobile application (Android)', N'HackerOne'),
(N'Firewall configuration review and hardening recommendations', N'Fiverr'),
(N'Malware analysis of a suspicious email attachment', N'Freelancer.com'),
(N'Security audit of a small business network infrastructure', N'Upwork'),
(N'Writing a security policy for a startup (GDPR compliance)', N'PeoplePerHour');

-- Data pool for Cybersecurity related certificates
DECLARE @CybersecurityCerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @CybersecurityCerts (Name, Provider) VALUES
(N'CompTIA Security+', N'CompTIA'),
(N'eJPT (eLearnSecurity Junior Penetration Tester)', N'INE'),
(N'CEH (Certified Ethical Hacker)', N'EC-Council'),
(N'CompTIA Network+', N'CompTIA'),
(N'Google Cybersecurity Professional Certificate', N'Coursera'),
(N'ISC2 Certified in Cybersecurity (CC)', N'ISC2'),
(N'Cisco Certified CyberOps Associate', N'Cisco');

-- Data pool for Cybersecurity related companies (from the provided list)
DECLARE @CybersecurityCompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @CybersecurityCompanies (Company_ID, Position) VALUES
(3, N'SOC Analyst L1'), (4, N'Junior Security Consultant'), (6, N'Network Security Engineer'),
(10, N'Cybersecurity Intern'), (13, N'Security Operations Analyst'), (14, N'Information Security Specialist'),
(23, N'NOC Security Analyst'), (27, N'Cybersecurity Associate'), (28, N'Risk Advisory Consultant'),
(42, N'Fintech Security Analyst'), (49, N'Junior Network Security Engineer');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Cybersecurity Associate' (Track_ID = 22)
DECLARE @CybersecurityTracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @CybersecurityTracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT 
    ibt.Intake_Branch_Track_ID, 
    i.Intake_ID, 
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 22; -- Track_ID for 'Cybersecurity Associate'

-- 2. Get all courses for 'Cybersecurity Associate' (Track_ID = 22)
DECLARE @CybersecurityCourses TABLE (Course_ID INT);
INSERT INTO @CybersecurityCourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 22;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Cybersecurity Associate (Track 22)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each Cybersecurity track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @CybersecurityTracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));
    
    SET @StudentCounter = 1;
    
    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.5 THEN N'Male' ELSE N'Female' END;
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.8 THEN N'Married' ELSE N'Single' END; -- 80% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());
        
        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-cyber.com';
        
        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);
        
        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.05 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 95% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));
        
        IF RAND() > 0.6
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn and GitHub (essential for tech)
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));
        
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'GitHub', N'https://github.com/' + LOWER(@StudentFname) + LOWER(@StudentLname));

        IF RAND() > 0.5 -- Optional X (Twitter)
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'X', N'https://x.com/' + LOWER(@StudentFname) + LOWER(@StudentLname));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate 
        FROM @CybersecurityCourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.6 -- 40% chance to have freelance jobs
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 2 AS INT) + 1; -- 1 or 2 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT 
                    @CurrentJobID, 
                    @CurrentStudentID,
                    CAST(RAND() * 1000 + 200 AS DECIMAL(12, 2)), -- Earn $200 - $1200
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @CybersecurityJobs ORDER BY NEWID()) AS J;
                
                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.2 -- 80% chance to have certificates
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT 
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 400 + 100 AS DECIMAL(12, 2)), -- Cost $100 - $500
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert earned during the intake
                FROM (SELECT TOP 1 * FROM @CybersecurityCerts ORDER BY NEWID()) AS C;
                
                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END
        
        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have a 75% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.25
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);
            
            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                CC.Company_ID,
                CAST(RAND() * 12000 + 10000 AS DECIMAL(12, 2)), -- Salary 10k - 22k
                CC.Position,
                N'Full-Time', -- Most tech jobs are full-time
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @CybersecurityCompanies ORDER BY NEWID()) AS CC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 42000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 42000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 42000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO

--Track 23
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 44000;
DECLARE @CurrentJobID INT = 44000;
DECLARE @CurrentCertificateID INT = 44000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Youssef'), (N'Omar'), (N'Adam'), (N'Khaled'), (N'Karim'), (N'Amr'), (N'Tarek'), 
(N'Hazem'), (N'Ziad'), (N'Mazen'), (N'Bilal'), (N'Faris'), (N'Sami'), (N'Nader');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Mariam'), (N'Hana'), (N'Salma'), (N'Aya'), (N'Nour'), (N'Yara'), (N'Lila'), 
(N'Jana'), (N'Farida'), (N'Kenzy'), (N'Malak'), (N'Reem'), (N'Dina'), (N'Lamar');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Masry'), (N'Hassan'), (N'Ali'), (N'Said'), (N'Gamal'), (N'Fathy'), (N'Adel'), 
(N'Zaki'), (N'Ibrahim'), (N'Kamel'), (N'Tawfik'), (N'Rizk'), (N'Shalaby'), (N'Diab');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'15 Abbas El Akkad, Nasr City, Cairo'), (N'27 Tahrir St, Dokki, Giza'), (N'44 Corniche El Nil, Maadi, Cairo'),
(N'10 Fouad St, Raml Station, Alexandria'), (N'88 El Geish St, El Mansoura'), (N'201 University St, Assiut'),
(N'55 El Horreya Rd, Heliopolis, Cairo'), (N'32 Gamal Abdel Nasser, Smouha, Alexandria'), (N'19 El Galaa St, Ismailia');

-- Data pool for University Faculties (Data Viz related)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Commerce, Cairo University'), 
(N'Faculty of Computers and Information, Ain Shams University'), 
(N'Faculty of Economics and Political Science, Cairo University'),
(N'Faculty of Business Informatics, Helwan University'),
(N'Faculty of Science (Statistics Dept.), Alexandria University'),
(N'Faculty of Arts (Geography Dept.), Mansoura University'); -- GIS uses visualization

-- Data pool for Data Visualization related freelance jobs
DECLARE @DataVizJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @DataVizJobs (Description, Site) VALUES
(N'Create interactive sales dashboard using Tableau', N'Upwork'),
(N'Develop Power BI report for marketing campaign analysis', N'Fiverr'),
(N'Build a D3.js chart for website traffic data', N'Freelancer.com'),
(N'Design infographics based on provided research data', N'Upwork'),
(N'Clean and visualize survey results in Excel/Power BI', N'PeoplePerHour'),
(N'Create a Tableau story presenting financial trends', N'Fiverr');

-- Data pool for Data Visualization related certificates
DECLARE @DataVizCerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @DataVizCerts (Name, Provider) VALUES
(N'Tableau Desktop Specialist', N'Tableau'),
(N'Microsoft Certified: Power BI Data Analyst Associate', N'Microsoft'),
(N'Google Data Analytics Professional Certificate', N'Coursera'),
(N'Data Visualization with Python', N'DataCamp'),
(N'Advanced Excel for Data Analysis', N'Udemy'),
(N'Information Visualization Specialization', N'Coursera (NYU)');

-- Data pool for Data Visualization related companies (from the provided list)
DECLARE @DataVizCompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @DataVizCompanies (Company_ID, Position) VALUES
(1, N'BI Analyst'), (3, N'Data Visualization Specialist'), (4, N'Reporting Analyst'),
(8, N'Business Intelligence Analyst'), (14, N'Data Analyst'), (15, N'Educational Data Analyst'),
(21, N'Financial Data Analyst'), (27, N'Data & Analytics Associate'), (31, N'BI Consultant'), (41, N'Marketing Data Analyst');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Data Visualization' (Track_ID = 23)
DECLARE @DataVizTracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @DataVizTracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT 
    ibt.Intake_Branch_Track_ID, 
    i.Intake_ID, 
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 23; -- Track_ID for 'Data Visualization'

-- 2. Get all courses for 'Data Visualization' (Track_ID = 23)
DECLARE @DataVizCourses TABLE (Course_ID INT);
INSERT INTO @DataVizCourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 23;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Data Visualization (Track 23)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each Data Visualization track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @DataVizTracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));
    
    SET @StudentCounter = 1;
    
    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.45 THEN N'Female' ELSE N'Male' END; -- Fairly balanced gender ratio
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.7 THEN N'Married' ELSE N'Single' END; -- 70% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());
        
        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-dataviz.com';
        
        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);
        
        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.07 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 93% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));
        
        IF RAND() > 0.5
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn and maybe GitHub/X
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));
        
        IF RAND() > 0.6 -- Optional GitHub for D3.js projects
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'GitHub', N'https://github.com/' + LOWER(@StudentFname) + LOWER(@StudentLname)); 
            
        IF RAND() > 0.5 -- Optional X (Twitter) for sharing insights/visuals
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'X', N'https://x.com/' + LOWER(@StudentFname) + LOWER(@StudentLname));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate 
        FROM @DataVizCourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.4 -- 60% chance to have freelance jobs
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 2 AS INT) + 1; -- 1 or 2 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT 
                    @CurrentJobID, 
                    @CurrentStudentID,
                    CAST(RAND() * 800 + 200 AS DECIMAL(12, 2)), -- Earn $200 - $1000
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @DataVizJobs ORDER BY NEWID()) AS J;
                
                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.15 -- 85% chance to have certificates
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT 
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 400 + 100 AS DECIMAL(12, 2)), -- Cost $100 - $500
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert earned during the intake
                FROM (SELECT TOP 1 * FROM @DataVizCerts ORDER BY NEWID()) AS C;
                
                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END
        
        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have an 80% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.2
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);
            
            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                DC.Company_ID,
                CAST(RAND() * 13000 + 10000 AS DECIMAL(12, 2)), -- Salary 10k - 23k
                DC.Position,
                N'Full-Time', -- Most data jobs are full-time
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @DataVizCompanies ORDER BY NEWID()) AS DC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 44000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 44000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 44000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO

--Track 24
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 46000;
DECLARE @CurrentJobID INT = 46000;
DECLARE @CurrentCertificateID INT = 46000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Youssef'), (N'Omar'), (N'Adam'), (N'Khaled'), (N'Karim'), (N'Amr'), (N'Tarek'), 
(N'Hazem'), (N'Ziad'), (N'Mazen'), (N'Bilal'), (N'Faris'), (N'Sami'), (N'Nader');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Mariam'), (N'Hana'), (N'Salma'), (N'Aya'), (N'Nour'), (N'Yara'), (N'Lila'), 
(N'Jana'), (N'Farida'), (N'Kenzy'), (N'Malak'), (N'Reem'), (N'Dina'), (N'Lamar');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Masry'), (N'Hassan'), (N'Ali'), (N'Said'), (N'Gamal'), (N'Fathy'), (N'Adel'), 
(N'Zaki'), (N'Ibrahim'), (N'Kamel'), (N'Tawfik'), (N'Rizk'), (N'Shalaby'), (N'Diab');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'15 Abbas El Akkad, Nasr City, Cairo'), (N'27 Tahrir St, Dokki, Giza'), (N'44 Corniche El Nil, Maadi, Cairo'),
(N'10 Fouad St, Raml Station, Alexandria'), (N'88 El Geish St, El Mansoura'), (N'201 University St, Assiut'),
(N'55 El Horreya Rd, Heliopolis, Cairo'), (N'32 Gamal Abdel Nasser, Smouha, Alexandria'), (N'19 El Galaa St, Ismailia');

-- Data pool for University Faculties (Salesforce related - Business/IT mix)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Commerce, Cairo University'), 
(N'Faculty of Computers and Information, Ain Shams University'), 
(N'Faculty of Business Administration, Helwan University'),
(N'Faculty of Economics and Political Science, Cairo University'),
(N'Faculty of Information Systems, Sadat Academy'),
(N'Faculty of Management Technology, German University in Cairo');

-- Data pool for Salesforce related freelance jobs
DECLARE @SalesforceJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @SalesforceJobs (Description, Site) VALUES
(N'Setup custom reports and dashboards in Salesforce Sales Cloud', N'Upwork'),
(N'Configure basic Flow automation for lead assignment', N'Fiverr'),
(N'Data cleaning and import for 500 contacts in Salesforce', N'Freelancer.com'),
(N'Create user profiles and manage permissions for a small team', N'Upwork'),
(N'Customize page layouts for Account and Opportunity objects', N'PeoplePerHour'),
(N'Troubleshoot basic Salesforce configuration issues', N'Fiverr');

-- Data pool for Salesforce related certificates
DECLARE @SalesforceCerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @SalesforceCerts (Name, Provider) VALUES
(N'Salesforce Certified Administrator', N'Salesforce'),
(N'Salesforce Certified Platform App Builder', N'Salesforce'),
(N'Salesforce Certified Sales Cloud Consultant', N'Salesforce'),
(N'Salesforce Certified Service Cloud Consultant', N'Salesforce'),
(N'Salesforce Certified Platform Developer I', N'Salesforce'),
(N'Salesforce Certified Associate', N'Salesforce');

-- Data pool for Salesforce related companies (from the provided list)
DECLARE @SalesforceCompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @SalesforceCompanies (Company_ID, Position) VALUES
(3, N'Junior Salesforce Administrator'), (4, N'Salesforce Consultant'), (10, N'CRM Specialist'),
(11, N'Salesforce Business Analyst'), (13, N'Salesforce Support Specialist'), (27, N'Salesforce Associate Consultant'),
(28, N'CRM Analyst'), (31, N'Salesforce Administrator'), (48, N'Junior Salesforce Developer');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Salesforce Specialist' (Track_ID = 24)
DECLARE @SalesforceTracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @SalesforceTracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT 
    ibt.Intake_Branch_Track_ID, 
    i.Intake_ID, 
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 24; -- Track_ID for 'Salesforce Specialist'

-- 2. Get all courses for 'Salesforce Specialist' (Track_ID = 24)
DECLARE @SalesforceCourses TABLE (Course_ID INT);
INSERT INTO @SalesforceCourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 24;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Salesforce Specialist (Track 24)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each Salesforce track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @SalesforceTracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));
    
    SET @StudentCounter = 1;
    
    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.4 THEN N'Female' ELSE N'Male' END; -- Slightly more females
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.7 THEN N'Married' ELSE N'Single' END; -- 70% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());
        
        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-sf.com';
        
        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);
        
        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.06 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 94% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));
        
        IF RAND() > 0.5
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn (essential) and maybe X
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));
            
        IF RAND() > 0.6 -- Optional X (Twitter)
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'X', N'https://x.com/' + LOWER(@StudentFname) + LOWER(@StudentLname));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate 
        FROM @SalesforceCourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.5 -- 50% chance to have freelance jobs
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 2 AS INT) + 1; -- 1 or 2 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT 
                    @CurrentJobID, 
                    @CurrentStudentID,
                    CAST(RAND() * 700 + 150 AS DECIMAL(12, 2)), -- Earn $150 - $850
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @SalesforceJobs ORDER BY NEWID()) AS J;
                
                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.1 -- 90% chance to have certificates (certs are important in Salesforce)
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT 
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 300 + 100 AS DECIMAL(12, 2)), -- Cost $100 - $400
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert earned during the intake
                FROM (SELECT TOP 1 * FROM @SalesforceCerts ORDER BY NEWID()) AS C;
                
                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END
        
        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have an 85% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.15
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);
            
            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                SC.Company_ID,
                CAST(RAND() * 14000 + 10000 AS DECIMAL(12, 2)), -- Salary 10k - 24k
                SC.Position,
                N'Full-Time', -- Most Salesforce jobs are full-time
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @SalesforceCompanies ORDER BY NEWID()) AS SC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 46000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 46000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 46000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO

--Track 25
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 48000;
DECLARE @CurrentJobID INT = 48000;
DECLARE @CurrentCertificateID INT = 48000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Ahmed'), (N'Mohamed'), (N'Mahmoud'), (N'Mostafa'), (N'Yassin'), (N'Hamza'), (N'Ali'),
(N'Omar'), (N'Khaled'), (N'Karim'), (N'Tarek'), (N'Hassan'), (N'Faris'), (N'Ramy');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Fatima'), (N'Aisha'), (N'Hana'), (N'Salma'), (N'Nour'), (N'Yara'), (N'Lojain'),
(N'Jana'), (N'Farida'), (N'Rowan'), (N'Malak'), (N'Ganna'), (N'Dina'), (N'Sarah');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Sayed'), (N'Hassan'), (N'Ali'), (N'Mahmoud'), (N'Ibrahim'), (N'Abdel-Rahman'), (N'Taha'),
(N'Osman'), (N'Khattab'), (N'Fawzy'), (N'Shahin'), (N'Nasser'), (N'Kamel'), (N'Ezzat');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'123 El Haram St, Giza'), (N'45 Mohi El Din Abu El Ezz, Dokki, Giza'), (N'789 Corniche El Nil, Maadi, Cairo'),
(N'10 El Gomhouria St, Assiut'), (N'88 El Geish St, El Mansoura'), (N'50 Port Said St, Alexandria'),
(N'22 Tanta St, Tanta'), (N'19 El Galaa St, Ismailia'), (N'33 El Obour Buildings, Nasr City, Cairo');

-- Data pool for University Faculties (Business Analysis related)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Commerce, Cairo University'),
(N'Faculty of Computers and Information, Ain Shams University'),
(N'Faculty of Economics and Political Science, Cairo University'),
(N'Faculty of Business Administration, Helwan University'),
(N'Faculty of Information Systems, Modern Academy'),
(N'Faculty of Management Sciences, October University for Modern Sciences and Arts (MSA)');

-- Data pool for Business Analysis related freelance jobs
DECLARE @BAJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @BAJobs (Description, Site) VALUES
(N'Elicit and document requirements for a new mobile app feature', N'Upwork'),
(N'Create process flow diagrams (BPMN) for an existing business process', N'Fiverr'),
(N'Write user stories and acceptance criteria for an e-commerce checkout process', N'Freelancer.com'),
(N'Analyze stakeholder needs for a CRM implementation project', N'Upwork'),
(N'Develop mockups/wireframes for a reporting dashboard', N'PeoplePerHour'),
(N'Conduct market research and competitor analysis for a startup', N'Fiverr');

-- Data pool for Business Analysis related certificates
DECLARE @BACerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @BACerts (Name, Provider) VALUES
(N'ECBA (Entry Certificate in Business Analysis)', N'IIBA'),
(N'CCBA (Certification of Capability in Business Analysis)', N'IIBA'),
(N'CBAP (Certified Business Analysis Professional)', N'IIBA'),
(N'PMI-PBA (Professional in Business Analysis)', N'PMI'),
(N'BCS Foundation Certificate in Business Analysis', N'BCS'),
(N'Agile Analysis Certification (IIBA-AAC)', N'IIBA');

-- Data pool for Business Analysis related companies (from the provided list)
DECLARE @BACompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @BACompanies (Company_ID, Position) VALUES
(3, N'Junior Business Analyst'), (4, N'Business Process Analyst'), (8, N'Systems Analyst'),
(10, N'Consultant - Business Analysis'), (11, N'Associate Business Analyst'), (14, N'Product Analyst'),
(21, N'Financial Business Analyst'), (24, N'IT Business Analyst'), (27, N'Business Analyst Consultant'),
(42, N'Junior Product Manager');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Business Analysis' (Track_ID = 25)
DECLARE @BATracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @BATracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT
    ibt.Intake_Branch_Track_ID,
    i.Intake_ID,
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 25; -- Track_ID for 'Business Analysis'

-- 2. Get all courses for 'Business Analysis' (Track_ID = 25)
DECLARE @BACourses TABLE (Course_ID INT);
INSERT INTO @BACourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 25;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Business Analysis (Track 25)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each Business Analysis track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @BATracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));

    SET @StudentCounter = 1;

    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.4 THEN N'Female' ELSE N'Male' END; -- Slightly more females
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.75 THEN N'Married' ELSE N'Single' END; -- 75% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());

        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-ba.com';

        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);

        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.08 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 92% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));

        IF RAND() > 0.5
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn (essential) and maybe X
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));

        IF RAND() > 0.7 -- Optional X (Twitter)
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'X', N'https://x.com/' + LOWER(@StudentFname) + LOWER(@StudentLname));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate
        FROM @BACourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.6 -- 40% chance to have freelance jobs
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 2 AS INT) + 1; -- 1 or 2 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT
                    @CurrentJobID,
                    @CurrentStudentID,
                    CAST(RAND() * 600 + 100 AS DECIMAL(12, 2)), -- Earn $100 - $700
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @BAJobs ORDER BY NEWID()) AS J;

                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.3 -- 70% chance to have certificates
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 2 AS INT) + 1; -- 1 or 2 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 450 + 150 AS DECIMAL(12, 2)), -- Cost $150 - $600
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert earned during the intake
                FROM (SELECT TOP 1 * FROM @BACerts ORDER BY NEWID()) AS C;

                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have an 80% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.2
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);

            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                BC.Company_ID,
                CAST(RAND() * 12000 + 9000 AS DECIMAL(12, 2)), -- Salary 9k - 21k
                BC.Position,
                N'Full-Time', -- Most BA jobs are full-time
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @BACompanies ORDER BY NEWID()) AS BC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 48000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 48000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 48000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO

--Track 26
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 50000;
DECLARE @CurrentJobID INT = 50000;
DECLARE @CurrentCertificateID INT = 50000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Ahmed'), (N'Mohamed'), (N'Mahmoud'), (N'Mostafa'), (N'Yassin'), (N'Hamza'), (N'Ali'),
(N'Omar'), (N'Khaled'), (N'Karim'), (N'Tarek'), (N'Hassan'), (N'Faris'), (N'Ramy');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Fatima'), (N'Aisha'), (N'Hana'), (N'Salma'), (N'Nour'), (N'Yara'), (N'Lojain'),
(N'Jana'), (N'Farida'), (N'Rowan'), (N'Malak'), (N'Ganna'), (N'Dina'), (N'Sarah');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Sayed'), (N'Hassan'), (N'Ali'), (N'Mahmoud'), (N'Ibrahim'), (N'Abdel-Rahman'), (N'Taha'),
(N'Osman'), (N'Khattab'), (N'Fawzy'), (N'Shahin'), (N'Nasser'), (N'Kamel'), (N'Ezzat');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'123 El Haram St, Giza'), (N'45 Mohi El Din Abu El Ezz, Dokki, Giza'), (N'789 Corniche El Nil, Maadi, Cairo'),
(N'10 El Gomhouria St, Assiut'), (N'88 El Geish St, El Mansoura'), (N'50 Port Said St, Alexandria'),
(N'22 Tanta St, Tanta'), (N'19 El Galaa St, Ismailia'), (N'33 El Obour Buildings, Nasr City, Cairo');

-- Data pool for University Faculties (BA & IA related)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Commerce, Cairo University'),
(N'Faculty of Computers and Information, Ain Shams University'),
(N'Faculty of Engineering, Alexandria University'),
(N'Faculty of Business Administration, Helwan University'),
(N'Faculty of Information Systems, Modern Academy'),
(N'Faculty of Management Technology, German University in Cairo');

-- Data pool for BA & Intelligent Automation related freelance jobs
DECLARE @BA_IAJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @BA_IAJobs (Description, Site) VALUES
(N'Identify and document processes suitable for RPA', N'Upwork'),
(N'Develop a simple UiPath automation for data entry', N'Fiverr'),
(N'Create Process Design Document (PDD) for an attended bot', N'Freelancer.com'),
(N'Analyze requirements for integrating a chatbot with a CRM', N'Upwork'),
(N'Map "As-Is" and "To-Be" process flows for automation candidate', N'PeoplePerHour'),
(N'Test and provide feedback on a developed RPA bot', N'Fiverr');

-- Data pool for BA & Intelligent Automation related certificates
DECLARE @BA_IACerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @BA_IACerts (Name, Provider) VALUES
(N'UiPath Certified RPA Associate (UiRPA)', N'UiPath'),
(N'ECBA (Entry Certificate in Business Analysis)', N'IIBA'),
(N'Blue Prism Certified Associate Developer', N'Blue Prism'),
(N'Microsoft Certified: Power Platform Fundamentals', N'Microsoft'),
(N'CCBA (Certification of Capability in Business Analysis)', N'IIBA'),
(N'Agile Analysis Certification (IIBA-AAC)', N'IIBA');

-- Data pool for BA & Intelligent Automation related companies (from the provided list)
DECLARE @BA_IACompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @BA_IACompanies (Company_ID, Position) VALUES
(3, N'RPA Business Analyst'), (4, N'Automation Consultant'), (10, N'Cognitive Process Automation Analyst'),
(11, N'Junior RPA Developer'), (27, N'Intelligent Automation Associate'), (28, N'Process Improvement Analyst'),
(3, N'Business Process Analyst'), -- VOIS hires a lot in this area
(42, N'Fintech Process Analyst'), (48, N'Junior Automation Engineer');

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Business Analysis and Intelligent Automation Development' (Track_ID = 26)
DECLARE @BA_IATracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @BA_IATracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT
    ibt.Intake_Branch_Track_ID,
    i.Intake_ID,
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 26; -- Track_ID for 'Business Analysis and Intelligent Automation Development'

-- 2. Get all courses for 'Business Analysis and Intelligent Automation Development' (Track_ID = 26)
DECLARE @BA_IACourses TABLE (Course_ID INT);
INSERT INTO @BA_IACourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 26;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Business Analysis and Intelligent Automation (Track 26)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each BA & IA track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @BA_IATracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));

    SET @StudentCounter = 1;

    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.5 THEN N'Female' ELSE N'Male' END; -- Balanced gender ratio
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.7 THEN N'Married' ELSE N'Single' END; -- 70% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());

        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-ba-ia.com';

        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);

        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.09 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 91% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));

        IF RAND() > 0.5
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn (essential) and maybe GitHub/X
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));

        IF RAND() > 0.8 -- Optional GitHub (less common unless building complex bots)
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'GitHub', N'https://github.com/' + LOWER(@StudentFname) + LOWER(@StudentLname));

        IF RAND() > 0.6 -- Optional X (Twitter)
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'X', N'https://x.com/' + LOWER(@StudentFname) + LOWER(@StudentLname));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate
        FROM @BA_IACourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.55 -- 45% chance to have freelance jobs
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 2 AS INT) + 1; -- 1 or 2 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT
                    @CurrentJobID,
                    @CurrentStudentID,
                    CAST(RAND() * 700 + 150 AS DECIMAL(12, 2)), -- Earn $150 - $850
                    DATEADD(DAY, RAND() * 120, @IntakeStartDate), -- Job during the intake
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @BA_IAJobs ORDER BY NEWID()) AS J;

                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.2 -- 80% chance to have certificates
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 400 + 100 AS DECIMAL(12, 2)), -- Cost $100 - $500
                    DATEADD(DAY, RAND() * 150, @IntakeStartDate) -- Cert earned during the intake
                FROM (SELECT TOP 1 * FROM @BA_IACerts ORDER BY NEWID()) AS C;

                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have an 85% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.15
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);

            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                BC.Company_ID,
                CAST(RAND() * 13000 + 10000 AS DECIMAL(12, 2)), -- Salary 10k - 23k
                BC.Position,
                N'Full-Time', -- Most BA/IA jobs are full-time
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @BA_IACompanies ORDER BY NEWID()) AS BC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 50000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 50000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 50000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO

--Track 27
-- =======================================================================
-- Configuration & Setup
-- =======================================================================
SET NOCOUNT ON;
GO

-- Set the starting IDs as requested
DECLARE @CurrentStudentID INT = 52000;
DECLARE @CurrentJobID INT = 52000;
DECLARE @CurrentCertificateID INT = 52000;

-- Get the current date to determine graduation status and check age constraint
DECLARE @Today DATE = GETDATE(); -- Using GETDATE() as per the table constraints

-- =======================================================================
-- Data Pools for Random Generation
-- =======================================================================

-- Data pool for Male names
DECLARE @MaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @MaleNames (Name) VALUES
(N'Ahmed'), (N'Mohamed'), (N'Mahmoud'), (N'Mostafa'), (N'Yassin'), (N'Hamza'), (N'Ali'),
(N'Omar'), (N'Khaled'), (N'Karim'), (N'Tarek'), (N'Hassan'), (N'Faris'), (N'Ramy');

-- Data pool for Female names
DECLARE @FemaleNames TABLE (Name NVARCHAR(50));
INSERT INTO @FemaleNames (Name) VALUES
(N'Fatima'), (N'Aisha'), (N'Hana'), (N'Salma'), (N'Nour'), (N'Yara'), (N'Lojain'),
(N'Jana'), (N'Farida'), (N'Rowan'), (N'Malak'), (N'Ganna'), (N'Dina'), (N'Sarah');

-- Data pool for Last names
DECLARE @LastNames TABLE (Name NVARCHAR(50));
INSERT INTO @LastNames (Name) VALUES
(N'El-Sayed'), (N'Hassan'), (N'Ali'), (N'Mahmoud'), (N'Ibrahim'), (N'Abdel-Rahman'), (N'Taha'),
(N'Osman'), (N'Khattab'), (N'Fawzy'), (N'Shahin'), (N'Nasser'), (N'Kamel'), (N'Ezzat');

-- Data pool for Addresses
DECLARE @Addresses TABLE (Address NVARCHAR(255));
INSERT INTO @Addresses (Address) VALUES
(N'123 El Haram St, Giza'), (N'45 Mohi El Din Abu El Ezz, Dokki, Giza'), (N'789 Corniche El Nil, Maadi, Cairo'),
(N'10 El Gomhouria St, Assiut'), (N'88 El Geish St, El Mansoura'), (N'50 Port Said St, Alexandria'),
(N'22 Tanta St, Tanta'), (N'19 El Galaa St, Ismailia'), (N'33 El Obour Buildings, Nasr City, Cairo');

-- Data pool for University Faculties (Social Media Marketing related)
DECLARE @Faculties TABLE (Name NVARCHAR(100));
INSERT INTO @Faculties (Name) VALUES
(N'Faculty of Mass Communication, Cairo University'),
(N'Faculty of Commerce (English Section), Ain Shams University'),
(N'Faculty of Arts (Media Dept.), Alexandria University'),
(N'Faculty of Al-Alsun (Languages), Minia University'),
(N'Faculty of Business Administration, Helwan University'),
(N'Faculty of Economics and Political Science, Cairo University');

-- Data pool for Social Media Marketing related freelance jobs
DECLARE @SMMJobs TABLE (Description NVARCHAR(1000), Site NVARCHAR(255));
INSERT INTO @SMMJobs (Description, Site) VALUES
(N'Manage Facebook & Instagram pages for a local restaurant (content & community)', N'Upwork'),
(N'Run a lead generation campaign on LinkedIn Ads for a B2B client', N'Fiverr'),
(N'Create a content calendar (30 posts) for a fashion brand', N'Freelancer.com'),
(N'Set up and manage Google Ads campaign for an e-commerce store', N'Upwork'),
(N'Analyze social media performance and provide monthly reports', N'PeoplePerHour'),
(N'Write engaging captions for 20 Instagram posts', N'Fiverr');

-- Data pool for Social Media Marketing related certificates
DECLARE @SMMCerts TABLE (Name NVARCHAR(200), Provider NVARCHAR(200));
INSERT INTO @SMMCerts (Name, Provider) VALUES
(N'Meta Certified Digital Marketing Associate', N'Meta Blueprint'),
(N'Google Ads Display Certification', N'Google Skillshop'),
(N'HubSpot Content Marketing Certification', N'HubSpot Academy'),
(N'Hootsuite Platform Certification', N'Hootsuite Academy'),
(N'Digital Marketing Professional Certificate', N'Digital Marketing Institute (DMI)'),
(N'Semrush SEO Toolkit Exam', N'Semrush Academy');

-- Data pool for Social Media Marketing related companies (from the provided list)
DECLARE @SMMCompanies TABLE (Company_ID INT, Position NVARCHAR(100));
INSERT INTO @SMMCompanies (Company_ID, Position) VALUES
(3, N'Social Media Specialist'), (6, N'Digital Marketing Executive'), (13, N'Online Marketing Specialist'),
(14, N'E-commerce Marketing Officer'), (16, N'Content Creator'), (41, N'Performance Marketing Specialist'), -- ArabyAds is relevant
(46, N'Social Media Coordinator'), -- Talabat/Delivery Hero
(50, N'Digital Marketing Intern'), -- Jumia
(41, N'SEO Specialist'); -- ArabyAds also does SEO

-- =======================================================================
-- Identify Target Tracks and Courses
-- =======================================================================

-- 1. Get all Intake_Branch_Track combinations for 'Social Media Marketing' (Track_ID = 27)
DECLARE @SMMTracks TABLE (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT,
    Intake_Start_Date DATE,
    Intake_End_Date DATE,
    IsGraduated BIT
);

INSERT INTO @SMMTracks (Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated)
SELECT
    ibt.Intake_Branch_Track_ID,
    i.Intake_ID,
    i.Intake_Start_Date,
    i.Intake_End_Date,
    CASE WHEN i.Intake_End_Date < @Today THEN 1 ELSE 0 END
FROM Intake_Branch_Track ibt
JOIN Intake i ON ibt.Intake_ID = i.Intake_ID
WHERE ibt.Track_ID = 27; -- Track_ID for 'Social Media Marketing'

-- 2. Get all courses for 'Social Media Marketing' (Track_ID = 27)
DECLARE @SMMCourses TABLE (Course_ID INT);
INSERT INTO @SMMCourses (Course_ID)
SELECT Course_ID FROM Track_Course WHERE Track_ID = 27;


-- =======================================================================
-- Main Generation Loop
-- =======================================================================

PRINT 'Starting data generation for Social Media Marketing (Track 27)...';

-- Declare variables for the loop
DECLARE @CurrentIBT_ID INT;
DECLARE @CurrentIntakeID INT;
DECLARE @IntakeStartDate DATE;
DECLARE @IntakeEndDate DATE;
DECLARE @IsGraduated BIT;
DECLARE @StudentCounter INT;

-- Declare variables for student data
DECLARE @StudentGender NVARCHAR(10);
DECLARE @StudentMaritalStatus NVARCHAR(50);
DECLARE @StudentFname NVARCHAR(50);
DECLARE @StudentLname NVARCHAR(50);
DECLARE @StudentMail NVARCHAR(100);
DECLARE @StudentBirthdate DATE;
DECLARE @StudentAddress NVARCHAR(255);
DECLARE @StudentFaculty NVARCHAR(100);
DECLARE @StudentFacultyGrade NVARCHAR(50);
DECLARE @StudentITIStatus NVARCHAR(50);
DECLARE @HireDate DATE;

-- CURSOR to loop through each Social Media Marketing track found
DECLARE TrackCursor CURSOR FOR
    SELECT Intake_Branch_Track_ID, Intake_ID, Intake_Start_Date, Intake_End_Date, IsGraduated
    FROM @SMMTracks;

OPEN TrackCursor;
FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  Generating 25 students for Intake_Branch_Track_ID: ' + CAST(@CurrentIBT_ID AS VARCHAR(10));

    SET @StudentCounter = 1;

    -- Inner loop to create 25 students for this track
    WHILE @StudentCounter <= 25
    BEGIN
        -- 1. Generate Student Base Data
        SET @StudentGender = CASE WHEN RAND() > 0.35 THEN N'Female' ELSE N'Male' END; -- More females in SMM
        SET @StudentMaritalStatus = CASE WHEN RAND() > 0.8 THEN N'Married' ELSE N'Single' END; -- 80% Single
        SET @StudentFacultyGrade = (SELECT TOP 1 Grade FROM (VALUES (N'Excellent'), (N'Very Good'), (N'Good'), (N'Pass')) AS G(Grade) ORDER BY NEWID());
        SET @StudentAddress = (SELECT TOP 1 Address FROM @Addresses ORDER BY NEWID());
        SET @StudentFaculty = (SELECT TOP 1 Name FROM @Faculties ORDER BY NEWID());

        -- Generate names
        IF @StudentGender = N'Male'
            SET @StudentFname = (SELECT TOP 1 Name FROM @MaleNames ORDER BY NEWID());
        ELSE
            SET @StudentFname = (SELECT TOP 1 Name FROM @FemaleNames ORDER BY NEWID());

        SET @StudentLname = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
        -- Ensure unique email
        SET @StudentMail = LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)) + '@iti-smm.com';

        -- Generate a birthdate that respects the 18-year-old CHECK constraint
        -- (Born between 18 and 28 years ago from @Today)
        SET @StudentBirthdate = DATEADD(DAY, -(RAND() * 3650 + (18 * 365.25)), @Today);

        -- Determine ITI Status based on Intake dates
        IF @IsGraduated = 1
            SET @StudentITIStatus = CASE WHEN RAND() > 0.1 THEN N'Graduated' ELSE N'Failed to Graduate' END; -- 90% graduation rate
        ELSE
            SET @StudentITIStatus = N'In Progress';

        -- ============================================
        -- INSERT INTO Student
        -- ============================================
        INSERT INTO Student (
            Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status,
            Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade,
            Student_ITI_Status, Intake_Branch_Track_ID
        )
        VALUES (
            @CurrentStudentID, @StudentMail, @StudentAddress, @StudentGender, @StudentMaritalStatus,
            @StudentFname, @StudentLname, @StudentBirthdate, @StudentFaculty, @StudentFacultyGrade,
            @StudentITIStatus, @CurrentIBT_ID
        );

        -- ============================================
        -- INSERT INTO Student_Phone
        -- ============================================
        -- Add one or two phone numbers
        INSERT INTO Student_Phone (Student_ID, Phone)
        VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 100000000 AS NVARCHAR(9)));

        IF RAND() > 0.4
            INSERT INTO Student_Phone (Student_ID, Phone)
            VALUES (@CurrentStudentID, N'01' + CAST(CAST(RAND() * 100000000 AS INT) + 200000000 AS NVARCHAR(9)));

        -- ============================================
        -- INSERT INTO Student_Social
        -- ============================================
        -- Add LinkedIn, Facebook, Instagram (essential for SMM)
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'LinkedIn', N'https://linkedin.com/in/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(@CurrentStudentID AS NVARCHAR(10)));

        -- Add random numbers to Facebook URL attempt to avoid potential (though unlikely in dummy data) non-uniqueness if PK includes URL
        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'Facebook', N'https://facebook.com/' + LOWER(@StudentFname) + '.' + LOWER(@StudentLname) + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR(4)));

        INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
        VALUES (@CurrentStudentID, N'Instagram', N'https://instagram.com/' + LOWER(@StudentFname) + '_' + LOWER(@StudentLname) + CAST(ABS(CHECKSUM(NEWID())) % 100 AS VARCHAR(3)));

        IF RAND() > 0.5 -- Optional X
            INSERT INTO Student_Social (Student_ID, Social_Type, Social_Url)
            VALUES (@CurrentStudentID, N'X', N'https://x.com/' + LOWER(@StudentFname) + LOWER(@StudentLname) + CAST(ABS(CHECKSUM(NEWID())) % 50 AS VARCHAR(2)));

        -- ============================================
        -- INSERT INTO Student_Course
        -- ============================================
        -- Add ALL courses for this track to this student
        INSERT INTO Student_Course (Student_ID, Course_ID, Course_StartDate, Course_EndDate)
        SELECT @CurrentStudentID, Course_ID, @IntakeStartDate, @IntakeEndDate
        FROM @SMMCourses;

        -- ============================================
        -- INSERT INTO Freelance_Job (Optional & Related)
        -- ============================================
        IF RAND() > 0.25 -- 75% chance to have freelance jobs (very common in SMM)
        BEGIN
            DECLARE @JobCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 jobs
            WHILE @JobCount > 0
            BEGIN
                INSERT INTO Freelance_Job (Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
                SELECT
                    @CurrentJobID,
                    @CurrentStudentID,
                    CAST(RAND() * 500 + 50 AS DECIMAL(12, 2)), -- Earn $50 - $550 (can be smaller gigs)
                    DATEADD(DAY, CAST(RAND() * DATEDIFF(DAY, @IntakeStartDate, ISNULL(@IntakeEndDate, @Today)) AS INT), @IntakeStartDate), -- Job during the intake period
                    J.Site,
                    J.Description
                FROM (SELECT TOP 1 * FROM @SMMJobs ORDER BY NEWID()) AS J;

                SET @CurrentJobID = @CurrentJobID + 1;
                SET @JobCount = @JobCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Certificate (Optional & Related)
        -- ============================================
        IF RAND() > 0.15 -- 85% chance to have certificates (highly valued in SMM)
        BEGIN
            DECLARE @CertCount INT = CAST(RAND() * 3 AS INT) + 1; -- 1 to 3 certs
            WHILE @CertCount > 0
            BEGIN
                INSERT INTO Certificate (Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
                SELECT
                    @CurrentCertificateID,
                    @CurrentStudentID,
                    C.Name,
                    C.Provider,
                    CAST(RAND() * 200 + 0 AS DECIMAL(12, 2)), -- Many SMM certs are free or low cost
                    DATEADD(DAY, CAST(RAND() * DATEDIFF(DAY, @IntakeStartDate, ISNULL(@IntakeEndDate, @Today)) AS INT) , @IntakeStartDate) -- Cert earned during the intake period
                FROM (SELECT TOP 1 * FROM @SMMCerts ORDER BY NEWID()) AS C;

                SET @CurrentCertificateID = @CurrentCertificateID + 1;
                SET @CertCount = @CertCount - 1;
            END
        END

        -- ============================================
        -- INSERT INTO Student_Company (Conditional & Related)
        -- ============================================
        -- RULE: Only if status is 'Graduated' AND they have a 70% chance of getting a job
        IF @StudentITIStatus = N'Graduated' AND RAND() > 0.3
        BEGIN
            -- Hire date is within 30 days after graduation
            SET @HireDate = DATEADD(DAY, CAST(RAND() * 30 AS INT) + 1, @IntakeEndDate);

            INSERT INTO Student_Company (Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
            SELECT
                @CurrentStudentID,
                SC.Company_ID,
                CAST(RAND() * 8000 + 6000 AS DECIMAL(12, 2)), -- Salary 6k - 14k (Entry level SMM)
                SC.Position,
                CASE WHEN RAND() > 0.15 THEN N'Full-Time' ELSE N'Part-Time' END, -- Some part-time is possible
                @HireDate,
                NULL -- Still employed
            FROM (SELECT TOP 1 * FROM @SMMCompanies ORDER BY NEWID()) AS SC;
        END

        -- Increment for next student
        SET @CurrentStudentID = @CurrentStudentID + 1;
        SET @StudentCounter = @StudentCounter + 1;
    END; -- End of 25-student loop

    FETCH NEXT FROM TrackCursor INTO @CurrentIBT_ID, @CurrentIntakeID, @IntakeStartDate, @IntakeEndDate, @IsGraduated;
END; -- End of track loop

CLOSE TrackCursor;
DEALLOCATE TrackCursor;

PRINT '------------------------------------------------';
PRINT 'Data generation complete.';
PRINT 'Total Students Inserted: ' + CAST((@CurrentStudentID - 52000) AS VARCHAR(10));
PRINT 'Total Jobs Inserted: ' + CAST((@CurrentJobID - 52000) AS VARCHAR(10));
PRINT 'Total Certificates Inserted: ' + CAST((@CurrentCertificateID - 52000) AS VARCHAR(10));
PRINT '------------------------------------------------';
GO