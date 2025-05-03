import sqlite3


class DBHelper:
    @staticmethod
    def connect(db_path):
        conn = sqlite3.connect(db_path, check_same_thread=False)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON;")
        return conn


    @staticmethod
    def close(conn):
        if conn:
            conn.close()


    @staticmethod
    def get_cursor(conn):
        return conn.cursor()


db = DBHelper
