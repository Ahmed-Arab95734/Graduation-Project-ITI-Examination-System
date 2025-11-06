import streamlit as st
import streamlit.components.v1 as components

# --- PAGE SETUP ---
st.set_page_config(layout="wide", page_title="Power BI Dashboard", page_icon="📊")

# --- CUSTOM STYLING ---
st.markdown(
    """
    <style>
        body {
            background-color: white;
        }
        .main {
            background-color: white;
        }
        /* Sidebar styling */
        [data-testid="stSidebar"] {
            background-color: #f7f7f7;
            border-right: 2px solid #e0e0e0;
        }
        /* Titles */
        h1, h2, h3 {
            color: #003366; /* deep blue */
        }
        /* Selectbox label */
        label {
            color: #003366 !important;
            font-weight: 600 !important;
        }
        /* Accent buttons / general elements */
        .stButton>button {
            background-color: #d80032; /* red */
            color: white;
            border-radius: 8px;
            padding: 0.5rem 1rem;
        }
        .stButton>button:hover {
            background-color: #b40028;
        }
    </style>
    """,
    unsafe_allow_html=True
)

# --- HEADER ---
st.title("📊 CLOUD SSRS REPORTS")
st.subheader("Use these login credentials to view the reports:")
st.subheader("Email: ahmedmohamed3805_sd@nsst.bsu.edu.eg | Password: Team2_ITI_12345")

# --- REPORT DICTIONARY ---
REPORTS = {
    "Course Topics": "https://app.powerbi.com/rdlEmbed?reportId=c415569d-8ceb-4aae-bbcd-69de90e9ff1e&autoAuth=true&ctid=0ffeb7b8-177f-48b0-809f-2499efab9107&experience=power-bi&rs:embed=true",
    "Instructor Courses & Number of Students": "https://app.powerbi.com/rdlEmbed?reportId=8ca9c034-34f4-4a44-9b72-e6958dae8e33&autoAuth=true&ctid=0ffeb7b8-177f-48b0-809f-2499efab9107&experience=power-bi&rs:embed=true",
    "Exam Questions": "https://app.powerbi.com/rdlEmbed?reportId=499f71c2-4480-43b5-8051-5d2ab9690c9f&autoAuth=true&ctid=0ffeb7b8-177f-48b0-809f-2499efab9107&experience=power-bi&rs:embed=true",
    "Student Exam Answers": "https://app.powerbi.com/rdlEmbed?reportId=51d593f5-6d84-448a-870c-fc87c6ac9226&autoAuth=true&ctid=0ffeb7b8-177f-48b0-809f-2499efab9107&experience=power-bi&rs:embed=true",
    "Student Grades": "https://app.powerbi.com/rdlEmbed?reportId=04d7f8b2-14e4-4d20-b8f8-36b2aea2657d&autoAuth=true&ctid=0ffeb7b8-177f-48b0-809f-2499efab9107&experience=power-bi&rs:embed=true",
    "Student Details by Track": "https://app.powerbi.com/rdlEmbed?reportId=7d2cf478-032e-4428-abdd-2bd31d4e43cc&autoAuth=true&ctid=0ffeb7b8-177f-48b0-809f-2499efab9107&experience=power-bi&rs:embed=true",
}

# --- SIDEBAR ---
st.sidebar.header("🔎 Select a Report")
selected_report_name = st.sidebar.selectbox(
    "Report:",
    options=list(REPORTS.keys())
)

# --- DISPLAY SELECTED REPORT ---
report_to_display_url = REPORTS[selected_report_name]

st.header(f"Showing: {selected_report_name}")
components.iframe(report_to_display_url, height=900, scrolling=True)


