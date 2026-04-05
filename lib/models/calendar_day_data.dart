import 'goal.dart';
import 'transaction.dart';

/// Data aggregated for a single day on the calendar
/// Holds goals due that day and all transactions for that day
class CalendarDayData {
  final List<Goal> goalsToday;
  final List<TransactionModel> transactionsToday;

  CalendarDayData({
    required this.goalsToday,
    required this.transactionsToday,
  });

  /// Sum of all income transactions for this day
  double get dailyIncome {
    return transactionsToday
        .where((t) => t.type == '+')
        .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
  }

  /// Sum of all expense transactions for this day
  double get dailyExpense {
    return transactionsToday
        .where((t) => t.type == '-')
        .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));
  }

  /// Net change for the day (income - expense)
  double get dailyNet => dailyIncome - dailyExpense;

  /// True if there are any events (goals or transactions)
  bool get hasEvents => goalsToday.isNotEmpty || transactionsToday.isNotEmpty;

  /// True if day has completed goals, upcoming goals, or overdue goals
  bool get hasCompleted => goalsToday.any((g) => g.isCompleted);
  bool get hasUpcoming => goalsToday.any((g) => !g.isCompleted && g.dueDate.isAfter(DateTime.now()));
  bool get hasOverdue => goalsToday.any((g) => !g.isCompleted && g.dueDate.isBefore(DateTime.now()));
}
