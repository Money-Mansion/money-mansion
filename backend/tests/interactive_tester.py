"""
Interactive Backend Test Runner
Provides an easy way to test backend functionality
"""

import sys
from pathlib import Path

# Add backend to path
backend_path = Path(__file__).parent.parent
sys.path.insert(0, str(backend_path))

from database.db_init import DatabaseManager
from database.dao import GameStateDAO, InventoryDAO, TaskDAO, TransactionDAO
from api.services import GameService, FinancialService, InventoryService, TaskService
from utils.helpers import CurrencyUtil, DateUtil


class BackendTester:
    """Interactive backend tester"""
    
    def __init__(self):
        self.running = True
        self.game_state_created = False
    
    def print_header(self, text):
        """Print a formatted header"""
        print("\n" + "=" * 60)
        print(f"  {text}")
        print("=" * 60)
    
    def print_section(self, text):
        """Print a formatted section"""
        print(f"\n> {text}")
        print("-" * 60)
    
    def print_success(self, text):
        """Print success message"""
        print(f"[OK] {text}")
    
    def print_error(self, text):
        """Print error message"""
        print(f"[ERROR] {text}")
    
    def print_info(self, text):
        """Print info message"""
        print(f"[INFO] {text}")
    
    def main_menu(self):
        """Display main menu"""
        self.print_header("MONEY MANSION BACKEND TESTER")
        print("""
1. Initialize Backend & Database
2. Test Game State Operations
3. Test Financial Operations
4. Test Inventory Operations
5. Test Task Operations
6. Run All Automated Tests
7. View Current Game State
8. Exit
        """)
    
    def run(self):
        """Run the tester"""
        DatabaseManager.DB_NAME = 'test_money_mansion.db'
        
        while self.running:
            self.main_menu()
            choice = input("\nSelect option (1-8): ").strip()
            
            if choice == '1':
                self.test_initialization()
            elif choice == '2':
                self.test_game_state()
            elif choice == '3':
                self.test_financial()
            elif choice == '4':
                self.test_inventory()
            elif choice == '5':
                self.test_tasks()
            elif choice == '6':
                self.run_all_tests()
            elif choice == '7':
                self.view_game_state()
            elif choice == '8':
                self.running = False
                self.print_info("Exiting...")
            else:
                self.print_error("Invalid option. Please try again.")
    
    def test_initialization(self):
        """Test database initialization"""
        self.print_section("Database Initialization Test")
        
        try:
            DatabaseManager.init_database()
            self.print_success("Database initialized successfully")
            
            # Create initial game state
            GameStateDAO.create_game_state(coins=111, money=780, date=7.7)
            self.print_success("Game state created with starting values")
            self.game_state_created = True
            
            self.print_info(f"Database location: {DatabaseManager.get_db_path()}")
            
        except Exception as e:
            self.print_error(f"Initialization failed: {e}")
    
    def test_game_state(self):
        """Test game state operations"""
        self.print_section("Game State Operations Test")
        
        if not self.game_state_created:
            try:
                GameStateDAO.create_game_state(coins=111, money=780)
                self.game_state_created = True
            except:
                self.print_error("Please initialize database first (option 1)")
                return
        
        try:
            # Get current state
            state = GameService.get_game_state()
            print(f"\nCurrent Game State:")
            print(f"  Coins: {state[1]}")
            print(f"  Money: {state[2]}")
            print(f"  Date: {state[3]}")
            print(f"  Level: {state[5]}")
            print(f"  Experience: {state[6]}")
            
            # Add coins
            add_coins = input("\nEnter coins to add (or press Enter to skip): ").strip()
            if add_coins.isdigit():
                GameService.add_coins(int(add_coins))
                self.print_success(f"Added {add_coins} coins")
            
            # Add money
            add_money = input("Enter money to add (or press Enter to skip): ").strip()
            if add_money.isdigit():
                GameService.add_money(int(add_money))
                self.print_success(f"Added {add_money} money")
            
            # Spend coins
            spend_coins = input("Enter coins to spend (or press Enter to skip): ").strip()
            if spend_coins.isdigit():
                if GameService.spend_coins(int(spend_coins)):
                    self.print_success(f"Spent {spend_coins} coins")
                else:
                    self.print_error("Not enough coins!")
            
            # Show updated state
            state = GameService.get_game_state()
            print(f"\nUpdated Game State:")
            print(f"  Coins: {state[1]}")
            print(f"  Money: {state[2]}")
            
        except Exception as e:
            self.print_error(f"Test failed: {e}")
    
    def test_financial(self):
        """Test financial operations"""
        self.print_section("Financial Operations Test")
        
        try:
            # Get balance
            summary = FinancialService.get_balance_summary()
            print(f"\nCurrent Balance:")
            print(f"  Coins: {summary['coins']}")
            print(f"  Money: {summary['money']}")
            
            # Record transaction
            trans_type = input("\nTransaction type (income/expense): ").strip()
            amount = input("Amount: ").strip()
            currency = input("Currency (coins/money): ").strip()
            description = input("Description (optional): ").strip()
            
            if trans_type and amount.isdigit() and currency:
                FinancialService.record_transaction(
                    trans_type, int(amount), currency, description
                )
                self.print_success("Transaction recorded")
            else:
                self.print_error("Invalid input")
            
            # Show transaction history
            transactions = FinancialService.get_all_transactions()
            print(f"\nRecent Transactions (last 5):")
            for t in transactions[-5:]:
                print(f"  [{t[1]}] {t[4]}: {t[2]} {t[3]}")
            
        except Exception as e:
            self.print_error(f"Test failed: {e}")
    
    def test_inventory(self):
        """Test inventory operations"""
        self.print_section("Inventory Operations Test")
        
        try:
            # Add item
            print("\nAdd new item:")
            item_name = input("Item name: ").strip()
            item_type = input("Item type: ").strip()
            quantity = input("Quantity: ").strip()
            rarity = input("Rarity (common/rare/epic/legendary) [default: common]: ").strip() or "common"
            
            if item_name and item_type and quantity.isdigit():
                InventoryService.add_item(item_name, item_type, int(quantity), rarity)
                self.print_success("Item added to inventory")
            else:
                self.print_error("Invalid input")
            
            # Show inventory
            inventory = InventoryService.get_inventory()
            print(f"\nCurrent Inventory ({len(inventory)} items):")
            for item in inventory:
                print(f"  {item[1]} ({item[2]}): {item[3]}x [{item[4]}]")
            
        except Exception as e:
            self.print_error(f"Test failed: {e}")
    
    def test_tasks(self):
        """Test task operations"""
        self.print_section("Task Operations Test")
        
        try:
            # Create task
            print("\nCreate new task:")
            task_name = input("Task name: ").strip()
            description = input("Description: ").strip()
            reward_coins = input("Reward coins (default: 0): ").strip() or "0"
            reward_money = input("Reward money (default: 0): ").strip() or "0"
            
            if task_name:
                TaskService.create_task(
                    task_name, description,
                    int(reward_coins), int(reward_money)
                )
                self.print_success("Task created")
            
            # Show tasks
            tasks = TaskService.get_all_tasks()
            print(f"\nAll Tasks ({len(tasks)} tasks):")
            for t in tasks:
                status_icon = "O" if t[3] == "pending" else "X"
                print(f"  {status_icon} {t[1]} - Status: {t[3]}")
                print(f"    Rewards: {t[4]} money coins")
            
            # Complete task
            pending = TaskService.get_pending_tasks()
            if pending:
                complete = input("\nComplete a task? (task_id or press Enter to skip): ").strip()
                if complete.isdigit():
                    TaskService.complete_task(int(complete))
                    self.print_success("Task completed!")
            
        except Exception as e:
            self.print_error(f"Test failed: {e}")
    
    def run_all_tests(self):
        """Run automated test suite"""
        self.print_section("Running Automated Test Suite")
        
        try:
            # Import test module
            from test_backend import run_tests
            
            print("\nRunning comprehensive tests...\n")
            success = run_tests()
            
            if success:
                self.print_success("All tests passed!")
            else:
                self.print_error("Some tests failed. Check output above.")
            
        except Exception as e:
            self.print_error(f"Could not run tests: {e}")
            self.print_info("Make sure test_backend.py is in the tests directory")
    
    def view_game_state(self):
        """View current game state"""
        self.print_section("Current Game State")
        
        try:
            state = GameService.get_game_state()
            if state:
                print(f"\nGame State ID: {state[0]}")
                print(f"Coins: {CurrencyUtil.format_currency(state[1], 'coins')}")
                print(f"Money: {CurrencyUtil.format_currency(state[2], 'money')}")
                print(f"Date: {DateUtil.format_date(state[3])}")
                print(f"Level: {state[5]}")
                print(f"Experience: {state[6]}")
                print(f"Created: {state[7]}")
                print(f"Updated: {state[8]}")
            else:
                self.print_error("No game state found. Please initialize (option 1)")
        except Exception as e:
            self.print_error(f"Failed to retrieve game state: {e}")


def main():
    """Main entry point"""
    tester = BackendTester()
    tester.run()


if __name__ == '__main__':
    main()
