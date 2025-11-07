# ============================================
# 🧠 ITI Examination System Assistant + Dashboard Generator
# ============================================

from dotenv import load_dotenv
import os
import re
import json
import pandas as pd
import pypyodbc as odbc
import streamlit as st
import google.generativeai as genai
import base64
import plotly.express as px

# ============================================
# 🎨 Streamlit Page Configuration
# ============================================
st.set_page_config(page_title="ITI Examination Assistant", page_icon="🧠", layout="wide")

# ============================================
# 🖼️ Background & Header Setup
# ============================================
def get_base64_of_bin_file(bin_file):
    with open(bin_file, 'rb') as f:
        data = f.read()
    return base64.b64encode(data).decode()

def set_background(png_file):
    bin_str = get_base64_of_bin_file(png_file)
    page_bg_img = f"""
    <style>
    .stApp {{
        background-image: url("data:image/png;base64,{bin_str}");
        background-size: cover;
        background-position: center;
        background-repeat: no-repeat;
        background-attachment: fixed;
    }}
    </style>
    """
    st.markdown(page_bg_img, unsafe_allow_html=True)

set_background("ITI_Background17601951402362703.png")

def get_base64_image(image_path):
    with open(image_path, "rb") as img_file:
        return base64.b64encode(img_file.read()).decode()

logo_base64 = get_base64_image("Gemini_Generated_Image_pwn1v3p13472503787887624.png")

st.markdown(f"""
<style>
.header {{
    display: flex;
    align-items: center;
    justify-content: flex-start;
    background-color: rgba(0, 0, 0, 0.4);
    padding: 15px 30px;
    border-radius: 12px;
    margin-bottom: 25px;
}}
.header img {{
    height: 110px;
    margin-right: 20px;
    border-radius: 10px;
}}
.header h1 {{
    font-size: 30px;
    font-weight: 800;
    color: white;
    letter-spacing: 0.5px;
}}
</style>
<div class="header">
    <img src="data:image/png;base64,{logo_base64}" alt="Logo">
    <h1>ITI Examination System Assistant</h1>
</div>
""", unsafe_allow_html=True)

# ============================================
# 🔐 Load Gemini API Key
# ============================================
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

if not GOOGLE_API_KEY:
    GOOGLE_API_KEY = st.text_input("🔑 Enter your Gemini API Key:", type="password")

if not GOOGLE_API_KEY:
    st.warning("Please provide your Gemini API key to continue.")
    st.stop()

genai.configure(api_key=GOOGLE_API_KEY)

# ============================================
# ⚙️ Helper Functions
# ============================================
@st.cache_resource
def load_model():
    return genai.GenerativeModel("models/gemini-2.5-pro")

def get_gemini_response(prompt, input_text):
    model = load_model()
    response = model.generate_content([prompt, input_text])
    return response.text.strip()

def read_sql_query(query, database):
    """Connect dynamically to either ITIExaminationSystem or ITI_DW"""
    DRIVER_NAME = 'SQL Server'
    SERVER_NAME = 'Haitham'
    CONNECTION_STRING = f'DRIVER={{{DRIVER_NAME}}};SERVER={SERVER_NAME};DATABASE={database};Trusted_Connection=yes;'

    connection = odbc.connect(CONNECTION_STRING)
    df = pd.read_sql(query, connection)
    connection.close()
    return df

# ============================================
# 📚 Schema Definitions (for AI Context)
# ============================================

# Schema 1: ITI Examination System (Transactional)
schema_examination = """
SCHEMA: ITIExaminationSystem
Tables:
Instructor(Instructor_ID, Instructor_Fname, Instructor_Lname, Instructor_Gender, Instructor_Birthdate, Instructor_Marital_Status, Instructor_Salary, Instructor_Contract_Type, Instructor_Email, Department_ID)
- Instructor_Phone(Instructor_ID, Phone)
- Department(Department_ID, Department_Name, Manager_ID)
- Intake(Intake_ID, Intake_Name, Intake_Type, Intake_Start_Date, Intake_End_Date)
- Branch(Branch_ID, Branch_Location, Branch_Name, Branch_Start_Date)
- Track(Track_ID, Track_Name, Department_ID)
- Group(Group_ID, Intake_ID, Branch_ID, Track_ID)
- Student(Student_ID, Student_Mail, Student_Address, Student_Gender, Student_Marital_Status, Student_Fname, Student_Lname, Student_Birthdate, Student_Faculty, Student_Faculty_Grade, Student_ITI_Status, Intake_Branch_Track_ID)
- Failed_Students(Student_ID, Failure_Reason)
- Student_Phone(Student_ID, Phone)
- Student_Social(Student_ID, Social_Type, Social_Url)
- Freelance_Job(Job_ID, Student_ID, Job_Earn, Job_Date, Job_Site, Description)
- Certificate(Certificate_ID, Student_ID, Certificate_Name, Certificate_Provider, Certificate_Cost, Certificate_Date)
- Company(Company_ID, Company_Name, Company_Location, Company_Type)
- Student_Company(Student_ID, Company_ID, Salary, Position, Contract_Type, Hire_Date, Leave_Date)
- Course(Course_ID, Course_Name)
- Track_Course(Track_ID, Course_ID)
- Instructor_Course(Instructor_ID, Course_ID)
- Student_Course(Student_ID, Course_ID, Course_StartDate, Course_EndDate)
- Exam(Exam_ID, Course_ID, Instructor_ID, Exam_Date, Exam_Duration_Minutes, Exam_Type)
- Question_Bank(Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer)
- Question_Choice(Question_Choice_ID, Question_ID, Choice_Text)
- Exam_Questions(Exam_ID, Question_ID)
- Student_Exam_Answer(Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade)
- Rating(Student_ID, Instructor_ID, RatingValue)
- Topic(Topic_ID, Topic_Name, Course_ID)
"""

# Schema 2: ITI_DW_v5 (Data Warehouse)
schema_dw = """
SCHEMA: ITI_DW 
Dimension Tables: DimDate, DimStudent, DimInstructor, DimCourse, DimDepartment, DimTrack, DimBranch, DimIntake, DimCompany
Fact Tables: FactStudentPerformance, FactStudentOutcomes, FactStudentRating, FactFreelanceJob, FactCertificate, FactStudentFailure
Use Dim and Fact relationships to build analytical dashboards.

FactStudentOutcomes(StudentKey, CompanyKey, HireDateKey, Salary, DaysToHire)
FactStudentRating(StudentKey, InstructorKey, RatingValue, RateDateKey)
FactStudentPerformance(StudentKey, CourseKey, InstructorKey, ExamKey, QuestionKey, ExamDateKey, Student_Grade)
DimStudent(StudentKey, Student_FullName, TrackKey, BranchKey, IntakeKey)
DimTrack(TrackKey, Track_Name)
DimCompany(CompanyKey, Company_Name)
DimDate(DateKey, FullDate)
"""

# ============================================
# 🧭 Sidebar Navigation
# ============================================
st.sidebar.title("🔍 Choose Assistant")
app_mode = st.sidebar.radio(
    "Select Mode:",
    ["🧩 Text-to-SQL Assistant", "📊 Dashboard Generator"]
)

# ============================================
# 🧩 TEXT-TO-SQL ASSISTANT
# ============================================
if app_mode == "🧩 Text-to-SQL Assistant":
    st.subheader("🧩 Text-to-SQL Assistant (ITIExaminationSystem)")

    user_question = st.text_input("💬 Ask a question about the ITI Examination System:")
    if st.button("Generate SQL and Execute"):
        if not user_question.strip():
            st.warning("Please enter a question.")
        else:
            sql_prompt = f"""
You are a senior SQL Server expert helping to translate natural language questions into valid T-SQL queries.
Rules:
- Use SQL Server syntax only.
- Use explicit JOINs.
- Avoid reserved keywords.
- Return only executable SQL (no markdown).
Schema:


{schema_examination}
"""
            response = get_gemini_response(sql_prompt, user_question)
            cleaned_query = re.sub(r"--.*", "", response)
            cleaned_query = cleaned_query.replace("```sql", "").replace("```", "").strip()

            st.subheader("🧠 Generated SQL Query")
            st.code(cleaned_query, language="sql")

            try:
                df = read_sql_query(cleaned_query, "ITIExaminationSystem")
                st.success("✅ Query executed successfully!")
                st.dataframe(df)
            except Exception as e:
                st.error(f"❌ Error executing SQL query: {e}")

# ============================================
# 📊 DASHBOARD GENERATOR
# ============================================
elif app_mode == "📊 Dashboard Generator":
    st.subheader("📊 Intelligent Dashboard Generator")

    dashboard_description = st.text_input(
        "📝 Describe the dashboard you want to generate:",
        placeholder="Example: Show average student grades by department and track"
    )

    if st.button("Generate Dashboard"):
        if not dashboard_description.strip():
            st.warning("Please describe the dashboard.")
        else:
            dashboard_prompt = f"""
You are an expert data visualization and SQL assistant.
Given a database schema and a dashboard description, return ONLY valid JSON with chart definitions.



Rules:
- Use these exact names in SQL queries.
- Always use SQL Server syntax (TOP N instead of LIMIT).
- Join Fact and Dim tables properly.
- Return only valid SQL queries (no markdown).


Output format:
[
  {{
    "title": "Chart Title",
    "chart_type": "bar | line | pie | table | kpi",
    "sql": "SQL Server query string"
  }}
]

Rules:
- Use ITI_DW star schema.
- Use SQL Server syntax only (no LIMIT; use TOP N instead).
- Ensure joins between Fact and Dim tables are logical.
Schema:
{schema_dw}
"""
            try:
                model = load_model()
                response = model.generate_content([dashboard_prompt, dashboard_description])
                content = response.text.strip().replace("```json", "").replace("```", "").strip()
                charts = json.loads(content)

                st.success("✅ Dashboard generated successfully!")

                # Layout for a true dashboard look
                cols = st.columns(2)
                for i, chart in enumerate(charts):
                    with cols[i % 2]:
                        st.markdown(f"### {chart['title']}")
                        st.code(chart['sql'], language="sql")

                        try:
                            df = read_sql_query(chart["sql"], "ITI_DW")
                            if chart["chart_type"] == "table":
                                st.dataframe(df)
                            elif chart["chart_type"] == "bar":
                                fig = px.bar(df, x=df.columns[0], y=df.columns[1], title=chart['title'])
                                st.plotly_chart(fig, use_container_width=True)
                            elif chart["chart_type"] == "line":
                                fig = px.line(df, x=df.columns[0], y=df.columns[1], title=chart['title'])
                                st.plotly_chart(fig, use_container_width=True)
                            elif chart["chart_type"] == "pie":
                                fig = px.pie(df, names=df.columns[0], values=df.columns[1], title=chart['title'])
                                st.plotly_chart(fig, use_container_width=True)
                            elif chart["chart_type"] == "kpi":
                                st.metric(label=chart["title"], value=float(df.iloc[0, 0]))
                        except Exception as e:
                            st.error(f"⚠️ Could not execute chart query: {e}")

            except Exception as e:
                st.error(f"⚠️ Could not parse Gemini response: {e}")
                st.write("Raw output:")
                st.code(response.text)
