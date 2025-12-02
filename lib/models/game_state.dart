import 'room.dart';

class GameState {
  int coins;
  int money; // Real-world financial tracking (starts at 0, user-logged)
  double date; // Herný dátum (napr. 7.7)
  List<Room> rooms;
  
  GameState({
    this.coins = 111,
    this.money = 0,
    this.date = 7.7,
    List<Room>? rooms,
  }) : rooms = rooms ?? [];

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
}
