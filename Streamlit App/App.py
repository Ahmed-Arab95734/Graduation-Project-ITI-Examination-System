import streamlit as st
import streamlit.components.v1 as components
import pandas as pd
from pathlib import Path
import tempfile
import requests
import networkx as nx
from pyvis.network import Network
import base64
import os
import re
from dotenv import load_dotenv
import pypyodbc as odbc
import google.generativeai as genai
import joblib
from catboost import CatBoostClassifier, Pool

# Try to import pbixray
try:
    from pbixray import PBIXRay
except ImportError:
    st.error("Could not import `pbixray`. Please install it using: `pip install pbixray`")
    st.stop()

# --- Page setup (set ONCE) ---
st.set_page_config(
    page_title="ITI Examination System Dashboard",
    page_icon="🎓",
    layout="wide",
)

# ------------------------------
# BACKGROUND IMAGE SETUP
# ------------------------------
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

# ------------------------------
# LOGO SETUP
# ------------------------------
def get_base64_image(image_path):
    with open(image_path, "rb") as img_file:
        return base64.b64encode(img_file.read()).decode()

logo_path = "Gemini_Generated_Image_pwn1v3p13472503787887624.png"
logo_base64 = get_base64_image(logo_path)

# --- Header ---
st.markdown(
    f"""
    <style>
    .header-container {{
        display: flex;
        align-items: center;
        justify-content: center; /* Centers content horizontally */
        gap: 15px; /* Space between logo and title */
        margin-bottom: 25px;
    }}
    .header-container img {{
        height: 160px;  /* Increased logo size */
        margin-right: 25px;
        border-radius: 12px;
    }}
    .header-title {{
        font-size: 36px;
        font-weight: 800;
        color: white;
        letter-spacing: 0.5px;
    }}
    </style>

    <div class="header-container">
        <img src="data:image/png;base64,{logo_base64}" alt="Logo">
        <div class="header-title">🎓 ITI Examination System Web Application</div>
    </div>
    """,
    unsafe_allow_html=True
)

# --- Session state ---
if 'pbi_model' not in st.session_state:
    st.session_state.pbi_model = None
if 'file_path' not in st.session_state:
    st.session_state.file_path = ""

# --- Tabs ---
tab_powerbi, tab_tableau, tab_inspector, text_to_sql, AI = st.tabs([
    "📊 Power BI Dashboard",
    "📈 Tableau Dashboard",
    "🧩 PBIX Inspector",
    "🧠 Text To SQL Using Gemini",
    "⚙️ AI Student Employment Predictor"
])

# =====================================================================
# 🔷 TAB 1: Power BI Dashboard
# =====================================================================
with tab_powerbi:
    st.markdown("<h2 style='text-align:center;'>📊 Power BI Dashboard</h2>", unsafe_allow_html=True)
    st.divider()
    report_url = "https://app.powerbi.com/reportEmbed?reportId=469d6c4a-986b-4f01-bd21-f24cfaf961d1&autoAuth=true&ctid=aee5de94-75d5-4ee4-bcc5-4267ccd37fe2"

    components.iframe(report_url, height=850, scrolling=True)
    st.info("This is a live Power BI report. You can interact with filters and visuals directly.")

# =====================================================================
# 🔶 TAB 2: Tableau Dashboard
# =====================================================================
with tab_tableau:
    st.markdown("<h2 style='text-align:center;'>📈 Tableau Dashboard</h2>", unsafe_allow_html=True)
    st.divider()
    tableau_url = "https://public.tableau.com/views/SalesDashboard_17579406008640/SalesDashboard?:showVizHome=no&:embed=true"
    DASH_WIDTH, DASH_HEIGHT = 1300, 850

    iframe_html = f"""
    <div style="width:{DASH_WIDTH}px;height:{DASH_HEIGHT}px;margin:0 auto;border-radius:12px;">
        <iframe src="{tableau_url}" width="100%" height="100%" frameborder="0" style="border-radius:12px;"></iframe>
    </div>
    """
    components.html(iframe_html, height=DASH_HEIGHT + 20)
    st.info("This view is published from Tableau Public and mirrors your ITI Examination dashboard.")


# =====================================================================
# 🧩 TAB 3: PBIX Inspector
# =====================================================================
with tab_inspector:
    st.markdown("<h2 style='text-align:center;'>🧠 PBIX Model Inspector</h2>", unsafe_allow_html=True)
    st.markdown("<p style='text-align:center;'>Automatically analyzes your ITI Examination System Power BI model.</p>", unsafe_allow_html=True)
    st.divider()
    github_pbix_url = (
        "https://github.com/Ahmed-Arab95734/Graduation-Project-ITI-Examination-System/"
        "raw/main/Ibrahim/Streamlit%20Application/ITI_Dashboard_Graduaton_Project.pbix"
    )

    def auto_load_pbix(url):
        try:
            with st.spinner("📥 Downloading PBIX file from GitHub..."):
                response = requests.get(url)
                response.raise_for_status()
                with tempfile.NamedTemporaryFile(delete=False, suffix=".pbix") as tmp_file:
                    tmp_file.write(response.content)
                    tmp_path = Path(tmp_file.name)
            with st.spinner("🔍 Analyzing PBIX file..."):
                model = PBIXRay(tmp_path)
                st.session_state.pbi_model = model
                st.session_state.file_path = str(tmp_path)
            st.success("✅ PBIX file loaded successfully!")
        except Exception as e:
            st.error(f"❌ Error loading PBIX file: {e}")

    if st.session_state.pbi_model is None:
        auto_load_pbix(github_pbix_url)

    if not st.session_state.pbi_model:
        st.warning("⚠️ PBIX model could not be loaded.")
    else:
        model = st.session_state.pbi_model
        st.success("✅ PBIX model analyzed successfully!")

        # --- DAX Measures ---
        with st.expander("🧮 DAX Measures", expanded=True):
            try:
                dax_df = model.dax_measures
                st.dataframe(dax_df if not dax_df.empty else pd.DataFrame(["No DAX measures found."]))
            except Exception as e:
                st.error(f"Error reading DAX: {e}")

        # --- Power Query ---
        with st.expander("⚙️ Power Query (M) Code"):
            try:
                m_df = model.power_query
                st.dataframe(m_df if not m_df.empty else pd.DataFrame(["No Power Query found."]))
            except Exception as e:
                st.error(f"Error reading Power Query: {e}")

        # --- Schema ---
        with st.expander("🧱 Data Model Schema"):
            try:
                schema_df = model.schema
                st.dataframe(schema_df if not schema_df.empty else pd.DataFrame(["No Schema found."]))
            except Exception as e:
                st.error(f"Error reading Schema: {e}")

        # --- Relationships ---
        with st.expander("🔗 Model Relationships", expanded=True):
            try:
                rel_df = model.relationships
                if rel_df is not None and not rel_df.empty:
                    st.dataframe(rel_df)
                else:
                    st.info("No relationships found in this PBIX model.")
            except Exception as e:
                st.error(f"Error reading relationships: {e}")

            except Exception as e:
                st.error(f"⚠️ Error rendering relationship graph: {e}")


# =====================================================================
# 🧠 TAB 4: Text to SQL using Gemini
# =====================================================================

with text_to_sql:

    st.markdown("<h2 style='text-align:center;'>🧠 ITI Examination System Assistant</h2>", unsafe_allow_html=True)
    st.markdown("<p style='text-align:center;'> Text To SQL Smart Assistant For ITI Examination System.</p>", unsafe_allow_html=True)
    st.divider()
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
        SERVER_NAME = 'HIMA'
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

# =====================================================================
# ⚙️ TAB 5: AI Student Employment Predictor
# =====================================================================
with AI:
    # -----------------------------
    # 2. Load trained CatBoost model
    # -----------------------------
    @st.cache_resource
    def load_model():
        return joblib.load("catboost_employment_model.pkl")

    model = load_model()

    # -----------------------------
    # 3. Define categorical mappings
    # -----------------------------
    categorical_features = ["student_faculty", "student_gender", "student_marital_status", "grade_bucket"]

    faculty_grade_map = {'Pass': 3, 'Good': 2, 'Very Good': 1, 'Excellent': 0}
    iti_status_map = {'Failed to Graduate': 1, 'Graduated': 0}

    # -----------------------------
    # 4. App Title
    # -----------------------------
    st.markdown("<h2 style='text-align:center;'>⚙️ Student Employment Predictor</h2>", unsafe_allow_html=True)

    st.markdown("<p style='text-align:center;'> Predict Whether a Student is Likely To Be Employed After Completing ITI Program.</p>", unsafe_allow_html=True)

    st.divider()

    # -----------------------------
    # 5. Input Section
    # -----------------------------
    st.header("📋 Student Details")

    col1, col2 = st.columns(2)

    with col1:
        student_faculty_grade = st.selectbox("Faculty Grade", list(faculty_grade_map.keys()))
        student_iti_status = st.selectbox("ITI Status", list(iti_status_map.keys()))
        total_grade = st.number_input("Total Grade", min_value=0.0, max_value=100.0, step=0.1)
        grade_bucket = st.selectbox("Grade Bucket", ['Low', 'Medium', 'High', 'Top'])

    with col2:
        student_faculty = st.selectbox("Faculty", [
            'Faculty of Computers Sciences', 'Faculty of Engineering', 'Faculty of Information Systems',
            'Faculty of Business Administration', 'Faculty of Commerce', 'Faculty of Agriculture',
            'Faculty of Science', 'Faculty of Fine Arts', 'Faculty of Applied Arts',
            'Faculty of Arts', 'Faculty of Economics and Political Science', 'Faculty of Education'
        ])
        student_gender = st.selectbox("Gender", ['Male', 'Female'])
        student_marital_status = st.selectbox("Marital Status", ['Single', 'Married'])

    st.divider()

    # -----------------------------
    # 6. Prepare input for prediction
    # -----------------------------
    input_dict = {
        "student_faculty_grade": [faculty_grade_map[student_faculty_grade]],
        "student_iti_status": [iti_status_map[student_iti_status]],
        "total_grade": [total_grade],
        "student_faculty": [student_faculty],
        "student_gender": [student_gender],
        "student_marital_status": [student_marital_status],
        "grade_bucket": [grade_bucket]
    }

    input_df = pd.DataFrame(input_dict)

    # -----------------------------
    # 7. Prediction Section
    # -----------------------------
    if st.button("🔍 Predict Employment Status", use_container_width=True):
        with st.spinner("Analyzing student profile..."):
            input_pool = Pool(input_df, cat_features=categorical_features)
            prediction = model.predict(input_pool)[0]
            prediction_proba = model.predict_proba(input_pool)[0]

        st.divider()
        st.header("📊 Prediction Result")

        if prediction == 1:
            st.success("✅ **The student is likely to be Employed**")
        else:
            st.error("❌ **The student is likely to be Unemployed**")

        st.subheader("🔢 Prediction Probabilities")
        col_a, col_b = st.columns(2)
        col_a.metric("Employed Probability", f"{prediction_proba[1]*100:.1f} %")
        col_b.metric("Unemployed Probability", f"{prediction_proba[0]*100:.1f} %")

        st.caption("⚙️ Model: CatBoostClassifier | Based on academic and demographic inputs")

