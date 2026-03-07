class Goal {
  static const String easyDifficulty = 'Easy';
  static const String mediumDifficulty = 'Medium';
  static const String hardDifficulty = 'Hard';

  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int rewardCoins;
  final double targetMoney;
  final double allocatedMoney;
  final int milestonesAwarded;
  final DateTime dueDate;
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
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
    String? difficulty,
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
      difficulty: difficulty ?? this.difficulty,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      targetMoney: targetMoney ?? this.targetMoney,
      allocatedMoney: allocatedMoney ?? this.allocatedMoney,
      milestonesAwarded: milestonesAwarded ?? this.milestonesAwarded,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
