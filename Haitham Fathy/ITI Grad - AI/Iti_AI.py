import streamlit as st
import pandas as pd
import joblib
from catboost import CatBoostClassifier, Pool

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
        <div class="header-title">🎓 ITI Examination System Dashboard</div>
    </div>
    """,
    unsafe_allow_html=True
)
# -----------------------------
# 1. Page Configuration
# -----------------------------
st.set_page_config(
    page_title="Student Employment Predictor",
    page_icon="🎓",
    layout="centered",
    initial_sidebar_state="collapsed"
)

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
st.title("🎓 Student Employment Predictor")
st.markdown("Use this app to predict whether a student is likely to be **employed** after completing their ITI program.")

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

