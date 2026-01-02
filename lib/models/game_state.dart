import 'room.dart';
import 'task.dart';

class GameState {
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
  }) : rooms = rooms ?? [],
       tasks = tasks ?? [];

  void addCoins(int amount) {
    coins += amount;
  }

  void addMoney(int amount) {
    money += amount;
  }

  void spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
    }
  }

  void spendMoney(int amount) {
    if (money >= amount) {
      money -= amount;
    }
  }

  void addTask(Task task) {
    tasks.add(task);
  }

  void completeTask(String taskId) {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1 && !tasks[taskIndex].isCompleted) {
      tasks[taskIndex] = tasks[taskIndex].copyWith(isCompleted: true);
      coins += tasks[taskIndex].rewardCoins;
    }
  }

  void removeTask(String taskId) {
    tasks.removeWhere((t) => t.id == taskId);
  }
}
