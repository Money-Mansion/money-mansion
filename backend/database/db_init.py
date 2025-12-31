"""
Database initialization module
"""

import sqlite3
import os
from pathlib import Path

DB_PATH = os.path.join(os.path.dirname(__file__), 'tasks.db')

def init_database():
    """Initialize SQLite database with tasks table"""
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Create tasks table if it doesn't exist
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                task_name TEXT NOT NULL,
                description TEXT,
                status TEXT DEFAULT 'pending',
                reward_coins INTEGER DEFAULT 0,
                reward_money REAL DEFAULT 0.0,
                due_date TEXT,
                completed_date TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        conn.close()
        print(f"✓ Database initialized: {DB_PATH}")
        return True
    except Exception as e:
        print(f"✗ Database initialization error: {e}")
        return False

def get_db_connection():
    """Get database connection"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn
