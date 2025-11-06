"""
sync_answers_to_sql.py
Runs locally on your network. Pulls /student_answers from Firebase, grades them,
and inserts/updates the Student_Exam_Answer table in ITIExamintionSystem.
Run periodically or as a daemon.
"""

import pyodbc
import requests
import os
import time
from dotenv import load_dotenv

load_dotenv()
FIREBASE_URL = os.getenv("FIREBASE_URL")
#FIREBASE_AUTH = os.getenv("FIREBASE_AUTH")
SQL_CONN =(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=ARAB;"
    "DATABASE=ITIExaminationSystem;"
    "UID=Ahmed Arab;"
    "PWD=12345;"
    "Encrypt=no"
)


def fb_url(path):
    auth =  ""
    return f"{FIREBASE_URL.rstrip('/')}/{path}.json{auth}"

def get_student_answers():
    """Fetches all student answers from Firebase."""
    url = fb_url("student_answers")
    r = requests.get(url)
    r.raise_for_status()
    data = r.json() or {}
    # returns list of (key, record)
    return list(data.items())

def load_model_answers(cursor):
    """Loads all model answers from Question_Bank into a dictionary."""
    print("Loading model answers from Question_Bank...")
    sql_query = "SELECT Question_ID, Question_Model_Answer FROM Question_Bank"
    cursor.execute(sql_query)
    rows = cursor.fetchall()
    # Create a map of { "Question_ID_String": "Model_Answer" }
    model_answers_map = {str(row.Question_ID): row.Question_Model_Answer for row in rows}
    print(f"Loaded {len(model_answers_map)} model answers.")
    return model_answers_map

def upsert_answer(cursor, exam_id, question_id, student_id, student_answer, model_answers_map):
    """
    Checks, grades, and inserts/updates a student's answer in the SQL database.
    """
    
    # --- NEW: Grading Logic ---
    model_answer = model_answers_map.get(str(question_id))
    grade = 0 # Default to 0 (wrong)

    if model_answer is None:
        print(f"WARNING: No model answer found for QID {question_id}. Defaulting to grade 0.")
    elif student_answer == model_answer:
        grade = 1 # Correct answer
    
    # Debug print for grading
    # print(f"  QID {question_id}: Model='{model_answer}', Student='{student_answer}', Grade={grade}")
    # --- End of NEW Logic ---

    # check if exists
    sql_check = """
        SELECT Student_Answer FROM Student_Exam_Answer
        WHERE Exam_ID = ? AND Question_ID = ? AND Student_ID = ?
    """
    cursor.execute(sql_check, exam_id, question_id, student_id)
    row = cursor.fetchone()
    
    if row:
        # update
        # --- MODIFIED: Added Student_Grade ---
        sql_upd = """
            UPDATE Student_Exam_Answer
            SET Student_Answer = ?, Student_Grade = ?
            WHERE Exam_ID = ? AND Question_ID = ? AND Student_ID = ?
        """
        cursor.execute(sql_upd, student_answer, grade, exam_id, question_id, student_id)
    else:
        # insert
        # --- MODIFIED: Added Student_Grade ---
        sql_ins = """
            INSERT INTO Student_Exam_Answer (Exam_ID, Question_ID, Student_ID, Student_Answer, Student_Grade)
            VALUES (?, ?, ?, ?, ?)
        """
        cursor.execute(sql_ins, exam_id, question_id, student_id, student_answer, grade)

def main():
    if not FIREBASE_URL:
        raise SystemExit("Set FIREBASE_URL in .env")
    
    cn = pyodbc.connect(SQL_CONN, autocommit=False)
    cur = cn.cursor()
    processed_keys = set()

    # --- NEW: Load model answers once at the start ---
    model_answers_map = load_model_answers(cur)

    print("Starting answer sync loop... Press Ctrl+C to stop.")
    while True:
        try:
            items = get_student_answers()  # [(key, record), ...]
            if not items:
                # print("No new answers found, sleeping...")
                time.sleep(3)
                continue

            new_answer_count = 0
            for key, rec in items:
                if key in processed_keys:
                    continue
                
                # record should have Exam_ID, Question_ID, Student_ID, Student_Answer
                try:
                    exam_id = int(rec.get("Exam_ID"))
                    qid = int(rec.get("Question_ID"))
                    sid = int(rec.get("Student_ID"))
                    ans = rec.get("Student_Answer") # This can be "N/A" or the answer text
                    
                    if ans is None:
                        print(f"Invalid record (ans is None), skipping: {key}")
                        processed_keys.add(key)
                        continue

                except Exception as e:
                    print(f"Invalid record format, skipping: {key}, Record: {rec}, Error: {e}")
                    processed_keys.add(key)
                    continue

                # --- MODIFIED: Pass the model_answers_map ---
                upsert_answer(cur, exam_id, qid, sid, ans, model_answers_map)
                cn.commit()
                # print(f"Processed {key} -> exam {exam_id}, q {qid}, student {sid}")
                processed_keys.add(key)
                new_answer_count += 1

            if new_answer_count > 0:
                print(f"Successfully processed and graded {new_answer_count} new answers.")

            # Sleep then poll again (tune interval as required)
            time.sleep(3)

        except requests.exceptions.RequestException as re:
            print(f"Connection error to Firebase: {re}")
            print("Retrying in 10 seconds...")
            time.sleep(10)
        except pyodbc.Error as dbe:
            print(f"Database error: {dbe}")
            print("Rolling back and retrying in 10 seconds...")
            try:
                cn.rollback()
            except Exception as rb_e:
                print(f"Rollback failed: {rb_e}")
            time.sleep(10)
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            print("Retrying in 10 seconds...")
            time.sleep(10)

if __name__ == "__main__":
    main()