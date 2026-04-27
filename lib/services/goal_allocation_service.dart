import '../models/goal.dart';
import '../models/game_state.dart';
import '../models/transaction.dart';
import '../models/goal_allocation.dart';
import 'goal_database_service.dart';
import 'financial_database_service.dart';
import 'package:uuid/uuid.dart';

/// Manages goal allocations and calculates money balances without double-counting.
/// 
/// Key design:
/// - Allocations are SEPARATE from transactions
/// - Only actual income/expense transactions affect the balance
/// - Allocated money doesn't count as "spent" but reduces available free balance
/// - Goals complete only when user manually marks them
/// - User can only spend their free balance (total balance - allocated amounts)
class GoalAllocationService {
  static const _uuid = Uuid();

  /// Gets the total allocated amount for a specific goal
  static Future<double> getAllocatedForGoal(String goalId) async {
    final allocations =
        await FinancialDatabaseService.getAllocationsForGoal(goalId);
    return allocations.fold<double>(0, (sum, alloc) => sum + alloc.amount);
  }

  /// Gets allocated amounts for all goals as a map
  static Future<Map<String, double>> getAllocatedForAllGoals() async {
    final allocations = await FinancialDatabaseService.getAllAllocations();
    final result = <String, double>{};
    for (final alloc in allocations) {
      result[alloc.goalId] = (result[alloc.goalId] ?? 0) + alloc.amount;
    }
    return result;
  }

  /// Recalculates money balance, allocations, milestones, and goal states.
  /// Called after any transaction or allocation change.
  static Future<void> recalculate(GameState gameState) async {
    final transactions = await FinancialDatabaseService.getAll();
    final allocations = await FinancialDatabaseService.getAllAllocations();
    final goals = await GoalDatabaseService.getAllGoals();

    // Calculate actual balance from transactions only (no allocations counted)
    double balanceTotal = 0.0;
    for (final TransactionModel t in transactions) {
      final signed = t.type == '+' ? t.amount : -t.amount;
      balanceTotal += signed;
    }

    // Group allocations by goal
    final Map<String, double> allocationsByGoal = {};
    for (final GoalAllocation alloc in allocations) {
      allocationsByGoal[alloc.goalId] =
          (allocationsByGoal[alloc.goalId] ?? 0) + alloc.amount;
    }

    gameState.setMoney(balanceTotal);

    // Update each goal's state based on allocations
    for (var i = 0; i < goals.length; i++) {
      final goal = goals[i];
      final allocated = allocationsByGoal[goal.id] ?? 0.0;
      Goal updatedGoal = goal.copyWith(allocatedMoney: allocated);

      // Update milestone progress (allocations determine milestones)
      if (updatedGoal.supportsMilestones) {
        final progress = (allocated / updatedGoal.targetMoney)
            .clamp(0.0, 1.0)
            .toDouble();
        final reachedMilestones =
            (progress * Goal.milestoneStepCount).floor();
        final prevMilestones = updatedGoal.milestonesAwarded;

        if (reachedMilestones != prevMilestones) {
          final prevAward =
              _rewardForMilestones(updatedGoal, prevMilestones);
          final newAward =
              _rewardForMilestones(updatedGoal, reachedMilestones);
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

      // Check if completed goal's allocation was reduced below target
      // (un-complete if it drops below)
      if (updatedGoal.isCompleted &&
          updatedGoal.targetMoney > 0 &&
          allocated < updatedGoal.targetMoney) {
        updatedGoal = updatedGoal.copyWith(dateCompleted: null);
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

  /// Allocates money to a goal by creating a GoalAllocation entry.
  static Future<void> allocateToGoal(
    String goalId,
    double amount,
  ) async {
    final allocation = GoalAllocation(
      id: _uuid.v4(),
      goalId: goalId,
      amount: amount,
      dateAllocated: DateTime.now(),
    );
    await FinancialDatabaseService.insertAllocation(allocation);
  }

  /// Removes money from a goal's allocation.
  static Future<void> removeFromGoal(
    String goalId,
    double amount,
  ) async {
    final allocations =
        await FinancialDatabaseService.getAllocationsForGoal(goalId);

    double remainingToRemove = amount;

    // Remove allocations from newest first
    allocations.sort((a, b) => b.dateAllocated.compareTo(a.dateAllocated));

    for (final allocation in allocations) {
      if (remainingToRemove <= 0) break;

      if (allocation.amount <= remainingToRemove) {
        // Delete entire allocation
        await FinancialDatabaseService.deleteAllocation(allocation.id);
        remainingToRemove -= allocation.amount;
      } else {
        // Reduce allocation
        final updated = allocation.copyWith(
          amount: allocation.amount - remainingToRemove,
        );
        await FinancialDatabaseService.updateAllocation(updated);
        remainingToRemove = 0;
      }
    }
  }

  /// Transfers money from one goal to another.
  static Future<void> transferBetweenGoals(
    String fromGoalId,
    String toGoalId,
    double amount,
  ) async {
    await removeFromGoal(fromGoalId, amount);
    await allocateToGoal(toGoalId, amount);
  }

  /// Handles manual goal completion.
  /// Converts allocated money to an expense transaction.
  /// User should only call this after purchasing what they were saving for.
  static Future<void> completeGoalManually(
    GameState gameState,
    String goalId,
    String goalTitle,
    double allocatedAmount,
    int rewardCoins,
  ) async {
    // Create expense transaction for the allocated amount
    final transaction = TransactionModel(
      id: _uuid.v4(),
      type: '-',
      amount: allocatedAmount,
      note: 'Completed goal: $goalTitle',
      date: DateTime.now(),
    );

    await FinancialDatabaseService.insert(transaction);

    // Remove all allocations for this goal
    await FinancialDatabaseService.deleteAllocationsForGoal(goalId);

    // Mark goal as completed and award coins
    final goal = gameState.goals.firstWhere((g) => g.id == goalId);
    final completedGoal = goal.copyWith(dateCompleted: DateTime.now());
    await GoalDatabaseService.updateGoal(completedGoal);
    
    // Award the coins from the completed goal
    gameState.addCoins(rewardCoins);

    // Recalculate
    await recalculate(gameState);
  }

  static int _rewardForMilestones(Goal goal, int milestoneCount) {
    final clamped = milestoneCount.clamp(0, Goal.milestoneStepCount);
    return (goal.rewardCoins * clamped) ~/ Goal.milestoneStepCount;
  }
}

