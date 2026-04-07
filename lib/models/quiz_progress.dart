class QuizProgress {
  final String quizId; // lessonId z JSON
  final String sectionId; // section číslo
  final int score; // 0-100
  final bool isCompleted;
  final DateTime? completedDate;

  const QuizProgress({
    required this.quizId,
    required this.sectionId,
    this.score = 0,
    this.isCompleted = false,
    this.completedDate,
  });

  /// Get the status color based on score
  /// Green (90%+), Yellow (60%-89%), Red (<60%), Gray (not done)
  QuizStatus getStatus() {
    if (!isCompleted) {
      return QuizStatus.notDone;
    }
    if (score >= 90) {
      return QuizStatus.excellent;
    } else if (score >= 60) {
      return QuizStatus.good;
    } else {
      return QuizStatus.poor;
    }
  }

  QuizProgress copyWith({
    String? quizId,
    String? sectionId,
    int? score,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return QuizProgress(
      quizId: quizId ?? this.quizId,
      sectionId: sectionId ?? this.sectionId,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'sectionId': sectionId,
      'score': score,
      'isCompleted': isCompleted ? 1 : 0,
      'completedDate': completedDate?.millisecondsSinceEpoch,
    };
  }

  factory QuizProgress.fromMap(Map<String, dynamic> map) {
    return QuizProgress(
      quizId: map['quizId'] as String,
      sectionId: map['sectionId'] as String,
      score: map['score'] as int? ?? 0,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      completedDate: map['completedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'] as int)
          : null,
    );
  }
}

enum QuizStatus {
  notDone,      // Gray (sivý)
  poor,         // Red (červený) <60%
  good,         // Yellow (žltý) 60%-89%
  excellent;    // Green (zelený) 90%+

  bool get isCompleted => this != QuizStatus.notDone;
}
