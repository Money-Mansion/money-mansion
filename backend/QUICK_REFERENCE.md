# 🧪 Backend Testing - Quick Reference Card

## ⚡ Quick Commands

```bash
# 1. Verify setup (2 seconds)
python backend/verify_setup.py

# 2. Quick test (5 seconds)
python backend/tests/quick_test.py

# 3. Interactive testing (5-10 minutes)
python backend/tests/interactive_tester.py

# 4. Full automated tests (15 seconds)
python backend/tests/test_backend.py
```

## ✅ Success Indicators

### Setup Verification
```
✓ Python Version
✓ Backend Structure
✓ Module Imports
✓ Database Initialization
```

### Quick Test
```
✓ Database initialization
✓ Create game state
✓ Add coins
✓ Add emeralds
✓ Record transaction
✓ Get balance
✓ Add item
✓ Create task
✓ Get pending tasks
```

### Full Test Suite
```
Ran 33 tests in 0.234s
OK
```

## 📋 Test Coverage

| Component | Tests | Status |
|-----------|-------|--------|
| Database | 3 | ✓ |
| Game State | 4 | ✓ |
| Game Service | 4 | ✓ |
| Financial | 3 | ✓ |
| Inventory | 5 | ✓ |
| Tasks | 5 | ✓ |
| Rooms | 3 | ✓ |
| Utilities | 5 | ✓ |
| Integration | 1 | ✓ |
| **TOTAL** | **33** | **✓** |

## 🎯 When to Run What

| Time | Purpose | Command |
|------|---------|---------|
| 2 sec | First setup | `verify_setup.py` |
| 5 sec | Daily check | `quick_test.py` |
| 10 min | Manual testing | `interactive_tester.py` |
| 15 sec | Full validation | `test_backend.py` |

## 🔍 Testing Checklist

- [ ] Run `verify_setup.py`
- [ ] Run `quick_test.py`
- [ ] All tests pass
- [ ] Run `test_backend.py`
- [ ] All 33 tests pass
- [ ] Backend ready!

## 📂 File Locations

```
backend/
├── verify_setup.py ............................ Setup check
└── tests/
    ├── quick_test.py ......................... Quick test
    ├── interactive_tester.py ................. Manual testing
    └── test_backend.py ....................... Full tests
```

## 🚀 Getting Started

```bash
# Navigate to project
cd money-mansion

# 1. Verify setup (2 sec)
python backend/verify_setup.py
# ✓ All checks pass

# 2. Quick test (5 sec)
cd backend/tests
python quick_test.py
# ✓ All tests pass

# Backend is working!
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Module not found | Check directory: `cd backend/tests` |
| Permission denied | Run as admin or `chmod 755 backend` |
| Database locked | Close Python processes |
| Import error | Run `verify_setup.py` |

## 📊 Test Features

- ✓ Database operations
- ✓ Game state management
- ✓ Resource management
- ✓ Financial tracking
- ✓ Inventory management
- ✓ Task management
- ✓ Room management
- ✓ Utility functions
- ✓ Integration testing

## 🎓 Interactive Menu

```
1. Initialize Backend & Database
2. Test Game State Operations
3. Test Financial Operations
4. Test Inventory Operations
5. Test Task Operations
6. Test Room Operations
7. Run All Automated Tests
8. View Current Game State
9. Exit
```

## 📈 Performance

```
Setup check:    ~2 seconds
Quick test:     ~5 seconds
Interactive:    ~30 seconds/operation
Full tests:     ~15 seconds
Database op:    <10ms
```

## ✨ Expected Output Examples

### Quick Test Success
```
[✓ PASS] Database initialization
[✓ PASS] Create game state
[✓ PASS] Add coins
...
✓ Backend is working correctly!
```

### Full Tests Success
```
Ran 33 tests in 0.234s
OK
```

## 📞 Quick Links

- Detailed Guide: `backend/tests/TESTING_GUIDE.md`
- Backend Info: `backend/README.md`
- Overview: `backend/TESTING.md`

## 🎯 Next Steps

1. ✓ Run `verify_setup.py`
2. ✓ Run `quick_test.py`
3. ✓ Backend is working!
4. → Ready for Flutter integration

## 💡 Pro Tips

- Run quick test daily during development
- Run full tests before committing
- Use interactive tester to debug specific features
- Check `TESTING_GUIDE.md` for detailed info

---

**Backend Testing Ready! ✓**
