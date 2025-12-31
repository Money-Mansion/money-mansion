import 'room.dart';
import 'goal.dart';

class GameState {
  int coins;
  int money; // Real-world financial tracking (starts at 0, user-logged)
  double date; // Herný dátum (napr. 7.7)
  List<Room> rooms;
  List<Goal> goals;
  
  GameState({
    this.coins = 111,
    this.money = 0,
    this.date = 7.7,
    List<Room>? rooms,
    List<Goal>? goals,
  }) : rooms = rooms ?? [],
       goals = goals ?? [];

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

  void addGoal(Goal goal) {
    goals.add(goal);
  }

  void completeGoal(String goalId) {
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1 && !goals[goalIndex].isCompleted) {
      goals[goalIndex] = goals[goalIndex].copyWith(isCompleted: true);
      coins += goals[goalIndex].rewardCoins;
    }
  }

  void removeGoal(String goalId) {
    goals.removeWhere((g) => g.id == goalId);
  }
}
