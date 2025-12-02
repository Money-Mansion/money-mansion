"""
Data Access Objects (DAOs) for Money Mansion
Handles database operations for each entity
"""

from datetime import datetime
from .db_init import DatabaseManager


class GameStateDAO:
    """Data Access Object for game state"""
    
    @staticmethod
    def create_game_state(coins=0, money=0, date=1.0):
        """Create a new game state"""
        query = '''
            INSERT INTO game_state (coins, money, current_date, level, experience)
            VALUES (?, ?, ?, ?, ?)
        '''
        DatabaseManager.execute_update(query, (coins, money, date, 1, 0))
        return GameStateDAO.get_latest_game_state()
    
    @staticmethod
    def get_latest_game_state():
        """Get the latest game state"""
        query = 'SELECT * FROM game_state ORDER BY id DESC LIMIT 1'
        result = DatabaseManager.execute_query(query)
        return result[0] if result else None
    
    @staticmethod
    def update_game_state(game_state_id, coins=None, money=None, current_date=None):
        """Update game state values"""
        updates = []
        params = []
        
        if coins is not None:
            updates.append('coins = ?')
            params.append(coins)
        if money is not None:
            updates.append('money = ?')
            params.append(money)
        if current_date is not None:
            updates.append('current_date = ?')
            params.append(current_date)
        
        if updates:
            updates.append('updated_at = CURRENT_TIMESTAMP')
            params.append(game_state_id)
            
            query = f'UPDATE game_state SET {", ".join(updates)} WHERE id = ?'
            DatabaseManager.execute_update(query, params)
            return GameStateDAO.get_latest_game_state()
        
        return None
    
    @staticmethod
    def add_coins(game_state_id, amount):
        """Add coins to game state"""
        query = 'UPDATE game_state SET coins = coins + ? WHERE id = ?'
        DatabaseManager.execute_update(query, (amount, game_state_id))
    
    @staticmethod
    def add_money(game_state_id, amount):
        """Add money to game state"""
        query = 'UPDATE game_state SET money = money + ? WHERE id = ?'
        DatabaseManager.execute_update(query, (amount, game_state_id))


class FurnitureDAO:
    """Data Access Object for furniture in the player's room"""
    
    @staticmethod
    def add_furniture(furniture_type, position_x, position_y, cost=0):
        """Add a furniture item to the player's room"""
        query = '''
            INSERT INTO furniture (furniture_type, position_x, position_y, cost)
            VALUES (?, ?, ?, ?)
        '''
        DatabaseManager.execute_update(query, (furniture_type, position_x, position_y, cost))
    
    @staticmethod
    def get_all_furniture():
        """Get all furniture in the player's room"""
        query = 'SELECT * FROM furniture ORDER BY created_at ASC'
        return DatabaseManager.execute_query(query)
    
    @staticmethod
    def remove_furniture(furniture_id):
        """Remove a furniture item"""
        query = 'DELETE FROM furniture WHERE id = ?'
        DatabaseManager.execute_update(query, (furniture_id,))
    
    @staticmethod
    def get_furniture_by_id(furniture_id):
        """Get a furniture item by ID"""
        query = 'SELECT * FROM furniture WHERE id = ?'
        result = DatabaseManager.execute_query(query, (furniture_id,))
        return result[0] if result else None


class WallDAO:
    """Data Access Object for walls in the player's room"""
    
    @staticmethod
    def create_walls(walls_list):
        """Create walls for the room (4 walls: north, south, east, west)"""
        query = 'INSERT INTO walls (wall_style, direction) VALUES (?, ?)'
        for wall_style, direction in walls_list:
            DatabaseManager.execute_update(query, (wall_style, direction))
    
    @staticmethod
    def get_all_walls():
        """Get all walls in the room"""
        query = 'SELECT * FROM walls ORDER BY direction ASC'
        return DatabaseManager.execute_query(query)
    
    @staticmethod
    def update_wall_style(direction, wall_style):
        """Update a wall's style"""
        query = 'UPDATE walls SET wall_style = ? WHERE direction = ?'
        DatabaseManager.execute_update(query, (wall_style, direction))


class FloorDAO:
    """Data Access Object for the floor in the player's room"""
    
    @staticmethod
    def create_floor(floor_type, grid_size=16):
        """Create the floor for the room"""
        query = 'INSERT INTO floors (floor_type, grid_size) VALUES (?, ?)'
        DatabaseManager.execute_update(query, (floor_type, grid_size))
    
    @staticmethod
    def get_floor():
        """Get the floor (should only be one)"""
        query = 'SELECT * FROM floors LIMIT 1'
        result = DatabaseManager.execute_query(query)
        return result[0] if result else None
    
    @staticmethod
    def update_floor_type(floor_type):
        """Update the floor type"""
        query = 'UPDATE floors SET floor_type = ? WHERE id = (SELECT MIN(id) FROM floors)'
        DatabaseManager.execute_update(query, (floor_type,))


class TransactionDAO:
    """Data Access Object for transactions"""
    
    @staticmethod
    def create_transaction(transaction_type, amount, currency_type, description="", transaction_date=0.0):
        """Create a new transaction"""
        query = '''
            INSERT INTO transactions (transaction_type, amount, currency_type, description, transaction_date)
            VALUES (?, ?, ?, ?, ?)
        '''
        DatabaseManager.execute_update(query, (transaction_type, amount, currency_type, description, transaction_date))
    
    @staticmethod
    def get_all_transactions():
        """Get all transactions"""
        query = 'SELECT * FROM transactions ORDER BY created_at DESC'
        return DatabaseManager.execute_query(query)
    
    @staticmethod
    def get_transactions_by_type(transaction_type):
        """Get transactions by type"""
        query = 'SELECT * FROM transactions WHERE transaction_type = ? ORDER BY created_at DESC'
        return DatabaseManager.execute_query(query, (transaction_type,))


class InventoryDAO:
    """Data Access Object for inventory"""
    
    @staticmethod
    def add_item(item_name, item_type, quantity=1, rarity="common"):
        """Add an item to inventory"""
        query = '''
            INSERT INTO inventory (item_name, item_type, quantity, rarity)
            VALUES (?, ?, ?, ?)
        '''
        DatabaseManager.execute_update(query, (item_name, item_type, quantity, rarity))
    
    @staticmethod
    def get_all_items():
        """Get all inventory items"""
        query = 'SELECT * FROM inventory'
        return DatabaseManager.execute_query(query)
    
    @staticmethod
    def get_items_by_type(item_type):
        """Get items by type"""
        query = 'SELECT * FROM inventory WHERE item_type = ?'
        return DatabaseManager.execute_query(query, (item_type,))
    
    @staticmethod
    def update_item_quantity(item_id, quantity):
        """Update item quantity"""
        query = 'UPDATE inventory SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?'
        DatabaseManager.execute_update(query, (quantity, item_id))
    
    @staticmethod
    def remove_item(item_id):
        """Remove an item from inventory"""
        query = 'DELETE FROM inventory WHERE id = ?'
        DatabaseManager.execute_update(query, (item_id,))


class TaskDAO:
    """Data Access Object for tasks"""
    
    @staticmethod
    def create_task(task_name, description="", reward_coins=0, reward_money=0, due_date=None):
        """Create a new task"""
        query = '''
            INSERT INTO tasks (task_name, description, status, reward_coins, reward_money, due_date)
            VALUES (?, ?, ?, ?, ?, ?)
        '''
        DatabaseManager.execute_update(query, (task_name, description, "pending", reward_coins, reward_money, due_date))
    
    @staticmethod
    def get_all_tasks():
        """Get all tasks"""
        query = 'SELECT * FROM tasks ORDER BY due_date ASC'
        return DatabaseManager.execute_query(query)
    
    @staticmethod
    def get_task_by_id(task_id):
        """Get a task by ID"""
        query = 'SELECT * FROM tasks WHERE id = ?'
        result = DatabaseManager.execute_query(query, (task_id,))
        return result[0] if result else None
    
    @staticmethod
    def get_tasks_by_status(status):
        """Get tasks by status (pending, completed, failed)"""
        query = 'SELECT * FROM tasks WHERE status = ? ORDER BY due_date ASC'
        return DatabaseManager.execute_query(query, (status,))
    
    @staticmethod
    def complete_task(task_id):
        """Mark a task as completed"""
        query = 'UPDATE tasks SET status = ?, completed_date = CURRENT_TIMESTAMP WHERE id = ?'
        DatabaseManager.execute_update(query, ("completed", task_id))
    
    @staticmethod
    def update_task_status(task_id, status):
        """Update task status"""
        query = 'UPDATE tasks SET status = ? WHERE id = ?'
        DatabaseManager.execute_update(query, (status, task_id))
