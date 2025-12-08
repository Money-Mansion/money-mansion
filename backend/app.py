"""
Main backend application for Money Mansion
Initializes and runs the backend services
"""

import sys
from pathlib import Path

# Add backend directory to path
sys.path.insert(0, str(Path(__file__).parent))

from flask import Flask
from flask_cors import CORS
from database.db_init import DatabaseManager
from api.services import GameService, FinancialService, InventoryService, TaskService
from api.routes import register_blueprints


class MoneyMansionBackend:
    """Main backend application class"""
    
    def __init__(self):
        """Initialize the backend"""
        self.app = Flask(__name__)
        CORS(self.app)
        self.db_manager = DatabaseManager
        self.game_service = GameService
        self.financial_service = FinancialService
        self.inventory_service = InventoryService
        self.task_service = TaskService
        
        # Register API routes
        register_blueprints(self.app)
    
    def initialize(self):
        """Initialize the backend"""
        print("Initializing Money Mansion Backend...")
        DatabaseManager.init_database()
        print("Backend initialized successfully!")
    
    def run(self, host=None, port=5000, debug=False):
        """Run the Flask server"""
        # If host is not specified, use 0.0.0.0 to listen on all interfaces
        if host is None:
            host = '0.0.0.0'
            
        print(f"\n{'='*50}")
        print("Starting Money Mansion Backend Server")
        print(f"{'='*50}")
        print(f"Server will listen on: {host}:{port}")
        print(f"Database location: {DatabaseManager.get_db_path()}")
        print(f"\nAccess from:")
        print(f"  Localhost: http://127.0.0.1:{port}/api/tasks")
        print(f"  Other devices: http://<your-ip>:{port}/api/tasks")
        print(f"  (Replace <your-ip> with this computer's IP address)")
        print(f"{'='*50}\n")
        
        self.app.run(host=host, port=port, debug=debug)
    
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
    
    # Run the Flask server - listen on all interfaces (0.0.0.0) so it can be accessed from other devices
    backend.run(host='0.0.0.0', port=5000, debug=True)


if __name__ == "__main__":
    main()
