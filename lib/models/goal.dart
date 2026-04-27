class Goal {
  static const int milestoneScoreThreshold = 35;
  static const int milestoneStepCount = 5;

  final String id;
  final String title;
  final String description;
  final int challengeScore;
  final int rewardCoins;
  final double targetMoney;
  final int milestonesAwarded;
  final DateTime dueDate;
  final DateTime? dateCompleted;
  final double allocatedMoney; // Transient: calculated from allocations table

  bool get supportsMilestones =>
      targetMoney > 0 && challengeScore >= milestoneScoreThreshold;

  bool get isCompleted => dateCompleted != null;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.challengeScore,
    required this.rewardCoins,
    this.targetMoney = 0.0,
    this.milestonesAwarded = 0,
    required this.dueDate,
    this.dateCompleted,
    this.allocatedMoney = 0.0,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    int? challengeScore,
    int? rewardCoins,
    double? targetMoney,
    int? milestonesAwarded,
    DateTime? dueDate,
    DateTime? dateCompleted,
    double? allocatedMoney,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      challengeScore: challengeScore ?? this.challengeScore,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      targetMoney: targetMoney ?? this.targetMoney,
      milestonesAwarded: milestonesAwarded ?? this.milestonesAwarded,
      dueDate: dueDate ?? this.dueDate,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      allocatedMoney: allocatedMoney ?? this.allocatedMoney,
    );
  }
}
