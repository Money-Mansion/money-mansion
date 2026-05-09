import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/developer_log_service.dart';
import '../../../config/items_config.dart';
import '../../../models/game_state.dart';
import '../../../services/financial_database_service.dart';
import '../../../services/goal_database_service.dart';
import '../../../services/item_database_service.dart';
import '../../../services/lesson_progress_database_service.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/quiz_progress_database_service.dart';
import '../../../services/room_component_database_service.dart';
import '../../../services/room_layout_database_service.dart';
import '../../../services/streak_service.dart';
import '../../../services/tutorial_provider.dart';
import '../../updater/domain/update_service.dart';
import '../data/developer_settings_service.dart';

class DeveloperResetService {
  Future<void> resetDatabases({
    required GameState gameState,
    TutorialProvider? tutorialProvider,
  }) async {
    DeveloperLogService.warning('Developer database reset started');
    await ItemDatabaseService.clearAllOwnedItems();
    await FinancialDatabaseService.clearAllFinancialData();
    await GoalDatabaseService.clearAllGoals();
    await RoomLayoutDatabaseService.clearAllRoomLayouts();
    await RoomComponentDatabaseService.clearAllOwnedComponents();
    await QuizProgressDatabaseService.clearAllProgress();
    await LessonProgressDatabaseService.clearAllOpenedLessons();
    await StreakService.resetStreak();
    await RoomComponentDatabaseService.ensureDefaultComponentsOwned();
    await RoomComponentDatabaseService.ensureStarterRuinedFloorsOwned();
    await ItemDatabaseService.ensureStarterBrokenItemsOwned(GAME_ITEMS);
    await tutorialProvider?.restartTutorial();

    gameState.clearOwnedItems();
    gameState.setCoins(100);
    gameState.setMoney(0.0);
    gameState.setCurrentStreak(0);
    DeveloperLogService.warning('Developer database reset completed');
  }

  Future<void> fullAppReset({
    required GameState gameState,
    TutorialProvider? tutorialProvider,
  }) async {
    DeveloperLogService.warning('Developer full app reset started');
    await resetDatabases(
      gameState: gameState,
      tutorialProvider: tutorialProvider,
    );
    await OnboardingService.resetAllOnboardingAndTutorialData();
    await OnboardingService.resetOnboarding();
    await OnboardingService.resetPrivacyConsent();
    await UpdateService.instance.clearUpdateCache();
    await DeveloperSettingsService.instance.clearAllDeveloperSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    DeveloperLogService.warning('Developer full app reset completed');
  }
}
