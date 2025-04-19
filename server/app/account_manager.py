import sqlite3
from hashlib import sha512

import db_utils as db


class AccountManager:
    def __init__(self, db_path="accounts.db"):
        self.conn = db.connect(db_path)
        self._init_db()

    def _init_db(self):
        with self.conn:
            cur = db.get_cursor(self.conn)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    token TEXT NOT NULL PRIMARY KEY,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_login TIMESTAMP
                );
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS stats (
                    token TEXT NOT NULL PRIMARY KEY,
                    games_played INTEGER DEFAULT 0,
                    wins INTEGER DEFAULT 0,
                    losses INTEGER DEFAULT 0,
                    FOREIGN KEY (token) REFERENCES users(token) ON DELETE CASCADE
                );
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS inventory (
                    token TEXT NOT NULL PRIMARY KEY,
                    currency_balance INTEGER DEFAULT 0,
                    FOREIGN KEY (token) REFERENCES users(token) ON DELETE CASCADE
                );
            """)

    def _validate_columns(self, table, columns):
        with self.conn:
            cur = db.get_cursor(self.conn)
            cur.execute(f"PRAGMA table_info({table});")
            table_info = cur.fetchall()

            if not table_info:
                return False

            table_columns = {row["name"] for row in table_info}
            return set(columns).issubset(table_columns)

    @staticmethod
    def _hash_token(token):
        return sha512(token.encode("utf-8")).hexdigest()

    def register(self, token):
        token_hash = self._hash_token(token)

        with self.conn:
            try:
                cur = db.get_cursor(self.conn)

                tables = ("users", "stats", "inventory")
                for table in tables:
                    cur.execute(f"INSERT INTO {table} (token) VALUES (?);", (token_hash,))

                return 0

            except sqlite3.IntegrityError:
                return 1

    def login(self, token):
        token_hash = self._hash_token(token)

        with self.conn:
            cur = db.get_cursor(self.conn)

            cur.execute("SELECT token FROM users WHERE token = ?;", (token_hash,))
            if cur.fetchone():
                cur.execute(
                    "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE token = ?;",
                    (token_hash,)
                )

                return 0

        return 1

    def update_data(self, token, table, **kwargs):
        token_hash = self._hash_token(token)

        if not self._validate_columns(table, kwargs.keys()):
            return 1

        fields = ", ".join(f"{col} = ?" for col in kwargs.keys())
        values = list(kwargs.values()) + [token_hash]

        with self.conn:
            cur = db.get_cursor(self.conn)

            sql = f"UPDATE {table} SET {fields} WHERE token = ?;"
            cur.execute(sql, tuple(values))
            result = cur.rowcount

        return 0 if result else 1

    def get_data(self, token, table, *args):
        token_hash = self._hash_token(token)

        if not self._validate_columns(table, args):
            return ()

        fields = ", ".join(args)

        with self.conn:
            cur = db.get_cursor(self.conn)

            sql = f"SELECT {fields} FROM {table} WHERE token = ?;"
            cur.execute(sql, (token_hash,))
            result = cur.fetchone()

        return result if result else ()

    def delete(self, token):
        token_hash = self._hash_token(token)

        with self.conn:
            cur = db.get_cursor(self.conn)

            cur.execute(
                "DELETE FROM users WHERE token = ?;",
                (token_hash,)
            )
            
            return 0 if cur.rowcount else 1
    
    def __del__(self):
        db.close(self.conn)


if __name__ == "__main__":
    account = AccountManager()

    test_token = "example-token-123"

    if account.register(test_token) == 0:
        print("Account registered.")
    else:
        print("Account already exists.")

    if account.login(test_token) == 0:
        print("Login successful.")
    else:
        print("Login failed.")

    result_stats = account.update_data(
        test_token,
        "stats",
        games_played=5,
        wins=3,
        losses=2
    )

    if result_stats == 0:
        print("Updated stats result")

    result_inventory = account.update_data(
        test_token,
        "inventory",
        currency_balance=500
    )

    if result_inventory == 0:
        print("Updated inventory result")

    sections = [
        (
            ["Hashed token", "Created at", "Last login"],
            account.get_data(
                test_token, "users", "token", "created_at", "last_login"
            ),
        ),
        (
            ["Games played", "Wins", "Losses"],
            account.get_data(
                test_token, "stats", "games_played", "wins", "losses"
            ),
        ),
        (
            ["Currency balance"],
            account.get_data(
                test_token, "inventory", "currency_balance"
            ),
        ),
    ]

    output = "\n".join(
        "\n".join(
            f"{label}: {val}"
            for label, val in zip(labels, data)
        )
        for labels, data in sections
    )

    print(output)

    if account.delete(test_token) == 0:
        print(f"Account with token {test_token} has been deleted")
    else:
        print(f"Account with token {test_token} doesn't exist")
