class Goal {
  static const int milestoneScoreThreshold = 70;
  static const int milestoneStepCount = 5;

  final String id;
  final String title;
  final String description;
  final int challengeScore;
  final int rewardCoins;
  final double targetMoney;
  final double allocatedMoney;
  final int milestonesAwarded;
  final DateTime dueDate;
  bool isCompleted;

  bool get supportsMilestones =>
      targetMoney > 0 && challengeScore >= milestoneScoreThreshold;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.challengeScore,
    required this.rewardCoins,
    this.targetMoney = 0.0,
    this.allocatedMoney = 0.0,
    this.milestonesAwarded = 0,
    required this.dueDate,
    this.isCompleted = false,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    int? challengeScore,
    int? rewardCoins,
    double? targetMoney,
    double? allocatedMoney,
    int? milestonesAwarded,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      challengeScore: challengeScore ?? this.challengeScore,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      targetMoney: targetMoney ?? this.targetMoney,
      allocatedMoney: allocatedMoney ?? this.allocatedMoney,
      milestonesAwarded: milestonesAwarded ?? this.milestonesAwarded,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
