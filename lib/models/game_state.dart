import 'package:flutter/foundation.dart';
import 'room.dart';
import 'task.dart';

class GameState extends ChangeNotifier {
  int coins;
  int money; // Real-world financial tracking (starts at 0, user-logged)
  double date; // Herný dátum (napr. 7.7)
  List<Room> rooms;
  List<Task> tasks;

  GameState({
    this.coins = 111,
    this.money = 0,
    this.date = 7.7,
    List<Room>? rooms,
    List<Task>? tasks,
  })  : rooms = rooms ?? [],
        tasks = tasks ?? [];

  // ===== COINS =====

  void addCoins(int amount) {
    if (amount <= 0) return;
    coins += amount;
    notifyListeners(); //UI updates instantly
  }

  void spendCoins(int amount) {
    if (amount <= 0) return;
    if (coins >= amount) {
      coins -= amount;
      notifyListeners(); //UI updates instantly
    }
  }

  // ===== MONEY =====

  void addMoney(int amount) {
    if (amount <= 0) return;
    money += amount;
    notifyListeners();
  }

  void spendMoney(int amount) {
    if (amount <= 0) return;
    if (money >= amount) {
      money -= amount;
      notifyListeners();
    }
  }

  // ===== TASKS =====

  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  void completeTask(String taskId) {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && !tasks[index].isCompleted) {
      final completedTask =
      tasks[index].copyWith(isCompleted: true);

      tasks[index] = completedTask;

      // Reward coins
      coins += completedTask.rewardCoins;

      notifyListeners(); //coins + UI update immediately
    }
  }

  void removeTask(String taskId) {
    tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }
}
