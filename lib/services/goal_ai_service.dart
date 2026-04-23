import 'dart:convert';
import 'package:http/http.dart' as http;

import 'onboarding_service.dart';

/// Calls Groq Llama 3.1-8B to classify a child's savings goal into Easy, Medium, Hard, or request more info.
class GoalAiService {
  static const _apiKey =
      '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';
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

      final structuredResult = _parseStructuredResult(text);
      if (structuredResult != null) {
        return structuredResult;
      }

      final normalized = text.toUpperCase();
      final parsedReason = _truncate(text);
      final inferredField = _inferInvalidFieldFromText(text);

      if (normalized.contains('MORE INFO') ||
          normalized.contains('MORE_INFO')) {
        return GoalAiResult.needsMoreInfo(
          reason: parsedReason,
          invalidField: inferredField,
        );
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
    final target = targetMoney != null && targetMoney > 0
        ? targetMoney.toStringAsFixed(2)
        : 'not provided';
    final profileSnippet = _profileSnippet(userProfile);

    return '''
You are helping a kids finance app. Respond in language code: $language.

Your job is to decide how difficult a savings goal is for a child with very low income. Use title, description, and target amount.
Assume the child is around 10 years old. Consider what the goal would feel like to them.
Assume the child has no savings yet, so the target amount is from zero.
Assume the child's monthly income is about $assumedMonthlyIncome EUR (allowance/chores) unless the profile below says otherwise.
Rules:
1. If title is missing or unclear -> status MORE_INFO and field title.
2. If description is missing or completely unclear -> status MORE_INFO and field description.
   Short descriptions are acceptable if they are specific.
3. If target amount is missing, zero, or invalid -> status MORE_INFO and field amount.
4. Otherwise, classify difficulty based on what the goal would feel like to a child:
   - EASY = very small or trivial goals; quick to achieve.
   - MEDIUM = typical goals for most kids; most goals fall here.
   - HARD = big, long-term, or significant goals; use more often for larger or ambitious goals; can be common if the description suggests effort or time.
5. Message must be user-facing and actionable.

Output:
Return JSON only. No markdown, no extra text.
{
  "status": "EASY|MEDIUM|HARD|MORE_INFO",
  "field": "none|title|description|amount",
  "message": "short explanation"
}

Constraints:
- If status is MORE_INFO, field must be title, description, or amount.
- If status is EASY/MEDIUM/HARD, field must be none.
- Keep message to max 12 words.

GOAL:
Title: $title
Description: $description
Target amount: $target
Due date: $due
User context: $profileSnippet
''';
  }

  static GoalAiResult _fallbackWithHeuristic({
    required String title,
    required String description,
    required double? targetMoney,
    required double monthlyIncome,
    String? reason,
  }) {
    final amountDifficulty = _difficultyFromAmount(targetMoney, monthlyIncome);
    if (amountDifficulty != null) {
      return GoalAiResult.difficulty(amountDifficulty, reason: reason);
    }
    return GoalAiResult.needsMoreInfo(
      reason: reason,
      invalidField: (targetMoney == null || targetMoney <= 0)
          ? GoalAiInvalidField.amount
          : GoalAiInvalidField.description,
    );
  }

  static GoalAiResult? _parseStructuredResult(String text) {
    final parsed = _extractStructuredPayload(text);
    if (parsed == null) return null;

    final status = (parsed['status'] ?? '').toString().toUpperCase().trim();
    if (status.isEmpty) return null;

    final message = _truncate(
      (parsed['message'] ?? parsed['reason'] ?? text).toString().trim(),
    );
    final field = _parseInvalidField(parsed['field']?.toString());

    switch (status) {
      case 'MORE_INFO':
      case 'MORE INFO':
        return GoalAiResult.needsMoreInfo(
          reason: message,
          invalidField: field ?? GoalAiInvalidField.description,
        );
      case 'EASY':
        return GoalAiResult.difficulty('Easy', reason: message);
      case 'MEDIUM':
        return GoalAiResult.difficulty('Medium', reason: message);
      case 'HARD':
        return GoalAiResult.difficulty('Hard', reason: message);
      default:
        return null;
    }
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
  final GoalAiInvalidField? invalidField;

  GoalAiResult._({
    required this.difficulty,
    required this.needsMoreInfo,
    this.reason,
    this.invalidField,
  });

  factory GoalAiResult.difficulty(String difficulty, {String? reason}) =>
      GoalAiResult._(
          difficulty: difficulty,
          needsMoreInfo: false,
          reason: reason,
          invalidField: null);

  factory GoalAiResult.needsMoreInfo({
    String? reason,
    GoalAiInvalidField? invalidField,
  }) =>
      GoalAiResult._(
        difficulty: null,
        needsMoreInfo: true,
        reason: reason,
        invalidField: invalidField,
      );

  factory GoalAiResult.fallback({String? reason}) => GoalAiResult._(
        difficulty: 'Easy',
        needsMoreInfo: false,
        reason: reason,
        invalidField: null,
      );
}

enum GoalAiInvalidField { title, description, amount }
