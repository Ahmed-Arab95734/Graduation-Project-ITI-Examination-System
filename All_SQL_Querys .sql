--Ahmed Arab 10/8/2025 4:30 PM
-- =====================================================================
-- Create Tables
-- =====================================================================
-- This section creates all the individual tables without relationships.
-- =====================================================================

-- Instructor Table
CREATE TABLE Instructor (
    Instructor_ID INT PRIMARY KEY IDENTITY(1,1),
    Instructor_FirstName NVARCHAR(50) NOT NULL,
    Instructor_LastName NVARCHAR(50) NOT NULL,
    Instructor_Gender NVARCHAR(10),
    Instructor_Birthdate DATE,
    Instructor_Address NVARCHAR(255),
    Instructor_Email NVARCHAR(100) UNIQUE,
);

-- Department Table
CREATE TABLE Department (
    Department_ID INT PRIMARY KEY IDENTITY(1,1),
    Department_Name NVARCHAR(100) NOT NULL,
    Manager_Instructor_ID INT -- This will be the manager/head of department
);

-- Course Table
CREATE TABLE Course (
    Course_ID INT PRIMARY KEY IDENTITY(1,1),
    Course_Name NVARCHAR(100) NOT NULL
);

-- Topic Table
CREATE TABLE Topic (
    Topic_ID INT PRIMARY KEY IDENTITY(1,1),
    Topic_Name NVARCHAR(100) NOT NULL,
    Course_ID INT NOT NULL
);

-- Student Table
CREATE TABLE Student (
    Student_ID INT PRIMARY KEY IDENTITY(1,1),
    Student_Gender NVARCHAR(10),
    Student_FirstName NVARCHAR(50) NOT NULL,
    Student_LastName NVARCHAR(50) NOT NULL,
    Student_Birthdate DATE,
    Student_Address NVARCHAR(255),
    Student_Email NVARCHAR(100) UNIQUE,
    Student_Faculty NVARCHAR(100),
    Student_Graduation_Grade NVARCHAR(20),
    Department_ID INT
);

-- Student_Phone Table
CREATE TABLE Student_Phone (
    Student_ID INT NOT NULL,
    Phone_Number VARCHAR(20) NOT NULL,
    PRIMARY KEY (Student_ID, Phone_Number)
);

-- Branch Table
CREATE TABLE Branch (
    Branch_Number INT PRIMARY KEY IDENTITY(1,1),
    Branch_Name NVARCHAR(100) NOT NULL,
    Branch_Location NVARCHAR(255)
);

-- Intake Table
CREATE TABLE Intake (
    Intake_Number INT PRIMARY KEY IDENTITY(1,1),
    Intake_StartDate DATE NOT NULL,
    Intake_EndDate DATE
);

-- Company Table
CREATE TABLE Company (
    Company_ID INT PRIMARY KEY IDENTITY(1,1),
    Company_Name NVARCHAR(100) NOT NULL,
    Company_Location NVARCHAR(255),
    Company_Type NVARCHAR(50)
);

-- Certificate Table
CREATE TABLE Certificate (
    Certificate_ID INT PRIMARY KEY IDENTITY(1,1),
    Student_ID INT NOT NULL,
    Certificate_Name NVARCHAR(150) NOT NULL,
    Certificate_Provider NVARCHAR(100),
    Certificate_Cost DECIMAL(10, 2),
    Company_Type NVARCHAR(50),
    Aquirement_Date Date
);

-- Freelancing_Job Table
CREATE TABLE Freelancing_Job (
    Job_ID INT PRIMARY KEY IDENTITY(1,1),
    Student_ID INT NOT NULL,
    Job_Earn DECIMAL(10, 2),
    Job_Description NVARCHAR(MAX),
    Job_Date DATE,
    Site NVARCHAR(100)
);

-- Exam Table
CREATE TABLE Exam (
    Exam_ID INT PRIMARY KEY IDENTITY(1,1),
    Exam_Date DATETIME NOT NULL,
    Exam_Duration INT, -- Duration in minutes
    Course_ID INT NOT NULL,
    Instructor_ID INT NOT NULL
);

-- Questions_Bank Table
CREATE TABLE Questions_Bank (
    Question_Number INT PRIMARY KEY IDENTITY(1,1),
    Question_Model_Answer NVARCHAR(50), 
    Question_Type NVARCHAR(50),-- e.g., MCQ, True/False
    Question_Description NVARCHAR(MAX) NOT NULL,
    Course_ID INT NOT NULL
);

-- Questions_Choices Table
CREATE TABLE Questions_Choices (
    Question_Number INT NOT NULL,
    Question_Choices NVARCHAR(500) NOT NULL,
    PRIMARY KEY (Question_Number, Question_Choices)
);


-- =====================================================================
-- Create Junction (Many-to-Many) Tables
-- =====================================================================

-- Instructor_Department Junction Table
CREATE TABLE Instructor_Department (
    Department_ID INT NOT NULL,
    Instructor_ID INT NOT NULL,
    PRIMARY KEY (Department_ID, Instructor_ID)
);

-- Course_Department Junction Table
CREATE TABLE Course_Department (
    Department_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    PRIMARY KEY (Department_ID, Course_ID)
);

-- Instructor_Course Junction Table
CREATE TABLE Instructor_Course (
    Course_ID INT NOT NULL,
    Instructor_ID INT NOT NULL,
    PRIMARY KEY (Course_ID, Instructor_ID)
);

-- Student_Course Junction Table
CREATE TABLE Student_Course (
    Student_ID INT NOT NULL,
    Course_ID INT NOT NULL,
    Course_StartDate DATE,
    PRIMARY KEY (Student_ID, Course_ID)
);

-- Enrolled_In Junction Table
CREATE TABLE Enrolled_In (
    Intake_Number INT NOT NULL,
    Student_ID INT NOT NULL,
    PRIMARY KEY (Intake_Number, Student_ID)
);

-- Intake_Branch_Department Junction Table
CREATE TABLE Intake_Branch_Department (
    Department_ID INT NOT NULL,
    Intake_Number INT NOT NULL,
    Branch_Number INT NOT NULL,
    PRIMARY KEY (Department_ID, Intake_Number, Branch_Number)
);

-- Student_Company Junction Table
CREATE TABLE Student_Company (
    Student_ID INT NOT NULL,
    Company_ID INT NOT NULL,
    Postion NVARCHAR(500) NOT NULL,
    Hire_Date Date,
    Salary INT, 
    Contract_Type NVARCHAR(500) --part time or full time job
    PRIMARY KEY (Student_ID, Company_ID)
);

-- Answers Junction Table
CREATE TABLE Answers (
    Question_Number INT NOT NULL,
    Exam_ID INT NOT NULL,
    Student_ID INT NOT NULL,
    Student_Answer NVARCHAR(MAX),
    Student_Grade INT,
    PRIMARY KEY (Question_Number, Exam_ID, Student_ID)
);


-- =====================================================================
-- Add Foreign Key Constraints
-- =====================================================================
-- This section adds all the foreign key relationships between the tables.
-- =====================================================================

-- Department Foreign Keys
ALTER TABLE Department ADD CONSTRAINT FK_Department_Instructor FOREIGN KEY (Manager_Instructor_ID) REFERENCES Instructor(Instructor_ID);

-- Topic Foreign Keys
ALTER TABLE Topic ADD CONSTRAINT FK_Topic_Course FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID);

-- Student Foreign Keys
ALTER TABLE Student ADD CONSTRAINT FK_Student_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID);

-- Student_Phone Foreign Keys
ALTER TABLE Student_Phone ADD CONSTRAINT FK_Student_Phone_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID);

-- Certificate Foreign Keys
ALTER TABLE Certificate ADD CONSTRAINT FK_Certificate_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID);

-- Freelancing_Job Foreign Keys
ALTER TABLE Freelancing_Job ADD CONSTRAINT FK_Freelancing_Job_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID);

-- Exam Foreign Keys
ALTER TABLE Exam ADD CONSTRAINT FK_Exam_Course FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID);
ALTER TABLE Exam ADD CONSTRAINT FK_Exam_Instructor FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID);

-- Questions_Bank Foreign Keys
ALTER TABLE Questions_Bank ADD CONSTRAINT FK_Questions_Bank_Course FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID);

-- Questions_Choices Foreign Keys
ALTER TABLE Questions_Choices ADD CONSTRAINT FK_Questions_Choices_Bank FOREIGN KEY (Question_Number) REFERENCES Questions_Bank(Question_Number);

-- Instructor_Department Foreign Keys
ALTER TABLE Instructor_Department ADD CONSTRAINT FK_Instructor_Department_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID);
ALTER TABLE Instructor_Department ADD CONSTRAINT FK_Instructor_Department_Instructor FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID);

-- Course_Department Foreign Keys
ALTER TABLE Course_Department ADD CONSTRAINT FK_Course_Department_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID);
ALTER TABLE Course_Department ADD CONSTRAINT FK_Course_Department_Course FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID);

-- Instructor_Course Foreign Keys
ALTER TABLE Instructor_Course ADD CONSTRAINT FK_Instructor_Course_Course FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID);
ALTER TABLE Instructor_Course ADD CONSTRAINT FK_Instructor_Course_Instructor FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID);

-- Student_Course Foreign Keys
ALTER TABLE Student_Course ADD CONSTRAINT FK_Student_Course_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID);
ALTER TABLE Student_Course ADD CONSTRAINT FK_Student_Course_Course FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID);

-- Enrolled_In Foreign Keys
ALTER TABLE Enrolled_In ADD CONSTRAINT FK_Enrolled_In_Intake FOREIGN KEY (Intake_Number) REFERENCES Intake(Intake_Number);
ALTER TABLE Enrolled_In ADD CONSTRAINT FK_Enrolled_In_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID);

-- Intake_Branch_Department Foreign Keys
ALTER TABLE Intake_Branch_Department ADD CONSTRAINT FK_IBD_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID);
ALTER TABLE Intake_Branch_Department ADD CONSTRAINT FK_IBD_Intake FOREIGN KEY (Intake_Number) REFERENCES Intake(Intake_Number);
ALTER TABLE Intake_Branch_Department ADD CONSTRAINT FK_IBD_Branch FOREIGN KEY (Branch_Number) REFERENCES Branch(Branch_Number);

-- Student_Company Foreign Keys
ALTER TABLE Student_Company ADD CONSTRAINT FK_Student_Company_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID);
ALTER TABLE Student_Company ADD CONSTRAINT FK_Student_Company_Company FOREIGN KEY (Company_ID) REFERENCES Company(Company_ID);

-- Answers Foreign Keys
ALTER TABLE Answers ADD CONSTRAINT FK_Answers_Questions_Bank FOREIGN KEY (Question_Number) REFERENCES Questions_Bank(Question_Number);
ALTER TABLE Answers ADD CONSTRAINT FK_Answers_Exam FOREIGN KEY (Exam_ID) REFERENCES Exam(Exam_ID);
ALTER TABLE Answers ADD CONSTRAINT FK_Answers_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID);

---------------------------------------------------------------------------------
--Database version 1.0 end By ahmed arab
--10/8/2025 4:30 PM 
---------------------------------------------------------------------------------
--Test 1.1 By Haitham Fathy
--Test 1215
