import 'package:flutter_test/flutter_test.dart';
import 'package:money_mansion/models/game_state.dart';
import 'package:money_mansion/models/goal.dart';
import 'package:money_mansion/models/item.dart';

void main() {
  group('GameState coins and money', () {
    test('adds and spends valid coin amounts only', () {
      final state = GameState(coins: 10);
      var notifications = 0;
      state.addListener(() => notifications++);

      state.addCoins(5);
      state.addCoins(0);
      state.addCoins(-3);
      state.spendCoins(4);
      state.spendCoins(0);
      state.spendCoins(-4);

      expect(state.coins, 11);
      expect(notifications, 2);
    });

    test('spends money only when balance is sufficient', () {
      final state = GameState(money: 20);
      var notifications = 0;
      state.addListener(() => notifications++);

      state.addMoney(10.5);
      state.spendMoney(5.25);
      state.spendMoney(100);
      state.addMoney(0);
      state.spendMoney(-1);

      expect(state.money, 25.25);
      expect(notifications, 2);
    });
  });

  group('GameState goals', () {
    test('completing a non-milestone goal awards reward coins once', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Goal',
        description: 'Save money',
        challengeScore: 10,
        rewardCoins: 25,
        dueDate: DateTime(2026),
      );
      final state = GameState(coins: 100, goals: [goal]);

      state.completeGoal(goal.id);
      state.completeGoal(goal.id);

      expect(state.goals.single.isCompleted, isTrue);
      expect(state.coins, 125);
    });

    test('completing a milestone goal does not double award reward coins', () {
      final goal = Goal(
        id: 'goal-1',
        title: 'Goal',
        description: 'Save money',
        challengeScore: Goal.milestoneScoreThreshold,
        rewardCoins: 25,
        targetMoney: 100,
        dueDate: DateTime(2026),
      );
      final state = GameState(coins: 100, goals: [goal]);

      state.completeGoal(goal.id);

      expect(state.goals.single.isCompleted, isTrue);
      expect(state.coins, 100);
    });
  });

  group('GameState owned items', () {
    test('adds new owned items and merges duplicate quantities', () {
      final item = Item(
        id: 'chair',
        name: 'Chair',
        type: ItemType.furniture,
        texture: 'assets/images/items/gauc_modry.png',
        cost: 10,
      );
      final state = GameState();

      state.addOwnedItem(item);
      state.addOwnedItem(item.copyWith(quantity: 2));

      expect(state.ownedItems, hasLength(1));
      expect(state.ownedItems.single.quantity, 3);
    });
  });
}
