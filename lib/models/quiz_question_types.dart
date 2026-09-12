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
  scenario,       // same shape as multipleChoice: a short decision-moment framing
  ranking,        // same shape as ordering: rank items that have one objectively correct order
  spotMistake,    // same shape as multipleChoice: correctAnswer is the index of the FALSE statement
}

class QuizQuestion {
  final String id;
  final String question;
  final QuestionType questionType;

  // ── multipleChoice, trueFalse, scenario, spotMistake ────
  final List<String> options;    // trueFalse: always ['True','False'] or localised equivalents
  final int correctAnswer;       // index into options

  // ── ordering, ranking ───────────────────────────────────
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
  final String label;           // the zone label shown to user
  final List<String> correctItems; // ALL labels that belong in this zone

  /// Convenience: the single correct item (for single-answer zones).
  /// Returns the first element; throws if correctItems is empty.
  String get correctItem => correctItems.first;

  const DragTarget({
    required this.label,
    required this.correctItems,
  });

  /// JSON support: accepts either
  ///   "correctItem": "Foo"          (single-answer, old format)
  ///   "correctItems": ["Foo","Bar"] (multi-answer, new format)
  factory DragTarget.fromJson(Map<String, dynamic> json) {
    List<String> items;

    final rawList = json['correctItems'];
    final rawSingle = json['correctItem'];

    if (rawList != null && rawList is List) {
      items = List<String>.from(rawList);
    } else if (rawSingle != null) {
      items = [rawSingle as String];
    } else {
      // Fallback: empty list so the app doesn't crash on malformed data
      items = [];
    }

    return DragTarget(
      label: json['label'] as String? ?? '',
      correctItems: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'correctItems': correctItems,
      };
}