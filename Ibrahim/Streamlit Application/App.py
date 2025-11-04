import streamlit as st
import streamlit.components.v1 as components
import pandas as pd
from pathlib import Path
import io

# Try to import pbixray. If it fails, show a helpful error message.
try:
    from pbixray import PBIXRay
except ImportError:
    st.error(
        "Could not import 'pbixray'. Please install it first by running:\n"
        "`pip install pbixray`"
    )
    st.stop()

# --- 1. App Configuration ---
st.set_page_config(
    page_title="My Dashboard & PBIX Inspector",
    layout="wide",
)

# --- Session State for Inspector ---
if 'pbi_model' not in st.session_state:
    st.session_state.pbi_model = None
if 'file_path' not in st.session_state:
    st.session_state.file_path = ""

# --- Create Tabs ---
Power_Bi_dashboard,Tableau_dashboard, tab_inspector = st.tabs([
    "Power_Bi_dashboard", 
    "Tableau_dashboard",
    "tab_inspector"
])
# ==============================================================================
# --- TAB 1: YOUR RE-CREATED HOTEL DASHBOARD ---
# ==============================================================================
with Power_Bi_dashboard:
    st.header(" Hotel Dashboard")
    st.markdown("This dashboard is loaded from the Power BI Publish Service")

    report_server_url = "https://app.powerbi.com/reportEmbed?reportId=469d6c4a-986b-4f01-bd21-f24cfaf961d1&autoAuth=true&ctid=aee5de94-75d5-4ee4-bcc5-4267ccd37fe2"

    # Embed the iframe
    st.write("Displaying the report:")
    components.iframe(report_server_url, height=800, scrolling=True)

    st.info(
        "**Note:** This is a view-only embedded report. "
        "To analyze the report's structure, download the `.pbix` file from Power BI "
        "and use the **'PBIX Inspector'** tab."
    )

# ==============================================================================
# --- TAB 2: YOUR RE-CREATED tableau DASHBOARD ---
# ==============================================================================

with Tableau_dashboard:
    st.header("My Re-created Hotel Dashboard")
    st.markdown("This dashboard is loaded from the Tableau Public Service")

    report_server_url = "https://public.tableau.com/views/SalesDashboard_17579406008640/SalesDashboard?:showVizHome=no&:embed=true"

    # Embed the iframe
    st.write("Displaying the report:")
    
    # --- FIX ---
    # Get these dimensions from your Tableau Public 'Share' -> 'Embed Code' option
    # Using example dimensions here:
    components.iframe(report_server_url, width=2000, height=800, scrolling=False)

    st.info(
        "**Note:** This is a view-only embedded report. "
        "To analyze the report's structure."
    )

# ==============================================================================
# --- TAB 3: PBIX INSPECTOR TOOL ---
# ==============================================================================
with tab_inspector:
    st.header("PBIX Inspector")
    st.markdown(
        "Use this tool to inspect the **logic** (DAX, M-Code, Schema) of a `.pbix` file. "
        "This tool **does not** extract the data or charts."
    )
    
    # --- Helper Function for Inspector ---
    def load_pbix(file_path_str="ITI_Dashboard_Graduaton_Project.pbix"):
        if not file_path_str:
            st.toast("Please enter a file path.")
            return

        file_path = Path(file_path_str.strip().strip('"')) # Clean up path
        
        if not file_path.exists():
            st.error(f"Error: File not found at '{file_path_str}'. Please check the path.")
            st.session_state.pbi_model = None
            return
        
        try:
            with st.spinner(f"Loading and inspecting '{file_path.name}'..."):
                st.session_state.pbi_model = PBIXRay(file_path)
                st.session_state.file_path = file_path_str
            st.success(f"Successfully loaded '{file_path.name}'!")
        except Exception as e:
            st.error(f"An error occurred while loading the file: {e}")
            st.session_state.pbi_model = None

    # --- Inspector UI ---
    st.subheader("Load a PBIX File")
    file_path_input = st.text_input(
        "Enter .pbix file path:", 
        value=st.session_state.file_path,
        placeholder="ITI_Dashboard_Graduaton_Project.pbix"
    )

    if st.button("Load & Inspect File"):
        load_pbix(file_path_input)
        
    st.markdown("---")

    # --- Inspector Results ---
    if not st.session_state.pbi_model:
        st.info("Please load a `.pbix` file to inspect it.")
    else:
        st.subheader("Inspector Results")
        model = st.session_state.pbi_model
        
        try:
            # 1. DAX Measures
            with st.expander("DAX Measures"):
                dax_measures_df = model.dax_measures
                if not dax_measures_df.empty:
                    st.dataframe(dax_measures_df)
                else:
                    st.info("No DAX measures found in this model.")

            # 2. Power Query (M)
            with st.expander("Power Query (M) Code"):
                power_query_df = model.power_query
                if not power_query_df.empty:
                    st.dataframe(power_query_df)
                else:
                    st.info("No Power Query expressions found.")

            # 3. Model Schema
            with st.expander("Data Model Schema"):
                schema_df = model.schema
                if not schema_df.empty:
                    st.dataframe(schema_df)
                else:
                    st.info("Could not retrieve model schema.")
            
            # 4. Relationships
            with st.expander("Model Relationships"):
                relationships_df = model.relationships
                if not relationships_df.empty:
                    st.dataframe(relationships_df)
                else:
                    st.info("No relationships found in this model.")

        except Exception as e:
            st.error(f"An error occurred while inspecting the file: {e}")
            st.info("This can sometimes happen with complex or corrupted .pbix files.")

