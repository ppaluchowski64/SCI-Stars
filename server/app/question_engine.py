import sqlite3


class QuestionEngine:
    def __init__(self, db_path="questions.db"):
        self.db_path = db_path

    def _connect(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON;")
        return conn

    def get_question(self, question_id):
        with self._connect() as conn:
            row = conn.execute(
                "SELECT content FROM questions WHERE id = ?;",
                (question_id,)
            ).fetchone()

            return row["content"] if row else None
    
    def get_question_id(self, question_content):
        with self._connect() as conn:
            row = conn.execute(
                "SELECT id FROM questions WHERE content = ?;",
                (question_content,)
            ).fetchone()
            
            return row["id"] if row else None

    def get_answers(self, question_id):
        with self._connect() as conn:
            rows = conn.execute(
                "SELECT content FROM answers WHERE question_id = ? ORDER BY id;",
                (question_id,)
            ).fetchall()

            return [row["content"] for row in rows]
    
    def get_correct_answer(self, question_id):
        with self._connect() as conn:
            row = conn.execute(
                "SELECT answer_id FROM correct_answers WHERE question_id = ?;",
                (question_id,)
            ).fetchone()

            return row["answer_id"] if row else None
    
    def get_random_question(self):
        with self._connect() as conn:
            row = conn.execute(
                "SELECT id FROM questions ORDER BY RANDOM() LIMIT 1;"
            ).fetchone()

            if not row:
                return None

            return self.get_question(row["id"])

    def check_answer(self, question_id, answer_id):
        correct = self.get_correct_answer(question_id)
        matches = correct.lower() == answer_id.lower()
        return correct and matches


if __name__ == "__main__":
    question = QuestionEngine()
    
    print("=== QUIZ STARTED ===\n")

    while True:
        question_content = question.get_random_question()
        question_id = question.get_question_id(question_content)
        answers = question.get_answers(question_id)

        print(question_content)
        print("a)", answers[0])
        print("b)", answers[1])
        print("c)", answers[2])
        print("d)", answers[3])

        user_answer = input("\nChoose your answer (a/b/c/d or q to quit): ").strip().lower()

        if user_answer == "q":
            print("Quiz ended.")
            break

        if user_answer not in ("a", "b", "c", "d"):
            print("Invalid choice. Please try again.\n")
            continue

        is_correct = question.check_answer(question_id, user_answer)

        if is_correct:
            print("Correct answer!\n")
        else:
            correct_answer = question.get_correct_answer(question_id)
            print(f"Wrong answer! The correct answer is {correct_answer.upper()}\n")

    print("\n=== QUIZ FINISHED ===")
