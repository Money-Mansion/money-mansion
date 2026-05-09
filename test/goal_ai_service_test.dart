import 'package:flutter_test/flutter_test.dart';
import 'package:money_mansion/services/goal_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'user_name': 'Tester',
      'user_age': 12,
      'user_monthly_income': 50.0,
      'user_monthly_expenses': 10.0,
      'user_experience': 'beginner',
      'user_goal': 'saving',
      'user_income_type': 'student',
    });
  });

  test('classifyGoal estimates reward locally from saved profile context',
      () async {
    final result = await GoalAiService.classifyGoal(
      title: 'Bike',
      description: 'Save money for a bike',
      targetMoney: 120,
      dueDate: DateTime.now().add(const Duration(days: 60)),
    );

    expect(result.needsMoreInfo, isFalse);
    expect(result.challengeScore, inInclusiveRange(1, 100));
    expect(result.rewardCoins, inInclusiveRange(10, 5000));
  });

  test('classifyGoal requires a positive target amount', () async {
    final result = await GoalAiService.classifyGoal(
      title: 'Bike',
      description: 'Save money for a bike',
      targetMoney: 0,
    );

    expect(result.needsMoreInfo, isTrue);
    expect(result.invalidField, GoalAiInvalidField.amount);
  });
}
