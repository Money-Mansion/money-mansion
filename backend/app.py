"""
Main backend application for Money Mansion
Initializes and runs the backend services
"""

import sys
from pathlib import Path

# Add backend directory to path
sys.path.insert(0, str(Path(__file__).parent))

from database.db_init import DatabaseManager
from api.services import GameService, FinancialService, InventoryService, TaskService


class MoneyMansionBackend:
    """Main backend application class"""
    
    def __init__(self):
        """Initialize the backend"""
        self.db_manager = DatabaseManager
        self.game_service = GameService
        self.financial_service = FinancialService
        self.inventory_service = InventoryService
        self.task_service = TaskService
    
    def initialize(self):
        """Initialize the backend"""
        print("Initializing Money Mansion Backend...")
        DatabaseManager.init_database()
        print("Backend initialized successfully!")
    
    def get_game_state(self):
        """Get current game state"""
        return self.game_service.get_game_state()
    
    def get_financial_summary(self):
        """Get financial summary"""
        return self.financial_service.get_balance_summary()
    
    def get_inventory(self):
        """Get player inventory"""
        return self.inventory_service.get_inventory()
    
    def get_tasks(self):
        """Get all tasks"""
        return self.task_service.get_all_tasks()
    
    def add_coins(self, amount):
        """Add coins to player (in-game currency)"""
        success = self.game_service.add_coins(amount)
        if success:
            self.financial_service.record_transaction('income', amount, 'coins', 'Coins added')
        return success
    
    def add_money(self, amount):
        """Add money to player (real-world financial tracking)"""
        success = self.game_service.add_money(amount)
        if success:
            self.financial_service.record_transaction('income', amount, 'money', 'Money added')
        return success
    
    def spend_coins(self, amount, description=""):
        """Spend coins (in-game currency)"""
        success = self.game_service.spend_coins(amount)
        if success:
            self.financial_service.record_transaction('expense', amount, 'coins', description)
        return success
    
    def spend_money(self, amount, description=""):
        """Spend money (real-world financial tracking)"""
        success = self.game_service.spend_money(amount)
        if success:
            self.financial_service.record_transaction('expense', amount, 'money', description)
        return success


def main():
    """Main entry point"""
    backend = MoneyMansionBackend()
    backend.initialize()
    
    print("\n=== Backend Ready ===")
    print("Database Location:", DatabaseManager.get_db_path())
    print("\nAvailable Services:")
    print("- GameService: Manage game state")
    print("- FinancialService: Track transactions")
    print("- InventoryService: Manage items")
    print("- TaskService: Manage tasks")


if __name__ == "__main__":
    main()
