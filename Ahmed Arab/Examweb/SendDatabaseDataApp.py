"""
export_sql_to_firebase.py
Exports initial tables from local SQL Server (ITIExamintionSystem) to Firebase Realtime Database.
Usage: python export_sql_to_firebase.py
"""

import time;
import pyodbc
import requests
import json
import os
from dotenv import load_dotenv

load_dotenv()

FIREBASE_URL = os.getenv("FIREBASE_URL")  # e.g. https://project-id-default-rtdb.firebaseio.com
#FIREBASE_AUTH = os.getenv("FIREBASE_AUTH")  # optional: ?auth=... or empty

if not FIREBASE_URL:
    raise SystemExit("Set FIREBASE_URL in environment or .env (e.g. https://...firebaseio.com)")

def fb_path(p):
    # returns full REST URL for a path
    auth = ""
    return f"{FIREBASE_URL.rstrip('/')}/{p}.json{auth}"


# SQL Server connection config - fill or set via .env
SQL_CONN = os.getenv("")  # full pyodbc connection string OR leave blank to use components
if not SQL_CONN:
    SQL_CONN = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=ARAB;"
    "DATABASE=ITIExaminationSystem;"
    "UID=Ahmed Arab;"
    "PWD=12345;"
    "Encrypt=no"
)

def query_table(cursor, sql):
    cursor.execute(sql)
    cols = [c[0] for c in cursor.description]
    rows = cursor.fetchall()
    return [dict(zip(cols, row)) for row in rows]

def push_to_firebase(path, data):
    url = fb_path(path)
    # Use PUT to overwrite at path (clean export), you can change to POST for appends
    """
    Uploads data to Firebase in multiple small PATCH requests.
    Each batch sends 'batch_size' records at a time.
    """
    batch_size = 25000


    # Convert dictionary items to a list
    items = list(data.items())
    total = len(items)
    print(f"Total records to push: {total}")

    for i in range(0, total, batch_size):
        # Take one chunk of items
        chunk = dict(items[i:i + batch_size])

        # Push this chunk using PATCH (merges instead of overwriting)
        r = requests.patch(url, json=chunk)

        # Log progress
        print(f"Batch {i // batch_size + 1}: "
              f"records {i + 1}–{min(i + batch_size, total)} → Status {r.status_code}")

        # Optional: short delay to avoid rate limits
        time.sleep(0.5)

  
    print("✅ All batches uploaded successfully.")
    r.raise_for_status()
    return r.json()

def main():
    cn = pyodbc.connect(SQL_CONN)
    cur = cn.cursor()

    print("Querying Course...")
    courses = query_table(cur, "SELECT Course_ID, Course_Name FROM Course")
    courses_map = {c["Course_ID"]: c for c in courses}
    print(f"Found {len(courses)} courses")

    print("Querying Student_Course...")
    student_courses = query_table(cur, "SELECT Student_ID, Course_ID FROM Student_Course")
    print(f"Found {len(student_courses)} student_course rows")

    print("Querying Exam...")
    exams = query_table(cur, "SELECT Exam_ID, Course_ID, Instructor_ID, Exam_Duration_Minutes, Exam_Type FROM Exam")
    exams_map = {e["Exam_ID"]: e for e in exams}
    print(f"Found {len(exams)} exams")

    print("Querying Question_Bank...")
    questions = query_table(cur, "SELECT Question_ID, Course_ID, Question_Type, Question_Description, Question_Model_Answer FROM Question_Bank")
    questions_map = {q["Question_ID"]: q for q in questions}
    print(f"Found {len(questions)} questions")

    print("Querying Question_Choice...")
    choices = query_table(cur, "SELECT Question_Choice_ID, Question_ID, Choice_Text FROM Question_Choice")
    # group choices by question_id
    choices_by_q = {}
    for ch in choices:
        choices_by_q.setdefault(str(ch["Question_ID"]), []).append(ch)
    print(f"Found {len(choices)} question choices")

    print("Querying Exam_Questions...")
    exam_questions = query_table(cur, "SELECT Exam_ID, Question_ID FROM Exam_Questions")
    eq_by_exam = {}
    for eq in exam_questions:
        eq_by_exam.setdefault(str(eq["Exam_ID"]), []).append(eq["Question_ID"])
    print(f"Found {len(exam_questions)} exam_questions rows")

    # Convert to dicts keyed by id for easy lookup on client side
    # push collections to Firebase
    print("Pushing collections to Firebase...")

    push_to_firebase("courses", {str(c["Course_ID"]): c for c in courses})
    push_to_firebase("student_courses", {
        f"{sc['Student_ID']}_{sc['Course_ID']}": sc for sc in student_courses
    })
    push_to_firebase("exams", {str(e["Exam_ID"]): e for e in exams})
    push_to_firebase("questions", {str(q["Question_ID"]): q for q in questions})
    push_to_firebase("choices", {str(ch["Question_Choice_ID"]): ch for ch in choices})
    push_to_firebase("exam_questions", {
        f"{eq['Exam_ID']}_{eq['Question_ID']}": eq for eq in exam_questions
    })

    # optionally push mapping structures that speed up queries in streamlit app (e.g., exam->question list)
    push_to_firebase("exam_questions_grouped", eq_by_exam)
    push_to_firebase("choices_by_question", choices_by_q)

    print("Export complete.")

if __name__ == "__main__":
    main()
