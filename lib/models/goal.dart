class Goal {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final double targetMoney;
  final double allocatedMoney;
  final DateTime dueDate;
  bool isCompleted;
  
  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    this.targetMoney = 0.0,
    this.allocatedMoney = 0.0,
    required this.dueDate,
    this.isCompleted = false,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    int? rewardCoins,
    double? targetMoney,
    double? allocatedMoney,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      targetMoney: targetMoney ?? this.targetMoney,
      allocatedMoney: allocatedMoney ?? this.allocatedMoney,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
