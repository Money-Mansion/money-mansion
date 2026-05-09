import 'onboarding_service.dart';

/// Validates goal inputs and estimates score/reward entirely on device.
class GoalAiService {
  static const double _defaultMonthlyIncome = 20;
  static const int _minChallengeScore = 1;
  static const int _maxChallengeScore = 100;
  static const int _minRewardCoins = 10;
  static const int _maxRewardCoins = 5000;
  static const int _rewardStep = 5;

  static Future<GoalAiResult> classifyGoal({
    required String title,
    required String description,
    double? targetMoney,
    DateTime? dueDate,
    String language = 'en',
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();

    if (trimmedTitle.isEmpty) {
      return GoalAiResult.needsMoreInfo(
        reason: _missingDetailsMessage(GoalAiInvalidField.title, language),
        invalidField: GoalAiInvalidField.title,
      );
    }

    if (trimmedDescription.isEmpty) {
      return GoalAiResult.needsMoreInfo(
        reason: _missingDetailsMessage(
          GoalAiInvalidField.description,
          language,
        ),
        invalidField: GoalAiInvalidField.description,
      );
    }

    if (targetMoney == null || targetMoney <= 0) {
      return GoalAiResult.needsMoreInfo(
        reason: _missingDetailsMessage(GoalAiInvalidField.amount, language),
        invalidField: GoalAiInvalidField.amount,
      );
    }

    final userProfile = await OnboardingService.getUserProfile();
    final monthlyIncome = userProfile?.monthlyIncome ?? _defaultMonthlyIncome;
    final monthlyExpenses = userProfile?.monthlyExpenses;

    // Keep this calculation local because goals can contain children's
    // financial context and free-form personal text.
    return _estimateWithHeuristic(
      targetMoney: targetMoney,
      dueDate: dueDate,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
    );
  }

  static GoalAiResult _estimateWithHeuristic({
    required double? targetMoney,
    DateTime? dueDate,
    required double monthlyIncome,
    double? monthlyExpenses,
  }) {
    if (targetMoney == null || targetMoney <= 0) {
      return GoalAiResult.needsMoreInfo(
        invalidField: GoalAiInvalidField.amount,
      );
    }

    final challengeScore = estimateChallengeScore(
      targetMoney: targetMoney,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      dueDate: dueDate,
    );

    final rewardCoins = estimateRewardCoins(
      challengeScore: challengeScore,
      targetMoney: targetMoney,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      dueDate: dueDate,
    );

    return GoalAiResult.ready(
      challengeScore: challengeScore,
      rewardCoins: rewardCoins,
    );
  }

  static int estimateChallengeScore({
    required double? targetMoney,
    double? monthlyIncome,
    double? monthlyExpenses,
    DateTime? dueDate,
  }) {
    if (targetMoney == null || targetMoney <= 0) return 0;

    final income = (monthlyIncome != null && monthlyIncome > 0)
        ? monthlyIncome
        : _defaultMonthlyIncome;
    final disposableIncome =
        _estimatedDisposableIncome(income, monthlyExpenses);

    final effortMonths = targetMoney / disposableIncome;
    final effortScore = _clampDouble(effortMonths * 11.0, 6.0, 85.0);

    var timePressure = 0.0;
    if (dueDate != null) {
      final daysLeft = dueDate.difference(DateTime.now()).inDays;
      if (daysLeft <= 0) {
        timePressure = 15.0;
      } else {
        final monthsLeft = daysLeft / 30.0;
        timePressure =
            _clampDouble((effortMonths - monthsLeft) * 8.0, 0.0, 15.0);
      }
    }

    return _clampInt(
      (effortScore + timePressure).round(),
      _minChallengeScore,
      _maxChallengeScore,
    );
  }

  static int estimateRewardCoins({
    required int challengeScore,
    double? targetMoney,
    double? monthlyIncome,
    double? monthlyExpenses,
    DateTime? dueDate,
  }) {
    final income = (monthlyIncome != null && monthlyIncome > 0)
        ? monthlyIncome
        : _defaultMonthlyIncome;
    final disposableIncome =
        _estimatedDisposableIncome(income, monthlyExpenses);

    final score = _clampInt(
      challengeScore,
      _minChallengeScore,
      _maxChallengeScore,
    );

    final amountForReward = (targetMoney != null && targetMoney > 0)
        ? targetMoney
        : disposableIncome;
    final savingsRatio =
        _clampDouble(amountForReward / disposableIncome, 0.25, 25.0);

    var dueDateBonus = 0.0;
    if (dueDate != null) {
      final daysLeft = dueDate.difference(DateTime.now()).inDays;
      if (daysLeft > 0 && daysLeft < 45) {
        dueDateBonus = _clampDouble((45 - daysLeft) * 0.35, 0.0, 12.0);
      }
    }

    final rawReward = 10 + (score * 2.6) + (savingsRatio * 4.2) + dueDateBonus;
    return _normalizeRewardCoins(rawReward.round());
  }

  static double _estimatedDisposableIncome(double income, double? expenses) {
    final normalizedIncome = income > 0 ? income : _defaultMonthlyIncome;
    if (expenses == null || expenses < 0) return normalizedIncome;

    final disposable = normalizedIncome - expenses;
    if (disposable > 0) return disposable;

    return normalizedIncome * 0.35;
  }

  static int _normalizeRewardCoins(int rewardCoins) {
    final clamped = _clampInt(rewardCoins, _minRewardCoins, _maxRewardCoins);
    final stepped = ((clamped / _rewardStep).round() * _rewardStep);
    return _clampInt(stepped, _minRewardCoins, _maxRewardCoins);
  }

  static String _missingDetailsMessage(
    GoalAiInvalidField field,
    String language,
  ) {
    final isSlovak = language.toLowerCase().startsWith('sk');
    switch (field) {
      case GoalAiInvalidField.title:
        return isSlovak ? 'Zadaj nazov ciela.' : 'Enter a goal title.';
      case GoalAiInvalidField.description:
        return isSlovak
            ? 'Zadaj kratky popis ciela.'
            : 'Enter a short goal description.';
      case GoalAiInvalidField.amount:
        return isSlovak
            ? 'Zadaj cielovu sumu vacsiu ako 0.'
            : 'Enter a target amount greater than 0.';
    }
  }

  static int _clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}

class GoalAiResult {
  final int? challengeScore;
  final int? rewardCoins;
  final String? reason;
  final bool needsMoreInfo;
  final GoalAiInvalidField? invalidField;

  GoalAiResult._({
    required this.challengeScore,
    required this.rewardCoins,
    required this.needsMoreInfo,
    this.reason,
    this.invalidField,
  });

  factory GoalAiResult.ready({
    required int challengeScore,
    required int rewardCoins,
    String? reason,
  }) =>
      GoalAiResult._(
        challengeScore: challengeScore,
        rewardCoins: rewardCoins,
        needsMoreInfo: false,
        reason: reason,
        invalidField: null,
      );

  factory GoalAiResult.needsMoreInfo({
    String? reason,
    GoalAiInvalidField? invalidField,
  }) =>
      GoalAiResult._(
        challengeScore: null,
        rewardCoins: null,
        needsMoreInfo: true,
        reason: reason,
        invalidField: invalidField,
      );
}

enum GoalAiInvalidField { title, description, amount }
