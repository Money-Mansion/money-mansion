import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tutorial_step.dart';

class TutorialProvider extends ChangeNotifier {
  static const _completedKey = 'tutorial_completed';
  static const _indexKey = 'tutorial_step_index';

  bool _initialized = false;
  bool _completed = false;
  int _currentIndex = 0;
  bool _currentSatisfied = false;

  SharedPreferences? _prefs;

  final List<TutorialStep> _steps = const [
    TutorialStep(
      id: 'home_intro',
      screenId: 'home',
      messageKey: 'tutorialHomeWelcome',
      targetAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      id: 'financial_nav',
      screenId: 'home',
      messageKey: 'tutorialFinancialNav',
      requiredActionId: 'open_financial',
      targetId: 'nav_financial',
    ),
    TutorialStep(
      id: 'financial_add',
      screenId: 'financial',
      messageKey: 'tutorialFinancialAction',
      requiredActionId: 'add_transaction',
      targetId: 'add_transaction',
    ),
    TutorialStep(
      id: 'shop_nav',
      screenId: 'home',
      messageKey: 'tutorialShopNav',
      requiredActionId: 'open_shop',
      targetId: 'nav_shop',
    ),
    TutorialStep(
      id: 'shop_action',
      screenId: 'shop',
      messageKey: 'tutorialShopAction',
      targetId: 'nav_shop',
    ),
    TutorialStep(
      id: 'goals_nav',
      screenId: 'home',
      messageKey: 'tutorialGoalsNav',
      requiredActionId: 'open_goals',
      targetId: 'nav_goals',
    ),
    TutorialStep(
      id: 'goal_add',
      screenId: 'goals',
      messageKey: 'tutorialGoalsAction',
      requiredActionId: 'add_goal',
      targetId: 'add_goal',
    ),
    TutorialStep(
      id: 'inventory_nav',
      screenId: 'home',
      messageKey: 'tutorialInventoryNav',
      requiredActionId: 'open_inventory',
      targetId: 'nav_inventory',
    ),
    TutorialStep(
      id: 'inventory_action',
      screenId: 'inventory',
      messageKey: 'tutorialInventoryAction',
      targetId: 'nav_inventory',
    ),
    TutorialStep(
      id: 'back_after_inventory',
      screenId: 'inventory',
      messageKey: 'tutorialBack',
      requiredActionId: 'go_back',
      targetId: 'nav_back',
    ),
    TutorialStep(
      id: 'calendar_action',
      screenId: 'home',
      messageKey: 'tutorialCalendar',
      requiredActionId: 'open_calendar',
      targetId: 'open_calendar',
    ),
    TutorialStep(
      id: 'lessons_action',
      screenId: 'home',
      messageKey: 'tutorialLessons',
      requiredActionId: 'open_lessons',
      targetId: 'open_lessons',
    ),
    TutorialStep(
      id: 'room_edit_action',
      screenId: 'home',
      messageKey: 'tutorialRoomEdit',
      requiredActionId: 'open_room_edit',
      targetId: 'open_room_edit',
    ),
    TutorialStep(
      id: 'settings_action',
      screenId: 'home',
      messageKey: 'tutorialSettings',
      requiredActionId: 'open_settings',
      targetId: 'open_settings',
    ),
    TutorialStep(
      id: 'finish',
      screenId: 'home',
      messageKey: 'tutorialFinish',
    ),
  ];

  TutorialProvider() {
    _init();
  }

  bool get isInitialized => _initialized;
  bool get isCompleted => _completed;
  bool get isActive =>
      _initialized && !_completed && _currentIndex < _steps.length;

  TutorialStep? get currentStep => isActive ? _steps[_currentIndex] : null;

  bool get isCurrentStepSatisfied {
    final step = currentStep;
    if (step == null) return false;
    if (step.requiredActionId == null) return true;
    return _currentSatisfied;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _completed = _prefs?.getBool(_completedKey) ?? false;
    _currentIndex = _prefs?.getInt(_indexKey) ?? 0;
    _currentSatisfied = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setBool(_completedKey, _completed);
    await _prefs!.setInt(_indexKey, _currentIndex);
  }

  Future<void> nextStep() async {
    if (!isActive) return;
    _currentIndex++;
    if (_currentIndex >= _steps.length) {
      _completed = true;
      _currentIndex = _steps.length;
      _currentSatisfied = false;
    } else {
      _currentSatisfied = false;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> skipTutorial() async {
    _completed = true;
    await _persist();
    notifyListeners();
  }

  Future<void> restartTutorial() async {
    _completed = false;
    _currentIndex = 0;
    _currentSatisfied = false;
    await _persist();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    await restartTutorial();
  }

  /// Mark an action as performed (e.g., user tapped a required element).
  Future<void> registerAction(String actionId) async {
    final step = currentStep;
    if (step == null) return;
    if (step.requiredActionId != null && step.requiredActionId == actionId) {
      _currentSatisfied = true;
      await _persist();
      notifyListeners();
    }
  }
}
