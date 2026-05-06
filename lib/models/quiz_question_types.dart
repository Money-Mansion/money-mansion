// ============================================================
// QUIZ QUESTION TYPES & MODEL
// File: lib/models/quiz_question_types.dart
//
// Single source of truth for QuizQuestion.
// Import this everywhere — do NOT define QuizQuestion in
// lesson_quiz_service.dart or quiz_service.dart.
// ============================================================

enum QuestionType {
  multipleChoice, // list of options, one correct index
  trueFalse,      // two options: True / False
  ordering,       // drag items into the correct order
  matching,       // match left items to right items
  dragDrop,       // drag labels onto target zones
}

class QuizQuestion {
  final String id;
  final String question;
  final QuestionType questionType;

  // ── multipleChoice & trueFalse ──────────────────────────
  final List<String> options;    // trueFalse: always ['True','False'] or localised equivalents
  final int correctAnswer;       // index into options

  // ── ordering ────────────────────────────────────────────
  /// Items stored in CORRECT order. Widget shuffles them for display.
  final List<String> orderItems;

  // ── matching ────────────────────────────────────────────
  /// matchRight[i] is the correct match for matchLeft[i].
  /// Both lists must have the same length.
  final List<String> matchLeft;
  final List<String> matchRight;

  // ── dragDrop ────────────────────────────────────────────
  final List<String> dragLabels;
  final List<DragTarget> dragTargets;

  // ── shared ──────────────────────────────────────────────
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    this.questionType = QuestionType.multipleChoice,
    this.options = const [],
    this.correctAnswer = 0,
    this.orderItems = const [],
    this.matchLeft = const [],
    this.matchRight = const [],
    this.dragLabels = const [],
    this.dragTargets = const [],
    required this.explanation,
  }) : assert(
          questionType != QuestionType.matching ||
              matchLeft.length == matchRight.length,
          'matchLeft and matchRight must have the same length',
        );

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final typeStr = json['questionType'] as String? ?? 'multipleChoice';
    final type = QuestionType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => QuestionType.multipleChoice,
    );

    // For trueFalse, options are always derived from language at widget level.
    // Store empty list in the model; the widget supplies localised labels.
    final rawOptions = json['options'];
    final options = rawOptions != null
        ? List<String>.from(rawOptions as List<dynamic>)
        : <String>[];

    return QuizQuestion(
      id: json['questionId'] as String,
      question: json['question'] as String,
      questionType: type,
      options: options,
      correctAnswer: json['correctAnswer'] as int? ?? 0,
      orderItems: json['orderItems'] != null
          ? List<String>.from(json['orderItems'] as List<dynamic>)
          : [],
      matchLeft: json['matchLeft'] != null
          ? List<String>.from(json['matchLeft'] as List<dynamic>)
          : [],
      matchRight: json['matchRight'] != null
          ? List<String>.from(json['matchRight'] as List<dynamic>)
          : [],
      dragLabels: json['dragLabels'] != null
          ? List<String>.from(json['dragLabels'] as List<dynamic>)
          : [],
      dragTargets: json['dragTargets'] != null
          ? (json['dragTargets'] as List<dynamic>)
              .map((t) => DragTarget.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': id,
        'question': question,
        'questionType': questionType.name,
        'options': options,
        'correctAnswer': correctAnswer,
        'orderItems': orderItems,
        'matchLeft': matchLeft,
        'matchRight': matchRight,
        'dragLabels': dragLabels,
        'dragTargets': dragTargets.map((t) => t.toJson()).toList(),
        'explanation': explanation,
      };
}

class DragTarget {
  final String label;        // the zone label shown to user
  final String correctItem;  // the dragLabel that belongs here

  const DragTarget({required this.label, required this.correctItem});

  factory DragTarget.fromJson(Map<String, dynamic> json) => DragTarget(
        label: json['label'] as String,
        correctItem: json['correctItem'] as String,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'correctItem': correctItem,
      };
}