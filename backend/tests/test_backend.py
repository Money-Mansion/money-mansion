"""
Unit tests for Money Mansion Backend
Tests all core functionality
"""

import unittest
import sys
import os
from pathlib import Path

# Add backend to path
backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from database.db_init import DatabaseManager
from database.dao import (
    GameStateDAO, FurnitureDAO, TransactionDAO,
    InventoryDAO, TaskDAO
)
from api.services import (
    GameService, FinancialService, InventoryService,
    TaskService
)
from utils.helpers import DateUtil, CurrencyUtil, ValidationUtil


class TestDatabaseInitialization(unittest.TestCase):
    """Test database initialization"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        # Use a test database
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        DatabaseManager.init_database()
    
    def test_database_exists(self):
        """Test that database is created"""
        db_path = Path(DatabaseManager.get_db_path())
        self.assertTrue(db_path.exists(), "Database file should exist")
    
    def test_tables_exist(self):
        """Test that all required tables are created"""
        conn = DatabaseManager.get_connection()
        cursor = conn.cursor()
        
        tables = [
            'game_state', 'furniture', 'walls',
            'floors', 'transactions', 'inventory', 'tasks'
        ]
        
        for table in tables:
            cursor.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name=?", (table,))
            result = cursor.fetchone()
            self.assertIsNotNone(result, f"Table {table} should exist")
        
        conn.close()


class TestGameState(unittest.TestCase):
    """Test game state operations"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        DatabaseManager.init_database()
    
    def test_create_game_state(self):
        """Test creating a new game state"""
        game_state = GameStateDAO.create_game_state(coins=100, money=50, date=5.5)
        self.assertIsNotNone(game_state)
        self.assertEqual(game_state[1], 100)  # coins
        self.assertEqual(game_state[2], 50)   # money
    
    def test_get_game_state(self):
        """Test retrieving game state"""
        GameStateDAO.create_game_state(coins=200, money=100)
        game_state = GameStateDAO.get_latest_game_state()
        self.assertIsNotNone(game_state)
        self.assertGreater(game_state[0], 0)  # id
    
    def test_update_game_state(self):
        """Test updating game state"""
        game_state = GameStateDAO.create_game_state(coins=150, money=75)
        GameStateDAO.update_game_state(game_state[0], coins=300)
        updated = GameStateDAO.get_latest_game_state()
        self.assertEqual(updated[1], 300)


class TestGameService(unittest.TestCase):
    """Test game service"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        DatabaseManager.init_database()
    
    def test_add_coins(self):
        """Test adding coins"""
        GameStateDAO.create_game_state(coins=100, money=50)
        initial_state = GameService.get_game_state()
        GameService.add_coins(50)
        updated_state = GameService.get_game_state()
        self.assertEqual(updated_state[1], initial_state[1] + 50)
    
    def test_add_money(self):
        """Test adding emeralds"""
        GameStateDAO.create_game_state(coins=100, money=50)
        initial_state = GameService.get_game_state()
        GameService.add_money(25)
        updated_state = GameService.get_game_state()
        self.assertEqual(updated_state[2], initial_state[2] + 25)
    
    def test_spend_coins(self):
        """Test spending coins"""
        GameStateDAO.create_game_state(coins=100, money=50)
        GameService.spend_coins(30)
        state = GameService.get_game_state()
        self.assertLessEqual(state[1], 100)
    
    def test_spend_more_coins_than_available(self):
        """Test spending more coins than available"""
        GameStateDAO.create_game_state(coins=50, money=50)
        result = GameService.spend_coins(100)
        self.assertFalse(result)


class TestFinancialService(unittest.TestCase):
    """Test financial service"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        DatabaseManager.init_database()
    
    def test_record_transaction(self):
        """Test recording a transaction"""
        result = FinancialService.record_transaction(
            'income', 100, 'coins', 'Test income'
        )
        self.assertTrue(result)
    
    def test_get_all_transactions(self):
        """Test retrieving all transactions"""
        FinancialService.record_transaction('income', 50, 'coins')
        FinancialService.record_transaction('expense', 25, 'money')
        transactions = FinancialService.get_all_transactions()
        self.assertGreaterEqual(len(transactions), 2)
    
    def test_get_balance_summary(self):
        """Test getting balance summary"""
        GameStateDAO.create_game_state(coins=250, money=125)
        summary = FinancialService.get_balance_summary()
        self.assertIn('coins', summary)
        self.assertIn('money', summary)


class TestInventoryService(unittest.TestCase):
    """Test inventory service"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        DatabaseManager.init_database()
    
    def test_add_item(self):
        """Test adding item to inventory"""
        result = InventoryService.add_item('Oak Wood', 'Material', 5, 'common')
        self.assertTrue(result)
    
    def test_get_inventory(self):
        """Test retrieving inventory"""
        InventoryService.add_item('Pine Wood', 'Material', 3)
        inventory = InventoryService.get_inventory()
        self.assertGreater(len(inventory), 0)
    
    def test_get_items_by_type(self):
        """Test filtering items by type"""
        InventoryService.add_item('Gold Ore', 'Ore', 2)
        items = InventoryService.get_items_by_type('Ore')
        self.assertGreater(len(items), 0)
    
    def test_update_item_quantity(self):
        """Test updating item quantity"""
        InventoryService.add_item('Stone', 'Material', 10)
        items = InventoryService.get_inventory()
        if items:
            item_id = items[-1][0]
            InventoryService.update_item_quantity(item_id, 20)
    
    def test_remove_item(self):
        """Test removing item"""
        InventoryService.add_item('Dust', 'Junk', 1)
        inventory_before = len(InventoryService.get_inventory())
        items = InventoryService.get_items_by_type('Junk')
        if items:
            InventoryService.remove_item(items[0][0])


class TestTaskService(unittest.TestCase):
    """Test task service"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        DatabaseManager.init_database()
        GameStateDAO.create_game_state(coins=500, money=250)
    
    def test_create_task(self):
        """Test creating a task"""
        result = TaskService.create_task(
            'Clean Room',
            'Clean the living room',
            reward_coins=50,
            reward_money=10
        )
        self.assertTrue(result)
    
    def test_get_all_tasks(self):
        """Test retrieving all tasks"""
        TaskService.create_task('Water Plants', reward_coins=25)
        tasks = TaskService.get_all_tasks()
        self.assertGreater(len(tasks), 0)
    
    def test_get_pending_tasks(self):
        """Test getting pending tasks"""
        TaskService.create_task('Fix Roof', reward_coins=100)
        pending = TaskService.get_pending_tasks()
        self.assertGreater(len(pending), 0)
    
    def test_complete_task(self):
        """Test completing a task"""
        GameStateDAO.create_game_state(coins=100, money=50)
        TaskService.create_task('Paint Wall', reward_coins=75, reward_money=20)
        tasks = TaskService.get_pending_tasks()
        if tasks:
            task_id = tasks[0][0]
            TaskService.complete_task(task_id)


class TestUtilities(unittest.TestCase):
    """Test utility functions"""
    
    def test_date_util_format(self):
        """Test date formatting"""
        formatted = DateUtil.format_date(7.7)
        self.assertIn('Day 7', formatted)
    
    def test_currency_util_format(self):
        """Test currency formatting"""
        formatted = CurrencyUtil.format_currency(100, 'coins')
        self.assertIn('100', formatted)
    
    def test_currency_validation(self):
        """Test currency validation"""
        result = CurrencyUtil.validate_transaction(100, 50)
        self.assertTrue(result)
        
        result = CurrencyUtil.validate_transaction(50, 100)
        self.assertFalse(result)
    
    def test_validation_item_name(self):
        """Test item name validation"""
        self.assertTrue(ValidationUtil.validate_item_name('Oak Wood'))
        self.assertFalse(ValidationUtil.validate_item_name('ab'))  # Too short
    
    def test_validation_quantity(self):
        """Test quantity validation"""
        self.assertTrue(ValidationUtil.validate_quantity(5))
        self.assertFalse(ValidationUtil.validate_quantity(0))
        self.assertFalse(ValidationUtil.validate_quantity(1000))


class TestIntegration(unittest.TestCase):
    """Integration tests"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        DatabaseManager.init_database()
    
    def test_complete_game_flow(self):
        """Test a complete game flow"""
        # Initialize game
        GameStateDAO.create_game_state(coins=100, money=50)
        state = GameService.get_game_state()
        self.assertIsNotNone(state)
        
        # Add resources
        GameService.add_coins(50)
        GameService.add_money(25)
        state = GameService.get_game_state()
        self.assertGreater(state[1], 100)
        
        # Create and complete task
        TaskService.create_task('Test Task', reward_coins=100)
        tasks = TaskService.get_pending_tasks()
        self.assertGreater(len(tasks), 0)
        
        # Add inventory
        InventoryService.add_item('Test Item', 'Material', 5)
        inventory = InventoryService.get_inventory()
        self.assertGreater(len(inventory), 0)
        
        # Record transaction
        FinancialService.record_transaction('expense', 30, 'coins', 'Test purchase')
        transactions = FinancialService.get_all_transactions()
        self.assertGreater(len(transactions), 0)


def run_tests():
    """Run all tests"""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test cases
    suite.addTests(loader.loadTestsFromTestCase(TestDatabaseInitialization))
    suite.addTests(loader.loadTestsFromTestCase(TestGameState))
    suite.addTests(loader.loadTestsFromTestCase(TestGameService))
    suite.addTests(loader.loadTestsFromTestCase(TestFinancialService))
    suite.addTests(loader.loadTestsFromTestCase(TestInventoryService))
    suite.addTests(loader.loadTestsFromTestCase(TestTaskService))
    suite.addTests(loader.loadTestsFromTestCase(TestUtilities))
    suite.addTests(loader.loadTestsFromTestCase(TestIntegration))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)
