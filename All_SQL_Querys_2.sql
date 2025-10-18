-- ============================================
-- DATABASE Creation: ITI Examination System
-- By Ahmed Arab 
-- 13/10/2025 06:00 PM
-- ============================================

-- ================
-- INSTRUCTOR
-- ================
CREATE TABLE Instructor (
    Instructor_ID INT PRIMARY KEY,
    Instructor_Fname NVARCHAR(50) NOT NULL,
    Instructor_Lname NVARCHAR(50) NOT NULL,
    Instructor_Gender NVARCHAR(10) CHECK (Instructor_Gender IN (N'Male', N'Female')),
    Instructor_Birthdate DATE CHECK (DATEADD(year, 18, Instructor_Birthdate) <= GETDATE()),
    Instructor_Marital_Status NVARCHAR(50) CHECK (Instructor_Marital_Status IN (N'Married', N'Single')),
    Instructor_Salary INT  CHECK (Instructor_Salary >= 8000),
    Instructor_Contract_Type NVARCHAR(50) CHECK (Instructor_Contract_Type IN (N'Full-Time', N'Part-Time')),
    Instructor_Email NVARCHAR(150),
    Department_ID INT --The Relation (FOREIGN KEY) Would be Done when Department table is created 
);

CREATE TABLE Instructor_Phone (
    Instructor_ID INT NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    PRIMARY KEY (Instructor_ID, Phone),
    FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID) ON DELETE CASCADE
);

-- ================
-- TRACK / DEPARTMENT / INTAKE / BRANCH
-- ================
CREATE TABLE Department (
    Department_ID INT PRIMARY KEY,
    Department_Name NVARCHAR(200) NOT NULL,
    Manager_ID INT ,
    FOREIGN KEY (Manager_ID) REFERENCES Instructor(Instructor_ID) ON DELETE SET NULL
);
ALTER TABLE Instructor ADD CONSTRAINT FK_Instructor_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID);

CREATE TABLE Intake (
    Intake_ID INT PRIMARY KEY,
    Intake_Name NVARCHAR(200) NOT NULL,
    Intake_Type NVARCHAR(50) CHECK (Intake_Type IN (N'Professional Training Program - (9 Months)' , 
                                                    N'Intensive Code Camps - (4 Months)')),
    Intake_Start_Date DATE NOT NULL,
    Intake_End_Date DATE NOT NULL
);

CREATE TABLE Branch (
    Branch_ID INT PRIMARY KEY,
    Branch_Location NVARCHAR(200),
    Branch_Name NVARCHAR(200) NOT NULL,
    Branch_Start_Date DATE NOT NULL
);

CREATE TABLE Track (
    Track_ID INT  PRIMARY KEY,
    Track_Name NVARCHAR(200) NOT NULL,
    Department_ID INT NOT NULL,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID) ON DELETE CASCADE
);

CREATE TABLE Intake_Branch_Track (
    Intake_Branch_Track_ID INT PRIMARY KEY,
    Intake_ID INT NOT NULL,
    Branch_ID INT NOT NULL,
    Track_ID INT NOT NULL,
    FOREIGN KEY (Intake_ID) REFERENCES Intake(Intake_ID) ON DELETE CASCADE,
    FOREIGN KEY (Track_ID) REFERENCES Track(Track_ID) ON DELETE CASCADE,
    FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID) ON DELETE CASCADE
);

-- ================
-- STUDENT
-- ================
CREATE TABLE Student (
    Student_ID INT  PRIMARY KEY,
    Student_Mail NVARCHAR(100) NOT NULL UNIQUE,
    Student_Address NVARCHAR(255) ,
    Student_Gender NVARCHAR(10) CHECK (Student_Gender IN (N'Male', N'Female')),
    Student_Marital_Status NVARCHAR(50) CHECK (Student_Marital_Status IN (N'Married', N'Single')),
    Student_Fname NVARCHAR(50) NOT NULL,
    Student_Lname NVARCHAR(50) NOT NULL,
    Student_Birthdate DATE NOT NULL CHECK (DATEADD(year, 18, Student_Birthdate) <= GETDATE()),
    Student_Faculty NVARCHAR(100) ,
    Student_Faculty_Grade NVARCHAR(50) CHECK (Student_Faculty_Grade IN (N'Excellent', N'Very Good',N'Good',N'Pass')),
    Student_ITI_Status NVARCHAR(50) CHECK (Student_ITI_Status IN (N'Graduated', N'Failed to Graduate',N'In Progress')),
    Intake_Branch_Track_ID INT NOT NULL,
    FOREIGN KEY (Intake_Branch_Track_ID) REFERENCES Intake_Branch_Track(Intake_Branch_Track_ID) ON DELETE CASCADE,
);

CREATE TABLE Student_Phone (
    Student_ID INT NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    PRIMARY KEY (Student_ID, Phone),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

CREATE TABLE Student_Social (
    Student_ID INT NOT NULL,
    Social_Type NVARCHAR(50) NOT NULL CHECK (Social_Type IN (N'Facebook',N'LinkedIn',N'Instagram',N'GitHub',N'X')), 
    Social_Url NVARCHAR(400) NOT NULL,
    PRIMARY KEY (Student_ID, Social_Type),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

-- ================
-- FREELANCE JOBS & CERTIFICATES
-- ================
CREATE TABLE Freelance_Job (
    Job_ID INT PRIMARY KEY,
    Student_ID INT NOT NULL,
    Job_Earn DECIMAL(12,2) NOT NULL,
    Job_Date DATE NOT NULL,
    Job_Site NVARCHAR(255) ,
    Description NVARCHAR(1000) NULL,
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

CREATE TABLE Certificate (
    Certificate_ID INT PRIMARY KEY,
    Student_ID INT NOT NULL,
    Certificate_Name NVARCHAR(200) NOT NULL,
    Certificate_Provider NVARCHAR(200) NULL,
    Certificate_Cost DECIMAL(12,2),
    Certificate_Date DATE ,
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

-- ================
-- COMPANY & EMPLOYMENT
-- ================
CREATE TABLE Company (
    Company_ID INT PRIMARY KEY,
    Company_Name NVARCHAR(200) NOT NULL,
    Company_Location NVARCHAR(200) ,
    Company_Type NVARCHAR(100) CHECK(Company_Type = N'Multinational' OR Company_Type = N'National')
);



CREATE TABLE Student_Company (
    Student_ID INT NOT NULL,
    Company_ID INT NOT NULL,
    Salary DECIMAL(12,2) ,
    Position NVARCHAR(100),
    Contract_Type NVARCHAR(50) CHECK (Contract_Type IN (N'Full-Time', N'Part-Time')),
    Hire_Date DATE ,
    Leave_Date DATE ,
    PRIMARY KEY (Student_ID, Company_ID),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE,
    FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID) ON DELETE CASCADE
);



-- ================
-- COURSE
-- ================
CREATE TABLE Course (
    Course_ID INT PRIMARY KEY,
    Course_Name NVARCHAR(200) NOT NULL
);

CREATE TABLE Track_Course (
    Course_ID INT NOT NULL,
    Track_ID INT NOT NULL,
    PRIMARY KEY (Track_ID, Course_ID),
    FOREIGN KEY (Track_ID) REFERENCES Track(Track_ID) ,
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) 
    
);

CREATE TABLE Instructor_Course (
    Instructor_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    PRIMARY KEY (Instructor_ID, Course_ID),
    FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID) ON DELETE CASCADE,
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE
);

CREATE TABLE Student_Course (
    Student_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Course_StartDate DATE ,
    Course_EndDate DATE ,
    PRIMARY KEY (Student_ID, Course_ID),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE,
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE
);

-- ================
-- EXAMS & QUESTIONS
-- ================
CREATE TABLE Exam (
    Exam_ID INT PRIMARY KEY,
    Course_ID INT NOT NULL,
    Instructor_ID INT NOT NULL,
    Exam_Date DATE NOT NULL,
    Exam_Duration_Minutes INT NOT NULL CHECK (Exam_Duration_Minutes > 0),
    Exam_Type NVARCHAR(50) CHECK (Exam_Type IN (N'Normal', N'Corrective')),
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE,
    FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID) ON DELETE CASCADE
);

CREATE TABLE Question_Bank (
    Question_ID INT PRIMARY KEY,
    Course_ID INT NOT NULL,
    Question_Type NVARCHAR(50) CHECK (Question_Type IN (N'MCQ', N'True/False')),
    Question_Description NVARCHAR(1000) NOT NULL,
    Question_Model_Answer NVARCHAR(1000) NOT NULL,
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE
);

CREATE TABLE Question_Choice (
    Question_Choice_ID INT PRIMARY KEY,
    Question_ID INT NOT NULL ,
    Choice_Text NVARCHAR(500) NOT NULL,
    FOREIGN KEY (Question_ID) REFERENCES Question_Bank(Question_ID) ON DELETE CASCADE
);

CREATE TABLE Exam_Questions (
    Exam_ID INT NOT NULL,
    Question_ID INT NOT NULL,
    PRIMARY KEY (Exam_ID, Question_ID),
    FOREIGN KEY (Exam_ID) REFERENCES Exam(Exam_ID),
    FOREIGN KEY (Question_ID) REFERENCES Question_Bank(Question_ID) 
);

CREATE TABLE Student_Exam_Answer (
    Exam_ID INT NOT NULL,
    Question_ID INT NOT NULL,
    Student_ID INT NOT NULL,
    Student_Answer NVARCHAR(1000) ,
    Student_Grade DECIMAL(6,2) CHECK (Student_Grade >= 0),
    PRIMARY KEY (Exam_ID, Question_ID, Student_ID),
    FOREIGN KEY (Exam_ID) REFERENCES Exam(Exam_ID) ,
    FOREIGN KEY (Question_ID) REFERENCES Question_Bank(Question_ID) ,
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID)
);

-- ================
-- RATING / FEEDBACK
-- ================
CREATE TABLE Rating (
    Student_ID INT NOT NULL,
    Instructor_ID INT NOT NULL,
    RatingValue TINYINT NOT NULL CHECK (RatingValue BETWEEN 1 AND 10),
    PRIMARY KEY (Student_ID, Instructor_ID),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID) 
);

-- ================
-- TOPICS
-- ================
CREATE TABLE Topic (
    Topic_ID INT  PRIMARY KEY,
    Topic_Name NVARCHAR(200) NOT NULL,
    Course_ID INT NOT NULL,
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE
);

-- ============================================
-- END OF Creation
-- ============================================
--AhmedArabBackup1.0.bak 13/10/2025 09:00 PM
-- ============================================


-- ============================================
-- Generation Data 
-- ============================================

-- ============================================
-- Departments & Instructor_Managers Data 
-- ============================================


INSERT INTO Department (Department_ID, Department_Name)
VALUES
(1, N'System Development'),
(2, N'Java'),
(3, N'Multimedia'),
(4, N'Unix'),
(5, N'Network'),
(6, N'E-Business');

--Insert the new Department
INSERT INTO Department (Department_ID, Department_Name)
VALUES
(7, N'Soft Skills');

INSERT INTO Instructor (
    Instructor_ID,
    Instructor_Fname, 
    Instructor_Lname, 
    Instructor_Gender,          
    Instructor_Birthdate,       
    Instructor_Marital_Status,  
    Instructor_Salary,          
    Instructor_Contract_Type, 
    Instructor_Email, 
    Department_ID
)
VALUES
(1, N'Ahmed',   N'Samir',   N'Male',    '1985-05-20', N'Married', 15000, N'Full-Time', N'ahmed.samir@iti.edu.eg',    1), 
(2, N'Salma',   N'Fathy',   N'Female',  '1990-11-15', N'Single',   9500, N'Part-Time', N'salma.fathy@iti.edu.eg',    2), 
(3, N'Youssef', N'Farid',   N'Male',    '1988-02-10', N'Single',   9000, N'Part-Time', N'youssef.farid@iti.edu.eg',  3), 
(4, N'Rana',    N'Adel',    N'Female',  '1982-07-30', N'Married', 16000, N'Full-Time', N'rana.adel@iti.edu.eg',      4), 
(5, N'Khaled',  N'Mostafa', N'Male',    '1980-01-25', N'Married', 17500, N'Full-Time', N'khaled.mostafa@iti.edu.eg', 5), 
(6, N'Dina',    N'Hassan',  N'Female',  '1992-09-05', N'Single',   8500, N'Part-Time', N'dina.hassan@iti.edu.eg',    6);

INSERT INTO Instructor (
    Instructor_ID,
    Instructor_Fname,
    Instructor_Lname,
    Instructor_Gender,
    Instructor_Birthdate,
    Instructor_Marital_Status,
    Instructor_Salary,
    Instructor_Contract_Type,
    Instructor_Email,
    Department_ID
)
VALUES
(193, N'Mona',   N'Selim',   N'Female', '1983-03-15', N'Married', 14000, N'Full-Time', N'mona.selim@iti.edu.eg',   7),
(194, N'Tamer',  N'Adel',    N'Male',   '1991-07-22', N'Single',  11000, N'Full-Time', N'tamer.adel@iti.edu.eg',   7),
(195, N'Heba',   N'Zaki',    N'Female', '1989-11-01', N'Single',   9000, N'Part-Time', N'heba.zaki@iti.edu.eg',    7),
(196, N'Karim',  N'Raouf',   N'Male',   '1985-01-30', N'Married', 12000, N'Full-Time', N'karim.raouf@iti.edu.eg',  7),
(197, N'Laila',  N'Nader',   N'Female', '1993-06-10', N'Single',   8500, N'Part-Time', N'laila.nader@iti.edu.eg',  7);

INSERT INTO Instructor_Phone (Instructor_ID, Phone)
VALUES
(1, N'01011122334'),
(1, N'01122334455'),
(2, N'01098765432'),
(3, N'01234567890'),
(4, N'01512345678'),
(5, N'01055667788'),
(6, N'01066778899');

UPDATE Department SET Manager_ID = 1 WHERE Department_ID = 1; -- System Development
UPDATE Department SET Manager_ID = 2 WHERE Department_ID = 2; -- Java
UPDATE Department SET Manager_ID = 3 WHERE Department_ID = 3; -- Multimedia
UPDATE Department SET Manager_ID = 4 WHERE Department_ID = 4; -- Unix
UPDATE Department SET Manager_ID = 5 WHERE Department_ID = 5; -- Network
UPDATE Department SET Manager_ID = 6 WHERE Department_ID = 6; -- E-Business
UPDATE Department SET Manager_ID = 193 WHERE Department_ID = 7;--Set the manager for the new 'Soft Skills' department

-- ============================================
--   INTAKE & BRANCH & TRACK  Data 
-- ============================================

INSERT INTO Intake (Intake_ID, Intake_Name, Intake_Type, Intake_Start_Date, Intake_End_Date)
VALUES
-- ===== 2023 =====
(1, 'Round 2023/2024', N'Professional Training Program - (9 Months)', '2023-10-01', '2024-06-30'),
(2, 'Round 1 2023', N'Intensive Code Camps - (4 Months)', '2023-02-01', '2023-05-31'),
(3, 'Round 2 2023', N'Intensive Code Camps - (4 Months)', '2023-07-01', '2023-10-31'),
(4, 'Round 3 2023', N'Intensive Code Camps - (4 Months)', '2023-11-01', '2024-02-29'),

-- ===== 2024 =====
(5, 'Round 2024/2025', N'Professional Training Program - (9 Months)', '2024-10-01', '2025-06-30'),
(6, 'Round 1 2024', N'Intensive Code Camps - (4 Months)', '2024-02-01', '2024-05-31'),
(7, 'Round 2 2024', N'Intensive Code Camps - (4 Months)', '2024-07-01', '2024-10-31'),
(8, 'Round 3 2024', N'Intensive Code Camps - (4 Months)', '2024-11-01', '2025-02-28')


INSERT INTO Branch (Branch_ID, Branch_Location, Branch_Name, Branch_Start_Date)
VALUES 
(1, 'Giza', 'Smart Village', '2009-01-01'),
(2, 'Alexandria', 'Alexandria', '1996-01-01'),
(3, 'Assiut', 'Assiut', '2007-01-01'),
(4, 'El Mansoura', 'El Mansoura', '2007-01-01'),
(5, 'Ismailia', 'Ismailia', '2013-01-01'),
(6, 'El Menoufia', 'El Menoufia', '2020-01-01'),
(7, 'El Minia', 'El Minia', '2020-01-01'),
(8, 'Sohag', 'Sohag', '2020-01-01'),
(9, 'Qena', 'Qena', '2020-01-01'),
(10, 'Aswan', 'Aswan', '2021-01-01'),
(11, 'New Capital', 'New Capital', '2022-01-01'),
(12, 'Giza', 'Cairo University', '2022-01-01'),
(13, 'New Valley', 'New Valley', '2023-01-01'),
(14, 'Beni Sweif', 'Beni Sweif', '2023-01-01'),
(15, 'Benha', 'Benha', '2024-01-01'),
(16, 'El Fayoum', 'El Fayoum', '2024-01-01'),
(17, 'Port Said', 'Port Said', '2024-01-01'),
(18, 'Al Arish', 'Al Arish', '2024-01-01'),
(19, 'Zagazig', 'Zagazig', '2024-01-01'),
(20, 'Damanhour', 'Damanhour', '2024-01-01'),
(21, 'Tanta', 'Tanta', '2024-01-01');

INSERT INTO Track (Track_ID, Track_Name, Department_ID)
VALUES
-- Department 1: System Development
(1, N'Power BI Development', 1),
(2, N'Industrial Automation', 1),
(3, N'AWS Re /Start', 1),
(4, N'Python and DevOps Development', 1),
(5, N'Data Engineering', 1),
(6, N'Front-End and Cross Platform Mobile Development', 1),
(7, N'iOS Mobile Application Development', 1),
(8, N'Software Development Fundamentals', 1),
(9, N'Software Testing', 1),
(10, N'Renewable Energy', 1),

-- Department 2: Java (Assuming this was a typo for Department 2)
(11, N'Full Stack Web Development Using .Net', 2),
(12, N'Full Stack Web Development Using MERN', 2),
(13, N'Full Stack Web Development using Python', 2),
(14, N'Web Development Using CMS', 2),
(15, N'Full Stack Web Development using PHP', 2),

-- Department 3: Multimedia (Corrected from 3 to 4)
(16, N'2D Graphics Design', 3),
(17, N'3D Modeling', 3),
(18, N'Motion Graphics', 3),
(19, N'Concept Art', 3),
(20, N'UI/UX Design', 3),

-- Department 4: Unix 
(21, N'Systems Administration', 4),

-- Department 5: Network 
(22, N'Cybersecurity Associate', 5),

-- Department 6: E-Business 
(23, N'Data Visualization', 6),
(24, N'Salesforce Specialist', 6),
(25, N'Business Analysis', 6),
(26, N'Business Analysis and Intelligent Automation Development',6),
(27, N'Social Media Marketing', 6);



INSERT INTO Intake_Branch_Track (Intake_Branch_Track_ID, Intake_ID, Branch_ID, Track_ID)
VALUES
-- =================================================================================================
-- YEAR 2023
-- =================================================================================================

-- Intake 1: Round 2023/2024 (9 Months), Start Date: 2023-10-01 (Branches 1-14 Open)
----------------------------------------------------------------------------------------------------
(1, 1, 1, 5), (2, 1, 1, 12), (3, 1, 1, 20), (4, 1, 1, 25), -- Intake: Round 2023/2024, Branch: Smart Village, Tracks: Data Engineering, MERN, UI/UX Design, Business Analysis
(5, 1, 2, 7), (6, 1, 2, 11), (7, 1, 2, 18), (8, 1, 2, 22), -- Intake: Round 2023/2024, Branch: Alexandria, Tracks: iOS Dev, .Net, Motion Graphics, Cybersecurity
(9, 1, 3, 1), (10, 1, 3, 9), (11, 1, 3, 16), (12, 1, 3, 26), -- Intake: Round 2023/2024, Branch: Assiut, Tracks: Power BI, Software Testing, 2D Graphics, BI & Automation
(13, 1, 4, 4), (14, 1, 4, 13), (15, 1, 4, 17), (16, 1, 4, 21), -- Intake: Round 2023/2024, Branch: El Mansoura, Tracks: Python/DevOps, Python Full Stack, 3D Modeling, SysAdmin
(17, 1, 5, 2), (18, 1, 5, 8), (19, 1, 5, 14), (20, 1, 5, 23), -- Intake: Round 2023/2024, Branch: Ismailia, Tracks: Industrial Automation, SW Fundamentals, CMS Dev, Data Viz
(21, 1, 6, 6), (22, 1, 6, 10), (23, 1, 6, 19), (24, 1, 6, 24), -- Intake: Round 2023/2024, Branch: El Menoufia, Tracks: Front-End, Renewable Energy, Concept Art, Salesforce
(25, 1, 7, 3), (26, 1, 7, 15), (27, 1, 7, 27), (28, 1, 7, 1), -- Intake: Round 2023/2024, Branch: El Minia, Tracks: AWS, PHP Full Stack, Social Media, Power BI
(29, 1, 8, 5), (30, 1, 8, 11), (31, 1, 8, 20), (32, 1, 8, 25), -- Intake: Round 2023/2024, Branch: Sohag, Tracks: Data Engineering, .Net, UI/UX Design, Business Analysis
(33, 1, 9, 8), (34, 1, 9, 13), (35, 1, 9, 18), (36, 1, 9, 22), -- Intake: Round 2023/2024, Branch: Qena, Tracks: SW Fundamentals, Python Full Stack, Motion Graphics, Cybersecurity
(37, 1, 10, 2), (38, 1, 10, 7), (39, 1, 10, 16), (40, 1, 10, 24), -- Intake: Round 2023/2024, Branch: Aswan, Tracks: Industrial Automation, iOS Dev, 2D Graphics, Salesforce
(41, 1, 11, 4), (42, 1, 11, 9), (43, 1, 11, 14), (44, 1, 11, 23), -- Intake: Round 2023/2024, Branch: New Capital, Tracks: Python/DevOps, Software Testing, CMS Dev, Data Viz
(45, 1, 12, 6), (46, 1, 12, 12), (47, 1, 12, 17), (48, 1, 12, 21), -- Intake: Round 2023/2024, Branch: Cairo University, Tracks: Front-End, MERN, 3D Modeling, SysAdmin
(49, 1, 13, 3), (50, 1, 13, 10), (51, 1, 13, 19), (52, 1, 13, 26), -- Intake: Round 2023/2024, Branch: New Valley, Tracks: AWS, Renewable Energy, Concept Art, BI & Automation
(53, 1, 14, 1), (54, 1, 14, 15), (55, 1, 14, 20), (56, 1, 14, 27), -- Intake: Round 2023/2024, Branch: Beni Sweif, Tracks: Power BI, PHP Full Stack, UI/UX Design, Social Media

-- Intake 2: Round 1 2023 (Intensive Code Camp), Start Date: 2023-02-01 (Branches 1-12 Open)
----------------------------------------------------------------------------------------------------
(57, 2, 1, 1), (58, 2, 1, 8), (59, 2, 1, 16), (60, 2, 1, 21), -- Intake: Round 1 2023, Branch: Smart Village, Tracks: Power BI, SW Fundamentals, 2D Graphics, SysAdmin
(61, 2, 2, 4), (62, 2, 2, 9), (63, 2, 2, 13), (64, 2, 2, 26), -- Intake: Round 1 2023, Branch: Alexandria, Tracks: Python/DevOps, Software Testing, Python Full Stack, BI & Automation
(65, 2, 3, 2), (66, 2, 3, 7), (67, 2, 3, 17), (68, 2, 3, 22), -- Intake: Round 1 2023, Branch: Assiut, Tracks: Industrial Automation, iOS Dev, 3D Modeling, Cybersecurity
(69, 2, 4, 5), (70, 2, 4, 11), (71, 2, 4, 19), (72, 2, 4, 24), -- Intake: Round 1 2023, Branch: El Mansoura, Tracks: Data Engineering, .Net, Concept Art, Salesforce
(73, 2, 5, 3), (74, 2, 5, 12), (75, 2, 5, 20), (76, 2, 5, 25), -- Intake: Round 1 2023, Branch: Ismailia, Tracks: AWS, MERN, UI/UX Design, Business Analysis
(77, 2, 6, 6), (78, 2, 6, 14), (79, 2, 6, 18), (80, 2, 6, 23), -- Intake: Round 1 2023, Branch: El Menoufia, Tracks: Front-End, CMS Dev, Motion Graphics, Data Viz
(81, 2, 7, 10), (82, 2, 7, 15), (83, 2, 7, 27), (84, 2, 7, 1), -- Intake: Round 1 2023, Branch: El Minia, Tracks: Renewable Energy, PHP Full Stack, Social Media, Power BI
(85, 2, 8, 2), (86, 2, 8, 8), (87, 2, 8, 16), (88, 2, 8, 21), -- Intake: Round 1 2023, Branch: Sohag, Tracks: Industrial Automation, SW Fundamentals, 2D Graphics, SysAdmin
(89, 2, 9, 4), (90, 2, 9, 9), (91, 2, 9, 13), (92, 2, 9, 26), -- Intake: Round 1 2023, Branch: Qena, Tracks: Python/DevOps, Software Testing, Python Full Stack, BI & Automation
(93, 2, 10, 5), (94, 2, 10, 11), (95, 2, 10, 19), (96, 2, 10, 24), -- Intake: Round 1 2023, Branch: Aswan, Tracks: Data Engineering, .Net, Concept Art, Salesforce
(97, 2, 11, 7), (98, 2, 11, 12), (99, 2, 11, 20), (100, 2, 11, 25), -- Intake: Round 1 2023, Branch: New Capital, Tracks: iOS Dev, MERN, UI/UX Design, Business Analysis
(101, 2, 12, 3), (102, 2, 12, 10), (103, 2, 12, 18), (104, 2, 12, 23), -- Intake: Round 1 2023, Branch: Cairo University, Tracks: AWS, Renewable Energy, Motion Graphics, Data Viz

-- Intake 3: Round 2 2023 (Intensive Code Camp), Start Date: 2023-07-01 (Branches 1-12 Open)
----------------------------------------------------------------------------------------------------
(105, 3, 1, 2), (106, 3, 1, 9), (107, 3, 1, 15), (108, 3, 1, 22), -- Intake: Round 2 2023, Branch: Smart Village, Tracks: Industrial Automation, SW Testing, PHP, Cybersecurity
(109, 3, 2, 6), (110, 3, 2, 11), (111, 3, 2, 18), (112, 3, 2, 27), -- Intake: Round 2 2023, Branch: Alexandria, Tracks: Front-End, .Net, Motion Graphics, Social Media
(113, 3, 3, 4), (114, 3, 3, 13), (115, 3, 3, 20), (116, 3, 3, 25), -- Intake: Round 2 2023, Branch: Assiut, Tracks: Python/DevOps, Python Full Stack, UI/UX, Business Analysis
(117, 3, 4, 1), (118, 3, 4, 7), (119, 3, 4, 14), (120, 3, 4, 21), -- Intake: Round 2 2023, Branch: El Mansoura, Tracks: Power BI, iOS Dev, CMS Dev, SysAdmin
(121, 3, 5, 5), (122, 3, 5, 10), (123, 3, 5, 17), (124, 3, 5, 26), -- Intake: Round 2 2023, Branch: Ismailia, Tracks: Data Engineering, Renewable Energy, 3D Modeling, BI & Automation
(125, 3, 6, 3), (126, 3, 6, 8), (127, 3, 6, 16), (128, 3, 6, 23), -- Intake: Round 2 2023, Branch: El Menoufia, Tracks: AWS, SW Fundamentals, 2D Graphics, Data Viz
(129, 3, 7, 2), (130, 3, 7, 12), (131, 3, 7, 19), (132, 3, 7, 24), -- Intake: Round 2 2023, Branch: El Minia, Tracks: Industrial Automation, MERN, Concept Art, Salesforce
(133, 3, 8, 4), (134, 3, 8, 9), (135, 3, 8, 15), (136, 3, 8, 22), -- Intake: Round 2 2023, Branch: Sohag, Tracks: Python/DevOps, SW Testing, PHP, Cybersecurity
(137, 3, 9, 6), (138, 3, 9, 11), (139, 3, 9, 18), (140, 3, 9, 27), -- Intake: Round 2 2023, Branch: Qena, Tracks: Front-End, .Net, Motion Graphics, Social Media
(141, 3, 10, 1), (142, 3, 10, 7), (143, 3, 10, 14), (144, 3, 10, 21), -- Intake: Round 2 2023, Branch: Aswan, Tracks: Power BI, iOS Dev, CMS Dev, SysAdmin
(145, 3, 11, 5), (146, 3, 11, 10), (147, 3, 11, 17), (148, 3, 11, 26), -- Intake: Round 2 2023, Branch: New Capital, Tracks: Data Engineering, Renewable Energy, 3D Modeling, BI & Automation
(149, 3, 12, 3), (150, 3, 12, 8), (151, 3, 12, 16), (152, 3, 12, 23), -- Intake: Round 2 2023, Branch: Cairo University, Tracks: AWS, SW Fundamentals, 2D Graphics, Data Viz

-- Intake 4: Round 3 2023 (Intensive Code Camp), Start Date: 2023-11-01 (Branches 1-14 Open)
----------------------------------------------------------------------------------------------------
(153, 4, 1, 3), (154, 4, 1, 10), (155, 4, 1, 17), (156, 4, 1, 24), -- Intake: Round 3 2023, Branch: Smart Village, Tracks: AWS, Renewable Energy, 3D Modeling, Salesforce
(157, 4, 2, 5), (158, 4, 2, 12), (159, 4, 2, 19), (160, 4, 2, 26), -- Intake: Round 3 2023, Branch: Alexandria, Tracks: Data Engineering, MERN, Concept Art, BI & Automation
(161, 4, 3, 1), (162, 4, 3, 8), (163, 4, 3, 16), (164, 4, 3, 23), -- Intake: Round 3 2023, Branch: Assiut, Tracks: Power BI, SW Fundamentals, 2D Graphics, Data Viz
(165, 4, 4, 2), (166, 4, 4, 9), (167, 4, 4, 15), (168, 4, 4, 22), -- Intake: Round 3 2023, Branch: El Mansoura, Tracks: Industrial Automation, SW Testing, PHP, Cybersecurity
(169, 4, 5, 4), (170, 4, 5, 11), (171, 4, 5, 18), (172, 4, 5, 25), -- Intake: Round 3 2023, Branch: Ismailia, Tracks: Python/DevOps, .Net, Motion Graphics, Business Analysis
(173, 4, 6, 6), (174, 4, 6, 13), (175, 4, 6, 20), (176, 4, 6, 27), -- Intake: Round 3 2023, Branch: El Menoufia, Tracks: Front-End, Python Full Stack, UI/UX, Social Media
(177, 4, 7, 7), (178, 4, 7, 14), (179, 4, 7, 21), (180, 4, 7, 1), -- Intake: Round 3 2023, Branch: El Minia, Tracks: iOS Dev, CMS Dev, SysAdmin, Power BI
(181, 4, 8, 3), (182, 4, 8, 10), (183, 4, 8, 17), (184, 4, 8, 24), -- Intake: Round 3 2023, Branch: Sohag, Tracks: AWS, Renewable Energy, 3D Modeling, Salesforce
(185, 4, 9, 5), (186, 4, 9, 12), (187, 4, 9, 19), (188, 4, 9, 26), -- Intake: Round 3 2023, Branch: Qena, Tracks: Data Engineering, MERN, Concept Art, BI & Automation
(189, 4, 10, 1), (190, 4, 10, 8), (191, 4, 10, 16), (192, 4, 10, 23), -- Intake: Round 3 2023, Branch: Aswan, Tracks: Power BI, SW Fundamentals, 2D Graphics, Data Viz
(193, 4, 11, 2), (194, 4, 11, 9), (195, 4, 11, 15), (196, 4, 11, 22), -- Intake: Round 3 2023, Branch: New Capital, Tracks: Industrial Automation, SW Testing, PHP, Cybersecurity
(197, 4, 12, 4), (198, 4, 12, 11), (199, 4, 12, 18), (200, 4, 12, 25), -- Intake: Round 3 2023, Branch: Cairo University, Tracks: Python/DevOps, .Net, Motion Graphics, Business Analysis
(201, 4, 13, 6), (202, 4, 13, 13), (203, 4, 13, 20), (204, 4, 13, 27), -- Intake: Round 3 2023, Branch: New Valley, Tracks: Front-End, Python Full Stack, UI/UX, Social Media
(205, 4, 14, 7), (206, 4, 14, 14), (207, 4, 14, 21), (208, 4, 14, 5), -- Intake: Round 3 2023, Branch: Beni Sweif, Tracks: iOS Dev, CMS Dev, SysAdmin, Data Engineering

-- =================================================================================================
-- YEAR 2024
-- =================================================================================================

-- Intake 5: Round 2024/2025 (9 Months), Start Date: 2024-10-01 (All 21 Branches Open)
----------------------------------------------------------------------------------------------------
(209, 5, 1, 1), (210, 5, 1, 11), (211, 5, 1, 21), (212, 5, 1, 27), -- Intake: Round 2024/2025, Branch: Smart Village, Tracks: Power BI, .Net, SysAdmin, Social Media
(213, 5, 2, 2), (214, 5, 2, 12), (215, 5, 2, 22), (216, 5, 2, 8), -- Intake: Round 2024/2025, Branch: Alexandria, Tracks: Industrial Automation, MERN, Cybersecurity, SW Fundamentals
(217, 5, 3, 3), (218, 5, 3, 13), (219, 5, 3, 23), (220, 5, 3, 9), -- Intake: Round 2024/2025, Branch: Assiut, Tracks: AWS, Python Full Stack, Data Viz, SW Testing
(221, 5, 4, 4), (222, 5, 4, 14), (223, 5, 4, 24), (224, 5, 4, 10), -- Intake: Round 2024/2025, Branch: El Mansoura, Tracks: Python/DevOps, CMS Dev, Salesforce, Renewable Energy
(225, 5, 5, 5), (226, 5, 5, 15), (227, 5, 5, 25), (228, 5, 5, 6), -- Intake: Round 2024/2025, Branch: Ismailia, Tracks: Data Engineering, PHP, Business Analysis, Front-End
(229, 5, 6, 7), (230, 5, 6, 16), (231, 5, 6, 26), (232, 5, 6, 1), -- Intake: Round 2024/2025, Branch: El Menoufia, Tracks: iOS Dev, 2D Graphics, BI & Automation, Power BI
(233, 5, 7, 8), (234, 5, 7, 17), (235, 5, 7, 20), (236, 5, 7, 2), -- Intake: Round 2024/2025, Branch: El Minia, Tracks: SW Fundamentals, 3D Modeling, UI/UX, Industrial Automation
(237, 5, 8, 9), (238, 5, 8, 18), (239, 5, 8, 1), (240, 5, 8, 3), -- Intake: Round 2024/2025, Branch: Sohag, Tracks: SW Testing, Motion Graphics, Power BI, AWS
(241, 5, 9, 10), (242, 5, 9, 19), (243, 5, 9, 2), (244, 5, 9, 4), -- Intake: Round 2024/2025, Branch: Qena, Tracks: Renewable Energy, Concept Art, Industrial Automation, Python/DevOps
(245, 5, 10, 11), (246, 5, 10, 20), (247, 5, 10, 3), (248, 5, 10, 5), -- Intake: Round 2024/2025, Branch: Aswan, Tracks: .Net, UI/UX, AWS, Data Engineering
(249, 5, 11, 12), (250, 5, 11, 21), (251, 5, 11, 4), (252, 5, 11, 6), -- Intake: Round 2024/2025, Branch: New Capital, Tracks: MERN, SysAdmin, Python/DevOps, Front-End
(253, 5, 12, 13), (254, 5, 12, 22), (255, 5, 12, 5), (256, 5, 12, 7), -- Intake: Round 2024/2025, Branch: Cairo University, Tracks: Python Full Stack, Cybersecurity, Data Engineering, iOS Dev
(257, 5, 13, 14), (258, 5, 13, 23), (259, 5, 13, 6), (260, 5, 13, 8), -- Intake: Round 2024/2025, Branch: New Valley, Tracks: CMS Dev, Data Viz, Front-End, SW Fundamentals
(261, 5, 14, 15), (262, 5, 14, 24), (263, 5, 14, 7), (264, 5, 14, 9), -- Intake: Round 2024/2025, Branch: Beni Sweif, Tracks: PHP, Salesforce, iOS Dev, SW Testing
(265, 5, 15, 16), (266, 5, 15, 25), (267, 5, 15, 8), (268, 5, 15, 10), -- Intake: Round 2024/2025, Branch: Benha, Tracks: 2D Graphics, Business Analysis, SW Fundamentals, Renewable Energy
(269, 5, 16, 17), (270, 5, 16, 26), (271, 5, 16, 9), (272, 5, 16, 11), -- Intake: Round 2024/2025, Branch: El Fayoum, Tracks: 3D Modeling, BI & Automation, SW Testing, .Net
(273, 5, 17, 18), (274, 5, 17, 27), (275, 5, 17, 10), (276, 5, 17, 12), -- Intake: Round 2024/2025, Branch: Port Said, Tracks: Motion Graphics, Social Media, Renewable Energy, MERN
(277, 5, 18, 19), (278, 5, 18, 1), (279, 5, 18, 11), (280, 5, 18, 13), -- Intake: Round 2024/2025, Branch: Al Arish, Tracks: Concept Art, Power BI, .Net, Python Full Stack
(281, 5, 19, 20), (282, 5, 19, 2), (283, 5, 19, 12), (284, 5, 19, 14), -- Intake: Round 2024/2025, Branch: Zagazig, Tracks: UI/UX, Industrial Automation, MERN, CMS Dev
(285, 5, 20, 21), (286, 5, 20, 3), (287, 5, 20, 13), (288, 5, 20, 15), -- Intake: Round 2024/2025, Branch: Damanhour, Tracks: SysAdmin, AWS, Python Full Stack, PHP
(289, 5, 21, 22), (290, 5, 21, 4), (291, 5, 21, 14), (292, 5, 21, 16), -- Intake: Round 2024/2025, Branch: Tanta, Tracks: Cybersecurity, Python/DevOps, CMS Dev, 2D Graphics

-- Intake 6: Round 1 2024 (Intensive Code Camp), Start Date: 2024-02-01 (Branches 1-14 Open)
----------------------------------------------------------------------------------------------------
(293, 6, 1, 3), (294, 6, 1, 9), (295, 6, 1, 15), (296, 6, 1, 24), -- Intake: Round 1 2024, Branch: Smart Village, Tracks: AWS, SW Testing, PHP, Salesforce
(297, 6, 2, 4), (298, 6, 2, 10), (299, 6, 2, 16), (300, 6, 2, 25), -- Intake: Round 1 2024, Branch: Alexandria, Tracks: Python/DevOps, Renewable Energy, 2D Graphics, Business Analysis
(301, 6, 3, 5), (302, 6, 3, 11), (303, 6, 3, 17), (304, 6, 3, 26), -- Intake: Round 1 2024, Branch: Assiut, Tracks: Data Engineering, .Net, 3D Modeling, BI & Automation
(305, 6, 4, 6), (306, 6, 4, 12), (307, 6, 4, 18), (308, 6, 4, 27), -- Intake: Round 1 2024, Branch: El Mansoura, Tracks: Front-End, MERN, Motion Graphics, Social Media
(309, 6, 5, 7), (310, 6, 5, 13), (311, 6, 5, 19), (312, 6, 5, 1), -- Intake: Round 1 2024, Branch: Ismailia, Tracks: iOS Dev, Python Full Stack, Concept Art, Power BI
(313, 6, 6, 8), (314, 6, 6, 14), (315, 6, 6, 20), (316, 6, 6, 2), -- Intake: Round 1 2024, Branch: El Menoufia, Tracks: SW Fundamentals, CMS Dev, UI/UX, Industrial Automation
(317, 6, 7, 9), (318, 6, 7, 15), (319, 6, 7, 21), (320, 6, 7, 3), -- Intake: Round 1 2024, Branch: El Minia, Tracks: SW Testing, PHP, SysAdmin, AWS
(321, 6, 8, 10), (322, 6, 8, 16), (323, 6, 8, 22), (324, 6, 8, 4), -- Intake: Round 1 2024, Branch: Sohag, Tracks: Renewable Energy, 2D Graphics, Cybersecurity, Python/DevOps
(325, 6, 9, 11), (326, 6, 9, 17), (327, 6, 9, 23), (328, 6, 9, 5), -- Intake: Round 1 2024, Branch: Qena, Tracks: .Net, 3D Modeling, Data Viz, Data Engineering
(329, 6, 10, 12), (330, 6, 10, 18), (331, 6, 10, 24), (332, 6, 10, 6), -- Intake: Round 1 2024, Branch: Aswan, Tracks: MERN, Motion Graphics, Salesforce, Front-End
(333, 6, 11, 13), (334, 6, 11, 19), (335, 6, 11, 25), (336, 6, 11, 7), -- Intake: Round 1 2024, Branch: New Capital, Tracks: Python Full Stack, Concept Art, Business Analysis, iOS Dev
(337, 6, 12, 14), (338, 6, 12, 20), (339, 6, 12, 26), (340, 6, 12, 8), -- Intake: Round 1 2024, Branch: Cairo University, Tracks: CMS Dev, UI/UX, BI & Automation, SW Fundamentals
(341, 6, 13, 15), (342, 6, 13, 21), (343, 6, 13, 27), (344, 6, 13, 9), -- Intake: Round 1 2024, Branch: New Valley, Tracks: PHP, SysAdmin, Social Media, SW Testing
(345, 6, 14, 16), (346, 6, 14, 22), (347, 6, 14, 1), (348, 6, 14, 10), -- Intake: Round 1 2024, Branch: Beni Sweif, Tracks: 2D Graphics, Cybersecurity, Power BI, Renewable Energy

-- Intake 7: Round 2 2024 (Intensive Code Camp), Start Date: 2024-07-01 (All 21 Branches Open)
----------------------------------------------------------------------------------------------------
(349, 7, 1, 18), (350, 7, 1, 2), (351, 7, 1, 10), (352, 7, 1, 25), -- Intake: Round 2 2024, Branch: Smart Village, Tracks: Motion Graphics, Automation, Energy, Business Analysis
(353, 7, 2, 19), (354, 7, 2, 3), (355, 7, 2, 11), (356, 7, 2, 26), -- Intake: Round 2 2024, Branch: Alexandria, Tracks: Concept Art, AWS, .Net, BI & Automation
(357, 7, 3, 20), (358, 7, 3, 4), (359, 7, 3, 12), (360, 7, 3, 27), -- Intake: Round 2 2024, Branch: Assiut, Tracks: UI/UX, Python/DevOps, MERN, Social Media
(361, 7, 4, 21), (362, 7, 4, 5), (363, 7, 4, 13), (364, 7, 4, 22), -- Intake: Round 2 2024, Branch: El Mansoura, Tracks: SysAdmin, Data Engineering, Python Full Stack, Cybersecurity
(365, 7, 5, 23), (366, 7, 5, 6), (367, 7, 5, 14), (368, 7, 5, 1), -- Intake: Round 2 2024, Branch: Ismailia, Tracks: Data Viz, Front-End, CMS Dev, Power BI
(369, 7, 6, 24), (370, 7, 6, 7), (371, 7, 6, 15), (372, 7, 6, 2), -- Intake: Round 2 2024, Branch: El Menoufia, Tracks: Salesforce, iOS Dev, PHP, Industrial Automation
(373, 7, 7, 25), (374, 7, 7, 8), (375, 7, 7, 16), (376, 7, 7, 3), -- Intake: Round 2 2024, Branch: El Minia, Tracks: Business Analysis, SW Fundamentals, 2D Graphics, AWS
(377, 7, 8, 26), (378, 7, 8, 9), (379, 7, 8, 17), (380, 7, 8, 4), -- Intake: Round 2 2024, Branch: Sohag, Tracks: BI & Automation, SW Testing, 3D Modeling, Python/DevOps
(381, 7, 9, 27), (382, 7, 9, 10), (383, 7, 9, 18), (384, 7, 9, 5), -- Intake: Round 2 2024, Branch: Qena, Tracks: Social Media, Renewable Energy, Motion Graphics, Data Engineering
(385, 7, 10, 1), (386, 7, 10, 11), (387, 7, 10, 19), (388, 7, 10, 6), -- Intake: Round 2 2024, Branch: Aswan, Tracks: Power BI, .Net, Concept Art, Front-End
(389, 7, 11, 2), (390, 7, 11, 12), (391, 7, 11, 20), (392, 7, 11, 7), -- Intake: Round 2 2024, Branch: New Capital, Tracks: Industrial Automation, MERN, UI/UX, iOS Dev
(393, 7, 12, 3), (394, 7, 12, 13), (395, 7, 12, 21), (396, 7, 12, 8), -- Intake: Round 2 2024, Branch: Cairo University, Tracks: AWS, Python Full Stack, SysAdmin, SW Fundamentals
(397, 7, 13, 4), (398, 7, 13, 14), (399, 7, 13, 22), (400, 7, 13, 9), -- Intake: Round 2 2024, Branch: New Valley, Tracks: Python/DevOps, CMS Dev, Cybersecurity, SW Testing
(401, 7, 14, 5), (402, 7, 14, 15), (403, 7, 14, 23), (404, 7, 14, 10), -- Intake: Round 2 2024, Branch: Beni Sweif, Tracks: Data Engineering, PHP, Data Viz, Renewable Energy
(405, 7, 15, 6), (406, 7, 15, 16), (407, 7, 15, 24), (408, 7, 15, 11), -- Intake: Round 2 2024, Branch: Benha, Tracks: Front-End, 2D Graphics, Salesforce, .Net
(409, 7, 16, 7), (410, 7, 16, 17), (411, 7, 16, 25), (412, 7, 16, 12), -- Intake: Round 2 2024, Branch: El Fayoum, Tracks: iOS Dev, 3D Modeling, Business Analysis, MERN
(413, 7, 17, 8), (414, 7, 17, 18), (415, 7, 17, 26), (416, 7, 17, 13), -- Intake: Round 2 2024, Branch: Port Said, Tracks: SW Fundamentals, Motion Graphics, BI & Automation, Python Full Stack
(417, 7, 18, 9), (418, 7, 18, 19), (419, 7, 18, 27), (420, 7, 18, 14), -- Intake: Round 2 2024, Branch: Al Arish, Tracks: SW Testing, Concept Art, Social Media, CMS Dev
(421, 7, 19, 10), (422, 7, 19, 20), (423, 7, 19, 1), (424, 7, 19, 15), -- Intake: Round 2 2024, Branch: Zagazig, Tracks: Renewable Energy, UI/UX, Power BI, PHP
(425, 7, 20, 11), (426, 7, 20, 21), (427, 7, 20, 2), (428, 7, 20, 16), -- Intake: Round 2 2024, Branch: Damanhour, Tracks: .Net, SysAdmin, Industrial Automation, 2D Graphics
(429, 7, 21, 12), (430, 7, 21, 22), (431, 7, 21, 3), (432, 7, 21, 17), -- Intake: Round 2 2024, Branch: Tanta, Tracks: MERN, Cybersecurity, AWS, 3D Modeling

-- Intake 8: Round 3 2024 (Intensive Code Camp), Start Date: 2024-11-01 (All 21 Branches Open)
----------------------------------------------------------------------------------------------------
(433, 8, 1, 20), (434, 8, 1, 4), (435, 8, 1, 12), (436, 8, 1, 27), -- Intake: Round 3 2024, Branch: Smart Village, Tracks: UI/UX, Python/DevOps, MERN, Social Media
(437, 8, 2, 21), (438, 8, 2, 5), (439, 8, 2, 13), (440, 8, 2, 24), -- Intake: Round 3 2024, Branch: Alexandria, Tracks: SysAdmin, Data Engineering, Python Full Stack, Salesforce
(441, 8, 3, 23), (442, 8, 3, 6), (443, 8, 3, 14), (444, 8, 3, 1), -- Intake: Round 3 2024, Branch: Assiut, Tracks: Data Viz, Front-End, CMS Dev, Power BI
(445, 8, 4, 18), (446, 8, 4, 2), (447, 8, 4, 10), (448, 8, 4, 25), -- Intake: Round 3 2024, Branch: El Mansoura, Tracks: Motion Graphics, Automation, Energy, Business Analysis
(449, 8, 5, 19), (450, 8, 5, 3), (451, 8, 5, 11), (452, 8, 5, 26), -- Intake: Round 3 2024, Branch: Ismailia, Tracks: Concept Art, AWS, .Net, BI & Automation
(453, 8, 6, 22), (454, 8, 6, 7), (455, 8, 6, 15), (456, 8, 6, 2), -- Intake: Round 3 2024, Branch: El Menoufia, Tracks: Cybersecurity, iOS Dev, PHP, Industrial Automation
(457, 8, 7, 24), (458, 8, 7, 8), (459, 8, 7, 16), (460, 8, 7, 3), -- Intake: Round 3 2024, Branch: El Minia, Tracks: Salesforce, SW Fundamentals, 2D Graphics, AWS
(461, 8, 8, 26), (462, 8, 8, 9), (463, 8, 8, 17), (464, 8, 8, 4), -- Intake: Round 3 2024, Branch: Sohag, Tracks: BI & Automation, SW Testing, 3D Modeling, Python/DevOps
(465, 8, 9, 27), (466, 8, 9, 10), (467, 8, 9, 18), (468, 8, 9, 5), -- Intake: Round 3 2024, Branch: Qena, Tracks: Social Media, Renewable Energy, Motion Graphics, Data Engineering
(469, 8, 10, 1), (470, 8, 10, 11), (471, 8, 10, 19), (472, 8, 10, 6), -- Intake: Round 3 2024, Branch: Aswan, Tracks: Power BI, .Net, Concept Art, Front-End
(473, 8, 11, 2), (474, 8, 11, 12), (475, 8, 11, 20), (476, 8, 11, 7), -- Intake: Round 3 2024, Branch: New Capital, Tracks: Industrial Automation, MERN, UI/UX, iOS Dev
(477, 8, 12, 3), (478, 8, 12, 13), (479, 8, 12, 21), (480, 8, 12, 8), -- Intake: Round 3 2024, Branch: Cairo University, Tracks: AWS, Python Full Stack, SysAdmin, SW Fundamentals
(481, 8, 13, 4), (482, 8, 13, 14), (483, 8, 13, 22), (484, 8, 13, 9), -- Intake: Round 3 2024, Branch: New Valley, Tracks: Python/DevOps, CMS Dev, Cybersecurity, SW Testing
(485, 8, 14, 5), (486, 8, 14, 15), (487, 8, 14, 23), (488, 8, 14, 10), -- Intake: Round 3 2024, Branch: Beni Sweif, Tracks: Data Engineering, PHP, Data Viz, Renewable Energy
(489, 8, 15, 6), (490, 8, 15, 16), (491, 8, 15, 24), (492, 8, 15, 11), -- Intake: Round 3 2024, Branch: Benha, Tracks: Front-End, 2D Graphics, Salesforce, .Net
(493, 8, 16, 7), (494, 8, 16, 17), (495, 8, 16, 25), (496, 8, 16, 12), -- Intake: Round 3 2024, Branch: El Fayoum, Tracks: iOS Dev, 3D Modeling, Business Analysis, MERN
(497, 8, 17, 8), (498, 8, 17, 18), (499, 8, 17, 26), (500, 8, 17, 13), -- Intake: Round 3 2024, Branch: Port Said, Tracks: SW Fundamentals, Motion Graphics, BI & Automation, Python Full Stack
(501, 8, 18, 9), (502, 8, 18, 19), (503, 8, 18, 27), (504, 8, 18, 14), -- Intake: Round 3 2024, Branch: Al Arish, Tracks: SW Testing, Concept Art, Social Media, CMS Dev
(505, 8, 19, 10), (506, 8, 19, 20), (507, 8, 19, 1), (508, 8, 19, 15), -- Intake: Round 3 2024, Branch: Zagazig, Tracks: Renewable Energy, UI/UX, Power BI, PHP
(509, 8, 20, 11), (510, 8, 20, 21), (511, 8, 20, 2), (512, 8, 20, 16), -- Intake: Round 3 2024, Branch: Damanhour, Tracks: .Net, SysAdmin, Industrial Automation, 2D Graphics
(513, 8, 21, 12), (514, 8, 21, 22), (515, 8, 21, 3), (516, 8, 21, 17); -- Intake: Round 3 2024, Branch: Tanta, Tracks: MERN, Cybersecurity, AWS, 3D Modeling



-- ================ ================ ================ ================ ================ ================ ================ ================
-- Courses Of Each TRACK Data
-- ================ ================ ================ ================ ================ ================ ================ ================
INSERT INTO Course (Course_ID, Course_Name)
VALUES
-- Track 1: Power BI Development
(1, N'Intro to Data Analytics & Power BI'), (2, N'Data Modeling & Power Query'), (3, N'DAX Fundamentals'), (4, N'Data Visualization & Design'), (5, N'Power BI Service & Admin'), (6, N'SQL for Analysts'), (7, N'Power BI Capstone Project'),
-- Track 2: Industrial Automation
(8, N'Intro to PLC & Ladder Logic'), (9, N'SCADA & HMI Design'), (10, N'Industrial Robotics'), (11, N'Control Systems & Instrumentation'), (12, N'Industrial Networks & IIoT'), (13, N'Functional Safety'), (14, N'Automation Capstone Project'),
-- Track 3: AWS Re /Start
(15, N'Cloud Intro & AWS Core Services'), (16, N'Linux & Python Scripting'), (17, N'AWS IAM & Security'), (18, N'AWS Databases & Networking'), (19, N'Infrastructure as Code (CloudFormation)'), (20, N'Serverless & CI/CD on AWS'), (21, N'AWS Capstone Project'),
-- Track 4: Python and DevOps Development
(22, N'Python & OOP Fundamentals'), (23, N'Git & DevOps Principles'), (24, N'CI/CD with Jenkins'), (25, N'Docker & Kubernetes'), (26, N'Ansible & Terraform'), (27, N'Microservices & Automated Testing'), (28, N'DevOps Pipeline Capstone Project'),
-- Track 5: Data Engineering
(29, N'Data Engineering Intro with Python'), (30, N'Advanced SQL & Data Warehousing'), (31, N'ETL, Hadoop & Spark'), (32, N'Cloud Data Platforms & Data Lakes'), (33, N'Real-time Streaming with Kafka'), (34, N'Workflow Orchestration with Airflow'), (35, N'Data Engineering Capstone Project'),
-- Track 6: Front-End and Cross Platform Mobile Development
(36, N'HTML, CSS & Advanced JavaScript'), (37, N'React.js Fundamentals'), (38, N'React Native Development'), (39, N'Flutter & Dart Development'), (40, N'Working with APIs & State Management'), (41, N'UI/UX for Mobile'), (42, N'Cross-Platform App Capstone'),
-- Track 7: iOS Mobile Application Development
(43, N'Swift Programming Fundamentals'), (44, N'iOS Development with UIKit & SwiftUI'), (45, N'Navigation & Layout'), (46, N'APIs & Core Data'), (47, N'iOS Design Patterns & Concurrency'), (48, N'Testing & Publishing to App Store'), (49, N'Native iOS App Capstone'),
-- Track 8: Software Development Fundamentals
(50, N'Programming Logic & Algorithms'), (51, N'C# & OOP Principles'), (52, N'Data Structures'), (53, N'Intro to Databases & SQL'), (54, N'Web Dev Essentials (HTML/CSS/JS)'), (55, N'Git & SDLC'), (56, N'Fundamentals Capstone Project'),
-- Track 9: Software Testing
(57, N'Software Testing Fundamentals & STLC'), (58, N'Manual Testing Techniques'), (59, N'Test Automation with Selenium'), (60, N'API Testing with Postman'), (61, N'Performance Testing with JMeter'), (62, N'Agile Testing & Defect Tracking'), (63, N'Automated Testing Capstone'),
-- Track 10: Renewable Energy
(64, N'Intro to Renewable Energy Sources'), (65, N'Solar PV & Wind Energy Tech'), (66, N'Energy Storage Systems'), (67, N'Smart Grids & Grid Integration'), (68, N'Renewable Energy Policy & Economics'), (69, N'Project Management for Energy'), (70, N'Renewable Energy Capstone Project'),
-- Track 11: Full Stack Web Development Using .Net
(71, N'C# & ASP.NET Core MVC'), (72, N'Entity Framework Core & SQL Server'), (73, N'Building RESTful APIs with .NET'), (74, N'Client-Side with Angular/TypeScript'), (75, N'Azure Deployment & DevOps'), (76, N'Microservices Architecture'), (77, N'.NET Full Stack Capstone'),
-- Track 12: Full Stack Web Development Using MERN
(78, N'Node.js, Express & MongoDB'), (79, N'Building RESTful APIs'), (80, N'React.js & Redux'), (81, N'Authentication with JWT'), (82, N'Consuming APIs in React'), (83, N'Testing & Deployment'), (84, N'MERN Stack Capstone'),
-- Track 13: Full Stack Web Development using Python
(85, N'Python & Django Fundamentals'), (86, N'Django REST Framework for APIs'), (87, N'Database Management with PostgreSQL'), (88, N'Front-End with React.js'), (89, N'Containerization with Docker'), (90, N'Testing & Deployment'), (91, N'Python Full Stack Capstone'),
-- Track 14: Web Development Using CMS
(92, N'WordPress Theme & Plugin Dev'), (93, N'E-commerce with WooCommerce'), (94, N'PHP for WordPress'), (95, N'Headless CMS (Strapi/Contentful)'), (96, N'JAMstack with Gatsby/Next.js'), (97, N'SEO & Performance Optimization'), (98, N'Custom CMS Capstone Project'),
-- Track 15: Full Stack Web Development using PHP
(99, N'OOP PHP & MySQL'), (100, N'Laravel Fundamentals'), (101, N'Building APIs with Laravel'), (102, N'Front-End with Vue.js'), (103, N'Authentication in Laravel'), (104, N'Testing & Deployment'), (105, N'PHP Full Stack Capstone'),
-- Track 16: 2D Graphics Design
(106, N'Design, Color Theory & Typography'), (107, N'Adobe Photoshop'), (108, N'Adobe Illustrator & Vector Art'), (109, N'Logo Design & Branding'), (110, N'Layout Design with InDesign'), (111, N'UI Design Fundamentals'), (112, N'Branding Capstone Project'),
-- Track 17: 3D Modeling
(113, N'3D Modeling with Maya'), (114, N'Character & Hard Surface Modeling'), (115, N'UV Unwrapping & Texturing'), (116, N'3D Sculpting with ZBrush'), (117, N'Lighting & Rendering'), (118, N'3D for Games & Optimization'), (119, N'3D Scene Capstone'),
-- Track 18: Motion Graphics
(120, N'Animation Principles'), (121, N'Adobe After Effects Fundamentals'), (122, N'Keyframe & Typography Animation'), (123, N'Visual Effects & Compositing'), (124, N'3D Integration with Cinema 4D'), (125, N'Sound Design'), (126, N'Motion Graphics Capstone'),
-- Track 19: Concept Art
(127, N'Drawing, Perspective & Composition'), (128, N'Digital Painting with Photoshop'), (129, N'Character & Creature Design'), (130, N'Environment Design'), (131, N'Prop & Vehicle Design'), (132, N'World Building & Storytelling'), (133, N'Concept Art Portfolio Capstone'),
-- Track 20: UI/UX Design
(134, N'UI/UX Intro & User Research'), (135, N'Information Architecture & User Flows'), (136, N'Wireframing & Prototyping with Figma'), (137, N'Visual Design & Design Systems'), (138, N'Usability Testing'), (139, N'Accessibility in Design'), (140, N'UI/UX Capstone Project'),
-- Track 21: Systems Administration
(141, N'Linux/Unix & Windows Server Admin'), (142, N'Networking & Active Directory'), (143, N'Scripting (Bash/PowerShell)'), (144, N'Virtualization & Cloud Concepts'), (145, N'System Security & Hardening'), (146, N'Backup & Disaster Recovery'), (147, N'SysAdmin Capstone Project'),
-- Track 22: Cybersecurity Associate
(148, N'Cybersecurity & Networking Intro'), (149, N'Threats, Attacks & Vulnerabilities'), (150, N'Ethical Hacking & Pen Testing'), (151, N'SIEM & Network Security'), (152, N'Digital Forensics & Incident Response'), (153, N'GRC & Application Security'), (154, N'Cybersecurity Capstone'),
-- Track 23: Data Visualization
(155, N'Data Visualization & Storytelling'), (156, N'Tableau for Data Viz'), (157, N'Power BI for Data Viz'), (158, N'SQL for Data Analysts'), (159, N'Interactive Viz with D3.js'), (160, N'UI/UX for Dashboards'), (161, N'Data Viz Capstone Project'),
-- Track 24: Salesforce Specialist
(162, N'Salesforce Admin & CRM Intro'), (163, N'Sales & Service Cloud'), (164, N'Data Modeling & Security'), (165, N'Process Automation with Flow'), (166, N'Reports & Dashboards'), (167, N'Apex & Lightning Web Components Intro'), (168, N'Salesforce Capstone Project'),
-- Track 25: Business Analysis
(169, N'Business Analysis Fundamentals (BABOK)'), (170, N'Stakeholder & Requirements Management'), (171, N'Process & Data Modeling'), (172, N'Agile Business Analysis'), (173, N'Writing User Stories'), (174, N'Solution Evaluation'), (175, N'Business Analysis Capstone'),
-- Track 26: Business Analysis and Intelligent Automation Development
(176, N'Business Analysis & RPA Intro'), (177, N'Process Discovery for Automation'), (178, N'UiPath Studio Fundamentals'), (179, N'Building & Managing Automations'), (180, N'Intelligent Document Processing'), (181, N'AI & Chatbots in Automation'), (182, N'Intelligent Automation Capstone'),
-- Track 27: Social Media Marketing
(183, N'Social Media Strategy & Content'), (184, N'Community Management'), (185, N'Facebook, Instagram & LinkedIn Ads'), (186, N'Video Marketing (YouTube/TikTok)'), (187, N'Analytics & Reporting'), (188, N'SEO & Email Marketing Basics'), (189, N'Social Media Campaign Capstone');

--Insert the new 'Soft Skills' courses
INSERT INTO Course (Course_ID, Course_Name)
VALUES
(190, N'Communication Skills'),
(191, N'Presentation Skills'),
(192, N'Ethics'),
(193, N'CV Writing'),
(194, N'Freelancing');

INSERT INTO Track_Course (Track_ID, Course_ID)
VALUES
-- Track 1: Power BI Development
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7),
-- Track 2: Industrial Automation
(2, 8), (2, 9), (2, 10), (2, 11), (2, 12), (2, 13), (2, 14),
-- Track 3: AWS Re /Start
(3, 15), (3, 16), (3, 17), (3, 18), (3, 19), (3, 20), (3, 21),
-- Track 4: Python and DevOps Development
(4, 22), (4, 23), (4, 24), (4, 25), (4, 26), (4, 27), (4, 28),
-- Track 5: Data Engineering
(5, 29), (5, 30), (5, 31), (5, 32), (5, 33), (5, 34), (5, 35),
-- Track 6: Front-End and Cross Platform Mobile Development
(6, 36), (6, 37), (6, 38), (6, 39), (6, 40), (6, 41), (6, 42),
-- Track 7: iOS Mobile Application Development
(7, 43), (7, 44), (7, 45), (7, 46), (7, 47), (7, 48), (7, 49),
-- Track 8: Software Development Fundamentals
(8, 50), (8, 51), (8, 52), (8, 53), (8, 54), (8, 55), (8, 56),
-- Track 9: Software Testing
(9, 57), (9, 58), (9, 59), (9, 60), (9, 61), (9, 62), (9, 63),
-- Track 10: Renewable Energy
(10, 64), (10, 65), (10, 66), (10, 67), (10, 68), (10, 69), (10, 70),
-- Track 11: Full Stack Web Development Using .Net
(11, 71), (11, 72), (11, 73), (11, 74), (11, 75), (11, 76), (11, 77),
-- Track 12: Full Stack Web Development Using MERN
(12, 78), (12, 79), (12, 80), (12, 81), (12, 82), (12, 83), (12, 84),
-- Track 13: Full Stack Web Development using Python
(13, 85), (13, 86), (13, 87), (13, 88), (13, 89), (13, 90), (13, 91),
-- Track 14: Web Development Using CMS
(14, 92), (14, 93), (14, 94), (14, 95), (14, 96), (14, 97), (14, 98),
-- Track 15: Full Stack Web Development using PHP
(15, 99), (15, 100), (15, 101), (15, 102), (15, 103), (15, 104), (15, 105),
-- Track 16: 2D Graphics Design
(16, 106), (16, 107), (16, 108), (16, 109), (16, 110), (16, 111), (16, 112),
-- Track 17: 3D Modeling
(17, 113), (17, 114), (17, 115), (17, 116), (17, 117), (17, 118), (17, 119),
-- Track 18: Motion Graphics
(18, 120), (18, 121), (18, 122), (18, 123), (18, 124), (18, 125), (18, 126),
-- Track 19: Concept Art
(19, 127), (19, 128), (19, 129), (19, 130), (19, 131), (19, 132), (19, 133),
-- Track 20: UI/UX Design
(20, 134), (20, 135), (20, 136), (20, 137), (20, 138), (20, 139), (20, 140),
-- Track 21: Systems Administration
(21, 141), (21, 142), (21, 143), (21, 144), (21, 145), (21, 146), (21, 147),
-- Track 22: Cybersecurity Associate
(22, 148), (22, 149), (22, 150), (22, 151), (22, 152), (22, 153), (22, 154),
-- Track 23: Data Visualization
(23, 155), (23, 156), (23, 157), (23, 158), (23, 159), (23, 160), (23, 161),
-- Track 24: Salesforce Specialist
(24, 162), (24, 163), (24, 164), (24, 165), (24, 166), (24, 167), (24, 168),
-- Track 25: Business Analysis
(25, 169), (25, 170), (25, 171), (25, 172), (25, 173), (25, 174), (25, 175),
-- Track 26: Business Analysis and Intelligent Automation Development
(26, 176), (26, 177), (26, 178), (26, 179), (26, 180), (26, 181), (26, 182),
-- Track 27: Social Media Marketing
(27, 183), (27, 184), (27, 185), (27, 186), (27, 187), (27, 188), (27, 189);

-- 7. Add all 5 new 'Soft Skills' courses to ALL existing tracks (Tracks 1-27)
INSERT INTO Track_Course (Track_ID, Course_ID)
VALUES
-- Track 1: Power BI Development
(1, 190), (1, 191), (1, 192), (1, 193), (1, 194),
-- Track 2: Industrial Automation
(2, 190), (2, 191), (2, 192), (2, 193), (2, 194),
-- Track 3: AWS Re /Start
(3, 190), (3, 191), (3, 192), (3, 193), (3, 194),
-- Track 4: Python and DevOps Development
(4, 190), (4, 191), (4, 192), (4, 193), (4, 194),
-- Track 5: Data Engineering
(5, 190), (5, 191), (5, 192), (5, 193), (5, 194),
-- Track 6: Front-End and Cross Platform Mobile Development
(6, 190), (6, 191), (6, 192), (6, 193), (6, 194),
-- Track 7: iOS Mobile Application Development
(7, 190), (7, 191), (7, 192), (7, 193), (7, 194),
-- Track 8: Software Development Fundamentals
(8, 190), (8, 191), (8, 192), (8, 193), (8, 194),
-- Track 9: Software Testing
(9, 190), (9, 191), (9, 192), (9, 193), (9, 194),
-- Track 10: Renewable Energy
(10, 190), (10, 191), (10, 192), (10, 193), (10, 194),
-- Track 11: Full Stack Web Development Using .Net
(11, 190), (11, 191), (11, 192), (11, 193), (11, 194),
-- Track 12: Full Stack Web Development Using MERN
(12, 190), (12, 191), (12, 192), (12, 193), (12, 194),
-- Track 13: Full Stack Web Development using Python
(13, 190), (13, 191), (13, 192), (13, 193), (13, 194),
-- Track 14: Web Development Using CMS
(14, 190), (14, 191), (14, 192), (14, 193), (14, 194),
-- Track 15: Full Stack Web Development using PHP
(15, 190), (15, 191), (15, 192), (15, 193), (15, 194),
-- Track 16: 2D Graphics Design
(16, 190), (16, 191), (16, 192), (16, 193), (16, 194),
-- Track 17: 3D Modeling
(17, 190), (17, 191), (17, 192), (17, 193), (17, 194),
-- Track 18: Motion Graphics
(18, 190), (18, 191), (18, 192), (18, 193), (18, 194),
-- Track 19: Concept Art
(19, 190), (19, 191), (19, 192), (19, 193), (19, 194),
-- Track 20: UI/UX Design
(20, 190), (20, 191), (20, 192), (20, 193), (20, 194),
-- Track 21: Systems Administration
(21, 190), (21, 191), (21, 192), (21, 193), (21, 194),
-- Track 22: Cybersecurity Associate
(22, 190), (22, 191), (22, 192), (22, 193), (22, 194),
-- Track 23: Data Visualization
(23, 190), (23, 191), (23, 192), (23, 193), (23, 194),
-- Track 24: Salesforce Specialist
(24, 190), (24, 191), (24, 192), (24, 193), (24, 194),
-- Track 25: Business Analysis
(25, 190), (25, 191), (25, 192), (25, 193), (25, 194),
-- Track 26: Business Analysis and Intelligent Automation Development
(26, 190), (26, 191), (26, 192), (26, 193), (26, 194),
-- Track 27: Social Media Marketing
(27, 190), (27, 191), (27, 192), (27, 193), (27, 194);

-- ================ ================ ================ ================ ================ ================ ================ ================
-- Instructors of the Courses Data
-- ================ ================ ================ ================ ================ ================ ================ ================

INSERT INTO Instructor (Instructor_ID, Instructor_Fname, Instructor_Lname, Instructor_Gender, Instructor_Birthdate, Instructor_Marital_Status, Instructor_Salary, Instructor_Contract_Type, Instructor_Email, Department_ID)
VALUES
-- Department 1: System Development 
(7, N'Karim', N'Hassan', N'Male', '1990-05-15', N'Married', 16540, N'Full-Time', N'karim.hassan@iti.edu.eg', 1),
(8, N'Sara', N'Adel', N'Female', '1995-02-20', N'Single', 9800, N'Part-Time', N'sara.adel@iti.edu.eg', 1),
(9, N'Omar', N'Gamal', N'Male', '1988-11-30', N'Married', 21300, N'Full-Time', N'omar.gamal@iti.edu.eg', 1),
(10, N'Nada', N'Ismail', N'Female', '1993-07-12', N'Single', 10200, N'Part-Time', N'nada.ismail@iti.edu.eg', 1),
(11, N'Walid', N'Said', N'Male', '1985-01-25', N'Married', 24500, N'Full-Time', N'walid.said@iti.edu.eg', 1),
(12, N'Reem', N'Sherif', N'Female', '1996-09-08', N'Single', 9150, N'Part-Time', N'reem.sherif@iti.edu.eg', 1),
(13, N'Amr', N'Ezzat', N'Male', '1991-04-18', N'Single', 13400, N'Full-Time', N'amr.ezzat@iti.edu.eg', 1),
(14, N'Fatima', N'Kamal', N'Female', '1987-12-03', N'Married', 19800, N'Full-Time', N'fatima.kamal@iti.edu.eg', 1),
(15, N'Youssef', N'Mansour', N'Male', '1994-06-22', N'Single', 11500, N'Part-Time', N'youssef.mansour@iti.edu.eg', 1),
(16, N'Aya', N'Wael', N'Female', '1992-08-14', N'Single', 12300, N'Full-Time', N'aya.wael@iti.edu.eg', 1),
(17, N'Mohamed', N'Zaki', N'Male', '1986-03-05', N'Married', 22700, N'Full-Time', N'mohamed.zaki@iti.edu.eg', 1),
(18, N'Yasmin', N'Ibrahim', N'Female', '1997-10-28', N'Single', 8900, N'Part-Time', N'yasmin.ibrahim@iti.edu.eg', 1),
(19, N'Ali', N'Tamer', N'Male', '1989-07-19', N'Married', 18800, N'Full-Time', N'ali.tamer@iti.edu.eg', 1),
(20, N'Mariam', N'Ashraf', N'Female', '1990-12-01', N'Married', 17200, N'Full-Time', N'mariam.ashraf@iti.edu.eg', 1),
(21, N'Ziad', N'Ali', N'Male', '1995-05-09', N'Single', 10800, N'Part-Time', N'ziad.ali@iti.edu.eg', 1),
(22, N'Hassan', N'Adel', N'Male', '1993-02-11', N'Single', 14200, N'Full-Time', N'hassan.adel@iti.edu.eg', 1),
(23, N'Nour', N'Hassan', N'Female', '1988-08-23', N'Married', 20500, N'Full-Time', N'nour.hassan@iti.edu.eg', 1),
(24, N'Sameh', N'Gamal', N'Male', '1996-04-02', N'Single', 9600, N'Part-Time', N'sameh.gamal@iti.edu.eg', 1),
(25, N'Dina', N'Said', N'Female', '1991-10-17', N'Single', 11900, N'Part-Time', N'dina.said@iti.edu.eg', 1),
(26, N'Khaled', N'Mansour', N'Male', '1984-06-28', N'Married', 24800, N'Full-Time', N'khaled.mansour@iti.edu.eg', 1),
(27, N'Laila', N'Ismail', N'Female', '1992-03-30', N'Single', 13100, N'Full-Time', N'laila.ismail@iti.edu.eg', 1),
(28, N'Tarek', N'Sherif', N'Male', '1990-09-14', N'Single', 15600, N'Full-Time', N'tarek.sherif@iti.edu.eg', 1),
(29, N'Mona', N'Kamal', N'Female', '1987-05-25', N'Married', 18200, N'Full-Time', N'mona.kamal@iti.edu.eg', 1),
(30, N'Fares', N'Ezzat', N'Male', '1994-01-07', N'Single', 10400, N'Part-Time', N'fares.ezzat@iti.edu.eg', 1),
(31, N'Salma', N'Zaki', N'Female', '1993-11-18', N'Single', 9300, N'Part-Time', N'salma.zaki@iti.edu.eg', 1),
(32, N'Rami', N'Ibrahim', N'Male', '1986-08-02', N'Married', 23400, N'Full-Time', N'rami.ibrahim@iti.edu.eg', 1),
(33, N'Heba', N'Tamer', N'Female', '1995-07-21', N'Single', 11100, N'Part-Time', N'heba.tamer@iti.edu.eg', 1),
(34, N'Mahmoud', N'Wael', N'Male', '1989-04-10', N'Married', 20100, N'Full-Time', N'mahmoud.wael@iti.edu.eg', 1),
(35, N'Rana', N'Ashraf', N'Female', '1991-06-04', N'Married', 16900, N'Full-Time', N'rana.ashraf@iti.edu.eg', 1),
(36, N'Karim', N'Ali', N'Male', '1996-02-15', N'Single', 9950, N'Part-Time', N'karim.ali@iti.edu.eg', 1),
(37, N'Sara', N'Said', N'Female', '1990-09-27', N'Married', 17500, N'Full-Time', N'sara.said@iti.edu.eg', 1),
(38, N'Omar', N'Mansour', N'Male', '1992-12-13', N'Single', 12800, N'Full-Time', N'omar.mansour@iti.edu.eg', 1),
(39, N'Nada', N'Adel', N'Female', '1988-03-24', N'Married', 22100, N'Full-Time', N'nada.adel@iti.edu.eg', 1),
(40, N'Walid', N'Hassan', N'Male', '1994-08-08', N'Single', 11300, N'Part-Time', N'walid.hassan@iti.edu.eg', 1),
(41, N'Reem', N'Gamal', N'Female', '1991-01-16', N'Single', 14800, N'Full-Time', N'reem.gamal@iti.edu.eg', 1),
(42, N'Amr', N'Ismail', N'Male', '1987-07-01', N'Married', 23900, N'Full-Time', N'amr.ismail@iti.edu.eg', 1),
(43, N'Fatima', N'Sherif', N'Female', '1995-03-09', N'Single', 10600, N'Part-Time', N'fatima.sherif@iti.edu.eg', 1),
(44, N'Youssef', N'Kamal', N'Male', '1990-10-06', N'Single', 16200, N'Full-Time', N'youssef.kamal@iti.edu.eg', 1),
(45, N'Aya', N'Ezzat', N'Female', '1986-05-11', N'Married', 21800, N'Full-Time', N'aya.ezzat@iti.edu.eg', 1),
(46, N'Mohamed', N'Wael', N'Male', '1993-09-03', N'Single', 12100, N'Part-Time', N'mohamed.wael@iti.edu.eg', 1),
(47, N'Yasmin', N'Tamer', N'Female', '1989-02-19', N'Married', 19400, N'Full-Time', N'yasmin.tamer@iti.edu.eg', 1),
(48, N'Ali', N'Ashraf', N'Male', '1997-06-25', N'Single', 9400, N'Part-Time', N'ali.ashraf@iti.edu.eg', 1),
(49, N'Mariam', N'Zaki', N'Female', '1992-04-29', N'Single', 13900, N'Full-Time', N'mariam.zaki@iti.edu.eg', 1),
(50, N'Ziad', N'Ibrahim', N'Male', '1985-11-12', N'Married', 25000, N'Full-Time', N'ziad.ibrahim@iti.edu.eg', 1),
(51, N'Hassan', N'Said', N'Male', '1994-10-01', N'Single', 10900, N'Part-Time', N'hassan.said@iti.edu.eg', 1),
(52, N'Nour', N'Mansour', N'Female', '1989-08-17', N'Married', 18600, N'Full-Time', N'nour.mansour@iti.edu.eg', 1),
(53, N'Sameh', N'Adel', N'Male', '1991-03-08', N'Single', 15100, N'Full-Time', N'sameh.adel@iti.edu.eg', 1),
(54, N'Dina', N'Hassan', N'Female', '1996-01-26', N'Single', 8800, N'Part-Time', N'dina.hassan@iti.edu.eg', 1),
(55, N'Khaled', N'Gamal', N'Male', '1987-09-09', N'Married', 23100, N'Full-Time', N'khaled.gamal@iti.edu.eg', 1),
(56, N'Laila', N'Sherif', N'Female', '1993-05-02', N'Single', 12500, N'Part-Time', N'laila.sherif@iti.edu.eg', 1),
(57, N'Tarek', N'Ismail', N'Male', '1988-12-21', N'Married', 21100, N'Full-Time', N'tarek.ismail@iti.edu.eg', 1),
(58, N'Mona', N'Ezzat', N'Female', '1990-07-14', N'Single', 15900, N'Full-Time', N'mona.ezzat@iti.edu.eg', 1),
(59, N'Fares', N'Kamal', N'Male', '1995-10-23', N'Single', 10100, N'Part-Time', N'fares.kamal@iti.edu.eg', 1),
(60, N'Salma', N'Wael', N'Female', '1992-06-16', N'Married', 17900, N'Full-Time', N'salma.wael@iti.edu.eg', 1),
(61, N'Rami', N'Tamer', N'Male', '1984-02-04', N'Married', 24200, N'Full-Time', N'rami.tamer@iti.edu.eg', 1),
(62, N'Heba', N'Ashraf', N'Female', '1994-04-06', N'Single', 11700, N'Part-Time', N'heba.ashraf@iti.edu.eg', 1),
(63, N'Mahmoud', N'Zaki', N'Male', '1991-09-19', N'Single', 14500, N'Full-Time', N'mahmoud.zaki@iti.edu.eg', 1),
(64, N'Rana', N'Ibrahim', N'Female', '1989-01-01', N'Married', 22500, N'Full-Time', N'rana.ibrahim@iti.edu.eg', 1),
(65, N'Karim', N'Said', N'Male', '1993-08-31', N'Single', 11400, N'Part-Time', N'karim.said@iti.edu.eg', 1),
(66, N'Sara', N'Mansour', N'Female', '1990-02-12', N'Married', 19100, N'Full-Time', N'sara.mansour@iti.edu.eg', 1),
(67, N'Omar', N'Adel', N'Male', '1986-10-09', N'Married', 23700, N'Full-Time', N'omar.adel@iti.edu.eg', 1),
(68, N'Nada', N'Hassan', N'Female', '1997-04-14', N'Single', 9250, N'Part-Time', N'nada.hassan@iti.edu.eg', 1),
(69, N'Walid', N'Gamal', N'Male', '1992-07-29', N'Single', 13700, N'Full-Time', N'walid.gamal@iti.edu.eg', 1),
(70, N'Reem', N'Ismail', N'Female', '1988-06-13', N'Married', 20800, N'Full-Time', N'reem.ismail@iti.edu.eg', 1),
(71, N'Amr', N'Sherif', N'Male', '1995-12-05', N'Single', 10300, N'Part-Time', N'amr.sherif@iti.edu.eg', 1),
(72, N'Fatima', N'Ezzat', N'Female', '1991-02-28', N'Single', 15400, N'Full-Time', N'fatima.ezzat@iti.edu.eg', 1),
(73, N'Youssef', N'Kamal', N'Male', '1987-03-18', N'Married', 22900, N'Full-Time', N'youssef.kamal@iti.edu.eg', 1),
(74, N'Aya', N'Wael', N'Female', '1994-09-21', N'Single', 11000, N'Part-Time', N'aya.wael@iti.edu.eg', 1),
(75, N'Mohamed', N'Tamer', N'Male', '1990-04-03', N'Married', 20400, N'Full-Time', N'mohamed.tamer@iti.edu.eg', 1),

-- Department 2: Java ==============================================================================================
(76, N'Hoda', N'Rady', N'Female', '1992-04-22', N'Single', 13500, N'Full-Time', N'hoda.rady@iti.edu.eg', 2),
(77, N'Tamer', N'Adel', N'Male', '1986-08-11', N'Married', 21500, N'Full-Time', N'tamer.adel@iti.edu.eg', 2),
(78, N'Amina', N'Fawzy', N'Female', '1995-01-30', N'Single', 9200, N'Part-Time', N'amina.fawzy@iti.edu.eg', 2),
(79, N'Hazem', N'Nabil', N'Male', '1990-06-15', N'Single', 15800, N'Full-Time', N'hazem.nabil@iti.edu.eg', 2),
(80, N'Ghada', N'Mahmoud', N'Female', '1988-03-25', N'Married', 19800, N'Full-Time', N'ghada.mahmoud@iti.edu.eg', 2),
(81, N'Ehab', N'Sobhy', N'Male', '1993-11-02', N'Single', 11200, N'Part-Time', N'ehab.sobhy@iti.edu.eg', 2),
(82, N'Marwa', N'Sayed', N'Female', '1989-09-18', N'Married', 17600, N'Full-Time', N'marwa.sayed@iti.edu.eg', 2),
(83, N'Hesham', N'Emad', N'Male', '1985-12-01', N'Married', 24300, N'Full-Time', N'hesham.emad@iti.edu.eg', 2),
(84, N'Naglaa', N'Helmy', N'Female', '1996-07-20', N'Single', 8800, N'Part-Time', N'naglaa.helmy@iti.edu.eg', 2),
(85, N'Ibrahim', N'Bakr', N'Male', '1991-02-14', N'Single', 14900, N'Full-Time', N'ibrahim.bakr@iti.edu.eg', 2),
(86, N'Walaa', N'Gaber', N'Female', '1987-10-05', N'Married', 20500, N'Full-Time', N'walaa.gaber@iti.edu.eg', 2),
(87, N'Adel', N'Tawfik', N'Male', '1994-05-28', N'Single', 10500, N'Part-Time', N'adel.tawfik@iti.edu.eg', 2),
(88, N'Soha', N'Amin', N'Female', '1990-08-08', N'Single', 16200, N'Full-Time', N'soha.amin@iti.edu.eg', 2),
(89, N'Raafat', N'Shawky', N'Male', '1984-04-19', N'Married', 22800, N'Full-Time', N'raafat.shawky@iti.edu.eg', 2),
(90, N'Hanan', N'Mounir', N'Female', '1992-12-12', N'Single', 12800, N'Part-Time', N'hanan.mounir@iti.edu.eg', 2),
(91, N'Sherif', N'Lotfy', N'Male', '1989-07-03', N'Married', 18300, N'Full-Time', N'sherif.lotfy@iti.edu.eg', 2),
(92, N'Nevine', N'Fahmy', N'Female', '1995-03-21', N'Single', 9600, N'Part-Time', N'nevine.fahmy@iti.edu.eg', 2),
(93, N'Magdy', N'Zakaria', N'Male', '1988-11-27', N'Married', 21900, N'Full-Time', N'magdy.zakaria@iti.edu.eg', 2),
(94, N'Amal', N'Ramzy', N'Female', '1991-06-09', N'Single', 14100, N'Full-Time', N'amal.ramzy@iti.edu.eg', 2),
(95, N'Fouad', N'Karim', N'Male', '1996-10-16', N'Single', 8500, N'Part-Time', N'fouad.karim@iti.edu.eg', 2),
(96, N'Manal', N'Sami', N'Female', '1986-01-04', N'Married', 23500, N'Full-Time', N'manal.sami@iti.edu.eg', 2),
(97, N'Osama', N'Refaat', N'Male', '1993-04-01', N'Single', 11800, N'Part-Time', N'osama.refaat@iti.edu.eg', 2),
(98, N'Eman', N'Salah', N'Female', '1990-02-07', N'Single', 15300, N'Full-Time', N'eman.salah@iti.edu.eg', 2),
(99, N'Nader', N'Waheed', N'Male', '1987-09-30', N'Married', 20100, N'Full-Time', N'nader.waheed@iti.edu.eg', 2),
(100, N'Rasha', N'Badawy', N'Female', '1994-08-14', N'Single', 10900, N'Part-Time', N'rasha.badawy@iti.edu.eg', 2),
(101, N'Samir', N'Younis', N'Male', '1989-05-06', N'Married', 19400, N'Full-Time', N'samir.younis@iti.edu.eg', 2),
(102, N'Basma', N'Shaker', N'Female', '1992-10-25', N'Single', 13200, N'Full-Time', N'basma.shaker@iti.edu.eg', 2),
(103, N'Ashraf', N'Aziz', N'Male', '1985-06-23', N'Married', 24900, N'Full-Time', N'ashraf.aziz@iti.edu.eg', 2),
(104, N'Yara', N'Talaat', N'Female', '1997-03-08', N'Single', 8100, N'Part-Time', N'yara.talaat@iti.edu.eg', 2),
(105, N'Maged', N'Riad', N'Male', '1991-08-19', N'Single', 14500, N'Full-Time', N'maged.riad@iti.edu.eg', 2),
(106, N'Omnia', N'Hamdy', N'Female', '1988-01-11', N'Married', 22200, N'Full-Time', N'omnia.hamdy@iti.edu.eg', 2),
(107, N'Medhat', N'Anwar', N'Male', '1993-09-05', N'Single', 11100, N'Part-Time', N'medhat.anwar@iti.edu.eg', 2),
(108, N'Shereen', N'Osman', N'Female', '1990-04-17', N'Married', 18800, N'Full-Time', N'shereen.osman@iti.edu.eg', 2),
(109, N'Gamal', N'Ezz', N'Male', '1986-11-13', N'Married', 23100, N'Full-Time', N'gamal.ezz@iti.edu.eg', 2),

-- Department 3: Multimedia 
(110, N'Hany', N'Fahmy', N'Male', '1990-07-22', N'Single', 15200, N'Full-Time', N'hany.fahmy@iti.edu.eg', 3),
(111, N'Rania', N'Gerges', N'Female', '1994-03-18', N'Single', 9800, N'Part-Time', N'rania.gerges@iti.edu.eg', 3),
(112, N'Wael', N'Botros', N'Male', '1987-11-01', N'Married', 20500, N'Full-Time', N'wael.botros@iti.edu.eg', 3),
(113, N'Mona', N'Hanna', N'Female', '1992-09-12', N'Single', 13800, N'Full-Time', N'mona.hanna@iti.edu.eg', 3),
(114, N'Sameh', N'Mansour', N'Male', '1993-01-25', N'Single', 11500, N'Part-Time', N'sameh.mansour@iti.edu.eg', 3),
(115, N'Dalia', N'Kamal', N'Female', '1989-05-30', N'Married', 18900, N'Full-Time', N'dalia.kamal@iti.edu.eg', 3),
(116, N'Fady', N'Abdo', N'Male', '1986-02-14', N'Married', 22300, N'Full-Time', N'fady.abdo@iti.edu.eg', 3),
(117, N'Sandra', N'Saad', N'Female', '1995-10-08', N'Single', 8900, N'Part-Time', N'sandra.saad@iti.edu.eg', 3),
(118, N'George', N'Rizk', N'Male', '1991-08-17', N'Single', 14700, N'Full-Time', N'george.rizk@iti.edu.eg', 3),
(119, N'Marina', N'Gendy', N'Female', '1988-06-05', N'Married', 19600, N'Full-Time', N'marina.gendy@iti.edu.eg', 3),
(120, N'Peter', N'Mikhail', N'Male', '1996-04-03', N'Single', 9200, N'Part-Time', N'peter.mikhail@iti.edu.eg', 3),
(121, N'Christine', N'Fahmy', N'Female', '1990-12-21', N'Single', 16100, N'Full-Time', N'christine.fahmy@iti.edu.eg', 3),
(122, N'Mina', N'Gerges', N'Male', '1985-09-19', N'Married', 23800, N'Full-Time', N'mina.gerges@iti.edu.eg', 3),
(123, N'Salwa', N'Botros', N'Female', '1993-07-11', N'Single', 10800, N'Part-Time', N'salwa.botros@iti.edu.eg', 3),
(124, N'Amir', N'Hanna', N'Male', '1989-03-28', N'Married', 20100, N'Full-Time', N'amir.hanna@iti.edu.eg', 3),
(125, N'Noha', N'Mansour', N'Female', '1992-01-07', N'Single', 14200, N'Full-Time', N'noha.mansour@iti.edu.eg', 3),
(126, N'Karim', N'Kamal', N'Male', '1994-11-15', N'Single', 10300, N'Part-Time', N'karim.kamal@iti.edu.eg', 3),
(127, N'Heba', N'Abdo', N'Female', '1987-08-02', N'Married', 21700, N'Full-Time', N'heba.abdo@iti.edu.eg', 3),
(128, N'Tamer', N'Saad', N'Male', '1990-04-26', N'Single', 15800, N'Full-Time', N'tamer.saad@iti.edu.eg', 3),
(129, N'Fatma', N'Rizk', N'Female', '1996-09-01', N'Single', 8600, N'Part-Time', N'fatma.rizk@iti.edu.eg', 3),
(130, N'Hazem', N'Gendy', N'Male', '1986-06-18', N'Married', 22900, N'Full-Time', N'hazem.gendy@iti.edu.eg', 3),
(131, N'Aisha', N'Mikhail', N'Female', '1991-03-09', N'Single', 13400, N'Full-Time', N'aisha.mikhail@iti.edu.eg', 3),
(132, N'Ehab', N'Fahmy', N'Male', '1995-02-23', N'Single', 9500, N'Part-Time', N'ehab.fahmy@iti.edu.eg', 3),
(133, N'Marwa', N'Gerges', N'Female', '1989-10-14', N'Married', 19200, N'Full-Time', N'marwa.gerges@iti.edu.eg', 3),
(134, N'Hesham', N'Botros', N'Male', '1984-12-07', N'Married', 24500, N'Full-Time', N'hesham.botros@iti.edu.eg', 3),
(135, N'Naglaa', N'Hanna', N'Female', '1993-06-29', N'Single', 11900, N'Part-Time', N'naglaa.hanna@iti.edu.eg', 3),
(136, N'Ibrahim', N'Mansour', N'Male', '1990-09-03', N'Single', 16500, N'Full-Time', N'ibrahim.mansour@iti.edu.eg', 3),
(137, N'Walaa', N'Kamal', N'Female', '1988-01-16', N'Married', 20800, N'Full-Time', N'walaa.kamal@iti.edu.eg', 3),
(138, N'Adel', N'Abdo', N'Male', '1992-05-13', N'Single', 12400, N'Part-Time', N'adel.abdo@iti.edu.eg', 3),
(139, N'Soha', N'Saad', N'Female', '1987-03-24', N'Married', 21100, N'Full-Time', N'soha.saad@iti.edu.eg', 3),
(140, N'Raafat', N'Rizk', N'Male', '1994-07-06', N'Single', 10100, N'Part-Time', N'raafat.rizk@iti.edu.eg', 3),
(141, N'Hanan', N'Gendy', N'Female', '1991-11-28', N'Single', 14900, N'Full-Time', N'hanan.gendy@iti.edu.eg', 3),
(142, N'Sherif', N'Mikhail', N'Male', '1986-10-20', N'Married', 23400, N'Full-Time', N'sherif.mikhail@iti.edu.eg', 3),
(143, N'Nevine', N'Fahmy', N'Female', '1995-08-15', N'Single', 9300, N'Part-Time', N'nevine.fahmy@iti.edu.eg', 3),

-- Department 4: Unix 
(144, N'Tarek', N'Fawzy', N'Male', '1988-10-15', N'Single', 16200, N'Full-Time', N'tarek.fawzy@iti.edu.eg', 4),
(145, N'Lobna', N'Said', N'Female', '1993-04-20', N'Single', 10500, N'Part-Time', N'lobna.said@iti.edu.eg', 4),
(146, N'Medhat', N'Gaber', N'Male', '1985-07-02', N'Married', 22500, N'Full-Time', N'medhat.gaber@iti.edu.eg', 4),
(147, N'Shaimaa', N'Adel', N'Female', '1991-12-11', N'Married', 18300, N'Full-Time', N'shaimaa.adel@iti.edu.eg', 4),
(148, N'Amr', N'Shahin', N'Male', '1995-02-28', N'Single', 9800, N'Part-Time', N'amr.shahin@iti.edu.eg', 4),
(149, N'Nabil', N'Shokry', N'Male', '1989-06-08', N'Single', 15100, N'Full-Time', N'nabil.shokry@iti.edu.eg', 4),
(150, N'Reham', N'Aziz', N'Female', '1992-08-25', N'Single', 12400, N'Part-Time', N'reham.aziz@iti.edu.eg', 4),

-- Department 5: Network
(151, N'Mohsen', N'Attia', N'Male', '1987-09-12', N'Married', 21000, N'Full-Time', N'mohsen.attia@iti.edu.eg', 5),
(152, N'Safaa', N'Kamel', N'Female', '1994-01-28', N'Single', 10200, N'Part-Time', N'safaa.kamel@iti.edu.eg', 5),
(153, N'Anwar', N'Hamed', N'Male', '1990-05-17', N'Single', 15500, N'Full-Time', N'anwar.hamed@iti.edu.eg', 5),
(154, N'Jihan', N'Saleh', N'Female', '1991-11-03', N'Married', 18800, N'Full-Time', N'jihan.saleh@iti.edu.eg', 5),
(155, N'Ziad', N'Ismail', N'Male', '1996-02-22', N'Single', 9400, N'Part-Time', N'ziad.ismail@iti.edu.eg', 5),
(156, N'Laila', N'Wahba', N'Female', '1992-06-30', N'Single', 14300, N'Full-Time', N'laila.wahba@iti.edu.eg', 5),
(157, N'Essam', N'Amer', N'Male', '1984-08-08', N'Married', 23500, N'Full-Time', N'essam.amer@iti.edu.eg', 5),

-- Department 6: E-Business 
(158, N'Asmaa', N'Khalil', N'Female', '1993-08-11', N'Single', 12800, N'Part-Time', N'asmaa.khalil@iti.edu.eg', 6),
(159, N'Mahmoud', N'El-Sayed', N'Male', '1989-02-19', N'Married', 19500, N'Full-Time', N'mahmoud.el-sayed@iti.edu.eg', 6),
(160, N'Reem', N'Rageb', N'Female', '1995-07-07', N'Single', 9100, N'Part-Time', N'reem.rageb@iti.edu.eg', 6),
(161, N'Mustafa', N'Sultan', N'Male', '1990-10-01', N'Single', 16000, N'Full-Time', N'mustafa.sultan@iti.edu.eg', 6),
(162, N'Yasmin', N'Gamal', N'Female', '1988-04-14', N'Married', 20200, N'Full-Time', N'yasmin.gamal@iti.edu.eg', 6),
(163, N'Abdelrahman', N'Abbas', N'Male', '1994-09-02', N'Single', 11300, N'Part-Time', N'abdelrahman.abbas@iti.edu.eg', 6),
(164, N'Mai', N'Taha', N'Female', '1991-03-23', N'Married', 17800, N'Full-Time', N'mai.taha@iti.edu.eg', 6),
(165, N'Walid', N'Diab', N'Male', '1986-12-05', N'Married', 24100, N'Full-Time', N'walid.diab@iti.edu.eg', 6),
(166, N'Sara', N'Ebeid', N'Female', '1996-05-29', N'Single', 8700, N'Part-Time', N'sara.ebeid@iti.edu.eg', 6),
(167, N'Karim', N'El-Masry', N'Male', '1992-01-16', N'Single', 15100, N'Full-Time', N'karim.el-masry@iti.edu.eg', 6),
(168, N'Nourhan', N'Zakaria', N'Female', '1989-08-30', N'Married', 20800, N'Full-Time', N'nourhan.zakaria@iti.edu.eg', 6),
(169, N'Ali', N'El-Sharkawy', N'Male', '1993-06-13', N'Single', 10800, N'Part-Time', N'ali.el-sharkawy@iti.edu.eg', 6),
(170, N'Farah', N'Fouad', N'Female', '1990-11-24', N'Single', 16600, N'Full-Time', N'farah.fouad@iti.edu.eg', 6),
(171, N'Islam', N'Shehata', N'Male', '1985-05-09', N'Married', 22900, N'Full-Time', N'islam.shehata@iti.edu.eg', 6),
(172, N'Aya', N'Ashraf', N'Female', '1994-10-18', N'Single', 12200, N'Part-Time', N'aya.ashraf@iti.edu.eg', 6),
(173, N'Moataz', N'Hosny', N'Male', '1988-07-03', N'Married', 18600, N'Full-Time', N'moataz.hosny@iti.edu.eg', 6),
(174, N'Salma', N'El-Shazly', N'Female', '1996-01-26', N'Single', 9900, N'Part-Time', N'salma.el-shazly@iti.edu.eg', 6),
(175, N'Sayed', N'El-Hawary', N'Male', '1987-03-15', N'Married', 21700, N'Full-Time', N'sayed.el-hawary@iti.edu.eg', 6),
(176, N'Mariam', N'Okasha', N'Female', '1992-08-01', N'Single', 14400, N'Full-Time', N'mariam.okasha@iti.edu.eg', 6),
(177, N'Mostafa', N'El-Naggar', N'Male', '1997-04-12', N'Single', 8300, N'Part-Time', N'mostafa.el-naggar@iti.edu.eg', 6),
(178, N'Nada', N'Basyouni', N'Female', '1986-09-08', N'Married', 23700, N'Full-Time', N'nada.basyouni@iti.edu.eg', 6),
(179, N'Ramy', N'El-Gendy', N'Male', '1993-11-20', N'Single', 11900, N'Part-Time', N'ramy.el-gendy@iti.edu.eg', 6),
(180, N'Doaa', N'Kandil', N'Female', '1991-01-31', N'Single', 15600, N'Full-Time', N'doaa.kandil@iti.edu.eg', 6),
(181, N'Hossam', N'El-Kholy', N'Male', '1988-06-25', N'Married', 20400, N'Full-Time', N'hossam.el-kholy@iti.edu.eg', 6),
(182, N'Esraa', N'Nassar', N'Female', '1995-02-11', N'Single', 10600, N'Part-Time', N'esraa.nassar@iti.edu.eg', 6),
(183, N'Yehia', N'El-Badry', N'Male', '1989-12-03', N'Married', 19100, N'Full-Time', N'yehia.el-badry@iti.edu.eg', 6),
(184, N'Habiba', N'El-Sawy', N'Female', '1993-05-16', N'Single', 13700, N'Full-Time', N'habiba.el-sawy@iti.edu.eg', 6),
(185, N'Omar', N'El-Sherif', N'Male', '1984-02-04', N'Married', 25000, N'Full-Time', N'omar.el-sherif@iti.edu.eg', 6),
(186, N'Rowan', N'El-Daly', N'Female', '1997-09-21', N'Single', 8200, N'Part-Time', N'rowan.el-daly@iti.edu.eg', 6),
(187, N'Bahaa', N'El-Tayeb', N'Male', '1992-03-06', N'Single', 14800, N'Full-Time', N'bahaa.el-tayeb@iti.edu.eg', 6),
(188, N'Menna', N'Fahmy', N'Female', '1989-07-19', N'Married', 22400, N'Full-Time', N'menna.fahmy@iti.edu.eg', 6),
(189, N'Loai', N'El-Meligy', N'Male', '1994-01-08', N'Single', 11000, N'Part-Time', N'loai.el-meligy@iti.edu.eg', 6),
(190, N'Shrouk', N'Ghanem', N'Female', '1991-09-14', N'Married', 18100, N'Full-Time', N'shrouk.ghanem@iti.edu.eg', 6),
(191, N'Bassem', N'Hefny', N'Male', '1987-10-27', N'Married', 22000, N'Full-Time', N'bassem.hefny@iti.edu.eg', 6),
(192, N'Malak', N'El-Attar', N'Female', '1996-08-05', N'Single', 9500, N'Part-Time', N'malak.el-attar@iti.edu.eg', 6);


INSERT INTO Instructor_Phone (Instructor_ID, Phone)
VALUES
(7, N'01112223344'),
(8, N'01223334455'),
(9, N'01001112233'),
(10, N'01114445566'), (10, N'01225556677'),
(11, N'01009988776'),
(12, N'01151112233'),
(13, N'01287654321'),
(14, N'01012312345'),
(15, N'01119876543'),
(16, N'01224567890'),
(17, N'01001234567'),
(18, N'01113456789'),
(19, N'01221234567'),
(20, N'01004567890'), (20, N'01115678901'),
(21, N'01116789012'),
(22, N'01227890123'),
(23, N'01008901234'),
(24, N'01119012345'),
(25, N'01220123456'),
(26, N'01001122334'),
(27, N'01112233445'),
(28, N'01223344556'),
(29, N'01004455667'),
(30, N'01115566778'), (30, N'01006677889'),
(31, N'01226677889'),
(32, N'01007788990'),
(33, N'01118899001'),
(34, N'01229900112'),
(35, N'01000011223'),
(36, N'01111122334'),
(37, N'01222233445'),
(38, N'01003344556'),
(39, N'01114455667'),
(40, N'01225566778'), (40, N'01556677889'),
(41, N'01006677889'),
(42, N'01117788990'),
(43, N'01228899001'),
(44, N'01009900112'),
(45, N'01110011223'),
(46, N'01221122334'),
(47, N'01002233445'),
(48, N'01113344556'),
(49, N'01224455667'),
(50, N'01005566778'), (50, N'01116677889'),
(51, N'01116677889'),
(52, N'01227788990'),
(53, N'01008899001'),
(54, N'01119900112'),
(55, N'01220011223'),
(56, N'01001122334'),
(57, N'01112233445'),
(58, N'01223344556'),
(59, N'01004455667'),
(60, N'01115566778'),
(61, N'01226677889'),
(62, N'01007788990'),
(63, N'01118899001'),
(64, N'01229900112'),
(65, N'01000011223'),
(66, N'01111122334'), (66, N'01222233445'),
(67, N'01222233445'),
(68, N'01003344556'),
(69, N'01114455667'),
(70, N'01225566778'),
(71, N'01006677889'),
(72, N'01117788990'),
(73, N'01228899001'),
(74, N'01009900112'),
(75, N'01110011223'), (75, N'01002233445'),
(76, N'01221122334'),
(77, N'01002233445'),
(78, N'01113344556'),
(79, N'01224455667'),
(80, N'01005566778'),
(81, N'01116677889'),
(82, N'01227788990'),
(83, N'01008899001'),
(84, N'01119900112'),
(85, N'01220011223'),
(86, N'01001122334'),
(87, N'01112233445'),
(88, N'01223344556'), (88, N'01004455667'),
(89, N'01004455667'),
(90, N'01115566778'),
(91, N'01226677889'),
(92, N'01007788990'),
(93, N'01118899001'),
(94, N'01229900112'),
(95, N'01000011223'),
(96, N'01111122334'),
(97, N'01222233445'),
(98, N'01003344556'),
(99, N'01114455667'), (99, N'01225566778'),
(100, N'01225566778'),
(101, N'01006677889'), (101, N'01117788990'),
(102, N'01117788990'),
(103, N'01228899001'),
(104, N'01009900112'),
(105, N'01110011223'),
(106, N'01221122334'),
(107, N'01002233445'),
(108, N'01113344556'),
(109, N'01224455667'),
(110, N'01005566778'), (110, N'01116677889'),
(111, N'01116677889'),
(112, N'01227788990'),
(113, N'01008899001'),
(114, N'01119900112'),
(115, N'01220011223'),
(116, N'01001122334'),
(117, N'01112233445'),
(118, N'01223344556'),
(119, N'01004455667'),
(120, N'01115566778'),
(121, N'01226677889'),
(122, N'01007788990'),
(123, N'01118899001'), (123, N'01229900112'),
(124, N'01229900112'),
(125, N'01000011223'),
(126, N'01111122334'),
(127, N'01222233445'),
(128, N'01003344556'),
(129, N'01114455667'),
(130, N'01225566778'),
(131, N'01006677889'),
(132, N'01117788990'),
(133, N'01228899001'),
(134, N'01009900112'),
(135, N'01110011223'), (135, N'01221122334'),
(136, N'01221122334'),
(137, N'01002233445'),
(138, N'01113344556'),
(139, N'01224455667'),
(140, N'01005566778'),
(141, N'01116677889'),
(142, N'01227788990'),
(143, N'01008899001'),
(144, N'01119900112'),
(145, N'01220011223'),
(146, N'01001122334'),
(147, N'01112233445'),
(148, N'01223344556'),
(149, N'01004455667'),
(150, N'01115566778'), (150, N'01226677889'),
(151, N'01226677889'),
(152, N'01007788990'),
(153, N'01118899001'),
(154, N'01229900112'),
(155, N'01000011223'),
(156, N'01111122334'),
(157, N'01222233445'),
(158, N'01003344556'),
(159, N'01114455667'),
(160, N'01225566778'),
(161, N'01006677889'), (161, N'01117788990'),
(162, N'01117788990'),
(163, N'01228899001'),
(164, N'01009900112'),
(165, N'01110011223'),
(166, N'01221122334'),
(167, N'01002233445'),
(168, N'01113344556'),
(169, N'01224455667'),
(170, N'01005566778'),
(171, N'01116677889'),
(172, N'01227788990'),
(173, N'01008899001'),
(174, N'01119900112'),
(175, N'01220011223'),
(176, N'01001122334'),
(177, N'01112233445'), (177, N'01223344556'),
(178, N'01223344556'),
(179, N'01004455667'),
(180, N'01115566778'), (180, N'01226677889'),
(181, N'01226677889'),
(182, N'01007788990'),
(183, N'01118899001'),
(184, N'01229900112'),
(185, N'01000011223'),
(186, N'01111122334'),
(187, N'01222233445'),
(188, N'01003344556'),
(189, N'01114455667'),
(190, N'01225566778'),
(191, N'01006677889'),
(192, N'01117788990'),
(193, N'01228899001'), (193, N'01009900112'),
(194, N'01110011223'),
(195, N'01221122334'),
(196, N'01002233445'),
(197, N'01113344556');

INSERT INTO Instructor_Course (Instructor_ID, Course_ID)
VALUES
-- Department 1: System Development (Courses 1-70 assigned to Instructors 1, 7-75)
(1, 1), (7, 2), (8, 3), (9, 4), (10, 5), (11, 6), (12, 7), (13, 8), (14, 9), (15, 10), (16, 11), (17, 12), (18, 13), (19, 14), (20, 15), (21, 16), (22, 17), (23, 18), (24, 19), (25, 20), (26, 21), (27, 22), (28, 23), (29, 24), (30, 25), (31, 26), (32, 27), (33, 28), (34, 29), (35, 30), (36, 31), (37, 32), (38, 33), (39, 34), (40, 35), (41, 36), (42, 37), (43, 38), (44, 39), (45, 40), (46, 41), (47, 42), (48, 43), (49, 44), (50, 45), (51, 46), (52, 47), (53, 48), (54, 49), (55, 50), (56, 51), (57, 52), (58, 53), (59, 54), (60, 55), (61, 56), (62, 57), (63, 58), (64, 59), (65, 60), (66, 61), (67, 62), (68, 63), (69, 64), (70, 65), (71, 66), (72, 67), (73, 68), (74, 69), (75, 70),

-- Department 2: Java (Courses 71-105 assigned to Instructors 2, 76-109)
(2, 71), (76, 72), (77, 73), (78, 74), (79, 75), (80, 76), (81, 77), (82, 78), (83, 79), (84, 80), (85, 81), (86, 82), (87, 83), (88, 84), (89, 85), (90, 86), (91, 87), (92, 88), (93, 89), (94, 90), (95, 91), (96, 92), (97, 93), (98, 94), (99, 95), (100, 96), (101, 97), (102, 98), (103, 99), (104, 100), (105, 101), (106, 102), (107, 103), (108, 104), (109, 105),

-- Department 3: Multimedia (Courses 106-140 assigned to Instructors 3, 110-143)
(3, 106), (110, 107), (111, 108), (112, 109), (113, 110), (114, 111), (115, 112), (116, 113), (117, 114), (118, 115), (119, 116), (120, 117), (121, 118), (122, 119), (123, 120), (124, 121), (125, 122), (126, 123), (127, 124), (128, 125), (129, 126), (130, 127), (131, 128), (132, 129), (133, 130), (134, 131), (135, 132), (136, 133), (137, 134), (138, 135), (139, 136), (140, 137), (141, 138), (142, 139), (143, 140),

-- Department 4: Unix (Courses 141-147 assigned to Instructors 4, 144-149)
(4, 141), (144, 142), (145, 143), (146, 144), (147, 145), (148, 146), (149, 147),

-- Department 5: Network (Courses 148-154 assigned to Instructors 5, 151-157)
(5, 148), (151, 149), (152, 150), (153, 151), (154, 152), (155, 153), (156, 154),

-- Department 6: E-Business (Courses 155-189 assigned to Instructors 6, 158-192)
(6, 155), (158, 156), (159, 157), (160, 158), (161, 159), (162, 160), (163, 161), (164, 162), (165, 163), (166, 164), (167, 165), (168, 166), (169, 167), (170, 168), (171, 169), (172, 170), (173, 171), (174, 172), (175, 173), (176, 174), (177, 175), (178, 176), (179, 177), (180, 178), (181, 179), (182, 180), (183, 181), (184, 182), (185, 183), (186, 184), (187, 185), (188, 186), (189, 187), (190, 188), (191, 189);

--Department 7 Link new Instructors to their respective new Courses
INSERT INTO Instructor_Course (Instructor_ID, Course_ID)
VALUES
(193, 190), -- Mona Selim -> Communication Skills
(194, 191), -- Tamer Adel -> Presentation Skills
(195, 192), -- Heba Zaki -> Ethics
(196, 193), -- Karim Raouf -> CV Writing
(197, 194); -- Laila Nader -> Freelancing

-- ================ ================ ================ ================ ================ ================ ================ ================ ================
-- Topics of the Courses Data
-- ================ ================ ================ ================ ================ ================ ================ ================ ================

-- Department: System Development - Track: Power BI Development - Course: Intro to Power BI
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (1, N'Power BI Desktop Interface', 1), (2, N'Connecting to Data Sources', 1), (3, N'Basic Data Modeling', 1), (4, N'Creating First Reports', 1);
-- Department: System Development - Track: Power BI Development - Course: Advanced Power BI
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (5, N'Advanced DAX Functions', 2), (6, N'Power Query (M Language)', 2), (7, N'Dataflows and Shared Datasets', 2);
-- Department: System Development - Track: Power BI Development - Course: DAX & Data Modeling
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (8, N'Calculated Columns vs. Measures', 3), (9, N'Time Intelligence Functions', 3), (10, N'Star Schema Modeling', 3);
-- Department: System Development - Track: Power BI Development - Course: Power BI Service Admin
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (11, N'Workspace Management', 4), (12, N'Gateway Configuration', 4), (13, N'Usage Monitoring & Security', 4);
-- Department: System Development - Track: Power BI Development - Course: Data Visualization Best Practices
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (14, N'Choosing the Right Visual', 5), (15, N'Dashboard Layout and Storytelling', 5), (16, N'User Experience (UX) for Reports', 5);
-- Department: System Development - Track: Power BI Development - Course: Power BI Report Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (17, N'Themes and Templates', 6), (18, N'Custom Visuals', 6), (19, N'Bookmarks and Page Navigation', 6), (20, N'Responsive Layouts', 6);
-- Department: System Development - Track: Power BI Development - Course: Paginated Reports in Power BI
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (21, N'Report Builder Introduction', 7), (22, N'Creating Datasets and Parameters', 7), (23, N'Designing Pixel-Perfect Layouts', 7);

-- Department: System Development - Track: Industrial Automation - Course: PLC Programming Basics
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (24, N'Introduction to PLCs', 8), (25, N'Ladder Logic Fundamentals', 8), (26, N'Timers and Counters', 8);
-- Department: System Development - Track: Industrial Automation - Course: SCADA Systems
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (27, N'SCADA Architecture', 9), (28, N'Tag Database Configuration', 9), (29, N'Alarming and Historical Data', 9);
-- Department: System Development - Track: Industrial Automation - Course: HMI Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (30, N'HMI Screen Development', 10), (31, N'Scripting and Animation', 10), (32, N'Connecting HMI to PLC', 10);
-- Department: System Development - Track: Industrial Automation - Course: Industrial Networks
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (33, N'EtherNet/IP & PROFINET', 11), (34, N'Modbus TCP/IP', 11), (35, N'Network Troubleshooting', 11);
-- Department: System Development - Track: Industrial Automation - Course: Robotics Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (36, N'Robot Types and Components', 12), (37, N'Robot Kinematics', 12), (38, N'Basic Robot Programming', 12);
-- Department: System Development - Track: Industrial Automation - Course: Motion Control
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (39, N'Servo Motors and Drives', 13), (40, N'Motion Profiles', 13), (41, N'Tuning and Optimization', 13);
-- Department: System Development - Track: Industrial Automation - Course: Process Control
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (42, N'PID Control Loops', 14), (43, N'Instrumentation and Sensors', 14), (44, N'Control Loop Tuning', 14);

-- Department: System Development - Track: AWS Re /Start - Course: Cloud Foundations
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (45, N'What is Cloud Computing?', 15), (46, N'AWS Global Infrastructure', 15), (47, N'Core AWS Services Overview', 15);
-- Department: System Development - Track: AWS Re /Start - Course: Linux Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (48, N'Command Line Interface (CLI)', 16), (49, N'File Systems and Permissions', 16), (50, N'Basic Shell Scripting', 16);
-- Department: System Development - Track: AWS Re /Start - Course: AWS Core Services
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (51, N'IAM and Security', 17), (52, N'EC2 and Compute', 17), (53, N'S3 and Storage', 17), (54, N'VPC and Networking', 17);
-- Department: System Development - Track: AWS Re /Start - Course: Python for AWS
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (55, N'Python Basics for Scripting', 18), (56, N'Boto3 SDK Introduction', 18), (57, N'Automating AWS Tasks with Python', 18);
-- Department: System Development - Track: AWS Re /Start - Course: Databases on AWS
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (58, N'Introduction to RDS', 19), (59, N'DynamoDB for NoSQL', 19), (60, N'Database Migration Strategies', 19);
-- Department: System Development - Track: AWS Re /Start - Course: Networking & Security
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (61, N'VPC Peering and Endpoints', 20), (62, N'Security Groups vs. NACLs', 20), (63, N'AWS Shield and WAF', 20);
-- Department: System Development - Track: AWS Re /Start - Course: DevOps on AWS
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (64, N'CI/CD with CodePipeline', 21), (65, N'Infrastructure as Code (IaC) with CloudFormation', 21), (66, N'Monitoring with CloudWatch', 21);

-- Department: System Development - Track: Python and DevOps Development - Course: Python Basics
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (67, N'Data Types and Variables', 22), (68, N'Control Flow', 22), (69, N'Functions and Modules', 22);
-- Department: System Development - Track: Python and DevOps Development - Course: Advanced Python
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (70, N'Object-Oriented Programming', 23), (71, N'Decorators and Generators', 23), (72, N'Concurrency in Python', 23);
-- Department: System Development - Track: Python and DevOps Development - Course: Git & Version Control
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (73, N'Git Fundamentals', 24), (74, N'Branching and Merging', 24), (75, N'Collaborating with GitHub/GitLab', 24);
-- Department: System Development - Track: Python and DevOps Development - Course: CI/CD Pipelines
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (76, N'Jenkins Introduction', 25), (77, N'Automated Testing', 25), (78, N'Building and Deploying Artifacts', 25);
-- Department: System Development - Track: Python and DevOps Development - Course: Docker & Containers
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (79, N'Introduction to Containers', 26), (80, N'Writing Dockerfiles', 26), (81, N'Docker Compose for Multi-Container Apps', 26);
-- Department: System Development - Track: Python and DevOps Development - Course: Kubernetes
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (82, N'Kubernetes Architecture', 27), (83, N'Pods, Deployments, and Services', 27), (84, N'Configuration and Secrets Management', 27);
-- Department: System Development - Track: Python and DevOps Development - Course: Monitoring & Logging
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (85, N'Prometheus and Grafana', 28), (86, N'ELK Stack (Elasticsearch, Logstash, Kibana)', 28), (87, N'Application Performance Monitoring (APM)', 28);

-- Department: System Development - Track: Data Engineering - Course: Data Engineering Intro
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (88, N'What is Data Engineering?', 29), (89, N'The Data Lifecycle', 29), (90, N'Tools of a Data Engineer', 29);
-- Department: System Development - Track: Data Engineering - Course: SQL for Data Engineering
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (91, N'Advanced SQL Window Functions', 30), (92, N'Common Table Expressions (CTEs)', 30), (93, N'Query Optimization', 30);
-- Department: System Development - Track: Data Engineering - Course: Data Warehousing
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (94, N'Data Warehouse Concepts (Kimball vs. Inmon)', 31), (95, N'Dimensional Modeling', 31), (96, N'ETL vs. ELT', 31);
-- Department: System Development - Track: Data Engineering - Course: Big Data Tech
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (97, N'Hadoop Ecosystem (HDFS, MapReduce)', 32), (98, N'Introduction to Apache Spark', 32), (99, N'Data Lakes', 32);
-- Department: System Development - Track: Data Engineering - Course: Data Pipelines & Airflow
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (100, N'Introduction to Apache Airflow', 33), (101, N'Building DAGs', 33), (102, N'Scheduling and Monitoring', 33);
-- Department: System Development - Track: Data Engineering - Course: Streaming Data
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (103, N'Introduction to Apache Kafka', 34), (104, N'Spark Streaming', 34), (105, N'Real-time Data Processing', 34);
-- Department: System Development - Track: Data Engineering - Course: Cloud Data Platforms
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (106, N'AWS Glue', 35), (107, N'Google BigQuery', 35), (108, N'Azure Data Factory', 35);

-- Department: System Development - Track: Front-End and Cross Platform Mobile Development - Course: HTML & CSS
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (109, N'HTML5 Semantics', 36), (110, N'CSS Flexbox and Grid', 36), (111, N'Responsive Design', 36);
-- Department: System Development - Track: Front-End and Cross Platform Mobile Development - Course: JavaScript Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (112, N'ES6+ Features', 37), (113, N'DOM Manipulation', 37), (114, N'Asynchronous JavaScript (Promises, async/await)', 37);
-- Department: System Development - Track: Front-End and Cross Platform Mobile Development - Course: React.js
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (115, N'Components, Props, and State', 38), (116, N'React Hooks', 38), (117, N'React Router', 38);
-- Department: System Development - Track: Front-End and Cross Platform Mobile Development - Course: React Native Basics
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (118, N'React Native Core Components', 39), (119, N'Styling in React Native', 39), (120, N'Navigation', 39);
-- Department: System Development - Track: Front-End and Cross Platform Mobile Development - Course: State Management
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (121, N'Redux Toolkit', 40), (122, N'React Context API', 40), (123, N'Zustand/Jotai', 40);
-- Department: System Development - Track: Front-End and Cross Platform Mobile Development - Course: API Integration
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (124, N'Fetching Data with Fetch API/Axios', 41), (125, N'Working with REST APIs', 41), (126, N'GraphQL Basics', 41);
-- Department: System Development - Track: Front-End and Cross Platform Mobile Development - Course: Testing & Deployment
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (127, N'Jest and React Testing Library', 42), (128, N'Building for Production', 42), (129, N'App Store/Play Store Deployment', 42);

-- Department: System Development - Track: iOS Mobile Application Development - Course: Swift Programming
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (130, N'Swift Fundamentals', 43), (131, N'Optionals and Error Handling', 43), (132, N'Structs vs. Classes', 43);
-- Department: System Development - Track: iOS Mobile Application Development - Course: UIKit Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (133, N'View Controllers and Lifecycle', 44), (134, N'Interface Builder and Auto Layout', 44), (135, N'Table and Collection Views', 44);
-- Department: System Development - Track: iOS Mobile Application Development - Course: SwiftUI
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (136, N'Declarative Syntax', 45), (137, N'State and Data Flow', 45), (138, N'Building UI with SwiftUI', 45);
-- Department: System Development - Track: iOS Mobile Application Development - Course: Data Persistence
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (139, N'UserDefaults', 46), (140, N'Codable Protocol', 46), (141, N'Core Data Basics', 46);
-- Department: System Development - Track: iOS Mobile Application Development - Course: Networking
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (142, N'URLSession', 47), (143, N'Decoding JSON', 47), (144, N'Concurrency with async/await', 47);
-- Department: System Development - Track: iOS Mobile Application Development - Course: Architecture (MVC, MVVM)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (145, N'Model-View-Controller (MVC)', 48), (146, N'Model-View-ViewModel (MVVM)', 48), (147, N'Coordinators', 48);
-- Department: System Development - Track: iOS Mobile Application Development - Course: App Store Submission
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (148, N'Certificates and Provisioning', 49), (149, N'App Store Connect', 49), (150, N'TestFlight for Beta Testing', 49);

-- Department: System Development - Track: Software Development Fundamentals - Course: Programming Logic
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (151, N'Algorithms and Pseudocode', 50), (152, N'Problem Solving Techniques', 50), (153, N'Flowcharts', 50);
-- Department: System Development - Track: Software Development Fundamentals - Course: Data Structures
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (154, N'Arrays and Lists', 51), (155, N'Stacks and Queues', 51), (156, N'Trees and Graphs', 51);
-- Department: System Development - Track: Software Development Fundamentals - Course: OOP Concepts
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (157, N'Encapsulation, Inheritance, Polymorphism', 52), (158, N'Classes and Objects', 52), (159, N'Abstraction', 52);
-- Department: System Development - Track: Software Development Fundamentals - Course: C# Basics
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (160, N'C# Syntax and Data Types', 53), (161, N'LINQ', 53), (162, N'Exception Handling', 53);
-- Department: System Development - Track: Software Development Fundamentals - Course: Database Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (163, N'Relational Databases', 54), (164, N'Basic SQL (SELECT, INSERT, UPDATE, DELETE)', 54), (165, N'Normalization', 54);
-- Department: System Development - Track: Software Development Fundamentals - Course: Web Basics
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (166, N'How the Web Works (HTTP/HTTPS)', 55), (167, N'Introduction to HTML, CSS, JavaScript', 55), (168, N'Client-Server Model', 55);
-- Department: System Development - Track: Software Development Fundamentals - Course: Software Dev Lifecycle
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (169, N'Agile and Scrum', 56), (170, N'Waterfall Model', 56), (171, N'Requirements, Design, Implementation, Testing', 56);

-- Department: System Development - Track: Software Testing - Course: Testing Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (172, N'Software Testing Lifecycle (STLC)', 57), (173, N'Types of Testing (Functional, Non-functional)', 57), (174, N'Test Cases and Test Scenarios', 57);
-- Department: System Development - Track: Software Testing - Course: Manual Testing
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (175, N'Test Case Design Techniques', 58), (176, N'Exploratory Testing', 58), (177, N'Bug Reporting and Tracking', 58);
-- Department: System Development - Track: Software Testing - Course: Test Automation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (178, N'Introduction to Selenium WebDriver', 59), (179, N'Page Object Model (POM)', 59), (180, N'Test Frameworks (TestNG/JUnit)', 59);
-- Department: System Development - Track: Software Testing - Course: API Testing
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (181, N'Introduction to APIs and Web Services', 60), (182, N'Testing with Postman', 60), (183, N'Automating API Tests', 60);
-- Department: System Development - Track: Software Testing - Course: Performance Testing
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (184, N'Introduction to JMeter', 61), (185, N'Load, Stress, and Soak Testing', 61), (186, N'Analyzing Performance Results', 61);
-- Department: System Development - Track: Software Testing - Course: Agile Testing
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (187, N'Testing in Scrum', 62), (188, N'Behavior-Driven Development (BDD)', 62), (189, N'Continuous Testing', 62);
-- Department: System Development - Track: Software Testing - Course: SQL for Testers
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (190, N'Database Validation', 63), (191, N'Writing SQL Queries for Testing', 63), (192, N'Data Integrity Testing', 63);

-- Department: System Development - Track: Renewable Energy - Course: Renewable Energy Intro
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (193, N'Types of Renewable Energy', 64), (194, N'Global Energy Landscape', 64), (195, N'Policy and Economics', 64);
-- Department: System Development - Track: Renewable Energy - Course: Solar PV Systems
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (196, N'Photovoltaic Principles', 65), (197, N'System Components (Panels, Inverters)', 65), (198, N'Grid-Tied vs. Off-Grid Systems', 65);
-- Department: System Development - Track: Renewable Energy - Course: Wind Energy
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (199, N'Wind Turbine Technology', 66), (200, N'Wind Resource Assessment', 66), (201, N'Wind Farm Design', 66);
-- Department: System Development - Track: Renewable Energy - Course: Energy Storage
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (202, N'Battery Technologies', 67), (203, N'Grid-Scale Storage', 67), (204, N'Pumped Hydro Storage', 67);
-- Department: System Development - Track: Renewable Energy - Course: Smart Grids
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (205, N'Smart Grid Architecture', 68), (206, N'Demand Side Management', 68), (207, N'Advanced Metering Infrastructure (AMI)', 68);
-- Department: System Development - Track: Renewable Energy - Course: Energy Modeling
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (208, N'Software for Energy Analysis (PVSyst, HOMER)', 69), (209, N'Financial Modeling for Projects', 69), (210, N'Forecasting and Simulation', 69);
-- Department: System Development - Track: Renewable Energy - Course: Project Management
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (211, N'Project Lifecycle in Renewable Energy', 70), (212, N'Site Selection and Permitting', 70), (213, N'Risk Management', 70);

-- Department: Java - Track: Full Stack Web Development Using .Net - Course: C# Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (214, N'Syntax, Types, and Control Flow', 71), (215, N'Object-Oriented Programming in C#', 71), (216, N'LINQ and Collections', 71);
-- Department: Java - Track: Full Stack Web Development Using .Net - Course: ASP.NET Core MVC
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (217, N'MVC Pattern', 72), (218, N'Routing and Controllers', 72), (219, N'Views and Razor Pages', 72);
-- Department: Java - Track: Full Stack Web Development Using .Net - Course: Entity Framework Core
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (220, N'Code-First and Database-First', 73), (221, N'Migrations', 73), (222, N'Querying with EF Core', 73);
-- Department: Java - Track: Full Stack Web Development Using .Net - Course: Web API with .NET
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (223, N'Building RESTful APIs', 74), (224, N'Authentication and Authorization', 74), (225, N'Swagger/OpenAPI', 74);
-- Department: Java - Track: Full Stack Web Development Using .Net - Course: SQL Server
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (226, N'Database Design', 75), (227, N'Stored Procedures and Functions', 75), (228, N'Indexing and Performance', 75);
-- Department: Java - Track: Full Stack Web Development Using .Net - Course: Angular
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (229, N'Components and Modules', 76), (230, N'Services and Dependency Injection', 76), (231, N'Routing in Angular', 76);
-- Department: Java - Track: Full Stack Web Development Using .Net - Course: Azure DevOps
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (232, N'Azure Repos (Git)', 77), (233, N'Azure Pipelines (CI/CD)', 77), (234, N'Deploying to Azure App Service', 77);

-- Department: Java - Track: Full Stack Web Development Using MERN - Course: JavaScript (Advanced)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (235, N'ES6+ and Asynchronous JS', 78), (236, N'Prototypes and Closures', 78), (237, N'Event Loop', 78);
-- Department: Java - Track: Full Stack Web Development Using MERN - Course: Node.js & Express
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (238, N'Building REST APIs with Express', 79), (239, N'Middleware', 79), (240, N'NPM and Module System', 79);
-- Department: Java - Track: Full Stack Web Development Using MERN - Course: MongoDB
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (241, N'NoSQL Concepts', 80), (242, N'CRUD Operations in MongoDB', 80), (243, N'Mongoose ODM', 80);
-- Department: Java - Track: Full Stack Web Development Using MERN - Course: React.js
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (244, N'React Components and Hooks', 81), (245, N'State Management (Redux/Context)', 81), (246, N'React Router', 81);
-- Department: Java - Track: Full Stack Web Development Using MERN - Course: Authentication & Security
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (247, N'JWT (JSON Web Tokens)', 82), (248, N'Password Hashing', 82), (249, N'CORS', 82);
-- Department: Java - Track: Full Stack Web Development Using MERN - Course: Testing MERN Stack
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (250, N'Unit Testing with Jest', 83), (251, N'API Testing with Postman/Supertest', 83), (252, N'React Testing Library', 83);
-- Department: Java - Track: Full Stack Web Development Using MERN - Course: Deployment
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (253, N'Deploying to Heroku', 84), (254, N'Dockerizing MERN Apps', 84), (255, N'Environment Variables', 84);

-- Department: Java - Track: Full Stack Web Development using Python - Course: Python for Web
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (256, N'Python Fundamentals Recap', 85), (257, N'Virtual Environments and Pip', 85), (258, N'Object-Oriented Programming in Python', 85);
-- Department: Java - Track: Full Stack Web Development using Python - Course: Django
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (259, N'Django MVT Architecture', 86), (260, N'Models and ORM', 86), (261, N'Django Admin', 86);
-- Department: Java - Track: Full Stack Web Development using Python - Course: Django REST Framework
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (262, N'Serializers', 87), (263, N'Building REST APIs', 87), (264, N'Authentication and Permissions', 87);
-- Department: Java - Track: Full Stack Web Development using Python - Course: Flask
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (265, N'Introduction to Microframeworks', 88), (266, N'Routing and Templates', 88), (267, N'Building a Simple API with Flask', 88);
-- Department: Java - Track: Full Stack Web Development using Python - Course: PostgreSQL
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (268, N'Relational Database Design', 89), (269, N'Advanced SQL', 89), (270, N'Connecting Python to PostgreSQL', 89);
-- Department: Java - Track: Full Stack Web Development using Python - Course: Frontend (Vue.js)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (271, N'Vue.js Fundamentals', 90), (272, N'Components and Props', 90), (273, N'Consuming APIs with Vue', 90);
-- Department: Java - Track: Full Stack Web Development using Python - Course: Deployment & DevOps
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (274, N'Gunicorn and Nginx', 91), (275, N'Dockerizing Django/Flask Apps', 91), (276, N'CI/CD for Python Web Apps', 91);

-- Department: Java - Track: Web Development Using CMS - Course: CMS Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (277, N'What is a CMS?', 92), (278, N'Hosted vs. Self-Hosted', 92), (279, N'Headless CMS vs. Traditional CMS', 92);
-- Department: Java - Track: Web Development Using CMS - Course: WordPress Development
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (280, N'Theme Development', 93), (281, N'Plugin Development', 93), (282, N'WordPress REST API', 93);
-- Department: Java - Track: Web Development Using CMS - Course: Shopify Development
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (283, N'Liquid Templating Language', 94), (284, N'Shopify Theme Customization', 94), (285, N'Shopify App Development', 94);
-- Department: Java - Track: Web Development Using CMS - Course: Webflow
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (286, N'Webflow Designer and CMS Collections', 95), (287, N'Animations and Interactions', 95), (288, N'Integrating Custom Code', 95);
-- Department: Java - Track: Web Development Using CMS - Course: Content Strategy
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (289, N'Information Architecture', 96), (290, N'Content Modeling', 96), (291, N'SEO for CMS', 96);
-- Department: Java - Track: Web Development Using CMS - Course: Site Optimization
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (292, N'Performance Optimization', 97), (293, N'Security Best Practices', 97), (294, N'Accessibility in CMS', 97);
-- Department: Java - Track: Web Development Using CMS - Course: Headless CMS (Strapi)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (295, N'Setting up Strapi', 98), (296, N'Creating Content Types', 98), (297, N'Consuming API with a Frontend Framework', 98);

-- Department: Java - Track: Full Stack Web Development using PHP - Course: PHP Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (298, N'Modern PHP Syntax (PHP 8+)', 99), (299, N'Object-Oriented PHP', 99), (300, N'Composer and Dependency Management', 99);
-- Department: Java - Track: Full Stack Web Development using PHP - Course: Laravel
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (301, N'MVC in Laravel', 100), (302, N'Eloquent ORM', 100), (303, N'Blade Templating', 100);
-- Department: Java - Track: Full Stack Web Development using PHP - Course: Building APIs with Laravel
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (304, N'Building RESTful APIs', 101), (305, N'API Resources', 101), (306, N'Laravel Sanctum/Passport for Authentication', 101);
-- Department: Java - Track: Full Stack Web Development using PHP - Course: MySQL
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (307, N'Database Design and Normalization', 102), (308, N'Advanced SQL Queries', 102), (309, N'Indexing for Performance', 102);
-- Department: Java - Track: Full Stack Web Development using PHP - Course: Vue.js for PHP Devs
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (310, N'Vue.js Basics', 103), (311, N'Integrating Vue with Laravel', 103), (312, N'Building Single Page Applications (SPAs)', 103);
-- Department: Java - Track: Full Stack Web Development using PHP - Course: Testing in Laravel
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (313, N'Unit Testing with PHPUnit', 104), (314, N'Feature Testing', 104), (315, N'Mocking and Fakes', 104);
-- Department: Java - Track: Full Stack Web Development using PHP - Course: Deployment
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (316, N'Server Configuration (Nginx/Apache)', 105), (317, N'Deploying with Laravel Forge/Envoyer', 105), (318, N'CI/CD for Laravel', 105);

-- Department: Multimedia - Track: 2D Graphics Design - Course: Design Principles
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (319, N'Composition and Layout', 106), (320, N'Color Theory', 106), (321, N'Typography', 106);
-- Department: Multimedia - Track: 2D Graphics Design - Course: Adobe Photoshop
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (322, N'Layers and Masks', 107), (323, N'Photo Retouching and Compositing', 107), (324, N'Working with Smart Objects', 107);
-- Department: Multimedia - Track: 2D Graphics Design - Course: Adobe Illustrator
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (325, N'Vector Graphics Fundamentals', 108), (326, N'Pen Tool and Shape Builders', 108), (327, N'Logo Design and Illustration', 108);
-- Department: Multimedia - Track: 2D Graphics Design - Course: Adobe InDesign
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (328, N'Layout for Print and Digital', 109), (329, N'Master Pages and Styles', 109), (330, N'Working with Text and Images', 109);
-- Department: Multimedia - Track: 2D Graphics Design - Course: Branding & Identity
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (331, N'Creating a Brand Style Guide', 110), (332, N'Logo Design Process', 110), (333, N'Applying Branding Across Media', 110);
-- Department: Multimedia - Track: 2D Graphics Design - Course: UI/UX for Graphics
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (334, N'Designing for Web and Mobile', 111), (335, N'Wireframing and Prototyping (Figma/XD)', 111), (336, N'Iconography', 111);
-- Department: Multimedia - Track: 2D Graphics Design - Course: Portfolio Development
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (337, N'Selecting and Refining Projects', 112), (338, N'Creating a Professional Portfolio', 112), (339, N'Presenting Your Work', 112);

-- Department: Multimedia - Track: 3D Modeling - Course: 3D Modeling Intro
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (340, N'3D Software Interface (Blender/Maya)', 113), (341, N'Polygon Modeling Fundamentals', 113), (342, N'3D Pipeline Overview', 113);
-- Department: Multimedia - Track: 3D Modeling - Course: Hard Surface Modeling
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (343, N'Modeling Props and Vehicles', 114), (344, N'Topology for Hard Surfaces', 114), (345, N'Bevels and Support Edges', 114);
-- Department: Multimedia - Track: 3D Modeling - Course: Organic Modeling
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (346, N'Digital Sculpting (ZBrush/Blender)', 115), (347, N'Character and Creature Anatomy', 115), (348, N'Retopology for Animation', 115);
-- Department: Multimedia - Track: 3D Modeling - Course: UV Unwrapping
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (349, N'UV Mapping Principles', 116), (350, N'Optimizing UV Layouts', 116), (351, N'UDIMs', 116);
-- Department: Multimedia - Track: 3D Modeling - Course: Texturing & Materials
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (352, N'PBR (Physically Based Rendering) Workflow', 117), (353, N'Texturing in Substance Painter', 117), (354, N'Procedural vs. Hand-Painted Textures', 117);
-- Department: Multimedia - Track: 3D Modeling - Course: Lighting & Rendering
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (355, N'Three-Point Lighting', 118), (356, N'Rendering Engines (Cycles/Arnold)', 118), (357, N'Composition and Camera Angles', 118);
-- Department: Multimedia - Track: 3D Modeling - Course: Portfolio & Presentation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (358, N'Creating Turntables and Renders', 119), (359, N'Presenting Models on ArtStation/Sketchfab', 119), (360, N'Building a 3D Modeling Portfolio', 119);

-- Department: Multimedia - Track: Motion Graphics - Course: Motion Design Principles
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (361, N'12 Principles of Animation in Motion Graphics', 120), (362, N'Timing and Spacing', 120), (363, N'Visual Storytelling', 120);
-- Department: Multimedia - Track: Motion Graphics - Course: Adobe After Effects
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (364, N'Keyframe Animation', 121), (365, N'Shape Layers and Vector Animation', 121), (366, N'Expressions Basics', 121);
-- Department: Multimedia - Track: Motion Graphics - Course: Kinetic Typography
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (367, N'Animating Text', 122), (368, N'Typography in Motion', 122), (369, N'Text Animators', 122);
-- Department: Multimedia - Track: Motion Graphics - Course: 2D Character Animation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (370, N'Character Rigging (Puppet Tool/Duik)', 123), (371, N'Walk Cycles', 123), (372, N'Lip Syncing', 123);
-- Department: Multimedia - Track: Motion Graphics - Course: 3D in After Effects
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (373, N'Working with 3D Layers and Cameras', 124), (374, N'Cinema 4D Lite Integration', 124), (375, N'3D Tracking and Compositing', 124);
-- Department: Multimedia - Track: Motion Graphics - Course: Visual Effects (VFX)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (376, N'Motion Tracking and Rotoscoping', 125), (377, N'Particle Systems', 125), (378, N'Color Correction and Grading', 125);
-- Department: Multimedia - Track: Motion Graphics - Course: Sound Design & Export
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (379, N'Audio in After Effects', 126), (380, N'Sound Design for Motion', 126), (381, N'Exporting for Web and Broadcast (Media Encoder)', 126);

-- Department: Multimedia - Track: Concept Art - Course: Digital Painting Intro
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (382, N'Photoshop for Digital Painting', 127), (383, N'Brushes and Blending', 127), (384, N'Value, Color, and Light', 127);
-- Department: Multimedia - Track: Concept Art - Course: Drawing Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (385, N'Perspective Drawing', 128), (386, N'Anatomy and Figure Drawing', 128), (387, N'Composition and Thumbnailing', 128);
-- Department: Multimedia - Track: Concept Art - Course: Character Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (388, N'Storytelling through Design', 129), (389, N'Silhouette and Shape Language', 129), (390, N'Costume and Prop Design', 129);
-- Department: Multimedia - Track: Concept Art - Course: Environment Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (391, N'World Building', 130), (392, N'Architectural and Natural Environments', 130), (393, N'Matte Painting Techniques', 130);
-- Department: Multimedia - Track: Concept Art - Course: Creature Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (394, N'Animal Anatomy', 131), (395, N'Designing Believable Creatures', 131), (396, N'Rendering Different Materials (Scales, Fur)', 131);
-- Department: Multimedia - Track: Concept Art - Course: Prop & Vehicle Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (397, N'Industrial Design Principles', 132), (398, N'Function and Form', 132), (399, N'Rendering Hard Surface Materials', 132);
-- Department: Multimedia - Track: Concept Art - Course: Industry Portfolio
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (400, N'Creating a Professional Concept Art Portfolio', 133), (401, N'Presenting Work for Games and Film', 133), (402, N'Art Tests and Client Briefs', 133);

-- Department: Multimedia - Track: UI/UX Design - Course: UI/UX Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (403, N'Difference between UI and UX', 134), (404, N'The Design Thinking Process', 134), (405, N'User-Centered Design', 134);
-- Department: Multimedia - Track: UI/UX Design - Course: User Research
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (406, N'User Interviews and Surveys', 135), (407, N'Personas and User Journey Maps', 135), (408, N'Competitive Analysis', 135);
-- Department: Multimedia - Track: UI/UX Design - Course: Information Architecture
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (409, N'Sitemaps and User Flows', 136), (410, N'Card Sorting', 136), (411, N'Navigation Design', 136);
-- Department: Multimedia - Track: UI/UX Design - Course: Wireframing & Prototyping
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (412, N'Low-Fidelity and High-Fidelity Wireframes', 137), (413, N'Interactive Prototyping in Figma/Adobe XD', 137), (414, N'Microinteractions', 137);
-- Department: Multimedia - Track: UI/UX Design - Course: Visual Design (UI)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (415, N'Design Systems and Component Libraries', 138), (416, N'Typography and Color for UI', 138), (417, N'Layout and Grids', 138);
-- Department: Multimedia - Track: UI/UX Design - Course: Usability Testing
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (418, N'Planning and Conducting Usability Tests', 139), (419, N'Analyzing Feedback', 139), (420, N'Iterating on Designs', 139);
-- Department: Multimedia - Track: UI/UX Design - Course: Handoff & Portfolio
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (421, N'Developer Handoff', 140), (422, N'Creating UX Case Studies', 140), (423, N'Building a UI/UX Portfolio', 140);

-- Department: Unix - Track: Systems Administration - Course: Linux Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (424, N'Linux Command Line', 141), (425, N'File System Hierarchy', 141), (426, N'User and Group Management', 141);
-- Department: Unix - Track: Systems Administration - Course: Bash Scripting
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (427, N'Shell Scripting Basics', 142), (428, N'Automating Tasks with Cron', 142), (429, N'Loops, Conditionals, and Functions in Bash', 142);
-- Department: Unix - Track: Systems Administration - Course: Network Administration
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (430, N'TCP/IP Networking', 143), (431, N'DNS and DHCP Configuration', 143), (432, N'Firewall Management (iptables/firewalld)', 143);
-- Department: Unix - Track: Systems Administration - Course: Server Management
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (433, N'Web Server (Apache/Nginx)', 144), (434, N'Database Server (MySQL/PostgreSQL)', 144), (435, N'File Server (Samba/NFS)', 144);
-- Department: Unix - Track: Systems Administration - Course: System Monitoring
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (436, N'Monitoring System Performance (CPU, Memory, Disk)', 145), (437, N'Log Management and Analysis', 145), (438, N'Monitoring Tools (Nagios/Zabbix)', 145);
-- Department: Unix - Track: Systems Administration - Course: Security Hardening
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (439, N'Securing SSH', 146), (440, N'File Permissions and Access Control', 146), (441, N'Intrusion Detection Systems', 146);
-- Department: Unix - Track: Systems Administration - Course: Virtualization & Cloud
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (442, N'Introduction to Virtualization (KVM/VirtualBox)', 147), (443, N'Managing Linux VMs in the Cloud (AWS/Azure)', 147), (444, N'Introduction to Containers (Docker)', 147);

-- Department: Network - Track: Cybersecurity Associate - Course: Networking Concepts
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (445, N'OSI and TCP/IP Models', 148), (446, N'Switching and Routing', 148), (447, N'Common Network Protocols', 148);
-- Department: Network - Track: Cybersecurity Associate - Course: Security Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (448, N'CIA Triad (Confidentiality, Integrity, Availability)', 149), (449, N'Threats, Vulnerabilities, and Risks', 149), (450, N'Security Policies', 149);
-- Department: Network - Track: Cybersecurity Associate - Course: Network Security
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (451, N'Firewalls and VPNs', 150), (452, N'Intrusion Detection/Prevention Systems (IDS/IPS)', 150), (453, N'Network Access Control (NAC)', 150);
-- Department: Network - Track: Cybersecurity Associate - Course: Threat Analysis
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (454, N'Malware Analysis', 151), (455, N'Social Engineering', 151), (456, N'Cyber Kill Chain', 151);
-- Department: Network - Track: Cybersecurity Associate - Course: Cryptography
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (457, N'Symmetric vs. Asymmetric Encryption', 152), (458, N'Hashing', 152), (459, N'Public Key Infrastructure (PKI)', 152);
-- Department: Network - Track: Cybersecurity Associate - Course: Security Operations (SOC)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (460, N'Security Information and Event Management (SIEM)', 153), (461, N'Incident Response', 153), (462, N'Log Analysis', 153);
-- Department: Network - Track: Cybersecurity Associate - Course: Ethical Hacking
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (463, N'Penetration Testing Phases', 154), (464, N'Vulnerability Scanning', 154), (465, N'Common Hacking Tools (Metasploit, Nmap)', 154);

-- Department: E-Business - Track: Data Visualization - Course: Data Viz Principles
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (466, N'Visual Perception and Cognition', 155), (467, N'Choosing the Right Chart Type', 155), (468, N'Data Storytelling', 155);
-- Department: E-Business - Track: Data Visualization - Course: Tableau
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (469, N'Connecting to Data in Tableau', 156), (470, N'Building Dashboards and Stories', 156), (471, N'Calculated Fields and LOD Expressions', 156);
-- Department: E-Business - Track: Data Visualization - Course: Power BI
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (472, N'Power Query for Data Transformation', 157), (473, N'DAX for Measures', 157), (474, N'Building Interactive Reports', 157);
-- Department: E-Business - Track: Data Visualization - Course: Data Prep for Viz
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (475, N'Data Cleaning and Transformation', 158), (476, N'Data Shaping and Structuring', 158), (477, N'Using SQL for Data Prep', 158);
-- Department: E-Business - Track: Data Visualization - Course: Dashboard Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (478, N'Layout and Composition', 159), (479, N'Color Theory for Dashboards', 159), (480, N'UI/UX for Dashboards', 159);
-- Department: E-Business - Track: Data Visualization - Course: Advanced Visualization
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (481, N'Geospatial Analysis', 160), (482, N'Advanced Chart Types (Sankey, Sunburst)', 160), (483, N'Statistical Visualization', 160);
-- Department: E-Business - Track: Data Visualization - Course: D3.js
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (484, N'Introduction to D3.js', 161), (485, N'Data Binding and Selections', 161), (486, N'Creating Custom Visualizations', 161);

-- Department: E-Business - Track: Salesforce Specialist - Course: Salesforce Admin
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (487, N'Salesforce Platform Basics', 162), (488, N'User Management and Security', 162), (489, N'Data Modeling (Objects, Fields, Relationships)', 162);
-- Department: E-Business - Track: Salesforce Specialist - Course: Automation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (490, N'Process Builder and Workflow Rules', 163), (491, N'Flow Builder', 163), (492, N'Approval Processes', 163);
-- Department: E-Business - Track: Salesforce Specialist - Course: Sales Cloud
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (493, N'Lead and Opportunity Management', 164), (494, N'Campaigns and Products', 164), (495, N'Sales Analytics', 164);
-- Department: E-Business - Track: Salesforce Specialist - Course: Service Cloud
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (496, N'Case Management', 165), (497, N'Knowledge Base', 165), (498, N'Service Console and Omni-Channel', 165);
-- Department: E-Business - Track: Salesforce Specialist - Course: App Builder
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (499, N'Lightning App Builder', 166), (500, N'Customizing UI', 166), (501, N'Mobile App Customization', 166);
-- Department: E-Business - Track: Salesforce Specialist - Course: Apex Programming
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (502, N'Apex Basics', 167), (503, N'Triggers and Classes', 167), (504, N'SOQL and SOSL', 167);
-- Department: E-Business - Track: Salesforce Specialist - Course: Lightning Web Components
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (505, N'LWC Fundamentals', 168), (506, N'Data Binding and Events', 168), (507, N'Calling Apex from LWC', 168);

-- Department: E-Business - Track: Business Analysis - Course: Business Analysis Intro
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (508, N'Role of the Business Analyst', 169), (509, N'Business Analysis Body of Knowledge (BABOK)', 169), (510, N'SDLC and the BA', 169);
-- Department: E-Business - Track: Business Analysis - Course: Requirements Elicitation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (511, N'Stakeholder Analysis', 170), (512, N'Interviewing and Workshops', 170), (513, N'Observation and Document Analysis', 170);
-- Department: E-Business - Track: Business Analysis - Course: Requirements Analysis
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (514, N'Functional vs. Non-functional Requirements', 171), (515, N'Process Modeling (BPMN)', 171), (516, N'Use Cases and User Stories', 171);
-- Department: E-Business - Track: Business Analysis - Course: Documentation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (517, N'Business Requirements Document (BRD)', 172), (518, N'Functional Requirements Specification (FRS)', 172), (519, N'Traceability Matrix', 172);
-- Department: E-Business - Track: Business Analysis - Course: Agile for BAs
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (520, N'BA Role in Scrum', 173), (521, N'Writing Effective User Stories', 173), (522, N'Backlog Grooming and Prioritization', 173);
-- Department: E-Business - Track: Business Analysis - Course: Solution Validation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (523, N'User Acceptance Testing (UAT)', 174), (524, N'Validating Solutions Against Business Needs', 174), (525, N'Post-Implementation Review', 174);
-- Department: E-Business - Track: Business Analysis - Course: BA Tools
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (526, N'Jira and Confluence', 175), (527, N'Modeling Tools (Visio, Lucidchart)', 175), (528, N'Prototyping Tools', 175);

-- Department: E-Business - Track: Business Analysis and Intelligent Automation Development - Course: Business Process Mgmt
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (529, N'Business Process Modeling Notation (BPMN)', 176), (530, N'As-Is and To-Be Process Mapping', 176), (531, N'Process Improvement Methodologies', 176);
-- Department: E-Business - Track: Business Analysis and Intelligent Automation Development - Course: RPA Fundamentals
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (532, N'Introduction to Robotic Process Automation (RPA)', 177), (533, N'Identifying Automation Opportunities', 177), (534, N'RPA Lifecycle', 177);
-- Department: E-Business - Track: Business Analysis and Intelligent Automation Development - Course: UiPath Development
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (535, N'UiPath Studio Basics', 178), (536, N'Selectors and UI Automation', 178), (537, N'Orchestrator and Bots', 178);
-- Department: E-Business - Track: Business Analysis and Intelligent Automation Development - Course: Intelligent Automation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (538, N'Introduction to AI and Machine Learning in Automation', 179), (539, N'Optical Character Recognition (OCR)', 179), (540, N'Chatbots and NLP', 179);
-- Department: E-Business - Track: Business Analysis and Intelligent Automation Development - Course: Solution Design
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (541, N'Process Design Document (PDD)', 180), (542, N'Solution Design Document (SDD)', 180), (543, N'Exception Handling and Logging', 180);
-- Department: E-Business - Track: Business Analysis and Intelligent Automation Development - Course: Testing & Deployment
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (544, N'Testing RPA Solutions', 181), (545, N'Deployment Strategies', 181), (546, N'Monitoring and Maintaining Bots', 181);
-- Department: E-Business - Track: Business Analysis and Intelligent Automation Development - Course: Governance & CoE
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (547, N'RPA Governance Models', 182), (548, N'Building a Center of Excellence (CoE)', 182), (549, N'Measuring ROI of Automation', 182);

-- Department: E-Business - Track: Social Media Marketing - Course: Social Media Strategy
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (550, N'Setting Goals and KPIs', 183), (551, N'Audience Persona Development', 183), (552, N'Content Calendars', 183);
-- Department: E-Business - Track: Social Media Marketing - Course: Content Creation
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (553, N'Copywriting for Social Media', 184), (554, N'Basic Graphic Design for Posts', 184), (555, N'Video Content Fundamentals', 184);
-- Department: E-Business - Track: Social Media Marketing - Course: Platform Management
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (556, N'Facebook & Instagram for Business', 185), (557, N'LinkedIn & B2B Marketing', 185), (558, N'Twitter & Real-time Engagement', 185);
-- Department: E-Business - Track: Social Media Marketing - Course: Paid Social Advertising
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (559, N'Facebook Ads Manager', 186), (560, N'Campaign Objectives and Budgeting', 186), (561, N'Ad Targeting and Optimization', 186);
-- Department: E-Business - Track: Social Media Marketing - Course: Community Management
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (562, N'Engagement Strategies', 187), (563, N'Handling Negative Feedback', 187), (564, N'Building Brand Advocates', 187);
-- Department: E-Business - Track: Social Media Marketing - Course: Analytics & Reporting
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (565, N'Understanding Platform Insights', 188), (566, N'UTM Tracking', 188), (567, N'Creating Performance Reports', 188);
-- Department: E-Business - Track: Social Media Marketing - Course: Influencer Marketing
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (568, N'Identifying and Vetting Influencers', 189), (569, N'Campaign Negotiation and Briefing', 189), (570, N'Measuring ROI of Influencer Campaigns', 189);

--  Insert Topics for the new 'Soft Skills' courses
-- Course: Communication Skills (190)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (571, N'Verbal Communication', 190), (572, N'Non-verbal Cues', 190), (573, N'Active Listening', 190);
-- Course: Presentation Skills (191)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (574, N'Structuring a Presentation', 191), (575, N'Public Speaking Techniques', 191), (576, N'Visual Aid Design', 191);
-- Course: Ethics (192)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (577, N'Workplace Ethics', 192), (578, N'Data Privacy', 192), (579, N'Professional Conduct', 192);
-- Course: CV Writing (193)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (580, N'CV vs. Resume', 193), (581, N'Tailoring Your CV', 193), (582, N'Cover Letter Writing', 193);
-- Course: Freelancing (194)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES (583, N'Finding Clients', 194), (584, N'Pricing and Contracts', 194), (585, N'Managing Freelance Finances', 194);


-- =================================================================
-- START: Add 10 new topics for each 'Soft Skills' course
-- =================================================================

-- Course: Communication Skills (190)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES
(586, N'Written Communication (Emails, Reports)', 190),
(587, N'Giving and Receiving Feedback', 190),
(588, N'Interpersonal Skills', 190),
(589, N'Conflict Resolution Strategies', 190),
(590, N'Negotiation Basics', 190),
(591, N'Cross-Cultural Communication', 190),
(592, N'Meeting Facilitation', 190),
(593, N'Business Storytelling', 190),
(594, N'Networking Skills', 190),
(595, N'Virtual Communication Etiquette (Zoom/Teams)', 190);

-- Course: Presentation Skills (191)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES
(596, N'Audience Analysis', 191),
(597, N'Managing Presentation Anxiety', 191),
(598, N'Vocal Variety and Pacing', 191),
(599, N'Body Language and Stage Presence', 191),
(600, N'Handling Q&A Sessions', 191),
(601, N'Crafting a Compelling Narrative', 191),
(602, N'Technical Presentations', 191),
(603, N'Impromptu Speaking', 191),
(604, N'Delivering Virtual Presentations', 191),
(605, N'Using Visuals Effectively', 191);

-- Course: Ethics (192)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES
(606, N'Intellectual Property and Copyright', 192),
(607, N'Code of Conduct', 192),
(608, N'Ethical Decision-Making Frameworks', 192),
(609, N'Whistleblowing', 192),
(610, N'Corporate Social Responsibility (CSR)', 192),
(611, N'Unconscious Bias', 192),
(612, N'AI and Algorithmic Ethics', 192),
(613, N'Client and Stakeholder Confidentiality', 192),
(614, N'Honesty and Integrity', 192),
(615, N'Readability and Accountability', 192);

-- Course: CV Writing (193)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES
(616, N'Understanding Job Descriptions', 193),
(617, N'Formatting and Layout', 193),
(618, N'Writing a Professional Summary', 193),
(619, N'Detailing Work Experience (STAR Method)', 193),
(620, N'Highlighting Skills and Qualifications', 193),
(621, N'Education and Certifications', 193),
(622, N'Projects and Portfolio Section', 193),
(623, N'Applicant Tracking Systems (ATS) Optimization', 193),
(624, N'Proofreading and Editing', 193),
(625, N'LinkedIn Profile Optimization', 193);

-- Course: Freelancing (194)
INSERT INTO Topic (Topic_ID, Topic_Name, Course_ID) VALUES
(626, N'Identifying Your Niche', 194),
(627, N'Building a Freelance Portfolio', 194),
(628, N'Using Freelance Platforms (Khamsat, Upwork, etc.)', 194),
(629, N'Marketing Your Services', 194),
(630, N'Writing Effective Proposals', 194),
(631, N'Client Communication and Management', 194),
(632, N'Time Management and Productivity', 194),
(633, N'Invoicing and Getting Paid', 194),
(634, N'Legal Aspects and Contracts', 194),
(635, N'Scaling Your Freelance Business', 194);

-- =================================================================
-- END: Topic insertion for 'Soft Skills' courses
-- =================================================================
-- ================ ================ ================ ================ ================ ================ ================ ================ ================
-- Question_Bank of the Courses Data
-- ================ ================ ================ ================ ================ ================ ================ ================ ================

--Track 1 Power BI Question   ================ ================ ================ ================ ================ ================

-- Department: System Development - Track: Power BI Development - Course: Intro to Data Analytics & Power BI
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1, 1, N'MCQ', N'What is the primary Power BI tool for authoring reports?', N'Power BI Desktop'), (2, 1, N'True/False', N'Power BI Service is mainly used for creating data models.', N'False'), (3, 1, N'MCQ', N'Which pane in Power BI Desktop is used to manage data fields?', N'Fields pane'), (4, 1, N'True/False', N'You can only connect to one data source per Power BI report.', N'False'), (5, 1, N'MCQ', N'What does ETL stand for in the context of data analytics?', N'Extract, Transform, Load'), (6, 1, N'MCQ', N'Which view is used to create relationships between tables?', N'Model View'), (7, 1, N'True/False', N'A bar chart is best used for showing trends over time.', N'False'), (8, 1, N'MCQ', N'What is a "measure" in Power BI?', N'A calculation created with DAX'), (9, 1, N'True/False', N'All data transformations are performed in the Report View.', N'False'), (10, 1, N'MCQ', N'Which feature allows you to clean and shape your data?', N'Power Query Editor'), (11, 1, N'True/False', N'Dashboards and reports are the same thing in Power BI Service.', N'False'), (12, 1, N'MCQ', N'What is the function of a slicer in a Power BI report?', N'To filter data in visuals'), (13, 1, N'True/False', N'Power BI is exclusively a desktop application.', N'False'), (14, 1, N'MCQ', N'Which file extension does a Power BI Desktop file have?', N'.pbix'), (15, 1, N'MCQ', N'What is the purpose of the "Get Data" button?', N'To connect to a new data source');
-- Department: System Development - Track: Power BI Development - Course: Data Modeling & Power Query
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (16, 2, N'MCQ', N'What is a star schema?', N'A model with a central fact table and multiple dimension tables'), (17, 2, N'True/False', N'Power Query uses the Python language for transformations.', N'False'), (18, 2, N'MCQ', N'Which Power Query feature is used to combine rows from two or more tables?', N'Append Queries'), (19, 2, N'True/False', N'A primary key in a table must contain unique values.', N'True'), (20, 2, N'MCQ', N'What is the purpose of "cardinality" in a relationship?', N'It defines how tables are related (one-to-one, one-to-many)'), (21, 2, N'MCQ', N'Which transformation allows you to pivot columns into rows?', N'Unpivot Columns'), (22, 2, N'True/False', N'You should always model your data in a single, flat table for best performance.', N'False'), (23, 2, N'MCQ', N'What is the M language used for?', N'To record data transformation steps in Power Query'), (24, 2, N'True/False', N'A "fact table" typically contains descriptive attributes.', N'False'), (25, 2, N'MCQ', N'Which join kind in "Merge Queries" includes all rows from the first table and matching from the second?', N'Left Outer'), (26, 2, N'True/False', N'Data types for columns cannot be changed in Power Query.', N'False'), (27, 2, N'MCQ', N'What is a "dimension table"?', N'A table that contains descriptive attributes'), (28, 2, N'True/False', N'Creating a date table is a common data modeling best practice.', N'True'), (29, 2, N'MCQ', N'What does the "Group By" feature do?', N'Summarizes rows of data into a single summary row'), (30, 2, N'MCQ', N'What is data profiling in Power Query?', N'A feature to understand column quality, distribution, and profile');
-- Department: System Development - Track: Power BI Development - Course: DAX Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (31, 3, N'MCQ', N'What does DAX stand for?', N'Data Analysis Expressions'), (32, 3, N'True/False', N'DAX is primarily used for creating visuals.', N'False'), (33, 3, N'MCQ', N'What is the difference between a calculated column and a measure?', N'A column is row-by-row, a measure is an aggregation'), (34, 3, N'True/False', N'The SUMX function iterates through a table to perform a calculation.', N'True'), (35, 3, N'MCQ', N'Which DAX function is used to modify the filter context?', N'CALCULATE'), (36, 3, N'MCQ', N'What does the RELATED function do?', N'Retrieves a value from the "one" side of a relationship'), (37, 3, N'True/False', N'DAX formulas are case-sensitive.', N'False'), (38, 3, N'MCQ', N'Which function would you use to count the number of distinct values in a column?', N'DISTINCTCOUNT'), (39, 3, N'True/False', N'A measure is physically stored in your data model.', N'False'), (40, 3, N'MCQ', N'What is "filter context"?', N'The set of active filters applied to a calculation'), (41, 3, N'True/False', N'The DIVIDE function is preferred over the / operator because it handles division by zero.', N'True'), (42, 3, N'MCQ', N'What is the purpose of time intelligence functions?', N'To perform calculations over date ranges'), (43, 3, N'True/False', N'Variables can be used in DAX formulas using the VAR keyword.', N'True'), (44, 3, N'MCQ', N'Which function returns a table?', N'FILTER'), (45, 3, N'MCQ', N'What is the most common aggregation function in DAX?', N'SUM');
-- Department: System Development - Track: Power BI Development - Course: Data Visualization & Design
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (46, 4, N'MCQ', N'Which chart is best for comparing values across categories?', N'Bar Chart'), (47, 4, N'True/False', N'A pie chart is ideal for showing data with many categories.', N'False'), (48, 4, N'MCQ', N'What is the purpose of a tooltip?', N'To show additional details when hovering over a data point'), (49, 4, N'True/False', N'Using too many colors in a report can make it difficult to read.', N'True'), (50, 4, N'MCQ', N'Which visual is best for displaying trends over time?', N'Line Chart'), (51, 4, N'MCQ', N'What is a key principle of good dashboard design?', N'Placing the most important information in the top-left'), (52, 4, N'True/False', N'Data labels should be enabled on every single visual.', N'False'), (53, 4, N'MCQ', N'What is a "slicer" used for?', N'Filtering the report page'), (54, 4, N'True/False', N'A matrix visual is similar to a pivot table.', N'True'), (55, 4, N'MCQ', N'What does the term "data storytelling" refer to?', N'Guiding a user through data with a clear narrative'), (56, 4, N'True/False', N'Using a dark background is always the best choice for a report.', N'False'), (57, 4, N'MCQ', N'Which feature allows you to create different views of a report page?', N'Bookmarks'), (58, 4, N'True/False', N'A scatter plot is used to show the relationship between two numerical variables.', N'True'), (59, 4, N'MCQ', N'What is a "card" visual used for?', N'Displaying a single, important number'), (60, 4, N'MCQ', N'What is the purpose of aligning visuals on a report page?', N'To create a clean and organized look');
-- Department: System Development - Track: Power BI Development - Course: Power BI Service & Admin
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (61, 5, N'MCQ', N'Where do you publish Power BI reports to share them?', N'Power BI Service'), (62, 5, N'True/False', N'A "Workspace" is a personal space that cannot be shared.', N'False'), (63, 5, N'MCQ', N'What is the purpose of a Power BI Gateway?', N'To refresh on-premises data'), (64, 5, N'True/False', N'A dashboard is an interactive, multi-page canvas for deep analysis.', N'False'), (65, 5, N'MCQ', N'Which role in a workspace has the highest level of permissions?', N'Admin'), (66, 5, N'MCQ', N'What is a Power BI "App"?', N'A packaged collection of dashboards and reports for distribution'), (67, 5, N'True/False', N'Scheduled refresh can be configured in Power BI Desktop.', N'False'), (68, 5, N'MCQ', N'What feature allows users to receive email updates of a report page?', N'Subscriptions'), (69, 5, N'True/False', N'Row-Level Security (RLS) restricts data access for different users.', N'True'), (70, 5, N'MCQ', N'What is the function of the "Usage metrics" report?', N'To monitor how content is being used'), (71, 5, N'True/False', N'Power BI Pro and Premium licenses are the same.', N'False'), (72, 5, N'MCQ', N'What is a "dataflow" in Power BI?', N'A self-service, reusable ETL process in the Power BI Service'), (73, 5, N'True/False', N'You can create and edit reports directly in the Power BI Service.', N'True'), (74, 5, N'MCQ', N'What is the purpose of "Featured" dashboards?', N'To make a specific dashboard the default landing page'), (75, 5, N'MCQ', N'Which setting controls who can share content with external users?', N'Tenant settings in the Admin portal');
-- Department: System Development - Track: Power BI Development - Course: SQL for Analysts
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (76, 6, N'MCQ', N'What does SQL stand for?', N'Structured Query Language'), (77, 6, N'True/False', N'The SELECT statement is used to delete data from a table.', N'False'), (78, 6, N'MCQ', N'Which clause is used to filter query results?', N'WHERE'), (79, 6, N'True/False', N'A FOREIGN KEY uniquely identifies each record in a table.', N'False'), (80, 6, N'MCQ', N'Which JOIN returns only the matching rows from both tables?', N'INNER JOIN'), (81, 6, N'MCQ', N'Which aggregate function returns the total number of rows?', N'COUNT()'), (82, 6, N'True/False', N'The ORDER BY clause sorts the results in ascending order by default.', N'True'), (83, 6, N'MCQ', N'Which clause is used with aggregate functions to group rows?', N'GROUP BY'), (84, 6, N'True/False', N'The statement `DELETE FROM Customers;` will delete the `Customers` table.', N'False'), (85, 6, N'MCQ', N'Which operator is used for pattern matching in a string?', N'LIKE'), (86, 6, N'True/False', N'`SELECT DISTINCT` is used to return only different values.', N'True'), (87, 6, N'MCQ', N'What is a primary key?', N'A unique identifier for each record in a table'), (88, 6, N'True/False', N'A NULL value is the same as a zero or a blank space.', N'False'), (89, 6, N'MCQ', N'Which JOIN returns all rows from the left table and matched rows from the right?', N'LEFT JOIN'), (90, 6, N'MCQ', N'What command is used to add new data into a database?', N'INSERT INTO');
-- Department: System Development - Track: Power BI Development - Course: Power BI Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (91, 7, N'MCQ', N'What is the first step in a typical data analytics project?', N'Defining the business requirements'), (92, 7, N'True/False', N'Data cleaning is usually not necessary if the data comes from a database.', N'False'), (93, 7, N'MCQ', N'What is the purpose of creating a project plan?', N'To outline tasks, timelines, and deliverables'), (94, 7, N'True/False', N'A good capstone project focuses only on creating complex visuals.', N'False'), (95, 7, N'MCQ', N'What does "stakeholder management" involve?', N'Communicating with and managing expectations of interested parties'), (96, 7, N'MCQ', N'Why is it important to document your data model?', N'For clarity and future maintenance'), (97, 7, N'True/False', N'The final presentation should focus on the technical DAX formulas used.', N'False'), (98, 7, N'MCQ', N'What is a key component of a project portfolio?', N'A collection of your best work demonstrating your skills'), (99, 7, N'True/False', N'User Acceptance Testing (UAT) involves getting feedback from end-users.', N'True'), (100, 7, N'MCQ', N'What is a "data dictionary"?', N'A document providing metadata about the data'), (101, 7, N'True/False', N'The project is complete as soon as the report is published.', N'False'), (102, 7, N'MCQ', N'What is the primary goal of the final report presentation?', N'To communicate insights and answer the business question'), (103, 7, N'True/False', N'You should use every type of visual available in your final report.', N'False'), (104, 7, N'MCQ', N'What is an "executive summary" in a report?', N'A brief overview of the key findings'), (105, 7, N'MCQ', N'Why is an iterative approach often used in analytics projects?', N'It allows for flexibility and incorporating feedback');


-- Department: System Development - Track: Power BI Development - Course: Intro to Data Analytics & Power BI
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1, 1, N'Power BI Desktop'), (2, 1, N'Power BI Service'), (3, 1, N'Excel'), (4, 3, N'Fields pane'), (5, 3, N'Visualizations pane'), (6, 3, N'Filters pane'), (7, 5, N'Execute, Test, Launch'), (8, 5, N'Extract, Transform, Load'), (9, 5, N'Enter, Transfer, Leave'), (10, 6, N'Report View'), (11, 6, N'Data View'), (12, 6, N'Model View'), (13, 8, N'A visual element'), (14, 8, N'A calculation created with DAX'), (15, 8, N'A table of data'), (16, 10, N'Power Query Editor'), (17, 10, N'DAX Formula Bar'), (18, 10, N'Report Canvas'), (19, 12, N'To add text to a report'), (20, 12, N'To filter data in visuals'), (21, 12, N'To create a new page'), (22, 14, N'.pbix'), (23, 14, N'.xlsx'), (24, 14, N'.docx'), (25, 15, N'To format visuals'), (26, 15, N'To publish a report'), (27, 15, N'To connect to a new data source');
-- Department: System Development - Track: Power BI Development - Course: Data Modeling & Power Query
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (28, 16, N'A single flat table'), (29, 16, N'A model with a central fact table and multiple dimension tables'), (30, 16, N'A model with only dimension tables'), (31, 18, N'Merge Queries'), (32, 18, N'Append Queries'), (33, 18, N'Group By'), (34, 20, N'It defines the color of the relationship line'), (35, 20, N'It defines how tables are related (one-to-one, one-to-many)'), (36, 20, N'It defines the number of columns in a table'), (37, 21, N'Pivot Columns'), (38, 21, N'Unpivot Columns'), (39, 21, N'Transpose'), (40, 23, N'To record data transformation steps in Power Query'), (41, 23, N'To create visuals'), (42, 23, N'To write SQL queries'), (43, 25, N'Inner'), (44, 25, N'Right Outer'), (45, 25, N'Left Outer'), (46, 27, N'A table that contains numerical measures'), (47, 27, N'A table that contains descriptive attributes'), (48, 27, N'A summary table'), (49, 29, N'Filters rows based on a condition'), (50, 29, N'Summarizes rows of data into a single summary row'), (51, 29, N'Sorts data'), (52, 30, N'A feature to share data with others'), (53, 30, N'A feature to understand column quality, distribution, and profile'), (54, 30, N'A visualization type');
-- Department: System Development - Track: Power BI Development - Course: DAX Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (55, 31, N'Data Analysis Expressions'), (56, 31, N'Data Access Exchange'), (57, 31, N'Dashboard Analytics Extension'), (58, 33, N'There is no difference'), (59, 33, N'A column is an aggregation, a measure is row-by-row'), (60, 33, N'A column is row-by-row, a measure is an aggregation'), (61, 35, N'SUMMARIZE'), (62, 35, N'FILTER'), (63, 35, N'CALCULATE'), (64, 36, N'Calculates a related sum'), (65, 36, N'Retrieves a value from the "one" side of a relationship'), (66, 36, N'Creates a new relationship'), (67, 38, N'COUNT'), (68, 38, N'DISTINCTCOUNT'), (69, 38, N'COUNTROWS'), (70, 40, N'The set of active filters applied to a calculation'), (71, 40, N'The colors used in a report'), (72, 40, N'The relationship between tables'), (73, 42, N'To perform calculations over date ranges'), (74, 42, N'To format text as dates'), (75, 42, N'To connect to time-based data sources'), (76, 44, N'CALCULATE'), (77, 44, N'SUM'), (78, 44, N'FILTER'), (79, 45, N'AVERAGE'), (80, 45, N'COUNT'), (81, 45, N'SUM');
-- Department: System Development - Track: Power BI Development - Course: Data Visualization & Design
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (82, 46, N'Line Chart'), (83, 46, N'Bar Chart'), (84, 46, N'Pie Chart'), (85, 48, N'A link to another report'), (86, 48, N'To show additional details when hovering over a data point'), (87, 48, N'The title of the visual'), (88, 50, N'Line Chart'), (89, 50, N'Table'), (90, 50, N'Card'), (91, 51, N'Using as many colors as possible'), (92, 51, N'Placing the most important information in the top-left'), (93, 51, N'Making all charts the same size'), (94, 53, N'Adding a title'), (95, 53, N'Exporting data'), (96, 53, N'Filtering the report page'), (97, 55, N'Writing a long report about the data'), (98, 55, N'Guiding a user through data with a clear narrative'), (99, 55, N'Using only table visuals'), (100, 57, N'Charts'), (101, 57, N'Bookmarks'), (102, 57, N'Slicers'), (103, 59, N'Displaying a single, important number'), (104, 59, N'Showing trends over time'), (105, 59, N'Displaying detailed table data'), (106, 60, N'It is not important'), (107, 60, N'To create a clean and organized look'), (108, 60, N'To make the report load faster');
-- Department: System Development - Track: Power BI Development - Course: Power BI Service & Admin
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (109, 61, N'Power BI Desktop'), (110, 61, N'Power BI Service'), (111, 61, N'OneDrive'), (112, 63, N'To refresh on-premises data'), (113, 63, N'To design reports'), (114, 63, N'To store large datasets'), (115, 65, N'Viewer'), (116, 65, N'Contributor'), (117, 65, N'Admin'), (118, 66, N'A single report file'), (119, 66, N'A packaged collection of dashboards and reports for distribution'), (120, 66, N'A workspace permission level'), (121, 68, N'Alerts'), (122, 68, N'Subscriptions'), (123, 68, N'Comments'), (124, 70, N'To see who has a Pro license'), (125, 70, N'To monitor how content is being used'), (126, 70, N'To calculate DAX measures'), (127, 72, N'A type of visual'), (128, 72, N'A self-service, reusable ETL process in the Power BI Service'), (129, 72, N'A connection to a database'), (130, 74, N'To make a specific dashboard the default landing page'), (131, 74, N'To highlight important visuals'), (132, 74, N'To delete a dashboard'), (133, 75, N'Workspace settings'), (134, 75, N'Tenant settings in the Admin portal'), (135, 75, N'Capacity settings');
-- Department: System Development - Track: Power BI Development - Course: SQL for Analysts
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (136, 76, N'Structured Query Language'), (137, 76, N'Simple Query Logic'), (138, 76, N'Standard Question Language'), (139, 78, N'FROM'), (140, 78, N'FILTER'), (141, 78, N'WHERE'), (142, 80, N'LEFT JOIN'), (143, 80, N'INNER JOIN'), (144, 80, N'OUTER JOIN'), (145, 81, N'SUM()'), (146, 81, N'COUNT()'), (147, 81, N'MAX()'), (148, 83, N'ORDER BY'), (149, 83, N'GROUP BY'), (150, 83, N'HAVING'), (151, 85, N'LIKE'), (152, 85, N'MATCH'), (153, 85, N'='), (154, 87, N'A foreign key'), (155, 87, N'A unique identifier for each record in a table'), (156, 87, N'An index'), (157, 89, N'INNER JOIN'), (158, 89, N'RIGHT JOIN'), (159, 89, N'LEFT JOIN'), (160, 90, N'ADD NEW'), (161, 90, N'INSERT INTO'), (162, 90, N'UPDATE');
-- Department: System Development - Track: Power BI Development - Course: Power BI Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (163, 91, N'Building the visuals'), (164, 91, N'Defining the business requirements'), (165, 91, N'Publishing the report'), (166, 93, N'To make the project look official'), (167, 93, N'To outline tasks, timelines, and deliverables'), (168, 93, N'To choose the report colors'), (169, 95, N'Writing complex DAX formulas'), (170, 95, N'Communicating with and managing expectations of interested parties'), (171, 95, N'Only talking to your manager'), (172, 96, N'It is not important'), (173, 96, N'For clarity and future maintenance'), (174, 96, N'To make the file size smaller'), (175, 98, N'A summary of your resume'), (176, 98, N'A collection of your best work demonstrating your skills'), (177, 98, N'A list of courses you have taken'), (178, 100, N'A visual type in Power BI'), (179, 100, N'A document providing metadata about the data'), (180, 100, N'The final project report'), (181, 102, N'To show off your design skills'), (182, 102, N'To communicate insights and answer the business question'), (183, 102, N'To prove you finished the project'), (184, 104, N'A brief overview of the key findings'), (185, 104, N'The page where you list all data sources'), (186, 104, N'A summary of your project tasks'), (187, 105, N'It is less work'), (188, 105, N'It allows for flexibility and incorporating feedback'), (189, 105, N'It is the only way to build reports');


--Track 2  Industrial Automation Question   ================ ================ ================ ================ ================ ================

-- Department: System Development, Track: Industrial Automation, Course: Intro to PLC & Ladder Logic
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (500, 8, N'MCQ', N'What does PLC stand for?', N'Programmable Logic Controller'),(501, 8, N'True/False', N'Ladder logic is a text-based programming language.', N'False'),(502, 8, N'MCQ', N'Which is a core component of a PLC system?', N'CPU'),(503, 8, N'True/False', N'A normally closed (NC) contact is open when its coil is de-energized.', N'False'),(504, 8, N'MCQ', N'What is the function of an input module?', N'To read signals from sensors'),(505, 8, N'True/False', N'PLCs can only handle digital signals.', N'False'),(506, 8, N'MCQ', N'A rung in ladder logic represents a single...', N'Logical expression'),(507, 8, N'True/False', N'PLCs are less flexible than hard-wired relay logic.', N'False'),(508, 8, N'MCQ', N'The PLC scan cycle includes reading inputs, executing logic, and...', N'Updating outputs'),(509, 8, N'True/False', N'A latching circuit requires continuous power to the start button to remain active.', N'False'),(510, 8, N'MCQ', N'Which instruction is used to count events?', N'Counter (CTU/CTD)'),(511, 8, N'True/False', N'The output module connects to devices like push buttons and switches.', N'False'),(512, 8, N'MCQ', N'What does a Timer On-Delay (TON) instruction do?', N'Delays turning an output on'),(513, 8, N'True/False', N'Ladder Logic diagrams are read from right to left, bottom to top.', N'False'),(514, 8, N'MCQ', N'Which of the following is an advantage of PLCs?', N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: SCADA & HMI Design
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (515, 9, N'MCQ', N'What does SCADA stand for?', N'Supervisory Control and Data Acquisition'),(516, 9, N'True/False', N'HMI stands for Human-Machine Interaction.', N'False'),(517, 9, N'MCQ', N'What is the primary role of an HMI?', N'Provide a graphical interface for operators'),(518, 9, N'True/False', N'SCADA systems are only for monitoring, not control.', N'False'),(519, 9, N'MCQ', N'Which SCADA component communicates directly with field sensors?', N'RTU'),(520, 9, N'True/False', N'An effective HMI screen should be filled with as much information as possible.', N'False'),(521, 9, N'MCQ', N'A "tag" in a SCADA system represents a...', N'Data point or variable'),(522, 9, N'True/False', N'Historical trending is used to predict future system failures.', N'False'),(523, 9, N'MCQ', N'The central hub of a SCADA system is the...', N'Master Terminal Unit (MTU)'),(524, 9, N'True/False', N'Alarms are notifications for routine, normal operational events.', N'False'),(525, 9, N'MCQ', N'What is a key principle of high-performance HMI design?', N'Situational awareness'),(526, 9, N'True/False', N'HMIs can only be physical hardware panels.', N'False'),(527, 9, N'MCQ', N'What does RTU stand for?', N'Remote Terminal Unit'),(528, 9, N'True/False', N'SCADA systems are typically used for small, localized processes.', N'False'),(529, 9, N'MCQ', N'Which of these is a common HMI/SCADA software feature?', N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: Industrial Robotics
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (530, 10, N'MCQ', N'How many degrees of freedom does a standard SCARA robot have?', N'4'),(531, 10, N'True/False', N'An "end-effector" is the base of the robot.', N'False'),(532, 10, N'MCQ', N'Which type of robot is best suited for pick-and-place operations on a flat plane?', N'SCARA'),(533, 10, N'True/False', N'The "work envelope" refers to the robot''s programming manual.', N'False'),(534, 10, N'MCQ', N'What is "singularity" in robotics?', N'A position where robot motion is limited'),(535, 10, N'True/False', N'Robots are programmed using only one standard language.', N'False'),(536, 10, N'MCQ', N'What is the function of a robot controller?', N'To execute program commands and control motors'),(537, 10, N'True/False', N'Collaborative robots (cobots) are designed to operate without any safety fencing.', N'True'),(538, 10, N'MCQ', N'Which coordinate system is defined relative to the robot''s mounting point?', N'World Frame'),(539, 10, N'True/False', N'Payload refers to the maximum speed of the robot.', N'False'),(540, 10, N'MCQ', N'What does "jogging" a robot mean?', N'Manually moving the robot axes'),(541, 10, N'True/False', N'An articulated robot has only rotary joints.', N'False'),(542, 10, N'MCQ', N'Which sensor allows a robot to "see"?', N'Vision System'),(543, 10, N'True/False', N'Repeatability and accuracy are the same concept in robotics.', N'False'),(544, 10, N'MCQ', N'Which is a primary safety device for an industrial robot work cell?', N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: Control Systems & Instrumentation
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (545, 11, N'MCQ', N'A control system that operates without feedback is called...', N'Open-loop'),(546, 11, N'True/False', N'A thermostat is an example of a closed-loop control system.', N'True'),(547, 11, N'MCQ', N'What does PID stand for in a PID controller?', N'Proportional-Integral-Derivative'),(548, 11, N'True/False', N'The "process variable" is the value the controller is trying to achieve.', N'False'),(549, 11, N'MCQ', N'Which instrument is used to measure temperature?', N'Thermocouple'),(550, 11, N'True/False', N'A transducer converts one form of energy into another.', N'True'),(551, 11, N'MCQ', N'Which part of PID control considers the accumulated error over time?', N'Integral'),(552, 11, N'True/False', N'"Gain" in a control system refers to its physical size.', N'False'),(553, 11, N'MCQ', N'What does a pressure transmitter measure?', N'Force per unit area'),(554, 11, N'True/False', N'A control valve is considered a final control element.', N'True'),(555, 11, N'MCQ', N'The difference between the setpoint and the process variable is called...', N'Error'),(556, 11, N'True/False', N'An open-loop system can compensate for disturbances automatically.', N'False'),(557, 11, N'MCQ', N'Which device is used to measure fluid flow?', N'Flowmeter'),(558, 11, N'True/False', N'The derivative action in a PID controller helps prevent overshoot.', N'True'),(559, 11, N'MCQ', N'The standard current signal in instrumentation is...', N'4-20 mA');

-- Department: System Development, Track: Industrial Automation, Course: Industrial Networks & IIoT
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (560, 12, N'MCQ', N'What does IIoT stand for?', N'Industrial Internet of Things'),(561, 12, N'True/False', N'EtherNet/IP is the same as standard office Ethernet.', N'False'),(562, 12, N'MCQ', N'Which protocol is a master-slave protocol for industrial networks?', N'Modbus'),(563, 12, N'True/False', N'PROFINET is a protocol primarily associated with Siemens devices.', N'True'),(564, 12, N'MCQ', N'What is the primary benefit of IIoT?', N'Enhanced data collection and analytics'),(565, 12, N'True/False', N'Cybersecurity is not a major concern for industrial networks.', N'False'),(566, 12, N'MCQ', N'What is "edge computing" in the context of IIoT?', N'Processing data near its source'),(567, 12, N'True/False', N'All industrial networks use twisted-pair copper wiring.', N'False'),(568, 12, N'MCQ', N'Which network topology involves a central hub or switch?', N'Star'),(569, 12, N'True/False', N'OPC UA is a standard for secure and reliable data exchange.', N'True'),(570, 12, N'MCQ', N'What is a digital twin?', N'A virtual model of a physical asset'),(571, 12, N'True/False', N'Industrial networks prioritize speed over determinism.', N'False'),(572, 12, N'MCQ', N'Which layer of the Purdue Model contains PLCs and RTUs?', N'Control Level'),(573, 12, N'True/False', N' MQTT is a complex, heavyweight protocol for IIoT.', N'False'),(574, 12, N'MCQ', N'A key characteristic of an industrial network is...', N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: Functional Safety
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (575, 13, N'MCQ', N'What is the main goal of functional safety?', N'To reduce the risk of physical injury'),(576, 13, N'True/False', N'Functional safety is only about software design.', N'False'),(577, 13, N'MCQ', N'What does SIL stand for?', N'Safety Integrity Level'),(578, 13, N'True/False', N'A higher SIL number (e.g., SIL 3) indicates a lower level of safety.', N'False'),(579, 13, N'MCQ', N'Which of these is a key standard for functional safety in the process industry?', N'IEC 61511'),(580, 13, N'True/False', N'A risk assessment is the first step in a functional safety lifecycle.', N'True'),(581, 13, N'MCQ', N'A Safety Instrumented Function (SIF) consists of a sensor, logic solver, and...', N'Final element'),(582, 13, N'True/False', N'Redundancy in a system decreases its reliability and safety.', N'False'),(583, 13, N'MCQ', N'What does PFD stand for?', N'Probability of Failure on Demand'),(584, 13, N'True/False', N'A simple E-Stop button is not considered a safety function.', N'False'),(585, 13, N'MCQ', N'Which concept is crucial for fault tolerance in safety systems?', N'Diversity'),(586, 13, N'True/False', N'Once a system is certified for a SIL level, it never needs to be re-evaluated.', N'False'),(587, 13, N'MCQ', N'What is a "safe state"?', N'A state where the system poses no immediate danger'),(588, 13, N'True/False', N'Human error is not considered in functional safety analysis.', N'False'),(589, 13, N'MCQ', N'The purpose of proof testing a SIF is to...', N'Detect hidden failures');

-- Department: System Development, Track: Industrial Automation, Course: Automation Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (590, 14, N'MCQ', N'What is the first phase of a typical automation project?', N'Requirements gathering and definition'),(591, 14, N'True/False', N'A Gantt chart is a tool for managing project costs.', N'False'),(592, 14, N'MCQ', N'What does a P&ID diagram show?', N'Piping and Instrumentation'),(593, 14, N'True/False', N'The project scope should remain flexible and change often.', N'False'),(594, 14, N'MCQ', N'FAT stands for...', N'Factory Acceptance Test'),(595, 14, N'True/False', N'Commissioning is the process of building the control panel.', N'False'),(596, 14, N'MCQ', N'What is the purpose of project documentation?', N'To ensure clear communication and future maintenance'),(597, 14, N'True/False', N'It is best to write all PLC code before designing any electrical schematics.', N'False'),(598, 14, N'MCQ', N'Which of these is a key project milestone?', N'All of the above'),(599, 14, N'True/False', N'The critical path in a project plan represents the least important tasks.', N'False'),(600, 14, N'MCQ', N'What is a "bill of materials" (BOM)?', N'A list of all parts and components needed'),(601, 14, N'True/False', N'Site Acceptance Testing (SAT) is performed at the manufacturer''s facility.', N'False'),(602, 14, N'MCQ', N'Who is the primary stakeholder responsible for defining the project requirements?', N'The client or end-user'),(603, 14, N'True/False', N'A successful project is one that is only completed on time, regardless of budget.', N'False'),(604, 14, N'MCQ', N'What is the final stage of the project lifecycle?', N'Handover and support');


-- Department: System Development, Track: Industrial Automation, Course: Intro to PLC & Ladder Logic
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (500, 500, N'Programmable Logic Controller'),(501, 500, N'Process Logic Computer'),(502, 500, N'Programmed Local Control'),(503, 502, N'Power Supply'),(504, 502, N'CPU'),(505, 502, N'Monitor'),(506, 504, N'To read signals from sensors'),(507, 504, N'To power the PLC'),(508, 504, N'To control motors'),(509, 506, N'Logical expression'),(510, 506, N'Power rail'),(511, 506, N'Instruction set'),(512, 508, N'Updating outputs'),(513, 508, N'Checking for errors'),(514, 508, N'Backing up the program'),(515, 510, N'Timer (TON)'),(516, 510, N'Counter (CTU/CTD)'),(517, 510, N'Move (MOV)'),(518, 512, N'Delays turning an output on'),(519, 512, N'Delays turning an output off'),(520, 512, N'Counts on-time'),(521, 514, N'Reliability'),(522, 514, N'Flexibility'),(523, 514, N'Low Cost'),(524, 514, N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: SCADA & HMI Design
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (525, 515, N'System Control and Digital Automation'),(526, 515, N'Supervisory Control and Data Acquisition'),(527, 515, N'Software Control and Data Access'),(528, 517, N'Run complex control logic'),(529, 517, N'Store historical data'),(530, 517, N'Provide a graphical interface for operators'),(531, 519, N'HMI'),(532, 519, N'Historian Server'),(533, 519, N'RTU'),(534, 521, N'A hardware module'),(535, 521, N'Data point or variable'),(536, 521, N'An alarm condition'),(537, 523, N'Remote Terminal Unit (RTU)'),(538, 523, N'Master Terminal Unit (MTU)'),(539, 523, N'Human-Machine Interface (HMI)'),(540, 525, N'Data overload'),(541, 525, N'Situational awareness'),(542, 525, N'Complex color schemes'),(543, 527, N'Remote Telephone Unit'),(544, 527, N'Real-time Unit'),(545, 527, N'Remote Terminal Unit'),(546, 529, N'Alarming'),(547, 529, N'Trending'),(548, 529, N'Reporting'),(549, 529, N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: Industrial Robotics
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (550, 530, N'3'),(551, 530, N'4'),(552, 530, N'6'),(553, 532, N'Articulated'),(554, 532, N'Cartesian'),(555, 532, N'SCARA'),(556, 534, N'The robot''s maximum reach'),(557, 534, N'A position where robot motion is limited'),(558, 534, N'A software error'),(559, 536, N'To provide power to the robot'),(560, 536, N'To execute program commands and control motors'),(561, 536, N'To grip parts'),(562, 538, N'Tool Frame'),(563, 538, N'Joint Frame'),(564, 538, N'World Frame'),(565, 540, N'Writing a program'),(566, 540, N'Manually moving the robot axes'),(567, 540, N'Starting automatic operation'),(568, 542, N'Proximity Sensor'),(569, 542, N'Force-Torque Sensor'),(570, 542, N'Vision System'),(571, 544, N'Light Curtain'),(572, 544, N'Safety Fence'),(573, 544, N'Emergency Stop'),(574, 544, N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: Control Systems & Instrumentation
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (575, 545, N'Closed-loop'),(576, 545, N'Open-loop'),(577, 545, N'Adaptive'),(578, 547, N'Process-Integral-Derivative'),(579, 547, N'Proportional-Integral-Derivative'),(580, 547, N'Proportional-Incremental-Differential'),(581, 549, N'Flowmeter'),(582, 549, N'Transmitter'),(583, 549, N'Thermocouple'),(584, 551, N'Proportional'),(585, 551, N'Integral'),(586, 551, N'Derivative'),(587, 553, N'Flow rate'),(588, 553, N'Temperature'),(589, 553, N'Force per unit area'),(590, 555, N'Gain'),(591, 555, N'Setpoint'),(592, 555, N'Error'),(593, 557, N'Thermometer'),(594, 557, N'Flowmeter'),(595, 557, N'Manometer'),(596, 559, N'0-10 V'),(597, 559, N'4-20 mA'),(598, 559, N'0-5 V');

-- Department: System Development, Track: Industrial Automation, Course: Industrial Networks & IIoT
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (599, 560, N'Industrial Internet of Things'),(600, 560, N'Intelligent Internet of Things'),(601, 560, N'Integrated Internet of Technology'),(602, 562, N'EtherNet/IP'),(603, 562, N'Modbus'),(604, 562, N'PROFINET'),(605, 564, N'Reduced hardware costs'),(606, 564, N'Enhanced data collection and analytics'),(607, 564, N'Simplified programming'),(608, 566, N'Storing data in the cloud'),(609, 566, N'Processing data near its source'),(610, 566, N'Transmitting all data to a central server'),(611, 568, N'Ring'),(612, 568, N'Bus'),(613, 568, N'Star'),(614, 570, N'An IIoT sensor'),(615, 570, N'A virtual model of a physical asset'),(616, 570, N'A network protocol'),(617, 572, N'Enterprise Level'),(618, 572, N'Control Level'),(619, 572, N'Process Level'),(620, 574, N'Low latency'),(621, 574, N'Determinism'),(622, 574, N'Robustness'),(623, 574, N'All of the above');

-- Department: System Development, Track: Industrial Automation, Course: Functional Safety
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (624, 575, N'To improve production efficiency'),(625, 575, N'To reduce the risk of physical injury'),(626, 575, N'To simplify machine design'),(627, 577, N'System Integrity Logic'),(628, 577, N'Safety Implementation Level'),(629, 577, N'Safety Integrity Level'),(630, 579, N'ISO 9001'),(631, 579, N'IEC 61511'),(632, 579, N'NFPA 70'),(633, 581, N'Logic solver'),(634, 581, N'Sensor'),(635, 581, N'Final element'),(636, 583, N'Possibility of Failure on Demand'),(637, 583, N'Probability of Failure on Demand'),(638, 583, N'Probability of Frequent Defects'),(639, 585, N'Simplicity'),(640, 585, N'Diversity'),(641, 585, N'Complexity'),(642, 587, N'The most productive operational state'),(643, 587, N'A state where the system is powered off'),(644, 587, N'A state where the system poses no immediate danger'),(645, 589, N'Improve system performance'),(646, 589, N'Detect hidden failures'),(647, 589, N'Calibrate the sensors');

-- Department: System Development, Track: Industrial Automation, Course: Automation Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (648, 590, N'Programming and coding'),(649, 590, N'Requirements gathering and definition'),(650, 590, N'Installation and commissioning'),(651, 592, N'Process Flow'),(652, 592, N'Piping and Instrumentation'),(653, 592, N'Power and Interconnection'),(654, 594, N'Final Acceptance Trial'),(655, 594, N'Factory Assembly Test'),(656, 594, N'Factory Acceptance Test'),(657, 596, N'To guide marketing efforts'),(658, 596, N'To entertain the project team'),(659, 596, N'To ensure clear communication and future maintenance'),(660, 598, N'Project Kickoff'),(661, 598, N'Design Approval'),(662, 598, N'Final Commissioning'),(663, 598, N'All of the above'),(664, 600, N'A list of project tasks'),(665, 600, N'A list of all parts and components needed'),(666, 600, N'A financial budget'),(667, 602, N'The project manager'),(668, 602, N'The lead engineer'),(669, 602, N'The client or end-user'),(670, 604, N'Design'),(671, 604, N'Testing'),(672, 604, N'Handover and support');

-- Track 3  AWS Re /Start Questions =======================================================================

-- Department: System Development, Track: AWS Re /Start, Course: Cloud Intro & AWS Core Services
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1000, 15, N'MCQ', N'Which AWS service provides resizable compute capacity in the cloud?', N'Amazon EC2'), (1001, 15, N'True/False', N'An AWS Availability Zone is a distinct location within a single AWS data center.', N'False'), (1002, 15, N'MCQ', N'What does S3 stand for?', N'Simple Storage Service'), (1003, 15, N'MCQ', N'Which service allows you to provision a logically isolated section of the AWS Cloud?', N'Amazon VPC'), (1004, 15, N'True/False', N'AWS Lambda is an example of Infrastructure as a Service (IaaS).', N'False'), (1005, 15, N'MCQ', N'Which AWS service is a managed relational database service?', N'Amazon RDS'), (1006, 15, N'MCQ', N'The AWS Global Infrastructure is composed of Regions and what other element?', N'Availability Zones'), (1007, 15, N'True/False', N'Amazon S3 offers unlimited storage capacity.', N'True'), (1008, 15, N'MCQ', N'Which of the following is NOT a cloud computing model?', N'System as a Service (SaaS)'), (1009, 15, N'MCQ', N'Which core service is used for object storage?', N'Amazon S3'), (1010, 15, N'True/False', N'An EC2 instance is a virtual server in the AWS cloud.', N'True'), (1011, 15, N'MCQ', N'What is the primary benefit of using AWS Regions?', N'Disaster recovery and low latency'), (1012, 15, N'True/False', N'You are charged for data transfer into Amazon S3 from the internet.', N'False'), (1013, 15, N'MCQ', N'Which service would you use to run a MySQL database on AWS?', N'Amazon RDS'), (1014, 15, N'MCQ', N'What does VPC stand for?', N'Virtual Private Cloud');

-- Department: System Development, Track: AWS Re /Start, Course: Linux & Python Scripting
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1015, 16, N'MCQ', N'Which Linux command is used to list files and directories?', N'ls'), (1016, 16, N'True/False', N'The `chmod` command is used to change file ownership in Linux.', N'False'), (1017, 16, N'MCQ', N'In Python, what keyword is used to define a function?', N'def'), (1018, 16, N'MCQ', N'Which command is used to display the current working directory in Linux?', N'pwd'), (1019, 16, N'True/False', N'Python is a statically-typed language.', N'False'), (1020, 16, N'MCQ', N'What is the standard library in Python for interacting with AWS?', N'Boto3'), (1021, 16, N'MCQ', N'Which Linux command searches for a specific pattern in a file?', N'grep'), (1022, 16, N'True/False', N'A `for` loop in Python is used for indefinite iteration.', N'False'), (1023, 16, N'MCQ', N'What does the `sudo` command stand for in Linux?', N'superuser do'), (1024, 16, N'MCQ', N'Which data type is used to store a sequence of characters in Python?', N'string'), (1025, 16, N'True/False', N'A shell script must always have a `.sh` extension to be executable.', N'False'), (1026, 16, N'MCQ', N'How do you get help for a command in Linux?', N'man [command]'), (1027, 16, N'True/False', N'Boto3 is the AWS SDK for Java.', N'False'), (1028, 16, N'MCQ', N'Which symbol is used for comments in Python?', N'#'), (1029, 16, N'MCQ', N'Which command removes a directory and its contents recursively?', N'rm -r');

-- Department: System Development, Track: AWS Re /Start, Course: AWS IAM & Security
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1030, 17, N'MCQ', N'What does IAM stand for?', N'Identity and Access Management'), (1031, 17, N'True/False', N'By default, new IAM users are granted full access to all AWS services.', N'False'), (1032, 17, N'MCQ', N'What is the best practice for securing the AWS root account?', N'Enable Multi-Factor Authentication (MFA)'), (1033, 17, N'MCQ', N'Which IAM entity is best used for granting temporary access to AWS resources?', N'IAM Role'), (1034, 17, N'True/False', N'A Security Group acts as a firewall at the subnet level.', N'False'), (1035, 17, N'MCQ', N'What component is used to define permissions for an IAM user, group, or role?', N'IAM Policy'), (1036, 17, N'MCQ', N'What is the primary function of a Network Access Control List (NACL)?', N'To control traffic in and out of subnets'), (1037, 17, N'True/False', N'IAM Roles can be assumed by EC2 instances.', N'True'), (1038, 17, N'MCQ', N'Which AWS service helps protect against DDoS attacks?', N'AWS Shield'), (1039, 17, N'MCQ', N'Security Groups are stateful. What does this mean?', N'Return traffic is automatically allowed'), (1040, 17, N'True/False', N'An IAM Group is an identity with permission policies.', N'False'), (1041, 17, N'MCQ', N'What should you use to grant an application on an EC2 instance access to an S3 bucket?', N'IAM Role'), (1042, 17, N'True/False', N'AWS WAF is a web application firewall that protects against common web exploits.', N'True'), (1043, 17, N'MCQ', N'What is the principle of least privilege?', N'Granting only the permissions required to perform a task'), (1044, 17, N'MCQ', N'Which of these is NOT an IAM entity?', N'IAM Subnet');

-- Department: System Development, Track: AWS Re /Start, Course: AWS Databases & Networking
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1045, 18, N'MCQ', N'Which AWS service is a fully managed NoSQL database?', N'Amazon DynamoDB'), (1046, 18, N'True/False', N'A VPC can span multiple AWS Regions.', N'False'), (1047, 18, N'MCQ', N'What component enables communication between a VPC and the internet?', N'Internet Gateway'), (1048, 18, N'MCQ', N'Which service is a managed data warehousing service?', N'Amazon Redshift'), (1049, 18, N'True/False', N'By default, all subnets in a VPC can communicate with each other.', N'True'), (1050, 18, N'MCQ', N'Which AWS database service supports engines like MySQL, PostgreSQL, and Oracle?', N'Amazon RDS'), (1051, 18, N'MCQ', N'A subnet is associated with a single __________.', N'Availability Zone'), (1052, 18, N'True/False', N'DynamoDB is a relational database service.', N'False'), (1053, 18, N'MCQ', N'What does a Route Table determine in a VPC?', N'Where network traffic is directed'), (1054, 18, N'MCQ', N'Which service is an in-memory caching service?', N'Amazon ElastiCache'), (1055, 18, N'True/False', N'A public subnet is a subnet that has a route to an Internet Gateway.', N'True'), (1056, 18, N'MCQ', N'To allow instances in a private subnet to access the internet, you should use a ________.', N'NAT Gateway'), (1057, 18, N'True/False', N'Amazon RDS automatically handles database patching and backups.', N'True'), (1058, 18, N'MCQ', N'What is the main use case for Amazon Redshift?', N'Analytics and data warehousing'), (1059, 18, N'MCQ', N'Which of these is a valid CIDR block for a VPC?', N'10.0.0.0/16');

-- Department: System Development, Track: AWS Re /Start, Course: Infrastructure as Code (CloudFormation)
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1060, 19, N'MCQ', N'What is the primary benefit of Infrastructure as Code (IaC)?', N'Automates infrastructure provisioning'), (1061, 19, N'True/False', N'CloudFormation templates can only be written in JSON format.', N'False'), (1062, 19, N'MCQ', N'What is a collection of AWS resources that you manage as a single unit called in CloudFormation?', N'A Stack'), (1063, 19, N'MCQ', N'Which section of a CloudFormation template is mandatory?', N'Resources'), (1064, 19, N'True/False', N'CloudFormation incurs additional charges for its use.', N'False'), (1065, 19, N'MCQ', N'What feature allows you to preview the changes CloudFormation will make to your stack?', N'Change Sets'), (1066, 19, N'MCQ', N'Which section is used to declare input values for a CloudFormation template?', N'Parameters'), (1067, 19, N'True/False', N'Deleting a CloudFormation stack also deletes all the resources created by it.', N'True'), (1068, 19, N'MCQ', N'What is a reusable, modular unit of CloudFormation configuration called?', N'A Module'), (1069, 19, N'MCQ', N'Which intrinsic function would you use to reference a resource''s attribute?', N'!GetAtt'), (1070, 19, N'True/False', N'A stack update will always succeed without errors.', N'False'), (1071, 19, N'MCQ', N'What does the `Outputs` section of a template do?', N'Declares values to view after stack creation'), (1072, 19, N'True/False', N'Terraform is AWS''s native Infrastructure as Code service.', N'False'), (1073, 19, N'MCQ', N'Which of the following is NOT a valid CloudFormation stack status?', N'CREATE_PENDING'), (1074, 19, N'MCQ', N'To create a new S3 bucket, where would you define it in your template?', N'Resources section');

-- Department: System Development, Track: AWS Re /Start, Course: Serverless & CI/CD on AWS
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1075, 20, N'MCQ', N'Which AWS service lets you run code without provisioning or managing servers?', N'AWS Lambda'), (1076, 20, N'True/False', N'AWS CodePipeline is a fully managed source control service.', N'False'), (1077, 20, N'MCQ', N'Which service acts as a "front door" for applications to access data or business logic from your backend?', N'Amazon API Gateway'), (1078, 20, N'MCQ', N'What is the core service in an AWS CI/CD workflow that orchestrates the build, test, and deploy phases?', N'AWS CodePipeline'), (1079, 20, N'True/False', N'A Lambda function can be triggered by an S3 bucket event.', N'True'), (1080, 20, N'MCQ', N'Which service is a fully managed build service that compiles source code and produces artifacts?', N'AWS CodeBuild'), (1081, 20, N'MCQ', N'What AWS service provides a secure, private Git repository?', N'AWS CodeCommit'), (1082, 20, N'True/False', N'Amazon API Gateway only supports RESTful APIs.', N'False'), (1083, 20, N'MCQ', N'Which service automates code deployments to services like EC2, Lambda, or ECS?', N'AWS CodeDeploy'), (1084, 20, N'MCQ', N'Which messaging service is best for decoupling microservices using a publish/subscribe model?', N'Amazon SNS'), (1085, 20, N'True/False', N'You pay for AWS Lambda functions even when they are not running.', N'False'), (1086, 20, N'MCQ', N'What is the configuration file used by AWS CodeBuild to define build commands?', N'buildspec.yml'), (1087, 20, N'True/False', N'Serverless computing means there are no servers involved.', N'False'), (1088, 20, N'MCQ', N'Which service is a message queuing service?', N'Amazon SQS'), (1089, 20, N'MCQ', N'A CI/CD pipeline helps to ________ software delivery.', N'Automate');

-- Department: System Development, Track: AWS Re /Start, Course: AWS Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1090, 21, N'MCQ', N'Which pillar of the AWS Well-Architected Framework focuses on running and monitoring systems?', N'Operational Excellence'), (1091, 21, N'True/False', N'Hardcoding credentials in your application code is a recommended security practice.', N'False'), (1092, 21, N'MCQ', N'To achieve high availability, you should deploy your application across multiple what?', N'Availability Zones'), (1093, 21, N'MCQ', N'Which pillar focuses on the ability of a system to recover from infrastructure or service disruptions?', N'Reliability'), (1094, 21, N'True/False', N'The Security pillar includes protecting data both in transit and at rest.', N'True'), (1095, 21, N'MCQ', N'What is a common design pattern for a scalable and highly available web application on AWS?', N'ELB with an Auto Scaling Group'), (1096, 21, N'MCQ', N'Which pillar is concerned with using computing resources efficiently?', N'Performance Efficiency'), (1097, 21, N'True/False', N'Cost Optimization means using the cheapest possible services, regardless of performance.', N'False'), (1098, 21, N'MCQ', N'When designing a system, what is the first step you should typically take?', N'Gather requirements'), (1099, 21, N'MCQ', N'Which of the following is NOT a pillar of the AWS Well-Architected Framework?', N'Scalability'), (1100, 21, N'True/False', N'A proof of concept (PoC) is primarily used to test technical feasibility.', N'True'), (1101, 21, N'MCQ', N'Which service is key for automating the deployment of a capstone project?', N'AWS CodePipeline'), (1102, 21, N'True/False', N'It is a good practice to use a single, oversized EC2 instance for all parts of an application.', N'False'), (1103, 21, N'MCQ', N'What is the best way to decouple components in an AWS architecture?', N'Use services like SQS or SNS'), (1104, 21, N'MCQ', N'The goal of a capstone project is to demonstrate your ability to ______.', N'Build a real-world solution');



-- Department: System Development, Track: AWS Re /Start, Course: Cloud Intro & AWS Core Services
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1000, 1000, N'Amazon EC2'), (1001, 1000, N'Amazon S3'), (1002, 1000, N'Amazon RDS'), (1003, 1000, N'Amazon VPC'), (1004, 1002, N'Simple Storage Service'), (1005, 1002, N'Standard Storage Solution'), (1006, 1002, N'Secure Storage Service'), (1007, 1002, N'Systematic Storage Service'), (1008, 1003, N'Amazon VPC'), (1009, 1003, N'AWS Lambda'), (1010, 1003, N'Amazon EC2'), (1011, 1003, N'AWS IAM'), (1012, 1005, N'Amazon RDS'), (1013, 1005, N'Amazon S3'), (1014, 1005, N'Amazon DynamoDB'), (1015, 1005, N'Amazon ElastiCache'), (1016, 1006, N'Availability Zones'), (1017, 1006, N'Data Centers'), (1018, 1006, N'Subnets'), (1019, 1006, N'Edge Locations'), (1020, 1008, N'Infrastructure as a Service (IaaS)'), (1021, 1008, N'Platform as a Service (PaaS)'), (1022, 1008, N'System as a Service (SaaS)'), (1023, 1008, N'Software as a Service (SaaS)'), (1024, 1009, N'Amazon EC2'), (1025, 1009, N'Amazon S3'), (1026, 1009, N'Amazon RDS'), (1027, 1009, N'Amazon EBS'), (1028, 1011, N'Disaster recovery and low latency'), (1029, 1011, N'Lower cost'), (1030, 1011, N'Simplified billing'), (1031, 1011, N'Increased security'), (1032, 1013, N'Amazon DynamoDB'), (1033, 1013, N'Amazon Redshift'), (1034, 1013, N'Amazon RDS'), (1035, 1013, N'Amazon DocumentDB'), (1036, 1014, N'Virtual Private Cloud'), (1037, 1014, N'Virtual Public Cloud'), (1038, 1014, N'Volatile Private Cloud'), (1039, 1014, N'Virtual Processing Computer');

-- Department: System Development, Track: AWS Re /Start, Course: Linux & Python Scripting
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1040, 1015, N'ls'), (1041, 1015, N'dir'), (1042, 1015, N'list'), (1043, 1015, N'cd'), (1044, 1017, N'function'), (1045, 1017, N'def'), (1046, 1017, N'fun'), (1047, 1017, N'define'), (1048, 1018, N'dir'), (1049, 1018, N'path'), (1050, 1018, N'pwd'), (1051, 1018, N'where'), (1052, 1020, N'AWS-SDK'), (1053, 1020, N'PyAWS'), (1054, 1020, N'Boto3'), (1055, 1020, N'CloudPy'), (1056, 1021, N'find'), (1057, 1021, N'search'), (1058, 1021, N'grep'), (1059, 1021, N'locate'), (1060, 1023, N'super user do'), (1061, 1023, N'switch user do'), (1062, 1023, N'secure user do'), (1063, 1023, N'system user do'), (1064, 1024, N'char'), (1065, 1024, N'string'), (1066, 1024, N'text'), (1067, 1024, N'str'), (1068, 1026, N'help [command]'), (1069, 1026, N'man [command]'), (1070, 1026, N'info [command]'), (1071, 1026, N'guide [command]'), (1072, 1028, N'//'), (1073, 1028, N'--'), (1074, 1028, N'/* */'), (1075, 1028, N'#'), (1076, 1029, N'del'), (1077, 1029, N'rmdir'), (1078, 1029, N'rm -r'), (1079, 1029, N'delete -r');

-- Department: System Development, Track: AWS Re /Start, Course: AWS IAM & Security
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1080, 1030, N'Identity and Authorization Management'), (1081, 1030, N'Identity and Access Management'), (1082, 1030, N'Infrastructure and Access Management'), (1083, 1030, N'Identity and Asset Management'), (1084, 1032, N'Change the root password frequently'), (1085, 1032, N'Enable Multi-Factor Authentication (MFA)'), (1086, 1032, N'Delete the root account'), (1087, 1032, N'Use the root account for daily tasks'), (1088, 1033, N'IAM User'), (1089, 1033, N'IAM Group'), (1090, 1033, N'IAM Role'), (1091, 1033, N'IAM Policy'), (1092, 1035, N'IAM Role'), (1093, 1035, N'IAM Entity'), (1094, 1035, N'IAM Policy'), (1095, 1035, N'IAM User'), (1096, 1036, N'To filter traffic for EC2 instances'), (1097, 1036, N'To control traffic in and out of subnets'), (1098, 1036, N'To grant users access to services'), (1099, 1036, N'To protect against DDoS attacks'), (1100, 1038, N'AWS WAF'), (1101, 1038, N'Amazon Inspector'), (1102, 1038, N'AWS Shield'), (1103, 1038, N'AWS GuardDuty'), (1104, 1039, N'It blocks all return traffic by default'), (1105, 1039, N'It only processes inbound rules'), (1106, 1039, N'Return traffic is automatically allowed'), (1107, 1039, N'It requires separate rules for return traffic'), (1108, 1041, N'IAM User with access keys'), (1109, 1041, N'IAM Group'), (1110, 1041, N'IAM Role'), (1111, 1041, N'A new root account'), (1112, 1043, N'Granting full access to trusted users'), (1113, 1043, N'Granting only the permissions required to perform a task'), (1114, 1043, N'Removing all permissions periodically'), (1115, 1043, N'Giving read-only access to everyone'), (1116, 1044, N'IAM Subnet'), (1117, 1044, N'IAM User'), (1118, 1044, N'IAM Group'), (1119, 1044, N'IAM Role');

-- Department: System Development, Track: AWS Re /Start, Course: AWS Databases & Networking
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1120, 1045, N'Amazon RDS'), (1121, 1045, N'Amazon Redshift'), (1122, 1045, N'Amazon DynamoDB'), (1123, 1045, N'Amazon Aurora'), (1124, 1047, N'VPC Endpoint'), (1125, 1047, N'NAT Gateway'), (1126, 1047, N'Internet Gateway'), (1127, 1047, N'Direct Connect'), (1128, 1048, N'Amazon DynamoDB'), (1129, 1048, N'Amazon Redshift'), (1130, 1048, N'Amazon RDS'), (1131, 1048, N'Amazon ElastiCache'), (1132, 1050, N'Amazon Redshift'), (1133, 1050, N'Amazon DynamoDB'), (1134, 1050, N'Amazon DocumentDB'), (1135, 1050, N'Amazon RDS'), (1136, 1051, N'Region'), (1137, 1051, N'Availability Zone'), (1138, 1051, N'VPC'), (1139, 1051, N'Account'), (1140, 1053, N'Which instances can communicate'), (1141, 1053, N'The size of the subnet'), (1142, 1053, N'Where network traffic is directed'), (1143, 1053, N'The database engine type'), (1144, 1054, N'Amazon ElastiCache'), (1145, 1054, N'Amazon S3 Glacier'), (1146, 1054, N'Amazon RDS'), (1147, 1054, N'Amazon EFS'), (1148, 1056, N'Internet Gateway'), (1149, 1056, N'VPC Peering Connection'), (1150, 1056, N'NAT Gateway'), (1151, 1056, N'VPN Gateway'), (1152, 1058, N'Transactional processing (OLTP)'), (1153, 1058, N'Analytics and data warehousing'), (1154, 1058, N'In-memory caching'), (1155, 1058, N'File storage'), (1156, 1059, N'10.0.0.0/8'), (1157, 1059, N'10.0.0.0/16'), (1158, 1059, N'10.0.0.0/28'), (1159, 1059, N'10.0.0.0/32');

-- Department: System Development, Track: AWS Re /Start, Course: Infrastructure as Code (CloudFormation)
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1160, 1060, N'Provides free compute resources'), (1161, 1060, N'Automates infrastructure provisioning'), (1162, 1060, N'Manually configures servers'), (1163, 1060, N'Replaces the need for developers'), (1164, 1062, N'A Stack'), (1165, 1062, N'A Template'), (1166, 1062, N'A Resource'), (1167, 1062, N'A Parameter'), (1168, 1063, N'Parameters'), (1169, 1063, N'Outputs'), (1170, 1063, N'Mappings'), (1171, 1063, N'Resources'), (1172, 1065, N'Stack Policy'), (1173, 1065, N'Drift Detection'), (1174, 1065, N'Change Sets'), (1175, 1065, N'StackSets'), (1176, 1066, N'Resources'), (1177, 1066, N'Outputs'), (1178, 1066, N'Parameters'), (1179, 1066, N'Conditions'), (1180, 1068, N'An Intrinsic Function'), (1181, 1068, N'A Macro'), (1182, 1068, N'A Nested Stack'), (1183, 1068, N'A Module'), (1184, 1069, N'!Ref'), (1185, 1069, N'!GetAtt'), (1186, 1069, N'!Sub'), (1187, 1069, N'!Join'), (1188, 1071, N'Defines the AWS resources to be created'), (1189, 1071, N'Declares values to view after stack creation'), (1190, 1071, N'Takes user input'), (1191, 1071, N'Defines conditional logic'), (1192, 1073, N'CREATE_IN_PROGRESS'), (1193, 1073, N'CREATE_COMPLETE'), (1194, 1073, N'CREATE_FAILED'), (1195, 1073, N'CREATE_PENDING'), (1196, 1074, N'Parameters section'), (1197, 1074, N'Outputs section'), (1198, 1074, N'Resources section'), (1199, 1074, N'Mappings section');

-- Department: System Development, Track: AWS Re /Start, Course: Serverless & CI/CD on AWS
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1200, 1075, N'Amazon EC2'), (1201, 1075, N'AWS Lambda'), (1202, 1075, N'Amazon ECS'), (1203, 1075, N'AWS Fargate'), (1204, 1077, N'Amazon CloudFront'), (1205, 1077, N'Elastic Load Balancer'), (1206, 1077, N'Amazon API Gateway'), (1207, 1077, N'AWS Direct Connect'), (1208, 1078, N'AWS CodeBuild'), (1209, 1078, N'AWS CodeDeploy'), (1210, 1078, N'AWS CodeCommit'), (1211, 1078, N'AWS CodePipeline'), (1212, 1080, N'AWS CodePipeline'), (1213, 1080, N'Jenkins'), (1214, 1080, N'AWS CodeBuild'), (1215, 1080, N'AWS CodeDeploy'), (1216, 1081, N'GitHub'), (1217, 1081, N'AWS CodeCommit'), (1218, 1081, N'Bitbucket'), (1219, 1081, N'Amazon S3'), (1220, 1083, N'AWS CloudFormation'), (1221, 1083, N'AWS CodeDeploy'), (1222, 1083, N'AWS CodeBuild'), (1223, 1083, N'AWS Elastic Beanstalk'), (1224, 1084, N'Amazon SQS'), (1225, 1084, N'Amazon Kinesis'), (1226, 1084, N'Amazon SNS'), (1227, 1084, N'Amazon MQ'), (1228, 1086, N'pipeline.json'), (1229, 1086, N'appspec.yml'), (1230, 1086, N'buildspec.yml'), (1231, 1086, N'config.xml'), (1232, 1088, N'Amazon SQS'), (1233, 1088, N'Amazon SNS'), (1234, 1088, N'Amazon Lambda'), (1235, 1088, N'Amazon API Gateway'), (1236, 1089, N'Slow down'), (1237, 1089, N'Complicate'), (1238, 1089, N'Automate'), (1239, 1089, N'Manually test');

-- Department: System Development, Track: AWS Re /Start, Course: AWS Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1240, 1090, N'Security'), (1241, 1090, N'Reliability'), (1242, 1090, N'Operational Excellence'), (1243, 1090, N'Cost Optimization'), (1244, 1092, N'Regions'), (1245, 1092, N'Availability Zones'), (1246, 1092, N'Edge Locations'), (1247, 1092, N'VPCs'), (1248, 1093, N'Performance Efficiency'), (1249, 1093, N'Reliability'), (1250, 1093, N'Security'), (1251, 1093, N'Operational Excellence'), (1252, 1095, N'A single large EC2 instance'), (1253, 1095, N'ELB with an Auto Scaling Group'), (1254, 1095, N'AWS Lambda with DynamoDB'), (1255, 1095, N'A serverless API'), (1256, 1096, N'Cost Optimization'), (1257, 1096, N'Security'), (1258, 1096, N'Performance Efficiency'), (1259, 1096, N'Reliability'), (1260, 1098, N'Deploy the code'), (1261, 1098, N'Choose the database'), (1262, 1098, N'Gather requirements'), (1263, 1098, N'Write the CloudFormation template'), (1264, 1099, N'Security'), (1265, 1099, N'Reliability'), (1266, 1099, N'Scalability'), (1267, 1099, N'Cost Optimization'), (1268, 1101, N'Amazon S3'), (1269, 1101, N'Amazon EC2'), (1270, 1101, N'AWS IAM'), (1271, 1101, N'AWS CodePipeline'), (1272, 1103, N'Hardcode IP addresses'), (1273, 1103, N'Use services like SQS or SNS'), (1274, 1103, N'Combine all logic into one large application'), (1275, 1103, N'Use a single database for all services'), (1276, 1104, N'Pass a certification exam'), (1277, 1104, N'Build a real-world solution'), (1278, 1104, N'Memorize AWS service limits'), (1279, 1104, N'Write a research paper');


--Track 4 Python and DevOps Development Qustions ================================================================================================

-- Department: System Development, Track: Python and DevOps Development, Course: Python & OOP Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1500, 22, N'MCQ', N'What keyword is used to define a function in Python?', N'def'), (1501, 22, N'True/False', N'Python is a statically typed language.', N'False'), (1502, 22, N'MCQ', N'Which collection is ordered, changeable, and allows duplicate members?', N'List'), (1503, 22, N'MCQ', N'What is the term for bundling data and methods that work on that data within one unit?', N'Encapsulation'), (1504, 22, N'True/False', N'A class is an instance of an object.', N'False'), (1505, 22, N'MCQ', N'Which OOP concept allows a class to inherit attributes and methods from another class?', N'Inheritance'), (1506, 22, N'MCQ', N'How do you start a single-line comment in Python?', N'#'), (1507, 22, N'True/False', N'The `self` parameter in a method refers to the instance of the class.', N'True'), (1508, 22, N'MCQ', N'What method is called automatically when a new object is created?', N'__init__()'), (1509, 22, N'MCQ', N'Which data type is immutable?', N'Tuple'), (1510, 22, N'True/False', N'Indentation is not important in Python syntax.', N'False'), (1511, 22, N'MCQ', N'The ability of an object to take on many forms is known as what?', N'Polymorphism'), (1512, 22, N'True/False', N'A dictionary in Python stores items in an unordered manner.', N'False'), (1513, 22, N'MCQ', N'What is the correct file extension for Python files?', N'.py'), (1514, 22, N'MCQ', N'Which keyword is used to create a class?', N'class');

-- Department: System Development, Track: Python and DevOps Development, Course: Git & DevOps Principles
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1515, 23, N'MCQ', N'What command is used to stage changes for a commit?', N'git add'), (1516, 23, N'True/False', N'DevOps is a specific tool that you can install.', N'False'), (1517, 23, N'MCQ', N'Which of the following is a core principle of DevOps?', N'Culture of collaboration'), (1518, 23, N'MCQ', N'What command downloads a repository to your local machine?', N'git clone'), (1519, 23, N'True/False', N'A `git push` sends your local commits to the remote repository.', N'True'), (1520, 23, N'MCQ', N'What does "CI" stand for in the context of DevOps?', N'Continuous Integration'), (1521, 23, N'MCQ', N'Which command shows the commit history?', N'git log'), (1522, 23, N'True/False', N'`git branch new_feature` creates and switches to the new branch.', N'False'), (1523, 23, N'MCQ', N'The CALMS framework for DevOps includes Culture, Automation, Lean, Measurement, and...?', N'Sharing'), (1524, 23, N'MCQ', N'What command is used to merge another branch into your current branch?', N'git merge'), (1525, 23, N'True/False', N'The `.gitignore` file specifies intentionally untracked files to ignore.', N'True'), (1526, 23, N'MCQ', N'Which of "The Three Ways" of DevOps focuses on fast feedback?', N'The Second Way'), (1527, 23, N'True/False', N'`git pull` is a combination of `git fetch` and `git merge`.', N'True'), (1528, 23, N'MCQ', N'What is the purpose of a `fork` in platforms like GitHub?', N'To create a personal copy of another user''s repository'), (1529, 23, N'MCQ', N'Which term refers to a pointer to a specific commit?', N'HEAD');

-- Department: System Development, Track: Python and DevOps Development, Course: CI/CD with Jenkins
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1530, 24, N'MCQ', N'What is the name of the file used for defining a Jenkins Pipeline as Code?', N'Jenkinsfile'), (1531, 24, N'True/False', N'Jenkins is primarily a source code management tool.', N'False'), (1532, 24, N'MCQ', N'A Jenkins "pipeline" is a suite of plugins that supports implementing and integrating...?', N'Continuous Delivery pipelines'), (1533, 24, N'MCQ', N'Which of these is a common type of Jenkins job?', N'Freestyle project'), (1534, 24, N'True/False', N'A Jenkins agent is the central, coordinating process which stores configuration.', N'False'), (1535, 24, N'MCQ', N'What language is used to write a Jenkinsfile?', N'Groovy'), (1536, 24, N'MCQ', N'In a Declarative Pipeline, what block contains the steps to be executed?', N'steps'), (1537, 24, N'True/False', N'CI involves automatically building and testing code changes frequently.', N'True'), (1538, 24, N'MCQ', N'What is the concept of distributing builds across multiple machines in Jenkins?', N'Master/Agent Architecture'), (1539, 24, N'MCQ', N'Which section of a Declarative Pipeline specifies where the Pipeline will execute?', N'agent'), (1540, 24, N'True/False', N'Jenkins can only be triggered manually by a user.', N'False'), (1541, 24, N'MCQ', N'What is the purpose of the "build" stage in a typical CI/CD pipeline?', N'Compile source code and create artifacts'), (1542, 24, N'True/False', N'You cannot use parameters in a Jenkins job.', N'False'), (1543, 24, N'MCQ', N'Which plugin is fundamental for using Git with Jenkins?', N'Git Plugin'), (1544, 24, N'MCQ', N'CD stands for Continuous Delivery or Continuous...?', N'Deployment');

-- Department: System Development, Track: Python and DevOps Development, Course: Docker & Kubernetes
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1545, 25, N'MCQ', N'What is a running instance of a Docker image called?', N'Container'), (1546, 25, N'True/False', N'A Docker image is a lightweight, standalone, executable package.', N'True'), (1547, 25, N'MCQ', N'What is the name of the text file that contains commands to assemble a Docker image?', N'Dockerfile'), (1548, 25, N'MCQ', N'Kubernetes is a tool for container...?', N'Orchestration'), (1549, 25, N'True/False', N'A Kubernetes Pod can contain multiple containers.', N'True'), (1550, 25, N'MCQ', N'What is the primary command-line tool for interacting with a Kubernetes cluster?', N'kubectl'), (1551, 25, N'MCQ', N'In Docker, what is used to store and distribute images?', N'A registry'), (1552, 25, N'True/False', N'Containers run on a full-blown guest operating system.', N'False'), (1553, 25, N'MCQ', N'Which Kubernetes component is responsible for maintaining a set of replica Pods?', N'Deployment'), (1554, 25, N'MCQ', N'What Docker command lists all running containers?', N'docker ps'), (1555, 25, N'True/False', N'Docker volumes are used for persisting data generated by containers.', N'True'), (1556, 25, N'MCQ', N'Which Kubernetes object provides a stable network endpoint for a set of Pods?', N'Service'), (1557, 25, N'True/False', N'Kubernetes was originally developed by Microsoft.', N'False'), (1558, 25, N'MCQ', N'What instruction in a Dockerfile sets the base image for subsequent instructions?', N'FROM'), (1559, 25, N'MCQ', N'The smallest deployable unit in Kubernetes is a...?', N'Pod');

-- Department: System Development, Track: Python and DevOps Development, Course: Ansible & Terraform
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1560, 26, N'MCQ', N'Which tool is primarily used for Infrastructure as Code (IaC) provisioning?', N'Terraform'), (1561, 26, N'True/False', N'Ansible requires agents to be installed on managed nodes.', N'False'), (1562, 26, N'MCQ', N'What is the main configuration file for Terraform called?', N'main.tf'), (1563, 26, N'MCQ', N'An Ansible script containing a list of tasks is called a...?', N'Playbook'), (1564, 26, N'True/False', N'Terraform uses a declarative language called HCL.', N'True'), (1565, 26, N'MCQ', N'Which command in Terraform shows what changes will be made to your infrastructure?', N'terraform plan'), (1566, 26, N'MCQ', N'In Ansible, what file defines the hosts that Ansible will manage?', N'Inventory'), (1567, 26, N'True/False', N'Ansible is best suited for infrastructure provisioning from scratch.', N'False'), (1568, 26, N'MCQ', N'What is the term for an operation that produces the same result if executed multiple times?', N'Idempotency'), (1569, 26, N'MCQ', N'What file does Terraform use to store the state of the managed infrastructure?', N'terraform.tfstate'), (1570, 26, N'True/False', N'`terraform apply` will destroy all your infrastructure.', N'False'), (1571, 26, N'MCQ', N'Ansible connects to managed nodes primarily using which protocol?', N'SSH'), (1572, 26, N'True/False', N'Terraform is an agentless tool.', N'True'), (1573, 26, N'MCQ', N'What are the reusable units of code in Ansible called?', N'Modules'), (1574, 26, N'MCQ', N'Terraform is primarily a tool for...?', N'Infrastructure Provisioning');

-- Department: System Development, Track: Python and DevOps Development, Course: Microservices & Automated Testing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1575, 27, N'MCQ', N'Which architectural style structures an application as a collection of small, autonomous services?', N'Microservices'), (1576, 27, N'True/False', N'In a microservice architecture, all services must share the same database.', N'False'), (1577, 27, N'MCQ', N'What type of testing verifies the functionality of individual software components in isolation?', N'Unit Testing'), (1578, 27, N'MCQ', N'What component in a microservice architecture acts as a single entry point for all clients?', N'API Gateway'), (1579, 27, N'True/False', N'The test pyramid suggests writing many more end-to-end tests than unit tests.', N'False'), (1580, 27, N'MCQ', N'Which testing level focuses on verifying the interaction between different components or services?', N'Integration Testing'), (1581, 27, N'MCQ', N'What is a common pattern for communication between microservices?', N'REST APIs'), (1582, 27, N'True/False', N'A monolithic application is built as a single, unified unit.', N'True'), (1583, 27, N'MCQ', N'What is the practice of automatically checking for bugs with every code change called?', N'Automated Testing'), (1584, 27, N'MCQ', N'Which concept allows microservices to find and communicate with each other dynamically?', N'Service Discovery'), (1585, 27, N'True/False', N'Microservices increase the complexity of deployment and monitoring.', N'True'), (1586, 27, N'MCQ', N'What does TDD stand for?', N'Test-Driven Development'), (1587, 27, N'True/False', N'Integration tests are generally faster to run than unit tests.', N'False'), (1588, 27, N'MCQ', N'A key benefit of microservices is...?', N'Independent deployment'), (1589, 27, N'MCQ', N'Which testing simulates user behavior and tests the entire application flow?', N'End-to-End Testing');

-- Department: System Development, Track: Python and DevOps Development, Course: DevOps Pipeline Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (1590, 28, N'MCQ', N'What is the first stage in a typical CI/CD pipeline?', N'Commit'), (1591, 28, N'True/False', N'Security should only be considered at the end of the pipeline.', N'False'), (1592, 28, N'MCQ', N'Which practice involves integrating security into every phase of the DevOps lifecycle?', N'DevSecOps'), (1593, 28, N'MCQ', N'What is the primary goal of a CI/CD pipeline?', N'To automate software delivery'), (1594, 28, N'True/False', N'A good pipeline should provide fast feedback to developers.', N'True'), (1595, 28, N'MCQ', N'Which of these is a key metric for monitoring a DevOps pipeline?', N'Deployment Frequency'), (1596, 28, N'MCQ', N'Tools like Prometheus and Grafana are used for...?', N'Monitoring and Visualization'), (1597, 28, N'True/False', N'It is a best practice to store credentials directly in your source code repository.', N'False'), (1598, 28, N'MCQ', N'The concept of treating your infrastructure components like application code is known as...?', N'Infrastructure as Code'), (1599, 28, N'MCQ', N'What is a rollback strategy?', N'A plan to revert to a previous version in case of failure'), (1600, 28, N'True/False', N'A capstone project is meant to integrate multiple tools and concepts learned.', N'True'), (1601, 28, N'MCQ', N'What is the main benefit of using feature flags in a pipeline?', N'To enable/disable functionality without deploying new code'), (1602, 28, N'True/False', N'A successful pipeline never has any failed builds.', N'False'), (1603, 28, N'MCQ', N'The ELK Stack (Elasticsearch, Logstash, Kibana) is used for...?', N'Centralized Logging'), (1604, 28, N'MCQ', N'What does a "build artifact" refer to?', N'The deployable unit produced by the build process');


-- Department: System Development, Track: Python and DevOps Development, Course: Python & OOP Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1500, 1500, N'fun'), (1501, 1500, N'def'), (1502, 1500, N'function'), (1503, 1500, N'define'), (1504, 1502, N'Set'), (1505, 1502, N'Tuple'), (1506, 1502, N'Dictionary'), (1507, 1502, N'List'), (1508, 1503, N'Inheritance'), (1509, 1503, N'Polymorphism'), (1510, 1503, N'Encapsulation'), (1511, 1503, N'Abstraction'), (1512, 1505, N'Inheritance'), (1513, 1505, N'Polymorphism'), (1514, 1505, N'Abstraction'), (1515, 1505, N'Encapsulation'), (1516, 1506, N'//'), (1517, 1506, N'/*'), (1518, 1506, N'--'), (1519, 1506, N'#'), (1520, 1508, N'__main__()'), (1521, 1508, N'__construct()'), (1522, 1508, N'__init__()'), (1523, 1508, N'__start__()'), (1524, 1509, N'List'), (1525, 1509, N'Dictionary'), (1526, 1509, N'Tuple'), (1527, 1509, N'Set'), (1528, 1511, N'Encapsulation'), (1529, 1511, N'Inheritance'), (1530, 1511, N'Polymorphism'), (1531, 1511, N'Abstraction'), (1532, 1513, N'.py'), (1533, 1513, N'.pyt'), (1534, 1513, N'.ph'), (1535, 1513, N'.pt'), (1536, 1514, N'class'), (1537, 1514, N'object'), (1538, 1514, N'def'), (1539, 1514, N'new');

-- Department: System Development, Track: Python and DevOps Development, Course: Git & DevOps Principles
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1540, 1515, N'git commit'), (1541, 1515, N'git stage'), (1542, 1515, N'git add'), (1543, 1515, N'git push'), (1544, 1517, N'Separation of teams'), (1545, 1517, N'Manual processes'), (1546, 1517, N'Culture of collaboration'), (1547, 1517, N'Infrequent releases'), (1548, 1518, N'git pull'), (1549, 1518, N'git clone'), (1550, 1518, N'git fetch'), (1551, 1518, N'git copy'), (1552, 1520, N'Continuous Integration'), (1553, 1520, N'Code Inspection'), (1554, 1520, N'Controlled Input'), (1555, 1520, N'Code Integration'), (1556, 1521, N'git status'), (1557, 1521, N'git history'), (1558, 1521, N'git log'), (1559, 1521, N'git diff'), (1560, 1523, N'Stability'), (1561, 1523, N'Silos'), (1562, 1523, N'Security'), (1563, 1523, N'Sharing'), (1564, 1524, N'git add'), (1565, 1524, N'git commit'), (1566, 1524, N'git merge'), (1567, 1524, N'git join'), (1568, 1526, N'The First Way'), (1569, 1526, N'The Second Way'), (1570, 1526, N'The Third Way'), (1571, 1526, N'The Fourth Way'), (1572, 1528, N'To delete a repository'), (1573, 1528, N'To create a personal copy of another user''s repository'), (1574, 1528, N'To create a new branch'), (1575, 1528, N'To submit a bug report'), (1576, 1529, N'Branch'), (1577, 1529, N'Tag'), (1578, 1529, N'HEAD'), (1579, 1529, N'Master');

-- Department: System Development, Track: Python and DevOps Development, Course: CI/CD with Jenkins
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1580, 1530, N'Jenkinsfile'), (1581, 1530, N'config.yml'), (1582, 1530, N'pipeline.groovy'), (1583, 1530, N'build.xml'), (1584, 1532, N'Source Code Management'), (1585, 1532, N'Continuous Delivery pipelines'), (1586, 1532, N'Project Management'), (1587, 1532, N'Database Administration'), (1588, 1533, N'Git Project'), (1589, 1533, N'Pipeline'), (1590, 1533, N'Freestyle project'), (1591, 1533, N'Docker Project'), (1592, 1535, N'Python'), (1593, 1535, N'Java'), (1594, 1535, N'Groovy'), (1595, 1535, N'YAML'), (1596, 1536, N'agent'), (1597, 1536, N'stages'), (1598, 1536, N'steps'), (1599, 1536, N'post'), (1600, 1538, N'Freestyle Projects'), (1601, 1538, N'Pipeline as Code'), (1602, 1538, N'Master/Agent Architecture'), (1603, 1538, N'Plugin Management'), (1604, 1539, N'agent'), (1605, 1539, N'environment'), (1606, 1539, N'tools'), (1607, 1539, N'triggers'), (1608, 1541, N'Run unit tests'), (1609, 1541, N'Deploy to production'), (1610, 1541, N'Compile source code and create artifacts'), (1611, 1541, N'Notify developers'), (1612, 1543, N'Docker Plugin'), (1613, 1543, N'Maven Plugin'), (1614, 1543, N'Git Plugin'), (1615, 1543, N'Blue Ocean Plugin'), (1616, 1544, N'Development'), (1617, 1544, N'Dashboard'), (1618, 1544, N'Deployment'), (1619, 1544, N'Documentation');

-- Department: System Development, Track: Python and DevOps Development, Course: Docker & Kubernetes
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1620, 1545, N'Image'), (1621, 1545, N'Container'), (1622, 1545, N'Dockerfile'), (1623, 1545, N'Volume'), (1624, 1547, N'Docker.yml'), (1625, 1547, N'build.file'), (1626, 1547, N'Dockerfile'), (1627, 1547, N'Containerfile'), (1628, 1548, N'Building'), (1629, 1548, N'Networking'), (1630, 1548, N'Orchestration'), (1631, 1548, N'Storage'), (1632, 1550, N'k8s'), (1633, 1550, N'kubeadm'), (1634, 1550, N'docker'), (1635, 1550, N'kubectl'), (1636, 1551, N'A repository'), (1637, 1551, N'An image layer'), (1638, 1551, N'A registry'), (1639, 1551, N'A volume'), (1640, 1553, N'Service'), (1641, 1553, N'Pod'), (1642, 1553, N'Deployment'), (1643, 1553, N'Namespace'), (1644, 1554, N'docker list'), (1645, 1554, N'docker ps'), (1646, 1554, N'docker images'), (1647, 1554, N'docker run'), (1648, 1556, N'Service'), (1649, 1556, N'Ingress'), (1650, 1556, N'Pod'), (1651, 1556, N'ReplicaSet'), (1652, 1558, N'RUN'), (1653, 1558, N'BASE'), (1654, 1558, N'FROM'), (1655, 1558, N'IMAGE'), (1656, 1559, N'Container'), (1657, 1559, N'Service'), (1658, 1559, N'Pod'), (1659, 1559, N'Node');

-- Department: System Development, Track: Python and DevOps Development, Course: Ansible & Terraform
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1660, 1560, N'Ansible'), (1661, 1560, N'Docker'), (1662, 1560, N'Jenkins'), (1663, 1560, N'Terraform'), (1664, 1562, N'playbook.yml'), (1665, 1562, N'main.tf'), (1666, 1562, N'variables.tf'), (1667, 1562, N'terraform.rc'), (1668, 1563, N'Recipe'), (1669, 1563, N'Manifest'), (1670, 1563, N'Playbook'), (1671, 1563, N'Module'), (1672, 1565, N'terraform init'), (1673, 1565, N'terraform apply'), (1674, 1565, N'terraform plan'), (1675, 1565, N'terraform show'), (1676, 1566, N'Playbook'), (1677, 1566, N'Inventory'), (1678, 1566, N'Role'), (1679, 1566, N'ansible.cfg'), (1680, 1568, N'Automation'), (1681, 1568, N'Orchestration'), (1682, 1568, N'Idempotency'), (1683, 1568, N'Declaration'), (1684, 1569, N'terraform.plan'), (1685, 1569, N'terraform.log'), (1686, 1569, N'terraform.tfstate'), (1687, 1569, N'provider.tf'), (1688, 1571, N'RDP'), (1689, 1571, N'FTP'), (1690, 1571, N'SSH'), (1691, 1571, N'HTTP'), (1692, 1573, N'Playbooks'), (1693, 1573, N'Tasks'), (1694, 1573, N'Inventories'), (1695, 1573, N'Modules'), (1696, 1574, N'Configuration Management'), (1697, 1574, N'Infrastructure Provisioning'), (1698, 1574, N'Continuous Integration'), (1699, 1574, N'Log Management');

-- Department: System Development, Track: Python and DevOps Development, Course: Microservices & Automated Testing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1700, 1575, N'Monolithic'), (1701, 1575, N'Microservices'), (1702, 1575, N'Client-Server'), (1703, 1575, N'Layered'), (1704, 1577, N'Integration Testing'), (1705, 1577, N'End-to-End Testing'), (1706, 1577, N'Unit Testing'), (1707, 1577, N'Performance Testing'), (1708, 1578, N'Service Mesh'), (1709, 1578, N'Load Balancer'), (1710, 1578, N'API Gateway'), (1711, 1578, N'Service Discovery'), (1712, 1580, N'Unit Testing'), (1713, 1580, N'Integration Testing'), (1714, 1580, N'Acceptance Testing'), (1715, 1580, N'System Testing'), (1716, 1581, N'SOAP'), (1717, 1581, N'File Sharing'), (1718, 1581, N'RPC'), (1719, 1581, N'REST APIs'), (1720, 1583, N'Manual Testing'), (1721, 1583, N'Exploratory Testing'), (1722, 1583, N'Automated Testing'), (1723, 1583, N'Usability Testing'), (1724, 1584, N'API Gateway'), (1725, 1584, N'Service Discovery'), (1726, 1584, N'Circuit Breaker'), (1727, 1584, N'Configuration Server'), (1728, 1586, N'Technology-Driven Development'), (1729, 1586, N'Test-Driven Development'), (1730, 1586, N'Team-Driven Design'), (1731, 1586, N'Test-Data Driven'), (1732, 1588, N'Simplified codebase'), (1733, 1588, N'No need for automation'), (1734, 1588, N'Independent deployment'), (1735, 1588, N'Single point of failure'), (1736, 1589, N'Unit Testing'), (1737, 1589, N'Component Testing'), (1738, 1589, N'Integration Testing'), (1739, 1589, N'End-to-End Testing');

-- Department: System Development, Track: Python and DevOps Development, Course: DevOps Pipeline Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (1740, 1590, N'Deploy'), (1741, 1590, N'Test'), (1742, 1590, N'Build'), (1743, 1590, N'Commit'), (1744, 1592, N'DevOps'), (1745, 1592, N'SecOps'), (1746, 1592, N'DevSecOps'), (1747, 1592, N'Agile'), (1748, 1593, N'To write more code'), (1749, 1593, N'To automate software delivery'), (1750, 1593, N'To manually test everything'), (1751, 1593, N'To eliminate the need for developers'), (1752, 1595, N'Lines of Code'), (1753, 1595, N'Number of Commits'), (1754, 1595, N'Deployment Frequency'), (1755, 1595, N'Team Size'), (1756, 1596, N'Source Code Management'), (1757, 1596, N'Monitoring and Visualization'), (1758, 1596, N'Code Compilation'), (1759, 1596, N'Security Scanning'), (1760, 1598, N'Continuous Integration'), (1761, 1598, N'Infrastructure as Code'), (1762, 1598, N'Continuous Delivery'), (1763, 1598, N'Configuration Management'), (1764, 1599, N'A plan to always move forward'), (1765, 1599, N'A plan to revert to a previous version in case of failure'), (1766, 1599, N'A plan for testing new features'), (1767, 1599, N'A plan to deploy manually'), (1768, 1601, N'To speed up the build process'), (1769, 1601, N'To enable/disable functionality without deploying new code'), (1770, 1601, N'To automatically fix bugs'), (1771, 1601, N'To manage infrastructure'), (1772, 1603, N'Code Quality Analysis'), (1773, 1603, N'Infrastructure Provisioning'), (1774, 1603, N'Centralized Logging'), (1775, 1603, N'Artifact Storage'), (1776, 1604, N'The source code'), (1777, 1604, N'A test report'), (1778, 1604, N'The deployable unit produced by the build process'), (1779, 1604, N'A commit message');


--Track 5 Data Engineering Qustions =============================================================================================================

-- Department: System Development, Track: Data Engineering, Course: Data Engineering Intro with Python
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2000, 29, N'MCQ', N'Which Python library is fundamental for numerical computing?', N'NumPy'), (2001, 29, N'True/False', N'Pandas DataFrames are mutable in size.', N'False'), (2002, 29, N'MCQ', N'What is the primary data structure in Pandas for data analysis?', N'DataFrame'), (2003, 29, N'MCQ', N'Which file format is row-based and human-readable?', N'JSON'), (2004, 29, N'True/False', N'Data Engineering is primarily concerned with building machine learning models.', N'False'), (2005, 29, N'MCQ', N'What is the process of moving data from a source to a destination called?', N'Data Pipeline'), (2006, 29, N'MCQ', N'Which library is commonly used for making HTTP requests in Python?', N'requests'), (2007, 29, N'True/False', N'A CSV file stores data in a columnar format.', N'False'), (2008, 29, N'MCQ', N'What does API stand for?', N'Application Programming Interface'), (2009, 29, N'MCQ', N'Which of these is a key responsibility of a Data Engineer?', N'Building reliable data pipelines'), (2010, 29, N'True/False', N'The `loc` method in Pandas selects data by numerical index.', N'False'), (2011, 29, N'MCQ', N'What function in Pandas is used to read a CSV file?', N'pd.read_csv()'), (2012, 29, N'True/False', N'Virtual environments are used to manage project-specific dependencies in Python.', N'True'), (2013, 29, N'MCQ', N'Which concept refers to cleaning and transforming raw data?', N'Data Wrangling'), (2014, 29, N'MCQ', N'What is the standard package manager for Python?', N'pip');

-- Department: System Development, Track: Data Engineering, Course: Advanced SQL & Data Warehousing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2015, 30, N'MCQ', N'Which SQL function is an example of a window function?', N'ROW_NUMBER()'), (2016, 30, N'True/False', N'A star schema consists of one or more fact tables referencing any number of dimension tables.', N'True'), (2017, 30, N'MCQ', N'What does CTE stand for in SQL?', N'Common Table Expression'), (2018, 30, N'MCQ', N'Which type of table in a data warehouse stores measurements or metrics?', N'Fact Table'), (2019, 30, N'True/False', N'OLTP systems are optimized for complex data analysis.', N'False'), (2020, 30, N'MCQ', N'A schema where dimension tables are normalized into multiple related tables is called?', N'Snowflake Schema'), (2021, 30, N'MCQ', N'What SQL clause is used to filter results of a window function?', N'QUALIFY'), (2022, 30, N'True/False', N'A dimension table contains descriptive attributes.', N'True'), (2023, 30, N'MCQ', N'What is a surrogate key?', N'A system-generated unique identifier'), (2024, 30, N'MCQ', N'The process of storing historical data changes in a dimension table is called?', N'Slowly Changing Dimension (SCD)'), (2025, 30, N'True/False', N'A primary key cannot contain NULL values.', N'True'), (2026, 30, N'MCQ', N'Which `JOIN` returns all rows when there is a match in either table?', N'FULL OUTER JOIN'), (2027, 30, N'True/False', N'A view in SQL is a virtual table based on the result-set of an SQL statement.', N'True'), (2028, 30, N'MCQ', N'Which of these is a type of data model?', N'Relational Model'), (2029, 30, N'MCQ', N'What does OLAP stand for?', N'Online Analytical Processing');

-- Department: System Development, Track: Data Engineering, Course: ETL, Hadoop & Spark
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2030, 31, N'MCQ', N'What does ETL stand for?', N'Extract, Transform, Load'), (2031, 31, N'True/False', N'In an ELT process, data is transformed before being loaded into the data warehouse.', N'False'), (2032, 31, N'MCQ', N'Which component of Hadoop is responsible for storing data?', N'HDFS'), (2033, 31, N'MCQ', N'What is the core data structure in Spark since version 2.x?', N'DataFrame'), (2034, 31, N'True/False', N'Spark processes data faster than Hadoop MapReduce primarily because it uses in-memory processing.', N'True'), (2035, 31, N'MCQ', N'What is the resource manager in a Hadoop ecosystem?', N'YARN'), (2036, 31, N'MCQ', N'The principle of "lazy evaluation" in Spark means that...?', N'Transformations are not executed until an action is called'), (2037, 31, N'True/False', N'An RDD (Resilient Distributed Dataset) in Spark is mutable.', N'False'), (2038, 31, N'MCQ', N'Which of these is a Spark "action"?', N'count()'), (2039, 31, N'MCQ', N'HDFS is designed for...?', N'Storing large files'), (2040, 31, N'True/False', N'MapReduce is a programming model for processing large data sets.', N'True'), (2041, 31, N'MCQ', N'What is the role of the Driver Program in Spark?', N'To coordinate workers and execute the main function'), (2042, 31, N'True/False', N'Hadoop is a single monolithic piece of software.', N'False'), (2043, 31, N'MCQ', N'Which of these is a Spark "transformation"?', N'filter()'), (2044, 31, N'MCQ', N'The "T" in ELT stands for...?', N'Transform');

-- Department: System Development, Track: Data Engineering, Course: Cloud Data Platforms & Data Lakes
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2045, 32, N'MCQ', N'A central repository for raw, unstructured data at any scale is called a...?', N'Data Lake'), (2046, 32, N'True/False', N'A Data Warehouse typically stores structured and processed data.', N'True'), (2047, 32, N'MCQ', N'Which of these is an example of a columnar storage format?', N'Parquet'), (2048, 32, N'MCQ', N'Which AWS service is commonly used as the storage layer for a data lake?', N'Amazon S3'), (2049, 32, N'True/False', N'Schema-on-read is a characteristic of a Data Warehouse.', N'False'), (2050, 32, N'MCQ', N'Which Google Cloud service is a serverless, highly scalable data warehouse?', N'Google BigQuery'), (2051, 32, N'MCQ', N'What is a major benefit of columnar file formats like Parquet?', N'Improved query performance and compression'), (2052, 32, N'True/False', N'Data Lakes are generally more flexible and less expensive than traditional Data Warehouses.', N'True'), (2053, 32, N'MCQ', N'Which Azure service is a distributed data storage and analytics service?', N'Azure Data Lake Storage'), (2054, 32, N'MCQ', N'What is the term for the metadata definition of data?', N'Schema'), (2055, 32, N'True/False', N'It is impossible to run SQL queries on data in a data lake.', N'False'), (2056, 32, N'MCQ', N'Which of the following is an open-source columnar file format?', N'ORC'), (2057, 32, N'True/False', N'Data governance is less important in a data lake than in a data warehouse.', N'False'), (2058, 32, N'MCQ', N'What does "serverless" mean in the context of services like BigQuery?', N'Users do not manage the underlying infrastructure'), (2059, 32, N'MCQ', N'Which AWS service is a petabyte-scale data warehouse?', N'Amazon Redshift');

-- Department: System Development, Track: Data Engineering, Course: Real-time Streaming with Kafka
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2060, 33, N'MCQ', N'What is Apache Kafka?', N'A distributed streaming platform'), (2061, 33, N'True/False', N'In Kafka, a message is called a "record".', N'True'), (2062, 33, N'MCQ', N'A stream of records in Kafka is organized into a...?', N'Topic'), (2063, 33, N'MCQ', N'What is the role of a Kafka "Broker"?', N'To store data'), (2064, 33, N'True/False', N'A Kafka Producer writes data to topics.', N'True'), (2065, 33, N'MCQ', N'How does Kafka achieve fault tolerance and scalability for topics?', N'Partitions'), (2066, 33, N'MCQ', N'What is the purpose of Zookeeper in a Kafka cluster?', N'To manage cluster metadata and broker coordination'), (2067, 33, N'True/False', N'A single partition in Kafka can be consumed by multiple consumers in the same consumer group.', N'False'), (2068, 33, N'MCQ', N'A Kafka "Consumer" subscribes to one or more...?', N'Topics'), (2069, 33, N'MCQ', N'What is the unique identifier for a record within a partition called?', N'Offset'), (2070, 33, N'True/False', N'Kafka messages are deleted immediately after they are consumed.', N'False'), (2071, 33, N'MCQ', N'What ensures that consumers in a group do not read the same message?', N'Consumer Group'), (2072, 33, N'True/False', N'Kafka is designed for batch processing, not real-time streaming.', N'False'), (2073, 33, N'MCQ', N'What is a key benefit of using Kafka?', N'High throughput and low latency'), (2074, 33, N'MCQ', N'A set of brokers in Kafka is called a...?', N'Cluster');

-- Department: System Development, Track: Data Engineering, Course: Workflow Orchestration with Airflow
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2075, 34, N'MCQ', N'In Airflow, a workflow is represented as a...?', N'DAG'), (2076, 34, N'True/False', N'An Airflow DAG file is written in YAML.', N'False'), (2077, 34, N'MCQ', N'What does DAG stand for?', N'Directed Acyclic Graph'), (2078, 34, N'MCQ', N'A single unit of work in a DAG is called a...?', N'Task'), (2079, 34, N'True/False', N'A task in Airflow is an instance of an Operator.', N'True'), (2080, 34, N'MCQ', N'Which Airflow component is responsible for scheduling DAG runs?', N'Scheduler'), (2081, 34, N'MCQ', N'What is the concept of a task producing the same output given the same input?', N'Idempotency'), (2082, 34, N'True/False', N'In a DAG, it is possible to have a circular dependency between tasks.', N'False'), (2083, 34, N'MCQ', N'Which operator would you use to run a Python function in Airflow?', N'PythonOperator'), (2084, 34, N'MCQ', N'The process of running a DAG for a past date is called...?', N'Backfilling'), (2085, 34, N'True/False', N'Airflow is primarily a data streaming tool.', N'False'), (2086, 34, N'MCQ', N'What is an XCom in Airflow?', N'A mechanism for tasks to pass messages'), (2087, 34, N'True/False', N'The Airflow Webserver is used to execute tasks.', N'False'), (2088, 34, N'MCQ', N'Which of these defines the relationship between tasks in a DAG?', N'Dependencies'), (2089, 34, N'MCQ', N'What is a predefined, reusable task template in Airflow?', N'Operator');

-- Department: System Development, Track: Data Engineering, Course: Data Engineering Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2090, 35, N'MCQ', N'What is the first step in designing a data pipeline?', N'Understanding requirements and data sources'), (2091, 35, N'True/False', N'A capstone project is designed to test knowledge of a single, isolated tool.', N'False'), (2092, 35, N'MCQ', N'Why is data quality monitoring important in a pipeline?', N'To ensure data is accurate, complete, and reliable'), (2093, 35, N'MCQ', N'Which of the following is a critical non-functional requirement for a data pipeline?', N'Scalability'), (2094, 35, N'True/False', N'Hardcoding credentials in your pipeline code is a secure practice.', N'False'), (2095, 35, N'MCQ', N'What is the purpose of a staging area in an ETL process?', N'To temporarily store data during transformation'), (2096, 35, N'MCQ', N'When choosing a data storage solution, a key factor is...?', N'The data model and query patterns'), (2097, 35, N'True/False', N'For a project, it''s best to choose the newest technology available, regardless of the use case.', N'False'), (2098, 35, N'MCQ', N'Which concept involves tracking the lineage and movement of data?', N'Data Governance'), (2099, 35, N'MCQ', N'What is a common challenge in data engineering projects?', N'Handling evolving data schemas'), (2100, 35, N'True/False', N'Automated testing is not necessary for data pipelines.', N'False'), (2101, 35, N'MCQ', N'A good project design should be...?', N'Modular and maintainable'), (2102, 35, N'True/False', N'Documentation is an optional part of a capstone project.', N'False'), (2103, 35, N'MCQ', N'What does it mean for a pipeline to be "resilient"?', N'It can recover from failures'), (2104, 35, N'MCQ', N'Why is logging important in a data pipeline?', N'For debugging and monitoring');



-- Department: System Development, Track: Data Engineering, Course: Data Engineering Intro with Python
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2000, 2000, N'Pandas'), (2001, 2000, N'Matplotlib'), (2002, 2000, N'NumPy'), (2003, 2000, N'Requests'), (2004, 2002, N'Series'), (2005, 2002, N'DataFrame'), (2006, 2002, N'Array'), (2007, 2002, N'List'), (2008, 2003, N'Parquet'), (2009, 2003, N'ORC'), (2010, 2003, N'Avro'), (2011, 2003, N'JSON'), (2012, 2005, N'Data Pipeline'), (2013, 2005, N'Data Model'), (2014, 2005, N'Data Lake'), (2015, 2005, N'Data Mart'), (2016, 2006, N'pandas'), (2017, 2006, N'numpy'), (2018, 2006, N'requests'), (2019, 2006, N'airflow'), (2020, 2008, N'Advanced Programming Interface'), (2021, 2008, N'Application Programming Interface'), (2022, 2008, N'Automated Protocol Interaction'), (2023, 2008, N'Application Protocol Interchange'), (2024, 2009, N'Visualizing data'), (2025, 2009, N'Building machine learning models'), (2026, 2009, N'Building reliable data pipelines'), (2027, 2009, N'Presenting results to stakeholders'), (2028, 2011, N'pd.read_csv()'), (2029, 2011, N'pd.open_csv()'), (2030, 2011, N'pd.load_csv()'), (2031, 2011, N'pd.get_csv()'), (2032, 2013, N'Data Governance'), (2033, 2013, N'Data Science'), (2034, 2013, N'Data Wrangling'), (2035, 2013, N'Data Modeling'), (2036, 2014, N'conda'), (2037, 2014, N'pip'), (2038, 2014, N'npm'), (2039, 2014, N'venv');

-- Department: System Development, Track: Data Engineering, Course: Advanced SQL & Data Warehousing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2040, 2015, N'SUM()'), (2041, 2015, N'COUNT()'), (2042, 2015, N'ROW_NUMBER()'), (2043, 2015, N'WHERE'), (2044, 2017, N'Complex Table Engine'), (2045, 2017, N'Common Table Expression'), (2046, 2017, N'Continuous Table Entry'), (2047, 2017, N'Cascading Table Expression'), (2048, 2018, N'Dimension Table'), (2049, 2018, N'Staging Table'), (2050, 2018, N'Fact Table'), (2051, 2018, N'View'), (2052, 2020, N'Star Schema'), (2053, 2020, N'Galaxy Schema'), (2054, 2020, N'Fact Constellation Schema'), (2055, 2020, N'Snowflake Schema'), (2056, 2021, N'HAVING'), (2057, 2021, N'WHERE'), (2058, 2021, N'FILTER'), (2059, 2021, N'QUALIFY'), (2060, 2023, N'A primary key from the source system'), (2061, 2023, N'A foreign key'), (2062, 2023, N'A system-generated unique identifier'), (2063, 2023, N'A composite key'), (2064, 2024, N'Rapidly Changing Dimension (RCD)'), (2065, 2024, N'Dimension History Table (DHT)'), (2066, 2024, N'Slowly Changing Dimension (SCD)'), (2067, 2024, N'Fact Change Log (FCL)'), (2068, 2026, N'INNER JOIN'), (2069, 2026, N'LEFT JOIN'), (2070, 2026, N'FULL OUTER JOIN'), (2071, 2026, N'RIGHT JOIN'), (2072, 2028, N'Hierarchical Model'), (2073, 2028, N'Network Model'), (2074, 2028, N'Relational Model'), (2075, 2028, N'Object-Oriented Model'), (2076, 2029, N'Online Application Processing'), (2077, 2029, N'Online Analytical Processing'), (2078, 2029, N'Operational Link Analysis Protocol'), (2079, 2029, N'Online Transactional Processing');

-- Department: System Development, Track: Data Engineering, Course: ETL, Hadoop & Spark
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2080, 2030, N'Extract, Transform, Load'), (2081, 2030, N'Execute, Test, Load'), (2082, 2030, N'Extract, Test, Link'), (2083, 2030, N'Execute, Transform, Link'), (2084, 2032, N'YARN'), (2085, 2032, N'MapReduce'), (2086, 2032, N'HDFS'), (2087, 2032, N'Spark Core'), (2088, 2033, N'RDD'), (2089, 2033, N'DataFrame'), (2090, 2033, N'Schema'), (2091, 2033, N'Tuple'), (2092, 2035, N'HDFS'), (2093, 2035, N'Spark'), (2094, 2035, N'YARN'), (2095, 2035, N'MapReduce'), (2096, 2036, N'Actions are executed before transformations'), (2097, 2036, N'All code is compiled at runtime'), (2098, 2036, N'Transformations are not executed until an action is called'), (2099, 2036, N'Spark evaluates code line by line'), (2100, 2038, N'filter()'), (2101, 2038, N'map()'), (2102, 2038, N'count()'), (2103, 2038, N'select()'), (2104, 2039, N'Fast, random reads and writes'), (2105, 2039, N'Storing small files'), (2106, 2039, N'Transactional operations'), (2107, 2039, N'Storing large files'), (2108, 2041, N'To store data on worker nodes'), (2109, 2041, N'To run individual tasks'), (2110, 2041, N'To coordinate workers and execute the main function'), (2111, 2041, N'To manage cluster resources'), (2112, 2043, N'collect()'), (2113, 2043, N'filter()'), (2114, 2043, N'take()'), (2115, 2043, N'save()'), (2116, 2044, N'Test'), (2117, 2044, N'Transform'), (2118, 2044, N'Table'), (2119, 2044, N'Terminate');

-- Department: System Development, Track: Data Engineering, Course: Cloud Data Platforms & Data Lakes
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2120, 2045, N'Data Warehouse'), (2121, 2045, N'Data Mart'), (2122, 2045, N'Data Lake'), (2123, 2045, N'Database'), (2124, 2047, N'CSV'), (2125, 2047, N'JSON'), (2126, 2047, N'Parquet'), (2127, 2047, N'XML'), (2128, 2048, N'Amazon RDS'), (2129, 2048, N'Amazon EC2'), (2130, 2048, N'Amazon S3'), (2131, 2048, N'Amazon DynamoDB'), (2132, 2050, N'Google Cloud Storage'), (2133, 2050, N'Google Bigtable'), (2134, 2050, N'Google BigQuery'), (2135, 2050, N'Google Dataflow'), (2136, 2051, N'Human readability'), (2137, 2051, N'Improved query performance and compression'), (2138, 2051, N'Ease of manual editing'), (2139, 2051, N'Better support for nested data'), (2140, 2053, N'Azure SQL Database'), (2141, 2053, N'Azure Cosmos DB'), (2142, 2053, N'Azure Synapse Analytics'), (2143, 2053, N'Azure Data Lake Storage'), (2144, 2054, N'Data'), (2145, 2054, N'Schema'), (2146, 2054, N'Payload'), (2147, 2054, N'Format'), (2148, 2056, N'JSON'), (2149, 2056, N'CSV'), (2150, 2056, N'XML'), (2151, 2056, N'ORC'), (2152, 2058, N'The service is free to use'), (2153, 2058, N'The service runs without servers'), (2154, 2058, N'Users do not manage the underlying infrastructure'), (2155, 2058, N'The service has no performance limits'), (2156, 2059, N'Amazon S3'), (2157, 2059, N'Amazon Redshift'), (2158, 2059, N'Amazon Aurora'), (2159, 2059, N'Amazon DynamoDB');

-- Department: System Development, Track: Data Engineering, Course: Real-time Streaming with Kafka
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2160, 2060, N'A relational database'), (2161, 2060, N'A distributed streaming platform'), (2162, 2060, N'A workflow scheduler'), (2163, 2060, N'An in-memory data grid'), (2164, 2062, N'Queue'), (2165, 2062, N'Topic'), (2166, 2062, N'Log'), (2167, 2062, N'Table'), (2168, 2063, N'To write code'), (2169, 2063, N'To consume data'), (2170, 2063, N'To manage the cluster'), (2171, 2063, N'To store data'), (2172, 2065, N'Topics'), (2173, 2065, N'Offsets'), (2174, 2065, N'Partitions'), (2175, 2065, N'Brokers'), (2176, 2066, N'To store topic data'), (2177, 2066, N'To process streaming data'), (2178, 2066, N'To manage cluster metadata and broker coordination'), (2179, 2066, N'To provide a user interface'), (2180, 2068, N'Brokers'), (2181, 2068, N'Topics'), (2182, 2068, N'Partitions'), (2183, 2068, N'Offsets'), (2184, 2069, N'Key'), (2185, 2069, N'Index'), (2186, 2069, N'Offset'), (2187, 2069, N'Watermark'), (2188, 2071, N'Producer'), (2189, 2071, N'Consumer Group'), (2190, 2071, N'Zookeeper'), (2191, 2071, N'Broker'), (2192, 2073, N'Strong consistency'), (2193, 2073, N'Support for complex queries'), (2194, 2073, N'High throughput and low latency'), (2195, 2073, N'Easy data transformation'), (2196, 2074, N'Group'), (2197, 2074, N'Swarm'), (2198, 2074, N'Cluster'), (2199, 2074, N'Federation');

-- Department: System Development, Track: Data Engineering, Course: Workflow Orchestration with Airflow
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2200, 2075, N'Pipeline'), (2201, 2075, N'Flowchart'), (2202, 2075, N'DAG'), (2203, 2075, N'Script'), (2204, 2077, N'Data Analytics Graph'), (2205, 2077, N'Directed Acyclic Graph'), (2206, 2077, N'Data Automation Grid'), (2207, 2077, N'Direct Action Graph'), (2208, 2078, N'Node'), (2209, 2078, N'Step'), (2210, 2078, N'Job'), (2211, 2078, N'Task'), (2212, 2080, N'Executor'), (2213, 2080, N'Webserver'), (2214, 2080, N'Scheduler'), (2215, 2080, N'Worker'), (2216, 2081, N'Atomicity'), (2217, 2081, N'Idempotency'), (2218, 2081, N'Durability'), (2219, 2081, N'Concurrency'), (2220, 2083, N'BashOperator'), (2221, 2083, N'PythonOperator'), (2222, 2083, N'FunctionOperator'), (2223, 2083, N'ScriptOperator'), (2224, 2084, N'Backfilling'), (2225, 2084, N'Re-running'), (2226, 2084, N'Catching up'), (2227, 2084, N'Time-traveling'), (2228, 2086, N'A type of operator'), (2229, 2086, N'A connection string'), (2230, 2086, N'A mechanism for tasks to pass messages'), (2231, 2086, N'A user-facing variable'), (2232, 2088, N'Variables'), (2233, 2088, N'Operators'), (2234, 2088, N'Connections'), (2235, 2088, N'Dependencies'), (2236, 2089, N'Hook'), (2237, 2089, N'Provider'), (2238, 2089, N'Operator'), (2239, 2089, N'Plugin');

-- Department: System Development, Track: Data Engineering, Course: Data Engineering Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2240, 2090, N'Choosing a cloud provider'), (2241, 2090, N'Writing the transformation logic'), (2242, 2090, N'Understanding requirements and data sources'), (2243, 2090, N'Setting up monitoring'), (2244, 2092, N'To make the pipeline run faster'), (2245, 2092, N'To reduce data storage costs'), (2246, 2092, N'To ensure data is accurate, complete, and reliable'), (2247, 2092, N'To simplify the pipeline code'), (2248, 2093, N'Code readability'), (2249, 2093, N'Scalability'), (2250, 2093, N'The programming language used'), (2251, 2093, N'The number of developers'), (2252, 2095, N'To archive old data'), (2253, 2095, N'To serve data to end-users'), (2254, 2095, N'To temporarily store data during transformation'), (2255, 2095, N'To run analytical queries'), (2256, 2096, N'The brand name'), (2257, 2096, N'How easy it is to install'), (2258, 2096, N'The data model and query patterns'), (2259, 2096, N'The popularity on social media'), (2260, 2098, N'Data Transformation'), (2261, 2098, N'Data Governance'), (2262, 2098, N'Data Orchestration'), (2263, 2098, N'Data Science'), (2264, 2099, N'Lack of data'), (2265, 2099, N'Handling evolving data schemas'), (2266, 2099, N'Hardware being too fast'), (2267, 2099, N'Too much documentation'), (2268, 2101, N'Complex and rigid'), (2269, 2101, N'Written by a single person'), (2270, 2101, N'Modular and maintainable'), (2271, 2101, N'Quick to build initially'), (2272, 2103, N'It runs very fast'), (2273, 2103, N'It is cheap to operate'), (2274, 2103, N'It never fails'), (2275, 2103, N'It can recover from failures'), (2276, 2104, N'To increase data volume'), (2277, 2104, N'To slow down the pipeline'), (2278, 2104, N'For debugging and monitoring'), (2279, 2104, N'To meet regulatory requirements');


--Track 6 Front-End and Cross Platform Mobile Development Questions ============================================================================

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: HTML, CSS & Advanced JavaScript
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2500, 36, N'MCQ', N'What does HTML stand for?', N'HyperText Markup Language'), (2501, 36, N'True/False', N'CSS is used to structure a web page.', N'False'), (2502, 36, N'MCQ', N'Which property is used to change the background color in CSS?', N'background-color'), (2503, 36, N'MCQ', N'Which JavaScript keyword declares a block-scoped variable?', N'let'), (2504, 36, N'True/False', N'An arrow function can have its own `this` binding.', N'False'), (2505, 36, N'MCQ', N'What CSS layout model is used for arranging items in a single dimension?', N'Flexbox'), (2506, 36, N'MCQ', N'An object that may produce a single value some time in the future is a...?', N'Promise'), (2507, 36, N'True/False', N'`===` operator checks for equality without type conversion.', N'True'), (2508, 36, N'MCQ', N'What HTML tag is used to define an unordered list?', N'<ul>'), (2509, 36, N'MCQ', N'Which CSS selector selects elements with a specific class?', N'.classname'), (2510, 36, N'True/False', N'A closure gives you access to an outer function’s scope from an inner function.', N'True'), (2511, 36, N'MCQ', N'What is the modern syntax for handling asynchronous operations in JavaScript?', N'async/await'), (2512, 36, N'True/False', N'The `const` keyword declares a variable that can be reassigned.', N'False'), (2513, 36, N'MCQ', N'Which property is used to create space between an element''s border and content?', N'padding'), (2514, 36, N'MCQ', N'Which HTML element is a container for metadata?', N'<head>');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: React.js Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2515, 37, N'MCQ', N'What is JSX?', N'A syntax extension for JavaScript'), (2516, 37, N'True/False', N'In React, data flows from child components to parent components.', N'False'), (2517, 37, N'MCQ', N'What is used to pass data to a component from outside?', N'props'), (2518, 37, N'MCQ', N'Which hook is used to add state to a functional component?', N'useState'), (2519, 37, N'True/False', N'React uses a real DOM for performance optimization.', N'False'), (2520, 37, N'MCQ', N'A reusable, self-contained piece of UI in React is called a...?', N'Component'), (2521, 37, N'MCQ', N'Which hook is used for handling side effects like data fetching?', N'useEffect'), (2522, 37, N'True/False', N'Props in React are mutable.', N'False'), (2523, 37, N'MCQ', N'What method in a class component is called to update the state?', N'setState()'), (2524, 37, N'MCQ', N'How do you render a list of items in React?', N'Using the map() function'), (2525, 37, N'True/False', N'A component must return a single root element.', N'True'), (2526, 37, N'MCQ', N'What is the main advantage of using a Virtual DOM?', N'Improved performance'), (2527, 37, N'True/False', N'All React components must start with a lowercase letter.', N'False'), (2528, 37, N'MCQ', N'What tool is used to create a new React app with a recommended setup?', N'Create React App'), (2529, 37, N'MCQ', N'The internal data store of a component is its...?', N'state');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: React Native Development
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2530, 38, N'MCQ', N'React Native allows you to build apps for which platforms?', N'iOS and Android'), (2531, 38, N'True/False', N'React Native uses HTML tags like `<div>` and `<span>` for layout.', N'False'), (2532, 38, N'MCQ', N'What is the basic container component in React Native for layout?', N'View'), (2533, 38, N'MCQ', N'How are styles applied in React Native?', N'Using JavaScript objects with StyleSheet'), (2534, 38, N'True/False', N'React Native compiles to native UI components.', N'True'), (2535, 38, N'MCQ', N'What is the default layout system in React Native?', N'Flexbox'), (2536, 38, N'MCQ', N'Which component is used to display text?', N'Text'), (2537, 38, N'True/False', N'You can share 100% of the code between iOS and Android in every app.', N'False'), (2538, 38, N'MCQ', N'What is a common library for handling navigation in React Native?', N'React Navigation'), (2539, 38, N'MCQ', N'Which of these is a core component for making elements touchable?', N'TouchableOpacity'), (2540, 38, N'True/False', N'Expo is a toolchain that makes React Native development easier.', N'True'), (2541, 38, N'MCQ', N'How can you fetch data from an API in React Native?', N'Using the Fetch API'), (2542, 38, N'True/False', N'The state and props concepts are different in React Native than in React for web.', N'False'), (2543, 38, N'MCQ', N'What component is used to render a scrollable list of data?', N'FlatList'), (2544, 38, N'MCQ', N'The "bridge" in React Native allows communication between JavaScript and...?', N'Native modules');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: Flutter & Dart Development
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2545, 39, N'MCQ', N'What programming language is used by Flutter?', N'Dart'), (2546, 39, N'True/False', N'In Flutter, almost everything is a Widget.', N'True'), (2547, 39, N'MCQ', N'Which widget is used for layouts with a horizontal arrangement?', N'Row'), (2548, 39, N'MCQ', N'A widget that does not require mutable state is called a...?', N'StatelessWidget'), (2549, 39, N'True/False', N'The `pubspec.yaml` file is used for managing project dependencies.', N'True'), (2550, 39, N'MCQ', N'Which function is the entry point for a Flutter app?', N'main()'), (2551, 39, N'MCQ', N'What is the name of Flutter''s reactive UI framework?', N'Widgets'), (2552, 39, N'True/False', N'A `StatefulWidget` can be rebuilt when its internal state changes.', N'True'), (2553, 39, N'MCQ', N'Which widget is used to place children in a vertical array?', N'Column'), (2554, 39, N'MCQ', N'How do you update the state of a StatefulWidget?', N'By calling setState()'), (2555, 39, N'True/False', N'Flutter compiles to native code, providing excellent performance.', N'True'), (2556, 39, N'MCQ', N'Which widget provides a standard mobile app layout structure?', N'Scaffold'), (2557, 39, N'True/False', N'The `final` keyword in Dart means the variable can be changed after initialization.', N'False'), (2558, 39, N'MCQ', N'Which widget would you use to add padding around another widget?', N'Padding'), (2559, 39, N'MCQ', N'The `build()` method in a widget is responsible for...?', N'Describing the widget''s UI');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: Working with APIs & State Management
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2560, 40, N'MCQ', N'What does API stand for?', N'Application Programming Interface'), (2561, 40, N'True/False', N'A POST request is typically used to retrieve data from a server.', N'False'), (2562, 40, N'MCQ', N'Which of these is a popular library for making HTTP requests?', N'axios'), (2563, 40, N'MCQ', N'A predictable state container for JavaScript apps is...?', N'Redux'), (2564, 40, N'True/False', N'Global state management is necessary for all applications.', N'False'), (2565, 40, N'MCQ', N'What HTTP method is idempotent and used to update a resource?', N'PUT'), (2566, 40, N'MCQ', N'In Redux, what is the only way to change the state?', N'Dispatching an action'), (2567, 40, N'True/False', N'React''s Context API can be used for state management.', N'True'), (2568, 40, N'MCQ', N'What is a pure function that takes the previous state and an action, and returns the next state?', N'A reducer'), (2569, 40, N'MCQ', N'What does the `await` keyword do?', N'Pauses the execution of an async function'), (2570, 40, N'True/False', N'REST is a strict protocol with a defined message format.', N'False'), (2571, 40, N'MCQ', N'What is "prop drilling" in React?', N'Passing props down through multiple component layers'), (2572, 40, N'True/False', N'The Fetch API returns a Promise.', N'True'), (2573, 40, N'MCQ', N'What is the single source of truth in a Redux application?', N'The store'), (2574, 40, N'MCQ', N'What is the purpose of the HTTP GET method?', N'To request data from a specified resource');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: UI/UX for Mobile
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2575, 41, N'MCQ', N'What does UX stand for?', N'User Experience'), (2576, 41, N'True/False', N'UI design is focused on how a product feels.', N'False'), (2577, 41, N'MCQ', N'A low-fidelity representation of a design is called a...?', N'Wireframe'), (2578, 41, N'MCQ', N'Which process involves understanding user behaviors, needs, and motivations?', N'User Research'), (2579, 41, N'True/False', N'Accessibility in design ensures that an app is usable by people with disabilities.', N'True'), (2580, 41, N'MCQ', N'What is the term for a visual vocabulary that synthesizes design elements?', N'Design System'), (2581, 41, N'MCQ', N'Google''s design language for Android is called...?', N'Material Design'), (2582, 41, N'True/False', N'A prototype is a static image of the final product.', N'False'), (2583, 41, N'MCQ', N'The practice of evaluating a product by testing it on users is...?', N'Usability Testing'), (2584, 41, N'MCQ', N'What is a User Persona?', N'A fictional character representing a target user type'), (2585, 41, N'True/False', N'A good user interface should require a lot of thought from the user.', N'False'), (2586, 41, N'MCQ', N'Apple''s design guidelines for iOS are called...?', N'Human Interface Guidelines'), (2587, 41, N'True/False', N'Consistency is a key principle of good UI design.', N'True'), (2588, 41, N'MCQ', N'The structure and flow of an app is its...?', N'Information Architecture'), (2589, 41, N'MCQ', N'What is the primary goal of UX design?', N'To improve user satisfaction');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: Cross-Platform App Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (2590, 42, N'MCQ', N'What is the first phase of a software development project?', N'Requirement Analysis'), (2591, 42, N'True/False', N'A capstone project is meant to combine and apply various skills learned.', N'True'), (2592, 42, N'MCQ', N'Which tool is essential for collaborative development and version control?', N'Git'), (2593, 42, N'MCQ', N'What is the main advantage of cross-platform development?', N'Code reusability and cost-effectiveness'), (2594, 42, N'True/False', N'It is a good practice to store API keys directly in the source code.', N'False'), (2595, 42, N'MCQ', N'The process of ensuring an application works as intended is called...?', N'Testing'), (2596, 42, N'MCQ', N'What is an MVP in product development?', N'Minimum Viable Product'), (2597, 42, N'True/False', N'State management is not a concern when building the final project.', N'False'), (2598, 42, N'MCQ', N'Which document outlines the project''s features and functionality?', N'Specification Document'), (2599, 42, N'MCQ', N'The process of publishing an app to the Google Play Store or Apple App Store is called...?', N'Deployment'), (2600, 42, N'True/False', N'Performance optimization is a step that should be ignored until after launch.', N'False'), (2601, 42, N'MCQ', N'What is a common challenge in cross-platform development?', N'Achieving a native look and feel'), (2602, 42, N'True/False', N'A good capstone project should have clear and concise documentation.', N'True'), (2603, 42, N'MCQ', N'What kind of testing is typically done by end-users?', N'User Acceptance Testing (UAT)'), (2604, 42, N'MCQ', N'Which of these is a key part of project planning?', N'Defining milestones');



-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: HTML, CSS & Advanced JavaScript
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2500, 2500, N'HyperText Markup Language'), (2501, 2500, N'Hyperlinks and Text Markup Language'), (2502, 2500, N'Home Tool Markup Language'), (2503, 2500, N'Hyper-Transfer Markup Language'), (2504, 2502, N'color'), (2505, 2502, N'bgcolor'), (2506, 2502, N'background-color'), (2507, 2502, N'background'), (2508, 2503, N'var'), (2509, 2503, N'let'), (2510, 2503, N'const'), (2511, 2503, N'variable'), (2512, 2505, N'Grid'), (2513, 2505, N'Flexbox'), (2514, 2505, N'Block'), (2515, 2505, N'Float'), (2516, 2506, N'Function'), (2517, 2506, N'Array'), (2518, 2506, N'Object'), (2519, 2506, N'Promise'), (2520, 2508, N'<ul>'), (2521, 2508, N'<ol>'), (2522, 2508, N'<li>'), (2523, 2508, N'<list>'), (2524, 2509, N'#classname'), (2525, 2509, N'classname'), (2526, 2509, N'.classname'), (2527, 2509, N'*classname'), (2528, 2511, N'callbacks'), (2529, 2511, N'async/await'), (2530, 2511, N'setTimeout'), (2531, 2511, N'promises'), (2532, 2513, N'padding'), (2533, 2513, N'margin'), (2534, 2513, N'border'), (2535, 2513, N'spacing'), (2536, 2514, N'<body>'), (2537, 2514, N'<footer>'), (2538, 2514, N'<head>'), (2539, 2514, N'<meta>');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: React.js Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2540, 2515, N'A JavaScript library'), (2541, 2515, N'A syntax extension for JavaScript'), (2542, 2515, N'A templating language'), (2543, 2515, N'A CSS preprocessor'), (2544, 2517, N'state'), (2545, 2517, N'props'), (2546, 2517, N'hooks'), (2547, 2517, N'refs'), (2548, 2518, N'useEffect'), (2549, 2518, N'useState'), (2550, 2518, N'useContext'), (2551, 2518, N'useReducer'), (2552, 2520, N'Element'), (2553, 2520, N'Module'), (2554, 2520, N'Component'), (2555, 2520, N'Package'), (2556, 2521, N'useState'), (2557, 2521, N'useEffect'), (2558, 2521, N'useCallback'), (2559, 2521, N'useMemo'), (2560, 2523, N'this.state = ...'), (2561, 2523, N'this.changeState()'), (2562, 2523, N'setState()'), (2563, 2523, N'updateState()'), (2564, 2524, N'Using the forEach() function'), (2565, 2524, N'Using a for loop'), (2566, 2524, N'Using the map() function'), (2567, 2524, N'Using the reduce() function'), (2568, 2526, N'Faster rendering'), (2569, 2526, N'Improved performance'), (2570, 2526, N'Server-side rendering'), (2571, 2526, N'Code splitting'), (2572, 2528, N'React Installer'), (2573, 2528, N'Create React App'), (2574, 2528, N'React Starter Kit'), (2575, 2528, N'NPM React'), (2576, 2529, N'props'), (2577, 2529, N'context'), (2578, 2529, N'state'), (2579, 2529, N'refs');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: React Native Development
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2580, 2530, N'Web and Desktop'), (2581, 2530, N'iOS only'), (2582, 2530, N'Android only'), (2583, 2530, N'iOS and Android'), (2584, 2532, N'View'), (2585, 2532, N'Div'), (2586, 2532, N'Container'), (2587, 2532, N'Box'), (2588, 2533, N'Using external CSS files'), (2589, 2533, N'Using JavaScript objects with StyleSheet'), (2590, 2533, N'Using inline style attributes'), (2591, 2533, N'Using SASS files'), (2592, 2535, N'Grid'), (2593, 2535, N'Flexbox'), (2594, 2535, N'Absolute positioning'), (2595, 2535, N'Float'), (2596, 2536, N'Text'), (2597, 2536, N'Label'), (2598, 2536, N'String'), (2599, 2536, N'Paragraph'), (2600, 2538, N'React Router'), (2601, 2538, N'Expo Router'), (2602, 2538, N'React Navigation'), (2603, 2538, N'Native Navigator'), (2604, 2539, N'Button'), (2605, 2539, N'TouchableHighlight'), (2606, 2539, N'TouchableOpacity'), (2607, 2539, N'Pressable'), (2608, 2541, N'Using the Fetch API'), (2609, 2541, N'Using the Axios library'), (2610, 2541, N'Using XMLHttpRequest'), (2611, 2541, N'All of the above'), (2612, 2543, N'ScrollView'), (2613, 2543, N'ListView'), (2614, 2543, N'FlatList'), (2615, 2543, N'VirtualizedList'), (2616, 2544, N'Web modules'), (2617, 2544, N'Native modules'), (2618, 2544, N'The DOM'), (2619, 2544, N'The browser');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: Flutter & Dart Development
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2620, 2545, N'JavaScript'), (2621, 2545, N'Kotlin'), (2622, 2545, N'Swift'), (2623, 2545, N'Dart'), (2624, 2547, N'Column'), (2625, 2547, N'Row'), (2626, 2547, N'Stack'), (2627, 2547, N'Container'), (2628, 2548, N'StatefulWidget'), (2629, 2548, N'StatelessWidget'), (2630, 2548, N'ComponentWidget'), (2631, 2548, N'ViewWidget'), (2632, 2550, N'runApp()'), (2633, 2550, N'main()'), (2634, 2550, N'start()'), (2635, 2550, N'build()'), (2636, 2551, N'Components'), (2637, 2551, N'Elements'), (2638, 2551, N'Widgets'), (2639, 2551, N'Blocks'), (2640, 2553, N'Row'), (2641, 2553, N'List'), (2642, 2553, N'Column'), (2643, 2553, N'Stack'), (2644, 2554, N'By calling updateState()'), (2645, 2554, N'By directly modifying the state'), (2646, 2554, N'By calling build()'), (2647, 2554, N'By calling setState()'), (2648, 2556, N'Container'), (2649, 2556, N'MaterialApp'), (2650, 2556, N'Scaffold'), (2651, 2556, N'Screen'), (2652, 2558, N'Container'), (2653, 2558, N'Padding'), (2654, 2558, N'Margin'), (2655, 2558, N'SizedBox'), (2656, 2559, N'Initializing state'), (2657, 2559, N'Handling user input'), (2658, 2559, N'Describing the widget''s UI'), (2659, 2559, N'Fetching data');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: Working with APIs & State Management
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2660, 2560, N'Application Programming Interface'), (2661, 2560, N'Automated Program Interaction'), (2662, 2560, N'Application Protocol Interface'), (2663, 2560, N'Applied Programming Interchange'), (2664, 2562, N'fetch'), (2665, 2562, N'http'), (2666, 2562, N'request'), (2667, 2562, N'axios'), (2668, 2563, N'React Context'), (2669, 2563, N'Redux'), (2670, 2563, N'MobX'), (2671, 2563, N'Zustand'), (2672, 2565, N'GET'), (2673, 2565, N'POST'), (2674, 2565, N'PUT'), (2675, 2565, N'DELETE'), (2676, 2566, N'Calling a reducer directly'), (2677, 2566, N'Dispatching an action'), (2678, 2566, N'Modifying the store object'), (2679, 2566, N'Creating a new store'), (2680, 2568, N'An action'), (2681, 2568, N'A component'), (2682, 2568, N'Middleware'), (2683, 2568, N'A reducer'), (2684, 2569, N'Ends the function immediately'), (2685, 2569, N'Makes a function asynchronous'), (2686, 2569, N'Pauses the execution of an async function'), (2687, 2569, N'Returns a Promise'), (2688, 2571, N'A state management pattern'), (2689, 2571, N'Passing props down through multiple component layers'), (2690, 2571, N'An anti-pattern in React'), (2691, 2571, N'A way to fetch data'), (2692, 2573, N'The components'), (2693, 2573, N'The reducers'), (2694, 2573, N'The actions'), (2695, 2573, N'The store'), (2696, 2574, N'To create a new resource'), (2697, 2574, N'To request data from a specified resource'), (2698, 2574, N'To update an existing resource'), (2699, 2574, N'To delete a resource');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: UI/UX for Mobile
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2700, 2575, N'User Interface'), (2701, 2575, N'User Engagement'), (2702, 2575, N'User Experience'), (2703, 2575, N'User Exploration'), (2704, 2577, N'Prototype'), (2705, 2577, N'Mockup'), (2706, 2577, N'Wireframe'), (2707, 2577, N'Sketch'), (2708, 2578, N'UI Design'), (2709, 2578, N'Graphic Design'), (2710, 2578, N'User Research'), (2711, 2578, N'Market Analysis'), (2712, 2580, N'Style Guide'), (2713, 2580, N'Component Library'), (2714, 2580, N'Brand Identity'), (2715, 2580, N'Design System'), (2716, 2581, N'Human Interface Guidelines'), (2717, 2581, N'Fluent Design'), (2718, 2581, N'Material Design'), (2719, 2581, N'Ant Design'), (2720, 2583, N'A/B Testing'), (2721, 2583, N'Usability Testing'), (2722, 2583, N'Unit Testing'), (2723, 2583, N'Focus Groups'), (2724, 2584, N'A real user profile'), (2725, 2584, N'A marketing segment'), (2726, 2584, N'A stakeholder analysis'), (2727, 2584, N'A fictional character representing a target user type'), (2728, 2586, N'Material Design'), (2729, 2586, N'Human Interface Guidelines'), (2730, 2586, N'iOS Design System'), (2731, 2586, N'Cupertino Design'), (2732, 2588, N'Visual Design'), (2733, 2588, N'Information Architecture'), (2734, 2588, N'User Flow'), (2735, 2588, N'Interaction Design'), (2736, 2589, N'To make the product look beautiful'), (2737, 2589, N'To follow the latest design trends'), (2738, 2589, N'To improve user satisfaction'), (2739, 2589, N'To increase the number of features');

-- Department: System Development, Track: Front-End and Cross Platform Mobile Development, Course: Cross-Platform App Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (2740, 2590, N'Development'), (2741, 2590, N'Testing'), (2742, 2590, N'Deployment'), (2743, 2590, N'Requirement Analysis'), (2744, 2592, N'Jira'), (2745, 2592, N'Slack'), (2746, 2592, N'Git'), (2747, 2592, N'Figma'), (2748, 2593, N'Superior performance'), (2749, 2593, N'Access to native APIs'), (2750, 2593, N'Code reusability and cost-effectiveness'), (2751, 2593, N'Simpler development process'), (2752, 2595, N'Planning'), (2753, 2595, N'Designing'), (2754, 2595, N'Coding'), (2755, 2595, N'Testing'), (2756, 2596, N'Maximum Value Product'), (2757, 2596, N'Minimum Viable Product'), (2758, 2596, N'Most Valuable Player'), (2759, 2596, N'Minimum Valid Product'), (2760, 2598, N'User Manual'), (2761, 2598, N'Marketing Plan'), (2762, 2598, N'Specification Document'), (2763, 2598, N'Test Plan'), (2764, 2599, N'Integration'), (2765, 2599, N'Deployment'), (2766, 2599, N'Compilation'), (2767, 2599, N'Versioning'), (2768, 2601, N'Slow development speed'), (2769, 2601, N'High cost of development'), (2770, 2601, N'Achieving a native look and feel'), (2771, 2601, N'Lack of community support'), (2772, 2603, N'Unit Testing'), (2773, 2603, N'Integration Testing'), (2774, 2603, N'User Acceptance Testing (UAT)'), (2775, 2603, N'Regression Testing'), (2776, 2604, N'Hiring developers'), (2777, 2604, N'Choosing a color scheme'), (2778, 2604, N'Defining milestones'), (2779, 2604, N'Writing code');


--Track 7 iOS Mobile Application Development Questions ========================================================================================

-- Department: System Development, Track: iOS Mobile Application Development, Course: Swift Programming Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3000, 43, N'MCQ', N'Which keyword is used to declare a constant in Swift?', N'let'), (3001, 43, N'True/False', N'A `struct` in Swift can have inheritance.', N'False'), (3002, 43, N'MCQ', N'What is a variable that can hold a value or no value called?', N'Optional'), (3003, 43, N'MCQ', N'Which control flow statement is used for pattern matching?', N'switch'), (3004, 43, N'True/False', N'Swift is a statically typed language.', N'True'), (3005, 43, N'MCQ', N'What symbol is used to unwrap an optional if you are sure it contains a value?', N'!'), (3006, 43, N'MCQ', N'Which of these is a value type?', N'Struct'), (3007, 43, N'True/False', N'The `var` keyword is used for declaring mutable variables.', N'True'), (3008, 43, N'MCQ', N'What is the term for a function that is defined inside another function?', N'Nested Function'), (3009, 43, N'MCQ', N'A block of self-contained code that can be passed around is a...?', N'Closure'), (3010, 43, N'True/False', N'A class in Swift is a reference type.', N'True'), (3011, 43, N'MCQ', N'How do you safely unwrap an optional?', N'if let'), (3012, 43, N'True/False', N'Swift requires semicolons at the end of every statement.', N'False'), (3013, 43, N'MCQ', N'Which collection type stores an ordered list of items?', N'Array'), (3014, 43, N'MCQ', N'What provides default values for properties if an instance is deinitialized?', N'deinit');

-- Department: System Development, Track: iOS Mobile Application Development, Course: iOS Development with UIKit & SwiftUI
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3015, 44, N'MCQ', N'Which framework is Apple''s modern, declarative UI framework?', N'SwiftUI'), (3016, 44, N'True/False', N'UIKit uses a declarative syntax to build user interfaces.', N'False'), (3017, 44, N'MCQ', N'In UIKit, what is the fundamental building block for UI?', N'UIView'), (3018, 44, N'MCQ', N'In SwiftUI, what property wrapper is used to manage a view''s own state?', N'@State'), (3019, 44, N'True/False', N'A `UIViewController` manages a view hierarchy in UIKit.', N'True'), (3020, 44, N'MCQ', N'What is the main component of a SwiftUI view that describes its content?', N'The `body` property'), (3021, 44, N'MCQ', N'Which file in a UIKit project often handles app lifecycle events?', N'AppDelegate'), (3022, 44, N'True/False', N'SwiftUI views are structs.', N'True'), (3023, 44, N'MCQ', N'To create a vertical list of views in SwiftUI, you would use a...?', N'VStack'), (3024, 44, N'MCQ', N'What is the visual editor for UI in Xcode for UIKit called?', N'Interface Builder'), (3025, 44, N'True/False', N'In SwiftUI, UI updates automatically when state changes.', N'True'), (3026, 44, N'MCQ', N'What object in UIKit represents a single screen of content?', N'UIViewController'), (3027, 44, N'True/False', N'SwiftUI can be used in existing UIKit apps.', N'True'), (3028, 44, N'MCQ', N'Which property wrapper connects a SwiftUI view to an observable object?', N'@ObservedObject'), (3029, 44, N'MCQ', N'A `UILabel` is a component from which framework?', N'UIKit');

-- Department: System Development, Track: iOS Mobile Application Development, Course: Navigation & Layout
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3030, 45, N'MCQ', N'What system is used to define adaptive layouts in UIKit?', N'Auto Layout'), (3031, 45, N'True/False', N'In SwiftUI, `HStack` is used to arrange views vertically.', N'False'), (3032, 45, N'MCQ', N'A set of rules that governs the position and size of a view is a...?', N'Constraint'), (3033, 45, N'MCQ', N'Which UIKit container view controller manages a stack of other view controllers?', N'UINavigationController'), (3034, 45, N'True/False', N'A `UIStackView` automatically creates Auto Layout constraints for its arranged subviews.', N'True'), (3035, 45, N'MCQ', N'In SwiftUI, what view is used to create a tappable navigation link?', N'NavigationLink'), (3036, 45, N'MCQ', N'What UIKit component displays a row of buttons at the bottom of the screen for navigation?', N'UITabBarController'), (3037, 45, N'True/False', N'Intrinsic content size refers to a view''s natural, preferred size.', N'True'), (3038, 45,  N'MCQ', N'In SwiftUI, what view is used to layer child views on top of each other?', N'ZStack'), (3039, 45, N'MCQ', N'A transition from one screen to another in UIKit is called a...?', N'Segue'), (3040, 45, N'True/False', N'You must always define both X and Y position constraints for a view.', N'True'), (3041, 45, N'MCQ', N'Which view in SwiftUI creates a scrollable container?', N'ScrollView'), (3042, 45, N'True/False', N'Constraints with a priority of 1000 are optional.', N'False'), (3043, 45, N'MCQ', N'Which SwiftUI view is used for presenting modal content?', N'Sheet'), (3044, 45, N'MCQ', N'What does "Safe Area" refer to?', N'The portion of a view that is unobscured by system elements');

-- Department: System Development, Track: iOS Mobile Application Development, Course: APIs & Core Data
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3045, 46, N'MCQ', N'Which Swift protocol is used for easy JSON parsing?', N'Codable'), (3046, 46, N'True/False', N'Core Data is a relational database.', N'False'), (3047, 46, N'MCQ', N'What is the primary class for making network requests in iOS?', N'URLSession'), (3048, 46, N'MCQ', N'In Core Data, what object represents a single record in the data store?', N'NSManagedObject'), (3049, 46, N'True/False', N'A REST API uses the HTTP protocol for communication.', N'True'), (3050, 46, N'MCQ', N'What is the Core Data stack encapsulated by in modern iOS?', N'NSPersistentContainer'), (3051, 46, N'MCQ', N'Which HTTP method is typically used to retrieve data from a server?', N'GET'), (3052, 46, N'True/False', N'The `JSONDecoder` is used to convert Swift objects into JSON data.', N'False'), (3053, 46, N'MCQ', N'A request to fetch data from Core Data is made using a...?', N'NSFetchRequest'), (3054, 46, N'MCQ', N'What is the purpose of Core Data''s visual data model editor?', N'To define entities and their attributes'), (3055, 46, N'True/False', N'All network requests should be made on the main UI thread.', N'False'), (3056, 46, N'MCQ', N'What does "CRUD" stand for in the context of data management?', N'Create, Read, Update, Delete'), (3057, 46, N'True/False', N'Core Data is a framework provided by Apple for data persistence.', N'True'), (3058, 46, N'MCQ', N'What object contains the response from a URLSession task?', N'URLResponse'), (3059, 46, N'MCQ', N'The schema of your Core Data model is defined by the...?', N'NSManagedObjectModel');

-- Department: System Development, Track: iOS Mobile Application Development, Course: iOS Design Patterns & Concurrency
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3060, 47, N'MCQ', N'Which design pattern is Apple''s traditional choice for iOS apps?', N'MVC'), (3061, 47, N'True/False', N'The Singleton pattern ensures that a class has only one instance.', N'True'), (3062, 47, N'MCQ', N'What design pattern uses a protocol to enable one object to communicate back to another?', N'Delegate'), (3063, 47, N'MCQ', N'What does GCD stand for?', N'Grand Central Dispatch'), (3064, 47, N'True/False', N'MVVM stands for Model-View-ViewModel.', N'True'), (3065, 47, N'MCQ', N'Which GCD queue should be used for all UI updates?', N'The main queue'), (3066, 47, N'MCQ', N'The modern way to handle concurrency in Swift is with...?', N'async/await'), (3067, 47, N'True/False', N'A race condition occurs when multiple threads access shared data simultaneously.', N'True'), (3068, 47, N'MCQ', N'In MVC, which component is responsible for the business logic?', N'Model'), (3069, 47, N'MCQ', N'What is a key benefit of the MVVM pattern?', N'Improved testability'), (3070, 47, N'True/False', N'A concurrent queue executes tasks one at a time in order.', N'False'), (3071, 47, N'MCQ', N'The `await` keyword can only be used inside a function marked with...?', N'async'), (3072, 47, N'True/False', N'The Observer pattern defines a one-to-many dependency between objects.', N'True'), (3073, 47, N'MCQ', N'Which design pattern provides a simplified interface to a complex subsystem?', N'Facade'), (3074, 47, N'MCQ', N'Which quality of service (QoS) class is for user-initiated tasks?', N'User-initiated');

-- Department: System Development, Track: iOS Mobile Application Development, Course: Testing & Publishing to App Store
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3075, 48, N'MCQ', N'What is Apple''s framework for writing unit and UI tests?', N'XCTest'), (3076, 48, N'True/False', N'Unit tests are used to check the functionality of the entire app from a user''s perspective.', N'False'), (3077, 48, N'MCQ', N'What is the platform for distributing beta versions of your app?', N'TestFlight'), (3078, 48, N'MCQ', N'What website is used to manage your app on the App Store?', N'App Store Connect'), (3079, 48, N'True/False', N'A Provisioning Profile links developers and devices to a development team.', N'True'), (3080, 48, N'MCQ', N'Testing individual functions or methods in isolation is called...?', N'Unit Testing'), (3081, 48, N'MCQ', N'What is required to sign and provision an app for release?', N'A Distribution Certificate'), (3082, 48, N'True/False', N'Anyone can download your app from TestFlight without an invitation.', N'False'), (3083, 48, N'MCQ', N'What does the `XCTAssert` function do?', N'Asserts that an expression is true'), (3084, 48, N'MCQ', N'The process of automating user interface interactions for testing is...?', N'UI Testing'), (3085, 48, N'True/False', N'The App Store review process is fully automated.', N'False'), (3086, 48, N'MCQ', N'What is the unique identifier for an app called?', N'Bundle ID'), (3087, 48, N'True/False', N'You must be a member of the Apple Developer Program to publish apps.', N'True'), (3088, 48, N'MCQ', N'What asset is crucial for your app''s branding on the App Store?', N'App Icon'), (3089, 48, N'MCQ', N'What is the main purpose of testing?', N'To find and fix bugs');

-- Department: System Development, Track: iOS Mobile Application Development, Course: Native iOS App Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3090, 49, N'MCQ', N'What is a primary goal of a capstone project?', N'To apply and integrate learned skills'), (3091, 49, N'True/False', N'Source control with Git is optional for a major development project.', N'False'), (3092, 49, N'MCQ', N'What is the practice of breaking down an app''s features into manageable tasks?', N'Project Planning'), (3093, 49, N'MCQ', N'A common way to manage third-party libraries in iOS is using...?', N'Swift Package Manager'), (3094, 49, N'True/False', N'Refactoring code is the process of adding new features.', N'False'), (3095, 49, N'MCQ', N'What is the term for finding and fixing bugs in your code?', N'Debugging'), (3096, 49, N'MCQ', N'Which of these is a key aspect of a good user experience?', N'Intuitive navigation'), (3097, 49, N'True/False', N'It is a good practice to handle potential errors gracefully in your app.', N'True'), (3098, 49, N'MCQ', N'Why is writing clean and readable code important?', N'It improves maintainability'), (3099, 49, N'MCQ', N'Which architectural pattern is often a good choice for a capstone project for testability?', N'MVVM'), (3100, 49, N'True/False', N'Performance optimization should only be considered after the app is finished.', N'False'), (3101, 49, N'MCQ', N'The process of ensuring an app is usable by people with disabilities is called...?', N'Accessibility'), (3102, 49, N'True/False', N'A good project includes documentation explaining its architecture and features.', N'True'), (3103, 49, N'MCQ', N'What does API stand for?', N'Application Programming Interface'), (3104, 49, N'MCQ', N'A successful project must meet the...?', N'Defined requirements');



-- Department: System Development, Track: iOS Mobile Application Development, Course: Swift Programming Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3000, 3000, N'var'), (3001, 3000, N'let'), (3002, 3000, N'const'), (3003, 3000, N'static'), (3004, 3002, N'Variable'), (3005, 3002, N'Tuple'), (3006, 3002, N'Optional'), (3007, 3002, N'Enum'), (3008, 3003, N'for'), (3009, 3003, N'if'), (3010, 3003, N'while'), (3011, 3003, N'switch'), (3012, 3005, N'?'), (3013, 3005, N'*'), (3014, 3005, N'!'), (3015, 3005, N'&'), (3016, 3006, N'Class'), (3017, 3006, N'Protocol'), (3018, 3006, N'Struct'), (3019, 3006, N'Function'), (3020, 3008, N'Closure'), (3021, 3008, N'Nested Function'), (3022, 3008, N'Higher-Order Function'), (3023, 3008, N'Sub-function'), (3024, 3009, N'Struct'), (3025, 3009, N'Protocol'), (3026, 3009, N'Closure'), (3027, 3009, N'Class'), (3028, 3011, N'guard let'), (3029, 3011, N'if let'), (3030, 3011, N'try?'), (3031, 3011, N'force unwrap'), (3032, 3013, N'Dictionary'), (3033, 3013, N'Set'), (3034, 3013, N'Array'), (3035, 3013, N'Tuple'), (3036, 3014, N'init'), (3037, 3014, N'deinit'), (3038, 3014, N'destroy'), (3039, 3014, N'dealloc');

-- Department: System Development, Track: iOS Mobile Application Development, Course: iOS Development with UIKit & SwiftUI
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3040, 3015, N'UIKit'), (3041, 3015, N'Core Data'), (3042, 3015, N'SwiftUI'), (3043, 3015, N'AppKit'), (3044, 3017, N'UIView'), (3045, 3017, N'CALayer'), (3046, 3017, N'UIWindow'), (3047, 3017, N'UIScreen'), (3048, 3018, N'@State'), (3049, 3018, N'@Binding'), (3050, 3018, N'@EnvironmentObject'), (3051, 3018, N'@ObservedObject'), (3052, 3020, N'The `view` property'), (3053, 3020, N'The `content` property'), (3054, 3020, N'The `body` property'), (3055, 3020, N'The `init` method'), (3056, 3021, N'ViewController'), (3057, 3021, N'SceneDelegate'), (3058, 3021, N'AppDelegate'), (3059, 3021, N'Info.plist'), (3060, 3023, N'HStack'), (3061, 3023, N'ZStack'), (3062, 3023, N'VStack'), (3063, 3023, N'List'), (3064, 3024, N'Interface Builder'), (3065, 3024, N'SwiftUI Preview'), (3066, 3024, N'Asset Catalog'), (3067, 3024, N'Storyboard'), (3068, 3026, N'UIView'), (3069, 3026, N'UIViewController'), (3070, 3026, N'UINavigationController'), (3071, 3026, N'UIWindow'), (3072, 3028, N'@State'), (3073, 3028, N'@Binding'), (3074, 3028, N'@Published'), (3075, 3028, N'@ObservedObject'), (3076, 3029, N'SwiftUI'), (3077, 3029, N'Core Graphics'), (3078, 3029, N'Foundation'), (3079, 3029, N'UIKit');

-- Department: System Development, Track: iOS Mobile Application Development, Course: Navigation & Layout
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3080, 3030, N'Auto Layout'), (3081, 3030, N'Stack Views'), (3082, 3030, N'Frame-based layout'), (3083, 3030, N'SwiftUI'), (3084, 3032, N'Frame'), (3085, 3032, N'Constraint'), (3086, 3032, N'Bound'), (3087, 3032, N'Anchor'), (3088, 3033, N'UIViewController'), (3089, 3033, N'UITabBarController'), (3090, 3033, N'UINavigationController'), (3091, 3033, N'UISplitViewController'), (3092, 3035, N'NavigationLink'), (3093, 3035, N'Button'), (3094, 3035, N'Sheet'), (3095, 3035, N'NavLink'), (3096, 3036, N'UINavigationController'), (3097, 3036, N'UISplitViewController'), (3098, 3036, N'UITabBarController'), (3099, 3036, N'UIPageViewController'), (3100, 3038, N'HStack'), (3101, 3038, N'VStack'), (3102, 3038, N'ZStack'), (3103, 3038, N'Group'), (3104, 3039, N'Transition'), (3105, 3039, N'Segue'), (3106, 3039, N'Push'), (3107, 3039, N'Modal'), (3108, 3041, N'List'), (3109, 3041, N'StackView'), (3110, 3041, N'Form'), (3111, 3041, N'ScrollView'), (3112, 3043, N'Alert'), (3113, 3043, N'Popover'), (3114, 3043, N'Sheet'), (3115, 3043, N'NavigationLink'), (3116, 3044, N'The entire screen area'), (3117, 3044, N'The area outside the bezels'), (3118, 3044, N'The portion of a view that is unobscured by system elements'), (3119, 3044, N'The main content area you define');

-- Department: System Development, Track: iOS Mobile Application Development, Course: APIs & Core Data
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3120, 3045, N'Serializable'), (3121, 3045, N'Decodable'), (3122, 3045, N'Codable'), (3123, 3045, N'Parsable'), (3124, 3047, N'URLRequest'), (3125, 3047, N'URLSession'), (3126, 3047, N'HTTPClient'), (3127, 3047, N'NetworkManager'), (3128, 3048, N'NSEntityDescription'), (3129, 3048, N'NSManagedObject'), (3130, 3048, N'NSManagedObjectContext'), (3131, 3048, N'NSPersistentStore'), (3132, 3050, N'NSManagedObjectContext'), (3133, 3050, N'NSPersistentStoreCoordinator'), (3134, 3050, N'NSPersistentContainer'), (3135, 3050, N'NSManagedObjectModel'), (3136, 3051, N'GET'), (3137, 3051, N'POST'), (3138, 3051, N'PUT'), (3139, 3051, N'DELETE'), (3140, 3053, N'NSQuery'), (3141, 3053, N'NSFetchRequest'), (3142, 3053, N'NSDataRequest'), (3143, 3053, N'NSPredicate'), (3144, 3054, N'To write fetch requests'), (3145, 3054, N'To define entities and their attributes'), (3146, 3054, N'To manage the persistent store'), (3147, 3054, N'To create managed object contexts'), (3148, 3056, N'Create, Review, Update, Destroy'), (3149, 3056, N'Copy, Read, Undo, Delete'), (3150, 3056, N'Create, Read, Update, Delete'), (3151, 3056, N'Connect, Receive, Utilize, Disconnect'), (3152, 3058, N'URLRequest'), (3153, 3058, N'URLResponse'), (3154, 3058, N'HTTPURLResponse'), (3155, 3058, N'Data'), (3156, 3059, N'NSPersistentStoreCoordinator'), (3157, 3059, N'NSManagedObjectModel'), (3158, 3059, N'NSManagedObjectContext'), (3159, 3059, N'NSEntityDescription');

-- Department: System Development, Track: iOS Mobile Application Development, Course: iOS Design Patterns & Concurrency
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3160, 3060, N'MVVM'), (3161, 3060, N'MVC'), (3162, 3060, N'VIPER'), (3163, 3060, N'Singleton'), (3164, 3062, N'Singleton'), (3165, 3062, N'Observer'), (3166, 3062, N'Delegate'), (3167, 3062, N'Facade'), (3168, 3063, N'Grand Central Dispatch'), (3169, 3063, N'Graphic Computation Driver'), (3170, 3063, N'General Concurrency Driver'), (3171, 3063, N'Grouped Central Dispatch'), (3172, 3065, N'A background queue'), (3173, 3065, N'Any serial queue'), (3174, 3065, N'The main queue'), (3175, 3065, N'A concurrent queue'), (3176, 3066, N'Callbacks'), (3177, 3066, N'Delegates'), (3178, 3066, N'GCD'), (3179, 3066, N'async/await'), (3180, 3068, N'View'), (3181, 3068, N'Controller'), (3182, 3068, N'Model'), (3183, 3068, N'ViewModel'), (3184, 3069, N'Simplicity'), (3185, 3069, N'Less code'), (3186, 3069, N'Improved testability'), (3187, 3069, N'Faster performance'), (3188, 3071, N'await'), (3189, 3071, N'sync'), (3190, 3071, N'throws'), (3191, 3071, N'async'), (3192, 3073, N'Adapter'), (3193, 3073, N'Facade'), (3194, 3073, N'Decorator'), (3195, 3073, N'Factory'), (3196, 3074, N'Background'), (3197, 3074, N'User-initiated'), (3198, 3074, N'Utility'), (3199, 3074, N'Default');

-- Department: System Development, Track: iOS Mobile Application Development, Course: Testing & Publishing to App Store
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3200, 3075, N'OCUnit'), (3201, 3075, N'Quick/Nimble'), (3202, 3075, N'XCTest'), (3203, 3075, N'SwiftCheck'), (3204, 3077, N'App Store'), (3205, 3077, N'TestFlight'), (3206, 3077, N'Xcode Cloud'), (3207, 3077, N'iTunes Connect'), (3208, 3078, N'developer.apple.com'), (3209, 3078, N'App Store Connect'), (3210, 3078, N'iCloud'), (3211, 3078, N'Xcode'), (3212, 3080, N'UI Testing'), (3213, 3080, N'Integration Testing'), (3214, 3080, N'Unit Testing'), (3215, 3080, N'Beta Testing'), (3216, 3081, N'A Development Certificate'), (3217, 3081, N'A Distribution Certificate'), (3218, 3081, N'An Ad Hoc Certificate'), (3219, 3081, N'A Developer ID Certificate'), (3220, 3083, N'Asserts that an expression is false'), (3221, 3083, N'Asserts that two values are equal'), (3222, 3083, N'Asserts that an object is nil'), (3223, 3083, N'Asserts that an expression is true'), (3224, 3084, N'Unit Testing'), (3225, 3084, N'UI Testing'), (3226, 3084, N'Manual Testing'), (3227, 3084, N'Snapshot Testing'), (3228, 3086, N'App ID'), (3229, 3086, N'Bundle ID'), (3230, 3086, N'Team ID'), (3231, 3086, N'Product ID'), (3232, 3088, N'Screenshots'), (3233, 3088, N'App Icon'), (3234, 3088, N'App Preview Video'), (3235, 3088, N'Description'), (3236, 3089, N'To write more code'), (3237, 3089, N'To prove the code works'), (3238, 3089, N'To find and fix bugs'), (3239, 3089, N'To satisfy management');

-- Department: System Development, Track: iOS Mobile Application Development, Course: Native iOS App Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3240, 3090, N'To focus on one specific skill'), (3241, 3090, N'To build a simple, single-screen app'), (3242, 3090, N'To apply and integrate learned skills'), (3243, 3090, N'To learn a new programming language'), (3244, 3092, N'Debugging'), (3245, 3092, N'Refactoring'), (3246, 3092, N'Project Planning'), (3247, 3092, N'Deployment'), (3248, 3093, N'CocoaPods'), (3249, 3093, N'Carthage'), (3250, 3093, N'Swift Package Manager'), (3251, 3093, N'All of the above'), (3252, 3095, N'Programming'), (3253, 3095, N'Debugging'), (3254, 3095, N'Compiling'), (3255, 3095, N'Designing'), (3256, 3096, N'Complex animations'), (3257, 3096, N'Use of many colors'), (3258, 3096, N'Intuitive navigation'), (3259, 3096, N'Lots of features'), (3260, 3098, N'It runs faster'), (3261, 3098, N'It uses less memory'), (3262, 3098, N'It improves maintainability'), (3263, 3098, N'It impresses other developers'), (3264, 3099, N'MVC'), (3265, 3099, N'Singleton'), (3266, 3099, N'MVVM'), (3267, 3099, N'VIPER'), (3268, 3101, N'Internationalization'), (3269, 3101, N'Accessibility'), (3270, 3101, N'Localization'), (3271, 3101, N'Optimization'), (3272, 3103, N'Application Programming Interface'), (3273, 3103, N'Apple Programming Interface'), (3274, 3103, N'Application Protocol Interaction'), (3275, 3103, N'Applied Programming Instruction'), (3276, 3104, N'Defined requirements'), (3277, 3104, N'Budget'), (3278, 3104, N'Timeline'), (3279, 3104, N'Latest iOS version');


--Track 8  Software Development Fundamentals Questions ===============================================================================================================================

-- Department: System Development, Track: Software Development Fundamentals, Course: Programming Logic & Algorithms
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3500, 50, N'MCQ', N'What is a step-by-step procedure for solving a problem called?', N'Algorithm'), (3501, 50, N'True/False', N'A flowchart is a textual representation of an algorithm.', N'False'), (3502, 50, N'MCQ', N'Which structure executes a sequence of statements only if a condition is true?', N'Selection'), (3503, 50, N'MCQ', N'Which loop structure is guaranteed to execute at least once?', N'do-while'), (3504, 50, N'True/False', N'Pseudocode is a formal programming language.', N'False'), (3505, 50, N'MCQ', N'The process of breaking a problem into smaller, manageable parts is called...?', N'Decomposition'), (3506, 50, N'MCQ', N'Which of these is a basic logical operator?', N'AND'), (3507, 50, N'True/False', N'A variable is a named storage location in memory.', N'True'), (3508, 50, N'MCQ', N'What is the term for a logical error in a program?', N'Bug'), (3509, 50, N'MCQ', N'Which structure allows for repeated execution of a block of code?', N'Iteration'), (3510, 50, N'True/False', N'Binary search is more efficient than linear search on a sorted list.', N'True'), (3511, 50, N'MCQ', N'What does IPO stand for in the context of program logic?', N'Input, Processing, Output'), (3512, 50, N'True/False', N'An infinite loop is a desirable feature in most programs.', N'False'), (3513, 50, N'MCQ', N'A graphical representation of an algorithm is a...?', N'Flowchart'), (3514, 50, N'MCQ', N'Which of these is NOT a fundamental control structure?', N'Variable declaration');

-- Department: System Development, Track: Software Development Fundamentals, Course: C# & OOP Principles
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3515, 51, N'MCQ', N'Which keyword is used to create an object from a class in C#?', N'new'), (3516, 51, N'True/False', N'Encapsulation is the bundling of data and methods that operate on the data.', N'True'), (3517, 51, N'MCQ', N'The ability of a class to derive properties from another class is called...?', N'Inheritance'), (3518, 51, N'MCQ', N'In C#, which is a value type?', N'struct'), (3519, 51, N'True/False', N'A class can inherit from multiple other classes in C#.', N'False'), (3520, 51, N'MCQ', N'What is the entry point method for a C# console application?', N'Main'), (3521, 51, N'MCQ', N'The OOP concept of taking on many forms is known as...?', N'Polymorphism'), (3522, 51, N'True/False', N'An `interface` in C# can contain implementation code for its methods.', N'False'), (3523, 51, N'MCQ', N'What access modifier makes a member accessible only within its own class?', N'private'), (3524, 51, N'MCQ', N'A special method for creating and initializing an object is a...?', N'Constructor'), (3525, 51, N'True/False', N'The `this` keyword refers to the current instance of the class.', N'True'), (3526, 51, N'MCQ', N'Hiding complex implementation details from the user is...?', N'Abstraction'), (3527, 51, N'True/False', N'A `string` in C# is a reference type.', N'True'), (3528, 51, N'MCQ', N'What keyword allows a method in a derived class to have a specific implementation?', N'override'), (3529, 51, N'MCQ', N'What does OOP stand for?', N'Object-Oriented Programming');

-- Department: System Development, Track: Software Development Fundamentals, Course: Data Structures
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3530, 52, N'MCQ', N'Which data structure uses a Last-In, First-Out (LIFO) approach?', N'Stack'), (3531, 52, N'True/False', N'Elements in an array are accessed using a key.', N'False'), (3532, 52, N'MCQ', N'Which data structure uses a First-In, First-Out (FIFO) approach?', N'Queue'), (3533, 52, N'MCQ', N'A data structure consisting of nodes, where each node points to the next, is a...?', N'Linked List'), (3534, 52, N'True/False', N'A binary search tree is always perfectly balanced.', N'False'), (3535, 52, N'MCQ', N'What is the term for adding an element to a stack?', N'Push'), (3536, 52, N'MCQ', N'Which data structure is ideal for storing key-value pairs?', N'Hash Table'), (3537, 52, N'True/False', N'Accessing an element in a linked list by its position is very fast.', N'False'), (3538, 52, N'MCQ', N'A tree data structure where each node has at most two children is a...?', N'Binary Tree'), (3539, 52, N'MCQ', N'What is the term for removing an element from a queue?', N'Dequeue'), (3540, 52, N'True/False', N'An array has a fixed size that is defined at the time of its creation.', N'True'), (3541, 52, N'MCQ', N'The top-most node in a tree is called the...?', N'Root'), (3542, 52, N'True/False', N'A stack can be implemented using an array.', N'True'), (3543, 52, N'MCQ', N'What is the main advantage of a linked list over an array?', N'Dynamic size'), (3544, 52, N'MCQ', N'What is a "collision" in a hash table?', N'When two keys hash to the same index');

-- Department: System Development, Track: Software Development Fundamentals, Course: Intro to Databases & SQL
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3545, 53, N'MCQ', N'What does SQL stand for?', N'Structured Query Language'), (3546, 53, N'True/False', N'A primary key in a table can contain NULL values.', N'False'), (3547, 53, N'MCQ', N'Which SQL statement is used to extract data from a database?', N'SELECT'), (3548, 53, N'MCQ', N'A relational database organizes data into...?', N'Tables'), (3549, 53, N'True/False', N'The `WHERE` clause is used to filter records.', N'True'), (3550, 53, N'MCQ', N'Which key uniquely identifies a record in a table?', N'Primary Key'), (3551, 53, N'MCQ', N'Which type of JOIN returns rows when there is a match in both tables?', N'INNER JOIN'), (3552, 53, N'True/False', N'`DELETE` is a DDL (Data Definition Language) command.', N'False'), (3553, 53, N'MCQ', N'What is a column in a table called?', N'Attribute'), (3554, 53, N'MCQ', N'Which SQL statement is used to add new data to a database?', N'INSERT INTO'), (3555, 53, N'True/False', N'A foreign key is a key used to link two tables together.', N'True'), (3556, 53, N'MCQ', N'What is a row in a table called?', N'Tuple'), (3557, 53, N'True/False', N'Normalization is the process of organizing columns and tables to minimize data redundancy.', N'True'), (3558, 53, N'MCQ', N'Which statement is used to modify existing records in a table?', N'UPDATE'), (3559, 53, N'MCQ', N'What does RDBMS stand for?', N'Relational Database Management System');

-- Department: System Development, Track: Software Development Fundamentals, Course: Web Dev Essentials (HTML/CSS/JS)
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3560, 54, N'MCQ', N'What does HTML stand for?', N'HyperText Markup Language'), (3561, 54, N'True/False', N'JavaScript is primarily used to style web pages.', N'False'), (3562, 54, N'MCQ', N'What does CSS stand for?', N'Cascading Style Sheets'), (3563, 54, N'MCQ', N'Which HTML tag defines the main content of the document?', N'<body>'), (3564, 54, N'True/False', N'An ID selector in CSS is prefixed with a hash (#) character.', N'True'), (3565, 54, N'MCQ', N'How do you declare a variable in JavaScript?', N'var, let, or const'), (3566, 54, N'MCQ', N'Which CSS property controls the text color?', N'color'), (3567, 54, N'True/False', N'The `<p>` tag is used to create a hyperlink.', N'False'), (3568, 54, N'MCQ', N'What is the correct way to link an external stylesheet in HTML?', N'<link rel="stylesheet" href="style.css">'), (3569, 54, N'MCQ', N'What is the DOM?', N'A programming interface for web documents'), (3570, 54, N'True/False', N'A class selector in CSS is prefixed with a period (.).', N'True'), (3571, 54, N'MCQ', N'Which of these is used to create a numbered list in HTML?', N'<ol>'), (3572, 54, N'True/False', N'JavaScript code must be placed inside the `<head>` tag of an HTML document.', N'False'), (3573, 54, N'MCQ', N'The CSS box model consists of the content, padding, border, and...?', N'Margin'), (3574, 54, N'MCQ', N'What does `document.getElementById("demo")` do?', N'Finds an HTML element with id="demo"');

-- Department: System Development, Track: Software Development Fundamentals, Course: Git & SDLC
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3575, 55, N'MCQ', N'What does SDLC stand for?', N'Software Development Life Cycle'), (3576, 55, N'True/False', N'The Waterfall model is an iterative and flexible approach to development.', N'False'), (3577, 55, N'MCQ', N'Which SDLC model emphasizes continuous feedback and small, rapid releases?', N'Agile'), (3578, 55, N'MCQ', N'What is Git?', N'A distributed version control system'), (3579, 55, N'True/False', N'In Git, a "commit" saves your changes to the remote repository.', N'False'), (3580, 55, N'MCQ', N'Which Git command is used to download a repository from a remote source?', N'git clone'), (3581, 55, N'MCQ', N'Which SDLC phase involves writing the code?', N'Implementation'), (3582, 55, N'True/False', N'`git push` is used to fetch and merge changes from the remote repository.', N'False'), (3583, 55, N'MCQ', N'What is the purpose of the "Testing" phase in SDLC?', N'To find and fix defects'), (3584, 55, N'MCQ', N'Which command stages changes in Git for the next commit?', N'git add'), (3585, 55, N'True/False', N'A "branch" in Git is a separate line of development.', N'True'), (3586, 55, N'MCQ', N'What is the first phase of a typical SDLC?', N'Planning/Requirement Analysis'), (3587, 55, N'True/False', N'GitHub is the same thing as Git.', N'False'), (3588, 55, N'MCQ', N'Which command combines the history of two branches?', N'git merge'), (3589, 55, N'MCQ', N'What is the final phase of the SDLC?', N'Maintenance');

-- Department: System Development, Track: Software Development Fundamentals, Course: Fundamentals Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (3590, 56, N'MCQ', N'What is the primary purpose of a capstone project?', N'To demonstrate integrated skills'), (3591, 56, N'True/False', N'A requirements document should be created after the coding is complete.', N'False'), (3592, 56, N'MCQ', N'The process of finding and fixing errors in code is called...?', N'Debugging'), (3593, 56, N'MCQ', N'Which of these is an essential tool for collaborative projects?', N'Version Control System'), (3594, 56, N'True/False', N'"Scope creep" refers to the project staying within its original boundaries.', N'False'), (3595, 56, N'MCQ', N'Breaking a large application into smaller, independent parts is called...?', N'Modular Design'), (3596, 56, N'MCQ', N'What is the practice of writing code that is easy to read and understand?', N'Clean Code'), (3597, 56, N'True/False', N'User feedback is not important during the development process.', N'False'), (3598, 56, N'MCQ', N'Which of the following is a type of testing?', N'Unit Testing'), (3599, 56, N'MCQ', N'What is the final step before a project is considered complete?', N'Deployment'), (3600, 56, N'True/False', N'Hardcoding values like connection strings is a good practice.', N'False'), (3601, 56, N'MCQ', N'What should good project documentation include?', N'Setup instructions and design choices'), (3602, 56, N'True/False', N'A project plan helps in tracking progress and managing deadlines.', N'True'), (3603, 56, N'MCQ', N'What is refactoring?', N'Improving code structure without changing its external behavior'), (3604, 56, N'MCQ', N'Which principle suggests that a class should have only one reason to change?', N'Single Responsibility Principle');


-- Department: System Development, Track: Software Development Fundamentals, Course: Programming Logic & Algorithms
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3500, 3500, N'Flowchart'), (3501, 3500, N'Pseudocode'), (3502, 3500, N'Algorithm'), (3503, 3500, N'Variable'), (3504, 3502, N'Sequence'), (3505, 3502, N'Iteration'), (3506, 3502, N'Selection'), (3507, 3502, N'Recursion'), (3508, 3503, N'for'), (3509, 3503, N'while'), (3510, 3503, N'if-else'), (3511, 3503, N'do-while'), (3512, 3505, N'Integration'), (3513, 3505, N'Decomposition'), (3514, 3505, N'Compilation'), (3515, 3505, N'Abstraction'), (3516, 3506, N'ADD'), (3517, 3506, N'AND'), (3518, 3506, N'IF'), (3519, 3506, N'SUM'), (3520, 3508, N'Feature'), (3521, 3508, N'Syntax error'), (3522, 3508, N'Comment'), (3523, 3508, N'Bug'), (3524, 3509, N'Variable'), (3525, 3509, N'Assignment'), (3526, 3509, N'Iteration'), (3527, 3509, N'Condition'), (3528, 3511, N'Input, Program, Output'), (3529, 3511, N'Initialize, Process, Organize'), (3530, 3511, N'Input, Processing, Output'), (3531, 3511, N'Insert, Print, Order'), (3532, 3513, N'Pseudocode'), (3533, 3513, N'UML Diagram'), (3534, 3513, N'Code'), (3535, 3513, N'Flowchart'), (3536, 3514, N'Iteration'), (3537, 3514, N'Selection'), (3538, 3514, N'Sequence'), (3539, 3514, N'Variable declaration');

-- Department: System Development, Track: Software Development Fundamentals, Course: C# & OOP Principles
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3540, 3515, N'create'), (3541, 3515, N'new'), (3542, 3515, N'object'), (3543, 3515, N'instance'), (3544, 3517, N'Polymorphism'), (3545, 3517, N'Encapsulation'), (3546, 3517, N'Inheritance'), (3547, 3517, N'Abstraction'), (3548, 3518, N'class'), (3549, 3518, N'string'), (3550, 3518, N'interface'), (3551, 3518, N'struct'), (3552, 3520, N'Start'), (3553, 3520, N'Main'), (3554, 3520, N'Run'), (3555, 3520, N'Execute'), (3556, 3521, N'Inheritance'), (3557, 3521, N'Polymorphism'), (3558, 3521, N'Abstraction'), (3559, 3521, N'Encapsulation'), (3560, 3523, N'public'), (3561, 3523, N'private'), (3562, 3523, N'protected'), (3563, 3523, N'internal'), (3564, 3524, N'Method'), (3565, 3524, N'Destructor'), (3566, 3524, N'Constructor'), (3567, 3524, N'Property'), (3568, 3526, N'Inheritance'), (3569, 3526, N'Polymorphism'), (3570, 3526, N'Abstraction'), (3571, 3526, N'Encapsulation'), (3572, 3528, N'virtual'), (3573, 3528, N'new'), (3574, 3528, N'override'), (3575, 3528, N'base'), (3576, 3529, N'Object-Oriented Programming'), (3577, 3529, N'Operational Object Programming'), (3578, 3529, N'Organized Object Paradigm'), (3579, 3529, N'Object-Optional Programming');

-- Department: System Development, Track: Software Development Fundamentals, Course: Data Structures
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3580, 3530, N'Queue'), (3581, 3530, N'Array'), (3582, 3530, N'Stack'), (3583, 3530, N'Linked List'), (3584, 3532, N'Stack'), (3585, 3532, N'Queue'), (3586, 3532, N'Array'), (3587, 3532, N'Tree'), (3588, 3533, N'Array'), (3589, 3533, N'Linked List'), (3590, 3533, N'Stack'), (3591, 3533, N'Queue'), (3592, 3535, N'Pop'), (3593, 3535, N'Push'), (3594, 3535, N'Enqueue'), (3595, 3535, N'Peek'), (3596, 3536, N'Array'), (3597, 3536, N'Queue'), (3598, 3536, N'Stack'), (3599, 3536, N'Hash Table'), (3600, 3538, N'Graph'), (3601, 3538, N'Array'), (3602, 3538, N'Binary Tree'), (3603, 3538, N'Ternary Tree'), (3604, 3539, N'Enqueue'), (3605, 3539, N'Dequeue'), (3606, 3539, N'Pop'), (3607, 3539, N'Push'), (3608, 3541, N'Leaf'), (3609, 3541, N'Branch'), (3610, 3541, N'Root'), (3611, 3541, N'Node'), (3612, 3543, N'Faster access'), (3613, 3543, N'Less memory usage'), (3614, 3543, N'Dynamic size'), (3615, 3543, N'Simpler implementation'), (3616, 3544, N'When an element is not found'), (3617, 3544, N'When the table is full'), (3618, 3544, N'When two keys hash to the same index'), (3619, 3544, N'When a key is invalid');

-- Department: System Development, Track: Software Development Fundamentals, Course: Intro to Databases & SQL
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3620, 3545, N'Standard Query Language'), (3621, 3545, N'Structured Query Language'), (3622, 3545, N'Simple Query Language'), (3623, 3545, N'System Query Language'), (3624, 3547, N'GET'), (3625, 3547, N'OPEN'), (3626, 3547, N'EXTRACT'), (3627, 3547, N'SELECT'), (3628, 3548, N'Documents'), (3629, 3548, N'Tables'), (3630, 3548, N'Graphs'), (3631, 3548, N'Files'), (3632, 3550, N'Foreign Key'), (3633, 3550, N'Primary Key'), (3634, 3550, N'Candidate Key'), (3635, 3550, N'Super Key'), (3636, 3551, N'OUTER JOIN'), (3637, 3551, N'LEFT JOIN'), (3638, 3551, N'RIGHT JOIN'), (3639, 3551, N'INNER JOIN'), (3640, 3553, N'Entity'), (3641, 3553, N'Record'), (3642, 3553, N'Attribute'), (3643, 3553, N'Table'), (3644, 3554, N'ADD NEW'), (3645, 3554, N'INSERT INTO'), (3646, 3554, N'CREATE'), (3647, 3554, N'NEW RECORD'), (3648, 3556, N'Field'), (3649, 3556, N'Tuple'), (3650, 3556, N'Attribute'), (3651, 3556, N'Schema'), (3652, 3558, N'MODIFY'), (3653, 3558, N'CHANGE'), (3654, 3558, N'SAVE'), (3655, 3558, N'UPDATE'), (3656, 3559, N'Relational Database Management System'), (3657, 3559, N'Rapid Database Management System'), (3658, 3559, N'Relational Data Manipulation System'), (3659, 3559, N'Record Database Management System');

-- Department: System Development, Track: Software Development Fundamentals, Course: Web Dev Essentials (HTML/CSS/JS)
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3660, 3560, N'Hyperlinks and Text Markup Language'), (3661, 3560, N'HyperText Markup Language'), (3662, 3560, N'Home Tool Markup Language'), (3663, 3560, N'High-Tech Markup Language'), (3664, 3562, N'Creative Style Sheets'), (3665, 3562, N'Computer Style Sheets'), (3666, 3562, N'Colorful Style Sheets'), (3667, 3562, N'Cascading Style Sheets'), (3668, 3563, N'<html>'), (3669, 3563, N'<body>'), (3670, 3563, N'<head>'), (3671, 3563, N'<main>'), (3672, 3565, N'variable'), (3673, 3565, N'v'), (3674, 3565, N'string, int'), (3675, 3565, N'var, let, or const'), (3676, 3566, N'text-color'), (3677, 3566, N'font-color'), (3678, 3566, N'color'), (3679, 3566, N'text'), (3680, 3568, N'<style src="style.css">'), (3681, 3568, N'<stylesheet>style.css</stylesheet>'), (3682, 3568, N'<link rel="stylesheet" href="style.css">'), (3683, 3568, N'<script src="style.css">'), (3684, 3569, N'Data Object Model'), (3685, 3569, N'Document Order Model'), (3686, 3569, N'A programming interface for web documents'), (3687, 3569, N'A CSS framework'), (3688, 3571, N'<ul>'), (3689, 3571, N'<dl>'), (3690, 3571, N'<ol>'), (3691, 3571, N'<list>'), (3692, 3573, N'Margin'), (3693, 3573, N'Space'), (3694, 3573, N'Outline'), (3695, 3573, N'Float'), (3696, 3574, N'Creates a new element with id="demo"'), (3697, 3574, N'Gets the document''s URL'), (3698, 3574, N'Finds an HTML element with id="demo"'), (3699, 3574, N'Deletes the element with id="demo"');

-- Department: System Development, Track: Software Development Fundamentals, Course: Git & SDLC
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3700, 3575, N'Software Design Life Cycle'), (3701, 3575, N'System Development Life Cycle'), (3702, 3575, N'Software Development Life Cycle'), (3703, 3575, N'System Design Life Cycle'), (3704, 3577, N'Waterfall'), (3705, 3577, N'V-Model'), (3706, 3577, N'Agile'), (3707, 3577, N'Spiral'), (3708, 3578, N'A cloud hosting service'), (3709, 3578, N'A project management tool'), (3710, 3578, N'A distributed version control system'), (3711, 3578, N'A text editor'), (3712, 3580, N'git push'), (3713, 3580, N'git pull'), (3714, 3580, N'git commit'), (3715, 3580, N'git clone'), (3716, 3581, N'Planning'), (3717, 3581, N'Design'), (3718, 3581, N'Implementation'), (3719, 3581, N'Testing'), (3720, 3583, N'To design the user interface'), (3721, 3583, N'To deploy the application'), (3722, 3583, N'To gather requirements'), (3723, 3583, N'To find and fix defects'), (3724, 3584, N'git commit'), (3725, 3584, N'git add'), (3726, 3584, N'git push'), (3727, 3584, N'git stage'), (3728, 3586, N'Implementation'), (3729, 3586, N'Testing'), (3730, 3586, N'Planning/Requirement Analysis'), (3731, 3586, N'Deployment'), (3732, 3588, N'git push'), (3733, 3588, N'git branch'), (3734, 3588, N'git merge'), (3735, 3588, N'git commit'), (3736, 3589, N'Deployment'), (3737, 3589, N'Maintenance'), (3738, 3589, N'Testing'), (3739, 3589, N'Design');

-- Department: System Development, Track: Software Development Fundamentals, Course: Fundamentals Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (3740, 3590, N'To learn a new language'), (3741, 3590, N'To demonstrate integrated skills'), (3742, 3590, N'To focus on a single concept'), (3743, 3590, N'To fix bugs in an existing project'), (3744, 3592, N'Compiling'), (3745, 3592, N'Deploying'), (3746, 3592, N'Debugging'), (3747, 3592, N'Designing'), (3748, 3593, N'A text editor'), (3749, 3593, N'Version Control System'), (3750, 3593, N'A web browser'), (3751, 3593, N'A database'), (3752, 3595, N'Monolithic Design'), (3753, 3595, N'Modular Design'), (3754, 3595, N'Spaghetti Code'), (3755, 3595, N'Hard Coding'), (3756, 3596, N'Obfuscated Code'), (3757, 3596, N'Complex Code'), (3758, 3596, N'Clean Code'), (3759, 3596, N'Legacy Code'), (3760, 3598, N'Unit Testing'), (3761, 3598, N'Integration Testing'), (3762, 3598, N'User Acceptance Testing'), (3763, 3598, N'All of the above'), (3764, 3599, N'Coding'), (3765, 3599, N'Testing'), (3766, 3599, N'Deployment'), (3767, 3599, N'Design'), (3768, 3601, N'The database schema'), (3769, 3601, N'API endpoints'), (3770, 3601, N'Setup instructions and design choices'), (3771, 3601, N'A list of bugs'), (3772, 3603, N'Adding new features'), (3773, 3603, N'Deleting old code'), (3774, 3603, N'Rewriting the entire application'), (3775, 3603, N'Improving code structure without changing its external behavior'), (3776, 3604, N'Interface Segregation Principle'), (3777, 3604, N'Open/Closed Principle'), (3778, 3604, N'Single Responsibility Principle'), (3779, 3604, N'Liskov Substitution Principle');


-- #############################################################################
-- # Track 9 Software Testing Question_Bank INSERTS
-- #############################################################################

--Department: System Development, Track: Software Testing, Course: Software Testing Fundamentals & STLC
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4000, 57, N'MCQ', N'What does STLC stand for?', N'Software Testing Life Cycle'),
(4001, 57, N'True/False', N'Verification is static testing.', N'True'),
(4002, 57, N'True/False', N'Validation is dynamic testing.', N'True'),
(4003, 57, N'MCQ', N'Which is NOT a level of testing?', N'Defect Testing'),
(4004, 57, N'True/False', N'White-box testing checks internal logic.', N'True'),
(4005, 57, N'True/False', N'Black-box testing requires code knowledge.', N'False'),
(4006, 57, N'MCQ', N'What is an RTM?', N'Requirement Traceability Matrix'),
(4007, 57, N'MCQ', N'Which is a key phase of STLC?', N'Test Planning'),
(4008, 57, N'True/False', N'Test Closure is the final phase of STLC.', N'True'),
(4009, 57, N'True/False', N'Finding defects is the only goal of testing.', N'False'),
(4010, 57, N'MCQ', N'What is a "bug"?', N'A mismatch with requirements'),
(4011, 57, N'MCQ', N'Which is a non-functional testing type?', N'Performance testing'),
(4012, 57, N'True/False', N'Acceptance testing is done by the customer.', N'True'),
(4013, 57, N'MCQ', N'What is "test execution"?', N'Running test cases'),
(4014, 57, N'MCQ', N'What are "entry criteria"?', N'Conditions to start testing');

--Department: System Development, Track: Software Testing, Course: Manual Testing Techniques
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4015, 58, N'True/False', N'Exploratory testing is heavily scripted.', N'False'),
(4016, 58, N'MCQ', N'Technique dividing input into value ranges?', N'Equivalence Partitioning'),
(4017, 58, N'MCQ', N'Technique testing the edges of partitions?', N'Boundary Value Analysis'),
(4018, 58, N'True/False', N'A test case must include expected results.', N'True'),
(4019, 58, N'True/False', N'Ad-hoc testing is a formal, planned process.', N'False'),
(4020, 58, N'MCQ', N'What is "error guessing"?', N'Using intuition to find bugs'),
(4021, 58, N'MCQ', N'Which technique is best for complex business rules?', N'Decision Table'),
(4022, 58, N'True/False', N'A test scenario is more detailed than a test case.', N'False'),
(4023, 58, N'MCQ', N'What does BVA stand for?', N'Boundary Value Analysis'),
(4024, 58, N'True/False', N'Usability testing checks if the UI is user-friendly.', N'True'),
(4025, 58, N'MCQ', N'What is "state transition testing"?', N'Testing system response to state changes'),
(4026, 58, N'True/False', N'A good test case is easily understandable and repeatable.', N'True'),
(4027, 58, N'MCQ', N'What is a "test plan"?', N'A document outlining test scope/strategy'),
(4028, 58, N'MCQ', N'Which is a static testing technique?', N'Walkthrough'),
(4029, 58, N'True/False', N'Manual testing is obsolete due to automation.', N'False');

--Department: System Development, Track: Software Testing, Course: Test Automation with Selenium
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4030, 59, N'MCQ', N'What is Selenium?', N'A web automation framework'),
(4031, 59, N'True/False', N'Selenium WebDriver talks directly to the browser.', N'True'),
(4032, 59, N'MCQ', N'Which is NOT a Selenium component?', N'Selenium Runner'),
(4033, 59, N'True/False', N'Selenium supports Python.', N'True'),
(4034, 59, N'MCQ', N'What locator is generally most reliable?', N'ID'),
(4035, 59, N'True/False', N'Absolute XPath is recommended over Relative XPath.', N'False'),
(4036, 59, N'MCQ', N'What does `findElement` method do?', N'Finds the first matching element'),
(4037, 59, N'True/False', N'Selenium Grid is used for parallel testing.', N'True'),
(4038, 59, N'MCQ', N'What method clicks a button?', N'.click()'),
(4039, 59, N'MCQ', N'What method types text into an input field?', N'.sendKeys()'),
(4040, 59, N'True/False', N'Selenium can automate desktop applications.', N'False'),
(4041, 59, N'True/False', N'An "explicit wait" waits for a specific condition.', N'True'),
(4042, 59, N'MCQ', N'Which is a popular BDD framework used with Selenium?', N'Cucumber'),
(4043, 59, N'True/False', N'Selenium IDE is primarily a code-based tool.', N'False'),
(4044, 59, N'MCQ', N'What is POM?', N'Page Object Model');

--Department: System Development, Track: Software Testing, Course: API Testing with Postman
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4045, 60, N'MCQ', N'What is an API?', N'A communication interface'),
(4046, 60, N'True/False', N'Postman is only for manual API testing.', N'False'),
(4047, 60, N'MCQ', N'Which HTTP method retrieves data?', N'GET'),
(4048, 60, N'MCQ', N'Which HTTP method creates new data?', N'POST'),
(4049, 60, N'True/False', N'A 404 status code means "OK".', N'False'),
(4050, 60, N'True/False', N'A 200 status code means "Success".', N'True'),
(4051, 60, N'MCQ', N'What is JSON?', N'A data format'),
(4052, 60, N'MCQ', N'What is an "endpoint" in API terms?', N'A specific URL for an API resource'),
(4053, 60, N'True/False', N'Postman "Collections" are used to group requests.', N'True'),
(4054, 60, N'True/False', N'"Authorization" is not needed for public APIs.', N'False'),
(4055, 60, N'MCQ', N'What is a "Query Parameter"?', N'Data appended to the URL after ?'),
(4056, 60, N'True/False', N'Postman can run tests from the command line using Newman.', N'True'),
(4057, 60, N'MCQ', N'What HTTP method updates an entire resource?', N'PUT'),
(4058, 60, N'MCQ', N'What is a common authorization method?', N'Bearer Token'),
(4059, 60, N'True/False', N'API testing is a type of white-box testing.', N'False');

--Department: System Development, Track: Software Testing, Course: Performance Testing with JMeter
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4060, 61, N'MCQ', N'What is performance testing?', N'Testing system speed and stability'),
(4061, 61, N'True/False', N'JMeter is primarily a functional testing tool.', N'False'),
(4062, 61, N'MCQ', N'What is "Load Testing"?', N'Testing under expected user load'),
(4063, 61, N'MCQ', N'What is "Stress Testing"?', N'Testing beyond normal capacity'),
(4064, 61, N'True/False', N'"Latency" is the time for a request to complete.', N'True'),
(4065, 61, N'True/False', N'"Throughput" is the number of users.', N'False'),
(4066, 61, N'MCQ', N'What is a "Thread Group" in JMeter?', N'A group of virtual users'),
(4067, 61, N'MCQ', N'What is a "Sampler"?', N'A type of request (e.g., HTTP)'),
(4068, 61, N'True/False', N'"Listeners" in JMeter are used to show results.', N'True'),
(4069, 61, N'True/False', N'JMeter can only test web applications.', N'False'),
(4070, 61, N'MCQ', N'What is "Soak Testing"?', N'Testing for a long duration'),
(4071, 61, N'MCQ', N'What is a performance "bottleneck"?', N'A component slowing the system'),
(4072, 61, N'True/False', N'JMeter should always be run in GUI mode for load tests.', N'False'),
(4073, 61, N'MCQ', N'What is the "ramp-up" period?', N'Time taken to add all users'),
(4074, 61, N'True/False', N'Performance testing is a type of non-functional testing.', N'True');

--Department: System Development, Track: Software Testing, Course: Agile Testing & Defect Tracking
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4075, 62, N'MCQ', N'What is Agile?', N'An iterative development methodology'),
(4076, 62, N'True/False', N'In Agile, testing starts after development is complete.', N'False'),
(4077, 62, N'MCQ', N'What is a "Sprint" in Scrum?', N'A time-boxed iteration'),
(4078, 62, N'MCQ', N'What is a "User Story"?', N'A requirement from a user perspective'),
(4079, 62, N'True/False', N'Testers are not part of the Agile team.', N'False'),
(4080, 62, N'True/False', N'BDD stands for Bug Driven Development.', N'False'),
(4081, 62, N'MCQ', N'What is Jira?', N'A project & defect tracking tool'),
(4082, 62, N'MCQ', N'What is a "defect life cycle"?', N'The states a defect goes through'),
(4083, 62, N'True/False', N'A "high priority, low severity" defect should be fixed first.', N'True'),
(4084, 62, N'True/False', N'A "high severity, low priority" defect is a critical blocker.', N'False'),
(4085, 62, N'MCQ', N'What is "Regression Testing"?', N'Testing that old features still work'),
(4086, 62, N'True/False', N'In Agile, automation is not important.', N'False'),
(4087, 62, N'MCQ', N'What is "TDD"?', N'Test Driven Development'),
(4088, 62, N'MCQ', N'A defect state "Closed" means:', N'It is fixed and verified'),
(4089, 62, N'True/False', N'"Definition of Done" helps ensure quality.', N'True');

--Department: System Development, Track: Software Testing, Course: Automated Testing Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4090, 63, N'MCQ', N'What is a "test framework"?', N'Guidelines/tools for automation'),
(4091, 63, N'True/False', N'A Data-Driven framework separates test data from logic.', N'True'),
(4092, 63, N'MCQ', N'What is a "Keyword-Driven" framework?', N'Uses keywords to represent actions'),
(4093, 63, N'MCQ', N'What is "CI/CD"?', N'Continuous Integration/Continuous Delivery'),
(4094, 63, N'True/False', N'Jenkins is a popular CI/CD tool.', N'True'),
(4095, 63, N'True/False', N'Test reports are not important in automation.', N'False'),
(4096, 63, N'MCQ', N'What is "flakiness" in tests?', N'Tests that fail randomly'),
(4097, 63, N'MCQ', N'Why use POM (Page Object Model)?', N'To reduce code duplication'),
(4098, 63, N'True/False', N'Automation should replace all manual testing.', N'False'),
(4099, 63, N'True/False', N'The capstone project combines multiple skills.', N'True'),
(4100, 63, N'MCQ', N'What is "version control"?', N'A system like Git'),
(4101, 63, N'MCQ', N'Which is NOT a goal of automation?', N'100% bug detection'),
(4102, 63, N'True/False', N'"Assertions" are used to validate expected outcomes.', N'True'),
(4103, 63, N'MCQ', N'What is a "smoke test"?', N'A quick test of critical functionality'),
(4104, 63, N'True/False', N'A good capstone demonstrates a full automation suite.', N'True');




-- #############################################################################
-- # FILE 2: Question_Choice INSERTS
-- #############################################################################

--Department: System Development, Track: Software Testing, Course: Software Testing Fundamentals & STLC
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4000, 4000, N'Software Testing Life Cycle'), (4001, 4000, N'System Testing Life Cycle'), (4002, 4000, N'Software Test Logic Caching'), (4003, 4000, N'System Test Logic Cycle'),
(4004, 4003, N'Unit Testing'), (4005, 4003, N'Integration Testing'), (4006, 4003, N'Defect Testing'), (4007, 4003, N'System Testing'),
(4008, 4006, N'Requirement Traceability Matrix'), (4009, 4006, N'Maps defects to code'), (4010, 4006, N'A tool for testing'), (4011, 4006, N'A type of test plan'),
(4012, 4007, N'Test Planning'), (4013, 4007, N'Code Deployment'), (4014, 4007, N'Marketing'), (4015, 4007, N'Sales'),
(4016, 4010, N'A feature'), (4017, 4010, N'A mismatch with requirements'), (4018, 4010, N'A user error'), (4019, 4010, N'A type of code'),
(4020, 4011, N'Unit testing'), (4021, 4011, N'Performance testing'), (4022, 4011, N'Integration testing'), (4023, 4011, N'Regression testing'),
(4024, 4013, N'Writing test cases'), (4025, 4013, N'Running test cases'), (4026, 4013, N'Planning test strategy'), (4027, 4013, N'Closing test cycle'),
(4028, 4014, N'Conditions to start testing'), (4029, 4014, N'Conditions to stop testing'), (4030, 4014, N'A test case'), (4031, 4014, N'A test script');

--Department: System Development, Track: Software Testing, Course: Manual Testing Techniques
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4032, 4016, N'Boundary Value Analysis'), (4033, 4016, N'Equivalence Partitioning'), (4034, 4016, N'Decision Table'), (4035, 4016, N'State Transition'),
(4036, 4017, N'Boundary Value Analysis'), (4037, 4017, N'Equivalence Partitioning'), (4038, 4017, N'Error Guessing'), (4039, 4017, N'Use Case Testing'),
(4040, 4020, N'A formal technique'), (4041, 4020, N'Using intuition to find bugs'), (4042, 4020, N'Guessing the code'), (4043, 4020, N'A type of test plan'),
(4044, 4021, N'Decision Table'), (4045, 4021, N'BVA'), (4046, 4021, N'Equivalence Partitioning'), (4047, 4021, N'Pair Testing'),
(4048, 4023, N'Basic Value Analysis'), (4049, 4023, N'Boundary Value Analysis'), (4050, 4023, N'Black-box Value Array'), (4051, 4023, N'Bug Validation Activity'),
(4052, 4025, N'Testing UI states'), (4053, 4025, N'Testing system response to state changes'), (4054, 4025, N'Testing database states'), (4055, 4025, N'Testing code transitions'),
(4056, 4027, N'A single test case'), (4057, 4027, N'A document outlining test scope/strategy'), (4058, 4027, N'A bug report'), (4059, 4027, N'A list of test cases'),
(4060, 4028, N'Walkthrough'), (4061, 4028, N'Unit Test'), (4062, 4028, N'Performance Test'), (4063, 4028, N'BVA');

--Department: System Development, Track: Software Testing, Course: Test Automation with Selenium
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4064, 4030, N'A manual test tool'), (4065, 4030, N'A web automation framework'), (4066, 4030, N'A bug tracker'), (4067, 4030, N'A performance tool'),
(4068, 4032, N'WebDriver'), (4069, 4032, N'IDE'), (4070, 4032, N'Grid'), (4071, 4032, N'Selenium Runner'),
(4072, 4034, N'ID'), (4073, 4034, N'XPath'), (4074, 4034, N'Link Text'), (4075, 4034, N'Class Name'),
(4076, 4036, N'Finds the first matching element'), (4077, 4036, N'Finds all matching elements'), (4078, 4036, N'Finds no elements'), (4079, 4036, N'Clicks an element'),
(4080, 4038, N'.click()'), (4081, 4038, N'.submit()'), (4082, 4038, N'.press()'), (4083, 4038, N'.go()'),
(4084, 4039, N'.type()'), (4085, 4039, N'.sendKeys()'), (4086, 4039, N'.inputText()'), (4087, 4039, N'.write()'),
(4088, 4042, N'JUnit'), (4089, 4042, N'TestNG'), (4090, 4042, N'Cucumber'), (4091, 4042, N'NUnit'),
(4092, 4044, N'Page Object Model'), (4093, 4044, N'Primary Object Mainframe'), (4094, 4044, N'Project Object Model'), (4095, 4044, N'Page Oriented Method');

--Department: System Development, Track: Software Testing, Course: API Testing with Postman
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4096, 4045, N'A UI'), (4097, 4045, N'A database'), (4098, 4045, N'A communication interface'), (4099, 4045, N'A server'),
(4100, 4047, N'GET'), (4101, 4047, N'POST'), (4102, 4047, N'PUT'), (4103, 4047, N'DELETE'),
(4104, 4048, N'GET'), (4105, 4048, N'POST'), (4106, 4048, N'PUT'), (4107, 4048, N'PATCH'),
(4108, 4051, N'A programming language'), (4109, 4051, N'A data format'), (4110, 4051, N'A test tool'), (4111, 4051, N'A database type'),
(4112, 4052, N'A server'), (4113, 4052, N'A test script'), (4114, 4052, N'A specific URL for an API resource'), (4115, 4052, N'A user'),
(4116, 4055, N'Data in the URL path'), (4117, 4055, N'Data appended to the URL after ?'), (4118, 4055, N'Data in the request body'), (4119, 4055, N'Data in the header'),
(4120, 4057, N'POST'), (4121, 4057, N'PATCH'), (4122, 4057, N'PUT'), (4123, 4057, N'GET'),
(4124, 4058, N'Bearer Token'), (4125, 4058, N'JSON'), (4126, 4058, N'XML'), (4127, 4058, N'HTTP');

--Department: System Development, Track: Software Testing, Course: Performance Testing with JMeter
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4128, 4060, N'Testing functionality'), (4129, 4060, N'Testing system speed and stability'), (4130, 4060, N'Testing UI'), (4131, 4060, N'Testing security'),
(4132, 4062, N'Testing under expected user load'), (4133, 4062, N'Testing at breaking point'), (4134, 4062, N'Testing over time'), (4135, 4062, N'Testing with one user'),
(4136, 4063, N'Testing under expected load'), (4137, 4063, N'Testing beyond normal capacity'), (4138, 4063, N'Testing stability'), (4139, 4063, N'Testing GUI'),
(4140, 4066, N'A test script'), (4141, 4066, N'A group of virtual users'), (4142, 4066, N'A test report'), (4143, 4066, N'A listener'),
(4144, 4067, N'A user'), (4145, 4067, N'A test plan'), (4146, 4067, N'A type of request (e.g., HTTP)'), (4147, 4067, N'A result'),
(4148, 4070, N'Testing for a long duration'), (4149, 4070, N'Testing with many users'), (4150, 4070, N'Testing with no users'), (4151, 4070, N'Testing the UI'),
(4152, 4071, N'A good result'), (4153, 4071, N'A component slowing the system'), (4154, 4071, N'A type of test'), (4155, 4071, N'A JMeter component'),
(4156, 4073, N'Time to end test'), (4157, 4073, N'Time taken to add all users'), (4158, 4073, N'Time for results'), (4159, 4073, N'Time to crash');

--Department: System Development, Track: Software Testing, Course: Agile Testing & Defect Tracking
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4160, 4075, N'A testing tool'), (4161, 4075, N'A waterfall method'), (4162, 4075, N'An iterative development methodology'), (4163, 4075, N'A defect'),
(4164, 4077, N'A long project'), (4165, 4077, N'A defect'), (4166, 4077, N'A time-boxed iteration'), (4167, 4077, N'A test plan'),
(4168, 4078, N'A bug report'), (4169, 4078, N'A requirement from a user perspective'), (4170, 4078, N'A test case'), (4171, 4078, N'A developer task'),
(4172, 4081, N'A testing tool'), (4173, 4081, N'A project & defect tracking tool'), (4174, 4081, N'An IDE'), (4175, 4081, N'A programming language'),
(4176, 4082, N'The agile cycle'), (4177, 4082, N'The STLC'), (4178, 4082, N'The states a defect goes through'), (4179, 4082, N'A user story'),
(4180, 4085, N'Testing new features'), (4181, 4085, N'Retesting fixed bugs'), (4182, 4085, N'Testing that old features still work'), (4183, 4085, N'Testing the UI'),
(4184, 4087, N'Test Driven Development'), (4185, 4087, N'Tool Driven Design'), (4186, 4087, N'Team Defect Database'), (4187, 4087, N'Test Data Design'),
(4188, 4088, N'It is new'), (4189, 4088, N'It is fixed and verified'), (4190, 4088, N'It is being fixed'), (4191, 4088, N'It is not a bug');

--Department: System Development, Track: Software Testing, Course: Automated Testing Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4192, 4090, N'A tool like Selenium'), (4193, 4090, N'Guidelines/tools for automation'), (4194, 4090, N'A bug report'), (4195, 4090, N'A test plan'),
(4196, 4092, N'Uses keywords to represent actions'), (4197, 4092, N'Uses data files'), (4198, 4092, N'Uses BDD'), (4199, 4092, N'Is linear'),
(4200, 4093, N'A test framework'), (4201, 4093, N'A bug tracker'), (4202, 4093, N'Continuous Integration/Continuous Delivery'), (4203, 4093, N'Code Inspection/Code Deployment'),
(4204, 4096, N'Tests that fail randomly'), (4205, 4096, N'Tests that run fast'), (4206, 4096, N'Tests that are manual'), (4207, 4096, N'Tests that find bugs'),
(4208, 4097, N'To make tests faster'), (4209, 4097, N'To reduce code duplication'), (4210, 4097, N'To find more bugs'), (4211, 4097, N'To test APIs'),
(4212, 4100, N'A test tool'), (4213, 4100, N'A system like Git'), (4214, 4100, N'A test plan'), (4215, 4100, N'A defect status'),
(4216, 4101, N'Faster feedback'), (4217, 4101, N'Running repetitive tests'), (4218, 4101, N'100% bug detection'), (4219, 4101, N'Executing tests overnight'),
(4220, 4103, N'A deep, detailed test'), (4221, 4103, N'A quick test of critical functionality'), (4222, 4103, N'A performance test'), (4223, 4103, N'A security test');


-- #############################################################################
-- #Track 10 Renewable Energy Question_Bank INSERTS
-- #############################################################################

--Department: System Development, Track: Renewable Energy, Course: Intro to Renewable Energy Sources
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4500, 64, N'MCQ', N'Which is NOT a renewable energy source?', N'Natural Gas'),
(4501, 64, N'True/False', N'Fossil fuels are considered renewable.', N'False'),
(4502, 64, N'True/False', N'Solar energy is derived from the sun.', N'True'),
(4503, 64, N'MCQ', N'What energy source uses heat from the Earth''s core?', N'Geothermal'),
(4504, 64, N'MCQ', N'What is energy from burning organic materials called?', N'Biomass'),
(4505, 64, N'True/False', N'Wind energy is caused by uneven heating of the Earth.', N'True'),
(4506, 64, N'MCQ', N'Which energy source uses the movement of water in rivers?', N'Hydropower'),
(4507, 64, N'True/False', N'A major drawback of solar/wind is intermittency.', N'True'),
(4508, 64, N'MCQ', N'What does "renewable" mean?', N'It replenishes naturally'),
(4509, 64, N'True/False', N'Tidal energy is a form of ocean energy.', N'True'),
(4510, 64, N'MCQ', N'What is the primary benefit of renewable energy?', N'Reduced greenhouse gas emissions'),
(4511, 64, N'True/False', N'Wave energy is the same as tidal energy.', N'False'),
(4512, 64, N'MCQ', N'What is "energy conservation"?', N'Using less energy'),
(4513, 64, N'True/False', N'All renewable energy sources are 100% clean.', N'False'),
(4514, 64, N'MCQ', N'Which is a form of solar energy?', N'Photovoltaics');

--Department: System Development, Track: Renewable Energy, Course: Solar PV & Wind Energy Tech
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4515, 65, N'MCQ', N'What does "PV" in Solar PV stand for?', N'Photovoltaic'),
(4516, 65, N'True/False', N'Solar PV panels generate AC electricity directly.', N'False'),
(4517, 65, N'MCQ', N'What device converts DC to AC in a solar system?', N'Inverter'),
(4518, 65, N'True/False', N'Wind turbines convert kinetic energy to electrical energy.', N'True'),
(4519, 65, N'MCQ', N'What is the main component of most PV cells?', N'Silicon'),
(4520, 65, N'True/False', N'Higher temperatures generally increase PV panel efficiency.', N'False'),
(4521, 65, N'MCQ', N'What does HAWT stand for?', N'Horizontal-Axis Wind Turbine'),
(4522, 65, N'MCQ', N'What part of a wind turbine houses the generator?', N'Nacelle'),
(4523, 65, N'True/False', N'The yaw drive turns the turbine to face the wind.', N'True'),
(4524, 65, N'MCQ', N'What is "CSP" (Concentrated Solar Power)?', N'Using mirrors to heat a fluid'),
(4525, 65, N'True/False', N'Offshore wind farms are built on land.', N'False'),
(4526, 65, N'MCQ', N'What does an anemometer measure?', N'Wind speed'),
(4527, 65, N'True/False', N'The Betz Limit defines the maximum theoretical efficiency of a wind turbine.', N'True'),
(4528, 65, N'MCQ', N'What is a group of solar panels connected together called?', N'An array'),
(4529, 65, N'True/False', N'VAWT stands for "Vertical-Angle Wind Turbine".', N'False');

--Department: System Development, Track: Renewable Energy, Course: Energy Storage Systems
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4530, 66, N'MCQ', N'Why is storage vital for renewables like solar/wind?', N'To manage intermittency'),
(4531, 66, N'True/False', N'Lithium-ion batteries are a form of electrochemical storage.', N'True'),
(4532, 66, N'MCQ', N'What is the most common large-scale energy storage?', N'Pumped Hydro Storage'),
(4533, 66, N'True/False', N'Flywheels store energy chemically.', N'False'),
(4534, 66, N'MCQ', N'What does CAES stand for?', N'Compressed Air Energy Storage'),
(4535, 66, N'True/False', N'Hydrogen is considered an energy carrier, not a source.', N'True'),
(4536, 66, N'MCQ', N'Which battery type is known for long life but low density?', N'Lead-Acid'),
(4537, 66, N'True/False', N'Thermal energy storage can only store heat, not cold.', N'False'),
(4538, 66, N'MCQ', N'What is BESS?', N'Battery Energy Storage System'),
(4539, 66, N'MCQ', N'What is a benefit of supercapacitors over batteries?', N'Faster charge/discharge'),
(4540, 66, N'True/False', N'Pumped hydro storage involves moving water between two reservoirs at different heights.', N'True'),
(4541, 66, N'MCQ', N'What is "round-trip efficiency"?', N'The ratio of energy out to energy in'),
(4542, 66, N'True/False', N'Flow batteries have energy and power decoupled.', N'True'),
(4543, 66, N'MCQ', N'What type of storage are flywheels?', N'Mechanical'),
(4544, 66, N'True/False', N'Energy storage cannot help stabilize grid frequency.', N'False');

--Department: System Development, Track: Renewable Energy, Course: Smart Grids & Grid Integration
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4545, 67, N'MCQ', N'What defines a "Smart Grid"?', N'Two-way communication'),
(4546, 67, N'True/False', N'The traditional grid was built for one-way power flow.', N'True'),
(4547, 67, N'MCQ', N'What does "DER" stand for?', N'Distributed Energy Resources'),
(4548, 67, N'True/False', N'A rooftop solar panel is an example of DER.', N'True'),
(4549, 67, N'MCQ', N'What is "Demand Response"?', N'Consumers reducing use during peak times'),
(4550, 67, N'True/False', N'Smart meters only provide monthly readings.', N'False'),
(4551, 67, N'MCQ', N'What is a "microgrid"?', N'A local grid that can disconnect'),
(4552, 67, N'True/False', N'Integrating renewables decreases grid inertia.', N'True'),
(4553, 67, N'MCQ', N'What does AMI stand for?', N'Advanced Metering Infrastructure'),
(4554, 67, N'True/False', N'A "self-healing" grid can automatically respond to faults.', N'True'),
(4555, 67, N'MCQ', N'What is V2G?', N'Vehicle-to-Grid'),
(4556, 67, N'True/False', N'Grid integration of renewables poses no stability challenges.', N'False'),
(4557, 67, N'MCQ', N'What is "grid inertia"?', N'Resistance to frequency changes'),
(4558, 67, N'True/False', N'Smart grids increase energy efficiency and reliability.', N'True'),
(4559, 67, N'MCQ', N'What do PMUs (Phasor Measurement Units) do?', N'Provide real-time grid monitoring');

--Department: System Development, Track: Renewable Energy, Course: Renewable Energy Policy & Economics
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4560, 68, N'MCQ', N'What is LCOE?', N'Levelized Cost of Energy'),
(4561, 68, N'True/False', N'A "carbon tax" is a subsidy for clean energy.', N'False'),
(4562, 68, N'MCQ', N'What is a "Feed-in Tariff" (FiT)?', N'A guaranteed price for renewable energy sent to the grid'),
(4563, 68, N'True/False', N'"Net Metering" allows selling all generated power at a premium.', N'False'),
(4564, 68, N'MCQ', N'What does "RPS" stand for?', N'Renewable Portfolio Standard'),
(4565, 68, N'True/False', N'An "externality" is a cost/benefit not included in the market price.', N'True'),
(4566, 68, N'MCQ', N'What is a "REC"?', N'Renewable Energy Certificate'),
(4567, 68, N'True/False', N'The Paris Agreement is a binding treaty setting specific national emissions limits.', N'False'),
(4568, 68, N'MCQ', N'What is "Cap-and-Trade"?', N'A market-based system to limit emissions'),
(4569, 68, N'True/False', N'Subsidies are designed to make mature technologies more expensive.', N'False'),
(4570, 68, N'MCQ', N'What is "energy security"?', N'Access to reliable and affordable energy'),
(4571, 68, N'True/False', N'LCOE calculation includes capital costs, O&M, and fuel costs.', N'True'),
(4572, 68, N'MCQ', N'What policy requires utilities to source a % of power from renewables?', N'Renewable Portfolio Standard'),
(4573, 68, N'True/False', N'Pollution is considered a positive externality.', N'False'),
(4574, 68, N'MCQ', N'What is a PPA?', N'Power Purchase Agreement');

--Department: System Development, Track: Renewable Energy, Course: Project Management for Energy
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4575, 69, N'MCQ', N'What is the first phase of the project management lifecycle?', N'Initiation'),
(4576, 69, N'True/False', N'A Gantt chart is primarily used for risk analysis.', N'False'),
(4577, 69, N'MCQ', N'What is "Scope Creep"?', N'Uncontrolled changes to the project'),
(4578, 69, N'True/False', N'The "Critical Path" is the shortest sequence of tasks in a project.', N'False'),
(4579, 69, N'MCQ', N'What does a "Feasibility Study" assess?', N'The project''s viability'),
(4580, 69, N'True/False', N'A PPA (Power Purchase Agreement) is a key contract in energy projects.', N'True'),
(4581, 69, N'MCQ', N'What does EPC stand for?', N'Engineering, Procurement, and Construction'),
(4582, 69, N'True/False', N'Risk management is a one-time activity during the planning phase.', N'False'),
(4583, 69, N'MCQ', N'What is a "Stakeholder"?', N'Anyone affected by the project'),
(4584, 69, N'True/False', N'Agile project management is never used in energy projects.', N'False'),
(4585, 69, N'MCQ', N'What is O&M?', N'Operations & Maintenance'),
(4586, 69, N'True/False', N'A Work Breakdown Structure (WBS) defines the project schedule.', N'False'),
(4587, 69, N'MCQ', N'Which is part of the "Triple Constraint"?', N'Scope'),
(4588, 69, N'True/False', N'"Siting and permitting" are typically quick and easy for energy projects.', N'False'),
(4589, 69, N'MCQ', N'What document officially authorizes a project?', N'Project Charter');

--Department: System Development, Track: Renewable Energy, Course: Renewable Energy Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(4590, 70, N'MCQ', N'What is the main purpose of a capstone project?', N'To integrate and apply skills'),
(4591, 70, N'True/False', N'A capstone project should avoid all economic analysis.', N'False'),
(4592, 70, N'MCQ', N'What is a good first step in a capstone?', N'Define the problem statement'),
(4593, 70, N'True/False', N'A feasibility study is irrelevant for a capstone.', N'False'),
(4594, 70, N'MCQ', N'What is a critical component for a proposed wind project?', N'Wind resource assessment'),
(4595, 70, N'True/False', N'A capstone project should ignore policy and regulations.', N'False'),
(4596, 70, N'MCQ', N'What analysis is key to a BESS project proposal?', N'Battery sizing and dispatch strategy'),
(4597, 70, N'True/False', N'A project plan (WBS, schedule) is a necessary part of a capstone.', N'True'),
(4598, 70, N'MCQ', N'What should a good capstone report clearly state?', N'Assumptions and limitations'),
(4599, 69, N'True/False', N'Stakeholder analysis is not important in a capstone project.', N'False'),
(4600, 70, N'MCQ', N'What financial metric is essential for a capstone proposal?', N'LCOE or NPV'),
(4601, 70, N'True/False', N'The capstone must propose a completely new, untested technology.', N'False'),
(4602, 70, N'MCQ', N'A capstone on grid integration should consider:', N'Grid stability impact'),
(4603, 70, N'True/False', N'Risk assessment is a valuable addition to a capstone project.', N'True'),
(4604, 70, N'MCQ', N'The final presentation should demonstrate:', N'A comprehensive understanding of the project lifecycle');



-- #############################################################################
-- # FILE 2: Question_Choice INSERTS
-- #############################################################################

--Department: System Development, Track: Renewable Energy, Course: Intro to Renewable Energy Sources
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4500, 4500, N'Solar'), (4501, 4500, N'Wind'), (4502, 4500, N'Natural Gas'), (4503, 4500, N'Hydropower'),
(4504, 4503, N'Geothermal'), (4505, 4503, N'Solar'), (4506, 4503, N'Biomass'), (4507, 4503, N'Nuclear'),
(4508, 4504, N'Biomass'), (4509, 4504, N'Geothermal'), (4510, 4504, N'Petroleum'), (4511, 4504, N'Hydropower'),
(4512, 4506, N'Hydropower'), (4513, 4506, N'Tidal'), (4514, 4506, N'Nuclear'), (4515, 4506, N'Geothermal'),
(4516, 4508, N'It is cheap'), (4517, 4508, N'It is inefficient'), (4518, 4508, N'It replenishes naturally'), (4519, 4508, N'It is man-made'),
(4520, 4510, N'Reduced greenhouse gas emissions'), (4521, 4510, N'It is always available'), (4522, 4510, N'It is free'), (4523, 4510, N'It requires no land'),
(4524, 4512, N'Using more energy'), (4525, 4512, N'Using less energy'), (4526, 4512, N'Creating new energy'), (4527, 4512, N'Storing energy'),
(4528, 4514, N'Geothermal'), (4529, 4514, N'Photovoltaics'), (4530, 4514, N'Biomass'), (4531, 4514, N'Fission');

--Department: System Development, Track: Renewable Energy, Course: Solar PV & Wind Energy Tech
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4532, 4515, N'Photo-Voltage'), (4533, 4515, N'Photovoltaic'), (4534, 4515, N'Primary Voltage'), (4535, 4515, N'Photo-Volt'),
(4536, 4517, N'Inverter'), (4537, 4517, N'Converter'), (4538, 4517, N'Transformer'), (4539, 4517, N'Rectifier'),
(4540, 4519, N'Silicon'), (4541, 4519, N'Copper'), (4542, 4519, N'Glass'), (4543, 4519, N'Aluminum'),
(4544, 4521, N'High-Axis Wind Turbine'), (4545, 4521, N'Horizontal-Access Wind Turbine'), (4546, 4521, N'Horizontal-Axis Wind Turbine'), (4547, 4521, N'High-Altitude Wind Turbine'),
(4548, 4522, N'Blade'), (4549, 4522, N'Tower'), (4550, 4522, N'Nacelle'), (4551, 4522, N'Foundation'),
(4552, 4524, N'Using mirrors to heat a fluid'), (4553, 4524, N'Using PV panels'), (4554, 4524, N'Passive solar heating'), (4555, 4524, N'Cooling with solar power'),
(4556, 4526, N'Wind speed'), (4557, 4526, N'Wind direction'), (4558, 4526, N'Air temperature'), (4559, 4526, N'Humidity'),
(4560, 4528, N'A cell'), (4561, 4528, N'An inverter'), (4562, 4528, N'An array'), (4563, 4528, N'A module');

--Department: System Development, Track: Renewable Energy, Course: Energy Storage Systems
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4564, 4530, N'To make them cheaper'), (4565, 4530, N'To manage intermittency'), (4566, 4530, N'To increase their power'), (4567, 4530, N'To reduce efficiency'),
(4568, 4532, N'Lithium-ion Batteries'), (4569, 4532, N'Pumped Hydro Storage'), (4570, 4532, N'Flywheels'), (4571, 4532, N'CAES'),
(4572, 4534, N'Compressed Air Energy Storage'), (4573, 4534, N'Common Air Energy System'), (4574, 4534, N'Compressed Air Energy System'), (4575, 4534, N'Critical Air Energy Storage'),
(4576, 4536, N'Lithium-ion'), (4577, 4536, N'Lead-Acid'), (4578, 4536, N'Flow Battery'), (4579, 4536, N'Nickel-Cadmium'),
(4580, 4538, N'Battery Energy Storage System'), (4581, 4538, N'Basic Energy Storage System'), (4582, 4538, N'Battery Efficiency Storage System'), (4583, 4538, N'Bulk Energy Storage System'),
(4584, 4539, N'Higher energy density'), (4585, 4539, N'Lower cost'), (4586, 4539, N'Faster charge/discharge'), (4587, 4539, N'Longer lifespan'),
(4588, 4541, N'The cost per cycle'), (4589, 4541, N'The total energy stored'), (4590, 4541, N'The ratio of energy out to energy in'), (4591, 4541, N'The time to charge'),
(4592, 4543, N'Electrochemical'), (4593, 4543, N'Thermal'), (4594, 4543, N'Mechanical'), (4595, 4543, N'Chemical');

--Department: System Development, Track: Renewable Energy, Course: Smart Grids & Grid Integration
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4596, 4545, N'One-way power flow'), (4597, 4545, N'Two-way communication'), (4598, 4545, N'Analog meters'), (4599, 4545, N'Manual fault correction'),
(4600, 4547, N'Distributed Energy Resources'), (4601, 4547, N'Direct Energy Resources'), (4602, 4547, N'Distributed Energy Response'), (4603, 4547, N'Dynamic Energy Resources'),
(4604, 4549, N'Utilities forcing blackouts'), (4605, 4549, N'Consumers reducing use during peak times'), (4606, 4549, N'Generating more power'), (4607, 4549, N'Storing energy'),
(4608, 4551, N'A small, isolated grid'), (4609, 4551, N'A local grid that can disconnect'), (4610, 4551, N'A utility-scale battery'), (4611, 4551, N'The main power grid'),
(4612, 4553, N'Advanced Metering Infrastructure'), (4613, 4553, N'Automated Metering Infrastructure'), (4614, 4553, N'Advanced Metering Interface'), (4615, 4553, N'Automated Metering Interface'),
(4616, 4555, N'Vehicle-to-Grid'), (4617, 4555, N'Voltage-to-Grid'), (4618, 4555, N'Vehicle-to-Go'), (4619, 4555, N'Voltage-to-Go'),
(4620, 4557, N'Resistance to voltage changes'), (4621, 4557, N'Resistance to frequency changes'), (4622, 4557, N'The total power capacity'), (4623, 4557, N'The speed of power flow'),
(4624, 4559, N'Generate power'), (4625, 4559, N'Provide real-time grid monitoring'), (4626, 4559, N'Store energy'), (4627, 4559, N'Convert DC to AC');

--Department: System Development, Track: Renewable Energy, Course: Renewable Energy Policy & Economics
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4628, 4560, N'Levelized Cost of Energy'), (4629, 4560, N'Low Cost of Energy'), (4630, 4560, N'Levelized cost of Emissions'), (4631, 4560, N'Lifetime Cost of Energy'),
(4632, 4562, N'A tax on fossil fuels'), (4633, 4562, N'A subsidy for consumers'), (4634, 4562, N'A guaranteed price for renewable energy sent to the grid'), (4635, 4562, N'A consumer-paid fee'),
(4636, 4564, N'Renewable Power Standard'), (4637, 4564, N'Renewable Portfolio Standard'), (4638, 4564, N'Regional Power Standard'), (4639, 4564, N'Renewable Portfolio System'),
(4640, 4566, N'Renewable Energy Credit'), (4641, 4566, N'Renewable Energy Certificate'), (4642, 4566, N'Regional Energy Credit'), (4643, 4566, N'Renewable Energy Cost'),
(4644, 4568, N'A tax on emissions'), (4645, 4568, N'A market-based system to limit emissions'), (4646, 4568, N'A ban on emissions'), (4647, 4568, N'A subsidy for low emissions'),
(4648, 4570, N'Access to reliable and affordable energy'), (4649, 4570, N'Energy independence'), (4650, 4570, N'Using only renewable energy'), (4651, 4570, N'Securing the power grid from attacks'),
(4652, 4572, N'Feed-in Tariff'), (4653, 4572, N'Net Metering'), (4654, 4572, N'Renewable Portfolio Standard'), (4655, 4572, N'Carbon Tax'),
(4656, 4574, N'Project Purchase Agreement'), (4657, 4574, N'Power Portfolio Agreement'), (4658, 4574, N'Power Purchase Agreement'), (4659, 4574, N'Project Portfolio Agreement');

--Department: System Development, Track: Renewable Energy, Course: Project Management for Energy
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4660, 4575, N'Planning'), (4661, 4575, N'Execution'), (4662, 4575, N'Initiation'), (4663, 4575, N'Closing'),
(4664, 4577, N'Uncontrolled changes to the project'), (4665, 4577, N'A reduction in project scope'), (4666, 4577, N'The project manager'), (4667, 4577, N'A formal change request'),
(4668, 4579, N'The project schedule'), (4669, 4579, N'The project''s viability'), (4670, 4579, N'The project budget'), (4671, 4579, N'The project team'),
(4672, 4581, N'Energy, Procurement, and Construction'), (4673, 4581, N'Engineering, Procurement, and Construction'), (4674, 4581, N'Engineering, Power, and Construction'), (4675, 4581, N'Energy, Power, and Construction'),
(4676, 4583, N'The project manager only'), (4677, 4583, N'The customer only'), (4678, 4583, N'Anyone affected by the project'), (4679, 4583, N'The project team only'),
(4680, 4585, N'Operations & Maintenance'), (4681, 4585, N'Organization & Management'), (4682, 4585, N'Opportunity & Management'), (4683, 4585, N'Operations & Management'),
(4684, 4587, N'Scope'), (4685, 4587, N'Risk'), (4686, 4587, N'Quality'), (4687, 4587, N'Team'),
(4688, 4589, N'Gantt Chart'), (4689, 4589, N'WBS'), (4690, 4589, N'Project Charter'), (4691, 4589, N'Feasibility Study');

--Department: System Development, Track: Renewable Energy, Course: Renewable Energy Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(4692, 4590, N'To learn one new skill'), (4693, 4590, N'To integrate and apply skills'), (4694, 4590, N'To pass the final exam'), (4695, 4590, N'To write a long report'),
(4696, 4592, N'Start coding immediately'), (4697, 4592, N'Define the problem statement'), (4698, 4592, N'Build the hardware'), (4699, 4592, N'Write the final report'),
(4700, 4594, N'A good project name'), (4701, 4594, N'A list of team members'), (4702, 4594, N'Wind resource assessment'), (4703, 4594, N'A marketing plan'),
(4704, 4596, N'Aesthetic design'), (4705, 4596, N'Marketing analysis'), (4706, 4596, N'Battery sizing and dispatch strategy'), (4707, 4596, N'A project logo'),
(4708, 4598, N'Only the final answer'), (4709, 4598, N'Assumptions and limitations'), (4710, 4598, N'A list of websites visited'), (4711, 4598, N'A personal opinion'),
(4712, 4600, N'Team member salaries'), (4713, 4600, N'LCOE or NPV'), (4714, 4600, N'The cost of the software used'), (4715, 4600, N'The color scheme'),
(4716, 4602, N'Grid stability impact'), (4717, 4602, N'The project''s color palette'), (4718, 4602, N'Team member preferences'), (4719, 4602, N'Local sports teams'),
(4720, 4604, N'Expertise in one specific tool'), (4721, 4604, N'A comprehensive understanding of the project lifecycle'), (4722, 4604, N'How fast the project was done'), (4723, 4604, N'The ability to follow instructions perfectly');

-- #############################################################################
-- # Track 11 Full Stack Web Development Using .Net  Question_Bank INSERTS
-- #############################################################################

--Department: Java, Track: Full Stack Web Development Using .Net, Course: C# & ASP.NET Core MVC
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5000, 71, N'MCQ', N'What does "MVC" stand for?', N'Model-View-Controller'),
(5001, 71, N'True/False', N'C# is a dynamically-typed language.', N'False'),
(5002, 71, N'MCQ', N'Which file extension is used for Razor views?', N'.cshtml'),
(5003, 71, N'True/False', N'In MVC, the Controller handles business logic.', N'False'),
(5004, 71, N'MCQ', N'What folder traditionally holds the views?', N'Views'),
(5005, 71, N'True/False', N'ASP.NET Core is cross-platform (Windows, Mac, Linux).', N'True'),
(5006, 71, 'MCQ', N'What C# keyword is used for inheritance?', N'colon (:)'),
(5007, 71, N'True/False', N'A "class" is an instance of an "object".', N'False'),
(5008, 71, N'MCQ', N'Which is a C# value type?', N'int'),
(5009, 71, N'True/False', N'`ViewBag` is a static property.', N'False'),
(5010, 71, N'MCQ', N'What is the entry point file in an ASP.NET Core app?', N'Program.cs'),
(5011, 71, N'True/False', N'Tag Helpers are server-side code.', N'True'),
(5012, 71, N'MCQ', N'Which OOP pillar hides implementation details?', N'Encapsulation'),
(5013, 71, N'True/False', N'Kestrel is the in-process web server for ASP.NET Core.', N'True'),
(5014, 71, N'MCQ', N'What is the base class for all .NET types?', N'System.Object');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Entity Framework Core & SQL Server
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5015, 72, N'MCQ', N'What is Entity Framework Core?', N'An Object-Relational Mapper (ORM)'),
(5016, 72, N'True/False', N'EF Core only supports SQL Server.', N'False'),
(5017, 72, N'MCQ', N'What class is the "gateway" to the database?', N'DbContext'),
(5018, 72, N'True/False', N'LINQ stands for Language Integrated Query.', N'True'),
(5019, 72, N'MCQ', N'What DB approach generates DB from code?', N'Code-First'),
(5020, 72, N'True/False', N'The `Add-Migration` command executes the migration.', N'False'),
(5021, 72, N'MCQ', N'What command applies pending migrations?', N'Update-Database'),
(5022, 72, N'True/False', N'A `DbSet<T>` property represents a table.', N'True'),
(5023, 72, N'MCQ', N'Which LINQ method executes the query immediately?', N'.ToList()'),
(5024, 72, N'True/False', N'EF Core uses eager loading by default.', N'False'),
(5025, 72, N'MCQ', N'What SQL keyword filters rows?', N'WHERE'),
(5026, 72, N'True/False', N'A primary key (PK) must be unique.', N'True'),
(5027, 72, N'MCQ', N'What links two tables together in SQL?', N'Foreign Key'),
(5028, 72, N'True/False', N'EF Core lazy loading is enabled by default.', N'False'),
(5029, 72, N'MCQ', N'What is "Database-First"?', N'Generating code from an existing DB');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Building RESTful APIs with .NET
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5030, 73, N'MCQ', N'What does "REST" stand for?', N'Representational State Transfer'),
(5031, 73, N'True/False', N'REST APIs must use JSON.', N'False'),
(5032, 73, N'MCQ', N'Which HTTP verb is for creating a new resource?', N'POST'),
(5033, 73, N'MCQ', N'Which HTTP verb is for retrieving a resource?', N'GET'),
(5034, 73, N'True/False', N'A 404 status code means "OK".', N'False'),
(5035, 73, N'True/False', N'A 201 status code means "Created".', N'True'),
(5036, 73, N'MCQ', N'What attribute marks a class as an API controller?', N'[ApiController]'),
(5037, 73, N'MCQ', N'What HTTP verb is "idempotent" and updates a resource?', N'PUT'),
(5038, 73, N'True/False', N'The `[FromBody]` attribute gets data from the URL.', N'False'),
(5039, 73, N'MCQ', N'What common return type allows flexible status codes?', N'IActionResult'),
(5040, 73, N'True/False', N'HTTP DELETE is used to delete a resource.', N'True'),
(5041, 73, N'MCQ', N'What does a 500 status code mean?', N'Internal Server Error'),
(5042, 73, N'True/False', N'API routing is defined using `[Route]` attributes.', N'True'),
(5043, 73, N'MCQ', N'What tool is often used to test APIs?', N'Postman'),
(5044, 73, N'True/False', N'REST is a protocol, like HTTP.', N'False');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Client-Side with Angular/TypeScript
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5045, 74, N'MCQ', N'What is TypeScript?', N'A superset of JavaScript'),
(5046, 74, N'True/False', N'Angular is a .NET framework.', N'False'),
(5047, 74, N'MCQ', N'What is the basic building block of an Angular app?', N'Component'),
(5048, 74, N'True/False', N'Angular uses `ng-model` for two-way data binding.', N'True'),
(5049, 74, N'MCQ', N'What command creates a new Angular component?', N'ng generate component'),
(5050, 74, N'True/False', N'TypeScript code runs directly in the browser.', N'False'),
(5051, 74, N'MCQ', N'What are Angular "Services" used for?', N'Sharing data/logic'),
(5052, 74, N'True/False', N'Dependency Injection (DI) is a core feature of Angular.', N'True'),
(5053, 74, N'MCQ', N'What file defines an Angular module?', N'app.module.ts'),
(5054, 74, N'True/False', N'Interpolation uses double curly braces `{{ }}`.', N'True'),
(5055, 74, N'MCQ', N'Which is NOT a valid TypeScript type?', N'Object'),
(5056, 74, N'MCQ', N'What Angular feature handles navigation?', N'Router'),
(5057, 74, N'True/False', N'The `HttpClient` module is for making API calls.', N'True'),
(5058, 74, N'True/False', N'An Angular component is just an HTML file.', N'False'),
(5059, 74, N'MCQ', N'What is `*ngFor` used for?', N'Looping over a list');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Azure Deployment & DevOps
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5060, 75, N'MCQ', N'What is Azure?', N'A cloud computing platform'),
(5061, 75, N'True/False', N'PaaS stands for Platform as a Service.', N'True'),
(5062, 75, N'MCQ', N'What Azure service is best for hosting web apps?', N'Azure App Service'),
(5063, 75, N'True/False', N'IaaS means you manage the physical servers.', N'False'),
(5064, 75, N'MCQ', N'What does "CI/CD" stand for?', N'Continuous Integration/Continuous Delivery'),
(5065, 75, N'True/False', N'Azure DevOps is a tool for managing CI/CD.', N'True'),
(5066, 75, N'MCQ', N'What is "Continuous Integration"?', N'Automatically building/testing code'),
(5067, 75, N'True/False', N'Azure SQL Database is an IaaS service.', N'False'),
(5068, 75, N'MCQ', N'What Azure DevOps service manages code?', N'Azure Repos'),
(5069, 75, N'True/False', N'A "build pipeline" compiles code and runs tests.', N'True'),
(5070, 75, N'MCQ', N'A "release pipeline" is used to:', N'Deploy the application'),
(5071, 75, N'True/False', N'Git is the only version control supported by Azure Repos.', N'False'),
(5072, 75, N'MCQ', N'What is an "App Service Plan"?', N'Defines the compute resources'),
(5073, 75, N'True/False', N'DevOps is only about tools, not culture.', N'False'),
(5074, 75, N'MCQ', N'What is "Infrastructure as Code" (IaC)?', N'Managing infrastructure via code');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Microservices Architecture
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5075, 76, N'MCQ', N'What is the opposite of a microservices architecture?', N'Monolith'),
(5076, 76, N'True/False', N'Microservices are loosely coupled.', N'True'),
(5077, 76, N'MCQ', N'What is a main benefit of microservices?', N'Independent deployment'),
(5078, 76, N'True/False', N'Microservices must all use the same database.', N'False'),
(5079, 76, N'MCQ', N'What component routes external requests to services?', N'API Gateway'),
(5080, 76, N'True/False', N'Microservices simplify overall application complexity.', N'False'),
(5081, 76, N'MCQ', N'What is "Service Discovery"?', N'Finding the network location of services'),
(5082, 76, N'True/False', N'Docker is a tool for containerizing microservices.', N'True'),
(5083, 76, N'MCQ', N'What is a major challenge of microservices?', N'Data consistency'),
(5084, 76, N'True/False', N'Each microservice should have a large, broad responsibility.', N'False'),
(5085, 76, N'MCQ', N'What pattern helps manage failed service calls?', N'Circuit Breaker'),
(5086, 76, N'True/False', N'All microservices must be written in .NET.', N'False'),
(5087, 76, N'MCQ', N'How do microservices typically communicate?', N'APIs (HTTP or messaging)'),
(5088, 76, N'True/False', N'Scalability is a key disadvantage of microservices.', N'False'),
(5089, 76, N'MCQ', N'What is a "container"?', N'A lightweight, standalone package of software');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: .NET Full Stack Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5090, 77, N'MCQ', N'What is the purpose of a capstone project?', N'To integrate and apply all learned skills'),
(5091, 77, N'True/False', N'A capstone only focuses on the back-end API.', N'False'),
(5092, 77, N'MCQ', N'What pattern separates data logic from controllers?', N'Repository Pattern'),
(5093, 77, N'True/False', N'"CORS" is not needed when front-end and back-end are on different domains.', N'False'),
(5094, 77, N'MCQ', N'What does "CORS" stand for?', N'Cross-Origin Resource Sharing'),
(5095, 77, N'True/False', N'A good capstone includes a CI/CD pipeline.', N'True'),
(5096, 77, N'MCQ', N'What is commonly used for authentication in a .NET/Angular app?', N'JWT (JSON Web Tokens)'),
(5097, 77, N'True/False', N'Angular''s `HttpClient` is used to call the .NET API.', N'True'),
(5098, 77, N'MCQ', N'What is a "unit test"?', N'A test for a small, isolated piece of code'),
(5099, 77, N'True/False', N'You should store connection strings directly in your source code on Git.', N'False'),
(5100, 77, N'MCQ', N'What file in .NET is used for user secrets?', N'secrets.json'),
(5101, 77, N'True/False', N'A capstone project should be in source control (e.g., Git).', N'True'),
(5102, 77, N'MCQ', N'What is "dependency injection" used for?', N'Decoupling components'),
(5103, 77, N'True/False', N'The .NET API should return Views, not JSON.', N'False'),
(5104, 77, N'MCQ', N'What is "Full Stack"?', N'Working on both front-end and back-end');




-- #############################################################################
-- # FILE 2: Question_Choice INSERTS
-- #############################################################################

--Department: Java, Track: Full Stack Web Development Using .Net, Course: C# & ASP.NET Core MVC
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5000, 5000, N'Model-View-Controller'), (5001, 5000, N'Model-View-Component'), (5002, 5000, N'Main-View-Controller'), (5003, 5000, N'Model-Value-Controller'),
(5004, 5002, N'.cs'), (5005, 5002, N'.html'), (5006, 5002, N'.cshtml'), (5007, 5002, N'.js'),
(5008, 5004, N'Models'), (5009, 5004, N'Controllers'), (5010, 5004, N'Views'), (5011, 5004, N'wwwroot'),
(5012, 5006, N'plus (+)'), (5013, 5006, N'colon (:)'), (5014, 5006, N'implements'), (5015, 5006, N'inherits'),
(5016, 5008, N'int'), (5017, 5008, N'string'), (5018, 5008, N'object'), (5019, 5008, N'class'),
(5020, 5010, N'Startup.cs'), (5021, 5010, N'Program.cs'), (5022, 5010, N'Index.cshtml'), (5023, 5010, N'appsettings.json'),
(5024, 5012, N'Inheritance'), (5025, 5012, N'Polymorphism'), (5026, 5012, N'Encapsulation'), (5027, 5012, N'Abstraction'),
(5028, 5014, N'System.Object'), (5029, 5014, N'System.Base'), (5030, 5014, N'System.Core'), (5031, 5014, N'System.Type');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Entity Framework Core & SQL Server
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5032, 5015, N'A database server'), (5033, 5015, N'An Object-Relational Mapper (ORM)'), (5034, 5015, N'A query language'), (5035, 5015, N'A .NET compiler'),
(5036, 5017, N'DbSet'), (5037, 5017, N'SQLContext'), (5038, 5017, N'DbContext'), (5039, 5017, N'Database'),
(5040, 5019, N'Code-First'), (5041, 5019, N'Database-First'), (5042, 5019, N'Model-First'), (5043, 5019, N'Query-First'),
(5044, 5021, N'Add-Migration'), (5045, 5021, N'Update-Database'), (5046, 5021, N'Scaffold-DbContext'), (5047, 5021, N'Drop-Database'),
(5048, 5023, N'.Select()'), (5049, 5023, N'.Where()'), (5050, 5023, N'.ToList()'), (5051, 5023, N'.Find()'),
(5052, 5025, N'SELECT'), (5053, 5025, N'WHERE'), (5054, 5025, N'FILTER'), (5055, 5025, N'HAVING'),
(5056, 5027, N'Primary Key'), (5057, 5027, N'Foreign Key'), (5058, 5027, N'Candidate Key'), (5059, 5027, N'Index'),
(5060, 5029, N'Generating code from an existing DB'), (5061, 5029, N'Writing code before the DB'), (5062, 5029, N'Deleting the database'), (5063, 5029, N'A type of SQL');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Building RESTful APIs with .NET
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5064, 5030, N'Representational State Transfer'), (5065, 5030, N'Remote State Transfer'), (5066, 5030, N'Resource State Transfer'), (5067, 5030, N'Representational Service Transfer'),
(5068, 5032, N'GET'), (5069, 5032, N'POST'), (5070, 5032, N'PUT'), (5071, 5032, N'DELETE'),
(5072, 5033, N'GET'), (5073, 5033, N'POST'), (5074, 5033, N'PATCH'), (5075, 5033, N'DELETE'),
(5076, 5036, N'[Route]'), (5077, 5036, N'[Controller]'), (5078, 5036, N'[ApiController]'), (5079, 5036, N'[Api]'),
(5080, 5037, N'POST'), (5081, 5037, N'GET'), (5082, 5037, N'PATCH'), (5083, 5037, N'PUT'),
(5084, 5039, N'IActionResult'), (5085, 5039, N'View'), (5086, 5039, N'JsonResult'), (5087, 5039, N'string'),
(5088, 5041, N'Not Found'), (5089, 5041, N'Bad Request'), (5090, 5041, N'Internal Server Error'), (5091, 5041, N'OK'),
(5092, 5043, N'Visual Studio'), (5093, 5043, N'Postman'), (5094, 5043, N'SQL Server'), (5095, 5043, N'Git');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Client-Side with Angular/TypeScript
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5096, 5045, N'A superset of JavaScript'), (5097, 5045, N'A new browser'), (5098, 5045, N'A .NET language'), (5099, 5045, N'A database'),
(5100, 5047, N'Service'), (5101, 5047, N'Module'), (5102, 5047, N'Component'), (5103, 5047, N'Pipe'),
(5104, 5049, N'ng new component'), (5105, 5049, N'ng generate component'), (5106, 5049, N'ng add component'), (5107, 5049, N'ng component create'),
(5108, 5051, N'Styling components'), (5109, 5051, N'Routing'), (5110, 5051, N'Sharing data/logic'), (5111, 5051, N'Storing HTML'),
(5112, 5053, N'app.component.ts'), (5113, 5053, N'main.ts'), (5114, 5053, N'app.module.ts'), (5115, 5053, N'angular.json'),
(5116, 5055, N'string'), (5117, 5055, N'number'), (5118, 5055, N'boolean'), (5119, 5055, N'Object'),
(5120, 5056, N'HttpClient'), (5121, 5056, N'Router'), (5122, 5056, N'FormsModule'), (5123, 5056, N'BrowserModule'),
(5124, 5059, N'Conditional rendering'), (5125, 5059, N'Looping over a list'), (5126, 5059, N'Binding events'), (5127, 5059, N'Two-way binding');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Azure Deployment & DevOps
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5128, 5060, N'A cloud computing platform'), (5129, 5060, N'A .NET framework'), (5130, 5060, N'A database'), (5131, 5060, N'An IDE'),
(5132, 5062, N'Azure Functions'), (5133, 5062, N'Azure App Service'), (5134, 5062, N'Azure VM'), (5135, 5062, N'Azure Storage'),
(5136, 5064, N'Continuous Integration/Continuous Delivery'), (5137, 5064, N'Code Integration/Code Deployment'), (5138, 5064, N'Continuous Integration/Code Delivery'), (5139, 5064, N'Code Integration/Continuous Deployment'),
(5140, 5066, N'Deploying to production'), (5141, 5066, N'Automatically building/testing code'), (5142, 5066, N'Writing code'), (5143, 5066, N'Planning features'),
(5144, 5068, N'Azure Pipelines'), (5145, 5068, N'Azure Boards'), (5146, 5068, N'Azure Repos'), (5147, 5068, N'Azure Artifacts'),
(5148, 5070, N'Compile the code'), (5149, 5070, N'Run unit tests'), (5150, 5070, N'Store code'), (5151, 5070, N'Deploy the application'),
(5152, 5072, N'A type of database'), (5153, 5072, N'Defines the compute resources'), (5154, 5072, N'A CI/CD pipeline'), (5155, 5072, N'A source code repository'),
(5156, 5074, N'Managing infrastructure via code'), (5157, 5074, N'Manually configuring servers'), (5158, 5074, N'A type of cloud service'), (5159, 5074, N'A deployment strategy');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: Microservices Architecture
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5160, 5075, N'Monolith'), (5161, 5075, N'API Gateway'), (5162, 5075, N'Container'), (5163, 5075, N'Service'),
(5164, 5077, N'Independent deployment'), (5165, 5077, N'Simplified testing'), (5166, 5077, N'Single database'), (5167, 5077, N'No network latency'),
(5168, 5079, N'API Gateway'), (5169, 5079, N'Service Discovery'), (5170, 5079, N'Docker'), (5171, 5079, N'Kubernetes'),
(5172, 5081, N'A design pattern'), (5173, 5081, N'Finding the network location of services'), (5174, 5081, N'A type of database'), (5175, 5081, N'An API gateway'),
(5176, 5083, N'Scalability'), (5177, 5083, N'Data consistency'), (5178, 5083, N'Independent deployment'), (5179, 5083, N'Fault isolation'),
(5180, 5085, N'API Gateway'), (5181, 5085, N'Circuit Breaker'), (5182, 5085, N'Retry Pattern'), (5183, 5085, N'Saga Pattern'),
(5184, 5087, N'Direct memory calls'), (5185, 5087, N'Shared database tables'), (5186, 5087, N'APIs (HTTP or messaging)'), (5187, 5087, N'File sharing'),
(5188, 5089, N'A virtual machine'), (5189, 5089, N'A lightweight, standalone package of software'), (5190, 5089, N'A .NET project'), (5191, 5089, N'A database');

--Department: Java, Track: Full Stack Web Development Using .Net, Course: .NET Full Stack Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5192, 5090, N'To learn one new technology'), (5193, 5090, N'To integrate and apply all learned skills'), (5194, 5090, N'To build an API only'), (5195, 5090, N'To build a UI only'),
(5196, 5092, N'Controller Pattern'), (5197, 5092, N'Singleton Pattern'), (5198, 5092, N'Repository Pattern'), (5199, 5092, N'View Pattern'),
(5200, 5094, N'Cross-Origin Resource Sharing'), (5201, 5094, N'Cross-Origin Request Service'), (5202, 5094, N'Cross-Object Resource Sharing'), (5203, 5094, N'Code-Origin Resource Sharing'),
(5204, 5096, N'Session Cookies'), (5205, 5096, N'Basic Auth'), (5206, 5096, N'JWT (JSON Web Tokens)'), (5207, 5096, N'OAuth 1.0'),
(5208, 5098, N'A test for the full application'), (5209, 5098, N'A test for a small, isolated piece of code'), (5210, 5098, N'A test for the UI'), (5211, 5098, N'A test for database connection'),
(5212, 5100, N'appsettings.json'), (5213, 5100, N'secrets.json'), (5214, 5100, N'Program.cs'), (5215, 5100, N'web.config'),
(5216, 5102, N'Tightly coupling components'), (5217, 5102, N'Making code harder to test'), (5218, 5102, N'Decoupling components'), (5219, 5102, N'Managing database connections'),
(5220, 5104, N'Working on the database only'), (5221, 5104, N'Working on the front-end only'), (5222, 5104, N'Working on both front-end and back-end'), (5223, 5104, N'Working on the back-end only');


-- #############################################################################
-- # Track 12 Full Stack Web Development Using MERN Question_Bank INSERTS
-- #############################################################################

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Node.js, Express & MongoDB
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5500, 78, N'MCQ', N'What is Node.js?', N'A back-end JavaScript runtime'),
(5501, 78, N'True/False', N'Node.js is single-threaded.', N'True'),
(5502, 78, N'MCQ', N'What is Express.js?', N'A web framework for Node.js'),
(5503, 78, N'True/False', N'MongoDB is a SQL database.', N'False'),
(5504, 78, N'MCQ', N'What format does MongoDB use to store data?', N'BSON (like JSON)'),
(5505, 78, N'True/False', N'NPM is the default package manager for Node.js.', N'True'),
(5506, 78, N'MCQ', N'What is a "document" in MongoDB?', N'A single record'),
(5507, 78, N'True/False', N'Mongoose is an ODM for MongoDB.', N'True'),
(5508, 78, N'MCQ', N'What file lists project dependencies?', N'package.json'),
(5509, 78, N'True/False', N'`require()` is the ES6 module syntax in Node.js.', N'False'),
(5510, 78, N'MCQ', N'What is a "collection" in MongoDB?', N'A group of documents (like a table)'),
(5511, 78, N'True/False', N'Express middleware can intercept requests.', N'True'),
(5512, 78, N'MCQ', N'What does the "M" in MERN stand for?', N'MongoDB'),
(5513, 78, N'True/False', N'Node.js is ideal for CPU-intensive tasks.', N'False'),
(5514, 78, N'MCQ', N'What is `nodemon` used for?', N'Restarting the server on file changes');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Building RESTful APIs
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5515, 79, N'MCQ', N'What HTTP method is for retrieving data?', N'GET'),
(5516, 79, N'True/False', N'A 200 status code means "Not Found".', N'False'),
(5517, 79, N'MCQ', N'What HTTP method is for creating new data?', N'POST'),
(5518, 79, N'True/False', N'A 201 status code means "Created".', N'True'),
(5519, 79, N'MCQ', N'What HTTP method is for updating an entire resource?', N'PUT'),
(5520, 79, N'True/False', N'REST stands for Representational State Transfer.', N'True'),
(5521, 79, N'MCQ', N'What HTTP method is for partial updates?', N'PATCH'),
(5522, 79, N'True/False', N'A 400 status code means "Bad Request".', N'True'),
(5523, 79, N'MCQ', N'What HTTP method deletes a resource?', N'DELETE'),
(5524, 79, N'True/False', N'`req.body` in Express contains URL parameters.', N'False'),
(5525, 79, N'MCQ', N'What middleware is needed to parse JSON bodies?', N'express.json()'),
(5526, 79, N'True/False', N'`req.params` contains data from the query string.', N'False'),
(5527, 79, N'MCQ', N'How do you send a JSON response in Express?', N'res.json()'),
(5528, 79, N'True/False', N'A 500 status code means "Internal Server Error".', N'True'),
(5529, 79, N'MCQ', N'What is Postman used for?', N'Testing APIs');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: React.js & Redux
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5530, 80, N'MCQ', N'What is React?', N'A JavaScript library for UIs'),
(5531, 80, N'True/False', N'React uses a real DOM.', N'False'),
(5532, 80, N'MCQ', N'What is JSX?', N'A syntax extension for JavaScript'),
(5533, 80, N'True/False', N'In React, data flows one way (parent to child).', N'True'),
(5534, 80, N'MCQ', N'What is "state" in React?', N'Internal data storage for a component'),
(5535, 80, N'True/False', N'You can modify "props" directly in a component.', N'False'),
(5536, 80, 'MCQ', N'What hook manages state in functional components?', N'useState'),
(5537, 80, N'True/False', N'Redux is a framework for React.', N'False'),
(5538, 80, N'MCQ', N'What is Redux used for?', N'Global state management'),
(5539, 80, N'True/False', N'In Redux, the "store" holds the entire app state.', N'True'),
(5540, 80, N'MCQ', N'What is a "reducer" in Redux?', N'A pure function that updates state'),
(5541, 80, N'True/False', N'You must mutate state directly in Redux.', N'False'),
(5542, 80, N'MCQ', N'What do you "dispatch" to trigger a Redux state change?', N'An action'),
(5543, 80, N'True/False', N'`create-react-app` is a tool to scaffold a new React app.', N'True'),
(5544, 80, N'MCQ', N'What hook performs side effects (e.g., data fetching)?', N'useEffect');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Authentication with JWT
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5545, 81, N'MCQ', N'What does JWT stand for?', N'JSON Web Token'),
(5546, 81, N'True/False', N'JWTs are encrypted by default.', N'False'),
(5547, 81, N'MCQ', N'What are the three parts of a JWT?', N'Header, Payload, Signature'),
(5548, 81, N'True/False', N'The JWT signature verifies the token''s integrity.', N'True'),
(5549, 81, N'MCQ', N'Where is user data (claims) stored in a JWT?', N'Payload'),
(5550, 81, N'True/False', N'JWTs must be stored in server-side sessions.', N'False'),
(5551, 81, N'MCQ', N'What is a common way to send a JWT to the server?', N'Authorization Header'),
(5552, 81, N'True/False', N'`bcrypt` is a library for hashing passwords.', N'True'),
(5553, 81, N'MCQ', N'What "Bearer" scheme prefix is used in the header?', N'Bearer '),
(5554, 81, N'True/False', N'You should store plain text passwords in the database.', N'False'),
(5555, 81, N'MCQ', N'What is "salting" a password?', N'Adding random data before hashing'),
(5556, 81, N'True/False', N'JWTs are stateful.', N'False'),
(5557, 81, N'MCQ', N'What part of the JWT ensures it wasn''t tampered with?', N'Signature'),
(5558, 81, N'True/False', N'A JWT cannot expire.', N'False'),
(5559, 81, N'MCQ', N'What library is often used to create JWTs in Node.js?', N'jsonwebtoken');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Consuming APIs in React
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5560, 82, N'MCQ', N'What hook is best for fetching data?', N'useEffect'),
(5561, 82, N'True/False', N'The browser''s `fetch` API returns a promise.', N'True'),
(5562, 82, N'MCQ', N'What is a popular library for making HTTP requests?', N'Axios'),
(5563, 82, N'True/False', N'Data fetching is a side effect in React.', N'True'),
(5564, 82, N'MCQ', N'How do you handle loading states?', N'With a state variable (e.g., `isLoading`)'),
(5565, 82, N'True/False', N'`useEffect` with an empty dependency array `[]` runs only once.', N'True'),
(5566, 82, N'MCQ', N'What does "CORS" stand for?', N'Cross-Origin Resource Sharing'),
(5567, 82, N'True/False', N'CORS errors are client-side React errors.', N'False'),
(5568, 82, N'MCQ', N'What `fetch` method is used to send JSON data?', N'POST'),
(5569, 82, N'True/False', N'You must `await` the `.json()` method on a fetch response.', N'True'),
(5570, 82, N'MCQ', N'Where do you typically store fetched data in a component?', N'In state'),
(5571, 82, N'True/False', N'Axios automatically stringifies JSON data.', N'True'),
(5572, 82, N'MCQ', N'How do you handle errors in a `fetch` promise chain?', N'`.catch()`'),
(5573, 82, N'True/False', N'You should put `fetch` calls directly in the component body.', N'False'),
(5574, 82, N'MCQ', N'What is an "async/await" used for?', N'Writing asynchronous code');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Testing & Deployment
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5575, 83, N'MCQ', N'What is Jest?', N'A JavaScript testing framework'),
(5576, 83, N'True/False', N'Unit tests check individual functions or components.', N'True'),
(5577, 83, N'MCQ', N'What is "Integration Testing"?', N'Testing how multiple units work together'),
(5578, 83, N'True/False', N'React Testing Library (RTL) tests implementation details.', N'False'),
(5579, 83, N'MCQ', N'What command builds a React app for production?', N'npm run build'),
(5580, 83, N'True/False', N'The `build` folder contains static files to be deployed.', N'True'),
(5581, 83, N'MCQ', N'What is Heroku?', N'A PaaS for deploying applications'),
(5582, 83, N'True/False', N'Environment variables (like secrets) should be in Git.', N'False'),
(5583, 83, N'MCQ', N'What service is commonly used to deploy static React apps?', N'Netlify'),
(5584, 83, N'True/False', N'A `Procfile` tells Heroku how to start your app.', N'True'),
(5585, 83, N'MCQ', N'What is "CI/CD"?', N'Continuous Integration/Continuous Delivery'),
(5586, 83, N'True/False', N'Jest `expect` is used to make assertions.', N'True'),
(5587, 83, N'MCQ', N'What is "E2E" (End-to-End) testing?', N'Testing the full application flow'),
(5588, 83, N'True/False', N'You deploy the entire Node.js server to Netlify.', N'False'),
(5589, 83, N'MCQ', N'What is `dotenv` used for?', N'Loading environment variables');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: MERN Stack Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(5590, 84, N'MCQ', N'What is the goal of a MERN capstone?', N'To build a full-stack application'),
(5591, 84, N'True/False', N'The capstone involves only a React front-end.', N'False'),
(5592, 84, N'MCQ', N'How does the React front-end talk to the Express back-end?', N'Via API calls (HTTP)'),
(5593, 84, N'True/False', N'Authentication (like JWT) is a key capstone feature.', N'True'),
(5594, 84, N'MCQ', N'What does "CRUD" stand for?', N'Create, Read, Update, Delete'),
(5595, 84, N'True/False', N'A capstone project should use source control (Git).', N'True'),
(5596, 84, N'MCQ', N'Where is the application state (e.g., logged-in user) managed?', N'React (e.g., Context or Redux)'),
(5597, 84, N'True/False', N'The Mongoose schema defines the data structure.', N'True'),
(5598, 84, N'MCQ', N'What is "protected routing" in React?', N'Restricting access to pages based on auth'),
(5599, 84, N'True/False', N'The capstone should be deployed to a live service.', N'True'),
(5600, 84, N'MCQ', N'How is the Express server connected to MongoDB?', N'With a Mongoose connection string'),
(5601, 84, N'True/False', N'It is best practice to hard-code API URLs in React.', N'False'),
(5602, 84, N'MCQ', N'What is a common tool for state management in a large MERN app?', N'Redux'),
(5603, 84, N'True/False', N'The capstone tests skills from all MERN courses.', N'True'),
(5604, 84, N'MCQ', N'What is "data validation"?', N'Ensuring data is in the correct format');




-- #############################################################################
-- # FILE 2: Question_Choice INSERTS
-- #############################################################################

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Node.js, Express & MongoDB
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5500, 5500, N'A front-end library'), (5501, 5500, N'A back-end JavaScript runtime'), (5502, 5500, N'A database'), (5503, 5500, N'A text editor'),
(5504, 5502, N'A Node.js runtime'), (5505, 5502, N'A database'), (5506, 5502, N'A web framework for Node.js'), (5507, 5502, N'A package manager'),
(5508, 5504, N'JSON'), (5509, 5504, N'SQL'), (5510, 5504, N'BSON (like JSON)'), (5511, 5504, N'XML'),
(5512, 5506, N'A table'), (5513, 5506, N'A single record'), (5514, 5506, N'A database'), (5515, 5506, N'A schema'),
(5516, 5508, N'node_modules'), (5517, 5508, N'package.json'), (5518, 5508, N'package-lock.json'), (5519, 5508, N'server.js'),
(5520, 5510, N'A group of documents (like a table)'), (5521, 5510, N'A single field'), (5522, 5510, N'A database'), (5523, 5510, N'A data type'),
(5524, 5512, N'MySQL'), (5525, 5512, N'MongoDB'), (5526, 5512, N'MariaDB'), (5527, 5512, N'MS SQL'),
(5528, 5514, N'Running tests'), (5529, 5514, N'Installing packages'), (5530, 5514, N'Restarting the server on file changes'), (5531, 5514, N'Minifying code');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Building RESTful APIs
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5532, 5515, N'GET'), (5533, 5515, N'POST'), (5534, 5515, N'PUT'), (5535, 5515, N'DELETE'),
(5536, 5517, N'GET'), (5537, 5517, N'POST'), (5538, 5517, N'PATCH'), (5539, 5517, N'DELETE'),
(5540, 5519, N'POST'), (5541, 5519, N'GET'), (5542, 5519, N'PUT'), (5543, 5519, N'PATCH'),
(5544, 5521, N'PUT'), (5545, 5521, N'POST'), (5546, 5521, N'PATCH'), (5547, 5521, N'GET'),
(5548, 5523, N'GET'), (5549, 5523, N'UPDATE'), (5550, 5523, N'POST'), (5551, 5523, N'DELETE'),
(5552, 5525, N'express.json()'), (5553, 5525, N'express.urlencoded()'), (5554, 5525, N'cors()'), (5555, 5525, N'morgan()'),
(5556, 5527, N'res.send()'), (5557, 5527, N'res.json()'), (5558, 5527, N'res.render()'), (5559, 5527, N'res.status()'),
(5600, 5529, N'Testing APIs'), (5601, 5529, N'Writing code'), (5602, 5529, N'Deploying apps'), (5603, 5529, N'Managing databases');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: React.js & Redux
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5604, 5530, N'A JavaScript library for UIs'), (5605, 5530, N'A back-end framework'), (5606, 5530, N'A database'), (5607, 5530, N'A programming language'),
(5608, 5532, N'A type of HTML'), (5609, 5532, N'A syntax extension for JavaScript'), (5610, 5532, N'A CSS preprocessor'), (5611, 5532, N'A data fetching library'),
(5612, 5534, N'External data (props)'), (5613, 5534, N'Internal data storage for a component'), (5614, 5534, N'A global variable'), (5615, 5534, N'A CSS class'),
(5616, 5536, N'useState'), (5617, 5536, N'useEffect'), (5618, 5536, N'useContext'), (5619, 5536, N'useReducer'),
(5620, 5538, N'Routing'), (5621, 5538, N'Making API calls'), (5622, 5538, N'Styling components'), (5623, 5538, N'Global state management'),
(5624, 5540, N'A component'), (5625, 5540, N'An action'), (5626, 5540, N'A pure function that updates state'), (5627, 5540, N'A middleware'),
(5628, 5542, N'A reducer'), (5629, 5542, N'A component'), (5630, 5542, N'An action'), (5631, 5542, N'A selector'),
(5632, 5544, N'useState'), (5633, 5544, N'useEffect'), (5634, 5544, N'useRef'), (5635, 5544, N'useCallback');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Authentication with JWT
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5636, 5545, N'JavaScript Web Token'), (5637, 5545, N'JSON Web Token'), (5638, 5545, N'JSON Web Transfer'), (5639, 5545, N'JavaScript Web Transfer'),
(5640, 5547, N'Header, Payload, Signature'), (5641, 5547, N'Header, Body, Footer'), (5642, 5547, N'Claims, Payload, Signature'), (5643, 5547, N'Header, Claims, Secret'),
(5644, 5549, N'Header'), (5645, 5549, N'Payload'), (5646, 5549, N'Signature'), (5647, 5549, N'The secret key'),
(5648, 5551, N'Query Parameter'), (5649, 5551, N'Request Body'), (5650, 5551, N'Authorization Header'), (5651, 5551, N'Cookie'),
(5652, 5553, N'Token '), (5653, 5553, N'JWT '), (5654, 5553, N'Bearer '), (5655, 5553, N'Auth '),
(5656, 5555, N'Encrypting the password'), (5657, 5555, N'Adding random data before hashing'), (5658, 5555, N'Storing it in plain text'), (5659, 5555, N'Hashing it twice'),
(5660, 5557, N'Header'), (5661, 5557, N'Payload'), (5662, 5557, N'Signature'), (5663, 5557, N'Claims'),
(5664, 5559, N'bcrypt'), (5665, 5559, N'jsonwebtoken'), (5666, 5559, N'passport'), (5667, 5559, N'express-session');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Consuming APIs in React
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5668, 5560, N'useState'), (5669, 5560, N'useContext'), (5670, 5560, N'useEffect'), (5671, 5560, N'useRef'),
(5672, 5562, N'Node-fetch'), (5673, 5562, N'Axios'), (5674, 5562, N'React-query'), (5675, 5562, N'Redux'),
(5676, 5564, N'With a state variable (e.g., `isLoading`)'), (5677, 5564, N'With `setTimeout`'), (5678, 5564, N'By redirecting the user'), (5679, 5564, N'With `console.log`'),
(5680, 5566, N'Cross-Origin Resource Sharing'), (5681, 5566, N'Cross-Origin Request Sharing'), (5682, 5566, N'Client-Origin Resource Sharing'), (5683, 5566, N'Cross-Object Resource Sharing'),
(5684, 5568, N'GET'), (5685, 5568, N'PUT'), (5686, 5568, N'POST'), (5687, 5568, N'DELETE'),
(5688, 5570, N'In state'), (5689, 5570, N'In props'), (5690, 5570, N'In a global variable'), (5691, 5570, N'In `localStorage`'),
(5692, 5572, N'`.then()`'), (5693, 5572, N'`.finally()`'), (5694, 5572, N'`.catch()`'), (5695, 5572, N'`.error()`'),
(5696, 5574, N'Writing asynchronous code'), (5697, 5574, N'Styling components'), (5698, 5574, N'Managing state'), (5699, 5574, N'Declaring variables');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: Testing & Deployment
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5700, 5575, N'A JavaScript testing framework'), (5701, 5575, N'A React component library'), (5702, 5575, N'A deployment platform'), (5703, 5575, N'A code linter'),
(5704, 5577, N'Testing individual functions'), (5705, 5577, N'Testing the UI'), (5706, 5577, N'Testing how multiple units work together'), (5707, 5577, N'Testing the production app'),
(5708, 5579, N'npm start'), (5709, 5579, N'npm install'), (5710, 5579, N'npm test'), (5711, 5579, N'npm run build'),
(5712, 5581, N'A database'), (5713, 5581, N'A PaaS for deploying applications'), (5714, 5581, N'A testing tool'), (5715, 5581, N'A code editor'),
(5716, 5583, N'Heroku'), (5717, 5583, N'Azure App Service'), (5718, 5583, N'Netlify'), (5719, 5583, N'A dedicated server'),
(5720, 5585, N'Code Inspection/Code Deployment'), (5721, 5585, N'Continuous Integration/Continuous Delivery'), (5722, 5585, N'Component Integration/Component Delivery'), (5723, 5585, N'Continuous Inspection/Continuous Deployment'),
(5724, 5587, N'Testing individual components'), (5725, 5587, N'Testing API endpoints'), (5726, 5587, N'Testing the full application flow'), (5727, 5587, N'Testing the database'),
(5728, 5589, N'Testing code'), (5729, 5589, N'Loading environment variables'), (5730, 5589, N'Deploying to production'), (5731, 5589, N'Installing packages');

--Department: Java, Track: Full Stack Web Development Using MERN, Course: MERN Stack Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(5732, 5590, N'To build a full-stack application'), (5733, 5590, N'To learn CSS'), (5734, 5590, N'To test APIs'), (5735, 5590, N'To design a database'),
(5736, 5592, N'Shared memory'), (5737, 5592, N'Via API calls (HTTP)'), (5738, 5592, N'Direct database connection'), (5739, 5592, N'File sharing'),
(5740, 5594, N'Create, Read, Update, Delete'), (5741, 5594, N'Copy, Read, Update, Drop'), (5742, 5594, N'Create, Review, Upload, Download'), (5743, 5594, N'Connect, Read, Undo, Deploy'),
(5744, 5596, N'Node.js variables'), (5745, 5596, N'MongoDB'), (5746, 5596, N'React (e.g., Context or Redux)'), (5747, 5596, N'In browser cookies only'),
(5748, 5598, N'Styling routes'), (5749, 5598, N'Restricting access to pages based on auth'), (5750, 5598, N'Connecting routes to the API'), (5751, 5598, N'Testing routes'),
(5752, 5600, N'With `require("mongodb")`'), (5753, 5600, N'With a Mongoose connection string'), (5754, 5600, N'With an environment file only'), (5755, 5600, N'With `fetch`'),
(5756, 5602, N'useState'), (5757, 5602, N'Axios'), (5758, 5602, N'Redux'), (5759, 5602, N'React Router'),
(5760, 5604, N'Testing the UI'), (5761, 5604, N'Deploying the app'), (5762, 5604, N'Ensuring data is in the correct format'), (5763, 5604, N'Hashing passwords');

-- #############################################################################
-- #Track 13 Full Stack Web Development using Python Question_Bank INSERTS
-- #############################################################################

--Department: Java, Track: Full Stack Web Development using Python, Course: Python & Django Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6000, 85, N'MCQ', N'What is Python?', N'An interpreted, high-level programming language'),
(6001, 85, N'True/False', N'Python is a statically-typed language.', N'False'),
(6002, 85, N'MCQ', N'What is Django?', N'A high-level Python web framework'),
(6003, 85, N'True/False', N'Django follows the MVT (Model-View-Template) pattern.', N'True'),
(6004, 85, N'MCQ', N'What is a Python virtual environment?', N'An isolated environment for Python projects'),
(6005, 85, N'True/False', N'A Python `tuple` is mutable.', N'False'),
(6006, 85, N'MCQ', N'What keyword defines a function in Python?', N'def'),
(6007, 85, N'True/False', N'`pip` is the standard package manager for Python.', N'True'),
(6008, 85, N'MCQ', N'What file contains the URL patterns for a Django project?', N'urls.py'),
(6009, 85, N'True/False', N'Django''s ORM maps Python objects to database tables.', N'True'),
(6010, 85, N'MCQ', N'What command starts the Django development server?', N'python manage.py runserver'),
(6011, 85, N'True/False', N'A Django "app" is the same as a Django "project".', N'False'),
(6012, 85, N'MCQ', N'What part of MVT handles business logic and data?', N'View'),
(6013, 85, N'True/False', N'Django includes a built-in admin interface.', N'True'),
(6014, 85, N'MCQ', N'What file defines the data structure in Django?', N'models.py');

--Department: Java, Track: Full Stack Web Development using Python, Course: Django REST Framework for APIs
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6015, 86, N'MCQ', N'What does DRF stand for?', N'Django REST Framework'),
(6016, 86, N'True/False', N'DRF is used to build web APIs.', N'True'),
(6017, 86, N'MCQ', N'What is "Serialization"?', N'Converting complex data to a transmittable format'),
(6018, 86, N'True/False', N'A `ModelSerializer` is loosely coupled to a Django model.', N'False'),
(6019, 86, N'MCQ', N'What DRF component handles authentication?', N'Authentication classes'),
(6020, 86, N'True/False', N'A `ViewSet` combines logic for a set of related views.', N'True'),
(6021, 86, N'MCQ', N'What HTTP verb is used for creating a new resource?', N'POST'),
(6022, 86, N'True/False', N'A 200 status code means "Created".', N'False'),
(6023, 86, N'MCQ', N'What is "Content Negotiation"?', N'Allowing clients to specify media type'),
(6024, 86, N'True/False', N'TokenAuthentication is a built-in DRF scheme.', N'True'),
(6025, 86, N'MCQ', N'What base class provides full CRUD operations for a model?', N'ModelViewSet'),
(6026, 86, N'True/False', N'REST is a strict protocol.', N'False'),
(6027, 86, N'MCQ', N'What are "Permissions" in DRF used for?', N'Controlling access to views'),
(6028, 86, N'True/False', N'DRF Browsable API is a human-readable interface.', N'True'),
(6029, 86, N'MCQ', N'What HTTP verb is for retrieving data?', N'GET');

--Department: Java, Track: Full Stack Web Development using Python, Course: Database Management with PostgreSQL
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6030, 87, N'MCQ', N'What type of database is PostgreSQL?', N'Object-Relational (ORDBMS)'),
(6031, 87, N'True/False', N'PostgreSQL is a NoSQL database.', N'False'),
(6032, 87, N'MCQ', N'What SQL command retrieves data from a table?', N'SELECT'),
(6033, 87, N'True/False', N'The `WHERE` clause is used to filter rows.', N'True'),
(6034, 87, N'MCQ', N'What SQL command adds a new row to a table?', N'INSERT INTO'),
(6035, 87, N'True/False', N'A `PRIMARY KEY` can contain duplicate values.', N'False'),
(6036, 87, N'MCQ', N'What constraint links two tables together?', N'FOREIGN KEY'),
(6037, 87, N'True/False', N'`pgAdmin` is a command-line interface for PostgreSQL.', N'False'),
(6038, 87, N'MCQ', N'What SQL command modifies existing data in a table?', N'UPDATE'),
(6039, 87, N'True/False', N'An `INNER JOIN` returns rows from both tables.', N'True'),
(6040, 87, N'MCQ', N'What is `psql`?', N'The PostgreSQL interactive terminal'),
(6041, 87, N'True/False', N'`TRUNCATE TABLE` is faster than `DELETE FROM table`.', N'True'),
(6042, 87, N'MCQ', N'What is an "index" used for?', N'To speed up query performance'),
(6043, 87, N'True/False', N'PostgreSQL supports JSON data types.', N'True'),
(6044, 87, N'MCQ', N'What command removes a table from the database?', N'DROP TABLE');

--Department: Java, Track: Full Stack Web Development using Python, Course: Front-End with React.js
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6045, 88, N'MCQ', N'What is React?', N'A JavaScript library for building UIs'),
(6046, 88, N'True/False', N'React uses a "Virtual DOM" for performance.', N'True'),
(6047, 88, N'MCQ', N'What is JSX?', N'A syntax extension for JavaScript'),
(6048, 88, N'True/False', N'You can modify "props" directly in a child component.', N'False'),
(6049, 88, N'MCQ', N'What hook is used to add state to functional components?', N'useState'),
(6050, 88, N'True/False', N'React is a full-fledged, opinionated framework.', N'False'),
(6051, 88, N'MCQ', N'What hook handles side effects like data fetching?', N'useEffect'),
(6052, 88, N'True/False', N'Data in React flows from child to parent (two-way).', N'False'),
(6053, 88, N'MCQ', N'What is `create-react-app`?', N'A tool to set up a new React project'),
(6054, 88, N'True/False', N'A React component must return a single root element.', N'True'),
(6055, 88, N'MCQ', N'What is "state" in React?', N'An object that holds a component''s internal data'),
(6056, 88, N'True/False', N'React Router is included with React by default.', N'False'),
(6057, 88, N'MCQ', N'What library is commonly used for API calls in React?', N'Axios'),
(6058, 88, N'True/False', N'Functional components are preferred over class components.', N'True'),
(6059, 88, N'MCQ', N'What is `npm`?', N'Node Package Manager');

--Department: Java, Track: Full Stack Web Development using Python, Course: Containerization with Docker
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6060, 89, N'MCQ', N'What is Docker?', N'A platform for developing, shipping, and running applications in containers'),
(6061, 89, N'True/False', N'A Docker container includes a full guest OS.', N'False'),
(6062, 89, N'MCQ', N'What is a Docker "image"?', N'A read-only template to create a container'),
(6063, 89, N'True/False', N'A `Dockerfile` is a text file with instructions to build an image.', N'True'),
(6064, 89, N'MCQ', N'What is Docker Hub?', N'A cloud-based registry for Docker images'),
(6065, 89, N'True/False', N'Containers are heavier than Virtual Machines.', N'False'),
(6066, 89, N'MCQ', N'What command is used to build an image from a Dockerfile?', N'docker build'),
(6067, 89, N'True/False', N'Docker "volumes" are used for persistent data.', N'True'),
(6068, 89, N'MCQ', N'What is Docker Compose?', N'A tool for defining and running multi-container applications'),
(6069, 89, N'True/False', N'`docker-compose.yml` is the default file for Docker Compose.', N'True'),
(6070, 89, N'MCQ', N'What command lists all running containers?', N'docker ps'),
(6071, 89, N'True/False', N'The `EXPOSE` instruction in a Dockerfile publishes the port.', N'False'),
(6072, 89, N'MCQ', N'What command runs a container from an image?', N'docker run'),
(6073, 89, N'True/False', N'Containers on the same host share the same kernel.', N'True'),
(6074, 89, N'MCQ', N'What instruction sets the base image?', N'FROM');

--Department: Java, Track: Full Stack Web Development using Python, Course: Testing & Deployment
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6075, 90, N'MCQ', N'What is "Unit Testing"?', N'Testing the smallest testable parts of an application in isolation'),
(6076, 90, N'True/False', N'`pytest` is a popular Python testing framework.', N'True'),
(6077, 90, N'MCQ', N'What is "CI/CD"?', N'Continuous Integration / Continuous Delivery'),
(6078, 89, N'True/False', N'Continuous Integration means merging code frequently.', N'True'),
(6079, 90, N'MCQ', N'What is Heroku?', N'A cloud Platform as a Service (PaaS)'),
(6080, 90, N'True/False', N'You should commit your `SECRET_KEY` to Git.', N'False'),
(6081, 90, N'MCQ', N'What is Gunicorn?', N'A Python WSGI HTTP Server'),
(6082, 90, N'True/False', N'A `Procfile` is used by Heroku to declare commands.', N'True'),
(6083, 90, N'MCQ', N'What are "environment variables"?', N'Variables set outside the application code'),
(6084, 90, N'True/False', N'Integration testing checks how multiple components work together.', N'True'),
(6085, 90, N'MCQ', N'What file lists Python dependencies?', N'requirements.txt'),
(6086, 90, N'True/False', N'E2E testing simulates a real user scenario.', N'True'),
(6087, 90, N'MCQ', N'What is Whitenoise used for?', N'Serving static files'),
(6088, 90, N'True/False', N'Django''s `DEBUG` setting should be `True` in production.', N'False'),
(6089, 90, N'MCQ', N'What Django command collects static files?', N'collectstatic');

--Department: Java, Track: Full Stack Web Development using Python, Course: Python Full Stack Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6090, 91, N'MCQ', N'What is a "full-stack" application?', N'An application with both front-end and back-end components'),
(6091, 91, N'True/False', N'The capstone project integrates skills from all courses.', N'True'),
(6092, 91, N'MCQ', N'What does "CORS" stand for?', N'Cross-Origin Resource Sharing'),
(6093, 91, N'True/False', N'The React app communicates with the Django app via API calls.', N'True'),
(6094, 91, N'MCQ', N'What is JWT used for?', N'Authentication'),
(6095, 91, N'True/False', N'It is good practice to store secrets in a `.env` file.', N'True'),
(6096, 91, N'MCQ', N'What is "version control"?', N'A system for tracking changes to files, like Git'),
(6097, 91, N'True/False', N'A good capstone project should include a `README.md` file.', N'True'),
(6098, 91, N'MCQ', N'What is "authorization"?', N'Determining what a user is allowed to do'),
(6099, 91, N'True/False', N'You should hard-code API URLs in your React app.', N'False'),
(6100, 91, N'MCQ', N'What is the purpose of "data validation"?', N'To ensure data is clean, correct, and useful'),
(6101, 91, N'True/False', N'Deployment is not a required part of a capstone.', N'False'),
(6102, 91, N'MCQ', N'What is the "Repository Pattern"?', N'An abstraction layer for data access'),
(6103, 91, N'True/False', N'The capstone only requires a back-end.', N'False'),
(6104, 91, N'MCQ', N'What is a "production build" of React?', N'An optimized, minified version for deployment');



-- #############################################################################
-- # FILE 2: Question_Choice INSERTS
-- #############################################################################

--Department: Java, Track: Full Stack Web Development using Python, Course: Python & Django Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6000, 6000, N'An interpreted, high-level programming language'), (6001, 6000, N'A compiled, low-level language'), (6002, 6000, N'A database'), (6003, 6000, N'A web server'),
(6004, 6002, N'A high-level Python web framework'), (6005, 6002, N'A database management system'), (6006, 6002, N'A front-end JavaScript library'), (6007, 6002, N'A text editor'),
(6008, 6004, N'A built-in Python module'), (6009, 6004, N'An isolated environment for Python projects'), (6010, 6004, N'A Python data type'), (6011, 6004, N'A machine learning library'),
(6012, 6006, N'func'), (6013, 6006, N'function'), (6014, 6006, N'def'), (6015, 6006, N'lambda'),
(6016, 6008, N'models.py'), (6017, 6008, N'views.py'), (6018, 6008, N'settings.py'), (6019, 6008, N'urls.py'),
(6020, 6010, N'python manage.py startapp'), (6021, 6010, N'python manage.py runserver'), (6022, 6010, N'python manage.py migrate'), (6023, 6010, N'python manage.py shell'),
(6024, 6012, N'Model'), (6025, 6012, N'View'), (6026, 6012, N'Template'), (6027, 6012, N'Controller'),
(6028, 6014, N'models.py'), (6029, 6014, N'views.py'), (6030, 6014, N'admin.py'), (6031, 6014, N'forms.py');

--Department: Java, Track: Full Stack Web Development using Python, Course: Django REST Framework for APIs
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6032, 6015, N'Django REST Framework'), (6033, 6015, N'Django React Framework'), (6034, 6015, N'Django Routing Framework'), (6035, 6015, N'Django Request Framework'),
(6036, 6017, N'Converting complex data to a transmittable format'), (6037, 6017, N'Running database migrations'), (6038, 6017, N'Authenticating users'), (6039, 6017, N'Handling URL routing'),
(6040, 6019, N'Serializers'), (6041, 6019, N'Authentication classes'), (6042, 6019, N'ViewSets'), (6043, 6019, N'Models'),
(6044, 6021, N'GET'), (6045, 6021, N'POST'), (6046, 6021, N'PUT'), (6047, 6021, N'DELETE'),
(6048, 6023, N'Authentication'), (6049, 6023, N'Content Negotiation'), (6050, 6023, N'Serialization'), (6051, 6023, N'Routing'),
(6052, 6025, N'APIView'), (6053, 6025, N'GenericViewSet'), (6054, 6025, N'ModelSerializer'), (6055, 6025, N'ModelViewSet'),
(6056, 6027, N'Controlling access to views'), (6057, 6027, N'Serializing data'), (6058, 6027, N'Routing URLs'), (6059, 6027, N'Parsing requests'),
(6060, 6029, N'GET'), (6061, 6029, N'POST'), (6062, 6029, N'PATCH'), (6063, 6029, N'DELETE');

--Department: Java, Track: Full Stack Web Development using Python, Course: Database Management with PostgreSQL
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6064, 6030, N'Key-Value Store'), (6065, 6030, N'Document Database'), (6066, 6030, N'Object-Relational (ORDBMS)'), (6067, 6030, N'Graph Database'),
(6068, 6032, N'SELECT'), (6069, 6032, N'GET'), (6070, 6032, N'FETCH'), (6071, 6032, N'QUERY'),
(6072, 6034, N'ADD ROW'), (6073, 6034, N'CREATE ROW'), (6074, 6034, N'INSERT INTO'), (6075, 6034, N'NEW ROW'),
(6076, 6036, N'PRIMARY KEY'), (6077, 6036, N'UNIQUE'), (6078, 6036, N'FOREIGN KEY'), (6079, 6036, N'INDEX'),
(6080, 6038, N'MODIFY'), (6081, 6038, N'UPDATE'), (6082, 6038, N'CHANGE'), (6083, 6038, N'SET'),
(6084, 6040, N'A GUI client'), (6085, 6040, N'The PostgreSQL interactive terminal'), (6086, 6040, N'A database driver'), (6087, 6040, N'A config file'),
(6088, 6042, N'To enforce constraints'), (6089, 6042, N'To store data'), (6090, 6042, N'To speed up query performance'), (6091, 6042, N'To delete data'),
(6092, 6044, N'DELETE TABLE'), (6093, 6044, N'REMOVE TABLE'), (6094, 6044, N'DROP TABLE'), (6095, 6044, N'CLEAR TABLE');

--Department: Java, Track: Full Stack Web Development using Python, Course: Front-End with React.js
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6096, 6045, N'A JavaScript library for building UIs'), (6097, 6045, N'A back-end framework'), (6098, 6045, N'A database'), (6099, 6045, N'A programming language'),
(6100, 6047, N'A CSS preprocessor'), (6101, 6047, N'A database query language'), (6102, 6047, N'A syntax extension for JavaScript'), (6103, 6047, N'A state management library'),
(6104, 6049, N'useState'), (6105, 6049, N'useEffect'), (6106, 6049, N'useContext'), (6107, 6049, N'useReducer'),
(6108, 6051, N'useState'), (6109, 6051, N'useEffect'), (6110, 6051, N'useRef'), (6111, 6051, N'useCallback'),
(6112, 6053, N'A tool to set up a new React project'), (6113, 6053, N'A state management library'), (6114, 6053, N'A React component'), (6115, 6053, N'A routing library'),
(6116, 6055, N'An object that holds a component''s internal data'), (6117, 6055, N'Data passed from a parent component'), (6118, 6055, N'A global variable'), (6119, 6055, N'A CSS style'),
(6120, 6057, N'React Router'), (6121, 6057, N'Redux'), (6122, 6057, N'Axios'), (6123, 6057, N'Node.js'),
(6124, 6059, N'Node Package Manager'), (6125, 6059, N'New Project Manager'), (6126, 6059, N'Node Project Module'), (6127, 6059, N'New Package Manager');

--Department: Java, Track: Full Stack Web Development using Python, Course: Containerization with Docker
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6128, 6060, N'A virtual machine manager'), (6129, 6060, N'A platform for developing, shipping, and running applications in containers'), (6130, 6060, N'A code editor'), (6131, 6060, N'A database'),
(6132, 6062, N'A running instance of a container'), (6133, 6062, N'A persistent storage volume'), (6134, 6062, N'A read-only template to create a container'), (6135, 6062, N'A networking rule'),
(6136, 6064, N'A private Git repository'), (6137, 6064, N'A cloud-based registry for Docker images'), (6138, 6064, N'A container monitoring tool'), (6139, 6064, N'A local Docker folder'),
(6140, 6066, N'docker run'), (6141, 6066, N'docker create'), (6142, 6066, N'docker build'), (6143, 6066, N'docker push'),
(6144, 6068, N'A single-container tool'), (6145, 6068, N'A tool for building images'), (6146, 6068, N'A tool for defining and running multi-container applications'), (6147, 6068, N'A container registry'),
(6148, 6070, N'docker images'), (6149, 6070, N'docker ps -a'), (6150, 6070, N'docker list'), (6151, 6070, N'docker ps'),
(6152, 6072, N'docker run'), (6153, 6072, N'docker start'), (6154, 6072, N'docker build'), (6155, 6072, N'docker exec'),
(6156, 6074, N'FROM'), (6157, 6074, N'RUN'), (6158, 6074, N'BASE'), (6159, 6074, N'COPY');

--Department: Java, Track: Full Stack Web Development using Python, Course: Testing & Deployment
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6160, 6075, N'Testing the entire application flow'), (6161, 6075, N'Testing how components interact'), (6162, 6075, N'Testing the smallest testable parts of an application in isolation'), (6163, 6075, N'Testing the UI'),
(6164, 6077, N'Continuous Integration / Continuous Delivery'), (6165, 6077, N'Code Integration / Code Deployment'), (6166, 6077, N'Container Inspection / Container Deployment'), (6167, 6077, N'Code Inspection / Code Delivery'),
(6168, 6079, N'A code editor'), (6169, 6079, N'A database'), (6170, 6079, N'A cloud Platform as a Service (PaaS)'), (6171, 6079, N'A testing library'),
(6172, 6081, N'A database adapter'), (6173, 6081, N'A front-end framework'), (6174, 6081, N'A Python WSGI HTTP Server'), (6175, 6081, N'A testing tool'),
(6176, 6083, N'Variables set inside the application code'), (6177, 6083, N'Variables set outside the application code'), (6178, 6083, N'CSS variables'), (6179, 6083, N'Database columns'),
(6180, 6085, N'requirements.txt'), (6181, 6085, N'package.json'), (6182, 6085, N'Procfile'), (6183, 6085, N'Dockerfile'),
(6184, 6087, N'Serving static files'), (6185, 6087, N'Running tests'), (6186, 6087, N'Managing databases'), (6187, 6087, N'Authenticating users'),
(6188, 6089, N'makemigrations'), (6189, 6089, N'migrate'), (6190, 6089, N'runserver'), (6191, 6089, N'collectstatic');

--Department: Java, Track: Full Stack Web Development using Python, Course: Python Full Stack Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6192, 6090, N'An application with only a front-end'), (6193, 6090, N'An application with only a back-end'), (6194, 6090, N'An application with both front-end and back-end components'), (6195, 6090, N'A desktop application'),
(6196, 6092, N'Cross-Origin Resource Sharing'), (6197, 6092, N'Cross-Origin Request Scripting'), (6198, 6092, N'Code Object Resource Sharing'), (6199, 6092, N'Cross-Object Request Scripting'),
(6200, 6094, N'Database management'), (6201, 6094, N'Styling'), (6202, 6094, N'Authentication'), (6203, 6094, N'Routing'),
(6204, 6096, N'A system for tracking changes to files, like Git'), (6205, 6096, N'A database'), (6206, 6096, N'A deployment platform'), (6207, 6096, N'A testing library'),
(6208, 6098, N'Verifying who a user is'), (6209, 6098, N'Determining what a user is allowed to do'), (6210, 6098, N'Storing user data'), (6211, 6098, N'Styling a user profile'),
(6212, 6100, N'To style data'), (6213, 6100, N'To ensure data is clean, correct, and useful'), (6214, 6100, N'To delete data'), (6215, 6100, N'To fetch data'),
(6216, 6102, N'A design pattern for UI'), (6217, 6102, N'An abstraction layer for data access'), (6218, 6102, N'A deployment strategy'), (6219, 6102, N'A testing method'),
(6220, 6104, N'A version with debug tools'), (6221, 6104, N'The development server'), (6222, 6104, N'An optimized, minified version for deployment'), (6223, 6104, N'A new React project');


-- #############################################################################
-- # Tack 14 Web Development Using CMS Question_Bank INSERTS
-- #############################################################################

--Department: Java, Track: Web Development Using CMS, Course: WordPress Theme & Plugin Dev
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6500, 92, N'MCQ', N'What is a WordPress "theme"?', N'Controls the design and layout of a site'),
(6501, 92, N'True/False', N'A WordPress theme requires at least `index.php` and `style.css`.', N'True'),
(6502, 92, N'MCQ', N'What is a "plugin"?', N'Adds new functionality to a site'),
(6503, 92, N'True/False', N'You must edit core WordPress files to add functionality.', N'False'),
(6504, 92, N'MCQ', N'What is the "WordPress Loop"?', N'The PHP code used to display posts'),
(6505, 92, N'True/False', N'A "child theme" is a theme that inherits functionality from a parent theme.', N'True'),
(6506, 92, N'MCQ', N'What PHP file is the main template file?', N'index.php'),
(6507, 92, N'True/False', N'WordPress "hooks" (actions and filters) are bad practice.', N'False'),
(6508, 92, N'MCQ', N'What is a "shortcode"?', N'A small snippet of code for use in posts/pages'),
(6509, 92, N'True/False', N'Plugins are stored in the `wp-content/themes` directory.', N'False'),
(6510, 92, N'MCQ', N'What function registers a new custom post type?', N'register_post_type()'),
(6511, 92, N'True/False', N'It is safe to edit your parent theme files directly.', N'False'),
(6512, 92, N'MCQ', N'What file is required for a plugin to be recognized?', N'A PHP file with a plugin header comment'),
(6513, 92, N'True/False', N'`functions.php` in a theme acts like a plugin.', N'True'),
(6514, 92, N'MCQ', N'What is a "widget"?', N'A small block that performs a specific function');

--Department: Java, Track: Web Development Using CMS, Course: E-commerce with WooCommerce
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6515, 93, N'MCQ', N'What is WooCommerce?', N'An e-commerce plugin for WordPress'),
(6516, 93, N'True/False', N'WooCommerce is a standalone platform, not a plugin.', N'False'),
(6517, 93, N'MCQ', N'What is a "simple product" in WooCommerce?', N'A physical product with no variations'),
(6518, 93, N'True/False', N'A "variable product" can have options like size or color.', N'True'),
(6519, 93, N'MCQ', N'What is a "payment gateway"?', N'A service that processes credit card payments'),
(6520, 93, N'True/False', N'WooCommerce "shortcodes" can display products on any page.', N'True'),
(6521, 93, N'MCQ', N'What is an "SKU"?', N'Stock Keeping Unit'),
(6522, 93, N'True/False', N'WooCommerce cannot handle digital (downloadable) products.', N'False'),
(6523, 93, N'MCQ', N'What is a "hook" in WooCommerce?', N'A way to add or modify functionality'),
(6524, 93, N'True/False', N'You must override WooCommerce templates in a child theme.', N'True'),
(6525, 93, N'MCQ', N'What is a "shipping zone"?', N'A geographic region for specific shipping methods'),
(6526, 93, N'True/False', N'WooCommerce is built and maintained by Google.', N'False'),
(6527, 93, N'MCQ', N'What is a "coupon" in WooCommerce?', N'A code for discounts'),
(6528, 93, N'True/False', N'You need to be a PHP expert to use WooCommerce.', N'False'),
(6529, 93, N'MCQ', N'What is an "attribute" in WooCommerce?', N'A product characteristic (e.g., color)');

--Department: Java, Track: Web Development Using CMS, Course: PHP for WordPress
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6530, 94, N'MCQ', N'What does PHP stand for?', N'Hypertext Preprocessor'),
(6531, 94, N'True/False', N'PHP code is executed on the client-side (browser).', N'False'),
(6532, 94, N'MCQ', N'How do you start a PHP block?', N'<?php'),
(6533, 94, N'True/False', N'Variables in PHP start with a `$` sign.', N'True'),
(6534, 94, N'MCQ', N'What function prints output in PHP?', N'echo'),
(6535, 94, N'True/False', N'PHP is a case-sensitive language for variable names.', N'True'),
(6536, 94, N'MCQ', N'What is a WordPress "hook"?', N'A way to modify WordPress behavior'),
(6537, 94, N'MCQ', N'What is `add_action()` used for?', N'To attach a function to an action hook'),
(6538, 94, N'True/False', N'A "filter" hook modifies data before it is displayed.', N'True'),
(6539, 94, N'MCQ', N'What is the `$wpdb` global object?', N'The WordPress database access object'),
(6540, 94, N'True/False', N'WordPress uses "The Loop" to display posts.', N'True'),
(6541, 94, N'MCQ', N'What function gets the post title?', N'get_the_title()'),
(6542, 94, N'True/False', N'You should always use `mysql_connect` in WordPress.', N'False'),
(6543, 94, N'MCQ', N'What is an "array" in PHP?', N'A variable that stores multiple values'),
(6544, 94, N'True/False', N'Semicolons (`;`) are optional at the end of PHP statements.', N'False');

--Department: Java, Track: Web Development Using CMS, Course: Headless CMS (Strapi/Contentful)
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6545, 95, N'MCQ', N'What is a "Headless CMS"?', N'A CMS that provides content via an API only'),
(6546, 95, N'True/False', N'A Headless CMS includes a built-in front-end.', N'False'),
(6547, 95, N'MCQ', N'What is the main benefit of a Headless CMS?', N'Omnichannel content delivery'),
(6548, 95, N'True/False', N'Strapi is a self-hosted (open-source) Headless CMS.', N'True'),
(6549, 95, N'MCQ', N'What API format do most Headless CMS use?', N'REST or GraphQL'),
(6550, 95, N'True/False', N'Contentful is a SaaS (cloud-based) Headless CMS.', N'True'),
(6551, 95, N'MCQ', N'What is a "content type" or "model"?', N'The structure/fields for a piece of content'),
(6552, 95, N'True/False', N'A Headless CMS is only for websites.', N'False'),
(6553, 95, N'MCQ', N'What does "API-first" mean?', N'Content is structured to be delivered via API'),
(6554, 95, N'True/False', N'Strapi is built with PHP.', N'False'),
(6555, 95, N'MCQ', N'What is a "decoupled" architecture?', N'Front-end and back-end are separate'),
(6556, 95, N'True/False', N'WordPress can be used as a Headless CMS.', N'True'),
(6557, 95, N'MCQ', N'What is GraphQL?', N'A query language for APIs'),
(6558, 95, N'True/False', N'Headless CMS gives developers more front-end freedom.', N'True'),
(6559, 95, N'MCQ', N'What is a "traditional" CMS?', N'A coupled system with both back-end and front-end');

--Department: Java, Track: Web Development Using CMS, Course: JAMstack with Gatsby/Next.js
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6560, 96, N'MCQ', N'What does JAMstack stand for?', N'JavaScript, APIs, Markup'),
(6561, 96, N'True/False', N'JAMstack sites rely on a traditional web server and database.', N'False'),
(6562, 96, N'MCQ', N'What is a key benefit of JAMstack?', N'Performance and security'),
(6563, 96, N'True/False', N'JAMstack sites are pre-rendered into static files.', N'True'),
(6564, 96, N'MCQ', N'What is Gatsby?', N'A static site generator for React'),
(6565, 96, N'True/False', N'Next.js only supports Static Site Generation (SSG).', N'False'),
(6566, 96, N'MCQ', N'What is Next.js?', N'A React framework for production'),
(6567, 96, N'True/False', N'In JAMstack, dynamic functionality is handled by APIs.', N'True'),
(6568, 96, N'MCQ', N'What does Next.js use for Server-Side Rendering?', N'SSR'),
(6569, 96, N'True/False', N'Gatsby uses GraphQL for data fetching at build time.', N'True'),
(6570, 96, N'MCQ', N'What is a "CDN"?', N'Content Delivery Network'),
(6571, 96, N'True/False', N'JAMstack sites are difficult to scale.', N'False'),
(6572, 96, N'MCQ', N'What is "hydration" in this context?', N'Making a static page interactive with JS'),
(6573, 96, N'True/False', N'Next.js can be used to build full-stack apps.', N'True'),
(6574, 96, N'MCQ', N'What is the "M" in JAMstack?', N'Pre-built Markup');

--Department: Java, Track: Web Development Using CMS, Course: SEO & Performance Optimization
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6575, 97, N'MCQ', N'What does SEO stand for?', N'Search Engine Optimization'),
(6576, 97, N'True/False', N'SEO is about ranking higher in search results.', N'True'),
(6577, 97, N'MCQ', N'What is a "keyword"?', N'A search term a user enters'),
(6578, 97, N'True/False', N'"On-page" SEO refers to building backlinks.', N'False'),
(6579, 97, N'MCQ', N'What is a "backlink"?', N'A link from another website to yours'),
(6580, 97, N'True/False', N'Minifying CSS/JS files improves site speed.', N'True'),
(6581, 97, N'MCQ', N'What is "caching"?', N'Storing copies of files to serve them faster'),
(6582, 97, N'True/False', N'Image compression is bad for performance.', N'False'),
(6583, 97, N'MCQ', N'What is a `meta description`?', N'A summary of a page''s content'),
(6584, 97, N'True/False', N'Google''s "Core Web Vitals" measure site performance.', N'True'),
(6585, 97, N'MCQ', N'What is "lazy loading"?', N'Deferring loading of non-critical assets'),
(6586, 97, N'True/False', N'A CDN (Content Delivery Network) slows down your site.', N'False'),
(6587, 97, N'MCQ', N'What is `alt text` for an image?', N'A description for accessibility and SEO'),
(6588, 97, N'True/False', N'Having a mobile-friendly site is important for SEO.', N'True'),
(6589, 97, N'MCQ', N'What is a `robots.txt` file?', N'Tells search crawlers which pages to avoid');

--Department: Java, Track: Web Development Using CMS, Course: Custom CMS Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES 
(6590, 98, N'MCQ', N'What is the goal of the CMS capstone?', N'To build a complete custom CMS-powered site'),
(6591, 98, N'True/False', N'The capstone must use a Headless CMS.', N'False'),
(6592, 98, N'MCQ', N'What is a "custom post type" in WordPress?', N'A content type you define'),
(6593, 98, N'True/False', N'The capstone must use a JAMstack front-end.', N'False'),
(6594, 98, N'MCQ', N'If using Headless WordPress, what is used to fetch data?', N'WP REST API'),
(6595, 98, N'True/False', N'A good capstone includes user roles and permissions.', N'True'),
(6596, 98, N'MCQ', N'If using JAMstack, where is the site hosted?', N'On a static host/CDN (e.g., Netlify)'),
(6597, 98, N'True/False', N'Performance optimization is not important.', N'False'),
(6598, 98, N'MCQ', N'If using Strapi, what is a "Collection Type"?', N'A custom content model (e.g., "Blog Post")'),
(6599, 98, N'True/False', N'The capstone should be in version control (Git).', N'True'),
(6600, 98, N'MCQ', N'What is a key part of a traditional WordPress capstone?', N'A custom theme'),
(6601, 98, N'True/False', N'A capstone only needs a back-end CMS.', N'False'),
(6602, 98, N'MCQ', N'What is a key part of a Headless CMS capstone?', N'A decoupled front-end (e.g., React)'),
(6603, 98, N'True/False', N'SEO principles should be ignored.', N'False'),
(6604, 98, N'MCQ', N'What does the capstone demonstrate?', N'Integration of all course skills');




-- #############################################################################
-- # FILE 2: Question_Choice INSERTS
-- #############################################################################

--Department: Java, Track: Web Development Using CMS, Course: WordPress Theme & Plugin Dev
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6500, 6500, N'Adds new functionality to a site'), (6501, 6500, N'Controls the design and layout of a site'), (6502, 6500, N'The WordPress core files'), (6503, 6500, N'The WordPress admin panel'),
(6504, 6502, N'The WordPress admin panel'), (6505, 6502, N'A design template'), (6506, 6502, N'Adds new functionality to a site'), (6507, 6502, N'A core WordPress file'),
(6508, 6504, N'A list of all users'), (6509, 6504, N'The PHP code used to display posts'), (6510, 6504, N'The admin login process'), (6511, 6504, N'The plugin installation code'),
(6512, 6506, N'index.php'), (6513, 6506, N'style.css'), (6514, 6506, N'functions.php'), (6515, 6506, N'header.php'),
(6516, 6508, N'A WordPress core function'), (6517, 6508, N'A type of theme'), (6518, 6508, N'A small snippet of code for use in posts/pages'), (6519, 6508, N'A database table'),
(6520, 6510, N'register_post_type()'), (6521, 6510, N'create_post_type()'), (6522, 6510, N'add_new_post()'), (6523, 6510, N'wp_insert_post()'),
(6524, 6512, N'A `readme.txt` file'), (6525, 6512, N'An `index.php` file'), (6526, 6512, N'A PHP file with a plugin header comment'), (6527, 6512, N'A `plugin.js` file'),
(6528, 6514, N'A core WordPress function'), (6529, 6514, N'A small block that performs a specific function'), (6530, 6514, N'A navigation menu'), (6531, 6514, N'A custom post type');

--Department: Java, Track: Web Development Using CMS, Course: E-commerce with WooCommerce
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6532, 6515, N'A WordPress theme'), (6533, 6515, N'A standalone CMS'), (6534, 6515, N'An e-commerce plugin for WordPress'), (6535, 6515, N'A payment gateway'),
(6536, 6517, N'A physical product with no variations'), (6537, 6517, N'A downloadable product'), (6538, 6517, N'A product with options like size/color'), (6539, 6517, N'A subscription product'),
(6540, 6519, N'A shipping company'), (6541, 6519, N'A product category'), (6542, 6519, N'A service that processes credit card payments'), (6543, 6519, N'A shopping cart'),
(6544, 6521, N'Shop Keeper Unit'), (6545, 6521, N'Stock Keeping Unit'), (6546, 6521, N'Sales Keeper Unit'), (6547, 6521, N'Stock Key Utility'),
(6548, 6523, N'A way to add or modify functionality'), (6549, 6523, N'A type of product'), (6550, 6523, N'A shipping method'), (6551, 6523, N'A bug in the code'),
(6552, 6525, N'A type of product'), (6553, 6525, N'A geographic region for specific shipping methods'), (6554, 6525, N'A tax rate'), (6555, 6525, N'A payment gateway area'),
(6556, 6527, N'A product review'), (6557, 6527, N'A shipping class'), (6558, 6527, N'A code for discounts'), (6559, 6527, N'A user role'),
(6560, 6529, N'A product characteristic (e.g., color)'), (6561, 6529, N'A product SKU'), (6562, 6529, N'A product review'), (6563, 6529, N'A product''s weight');

--Department: Java, Track: Web Development Using CMS, Course: PHP for WordPress
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6564, 6530, N'Personal Home Page'), (6565, 6530, N'Python Hypertext Processor'), (6566, 6530, N'Hypertext Preprocessor'), (6567, 6530, N'Preprocessed Hypertext Pages'),
(6568, 6532, N'<script>'), (6569, 6532, N'<?php'), (6570, 6532, N'<%'), (6571, 6532, N'{%'),
(6572, 6534, N'print()'), (6573, 6534, N'console.log()'), (6574, 6534, N'echo'), (6575, 6534, N'display()'),
(6576, 6536, N'A bug in WordPress'), (6577, 6536, N'A WordPress core file'), (6578, 6536, N'A way to modify WordPress behavior'), (6579, 6536, N'A user role'),
(6580, 6537, N'To create a new action'), (6581, 6537, N'To attach a function to an action hook'), (6582, 6537, N'To remove an action'), (6583, 6537, N'To apply a filter'),
(6584, 6539, N'The WordPress admin object'), (6585, 6539, N'The post content object'), (6586, 6539, N'The WordPress database access object'), (6587, 6539, N'The user object'),
(6588, 6541, N'get_the_title()'), (6589, 6541, N'the_title()'), (6590, 6541, N'post_title()'), (6591, 6541, N'wp_title()'),
(6592, 6543, N'A function'), (6593, 6543, N'A class'), (6594, 6543, N'A loop'), (6595, 6543, N'A variable that stores multiple values');

--Department: Java, Track: Web Development Using CMS, Course: Headless CMS (Strapi/Contentful)
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6596, 6545, N'A CMS that provides content via an API only'), (6597, 6545, N'A CMS without an admin panel'), (6598, 6545, N'A CMS for blogs only'), (6599, 6545, N'A CMS built with Node.js'),
(6600, 6547, N'Easier theme installation'), (6601, 6547, N'A built-in front-end'), (6602, 6547, N'Omnichannel content delivery'), (6603, 6547, N'It is always free'),
(6604, 6549, N'HTML'), (6605, 6549, N'REST or GraphQL'), (6606, 6549, N'FTP'), (6607, 6549, N'SQL'),
(6608, 6551, N'The admin user role'), (6609, 6551, N'The front-end design'), (6610, 6551, N'The structure/fields for a piece of content'), (6611, 6551, N'A payment gateway'),
(6612, 6553, N'API is the only product'), (6613, 6553, N'Content is structured to be delivered via API'), (6614, 6553, N'The API is built last'), (6615, 6553, N'The API is optional'),
(6616, 6555, N'Front-end and back-end are separate'), (6617, 6555, N'Front-end and back-end are tightly linked'), (6618, 6555, N'There is no front-end'), (6619, 6555, N'There is no back-end'),
(6620, 6557, N'A query language for APIs'), (6621, 6557, N'A database'), (6622, 6557, N'A Headless CMS'), (6623, 6557, N'A JavaScript framework'),
(6624, 6559, N'A Headless CMS'), (6625, 6559, N'A coupled system with both back-end and front-end'), (6626, 6559, N'A static site generator'), (6627, 6559, N'An API-only service');

--Department: Java, Track: Web Development Using CMS, Course: JAMstack with Gatsby/Next.js
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6628, 6560, N'JavaScript, APIs, Markup'), (6629, 6560, N'Java, APIs, Markup'), (6630, 6560, N'JavaScript, ASP.NET, MySQL'), (6631, 6560, N'Java, APIs, Markdown'),
(6632, 6562, N'Reliance on a database'), (6633, 6562, N'Performance and security'), (6634, 6562, N'Dynamic server-side rendering'), (6635, 6562, N'Easy plugin installation'),
(6636, 6564, N'A React framework for production'), (6637, 6564, N'A static site generator for React'), (6638, 6564, N'A Headless CMS'), (6639, 6564, N'A database'),
(6640, 6566, N'A static site generator for Vue'), (6641, 6566, N'A React framework for production'), (6642, 6566, N'A CSS framework'), (6643, 6566, N'A Headless CMS'),
(6644, 6568, N'SSR'), (6645, 6568, N'SSG'), (6646, 6568, N'CSR'), (6647, 6568, N'ISR'),
(6648, 6570, N'Content Delivery Network'), (6649, 6570, N'Code Delivery Network'), (6650, 6570, N'Content Database Network'), (6651, 6570, N'Complex Delivery Network'),
(6652, 6572, N'Deleting JavaScript'), (6653, 6572, N'Serving static HTML'), (6654, 6572, N'Making a static page interactive with JS'), (6655, 6572, N'Fetching data from an API'),
(6656, 6574, N'MongoDB'), (6657, 6574, N'MySQL'), (6658, 6574, N'Pre-built Markup'), (6659, 6574, N'Markdown');

--Department: Java, Track: Web Development Using CMS, Course: SEO & Performance Optimization
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6660, 6575, N'Site Engine Optimization'), (6661, 6575, N'Search Engine Optimization'), (6662, 6575, N'Site Efficiency Optimization'), (6663, 6575, N'Search Efficiency Optimization'),
(6664, 6577, N'A link to your site'), (6665, 6577, N'An image on your site'), (6666, 6577, N'A search term a user enters'), (6667, 6577, N'A meta description'),
(6668, 6579, N'A link from your site to another'), (6669, 6579, N'An internal link'), (6670, 6579, N'A broken link'), (6671, 6579, N'A link from another website to yours'),
(6672, 6581, N'Storing copies of files to serve them faster'), (6673, 6581, N'Deleting old files'), (6674, 6581, N'Compressing images'), (6675, 6581, N'Writing keywords'),
(6676, 6583, N'The page title'), (6677, 6583, N'A summary of a page''s content'), (6678, 6583, N'A list of keywords'), (6679, 6583, N'The image alt text'),
(6680, 6585, N'Loading all assets immediately'), (6681, 6585, N'Deferring loading of non-critical assets'), (6682, 6585, N'Minifying JavaScript'), (6683, 6585, N'Caching files'),
(6684, 6587, N'The image caption'), (6685, 6587, N'A description for accessibility and SEO'), (6686, 6587, N'The image filename'), (6687, 6587, N'The image title'),
(6688, 6589, N'Tells search crawlers which pages to avoid'), (6689, 6589, N'A map of all pages on your site'), (6690, 6589, N'A file with SEO keywords'), (6691, 6589, N'A performance report');

--Department: Java, Track: Web Development Using CMS, Course: Custom CMS Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES 
(6692, 6590, N'To build a complete custom CMS-powered site'), (6693, 6590, N'To learn basic HTML'), (6694, 6590, N'To write one blog post'), (6695, 6590, N'To install WordPress'),
(6696, 6592, N'A blog post'), (6697, 6592, N'A standard page'), (6698, 6592, N'A content type you define'), (6699, 6592, N'A plugin'),
(6700, 6594, N'WP REST API'), (6701, 6594, N'A custom PHP function'), (6702, 6594, N'By linking databases'), (6703, 6594, N'WP Admin Ajax'),
(6704, 6596, N'On the WordPress server'), (6705, 6596, N'On a shared hosting server'), (6706, 6596, N'On a static host/CDN (e.g., Netlify)'), (6707, 6596, N'On your local machine'),
(6708, 6598, N'A user role'), (6709, 6598, N'A media type'), (6710, 6598, N'A plugin'), (6711, 6598, N'A custom content model (e.g., "Blog Post")'),
(6712, 6600, N'A pre-made theme'), (6713, 6600, N'A custom theme'), (6714, 6600, N'A custom plugin only'), (6715, 6600, N'A React front-end'),
(6716, 6602, N'A custom theme'), (6717, 6602, N'A coupled WordPress site'), (6718, 6602, N'A decoupled front-end (e.g., React)'), (6719, 6602, N'A database diagram'),
(6720, 6604, N'Knowledge of one specific tool'), (6721, 6604, N'Integration of all course skills'), (6722, 6604, N'Ability to write PHP'), (6723, 6604, N'Ability to use React');


--Track 15 Full Stack Web Development using PHP Questions ===========================================================================================================================

-- Department: Java, Track: Full Stack Web Development using PHP, Course: OOP PHP & MySQL
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7000, 99, N'MCQ', N'What does PHP stand for?', N'PHP: Hypertext Preprocessor'), (7001, 99, N'True/False', N'PHP can only be used on Windows servers.', N'False'), (7002, 99, N'MCQ', N'Which keyword is used to create an object in PHP?', N'new'), (7003, 99, N'MCQ', N'How do you start a PHP script?', N'<?php'), (7004, 99, N'True/False', N'A class can inherit from multiple parent classes in PHP.', N'False'), (7005, 99, N'MCQ', N'Which magic constant returns the current class name?', N'__CLASS__'), (7006, 99, N'MCQ', N'What is the term for a class that cannot be instantiated?', N'Abstract'), (7007, 99, N'True/False', N'The `final` keyword prevents a method from being overridden.', N'True'), (7008, 99, N'MCQ', N'Which visibility keyword makes a property accessible only within the class?', N'private'), (7009, 99, N'MCQ', N'What does SQL stand for?', N'Structured Query Language'), (7010, 99, N'True/False', N'A FOREIGN KEY uniquely identifies each record in a table.', N'False'), (7011, 99, N'MCQ', N'Which SQL statement is used to extract data from a database?', N'SELECT'), (7012, 99, N'MCQ', N'Which MySQL function is used to connect to a database?', N'mysqli_connect()'), (7013, 99, N'True/False', N'PDO stands for PHP Data Objects.', N'True'), (7014, 99, N'MCQ', N'Which SQL clause is used to filter records?', N'WHERE');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Laravel Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7015, 100, N'MCQ', N'What is the command-line interface for Laravel?', N'Artisan'), (7016, 100, N'True/False', N'Laravel was created by Taylor Otwell.', N'True'), (7017, 100, N'MCQ', N'Which file is used for defining web routes in Laravel?', N'routes/web.php'), (7018, 100, N'MCQ', N'What is the name of Laravel''s templating engine?', N'Blade'), (7019, 100, N'True/False', N'The `.env` file is typically committed to version control.', N'False'), (7020, 100, N'MCQ', N'Which Artisan command creates a new controller?', N'make:controller'), (7021, 100, N'MCQ', N'What does ORM stand for in the context of Laravel''s Eloquent?', N'Object-Relational Mapping'), (7022, 100, N'True/False', N'Migrations are used to manage the database schema.', N'True'), (7023, 100, N'MCQ', N'How do you get all records from a model named `User`?', N'User::all()'), (7024, 100, N'MCQ', N'What is the purpose of Composer in a Laravel project?', N'Dependency Management'), (7025, 100, N'True/False', N'Middleware can be used to filter HTTP requests.', N'True'), (7026, 100, N'MCQ', N'Which directory contains the Blade view files?', N'resources/views'), (7027, 100, N'MCQ', N'What is the default method for a web route defined with `Route::get()`?', N'GET'), (7028, 100, N'True/False', N'You can create custom Artisan commands.', N'True'), (7029, 100, N'MCQ', N'What component handles request validation in Laravel?', N'Form Requests');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Building APIs with Laravel
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7030, 101, N'MCQ', N'Which file is typically used for API routes?', N'routes/api.php'), (7031, 101, N'True/False', N'API routes in Laravel are stateless by default.', N'True'), (7032, 101, N'MCQ', N'What is a common format for API responses?', N'JSON'), (7033, 101, N'MCQ', N'Which HTTP method is used for creating a new resource?', N'POST'), (7034, 101, N'True/False', N'The `PUT` method is used to partially update a resource.', N'False'), (7035, 101, N'MCQ', N'Which Laravel component is used to transform Eloquent models into JSON?', N'API Resources'), (7036, 101, N'MCQ', N'What is a common status code for a successfully created resource?', N'201 Created'), (7037, 101, N'True/False', N'A `404 Not Found` error means the server is down.', N'False'), (7038, 101, N'MCQ', N'What is the purpose of Laravel Sanctum?', N'API Authentication'), (7039, 101, N'MCQ', N'Which HTTP method is idempotent?', N'GET'), (7040, 101, N'True/False', N'API versioning can be done via URL (e.g., /api/v1/).', N'True'), (7041, 101, N'MCQ', N'What does the `DELETE` HTTP method do?', N'Deletes a resource'), (7042, 101, N'MCQ', N'Which Artisan command creates a new API resource class?', N'make:resource'), (7043, 101, N'True/False', N'API keys should be stored in plain text in the code.', N'False'), (7044, 101, N'MCQ', N'What is rate limiting in the context of APIs?', N'Limiting request frequency');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Front-End with Vue.js
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7045, 102, N'MCQ', N'Who created Vue.js?', N'Evan You'), (7046, 102, N'True/False', N'Vue.js is considered a monolithic framework.', N'False'), (7047, 102, N'MCQ', N'Which directive is used for conditional rendering in Vue?', N'v-if'), (7048, 102, N'MCQ', N'How do you bind an attribute in Vue?', N'v-bind or :'), (7049, 102, N'True/False', N'Vuex is the official state management library for Vue.', N'True'), (7050, 102, N'MCQ', N'What is the file extension for Single File Components in Vue?', N'.vue'), (7051, 102, N'MCQ', N'Which directive is used to render a list of items?', N'v-for'), (7052, 102, N'True/False', N'Props are used to pass data from a child component to a parent.', N'False'), (7053, 102, N'MCQ', N'Which part of a Vue component contains its reactive data?', N'data()'), (7054, 102, N'MCQ', N'How do child components communicate with parent components?', N'Emitting events'), (7055, 102, N'True/False', N'Computed properties are cached based on their reactive dependencies.', N'True'), (7056, 102, N'MCQ', N'What is the function of Vue Router?', N'Client-side routing'), (7057, 102, N'MCQ', N'Which directive listens to DOM events?', N'v-on or @'), (7058, 102, N'True/False', N'The `created` lifecycle hook is called after the component is mounted to the DOM.', N'False'), (7059, 102, N'MCQ', N'What tool is typically used to create a new Vue project?', N'Vue CLI');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Authentication in Laravel
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7060, 103, N'MCQ', N'Which Laravel package provides a complete authentication system?', N'Laravel Breeze/Jetstream'), (7061, 103, N'True/False', N'Passwords should be stored as plain text in the database.', N'False'), (7062, 103, N'MCQ', N'What is the name of the process of verifying a user''s identity?', N'Authentication'), (7063, 103, N'MCQ', N'What process determines if a user can access a resource?', N'Authorization'), (7064, 103, N'True/False', N'Laravel''s default `users` table includes a `password` column.', N'True'), (7065, 103, N'MCQ', N'Which Facade is used to access authentication services?', N'Auth'), (7066, 103, N'MCQ', N'What is a "Guard" in Laravel authentication?', N'Defines how users are authenticated'), (7067, 103, N'True/False', N'Laravel Policies are used to organize authorization logic.', N'True'), (7068, 103, N'MCQ', N'Which middleware is used to protect routes for logged-in users?', N'auth'), (7069, 103, N'MCQ', N'How does Laravel securely store passwords?', N'Hashing'), (7070, 103, N'True/False', N'Socialite is an official Laravel package for OAuth authentication.', N'True'), (7071, 103, N'MCQ', N'What does the `Auth::check()` method do?', N'Checks if a user is authenticated'), (7072, 103, N'MCQ', N'What is the purpose of the "remember me" functionality?', N'Keeps the user logged in'), (7073, 103, N'True/False', N'CSRF protection is enabled by default in Laravel.', N'True'), (7074, 103, N'MCQ', N'Which method logs a user out?', N'Auth::logout()');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Testing & Deployment
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7075, 104, N'MCQ', N'What is the primary testing framework included with Laravel?', N'PHPUnit'), (7076, 104, N'True/False', N'Unit tests are for testing individual components in isolation.', N'True'), (7077, 104, N'MCQ', N'Which type of test simulates user interaction with the application?', N'Feature Test'), (7078, 104, N'MCQ', N'Which file configures the testing environment?', N'phpunit.xml'), (7079, 104, N'True/False', N'You should use your production database for running tests.', N'False'), (7080, 104, N'MCQ', N'What does TDD stand for?', N'Test-Driven Development'), (7081, 104, N'MCQ', N'Which Artisan command runs all tests?', N'test'), (7082, 104, N'True/False', N'CI/CD stands for Continuous Integration & Continuous Delivery.', N'True'), (7083, 104, N'MCQ', N'What is a popular platform for automating deployment pipelines?', N'GitHub Actions'), (7084, 104, N'MCQ', N'Which command prepares a Laravel project for production?', N'config:cache'), (7085, 104, N'True/False', N'`APP_DEBUG` should be set to `true` in production.', N'False'), (7086, 104, N'MCQ', N'What is a common web server used to deploy PHP applications?', N'Nginx'), (7087, 104, N'MCQ', N'What is the purpose of a `.gitignore` file?', N'Specifies untracked files'), (7088, 104, N'True/False', N'Laravel Dusk is used for browser automation testing.', N'True'), (7089, 104, N'MCQ', N'Which PHP process manager is often used in production?', N'PHP-FPM');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: PHP Full Stack Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7090, 105, N'MCQ', N'What is a key aspect of a capstone project?', N'Integrating multiple skills'), (7091, 105, N'True/False', N'A good practice for a large project is to start coding immediately without planning.', N'False'), (7092, 105, N'MCQ', N'What is a `README.md` file typically used for?', N'Project documentation'), (7093, 105, N'MCQ', N'Which version control system is standard for collaborative projects?', N'Git'), (7094, 105, N'True/False', N'It is best practice to store secrets like API keys directly in the code.', N'False'), (7095, 105, N'MCQ', N'What does the "M" in the LAMP stack stand for?', N'MySQL'), (7096, 105, N'MCQ', N'Which of these is a key principle of RESTful API design?', N'Statelessness'), (7097, 105, N'True/False', N'Agile is a project management methodology.', N'True'), (7098, 105, N'MCQ', N'In a full stack project, what is the front-end''s primary role?', N'User Interface and Interaction'), (7099, 105, N'MCQ', N'What is code refactoring?', N'Improving code structure without changing behavior'), (7100, 105, N'True/False', N'A project''s scope should never change once it has been defined.', N'False'), (7101, 105, N'MCQ', N'What is the main goal of user acceptance testing (UAT)?', N'Verify it meets user needs'), (7102, 105, N'MCQ', N'Which HTTP header specifies the content type of the response?', N'Content-Type'), (7103, 105, N'True/False', N'Scalability refers to a system''s ability to handle growing amounts of work.', N'True'), (7104, 105, N'MCQ', N'What is dependency injection?', N'A design pattern to achieve inversion of control');
-----------------------------------------------
-- Department: Java, Track: Full Stack Web Development using PHP, Course: OOP PHP & MySQL
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7000, 7000, N'Personal Home Page'), (7001, 7000, N'PHP: Hypertext Preprocessor'), (7002, 7000, N'Private Home Page'), (7003, 7002, N'object'), (7004, 7002, N'create'), (7005, 7002, N'new'), (7006, 7003, N'<script>'), (7007, 7003, N'<?php'), (7008, 7003, N'<php>'), (7009, 7005, N'__METHOD__'), (7010, 7005, N'__CLASS__'), (7011, 7005, N'self::class'), (7012, 7006, N'Final'), (7013, 7006, N'Static'), (7014, 7006, N'Abstract'), (7015, 7008, N'public'), (7016, 7008, N'protected'), (7017, 7008, N'private'), (7018, 7009, N'Standard Query Language'), (7019, 7009, N'Structured Query Language'), (7020, 7009, N'Simple Query Language'), (7021, 7011, N'GET'), (7022, 7011, N'OPEN'), (7023, 7011, N'SELECT'), (7024, 7012, N'mysql_connect()'), (7025, 7012, N'pdo_connect()'), (7026, 7012, N'mysqli_connect()'), (7027, 7014, N'ORDER BY'), (7028, 7014, N'WHERE'), (7029, 7014, N'GROUP BY');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Laravel Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7030, 7015, N'Composer'), (7031, 7015, N'Artisan'), (7032, 7015, N'Blade'), (7033, 7017, N'app/Http/routes.php'), (7034, 7017, N'routes/web.php'), (7035, 7017, N'config/routes.php'), (7036, 7018, N'Twig'), (7037, 7018, N'Blade'), (7038, 7018, N'Volt'), (7039, 7020, N'make:controller'), (7040, 7020, N'new:controller'), (7041, 7020, N'controller:create'), (7042, 7021, N'Object-Relational Model'), (7043, 7021, N'Object-Resource Mapping'), (7044, 7021, N'Object-Relational Mapping'), (7045, 7023, N'User->all()'), (7046, 7023, N'User::all()'), (7047, 7023, N'User::get()'), (7048, 7024, N'Code Generation'), (7049, 7024, N'Dependency Management'), (7050, 7024, N'Database Migration'), (7051, 7026, N'app/views'), (7052, 7026, N'resources/views'), (7053, 7026, N'views/blade'), (7054, 7027, N'POST'), (7055, 7027, N'ANY'), (7056, 7027, N'GET'), (7057, 7029, N'Eloquent Models'), (7058, 7029, N'Middleware'), (7059, 7029, N'Form Requests');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Building APIs with Laravel
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7060, 7030, N'routes/api.php'), (7061, 7030, N'routes/web.php'), (7062, 7030, N'app/api.php'), (7063, 7032, N'XML'), (7064, 7032, N'HTML'), (7065, 7032, N'JSON'), (7066, 7033, N'GET'), (7067, 7033, N'POST'), (7068, 7033, N'PUT'), (7069, 7035, N'API Resources'), (7070, 7035, N'Blade Templates'), (7071, 7035, N'Controllers'), (7072, 7036, N'200 OK'), (7073, 7036, N'201 Created'), (7074, 7036, N'404 Not Found'), (7075, 7038, N'Database Seeding'), (7076, 7038, N'Template Engine'), (7077, 7038, N'API Authentication'), (7078, 7039, N'POST'), (7079, 7039, N'GET'), (7080, 7039, N'PATCH'), (7081, 7041, N'Updates a resource'), (7082, 7041, N'Deletes a resource'), (7083, 7041, N'Creates a resource'), (7084, 7042, N'make:api'), (7085, 7042, N'make:json'), (7086, 7042, N'make:resource'), (7087, 7044, N'Throttling API usage'), (7088, 7044, N'Limiting request frequency'), (7089, 7044, N'Caching API responses');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Front-End with Vue.js
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7090, 7045, N'Evan You'), (7091, 7045, N'Taylor Otwell'), (7092, 7045, N'Jordan Walke'), (7093, 7047, N'v-for'), (7094, 7047, N'v-if'), (7095, 7047, N'v-show'), (7096, 7048, N'v-on or @'), (7097, 7048, N'v-model'), (7098, 7048, N'v-bind or :'), (7099, 7050, N'.js'), (7100, 7050, N'.vue'), (7101, 7050, N'.jsx'), (7102, 7051, N'v-for'), (7103, 7051, N'v-list'), (7104, 7051, N'v-render'), (7105, 7053, N'methods'), (7106, 7053, N'props'), (7107, 7053, N'data()'), (7108, 7054, N'Using props'), (7109, 7054, N'Emitting events'), (7110, 7054, N'Using Vuex'), (7111, 7056, N'State management'), (7112, 7056, N'Client-side routing'), (7113, 7056, N'Server-side rendering'), (7114, 7057, N'v-on or @'), (7115, 7057, N'v-bind or :'), (7116, 7057, N'v-click'), (7117, 7059, N'NPM'), (7118, 7059, N'Vue CLI'), (7119, 7059, N'Webpack');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Authentication in Laravel
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7120, 7060, N'Laravel Socialite'), (7121, 7060, N'Laravel Passport'), (7122, 7060, N'Laravel Breeze/Jetstream'), (7123, 7062, N'Authorization'), (7124, 7062, N'Authentication'), (7125, 7062, N'Registration'), (7126, 7063, N'Authentication'), (7127, 7063, N'Authorization'), (7128, 7063, N'Encryption'), (7129, 7065, N'User'), (7130, 7065, N'Session'), (7131, 7065, N'Auth'), (7132, 7066, N'A session driver'), (7133, 7066, N'Defines how users are authenticated'), (7134, 7066, N'A type of middleware'), (7135, 7068, N'auth'), (7136, 7068, N'guest'), (7137, 7068, N'verified'), (7138, 7069, N'Encryption'), (7139, 7069, N'Hashing'), (7140, 7069, N'Encoding'), (7141, 7071, N'Returns the current user object'), (7142, 7071, N'Checks if a user is authenticated'), (7143, 7071, N'Logs in a user'), (7144, 7072, N'Stores password in a cookie'), (7145, 7072, N'Keeps the user logged in'), (7146, 7072, N'Remembers user preferences'), (7147, 7074, N'Auth::destroy()'), (7148, 7074, N'Auth::logout()'), (7149, 7074, N'Auth::end()');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: Testing & Deployment
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7150, 7075, N'Pest'), (7151, 7075, N'PHPUnit'), (7152, 7075, N'Codeception'), (7153, 7077, N'Unit Test'), (7154, 7077, N'Integration Test'), (7155, 7077, N'Feature Test'), (7156, 7078, N'composer.json'), (7157, 7078, N'phpunit.xml'), (7158, 7078, N'.env.testing'), (7159, 7080, N'Test-Driven Development'), (7160, 7080, N'Test-Design Driven'), (7161, 7080, N'True-Driven Development'), (7162, 7081, N'run:tests'), (7163, 7081, N'test'), (7164, 7081, N'phpunit'), (7165, 7083, N'Laravel Forge'), (7166, 7083, N'Jenkins'), (7167, 7083, N'GitHub Actions'), (7168, 7084, N'optimize'), (7169, 7084, N'route:cache'), (7170, 7084, N'config:cache'), (7171, 7086, N'Apache'), (7172, 7086, N'Nginx'), (7173, 7086, N'Both are common'), (7174, 7087, N'Specifies untracked files'), (7175, 7087, N'Lists project dependencies'), (7176, 7087, N'Contains environment variables'), (7177, 7089, N'Composer'), (7178, 7089, N'PHP-FPM'), (7179, 7089, N'Nginx');

-- Department: Java, Track: Full Stack Web Development using PHP, Course: PHP Full Stack Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7180, 7090, N'Writing a single function'), (7181, 7090, N'Focusing on one technology'), (7182, 7090, N'Integrating multiple skills'), (7183, 7092, N'Storing passwords'), (7184, 7092, N'Project documentation'), (7185, 7092, N'Running tests'), (7186, 7093, N'SVN'), (7187, 7093, N'Git'), (7188, 7093, N'Mercurial'), (7189, 7095, N'MongoDB'), (7190, 7095, N'MySQL'), (7191, 7095, N'MariaDB'), (7192, 7096, N'Statefulness'), (7193, 7096, N'Statelessness'), (7194, 7096, N'Complex URLs'), (7195, 7098, N'Database management'), (7196, 7098, N'Server-side logic'), (7197, 7098, N'User Interface and Interaction'), (7198, 7099, N'Adding new features'), (7199, 7099, N'Improving code structure without changing behavior'), (7200, 7099, N'Fixing bugs'), (7201, 7101, N'Check code quality'), (7202, 7101, N'Verify it meets user needs'), (7203, 7101, N'Test server performance'), (7204, 7102, N'Accept-Language'), (7205, 7102, N'Content-Type'), (7206, 7102, N'Authorization'), (7207, 7104, N'A way to inject SQL code'), (7208, 7104, N'A data storage pattern'), (7209, 7104, N'A design pattern to achieve inversion of control');


--Track 16 2D Graphics Design Questions ===========================================================================================================
-- Department: Multimedia, Track: 2D Graphics Design, Course: Design, Color Theory & Typography
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7500, 106, N'MCQ', N'What are the three primary colors?', N'Red, Yellow, Blue'), (7501, 106, N'True/False', N'Green is a primary color.', N'False'), (7502, 106, N'MCQ', N'Which principle of design refers to the distribution of visual weight?', N'Balance'), (7503, 106, N'MCQ', N'What is the space around and between the subject(s) of an image called?', N'Negative Space'), (7504, 106, N'True/False', N'Kerning is the adjustment of space between groups of letters.', N'False'), (7505, 106, N'MCQ', N'Colors opposite each other on the color wheel are called?', N'Complementary'), (7506, 106, N'MCQ', N'A font without serifs is called a ________ font.', N'Sans-serif'), (7507, 106, N'True/False', N'The Rule of Thirds is a principle of typography.', N'False'), (7508, 106, N'MCQ', N'What does "Hierarchy" in design refer to?', N'Arranging elements to show importance'), (7509, 106, N'MCQ', N'Which color model is used for digital screens?', N'RGB'), (7510, 106, N'True/False', N'CMYK is used for printing.', N'True'), (7511, 106, N'MCQ', N'What is "Leading" in typography?', N'The space between lines of text'), (7512, 106, N'MCQ', N'The principle of creating a focal point is called?', N'Emphasis'), (7513, 106, N'True/False', N'Analogous colors are next to each other on the color wheel.', N'True'), (7514, 106, N'MCQ', N'What is the repetition of a design element called?', N'Pattern');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Adobe Photoshop
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7515, 107, N'MCQ', N'What type of graphics does Photoshop primarily edit?', N'Raster'), (7516, 107, N'True/False', N'Photoshop files have a .AI extension by default.', N'False'), (7517, 107, N'MCQ', N'Which tool is best for removing a blemish from a photo?', N'Spot Healing Brush'), (7518, 107, N'MCQ', N'What do layers allow you to do in Photoshop?', N'Work on elements non-destructively'), (7519, 107, N'True/False', N'Flattening an image combines all layers into a single layer.', N'True'), (7520, 107, N'MCQ', N'What is the keyboard shortcut to deselect?', N'Ctrl/Cmd + D'), (7521, 107, N'MCQ', N'What does the acronym PSD stand for?', N'Photoshop Document'), (7522, 107, N'True/False', N'Adjustment Layers permanently alter the pixels of a layer.', N'False'), (7523, 107, N'MCQ', N'Which tool makes selections based on color?', N'Magic Wand'), (7524, 107, N'MCQ', N'What is opacity?', N'The level of transparency'), (7525, 107, N'True/False', N'The Clone Stamp tool is used to create text.', N'False'), (7526, 107, N'MCQ', N'What is a "Smart Object"?', N'A layer containing image data from raster or vector images'), (7527, 107, N'MCQ', N'Which color mode is best for web graphics?', N'RGB'), (7528, 107, N'True/False', N'You can apply filters to Smart Objects non-destructively.', N'True'), (7529, 107, N'MCQ', N'What does the Pen Tool create?', N'Paths and vector shapes');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Adobe Illustrator & Vector Art
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7530, 108, N'MCQ', N'What type of graphics does Illustrator create?', N'Vector'), (7531, 108, N'True/False', N'Vector graphics lose quality when scaled up.', N'False'), (7532, 108, N'MCQ', N'What is the default file extension for Illustrator files?', N'.AI'), (7533, 108, N'MCQ', N'What are the points that define a vector path called?', N'Anchor Points'), (7534, 108, N'True/False', N'The Pathfinder panel is used to combine shapes.', N'True'), (7535, 108, N'MCQ', N'Which tool allows you to manipulate anchor points and handles?', N'Direct Selection Tool'), (7536, 108, N'MCQ', N'What is the purpose of the "Create Outlines" command?', N'Convert text to shapes'), (7537, 108, N'True/False', N'Illustrator is the ideal program for editing photographs.', N'False'), (7538, 108, N'MCQ', N'What does "Stroke" refer to in Illustrator?', N'The outline of a shape'), (7539, 108, N'MCQ', N'Which tool is used to create complex shapes by merging and erasing?', N'Shape Builder Tool'), (7540, 108, N'True/False', N'An Artboard in Illustrator is similar to a Page.', N'True'), (7541, 108, N'MCQ', N'What is a Clipping Mask?', N'An object whose shape masks other artwork'), (7542, 108, N'MCQ', N'What does SVG stand for?', N'Scalable Vector Graphics'), (7543, 108, N'True/False', N'You can embed raster images into an Illustrator file.', N'True'), (7544, 108, N'MCQ', N'Which panel allows you to change the color of an object''s fill and stroke?', N'Color Panel');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Logo Design & Branding
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7545, 109, N'MCQ', N'A logo that is purely text-based is called a?', N'Logotype/Wordmark'), (7546, 109, N'True/False', N'A good logo should be complex and detailed.', N'False'), (7547, 109, N'MCQ', N'What is a brand style guide?', N'A rulebook for brand identity application'), (7548, 109, N'MCQ', N'Which file format is best for a master logo file?', N'Vector (AI, EPS, SVG)'), (7549, 109, N'True/False', N'Branding is just about the logo design.', N'False'), (7550, 109, N'MCQ', N'Which type of logo uses the first letter of a business name?', N'Lettermark/Monogram'), (7551, 109, N'MCQ', N'What is the main goal of a logo?', N'Identification'), (7552, 109, N'True/False', N'A logo should work well in a single color.', N'True'), (7553, 109, N'MCQ', N'What does "brand identity" refer to?', N'The visual components of a brand'), (7554, 109, N'MCQ', N'A logo that combines a symbol and a wordmark is called a?', N'Combination Mark'), (7555, 109, N'True/False', N'It is good practice to use trendy fonts for a logo.', N'False'), (7556, 109, N'MCQ', N'What is a mascot logo?', N'A logo involving an illustrated character'), (7557, 109, N'MCQ', N'Why is scalability important for a logo?', N'So it looks good at any size'), (7558, 109, N'True/False', N'The target audience should be considered when designing a logo.', N'True'), (7559, 109, N'MCQ', N'What is an abstract logo mark?', N'A geometric form representing the business');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Layout Design with InDesign
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7560, 110, N'MCQ', N'What is Adobe InDesign primarily used for?', N'Page layout and desktop publishing'), (7561, 110, N'True/False', N'InDesign is a vector illustration software.', N'False'), (7562, 110, N'MCQ', N'What is a "Master Page" in InDesign?', N'A template for consistent page elements'), (7563, 110, N'MCQ', N'What does it mean when text has overflown a text frame?', N'There is more text than can fit'), (7564, 110, N'True/False', N'Images are embedded into InDesign files by default.', N'False'), (7565, 110, N'MCQ', N'What is "facing pages" used for?', N'Creating spreads like in books/magazines'), (7566, 110, N'MCQ', N'The space between columns of text is called the?', N'Gutter'), (7567, 110, N'True/False', N'A bleed is an area outside the page that gets trimmed off.', N'True'), (7568, 110, N'MCQ', N'What panel is used to manage placed images and graphics?', N'Links Panel'), (7569, 110, N'MCQ', N'What is the purpose of "Text Wrap"?', N'To make text flow around an object'), (7570, 110, N'True/False', N'You can create interactive PDFs from InDesign.', N'True'), (7571, 110, N'MCQ', N'What is a Paragraph Style?', N'A collection of formatting attributes'), (7572, 110, N'MCQ', N'What does the "Preflight" feature do?', N'Checks for errors before printing'), (7573, 110, N'True/False', N'The .INDD file extension is for InDesign templates.', N'False'), (7574, 110, N'MCQ', N'What is a grid system used for in layout design?', N'To create structure and alignment');

-- Department: Multimedia, Track: 2D Graphics Design, Course: UI Design Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7575, 111, N'MCQ', N'What does UI stand for?', N'User Interface'), (7576, 111, N'True/False', N'UI design is primarily concerned with how the product feels.', N'False'), (7577, 111, N'MCQ', N'What is a wireframe?', N'A low-fidelity layout sketch'), (7578, 111, N'MCQ', N'What is a common grid size for UI design?', N'8-point grid'), (7579, 111, N'True/False', N'A design system is a collection of reusable components.', N'True'), (7580, 111, N'MCQ', N'Which principle states that users should not have to wonder what to do next?', N'Clarity'), (7581, 111, N'MCQ', N'What is "Affordance" in UI design?', N'A property that indicates how an object can be used'), (7582, 111, N'True/False', N'Contrast is not important for readability in UI design.', N'False'), (7583, 111, N'MCQ', N'A high-fidelity, interactive representation of the final product is a?', N'Prototype'), (7584, 111, N'MCQ', N'What is Fitts''s Law related to in UI design?', N'The time it takes to move to a target area'), (7585, 111, N'True/False', N'Hick''s Law suggests that more choices increase decision time.', N'True'), (7586, 111, N'MCQ', N'What is the primary goal of good UI design?', N'To enable users to achieve goals easily'), (7587, 111, N'MCQ', N'What is a call to action (CTA)?', N'An element designed to prompt an immediate response'), (7588, 111, N'True/False', N'White space in UI design is wasted space.', N'False'), (7589, 111, N'MCQ', N'What is visual hierarchy?', N'The arrangement of elements to guide the user''s eye');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Branding Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (7590, 112, N'MCQ', N'What is the first step in a branding project?', N'Research and Discovery'), (7591, 112, N'True/False', N'A mood board is used to test the final code of a website.', N'False'), (7592, 112, N'MCQ', N'What is a key deliverable of a branding project?', N'Brand Style Guide'), (7593, 112, N'MCQ', N'What is a "touchpoint" in branding?', N'Any interaction a customer has with a brand'), (7594, 112, N'True/False', N'The capstone project should only showcase the final logo.', N'False'), (7595, 112, N'MCQ', N'What is a competitive analysis in branding?', N'Evaluating competitor strategies'), (7596, 112, N'MCQ', N'Why is creating a user persona useful?', N'To understand the target audience'), (7597, 112, N'True/False', N'A brand''s "voice" refers to the music it uses in ads.', N'False'), (7598, 112, N'MCQ', N'What does it mean to create a "scalable" brand identity?', N'It can grow and adapt with the business'), (7599, 112, N'MCQ', N'What is a mockup?', N'A realistic render of a design on a product'), (7600, 112, N'True/False', N'Presenting only one final concept to a client is the best approach.', N'False'), (7601, 112, N'MCQ', N'What is the purpose of showing the design process in a portfolio?', N'To demonstrate problem-solving skills'), (7602, 112, N'MCQ', N'What is brand positioning?', N'How a brand is perceived in relation to competitors'), (7603, 112, N'True/False', N'A capstone project is a good place to experiment with unproven, trendy designs.', N'False'), (7604, 112, N'MCQ', N'What is the final stage of a typical design process?', N'Delivery and Feedback');
---------------------------------------------------------
-- Department: Multimedia, Track: 2D Graphics Design, Course: Design, Color Theory & Typography
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7500, 7500, N'Red, Yellow, Blue'), (7501, 7500, N'Red, Green, Blue'), (7502, 7500, N'Cyan, Magenta, Yellow'), (7503, 7502, N'Contrast'), (7504, 7502, N'Balance'), (7505, 7502, N'Repetition'), (7506, 7503, N'Positive Space'), (7507, 7503, N'White Space'), (7508, 7503, N'Negative Space'), (7509, 7505, N'Analogous'), (7510, 7505, N'Complementary'), (7511, 7505, N'Triadic'), (7512, 7506, N'Serif'), (7513, 7506, N'Script'), (7514, 7506, N'Sans-serif'), (7515, 7508, N'Using the same font size'), (7516, 7508, N'Arranging elements to show importance'), (7517, 7508, N'Making everything symmetrical'), (7518, 7509, N'RGB'), (7519, 7509, N'CMYK'), (7520, 7509, N'HSB'), (7521, 7511, N'The space between letters'), (7522, 7511, N'The space between lines of text'), (7523, 7511, N'The height of a letter'), (7524, 7512, N'Unity'), (7525, 7512, N'Emphasis'), (7526, 7512, N'Rhythm'), (7527, 7514, N'Pattern'), (7528, 7514, N'Contrast'), (7529, 7514, N'Scale');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Adobe Photoshop
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7530, 7515, N'Raster'), (7531, 7515, N'Vector'), (7532, 7515, N'Text'), (7533, 7517, N'Eraser Tool'), (7534, 7517, N'Spot Healing Brush'), (7535, 7517, N'Paint Bucket'), (7536, 7518, N'Change file format'), (7537, 7518, N'Work on elements non-destructively'), (7538, 7518, N'Increase file size'), (7539, 7520, N'Ctrl/Cmd + A'), (7540, 7520, N'Ctrl/Cmd + S'), (7541, 7520, N'Ctrl/Cmd + D'), (7542, 7521, N'Photo Style Document'), (7543, 7521, N'Photoshop Document'), (7544, 7521, N'Photoshop Design'), (7545, 7523, N'Lasso Tool'), (7546, 7523, N'Pen Tool'), (7547, 7523, N'Magic Wand'), (7548, 7524, N'The level of brightness'), (7549, 7524, N'The color intensity'), (7550, 7524, N'The level of transparency'), (7551, 7526, N'A layer containing image data from raster or vector images'), (7552, 7526, N'A layer that cannot be edited'), (7553, 7526, N'A layer for adding text'), (7554, 7527, N'RGB'), (7555, 7527, N'CMYK'), (7556, 7527, N'Grayscale'), (7557, 7529, N'Pixel selections'), (7558, 7529, N'Paths and vector shapes'), (7559, 7529, N'Gradients');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Adobe Illustrator & Vector Art
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7560, 7530, N'Raster'), (7561, 7530, N'Vector'), (7562, 7530, N'Pixel'), (7563, 7532, N'.PSD'), (7564, 7532, N'.AI'), (7565, 7532, N'.INDD'), (7566, 7533, N'Pixels'), (7567, 7533, N'Nodes'), (7568, 7533, N'Anchor Points'), (7569, 7535, N'Selection Tool'), (7570, 7535, N'Direct Selection Tool'), (7571, 7535, N'Pen Tool'), (7572, 7536, N'Convert text to shapes'), (7573, 7536, N'Rasterize text'), (7574, 7536, N'Check spelling'), (7575, 7538, N'The fill color of a shape'), (7576, 7538, N'The outline of a shape'), (7577, 7538, N'The transparency of a shape'), (7578, 7539, N'Pathfinder'), (7579, 7539, N'Shape Builder Tool'), (7580, 7539, N'Blend Tool'), (7581, 7541, N'A filter that hides parts of a layer'), (7582, 7541, N'An object whose shape masks other artwork'), (7583, 7541, N'A layer with a special effect'), (7584, 7542, N'Standard Vector Graphics'), (7585, 7542, N'Scalable Vector Graphics'), (7586, 7542, N'Simple Vector Graphics'), (7587, 7544, N'Swatches Panel'), (7588, 7544, N'Layers Panel'), (7589, 7544, N'Color Panel');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Logo Design & Branding
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7590, 7545, N'Pictorial Mark'), (7591, 7545, N'Logotype/Wordmark'), (7592, 7545, N'Mascot'), (7593, 7547, N'A collection of logo files'), (7594, 7547, N'A rulebook for brand identity application'), (7595, 7547, N'A document of brand history'), (7596, 7548, N'JPEG'), (7597, 7548, N'Vector (AI, EPS, SVG)'), (7598, 7548, N'PNG'), (7599, 7550, N'Abstract Mark'), (7600, 7550, N'Lettermark/Monogram'), (7601, 7550, N'Emblem'), (7602, 7551, N'Decoration'), (7603, 7551, N'Identification'), (7604, 7551, N'Complexity'), (7605, 7553, N'The brand''s financial value'), (7606, 7553, N'The visual components of a brand'), (7607, 7553, N'The brand''s mission statement'), (7608, 7554, N'Combination Mark'), (7609, 7554, N'Abstract Mark'), (7610, 7554, N'Wordmark'), (7611, 7556, N'A logo involving an illustrated character'), (7612, 7556, N'A logo that is an animal silhouette'), (7613, 7556, N'A logo with a hidden meaning'), (7614, 7557, N'So it can be animated'), (7615, 7557, N'So it looks good at any size'), (7616, 7557, N'So it can be printed easily'), (7617, 7559, N'A picture of a real object'), (7618, 7559, N'A geometric form representing the business'), (7619, 7559, N'A character or person');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Layout Design with InDesign
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7620, 7560, N'Photo editing'), (7621, 7560, N'Page layout and desktop publishing'), (7622, 7560, N'3D modeling'), (7623, 7562, N'The first page of a document'), (7624, 7562, N'A template for consistent page elements'), (7625, 7562, N'The page with the highest resolution'), (7626, 7563, N'The text is too large'), (7627, 7563, N'There is more text than can fit'), (7628, 7563, N'The text frame is locked'), (7629, 7565, N'Printing on both sides of a page'), (7630, 7565, N'Creating spreads like in books/magazines'), (7631, 7565, N'Comparing two different pages'), (7632, 7566, N'Margin'), (7633, 7566, N'Bleed'), (7634, 7566, N'Gutter'), (7635, 7568, N'Layers Panel'), (7636, 7568, N'Links Panel'), (7637, 7568, N'Swatches Panel'), (7638, 7569, N'To make text flow around an object'), (7639, 7569, N'To compress text'), (7640, 7569, N'To convert text to outlines'), (7641, 7571, N'A collection of formatting attributes'), (7642, 7571, N'The font family used'), (7643, 7571, N'A style for image frames'), (7644, 7572, N'Packages files for printing'), (7645, 7572, N'Checks for errors before printing'), (7646, 7572, N'Previews the final document'), (7647, 7574, N'To add a background color'), (7648, 7574, N'To create structure and alignment'), (7649, 7574, N'To measure objects');

-- Department: Multimedia, Track: 2D Graphics Design, Course: UI Design Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7650, 7575, N'User Interaction'), (7651, 7575, N'User Interface'), (7652, 7575, N'Usability Initiative'), (7653, 7577, N'A high-fidelity interactive mock-up'), (7654, 7577, N'A low-fidelity layout sketch'), (7655, 7577, N'The final design file'), (7656, 7578, N'5-point grid'), (7657, 7578, N'8-point grid'), (7658, 7578, N'12-point grid'), (7659, 7580, N'Consistency'), (7660, 7580, N'Clarity'), (7661, 7580, N'Familiarity'), (7662, 7581, N'The aesthetic appeal of an object'), (7663, 7581, N'A property that indicates how an object can be used'), (7664, 7581, N'The color palette used'), (7665, 7583, N'Wireframe'), (7666, 7583, N'Mockup'), (7667, 7583, N'Prototype'), (7668, 7584, N'The complexity of a design'), (7669, 7584, N'The time it takes to move to a target area'), (7670, 7584, N'The number of items on a screen'), (7671, 7586, N'To be visually stunning'), (7672, 7586, N'To use the latest trends'), (7673, 7586, N'To enable users to achieve goals easily'), (7674, 7587, N'A navigational menu'), (7675, 7587, N'An element designed to prompt an immediate response'), (7676, 7587, N'A search bar'), (7677, 7589, N'The arrangement of elements to guide the user''s eye'), (7678, 7589, N'A list of all visual elements'), (7679, 7589, N'The grid system used');

-- Department: Multimedia, Track: 2D Graphics Design, Course: Branding Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (7680, 7590, N'Logo design'), (7681, 7590, N'Research and Discovery'), (7682, 7590, N'Client presentation'), (7683, 7592, N'A single logo file'), (7684, 7592, N'Brand Style Guide'), (7685, 7592, N'A list of fonts'), (7686, 7593, N'A brand''s primary color'), (7687, 7593, N'A physical store location'), (7688, 7593, N'Any interaction a customer has with a brand'), (7689, 7595, N'Asking customers what they like'), (7690, 7595, N'Evaluating competitor strategies'), (7691, 7595, N'Copying a competitor''s logo'), (7692, 7596, N'To pick colors for the brand'), (7693, 7596, N'To create a realistic mockup'), (7694, 7596, N'To understand the target audience'), (7695, 7598, N'It uses a simple color palette'), (7696, 7598, N'It is a vector format'), (7697, 7598, N'It can grow and adapt with the business'), (7698, 7599, N'A wireframe'), (7699, 7599, N'A prototype'), (7700, 7599, N'A realistic render of a design on a product'), (7701, 7601, N'To make the portfolio longer'), (7702, 7601, N'To demonstrate problem-solving skills'), (7703, 7601, N'To show what was rejected'), (7704, 7602, N'Where a brand''s headquarters is located'), (7705, 7602, N'How a brand is perceived in relation to competitors'), (7706, 7602, N'A brand''s financial standing'), (7707, 7604, N'Sketching'), (7708, 7604, N'Prototyping'), (7709, 7604, N'Delivery and Feedback');


--Track 17 3D Modeling Questions ==========================================================================================================================

-- Department: Multimedia, Track: 3D Modeling, Course: 3D Modeling with Maya
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8000, 113, N'MCQ', N'What is the main file format for Maya scenes?', N'.mb or .ma'), (8001, 113, N'True/False', N'Maya can only create polygonal models.', N'False'), (8002, 113, N'MCQ', N'What are the three basic manipulation tools in Maya?', N'Move, Rotate, Scale'), (8003, 113, N'MCQ', N'What is a "vertex" in 3D modeling?', N'A single point in 3D space'), (8004, 113, N'True/False', N'The "Extrude" tool pushes or pulls a face along its normal.', N'True'), (8005, 113, N'MCQ', N'Which Maya editor is used for organizing objects in a hierarchy?', N'Outliner'), (8006, 113, N'MCQ', N'A flat surface on a 3D model is called a(n)?', N'Face/Polygon'), (8007, 113, N'True/False', N'NURBS stands for Non-Uniform Rational B-Spline.', N'True'), (8008, 113, N'MCQ', N'What does the "Bevel" tool do?', N'Chamfers edges or corners'), (8009, 113, N'MCQ', N'In which mode can you edit the individual points of a model?', N'Vertex Mode'), (8010, 113, N'True/False', N'A model''s pivot point is where it transforms from.', N'True'), (8011, 113, N'MCQ', N'What is the purpose of the "Freeze Transformations" command?', N'Resets transform values to zero without moving the object'), (8012, 113, N'True/False', N'You cannot combine two separate polygon meshes in Maya.', N'False'), (8013, 113, N'MCQ', N'What is a "shelf" in the Maya UI?', N'A customizable collection of tools and commands'), (8014, 113, N'True/False', N'The Hypershade is used for creating and editing materials.', N'True');

-- Department: Multimedia, Track: 3D Modeling, Course: Character & Hard Surface Modeling
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8015, 114, N'MCQ', N'What is "topology" in 3D modeling?', N'The flow of polygons on a model''s surface'), (8016, 114, N'True/False', N'Good topology is not important for animation.', N'False'), (8017, 114, N'MCQ', N'A polygon with more than four sides is called an?', N'N-gon'), (8018, 114, N'MCQ', N'What is the main characteristic of hard surface modeling?', N'Modeling man-made, non-organic objects'), (8019, 114, N'True/False', N'Edge loops are crucial for creating clean deformations in characters.', N'True'), (8020, 114, N'MCQ', N'What technique involves creating a high-poly model and then a low-poly version?', N'Retopology'), (8021, 114, N'MCQ', N'Which type of polygon is most desirable for clean modeling?', N'Quad (4-sided)'), (8022, 114, N'True/False', N'Hard surface models should never have beveled edges.', N'False'), (8023, 114, N'MCQ', N'What is box modeling?', N'Starting from a primitive shape like a cube'), (8024, 114, N'MCQ', N'The "Symmetry" function is useful for modeling what kind of objects?', N'Bilaterally symmetrical objects'), (8025, 114, N'True/False', N'A character''s T-pose is the standard pose for modeling.', N'True'), (8026, 114, N'MCQ', N'What are "support edges" used for in subdivision modeling?', N'To hold the shape and create sharper edges'), (8027, 114, N'True/False', N'It is a good practice to model a character with as few polygons as possible.', N'False'), (8028, 114, N'MCQ', N'What is a "pole" in topology?', N'A vertex with more or less than 4 edges connected'), (8029, 114, N'True/False', N'Boolean operations are always the cleanest way to combine meshes.', N'False');

-- Department: Multimedia, Track: 3D Modeling, Course: UV Unwrapping & Texturing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8030, 115, N'MCQ', N'What is UV unwrapping?', N'Flattening a 3D mesh into 2D space'), (8031, 115, N'True/False', N'UV coordinates are 3D coordinates.', N'False'), (8032, 115, N'MCQ', N'What is a "texel"?', N'A pixel on a texture map'), (8033, 115, N'MCQ', N'Why is consistent texel density important?', N'Ensures even texture detail across the model'), (8034, 115, N'True/False', N'Overlapping UVs are generally a good practice.', N'False'), (8035, 115, N'MCQ', N'What is a "seam" in UV mapping?', N'A place where the 3D mesh is split for flattening'), (8036, 115, N'MCQ', N'What does a "checker map" help to identify?', N'Stretching and distortion in UVs'), (8037, 115, N'True/False', N'A Normal Map is used to fake high-poly detail on a low-poly model.', N'True'), (8038, 115, N'MCQ', N'What does a specular map control?', N'The shininess of a surface'), (8039, 115, N'MCQ', N'What is Ambient Occlusion (AO)?', N'A map that fakes soft shadows in crevices'), (8040, 115, N'True/False', N'PBR stands for Physically Based Rendering.', N'True'), (8041, 115, N'MCQ', N'Which map defines the base color of a material?', N'Albedo/Diffuse Map'), (8042, 115, N'True/False', N'Procedural textures are generated by mathematical algorithms.', N'True'), (8043, 115, N'MCQ', N'What does a metallic map define?', N'Which parts of a material are metallic'), (8044, 115, N'True/False', N'All textures need to be square and power-of-two resolution (e.g., 1024x1024).', N'False');

-- Department: Multimedia, Track: 3D Modeling, Course: 3D Sculpting with ZBrush
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8045, 116, N'MCQ', N'What is ZBrush primarily used for?', N'High-detail digital sculpting'), (8046, 116, N'True/False', N'ZBrush uses standard polygons for its models.', N'False'), (8047, 116, N'MCQ', N'What is the proprietary technology ZBrush uses instead of polygons?', N'Pixols'), (8048, 116, N'MCQ', N'What is a "SubTool" in ZBrush?', N'A separate object within a single ZBrush tool/file'), (8049, 116, N'True/False', N'DynaMesh is used for creating a low-resolution base mesh.', N'False'), (8050, 116, N'MCQ', N'What is the purpose of subdivision levels?', N'To work between low and high resolutions non-destructively'), (8051, 116, N'MCQ', N'Which feature allows you to quickly create a new, even topology for sculpting?', N'DynaMesh'), (8052, 116, N'True/False', N'Masking in ZBrush protects areas from being sculpted.', N'True'), (8053, 116, N'MCQ', N'What is "Polypaint"?', N'Painting color directly onto a model''s vertices'), (8054, 116, N'MCQ', N'What are ZSpheres used for?', N'Creating a base mesh armature quickly'), (8055, 116, N'True/False', N'The "Move" brush is used to add clay to a model.', N'False'), (8056, 116, N'MCQ', N'What does ZRemesher do?', N'Automatically creates new, clean topology'), (8057, 116, N'True/False', N'Alpha maps can be used to create detailed surface textures.', N'True'), (8058, 116, N'MCQ', N'What is the "Transpose" tool used for?', N'Posing and transforming models'), (8059, 116, N'True/False', N'You must UV unwrap a model before you can Polypaint it.', N'False');

-- Department: Multimedia, Track: 3D Modeling, Course: Lighting & Rendering
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8060, 117, N'MCQ', N'What is the process of generating a 2D image from a 3D scene called?', N'Rendering'), (8061, 117, N'True/False', N'A Key Light is typically the brightest light in a scene.', N'True'), (8062, 117, N'MCQ', N'What type of lighting setup uses a Key, Fill, and Back light?', N'Three-Point Lighting'), (8063, 117, N'MCQ', N'What is the purpose of a Fill Light?', N'To soften shadows created by the Key Light'), (8064, 117, N'True/False', N'Global Illumination simulates how light bounces off surfaces.', N'True'), (8065, 117, N'MCQ', N'What does an HDRI map provide for a scene?', N'Image-based lighting and reflections'), (8066, 117, N'MCQ', N'What is "noise" or "grain" in a render?', N'Visual artifacts from insufficient sampling'), (8067, 117, N'True/False', N'A rendering engine is software that generates the final image.', N'True'), (8068, 117, N'MCQ', N'Which light type emits light in all directions from a single point?', N'Point Light'), (8069, 117, N'MCQ', N'What is Subsurface Scattering (SSS) used to simulate?', N'Light passing through translucent objects'), (8070, 117, N'True/False', N'Arnold is a popular rendering engine integrated with Maya.', N'True'), (8071, 117, N'MCQ', N'What are "Render Passes" or "AOVs"?', N'Separate rendered images of scene elements (e.g., color, shadows)'), (8072, 117, N'True/False', N'Lowering the render samples will decrease render time and increase quality.', N'False'), (8073, 117, N'MCQ', N'What is the function of a Back Light or Rim Light?', N'Separates the subject from the background'), (8074, 117, N'True/False', N'Ray Tracing is a technique that traces the path of light rays.', N'True');

-- Department: Multimedia, Track: 3D Modeling, Course: 3D for Games & Optimization
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8075, 118, N'MCQ', N'What is a "poly count"?', N'The number of polygons in a model'), (8076, 118, N'True/False', N'Higher poly counts always result in better game performance.', N'False'), (8077, 118, N'MCQ', N'What is the process of creating simplified models for distant objects called?', N'Level of Detail (LOD)'), (8078, 118, N'MCQ', N'What is "baking" in the context of game assets?', N'Transferring details from a high-poly to a low-poly model'), (8079, 118, N'True/False', N'A game-ready model typically has millions of polygons.', N'False'), (8080, 118, N'MCQ', N'Which map is crucial for faking high-poly detail on a low-poly game asset?', N'Normal Map'), (8081, 118, N'MCQ', N'What is a "texture atlas"?', N'A single texture image containing multiple smaller textures'), (8082, 118, N'True/False', N'Using a texture atlas helps reduce draw calls and improve performance.', N'True'), (8083, 118, N'MCQ', N'What is the role of a "collider" or collision mesh?', N'Defines the physical boundaries of an object for physics'), (8084, 118, N'MCQ', N'Which file format is commonly used to export models to game engines like Unity or Unreal?', N'.FBX'), (8085, 118, N'True/False', N'N-gons are perfectly acceptable for game engine models.', N'False'), (8086, 118, N'MCQ', N'What does "mipmapping" do?', N'Creates pre-scaled, lower-resolution versions of a texture'), (8087, 118, N'True/False', N'Real-time rendering means the images are generated instantaneously.', N'True'), (8088, 118, N'MCQ', N'What is the process of removing unseen polygons called?', N'Culling'), (8089, 118, N'True/False', N'A game model''s topology does not need to be clean.', N'False');

-- Department: Multimedia, Track: 3D Modeling, Course: 3D Scene Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8090, 119, N'MCQ', N'What is the first step in creating a 3D scene?', N'Planning and reference gathering'), (8091, 119, N'True/False', N'A blockout or blocking pass involves creating final, detailed models.', N'False'), (8092, 119, N'MCQ', N'What is the purpose of a blockout?', N'To establish composition and scale'), (8093, 119, N'MCQ', N'Which principle of composition helps to guide the viewer''s eye?', N'Leading Lines'), (8094, 119, N'True/False', N'A good scene tells a story.', N'True'), (8095, 119, N'MCQ', N'What is "set dressing"?', N'Adding small props and details to a scene'), (8096, 119, N'MCQ', N'Why is asset reuse important in large scenes?', N'Saves time and improves performance'), (8097, 119, N'True/False', N'The focal point is the least important part of a scene.', N'False'), (8098, 119, N'MCQ', N'What is "atmospheric perspective"?', N'Objects in the distance appear less clear and saturated'), (8099, 119, N'MCQ', N'What does post-processing refer to?', N'Editing the rendered image to enhance it'), (8100, 119, N'True/False', N'A capstone project should demonstrate a single 3D skill.', N'False'), (8101, 119, N'MCQ', N'What is a "turntable" render?', N'An animation showing the model rotating 360 degrees'), (8102, 119, N'True/False', N'Lighting plays a key role in setting the mood of a scene.', N'True'), (8103, 119, N'MCQ', N'Which of these is NOT a core part of the 3D pipeline?', N'Video Editing'), (8104, 119, N'True/False', N'Gathering feedback is an important part of the creative process.', N'True');
-----------------------------------------------------------------
-- Department: Multimedia, Track: 3D Modeling, Course: 3D Modeling with Maya
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8000, 8000, N'.psd'), (8001, 8000, N'.mb or .ma'), (8002, 8000, N'.obj'), (8003, 8002, N'Draw, Paint, Sculpt'), (8004, 8002, N'Move, Rotate, Scale'), (8005, 8002, N'Pan, Zoom, Orbit'), (8006, 8003, N'An edge'), (8007, 8003, N'A face'), (8008, 8003, N'A single point in 3D space'), (8009, 8005, N'Hypershade'), (8010, 8005, N'Outliner'), (8011, 8005, N'Attribute Editor'), (8012, 8006, N'Vertex'), (8013, 8006, N'Edge'), (8014, 8006, N'Face/Polygon'), (8015, 8008, N'Combines multiple objects'), (8016, 8008, N'Smooths the entire model'), (8017, 8008, N'Chamfers edges or corners'), (8018, 8009, N'Object Mode'), (8019, 8009, N'Vertex Mode'), (8020, 8009, N'Face Mode'), (8021, 8011, N'Moves the object to the world origin'), (8022, 8011, N'Resets transform values to zero without moving the object'), (8023, 8011, N'Deletes the object''s history'), (8024, 8013, N'A modeling tool'), (8025, 8013, N'A rendering window'), (8026, 8013, N'A customizable collection of tools and commands');

-- Department: Multimedia, Track: 3D Modeling, Course: Character & Hard Surface Modeling
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8027, 8015, N'The material of a model'), (8028, 8015, N'The flow of polygons on a model''s surface'), (8029, 8015, N'The number of vertices'), (8030, 8017, N'A triangle'), (8031, 8017, N'A quad'), (8032, 8017, N'An N-gon'), (8033, 8018, N'Modeling characters and animals'), (8034, 8018, N'Modeling man-made, non-organic objects'), (8035, 8018, N'Sculpting with high detail'), (8036, 8020, N'UV Unwrapping'), (8037, 8020, N'Texturing'), (8038, 8020, N'Retopology'), (8039, 8021, N'Triangle (3-sided)'), (8040, 8021, N'Quad (4-sided)'), (8041, 8021, N'N-gon (>4 sides)'), (8042, 8023, N'Starting from a curve or spline'), (8043, 8023, N'Starting from a primitive shape like a cube'), (8044, 8023, N'Sculpting from a sphere'), (8045, 8024, N'Organic objects'), (8046, 8024, N'Asymmetrical objects'), (8047, 8024, N'Bilaterally symmetrical objects'), (8048, 8026, N'To add color to the model'), (8049, 8026, N'To hold the shape and create sharper edges'), (8050, 8026, N'To make the model easier to animate'), (8051, 8028, N'An edge with 3 connected faces'), (8052, 8028, N'A vertex with more or less than 4 edges connected'), (8053, 8028, N'A face with 5 vertices');

-- Department: Multimedia, Track: 3D Modeling, Course: UV Unwrapping & Texturing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8054, 8030, N'Flattening a 3D mesh into 2D space'), (8055, 8030, N'Wrapping a texture around a model'), (8056, 8030, N'Creating a 3D texture'), (8057, 8032, N'A 3D pixel'), (8058, 8032, N'A pixel on a texture map'), (8059, 8032, N'A UV coordinate'), (8060, 8033, N'Makes rendering faster'), (8061, 8033, N'Ensures even texture detail across the model'), (8062, 8033, N'Reduces file size'), (8063, 8035, N'A weld in the UV editor'), (8064, 8035, N'A place where the 3D mesh is split for flattening'), (8065, 8035, N'A fold in the UV island'), (8066, 8036, N'Model errors'), (8067, 8036, N'Texture resolution'), (8068, 8036, N'Stretching and distortion in UVs'), (8069, 8038, N'The color of a surface'), (8070, 8038, N'The shininess of a surface'), (8071, 8038, N'The transparency of a surface'), (8072, 8039, N'A map that fakes soft shadows in crevices'), (8073, 8039, N'A map that adds bright highlights'), (8074, 8039, N'A map that defines color'), (8075, 8041, N'Normal Map'), (8076, 8041, N'Albedo/Diffuse Map'), (8077, 8041, N'Roughness Map'), (8078, 8043, N'How rough a surface is'), (8079, 8043, N'Which parts of a material are metallic'), (8080, 8043, N'How much light the material emits');

-- Department: Multimedia, Track: 3D Modeling, Course: 3D Sculpting with ZBrush
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8081, 8045, N'Video editing'), (8082, 8045, N'Low-poly modeling'), (8083, 8045, N'High-detail digital sculpting'), (8084, 8047, N'Voxels'), (8085, 8047, N'Pixols'), (8086, 8047, N'Metaballs'), (8087, 8048, N'A sculpting brush'), (8088, 8048, N'A separate object within a single ZBrush tool/file'), (8089, 8048, N'A layer for painting'), (8090, 8050, N'To permanently increase model resolution'), (8091, 8050, N'To work between low and high resolutions non-destructively'), (8092, 8050, N'To store different material properties'), (8093, 8051, N'ZRemesher'), (8094, 8051, N'DynaMesh'), (8095, 8051, N'Subdivision'), (8096, 8053, N'A special type of material'), (8097, 8053, N'Painting color directly onto a model''s vertices'), (8098, 8053, N'Creating UV maps'), (8099, 8054, N'Posing a finished model'), (8100, 8054, N'Creating a base mesh armature quickly'), (8101, 8054, N'Adding fine details'), (8102, 8056, N'Adds subdivision levels'), (8103, 8056, N'Automatically creates new, clean topology'), (8104, 8056, N'Paints the model'), (8105, 8058, N'Sculpting fine details'), (8106, 8058, N'Posing and transforming models'), (8107, 8058, N'Creating UVs');

-- Department: Multimedia, Track: 3D Modeling, Course: Lighting & Rendering
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8108, 8060, N'Modeling'), (8109, 8060, N'Texturing'), (8110, 8060, N'Rendering'), (8111, 8062, N'Three-Point Lighting'), (8112, 8062, N'Ambient Lighting'), (8113, 8062, N'Image-Based Lighting'), (8114, 8063, N'To create harsh shadows'), (8115, 8063, N'To separate the subject from the background'), (8116, 8063, N'To soften shadows created by the Key Light'), (8117, 8065, N'High-resolution textures'), (8118, 8065, N'Image-based lighting and reflections'), (8119, 8065, N'A 3D background model'), (8120, 8066, N'Realistic film effects'), (8121, 8066, N'Visual artifacts from insufficient sampling'), (8122, 8066, N'A type of material'), (8123, 8068, N'Directional Light'), (8124, 8068, N'Spot Light'), (8125, 8068, N'Point Light'), (8126, 8069, N'Hard surfaces like metal'), (8127, 8069, N'Light passing through translucent objects'), (8128, 8069, N'Reflective surfaces'), (8129, 8071, N'Different camera angles'), (8130, 8071, N'Separate rendered images of scene elements (e.g., color, shadows)'), (8131, 8071, N'Different lighting setups'), (8132, 8073, N'To illuminate the whole scene evenly'), (8133, 8073, N'Separates the subject from the background'), (8134, 8073, N'To act as the main light source');

-- Department: Multimedia, Track: 3D Modeling, Course: 3D for Games & Optimization
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8135, 8075, N'The number of textures'), (8136, 8075, N'The number of polygons in a model'), (8137, 8075, N'The file size of the model'), (8138, 8077, N'Retopology'), (8139, 8077, N'Level of Detail (LOD)'), (8140, 8077, N'Texture Atlasing'), (8141, 8078, N'Rendering a final image'), (8142, 8078, N'Transferring details from a high-poly to a low-poly model'), (8143, 8078, N'Combining multiple textures'), (8144, 8080, N'Specular Map'), (8145, 8080, N'Normal Map'), (8146, 8080, N'Ambient Occlusion Map'), (8147, 8081, N'A 3D map of textures'), (8148, 8081, N'A library of materials'), (8149, 8081, N'A single texture image containing multiple smaller textures'), (8150, 8083, N'A mesh used for rendering'), (8151, 8083, N'Defines the physical boundaries of an object for physics'), (8152, 8083, N'A simplified mesh for distant viewing'), (8153, 8084, N'.MA'), (8154, 8084, N'.ZTL'), (8155, 8084, N'.FBX'), (8156, 8086, N'Compresses texture file sizes'), (8157, 8086, N'Creates pre-scaled, lower-resolution versions of a texture'), (8158, 8086, N'Combines textures into an atlas'), (8159, 8088, N'Culling'), (8160, 8088, N'Baking'), (8161, 8088, N'Instancing');

-- Department: Multimedia, Track: 3D Modeling, Course: 3D Scene Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8162, 8090, N'Detailed modeling'), (8163, 8090, N'Planning and reference gathering'), (8164, 8090, N'Texturing'), (8165, 8092, N'To create the final lighting'), (8166, 8092, N'To establish composition and scale'), (8167, 8092, N'To apply materials'), (8168, 8093, N'The Rule of Thirds'), (8169, 8093, N'Leading Lines'), (8170, 8093, N'Golden Ratio'), (8171, 8095, N'Lighting the scene'), (8172, 8095, N'Adding small props and details to a scene'), (8173, 8095, N'Creating the main character'), (8174, 8096, N'Saves time and improves performance'), (8175, 8096, N'Increases visual quality'), (8176, 8096, N'It is not important'), (8177, 8098, N'Objects in the distance appear sharper'), (8178, 8098, N'Objects in the distance appear less clear and saturated'), (8179, 8098, N'Objects in the distance are larger'), (8180, 8099, N'The initial modeling phase'), (8181, 8099, N'Editing the rendered image to enhance it'), (8182, 8099, N'The process of UV unwrapping'), (8183, 8101, N'A render from the top-down view'), (8184, 8101, N'An animation showing the model rotating 360 degrees'), (8185, 8101, N'A still render of the scene'), (8186, 8103, N'Modeling'), (8187, 8103, N'Video Editing'), (8188, 8103, N'Rendering');


--Track 18 Motion Graphics Questions ===============================================================================================

-- Department: Multimedia, Track: Motion Graphics, Course: Animation Principles
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8500, 120, N'MCQ', N'Which principle creates the illusion of weight and volume?', N'Squash and Stretch'), (8501, 120, N'True/False', N'Straight ahead action is always better than pose to pose.', N'False'), (8502, 120, N'MCQ', N'What is "Anticipation" in animation?', N'Preparing the audience for an action'), (8503, 120, N'MCQ', N'Which principle involves making objects follow a curved path?', N'Arcs'), (8504, 120, N'True/False', N'Staging means presenting an idea so it is completely clear.', N'True'), (8505, 120, N'MCQ', N'What is "Follow Through and Overlapping Action"?', N'When parts of a body continue moving after the body has stopped'), (8506, 120, N'MCQ', N'Easing in and out of an action is called what?', N'Slow In and Slow Out'), (8507, 120, N'True/False', N'Secondary action is an action that distracts from the main action.', N'False'), (8508, 120, N'MCQ', N'The principle of "Timing" refers to what?', N'The number of frames for an action'), (8509, 120, N'MCQ', N'What is "Exaggeration" used for?', N'To increase the appeal and impact of an action'), (8510, 120, N'True/False', N'Solid drawing refers to making sure characters look flat.', N'False'), (8511, 120, N'MCQ', N'The "Appeal" principle means what?', N'The character is pleasing to look at'), (8512, 120, N'True/False', N'The 12 principles of animation were developed by Disney animators.', N'True'), (8513, 120, N'MCQ', N'Which principle helps to define the mood and intention of a character?', N'Appeal'), (8514, 120, N'True/False', N'An object moving faster should have more frames.', N'False');

-- Department: Multimedia, Track: Motion Graphics, Course: Adobe After Effects Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8515, 121, N'MCQ', N'What is the main purpose of After Effects?', N'Motion graphics and visual effects'), (8516, 121, N'True/False', N'After Effects is primarily a video editing software like Premiere Pro.', N'False'), (8517, 121, N'MCQ', N'What is a "Composition" in After Effects?', N'The container and timeline for layers'), (8518, 121, N'MCQ', N'What does a keyframe do?', N'Marks a point in time where a property''s value is set'), (8519, 121, N'True/False', N'Layers at the top of the timeline appear in front of layers below them.', N'True'), (8520, 121, N'MCQ', N'What is the keyboard shortcut to reveal a layer''s position property?', N'P'), (8521, 121, N'MCQ', N'A "Pre-comp" is used to do what?', N'Group layers together into a nested composition'), (8522, 121, N'True/False', N'Masks are used to permanently delete parts of a layer.', N'False'), (8523, 121, N'MCQ', N'What does the "Puppet Pin" tool allow you to do?', N'Deform and animate a layer'), (8524, 121, N'MCQ', N'What is the Graph Editor used for?', N'Fine-tuning the speed and value of an animation'), (8525, 121, N'True/False', N'RAM Preview is used for viewing your animation in real-time.', N'True'), (8526, 121, N'MCQ', N'Which effect is used to remove a solid color background (like a green screen)?', N'Keylight'), (8527, 121, N'True/False', N'Shape Layers are raster-based and will pixelate when scaled up.', N'False'), (8528, 121, N'MCQ', N'What is the function of an "Adjustment Layer"?', N'To apply effects to all layers beneath it'), (8529, 121, N'True/False', N'The Render Queue is where you export your final video.', N'True');

-- Department: Multimedia, Track: Motion Graphics, Course: Keyframe & Typography Animation
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8530, 122, N'MCQ', N'What is "interpolation" between keyframes?', N'How After Effects calculates the frames in-between keyframes'), (8531, 122, N'True/False', N'Linear interpolation creates a constant rate of change.', N'True'), (8532, 122, N'MCQ', N'What is the purpose of "Easy Ease"?', N'To create smooth, natural-looking motion'), (8533, 122, N'MCQ', N'What do the handles on a keyframe in the Graph Editor control?', N'The influence of the keyframe on the motion curve'), (8534, 122, N'True/False', N'A Hold keyframe makes a layer instantly jump to the next value.', N'True'), (8535, 122, N'MCQ', N'What is a text "Animator" in After Effects?', N'A property that animates characters, words, or lines individually'), (8536, 122, N'MCQ', N'What is "Kerning" in typography?', N'The spacing between two specific characters'), (8537, 122, N'True/False', N'You cannot animate individual letters of a text layer.', N'False'), (8538, 122, N'MCQ', N'Which text animation property would you use to make letters fade in one by one?', N'Opacity Animator with a Range Selector'), (8539, 122, N'MCQ', N'What is a "Kinetic Typography"?', N'An animation technique that uses moving text'), (8540, 122, N'True/False', N'The Graph Editor can only edit spatial properties like Position.', N'False'), (8541, 122, N'MCQ', N'What is the purpose of parenting a layer?', N'To make a child layer follow the transformations of a parent layer'), (8542, 122, N'True/False', N'A Null Object is a visible layer used as a background.', N'False'), (8543, 122, N'MCQ', N'How can you sync animation to audio in After Effects?', N'Convert audio to keyframes'), (8544, 122, N'True/False', N'A serif font is generally considered more modern and clean than a sans-serif font.', N'False');

-- Department: Multimedia, Track: Motion Graphics, Course: Visual Effects & Compositing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8545, 123, N'MCQ', N'What is "compositing"?', N'Combining multiple visual elements into a single image'), (8546, 123, N'True/False', N'VFX stands for Video File Extension.', N'False'), (8547, 123, N'MCQ', N'What is the process of removing a green or blue screen called?', N'Chroma Keying'), (8548, 123, N'MCQ', N'What is "rotoscoping"?', N'Manually tracing an object frame-by-frame to create a matte'), (8549, 123, N'True/False', N'A "matte" is a layer that defines the transparent areas of another layer.', N'True'), (8550, 123, N'MCQ', N'What is motion tracking used for?', N'To match the movement of an element to footage'), (8551, 123, N'MCQ', N'What does a Camera Tracker do?', N'Recreates the 3D camera movement from 2D footage'), (8552, 123, N'True/False', N'Color grading is the process of fixing color issues, while color correction is stylistic.', N'False'), (8553, 123, N'MCQ', N'Which Blending Mode would you use to make black areas transparent?', N'Screen'), (8554, 123, N'MCQ', N'What are particle systems used to create?', N'Effects like smoke, fire, and rain'), (8555, 123, N'True/False', N'The order of effects in the Effect Controls panel does not matter.', N'False'), (8556, 123, N'MCQ', N'What is a "Luma Matte"?', N'A matte that uses the brightness values of an image'), (8557, 123, N'True/False', N'A 32-bit color depth allows for more realistic lighting and color.', N'True'), (8558, 123, N'MCQ', N'What is the purpose of "spill suppression" in keying?', N'To remove color reflections from the background'), (8559, 123, N'True/False', N'Compositing is always done in 2D space.', N'False');

-- Department: Multimedia, Track: Motion Graphics, Course: 3D Integration with Cinema 4D
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8560, 124, N'MCQ', N'Which plugin allows for live integration between After Effects and Cinema 4D?', N'Cineware'), (8561, 124, N'True/False', N'You need to render a final video from Cinema 4D before you can use it in After Effects with Cineware.', N'False'), (8562, 124, N'MCQ', N'What is a "render pass" or "multi-pass"?', N'Separate rendered images of scene elements like shadows or reflections'), (8563, 124, N'MCQ', N'Why would you use a multi-pass workflow?', N'For more control during compositing'), (8564, 124, N'True/False', N'You can extract 3D scene data like camera and lights from a C4D file into After Effects.', N'True'), (8565, 124, N'MCQ', N'What is an "Object Buffer"?', N'A matte for a specific object in the 3D scene'), (8566, 124, N'MCQ', N'Which renderer is now standard in Cinema 4D and integrates well with After Effects?', N'Redshift'), (8567, 124, N'True/False', N'The Cineware effect allows you to select the render engine used inside After Effects.', N'True'), (8568, 124, N'MCQ', N'What is the purpose of a "Depth Pass"?', N'To add effects like depth of field in post-production'), (8569, 124, N'MCQ', N'What is the main advantage of integrating 3D into a motion graphics workflow?', N'Adds depth, realism, and dynamic camera moves'), (8570, 124, N'True/False', N'Mograph effectors from C4D can be directly controlled inside of After Effects.', N'False'), (8571, 124, N'MCQ', N'How can you place a 2D layer from After Effects onto a 3D surface in Cinema 4D?', N'Using solids and the Cineware plugin'), (8572, 124, N'True/False', N'Changes made to the .c4d file will automatically update in the linked After Effects project.', N'True'), (8573, 124, N'MCQ', N'What is an "External Compositing Tag" used for in C4D?', N'To align 2D layers from AE to 3D objects'), (8574, 124, N'True/False', N'It is impossible to match the lighting between a 3D render and 2D footage.', N'False');

-- Department: Multimedia, Track: Motion Graphics, Course: Sound Design
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8575, 125, N'MCQ', N'What does "Foley" refer to in sound design?', N'Reproduction of everyday sound effects added in post-production'), (8576, 125, N'True/False', N'Diegetic sound is sound that the characters in the film can hear.', N'True'), (8577, 125, N'MCQ', N'What is non-diegetic sound?', N'Sound the characters cannot hear, like a film score'), (8578, 125, N'MCQ', N'What unit is used to measure sound intensity?', N'Decibels (dB)'), (8579, 125, N'True/False', N'Audio mixing is the process of recording the original audio.', N'False'), (8580, 125, N'MCQ', N'What is an "audio waveform"?', N'A visual representation of an audio signal'), (8581, 125, N'MCQ', N'What does an EQ (Equalizer) do?', N'Adjusts the balance between frequency components'), (8582, 125, N'True/False', N'Reverb is an effect used to create an echo.', N'True'), (8583, 125, N'MCQ', N'What is "ambience" in sound design?', N'The background sounds present in a scene'), (8584, 125, N'MCQ', N'Why is sound design important in motion graphics?', N'It enhances mood and impact'), (8585, 125, N'True/False', N'WAV files are lossy, compressed audio files.', N'False'), (8586, 125, N'MCQ', N'What is audio "normalization"?', N'Adjusting the peak or average level of audio to a standard'), (8587, 125, N'True/False', N'Sound effects and music should always be at the same volume level.', N'False'), (8588, 125, N'MCQ', N'What is a "sound bridge"?', N'When sound from the next scene begins before the current scene ends'), (8589, 125, N'True/False', N'A compressor is used to reduce the dynamic range of an audio signal.', N'True');

-- Department: Multimedia, Track: Motion Graphics, Course: Motion Graphics Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (8590, 126, N'MCQ', N'What is the first step in a motion graphics project?', N'Developing a concept and storyboard'), (8591, 126, N'True/False', N'A moodboard is a collection of audio clips for a project.', N'False'), (8592, 126, N'MCQ', N'What is an "animatic"?', N'A simplified animation of the storyboard timed with audio'), (8593, 126, N'MCQ', N'Why is a style frame important?', N'To establish the visual look and feel before animating'), (8594, 126, N'True/False', N'It is best to start animating without a clear plan.', N'False'), (8595, 126, N'MCQ', N'What should be the primary focus of a motion graphics portfolio piece?', N'Showcasing design and animation skills'), (8596, 126, N'MCQ', N'What does "rendering" mean in this context?', N'Exporting the final video file'), (8597, 126, N'True/False', N'Good pacing and timing are crucial for a successful project.', N'True'), (8598, 126, N'MCQ', N'What is a key consideration when choosing music for a project?', N'The mood and tone it creates'), (8599, 126, N'MCQ', N'What is a "breakdown" in a portfolio?', N'Showing the layers and process of creating a shot'), (8600, 126, N'True/False', N'Technical skill is more important than design principles.', N'False'), (8601, 126, N'MCQ', N'What is the final stage before delivering a project?', N'Final review and rendering'), (8602, 126, N'True/False', N'A capstone project should integrate multiple techniques learned.', N'True'), (8603, 126, N'MCQ', N'Which principle ensures all parts of a design feel like they belong together?', N'Unity/Harmony'), (8604, 126, N'True/False', N'You should not worry about file organization during a complex project.', N'False');
-----------------------------------------------------
-- Department: Multimedia, Track: Motion Graphics, Course: Animation Principles
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8500, 8500, N'Arcs'), (8501, 8500, N'Squash and Stretch'), (8502, 8500, N'Timing'), (8503, 8502, N'Following through on an action'), (8504, 8502, N'Preparing the audience for an action'), (8505, 8502, N'The main action itself'), (8506, 8503, N'Straight Ahead Action'), (8507, 8503, N'Arcs'), (8508, 8503, N'Staging'), (8509, 8505, N'When a character stops suddenly'), (8510, 8505, N'Two characters moving at once'), (8511, 8505, N'When parts of a body continue moving after the body has stopped'), (8512, 8506, N'Anticipation'), (8513, 8506, N'Slow In and Slow Out'), (8514, 8506, N'Timing'), (8515, 8508, N'The time of day in the scene'), (8516, 8508, N'The physical speed of an object'), (8517, 8508, N'The number of frames for an action'), (8518, 8509, N'To make an animation more realistic'), (8519, 8509, N'To make an animation boring'), (8520, 8509, N'To increase the appeal and impact of an action'), (8521, 8511, N'The character is angry'), (8522, 8511, N'The character is well-drawn'), (8523, 8511, N'The character is pleasing to look at'), (8524, 8513, N'Squash and Stretch'), (8525, 8513, N'Appeal'), (8526, 8513, N'Solid Drawing');

-- Department: Multimedia, Track: Motion Graphics, Course: Adobe After Effects Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8527, 8515, N'3D modeling'), (8528, 8515, N'Motion graphics and visual effects'), (8529, 8515, N'Audio editing'), (8530, 8517, N'A single layer'), (8531, 8517, N'An exported video file'), (8532, 8517, N'The container and timeline for layers'), (8533, 8518, N'Adds an effect to a layer'), (8534, 8518, N'Marks a point in time where a property''s value is set'), (8535, 8518, N'Plays the animation'), (8536, 8520, N'A'), (8537, 8520, N'P'), (8538, 8520, N'T'), (8539, 8521, N'Export a project'), (8540, 8521, N'Group layers together into a nested composition'), (8541, 8521, N'Apply a single effect'), (8542, 8523, N'Create a mask'), (8543, 8523, N'Track motion'), (8544, 8523, N'Deform and animate a layer'), (8545, 8524, N'Organizing project files'), (8546, 8524, N'Fine-tuning the speed and value of an animation'), (8547, 8524, N'Adding text to a composition'), (8548, 8526, N'Brightness & Contrast'), (8549, 8526, N'Keylight'), (8550, 8526, N'Hue/Saturation'), (8551, 8528, N'To store footage'), (8552, 8528, N'A layer that is invisible but can be a parent'), (8553, 8528, N'To apply effects to all layers beneath it');

-- Department: Multimedia, Track: Motion Graphics, Course: Keyframe & Typography Animation
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8554, 8530, N'How keyframes are colored'), (8555, 8530, N'How After Effects calculates the frames in-between keyframes'), (8556, 8530, N'How keyframes are deleted'), (8557, 8532, N'To make motion stop abruptly'), (8558, 8532, N'To create smooth, natural-looking motion'), (8559, 8532, N'To make motion move at a constant speed'), (8560, 8533, N'The timing of the keyframe'), (8561, 8533, N'The opacity of the keyframe'), (8562, 8533, N'The influence of the keyframe on the motion curve'), (8563, 8535, N'A person who animates text'), (8564, 8535, N'A property that animates characters, words, or lines individually'), (8565, 8535, N'A pre-made text animation preset'), (8566, 8536, N'The spacing between all characters'), (8567, 8536, N'The spacing between lines of text'), (8568, 8536, N'The spacing between two specific characters'), (8569, 8538, N'Position Animator with a Wiggly Selector'), (8570, 8538, N'Opacity Animator with a Range Selector'), (8571, 8538, N'Scale Animator'), (8572, 8539, N'Slow-moving text'), (8573, 8539, N'An animation technique that uses moving text'), (8574, 8539, N'Text with a glowing effect'), (8575, 8541, N'To link two layers with an expression'), (8576, 8541, N'To make a child layer follow the transformations of a parent layer'), (8577, 8541, N'To merge two layers into one'), (8578, 8543, N'Manually sync by watching the waveform'), (8579, 8543, N'Use the "Animate to Audio" effect'), (8580, 8543, N'Convert audio to keyframes');

-- Department: Multimedia, Track: Motion Graphics, Course: Visual Effects & Compositing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8581, 8545, N'Editing video clips together'), (8582, 8545, N'Combining multiple visual elements into a single image'), (8583, 8545, N'Creating 3D models'), (8584, 8547, N'Color Grading'), (8585, 8547, N'Rotoscoping'), (8586, 8547, N'Chroma Keying'), (8587, 8548, N'Automatically tracking an object'), (8588, 8548, N'Manually tracing an object frame-by-frame to create a matte'), (8589, 8548, N'Creating a 3D model from footage'), (8590, 8550, N'To stabilize shaky footage'), (8591, 8550, N'To match the movement of an element to footage'), (8592, 8550, N'To change the color of a moving object'), (8593, 8551, N'Adds a virtual camera to the scene'), (8594, 8551, N'Recreates the 3D camera movement from 2D footage'), (8595, 8551, N'Tracks an object to attach text to it'), (8596, 8553, N'Multiply'), (8597, 8553, N'Overlay'), (8598, 8553, N'Screen'), (8599, 8554, N'Complex 3D models'), (8600, 8554, N'Effects like smoke, fire, and rain'), (8601, 8554, N'Animated text'), (8602, 8556, N'A matte that uses color information'), (8603, 8556, N'A matte created with the Pen tool'), (8604, 8556, N'A matte that uses the brightness values of an image'), (8605, 8558, N'To add more green to the keyed subject'), (8606, 8558, N'To blur the background'), (8607, 8558, N'To remove color reflections from the background');

-- Department: Multimedia, Track: Motion Graphics, Course: 3D Integration with Cinema 4D
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8608, 8560, N'Element 3D'), (8609, 8560, N'Cineware'), (8610, 8560, N'Motion v3'), (8611, 8562, N'A single final image'), (8612, 8562, N'Separate rendered images of scene elements like shadows or reflections'), (8613, 8562, N'The raw 3D file'), (8614, 8563, N'To render faster'), (8615, 8563, N'For more control during compositing'), (8616, 8563, N'Because it is the only way to render'), (8617, 8565, N'A 3D object from a library'), (8618, 8565, N'An effect that adds motion blur'), (8619, 8565, N'A matte for a specific object in the 3D scene'), (8620, 8566, N'Arnold'), (8621, 8566, N'V-Ray'), (8622, 8566, N'Redshift'), (8623, 8568, N'To create a black and white image'), (8624, 8568, N'To add effects like depth of field in post-production'), (8625, 8568, N'To control the ambient light in the scene'), (8626, 8569, N'Makes projects simpler'), (8627, 8569, N'Reduces render times'), (8628, 8569, N'Adds depth, realism, and dynamic camera moves'), (8629, 8571, N'By pre-composing the layer'), (8630, 8571, N'Using solids and the Cineware plugin'), (8631, 8571, N'It is not possible'), (8632, 8573, N'To create an external copy of the project'), (8633, 8573, N'To align 2D layers from AE to 3D objects'), (8634, 8573, N'To link to an external texture');

-- Department: Multimedia, Track: Motion Graphics, Course: Sound Design
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8635, 8575, N'The film''s musical score'), (8636, 8575, N'Reproduction of everyday sound effects added in post-production'), (8637, 8575, N'Dialogue spoken by characters'), (8638, 8577, N'Sound the characters can hear'), (8639, 8577, N'Sound coming from an on-screen source'), (8640, 8577, N'Sound the characters cannot hear, like a film score'), (8641, 8578, N'Hertz (Hz)'), (8642, 8578, N'Decibels (dB)'), (8643, 8578, N'Frames Per Second (FPS)'), (8644, 8580, N'A list of sound files'), (8645, 8580, N'A visual representation of an audio signal'), (8646, 8580, N'An effect that adds echo'), (8647, 8581, N'Increases the overall volume'), (8648, 8581, N'Adds compression to the audio'), (8649, 8581, N'Adjusts the balance between frequency components'), (8650, 8583, N'The main sound effect of an action'), (8651, 8583, N'The background sounds present in a scene'), (8652, 8583, N'A silent part of the audio track'), (8653, 8584, N'It is not important'), (8654, 8584, N'It enhances mood and impact'), (8655, 8584, N'It makes the video file smaller'), (8656, 8586, N'Applying the same effect to multiple clips'), (8657, 8586, N'Adjusting the peak or average level of audio to a standard'), (8658, 8586, N'Changing the audio file format'), (8659, 8588, N'When two sounds play at the same time'), (8660, 8588, N'When sound from the next scene begins before the current scene ends'), (8661, 8588, N'A piece of music that connects two scenes');

-- Department: Multimedia, Track: Motion Graphics, Course: Motion Graphics Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (8662, 8590, N'Animating the main sequence'), (8663, 8590, N'Sound design'), (8664, 8590, N'Developing a concept and storyboard'), (8665, 8592, N'The final rendered video'), (8666, 8592, N'A simplified animation of the storyboard timed with audio'), (8667, 8592, N'A collection of style frames'), (8668, 8593, N'To test the animation speed'), (8669, 8593, N'To establish the visual look and feel before animating'), (8670, 8593, N'To choose the final music'), (8671, 8595, N'Using as many effects as possible'), (8672, 8595, N'Showcasing design and animation skills'), (8673, 8595, N'Making the piece as long as possible'), (8674, 8596, N'Organizing files'), (8675, 8596, N'Exporting the final video file'), (8676, 8596, N'Importing footage'), (8677, 8598, N'If it is a popular song'), (8678, 8598, N'The mood and tone it creates'), (8679, 8598, N'The length of the song'), (8680, 8599, N'The final result'), (8681, 8599, N'A list of software used'), (8682, 8599, N'Showing the layers and process of creating a shot'), (8683, 8601, N'Storyboarding'), (8684, 8601, N'Style frames'), (8685, 8601, N'Final review and rendering'), (8686, 8603, N'Contrast'), (8687, 8603, N'Hierarchy'), (8688, 8603, N'Unity/Harmony');


--Track 19 Concept Art Questions =========================================================================================================

-- Department: Multimedia, Track: Concept Art, Course: Drawing, Perspective & Composition
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9000, 127, N'MCQ', N'What is the line where the sky meets the ground called?', N'Horizon Line'), (9001, 127, N'True/False', N'In two-point perspective, all parallel lines converge to a single vanishing point.', N'False'), (9002, 127, N'MCQ', N'What is the "Rule of Thirds"?', N'A compositional guide dividing an image into nine equal parts'), (9003, 127, N'MCQ', N'Lines that are closer to the viewer should generally be:', N'Thicker and darker'), (9004, 127, N'True/False', N'A vanishing point always sits on the horizon line.', N'True'), (9005, 127, N'MCQ', N'What does "foreshortening" depict?', N'An object appearing compressed to create depth'), (9006, 127, N'MCQ', N'What is the primary purpose of thumbnail sketching?', N'To quickly explore compositions and ideas'), (9007, 127, N'True/False', N'One-point perspective is used for viewing an object head-on.', N'True'), (9008, 127, N'MCQ', N'"Leading lines" in composition are used to:', N'Guide the viewer''s eye to a focal point'), (9009, 127, N'True/False', N'Symmetrical balance in a composition feels dynamic and energetic.', N'False'), (9010, 127, N'MCQ', N'What is "negative space" in a drawing?', N'The empty space around the subject'), (9011, 127, N'True/False', N'Three-point perspective adds a vanishing point above or below the horizon.', N'True'), (9012, 127, N'MCQ', N'The technique of using light and shadow to create a sense of 3D form is called?', N'Shading'), (9013, 127, N'True/False', N'A high horizon line can make the viewer feel like they are looking down.', N'True'), (9014, 127, N'MCQ', N'What is a "gesture drawing"?', N'A quick sketch to capture movement and form');

-- Department: Multimedia, Track: Concept Art, Course: Digital Painting with Photoshop
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9015, 128, N'MCQ', N'Which Photoshop tool is best for blending colors smoothly?', N'Soft Round Brush with low flow'), (9016, 128, N'True/False', N'A layer set to "Multiply" blending mode will make the image darker.', N'True'), (9017, 128, N'MCQ', N'What is the main advantage of using layers?', N'Allows for non-destructive editing'), (9018, 128, N'MCQ', N'What does the "Lasso Tool" do?', N'Creates a freehand selection'), (9019, 128, N'True/False', N'You should start a painting with fine details first.', N'False'), (9020, 128, N'MCQ', N'What is an "Adjustment Layer"?', N'A layer that applies color and tonal adjustments without permanently changing pixels'), (9021, 128, N'MCQ', N'What is a "Clipping Mask" used for?', N'To confine the pixels of one layer to the shape of the layer below it'), (9022, 128, N'True/False', N'The "Eyedropper Tool" is used to select areas of an image.', N'False'), (9023, 128, N'MCQ', N'Which blending mode is good for adding highlights or glow effects?', N'Screen or Linear Dodge (Add)'), (9024, 128, N'MCQ', N'What is the first step in digital painting?', N'Blocking in large shapes and values'), (9025, 128, N'True/False', N'A higher DPI/PPI is generally better for printed images than for web images.', N'True'), (9026, 128, N'MCQ', N'What does "value" refer to in painting?', N'The lightness or darkness of a color'), (9027, 128, N'True/False', N'The Smudge Tool is the best way to blend colors for a painterly look.', N'False'), (9028, 128, N'MCQ', N'Which keyboard shortcut quickly inverts a layer mask?', N'Ctrl/Cmd + I'), (9029, 128, N'True/False', N'It is a good practice to merge all layers frequently to save file space.', N'False');

-- Department: Multimedia, Track: Concept Art, Course: Character & Creature Design
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9030, 129, N'MCQ', N'What is the most important aspect of a character design at first glance?', N'Silhouette'), (9031, 129, N'True/False', N'Round shapes are often used to design intimidating, evil characters.', N'False'), (9032, 129, N'MCQ', N'What is "shape language"?', N'Using shapes to communicate a character''s personality'), (9033, 129, N'MCQ', N'Why is gathering reference important for creature design?', N'To ground the design in realism and believability'), (9034, 129, N'True/False', N'A good character design should be as complex and detailed as possible.', N'False'), (9035, 129, N'MCQ', N'What is a "character lineup"?', N'A comparison of multiple characters to show scale and style'), (9036, 129, N'MCQ', N'The study of body structure and form is called?', N'Anatomy'), (9037, 129, N'True/False', N'Symmetry in a character design can make it feel more heroic and stable.', N'True'), (9038, 129, N'MCQ', N'What is the purpose of exploring different "thumbnails" for a character?', N'To generate a variety of ideas quickly'), (9039, 129, N'MCQ', N'Which shape is often associated with friendly and harmless characters?', N'Circle'), (9040, 129, N'True/False', N'The colors used for a character have little impact on their perceived personality.', N'False'), (9041, 129, N'MCQ', N'What does "storytelling" in a design refer to?', N'Visual clues about the character''s history and personality'), (9042, 129, N'True/False', N'A creature design should always be based on a single real-world animal.', N'False'), (9043, 129, N'MCQ', N'What is a "turnaround" or "model sheet"?', N'Views of the character from multiple angles'), (9044, 129, N'True/False', N'Function should be considered when designing creature anatomy (e.g., how it eats, moves).', N'True');

-- Department: Multimedia, Track: Concept Art, Course: Environment Design
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9045, 130, N'MCQ', N'What is "atmospheric perspective"?', N'Objects in the distance appearing faded and bluer'), (9046, 130, N'True/False', N'A "focal point" is where you want the viewer to look first.', N'True'), (9047, 130, N'MCQ', N'What is the purpose of a "thumbnail sketch" in environment design?', N'To explore composition and mood'), (9048, 130, N'MCQ', N'What is a "callout sheet"?', N'A detailed drawing of a specific part of the environment'), (9049, 130, N'True/False', N'An environment should be designed without considering the story.', N'False'), (9050, 130, N'MCQ', N'How can an artist create a sense of scale in an environment?', N'Including objects of a known size (e.g., a person)'), (9051, 130, N'MCQ', N'What is the difference between foreground, midground, and background?', N'The different planes of depth in an image'), (9052, 130, N'True/False', N'Hard, sharp edges are typically used for objects in the far background.', N'False'), (9053, 130, N'MCQ', N'What is "visual language" in environment design?', N'Consistent use of shapes and motifs'), (9054, 130, N'MCQ', N'What is the primary function of lighting in an environment concept?', N'To establish mood and guide the eye'), (9055, 130, N'True/False', N'Using a limited color palette can help create a more cohesive mood.', N'True'), (9056, 130, N'MCQ', N'What is a "matte painting"?', N'A detailed painting of a landscape or set'), (9057, 130, N'True/False', N'Weather and atmosphere should not affect the design.', N'False'), (9058, 130, N'MCQ', N'What does the term "kitbashing" refer to?', N'Combining parts from various 3D models to create something new'), (9059, 130, N'True/False', N'An environment concept should feel sterile and unused.', N'False');

-- Department: Multimedia, Track: Concept Art, Course: Prop & Vehicle Design
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9060, 131, N'MCQ', N'What is the most important consideration for prop design?', N'Its function and story relevance'), (9061, 131, N'True/False', N'A vehicle''s design should reflect its purpose (e.g., speed, cargo).', N'True'), (9062, 131, N'MCQ', N'What is a "hero prop"?', N'A key prop that is seen up close and is highly detailed'), (9063, 131, N'MCQ', N'What does an "exploded view" of a prop show?', N'How the different parts of the prop fit together'), (9064, 131, N'True/False', N'The wear and tear on a prop can tell a story about its history.', N'True'), (9065, 131, N'MCQ', N'What is the main purpose of "shape language" in vehicle design?', N'To convey the vehicle''s personality and function'), (9066, 131, N'MCQ', N'Why is silhouette important for vehicle and prop design?', N'For immediate readability'), (9067, 131, N'True/False', N'It is unnecessary to research real-world mechanics when designing a fictional vehicle.', N'False'), (9068, 131, N'MCQ', N'What is a "material callout"?', N'Labels that indicate the different materials on a design'), (9069, 131, N'MCQ', N'Which of these is NOT a primary principle of good prop design?', N'Making it symmetrical'), (9070, 131, N'True/False', N'A prop should be designed in isolation, without considering the character who uses it.', N'False'), (9071, 131, N'MCQ', N'What is the first step in designing a prop?', N'Understanding its role in the story'), (9072, 131, N'True/False', N'Industrial design is a good field to study for vehicle concept art.', N'True'), (9073, 131, N'MCQ', N'How can scale be established in a vehicle design drawing?', N'Including a human figure next to it'), (9074, 131, N'True/False', N'The interior of a vehicle is not considered part of its design.', N'False');

-- Department: Multimedia, Track: Concept Art, Course: World Building & Storytelling
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9075, 132, N'MCQ', N'What is "world building"?', N'The process of constructing an imaginary world'), (9076, 132, N'True/False', N'Visual storytelling is about writing a good script.', N'False'), (9077, 132, N'MCQ', N'What is a "visual motif"?', N'A recurring shape or pattern that has symbolic meaning'), (9078, 132, N'MCQ', N'How does architecture contribute to world building?', N'It reflects the culture, technology, and history of the inhabitants'), (9079, 132, N'True/False', N'A well-built world should have no internal rules or logic.', N'False'), (9080, 132, N'MCQ', N'What is a "beat board"?', N'A series of images that outline the key story moments'), (9081, 132, N'MCQ', N'What is the role of color script in storytelling?', N'To map out the color, lighting, and emotional progression of a story'), (9082, 132, N'True/False', N'Costume design can reveal a character''s social status and personality.', N'True'), (9083, 132, N'MCQ', N'The concept of "show, don''t tell" means:', N'Conveying information visually rather than through dialogue'), (9084, 132, N'MCQ', N'What is the purpose of establishing shots?', N'To show the location and set the scene'), (9085, 132, N'True/False', N'Good world building means explaining every single detail to the audience.', N'False'), (9086, 132, N'MCQ', N'How can history be shown in a world?', N'Through ruins, aged props, and layered architecture'), (9087, 132, N'True/False', N'The geography and climate of a world should influence its cultures and designs.', N'True'), (9088, 132, N'MCQ', N'What is a "mood board" used for?', N'To collect visual references to establish a feeling or aesthetic'), (9089, 132, N'True/False', N'Every element in a scene should have a purpose related to the story.', N'True');

-- Department: Multimedia, Track: Concept Art, Course: Concept Art Portfolio Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9090, 133, N'MCQ', N'What is the primary purpose of a concept art portfolio?', N'To get a job'), (9091, 133, N'True/False', N'A portfolio should show a wide variety of inconsistent styles.', N'False'), (9092, 133, N'MCQ', N'What should a portfolio begin and end with?', N'Your strongest work'), (9093, 133, N'MCQ', N'How many pieces should a typical online portfolio have?', N'10-20'), (9094, 133, N'True/False', N'It is a good idea to include fan art in a professional portfolio.', N'False'), (9095, 133, N'MCQ', N'What does it mean to "tailor" your portfolio?', N'To customize it for the specific studio you are applying to'), (9096, 133, N'MCQ', N'Why is it important to show your process work (sketches, thumbnails)?', N'It demonstrates your thought process and problem-solving skills'), (9097, 133, N'True/False', N'Only finished, polished illustrations should be included.', N'False'), (9098, 133, N'MCQ', N'What is a "personal project" in a portfolio?', N'A project based on your own ideas to showcase your passion and skills'), (9099, 133, N'MCQ', N'What is the best format for an online portfolio?', N'A personal website or a dedicated portfolio site like ArtStation'), (9100, 133, N'True/False', N'You should write long paragraphs explaining each image.', N'False'), (9101, 133, N'MCQ', N'What is a key skill demonstrated by a project-based portfolio?', N'The ability to develop an idea cohesively'), (9102, 133, N'True/False', N'The presentation of your work is just as important as the work itself.', N'True'), (9103, 133, N'MCQ', N'What should your contact information on a portfolio include?', N'Your name, email, and a link to your portfolio'), (9104, 133, N'True/False', N'A capstone project is designed to be the main showcase of your portfolio.', N'True');
-------------------------------------------
-- Department: Multimedia, Track: Concept Art, Course: Drawing, Perspective & Composition
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9000, 9000, N'Vanishing Point'), (9001, 9000, N'Horizon Line'), (9002, 9000, N'Picture Plane'), (9003, 9002, N'A way to create perfect symmetry'), (9004, 9002, N'A compositional guide dividing an image into nine equal parts'), (9005, 9002, N'A rule for mixing three colors'), (9006, 9003, N'Thinner and lighter'), (9007, 9003, N'The same as distant lines'), (9008, 9003, N'Thicker and darker'), (9009, 9005, N'An object appearing stretched out'), (9010, 9005, N'An object appearing compressed to create depth'), (9011, 9005, N'An object that is perfectly flat'), (9012, 9006, N'To create a final, polished drawing'), (9013, 9006, N'To practice shading techniques'), (9014, 9006, N'To quickly explore compositions and ideas'), (9015, 9008, N'Create a sense of chaos'), (9016, 9008, N'Guide the viewer''s eye to a focal point'), (9017, 9008, N'Flatten the image'), (9018, 9010, N'The main subject of a drawing'), (9019, 9010, N'The empty space around the subject'), (9020, 9010, N'The frame of the drawing'), (9021, 9012, N'Hatching'), (9022, 9012, N'Linework'), (9023, 9012, N'Shading'), (9024, 9014, N'A detailed anatomical study'), (9025, 9014, N'A quick sketch to capture movement and form'), (9026, 9014, N'A final, rendered image');

-- Department: Multimedia, Track: Concept Art, Course: Digital Painting with Photoshop
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9027, 9015, N'Hard Round Brush'), (9028, 9015, N'Smudge Tool'), (9029, 9015, N'Soft Round Brush with low flow'), (9030, 9017, N'Increases file size'), (9031, 9017, N'Allows for non-destructive editing'), (9032, 9017, N'Makes painting faster'), (9033, 9018, N'Paints with a solid color'), (9034, 9018, N'Creates a freehand selection'), (9035, 9018, N'Erases pixels'), (9036, 9020, N'A filter that sharpens the image'), (9037, 9020, N'A layer that applies color and tonal adjustments without permanently changing pixels'), (9038, 9020, N'The bottom-most layer in a file'), (9039, 9021, N'To permanently merge two layers'), (9040, 9021, N'To hide a layer from view'), (9041, 9021, N'To confine the pixels of one layer to the shape of the layer below it'), (9042, 9023, N'Multiply'), (9043, 9023, N'Overlay'), (9044, 9023, N'Screen or Linear Dodge (Add)'), (9045, 9024, N'Blocking in large shapes and values'), (9046, 9024, N'Adding small textures'), (9047, 9024, N'Choosing a color palette'), (9048, 9026, N'The hue of a color'), (9049, 9026, N'The saturation of a color'), (9050, 9026, N'The lightness or darkness of a color'), (9051, 9028, N'Ctrl/Cmd + L'), (9052, 9028, N'Ctrl/Cmd + I'), (9053, 9028, N'Ctrl/Cmd + D');

-- Department: Multimedia, Track: Concept Art, Course: Character & Creature Design
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9054, 9030, N'Color Palette'), (9055, 9030, N'Costume'), (9056, 9030, N'Silhouette'), (9057, 9032, N'A specific dialect'), (9058, 9032, N'The font used for a character''s name'), (9059, 9032, N'Using shapes to communicate a character''s personality'), (9060, 9033, N'To copy an existing animal exactly'), (9061, 9033, N'To ground the design in realism and believability'), (9062, 9033, N'Because it is a required step'), (9063, 9035, N'A list of the character''s abilities'), (9064, 9035, N'A comparison of multiple characters to show scale and style'), (9065, 9035, N'A single drawing of the character'), (9066, 9036, N'Psychology'), (9067, 9036, N'Anatomy'), (9068, 9036, N'History'), (9069, 9038, N'To create final, polished images'), (9070, 9038, N'To generate a variety of ideas quickly'), (9071, 9038, N'To practice coloring'), (9072, 9039, N'Square'), (9073, 9039, N'Triangle'), (9074, 9039, N'Circle'), (9075, 9041, N'A written backstory'), (9076, 9041, N'Visual clues about the character''s history and personality'), (9077, 9041, N'The character''s dialogue'), (9078, 9043, N'An action pose'), (9079, 9043, N'A 3D model of the character'), (9080, 9043, N'Views of the character from multiple angles');

-- Department: Multimedia, Track: Concept Art, Course: Environment Design
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9081, 9045, N'One-point perspective'), (9082, 9045, N'The Rule of Thirds'), (9083, 9045, N'Objects in the distance appearing faded and bluer'), (9084, 9047, N'To create the final painting'), (9085, 9047, N'To explore composition and mood'), (9086, 9047, N'To test color palettes'), (9087, 9048, N'A wide shot of the entire environment'), (9088, 9048, N'A 3D model'), (9089, 9048, N'A detailed drawing of a specific part of the environment'), (9090, 9050, N'Using only dark colors'), (9091, 9050, N'Including objects of a known size (e.g., a person)'), (9092, 9050, N'Making everything the same size'), (9093, 9051, N'The different color zones'), (9094, 9051, N'The time of day'), (9095, 9051, N'The different planes of depth in an image'), (9096, 9053, N'The spoken language in the world'), (9097, 9053, N'Consistent use of shapes and motifs'), (9098, 9053, N'The text written on signs'), (9099, 9054, N'To make everything visible'), (9100, 9054, N'To establish mood and guide the eye'), (9101, 9054, N'To flatten the image'), (9102, 9056, N'A rough compositional sketch'), (9103, 9056, N'A detailed painting of a landscape or set'), (9104, 9056, N'A 3D render'), (9105, 9058, N'Painting over a 3D render'), (9106, 9058, N'Combining parts from various 3D models to create something new'), (9107, 9058, N'Using a photo as a base for painting');

-- Department: Multimedia, Track: Concept Art, Course: Prop & Vehicle Design
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9108, 9060, N'How shiny it is'), (9109, 9060, N'Its color'), (9110, 9060, N'Its function and story relevance'), (9111, 9062, N'A prop used by a secondary character'), (9112, 9062, N'A key prop that is seen up close and is highly detailed'), (9113, 9062, N'Any prop that is a weapon'), (9114, 9063, N'A 360-degree view of the prop'), (9115, 9063, N'The prop in a state of disrepair'), (9116, 9063, N'How the different parts of the prop fit together'), (9117, 9065, N'To make it look cool'), (9118, 9065, N'To convey the vehicle''s personality and function'), (9119, 9065, N'To make it aerodynamic'), (9120, 9066, N'For aesthetic appeal'), (9121, 9066, N'For immediate readability'), (9122, 9066, N'To make it easier to model in 3D'), (9123, 9068, N'A list of the prop''s functions'), (9124, 9068, N'Labels that indicate the different materials on a design'), (9125, 9068, N'Instructions for animation'), (9126, 9069, N'Readability'), (9127, 9069, N'Functionality'), (9128, 9069, N'Making it symmetrical'), (9129, 9071, N'Sketching different shapes'), (9130, 9071, N'Understanding its role in the story'), (9131, 9071, N'Choosing a color scheme'), (9132, 9073, N'Using perspective'), (9133, 9073, N'Including a human figure next to it'), (9134, 9073, N'Writing the dimensions in text');

-- Department: Multimedia, Track: Concept Art, Course: World Building & Storytelling
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9135, 9075, N'Designing a single character'), (9136, 9075, N'The process of constructing an imaginary world'), (9137, 9075, N'Painting a landscape'), (9138, 9077, N'A random decorative element'), (9139, 9077, N'A recurring shape or pattern that has symbolic meaning'), (9140, 9077, N'The logo of the project'), (9141, 9078, N'It only provides a backdrop'), (9142, 9078, N'It reflects the culture, technology, and history of the inhabitants'), (9143, 9078, N'It has no impact on the story'), (9144, 9080, N'A page from a script'), (9145, 9080, N'A series of images that outline the key story moments'), (9146, 9080, N'A list of character names'), (9147, 9081, N'To pick the final colors for a character'), (9148, 9081, N'To map out the color, lighting, and emotional progression of a story'), (9149, 9081, N'A list of all colors used in the project'), (9150, 9083, N'Using lots of text and labels'), (9151, 9083, N'Conveying information visually rather than through dialogue'), (9152, 9083, N'Telling the audience the story directly'), (9153, 9084, N'To show a close-up of a character'), (9154, 9084, N'To show the location and set the scene'), (9155, 9084, N'To create a dramatic moment'), (9156, 9086, N'By stating the history in text'), (9157, 9086, N'Through ruins, aged props, and layered architecture'), (9158, 9086, N'It can''t be shown, only told'), (9159, 9088, N'A storyboard'), (9160, 9088, N'To collect visual references to establish a feeling or aesthetic'), (9161, 9088, N'The final design document');

-- Department: Multimedia, Track: Concept Art, Course: Concept Art Portfolio Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9162, 9090, N'To showcase your hobbies'), (9163, 9090, N'To get a job'), (9164, 9090, N'To store all of your artwork'), (9165, 9092, N'Your strongest work'), (9166, 9092, N'Your oldest work'), (9167, 9092, N'Your weakest work'), (9168, 9093, N'Over 50'), (9169, 9093, N'Less than 5'), (9170, 9093, N'10-20'), (9171, 9095, N'To create a new portfolio from scratch'), (9172, 9095, N'To include work that is not yours'), (9173, 9095, N'To customize it for the specific studio you are applying to'), (9174, 9096, N'It is not important and should be excluded'), (9175, 9096, N'It demonstrates your thought process and problem-solving skills'), (9176, 9096, N'To make the portfolio look more full'), (9177, 9098, N'Work done for a client'), (9178, 9098, N'A project based on your own ideas to showcase your passion and skills'), (9179, 9098, N'Fan art of a popular movie'), (9180, 9099, N'A PDF file sent via email'), (9181, 9099, N'A personal website or a dedicated portfolio site like ArtStation'), (9182, 9099, N'An Instagram account'), (9183, 9101, N'The ability to draw quickly'), (9184, 9101, N'The ability to follow instructions'), (9185, 9101, N'The ability to develop an idea cohesively'), (9186, 9103, N'Your home address'), (9187, 9103, N'Your name, email, and a link to your portfolio'), (9188, 9103, N'A long biography');


--Track 20 UI/UX Design Questions ======================================================================================================================

-- Department: Multimedia, Track: UI/UX Design, Course: UI/UX Intro & User Research
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9500, 134, N'MCQ', N'What does UX stand for?', N'User Experience'), (9501, 134, N'True/False', N'UI is the same as UX.', N'False'), (9502, 134, N'MCQ', N'Which of these is a primary goal of UX design?', N'To make a product useful, usable, and enjoyable'), (9503, 134, N'MCQ', N'What is a "user persona"?', N'A fictional character representing a target user group'), (9504, 134, N'True/False', N'User research is best done after the product has been designed and built.', N'False'), (9505, 134, N'MCQ', N'Which research method involves observing users in their natural environment?', N'Ethnographic study'), (9506, 134, N'MCQ', N'What is an "empathy map"?', N'A tool to visualize user attitudes and behaviors'), (9507, 134, N'True/False', N'Quantitative research focuses on non-numerical data like opinions and feelings.', N'False'), (9508, 134, N'MCQ', N'A user interview is an example of what type of research?', N'Qualitative'), (9509, 134, N'MCQ', N'What is Jakob''s Law?', N'Users prefer your site to work the same way as all the other sites they already know'), (9510, 134, N'True/False', N'The "double diamond" is a design process model.', N'True'), (9511, 134, N'MCQ', N'What is a "pain point"?', N'A specific problem that users experience'), (9512, 134, N'True/False', N'Surveys are a good way to gather qualitative data.', N'False'), (9513, 134, N'MCQ', N'What does UI design primarily focus on?', N'The visual layout and interactive elements of a product'), (9514, 134, N'True/False', N'A stakeholder is anyone with an interest in the project.', N'True');

-- Department: Multimedia, Track: UI/UX Design, Course: Information Architecture & User Flows
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9515, 135, N'MCQ', N'What is Information Architecture (IA)?', N'The practice of organizing and structuring content'), (9516, 135, N'True/False', N'A sitemap is a visual representation of a website''s IA.', N'True'), (9517, 135, N'MCQ', N'What is a "user flow"?', N'A diagram showing the path a user takes to complete a task'), (9518, 135, N'MCQ', N'Which IA principle involves arranging content in a way that is intuitive to the user?', N'Organization'), (9519, 135, N'True/False', N'"Card sorting" is a method used to understand users'' mental models.', N'True'), (9520, 135, N'MCQ', N'What is a "taxonomy"?', N'The classification and naming of content'), (9521, 135, N'MCQ', N'What does a user flow diagram typically begin and end with?', N'An entry point and a final action/success state'), (9522, 135, N'True/False', N'Good navigation is a key outcome of good Information Architecture.', N'True'), (9523, 135, N'MCQ', N'In an open card sort, users are asked to:', N'Group topics into their own categories and name them'), (9524, 135, N'MCQ', N'What is a "happy path" in a user flow?', N'The ideal path a user takes with no errors'), (9525, 135, N'True/False', N'User flows and user journeys are the exact same thing.', N'False'), (9526, 135, N'MCQ', N'What is the primary goal of IA?', N'To help users find information and complete tasks'), (9527, 135, N'True/False', N'IA is only important for large, complex websites.', N'False'), (9528, 135, N'MCQ', N'A set of links that help users navigate a site is called what?', N'Navigation System'), (9529, 135, N'True/False', N'A flowchart is a common tool for creating user flows.', N'True');

-- Department: Multimedia, Track: UI/UX Design, Course: Wireframing & Prototyping with Figma
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9530, 136, N'MCQ', N'What is a "wireframe"?', N'A low-fidelity, basic layout of a screen'), (9531, 136, N'True/False', N'Wireframes should include final colors and fonts.', N'False'), (9532, 136, N'MCQ', N'What is the main purpose of wireframing?', N'To focus on structure and functionality'), (9533, 136, N'MCQ', N'What is a "prototype"?', N'An interactive simulation of the final product'), (9534, 136, N'True/False', N'A low-fidelity prototype is often made from paper sketches.', N'True'), (9535, 136, N'MCQ', N'Figma is primarily a...?', N'Collaborative, browser-based design tool'), (9536, 136, N'MCQ', N'What are "components" in Figma?', N'Reusable UI elements that can be instanced'), (9537, 136, N'True/False', N'You cannot create interactive prototypes in Figma.', N'False'), (9538, 136, N'MCQ', N'What does "Auto Layout" in Figma help with?', N'Creating responsive designs that adapt to content'), (9539, 136, N'MCQ', N'What is a mockup?', N'A static, high-fidelity design that shows the visual style'), (9540, 136, N'True/False', N'Prototyping is essential for user testing before development.', N'True'), (9541, 136, N'MCQ', N'What is the benefit of using "Styles" in Figma?', N'Ensures consistency for colors and typography'), (9542, 136, N'True/False', N'A wireframe is the same as a mockup.', N'False'), (9543, 136, N'MCQ', N'What is "Lorem Ipsum"?', N'Placeholder text used in design mockups'), (9544, 136, N'True/False', N'Figma files can only be accessed by one person at a time.', N'False');

-- Department: Multimedia, Track: UI/UX Design, Course: Visual Design & Design Systems
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9545, 137, N'MCQ', N'What is a "design system"?', N'A collection of reusable components and standards'), (9546, 137, N'True/False', N'A style guide is the same as a design system.', N'False'), (9547, 137, N'MCQ', N'Which principle of visual design relates to creating a focal point?', N'Emphasis'), (9548, 137, N'MCQ', N'The space between elements in a design is called?', N'White Space / Negative Space'), (9549, 137, N'True/False', N'A grid system helps to create alignment and consistency.', N'True'), (9550, 137, N'MCQ', N'What is "visual hierarchy"?', N'The arrangement of elements to show their order of importance'), (9551, 137, N'MCQ', N'What is the primary benefit of a design system?', N'Consistency and efficiency'), (9552, 137, N'True/False', N'Using too many different typefaces is a good design practice.', N'False'), (9553, 137, N'MCQ', N'What does "contrast" help with in UI design?', N'Readability and directing attention'), (9554, 137, N'MCQ', N'What are "atomic design" principles?', N'A methodology for creating design systems'), (9555, 137, N'True/False', N'Design tokens are variables that store visual design attributes.', N'True'), (9556, 137, N'MCQ', N'Which of these is a core component of a design system?', N'UI Components (e.g., buttons, forms)'), (9557, 137, N'True/False', N'A design system is only useful for designers, not developers.', N'False'), (9558, 137, N'MCQ', N'The principle of keeping related items grouped together is called?', N'Proximity'), (9559, 137, N'True/False', N'The 8-point grid system is a common layout framework in UI design.', N'True');

-- Department: Multimedia, Track: UI/UX Design, Course: Usability Testing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9560, 138, N'MCQ', N'What is the main goal of usability testing?', N'To identify usability problems with a design'), (9561, 138, N'True/False', N'During a usability test, you should help the user if they get stuck.', N'False'), (9562, 138, N'MCQ', N'What is a "moderated" usability test?', N'A test where a facilitator guides the participant'), (9563, 138, N'MCQ', N'What is the "think aloud" protocol?', N'Asking users to verbalize their thoughts as they perform tasks'), (9564, 138, N'True/False', N'You need at least 20-30 users to find most usability issues.', N'False'), (9565, 138, N'MCQ', N'A/B testing is a method for what?', N'Comparing two versions of a design to see which performs better'), (9566, 138, N'MCQ', N'Which metric measures how long it takes a user to complete a task?', N'Time on Task'), (9567, 138, N'True/False', N'A usability test script should contain leading questions.', N'False'), (9568, 138, N'MCQ', N'What is an "unmoderated" usability test?', N'A test where participants complete tasks on their own'), (9569, 138, N'MCQ', N'What is a key benefit of remote usability testing?', N'Access to a wider pool of participants'), (9570, 138, N'True/False', N'The System Usability Scale (SUS) is a questionnaire to measure perceived usability.', N'True'), (9571, 138, N'MCQ', N'What is a "heuristic evaluation"?', N'An inspection of a UI by experts against usability principles'), (9572, 138, N'True/False', N'The ideal participant for a usability test is a fellow designer.', N'False'), (9573, 138, N'MCQ', N'What is a "pilot test"?', N'A practice run of a usability study'), (9574, 138, N'True/False', N'Usability testing should only be done once at the end of the project.', N'False');

-- Department: Multimedia, Track: UI/UX Design, Course: Accessibility in Design
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9575, 139, N'MCQ', N'What does "Accessibility" (a11y) mean in design?', N'Designing products usable by people with disabilities'), (9576, 139, N'True/False', N'Accessibility is an optional add-on for most websites.', N'False'), (9577, 139, N'MCQ', N'What does WCAG stand for?', N'Web Content Accessibility Guidelines'), (9578, 139, N'MCQ', N'What is the purpose of "alt text" for images?', N'To describe the image for screen reader users'), (9579, 139, N'True/False', N'Using only color to convey information is an accessible practice.', N'False'), (9580, 139, N'MCQ', N'What is a minimum contrast ratio for normal text according to WCAG AA?', N'4.5:1'), (9581, 139, N'MCQ', N'What does "semantic HTML" refer to?', N'Using HTML elements for their correct purpose (e.g., `<nav>`, `<button>`)'), (9582, 139, N'True/False', N'All users navigate websites with a mouse.', N'False'), (9583, 139, N'MCQ', N'Who benefits from accessible design?', N'Everyone'), (9584, 139, N'MCQ', N'What is a "screen reader"?', N'Software that reads out the content of a screen for visually impaired users'), (9585, 139, N'True/False', N'Videos with audio should have captions for accessibility.', N'True'), (9586, 139, N'MCQ', N'What does "keyboard focus" refer to?', N'The visible indicator showing which element is active for keyboard navigation'), (9587, 139, N'True/False', N'Designing for accessibility often leads to a better experience for all users.', N'True'), (9588, 139, N'MCQ', N'Which of these is a type of disability to consider in design?', N'All of the above'), (9589, 139, N'True/False', N'WCAG has three levels of conformance: A, AA, and AAA.', N'True');

-- Department: Multimedia, Track: UI/UX Design, Course: UI/UX Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (9590, 140, N'MCQ', N'What is a UX case study?', N'A detailed presentation of a design project from start to finish'), (9591, 140, N'True/False', N'A capstone project should only show the final, polished designs.', N'False'), (9592, 140, N'MCQ', N'What is the first phase of the design thinking process?', N'Empathize'), (9593, 140, N'MCQ', N'Why is storytelling important in a case study?', N'To engage the reader and explain design decisions'), (9594, 140, N'True/False', N'A problem statement defines the user, their need, and the insight.', N'True'), (9595, 140, N'MCQ', N'What is the purpose of a project retrospective?', N'To reflect on what went well and what could be improved'), (9596, 140, N'MCQ', N'What should your portfolio demonstrate to potential employers?', N'Your design process and problem-solving skills'), (9597, 140, N'True/False', N'You should clearly state your role and contributions in a team project.', N'True'), (9598, 140, N'MCQ', N'What does it mean to "iterate" on a design?', N'To refine and improve it based on feedback and testing'), (9599, 140, N'MCQ', N'Which part of a case study shows the evolution of the design?', N'Sketches, wireframes, and prototypes'), (9600, 140, N'True/False', N'Measuring the impact of your design with metrics is not important.', N'False'), (9601, 140, N'MCQ', N'What is a key component of a good capstone project presentation?', N'Focusing on the "why" behind your design choices'), (9602, 140, N'True/False', N'The "Define" phase of design thinking involves creating prototypes.', N'False'), (9603, 140, N'MCQ', N'What is a "deliverable" in a UX project?', N'A tangible output, such as a persona or wireframe'), (9604, 140, N'True/False', N'A capstone project is an opportunity to showcase your entire skillset.', N'True');
-----------------------------------------------------------------------------
-- Department: Multimedia, Track: UI/UX Design, Course: UI/UX Intro & User Research
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9500, 9500, N'User Experience'), (9501, 9500, N'User Engagement'), (9502, 9500, N'User Exit'), (9503, 9502, N'To make a product look beautiful'), (9504, 9502, N'To make a product useful, usable, and enjoyable'), (9505, 9502, N'To add as many features as possible'), (9506, 9503, N'A job description for a user'), (9507, 9503, N'A real person you interviewed'), (9508, 9503, N'A fictional character representing a target user group'), (9509, 9505, N'Card sorting'), (9510, 9505, N'A/B testing'), (9511, 9505, N'Ethnographic study'), (9512, 9506, N'A sitemap'), (9513, 9506, N'A tool to visualize user attitudes and behaviors'), (9514, 9506, N'A customer journey map'), (9515, 9508, N'Qualitative'), (9516, 9508, N'Quantitative'), (9517, 9508, N'Both'), (9518, 9509, N'Users spend most of their time on other sites'), (9519, 9509, N'Users prefer your site to work the same way as all the other sites they already know'), (9520, 9509, N'Users dislike complex designs'), (9521, 9511, N'A user goal'), (9522, 9511, N'A specific problem that users experience'), (9523, 9511, N'A design opportunity'), (9524, 9513, N'How the product works'), (9525, 9513, N'The user''s emotional journey'), (9526, 9513, N'The visual layout and interactive elements of a product');

-- Department: Multimedia, Track: UI/UX Design, Course: Information Architecture & User Flows
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9527, 9515, N'The visual design of a website'), (9528, 9515, N'The practice of organizing and structuring content'), (9529, 9515, N'The flow a user takes through an app'), (9530, 9517, N'A list of all users'), (9531, 9517, N'A diagram showing the path a user takes to complete a task'), (9532, 9517, N'A site map'), (9533, 9518, N'Labeling'), (9534, 9518, N'Navigation'), (9535, 9518, N'Organization'), (9536, 9520, N'A user persona'), (9537, 9520, N'The classification and naming of content'), (9538, 9520, N'A type of navigation menu'), (9539, 9521, N'The homepage and the contact page'), (9540, 9521, N'An entry point and a final action/success state'), (9541, 9521, N'A decision diamond and a process box'), (9542, 9523, N'Sort topics into pre-defined categories'), (9543, 9523, N'Rank topics by importance'), (9544, 9523, N'Group topics into their own categories and name them'), (9545, 9524, N'A flow with many error states'), (9546, 9524, N'The path most users take'), (9547, 9524, N'The ideal path a user takes with no errors'), (9548, 9526, N'To make content look organized'), (9549, 9526, N'To help users find information and complete tasks'), (9550, 9526, N'To create a wireframe'), (9551, 9528, N'Taxonomy'), (9552, 9528, N'Navigation System'), (9553, 9528, N'User Flow');

-- Department: Multimedia, Track: UI/UX Design, Course: Wireframing & Prototyping with Figma
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9554, 9530, N'A high-fidelity visual design'), (9555, 9530, N'A low-fidelity, basic layout of a screen'), (9556, 9530, N'An interactive prototype'), (9557, 9532, N'To choose the color palette'), (9558, 9532, N'To focus on structure and functionality'), (9559, 9532, N'To test the final code'), (9560, 9533, N'The final, coded product'), (9561, 9533, N'A user persona'), (9562, 9533, N'An interactive simulation of the final product'), (9563, 9535, N'A desktop-only illustration software'), (9564, 9535, N'A video editing program'), (9565, 9535, N'A collaborative, browser-based design tool'), (9566, 9536, N'Code snippets'), (9567, 9536, N'Individual layers that cannot be changed'), (9568, 9536, N'Reusable UI elements that can be instanced'), (9569, 9538, N'Animating transitions between frames'), (9570, 9538, N'Creating responsive designs that adapt to content'), (9571, 9538, N'Organizing your files'), (9572, 9539, N'A low-fidelity wireframe'), (9573, 9539, N'A static, high-fidelity design that shows the visual style'), (9574, 9539, N'A user flow diagram'), (9575, 9541, N'To export code'), (9576, 9541, N'Ensures consistency for colors and typography'), (9577, 9541, N'To create animations'), (9578, 9543, N'A font name'), (9579, 9543, N'A color code'), (9580, 9543, N'Placeholder text used in design mockups');

-- Department: Multimedia, Track: UI/UX Design, Course: Visual Design & Design Systems
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9581, 9545, N'A final version of the app'), (9582, 9545, N'A collection of reusable components and standards'), (9583, 9545, N'A folder of design files'), (9584, 9547, N'Balance'), (9585, 9547, N'Emphasis'), (9586, 9547, N'Repetition'), (9587, 9548, N'The grid'), (9588, 9548, N'The alignment'), (9589, 9548, N'White Space / Negative Space'), (9590, 9550, N'The grid system'), (9591, 9550, N'The arrangement of elements to show their order of importance'), (9592, 9550, N'The color palette'), (9593, 9551, N'Creativity and uniqueness'), (9594, 9551, N'Faster development'), (9595, 9551, N'Consistency and efficiency'), (9596, 9553, N'Making the design more colorful'), (9597, 9553, N'Readability and directing attention'), (9598, 9553, N'Creating a flat design'), (9599, 9554, N'A set of design principles by Apple'), (9600, 9554, N'A methodology for creating design systems'), (9601, 9554, N'A way to organize files'), (9602, 9556, N'User personas'), (9603, 9556, N'UI Components (e.g., buttons, forms)'), (9604, 9556, N'Meeting notes'), (9605, 9558, N'Repetition'), (9606, 9558, N'Contrast'), (9607, 9558, N'Proximity');

-- Department: Multimedia, Track: UI/UX Design, Course: Usability Testing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9608, 9560, N'To check if the code is bug-free'), (9609, 9560, N'To see if users like the design'), (9610, 9560, N'To identify usability problems with a design'), (9611, 9562, N'A test where a facilitator guides the participant'), (9612, 9562, N'A test that is not moderated'), (9613, 9562, N'A test done in a group'), (9614, 9563, N'A survey sent after the test'), (9615, 9563, N'Asking users to verbalize their thoughts as they perform tasks'), (9616, 9563, N'A debriefing session with the user'), (9617, 9565, N'Testing two users at once'), (9618, 9565, N'Comparing two versions of a design to see which performs better'), (9619, 9565, N'A type of heuristic evaluation'), (9620, 9566, N'Success Rate'), (9621, 9566, N'Time on Task'), (9622, 9566, N'User Satisfaction'), (9623, 9568, N'A test done in person'), (9624, 9568, N'A test that is recorded'), (9625, 9568, N'A test where participants complete tasks on their own'), (9626, 9569, N'Cheaper and faster'), (9627, 9569, N'More control over the test environment'), (9628, 9569, N'Access to a wider pool of participants'), (9629, 9571, N'A test with real users'), (9630, 9571, N'A survey about usability'), (9631, 9571, N'An inspection of a UI by experts against usability principles'), (9632, 9573, N'The main usability study'), (9633, 9573, N'A practice run of a usability study'), (9634, 9573, N'A final report');

-- Department: Multimedia, Track: UI/UX Design, Course: Accessibility in Design
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9635, 9575, N'Making a website look good on all devices'), (9636, 9575, N'Designing products usable by people with disabilities'), (9637, 9575, N'How easily a user can access the website'), (9638, 9577, N'Website Compliance and Guidlines'), (9639, 9577, N'Web Content Accessibility Guidelines'), (9640, 9577, N'Web Content and Accessibility Group'), (9641, 9578, N'To provide a title for the image'), (9642, 9578, N'To improve search engine optimization'), (9643, 9578, N'To describe the image for screen reader users'), (9644, 9580, N'3:1'), (9645, 9580, N'4.5:1'), (9646, 9580, N'7:1'), (9647, 9581, N'Using HTML to style a page'), (9648, 9581, N'Writing HTML that is easy to read'), (9649, 9581, N'Using HTML elements for their correct purpose (e.g., `<nav>`, `<button>`)'), (9650, 9583, N'Only people with disabilities'), (9651, 9583, N'Everyone'), (9652, 9583, N'Only elderly users'), (9653, 9584, N'A tool for designers'), (9654, 9584, N'Software that reads out the content of a screen for visually impaired users'), (9655, 9584, N'A type of web browser'), (9656, 9586, N'The element that is currently selected'), (9657, 9586, N'The visible indicator showing which element is active for keyboard navigation'), (9658, 9586, N'The first interactive element on a page'), (9659, 9588, N'Visual'), (9660, 9588, N'Motor'), (9661, 9588, N'All of the above');

-- Department: Multimedia, Track: UI/UX Design, Course: UI/UX Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (9662, 9590, N'A final bill for a project'), (9663, 9590, N'A detailed presentation of a design project from start to finish'), (9664, 9590, N'A single mockup of a design'), (9665, 9592, N'Ideate'), (9666, 9592, N'Empathize'), (9667, 9592, N'Prototype'), (9668, 9593, N'To make the case study longer'), (9669, 9593, N'To show off writing skills'), (9670, 9593, N'To engage the reader and explain design decisions'), (9671, 9595, N'To assign blame for mistakes'), (9672, 9595, N'To reflect on what went well and what could be improved'), (9673, 9595, N'To plan the next project'), (9674, 9596, N'Only your visual design skills'), (9675, 9596, N'Your ability to work long hours'), (9676, 9596, N'Your design process and problem-solving skills'), (9677, 9598, N'To start over from scratch'), (9678, 9598, N'To hand off the design to developers'), (9679, 9598, N'To refine and improve it based on feedback and testing'), (9680, 9599, N'The problem statement'), (9681, 9599, N'The user research section'), (9682, 9599, N'Sketches, wireframes, and prototypes'), (9683, 9601, N'Using complex jargon'), (9684, 9601, N'Showing every single sketch you made'), (9685, 9601, N'Focusing on the "why" behind your design choices'), (9686, 9603, N'A meeting with stakeholders'), (9687, 9603, N'A tangible output, such as a persona or wireframe'), (9688, 9603, N'A design software');

--Track 21 Systems Administration Questions =============================================================================================================
-- Department: Unix, Track: Systems Administration, Course: Linux/Unix & Windows Server Admin
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10000, 141, N'MCQ', N'Which command lists files in a Linux directory?', N'ls'), (10001, 141, N'True/False', N'In Windows Server, `gpupdate` forces a Group Policy refresh.', N'True'), (10002, 141, N'MCQ', N'What does the `pwd` command do in Unix?', N'Prints the current working directory'), (10003, 141, N'MCQ', N'Which role must be installed to make a Windows Server a domain controller?', N'Active Directory Domain Services'), (10004, 141, N'True/False', N'The `chmod` command in Linux is used to change file ownership.', N'False'), (10005, 141, N'MCQ', N'In Linux, which directory contains system configuration files?', N'/etc'), (10006, 141, N'MCQ', N'What is the command to create a new user in Windows Server command line?', N'net user'), (10007, 141, N'True/False', N'FAT32 is the recommended file system for modern Windows Servers.', N'False'), (10008, 141, N'MCQ', N'Which command is used to display the IP address of a machine in Linux?', N'ip addr'), (10009, 141, N'True/False', N'A `sudo` command in Linux temporarily elevates privileges.', N'True'), (10010, 141, N'MCQ', N'What is the function of DNS in Windows Server?', N'Resolves domain names to IP addresses'), (10011, 141, N'MCQ', N'How do you stop a process in Linux using its PID?', N'kill [PID]'), (10012, 141, N'True/False', N'Server Core is a minimal installation option for Windows Server.', N'True'), (10013, 141, N'MCQ', N'What does the `grep` command do?', N'Searches for patterns in text'), (10014, 141, N'True/False', N'You can join a Linux machine to a Windows Active Directory domain.', N'True');

-- Department: Unix, Track: Systems Administration, Course: Networking & Active Directory
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10015, 142, N'MCQ', N'What is the primary function of Active Directory?', N'Centralized domain management'), (10016, 142, N'True/False', N'A subnet mask of 255.255.255.0 corresponds to a /24 CIDR notation.', N'True'), (10017, 142, N'MCQ', N'Which of these is NOT an FSMO role in Active Directory?', N'File Server Master'), (10018, 142, N'MCQ', N'What protocol is used for secure remote administration of network devices?', N'SSH'), (10019, 142, N'True/False', N'A forest in Active Directory can contain multiple domains.', N'True'), (10020, 142, N'MCQ', N'Which type of AD object represents a user?', N'User Account'), (10021, 142, N'True/False', N'A Hub operates at Layer 3 (Network Layer) of the OSI model.', N'False'), (10022, 142, N'MCQ', N'What is a Group Policy Object (GPO) used for?', N'To manage user and computer settings'), (10023, 142, N'True/False', N'DHCP is used to assign IP addresses manually.', N'False'), (10024, 142, N'MCQ', N'What does OU stand for in Active Directory?', N'Organizational Unit'), (10025, 142, N'MCQ', N'Which command checks network connectivity to another host?', N'ping'), (10026, 142, N'True/False', N'A trust relationship allows users in one domain to access resources in another.', N'True'), (10027, 142, N'MCQ', N'Which record type in DNS maps a hostname to an IPv4 address?', N'A'), (10028, 142, N'True/False', N'VLANs are used to create broadcast domains in a Layer 2 network.', N'True'), (10029, 142, N'MCQ', N'What is the purpose of a default gateway?', N'To route traffic to other networks');

-- Department: Unix, Track: Systems Administration, Course: Scripting (Bash/PowerShell)
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10030, 143, N'MCQ', N'In Bash, what does `#!/bin/bash` signify?', N'It defines the script to be run with bash'), (10031, 143, N'True/False', N'In PowerShell, variables are denoted with a `$` prefix.', N'True'), (10032, 143, N'MCQ', N'Which PowerShell cmdlet is used to get a list of running processes?', N'Get-Process'), (10033, 143, N'MCQ', N'How do you create a variable named `VAR` with value `10` in Bash?', N'VAR=10'), (10034, 143, N'True/False', N'A `for` loop in Bash is used for conditional execution.', N'False'), (10035, 143, N'MCQ', N'What is the file extension for a PowerShell script?', N'.ps1'), (10036, 143, N'MCQ', N'In Bash, what does `$?` contain?', N'The exit status of the last command'), (10037, 143, N'True/False', N'`Write-Host` is the primary way to output objects in PowerShell.', N'False'), (10038, 143, N'MCQ', N'What does the pipe `|` symbol do in both Bash and PowerShell?', N'Sends the output of one command to the input of another'), (10039, 143, N'True/False', N'Bash is the native scripting shell for Windows.', N'False'), (10040, 143, N'MCQ', N'Which cmdlet in PowerShell would you use to change the current directory?', N'Set-Location'), (10041, 143, N'MCQ', N'In Bash, how do you make a script executable?', N'chmod +x script.sh'), (10042, 143, N'True/False', N'PowerShell is built on the .NET framework.', N'True'), (10043, 143, N'MCQ', N'Which operator is used for string comparison in a Bash `if` statement?', N'=='), (10044, 143, N'True/False', N'You can use `Get-Help` in PowerShell to get information about a cmdlet.', N'True');

-- Department: Unix, Track: Systems Administration, Course: Virtualization & Cloud Concepts
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10045, 144, N'MCQ', N'What is a hypervisor?', N'Software that creates and runs virtual machines'), (10046, 144, N'True/False', N'SaaS stands for Software as a Service.', N'True'), (10047, 144, N'MCQ', N'Which of these is a Type 1 hypervisor?', N'VMware ESXi'), (10048, 144, N'MCQ', N'What is the key benefit of cloud computing?', N'Scalability and elasticity'), (10049, 144, N'True/False', N'A virtual machine shares its kernel with the host OS.', N'False'), (10050, 144, N'MCQ', N'Which cloud service model provides the highest level of control?', N'IaaS'), (10051, 144, N'MCQ', N'What is a snapshot of a VM?', N'A point-in-time copy of the VM state'), (10052, 144, N'True/False', N'A Public Cloud is owned and operated by the end-user organization.', N'False'), (10053, 144, N'MCQ', N'Which technology is an alternative to traditional virtualization, focusing on containerization?', N'Docker'), (10054, 144, N'True/False', N'Virtualization increases hardware costs significantly.', N'False'), (10055, 144, N'MCQ', N'What does PaaS stand for?', N'Platform as a Service'), (10056, 144, N'True/False', N'Live migration allows moving a running VM from one host to another with no downtime.', N'True'), (10057, 144, N'MCQ', N'Which of the following is a major public cloud provider?', N'Amazon Web Services (AWS)'), (10058, 144, N'MCQ', N'What is a virtual network interface card (vNIC)?', N'A virtualized network adapter for a VM'), (10059, 144, N'True/False', N'Hybrid cloud combines public and private cloud environments.', N'True');

-- Department: Unix, Track: Systems Administration, Course: System Security & Hardening
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10060, 145, N'MCQ', N'What is the principle of least privilege?', N'Giving a user only the access necessary to do their job'), (10061, 145, N'True/False', N'A firewall can only filter outgoing traffic.', N'False'), (10062, 145, N'MCQ', N'What is the purpose of system hardening?', N'To reduce the system''s attack surface'), (10063, 145, N'MCQ', N'Which of the following is a key part of hardening a server?', N'Disabling unnecessary services'), (10064, 145, N'True/False', N'Using default passwords for admin accounts is a security best practice.', N'False'), (10065, 145, N'MCQ', N'What is an IDS?', N'Intrusion Detection System'), (10066, 145, N'MCQ', N'What does patching a system accomplish?', N'Fixes security vulnerabilities'), (10067, 145, N'True/False', N'SELinux is a security module for the Windows kernel.', N'False'), (10068, 145, N'MCQ', N'Which of these is a form of multi-factor authentication (MFA)?', N'Password and a fingerprint scan'), (10069, 145, N'True/False', N'Encrypting data at rest makes it unreadable if the storage media is stolen.', N'True'), (10070, 145, N'MCQ', N'What is a "honeypot" in network security?', N'A decoy system to attract attackers'), (10071, 145, N'True/False', N'Physical security of a server room is not considered part of system security.', N'False'), (10072, 145, N'MCQ', N'What is the purpose of a security audit log?', N'To record security-relevant events'), (10073, 145, N'MCQ', N'Disabling root login over SSH is a common hardening step for which OS?', N'Linux'), (10074, 145, N'True/False', N'Anti-virus software is not necessary on servers.', N'False');

-- Department: Unix, Track: Systems Administration, Course: Backup & Disaster Recovery
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10075, 146, N'MCQ', N'What is a full backup?', N'A copy of all selected data'), (10076, 146, N'True/False', N'RPO (Recovery Point Objective) is the targeted duration of time a service can be down.', N'False'), (10077, 146, N'MCQ', N'Which backup type only copies data that has changed since the last full backup?', N'Differential'), (10078, 146, N'MCQ', N'What is the "3-2-1 rule" of backups?', N'3 copies, 2 different media, 1 offsite'), (10079, 146, N'True/False', N'Storing backups in the same physical location as the original server is ideal.', N'False'), (10080, 146, N'MCQ', N'What does a disaster recovery plan (DRP) primarily focus on?', N'Restoring IT operations after a catastrophe'), (10081, 146, N'MCQ', N'Which backup type copies data changed since the last backup of any type?', N'Incremental'), (10082, 146, N'True/False', N'A "hot site" is a disaster recovery site that is fully equipped and ready to operate.', N'True'), (10083, 146, N'MCQ', N'What is a Business Impact Analysis (BIA)?', N'Identifies critical business functions and their dependencies'), (10084, 146, N'True/False', N'You should never test your backups.', N'False'), (10085, 146, N'MCQ', N'What is a "cold site"?', N'A basic office space with no equipment'), (10086, 146, N'True/False', N'RAID is a substitute for backups.', N'False'), (10087, 146, N'MCQ', N'What does RTO stand for?', N'Recovery Time Objective'), (10088, 146, N'MCQ', N'What is data deduplication?', N'A technique to eliminate redundant copies of data'), (10089, 146, N'True/False', N'A DRP should be regularly reviewed and updated.', N'True');

-- Department: Unix, Track: Systems Administration, Course: SysAdmin Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10090, 147, N'MCQ', N'What is the first step in a system administration project?', N'Requirement gathering and planning'), (10091, 147, N'True/False', N'Documentation is an optional part of a project.', N'False'), (10092, 147, N'MCQ', N'Which of these is a common project management methodology?', N'Agile'), (10093, 147, N'MCQ', N'What is a "proof of concept" (PoC)?', N'A small-scale test to verify feasibility'), (10094, 147, N'True/False', N'A project scope defines the boundaries and deliverables.', N'True'), (10095, 147, N'MCQ', N'What is the purpose of a post-mortem or lessons learned meeting?', N'To review what went right and wrong'), (10096, 147, N'MCQ', N'When deploying a new server, what is a critical pre-launch step?', N'Testing'), (10097, 147, N'True/False', N'It is best to implement major system changes during peak business hours.', N'False'), (10098, 147, N'MCQ', N'What is a rollback plan?', N'A plan to revert to the previous state if a deployment fails'), (10099, 147, N'True/False', N'Stakeholder communication is not important for a project''s success.', N'False'), (10100, 147, N'MCQ', N'Which task involves setting up monitoring for a new system?', N'Post-deployment configuration'), (10101, 147, N'MCQ', N'What tool could be used for documenting a project plan?', N'A Gantt chart'), (10102, 147, N'True/False', N'Security considerations should be addressed only after a project is complete.', N'False'), (10103, 147, N'MCQ', N'What does it mean to "baseline" a system''s performance?', N'To measure its normal operating performance'), (10104, 147, N'True/False', N'A successful project is one that is completed on time and within budget.', N'True');

-- Department: Unix, Track: Systems Administration, Course: Linux/Unix & Windows Server Admin
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10000, 10000, N'ls'), (10001, 10000, N'list'), (10002, 10000, N'dir'), (10003, 10000, N'show'), (10004, 10002, N'Prints the current working directory'), (10005, 10002, N'Shows the system password'), (10006, 10002, N'Lists parent working directories'), (10007, 10002, N'Creates a new directory'), (10008, 10003, N'Active Directory Domain Services'), (10009, 10003, N'DNS Server'), (10010, 10003, N'File and Storage Services'), (10011, 10003, N'Web Server (IIS)'), (10012, 10005, N'/etc'), (10013, 10005, N'/bin'), (10014, 10005, N'/home'), (10015, 10005, N'/root'), (10016, 10006, N'net user'), (10017, 10006, N'new user'), (10018, 10006, N'adduser'), (10019, 10006, N'useradd'), (10020, 10008, N'ip addr'), (10021, 10008, N'ifconfig'), (10022, 10008, N'netstat'), (10023, 10008, N'All of the above'), (10024, 10010, N'Resolves domain names to IP addresses'), (10025, 10010, N'Assigns IP addresses to clients'), (10026, 10010, N'Authenticates users'), (10027, 10010, N'Stores files'), (10028, 10011, N'kill [PID]'), (10029, 10011, N'stop [PID]'), (10030, 10011, N'delete [PID]'), (10031, 10011, N'halt [PID]'), (10032, 10013, N'Searches for patterns in text'), (10033, 10013, N'Creates new files'), (10034, 10013, N'Lists user groups'), (10035, 10013, N'Formats a disk');

-- Department: Unix, Track: Systems Administration, Course: Networking & Active Directory
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10036, 10015, N'Centralized domain management'), (10037, 10015, N'File sharing and storage'), (10038, 10015, N'Web hosting'), (10039, 10015, N'Running virtual machines'), (10040, 10017, N'File Server Master'), (10041, 10017, N'Schema Master'), (10042, 10017, N'PDC Emulator'), (10043, 10017, N'RID Master'), (10044, 10018, N'SSH'), (10045, 10018, N'Telnet'), (10046, 10018, N'HTTP'), (10047, 10018, N'FTP'), (10048, 10020, N'User Account'), (10049, 10020, N'Group'), (10050, 10020, N'Computer'), (10051, 10020, N'Container'), (10052, 10022, N'To manage user and computer settings'), (10053, 10022, N'To organize users into groups'), (10054, 10022, N'To create shared folders'), (10055, 10022, N'To install software'), (10056, 10024, N'Organizational Unit'), (10057, 10024, N'Operational User'), (10058, 10024, N'Outer Unit'), (10059, 10024, N'Official Usergroup'), (10060, 10025, N'ping'), (10061, 10025, N'tracert'), (10062, 10025, N'ipconfig'), (10063, 10025, N'netstat'), (10064, 10027, N'A'), (10065, 10027, N'MX'), (10066, 10027, N'CNAME'), (10067, 10027, N'TXT'), (10068, 10029, N'To route traffic to other networks'), (10069, 10029, N'To identify the local computer'), (10070, 10029, N'To resolve domain names'), (10071, 10029, N'To store temporary internet files');

-- Department: Unix, Track: Systems Administration, Course: Scripting (Bash/PowerShell)
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10072, 10030, N'It defines the script to be run with bash'), (10073, 10030, N'It''s a comment'), (10074, 10030, N'It imports a library'), (10075, 10030, N'It sets a variable'), (10076, 10032, N'Get-Process'), (10077, 10032, N'List-Process'), (10078, 10032, N'Show-Process'), (10079, 10032, N'ps'), (10080, 10033, N'VAR=10'), (10081, 10033, N'set VAR=10'), (10082, 10033, N'$VAR=10'), (10083, 10033, N'VAR = 10'), (10084, 10035, N'.ps1'), (10085, 10035, N'.sh'), (10086, 10035, N'.bat'), (10087, 10035, N'.ps'), (10088, 10036, N'The exit status of the last command'), (10089, 10036, N'The process ID of the current script'), (10090, 10036, N'The number of arguments passed'), (10091, 10036, N'The current user''s name'), (10092, 10038, N'Sends the output of one command to the input of another'), (10093, 10038, N'Executes commands in parallel'), (10094, 10038, N'Is a logical OR operator'), (10095, 10038, N'Redirects output to a file'), (10096, 10040, N'Set-Location'), (10097, 10040, N'cd'), (10098, 10040, N'Change-Directory'), (10099, 10040, N'sl'), (10100, 10041, N'chmod +x script.sh'), (10101, 10041, N'executable script.sh'), (10102, 10041, N'run script.sh'), (10103, 10041, N'set-execute script.sh'), (10104, 10043, N'=='), (10105, 10043, N'-eq'), (10106, 10043, N'='), (10107, 10043, N'-str'), (10108, 10040, N'Both A and D are correct');

-- Department: Unix, Track: Systems Administration, Course: Virtualization & Cloud Concepts
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10109, 10045, N'Software that creates and runs virtual machines'), (10110, 10045, N'A physical server'), (10111, 10045, N'A cloud storage service'), (10112, 10045, N'A type of network switch'), (10113, 10047, N'VMware ESXi'), (10114, 10047, N'Oracle VirtualBox'), (10115, 10047, N'VMware Workstation'), (10116, 10047, N'Hyper-V on Windows 10'), (10117, 10048, N'Scalability and elasticity'), (10118, 10048, N'Higher upfront hardware cost'), (10119, 10048, N'Total control over physical hardware'), (10120, 10048, N'Reduced internet dependency'), (10121, 10050, N'IaaS'), (10122, 10050, N'PaaS'), (10123, 10050, N'SaaS'), (10124, 10050, N'FaaS'), (10125, 10051, N'A point-in-time copy of the VM state'), (10126, 10051, N'A full backup of the VM files'), (10127, 10051, N'A clone of the VM'), (10128, 10051, N'A hardware configuration file'), (10129, 10053, N'Docker'), (10130, 10053, N'Hyper-V'), (10131, 10053, N'KVM'), (10132, 10053, N'Xen'), (10133, 10055, N'Platform as a Service'), (10134, 10055, N'Processing as a Service'), (10135, 10055, N'Power as a Service'), (10136, 10055, N'Pipeline as a Service'), (10137, 10057, N'Amazon Web Services (AWS)'), (10138, 10057, N'VMware'), (10139, 10057, N'Cisco'), (10140, 10057, N'Oracle VirtualBox'), (10141, 10058, N'A virtualized network adapter for a VM'), (10142, 10058, N'A physical network card'), (10143, 10058, N'A virtual CPU'), (10144, 10058, N'A virtual storage controller');

-- Department: Unix, Track: Systems Administration, Course: System Security & Hardening
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10145, 10060, N'Giving a user only the access necessary to do their job'), (10146, 10060, N'Giving all users administrator rights'), (10147, 10060, N'Giving access based on seniority'), (10148, 10060, N'Never giving any user access'), (10149, 10062, N'To reduce the system''s attack surface'), (10150, 10062, N'To make the system run faster'), (10151, 10062, N'To install more software'), (10152, 10062, N'To increase compatibility'), (10153, 10063, N'Disabling unnecessary services'), (10154, 10063, N'Installing more applications'), (10155, 10063, N'Using a simple password'), (10156, 10063, N'Enabling all firewall ports'), (10157, 10065, N'Intrusion Detection System'), (10158, 10065, N'Internet Download Service'), (10159, 10065, N'Integrated Design System'), (10160, 10065, N'Internal Directory Service'), (10161, 10066, N'Fixes security vulnerabilities'), (10162, 10066, N'Adds new features'), (10163, 10066, N'Increases system performance'), (10164, 10066, N'Deletes old log files'), (10165, 10068, N'Password and a fingerprint scan'), (10166, 10068, N'Two different passwords'), (10167, 10068, N'A password and a security question'), (10168, 10068, N'Logging in from two devices'), (10169, 10070, N'A decoy system to attract attackers'), (10170, 10070, N'A secure data storage vault'), (10171, 10070, N'A type of firewall'), (10172, 10070, N'A system for analyzing logs'), (10173, 10072, N'To record security-relevant events'), (10174, 10072, N'To improve system performance'), (10175, 10072, N'To store user data'), (10176, 10072, N'To delete temporary files'), (10177, 10073, N'Linux'), (10178, 10073, N'Windows Server'), (10179, 10073, N'macOS Server'), (10180, 10073, N'All of the above');

-- Department: Unix, Track: Systems Administration, Course: Backup & Disaster Recovery
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10181, 10075, N'A copy of all selected data'), (10182, 10075, N'A copy of data changed since the last backup'), (10183, 10075, N'A copy of only the operating system'), (10184, 10075, N'A snapshot of a virtual machine'), (10185, 10077, N'Differential'), (10186, 10077, N'Incremental'), (10187, 10077, N'Full'), (10188, 10077, N'Snapshot'), (10189, 10078, N'3 copies, 2 different media, 1 offsite'), (10190, 10078, N'3 copies on 2 servers in 1 location'), (10191, 10078, N'1 copy on 2 tapes in 3 locations'), (10192, 10078, N'3 admins, 2 backups, 1 plan'), (10193, 10080, N'Restoring IT operations after a catastrophe'), (10194, 10080, N'Creating daily backups'), (10195, 10080, N'Preventing disasters from happening'), (10196, 10080, N'Analyzing business risks'), (10197, 10081, N'Incremental'), (10198, 10081, N'Differential'), (10199, 10081, N'Full'), (10200, 10081, N'Partial'), (10201, 10083, N'Identifies critical business functions and their dependencies'), (10202, 10083, N'A plan to recover from a disaster'), (10203, 10083, N'A test of the backup system'), (10204, 10083, N'A list of emergency contacts'), (10205, 10085, N'A basic office space with no equipment'), (10206, 10085, N'A fully equipped duplicate data center'), (10207, 10085, N'A partially equipped data center'), (10208, 10085, N'A cloud-based recovery site'), (10209, 10087, N'Recovery Time Objective'), (10210, 10087, N'Real Time Operation'), (10211, 10087, N'Recovery Test Objective'), (10212, 10087, N'Required Total Objects'), (10213, 10088, N'A technique to eliminate redundant copies of data'), (10214, 10088, N'A method of encrypting backups'), (10215, 10088, N'A way to duplicate data across multiple sites'), (10216, 10088, N'A process to verify backup integrity');

-- Department: Unix, Track: Systems Administration, Course: SysAdmin Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10217, 10090, N'Requirement gathering and planning'), (10218, 10090, N'Purchasing hardware'), (10219, 10090, N'Writing documentation'), (10220, 10090, N'System decommissioning'), (10221, 10092, N'Agile'), (10222, 10092, N'TCP/IP'), (10223, 10092, N'RAID'), (10224, 10092, N'DNS'), (10225, 10093, N'A small-scale test to verify feasibility'), (10226, 10093, N'The final, finished product'), (10227, 10093, N'A detailed project plan'), (10228, 10093, N'A backup of the system'), (10229, 10095, N'To review what went right and wrong'), (10230, 10095, N'To assign blame for failures'), (10231, 10095, N'To plan the next project'), (10232, 10095, N'To present the project to stakeholders'), (10233, 10096, N'Testing'), (10234, 10096, N'User training'), (10235, 10096, N'Ordering pizza'), (10236, 10096, N'Deleting the old server'), (10237, 10098, N'A plan to revert to the previous state if a deployment fails'), (10238, 10098, N'A plan to back up the new system'), (10239, 10098, N'A plan to roll out the project to more users'), (10240, 10098, N'A list of project milestones'), (10241, 10100, N'Post-deployment configuration'), (10242, 10100, N'Initial planning'), (10243, 10100, N'Requirements analysis'), (10244, 10100, N'Hardware procurement'), (10245, 10101, N'A Gantt chart'), (10246, 10101, N'A firewall'), (10247, 10101, N'A network diagram'), (10248, 10101, N'An Active Directory user account'), (10249, 10103, N'To measure its normal operating performance'), (10250, 10103, N'To harden the system security'), (10251, 10103, N'To back up the system configuration'), (10252, 10103, N'To delete all logs and start fresh');


--Track 22 Cybersecurity Associate Questions =============================================================================================================

-- Department: Network, Track: Cybersecurity Associate, Course: Cybersecurity & Networking Intro
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10500, 148, N'MCQ', N'What is the CIA triad in cybersecurity?', N'Confidentiality, Integrity, Availability'), (10501, 148, N'True/False', N'A router operates at Layer 2 (Data Link) of the OSI model.', N'False'), (10502, 148, N'MCQ', N'Which protocol is commonly used for secure web browsing?', N'HTTPS'), (10503, 148, N'MCQ', N'What is the function of a firewall?', N'To monitor and control network traffic'), (10504, 148, N'True/False', N'An IP address is a unique identifier for a device on a network.', N'True'), (10505, 148, N'MCQ', N'What does DNS stand for?', N'Domain Name System'), (10506, 148, N'True/False', N'MAC addresses are used for routing between different networks.', N'False'), (10507, 148, N'MCQ', N'Which of these is a private IP address range?', N'192.168.0.0/16'), (10508, 148, N'True/False', N'Authentication is the process of verifying a user''s identity.', N'True'), (10509, 148, N'MCQ', N'What is the main purpose of an Intrusion Detection System (IDS)?', N'To detect potential security breaches'), (10510, 148, N'MCQ', N'Which OSI model layer is responsible for data encryption?', N'Presentation Layer'), (10511, 148, N'True/False', N'A switch is more intelligent than a hub.', N'True'), (10512, 148, N'MCQ', N'The term "risk" in cybersecurity is a combination of a vulnerability and a _____.', N'Threat'), (10513, 148, N'True/False', N'Non-repudiation ensures that a user cannot deny having sent a message.', N'True'), (10514, 148, N'MCQ', N'What type of cable is typically used for modern Ethernet networks?', N'Twisted-Pair');

-- Department: Network, Track: Cybersecurity Associate, Course: Threats, Attacks & Vulnerabilities
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10515, 149, N'MCQ', N'What type of attack involves overwhelming a server with traffic?', N'DDoS'), (10516, 149, N'True/False', N'A virus requires human assistance to spread to other computers.', N'True'), (10517, 149, N'MCQ', N'What is phishing?', N'An attempt to acquire sensitive information by masquerading as a trustworthy entity'), (10518, 149, N'MCQ', N'Which of these is a form of malware?', N'Ransomware'), (10519, 149, N'True/False', N'A zero-day vulnerability is one that is publicly known and patched.', N'False'), (10520, 149, N'MCQ', N'A "Man-in-the-Middle" attack involves what?', N'Intercepting communication between two parties'), (10521, 149, N'True/False', N'A security vulnerability is a weakness that can be exploited.', N'True'), (10522, 149, N'MCQ', N'What is the goal of a SQL injection attack?', N'To manipulate a back-end database'), (10523, 149, N'True/False', N'Social engineering relies on technical exploits, not human psychology.', N'False'), (10524, 149, N'MCQ', N'What is a botnet?', N'A network of compromised computers'), (10525, 149, N'MCQ', N'Which attack exploits web application vulnerabilities by inserting malicious scripts?', N'Cross-Site Scripting (XSS)'), (10526, 149, N'True/False', N'A worm is a standalone malware that replicates itself to spread.', N'True'), (10527, 149, N'MCQ', N'A weakness in a system''s design or implementation is called a what?', N'Vulnerability'), (10528, 149, N'True/False', N'Brute-force attacks are used to discover weak encryption keys.', N'False'), (10529, 149, N'MCQ', N'What is "tailgating" in the context of physical security?', N'Following an authorized person into a restricted area');

-- Department: Network, Track: Cybersecurity Associate, Course: Ethical Hacking & Pen Testing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10530, 150, N'MCQ', N'What is the first phase of a penetration test?', N'Planning and Reconnaissance'), (10531, 150, N'True/False', N'A white-box penetration test means the tester has no prior knowledge of the system.', N'False'), (10532, 150, N'MCQ', N'Which tool is commonly used for network scanning and port discovery?', N'Nmap'), (10533, 150, N'MCQ', N'What is the purpose of "privilege escalation" in an attack?', N'To gain higher-level access'), (10534, 150, N'True/False', N'Ethical hacking is performed without permission from the target organization.', N'False'), (10535, 150, N'MCQ', N'What is the "Rules of Engagement" document in a pen test?', N'Defines the scope and limits of the test'), (10536, 150, N'True/False', N'A vulnerability scanner like Nessus can automatically exploit vulnerabilities.', N'False'), (10537, 150, N'MCQ', N'Which framework provides a comprehensive collection of penetration testing tools?', N'Metasploit'), (10538, 150, N'True/False', N'The goal of ethical hacking is to improve the security of a system.', N'True'), (10539, 150, N'MCQ', N'The process of gathering information about a target is called what?', N'Reconnaissance'), (10540, 150, N'MCQ', N'What does a "pivoting" attack involve?', N'Using a compromised system to attack other systems on the same network'), (10541, 150, N'True/False', N'A black-box test simulates an attack from a malicious outsider.', N'True'), (10542, 150, N'MCQ', N'What is the final phase of a penetration test?', N'Reporting'), (10543, 150, N'True/False', N'Aircrack-ng is a tool used for attacking web applications.', N'False'), (10544, 150, N'MCQ', N'Which tool is a popular web application proxy for security testing?', N'Burp Suite');

-- Department: Network, Track: Cybersecurity Associate, Course: SIEM & Network Security
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10545, 151, N'MCQ', N'What does SIEM stand for?', N'Security Information and Event Management'), (10546, 151, N'True/False', N'A honeypot is a real production system used to trap attackers.', N'False'), (10547, 151, N'MCQ', N'What is the primary function of a SIEM system?', N'To aggregate and analyze log data'), (10548, 151, N'MCQ', N'Which technology is used to create a secure, encrypted connection over a public network?', N'VPN'), (10549, 151, N'True/False', N'Network Access Control (NAC) can restrict devices from joining a network.', N'True'), (10550, 151, N'MCQ', N'What is "log correlation" in a SIEM?', N'Linking related events from different sources'), (10551, 151, N'True/False', N'An Intrusion Prevention System (IPS) can actively block malicious traffic.', N'True'), (10552, 151, N'MCQ', N'What is a Demilitarized Zone (DMZ) in networking?', N'A perimeter network that protects an internal LAN'), (10553, 151, N'True/False', N'Data Loss Prevention (DLP) systems only monitor data in transit.', N'False'), (10554, 151, N'MCQ', N'What is the purpose of a proxy server?', N'To act as an intermediary for requests from clients'), (10555, 151, N'MCQ', N'Which of these is a key benefit of using a SIEM?', N'Centralized security monitoring'), (10556, 151, N'True/False', N'A stateful firewall only inspects packet headers.', N'False'), (10557, 151, N'MCQ', N'What is a baseline in security monitoring?', N'A standard for normal network activity'), (10558, 151, N'True/False', N'All alerts from a SIEM system indicate a confirmed security breach.', N'False'), (10559, 151, N'MCQ', N'A Unified Threat Management (UTM) appliance typically includes which function?', N'All of the above');

-- Department: Network, Track: Cybersecurity Associate, Course: Digital Forensics & Incident Response
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10560, 152, N'MCQ', N'What is the "chain of custody" in digital forensics?', N'A log of the handling and control of evidence'), (10561, 152, N'True/False', N'The first step in incident response is always to shut down the affected system.', N'False'), (10562, 152, N'MCQ', N'What is the main goal of digital forensics?', N'To recover and investigate material found in digital devices'), (10563, 152, N'MCQ', N'Which phase of incident response involves learning from an incident?', N'Post-Incident Activity (Lessons Learned)'), (10564, 152, N'True/False', N'Volatile data, such as RAM content, is lost when a computer is turned off.', N'True'), (10565, 152, N'MCQ', N'What is a "write blocker" used for?', N'To prevent modification of data on a drive during acquisition'), (10566, 152, N'True/False', N'Steganography is the practice of encrypting data.', N'False'), (10567, 152, N'MCQ', N'The process of creating a bit-for-bit copy of a storage device is called what?', N'Imaging'), (10568, 152, N'True/False', N'An Incident Response Plan (IRP) should be created after an incident occurs.', N'False'), (10569, 152, N'MCQ', N'What is "slack space" on a hard drive?', N'Unused space at the end of a file cluster'), (10570, 152, N'MCQ', N'Which phase of incident response focuses on stopping the attack?', N'Containment'), (10571, 152, N'True/False', N'A file''s hash value (e.g., MD5, SHA-256) is used to verify its integrity.', N'True'), (10572, 152, N'MCQ', N'Where would an investigator look for a log of websites a user has visited?', N'Browser history'), (10573, 152, N'True/False', N'It is impossible to recover deleted files from a hard drive.', N'False'), (10574, 152, N'MCQ', N'What is the "order of volatility" in evidence collection?', N'Collecting data from most volatile to least volatile');

-- Department: Network, Track: Cybersecurity Associate, Course: GRC & Application Security
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10575, 153, N'MCQ', N'In GRC, what does the "G" stand for?', N'Governance'), (10576, 153, N'True/False', N'A security policy is a high-level statement of intent from management.', N'True'), (10577, 153, N'MCQ', N'Which of these is a well-known security standard?', N'ISO/IEC 27001'), (10578, 153, N'MCQ', N'What is the purpose of input validation in an application?', N'To prevent malformed data from entering a system'), (10579, 153, N'True/False', N'Compliance is the act of adhering to laws, regulations, and standards.', N'True'), (10580, 153, N'MCQ', N'What does OWASP stand for?', N'Open Web Application Security Project'), (10581, 153, N'True/False', N'Hardcoding credentials into application source code is a secure practice.', N'False'), (10582, 153, N'MCQ', N'What is the "principle of least privilege" in application security?', N'Granting an application only the permissions it needs to function'), (10583, 153, N'True/False', N'A risk assessment identifies and analyzes potential risks.', N'True'), (10584, 153, N'MCQ', N'What is "fuzzing" in application security testing?', N'Providing invalid or random data to a program''s inputs'), (10585, 153, N'MCQ', N'Which GRC component involves measuring and reporting on security controls?', N'Compliance'), (10586, 153, N'True/False', N'GDPR is a regulation related to environmental protection.', N'False'), (10587, 153, N'MCQ', N'What is the purpose of a code review?', N'To find security flaws in the source code'), (10588, 153, N'True/False', N'Risk acceptance means deciding to not take any action against a specific risk.', N'True'), (10589, 153, N'MCQ', N'What is the primary risk of not performing proper error handling?', N'Leaking sensitive system information');

-- Department: Network, Track: Cybersecurity Associate, Course: Cybersecurity Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (10590, 154, N'MCQ', N'When responding to a data breach, what is a primary initial goal?', N'Contain the breach to prevent further damage'), (10591, 154, N'True/False', N'A comprehensive security program should rely solely on technology, not people.', N'False'), (10592, 154, N'MCQ', N'What is a key component of a successful security awareness program?', N'Regular training and phishing simulations'), (10593, 154, N'MCQ', N'A "defense in depth" strategy involves what?', N'Implementing multiple layers of security controls'), (10594, 154, N'True/False', N'A Business Continuity Plan (BCP) is the same as a Disaster Recovery Plan (DRP).', N'False'), (10595, 154, N'MCQ', N'In a project, what is the purpose of threat modeling?', N'To identify and mitigate potential security threats early'), (10596, 154, N'True/False', N'Once a security control is implemented, it does not need to be reviewed again.', N'False'), (10597, 154, N'MCQ', N'You discover a compromised server. What forensic principle should you follow?', N'Preserve evidence in its original state'), (10598, 154, N'True/False', N'A good password policy should allow users to reuse old passwords.', N'False'), (10599, 154, N'MCQ', N'How should an organization handle a newly discovered zero-day vulnerability in its software?', N'Apply vendor patches as soon as they are available'), (10600, 154, N'MCQ', N'What is the primary reason for classifying data?', N'To determine the level of protection it requires'), (10601, 154, N'True/False', N'Communicating a security incident to stakeholders is an important step in IR.', N'True'), (10602, 154, N'MCQ', N'When designing a secure network, which principle is most critical?', N'Least privilege'), (10603, 154, N'True/False', N'It is acceptable to conduct a penetration test on a third-party cloud service without their permission.', N'False'), (10604, 154, N'MCQ', N'What is the final output of a comprehensive risk assessment?', N'A prioritized list of risks for mitigation');

-- Department: Network, Track: Cybersecurity Associate, Course: Cybersecurity & Networking Intro
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10500, 10500, N'Confidentiality, Integrity, Availability'), (10501, 10500, N'Control, Inspect, Authorize'), (10502, 10500, N'Cybersecurity, Intelligence, Action'), (10503, 10500, N'Confidentiality, Identity, Access'), (10504, 10502, N'HTTPS'), (10505, 10502, N'FTP'), (10506, 10502, N'Telnet'), (10507, 10502, N'HTTP'), (10508, 10503, N'To monitor and control network traffic'), (10509, 10503, N'To speed up network connections'), (10510, 10503, N'To assign IP addresses'), (10511, 10503, N'To store website data'), (10512, 10505, N'Domain Name System'), (10513, 10505, N'Dynamic Network Service'), (10514, 10505, N'Data Naming Standard'), (10515, 10505, N'Domain Naming Service'), (10516, 10507, N'192.168.0.0/16'), (10517, 10507, N'8.8.8.8'), (10518, 10507, N'208.67.222.222'), (10519, 10507, N'1.1.1.1'), (10520, 10509, N'To detect potential security breaches'), (10521, 10509, N'To prevent all network attacks'), (10522, 10509, N'To install software updates'), (10523, 10509, N'To encrypt all network traffic'), (10524, 10510, N'Presentation Layer'), (10525, 10510, N'Transport Layer'), (10526, 10510, N'Network Layer'), (10527, 10510, N'Physical Layer'), (10528, 10512, N'Threat'), (10529, 10512, N'Asset'), (10530, 10512, N'Control'), (10531, 10512, N'Policy'), (10532, 10514, N'Twisted-Pair'), (10533, 10514, N'Coaxial'), (10534, 10514, N'Fiber-Optic'), (10535, 10514, N'Serial');

-- Department: Network, Track: Cybersecurity Associate, Course: Threats, Attacks & Vulnerabilities
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10536, 10515, N'DDoS'), (10537, 10515, N'Phishing'), (10538, 10515, N'SQL Injection'), (10539, 10515, N'Malware'), (10540, 10517, N'An attempt to acquire sensitive information by masquerading as a trustworthy entity'), (10541, 10517, N'A type of self-replicating malware'), (10542, 10517, N'An attack that overwhelms a system with traffic'), (10543, 10517, N'The act of physically stealing a computer'), (10544, 10518, N'Ransomware'), (10545, 10518, N'Firewall'), (10546, 10518, N'VPN'), (10547, 10518, N'Router'), (10548, 10520, N'Intercepting communication between two parties'), (10549, 10520, N'Guessing a user''s password'), (10550, 10520, N'Deleting files from a server'), (10551, 10520, N'Sending a large volume of spam email'), (10552, 10522, N'To manipulate a back-end database'), (10553, 10522, N'To gain control of a user''s web browser'), (10554, 10522, N'To shut down a web server'), (10555, 10522, N'To steal a user''s session cookie'), (10556, 10524, N'A network of compromised computers'), (10557, 10524, N'A type of antivirus software'), (10558, 10524, N'A secure web gateway'), (10559, 10524, N'A team of security analysts'), (10560, 10525, N'Cross-Site Scripting (XSS)'), (10561, 10525, N'Denial-of-Service (DoS)'), (10562, 10525, N'Man-in-the-Middle (MITM)'), (10563, 10525, N'Phishing'), (10564, 10527, N'Vulnerability'), (10565, 10527, N'Threat'), (10566, 10527, N'Risk'), (10567, 10527, N'Exploit'), (10568, 10529, N'Following an authorized person into a restricted area'), (10569, 10529, N'Searching through a company''s trash'), (10570, 10529, N'Installing a keylogger on a public computer'), (10571, 10529, N'Disguising oneself as a repair person');

-- Department: Network, Track: Cybersecurity Associate, Course: Ethical Hacking & Pen Testing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10572, 10530, N'Planning and Reconnaissance'), (10573, 10530, N'Scanning'), (10574, 10530, N'Gaining Access'), (10575, 10530, N'Reporting'), (10576, 10532, N'Nmap'), (10577, 10532, N'Wireshark'), (10578, 10532, N'Metasploit'), (10579, 10532, N'John the Ripper'), (10580, 10533, N'To gain higher-level access'), (10581, 10533, N'To erase logs and traces'), (10582, 10533, N'To discover open ports'), (10583, 10533, N'To install a backdoor'), (10584, 10535, N'Defines the scope and limits of the test'), (10585, 10535, N'Is the final report of findings'), (10586, 10535, N'Is a list of hacking tools to be used'), (10587, 10535, N'Is a contract for payment'), (10588, 10537, N'Metasploit'), (10589, 10537, N'Nessus'), (10590, 10537, N'Autopsy'), (10591, 10537, N'Snort'), (10592, 10539, N'Reconnaissance'), (10593, 10539, N'Exploitation'), (10594, 10539, N'Covering tracks'), (10595, 10539, N'Pivoting'), (10596, 10540, N'Using a compromised system to attack other systems on the same network'), (10597, 10540, N'Escalating privileges from a user to an administrator'), (10598, 10540, N'Trying multiple exploits against a single vulnerability'), (10599, 10540, N'Analyzing network traffic for passwords'), (10600, 10542, N'Reporting'), (10601, 10542, N'Maintaining Access'), (10602, 10542, N'Scanning'), (10603, 10542, N'Reconnaissance'), (10604, 10544, N'Burp Suite'), (10605, 10544, N'Nmap'), (10606, 10544, N'Aircrack-ng'), (10607, 10544, N'Hydra');

-- Department: Network, Track: Cybersecurity Associate, Course: SIEM & Network Security
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10608, 10545, N'Security Information and Event Management'), (10609, 10545, N'System Information and Enterprise Management'), (10610, 10545, N'Secure Internet and Email Monitoring'), (10611, 10545, N'System Incident and Event Monitoring'), (10612, 10547, N'To aggregate and analyze log data'), (10613, 10547, N'To perform automated penetration tests'), (10614, 10547, N'To manage user access controls'), (10615, 10547, N'To deploy software patches'), (10616, 10548, N'VPN'), (10617, 10548, N'VLAN'), (10618, 10548, N'NAT'), (10619, 10548, N'DNS'), (10620, 10550, N'Linking related events from different sources'), (10621, 10550, N'Deleting unimportant log entries'), (10622, 10550, N'Backing up log data to the cloud'), (10623, 10550, N'Encrypting all log files'), (10624, 10552, N'A perimeter network that protects an internal LAN'), (10625, 10552, N'A highly secured internal network zone'), (10626, 10552, N'A zone where all traffic is blocked'), (10627, 10552, N'A cloud-based virtual network'), (10628, 10554, N'To act as an intermediary for requests from clients'), (10629, 10554, N'To authenticate users to the network'), (10630, 10554, N'To store and manage encryption keys'), (10631, 10554, N'To directly connect two separate networks'), (10632, 10555, N'Centralized security monitoring'), (10633, 10555, N'Guaranteed prevention of all attacks'), (10634, 10555, N'Automatic patching of vulnerabilities'), (10635, 10555, N'Increased network speed'), (10636, 10557, N'A standard for normal network activity'), (10637, 10557, N'The minimum level of security required'), (10638, 10557, N'A list of all known threats'), (10639, 10557, N'The physical layout of the network'), (10640, 10559, N'All of the above'), (10641, 10559, N'Firewall'), (10642, 10559, N'Antivirus'), (10643, 10559, N'VPN');

-- Department: Network, Track: Cybersecurity Associate, Course: Digital Forensics & Incident Response
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10644, 10560, N'A log of the handling and control of evidence'), (10645, 10560, N'The physical security of the server room'), (10646, 10560, N'The steps to respond to an incident'), (10647, 10560, N'A list of approved forensic tools'), (10648, 10562, N'To recover and investigate material found in digital devices'), (10649, 10562, N'To punish the perpetrators of cybercrime'), (10650, 10562, N'To prevent future security incidents'), (10651, 10562, N'To restore systems to their original state'), (10652, 10563, N'Post-Incident Activity (Lessons Learned)'), (10653, 10563, N'Preparation'), (10654, 10563, N'Identification'), (10655, 10563, N'Containment'), (10656, 10565, N'To prevent modification of data on a drive during acquisition'), (10657, 10565, N'To unlock encrypted files'), (10658, 10565, N'To bypass password protection'), (10659, 10565, N'To speed up the data imaging process'), (10660, 10567, N'Imaging'), (10661, 10567, N'Hashing'), (10662, 10567, N'Cloning'), (10663, 10567, N'Wiping'), (10664, 10569, N'Unused space at the end of a file cluster'), (10665, 10569, N'A hidden partition on the drive'), (10666, 10569, N'Temporary internet files'), (10667, 10569, N'Space containing deleted files'), (10668, 10570, N'Containment'), (10669, 10570, N'Eradication'), (10670, 10570, N'Recovery'), (10671, 10570, N'Identification'), (10672, 10572, N'Browser history'), (10673, 10572, N'Windows Registry'), (10674, 10572, N'Event Logs'), (10675, 10572, N'Prefetch files'), (10676, 10574, N'Collecting data from most volatile to least volatile'), (10677, 10574, N'Collecting data from largest files to smallest'), (10678, 10574, N'Collecting data from the oldest files to the newest'), (10679, 10574, N'Collecting data based on file type');

-- Department: Network, Track: Cybersecurity Associate, Course: GRC & Application Security
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10680, 10575, N'Governance'), (10681, 10575, N'Guidance'), (10682, 10575, N'General'), (10683, 10575, N'Global'), (10684, 10577, N'ISO/IEC 27001'), (10685, 10577, N'ITIL'), (10686, 10577, N'TCP/IP'), (10687, 10577, N'Scrum'), (10688, 10578, N'To prevent malformed data from entering a system'), (10689, 10578, N'To check if a user is authorized'), (10690, 10578, N'To encrypt data before storing it'), (10691, 10578, N'To log application errors'), (10692, 10580, N'Open Web Application Security Project'), (10693, 10580, N'Open Web and Software Protection'), (10694, 10580, N'Online Web Application Safety Protocol'), (10695, 10580, N'Official Web Application Security Program'), (10696, 10582, N'Granting an application only the permissions it needs to function'), (10697, 10582, N'Ensuring the application is available to all users'), (10698, 10582, N'Allowing the application to run with administrator rights'), (10699, 10582, N'Logging every action the application takes'), (10700, 10584, N'Providing invalid or random data to a program''s inputs'), (10701, 10584, N'Manually reviewing source code for flaws'), (10702, 10584, N'Analyzing the flow of data through an application'), (10703, 10584, N'Testing an application from an end-user perspective'), (10704, 10585, N'Compliance'), (10705, 10585, N'Governance'), (10706, 10585, N'Risk Management'), (10707, 10585, N'None of the above'), (10708, 10587, N'To find security flaws in the source code'), (10709, 10587, N'To test the application''s performance'), (10710, 10587, N'To confirm the application meets user requirements'), (10711, 10587, N'To document the application''s features'), (10712, 10589, N'Leaking sensitive system information'), (10713, 10589, N'Causing the application to use more memory'), (10714, 10589, N'Preventing users from logging in'), (10715, 10589, N'Slowing down database queries');

-- Department: Network, Track: Cybersecurity Associate, Course: Cybersecurity Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (10716, 10590, N'Contain the breach to prevent further damage'), (10717, 10590, N'Notify the media immediately'), (10718, 10590, N'Identify the attacker'), (10719, 10590, N'Delete all logs'), (10720, 10592, N'Regular training and phishing simulations'), (10721, 10592, N'A long and complex security policy document'), (10722, 10592, N'Purchasing the most expensive firewall'), (10723, 10592, N'Hiring more security staff'), (10724, 10593, N'Implementing multiple layers of security controls'), (10725, 10593, N'Focusing all resources on protecting the network perimeter'), (10726, 10593, N'Having a single, very strong password for all systems'), (10727, 10593, N'Encrypting every file on the network'), (10728, 10595, N'To identify and mitigate potential security threats early'), (10729, 10595, N'To create a model of network traffic flow'), (10730, 10595, N'To decide which programming language to use'), (10731, 10595, N'To estimate the total cost of the project'), (10732, 10597, N'Preserve evidence in its original state'), (10733, 10597, N'Immediately patch and reboot the server'), (10734, 10597, N'Run a full antivirus scan'), (10735, 10597, N'Disconnect the server from the network'), (10736, 10599, N'Apply vendor patches as soon as they are available'), (10737, 10599, N'Shut down the affected systems indefinitely'), (10738, 10599, N'Wait to see if an attack occurs'), (10739, 10599, N'Attempt to write its own patch'), (10740, 10600, N'To determine the level of protection it requires'), (10741, 10600, N'To know how much storage space it needs'), (10742, 10600, N'To decide who created the data'), (10743, 10600, N'To make it easier to search for'), (10744, 10602, N'Least privilege'), (10745, 10602, N'Default allow'), (10746, 10602, N'Maximum performance'), (10747, 10602, N'Ease of use'), (10748, 10604, N'A prioritized list of risks for mitigation'), (10749, 10604, N'A complete list of all system assets'), (10750, 10604, N'A guarantee that no incidents will occur'), (10751, 10604, N'A new security policy document');


--Track 23 Data Visualization Questions =========================================================================================================

-- Department: E-Business, Track: Data Visualization, Course: Data Visualization & Storytelling
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11000, 155, N'MCQ', N'Which chart is best for showing parts of a whole?', N'Pie Chart'), (11001, 155, N'True/False', N'Color is a pre-attentive attribute that can draw a user''s attention.', N'True'), (11002, 155, N'MCQ', N'What is the main goal of data storytelling?', N'To communicate insights effectively'), (11003, 155, N'MCQ', N'Which chart type is ideal for showing a relationship between two variables?', N'Scatter Plot'), (11004, 155, N'True/False', N'Adding a lot of "chart junk" helps clarify the message.', N'False'), (11005, 155, N'MCQ', N'The Z-pattern describes how users typically do what?', N'Scan a web page or dashboard'), (11006, 155, N'True/False', N'A good data story should have a clear beginning, middle, and end.', N'True'), (11007, 155, N'MCQ', N'Which Gestalt principle involves grouping similar-looking objects?', N'Similarity'), (11008, 155, N'MCQ', N'What should you use to compare values across different categories?', N'Bar Chart'), (11009, 155, N'True/False', N'A line chart is best used for showing data over time.', N'True'), (11010, 155, N'MCQ', N'"Decluttering" a visualization means doing what?', N'Removing unnecessary elements'), (11011, 155, N'True/False', N'Using a 3D bar chart is a recommended best practice.', N'False'), (11012, 155, N'MCQ', N'What does "context" mean in data storytelling?', N'The background information needed to understand the data'), (11013, 155, N'True/False', N'The choice of color can affect the emotional tone of a visualization.', N'True'), (11014, 155, N'MCQ', N'What is a key principle of effective visualization?', N'Show the data, don''t hide it');

-- Department: E-Business, Track: Data Visualization, Course: Tableau for Data Viz
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11015, 156, N'MCQ', N'In Tableau, what color are "Dimension" pills?', N'Blue'), (11016, 156, N'True/False', N'A .twbx file includes the data source within the file.', N'True'), (11017, 156, N'MCQ', N'Which card is used to change the chart type (e.g., to a bar or line chart)?', N'Marks Card'), (11018, 156, N'MCQ', N'What is a "Measure" in Tableau?', N'A numeric, quantifiable field'), (11019, 156, N'True/False', N'You can combine multiple worksheets into a single Dashboard.', N'True'), (11020, 156, N'MCQ', N'What feature allows you to create new fields from existing data?', N'Calculated Fields'), (11021, 156, N'True/False', N'A live connection to a data source updates automatically in Tableau.', N'True'), (11022, 156, N'MCQ', N'What is the difference between a Dimension and a Measure?', N'Dimensions segment data, Measures are aggregated'), (11023, 156, N'MCQ', N'Where do you drag fields to create the rows and columns of your visualization?', N'Shelves'), (11024, 156, N'True/False', N'Tableau can only connect to Excel spreadsheets.', N'False'), (11025, 156, N'MCQ', N'What does an LOD expression stand for?', N'Level of Detail'), (11026, 156, N'True/False', N'A Tableau "Story" is a sequence of visualizations that work together.', N'True'), (11027, 156, N'MCQ', N'How do you filter data in a Tableau worksheet?', N'Drag a dimension or measure to the Filters shelf'), (11028, 156, N'True/False', N'Once a dashboard is published, it cannot be changed.', N'False'), (11029, 156, N'MCQ', N'What is the purpose of the "Show Me" panel?', N'To suggest appropriate chart types');

-- Department: E-Business, Track: Data Visualization, Course: Power BI for Data Viz
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11030, 157, N'MCQ', N'What language is used for creating calculations in Power BI?', N'DAX'), (11031, 157, N'True/False', N'Power Query is used for data transformation and cleaning.', N'True'), (11032, 157, N'MCQ', N'What are the three main components of Power BI Desktop?', N'Report, Data, and Model views'), (11033, 157, N'MCQ', N'A "Measure" in Power BI is created using what?', N'A DAX formula'), (11034, 157, N'True/False', N'You must publish a report to Power BI Service to share it with others.', N'True'), (11035, 157, N'MCQ', N'What is the purpose of creating relationships in the Model view?', N'To link tables together for filtering'), (11036, 157, N'True/False', N'A calculated column computes a value for each row in a table.', N'True'), (11037, 157, N'MCQ', N'Which component is used for ETL (Extract, Transform, Load) activities?', N'Power Query Editor'), (11038, 157, N'MCQ', N'What is a Power BI "visual"?', N'A chart or graph on a report'), (11039, 157, N'True/False', N'Power BI can only connect to Microsoft data sources like SQL Server.', N'False'), (11040, 157, N'MCQ', N'What is the primary difference between a measure and a calculated column?', N'Measures are calculated on the fly, columns are pre-calculated'), (11041, 157, N'True/False', N'A Slicer is a visual used for filtering other visuals on the page.', N'True'), (11042, 157, N'MCQ', N'Where can you download custom visuals for Power BI?', N'AppSource'), (11043, 157, N'True/False', N'DAX stands for Data Analysis eXpressions.', N'True'), (11044, 157, N'MCQ', N'What is a "Dashboard" in Power BI Service?', N'A single page canvas of visuals from one or more reports');

-- Department: E-Business, Track: Data Visualization, Course: SQL for Data Analysts
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11045, 158, N'MCQ', N'Which keyword is used to retrieve data from a database?', N'SELECT'), (11046, 158, N'True/False', N'The `WHERE` clause is used to filter records.', N'True'), (11047, 158, N'MCQ', N'Which `JOIN` returns all records from the left table, and the matched records from the right table?', N'LEFT JOIN'), (11048, 158, N'MCQ', N'Which function returns the total number of rows?', N'COUNT()'), (11049, 158, N'True/False', N'`GROUP BY` is used with aggregate functions to group rows.', N'True'), (11050, 158, N'MCQ', N'Which statement is used to combine the result-set of two or more `SELECT` statements?', N'UNION'), (11051, 158, N'True/False', N'A primary key can contain NULL values.', N'False'), (11052, 158, N'MCQ', N'How do you sort the results of a query in descending order?', N'ORDER BY ... DESC'), (11053, 158, N'MCQ', N'Which `JOIN` returns records that have matching values in both tables?', N'INNER JOIN'), (11054, 158, N'True/False', N'The `SELECT DISTINCT` statement is used to return only unique values.', N'True'), (11055, 158, N'MCQ', N'What does the `LIKE` operator do?', N'Searches for a specified pattern in a column'), (11056, 158, N'True/False', N'A subquery is a query nested inside another query.', N'True'), (11057, 158, N'MCQ', N'Which clause is used to filter groups based on an aggregate function?', N'HAVING'), (11058, 158, N'True/False', N'SQL is not case-sensitive for keywords, but is for table/column names in some systems.', N'True'), (11059, 158, N'MCQ', N'The `AS` keyword is used to create an ___ for a column or table.', N'Alias');

-- Department: E-Business, Track: Data Visualization, Course: Interactive Viz with D3.js
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11060, 159, N'MCQ', N'What does D3 stand for?', N'Data-Driven Documents'), (11061, 159, N'True/False', N'D3.js directly manipulates the Document Object Model (DOM).', N'True'), (11062, 159, N'MCQ', N'What technology does D3 primarily use to draw shapes?', N'SVG'), (11063, 159, N'MCQ', N'Which D3 method is used to bind data to DOM elements?', N'.data()'), (11064, 159, N'True/False', N'D3 is a charting library with pre-built charts like Chart.js.', N'False'), (11065, 159, N'MCQ', N'What is the purpose of a D3 "scale"?', N'To map a data domain to a visual range'), (11066, 159, N'True/False', N'D3 selections are immutable; you cannot change them after creation.', N'False'), (11067, 159, N'MCQ', N'The "enter" selection in D3 refers to what?', N'Incoming data elements that need new DOM elements'), (11068, 159, N'MCQ', N'How would you select all `<p>` elements on a page with D3?', N'd3.selectAll("p")'), (11069, 159, N'True/False', N'D3 requires a web server to run, it cannot be run from local files.', N'False'), (11070, 159, N'MCQ', N'What is a D3 "transition" used for?', N'To animate changes over time'), (11071, 159, N'True/False', N'You must use JavaScript to work with D3.js.', N'True'), (11072, 159, N'MCQ', N'What does the "exit" selection represent?', N'DOM elements that are no longer needed'), (11073, 159, N'True/False', N'D3 can load data from external files like CSV and JSON.', N'True'), (11074, 159, N'MCQ', N'What do D3 axes generators create?', N'Visual representations of scales with ticks and labels');

-- Department: E-Business, Track: Data Visualization, Course: UI/UX for Dashboards
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11075, 160, N'MCQ', N'What is the most important consideration in dashboard design?', N'The audience and their needs'), (11076, 160, N'True/False', N'A good dashboard should answer key questions at a glance.', N'True'), (11077, 160, N'MCQ', N'Which UX principle suggests placing the most important info in the top-left?', N'The F-Pattern or Z-Pattern'), (11078, 160, N'MCQ', N'What does the "CRAP" design principle stand for?', N'Contrast, Repetition, Alignment, Proximity'), (11079, 160, N'True/False', N'Using more than 5-7 colors on a single dashboard is a good practice.', N'False'), (11080, 160, N'MCQ', N'What is the purpose of a tooltip on a dashboard?', N'To provide more detail on demand'), (11081, 160, N'True/False', N'Consistency in design helps users understand and use the dashboard faster.', N'True'), (11082, 160, N'MCQ', N'"Whitespace" or negative space in design is used to do what?', N'Reduce clutter and improve readability'), (11083, 160, N'MCQ', N'Why is alignment important in dashboard design?', N'It creates a clean and organized look'), (11084, 160, N'True/False', N'A dashboard should contain as much data as possible on one screen.', N'False'), (11085, 160, N'MCQ', N'What is a common mistake in dashboard UI?', N'Poor color choices'), (11086, 160, N'True/False', N'User feedback should only be collected after the dashboard is fully built.', N'False'), (11087, 160, N'MCQ', N'What is "visual hierarchy"?', N'Arranging elements to show their order of importance'), (11088, 160, N'True/False', N'It is important to provide clear labels and titles for all charts.', N'True'), (11089, 160, N'MCQ', N'The process of creating a low-fidelity layout of a dashboard is called what?', N'Wireframing');

-- Department: E-Business, Track: Data Visualization, Course: Data Viz Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11090, 161, N'MCQ', N'What is the first step in any data visualization project?', N'Defining the objective and audience'), (11091, 161, N'True/False', N'A project plan is not necessary for a capstone project.', N'False'), (11092, 161, N'MCQ', N'What does KPI stand for?', N'Key Performance Indicator'), (11093, 161, N'MCQ', N'What is the purpose of building a project portfolio?', N'To showcase your skills and work to potential employers'), (11094, 161, N'True/False', N'You should start building your visualizations before cleaning your data.', N'False'), (11095, 161, N'MCQ', N'Why is it important to understand your audience?', N'To tailor the story and complexity of the viz'), (11096, 161, N'True/False', N'The final presentation is as important as the visualization itself.', N'True'), (11097, 161, N'MCQ', N'What is a good way to get data for a personal project?', N'Public datasets (e.g., Kaggle, data.gov)'), (11098, 161, N'MCQ', N'What is an essential part of the project documentation?', N'Describing the data sources and methodology'), (11099, 161, N'True/False', N'Receiving feedback on your project is crucial for improvement.', N'True'), (11100, 161, N'MCQ', N'When presenting your project, you should start by explaining what?', N'The problem or question you are addressing'), (11101, 161, N'True/False', N'A capstone project should demonstrate both technical and analytical skills.', N'True'), (11102, 161, N'MCQ', N'What is the process of finding and correcting issues in your data called?', N'Data Cleaning'), (11103, 161, N'True/False', N'It is a good idea to include a "next steps" or "recommendations" section.', N'True'), (11104, 161, N'MCQ', N'What is the primary goal of the capstone project?', N'To apply all learned skills to a real-world problem');

-- Department: E-Business, Track: Data Visualization, Course: Data Visualization & Storytelling
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11000, 11000, N'Pie Chart'), (11001, 11000, N'Line Chart'), (11002, 11000, N'Scatter Plot'), (11003, 11000, N'Histogram'), (11004, 11002, N'To communicate insights effectively'), (11005, 11002, N'To show raw data tables'), (11006, 11002, N'To make data look pretty'), (11007, 11002, N'To perform statistical analysis'), (11008, 11003, N'Scatter Plot'), (11009, 11003, N'Bar Chart'), (11010, 11003, N'Treemap'), (11011, 11003, N'Pie Chart'), (11012, 11005, N'Scan a web page or dashboard'), (11013, 11005, N'Create a 3D model'), (11014, 11005, N'Write a line of code'), (11015, 11005, N'Join database tables'), (11016, 11007, N'Similarity'), (11017, 11007, N'Proximity'), (11018, 11007, N'Closure'), (11019, 11007, N'Continuity'), (11020, 11008, N'Bar Chart'), (11021, 11008, N'Line Chart'), (11022, 11008, N'Scatter Plot'), (11023, 11008, N'Pie Chart'), (11024, 11010, N'Removing unnecessary elements'), (11025, 11010, N'Adding more data'), (11026, 11010, N'Changing the chart type'), (11027, 11010, N'Making the colors brighter'), (11028, 11012, N'The background information needed to understand the data'), (11029, 11012, N'The chart type being used'), (11030, 11012, N'The person who created the viz'), (11031, 11012, N'The title of the chart'), (11032, 11014, N'Show the data, don''t hide it'), (11033, 11014, N'Use as many colors as possible'), (11034, 11014, N'Make it as complex as possible'), (11035, 11014, N'Always use a pie chart');

-- Department: E-Business, Track: Data Visualization, Course: Tableau for Data Viz
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11036, 11015, N'Blue'), (11037, 11015, N'Green'), (11038, 11015, N'Red'), (11039, 11015, N'Orange'), (11040, 11017, N'Marks Card'), (11041, 11017, N'Filters Shelf'), (11042, 11017, N'Data Pane'), (11043, 11017, N'Format Menu'), (11044, 11018, N'A numeric, quantifiable field'), (11045, 11018, N'A categorical field'), (11046, 11018, N'A date field'), (11047, 11018, N'A text field'), (11048, 11020, N'Calculated Fields'), (11049, 11020, N'Data Blending'), (11050, 11020, N'Dashboard Actions'), (11051, 11020, N'Worksheets'), (11052, 11022, N'Dimensions segment data, Measures are aggregated'), (11053, 11022, N'Dimensions are green, Measures are blue'), (11054, 11022, N'There is no difference'), (11055, 11022, N'Dimensions are numbers, Measures are text'), (11056, 11023, N'Shelves'), (11057, 11023, N'Cards'), (11058, 11023, N'Menus'), (11059, 11023, N'The Data Pane'), (11060, 11025, N'Level of Detail'), (11061, 11025, N'Length of Data'), (11062, 11025, N'Limit of Dimension'), (11063, 11025, N'Logical Data'), (11064, 11027, N'Drag a dimension or measure to the Filters shelf'), (11065, 11027, N'Write a SQL query'), (11066, 11027, N'Use the "Show Me" panel'), (11067, 11027, N'Right-click on the data source'), (11068, 11029, N'To suggest appropriate chart types'), (11069, 11029, N'To display underlying data'), (11070, 11029, N'To create a calculated field'), (11071, 11029, N'To format the visualization');

-- Department: E-Business, Track: Data Visualization, Course: Power BI for Data Viz
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11072, 11030, N'DAX'), (11073, 11030, N'SQL'), (11074, 11030, N'M'), (11075, 11030, N'Python'), (11076, 11032, N'Report, Data, and Model views'), (11077, 11032, N'Power Query, Power Pivot, Power View'), (11078, 11032, N'Desktop, Service, and Mobile'), (11079, 11032, N'Visuals, Fields, and Filters panes'), (11080, 11033, N'A DAX formula'), (11081, 11033, N'The Power Query Editor'), (11082, 11033, N'The Visualizations pane'), (11083, 11033, N'The relationships view'), (11084, 11035, N'To link tables together for filtering'), (11085, 11035, N'To clean and transform data'), (11086, 11035, N'To create visualizations'), (11087, 11035, N'To format the report'), (11088, 11037, N'Power Query Editor'), (11089, 11037, N'DAX Formula Bar'), (11090, 11037, N'Report Canvas'), (11091, 11037, N'Power BI Service'), (11092, 11038, N'A chart or graph on a report'), (11093, 11038, N'A connection to a data source'), (11094, 11038, N'A DAX calculation'), (11095, 11038, N'A table of data'), (11096, 11040, N'Measures are calculated on the fly, columns are pre-calculated'), (11097, 11040, N'Columns use DAX, Measures do not'), (11098, 11040, N'Measures are stored in memory, columns are not'), (11099, 11040, N'There is no difference'), (11100, 11042, N'AppSource'), (11101, 11042, N'The Power Query Editor'), (11102, 11042, N'The Model View'), (11103, 11042, N'Windows Store'), (11104, 11044, N'A single page canvas of visuals from one or more reports'), (11105, 11044, N'The file you create in Power BI Desktop'), (11106, 11044, N'A collection of datasets'), (11107, 11044, N'A tool for cleaning data');

-- Department: E-Business, Track: Data Visualization, Course: SQL for Data Analysts
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11108, 11045, N'SELECT'), (11109, 11045, N'GET'), (11110, 11045, N'RETRIEVE'), (11111, 11045, N'QUERY'), (11112, 11047, N'LEFT JOIN'), (11113, 11047, N'INNER JOIN'), (11114, 11047, N'RIGHT JOIN'), (11115, 11047, N'FULL OUTER JOIN'), (11116, 11048, N'COUNT()'), (11117, 11048, N'SUM()'), (11118, 11048, N'TOTAL()'), (11119, 11048, N'NUMBER()'), (11120, 11050, N'UNION'), (11121, 11050, N'JOIN'), (11122, 11050, N'COMBINE'), (11123, 11050, N'MERGE'), (11124, 11052, N'ORDER BY ... DESC'), (11125, 11052, N'SORT BY ... DESC'), (11126, 11052, N'ORDER BY ... ASC'), (11127, 11052, N'GROUP BY ... DESC'), (11128, 11053, N'INNER JOIN'), (11129, 11053, N'LEFT JOIN'), (11130, 11053, N'RIGHT JOIN'), (11131, 11053, N'CROSS JOIN'), (11132, 11055, N'Searches for a specified pattern in a column'), (11133, 11055, N'Performs a mathematical calculation'), (11134, 11055, N'Limits the number of returned rows'), (11135, 11055, N'Checks for NULL values'), (11136, 11057, N'HAVING'), (11137, 11057, N'WHERE'), (11138, 11057, N'FILTER'), (11139, 11057, N'GROUP FILTER'), (11140, 11059, N'Alias'), (11141, 11059, N'Index'), (11142, 11059, N'View'), (11143, 11059, N'Key');

-- Department: E-Business, Track: Data Visualization, Course: Interactive Viz with D3.js
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11144, 11060, N'Data-Driven Documents'), (11145, 11060, N'Dynamic Data Documents'), (11146, 11060, N'Document Data Driven'), (11147, 11060, N'Data Drawing Directives'), (11148, 11062, N'SVG'), (11149, 11062, N'HTML Canvas'), (11150, 11062, N'CSS'), (11151, 11062, N'WebGL'), (11152, 11063, N'.data()'), (11153, 11063, N'.select()'), (11154, 11063, N'.append()'), (11155, 11063, N'.attr()'), (11156, 11065, N'To map a data domain to a visual range'), (11157, 11065, N'To change the size of the SVG container'), (11158, 11065, N'To load external data'), (11159, 11065, N'To select multiple elements'), (11160, 11067, N'Incoming data elements that need new DOM elements'), (11161, 11067, N'Existing DOM elements that need to be updated'), (11162, 11067, N'DOM elements that need to be removed'), (11163, 11067, N'All elements currently selected'), (11164, 11068, N'd3.selectAll("p")'), (11165, 11068, N'd3.select("p")'), (11166, 11068, N'd3.p.all()'), (11167, 11068, N'd3.getElementsByTagName("p")'), (11168, 11070, N'To animate changes over time'), (11169, 11070, N'To switch between different datasets'), (11170, 11070, N'To handle user click events'), (11171, 11070, N'To create a static chart'), (11172, 11072, N'DOM elements that are no longer needed'), (11173, 11072, N'Elements that are entering the visualization'), (11174, 11072, N'The first element in a selection'), (11175, 11072, N'Elements that have failed to load'), (11176, 11074, N'Visual representations of scales with ticks and labels'), (11177, 11074, N'The main title of the chart'), (11178, 11074, N'The data points themselves'), (11179, 11074, N'Interactive tooltips');

-- Department: E-Business, Track: Data Visualization, Course: UI/UX for Dashboards
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11180, 11075, N'The audience and their needs'), (11181, 11075, N'The colors used'), (11182, 11075, N'The amount of data shown'), (11183, 11075, N'The specific charting tool'), (11184, 11077, N'The F-Pattern or Z-Pattern'), (11185, 11077, N'The Rule of Thirds'), (11186, 11077, N'The Golden Ratio'), (11187, 11077, N'The Law of Proximity'), (11188, 11078, N'Contrast, Repetition, Alignment, Proximity'), (11189, 11078, N'Clarity, Readability, Accuracy, Purpose'), (11190, 11078, N'Color, Rank, Area, Position'), (11191, 11078, N'Create, Read, Alter, Process'), (11192, 11080, N'To provide more detail on demand'), (11193, 11080, N'To permanently label a data point'), (11194, 11080, N'To filter the entire dashboard'), (11195, 11080, N'To change the chart type'), (11196, 11082, N'Reduce clutter and improve readability'), (11197, 11082, N'Fill every available pixel with information'), (11198, 11082, N'Add more charts to the dashboard'), (11199, 11082, N'Make the dashboard background white'), (11200, 11083, N'It creates a clean and organized look'), (11201, 11083, N'It ensures colors do not clash'), (11202, 11083, N'It makes the dashboard load faster'), (11203, 11083, N'It connects the dashboard to the database'), (11204, 11085, N'Poor color choices'), (11205, 11085, N'Using too much white space'), (11206, 11085, N'Making the dashboard interactive'), (11207, 11085, N'Clearly labeling charts'), (11208, 11087, N'Arranging elements to show their order of importance'), (11209, 11087, N'A list of all visuals on the dashboard'), (11210, 11087, N'The connection between different data tables'), (11211, 11087, N'The order in which a user filters the data'), (11212, 11089, N'Wireframing'), (11213, 11089, N'Prototyping'), (11214, 11089, N'Storyboarding'), (11215, 11089, N'Mind mapping');

-- Department: E-Business, Track: Data Visualization, Course: Data Viz Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11216, 11090, N'Defining the objective and audience'), (11217, 11090, N'Choosing a color scheme'), (11218, 11090, N'Finding a dataset'), (11219, 11090, N'Building the first chart'), (11220, 11092, N'Key Performance Indicator'), (11221, 11092, N'Key Process Information'), (11222, 11092, N'Known Programming Interface'), (11223, 11092, N'Key Python Implementation'), (11224, 11093, N'To showcase your skills and work to potential employers'), (11225, 11093, N'To back up your project files'), (11226, 11093, N'To fulfill a course requirement only'), (11227, 11093, N'To document project bugs'), (11228, 11095, N'To tailor the story and complexity of the viz'), (11229, 11095, N'It is not important'), (11230, 11095, N'To know how much to charge for the project'), (11231, 11095, N'To decide which programming language to use'), (11232, 11097, N'Public datasets (e.g., Kaggle, data.gov)'), (11233, 11097, N'Making up data'), (11234, 11097, N'Only using data from your current company'), (11235, 11097, N'Copying a classmate''s data'), (11236, 11098, N'Describing the data sources and methodology'), (11237, 11098, N'Your personal opinion of the project'), (11238, 11098, N'A list of your favorite charts'), (11239, 11098, N'The code for your project printed out'), (11240, 11100, N'The problem or question you are addressing'), (11241, 11100, N'Your final conclusion'), (11242, 11100, N'A detailed walkthrough of your code'), (11243, 11100, N'Your biography'), (11244, 11102, N'Data Cleaning'), (11245, 11102, N'Data Visualization'), (11246, 11102, N'Data Modeling'), (11247, 11102, N'Data Mining'), (11248, 11104, N'To apply all learned skills to a real-world problem'), (11249, 11104, N'To create the most beautiful visualization possible'), (11250, 11104, N'To pass the course'), (11251, 11104, N'To use a specific software tool');


--Track 24 Salesforce Specialist Questions =========================================================================================================

-- Department: E-Business, Track: Salesforce Specialist, Course: Salesforce Admin & CRM Intro
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11500, 162, N'MCQ', N'What does CRM stand for?', N'Customer Relationship Management'), (11501, 162, N'True/False', N'Salesforce is considered a "Platform as a Service" (PaaS).', N'True'), (11502, 162, N'MCQ', N'In Salesforce, what is an "Object"?', N'A table in the database'), (11503, 162, N'MCQ', N'What is a "Record" in Salesforce?', N'A row of data in an object'), (11504, 162, N'True/False', N'The App Launcher is used to switch between different Salesforce apps.', N'True'), (11505, 162, N'MCQ', N'What is a Salesforce "Org"?', N'A specific instance of the Salesforce platform'), (11506, 162, N'True/False', N'Standard objects, like Account and Contact, are created by the user.', N'False'), (11507, 162, N'MCQ', N'Which of the following is a standard object?', N'Lead'), (11508, 162, N'MCQ', N'The "Setup" menu is used for what purpose?', N'Administration and customization'), (11509, 162, N'True/False', N'Salesforce Classic is the most modern user interface available.', N'False'), (11510, 162, N'MCQ', N'What is Trailhead?', N'Salesforce''s free online learning platform'), (11511, 162, N'True/False', N'A user''s Profile controls what they can see and do in Salesforce.', N'True'), (11512, 162, N'MCQ', N'What is a "Field" on a Salesforce object?', N'A column of data in an object'), (11513, 162, N'MCQ', N'What is the AppExchange?', N'A marketplace for Salesforce apps'), (11514, 162, N'True/False', N'Multi-tenant architecture means all customers share the same infrastructure.', N'True');

-- Department: E-Business, Track: Salesforce Specialist, Course: Sales & Service Cloud
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11515, 163, N'MCQ', N'What is a "Lead" in Sales Cloud?', N'A potential customer or prospect'), (11516, 163, N'True/False', N'Converting a Lead can create an Account, Contact, and Opportunity.', N'True'), (11517, 163, N'MCQ', N'What does the "Account" object typically represent?', N'A company or organization'), (11518, 163, N'MCQ', N'What is a "Case" in Service Cloud?', N'A customer''s question or issue'), (11519, 163, N'True/False', N'A Sales Process defines the stages of an Opportunity.', N'True'), (11520, 163, N'MCQ', N'What is a "Contact" in Salesforce?', N'An individual person associated with an Account'), (11521, 163, N'True/False', N'Web-to-Lead allows you to automatically capture leads from your company website.', N'True'), (11522, 163, N'MCQ', N'What is a "Queue" used for in Salesforce?', N'To hold records that are unassigned'), (11523, 163, N'MCQ', N'What is a "Knowledge" article in Service Cloud?', N'A resource to help solve customer issues'), (11524, 163, N'True/False', N'Service Cloud is primarily used to manage the sales cycle.', N'False'), (11525, 163, N'MCQ', N'What is an "Opportunity"?', N'A potential revenue-generating deal'), (11526, 163, N'True/False', N'An Escalation Rule can automatically re-route a Case if it is not solved in time.', N'True'), (11527, 163, N'MCQ', N'What does a Campaign object represent?', N'A marketing initiative'), (11528, 163, N'True/False', N'The Service Console provides a unified interface for support agents.', N'True'), (11529, 163, N'MCQ', N'What is an "Asset" in Service Cloud used to track?', N'Specific products a customer has purchased');

-- Department: E-Business, Track: Salesforce Specialist, Course: Data Modeling & Security
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11530, 164, N'MCQ', N'Which relationship type creates a dependency where deleting the parent deletes the child?', N'Master-Detail'), (11531, 164, N'True/False', N'A Lookup relationship is a tightly coupled relationship between two objects.', N'False'), (11532, 164, N'MCQ', N'What does OWD stand for?', N'Organization-Wide Defaults'), (11533, 164, N'MCQ', N'What does a user''s Profile control?', N'Object permissions, field permissions, and app access'), (11534, 164, N'True/False', N'Sharing Rules are used to restrict data access from what was granted by OWDs.', N'False'), (11535, 164, N'MCQ', N'What is the purpose of the Role Hierarchy?', N'To grant managers access to their subordinates'' records'), (11536, 164, N'True/False', N'Field-Level Security (FLS) can make a field read-only for certain users.', N'True'), (11537, 164, N'MCQ', N'Which tool is a visual, drag-and-drop interface for managing objects and relationships?', N'Schema Builder'), (11538, 164, N'MCQ', N'What is a custom object?', N'An object you create to store company-specific data'), (11539, 164, N'True/False', N'Permission Sets are used to grant additional permissions to specific users.', N'True'), (11540, 164, N'MCQ', N'What is the purpose of a junction object?', N'To create a many-to-many relationship'), (11541, 164, N'True/False', N'You can have a maximum of 5 master-detail relationships on a single object.', N'False'), (11542, 164, N'MCQ', N'What do Page Layouts control?', N'The arrangement of fields and buttons on a record page'), (11543, 164, N'True/False', N'The security model in Salesforce is based on a "deny by default" principle.', N'True'), (11544, 164, N'MCQ', N'Which security feature is the most restrictive and sets the baseline access?', N'Organization-Wide Defaults');

-- Department: E-Business, Track: Salesforce Specialist, Course: Process Automation with Flow
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11545, 165, N'MCQ', N'What is the current recommended tool for most declarative automation in Salesforce?', N'Flow Builder'), (11546, 165, N'True/False', N'Workflow Rules and Process Builder are being retired and replaced by Flow.', N'True'), (11547, 165, N'MCQ', N'Which type of Flow is designed to guide users through a business process with a UI?', N'Screen Flow'), (11548, 165, N'MCQ', N'A Flow that runs when a record is created or updated is called a what?', N'Record-Triggered Flow'), (11549, 165, N'True/False', N'The "Get Records" element in Flow is used to update existing records.', N'False'), (11550, 165, N'MCQ', N'Which element in Flow allows you to evaluate conditions and follow different paths?', N'Decision'), (11551, 165, N'True/False', N'A Flow can be triggered to run on a specific schedule.', N'True'), (11552, 165, N'MCQ', N'What is an "Assignment" element used for in Flow?', N'To set or change the value of a variable'), (11553, 165, N'MCQ', N'What is a major advantage of Flow over Workflow Rules?', N'It can delete records'), (11554, 165, N'True/False', N'You can use the "Debug" tool in Flow Builder to test your Flow before activating it.', N'True'), (11555, 165, N'MCQ', N'What does a "Loop" element do?', N'Iterates over a collection of items'), (11556, 165, N'True/False', N'An Autolaunched Flow must be initiated by a user clicking a button.', N'False'), (11557, 165, N'MCQ', N'What is an "Approval Process"?', N'An automated process for approving records'), (11558, 165, N'True/False', N'Flows cannot send outbound emails.', N'False'), (11559, 165, N'MCQ', N'A "Fault Path" in a Flow is used to handle what?', N'Errors that occur during execution');

-- Department: E-Business, Track: Salesforce Specialist, Course: Reports & Dashboards
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11560, 166, N'MCQ', N'What is a "Report" in Salesforce?', N'A list of records that meet specific criteria'), (11561, 166, N'True/False', N'A "Dashboard" is a visual representation of data from one or more reports.', N'True'), (11562, 166, N'MCQ', N'Which report format is best for creating lists of records?', N'Tabular'), (11563, 166, N'MCQ', N'Which report format groups rows by one or more fields?', N'Summary'), (11564, 166, N'True/False', N'You can subscribe to a report to receive it via email on a schedule.', N'True'), (11565, 166, N'MCQ', N'What is a "Report Type"?', N'A template that defines the objects and fields for a report'), (11566, 166, N'True/False', N'A dashboard can only display data from a single report.', N'False'), (11567, 166, N'MCQ', N'What is a "Matrix" report used for?', N'Grouping data by both rows and columns'), (11568, 166, N'MCQ', N'What is a "Bucket" field used for in a report?', N'To categorize records without creating a formula field'), (11569, 166, N'True/False', N'A dynamic dashboard shows data according to the viewing user''s access level.', N'True'), (11570, 166, N'MCQ', N'What is a "Joined Report"?', N'A report containing data from multiple report types'), (11571, 166, N'True/False', N'You cannot add charts to a Salesforce report.', N'False'), (11572, 166, N'MCQ', N'What is the maximum number of components you can add to a single dashboard?', N'20'), (11573, 166, N'True/False', N'Report filters are used to include more data in the results.', N'False'), (11574, 166, N'MCQ', N'What does a dashboard "refresh" do?', N'Updates the data displayed in its components');

-- Department: E-Business, Track: Salesforce Specialist, Course: Apex & Lightning Web Components Intro
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11575, 167, N'MCQ', N'What is Apex?', N'A strongly-typed, object-oriented programming language'), (11576, 167, N'True/False', N'Apex code is executed on the client''s browser, not on the server.', N'False'), (11577, 167, N'MCQ', N'What does SOQL stand for?', N'Salesforce Object Query Language'), (11578, 167, N'MCQ', N'What is an Apex "Trigger"?', N'Code that executes before or after records are manipulated'), (11579, 167, N'True/False', N'Lightning Web Components (LWC) is a framework for building user interfaces.', N'True'), (11580, 167, N'MCQ', N'Which language is used for the client-side logic in an LWC?', N'JavaScript'), (11581, 167, N'True/False', N'Apex Test Classes are required and must cover at least 75% of your code for deployment.', N'True'), (11582, 167, N'MCQ', N'What is the Developer Console?', N'An in-browser IDE for writing and debugging code'), (11583, 167, N'MCQ', N'What is an "sObject" in Apex?', N'A variable that represents a Salesforce record'), (11584, 167, N'True/False', N'LWC is a proprietary Salesforce framework and does not use web standards.', N'False'), (11585, 167, N'MCQ', N'What is SOSL used for?', N'Searching for text across multiple objects'), (11586, 167, N'True/False', N'Governor limits are in place to prevent code from monopolizing shared resources.', N'True'), (11587, 167, N'MCQ', N'An LWC is composed of which main file types?', N'HTML, JavaScript, and XML'), (11588, 167, N'True/False', N'You can query an unlimited number of records in a single SOQL query.', N'False'), (11589, 167, N'MCQ', N'What is the primary function of an Apex class?', N'To contain methods, variables, and logic');

-- Department: E-Business, Track: Salesforce Specialist, Course: Salesforce Capstone Project
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (11590, 168, N'MCQ', N'What is the first crucial phase of a Salesforce project?', N'Discovery and requirements gathering'), (11591, 168, N'True/False', N'A "Sandbox" is a copy of your production org used for development and testing.', N'True'), (11592, 168, N'MCQ', N'What is the purpose of User Acceptance Testing (UAT)?', N'For business users to validate the solution'), (11593, 168, N'MCQ', N'How are customizations typically moved from a Sandbox to Production?', N'Using Change Sets'), (11594, 168, N'True/False', N'It is a best practice to build new features directly in the Production environment.', N'False'), (11595, 168, N'MCQ', N'What is a "Solution Design Document"?', N'A blueprint of how the requirements will be met'), (11596, 168, N'True/False', N'Agile is a project methodology that focuses on iterative development.', N'True'), (11597, 168, N'MCQ', N'What does "deployment" refer to?', N'The process of releasing changes to production'), (11598, 168, N'MCQ', N'Why is end-user training important for a project''s success?', N'It ensures users adopt and correctly use the new system'), (11599, 168, N'True/False', N'A project portfolio is not useful for showcasing your Salesforce skills.', N'False'), (11600, 168, N'MCQ', N'What is a "proof-of-concept" (PoC)?', N'A small-scale test to demonstrate feasibility'), (11601, 168, N'True/False', N'Once a project is deployed, no further maintenance or review is needed.', N'False'), (11602, 168, N'MCQ', N'What is a critical component of project documentation?', N'Recording configuration and code changes'), (11603, 168, N'True/False', N'Stakeholder communication is a key factor in a successful project.', N'True'), (11604, 168, N'MCQ', N'What is the primary goal of a capstone project?', N'To apply and demonstrate learned skills on a practical problem');

-- Department: E-Business, Track: Salesforce Specialist, Course: Salesforce Admin & CRM Intro
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11500, 11500, N'Customer Relationship Management'), (11501, 11500, N'Company Resource Management'), (11502, 11500, N'Customer Resource Mainframe'), (11503, 11500, N'Company Relationship Model'), (11504, 11502, N'A table in the database'), (11505, 11502, N'A single piece of data'), (11506, 11502, N'A user interface'), (11507, 11502, N'A report'), (11508, 11503, N'A row of data in an object'), (11509, 11503, N'An entire database table'), (11510, 11503, N'A user''s password'), (11511, 11503, N'A visual chart'), (11512, 11505, N'A specific instance of the Salesforce platform'), (11513, 11505, N'A Salesforce user group'), (11514, 11505, N'The Salesforce headquarters'), (11515, 11505, N'A type of license'), (11516, 11507, N'Lead'), (11517, 11507, N'Invoice'), (11518, 11507, N'Project'), (11519, 11507, N'Territory'), (11520, 11508, N'Administration and customization'), (11521, 11508, N'Running reports'), (11522, 11508, N'Creating new records'), (11523, 11508, N'Logging out'), (11524, 11510, N'Salesforce''s free online learning platform'), (11525, 11510, N'A Salesforce conference'), (11526, 11510, N'A tool for debugging code'), (11527, 11510, N'A type of custom object'), (11528, 11512, N'A column of data in an object'), (11529, 11512, N'A report dashboard'), (11530, 11512, N'An automation rule'), (11531, 11512, N'A collection of users'), (11532, 11513, N'A marketplace for Salesforce apps'), (11533, 11513, N'A place to change your password'), (11534, 11513, N'The main sales user interface'), (11535, 11513, N'A data import tool');

-- Department: E-Business, Track: Salesforce Specialist, Course: Sales & Service Cloud
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11536, 11515, N'A potential customer or prospect'), (11537, 11515, N'An existing customer'), (11538, 11515, N'A closed/won deal'), (11539, 11515, N'A customer complaint'), (11540, 11517, N'A company or organization'), (11541, 11517, N'An individual person'), (11542, 11517, N'A sales deal'), (11543, 11517, N'A support ticket'), (11544, 11518, N'A customer''s question or issue'), (11545, 11518, N'A potential sale'), (11546, 11518, N'A marketing campaign'), (11547, 11518, N'An employee record'), (11548, 11520, N'An individual person associated with an Account'), (11549, 11520, N'A business you are selling to'), (11550, 11520, N'A list of sales stages'), (11551, 11520, N'A group of users'), (11552, 11522, N'To hold records that are unassigned'), (11553, 11522, N'To group users for reporting'), (11554, 11522, N'To define a sales territory'), (11555, 11522, N'To store deleted records'), (11556, 11523, N'A resource to help solve customer issues'), (11557, 11523, N'A list of all customers'), (11558, 11523, N'A sales forecasting tool'), (11559, 11523, N'An automation rule'), (11560, 11525, N'A potential revenue-generating deal'), (11561, 11525, N'A solved customer case'), (11562, 11525, N'A new, unqualified lead'), (11563, 11525, N'A company you do business with'), (11564, 11527, N'A marketing initiative'), (11565, 11527, N'A customer service team'), (11566, 11527, N'A pending sale'), (11567, 11527, N'A type of report'), (11568, 11529, N'Specific products a customer has purchased'), (11569, 11529, N'A company''s financial information'), (11570, 11529, N'A user''s login history'), (11571, 11529, N'A list of support agents');

-- Department: E-Business, Track: Salesforce Specialist, Course: Data Modeling & Security
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11572, 11530, N'Master-Detail'), (11573, 11530, N'Lookup'), (11574, 11530, N'Hierarchical'), (11575, 11530, N'Many-to-Many'), (11576, 11532, N'Organization-Wide Defaults'), (11577, 11532, N'Object-Wide Defaults'), (11578, 11532, N'Overall Wide-ranging Defaults'), (11579, 11532, N'Official Web Domain'), (11580, 11533, N'Object permissions, field permissions, and app access'), (11581, 11533, N'Only record access'), (11582, 11533, N'Only the user''s password'), (11583, 11533, N'Only which reports a user can see'), (11584, 11535, N'To grant managers access to their subordinates'' records'), (11585, 11535, N'To set the company''s physical address'), (11586, 11535, N'To change the user interface color'), (11587, 11535, N'To create new objects'), (11588, 11537, N'Schema Builder'), (11589, 11537, N'Report Builder'), (11590, 11537, N'Flow Builder'), (11591, 11537, N'App Builder'), (11592, 11538, N'An object you create to store company-specific data'), (11593, 11538, N'An object that comes with Salesforce by default'), (11594, 11538, N'A deleted object'), (11595, 11538, N'A user''s profile page'), (11596, 11540, N'To create a many-to-many relationship'), (11597, 11540, N'To create a one-to-one relationship'), (11598, 11540, N'To delete records'), (11599, 11540, N'To store user login information'), (11600, 11542, N'The arrangement of fields and buttons on a record page'), (11601, 11542, N'The underlying database structure'), (11602, 11542, N'The results of a report'), (11603, 11542, N'The logic in an automation'), (11604, 11544, N'Organization-Wide Defaults'), (11605, 11544, N'Profiles'), (11606, 11544, N'Sharing Rules'), (11607, 11544, N'Permission Sets');

-- Department: E-Business, Track: Salesforce Specialist, Course: Process Automation with Flow
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11608, 11545, N'Flow Builder'), (11609, 11545, N'Apex Triggers'), (11610, 11545, N'Workflow Rules'), (11611, 11545, N'Process Builder'), (11612, 11547, N'Screen Flow'), (11613, 11547, N'Record-Triggered Flow'), (11614, 11547, N'Scheduled Flow'), (11615, 11547, N'Autolaunched Flow'), (11616, 11548, N'Record-Triggered Flow'), (11617, 11548, N'Screen Flow'), (11618, 11548, N'Process Builder'), (11619, 11548, N'Approval Process'), (11620, 11550, N'Decision'), (11621, 11550, N'Assignment'), (11622, 11550, N'Loop'), (11623, 11550, N'Get Records'), (11624, 11552, N'To set or change the value of a variable'), (11625, 11552, N'To find records in the database'), (11626, 11552, N'To display a screen to the user'), (11627, 11552, N'To delete a record'), (11628, 11553, N'It can delete records'), (11629, 11553, N'It can update fields'), (11630, 11553, N'It can send emails'), (11631, 11553, N'It can create tasks'), (11632, 11555, N'Iterates over a collection of items'), (11633, 11555, N'Ends the flow'), (11634, 11555, N'Makes a decision'), (11635, 11555, N'Gets records from the database'), (11636, 11557, N'An automated process for approving records'), (11637, 11557, N'A tool for building user interfaces'), (11638, 11557, N'A type of report'), (11639, 11557, N'A way to delete records'), (11640, 11559, N'Errors that occur during execution'), (11641, 11559, N'Successful completion of the flow'), (11642, 11559, N'User decisions'), (11643, 11559, N'The start of the flow');

-- Department: E-Business, Track: Salesforce Specialist, Course: Reports & Dashboards
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11644, 11560, N'A list of records that meet specific criteria'), (11645, 11560, N'A single Salesforce record'), (11646, 11560, N'A visual chart'), (11647, 11560, N'An automation tool'), (11648, 11562, N'Tabular'), (11649, 11562, N'Matrix'), (11650, 11562, N'Summary'), (11651, 11562, N'Joined'), (11652, 11563, N'Summary'), (11653, 11563, N'Tabular'), (11654, 11563, N'Graphical'), (11655, 11563, N'Detailed'), (11656, 11565, N'A template that defines the objects and fields for a report'), (11657, 11565, N'The format of the report output'), (11658, 11565, N'A specific report that has been saved'), (11659, 11565, N'A filter applied to a report'), (11660, 11567, N'Grouping data by both rows and columns'), (11661, 11567, N'Showing a simple list of data'), (11662, 11567, N'Displaying data in a single chart'), (11663, 11567, N'Combining two different reports'), (11664, 11568, N'To categorize records without creating a formula field'), (11665, 11568, N'To perform a mathematical calculation'), (11666, 11568, N'To filter the report results'), (11667, 11568, N'To sort the report'), (11668, 11570, N'A report containing data from multiple report types'), (11669, 11570, N'A report that has been joined to a dashboard'), (11670, 11570, N'A report with two or more filters'), (11671, 11570, N'A report that is grouped by rows and columns'), (11672, 11572, N'20'), (11673, 11572, N'10'), (11674, 11572, N'25'), (11675, 11572, N'50'), (11676, 11574, N'Updates the data displayed in its components'), (11677, 11574, N'Saves the dashboard layout'), (11678, 11574, N'Deletes the dashboard'), (11679, 11574, N'Emails the dashboard to a user');

-- Department: E-Business, Track: Salesforce Specialist, Course: Apex & Lightning Web Components Intro
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11680, 11575, N'A strongly-typed, object-oriented programming language'), (11681, 11575, N'A user interface framework'), (11682, 11575, N'A declarative automation tool'), (11683, 11575, N'A database query language'), (11684, 11577, N'Salesforce Object Query Language'), (11685, 11577, N'Standard Object Query Language'), (11686, 11577, N'Systematic Object Query Language'), (11687, 11577, N'Salesforce Official Query Language'), (11688, 11578, N'Code that executes before or after records are manipulated'), (11689, 11578, N'A user-interface component'), (11690, 11578, N'A scheduled job'), (11691, 11578, N'A type of report'), (11692, 11580, N'JavaScript'), (11693, 11580, N'Apex'), (11694, 11580, N'HTML'), (11695, 11580, N'SOQL'), (11696, 11582, N'An in-browser IDE for writing and debugging code'), (11697, 11582, N'A user interface for sales reps'), (11698, 11582, N'A tool for building reports'), (11699, 11582, N'The main Salesforce setup menu'), (11700, 11583, N'A variable that represents a Salesforce record'), (11701, 11583, N'A custom user interface'), (11702, 11583, N'A connection to an external system'), (11703, 11583, N'An error in the code'), (11704, 11585, N'Searching for text across multiple objects'), (11705, 11585, N'Querying for records from a single object'), (11706, 11585, N'Updating records in the database'), (11707, 11585, N'Describing the shape of an object'), (11708, 11587, N'HTML, JavaScript, and XML'), (11709, 11587, N'Apex and Visualforce'), (11710, 11587, N'Flow and Process Builder'), (11711, 11587, N'Java and Python'), (11712, 11589, N'To contain methods, variables, and logic'), (11713, 11589, N'To display data on a page layout'), (11714, 11589, N'To trigger automation'), (11715, 11589, N'To define a relationship between objects');

-- Department: E-Business, Track: Salesforce Specialist, Course: Salesforce Capstone Project
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (11716, 11590, N'Discovery and requirements gathering'), (11717, 11590, N'Writing Apex code'), (11718, 11590, N'Deploying to production'), (11719, 11590, N'Training users'), (11720, 11592, N'For business users to validate the solution'), (11721, 11592, N'For developers to write code'), (11722, 11592, N'For admins to reset passwords'), (11723, 11592, N'For marketing to create campaigns'), (11724, 11593, N'Using Change Sets'), (11725, 11593, N'By emailing the code'), (11726, 11593, N'By manually recreating everything'), (11727, 11593, N'Using the data loader'), (11728, 11595, N'A blueprint of how the requirements will be met'), (11729, 11595, N'The final user training manual'), (11730, 11595, N'A list of all users in the system'), (11731, 11595, N'The contract for the project'), (11732, 11597, N'The process of releasing changes to production'), (11733, 11597, N'The process of creating a new Sandbox'), (11734, 11597, N'The process of deleting old data'), (11735, 11597, N'The process of writing test classes'), (11736, 11598, N'It ensures users adopt and correctly use the new system'), (11737, 11598, N'It is not important'), (11738, 11598, N'It helps developers find bugs'), (11739, 11598, N'It is a legal requirement'), (11740, 11600, N'A small-scale test to demonstrate feasibility'), (11741, 11600, N'The final deployed application'), (11742, 11600, N'A project management methodology'), (11743, 11600, N'A type of user license'), (11744, 11602, N'Recording configuration and code changes'), (11745, 11602, N'A list of everyone''s favorite features'), (11746, 11602, N'Meeting minutes from the kickoff call'), (11747, 11602, N'The project budget'), (11748, 11604, N'To apply and demonstrate learned skills on a practical problem'), (11749, 11604, N'To get the highest grade possible'), (11750, 11604, N'To finish as quickly as possible'), (11751, 11604, N'To build a solution with zero bugs');


--Track 25 Business Analysis Questions ============================================================================================================

-- Department: E-Business, Track: Business Analysis, Course: Business Analysis Fundamentals (BABOK)
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12000, 169, N'MCQ', N'What does BABOK stand for?', N'Business Analysis Body of Knowledge'), (12001, 169, N'True/False', N'A Business Analyst''s primary role is to write code.', N'False'), (12002, 169, N'MCQ', N'Which of these is a BABOK Knowledge Area?', N'Elicitation and Collaboration'), (12003, 169, N'MCQ', N'What is a "requirement"?', N'A usable representation of a need'), (12004, 169, N'True/False', N'The BABOK Guide is published by the Project Management Institute (PMI).', N'False'), (12005, 169, N'MCQ', N'Which is NOT a core concept in the BACCM (Business Analysis Core Concept Model)?', N'Budget'), (12006, 169, N'True/False', N'A stakeholder is anyone with an interest in the change.', N'True'), (12007, 169, N'MCQ', N'What is the purpose of "Business Analysis Planning and Monitoring"?', N'To organize and coordinate the BA effort'), (12008, 169, N'MCQ', N'Which technique is used for brainstorming?', N'Mind Mapping'), (12009, 169, N'True/False', N'Functional requirements describe how a system should behave.', N'True'), (12010, 169, N'MCQ', N'What is a "constraint"?', N'A restriction or limitation on a solution'), (12011, 169, N'True/False', N'Solution assessment and validation is done before a solution is designed.', N'False'), (12012, 169, N'MCQ', N'What is the purpose of a business case?', N'To justify the investment in a project'), (12013, 169, N'True/False', N'A business analysis technique is a specific way to perform a BA task.', N'True'), (12014, 169, N'MCQ', N'What is "elicitation"?', N'The process of drawing out requirements from stakeholders');

-- Department: E-Business, Track: Business Analysis, Course: Stakeholder & Requirements Management
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12015, 170, N'MCQ', N'What does the "R" in a RACI matrix stand for?', N'Responsible'), (12016, 170, N'True/False', N'It is best to ignore difficult stakeholders.', N'False'), (12017, 170, N'MCQ', N'Which technique involves watching a user perform their job?', N'Observation'), (12018, 170, N'MCQ', N'What is the first step in stakeholder analysis?', N'Identify Stakeholders'), (12019, 170, N'True/False', N'Requirements should be ambiguous to allow for flexibility.', N'False'), (12020, 170, N'MCQ', N'What is the primary goal of requirements management?', N'To ensure requirements are met throughout the project'), (12021, 170, N'True/False', N'A focus group is a one-on-one interview with a key stakeholder.', N'False'), (12022, 170, N'MCQ', N'What is "traceability" in requirements management?', N'The ability to track the life of a requirement'), (12023, 170, N'MCQ', N'What is a common challenge in requirements elicitation?', N'Conflicting stakeholder needs'), (12024, 170, N'True/False', N'Once requirements are approved, they can never be changed.', N'False'), (12025, 170, N'MCQ', N'What is the purpose of requirements prioritization?', N'To determine which requirements are most critical'), (12026, 170, N'True/False', N'Prototyping is a technique to visually demonstrate requirements.', N'True'), (12027, 170, N'MCQ', N'Which of these is a key stakeholder group?', N'End Users'), (12028, 170, N'True/False', N'Stakeholder communication should be a one-time event.', N'False'), (12029, 170, N'MCQ', N'What is "scope creep"?', N'Uncontrolled changes or growth in project scope');

-- Department: E-Business, Track: Business Analysis, Course: Process & Data Modeling
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12030, 171, N'MCQ', N'What does BPMN stand for?', N'Business Process Model and Notation'), (12031, 171, N'True/False', N'In BPMN, a circle represents an event.', N'True'), (12032, 171, N'MCQ', N'What does a diamond shape typically represent in a flowchart?', N'A decision'), (12033, 171, N'MCQ', N'What is an Entity-Relationship Diagram (ERD) used for?', N'To model the data structure of a system'), (12034, 171, N'True/False', N'A "swimlane" in a process model is used to show who is responsible for a task.', N'True'), (12035, 171, N'MCQ', N'What does "cardinality" define in a data model?', N'The relationship between entities (e.g., one-to-many)'), (12036, 171, N'True/False', N'An "As-Is" process model shows the future, improved process.', N'False'), (12037, 171, N'MCQ', N'What is a "data dictionary"?', N'A central repository of information about data'), (12038, 171, N'MCQ', N'In an ERD, what does an "entity" represent?', N'A person, place, or thing (a noun)'), (12039, 171, N'True/False', N'Process modeling is only useful for manufacturing.', N'False'), (12040, 171, N'MCQ', N'What is a primary key in a data model?', N'A unique identifier for each record in a table'), (12041, 171, N'True/False', N'A "To-Be" process model represents the current state.', N'False'), (12042, 171, N'MCQ', N'Which of these is a benefit of process modeling?', N'Identifying bottlenecks and inefficiencies'), (12043, 171, N'True/False', N'A foreign key is used to link two tables together.', N'True'), (12044, 171, N'MCQ', N'What is a "use case diagram" used to show?', N'Interactions between users (actors) and a system');

-- Department: E-Business, Track: Business Analysis, Course: Agile Business Analysis
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12045, 172, N'MCQ', N'Which is a core value of the Agile Manifesto?', N'Customer collaboration over contract negotiation'), (12046, 172, N'True/False', N'In Agile, planning is a one-time event at the beginning of the project.', N'False'), (12047, 172, N'MCQ', N'What is the primary role of a Product Owner in Scrum?', N'To manage and prioritize the product backlog'), (12048, 172, N'MCQ', N'What is a "sprint" in Scrum?', N'A short, time-boxed period to complete a set amount of work'), (12049, 172, N'True/False', N'The Daily Stand-up meeting is for detailed problem-solving.', N'False'), (12050, 172, N'MCQ', N'What is a "product backlog"?', N'A prioritized list of all desired features'), (12051, 172, N'True/False', N'Agile methodologies welcome changing requirements.', N'True'), (12052, 172, N'MCQ', N'What is the purpose of a Sprint Retrospective?', N'To reflect on the sprint and identify improvements'), (12053, 172, N'MCQ', N'Who is responsible for facilitating Scrum events?', N'The Scrum Master'), (12054, 172, N'True/False', N'A Burndown Chart shows the amount of remaining work.', N'True'), (12055, 172, N'MCQ', N'What is a Minimum Viable Product (MVP)?', N'A version of a product with just enough features to be usable by early customers'), (12056, 172, N'True/False', N'The BA in an Agile team often acts as a proxy for the Product Owner.', N'True'), (12057, 172, N'MCQ', N'What is "velocity" in an Agile context?', N'A measure of the amount of work a team can complete in a sprint'), (12058, 172, N'True/False', N'Agile projects deliver value incrementally.', N'True'), (12059, 172, N'MCQ', N'What is Kanban?', N'A visual method for managing workflow');

-- Department: E-Business, Track: Business Analysis, Course: Writing User Stories
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12060, 173, N'MCQ', N'What is the standard format of a user story?', N'As a [user], I want to [action], so that [benefit]'), (12061, 173, N'True/False', N'A user story should describe a specific technical implementation.', N'False'), (12062, 173, N'MCQ', N'What does the "I" in the INVEST acronym for user stories stand for?', N'Independent'), (12063, 173, N'MCQ', N'What is an "Epic"?', N'A large user story that can be broken down into smaller stories'), (12064, 173, N'True/False', N'Acceptance criteria define the boundaries of a user story.', N'True'), (12065, 173, N'MCQ', N'Who is primarily responsible for writing user stories?', N'The Product Owner'), (12066, 173, N'True/False', N'A good user story represents a small, vertical slice of functionality.', N'True'), (12067, 173, N'MCQ', N'What is the purpose of the "so that" clause in a user story?', N'To provide the value or reason for the feature'), (12068, 173, N'MCQ', N'What is the "V" in INVEST?', N'Valuable'), (12069, 173, N'True/False', N'User stories should be written on the first day of the project and never changed.', N'False'), (12070, 173, N'MCQ', N'What is "story mapping"?', N'A technique to visually organize the product backlog'), (12071, 173, N'True/False', N'Acceptance criteria should be written in a "Given/When/Then" format.', N'True'), (12072, 173, N'MCQ', N'A "Spike" is a type of story used for what?', N'Research or investigation'), (12073, 173, N'True/False', N'The "3 Cs" of user stories are Card, Conversation, Confirmation.', N'True'), (12074, 173, N'MCQ', N'What does it mean for a story to be "Testable"?', N'It is possible to verify that it has been implemented correctly');

-- Department: E-Business, Track: Business Analysis, Course: Solution Evaluation
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12075, 174, N'MCQ', N'What is the primary purpose of solution evaluation?', N'To assess the performance of and value delivered by a solution'), (12076, 174, N'True/False', N'Solution evaluation only occurs after the project is completely finished.', N'False'), (12077, 174, N'MCQ', N'What is a "Key Performance Indicator" (KPI)?', N'A measurable value that demonstrates how effectively a company is achieving key business objectives'), (12078, 174, N'MCQ', N'What is a "Go/No-Go" decision?', N'A decision point to continue with or stop a project'), (12079, 174, N'True/False', N'User Acceptance Testing (UAT) is a key part of solution evaluation.', N'True'), (12080, 174, N'MCQ', N'Which of these is a common evaluation metric?', N'Return on Investment (ROI)'), (12081, 174, N'True/False', N'The "as-is" state is compared to the "to-be" state during evaluation.', N'True'), (12082, 174, N'MCQ', N'What is a "proof of concept" (PoC)?', N'A small exercise to test a design idea'), (12083, 174, N'MCQ', N'What is a root cause analysis used for?', N'To identify the underlying cause of a problem'), (12084, 174, N'True/False', N'A solution must meet all original requirements to be considered successful.', N'False'), (12085, 174, N'MCQ', N'What is the goal of "Lessons Learned"?', N'To improve future projects'), (12086, 174, N'True/False', N'Qualitative data (e.g., user feedback) is not useful in solution evaluation.', N'False'), (12087, 174, N'MCQ', N'What does "validating" a solution mean?', N'Confirming it meets the business need'), (12088, 174, N'True/False', N'A pilot or beta test can be used to evaluate a solution with a small group of users.', N'True'), (12089, 174, N'MCQ', N'Why is it important to measure solution performance?', N'To determine if it delivered the expected value');

-- Department: E-Business, Track: Business Analysis, Course: Business Analysis Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12090, 175, N'MCQ', N'What document is created to initiate a project?', N'Project Charter or Business Case'), (12091, 175, N'True/False', N'A capstone project is meant to be a purely theoretical exercise.', N'False'), (12092, 175, N'MCQ', N'What is a "business problem statement"?', N'A clear and concise description of the issue to be solved'), (12093, 175, N'MCQ', N'Presenting your findings to stakeholders is a key part of what?', N'Communication'), (12094, 175, N'True/False', N'It''s important to define the "scope" of your project early on.', N'True'), (12095, 175, N'MCQ', N'What is a SWOT analysis used for?', N'To identify Strengths, Weaknesses, Opportunities, and Threats'), (12096, 175, N'True/False', N'A good project plan includes tasks, timelines, and resources.', N'True'), (12097, 175, N'MCQ', N'Which of the following is an example of a project deliverable?', N'A requirements document'), (12098, 175, N'MCQ', N'What is the goal of a project kickoff meeting?', N'To align the team and set expectations'), (12099, 175, N'True/False', N'Risk management is not a concern for a business analyst.', N'False'), (12100, 175, N'MCQ', N'What does it mean to "synthesize" information?', N'To combine various pieces into a coherent whole'), (12101, 175, N'True/False', N'Documentation is an unimportant, final step in a project.', N'False'), (12102, 175, N'MCQ', N'Which skill is crucial for a business analyst to have?', N'All of the above'), (12103, 175, N'True/False', N'The capstone should demonstrate a BA''s ability to see a project from start to finish.', N'True'), (12104, 175, N'MCQ', N'What is the final part of a business case?', N'Recommendation');

-- Department: E-Business, Track: Business Analysis, Course: Business Analysis Fundamentals (BABOK)
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12000, 12000, N'Business Analysis Body of Knowledge'), (12001, 12000, N'Business and Banking Open Knowledge'), (12002, 12000, N'Building a Better Outcome Kit'), (12003, 12000, N'Business Analyst Best of Klass'), (12004, 12002, N'Elicitation and Collaboration'), (12005, 12002, N'Project Management'), (12006, 12002, N'Software Development'), (12007, 12002, N'Quality Assurance'), (12008, 12003, N'A usable representation of a need'), (12009, 12003, N'A piece of code'), (12010, 12003, N'A project schedule'), (12011, 12003, N'A team member'), (12012, 12005, N'Budget'), (12013, 12005, N'Change'), (12014, 12005, N'Need'), (12015, 12005, N'Context'), (12016, 12007, N'To organize and coordinate the BA effort'), (12017, 12007, N'To write the final code'), (12018, 12007, N'To manage the project budget'), (12019, 12007, N'To test the final solution'), (12020, 12008, N'Mind Mapping'), (12021, 12008, N'Code Review'), (12022, 12008, N'Unit Testing'), (12023, 12008, N'Database Administration'), (12024, 12010, N'A restriction or limitation on a solution'), (12025, 12010, N'A feature request'), (12026, 12010, N'A project goal'), (12027, 12010, N'A team member''s role'), (12028, 12012, N'To justify the investment in a project'), (12029, 12012, N'To list all technical requirements'), (12030, 12012, N'To assign tasks to team members'), (12031, 12012, N'To document meeting minutes'), (12032, 12014, N'The process of drawing out requirements from stakeholders'), (12033, 12014, N'The process of writing software'), (12034, 12014, N'The process of testing a solution'), (12035, 12014, N'The process of deploying a solution');

-- Department: E-Business, Track: Business Analysis, Course: Stakeholder & Requirements Management
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12036, 12015, N'Responsible'), (12037, 12015, N'Required'), (12038, 12015, N'Resource'), (12039, 12015, N'Reviewed'), (12040, 12017, N'Observation'), (12041, 12017, N'Brainstorming'), (12042, 12017, N'Prototyping'), (12043, 12017, N'Document Analysis'), (12044, 12018, N'Identify Stakeholders'), (12045, 12018, N'Analyze Stakeholders'), (12046, 12018, N'Manage Stakeholders'), (12047, 12018, N'Communicate with Stakeholders'), (12048, 12020, N'To ensure requirements are met throughout the project'), (12049, 12020, N'To write the requirements once and never change them'), (12050, 12020, N'To make requirements as complex as possible'), (12051, 12020, N'To ignore stakeholder feedback'), (12052, 12022, N'The ability to track the life of a requirement'), (12053, 12022, N'The process of testing requirements'), (12054, 12022, N'The cost associated with a requirement'), (12055, 12022, N'The number of requirements in a project'), (12056, 12023, N'Conflicting stakeholder needs'), (12057, 12023, N'Stakeholders being too agreeable'), (12058, 12023, N'Having too much budget'), (12059, 12023, N'Finishing the project too early'), (12060, 12025, N'To determine which requirements are most critical'), (12061, 12025, N'To make all requirements equally important'), (12062, 12025, N'To reject all new requirements'), (12063, 12025, N'To assign requirements to developers'), (12064, 12027, N'End Users'), (12065, 12027, N'Competitors'), (12066, 12027, N'Former Employees'), (12067, 12027, N'The General Public'), (12068, 12029, N'Uncontrolled changes or growth in project scope'), (12069, 12029, N'A decrease in project scope'), (12070, 12029, N'Completing a project under budget'), (12071, 12029, N'A formal change request');

-- Department: E-Business, Track: Business Analysis, Course: Process & Data Modeling
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12072, 12030, N'Business Process Model and Notation'), (12073, 12030, N'Basic Project Management Network'), (12074, 12030, N'Business Product Model Numbering'), (12075, 12030, N'Building Process Management Nodes'), (12076, 12032, N'A decision'), (12077, 12032, N'A process step'), (12078, 12032, N'The start/end point'), (12079, 12032, N'Data storage'), (12080, 12033, N'To model the data structure of a system'), (12081, 12033, N'To show the flow of work'), (12082, 12033, N'To list project tasks'), (12083, 12033, N'To create a user interface mockup'), (12084, 12035, N'The relationship between entities (e.g., one-to-many)'), (12085, 12035, N'The color of the diagram'), (12086, 12035, N'The number of tables'), (12087, 12035, N'The name of the database'), (12088, 12037, N'A central repository of information about data'), (12089, 12037, N'A list of business rules'), (12090, 12037, N'A process flow diagram'), (12091, 12037, N'A project plan'), (12092, 12038, N'A person, place, or thing (a noun)'), (12093, 12038, N'An action (a verb)'), (12094, 12038, N'A characteristic (an adjective)'), (12095, 12038, N'A process flow'), (12096, 12040, N'A unique identifier for each record in a table'), (12097, 12040, N'A key that is not important'), (12098, 12040, N'A field that stores text'), (12099, 12040, N'A link to another table'), (12100, 12042, N'Identifying bottlenecks and inefficiencies'), (12101, 12042, N'Writing code for the application'), (12102, 12042, N'Hiring new employees'), (12103, 12042, N'Calculating the project budget'), (12104, 12044, N'Interactions between users (actors) and a system'), (12105, 12044, N'The database schema'), (12106, 12044, N'The project timeline'), (12107, 12044, N'The colors used in the user interface');

-- Department: E-Business, Track: Business Analysis, Course: Agile Business Analysis
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12108, 12045, N'Customer collaboration over contract negotiation'), (12109, 12045, N'Processes and tools over individuals and interactions'), (12110, 12045, N'Comprehensive documentation over working software'), (12111, 12045, N'Following a plan over responding to change'), (12112, 12047, N'To manage and prioritize the product backlog'), (12113, 12047, N'To manage the development team'), (12114, 12047, N'To facilitate Scrum meetings'), (12115, 12047, N'To write the code'), (12116, 12048, N'A short, time-boxed period to complete a set amount of work'), (12117, 12048, N'The entire duration of the project'), (12118, 12048, N'A type of meeting'), (12119, 12048, N'A project deliverable'), (12120, 12050, N'A prioritized list of all desired features'), (12121, 12050, N'The project plan'), (12122, 12050, N'A list of bugs'), (12123, 12050, N'The team roster'), (12124, 12052, N'To reflect on the sprint and identify improvements'), (12125, 12052, N'To plan the next sprint'), (12126, 12052, N'To demonstrate the work to stakeholders'), (12127, 12052, N'To provide daily status updates'), (12128, 12053, N'The Scrum Master'), (12129, 12053, N'The Product Owner'), (12130, 12053, N'The Development Team'), (12131, 12053, N'The Project Manager'), (12132, 12055, N'A version of a product with just enough features to be usable by early customers'), (12133, 12055, N'The final, fully-featured product'), (12134, 12055, N'A product that is not viable'), (12135, 12055, N'The most expensive version of a product'), (12136, 12057, N'A measure of the amount of work a team can complete in a sprint'), (12137, 12057, N'The speed at which the team works'), (12138, 12057, N'The number of bugs in the code'), (12139, 12057, N'The project budget'), (12140, 12059, N'A visual method for managing workflow'), (12141, 12059, N'A type of agile meeting'), (12142, 12059, N'A role on the Scrum team'), (12143, 12059, N'A software development framework');

-- Department: E-Business, Track: Business Analysis, Course: Writing User Stories
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12144, 12060, N'As a [user], I want to [action], so that [benefit]'), (12145, 12060, N'To [benefit], we need [action], for [user]'), (12146, 12060, N'The system must [action]'), (12147, 12060, N'When [user] does [action], [benefit] happens'), (12148, 12062, N'Independent'), (12149, 12062, N'Interesting'), (12150, 12062, N'Immediate'), (12151, 12062, N'Important'), (12152, 12063, N'A large user story that can be broken down into smaller stories'), (12153, 12063, N'A story that has already been completed'), (12154, 12063, N'The final story in a project'), (12155, 12063, N'A story that has been rejected'), (12156, 12065, N'The Product Owner'), (12157, 12065, N'The Scrum Master'), (12158, 12065, N'The Development Team'), (12159, 12065, N'The QA Tester'), (12160, 12067, N'To provide the value or reason for the feature'), (12161, 12067, N'To describe the technical implementation'), (12162, 12067, N'To list the acceptance criteria'), (12163, 12067, N'To assign the story to a developer'), (12164, 12068, N'Valuable'), (12165, 12068, N'Vague'), (12166, 12068, N'Visible'), (12167, 12068, N'Verified'), (12168, 12070, N'A technique to visually organize the product backlog'), (12169, 12070, N'A way to estimate story points'), (12170, 12070, N'A type of sprint meeting'), (12171, 12070, N'A method for writing code'), (12172, 12072, N'Research or investigation'), (12173, 12072, N'A bug fix'), (12174, 12072, N'A user-facing feature'), (12175, 12072, N'A design task'), (12176, 12074, N'It is possible to verify that it has been implemented correctly'), (12177, 12074, N'It has been reviewed by the test team'), (12178, 12074, N'It is small enough to fit on one card'), (12179, 12074, N'It has a high business value');

-- Department: E-Business, Track: Business Analysis, Course: Solution Evaluation
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12180, 12075, N'To assess the performance of and value delivered by a solution'), (12181, 12075, N'To plan a new project'), (12182, 12075, N'To gather initial requirements'), (12183, 12075, N'To assign tasks to the development team'), (12184, 12077, N'A measurable value that demonstrates how effectively a company is achieving key business objectives'), (12185, 12077, N'A list of all project tasks'), (12186, 12077, N'A project management methodology'), (12187, 12077, N'A user interface design pattern'), (12188, 12078, N'A decision point to continue with or stop a project'), (12189, 12078, N'A type of software test'), (12190, 12078, N'A requirements gathering technique'), (12191, 12078, N'A project budget approval'), (12192, 12080, N'Return on Investment (ROI)'), (12193, 12080, N'Number of developers'), (12194, 12080, N'Lines of code written'), (12195, 12080, N'The project start date'), (12196, 12082, N'A small exercise to test a design idea'), (12197, 12082, N'The final version of the solution'), (12198, 12082, N'A requirements document'), (12199, 12082, N'A user training session'), (12200, 12083, N'To identify the underlying cause of a problem'), (12201, 12083, N'To list all possible solutions'), (12202, 12083, N'To estimate the project cost'), (12203, 12083, N'To create a project schedule'), (12204, 12085, N'To improve future projects'), (12205, 12085, N'To assign blame for mistakes'), (12206, 12085, N'To close the project financially'), (12207, 12085, N'To write a final report'), (12208, 12087, N'Confirming it meets the business need'), (12209, 12087, N'Confirming it is free of bugs'), (12210, 12087, N'Confirming it was delivered on time'), (12211, 12087, N'Confirming it was under budget'), (12212, 12089, N'To determine if it delivered the expected value'), (12213, 12089, N'To satisfy the curiosity of the BA'), (12214, 12089, N'Because it is required by law'), (12215, 12089, N'To fill out a form');

-- Department: E-Business, Track: Business Analysis, Course: Business Analysis Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12216, 12090, N'Project Charter or Business Case'), (12217, 12090, N'Code Repository'), (12218, 12090, N'User Manual'), (12219, 12090, N'Final Invoice'), (12220, 12092, N'A clear and concise description of the issue to be solved'), (12221, 12092, N'The proposed solution'), (12222, 12092, N'A list of team members'), (12223, 12092, N'The project budget'), (12224, 12093, N'Communication'), (12225, 12093, N'Coding'), (12226, 12093, N'Debugging'), (12227, 12093, N'Database design'), (12228, 12095, N'To identify Strengths, Weaknesses, Opportunities, and Threats'), (12229, 12095, N'To create a project schedule'), (12230, 12095, N'To design a database'), (12231, 12095, N'To write user stories'), (12232, 12097, N'A requirements document'), (12233, 12097, N'A team meeting'), (12234, 12097, N'A project idea'), (12235, 12097, N'A stakeholder'), (12236, 12098, N'To align the team and set expectations'), (12237, 12098, N'To have a party'), (12238, 12098, N'To write the first line of code'), (12239, 12098, N'To close out the project'), (12240, 12100, N'To combine various pieces into a coherent whole'), (12241, 12100, N'To break down a problem into smaller parts'), (12242, 12100, N'To write code'), (12243, 12100, N'To create a schedule'), (12244, 12102, N'All of the above'), (12245, 12102, N'Communication'), (12246, 12102, N'Problem-solving'), (12247, 12102, N'Analytical thinking'), (12248, 12104, N'Recommendation'), (12249, 12104, N'Problem Statement'), (12250, 12104, N'Cost-Benefit Analysis'), (12251, 12104, N'Executive Summary');


--Track 26 Business Analysis and Intelligent Automation Development Questions ============================================================================================================

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Business Analysis & RPA Intro
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12500, 176, N'MCQ', N'What does RPA stand for?', N'Robotic Process Automation'), (12501, 176, N'True/False', N'RPA bots are physical robots that type on keyboards.', N'False'), (12502, 176, N'MCQ', N'What is the main goal of RPA?', N'To automate repetitive, rules-based tasks'), (12503, 176, N'True/False', N'Business Analysis is not important for a successful RPA project.', N'False'), (12504, 176, N'MCQ', N'Which is a key benefit of RPA?', N'Increased efficiency'), (12505, 176, N'MCQ', N'What is an "attended" bot?', N'A bot triggered by a user on their desktop'), (12506, 176, N'True/False', N'RPA is the exact same as Artificial Intelligence (AI).', N'False'), (12507, 176, N'MCQ', N'What is the BA''s primary role in RPA?', N'Identifying and documenting processes for automation'), (12508, 176, N'True/False', N'RPA can only interact with modern, API-based applications.', N'False'), (12509, 176, N'MCQ', N'What is a "Process Design Document" (PDD)?', N'A detailed blueprint for building the automation'), (12510, 176, N'True/False', N'RPA is ideal for tasks that require complex human judgment.', N'False'), (12511, 176, N'MCQ', N'Which is NOT a major RPA vendor?', N'Oracle'), (12512, 176, N'True/False', N'RPA can help reduce the number of human errors.', N'True'), (12513, 176, N'MCQ', N'What is an "unattended" bot?', N'A bot that runs scheduled tasks on a server'), (12514, 176, N'True/False', N'The first step in any RPA project is to start coding.', N'False');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Process Discovery for Automation
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12515, 177, N'MCQ', N'What is Process Discovery?', N'The act of identifying and analyzing business processes'), (12516, 177, N'True/False', N'All processes in a business are good candidates for automation.', N'False'), (12517, 177, N'MCQ', N'What is a key trait of a good automation candidate?', N'Rules-based and repetitive'), (12518, 177, N'True/False', N'"Process mining" uses system event logs to discover processes.', N'True'), (12519, 177, N'MCQ', N'What is a "happy path" in a process?', N'The standard flow with no errors or exceptions'), (12520, 177, N'True/False', N'Exception handling is not an important part of automation design.', N'False'), (12521, 177, N'MCQ', N'Which technique involves BAs watching employees perform their tasks?', N'Observation'), (12522, 177, N'MCQ', N'What is the purpose of a "Feasibility Analysis"?', N'To determine if an automation is technically and financially viable'), (12523, 177, N'True/False', N'A process with many exceptions is a very simple automation candidate.', N'False'), (12524, 177, N'MCQ', N'What is "Task Capture"?', N'A tool that records user actions to help map a process'), (12525, 177, N'True/False', N'Process discovery is a one-time activity that ends before development.', N'False'), (12526, 177, N'MCQ', N'What is a PDD?', N'Process Design Document'), (12527, 177, N'MCQ', N'What metric measures the financial benefit of an automation?', N'Return on Investment (ROI)'), (12528, 177, N'True/False', N'Processes that use unstructured data are typically easy to automate.', N'False'), (12529, 177, N'True/False', N'Stakeholder workshops are a good technique for discovering processes.', N'True');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: UiPath Studio Fundamentals
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12530, 178, N'MCQ', N'What is the main component of UiPath for building bots?', N'UiPath Studio'), (12531, 178, N'True/False', N'A "Sequence" in UiPath runs activities in a linear, sequential order.', N'True'), (12532, 178, N'MCQ', N'What is a "Flowchart" in UiPath used for?', N'For more complex logic with multiple decisions'), (12533, 178, N'MCQ', N'What does the "Type Into" activity do?', N'Simulates keyboard input'), (12534, 178, N'True/False', N'UiPath Studio can only use C# for expressions.', N'False'), (12535, 178, N'MCQ', N'What is a "Selector"?', N'An "address" used to identify a specific UI element'), (12536, 178, N'True/False', N'A dynamic selector is always less reliable than a static one.', N'False'), (12537, 178, N'MCQ', N'What is "Orchestrator" used for?', N'To manage, deploy, and schedule bots'), (12538, 178, N'True/False', N'"Web scraping" is the act of extracting data from websites.', N'True'), (12539, 178, N'MCQ', N'Which activity would you use to read an Excel file?', N'Read Range'), (12540, 178, N'True/False', N'The "Click" activity can only be used on web pages.', N'False'), (12541, 178, N'MCQ', N'What is a "Variable" used for?', N'To store data temporarily'), (12542, 178, N'MCQ', N'What is the purpose of the "Attach Window" activity?', N'To attach the bot to a specific application window'), (12543, 178, N'True/False', N'UiPath cannot automate desktop applications.', N'False'), (12544, 178, N'True/False', N'The "Debug" feature allows you to run your process step-by-step.', N'True');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Building & Managing Automations
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12545, 179, N'MCQ', N'What is the REFramework?', N'A robust, pre-built template for transactional automations'), (12546, 179, N'True/False', N'Hardcoding credentials directly into the bot''s code is a security best practice.', N'False'), (12547, 179, N'MCQ', N'What is a "Queue" in Orchestrator used for?', N'To store and manage transaction items'), (12548, 179, N'MCQ', N'What is a "Dispatcher" bot?', N'A bot that adds items to a queue'), (12549, 179, N'True/False', N'A "Performer" bot is a bot that processes items from a queue.', N'True'), (12550, 179, N'MCQ', N'What is a "Business Exception" in REFramework?', N'A predictable error, e.g., "invalid data"'), (12551, 179, N'True/False', N'An "Application Exception" is a predictable error, like an invalid invoice.', N'False'), (12552, 179, N'MCQ', N'What is a configuration file (e.g., Config.xlsx) used for?', N'To store settings and assets externally'), (12553, 179, N'True/False', N'You should not include logging in your automation.', N'False'), (12554, 179, N'MCQ', N'What is an "Asset" in Orchestrator?', N'A centrally stored variable, like a credential or URL'), (12555, 179, N'True/False', N'A "Try-Catch" block is used for error handling.', N'True'), (12556, 179, N'MCQ', N'What is source control (like Git) used for?', N'To manage and track changes to the project code'), (12557, 179, N'True/False', N'It is impossible to run multiple bots in parallel.', N'False'), (12558, 179, N'MCQ', N'What does "scalability" mean in automation?', N'The ability to handle an increasing workload'), (12559, 179, N'True/False', N'The REFramework includes built-in exception handling and logging.', N'True');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Intelligent Document Processing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12560, 180, N'MCQ', N'What is "Intelligent Document Processing" (IDP)?', N'Using AI to extract data from documents'), (12561, 180, N'True/False', N'IDP is just another name for traditional OCR.', N'False'), (12562, 180, N'MCQ', N'What does "OCR" stand for?', N'Optical Character Recognition'), (12563, 180, N'True/False', N'IDP can only process fully structured documents like forms.', N'False'), (12564, 180, N'MCQ', N'Which of these is an "unstructured" document?', N'An email or contract'), (12565, 180, N'MCQ', N'What is "data extraction" in IDP?', N'Identifying and pulling specific data fields from a document'), (12566, 180, N'True/False', N'"Classification" is the step of identifying the document type (e.g., invoice vs. receipt).', N'True'), (12567, 180, N'MCQ', N'What is "straight-through processing" (STP)?', N'Processing a document with no human intervention'), (12568, 180, N'True/False', N'A "confidence score" indicates how certain the AI is about its extraction.', N'True'), (12569, 180, N'MCQ', N'What is "Human-in-the-Loop"?', N'A human validates or corrects the AI''s output'), (12570, 180, N'True/False', N'IDP models get worse as they process more documents.', N'False'), (12571, 180, N'MCQ', N'Which UiPath product is used for IDP?', N'Document Understanding'), (12572, 180, N'MCQ', N'What is a "taxonomy" in document processing?', N'A classification schema for documents'), (12573, 180, N'True/False', N'Modern IDP systems are unable to read handwritten text.', N'False'), (12574, 180, N'True/False', N'The main benefit of IDP is reducing manual data entry.', N'True');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: AI & Chatbots in Automation
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12575, 181, N'MCQ', N'What is a "chatbot"?', N'A program that simulates human conversation'), (12576, 181, N'True/False', N'A simple, rules-based chatbot can understand complex, ambiguous questions.', N'False'), (12577, 181, N'MCQ', N'What does "NLP" stand for?', N'Natural Language Processing'), (12578, 181, N'True/False', N'The "intent" in a chatbot refers to what the user is trying to achieve.', N'True'), (12579, 181, N'MCQ', N'What is an "entity" in NLP?', N'A specific piece of data, such as a date, city, or name'), (12580, 181, N'MCQ', N'How can AI enhance traditional RPA?', N'By handling tasks that require human-like judgment'), (12581, 181, N'True/False', N'An "AI-powered" chatbot uses machine learning to understand and respond.', N'True'), (12582, 181, N'MCQ', N'What is "sentiment analysis"?', N'Determining the emotional tone (positive, negative, neutral) of text'), (12583, 181, N'True/False', N'Chatbots can be integrated with RPA bots to execute tasks.', N'True'), (12584, 181, N'MCQ', N'Which is NOT a primary benefit of using chatbots?', N'Replacing all human customer service agents'), (12585, 181, N'True/False', N'AI models must be "trained" on data to learn patterns.', N'True'), (12586, 181, N'MCQ', N'What is "Conversational AI"?', N'Technology that allows users to interact with systems using natural language'), (12587, 178, N'True/False', N'AI can be used in RPA for tasks like image recognition.', N'True'), (12588, 178, N'MCQ', N'What is a common use case for AI in automation?', N'All of the above'), (12589, 178, N'True/False', N'AI in automation is only for very large, technical companies.', N'False');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Intelligent Automation Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (12590, 182, N'MCQ', N'What is the first step of a capstone project?', N'Defining the business problem and scope'), (12591, 182, N'True/False', N'The PDD (Process Design Document) is a critical deliverable.', N'True'), (12592, 182, N'MCQ', N'What is the purpose of UAT?', N'User Acceptance Testing'), (12593, 182, N'MCQ', N'A good capstone presentation should always include what?', N'A live demo and the calculated benefits'), (12594, 182, N'True/False', N'It is a best practice to hardcode all file paths and credentials.', N'False'), (12595, 182, N'MCQ', N'What is the role of the BA in the capstone?', N'To define requirements, scope, and test cases'), (12596, 182, N'True/False', N'A capstone project should not include any error handling.', N'False'), (12597, 182, N'MCQ', N'What is a key metric to report on in your capstone?', N'Time saved or ROI'), (12598, 182, N'True/False', N'A "Go-Live" plan details the steps for deploying the bot to production.', N'True'), (12599, 182, N'MCQ', N'What is a "hypercare" period?', N'A short period of intensive support just after go-live'), (12600, 182, N'True/False', N'The REFramework is a bad choice for a capstone project.', N'False'), (12601, 182, N'MCQ', N'What is a "Solution Design Document" (SDD)?', N'A technical document explaining how the bot is built'), (12602, 182, N'MCQ', N'Why is a "Lessons Learned" session important?', N'To identify what went well and what could be improved'), (12603, 182, N'True/False', N'The capstone should ideally solve a real-world business problem.', N'True'), (12604, 182, N'True/False', N'Once the bot is live, the project is completely finished forever.', N'False');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Business Analysis & RPA Intro
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12500, 12500, N'Robotic Process Automation'), (12501, 12500, N'Repetitive Personal Assistant'), (12502, 12500, N'Rules-based Program Automation'), (12503, 12500, N'Robotic Personal Computer'), (12504, 12502, N'To automate repetitive, rules-based tasks'), (12505, 12502, N'To design websites'), (12506, 12502, N'To create physical robots'), (12507, 12502, N'To replace all human jobs'), (12508, 12504, N'Increased efficiency'), (12509, 12504, N'Increased need for manual work'), (12510, 12504, N'Higher error rates'), (12511, 12504, N'Slower processing times'), (12512, 12505, N'A bot triggered by a user on their desktop'), (12513, 12505, N'A bot that runs on a schedule'), (12514, 12505, N'A physical robot'), (12515, 12505,  N'A bot that requires no setup'), (12516, 12507, N'Identifying and documenting processes for automation'), (12517, 12507, N'Writing the final code'), (12518, 12507, N'Managing the company''s database'), (12519, 12507, N'Hiring new employees'), (12520, 12509, N'A detailed blueprint for building the automation'), (12521, 12509, N'A project budget'), (12522, 12509, N'A user''s password file'), (12523, 12509, N'A list of project managers'), (12524, 12511, N'Oracle'), (12525, 12511, N'UiPath'), (12526, 12511, N'Automation Anywhere'), (12527, 12511, N'Blue Prism'), (12528, 12513, N'A bot that runs scheduled tasks on a server'), (12529, 12513, N'A bot that watches the user'), (12530, 12513, N'A bot that only works at night'), (12531, 12513, N'A bot that is offline');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Process Discovery for Automation
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12532, 12515, N'The act of identifying and analyzing business processes'), (12533, 12515, N'The act of coding a bot'), (12534, 12515, N'The act of testing a bot'), (12535, 12515, N'The act of deploying a bot'), (12536, 12517, N'Rules-based and repetitive'), (12537, 12517, N'Requires human creativity'), (12538, 12517, N'Changes frequently'), (12539, 12517, N'Has unstructured inputs'), (12540, 12519, N'The standard flow with no errors or exceptions'), (12541, 12519, N'The part of the process that always fails'), (12542, 12519, N'The most complex path'), (12543, 12519, N'A path that is not documented'), (12544, 12521, N'Observation'), (12545, 12521, N'Process Mining'), (12546, 12521, N'Data Modeling'), (12547, 12521, N'Code Review'), (12548, 12522, N'To determine if an automation is technically and financially viable'), (12549, 12522, N'To calculate the final ROI'), (12550, 12522, N'To write the PDD'), (12551, 12522, N'To interview stakeholders'), (12552, 12524, N'A tool that records user actions to help map a process'), (12553, 12524, N'A tool for writing code'), (12554, 12524, N'A tool for deploying bots'), (12555, 12524, N'A tool for managing users'), (12556, 12526, N'Process Design Document'), (12557, 12526, N'Project Deployment D'), (12558, 12526, N'People Data Document'), (12559, 12526, N'Process Discovery Database'), (12560, 12527, N'Return on Investment (ROI)'), (12561, 12527, N'Process Completion Time (PCT)'), (12562, 12527, N'Net Promoter Score (NPS)'), (12563, 12527, N'Key Performance Indicator (KPI)');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: UiPath Studio Fundamentals
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12564, 12530, N'UiPath Studio'), (12565, 12530, N'UiPath Orchestrator'), (12566, 12530, N'UiPath Assistant'), (12567, 12530, N'UiPath AI Center'), (12568, 12532, N'For more complex logic with multiple decisions'), (12569, 12532, N'For simple, linear tasks only'), (12570, 12532, N'For storing variables'), (12571, 12532, N'For logging errors'), (12572, 12533, N'Simulates keyboard input'), (12573, 12533, N'Simulates a mouse click'), (12574, 12533, N'Reads text from the screen'), (12575, 12533, N'Attaches to a window'), (12576, 12535, N'An "address" used to identify a specific UI element'), (12577, 12535, N'A type of variable'), (12578, 12535, N'A container for activities'), (12579, 12535, N'An error handling block'), (12580, 12537, N'To manage, deploy, and schedule bots'), (12581, 12537, N'To build automation workflows'), (12582, 12537, N'To extract data from documents'), (12583, 12537, N'To run bots on a user''s desktop'), (12584, 12539, N'Read Range'), (12585, 12539, N'Type Into'), (12586, 12539, N'Get Text'), (12587, 12539, N'Write Line'), (12588, 12541, N'To store data temporarily'), (12589, 12541, N'To select UI elements'), (12590, 12541, N'To manage project dependencies'), (12591, 12541, N'To publish a project'), (12592, 12542, N'To attach the bot to a specific application window'), (12593, 12542, N'To create a user interface'), (12594, 12542, N'To send an email'), (12595, 12542, N'To loop through a list');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Building & Managing Automations
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12596, 12545, N'A robust, pre-built template for transactional automations'), (12597, 12545, N'A simple sequence for testing'), (12598, 12545, N'A tool for designing UI elements'), (12599, 12545, N'A framework for building websites'), (12600, 12547, N'To store and manage transaction items'), (12601, 12547, N'To store bot source code'), (12602, 12547, N'To display a user interface'), (12603, 12547, N'To log errors'), (12604, 12548, N'A bot that adds items to a queue'), (12605, 12548, N'A bot that processes items from a queue'), (12606, 12548, N'A bot that is currently turned off'), (12607, 12548, N'A bot that manages user licenses'), (12608, 12550, N'A predictable error, e.g., "invalid data"'), (12609, 12550, N'An unexpected system crash'), (12610, 12550, N'A successful transaction'), (12611, 12550, N'A log message'), (12612, 12552, N'To store settings and assets externally'), (12613, 12552, N'To store the main automation logic'), (12614, 12552, N'To store transaction data'), (12615, 12552, N'To store user interface selectors'), (12616, 12554, N'A centrally stored variable, like a credential or URL'), (12617, 12554, N'A piece of source code'), (12618, 12554, N'A UI element selector'), (12619, 12554, N'A log file'), (12620, 12556, N'To manage and track changes to the project code'), (12621, 12556, N'To control the bot''s schedule'), (12622, 12556, N'To handle application exceptions'), (12623, 12556, N'To store transaction items'), (12624, 12558, N'The ability to handle an increasing workload'), (12625, 12558, N'The ability to run on a user''s desktop'), (12626, 12558, N'The physical size of the bot'), (12627, 12558, N'The programming language used');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Intelligent Document Processing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12628, 12560, N'Using AI to extract data from documents'), (12629, 12560, N'Manually typing data from documents'), (12630, 12560, N'A system for storing physical documents'), (12631, 12560, N'A standard RPA process'), (12632, 12562, N'Optical Character Recognition'), (12633, 12562, N'Online Character Reader'), (12634, 12562, N'Object Code Reader'), (12635, 12562, N'Operational Control Room'), (12636, 12564, N'An email or contract'), (12637, 12564, N'A fillable PDF form'), (12638, 12564, N'A tax form'), (12639, 12564, N'A database table'), (12640, 12565, N'Identifying and pulling specific data fields from a document'), (12641, 12565, N'Deleting the document'), (12642, 12565, N'Classifying the document type'), (12643, 12565, N'Converting the document to a PDF'), (12644, 12567, N'Processing a document with no human intervention'), (12645, 12567, N'Processing that requires multiple humans'), (12646, 12567, N'A process that fails every time'), (12647, 12567, N'A process that is very slow'), (12648, 12569, N'A human validates or corrects the AI''s output'), (12649, 12569, N'A human is replaced by a robot'), (12650, 12569, N'A human performs the entire task manually'), (12651, 12569, N'A computer loop that never ends'), (12652, 12571, N'Document Understanding'), (12653, 12571, N'UiPath Assistant'), (12654, 12571, N'UiPath Studio'), (12655, 12571, N'UiPath Orchestrator'), (12656, 12572, N'A classification schema for documents'), (12657, 12572, N'A list of all users'), (12658, 12572, N'A project''s code repository'), (12659, 12572, N'An economic principle');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: AI & Chatbots in Automation
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12660, 12575, N'A program that simulates human conversation'), (12661, 12575, N'A physical robot that talks'), (12662, 12575, N'A tool for sending spam email'), (12663, 12575, N'A type of RPA bot'), (12664, 12577, N'Natural Language Processing'), (12665, 12577, N'New Language Program'), (12666, 12577, N'Network Logic Protocol'), (12667, 12577, N'Natural Logic Programming'), (12668, 12579, N'A specific piece of data, such as a date, city, or name'), (12669, 12579, N'The user''s main goal'), (12670, 12579, N'The entire chatbot application'), (12671, 12579, N'A type of database'), (12672, 12580, N'By handling tasks that require human-like judgment'), (12673, 12580, N'By making the bot type faster'), (12674, 12580, N'By replacing the need for Orchestrator'), (12675, 12580, N'It cannot enhance RPA'), (12676, 12582, N'Determining the emotional tone (positive, negative, neutral) of text'), (12677, 12582, N'Analyzing the security of a system'), (12678, 12582, N'Calculating a financial ROI'), (12679, 12582, N'Extracting data from an image'), (12680, 12584, N'Replacing all human customer service agents'), (12681, 12584, N'Providing 24/7 availability'), (12682, 12584, N'Handling multiple conversations at once'), (12683, 12584, N'Providing instant responses'), (12684, 12586, N'Technology that allows users to interact with systems using natural language'), (12685, 12586, N'A specific type of RPA bot'), (12686, 12586, N'A method for documenting processes'), (12687, 12586, N'A project management style'), (12688, 12588, N'All of the above'), (12689, 12588, N'Intelligent Document Processing'), (12690, 12588, N'Sentiment Analysis'), (12691, 12588, N'Image Recognition');

-- Department: E-Business, Track: Business Analysis and Intelligent Automation Development, Course: Intelligent Automation Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (12692, 12590, N'Defining the business problem and scope'), (12693, 12590, N'Writing the automation code'), (12694, 12590, N'Deploying the bot to production'), (12695, 12590, N'Holding the "lessons learned" meeting'), (12696, 12592, N'User Acceptance Testing'), (12697, 12592, N'Universal Automation Tool'), (12698, 12592, N'User Account Transfer'), (12699, 12592, N'UiPath Automation Test'), (12700, 12593, N'A live demo and the calculated benefits'), (12701, 12593, N'A detailed code review'), (12702, 12593, N'A list of all variables used'), (12703, 12593, N'The project budget'), (12704, 12595, N'To define requirements, scope, and test cases'), (12705, 12595, N'To write all of the automation code'), (12706, 12595, N'To manage the Orchestrator server'), (12707, 12595, N'To provide technical support after go-live'), (12708, 12597, N'Time saved or ROI'), (12709, 12597, N'The number of activities used'), (12710, 12597, N'The color scheme of the PDD'), (12711, 12597, N'The BA''s name'), (12712, 12599, N'A short period of intensive support just after go-live'), (12713, 12599, N'The period when the bot is being built'), (12714, 12599, N'A type of automation software'), (12715, 12599, N'The final project presentation'), (12716, 12601, N'A technical document explaining how the bot is built'), (12717, 12601, N'A business document explaining why the bot is needed'), (12718, 12601, N'A test plan for UAT'), (12719, 12601, N'A list of project stakeholders'), (12720, 12602, N'To identify what went well and what could be improved'), (12721, 12602, N'To assign blame for project failures'), (12722, 12602, N'To formally close the project budget'), (12723, 12602, N'To demo the bot to executives');


--Track 27 Social Media Marketing Questions ============================================================================================================

-- Department: E-Business, Track: Social Media Marketing, Course: Social Media Strategy & Content
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (13000, 183, N'MCQ', N'What is a S.M.A.R.T. goal?', N'Specific, Measurable, Achievable, Relevant, Time-bound'), (13001, 183, N'True/False', N'A buyer persona is a fictional profile of your ideal customer.', N'True'), (13002, 183, N'MCQ', N'What is a "content pillar"?', N'A core theme or topic for your content'), (13003, 183, N'MCQ', N'What is "evergreen content"?', N'Content that remains relevant over a long period'), (13004, 183, N'True/False', N'You should post the exact same message across all social media platforms.', N'False'), (13005, 183, N'MCQ', N'What is a "content calendar"?', N'A schedule for when and where you post content'), (13006, 183, N'True/False', N'A brand''s "tone of voice" refers to its visual design.', N'False'), (13007, 183, N'MCQ', N'What is User-Generated Content (UGC)?', N'Content created by your audience or followers'), (13008, 183, N'True/False', N'A call-to-action (CTA) is the first step in a social media strategy.', N'False'), (13009, 183, N'MCQ', N'What does A/B testing involve?', N'Comparing two versions of a post to see which performs better'), (13010, 183, N'MCQ', N'What is the "Awareness" stage of the marketing funnel?', N'When a customer first discovers your brand'), (13011, 183, N'True/False', N'A good strategy focuses only on making sales in every post.', N'False'), (13012, 183, N'MCQ', N'What is a key benefit of a content calendar?', N'Ensuring consistency and planning'), (13013, 183, N'True/False', N'Hashtags are a way to categorize content and improve discoverability.', N'True'), (13014, 183, N'True/False', N'Your social media goals should be vague to allow for flexibility.', N'False');

-- Department: E-Business, Track: Social Media Marketing, Course: Community Management
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (13015, 184, N'MCQ', N'What is a key role of a community manager?', N'Engaging with the audience and building relationships'), (13016, 184, N'True/False', N'You should immediately delete all negative comments.', N'False'), (13017, 184, N'MCQ', N'What is "social listening"?', N'Monitoring social media for mentions of your brand or keywords'), (13018, 184, N'MCQ', N'What is a "brand advocate"?', N'A loyal customer who promotes your brand for free'), (13019, 184, N'True/False', N'Community management is a purely reactive job.', N'False'), (13020, 184, N'MCQ', N'What is the best way to handle a public customer complaint?', N'Respond publicly with empathy and offer to take it private'), (13021, 184, N'True/False', N'An "escalation plan" defines how to handle a crisis or serious issue.', N'True'), (13022, 184, N'MCQ', N'What is a "troll"?', N'A user who posts inflammatory content to provoke a reaction'), (13023, 184, N'True/False', N'A good community manager speaks *at* the audience, not *with* them.', N'False'), (13024, 184, N'MCQ', N'What is a key benefit of a strong online community?', N'Increased brand loyalty and customer feedback'), (13025, 184, N'MCQ', N'Which is a proactive community management task?', N'Asking questions or starting conversations'), (13026, 184, N'True/False', N'Having a clear "Community Guidelines" document is important.', N'True'), (13027, 184, N'MCQ', N'What is a "FAQ" page used for?', N'To answer common questions proactively'), (13028, 184, N'True/False', N'It is important to maintain a consistent brand voice in all interactions.', N'True'), (13029, 184, N'True/False', N'Ignoring your community is a valid strategy for growth.', N'False');

-- Department: E-Business, Track: Social Media Marketing, Course: Facebook, Instagram & LinkedIn Ads
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (13030, 185, N'MCQ', N'What is the highest level of the Meta ad structure?', N'Campaign'), (13031, 185, N'True/False', N'Instagram is owned by Google.', N'False'), (13032, 185, N'MCQ', N'Which platform is generally considered best for B2B advertising?', N'LinkedIn'), (13033, 185, N'MCQ', N'What is a "Lookalike Audience"?', N'An audience Meta finds that is similar to your existing customers'), (13034, 185, N'True/False', N'The "Ad Set" level controls the budget, schedule, and targeting.', N'True'), (13035, 185, N'MCQ', N'What is "retargeting"?', N'Showing ads to users who have already visited your website'), (13036, 185, N'True/False', N'LinkedIn ads are usually cheaper than Facebook ads.', N'False'), (13037, 185, N'MCQ', N'What does "CPC" stand for?', N'Cost Per Click'), (13038, 185, N'MCQ', N'What is a "Carousel Ad"?', N'An ad with multiple scrollable images or videos'), (13039, 185, N'True/False', N'The Meta Pixel is a tool for designing ad images.', N'False'), (13040, 185, N'MCQ', N'What does LinkedIn targeting allow you to use?', N'Job Title, Company Size, and Industry'), (13041, 185, N'True/False', N'You must have a Facebook Page to run ads on Instagram.', N'True'), (13042, 185, N'MCQ', N'What are "Impressions"?', N'The total number of times an ad was shown on screen'), (13043, 185, N'True/False', N'A/B testing is used to compare different ad versions.', N'True'), (13044, 185, N'True/False', N'You can only use video ads on Instagram.', N'False');

-- Department: E-Business, Track: Social Media Marketing, Course: Video Marketing (YouTube/TikTok)
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (13045, 186, N'MCQ', N'Which platform is built around short-form vertical video and trends?', N'TikTok'), (13046, 186, N'True/False', N'YouTube is primarily used for short, disappearing video content.', N'False'), (13047, 186, N'MCQ', N'What is "watch time" on YouTube?', N'The total amount of time viewers have spent watching your videos'), (13048, 186, N'MCQ', N'What is the "For You" page on TikTok?', N'A personalized feed of videos curated by an algorithm'), (13049, 186, N'True/False', N'A video "hook" refers to the final call-to-action.', N'False'), (13050, 186, N'MCQ', N'What is a key component of YouTube SEO?', N'Using keywords in the video title and description'), (13051, 186, N'True/False', N'A YouTube "thumbnail" has very little impact on click-through rate.', N'False'), (13052, 186, N'MCQ', N'What is a TikTok "Duet"?', N'A feature to create a video side-by-side with another user''s video'), (13053, 186, N'True/False', N'Live streaming is a form of video marketing.', N'True'), (13054, 186, N'MCQ', N'What is the purpose of a YouTube "End Screen"?', N'To suggest other videos or playlists to the viewer'), (13055, 186, N'True/False', N'TikTok videos cannot use popular music due to copyright.', N'False'), (13056, 186, N'MCQ', N'Which content style is generally more authentic for TikTok?', N'Lo-fi, unpolished, and trend-based'), (13057, 186, N'True/False', N'Storytelling is an important element of video marketing.', N'True'), (13058, 186, N'MCQ', N'What is a YouTube "Playlist"?', N'A curated collection of videos'), (13059, 186, N'True/False', N'Video marketing is only effective for B2C brands.', N'False');

-- Department: E-Business, Track: Social Media Marketing, Course: Analytics & Reporting
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (13060, 187, N'MCQ', N'What does "Reach" measure?', N'The number of unique users who saw your content'), (13061, 187, N'True/False', N'"Impressions" are the same as "Reach".', N'False'), (13062, 187, N'MCQ', N'What is "Engagement Rate"?', N'A metric of how many people interacted with your post'), (13063, 187, N'True/False', N'A "vanity metric" is a metric that is easy to measure but doesn''t show business value.', N'True'), (13064, 187, N'MCQ', N'What does "CTR" stand for?', N'Click-Through Rate'), (13065, 187, N'MCQ', N'What is a "KPI"?', N'Key Performance Indicator'), (13066, 187, N'True/False', N'A good report should just be a list of data points without any insights.', N'False'), (13067, 187, N'MCQ', N'What is a "UTM parameter"?', N'A tag added to a URL to track its source and performance'), (13068, 187, N'True/False', N'Google Analytics cannot track traffic from social media.', N'False'), (13069, 187, N'MCQ', N'What is "Sentiment Analysis"?', N'Determining the emotional tone (positive, negative, neutral) of brand mentions'), (13070, 187, N'MCQ', N'What does "Share of Voice" measure?', N'Your brand''s presence compared to your competitors'), (13071, 187, N'True/False', N'Conversion rate measures how many people "liked" your post.', N'False'), (13072, 187, N'MCQ', N'What does "ROI" stand for?', N'Return on Investment'), (13073, 187, N'True/False', N'"Likes" are the most important metric for proving business value.', N'False'), (13074, 187, N'True/False', N'Reporting should be done at regular intervals (e.g., weekly, monthly).', N'True');

-- Department: E-Business, Track: Social Media Marketing, Course: SEO & Email Marketing Basics
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (13075, 188, N'MCQ', N'What does "SEO" stand for?', N'Search Engine Optimization'), (13076, 188, N'True/False', N'"On-page" SEO refers to building backlinks from other websites.', N'False'), (13077, 188, N'MCQ', N'What is a "backlink"?', N'A link from an external website to your website'), (13078, 188, N'MCQ', N'What is a "keyword"?', N'A word or phrase users type into search engines'), (13079, 188, N'True/False', N'A good email "subject line" is critical for open rates.', N'True'), (13080, 188, N'MCQ', N'What is "email segmentation"?', N'Dividing your email list into smaller, targeted groups'), (13081, 188, N'True/False', N'Social media activity has no impact on SEO.', N'False'), (13082, 188, N'MCQ', N'What is an "email open rate"?', N'The percentage of recipients who opened your email'), (13083, 188, N'True/False', N'Buying email lists is a recommended best practice.', N'False'), (13084, 188, N'MCQ', N'What is a "meta description"?', N'A short summary of a webpage shown in search results'), (13085, 188, N'MCQ', N'What is a "drip campaign"?', N'A series of automated emails sent on a schedule'), (13086, 188, N'True/False', N'SEO is a one-time task that you set and forget.', N'False'), (13087, 188, N'MCQ', N'What does "A/B testing" an email mean?', N'Sending two variations to see which performs better'), (13088, 188, N'True/False', N'"Off-page" SEO refers to optimizing elements on your website, like title tags.', N'False'), (13089, 188, N'True/False', N'An "opt-in" is when a user gives you permission to email them.', N'True');

-- Department: E-Business, Track: Social Media Marketing, Course: Social Media Campaign Capstone
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES (13090, 189, N'MCQ', N'What is the first step in planning a capstone campaign?', N'Defining clear, measurable goals and KPIs'), (13091, 189, N'True/False', N'A capstone project should not have a set budget.', N'False'), (13092, 189, N'MCQ', N'What is a "Gantt chart" often used for?', N'Visualizing the project timeline and tasks'), (13093, 189, N'MCQ', N'What is a key "deliverable" of a capstone project?', N'A final report analyzing campaign results'), (13094, 189, N'True/False', N'You should choose your target audience *after* creating your content.', N'False'), (13095, 189, N'MCQ', N'What is a campaign "theme"?', N'The overarching creative idea or message'), (13096, 189, N'True/False', N'A campaign "landing page" is a user''s social media profile.', N'False'), (13097, 189, N'MCQ', N'What is the purpose of a "post-campaign analysis"?', N'To measure results against KPIs and find lessons learned'), (13098, 189, N'True/False', N'A unique campaign hashtag can help track user-generated content.', N'True'), (13099, 189, N'MCQ', N'Why is a project plan important for a capstone?', N'It keeps the project organized, on time, and on budget'), (13100, 189, N'MCQ', N'What is a "contingency plan"?', N'A plan for what to do if things go wrong'), (13101, 189, N'True/False', N'A/B testing is not useful in a capstone campaign.', N'False'), (13102, 189, N'MCQ', N'What does a good capstone presentation include?', N'All of the above'), (13103, 189, N'True/False', N'The capstone project is meant to demonstrate your ability to execute a full strategy.', N'True'), (13104, 189, N'True/False', N'Once the campaign is launched, no more monitoring is needed.', N'False');

-- Department: E-Business, Track: Social Media Marketing, Course: Social Media Strategy & Content
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (13000, 13000, N'Simple, Meaningful, Active, Real, Tested'), (13001, 13000, N'Specific, Measurable, Achievable, Relevant, Time-bound'), (13002, 13000, N'Social, Mobile, Automated, Responsive, Targeted'), (13003, 13000, N'Specific, Measurable, Actionable, Right, Timely'), (13004, 13002, N'A core theme or topic for your content'), (13005, 13002, N'The first post you ever made'), (13006, 13002, N'A post with many "likes"'), (13007, 13002, N'A specific type of ad'), (13008, 13003, N'Content that expires after 24 hours'), (13009, 13003, N'Content that remains relevant over a long period'), (13010, 13003, N'Content that is about trees'), (13011, 13003, N'A video blog'), (13012, 13005, N'A schedule for when and where you post content'), (13013, 13005, N'A list of your followers'), (13014, 13005, N'A tool for designing images'), (13015, 13005, N'A report of your analytics'), (13016, 13007, N'Content created by your audience or followers'), (13017, 13007, N'Content you pay an influencer to make'), (13018, 13007, N'Content created by your employees'), (13019, 13007, N'A video ad'), (13020, 13009, N'Posting the same content twice'), (13021, 13009, N'Deleting a post that performs badly'), (13022, 13009, N'Comparing two versions of a post to see which performs better'), (13023, 13009, N'Testing your website''s speed'), (13024, 13010, N'When a customer first discovers your brand'), (13025, 13010, N'When a customer makes a purchase'), (13026, 13010, N'When a customer becomes a loyal advocate'), (13027, 13010, N'When a customer stops following you'), (13028, 13012, N'It guarantees your posts will go viral'), (13029, 13012, N'It automatically writes posts for you'), (13030, 13012, N'It ensures consistency and planning'), (13031, 13012, N'It tracks your budget');

-- Department: E-Business, Track: Social Media Marketing, Course: Community Management
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (13032, 13015, N'Designing ad graphics'), (13033, 13015, N'Writing code for the website'), (13034, 13015, N'Engaging with the audience and building relationships'), (13035, 13015, N'Managing the company''s finances'), (13036, 13017, N'Monitoring social media for mentions of your brand or keywords'), (13037, 13017, N'Only listening to positive feedback'), (13038, 13017, N'Posting content without reading comments'), (13039, 13017, N'A feature on Spotify'), (13040, 13018, N'A loyal customer who promotes your brand for free'), (13041, 13018, N'A paid influencer'), (13042, 13018, N'A customer who complains'), (13043, 13018, N'A member of your marketing team'), (13044, 13020, N'Delete the comment and block the user'), (13045, 13020, N'Ignore the comment completely'), (13046, 13020, N'Respond publicly with empathy and offer to take it private'), (13047, 13020, N'Argue with the customer publicly'), (13048, 13022, N'A loyal fan'), (13049, 13022, N'A user who posts inflammatory content to provoke a reaction'), (13050, 13022, N'A potential customer'), (13051, 13022, N'A community manager from a competitor'), (13052, 13024, N'Increased brand loyalty and customer feedback'), (13053, 13024, N'Higher advertising costs'), (13054, 13024, N'Less time for the marketing team'), (13055, 13024, N'It has no benefits'), (13056, 13025, N'Asking questions or starting conversations'), (13057, 13025, N'Responding to a complaint'), (13058, 13025, N'Deleting spam'), (13059, 13025, N'Reporting a bug'), (13060, 13027, N'To list your company''s employees'), (13061, 13027, N'To answer common questions proactively'), (13062, 13027, N'To showcase your products'), (13063, 13027, N'To collect user data');

-- Department: E-Business, Track: Social Media Marketing, Course: Facebook, Instagram & LinkedIn Ads
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (13064, 13030, N'Ad'), (13065, 13030, N'Ad Set'), (13066, 13030, N'Campaign'), (13067, 13030, N'Account'), (13068, 13032, N'TikTok'), (13069, 13032, N'LinkedIn'), (13070, 13032, N'Instagram'), (13071, 13032, N'Facebook'), (13072, 13033, N'An audience Meta finds that is similar to your existing customers'), (13073, 13033, N'An audience of people who "liked" your page'), (13074, 13033, N'An audience of people you manually upload'), (13075, 13033, N'An audience that looks different from your customers'), (13076, 13035, N'Showing ads to users who have already visited your website'), (13077, 13035, N'Finding new customers who have never heard of you'), (13078, 13035, N'Showing ads on television'), (13079, 13035, N'Targeting users in a specific location'), (13080, 13037, N'Cost Per Conversion'), (13081, 13037, N'Cost Per Click'), (13082, 13037, N'Cost Per Mille (Thousand)'), (13083, 13037, N'Campaign Performance Check'), (13084, 13038, N'An ad that is only shown to one person'), (13085, 13038, N'An ad that plays on a loop'), (13086, 13038, N'An ad with multiple scrollable images or videos'), (13087, 13038, N'A full-screen video ad'), (13088, 13040, N'Job Title, Company Size, and Industry'), (13089, 13040, N'Favorite color and hobby'), (13090, 13040, N'Family members and relationship status'), (13091, 13040, N'What they ate for breakfast'), (13092, 13042, N'The total number of times an ad was shown on screen'), (13093, 13042, N'The number of unique people who saw an ad'), (13094, 13042, N'The number of people who clicked an ad'), (13095, 13042, N'The number of people who bought a product');

-- Department: E-Business, Track: Social Media Marketing, Course: Video Marketing (YouTube/TikTok)
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (13096, 13045, N'YouTube'), (13097, 13045, N'LinkedIn'), (13098, 13045, N'TikTok'), (13099, 13045, N'Facebook'), (13100, 13047, N'The time of day a video is watched'), (13101, 13047, N'The total amount of time viewers have spent watching your videos'), (13102, 13047, N'The number of "likes" on a video'), (13103, 13047, N'The length of the video file'), (13104, 13048, N'A personalized feed of videos curated by an algorithm'), (13105, 13048, N'A page showing only videos from accounts you follow'), (13106, 13048, N'A page to buy products'), (13107, 13048, N'A list of trending hashtags'), (13108, 13050, N'Using keywords in the video title and description'), (13109, 13050, N'Having the most subscribers'), (13110, 13050, N'Using a colorful thumbnail'), (13111, 13050, N'Posting videos every day'), (13112, 13052, N'A feature to delete another user''s video'), (13113, 13052, N'A feature to create a video side-by-side with another user''s video'), (13114, 13052, N'A type of ad'), (13115, 13052, N'A private video message'), (13116, 13054, N'To suggest other videos or playlists to the viewer'), (13117, 13054, N'To show the video credits'), (13118, 13054, N'To pause the video'), (13119, 13054, N'To report the video'), (13120, 13056, N'Lo-fi, unpolished, and trend-based'), (13121, 13056, N'Long-form, high-production documentaries'), (13122, 13056, N'Silent films'), (13123, 13056, N'Slow-paced, educational lectures'), (13124, 13058, N'A curated collection of videos'), (13125, 13058, N'A list of your subscribers'), (13126, 13058, N'Your channel''s comment section'), (13127, 13058, N'A type of YouTube ad');

-- Department: E-Business, Track: Social Media Marketing, Course: Analytics & Reporting
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (13128, 13060, N'The number of unique users who saw your content'), (13129, 13060, N'The total number of followers you have'), (13130, 13060, N'The total number of times your content was shown'), (13131, 13060, N'The number of "likes" on a post'), (13132, 13062, N'A metric of how many people interacted with your post'), (13133, 13062, N'The number of people who saw your post'), (13134, 13062, N'The number of followers you gained'), (13135, 13062, N'The amount of money you spent'), (13136, 13064, N'Cost To Reach'), (13137, 13064, N'Conversion Time Rate'), (13138, 13064, N'Click-Through Rate'), (13139, 13064, N'Customer Total Revenue'), (13140, 13065, N'Key Performance Indicator'), (13141, 13065, N'Key Process Input'), (13142, 13065, N'Known Programming Interface'), (13143, 13065, N'Key Page Influencer'), (13144, 13067, N'A tag added to a URL to track its source and performance'), (13145, 13067, N'A user''s unique tracking number'), (13146, 13067, N'A type of social media post'), (13147, 13067, N'A Universal Team Manager'), (13148, 13069, N'Determining the emotional tone (positive, negative, neutral) of brand mentions'), (13149, 13069, N'Analyzing the grammar of comments'), (13150, 13069, N'Counting the number of "likes"'), (13151, 13069, N'A/B testing a subject line'), (13152, 13070, N'Your brand''s presence compared to your competitors'), (13153, 13070, N'The volume of your video content'), (13154, 13070, N'The number of followers you have'), (13155, 13070, N'The cost of your ads'), (13156, 13072, N'Rate of Interaction'), (13157, 13072, N'Report on Influence'), (13158, 13072, N'Return on Investment'), (13159, 13072, N'Reach Over Impressions');

-- Department: E-Business, Track: Social Media Marketing, Course: SEO & Email Marketing Basics
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (13160, 13075, N'Search Engine Optimization'), (13161, 13075, N'Social Engagement Optimization'), (13162, 13075, N'Sales Engine Operations'), (13163, 13075, N'Secure Email Office'), (13164, 13077, N'A link from an external website to your website'), (13165, 13077, N'A link from your website to another website'), (13166, 13077, N'A link inside your own website'), (13167, 13077, N'A broken link'), (13168, 13078, N'A word or phrase users type into search engines'), (13169, 13078, N'A button on your website'), (13170, 13078, N'An image file name'), (13171, 13078, N'A special type of ad'), (13172, 13080, N'Dividing your email list into smaller, targeted groups'), (13173, 13080, N'Sending the same email to your entire list'), (13174, 13080, N'Deleting your email list'), (13175, 13080, N'Hiding your email address'), (13176, 13082, N'The percentage of recipients who opened your email'), (13177, 13082, N'The number of people who clicked a link'), (13178, 13082, N'The number of people who unsubscribed'), (13179, 13082, N'The number of emails sent'), (13180, 13084, N'A short summary of a webpage shown in search results'), (13181, 13084, N'The main headline of your webpage'), (13182, 13084, N'A keyword used in your content'), (13183, 13084, N'An image''s caption'), (13184, 13085, N'A single email sent to all users'), (13185, 13085, N'A series of automated emails sent on a schedule'), (13186, 13085, N'An email that is deleted immediately'), (13187, 13085, N'A campaign to get new subscribers'), (13188, 13087, N'Sending two variations to see which performs better'), (13189, 13087, N'Testing if an email address is valid'), (13190, 13087, N'Sending the email at 2 AM and 2 PM'), (13191, 13087, N'Sending an email to person A and person B');

-- Department: E-Business, Track: Social Media Marketing, Course: Social Media Campaign Capstone
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES (13192, 13090, N'Choosing a campaign hashtag'), (13193, 13090, N'Designing the first ad'), (13194, 13090, N'Defining clear, measurable goals and KPIs'), (13195, 13090, N'Posting the first piece of content'), (13196, 13092, N'Visualizing the project timeline and tasks'), (13197, 13092, N'Analyzing ad performance'), (13198, 13092, N'Writing content captions'), (13199, 13092, N'Calculating final ROI'), (13200, 13093, N'A list of your followers'), (13201, 13093, N'A final report analyzing campaign results'), (13202, 13093, N'A rough draft of a post'), (13203, 13093, N'An idea for a campaign'), (13204, 13095, N'The overarching creative idea or message'), (13205, 13095, N'The ad budget'), (13206, 13095, N'The list of target keywords'), (13207, 13095, N'The font used in the ads'), (13208, 13097, N'To measure results against KPIs and find lessons learned'), (13209, 13097, N'To delete all the campaign posts'), (13210, 13097, N'To start planning the next campaign'), (13211, 13097, N'To give the team a vacation'), (13212, 13099, N'It keeps the project organized, on time, and on budget'), (13213, 13099, N'It is not important'), (13214, 13099, N'It automatically creates the content'), (13215, 13099, N'It guarantees the campaign will go viral'), (13216, 13100, N'A plan for what to do if things go wrong'), (13217, 13100, N'A plan to get more followers'), (13218, 13100, N'The content calendar'), (13219, 13100, N'The ad budget'), (13220, 13102, N'The initial goals'), (13221, 13102, N'The final results and ROI'), (13222, 13102, N'Lessons learned'), (13223, 13102, N'All of the above');


--Soft Skills Questions ================ ================ ================ ================ ================ ================

-- Department: Soft Skills - Course: Communication Skills
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES
(13500, 190, N'MCQ', N'What is "active listening"?', N'Focusing fully on the speaker and understanding their message'),
(13501, 190, N'True/False', N'Non-verbal communication (body language, tone) is often less important than the words spoken.', N'False'),
(13502, 190, N'MCQ', N'What is a key component of constructive feedback?', N'Being specific, actionable, and focusing on behavior'),
(13503, 190, N'True/False', N'Using "You" statements (e.g., "You always...") is an effective way to resolve conflict.', N'False'),
(13504, 190, N'MCQ', N'What is the main purpose of "business storytelling"?', N'To make data and ideas more engaging and memorable'),
(13505, 190, N'True/False', N'Cross-cultural communication barriers only include language differences.', N'False'),
(13506, 190, N'MCQ', N'What is a primary goal of professional networking?', N'To build mutually beneficial long-term relationships'),
(13507, 190, N'True/False', N'"Active listening" means quietly waiting for your turn to speak.', N'False'),
(13508, 190, N'MCQ', N'Which of these is a common barrier to effective communication?', N'Assumptions and jargon'),
(13509, 190, N'True/False', N'A follow-up email after a meeting is good etiquette to summarize actions.', N'True');
-- Department: Soft Skills - Course: Presentation Skills
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES
(13510, 191, N'MCQ', N'What is the primary purpose of a presentation''s opening?', N'To grab the audience''s attention and state the purpose'),
(13511, 191, N'True/False', N'It is best to read your entire presentation directly from your slides or notes.', N'False'),
(13512, 191, N'MCQ', N'What does "vocal variety" refer to?', N'Changing your pitch, pace, and volume'),
(13513, 191, N'True/False', N'Making eye contact with the audience can make you appear less confident.', N'False'),
(13514, 191, N'MCQ', N'What is a key principle for designing effective presentation slides?', N'Keep text minimal; use visuals to support points'),
(13515, 191, N'True/False', N'You should always save the Q&A session for the very end, with no exceptions.', N'False'),
(13516, 191, N'MCQ', N'What is the purpose of "audience analysis" before a presentation?', N'To tailor your message, tone, and content to the audience'),
(13517, 191, N'True/False', N'Using humor is always a good idea, regardless of the audience or topic.', N'False'),
(13518, 191, N'MCQ', N'What is a common mistake in using body language during a presentation?', N'Standing perfectly still or pacing nervously'),
(13519, 191, N'True/False', N'A strong conclusion should summarize the key takeaways and include a call to action.', N'True');
-- Department: Soft Skills - Course: Ethics
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES
(13520, 192, N'MCQ', N'What is a "conflict of interest"?', N'A situation where personal interests may compromise professional judgment'),
(13521, 192, N'True/False', N'If an action is legal, it is guaranteed to be ethical.', N'False'),
(13522, 192, N'MCQ', N'What does "intellectual property" (IP) protect?', N'Creations of the mind, such as inventions, literary works, and designs'),
(13523, 192, N'True/False', N'"Whistleblowing" is the act of reporting unethical or illegal activities within an organization.', N'True'),
(13524, 192, N'MCQ', N'What is a primary principle of "data privacy"?', N'Handling personal information responsibly, securely, and with consent'),
(13525, 192, N'True/False', N'Using company equipment and time for a personal side-project is always acceptable.', N'False'),
(13526, 192, N'MCQ', N'What is "accountability" in a professional context?', N'Taking responsibility for your actions, decisions, and their outcomes'),
(13527, 192, N'True/False', N'"Unconscious bias" refers to prejudices that we are aware of and actively conceal.', N'False'),
(13528, 192, N'MCQ', N'What is the purpose of a "code of conduct"?', N'To provide clear guidelines for employees on expected behavior'),
(13529, 192, N'True/False', N'Corporate Social Responsibility (CSR) is solely about donating money to charity.', N'False');
-- Department: Soft Skills - Course: CV Writing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES
(13530, 193, N'MCQ', N'What does "ATS" stand for in the context of recruiting?', N'Applicant Tracking System'),
(13531, 193, N'True/False', N'You should use the exact same CV for every job application.', N'False'),
(13532, 193, N'MCQ', N'What is the "STAR" method used for in a CV or interview?', N'Structuring answers (Situation, Task, Action, Result)'),
(13533, 193, N'True/False', N'A "Resume" and a "CV" are identical in all countries and contexts.', N'False'),
(13534, 193, N'MCQ', N'What is the ideal length for a CV for a recent graduate?', N'One page'),
(13535, 193, N'True/False', N'A "professional summary" should be a long paragraph detailing your life story.', N'False'),
(13536, 193, N'MCQ', N'What is the primary purpose of a "cover letter"?', N'To introduce yourself and tailor your application to the specific role'),
(13537, 193, N'True/False', N'It is highly recommended to include a professional photo on your CV.', N'False'),
(13538, 193, N'MCQ', N'When listing work experience, how should you order it?', N'Reverse-chronological order (most recent first)'),
(13539, 193, N'True/False', N'One or two small spelling errors on a CV are acceptable and will be ignored.', N'False');
-- Department: Soft Skills - Course: Freelancing
INSERT INTO Question_Bank (Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer) VALUES
(13540, 194, N'MCQ', N'What is "scope creep" in a freelance project?', N'When the project''s requirements expand beyond the original agreement'),
(13541, 194, N'True/False', N'A freelance portfolio is not necessary if you have a good CV.', N'False'),
(13542, 194, N'MCQ', N'What is a "niche" in freelancing?', N'A specific, specialized area or market that you serve'),
(13543, 194, N'True/False', N'You should always charge an hourly rate, as project-based fees are unprofessional.', N'False'),
(13544, 194, N'MCQ', N'What is a "retainer agreement"?', N'A client pays a fixed fee in advance for work to be specified later'),
(13545, 194, N'True/False', N'Freelance platforms like Khamsat and Upwork take a percentage of your earnings as a fee.', N'True'),
(13546, 194, N'MCQ', N'What is a key element of a strong freelance proposal?', N'Demonstrating you understand the client''s problem and how you will solve it'),
(13547, 194, N'True/False', N'As a freelancer, you do not need to worry about contracts for small projects.', N'False'),
(13548, 194, N'MCQ', N'What is the main purpose of "invoicing"?', N'To formally request payment from a client for services rendered'),
(13549, 194, N'True/False', N'Marketing your freelance services is a one-time task when you first start.', N'False');

-- Department: Soft Skills - Course: Communication Skills
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES
(13500, 13500, N'Focusing fully on the speaker and understanding their message'), (13501, 13500, N'Waiting for the other person to finish so you can speak'), (13502, 13500, N'Nodding your head while thinking about something else'),
(13503, 13502, N'Using vague language'), (13504, 13502, N'Focusing on the person''s personality'), (13505, 13502, N'Being specific, actionable, and focusing on behavior'),
(13506, 13504, N'To replace all data with stories'), (13507, 13504, N'To make data and ideas more engaging and memorable'), (13508, 13504, N'To make presentations longer'),
(13509, 13506, N'To ask for a job from everyone you meet'), (13510, 13506, N'To collect as many business cards as possible'), (13511, 13506, N'To build mutually beneficial long-term relationships'),
(13512, 13508, N'Assumptions and jargon'), (13513, 13508, N'Speaking clearly'), (13514, 13508, N'Active listening');
-- Department: Soft Skills - Course: Presentation Skills
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES
(13515, 13510, N'To tell a long personal story'), (13516, 13510, N'To grab the audience''s attention and state the purpose'), (13517, 13510, N'To show your most complex data slide first'),
(13518, 13512, N'Speaking in a monotone voice'), (13519, 13512, N'Changing your pitch, pace, and volume'), (13520, 13512, N'Shouting to keep people awake'),
(13521, 13514, N'Using at least 10 different fonts'), (13522, 13514, N'Filling every slide with long paragraphs of text'), (13523, 13514, N'Keep text minimal; use visuals to support points'),
(13524, 13516, N'To ignore the audience and focus on your script'), (13525, 13516, N'To tailor your message, tone, and content to the audience'), (13526, 13516, N'To find out who to avoid during the Q&A'),
(13527, 13518, N'Open and confident posture'), (13528, 13518, N'Pointing at the audience'), (13529, 13518, N'Standing perfectly still or pacing nervously');
-- Department: Soft Skills - Course: Ethics
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES
(13530, 13520, N'A situation where you disagree with your boss'), (13531, 13520, N'A situation where personal interests may compromise professional judgment'), (13532, 13520, N'Having two different jobs'),
(13533, 13522, N'Physical property like buildings and land'), (13534, 13522, N'Creations of the mind, such as inventions, literary works, and designs'), (13535, 13522, N'Company-owned computers and phones'),
(13536, 13524, N'Sharing all customer data publicly'), (13537, 13524, N'Handling personal information responsibly, securely, and with consent'), (13538, 13524, N'Using data for any purpose without asking'),
(13539, 13526, N'Blaming others for your mistakes'), (13540, 13526, N'Taking responsibility for your actions, decisions, and their outcomes'), (13541, 13526, N'Only doing work when your manager is watching'),
(13542, 13528, N'A list of company holidays'), (13543, 13528, N'A marketing brochure'), (13544, 13528, N'To provide clear guidelines for employees on expected behavior');
-- Department: Soft Skills - Course: CV Writing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES
(13545, 13530, N'Automatic Talent Scanner'), (13546, 13530, N'Applicant Tracking System'), (13547, 13530, N'Application Transfer Service'),
(13548, 13532, N'A way to format your CV text'), (13549, 13532, N'Structuring answers (Situation, Task, Action, Result)'), (13550, 13532, N'A popular font for CVs'),
(13551, 13534, N'One page'), (13552, 13534, N'Five pages'), (13553, 13534, N'As long as possible'),
(13554, 13536, N'To repeat your CV word-for-word'), (13555, 13536, N'To introduce yourself and tailor your application to the specific role'), (13556, 13536, N'To ask for a higher salary'),
(13557, 13538, N'Alphabetical order'), (13558, 13538, N'Chronological order (oldest first)'), (13559, 13538, N'Reverse-chronological order (most recent first)');
-- Department: Soft Skills - Course: Freelancing
INSERT INTO Question_Choice (Question_Choice_ID, Question_ID, Choice_Text) VALUES
(13560, 13540, N'When the client pays extra'), (13561, 13540, N'When the project''s requirements expand beyond the original agreement'), (13562, 13540, N'Finishing a project ahead of schedule'),
(13563, 13542, N'A common, general service that everyone offers'), (13564, 13542, N'A specific, specialized area or market that you serve'), (13565, 13542, N'A type of freelance contract'),
(13566, 13544, N'A single, one-time project payment'), (13567, 13544, N'A bonus paid after project completion'), (13568, 13544, N'A client pays a fixed fee in advance for work to be specified later'),
(13569, 13546, N'Using a generic template for all clients'), (13570, 13546, N'Offering the lowest possible price'), (13571, 13546, N'Demonstrating you understand the client''s problem and how you will solve it'),
(13572, 13548, N'To write a project proposal'), (13573, 13548, N'To formally request payment from a client for services rendered'), (13574, 13548, N'To track your work hours for yourself');


-- ================================================================================================================================================================================
--  Student Data 
-- ================================================================================================================================================================================

INSERT INTO Company (Company_ID, Company_Name, Company_Location, Company_Type)
VALUES
(1, N'Microsoft', N'Cairo', N'Multinational'),
(2, N'Amazon (AWS)', N'Cairo', N'Multinational'),
(3, N'Vodafone Intelligent Solutions (VOIS)', N'Smart Village, Giza', N'Multinational'),
(4, N'Accenture', N'Cairo', N'Multinational'),
(5, N'Elsewedy Electric', N'Cairo', N'National'),
(6, N'Orange Egypt', N'Smart Village, Giza', N'Multinational'),
(7, N'Valeo', N'Smart Village, Giza', N'Multinational'),
(8, N'CIB (Commercial International Bank)', N'Cairo', N'National'),
(9, N'Orascom Construction', N'Cairo', N'National'),
(10, N'IBM', N'Giza', N'Multinational'),
(11, N'Capgemini', N'Cairo', N'Multinational'),
(12, N'Dell Technologies', N'Cairo', N'Multinational'),
(13, N'Etisalat by e&', N'Cairo', N'Multinational'),
(14, N'Fawry', N'Smart Village, Giza', N'National'),
(15, N'NAGWA', N'Cairo', N'National'),
(16, N'Robusta', N'Cairo', N'National'),
(17, N'Instabug', N'Cairo', N'National'),
(18, N'Google', N'Cairo', N'Multinational'),
(19, N'Siemens', N'Cairo', N'Multinational'),
(20, N'Schneider Electric', N'Cairo', N'Multinational'),
(21, N'National Bank of Egypt (NBE)', N'Cairo', N'National'),
(22, N'Banque Misr', N'Cairo', N'National'),
(23, N'Telecom Egypt (WE)', N'Smart Village, Giza', N'National'),
(24, N'Raya Holding', N'6th of October, Giza', N'National'),
(25, N'Hassan Allam Holding', N'Cairo', N'National'),
(26, N'Arab Contractors', N'Cairo', N'National'),
(27, N'PwC (PricewaterhouseCoopers)', N'Cairo', N'Multinational'),
(28, N'Deloitte', N'Cairo', N'Multinational'),
(29, N'EY (Ernst & Young)', N'Cairo', N'Multinational'),
(30, N'KPMG', N'Cairo', N'Multinational'),
(31, N'Oracle', N'Cairo', N'Multinational'),
(32, N'SAP', N'Cairo', N'Multinational'),
(33, N'Intel', N'Cairo', N'Multinational'),
(34, N'General Motors (GM)', N'Cairo', N'Multinational'),
(35, N'Bosch', N'Cairo', N'Multinational'),
(36, N'Procter & Gamble (P&G)', N'Cairo', N'Multinational'),
(37, N'Unilever', N'Cairo', N'Multinational'),
(38, N'Nestlé', N'Cairo', N'Multinational'),
(39, N'Pfizer', N'Cairo', N'Multinational'),
(40, N'Majid Al Futtaim', N'Cairo', N'Multinational'),
(41, N'ArabyAds', N'Cairo', N'National'),
(42, N'e-finance', N'Cairo', N'National'),
(43, N'Paymob', N'Cairo', N'National'),
(44, N'MNT-Halan', N'Cairo', N'National'),
(45, N'Swvl', N'Cairo', N'National'),
(46, N'Talabat (Delivery Hero)', N'Cairo', N'Multinational'),
(47, N'Kyndryl', N'Cairo', N'Multinational'),
(48, N'Atos', N'Cairo', N'Multinational'),
(49, N'Cisco', N'Cairo', N'Multinational'),
(50, N'Jumia', N'Cairo', N'Multinational'),
(51, N'Novartis', N'Cairo', N'Multinational'),
(52, N'L''Oréal', N'Cairo', N'Multinational'),
(53, N'EFG Hermes', N'6th of October, Giza', N'National'),
(54, N'EGAS (Egyptian Natural Gas Holding Co.)', N'Cairo', N'National');