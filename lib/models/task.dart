class Task {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final DateTime dueDate;
  bool isCompleted;
  
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.dueDate,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? rewardCoins,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
