"""
Utility functions for Money Mansion backend
"""

import json
from datetime import datetime


class DateUtil:
    """Utilities for date handling"""
    
    @staticmethod
    def current_game_date():
        """Get current game date"""
        # This can be modified to return the actual game date from database
        return 7.7
    
    @staticmethod
    def advance_date(current_date, days):
        """Advance the game date by specified days"""
        # Game date is represented as a float (e.g., 7.7 means day 7, 7 hours)
        return current_date + (days / 24.0)
    
    @staticmethod
    def format_date(game_date):
        """Format game date for display"""
        day = int(game_date)
        hour = int((game_date - day) * 24)
        return f"Day {day}, {hour:02d}:00"


class CurrencyUtil:
    """Utilities for currency handling"""
    
    CURRENCY_SYMBOLS = {
        'coins': '🪙',
        'money': '💵'
    }
    
    @staticmethod
    def format_currency(amount, currency_type):
        """Format currency for display"""
        symbol = CurrencyUtil.CURRENCY_SYMBOLS.get(currency_type, '?')
        return f"{symbol} {amount}"
    
    @staticmethod
    def validate_transaction(current_amount, transaction_amount):
        """Validate if transaction is possible"""
        return current_amount >= transaction_amount


class ValidationUtil:
    """Utilities for data validation"""
    
    @staticmethod
    def validate_item_name(name):
        """Validate item name"""
        if not name or not isinstance(name, str):
            return False
        return 3 <= len(name) <= 100
    
    @staticmethod
    def validate_quantity(quantity):
        """Validate quantity"""
        if not isinstance(quantity, int):
            return False
        return 1 <= quantity <= 999
    
    @staticmethod
    def validate_room_id(room_id):
        """Validate room ID"""
        if not room_id or not isinstance(room_id, str):
            return False
        return len(room_id) > 0


class DataExporter:
    """Utilities for exporting/importing game data"""
    
    @staticmethod
    def export_game_state(game_state):
        """Export game state to JSON"""
        return json.dumps({
            'coins': game_state[1],
            'money': game_state[2],
            'date': game_state[3],
            'level': game_state[5],
            'experience': game_state[6]
        }, indent=2)
    
    @staticmethod
    def export_inventory(inventory_items):
        """Export inventory to JSON"""
        items = []
        for item in inventory_items:
            items.append({
                'id': item[0],
                'name': item[1],
                'type': item[2],
                'quantity': item[3],
                'rarity': item[4]
            })
        return json.dumps(items, indent=2)
    
    @staticmethod
    def export_transactions(transactions):
        """Export transactions to JSON"""
        trans = []
        for t in transactions:
            trans.append({
                'id': t[0],
                'type': t[1],
                'amount': t[2],
                'currency': t[3],
                'description': t[4],
                'date': t[5]
            })
        return json.dumps(trans, indent=2)
