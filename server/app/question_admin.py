import sqlite3

import db_utils as db


class QuestionAdmin:
    def __init__(self, db_path="questions.db"):
        self.conn = db.connect(db_path)
        self._init_db()
    
    def _init_db(self):
        with self.conn:
            cur = db.get_cursor(self.conn)

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
    
    def add_question(self, question, answers, correct_answer):
        with self.conn:
            cur = db.get_cursor(self.conn)

            cur.execute(
                "INSERT INTO questions (content) VALUES (?);",
                (question,)
            )

            question_id = cur.lastrowid
            answer_data = tuple((question_id, letter, text) for letter, text in answers.items())
            
            cur.executemany(
                "INSERT INTO answers (question_id, id, content) VALUES (?, ?, ?);",
                answer_data
            )

            cur.execute(
                "INSERT INTO correct_answers (question_id, answer_id) VALUES (?, ?);",
                (question_id, correct_answer)
            )

        return question_id
    
    def delete_question(self, question_id):
        # TODO: Consider updating question IDs after deletion
        with self.conn:
            cur = db.get_cursor(self.conn)

            cur.execute(
                "DELETE FROM questions WHERE id = ?;",
                (question_id,)
            )

            return 0 if cur.rowcount else 1
    
    def __del__(self):
        db.close(self.conn)


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
            for letter in ("a", "b", "c", "d"):
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
