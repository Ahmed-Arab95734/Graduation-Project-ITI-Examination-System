CREATE TABLE [Department] (
    [Department_ID] INT PRIMARY KEY,
    [Department_Name] NVARCHAR(200) NOT NULL,
    [Manager_ID] INT,
    FOREIGN KEY ([Manager_ID]) REFERENCES [Instructor] ([Instructor_ID]) ON DELETE SET NULL);

CREATE TABLE [Instructor] (
    [Instructor_ID] INT PRIMARY KEY,
    [Instructor_Fname] NVARCHAR(50) NOT NULL,
    [Instructor_Lname] NVARCHAR(50) NOT NULL,
    [Instructor_Gender] NVARCHAR(10) CHECK ([Instructor_Gender] IN (N'Male', N'Female')),
    [Instructor_Birthdate] DATE CHECK (DATEADD(year, 18, [Instructor_Birthdate]) <= GETDATE()),
    [Instructor_Marital_Status] NVARCHAR(50) CHECK ([Instructor_Marital_Status] IN (N'Married', N'Single')),
    [Instructor_Salary] INT CHECK ([Instructor_Salary] >= 8000),
    [Instructor_Contract_Type] NVARCHAR(50) CHECK ([Instructor_Contract_Type] IN (N'Full-Time', N'Part-Time')),
    [Instructor_Email] NVARCHAR(150),
    [Department_ID] INT,
    CONSTRAINT [CK_Instructor_MinAge23] CHECK (DATEADD(YEAR, 23, [Instructor_Birthdate]) <= GETDATE()),
    CONSTRAINT [FK_Instructor_Department] FOREIGN KEY ([Department_ID]) REFERENCES [Department]([Department_ID])
);

CREATE TABLE [Instructor_Phone] (
    [Instructor_ID] INT NOT NULL,
    [Phone] NVARCHAR(20) NOT NULL,
    PRIMARY KEY ([Instructor_ID], [Phone]),
    FOREIGN KEY ([Instructor_ID]) REFERENCES [Instructor]([Instructor_ID]) ON DELETE CASCADE
);

CREATE TABLE [Intake] (
    [Intake_ID] INT PRIMARY KEY,
    [Intake_Name] NVARCHAR(200) NOT NULL,
    [Intake_Type] NVARCHAR(50) CHECK ([Intake_Type] IN (N'Professional Training Program - (9 Months)', N'Intensive Code Camps - (4 Months)')),
    [Intake_Start_Date] DATE NOT NULL,
    [Intake_End_Date] DATE NOT NULL
);

CREATE TABLE [Branch] (
    [Branch_ID] INT PRIMARY KEY,
    [Branch_Location] NVARCHAR(200),
    [Branch_Name] NVARCHAR(200) NOT NULL,
    [Branch_Start_Date] DATE NOT NULL
);

CREATE TABLE [Track] (
    [Track_ID] INT PRIMARY KEY,
    [Track_Name] NVARCHAR(200) NOT NULL,
    [Department_ID] INT NOT NULL,
    FOREIGN KEY ([Department_ID]) REFERENCES [Department]([Department_ID]) ON DELETE CASCADE
);

CREATE TABLE [dbo].[Group] (
    [Group_ID] [int] NOT NULL,
    [Intake_ID] [int] NOT NULL,
    [Branch_ID] [int] NOT NULL,
    [Track_ID] [int] NOT NULL,
    PRIMARY KEY CLUSTERED ([Group_ID] ASC),
    FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[Branch] ([Branch_ID]) ON DELETE CASCADE,
    FOREIGN KEY ([Intake_ID]) REFERENCES [dbo].[Intake] ([Intake_ID]) ON DELETE CASCADE,
    FOREIGN KEY ([Track_ID]) REFERENCES [dbo].[Track] ([Track_ID]) ON DELETE CASCADE
);


CREATE TABLE [Student] (
    [Student_ID] INT PRIMARY KEY,
    [Student_Mail] NVARCHAR(100) NOT NULL UNIQUE,
    [Student_Address] NVARCHAR(255),
    [Student_Gender] NVARCHAR(10) CHECK ([Student_Gender] IN (N'Male', N'Female')),
    [Student_Marital_Status] NVARCHAR(50) CHECK ([Student_Marital_Status] IN (N'Married', N'Single')),
    [Student_Fname] NVARCHAR(50) NOT NULL,
    [Student_Lname] NVARCHAR(50) NOT NULL,
    [Student_Birthdate] DATE NOT NULL CHECK (DATEADD(year, 18, [Student_Birthdate]) <= GETDATE()),
    [Student_Faculty] NVARCHAR(100),
    [Student_Faculty_Grade] NVARCHAR(50) CHECK ([Student_Faculty_Grade] IN (N'Excellent', N'Very Good', N'Good', N'Pass')),
    [Student_ITI_Status] NVARCHAR(50) CHECK ([Student_ITI_Status] IN (N'Graduated', N'Failed to Graduate', N'In Progress')),
    [Group_ID] INT NOT NULL,
    FOREIGN KEY ([Group_ID]) REFERENCES [Group]([Group_ID]) ON DELETE CASCADE,
    CONSTRAINT [CK_Student_MinAge22] CHECK (DATEADD(YEAR, 22, [Student_Birthdate]) <= GETDATE())
);

CREATE TABLE [Failed_Students] (
    [Student_ID] INT NOT NULL,
    [Failure_Reason] NVARCHAR(255) NOT NULL,
    PRIMARY KEY ([Student_ID], [Failure_Reason]),
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]) ON DELETE CASCADE
);

CREATE TABLE [Student_Phone] (
    [Student_ID] INT NOT NULL,
    [Phone] NVARCHAR(20) NOT NULL,
    PRIMARY KEY ([Student_ID], [Phone]),
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]) ON DELETE CASCADE
);

CREATE TABLE [Student_Social] (
    [Student_ID] INT NOT NULL,
    [Social_Type] NVARCHAR(50) NOT NULL CHECK ([Social_Type] IN (N'Facebook', N'LinkedIn', N'Instagram', N'GitHub', N'X')),
    [Social_Url] NVARCHAR(400) NOT NULL,
    PRIMARY KEY ([Student_ID], [Social_Type]),
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]) ON DELETE CASCADE
);


CREATE TABLE [Freelance_Job] (
    [Job_ID] INT PRIMARY KEY,
    [Student_ID] INT NOT NULL,
    [Job_Earn] DECIMAL(12, 2) NOT NULL,
    [Job_Date] DATE NOT NULL,
    [Job_Site] NVARCHAR(255),
    [Description] NVARCHAR(1000) NULL,
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]) ON DELETE CASCADE
);

CREATE TABLE [Certificate] (
    [Certificate_ID] INT PRIMARY KEY,
    [Student_ID] INT NOT NULL,
    [Certificate_Name] NVARCHAR(200) NOT NULL,
    [Certificate_Provider] NVARCHAR(200) NULL,
    [Certificate_Cost] DECIMAL(12, 2),
    [Certificate_Date] DATE,
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]) ON DELETE CASCADE
);


CREATE TABLE [Company] (
    [Company_ID] INT PRIMARY KEY,
    [Company_Name] NVARCHAR(200) NOT NULL,
    [Company_Location] NVARCHAR(200),
    [Company_Type] NVARCHAR(100) CHECK ([Company_Type] = N'Multinational' OR [Company_Type] = N'National')
);

CREATE TABLE [Student_Company] (
    [Student_ID] INT NOT NULL,
    [Company_ID] INT NOT NULL,
    [Salary] DECIMAL(12, 2),
    [Position] NVARCHAR(100),
    [Contract_Type] NVARCHAR(50) CHECK ([Contract_Type] IN (N'Full-Time', N'Part-Time')),
    [Hire_Date] DATE,
    [Leave_Date] DATE,
    PRIMARY KEY ([Student_ID], [Company_ID]),
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]) ON DELETE CASCADE,
    FOREIGN KEY ([Company_ID]) REFERENCES [Company]([Company_ID]) ON DELETE CASCADE
);


CREATE TABLE [Course] (
    [Course_ID] INT PRIMARY KEY,
    [Course_Name] NVARCHAR(200) NOT NULL
);

CREATE TABLE [Topic] (
    [Topic_ID] INT PRIMARY KEY,
    [Topic_Name] NVARCHAR(200) NOT NULL,
    [Course_ID] INT NOT NULL,
    FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]) ON DELETE CASCADE
);

CREATE TABLE [Track_Course] (
    [Course_ID] INT NOT NULL,
    [Track_ID] INT NOT NULL,
    PRIMARY KEY ([Track_ID], [Course_ID]),
    FOREIGN KEY ([Track_ID]) REFERENCES [Track]([Track_ID]),
    FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID])
);

CREATE TABLE [Instructor_Course] (
    [Instructor_ID] INT NOT NULL,
    [Course_ID] INT NOT NULL,
    PRIMARY KEY ([Instructor_ID], [Course_ID]),
    FOREIGN KEY ([Instructor_ID]) REFERENCES [Instructor]([Instructor_ID]) ON DELETE CASCADE,
    FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]) ON DELETE CASCADE
);

CREATE TABLE [Student_Course] (
    [Student_ID] INT NOT NULL,
    [Course_ID] INT NOT NULL,
    [Course_StartDate] DATE,
    [Course_EndDate] DATE,
    PRIMARY KEY ([Student_ID], [Course_ID]),
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]) ON DELETE CASCADE,
    FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]) ON DELETE CASCADE
);


CREATE TABLE [Exam] (
    [Exam_ID] INT PRIMARY KEY,
    [Course_ID] INT NOT NULL,
    [Instructor_ID] INT NOT NULL,
    [Exam_Date] DATE NOT NULL,
    [Exam_Duration_Minutes] INT NOT NULL CHECK ([Exam_Duration_Minutes] > 0),
    [Exam_Type] NVARCHAR(50) CHECK ([Exam_Type] IN (N'Normal', N'Corrective')),
    FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]) ON DELETE CASCADE,
    FOREIGN KEY ([Instructor_ID]) REFERENCES [Instructor]([Instructor_ID]) ON DELETE CASCADE
);

CREATE TABLE [Question_Bank] (
    [Question_ID] INT PRIMARY KEY,
    [Course_ID] INT NOT NULL,
    [Question_Type] NVARCHAR(50) CHECK ([Question_Type] IN (N'MCQ', N'True/False')),
    [Question_Description] NVARCHAR(1000) NOT NULL,
    [Question_Model_Answer] NVARCHAR(1000) NOT NULL,
    FOREIGN KEY ([Course_ID]) REFERENCES [Course]([Course_ID]) ON DELETE CASCADE
);

CREATE TABLE [Question_Choice] (
    [Question_Choice_ID] INT PRIMARY KEY,
    [Question_ID] INT NOT NULL,
    [Choice_Text] NVARCHAR(500) NOT NULL,
    FOREIGN KEY ([Question_ID]) REFERENCES [Question_Bank]([Question_ID]) ON DELETE CASCADE
);

CREATE TABLE [Exam_Questions] (
    [Exam_ID] INT NOT NULL,
    [Question_ID] INT NOT NULL,
    PRIMARY KEY ([Exam_ID], [Question_ID]),
    FOREIGN KEY ([Exam_ID]) REFERENCES [Exam]([Exam_ID]),
    FOREIGN KEY ([Question_ID]) REFERENCES [Question_Bank]([Question_ID])
);

CREATE TABLE [Student_Exam_Answer] (
    [Exam_ID] INT NOT NULL,
    [Question_ID] INT NOT NULL,
    [Student_ID] INT NOT NULL,
    [Student_Answer] NVARCHAR(1000),
    [Student_Grade] DECIMAL(6, 2) CHECK ([Student_Grade] >= 0),
    PRIMARY KEY ([Exam_ID], [Question_ID], [Student_ID]),
    FOREIGN KEY ([Exam_ID]) REFERENCES [Exam]([Exam_ID]),
    FOREIGN KEY ([Question_ID]) REFERENCES [Question_Bank]([Question_ID]),
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID])
);


CREATE TABLE [Rating] (
    [Student_ID] INT NOT NULL,
    [Instructor_ID] INT NOT NULL,
    [RatingValue] TINYINT NOT NULL CHECK ([RatingValue] BETWEEN 1 AND 10),
    PRIMARY KEY ([Student_ID], [Instructor_ID]),
    FOREIGN KEY ([Student_ID]) REFERENCES [Student]([Student_ID]),
    FOREIGN KEY ([Instructor_ID]) REFERENCES [Instructor]([Instructor_ID])
);