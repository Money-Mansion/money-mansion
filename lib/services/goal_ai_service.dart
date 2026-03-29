import 'dart:convert';
import 'package:http/http.dart' as http;

/// Calls Groq Llama 3.1-8B to classify a child's savings goal into Easy, Medium, Hard, or request more info.
class GoalAiService {
  static const _apiKey = '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';
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.1-8b-instant';

  // Amount thresholds for super-easy bias
  static const double _easyMax = 1000; // Almost all goals should be easy
  static const double _mediumMax = 5000; // Tiny step above easy
  // Hard is extremely rare

  static Future<GoalAiResult> classifyGoal({
    required String title,
    required String description,
    double? targetMoney,
    DateTime? dueDate,
    String language = 'en',
  }) async {
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
      final amountDifficulty = _difficultyFromAmount(targetMoney);
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
  }) {
    final due = dueDate != null
        ? '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}'
        : 'not provided';
    final target =
    targetMoney != null && targetMoney > 0 ? targetMoney.toStringAsFixed(2) : 'not provided';

    return '''
You are helping a kids finance app. Respond in language code: $language.

Your job is to decide how difficult a savings goal is for a child. Use both the title and description.
assume the child is around 10 years old. Consider what the goal would feel like to them.
assume the child has no money saved yet, so the target amount is what they need to reach from zero.
assume max income of child is around 20 EUR/month from allowances, chores, and small gigs.
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
    String? reason,
  }) {
    final amountDifficulty = _difficultyFromAmount(targetMoney);
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

  static String? _difficultyFromAmount(double? amount) {
    if (amount == null || amount <= 0) return null;
    if (amount < _easyMax) return 'Easy';
    if (amount <= _mediumMax) return 'Medium';
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