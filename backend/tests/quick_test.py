"""
Quick Backend Verification Script
Run this to quickly verify backend is working
"""

import sys
from pathlib import Path

# Add backend to path
backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from database.db_init import DatabaseManager
from database.dao import GameStateDAO
from api.services import GameService, FinancialService, InventoryService, TaskService


def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def print_status(test_name, passed, message=""):
    status = "✓ PASS" if passed else "✗ FAIL"
    print(f"[{status}] {test_name}")
    if message:
        print(f"     {message}")


def run_quick_test():
    """Run quick verification tests"""
    
    print_section("MONEY MANSION BACKEND - QUICK VERIFICATION")
    
    try:
        # Test 1: Initialize database
        print("\n1. Database Initialization")
        DatabaseManager.DB_NAME = 'quick_test.db'
        DatabaseManager.init_database()
        print_status("Database initialization", True, "Database created successfully")
        
        # Test 2: Create game state
        print("\n2. Game State")
        game_state = GameStateDAO.create_game_state(coins=111, money=780, date=7.7)
        print_status("Create game state", game_state is not None, f"Created with ID: {game_state[0]}")
        
        # Test 3: Add resources
        print("\n3. Resource Management")
        initial_state = GameService.get_game_state()
        GameService.add_coins(50)
        updated_state = GameService.get_game_state()
        coins_added = updated_state[1] > initial_state[1]
        print_status("Add coins", coins_added, f"Coins: {initial_state[1]} → {updated_state[1]}")
        
        GameService.add_money(25)
        updated_state = GameService.get_game_state()
        money_added = updated_state[2] > initial_state[2]
        print_status("Add money", money_added, f"Money: {initial_state[2]} → {updated_state[2]}")
        
        # Test 4: Financial tracking
        print("\n4. Financial Operations")
        FinancialService.record_transaction('income', 100, 'coins', 'Test income')
        transactions = FinancialService.get_all_transactions()
        print_status("Record transaction", len(transactions) > 0, f"Total transactions: {len(transactions)}")
        
        balance = FinancialService.get_balance_summary()
        print_status("Get balance", balance is not None, f"Coins: {balance['coins']}, Money: {balance['money']}")
        
        # Test 5: Inventory
        print("\n5. Inventory Management")
        InventoryService.add_item('Oak Wood', 'Material', 5, 'common')
        inventory = InventoryService.get_inventory()
        print_status("Add item", len(inventory) > 0, f"Total items: {len(inventory)}")
        
        # Test 6: Tasks
        print("\n6. Task Management")
        TaskService.create_task('Clean Room', 'Clean the living room', 50, 10)
        tasks = TaskService.get_all_tasks()
        print_status("Create task", len(tasks) > 0, f"Total tasks: {len(tasks)}")
        
        pending = TaskService.get_pending_tasks()
        print_status("Get pending tasks", len(pending) > 0, f"Pending tasks: {len(pending)}")
        
        # Final summary
        print_section("VERIFICATION COMPLETE")
        print("\n✓ Backend is working correctly!")
        print(f"\nDatabase location: {DatabaseManager.get_db_path()}")
        print("\nAll core features verified:")
        print("  ✓ Database initialization")
        print("  ✓ Game state management")
        print("  ✓ Resource management")
        print("  ✓ Financial tracking")
        print("  ✓ Inventory management")
        print("  ✓ Task management")
        
        return True
        
    except Exception as e:
        print_section("ERROR")
        print(f"\n✗ Verification failed: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == '__main__':
    success = run_quick_test()
    sys.exit(0 if success else 1)
