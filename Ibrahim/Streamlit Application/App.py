import streamlit as st
import streamlit.components.v1 as components
import pandas as pd
from pathlib import Path
import tempfile
import requests
import networkx as nx
from pyvis.network import Network
import base64

# Try to import pbixray
try:
    from pbixray import PBIXRay
except ImportError:
    st.error("Could not import `pbixray`. Please install it using: `pip install pbixray`")
    st.stop()

# --- Page setup ---
st.set_page_config(
    page_title="ITI Examination System Dashboard",
    page_icon="🎓",
    layout="wide",
)

# BACKGROUND IMAGE SETUP

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

# --- Header ---
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
        height: 120px;  /* Increase logo size here */
        margin-right: 20px;
        border-radius: 12px;
    }}
    .header-title {{
        font-size: 34px;  /* Slightly larger text */
        font-weight: 800;
        color: white;
        letter-spacing: 0.5px;
    }}
    </style>

    <div class="header-container">
        <img src="data:image/png;base64,{logo_base64}" alt="Logo">
        <div class="header-title">🎓 ITI Examination System Dashboard</div>
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
tab_powerbi, tab_tableau, tab_inspector = st.tabs([
    "📊 Power BI Dashboard",
    "📈 Tableau Dashboard",
    "🧩 PBIX Inspector"
])

# =====================================================================
# 🔷 TAB 1: Power BI Dashboard
# =====================================================================
with tab_powerbi:
    st.markdown("<h2 style='text-align:center;'>🎓 ITI Examination System — Power BI Dashboard</h2>", unsafe_allow_html=True)
    st.markdown("<p style='text-align:center;'>This dashboard is embedded directly from the Power BI Service.</p>", unsafe_allow_html=True)

    report_url = "https://app.powerbi.com/reportEmbed?reportId=469d6c4a-986b-4f01-bd21-f24cfaf961d1&autoAuth=true&ctid=aee5de94-75d5-4ee4-bcc5-4267ccd37fe2"

    st.markdown("""
        <style>
        iframe[title="streamlit.components.v1.html"] {
            width: 100% !important;
            height: 90vh !important;
            border-radius: 12px;
        }
        </style>
    """, unsafe_allow_html=True)

    components.iframe(report_url, height=850, scrolling=True)
    st.info("This is a live Power BI report. You can interact with filters and visuals directly.")

# =====================================================================
# 🔶 TAB 2: Tableau Dashboard
# =====================================================================
with tab_tableau:
    st.markdown("<h2 style='text-align:center;'>📈 ITI Examination System — Tableau Dashboard</h2>", unsafe_allow_html=True)
    st.markdown("<p style='text-align:center;'>This dashboard is embedded from Tableau Public.</p>", unsafe_allow_html=True)

    tableau_url = "https://public.tableau.com/views/SalesDashboard_17579406008640/SalesDashboard?:showVizHome=no&:embed=true"

    # --- FIX: Center the dashboard ---
    # We wrap the iframe in a <div> with 'margin: 0 auto' to center it.
    
    # These are the correct dimensions from your embed code
    DASH_WIDTH = 1200
    DASH_HEIGHT = 827

    # Create the HTML string
    iframe_html = f"""
    <div style="
        width: {DASH_WIDTH}px;      /* Set the fixed width */
        height: {DASH_HEIGHT}px;   /* Set the fixed height */
        margin: 0 auto;          /* This centers the <div> horizontally */
        overflow: hidden;        /* Hides scrollbars from the container */
        border-radius: 12px;     /* Optional: adds rounded corners */
        ">
        <iframe
            src="{tableau_url}"
            width="100%"
            height="100%"
            scrolling="yes"
            frameborder="0"
            style="border-radius: 12px;"
        >
        </iframe>
    </div>
    """
    
    # Use components.html to render the centered iframe
    # Set the component height slightly taller to avoid cut-off
    components.html(iframe_html, height=DASH_HEIGHT + 20) 

    st.info("This view is published from Tableau Public and mirrors your ITI Examination dashboard.")
# =====================================================================
# 🧩 TAB 3: PBIX Inspector
# =====================================================================
with tab_inspector:
    st.markdown("<h2 style='text-align:center;'>🧠 PBIX Model Inspector</h2>", unsafe_allow_html=True)
    st.markdown("<p style='text-align:center;'>Automatically analyzes your ITI Examination System Power BI model.</p>", unsafe_allow_html=True)

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

        # --- Relationship Graph ---
        with st.expander("🌐 Visual Relationship Graph", expanded=True):
            try:
                rel_df = model.relationships
                if rel_df is None or rel_df.empty:
                    st.info("No relationships found to visualize.")
                else:
                    rel_df.columns = [c.lower() for c in rel_df.columns]
                    src_col = next((c for c in rel_df.columns if "fromtable" in c), None)
                    tgt_col = next((c for c in rel_df.columns if "totable" in c), None)
                    src_field = next((c for c in rel_df.columns if "fromcolumn" in c), None)
                    tgt_field = next((c for c in rel_df.columns if "tocolumn" in c), None)

                    if not src_col or not tgt_col:
                        st.warning("⚠️ Could not find FromTable/ToTable columns.")
                    else:
                        G = nx.Graph()
                        for _, row in rel_df.iterrows():
                            src = str(row.get(src_col, "Unknown"))
                            tgt = str(row.get(tgt_col, "Unknown"))
                            label = ""
                            if src_field and tgt_field:
                                label = f"{row.get(src_field, '')} → {row.get(tgt_field, '')}"
                            G.add_edge(src, tgt, label=label)

                        net = Network(height="750px", width="100%", bgcolor="#0E1117", font_color="white", directed=False)
                        net.from_nx(G)
                        net.force_atlas_2based(gravity=-50, central_gravity=0.005, spring_length=120, damping=0.9)

                        with tempfile.NamedTemporaryFile(delete=False, suffix=".html") as tmpfile:
                            net.save_graph(tmpfile.name)
                            html_path = tmpfile.name

                        with open(html_path, "r", encoding="utf-8") as f:
                            graph_html = f.read()

                        components.html(graph_html, height=780, scrolling=True)
            except Exception as e:
                st.error(f"⚠️ Error rendering relationship graph: {e}")
