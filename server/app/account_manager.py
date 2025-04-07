import sqlite3
from hashlib import sha512


class AccountManager:
    def __init__(self, db_path="accounts.db"):
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
                    FOREIGN KEY (token) REFERENCES users (token) ON DELETE CASCADE
                );
            """)

            cur.execute("""
                CREATE TABLE IF NOT EXISTS inventory (
                    token TEXT NOT NULL PRIMARY KEY,
                    currency_balance INTEGER DEFAULT 0,
                    FOREIGN KEY (token) REFERENCES users (token) ON DELETE CASCADE
                );
            """)

            conn.commit()

    def _validate_columns(self, table, columns):
        with self._connect() as conn:
            try:
                cur = conn.cursor()

                cur.execute(f"PRAGMA table_info({table});")
                table_info = cur.fetchall()

                if not table_info:
                    return False

                table_columns = {row[1] for row in table_info}

                return set(columns).issubset(table_columns)

            except sqlite3.Error:
                return False

    @staticmethod
    def _hash_token(token):
        encoded = token.encode("utf-8")
        hash_obj = sha512(encoded)
        hashed_token = hash_obj.hexdigest()
        return hashed_token

    def register(self, token):
        token_hash = self._hash_token(token)

        with self._connect() as conn:
            try:
                cur = conn.cursor()

                tables = ["users", "stats", "inventory"]
                for table in tables:
                    cur.execute(f"INSERT INTO {table} (token) VALUES (?);", (token_hash,))

                conn.commit()

                return 0

            except sqlite3.IntegrityError:
                return 1

    def login(self, token):
        token_hash = self._hash_token(token)

        with self._connect() as conn:
            cur = conn.cursor()

            cur.execute("SELECT token FROM users WHERE token = ?;", (token_hash,))
            if cur.fetchone():
                cur.execute(
                    "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE token = ?;",
                    (token_hash,)
                )

                conn.commit()

                return 0

            return 1

    def update_data(self, token, table, **kwargs):
        token_hash = self._hash_token(token)

        if not self._validate_columns(table, kwargs.keys()):
            return 1

        with self._connect() as conn:
            cur = conn.cursor()

            cur.execute(f"SELECT 1 FROM {table} WHERE token = ?;", (token_hash,))
            if not cur.fetchone():
                return 1

            fields = ", ".join([f"{col} = ?" for col in kwargs.keys()])
            values = list(kwargs.values())
            values.append(token_hash)

            sql = f"UPDATE {table} SET {fields} WHERE token = ?;"
            cur.execute(sql, tuple(values))

            conn.commit()

            return 0

    def get_data(self, token, table, *args):
        token_hash = self._hash_token(token)

        if not self._validate_columns(table, args):
            return ()

        with self._connect() as conn:
            cur = conn.cursor()

            fields = ", ".join(args)
            sql = f"SELECT {fields} FROM {table} WHERE token = ?;"
            cur.execute(sql, (token_hash,))
            result = cur.fetchone()

            return result if result else ()

    def delete(self, token):
        token_hash = self._hash_token(token)

        with self._connect() as conn:
            try:
                cur = conn.cursor()

                cur.execute("SELECT 1 FROM users WHERE token = ?;", (token_hash,))
                if not cur.fetchone():
                    return 1

                cur.execute("DELETE FROM users WHERE token = ?;", (token_hash,))

                conn.commit()

                return 0

            except sqlite3.Error:
                return 1


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
