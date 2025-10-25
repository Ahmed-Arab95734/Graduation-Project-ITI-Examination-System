USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Department]    Script Date: 10/25/2025 3:35:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Department](
	[Department_ID] [int] NOT NULL,
	[Department_Name] [nvarchar](200) NOT NULL,
	[Manager_ID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Department_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Department]  WITH CHECK ADD FOREIGN KEY([Manager_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
ON DELETE SET NULL
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Instructor]    Script Date: 10/25/2025 3:37:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Instructor](
	[Instructor_ID] [int] NOT NULL,
	[Instructor_Fname] [nvarchar](50) NOT NULL,
	[Instructor_Lname] [nvarchar](50) NOT NULL,
	[Instructor_Gender] [nvarchar](10) NULL,
	[Instructor_Birthdate] [date] NULL,
	[Instructor_Marital_Status] [nvarchar](50) NULL,
	[Instructor_Salary] [int] NULL,
	[Instructor_Contract_Type] [nvarchar](50) NULL,
	[Instructor_Email] [nvarchar](150) NULL,
	[Department_ID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Instructor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD  CONSTRAINT [FK_Instructor_Department] FOREIGN KEY([Department_ID])
REFERENCES [dbo].[Department] ([Department_ID])
GO

ALTER TABLE [dbo].[Instructor] CHECK CONSTRAINT [FK_Instructor_Department]
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD CHECK  (([Instructor_Gender]=N'Female' OR [Instructor_Gender]=N'Male'))
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD CHECK  ((dateadd(year,(18),[Instructor_Birthdate])<=getdate()))
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD CHECK  (([Instructor_Marital_Status]=N'Single' OR [Instructor_Marital_Status]=N'Married'))
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD CHECK  (([Instructor_Salary]>=(8000)))
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD CHECK  (([Instructor_Contract_Type]=N'Part-Time' OR [Instructor_Contract_Type]=N'Full-Time'))
GO

ALTER TABLE [dbo].[Instructor]  WITH CHECK ADD  CONSTRAINT [CK_Instructor_MinAge23] CHECK  ((dateadd(year,(23),[Instructor_Birthdate])<=getdate()))
GO

ALTER TABLE [dbo].[Instructor] CHECK CONSTRAINT [CK_Instructor_MinAge23]
GO




USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Instructor_Phone]    Script Date: 10/25/2025 3:37:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Instructor_Phone](
	[Instructor_ID] [int] NOT NULL,
	[Phone] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Instructor_ID] ASC,
	[Phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Instructor_Phone]  WITH CHECK ADD FOREIGN KEY([Instructor_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
ON DELETE CASCADE
GO



USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Intake]    Script Date: 10/25/2025 3:38:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Intake](
	[Intake_ID] [int] NOT NULL,
	[Intake_Name] [nvarchar](200) NOT NULL,
	[Intake_Type] [nvarchar](50) NULL,
	[Intake_Start_Date] [date] NOT NULL,
	[Intake_End_Date] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Intake_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Intake]  WITH CHECK ADD CHECK  (([Intake_Type]=N'Intensive Code Camps - (4 Months)' OR [Intake_Type]=N'Professional Training Program - (9 Months)'))
GO



USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Branch]    Script Date: 10/25/2025 3:38:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Branch](
	[Branch_ID] [int] NOT NULL,
	[Branch_Location] [nvarchar](200) NULL,
	[Branch_Name] [nvarchar](200) NOT NULL,
	[Branch_Start_Date] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Branch_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Track]    Script Date: 10/25/2025 3:39:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Track](
	[Track_ID] [int] NOT NULL,
	[Track_Name] [nvarchar](200) NOT NULL,
	[Department_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Track_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Track]  WITH CHECK ADD FOREIGN KEY([Department_ID])
REFERENCES [dbo].[Department] ([Department_ID])
ON DELETE CASCADE
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Group]    Script Date: 10/25/2025 3:39:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Group](
	[Group_ID] [int] NOT NULL,
	[Intake_ID] [int] NOT NULL,
	[Branch_ID] [int] NOT NULL,
	[Track_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Group_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Group]  WITH CHECK ADD FOREIGN KEY([Branch_ID])
REFERENCES [dbo].[Branch] ([Branch_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Group]  WITH CHECK ADD FOREIGN KEY([Intake_ID])
REFERENCES [dbo].[Intake] ([Intake_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Group]  WITH CHECK ADD FOREIGN KEY([Track_ID])
REFERENCES [dbo].[Track] ([Track_ID])
ON DELETE CASCADE
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Student]    Script Date: 10/25/2025 3:40:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student](
	[Student_ID] [int] NOT NULL,
	[Student_Mail] [nvarchar](100) NOT NULL,
	[Student_Address] [nvarchar](255) NULL,
	[Student_Gender] [nvarchar](10) NULL,
	[Student_Marital_Status] [nvarchar](50) NULL,
	[Student_Fname] [nvarchar](50) NOT NULL,
	[Student_Lname] [nvarchar](50) NOT NULL,
	[Student_Birthdate] [date] NOT NULL,
	[Student_Faculty] [nvarchar](100) NULL,
	[Student_Faculty_Grade] [nvarchar](50) NULL,
	[Student_ITI_Status] [nvarchar](50) NULL,
	[Intake_Branch_Track_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Student_Mail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD FOREIGN KEY([Intake_Branch_Track_ID])
REFERENCES [dbo].[Group] ([Group_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD CHECK  (([Student_Gender]=N'Female' OR [Student_Gender]=N'Male'))
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD CHECK  (([Student_Marital_Status]=N'Single' OR [Student_Marital_Status]=N'Married'))
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD CHECK  ((dateadd(year,(18),[Student_Birthdate])<=getdate()))
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD CHECK  (([Student_Faculty_Grade]=N'Pass' OR [Student_Faculty_Grade]=N'Good' OR [Student_Faculty_Grade]=N'Very Good' OR [Student_Faculty_Grade]=N'Excellent'))
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD CHECK  (([Student_ITI_Status]=N'In Progress' OR [Student_ITI_Status]=N'Failed to Graduate' OR [Student_ITI_Status]=N'Graduated'))
GO

ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [CK_Student_MinAge22] CHECK  ((dateadd(year,(22),[Student_Birthdate])<=getdate()))
GO

ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [CK_Student_MinAge22]
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Failed_Students]    Script Date: 10/25/2025 3:40:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Failed_Students](
	[Student_ID] [int] NOT NULL,
	[Failure_Reason] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_ID] ASC,
	[Failure_Reason] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Failed_Students]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
ON DELETE CASCADE
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Student_Phone]    Script Date: 10/25/2025 3:40:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Phone](
	[Student_ID] [int] NOT NULL,
	[Phone] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_ID] ASC,
	[Phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Phone]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
ON DELETE CASCADE
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Student_Social]    Script Date: 10/25/2025 3:41:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Social](
	[Student_ID] [int] NOT NULL,
	[Social_Type] [nvarchar](50) NOT NULL,
	[Social_Url] [nvarchar](400) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_ID] ASC,
	[Social_Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Social]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Social]  WITH CHECK ADD CHECK  (([Social_Type]=N'X' OR [Social_Type]=N'GitHub' OR [Social_Type]=N'Instagram' OR [Social_Type]=N'LinkedIn' OR [Social_Type]=N'Facebook'))
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Freelance_Job]    Script Date: 10/25/2025 3:41:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Freelance_Job](
	[Job_ID] [int] NOT NULL,
	[Student_ID] [int] NOT NULL,
	[Job_Earn] [decimal](12, 2) NOT NULL,
	[Job_Date] [date] NOT NULL,
	[Job_Site] [nvarchar](255) NULL,
	[Description] [nvarchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[Job_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Freelance_Job]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
ON DELETE CASCADE
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Certificate]    Script Date: 10/25/2025 3:41:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Certificate](
	[Certificate_ID] [int] NOT NULL,
	[Student_ID] [int] NOT NULL,
	[Certificate_Name] [nvarchar](200) NOT NULL,
	[Certificate_Provider] [nvarchar](200) NULL,
	[Certificate_Cost] [decimal](12, 2) NULL,
	[Certificate_Date] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[Certificate_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Certificate]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
ON DELETE CASCADE
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Company]    Script Date: 10/25/2025 3:42:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Company](
	[Company_ID] [int] NOT NULL,
	[Company_Name] [nvarchar](200) NOT NULL,
	[Company_Location] [nvarchar](200) NULL,
	[Company_Type] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Company_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Company]  WITH CHECK ADD CHECK  (([Company_Type]=N'Multinational' OR [Company_Type]=N'National'))
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Student_Company]    Script Date: 10/25/2025 3:42:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Company](
	[Student_ID] [int] NOT NULL,
	[Company_ID] [int] NOT NULL,
	[Salary] [decimal](12, 2) NULL,
	[Position] [nvarchar](100) NULL,
	[Contract_Type] [nvarchar](50) NULL,
	[Hire_Date] [date] NULL,
	[Leave_Date] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_ID] ASC,
	[Company_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Company]  WITH CHECK ADD FOREIGN KEY([Company_ID])
REFERENCES [dbo].[Company] ([Company_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Company]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Company]  WITH CHECK ADD CHECK  (([Contract_Type]=N'Part-Time' OR [Contract_Type]=N'Full-Time'))
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Course]    Script Date: 10/25/2025 3:42:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Course](
	[Course_ID] [int] NOT NULL,
	[Course_Name] [nvarchar](200) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Course_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Topic]    Script Date: 10/25/2025 3:42:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Topic](
	[Topic_ID] [int] NOT NULL,
	[Topic_Name] [nvarchar](200) NOT NULL,
	[Course_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Topic_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Topic]  WITH CHECK ADD FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON DELETE CASCADE
GO


USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Track_Course]    Script Date: 10/25/2025 3:43:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Track_Course](
	[Course_ID] [int] NOT NULL,
	[Track_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Track_ID] ASC,
	[Course_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Track_Course]  WITH CHECK ADD FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
GO

ALTER TABLE [dbo].[Track_Course]  WITH CHECK ADD FOREIGN KEY([Track_ID])
REFERENCES [dbo].[Track] ([Track_ID])
GO



USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Instructor_Course]    Script Date: 10/25/2025 3:43:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Instructor_Course](
	[Instructor_ID] [int] NOT NULL,
	[Course_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Instructor_ID] ASC,
	[Course_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Instructor_Course]  WITH CHECK ADD FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Instructor_Course]  WITH CHECK ADD FOREIGN KEY([Instructor_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
ON DELETE CASCADE
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Student_Course]    Script Date: 10/25/2025 3:44:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Course](
	[Student_ID] [int] NOT NULL,
	[Course_ID] [int] NOT NULL,
	[Course_StartDate] [date] NULL,
	[Course_EndDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_ID] ASC,
	[Course_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Course]  WITH CHECK ADD FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Student_Course]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
ON DELETE CASCADE
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Exam]    Script Date: 10/25/2025 3:44:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Exam](
	[Exam_ID] [int] NOT NULL,
	[Course_ID] [int] NOT NULL,
	[Instructor_ID] [int] NOT NULL,
	[Exam_Date] [date] NOT NULL,
	[Exam_Duration_Minutes] [int] NOT NULL,
	[Exam_Type] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Exam_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Exam]  WITH CHECK ADD FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Exam]  WITH CHECK ADD FOREIGN KEY([Instructor_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Exam]  WITH CHECK ADD CHECK  (([Exam_Duration_Minutes]>(0)))
GO

ALTER TABLE [dbo].[Exam]  WITH CHECK ADD CHECK  (([Exam_Type]=N'Corrective' OR [Exam_Type]=N'Normal'))
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Question_Bank]    Script Date: 10/25/2025 3:44:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Question_Bank](
	[Question_ID] [int] NOT NULL,
	[Course_ID] [int] NOT NULL,
	[Question_Type] [nvarchar](50) NULL,
	[Question_Description] [nvarchar](1000) NOT NULL,
	[Question_Model_Answer] [nvarchar](1000) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Question_Bank]  WITH CHECK ADD FOREIGN KEY([Course_ID])
REFERENCES [dbo].[Course] ([Course_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Question_Bank]  WITH CHECK ADD CHECK  (([Question_Type]=N'True/False' OR [Question_Type]=N'MCQ'))
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Question_Choice]    Script Date: 10/25/2025 3:44:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Question_Choice](
	[Question_Choice_ID] [int] NOT NULL,
	[Question_ID] [int] NOT NULL,
	[Choice_Text] [nvarchar](500) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Question_Choice_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Question_Choice]  WITH CHECK ADD FOREIGN KEY([Question_ID])
REFERENCES [dbo].[Question_Bank] ([Question_ID])
ON DELETE CASCADE
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Exam_Questions]    Script Date: 10/25/2025 3:45:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Exam_Questions](
	[Exam_ID] [int] NOT NULL,
	[Question_ID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Exam_ID] ASC,
	[Question_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Exam_Questions]  WITH CHECK ADD FOREIGN KEY([Exam_ID])
REFERENCES [dbo].[Exam] ([Exam_ID])
GO

ALTER TABLE [dbo].[Exam_Questions]  WITH CHECK ADD FOREIGN KEY([Question_ID])
REFERENCES [dbo].[Question_Bank] ([Question_ID])
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Student_Exam_Answer]    Script Date: 10/25/2025 3:45:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Student_Exam_Answer](
	[Exam_ID] [int] NOT NULL,
	[Question_ID] [int] NOT NULL,
	[Student_ID] [int] NOT NULL,
	[Student_Answer] [nvarchar](1000) NULL,
	[Student_Grade] [decimal](6, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Exam_ID] ASC,
	[Question_ID] ASC,
	[Student_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Student_Exam_Answer]  WITH CHECK ADD FOREIGN KEY([Exam_ID])
REFERENCES [dbo].[Exam] ([Exam_ID])
GO

ALTER TABLE [dbo].[Student_Exam_Answer]  WITH CHECK ADD FOREIGN KEY([Question_ID])
REFERENCES [dbo].[Question_Bank] ([Question_ID])
GO

ALTER TABLE [dbo].[Student_Exam_Answer]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
GO

ALTER TABLE [dbo].[Student_Exam_Answer]  WITH CHECK ADD CHECK  (([Student_Grade]>=(0)))
GO

USE [ITIExaminationSystem]
GO

/****** Object:  Table [dbo].[Rating]    Script Date: 10/25/2025 3:45:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Rating](
	[Student_ID] [int] NOT NULL,
	[Instructor_ID] [int] NOT NULL,
	[RatingValue] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Student_ID] ASC,
	[Instructor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Rating]  WITH CHECK ADD FOREIGN KEY([Instructor_ID])
REFERENCES [dbo].[Instructor] ([Instructor_ID])
GO

ALTER TABLE [dbo].[Rating]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([Student_ID])
GO

ALTER TABLE [dbo].[Rating]  WITH CHECK ADD CHECK  (([RatingValue]>=(1) AND [RatingValue]<=(10)))
GO
