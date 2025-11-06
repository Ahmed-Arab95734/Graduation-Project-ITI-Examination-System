"""
streamlit_app.py
Multi-step Streamlit app "ITI Student Exam Portal" that reads/writes from Firebase Realtime Database.
Run: streamlit run streamlit_app.py
"""

import streamlit as st
import requests
import os
import time
import random
import json
from dotenv import load_dotenv

load_dotenv()

# --- Page Configuration & URLs ---
st.set_page_config(page_title="ITI Student Exam Portal", layout="wide")

# *** 1. SET YOUR URLs HERE ***
ITI_LOGO_URL = "https://iti.gov.eg/assets/images/ColoredLogo.svg"  # <-- PUT YOUR ITI LOGO URL HERE
BACKGROUND_IMAGE_URL = "https://i.ibb.co/tT7vYnPL/ITI-Background17601951402362703.png"  # <-- PUT YOUR BACKGROUND URL HERE

# --- Firebase Configuration ---
FIREBASE_URL = os.getenv("FIREBASE_URL")  # e.g. https://project-id-default-rtdb.firebaseio.com

if not FIREBASE_URL:
    st.error("FIREBASE_URL not set in .env")
    st.stop()

def fb_url(path):
    auth =""
    return f"{FIREBASE_URL.rstrip('/')}/{path}.json{auth}"

# --- Firebase Helper Functions ---
def fb_get(path):
    url = fb_url(path)
    try:
        r = requests.get(url)
        r.raise_for_status()  # Raise an exception for bad status codes
        return r.json() or {}
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data from Firebase path '{path}': {e}") # Replaced st.error with print
        return {}
    except json.JSONDecodeError:
        print(f"Error decoding JSON from Firebase path '{path}'. Response was: {r.text}") # Replaced st.error with print
        return {}

def fb_post(path, payload):
    url = fb_url(path)
    try:
        r = requests.post(url, json=payload)
        r.raise_for_status()
        return r.json()
    except requests.exceptions.RequestException as e:
        print(f"Error posting data to Firebase path '{path}': {e}") # Replaced st.error with print
        return None

def fb_put(path, payload):
    url = fb_url(path)
    try:
        r = requests.put(url, json=payload)
        r.raise_for_status()
        return r.json()
    except requests.exceptions.RequestException as e:
        print(f"Error putting data to Firebase path '{path}': {e}") # Replaced st.error with print
        return None

# --- Data Loading ---
@st.cache_resource
def load_all_data():
    # REMOVED: st.toast("Loading exam data from Firebase Realtime Database...")
    # This was causing the CacheReplayClosureError.
    # The st.spinner outside this function already handles the loading message.
    
    def process_to_id_map(raw_data, id_field_name):
        """Converts raw data (list or dict) to a dict keyed by the ID field."""
        processed_map = {}
        if isinstance(raw_data, dict):
            for key, val in raw_data.items():
                if not (val and isinstance(val, dict)):
                    continue
                cid = val.get(id_field_name)
                if cid:
                    processed_map[str(cid)] = val
                elif key.isdigit():
                    processed_map[key] = val
        elif isinstance(raw_data, list):
            for idx, val in enumerate(raw_data):
                if not (val and isinstance(val, dict)):
                    continue
                cid = val.get(id_field_name)
                if cid:
                    processed_map[str(cid)] = val
                else:
                    processed_map[str(idx)] = val
        return processed_map

    courses = process_to_id_map(fb_get("courses"), "Course_ID")
    exams = process_to_id_map(fb_get("exams"), "Exam_ID")
    questions = process_to_id_map(fb_get("questions"), "Question_ID")

    student_courses_raw = fb_get("student_courses")
    student_courses_map = {}
    if isinstance(student_courses_raw, dict):
        student_courses_map = student_courses_raw
    elif isinstance(student_courses_raw, list):
        for idx, val in enumerate(student_courses_raw):
            if val:
                student_courses_map[str(idx)] = val
    
    choices = fb_get("choices")
    
    def get_as_dict(path):
        data = fb_get(path)
        if isinstance(data, dict):
            return data or {}
        if isinstance(data, list):
            converted_dict = {}
            for idx, val in enumerate(data):
                if val:
                    converted_dict[str(idx)] = val
            return converted_dict
        print(f"Data at path '{path}' was not a dictionary or list. Using empty map.") # Replaced st.error with print
        return {}

    exam_questions_grouped = get_as_dict("exam_questions_grouped")
    choices_by_question = get_as_dict("choices_by_question")
    
    return {
        "courses": courses,
        "student_courses": student_courses_map,
        "exams": exams,
        "questions": questions,
        "choices": choices,
        "exam_questions_grouped": exam_questions_grouped,
        "choices_by_question": choices_by_question
    }

# --- GUI Styling ---
# *** 3. Custom CSS Styling ***
# *** 3. Custom CSS Styling ***
# *** 3. Custom CSS Styling ***
st.markdown(f"""
<style>
    /* --- Base --- */
    body {{
        background-image: url("{BACKGROUND_IMAGE_URL}");
        background-size: cover;
        background-repeat: no-repeat;
        background-attachment: fixed;
        color: #FFFFFF; /* Make all base text white */
    }}
    .stApp {{
        background-color: transparent;
    }}
    /* --- Main Content Box --- */
    [data-testid="stAppViewContainer"] > .main .block-container {{
        background-color: rgba(10, 10, 10, 0.85); /* Dark semi-transparent */
        border-radius: 20px;
        padding: 2rem 3rem;
        margin-top: 2rem;
        border: 1px solid rgba(200, 200, 200, 0.2);
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
    }}
    /* --- Headers & Text (FIX: More specific) --- */
    [data-testid="stAppViewContainer"] h1,
    [data-testid="stAppViewContainer"] h2,
    [data-testid="stAppViewContainer"] h3 {{
        color: #FFFFFF !important; /* Bright white titles */
        font-weight: 600;
        text-align: center; /* FIX: Center titles */
    }}
    .stMarkdown {{
        color: #FAFAFA; /* Off-white for body text */
    }}
    
    /* FIX: Center Question Text */
    [data-testid="stForm"] [data-testid="stMarkdown"] p {{
        
        font-size: 1.15rem; /* Make questions a bit bigger */
        font-weight: 600;
        color: #FFFFFF;
    }}

    /* --- Logo --- */
    [data-testid="stImage"] img {{
        border-radius: 10px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    }}
    /* --- Buttons --- */
    .stButton > button {{
        background-color: #C00000; /* ITI Red */
        color: white;
        border: 1px solid #A00000; /* Darker red border */
        border-radius: 10px;
        font-weight: 600;
        transition: all 0.2s ease;
        padding: 0.5rem 1rem;
    }}
    .stButton > button:hover {{
        background-color: #A00000; /* Darker red on hover */
        color: white;
        border: 1px solid #C00000;
    }}
    /* --- Inputs --- */
    .stTextInput input, .stSelectbox [data-baseweb="select"] > div {{
        border-radius: 10px;
        border: 1px solid rgba(255, 255, 255, 0.3);
        background-color: rgba(50, 50, 50, 0.5);
        color: #FFFFFF;
    }}
    /* --- Exam Choices (Radio) --- */
    .stRadio {{
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 10px;
        padding: 1rem 1.5rem;
    }}

    /* Make sure the label text itself is white */
    .stRadio [data-baseweb="radio"] div label {{
        color: #FFFFFF !important;
    }}

    /* Style for HOVERED radio item */
    .stRadio [data-baseweb="radio"] div:hover {{
        background-color: rgba(255, 255, 255, 0.2);
    }}
    /* Style for SELECTED radio item */
    .stRadio [data-baseweb="radio"][aria-checked="true"] > div {{
        background-color: #C00000; /* ITI Red for selected */
        color: #FFFFFF !important;
        border: 1px solid #FF4136; /* Brighter red border */
    }}
    /* Style for each radio item */
    .stRadio [data-baseweb="radio"] div {{

        
        color: #FFFFFF !important; /* Make radio label text white */

    }}
    
    /* --- Timer --- */
    .timer-box {{
        position: fixed;
        top: 10px;
        right: 20px;
        background-color: rgba(10, 10, 10, 0.8); /* Dark background */
        color: #FF4136; /* Bright Red */
        padding: 0.75rem 1.25rem;
        border-radius: 10px;
        font-size: 1.25rem;
        font-weight: 800;
        border: 1px solid #FF4136;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
        z-index: 1000;
    }}
    /* --- Form (to remove extra space) --- */
    [data-testid="stForm"] {{
        padding: 0;
        border: none;
    }}
</style>
""", unsafe_allow_html=True)
# --- Load Data with Spinner ---
with st.spinner("Connecting to Exam Database..."):
    data = load_all_data()
# st.success("Data loaded successfully!") # Optional: can be too noisy

# --- Page Title & Logo ---
st.image(ITI_LOGO_URL)
st.title("ITI Student Exam Portal")


# --- Session State Initialization ---
if "step" not in st.session_state:
    st.session_state.step = 1
if "student_id" not in st.session_state:
    st.session_state.student_id = None
if "selected_course_id" not in st.session_state:
    st.session_state.selected_course_id = None
if "exam_id" not in st.session_state:
    st.session_state.exam_id = None
if "exam_questions" not in st.session_state:
    st.session_state.exam_questions = []
if "answers" not in st.session_state:
    st.session_state.answers = {}  # question_id -> answer text (or None)
if "end_time" not in st.session_state:
    st.session_state.end_time = None
if "duration_minutes" not in st.session_state:
    st.session_state.duration_minutes = 0

# --- UI Functions (Steps) ---

def step1_ui():
    st.subheader("Step 1 — Student Authentication")
    st.write("Please enter your Student ID to find your available exams.")
    sid = st.text_input("Enter Your Student ID", key="student_id_input", label_visibility="collapsed")
    
    if st.button("Find My Exams"):
        if not sid:
            st.warning("Please enter your Student ID.")
            return
        # set and go to step 2
        st.session_state.student_id = sid
        st.session_state.step = 2
        st.rerun()

def step2_ui():
    st.subheader("Step 2 — Course Selection")
    sid = st.session_state.student_id
    st.info(f"Welcome, Student ID: **{sid}**")
    st.write("Please select an exam from your available courses.")

    # Find student_course rows where Student_ID matches
    sc_map = data["student_courses"] or {}
    courses_map = data["courses"] or {}

    available = []
    if isinstance(sc_map, dict):
        for key, sc in sc_map.items():
            try:
                sc_student = str(sc.get("Student_ID") or sc.get("student_id") or sc.get("StudentID"))
            except Exception:
                sc_student = None
            
            if sc_student == str(sid):
                cid = str(sc.get("Course_ID"))
                course = courses_map.get(cid) 
                if course:
                    available.append((cid, course.get("Course_Name")))
    else:
        st.error("Student courses data is not in the expected dictionary format.")

    if not available:
        st.error("No courses found for this Student ID. Please contact your administrator.")
        # No "Back" button, student is stuck here. They must refresh.
        return

    # build dropdown
    options = {name: cid for cid, name in available if name} # Filter out None names
    if not options:
        st.error("Courses found, but they have no names. Please contact your administrator.")
        return
        
    choice = st.selectbox("Select an Available Exam", options=list(options.keys()))
    
    if st.button("Start Selected Exam"):
        st.session_state.selected_course_id = options[choice]
        st.session_state.step = 3
        st.rerun()
    
    # REMOVED: "Back" button

def start_exam_for_course(course_id):
    exams_map = data["exams"]
    matching = [eid for eid, e in exams_map.items() if str(e.get("Course_ID")) == str(course_id)]
    if not matching:
        return None
    chosen = random.choice(matching)
    return chosen

def step3_ui():
    st.subheader("Step 3 — Exam In Progress")
    course_id = st.session_state.selected_course_id

    # pick random exam if not chosen already
    if not st.session_state.exam_id:
        exam_id = start_exam_for_course(course_id)
        if not exam_id:
            st.error("No exam found for this course.")
            # REMOVED: "Back to courses" button
            return
        st.session_state.exam_id = exam_id
        exam_info = data["exams"].get(str(exam_id), {})
        
        dur = exam_info.get("Exam_Duration_Minutes") or exam_info.get("Exam_Duration")
        try:
            dur = int(dur)
        except (ValueError, TypeError):
            dur = 30  # Default duration
        
        st.session_state.duration_minutes = dur
        st.session_state.end_time = time.time() + dur * 60
        st.session_state.exam_questions = data["exam_questions_grouped"].get(str(exam_id), [])
        
        # FIX: Initialize answers map with None for no default selection
        st.session_state.answers = {str(qid): None for qid in st.session_state.exam_questions}

    # Display the Exam ID
    if st.session_state.exam_id:
        st.caption(f"Student ID: {st.session_state.student_id} | Exam ID: {st.session_state.exam_id}")

    # show timer
    remaining = int(st.session_state.end_time - time.time())
    if remaining <= 0:
        st.warning("Time is up. Submitting...")
        st.toast("Time's up! Automatically submitting your exam.", icon="⏰")
        submit_answers()
        st.rerun() # Rerun to go to step 4
        return
        
    minutes = remaining // 60
    seconds = remaining % 60
    st.markdown(f"**Time remaining: {minutes:02d}:{seconds:02d}**")

    # Render questions
    questions_map = data["questions"]
    choices_by_q = data["choices_by_question"]

    st.write("---")
    with st.form(key="exam_form"):
        for idx, qid in enumerate(st.session_state.exam_questions, start=1):
            qid_s = str(qid)
            q = questions_map.get(qid_s)
            if not q:
                st.error(f"Question {qid_s} not found.")
                continue
            
            st.write(f"**Q{idx}. {q.get('Question_Description')}**")
            qtype = q.get("Question_Type")
            key = f"q_{qid_s}"
            
            # FIX: Get current val (which might be None)
            current_val = st.session_state.answers.get(qid_s)
            
            if qtype == "MCQ":
                choices_list = choices_by_q.get(qid_s) or []
                labels = [c.get("Choice_Text") for c in choices_list if c]
                if not labels:
                    st.warning(f"No choices found for question {qid_s}")
                    continue
                
                # FIX: Set index to None if no answer selected yet
                try:
                    default_index = labels.index(current_val)
                except ValueError:
                    default_index = None # No default selection
                    
                sel = st.radio("Select one", labels, index=default_index, key=key,label_visibility="collapsed")
                st.session_state.answers[qid_s] = sel
                
            elif qtype == "True/False":
                opts = ["True", "False"]
                
                # FIX: Set index to None if no answer selected yet
                try:
                    default_index = opts.index(current_val)
                except ValueError:
                    default_index = None # No default selection

                sel = st.radio("Select one", opts, index=default_index, key=key,label_visibility="collapsed")
                st.session_state.answers[qid_s] = sel
                
            else:
                # fallback: free text
                # FIX: Handle None value
                txt = st.text_input("Answer", value=current_val if current_val else "", key=key)
                st.session_state.answers[qid_s] = txt

            st.write("---")
        
        # Submit button inside the form
        submitted = st.form_submit_button("Submit Exam")
        if submitted:
            submit_answers()
            st.rerun() # Rerun to go to step 4
            return

    # REMOVED: "Cancel and go back" button

    # simple rerun loop to update timer every 1 second
    time.sleep(1)
    st.rerun()

def submit_answers():
    st.toast("Submitting your answers...")
    sid = st.session_state.student_id
    exam_id = st.session_state.exam_id
    answers = st.session_state.answers
    
    # FIX: Updated validation to check for None or empty string
    all_answered = all(ans is not None and ans != "" for ans in answers.values())
    if not all_answered:
        st.warning("You have not answered all questions, but submitting anyway.")

    payloads = []
    for qid, ans in answers.items():
        record = {
            "Exam_ID": int(exam_id) if str(exam_id).isdigit() else exam_id,
            "Question_ID": int(qid) if str(qid).isdigit() else qid,
            "Student_ID": int(sid) if str(sid).isdigit() else sid,
            "Student_Answer": ans if ans is not None else "N/A", # Store "N/A" if unanswered
            "Submitted_At": int(time.time())
        }
        payloads.append(record)

    results = []
    with st.spinner("Submitting your answers to the database..."):
        for rec in payloads:
            res = fb_post("student_answers", rec)
            if res:
                results.append(res.get("name")) # Get the push key from Firebase
            else:
                st.error(f"Failed to submit answer for Question ID: {rec['Question_ID']}")
                # Continue submitting other answers

    st.session_state.step = 4
    st.session_state.submitted_results = results
    # No rerun here, it's handled by the caller function (step3_ui)

def step4_ui():
    st.subheader("Step 4 — Submission Complete")
    st.success("Your answers have been submitted successfully. You may now close this window.")
    st.balloons()
    
    # Clear sensitive session state
    st.session_state.student_id = None
    st.session_state.selected_course_id = None
    st.session_state.exam_id = None
    st.session_state.exam_questions = []
    st.session_state.answers = {}
    st.session_state.end_time = None
    
    st.info("If you need to take another exam, please REFRESH the page to log in again.")
    
    res = st.session_state.get("submitted_results", None)
    if res:
        with st.expander("View Submission Summary (Technical Details)"):
            st.json(res)

# --- Main App Flow ---
if "step" in st.session_state:
    if st.session_state.step == 1:
        step1_ui()
    elif st.session_state.step == 2:
        step2_ui()
    elif st.session_state.step == 3:
        step3_ui()
    elif st.session_state.step == 4:
        step4_ui()
else:
    # Default to step 1 if state is lost
    step1_ui()


