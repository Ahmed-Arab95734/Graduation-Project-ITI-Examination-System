# ================================
# 📊 ITI Examination System Assistant
# ================================

from dotenv import load_dotenv
import os
import re
import pandas as pd
import pypyodbc as odbc
import streamlit as st
import google.generativeai as genai
import base64

def get_base64_of_bin_file(bin_file):
    with open(bin_file, 'rb') as f:
        data = f.read()
    return base64.b64encode(data).decode()

def set_background(png_file):
    bin_str = get_base64_of_bin_file(png_file)
    page_bg_img = f'''
    <style>
    .stApp {{
        background-image: url("data:image/png;base64,{bin_str}");
        background-size: cover;
        background-position: center;
        background-repeat: no-repeat;
        background-attachment: fixed;
    }}
    </style>
    '''
    st.markdown(page_bg_img, unsafe_allow_html=True)

set_background("ITI_Background17601951402362703.png")

def get_base64_image(image_path):
    with open(image_path, "rb") as img_file:
        return base64.b64encode(img_file.read()).decode()


logo_path = "Gemini_Generated_Image_pwn1v3p13472503787887624.png"
logo_base64 = get_base64_image(logo_path)

st.markdown(
    f"""
    <style>
    .header-container {{
        display: flex;
        align-items: center;
        justify-content: flex-start;
        background-color: rgba(0, 0, 0, 0.3);
        padding: 15px 30px;
        border-radius: 12px;
        margin-bottom: 30px;
    }}
    .header-container img {{
        height: 120px;  /* Increase logo size here /
        margin-right: 20px;
        border-radius: 12px;
    }}
    .header-title {{
        font-size: 34px;  / Slightly larger text */
        font-weight: 800;
        color: white;
        letter-spacing: 0.5px;
    }}
    </style>

    <div class="header-container">
        <img src="data:image/png;base64,{logo_base64}" alt="Logo">
        <div class="header-title"> ITI Examination System Assistant (Text-to-SQL)</div>
    </div>
    """,
    unsafe_allow_html=True
)


# -----------------------------
# Load environment variables
# -----------------------------
load_dotenv()  # Load API key from .env

# -----------------------------
# Configure Gemini API
# -----------------------------
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

@st.cache_resource
def load_model():
    """Cache the Gemini model to avoid reloading every time."""
    return genai.GenerativeModel("models/gemini-2.5-pro")

# -----------------------------
# Function to call Gemini model
# -----------------------------
def get_gemini_response(question, prompt):
    model = load_model()
    response = model.generate_content([prompt, question])
    return response.text.strip()

# -----------------------------
# Function to execute SQL safely
# -----------------------------
def read_sql_query(query):
    DRIVER_NAME = 'SQL Server'
    SERVER_NAME = 'Haitham'
    DATABASE_NAME = 'ITIExaminationSystem'
    CONNECTION_STRING = f'DRIVER={{{DRIVER_NAME}}};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME};Trusted_Connection=yes;'

    connection = odbc.connect(CONNECTION_STRING)
    df = pd.read_sql(query, connection)
    connection.close()
    return df

# -----------------------------
# SQL generation prompt
# -----------------------------
prompt = """
You are a senior SQL Server expert helping to translate natural language questions into valid, executable T-SQL queries.

The database schema is as follows (Microsoft SQL Server syntax):

📚 SCHEMA OVERVIEW:
- Instructor(Instructor_ID, Instructor_Fname, Instructor_Lname, Instructor_Gender, Instructor_Birthdate, Instructor_Marital_Status, Instructor_Salary, Instructor_Contract_Type, Instructor_Email, Department_ID)
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

💡 RULES & INSTRUCTIONS:
1. Generate **only T-SQL (SQL Server syntax)**.
2. Do NOT use backticks (`) or MySQL-specific syntax.
3. Wrap identifiers in **[square brackets]** if necessary.
4. Always use **JOINs** explicitly — avoid implicit joins.
5. Always check foreign key relationships when linking tables.
6. Avoid using reserved keywords like “Group” without square brackets ([Group]).
7. The final query must be **executable** directly in SQL Server.
8. If the user asks a question about “top” or “limit”, use `SELECT TOP (N)` syntax.
9. For counting or summarizing, use `COUNT()`, `AVG()`, `SUM()`, etc. properly.
10. Include comments explaining what the query does if possible.


"""

# -----------------------------
# Streamlit UI
# -----------------------------
st.set_page_config(page_title="ITI Examination System Assistant", page_icon="🧠")


user_question = st.text_input("Ask your question about the ITI Examination System:")

if st.button("Generate and Run SQL"):
    if user_question.strip() == "":
        st.warning("Please enter a question.")
    else:
        # 1️⃣ Generate SQL
        response = get_gemini_response(user_question, prompt)
        st.subheader("Generated SQL Query (from Gemini):")
        st.code(response, language="sql")

        # 2️⃣ Clean query (remove markdown and comments)
        cleaned_query = re.sub(r"--.*", "", response)
        cleaned_query = cleaned_query.replace("```sql", "").replace("```", "").strip()

        # 3️⃣ Execute SQL safely
        try:
            df = read_sql_query(cleaned_query)
            st.success("✅ Query executed successfully!")
            st.dataframe(df)
        except Exception as e:
            st.error(f"❌ Error executing SQL query: {e}")
# -----------------------------