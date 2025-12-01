# Backend Testing - Complete Setup

## Quick Start

### 1. Verify Backend Installation
```bash
cd backend
python verify_setup.py
```

This checks:
- ✓ Python version (3.8+)
- ✓ Directory structure
- ✓ All required files
- ✓ Module imports
- ✓ Database initialization

### 2. Quick Verification Test (5 seconds)
```bash
cd backend/tests
python quick_test.py
```

Tests all core functionality:
- Database initialization
- Game state management
- Resource management
- Financial tracking
- Inventory management
- Task management

### 3. Interactive Testing (Manual)
```bash
cd backend/tests
python interactive_tester.py
```

Interactive menu to:
- Initialize database
- Test individual features
- View game state
- Run full test suite

### 4. Automated Tests (Comprehensive)
```bash
cd backend/tests
python test_backend.py
```

Runs 33 comprehensive unit tests covering:
- Database operations
- Game state management
- Financial service
- Inventory management
- Task management
- Room management
- Utility functions
- Integration tests

## Testing Suite Overview

### File Structure
```
backend/
├── verify_setup.py              # Setup verification script
├── app.py                       # Main application
├── database/                    # Database layer
│   ├── db_init.py              # Database initialization
│   └── dao.py                  # Data Access Objects
├── models/                      # Data models
│   └── models.py               # Model definitions
├── api/                         # Business logic
│   └── services.py             # Service classes
├── utils/                       # Utilities
│   └── helpers.py              # Helper functions
└── tests/                       # Testing module
    ├── quick_test.py           # Quick verification
    ├── interactive_tester.py   # Interactive testing
    ├── test_backend.py         # Automated tests
    ├── TESTING_GUIDE.md        # Detailed guide
    └── __init__.py             # Module init
```

## Test Methods Comparison

| Method | Time | Best For | Command |
|--------|------|----------|---------|
| **Setup Verification** | 2 sec | Initial setup | `python verify_setup.py` |
| **Quick Test** | 5 sec | Daily checks | `python tests/quick_test.py` |
| **Interactive** | 5-10 min | Manual testing | `python tests/interactive_tester.py` |
| **Automated** | 15 sec | CI/CD | `python tests/test_backend.py` |

## What Gets Tested

### ✓ Database Layer
- SQLite connection
- Table creation
- Schema validation
- Data persistence

### ✓ Game State
- Create new game
- Update resources
- Retrieve state
- Manage statistics

### ✓ Financial Management
- Record transactions
- Transaction history
- Balance tracking
- Income/expense categorization

### ✓ Inventory System
- Add items
- Remove items
- Update quantities
- Filter by type

### ✓ Task System
- Create tasks
- Complete tasks
- Reward distribution
- Task status tracking

### ✓ Room Management
- Create rooms
- Store room data
- Retrieve room info

### ✓ Utilities
- Date formatting
- Currency formatting
- Data validation
- Data export

## Test Database

All tests use isolated test databases:
- `test_money_mansion.db` - Automated tests
- `quick_test.db` - Quick verification
- `setup_test.db` - Setup verification

These don't interfere with production data.

## Running Tests Step-by-Step

### Step 1: Verify Setup (2 seconds)
```bash
cd backend
python verify_setup.py
```
Expected output:
```
✓ PASS Python Version
✓ PASS Backend Structure
✓ PASS Module Imports
✓ PASS Database Initialization
```

### Step 2: Quick Test (5 seconds)
```bash
cd tests
python quick_test.py
```
Expected output:
```
[✓ PASS] Database initialization
[✓ PASS] Create game state
[✓ PASS] Add coins
[✓ PASS] Add emeralds
...
✓ Backend is working correctly!
```

### Step 3: Interactive Testing (Optional)
```bash
python interactive_tester.py
```
Menu-driven interface to manually test features.

### Step 4: Full Test Suite
```bash
python test_backend.py
```
Expected output:
```
test_create_game_state ... ok
test_add_coins ... ok
test_record_transaction ... ok
...
Ran 33 tests in 0.234s
OK
```

## Troubleshooting

### "ModuleNotFoundError: No module named 'database'"
```bash
# Make sure you're in the correct directory
cd backend/tests
python quick_test.py
```

### "Permission Denied" errors
```bash
# On Windows - Run as Administrator
# On Mac/Linux:
chmod 755 backend/tests
chmod 644 backend/tests/*.py
```

### Database locked errors
- Close any running Python processes
- Delete test database files
- Try again

### Import errors
```bash
# Verify setup
cd backend
python verify_setup.py
```

## Integration with Flutter

After verifying the backend works, you can integrate it with your Flutter app:

1. Use platform channels (MethodChannel) to call Python backend
2. Run backend as a local service
3. Share database between platforms

See `backend/README.md` for integration details.

## Test Output Examples

### Successful Quick Test
```
============================================================
  MONEY MANSION BACKEND - QUICK VERIFICATION
============================================================

[✓ PASS] Database initialization
         Database created successfully
[✓ PASS] Create game state
         Created with ID: 1
[✓ PASS] Add coins
         Coins: 111 → 161
[✓ PASS] Add emeralds
         Emeralds: 780 → 805
[✓ PASS] Record transaction
         Total transactions: 1
[✓ PASS] Get balance
         Coins: 161, Emeralds: 805
[✓ PASS] Add item
         Total items: 1
[✓ PASS] Create task
         Total tasks: 1
[✓ PASS] Get pending tasks
         Pending tasks: 1

============================================================
  VERIFICATION COMPLETE
============================================================

✓ Backend is working correctly!
```

### Successful Automated Test
```
test_database_exists (test_backend.TestDatabaseInitialization) ... ok
test_tables_exist (test_backend.TestDatabaseInitialization) ... ok
test_create_game_state (test_backend.TestGameState) ... ok
test_get_game_state (test_backend.TestGameState) ... ok
test_update_game_state (test_backend.TestGameState) ... ok
test_add_coins (test_backend.TestGameService) ... ok
test_add_emeralds (test_backend.TestGameService) ... ok
test_spend_coins (test_backend.TestGameService) ... ok
test_spend_more_coins_than_available (test_backend.TestGameService) ... ok
test_record_transaction (test_backend.TestFinancialService) ... ok
test_get_all_transactions (test_backend.TestFinancialService) ... ok
test_get_balance_summary (test_backend.TestFinancialService) ... ok
test_add_item (test_backend.TestInventoryService) ... ok
test_get_inventory (test_backend.TestInventoryService) ... ok
test_get_items_by_type (test_backend.TestInventoryService) ... ok
test_update_item_quantity (test_backend.TestInventoryService) ... ok
test_remove_item (test_backend.TestInventoryService) ... ok
test_create_task (test_backend.TestTaskService) ... ok
test_get_all_tasks (test_backend.TestTaskService) ... ok
test_get_pending_tasks (test_backend.TestTaskService) ... ok
test_complete_task (test_backend.TestTaskService) ... ok
test_create_room (test_backend.TestRoomService) ... ok
test_get_room (test_backend.TestRoomService) ... ok
test_get_all_rooms (test_backend.TestRoomService) ... ok
test_date_util_format (test_backend.TestUtilities) ... ok
test_currency_util_format (test_backend.TestUtilities) ... ok
test_currency_validation (test_backend.TestUtilities) ... ok
test_validation_item_name (test_backend.TestUtilities) ... ok
test_validation_quantity (test_backend.TestUtilities) ... ok
test_complete_game_flow (test_backend.TestIntegration) ... ok

Ran 33 tests in 0.234s

OK
```

## Best Practices

1. **Daily Testing**: Run `quick_test.py` to ensure backend is working
2. **Before Commits**: Run full test suite
3. **After Updates**: Run all tests to ensure nothing broke
4. **Debugging**: Use interactive tester to isolate issues

## Documentation

- `verify_setup.py` - Setup verification
- `quick_test.py` - Quick functionality check
- `interactive_tester.py` - Manual testing interface
- `test_backend.py` - Automated test suite
- `TESTING_GUIDE.md` - Detailed testing guide
- `backend/README.md` - Backend architecture
- `backend/QUICKSTART.md` - Quick start guide

## Performance

- Setup verification: ~2 seconds
- Quick test: ~5 seconds
- Interactive test: ~30 seconds per operation
- Full test suite: ~15 seconds
- Database operations: <10ms typical

## Next Steps

1. ✓ Verify setup: `python verify_setup.py`
2. ✓ Run quick test: `python tests/quick_test.py`
3. ✓ Try interactive tester: `python tests/interactive_tester.py`
4. ✓ Run full tests: `python tests/test_backend.py`
5. → Integrate with Flutter app

---

**Backend is ready for testing!** 🎉
