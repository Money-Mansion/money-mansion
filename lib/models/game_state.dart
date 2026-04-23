import 'package:flutter/foundation.dart';
import 'room.dart';
import 'goal.dart';
import 'item.dart';

class GameState extends ChangeNotifier {
  int coins;
  int currentStreak; // Daily quiz streak
  double money; // Real-world financial tracking (starts at 0, user-logged)
  double date; // Herný dátum (napr. 7.7)
  bool musicEnabled; // Background music setting
  double musicVolume; // Music volume (0.0 to 1.0)
  List<Room> rooms;
  List<Goal> goals;
  List<Item> ownedItems;

  GameState({
    this.coins = 111,
    this.currentStreak = 0,
    this.money = 0.0,
    this.date = 7.7,
    this.musicEnabled = true,
    this.musicVolume = 0.5,
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

  void setCoins(int amount) {
    coins = amount;
    notifyListeners();
  }

  /// Award coins for a correct quiz answer on first attempt
  void awardQuizQuestionCoins(int amount) {
    if (amount <= 0) return;
    coins += amount;
    notifyListeners();
  }

  // ===== STREAK =====

  void setCurrentStreak(int streak) {
    currentStreak = streak;
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
      final completedGoal = goals[index].copyWith(isCompleted: true);

      goals[index] = completedGoal;

      // Hard goals are rewarded by milestones during progress.
      if (completedGoal.difficulty != Goal.hardDifficulty) {
        coins += completedGoal.rewardCoins;
      }

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
    final index = ownedItems.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      ownedItems.add(item);
    } else {
      final existing = ownedItems[index];
      ownedItems[index] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    }
    notifyListeners();
  }

  void removeOwnedItem(String itemId) {
    ownedItems.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  // DEBUG: Clear all owned items
  void clearOwnedItems() {
    ownedItems.clear();
    notifyListeners();
  }

  // ===== MUSIC SETTINGS =====

  void setMusicEnabled(bool enabled) {
    musicEnabled = enabled;
    notifyListeners();
  }

  bool isMusicEnabled() {
    return musicEnabled;
  }

  void setMusicVolume(double volume) {
    musicVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  double getMusicVolume() {
    return musicVolume;
  }
}
