class TransactionModel {
  final String id;
  final String type; // '+' or '-'
  final double amount;
  final String note;
  final DateTime date;
  final String? goalId;
  final String? category;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.date,
    this.goalId,
    this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'amount': amount,
    'note': note,
    'date': date.millisecondsSinceEpoch,
    'goalId': goalId,
    'category': category,
  };
}
