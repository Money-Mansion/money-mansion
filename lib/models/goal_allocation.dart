/// Represents money allocated to a specific goal.
/// This is separate from transactions - allocations don't affect the main balance.
class GoalAllocation {
  final String id;
  final String goalId;
  final double amount;
  final DateTime dateAllocated;

  GoalAllocation({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.dateAllocated,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'goalId': goalId,
    'amount': amount,
    'dateAllocated': dateAllocated.millisecondsSinceEpoch,
  };

  GoalAllocation copyWith({
    String? id,
    String? goalId,
    double? amount,
    DateTime? dateAllocated,
  }) {
    return GoalAllocation(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      dateAllocated: dateAllocated ?? this.dateAllocated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAllocation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          goalId == other.goalId &&
          amount == other.amount &&
          dateAllocated == other.dateAllocated;

  @override
  int get hashCode =>
      id.hashCode ^ goalId.hashCode ^ amount.hashCode ^ dateAllocated.hashCode;
}
