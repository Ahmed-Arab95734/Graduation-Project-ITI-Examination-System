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
tab_powerbi, tab_tableau, tab_inspector, SSRS_Report= st.tabs([
    "📊 Power BI Dashboard",
    "📈 Tableau Dashboard",
    "🧩 PBIX Inspector",
    "SSRS_Report"
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
# 🧩 TAB 4: SSRS Report
# =====================================================================
with SSRS_Report:

# --- PAGE SETUP ---

    st.markdown("<h2 style='text-align:center;'>🧮 SSRS Reporting</h2>", unsafe_allow_html=True)
    st.markdown("<p style='text-align:center;'>Automatically analyzes your ITI Examination System Power BI model.</p>", unsafe_allow_html=True)
    st.divider()
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



