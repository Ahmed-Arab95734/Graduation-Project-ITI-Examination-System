-- ============================================
-- DATABASE Creation: ITI Examination System
-- By Ahmed Arab 
-- 13/10/2025 06:00 PM
-- ============================================

-- ================
-- INSTRUCTOR
-- ================
CREATE TABLE Instructor (
    Instructor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Instructor_Fname NVARCHAR(50) NOT NULL,
    Instructor_Lname NVARCHAR(50) NOT NULL,
    Instructor_Contract_Type NVARCHAR(50) CHECK (Instructor_Contract_Type IN (N'Full-Time', N'Part-Time', N'Contract')),
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
    Department_ID INT IDENTITY(1,1) PRIMARY KEY,
    Department_Name NVARCHAR(200) NOT NULL,
    Manager_ID INT ,
    FOREIGN KEY (Manager_ID) REFERENCES Instructor(Instructor_ID) ON DELETE SET NULL
);
ALTER TABLE Instructor ADD CONSTRAINT FK_Instructor_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID);

CREATE TABLE Intake (
    Intake_ID INT IDENTITY(1,1) PRIMARY KEY,
    Intake_Name NVARCHAR(200) NOT NULL,
    Intake_StartDate DATE NOT NULL,
    Intake_EndDate DATE NOT NULL
);

CREATE TABLE Branch (
    Branch_ID INT IDENTITY(1,1) PRIMARY KEY,
    Branch_Location NVARCHAR(200),
    Branch_Name NVARCHAR(200) NOT NULL
);

CREATE TABLE Track (
    Track_ID INT IDENTITY(1,1) PRIMARY KEY,
    Track_Name NVARCHAR(200) NOT NULL,
    Department_ID INT NOT NULL,
    FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID) ON DELETE CASCADE
);

CREATE TABLE Intake_Branch_Track (
    Intake_ID INT NOT NULL,
    Branch_ID INT NOT NULL,
    Track_ID INT NOT NULL,
    PRIMARY KEY (Intake_ID, Track_ID, Branch_ID),
    FOREIGN KEY (Intake_ID) REFERENCES Intake(Intake_ID) ON DELETE CASCADE,
    FOREIGN KEY (Track_ID) REFERENCES Track(Track_ID) ON DELETE CASCADE,
    FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID) ON DELETE CASCADE
);

-- ================
-- STUDENT
-- ================
CREATE TABLE Student (
    Student_ID INT IDENTITY(1,1) PRIMARY KEY,
    Student_Mail NVARCHAR(100) NOT NULL UNIQUE,
    Student_Address NVARCHAR(255) ,
    Student_Gender CHAR(1) NOT NULL CHECK (Student_Gender IN ('M','F')),
    Student_Fname NVARCHAR(50) NOT NULL,
    Student_Lname NVARCHAR(50) NOT NULL,
    Student_Birthdate DATE NOT NULL CHECK (DATEADD(year, 18, Student_Birthdate) <= GETDATE()),
    Student_Faculty NVARCHAR(100) ,
    Student_Grad_Grade NVARCHAR(50) ,
    Intake_ID INT NOT NULL,
    Branch_ID INT NOT NULL,
    Track_ID INT NOT NULL,
    FOREIGN KEY (Intake_ID) REFERENCES Intake(Intake_ID) ON DELETE CASCADE,
    FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID) ON DELETE CASCADE,
    FOREIGN KEY (Track_ID) REFERENCES Track(Track_ID) ON DELETE CASCADE
);

CREATE TABLE Student_Phone (
    Student_ID INT NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    PRIMARY KEY (Student_ID, Phone),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

CREATE TABLE Student_Social (
    Student_ID INT NOT NULL,
    Social_Url NVARCHAR(400) NOT NULL,
    PRIMARY KEY (Student_ID, Social_Url),
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

-- ================
-- FREELANCE JOBS & CERTIFICATES
-- ================
CREATE TABLE Freelance_Job (
    Job_ID INT IDENTITY(1,1) PRIMARY KEY,
    Student_ID INT NOT NULL,
    Job_Earn DECIMAL(12,2) NOT NULL,
    Job_Date DATE NOT NULL,
    Job_Site NVARCHAR(255) ,
    Description NVARCHAR(1000) NULL,
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID) ON DELETE CASCADE
);

CREATE TABLE Certificate (
    Certificate_ID INT IDENTITY(1,1) PRIMARY KEY,
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
    Company_ID INT IDENTITY(1,1) PRIMARY KEY,
    Company_Name NVARCHAR(200) NOT NULL,
    Company_Location NVARCHAR(200) ,
    Company_Type NVARCHAR(100) 
);

CREATE TABLE Student_Company (
    Student_ID INT NOT NULL,
    Company_ID INT NOT NULL,
    Salary DECIMAL(12,2) ,
    Position NVARCHAR(100),
    Contract_Type NVARCHAR(50) CHECK (Contract_Type IN (N'Full-Time', N'Part-Time', N'Contract')),
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
    Course_ID INT IDENTITY(1,1) PRIMARY KEY,
    Course_Name NVARCHAR(200) NOT NULL
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
    Exam_ID INT IDENTITY(1,1) PRIMARY KEY,
    Course_ID INT NOT NULL,
    Instructor_ID INT NOT NULL,
    Exam_Date DATE NOT NULL,
    Exam_Duration_Minutes INT NOT NULL CHECK (Exam_Duration_Minutes > 0),
    Exam_Type NVARCHAR(50) CHECK (Exam_Type IN (N'Normal', N'Corrective')),
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE,
    FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID) ON DELETE CASCADE
);

CREATE TABLE Question_Bank (
    Question_ID INT IDENTITY(1,1) PRIMARY KEY,
    Course_ID INT NOT NULL,
    Question_Type NVARCHAR(50) CHECK (Question_Type IN (N'MCQ', N'True/False')),
    Question_Description NVARCHAR(1000) NOT NULL,
    Question_Model_Answer NVARCHAR(1000) NOT NULL,
    FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE
);

CREATE TABLE Question_Choice (
    Question_Choice_ID INT IDENTITY(1,1) PRIMARY KEY,
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
    Topic_ID INT IDENTITY(1,1) PRIMARY KEY,
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

INSERT INTO Department (Department_Name)
VALUES
(N'System Development'),
(N'E-Learning'),
(N'Java'),
(N'Multimedia'),
(N'Unix'),
(N'Network'),
(N'E-Business');

SET IDENTITY_INSERT Instructor ON;
INSERT INTO Instructor (Instructor_ID, Instructor_Fname, Instructor_Lname, Instructor_Contract_Type, Instructor_Email, Department_ID)
VALUES
(1, N'Ahmed',   N'Samir',   N'Full-Time',  N'ahmed.samir@iti.edu.eg',   1), -- System Dev
(2, N'Salma',   N'Fathy',   N'Part-Time',  N'salma.fathy@iti.edu.eg',   2), -- E-Learning
(3, N'Youssef', N'Farid',   N'Contract',   N'youssef.farid@iti.edu.eg', 3), -- Java
(4, N'Rana',    N'Adel',    N'Full-Time',  N'rana.adel@iti.edu.eg',     4), -- Multimedia
(5, N'Khaled',  N'Mostafa', N'Full-Time',  N'khaled.mostafa@iti.edu.eg',5), -- Unix
(6, N'Dina',    N'Hassan',  N'Part-Time',  N'dina.hassan@iti.edu.eg',   6), -- Network
(7, N'Mohamed', N'Attia',   N'Contract',   N'mohamed.attia@iti.edu.eg', 7), -- E-Business
(8, N'Laila',   N'Emad',    N'Full-Time',  N'laila.emad@iti.edu.eg',    1); -- System Dev
SET IDENTITY_INSERT Instructor OFF;


INSERT INTO Instructor_Phone (Instructor_ID, Phone)
VALUES
(1, N'01011122334'),
(1, N'01122334455'),
(2, N'01098765432'),
(3, N'01234567890'),
(4, N'01512345678'),
(5, N'01055667788'),
(6, N'01066778899'),
(7, N'01299887766'),
(8, N'01122335566');

UPDATE Department SET Manager_ID = 1 WHERE Department_ID = 1; -- System Development
UPDATE Department SET Manager_ID = 2 WHERE Department_ID = 2; -- E-Learning
UPDATE Department SET Manager_ID = 3 WHERE Department_ID = 3; -- Java
UPDATE Department SET Manager_ID = 4 WHERE Department_ID = 4; -- Multimedia
UPDATE Department SET Manager_ID = 5 WHERE Department_ID = 5; -- Unix
UPDATE Department SET Manager_ID = 6 WHERE Department_ID = 6; -- Network
UPDATE Department SET Manager_ID = 7 WHERE Department_ID = 7; -- E-Business


-- =======================================================================================
-- Buliding a logging system with triggers for every data action (INSERT, UPDATE, DELETE)
-- =======================================================================================

CREATE TABLE Audit_Log (
    Log_ID INT IDENTITY(1,1) PRIMARY KEY,
    Table_Name NVARCHAR(128),
    Action_Type NVARCHAR(10),  -- 'INSERT', 'UPDATE', 'DELETE'
    Action_Date DATETIME DEFAULT GETDATE(),
    User_Name NVARCHAR(128) DEFAULT SUSER_SNAME(),
    Host_Name NVARCHAR(128) DEFAULT HOST_NAME(),
    Key_Value NVARCHAR(500),  -- Primary Key or identifying info
    Changed_Data NVARCHAR(MAX) NULL  -- JSON or text of the changed row
);