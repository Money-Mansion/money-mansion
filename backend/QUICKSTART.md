# Money Mansion Backend - Quick Start Guide

## Setup

1. **Navigate to the backend directory**:
   ```bash
   cd backend
   ```

2. **Install dependencies** (if any):
   ```bash
   pip install -r requirements.txt
   ```

3. **Initialize the database**:
   ```bash
   python app.py
   ```

## Running the Backend

### Option 1: Direct Python Execution
```bash
python app.py
```

### Option 2: Import as Module
```python
from app import MoneyMansionBackend

backend = MoneyMansionBackend()
backend.initialize()
```

## Common Operations

### Initialize Game
```python
game_state = backend.get_game_state()
print(f"Coins: {game_state[1]}, Emeralds: {game_state[2]}")
```

### Add Resources
```python
backend.add_coins(100)
backend.add_emeralds(50)
```

### Create Task
```python
backend.task_service.create_task(
    task_name="Clean Living Room",
    description="Make the living room spotless",
    reward_coins=75,
    reward_emeralds=15
)
```

### Add Inventory Item
```python
backend.inventory_service.add_item(
    item_name="Oak Wood",
    item_type="Material",
    quantity=10,
    rarity="common"
)
```

### Get Financial Summary
```python
summary = backend.get_financial_summary()
print(f"Total Coins: {summary['coins']}")
print(f"Total Emeralds: {summary['emeralds']}")
```

## Database Location

The SQLite database file is created at:
```
backend/database/money_mansion.db
```

## Troubleshooting

### Database Won't Initialize
- Ensure the `database/` directory exists
- Check file permissions
- Verify Python version is 3.8+

### Import Errors
- Ensure you're running from the correct directory
- Check that all `__init__.py` files are present in subdirectories
- Verify Python path includes the backend directory

### Data Not Persisting
- Confirm database file exists in `database/` directory
- Check write permissions on the database file
- Ensure connections are being committed properly

## Development

To add new services:

1. Create DAOs in `database/dao.py`
2. Create models in `models/models.py`
3. Create service methods in `api/services.py`
4. Add helper functions in `utils/helpers.py` if needed

## Testing

To test the backend:

```python
from app import MoneyMansionBackend

backend = MoneyMansionBackend()
backend.initialize()

# Test game state
print("Game State:", backend.get_game_state())

# Test adding resources
backend.add_coins(100)
print("After adding coins:", backend.get_financial_summary())

# Test inventory
backend.inventory_service.add_item("Test Item", "Material", 5)
print("Inventory:", backend.get_inventory())

# Test tasks
backend.task_service.create_task("Test Task", reward_coins=50)
print("Tasks:", backend.get_tasks())
```

## Performance Tips

1. Use `get_*_by_type()` methods to filter data at database level
2. Cache frequently accessed data in your Flutter app
3. Batch database operations when possible
4. Consider adding indexes for frequently queried columns

## Security Notes

- Never expose database file directly to users
- Validate all input from the Flutter app
- Consider encryption for sensitive data
- Use transactions for multi-step operations
- Enable audit logging for important operations

## Future Roadmap

- [ ] REST API layer
- [ ] Real-time synchronization
- [ ] Data encryption
- [ ] Backup/restore functionality
- [ ] Performance optimization
- [ ] Advanced caching
- [ ] Migration system
