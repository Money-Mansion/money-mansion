import '../models/goal.dart';
import '../models/game_state.dart';
import '../models/transaction.dart';
import 'goal_database_service.dart';
import 'financial_database_service.dart';

/// Recalculates balance, goal allocations, milestones, and completion from transactions.
class GoalAllocationService {
  static const int _hardGoalMilestoneCount = 5;

  static Future<void> recalculate(GameState gameState) async {
    final transactions = await FinancialDatabaseService.getAll();
    final goals = await GoalDatabaseService.getAllGoals();

    double balanceTotal = 0.0;
    final Map<String, double> allocations = {};

    for (final TransactionModel t in transactions) {
      final signed = t.type == '+' ? t.amount : -t.amount;
      if (t.goalId == null) {
        balanceTotal += signed;
      } else {
        allocations[t.goalId!] = (allocations[t.goalId!] ?? 0) + signed;
      }
    }

    gameState.setMoney(balanceTotal);

    for (var i = 0; i < goals.length; i++) {
      final goal = goals[i];
      final allocated =
          (allocations[goal.id] ?? 0).clamp(0, double.infinity).toDouble();
      Goal updatedGoal = goal;

      if ((goal.allocatedMoney - allocated).abs() > 0.009) {
        updatedGoal = updatedGoal.copyWith(allocatedMoney: allocated);
      }

      if (updatedGoal.difficulty == Goal.hardDifficulty &&
          updatedGoal.targetMoney > 0) {
        final progress =
            (allocated / updatedGoal.targetMoney).clamp(0.0, 1.0).toDouble();
        final reachedMilestones =
            (progress * _hardGoalMilestoneCount).floor();
        final prevMilestones = updatedGoal.milestonesAwarded;

        if (reachedMilestones != prevMilestones) {
          final prevAward =
              _hardGoalRewardForMilestones(updatedGoal, prevMilestones);
          final newAward =
              _hardGoalRewardForMilestones(updatedGoal, reachedMilestones);
          final delta = newAward - prevAward;
          if (delta > 0) {
            gameState.addCoins(delta);
          } else if (delta < 0) {
            final remove = -delta;
            if (gameState.coins >= remove) {
              gameState.spendCoins(remove);
            } else {
              gameState.setCoins(0);
            }
          }
          updatedGoal =
              updatedGoal.copyWith(milestonesAwarded: reachedMilestones);
        }
      }

      if (!updatedGoal.isCompleted &&
          updatedGoal.targetMoney > 0 &&
          allocated >= updatedGoal.targetMoney) {
        updatedGoal = updatedGoal.copyWith(isCompleted: true);
        gameState.completeGoal(updatedGoal.id);
      }

      if (updatedGoal.isCompleted &&
          updatedGoal.targetMoney > 0 &&
          allocated < updatedGoal.targetMoney) {
        updatedGoal = updatedGoal.copyWith(isCompleted: false);
      }

      if (updatedGoal != goal) {
        goals[i] = updatedGoal;
        await GoalDatabaseService.updateGoal(updatedGoal);
      }
    }

    gameState.goals
      ..clear()
      ..addAll(goals);
  }

  static int _hardGoalRewardForMilestones(Goal goal, int milestoneCount) {
    final clamped = milestoneCount.clamp(0, _hardGoalMilestoneCount);
    return (goal.rewardCoins * clamped) ~/ _hardGoalMilestoneCount;
  }
}
