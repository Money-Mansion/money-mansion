"""
Business logic and API handlers for Money Mansion
Handles game operations and data management
"""

from database.dao import (
    GameStateDAO, FurnitureDAO, WallDAO, FloorDAO, TransactionDAO, 
    InventoryDAO, TaskDAO
)
from models.models import GameState, Transaction, InventoryItem, Task


class GameService:
    """Service for managing game-related operations"""
    
    @staticmethod
    def initialize_game():
        """Initialize a new game"""
        game_state = GameStateDAO.create_game_state(coins=111, money=0, date=7.7)
        return game_state
    
    @staticmethod
    def get_game_state():
        """Get current game state"""
        return GameStateDAO.get_latest_game_state()
    
    @staticmethod
    def add_coins(amount):
        """Add coins to player"""
        game_state = GameService.get_game_state()
        if game_state:
            GameStateDAO.add_coins(game_state[0], amount)
            return True
        return False
    
    @staticmethod
    def add_money(amount):
        """Add money to player (real-world money gained by user)"""
        game_state = GameService.get_game_state()
        if game_state:
            GameStateDAO.add_money(game_state[0], amount)
            return True
        return False
    
    @staticmethod
    def spend_money(amount):
        """Spend money"""
        game_state = GameService.get_game_state()
        if game_state and game_state[2] >= amount:  # game_state[2] is money
            GameStateDAO.add_money(game_state[0], -amount)
            return True
        return False
    
    @staticmethod
    def spend_coins(amount):
        """Spend coins (in-game currency)"""
        game_state = GameService.get_game_state()
        if game_state and game_state[1] >= amount:  # game_state[1] is coins
            GameStateDAO.add_coins(game_state[0], -amount)
            return True
        return False


class FinancialService:
    """Service for managing financial operations"""
    
    @staticmethod
    def record_transaction(transaction_type, amount, currency_type, description="", transaction_date=0.0):
        """Record a financial transaction"""
        TransactionDAO.create_transaction(transaction_type, amount, currency_type, description, transaction_date)
        return True
    
    @staticmethod
    def get_all_transactions():
        """Get all transactions"""
        return TransactionDAO.get_all_transactions()
    
    @staticmethod
    def get_transaction_history(transaction_type=None):
        """Get transaction history by type"""
        if transaction_type:
            return TransactionDAO.get_transactions_by_type(transaction_type)
        return TransactionDAO.get_all_transactions()
    
    @staticmethod
    def get_balance_summary():
        """Get a summary of financial balance"""
        game_state = GameService.get_game_state()
        if game_state:
            return {
                'coins': game_state[1],
                'money': game_state[2]
            }
        return {'coins': 0, 'money': 0}


class InventoryService:
    """Service for managing inventory"""
    
    @staticmethod
    def add_item(item_name, item_type, quantity=1, rarity="common"):
        """Add item to inventory"""
        InventoryDAO.add_item(item_name, item_type, quantity, rarity)
        return True
    
    @staticmethod
    def get_inventory():
        """Get all inventory items"""
        return InventoryDAO.get_all_items()
    
    @staticmethod
    def get_items_by_type(item_type):
        """Get items by type"""
        return InventoryDAO.get_items_by_type(item_type)
    
    @staticmethod
    def remove_item(item_id):
        """Remove item from inventory"""
        InventoryDAO.remove_item(item_id)
        return True
    
    @staticmethod
    def update_item_quantity(item_id, quantity):
        """Update item quantity"""
        if quantity <= 0:
            return InventoryService.remove_item(item_id)
        InventoryDAO.update_item_quantity(item_id, quantity)
        return True


class TaskService:
    """Service for managing tasks"""
    
    @staticmethod
    def create_task(task_name, description="", reward_coins=0, reward_money=0, due_date=None):
        """Create a new task (reward_money represents coins awarded as task reward)"""
        TaskDAO.create_task(task_name, description, reward_money, due_date)
        return True
    
    @staticmethod
    def get_all_tasks():
        """Get all tasks"""
        return TaskDAO.get_all_tasks()
    
    @staticmethod
    def get_pending_tasks():
        """Get pending tasks"""
        return TaskDAO.get_tasks_by_status("pending")
    
    @staticmethod
    def get_completed_tasks():
        """Get completed tasks"""
        return TaskDAO.get_tasks_by_status("completed")
    
    @staticmethod
    def complete_task(task_id):
        """Mark task as completed and reward player with coins"""
        task = TaskDAO.get_task_by_id(task_id)
        if task and task[4] > 0:  # task[4] is reward_money (coins given as reward)
            GameService.add_coins(task[4])
        
        TaskDAO.complete_task(task_id)
        return True
    
    @staticmethod
    def update_task_status(task_id, status):
        """Update task status"""
        TaskDAO.update_task_status(task_id, status)
        return True
