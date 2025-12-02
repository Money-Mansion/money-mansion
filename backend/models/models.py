"""
Data models for Money Mansion
Represents the structure of entities
"""

from dataclasses import dataclass
from typing import List, Optional
from datetime import datetime


@dataclass
class GameState:
    """Represents the current game state"""
    coins: int
    money: int
    current_date: float
    level: int = 1
    experience: int = 0
    id: Optional[int] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


@dataclass
class Furniture:
    """Represents a furniture item in the player's room"""
    furniture_type: str
    position_x: float
    position_y: float
    cost: int = 0
    id: Optional[int] = None
    created_at: Optional[str] = None


@dataclass
class Wall:
    """Represents a wall in the player's room"""
    wall_style: str
    direction: str
    id: Optional[int] = None
    created_at: Optional[str] = None


@dataclass
class Floor:
    """Represents the floor in the player's room"""
    floor_type: str
    grid_size: int = 16
    id: Optional[int] = None
    created_at: Optional[str] = None


@dataclass
class Transaction:
    """Represents a financial transaction"""
    transaction_type: str  # 'income' or 'expense'
    amount: int
    currency_type: str  # 'coins' or 'money'
    description: str = ""
    transaction_date: float = 0.0
    id: Optional[int] = None
    created_at: Optional[str] = None


@dataclass
class InventoryItem:
    """Represents an item in the player's inventory"""
    item_name: str
    item_type: str
    quantity: int = 1
    rarity: str = "common"
    id: Optional[int] = None
    added_date: Optional[str] = None
    updated_at: Optional[str] = None


@dataclass
class Task:
    """Represents a task for the player"""
    task_name: str
    description: str = ""
    status: str = "pending"  # 'pending', 'completed', 'failed'
    reward_coins: int = 0
    reward_money: int = 0
    due_date: Optional[float] = None
    id: Optional[int] = None
    completed_date: Optional[str] = None
    created_at: Optional[str] = None
