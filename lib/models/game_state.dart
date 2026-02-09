import 'package:flutter/foundation.dart';
import 'room.dart';
import 'goal.dart';
import 'item.dart';

class GameState extends ChangeNotifier {
  int coins;
  double money; // Real-world financial tracking (starts at 0, user-logged)
  double date; // Herný dátum (napr. 7.7)
  List<Room> rooms;
  List<Goal> goals;
  List<Item> ownedItems;

  GameState({
    this.coins = 111,
    this.money = 0.0,
    this.date = 7.7,
    List<Room>? rooms,
    List<Goal>? goals,
    List<Item>? ownedItems,
  })  : rooms = rooms ?? [],
        goals = goals ?? [],
        ownedItems = ownedItems ?? [];

  // ===== COINS =====

  void addCoins(int amount) {
    if (amount <= 0) return;
    coins += amount;
    notifyListeners();
  }

  void spendCoins(int amount) {
    if (amount <= 0) return;
    if (coins >= amount) {
      coins -= amount;
      notifyListeners();
    }
  }

  void addMoney(double amount) {
    if (amount <= 0) return;
    money += amount;
    notifyListeners();
  }

  void spendMoney(double amount) {
    if (amount <= 0) return;
    if (money >= amount) {
      money -= amount;
      notifyListeners();
    }
  }

  void setMoney(double amount) {
    money = amount;
    notifyListeners();
  }

  // ===== GOALS =====

  void addGoal(Goal goal) {
    goals.add(goal);
    notifyListeners();
  }

  void completeGoal(String goalId) {
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index != -1 && !goals[index].isCompleted) {
      final completedGoal =
      goals[index].copyWith(isCompleted: true);

      goals[index] = completedGoal;

      // Reward coins
      coins += completedGoal.rewardCoins;

      notifyListeners();
    }
  }

  void removeGoal(String goalId) {
    goals.removeWhere((g) => g.id == goalId);
    notifyListeners();
  }

  // ===== ITEMS =====

  void loadOwnedItems(List<Item> items) {
    ownedItems = items;
    notifyListeners();
  }

  void addOwnedItem(Item item) {
    if (!ownedItems.any((i) => i.id == item.id)) {
      ownedItems.add(item.copyWith(owned: true));
      notifyListeners();
    }
  }

  void removeOwnedItem(String itemId) {
    ownedItems.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }
}

