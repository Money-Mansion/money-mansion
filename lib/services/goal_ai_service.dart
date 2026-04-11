import 'dart:convert';
import 'package:http/http.dart' as http;

import 'onboarding_service.dart';

/// Calls Groq Llama 3.1-8B to classify a child's savings goal into Easy, Medium, Hard, or request more info.
class GoalAiService {
  static const _apiKey = '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';
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  // Heuristic thresholds relative to a low child income (defaults to 20 EUR/month)
  static const double _defaultMonthlyIncome = 20; // typical allowance
  static const double _easyMultiplier = 3; // ~3 months of saving
  static const double _mediumMultiplier = 8; // ~8 months of saving
  // Hard is extremely rare

  static Future<GoalAiResult> classifyGoal({
    required String title,
    required String description,
    double? targetMoney,
    DateTime? dueDate,
    String language = 'en',
  }) async {
    final userProfile = await OnboardingService.getUserProfile();
    final monthlyIncomeForHeuristic =
        userProfile?.monthlyIncome ?? _defaultMonthlyIncome;

    if (_isVague(description)) {
      return GoalAiResult.needsMoreInfo(
        reason: 'Please add a clear description for this goal.',
      );
    }

    final prompt = _buildPrompt(
      title: title,
      description: description,
      targetMoney: targetMoney,
      dueDate: dueDate,
      language: language,
      userProfile: userProfile,
      assumedMonthlyIncome: monthlyIncomeForHeuristic,
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
          'temperature': 0.2,
          'max_tokens': 200,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode != 200) {
        print('GoalAiService HTTP ${response.statusCode}: ${response.body}');
        return _fallbackWithHeuristic(
          title: title,
          description: description,
          targetMoney: targetMoney,
          monthlyIncome: monthlyIncomeForHeuristic,
          reason: 'AI unavailable (${response.statusCode})',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractText(data);
      if (text == null) {
        return _fallbackWithHeuristic(
          title: title,
          description: description,
          targetMoney: targetMoney,
          monthlyIncome: monthlyIncomeForHeuristic,
          reason: 'Empty AI response',
        );
      }

      print('GoalAiService answer: $text');

      final normalized = text.toUpperCase();
      final parsedReason = _truncate(text);

      if (normalized.contains('MORE INFO') || normalized.contains('MORE_INFO')) {
        return GoalAiResult.needsMoreInfo(reason: parsedReason);
      } else if (normalized.contains('EASY')) {
        return GoalAiResult.difficulty('Easy', reason: parsedReason);
      } else if (normalized.contains('MEDIUM')) {
        return GoalAiResult.difficulty('Medium', reason: parsedReason);
      } else if (normalized.contains('HARD')) {
        return GoalAiResult.difficulty('Hard', reason: parsedReason);
      }

      // fallback based on amount
      final amountDifficulty =
          _difficultyFromAmount(targetMoney, monthlyIncomeForHeuristic);
      if (amountDifficulty != null) {
        return GoalAiResult.difficulty(amountDifficulty, reason: parsedReason);
      }

      return GoalAiResult.fallback(reason: parsedReason);
    } catch (e) {
      print('GoalAiService error: $e');
      return _fallbackWithHeuristic(
        title: title,
        description: description,
        targetMoney: targetMoney,
        monthlyIncome: monthlyIncomeForHeuristic,
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
  }) {
    final due = dueDate != null
        ? '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}'
        : 'not provided';
    final target =
    targetMoney != null && targetMoney > 0 ? targetMoney.toStringAsFixed(2) : 'not provided';
    final profileSnippet = _profileSnippet(userProfile);

    return '''
You are helping a kids finance app. Respond in language code: $language.

Your job is to decide how difficult a savings goal is for a child with very low income. Use both the title and description.
Assume the child is around 10 years old. Consider what the goal would feel like to them.
Assume the child has no savings yet, so the target amount is from zero.
Assume the child's monthly income is about $assumedMonthlyIncome EUR (allowance/chores) unless the profile below says otherwise.
RULES:

1. If the goal is unclear, too short, or missing details -> return MORE_INFO.
2. If the target amount is missing -> return MORE_INFO.
3. Otherwise, classify difficulty based on what the goal would feel like to a child:
   - EASY = very small or trivial goals; quick to achieve.
   - MEDIUM = typical goals for most kids; most goals fall here.
   - HARD = big, long-term, or significant goals; use more often for larger or ambitious goals; can be common if the description suggests effort or time.

OUTPUT FORMAT:

Start your answer with one of:
EASY
MEDIUM
HARD
MORE_INFO

Then add a short explanation.

GOAL:
Title: $title
Description: $description
Target amount: $target
Due date: $due
User context: $profileSnippet
respond in max 1-2 sentences max 15 words, be concise. dont say the facts of the kids finance like 20/month, 10 years old
''';
  }

  static bool _isVague(String text) {
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return words < 4;
  }

  static GoalAiResult _fallbackWithHeuristic({
    required String title,
    required String description,
    required double? targetMoney,
    required double monthlyIncome,
    String? reason,
  }) {
    final amountDifficulty =
        _difficultyFromAmount(targetMoney, monthlyIncome);
    if (amountDifficulty != null) {
      return GoalAiResult.difficulty(amountDifficulty, reason: reason);
    }
    return GoalAiResult.needsMoreInfo(reason: reason);
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
    return text.substring(0, max) + '...';
  }

  static String _profileSnippet(UserProfile? profile) {
    if (profile == null) {
      return 'age not set; income ~20; beginner by default; goal: saving; income type: student.';
    }

    final experience = profile.experience == FinancialExperience.intermediate
        ? 'intermediate experience'
        : 'beginner experience';

    final goal = () {
      switch (profile.mainGoal) {
        case MainGoal.learning:
          return 'goal: learning';
        case MainGoal.tracking:
          return 'goal: tracking spending';
        case MainGoal.saving:
        default:
          return 'goal: saving';
      }
    }();

    final incomeType = () {
      switch (profile.incomeType) {
        case IncomeType.partTime:
          return 'income type: part-time';
        case IncomeType.fullTime:
          return 'income type: full-time';
        case IncomeType.student:
        default:
          return 'income type: student';
      }
    }();

    final expenses = profile.monthlyExpenses != null
        ? 'monthly expenses: ${profile.monthlyExpenses!.toStringAsFixed(2)}'
        : 'monthly expenses not provided (assume low)';

    return 'age ${profile.age}; monthly income ${profile.monthlyIncome.toStringAsFixed(2)}; $expenses; $experience; $goal; $incomeType';
  }

  static String? _difficultyFromAmount(double? amount, double monthlyIncome) {
    if (amount == null || amount <= 0) return null;

    final easyMax = monthlyIncome * _easyMultiplier;
    final mediumMax = monthlyIncome * _mediumMultiplier;

    if (amount <= easyMax) return 'Easy';
    if (amount <= mediumMax) return 'Medium';
    return 'Hard';
  }
}

class GoalAiResult {
  final String? difficulty;
  final String? reason;
  final bool needsMoreInfo;

  GoalAiResult._({
    required this.difficulty,
    required this.needsMoreInfo,
    this.reason,
  });

  factory GoalAiResult.difficulty(String difficulty, {String? reason}) =>
      GoalAiResult._(difficulty: difficulty, needsMoreInfo: false, reason: reason);

  factory GoalAiResult.needsMoreInfo({String? reason}) =>
      GoalAiResult._(difficulty: null, needsMoreInfo: true, reason: reason);

  factory GoalAiResult.fallback({String? reason}) =>
      GoalAiResult._(difficulty: 'Easy', needsMoreInfo: false, reason: reason);
}
