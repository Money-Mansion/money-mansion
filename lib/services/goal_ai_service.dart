import 'dart:convert';
import 'package:http/http.dart' as http;

import 'onboarding_service.dart';

/// Validates goal inputs and generates numeric score + reward from AI.
class GoalAiService {
  static const _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'openai/gpt-oss-120b';

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
    final userProfile = await OnboardingService.getUserProfile();
    final monthlyIncome = userProfile?.monthlyIncome ?? _defaultMonthlyIncome;
    final monthlyExpenses = userProfile?.monthlyExpenses;

    if (_apiKey.isEmpty) {
      return _fallbackWithHeuristic(
        targetMoney: targetMoney,
        dueDate: dueDate,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        reason: 'Local scoring used',
      );
    }

    final prompt = _buildPrompt(
      title: title,
      description: description,
      targetMoney: targetMoney,
      dueDate: dueDate,
      language: language,
      userProfile: userProfile,
      assumedMonthlyIncome: monthlyIncome,
      assumedMonthlyExpenses: monthlyExpenses,
    );

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.1,
          'max_tokens': 220,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode != 200) {
        print('GoalAiService HTTP ${response.statusCode}');
        return _fallbackWithHeuristic(
          targetMoney: targetMoney,
          dueDate: dueDate,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          reason: 'AI unavailable (${response.statusCode})',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractText(data);
      if (text == null) {
        return _fallbackWithHeuristic(
          targetMoney: targetMoney,
          dueDate: dueDate,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          reason: 'Empty AI response',
        );
      }

      final structuredResult = _parseStructuredResult(
        text,
        targetMoney: targetMoney,
        dueDate: dueDate,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
      );
      if (structuredResult != null) {
        return structuredResult;
      }

      final normalized = text.toUpperCase();
      if (normalized.contains('MORE INFO') ||
          normalized.contains('MORE_INFO')) {
        return GoalAiResult.needsMoreInfo(
          reason: _truncate(text),
          invalidField: _inferInvalidFieldFromText(text),
        );
      }

      return _fallbackWithHeuristic(
        targetMoney: targetMoney,
        dueDate: dueDate,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        reason: _truncate(text),
      );
    } catch (e) {
      print('GoalAiService error: $e');
      return _fallbackWithHeuristic(
        targetMoney: targetMoney,
        dueDate: dueDate,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        reason: 'Local fallback after exception',
      );
    }
  }

  static String _buildPrompt({
    required String title,
    required String description,
    double? targetMoney,
    DateTime? dueDate,
    required String language,
    UserProfile? userProfile,
    required double assumedMonthlyIncome,
    double? assumedMonthlyExpenses,
  }) {
    final due = dueDate != null
        ? '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}'
        : 'not provided';
    final target = targetMoney != null && targetMoney > 0
        ? targetMoney.toStringAsFixed(2)
        : 'not provided';

    final profileSnippet = _profileSnippet(userProfile);
    final financialContextSnippet = _financialContextSnippet(
      targetMoney: targetMoney,
      dueDate: dueDate,
      monthlyIncome: assumedMonthlyIncome,
      monthlyExpenses: assumedMonthlyExpenses,
    );

    return '''
You are helping a kids finance app. Respond in language code: $language.

Your task:
- Validate goal input quality.
- If valid, assign numeric values from user profile and financial context.
- Use only numbers, no category labels.

Rules:
1. If title is missing or unclear -> status MORE_INFO and field title.
2. If description is missing or unclear -> status MORE_INFO and field description.
3. If target amount is missing, zero, or invalid -> status MORE_INFO and field amount.
4. If valid -> status READY and field none.
5. For READY:
   - challengeScore must be integer 1..100.
   - rewardCoins must be integer {_minRewardCoins}..{_maxRewardCoins}.
   - rewardCoins must scale with challengeScore, target amount, due date pressure, and affordability.
6. Message must be user-facing and actionable.

Output:
Return JSON only. No markdown, no extra text.
{
  "status": "READY|MORE_INFO",
  "field": "none|title|description|amount",
  "challengeScore": 0,
  "rewardCoins": 0,
  "message": "short explanation"
}

Constraints:
- MORE_INFO => field must be title|description|amount, challengeScore 0, rewardCoins 0.
- READY => field must be none, challengeScore 1..100, rewardCoins 10..500.
- Keep message max 12 x.

GOAL:
Title: $title
Description: $description
Target amount: $target
Due date: $due

PERSONAL PROFILE:
$profileSnippet

FINANCIAL CONTEXT:
$financialContextSnippet
''';
  }

  static GoalAiResult _fallbackWithHeuristic({
    required double? targetMoney,
    DateTime? dueDate,
    required double monthlyIncome,
    double? monthlyExpenses,
    String? reason,
  }) {
    if (targetMoney == null || targetMoney <= 0) {
      return GoalAiResult.needsMoreInfo(
        reason: reason,
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
      reason: reason,
    );
  }

  static GoalAiResult? _parseStructuredResult(
    String text, {
    required double? targetMoney,
    DateTime? dueDate,
    required double monthlyIncome,
    double? monthlyExpenses,
  }) {
    final parsed = _extractStructuredPayload(text);
    if (parsed == null) return null;

    final status = (parsed['status'] ?? '').toString().toUpperCase().trim();
    if (status.isEmpty) return null;

    final message = _truncate(
      (parsed['message'] ?? parsed['reason'] ?? text).toString().trim(),
    );
    final field = _parseInvalidField(parsed['field']?.toString());

    if (status == 'MORE_INFO' || status == 'MORE INFO') {
      return GoalAiResult.needsMoreInfo(
        reason: message,
        invalidField: field ?? GoalAiInvalidField.description,
      );
    }

    if (status != 'READY' && status != 'VALID' && status != 'OK') {
      return null;
    }

    final challengeScore = _parseChallengeScore(parsed) ??
        estimateChallengeScore(
          targetMoney: targetMoney,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          dueDate: dueDate,
        );

    final rewardCoins = _parseRewardCoins(parsed) ??
        estimateRewardCoins(
          challengeScore: challengeScore,
          targetMoney: targetMoney,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          dueDate: dueDate,
        );

    return GoalAiResult.ready(
      challengeScore: challengeScore,
      rewardCoins: rewardCoins,
      reason: message,
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

    // Keep non-zero saving capacity for robust fallback math.
    return normalizedIncome * 0.35;
  }

  static int _normalizeRewardCoins(int rewardCoins) {
    final clamped = _clampInt(rewardCoins, _minRewardCoins, _maxRewardCoins);
    final stepped = ((clamped / _rewardStep).round() * _rewardStep);
    return _clampInt(stepped, _minRewardCoins, _maxRewardCoins);
  }

  static int? _parseRewardCoins(Map<String, dynamic> parsed) {
    final rewardRaw = parsed['rewardCoins'] ??
        parsed['reward_coins'] ??
        parsed['reward'] ??
        parsed['coins'];

    final parsedInt = _parseIntLike(rewardRaw);
    if (parsedInt == null) return null;
    return _normalizeRewardCoins(parsedInt);
  }

  static int? _parseChallengeScore(Map<String, dynamic> parsed) {
    final scoreRaw = parsed['challengeScore'] ??
        parsed['challenge_score'] ??
        parsed['goalScore'] ??
        parsed['score'];

    final parsedInt = _parseIntLike(scoreRaw);
    if (parsedInt == null) return null;
    return _clampInt(parsedInt, _minChallengeScore, _maxChallengeScore);
  }

  static int? _parseIntLike(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      final direct = double.tryParse(normalized);
      if (direct != null) return direct.round();

      final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
      if (match != null) {
        final extracted = double.tryParse(match.group(0)!);
        if (extracted != null) return extracted.round();
      }
    }
    return null;
  }

  static Map<String, dynamic>? _extractStructuredPayload(String text) {
    Map<String, dynamic>? parseJson(String input) {
      final decoded = jsonDecode(input);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
      return null;
    }

    try {
      return parseJson(text.trim());
    } catch (_) {}

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;

    final candidate = text.substring(start, end + 1).trim();
    try {
      return parseJson(candidate);
    } catch (_) {
      return null;
    }
  }

  static GoalAiInvalidField? _parseInvalidField(String? rawField) {
    if (rawField == null || rawField.trim().isEmpty) return null;
    final normalized = rawField.trim().toLowerCase();
    if (normalized.contains('title')) return GoalAiInvalidField.title;
    if (normalized.contains('description') || normalized.contains('detail')) {
      return GoalAiInvalidField.description;
    }
    if (normalized.contains('amount') ||
        normalized.contains('target') ||
        normalized.contains('money')) {
      return GoalAiInvalidField.amount;
    }
    return null;
  }

  static GoalAiInvalidField? _inferInvalidFieldFromText(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('title')) return GoalAiInvalidField.title;
    if (normalized.contains('description') || normalized.contains('detail')) {
      return GoalAiInvalidField.description;
    }
    if (normalized.contains('amount') ||
        normalized.contains('target') ||
        normalized.contains('money')) {
      return GoalAiInvalidField.amount;
    }
    return null;
  }

  static String? _extractText(Map<String, dynamic> data) {
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final msg = choices.first['message'];
    if (msg is! Map) return null;
    final content = msg['content'];
    return content is String ? content : null;
  }

  static String _truncate(String text, {int max = 120}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...';
  }

  static String _profileSnippet(UserProfile? profile) {
    if (profile == null) {
      return 'age not set; monthly income about 20; monthly expenses unknown; beginner profile; primary goal saving; income type student.';
    }

    final experience = profile.experience == FinancialExperience.intermediate
        ? 'intermediate experience'
        : 'beginner experience';

    final mainGoal = () {
      switch (profile.mainGoal) {
        case MainGoal.learning:
          return 'primary goal learning';
        case MainGoal.tracking:
          return 'primary goal expense tracking';
        case MainGoal.saving:
          return 'primary goal saving';
      }
    }();

    final incomeType = () {
      switch (profile.incomeType) {
        case IncomeType.partTime:
          return 'income type part-time';
        case IncomeType.fullTime:
          return 'income type full-time';
        case IncomeType.student:
          return 'income type student';
      }
    }();

    final expenses = profile.monthlyExpenses != null
        ? profile.monthlyExpenses!.toStringAsFixed(2)
        : 'not provided';

    return 'age ${profile.age}; monthly income ${profile.monthlyIncome.toStringAsFixed(2)}; monthly expenses $expenses; $experience; $mainGoal; $incomeType';
  }

  static String _financialContextSnippet({
    required double? targetMoney,
    DateTime? dueDate,
    required double monthlyIncome,
    double? monthlyExpenses,
  }) {
    final income = monthlyIncome > 0 ? monthlyIncome : _defaultMonthlyIncome;
    final disposable = _estimatedDisposableIncome(income, monthlyExpenses);

    final targetText = (targetMoney != null && targetMoney > 0)
        ? targetMoney.toStringAsFixed(2)
        : 'not provided';
    final ratioText = (targetMoney != null && targetMoney > 0)
        ? (targetMoney / disposable).toStringAsFixed(2)
        : 'n/a';
    final effortMonthsText = (targetMoney != null && targetMoney > 0)
        ? (targetMoney / disposable).toStringAsFixed(1)
        : 'n/a';

    final dueText = dueDate != null
        ? '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}'
        : 'not provided';
    final daysLeftText = dueDate != null
        ? dueDate.difference(DateTime.now()).inDays.toString()
        : 'n/a';

    final expensesText = monthlyExpenses != null
        ? monthlyExpenses.toStringAsFixed(2)
        : 'not provided';

    return 'monthly income $income EUR; monthly expenses $expensesText EUR; estimated disposable income ${disposable.toStringAsFixed(2)} EUR; target amount $targetText EUR; target/disposable ratio $ratioText; estimated saving effort months $effortMonthsText; due date $dueText; days until due $daysLeftText';
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
