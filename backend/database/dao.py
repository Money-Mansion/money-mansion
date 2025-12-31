"""
Task Data Access Object (DAO)
Handles all database operations for tasks
"""

from database.db_init import get_db_connection
from datetime import datetime

class TaskDAO:
    """Data Access Object for task operations"""
    
    @staticmethod
    def create_task(task_id, task_name, description='', reward_coins=0, reward_money=0.0, due_date=None):
        """Create a new task"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO tasks (id, task_name, description, reward_coins, reward_money, due_date)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (task_id, task_name, description, reward_coins, reward_money, due_date))
            
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            print(f"Error creating task: {e}")
            return False
    
    @staticmethod
    def get_all_tasks():
        """Get all tasks from database"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute('SELECT * FROM tasks ORDER BY created_at DESC')
            rows = cursor.fetchall()
            conn.close()
            
            tasks = []
            for row in rows:
                tasks.append({
                    'id': row['id'],
                    'task_name': row['task_name'],
                    'description': row['description'],
                    'status': row['status'],
                    'reward_coins': row['reward_coins'],
                    'reward_money': row['reward_money'],
                    'due_date': row['due_date'],
                    'completed_date': row['completed_date'],
                    'created_at': row['created_at']
                })
            return tasks
        except Exception as e:
            print(f"Error getting tasks: {e}")
            return []
    
    @staticmethod
    def get_task_by_id(task_id):
        """Get a specific task by ID"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
            row = cursor.fetchone()
            conn.close()
            
            if row:
                return {
                    'id': row['id'],
                    'task_name': row['task_name'],
                    'description': row['description'],
                    'status': row['status'],
                    'reward_coins': row['reward_coins'],
                    'reward_money': row['reward_money'],
                    'due_date': row['due_date'],
                    'completed_date': row['completed_date'],
                    'created_at': row['created_at']
                }
            return None
        except Exception as e:
            print(f"Error getting task: {e}")
            return None
    
    @staticmethod
    def update_task(task_id, task_name=None, description=None, reward_coins=None, reward_money=None, due_date=None):
        """Update an existing task"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            updates = []
            params = []
            
            if task_name is not None:
                updates.append('task_name = ?')
                params.append(task_name)
            if description is not None:
                updates.append('description = ?')
                params.append(description)
            if reward_coins is not None:
                updates.append('reward_coins = ?')
                params.append(reward_coins)
            if reward_money is not None:
                updates.append('reward_money = ?')
                params.append(reward_money)
            if due_date is not None:
                updates.append('due_date = ?')
                params.append(due_date)
            
            if not updates:
                return False
            
            params.append(task_id)
            update_sql = 'UPDATE tasks SET ' + ', '.join(updates) + ' WHERE id = ?'
            
            cursor.execute(update_sql, params)
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            print(f"Error updating task: {e}")
            return False
    
    @staticmethod
    def update_task_status(task_id, status):
        """Update task status (pending, completed, etc.)"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            completed_date = None
            if status == 'completed':
                completed_date = datetime.now().isoformat()
            
            if completed_date:
                cursor.execute('''
                    UPDATE tasks SET status = ?, completed_date = ? WHERE id = ?
                ''', (status, completed_date, task_id))
            else:
                cursor.execute('''
                    UPDATE tasks SET status = ? WHERE id = ?
                ''', (status, task_id))
            
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            print(f"Error updating task status: {e}")
            return False
    
    @staticmethod
    def complete_task(task_id):
        """Mark task as completed"""
        return TaskDAO.update_task_status(task_id, 'completed')
    
    @staticmethod
    def delete_task(task_id):
        """Delete a task from database"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute('DELETE FROM tasks WHERE id = ?', (task_id,))
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            print(f"Error deleting task: {e}")
            return False
    
    @staticmethod
    def get_game_state():
        """Get overall game state (total coins, money, tasks count, etc.)"""
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute('SELECT COUNT(*) as total FROM tasks')
            total_tasks = cursor.fetchone()['total']
            
            cursor.execute('SELECT COUNT(*) as completed FROM tasks WHERE status = "completed"')
            completed_tasks = cursor.fetchone()['completed']
            
            cursor.execute('SELECT SUM(reward_coins) as coins FROM tasks WHERE status = "completed"')
            total_coins = cursor.fetchone()['coins'] or 0
            
            cursor.execute('SELECT SUM(reward_money) as money FROM tasks WHERE status = "completed"')
            total_money = cursor.fetchone()['money'] or 0.0
            
            conn.close()
            
            return {
                'total_tasks': total_tasks,
                'completed_tasks': completed_tasks,
                'total_coins': total_coins,
                'total_money': total_money
            }
        except Exception as e:
            print(f"Error getting game state: {e}")
            return {
                'total_tasks': 0,
                'completed_tasks': 0,
                'total_coins': 0,
                'total_money': 0.0
            }
