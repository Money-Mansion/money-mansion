"""
Database initialization module for Money Mansion
Handles SQLite database setup and schema creation
"""

import sqlite3
import os
from pathlib import Path


class DatabaseManager:
    """Manages SQLite database connections and initialization"""
    
    DB_NAME = 'money_mansion.db'
    DB_PATH = Path(__file__).parent / DB_NAME
    
    @classmethod
    def get_db_path(cls):
        """Get the absolute path to the database file"""
        return str(cls.DB_PATH)
    
    @classmethod
    def init_database(cls):
        """Initialize the database with required schema"""
        conn = sqlite3.connect(cls.get_db_path())
        cursor = conn.cursor()
        
        try:
            # Create tables
            cls._create_game_state_table(cursor)
            cls._create_furniture_table(cursor)
            cls._create_walls_table(cursor)
            cls._create_floors_table(cursor)
            cls._create_transactions_table(cursor)
            cls._create_inventory_table(cursor)
            cls._create_tasks_table(cursor)
            
            conn.commit()
            print("Database initialized successfully!")
            
        except sqlite3.Error as e:
            print(f"Error initializing database: {e}")
            conn.rollback()
            
        finally:
            conn.close()
    
    @classmethod
    def _create_game_state_table(cls, cursor):
        """Create game_state table to store player statistics"""
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS game_state (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                coins INTEGER DEFAULT 0,
                money INTEGER DEFAULT 0,
                current_date REAL DEFAULT 1.0,
                level INTEGER DEFAULT 1,
                experience INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
    
    @classmethod
    def _create_furniture_table(cls, cursor):
        """Create furniture table to store furniture items in the player's room"""
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS furniture (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                furniture_type TEXT NOT NULL,
                position_x REAL NOT NULL,
                position_y REAL NOT NULL,
                cost INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
    
    @classmethod
    def _create_walls_table(cls, cursor):
        """Create walls table to store wall data for the player's room"""
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS walls (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                wall_style TEXT NOT NULL,
                direction TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
    
    @classmethod
    def _create_floors_table(cls, cursor):
        """Create floors table to store floor data for the player's room"""
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS floors (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                floor_type TEXT NOT NULL,
                grid_size INTEGER DEFAULT 16,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
    
    @classmethod
    def _create_transactions_table(cls, cursor):
        """Create transactions table for financial history"""
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS transactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                transaction_type TEXT NOT NULL,
                amount INTEGER NOT NULL,
                currency_type TEXT NOT NULL,
                description TEXT,
                transaction_date REAL NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
    
    @classmethod
    def _create_inventory_table(cls, cursor):
        """Create inventory table to store player items"""
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS inventory (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                item_name TEXT NOT NULL,
                item_type TEXT NOT NULL,
                quantity INTEGER DEFAULT 1,
                rarity TEXT DEFAULT 'common',
                added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
    
    @classmethod
    def _create_tasks_table(cls, cursor):
        """Create tasks table to store player tasks"""
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                task_name TEXT NOT NULL,
                description TEXT,
                status TEXT DEFAULT 'pending',
                reward_coins INTEGER DEFAULT 0,
                reward_money INTEGER DEFAULT 0,
                due_date REAL,
                completed_date TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
    
    @classmethod
    def get_connection(cls):
        """Get a new database connection"""
        return sqlite3.connect(cls.get_db_path())
    
    @classmethod
    def execute_query(cls, query, params=()):
        """Execute a SELECT query and return results"""
        conn = cls.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute(query, params)
            results = cursor.fetchall()
            return results
        
        finally:
            conn.close()
    
    @classmethod
    def execute_update(cls, query, params=()):
        """Execute an INSERT, UPDATE, or DELETE query"""
        conn = cls.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute(query, params)
            conn.commit()
            return cursor.rowcount
        
        finally:
            conn.close()


if __name__ == "__main__":
    DatabaseManager.init_database()
