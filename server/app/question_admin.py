import sqlite3


class QuestionAdmin:
    def __init__(self, db_path="questions.db"):
        self.db_path = db_path
        self._init_db()
    
    def _connect(self):
        conn = sqlite3.connect(self.db_path)
        conn.execute("PRAGMA foreign_keys = ON;")
        return conn
    
    def _init_db(self):
        with self._connect() as conn:
            cur = conn.cursor()

            cur.execute("""
                CREATE TABLE IF NOT EXISTS questions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    content TEXT NOT NULL
                );
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS answers (
                    question_id INTEGER NOT NULL,
                    id CHAR(1) NOT NULL,
                    content TEXT NOT NULL,
                    PRIMARY KEY (question_id, id),
                    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
                );
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS correct_answers (
                    question_id INTEGER PRIMARY KEY,
                    answer_id CHAR(1) NOT NULL,
                    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
                    FOREIGN KEY (question_id, answer_id) REFERENCES answers(question_id, id)
                );
            """)

            conn.commit()
    
    def add_question(self, question, answers, correct_answer):
        with self._connect() as conn:
            cur = conn.cursor()

            cur.execute("INSERT INTO questions (question) VALUES (?);", (question,))
            question_id = cur.lastrowid

            for letter, text in answers.items():
                cur.execute(
                    "INSERT INTO answers (question_id, id, question) VALUES (?, ?, ?);",
                    (question_id, letter, text)
                )

            cur.execute(
                "INSERT INTO correct_answers (question_id, answer_id) VALUES (?, ?);",
                (question_id, correct_answer)
            )

            conn.commit()
            return question_id
    
    def delete_question(self, question_id):
        # TODO: Consider updating question IDs after deletion
        with self._connect() as conn:
            cur = conn.cursor()

            cur.execute("SELECT 1 FROM questions WHERE id = ?;", (question_id,))
            if not cur.fetchone():
                return 1
            
            cur.execute("DELETE FROM questions WHERE id = ?;", (question_id,))

            conn.commit()
            return 0


if __name__ == "__main__":
    admin = QuestionAdmin()

    while True:
        print("What do you want to do?")
        print("1 - Add a question")
        print("2 - Delete a question")
        print("exit - Finish modifications")

        action = input("\nOption: ").strip().lower()

        if action == "exit":
            break

        elif action == "1":
            question = input("Content of the question: ").strip()

            answers = {}
            for letter in ["a", "b", "c", "d"]:
                answer = input(f"Answer {letter.upper()}: ").strip()
                answers[letter] = answer

            correct_answer = input("Correct answer (a/b/c/d): ").strip().lower()

            question_id = admin.add_question(question, answers, correct_answer)
            print(f"\nThe question has been added with ID {question_id}.")

        elif action == "2":
            question_id = input("Question ID to be deleted: ").strip()
            try:
                question_id = int(question_id)
                result = admin.delete_question(question_id)

                if result == 0:
                    print("The question has been deleted.")
                else:
                    print("Question with the given ID doesn't exist.")
            except ValueError:
                print("Please enter a valid question ID!")

        else:
            print("Invalid option. Please try again.")

        print()
 