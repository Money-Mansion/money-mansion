# Money Mansion Backend - Testing Guide

## Overview

This guide explains how to test the Money Mansion backend to ensure it's working correctly.

## Testing Methods

There are three ways to test the backend:

### 1. Quick Verification Test (Recommended for first-time users)

The quickest way to verify the backend is working:

```bash
cd backend/tests
python quick_test.py
```

**Output:**
- ✓ PASS for each successful test
- ✗ FAIL for any failures
- Summary of all verified features

**Time:** ~5 seconds

**Tests:**
- Database initialization
- Game state creation
- Resource management (add coins/emeralds)
- Financial tracking
- Inventory management
- Task management

---

### 2. Interactive Tester (For manual testing)

An interactive menu-driven tester for exploring backend functionality:

```bash
cd backend/tests
python interactive_tester.py
```

**Menu Options:**
1. **Initialize Backend & Database** - Set up test database
2. **Test Game State Operations** - Add/spend coins and emeralds
3. **Test Financial Operations** - Record and view transactions
4. **Test Inventory Operations** - Add and manage items
5. **Test Task Operations** - Create and complete tasks
6. **Test Room Operations** - Create and manage rooms
7. **Run All Automated Tests** - Execute full test suite
8. **View Current Game State** - Display current state
9. **Exit** - Close the tester

**Interactive Features:**
- Guided input prompts
- Real-time feedback
- Visual status indicators (✓, ✗, ℹ)
- Formatted output tables

**Time:** ~5-10 minutes (depends on tests run)

---

### 3. Comprehensive Automated Tests (For CI/CD)

Run the full test suite with detailed output:

```bash
cd backend/tests
python -m unittest test_backend -v
```

Or use the test runner:

```bash
cd backend/tests
python test_backend.py
```

**Test Coverage:**
- Database initialization (3 tests)
- Game state operations (4 tests)
- Game service (4 tests)
- Financial service (3 tests)
- Inventory service (5 tests)
- Task service (5 tests)
- Room service (3 tests)
- Utilities (5 tests)
- Integration tests (1 test)

**Total:** 33 comprehensive tests

**Time:** ~10-15 seconds

**Output Example:**
```
test_add_coins (test_backend.TestGameService) ... ok
test_add_emeralds (test_backend.TestGameService) ... ok
test_spend_coins (test_backend.TestGameService) ... ok
...
Ran 33 tests in 0.234s
OK
```

---

## Test Database

All tests use a separate test database: `test_money_mansion.db`

This keeps your production data (if any) separate from test data.

### Location
```
backend/tests/
├── test_money_mansion.db (created during tests)
├── quick_test.db (created by quick_test.py)
└── (test files)
```

### Cleaning Up Test Data

To remove test databases:

**Windows:**
```bash
cd backend/tests
del test_money_mansion.db
del quick_test.db
```

**Mac/Linux:**
```bash
cd backend/tests
rm test_money_mansion.db quick_test.db
```

---

## Expected Results

### Quick Test Success Output
```
============================================================
  MONEY MANSION BACKEND - QUICK VERIFICATION
============================================================

1. Database Initialization
[✓ PASS] Database initialization
         Database created successfully

2. Game State
[✓ PASS] Create game state
         Created with ID: 1

3. Resource Management
[✓ PASS] Add coins
         Coins: 111 → 161
[✓ PASS] Add emeralds
         Emeralds: 780 → 805

4. Financial Operations
[✓ PASS] Record transaction
         Total transactions: 1
[✓ PASS] Get balance
         Coins: 161, Emeralds: 805

5. Inventory Management
[✓ PASS] Add item
         Total items: 1

6. Task Management
[✓ PASS] Create task
         Total tasks: 1
[✓ PASS] Get pending tasks
         Pending tasks: 1

============================================================
  VERIFICATION COMPLETE
============================================================

✓ Backend is working correctly!
```

### Common Issues & Solutions

#### Issue: "ModuleNotFoundError: No module named 'database'"
**Solution:** Run tests from the `tests/` directory, or ensure `backend/` is in your Python path

#### Issue: "database.db is locked"
**Solution:** Close any other Python processes using the database, then try again

#### Issue: "Permission denied" when creating database
**Solution:** Check file permissions in the `tests/` directory
- Windows: Right-click folder → Properties → Security
- Mac/Linux: `chmod 755 backend/tests/`

#### Issue: "No game state found"
**Solution:** Run "Initialize Backend & Database" (option 1) in interactive tester first

---

## Testing Workflow

### First Time Setup
1. Run quick test to verify basic functionality
2. Use interactive tester to explore features
3. Run automated tests to ensure everything works

### Regular Testing
- Quick test: Daily verification (~5 sec)
- Interactive tester: When testing specific features
- Automated tests: Before commits/releases

### Debugging
1. Run quick test to isolate the problem
2. Use interactive tester for manual investigation
3. Check test output for specific failure messages

---

## Test Specifications

### Database Tests
- ✓ Database file creation
- ✓ Table schema creation
- ✓ Connection management
- ✓ Query execution

### Game State Tests
- ✓ Create new game state with initial values
- ✓ Retrieve latest game state
- ✓ Update coins and emeralds
- ✓ Add/spend resources

### Financial Tests
- ✓ Record transactions (income/expense)
- ✓ Retrieve transaction history
- ✓ Get balance summary
- ✓ Filter transactions by type

### Inventory Tests
- ✓ Add items
- ✓ Retrieve all items
- ✓ Filter by item type
- ✓ Update quantities
- ✓ Remove items

### Task Tests
- ✓ Create tasks
- ✓ Retrieve tasks
- ✓ Get pending tasks
- ✓ Complete tasks with rewards
- ✓ Update task status

### Room Tests
- ✓ Create rooms
- ✓ Retrieve room details
- ✓ Get all rooms

### Utility Tests
- ✓ Date formatting
- ✓ Currency formatting
- ✓ Currency validation
- ✓ Item name validation
- ✓ Quantity validation

---

## Integration Test

The comprehensive test suite includes an integration test that verifies a complete game flow:

1. Initialize game
2. Add resources
3. Create and view tasks
4. Add inventory items
5. Record financial transactions

This ensures all components work together correctly.

---

## Continuous Integration

For CI/CD pipelines, use:

```bash
python backend/tests/test_backend.py
```

Exit code:
- `0`: All tests passed
- `1`: Tests failed

---

## Performance Notes

- Quick test: ~5 seconds
- Interactive tester: ~30 seconds per operation
- Full test suite: ~15 seconds
- Database operations: <10ms typical

---

## Next Steps

After verifying the backend works:

1. **Integrate with Flutter**: Use platform channels to call Python backend
2. **Add custom tests**: Create additional test cases for your specific needs
3. **Performance tuning**: Optimize database queries if needed
4. **Data persistence**: Ensure game data persists across app restarts

---

## Support

For issues:
1. Check the "Common Issues & Solutions" section above
2. Review the test output for specific error messages
3. Check the backend logs in `backend.log` (if logging is enabled)
4. Verify all required files are in place in `backend/` directory

---

## Test Files Reference

| File | Purpose | Run Command |
|------|---------|-------------|
| `quick_test.py` | Quick verification | `python quick_test.py` |
| `interactive_tester.py` | Interactive testing | `python interactive_tester.py` |
| `test_backend.py` | Automated tests | `python test_backend.py` |

---

Happy testing! ✓
