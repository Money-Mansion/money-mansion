# Money Mansion Backend

An offline backend system for the Money Mansion game application built with Python and SQLite.

## Overview

The backend provides a complete data management and business logic layer for the Money Mansion Flutter application. It uses SQLite for persistent storage and is designed to run locally on the user's device.

## Architecture

```
backend/
├── database/          # Data access layer
│   ├── db_init.py    # Database initialization and schema
│   └── dao.py        # Data Access Objects
├── models/           # Data models
│   └── models.py     # Data structures
├── api/              # Business logic layer
│   └── services.py   # Service classes
├── utils/            # Utility functions
│   └── helpers.py    # Helper utilities
└── app.py            # Main application
```

## Database Schema

### Tables

1. **game_state**: Stores player statistics
   - coins, emeralds, current_date, level, experience

2. **rooms**: Stores room information
   - id, room_type, description

3. **furniture**: Stores furniture items in rooms
   - id, room_id, furniture_type, position_x, position_y, condition_percentage

4. **walls**: Stores wall data
   - id, room_id, wall_style, direction

5. **floors**: Stores floor data
   - id, room_id, floor_type, condition_percentage

6. **transactions**: Financial transaction history
   - id, transaction_type, amount, currency_type, description, transaction_date

7. **inventory**: Player's inventory items
   - id, item_name, item_type, quantity, rarity

8. **tasks**: Player tasks
   - id, task_name, description, status, reward_coins, reward_emeralds, due_date

## Services

### GameService
Manages core game operations:
- `initialize_game()`: Create new game
- `get_game_state()`: Get current state
- `add_coins(amount)`: Add coins
- `add_emeralds(amount)`: Add emeralds
- `spend_coins(amount)`: Spend coins
- `spend_emeralds(amount)`: Spend emeralds

### FinancialService
Manages financial operations:
- `record_transaction(type, amount, currency, description, date)`: Record transaction
- `get_all_transactions()`: Get transaction history
- `get_transaction_history(type)`: Get transactions by type
- `get_balance_summary()`: Get current balance

### InventoryService
Manages inventory:
- `add_item(name, type, quantity, rarity)`: Add item
- `get_inventory()`: Get all items
- `get_items_by_type(type)`: Filter items by type
- `update_item_quantity(id, quantity)`: Update quantity
- `remove_item(id)`: Remove item

### TaskService
Manages tasks:
- `create_task(name, description, reward_coins, reward_emeralds, due_date)`: Create task
- `get_all_tasks()`: Get all tasks
- `get_pending_tasks()`: Get pending tasks
- `complete_task(id)`: Complete task and reward player
- `update_task_status(id, status)`: Update task status

### RoomService
Manages rooms:
- `create_room(id, type, description)`: Create room
- `get_room(id)`: Get room details
- `get_all_rooms()`: Get all rooms

## Usage

### Initialize Backend

```python
from backend.app import MoneyMansionBackend

backend = MoneyMansionBackend()
backend.initialize()
```

### Get Game State

```python
game_state = backend.get_game_state()
```

### Add Resources

```python
backend.add_coins(100)
backend.add_emeralds(50)
```

### Spend Resources

```python
backend.spend_coins(50, "Purchased furniture")
backend.spend_emeralds(25, "Bought decorations")
```

### Manage Inventory

```python
backend.inventory_service.add_item("Wood Plank", "building_material", 5)
inventory = backend.get_inventory()
```

### Create and Complete Tasks

```python
backend.task_service.create_task(
    "Clean Room",
    "Clean the living room",
    reward_coins=50,
    reward_emeralds=10
)
backend.task_service.complete_task(1)
```

## Utilities

### DateUtil
- `current_game_date()`: Get current game date
- `advance_date(current_date, days)`: Advance date
- `format_date(game_date)`: Format for display

### CurrencyUtil
- `format_currency(amount, currency_type)`: Format currency display
- `validate_transaction(current_amount, transaction_amount)`: Validate transaction

### ValidationUtil
- `validate_item_name(name)`: Validate item name
- `validate_quantity(quantity)`: Validate quantity
- `validate_room_id(room_id)`: Validate room ID

### DataExporter
- `export_game_state(game_state)`: Export to JSON
- `export_inventory(items)`: Export to JSON
- `export_transactions(transactions)`: Export to JSON

## File Structure

```
money-mansion/
├── backend/
│   ├── database/
│   │   ├── __init__.py
│   │   ├── db_init.py
│   │   ├── dao.py
│   │   └── money_mansion.db (created at runtime)
│   ├── models/
│   │   ├── __init__.py
│   │   └── models.py
│   ├── api/
│   │   ├── __init__.py
│   │   └── services.py
│   ├── utils/
│   │   ├── __init__.py
│   │   └── helpers.py
│   ├── app.py
│   └── requirements.txt
├── lib/
│   └── (Flutter app files)
└── README.md
```

## Integration with Flutter

To integrate with the Flutter app:

1. Use platform channels (MethodChannel) to communicate with Python backend
2. Alternatively, run backend as a local service and make HTTP requests
3. Store database path for both platforms to share

## Future Enhancements

- REST API layer using Flask
- Real-time sync capabilities
- Data encryption for sensitive information
- Backup and restore functionality
- Performance optimization with indexing
- Migration system for database updates

## Requirements

- Python 3.8 or higher
- SQLite3 (included with Python)
- No external dependencies required for basic functionality

## Running the Backend

```bash
cd backend
python app.py
```

This will:
1. Initialize the database if it doesn't exist
2. Create all required tables
3. Print backend readiness status

## Notes

- Database file is stored locally in `backend/database/money_mansion.db`
- All dates are stored as floats (day.hour format, e.g., 7.7 = day 7, 7 hours)
- All currency amounts are stored as integers
- Transactions are immutable and logged for audit trail
