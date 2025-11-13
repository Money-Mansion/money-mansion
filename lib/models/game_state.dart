import 'room.dart';

class GameState {
  int coins;
  int emeralds;
  double date; // Herný dátum (napr. 7.7)
  List<Room> rooms;
  
  GameState({
    this.coins = 111,
    this.emeralds = 780,
    this.date = 7.7,
    List<Room>? rooms,
  }) : rooms = rooms ?? [];

  void addCoins(int amount) {
    coins += amount;
  }

  void addEmeralds(int amount) {
    emeralds += amount;
  }

  void spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
    }
  }

  void spendEmeralds(int amount) {
    if (emeralds >= amount) {
      emeralds -= amount;
    }
  }
}
