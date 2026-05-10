import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../core/logging/developer_log_service.dart';
import '../../../config/items_config.dart';
import '../../../config/room_components_config.dart';
import '../../../models/game_state.dart';
import '../../../models/goal.dart';
import '../../../services/financial_database_service.dart';
import '../../../services/goal_database_service.dart';
import '../../../services/item_database_service.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/room_component_database_service.dart';
import '../../../services/streak_service.dart';
import '../../../services/tutorial_provider.dart';
import '../../updater/domain/update_service.dart';
import '../../updater/models/update_check_result.dart';
import '../../updater/models/update_manifest.dart';
import '../../updater/presentation/download_progress_dialog.dart';
import '../../updater/presentation/update_dialog.dart';
import '../data/developer_settings_service.dart';
import '../domain/developer_reset_service.dart';

class DeveloperDashboardScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback? onClose;

  const DeveloperDashboardScreen({
    super.key,
    required this.gameState,
    this.onClose,
  });

  @override
  State<DeveloperDashboardScreen> createState() =>
      _DeveloperDashboardScreenState();
}

class _DeveloperDashboardScreenState extends State<DeveloperDashboardScreen> {
  final _settingsService = DeveloperSettingsService.instance;
  final _resetService = DeveloperResetService();

  DeveloperSettings? _settings;
  PackageInfo? _packageInfo;
  bool _hasToken = false;
  bool _busy = false;
  String _logFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _settingsService.loadSettings();
    final token = await _settingsService.loadGithubToken();
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _packageInfo = packageInfo;
      _hasToken = token != null;
    });
  }

  Future<void> _setCoins(int coins) async {
    widget.gameState.setCoins(coins);
    await FinancialDatabaseService.saveCoins(widget.gameState.coins);
    _showSnack('Coins set to ${widget.gameState.coins}');
  }

  Future<void> _addCoins(int coins) async {
    widget.gameState.addCoins(coins);
    await FinancialDatabaseService.saveCoins(widget.gameState.coins);
    _showSnack('Added $coins coins');
  }

  Future<void> _setMoney(double money) async {
    widget.gameState.setMoney(money);
    await FinancialDatabaseService.saveMoney(widget.gameState.money);
    _showSnack('Money set to \$${widget.gameState.money.toStringAsFixed(2)}');
  }

  Future<void> _addMoney(double money) async {
    widget.gameState.addMoney(money);
    await FinancialDatabaseService.saveMoney(widget.gameState.money);
    _showSnack('Added \$${money.toStringAsFixed(2)}');
  }

  Future<void> _markQuizCompleted() async {
    final streak = await StreakService.onQuizCompleted();
    widget.gameState.setCurrentStreak(streak);
    _showSnack('Quiz completion recorded. Streak: $streak');
  }

  Future<void> _reloadGameStateFromStorage() async {
    setState(() => _busy = true);
    try {
      final coins = await FinancialDatabaseService.getCoins();
      final money = await FinancialDatabaseService.getMoney();
      final streak = await StreakService.getCurrentStreak();
      final goals = await GoalDatabaseService.getAllGoals();
      final ownedItems = await ItemDatabaseService.getOwnedItems();
      widget.gameState.setCoins(coins);
      widget.gameState.setMoney(money);
      widget.gameState.setCurrentStreak(streak);
      widget.gameState.goals
        ..clear()
        ..addAll(goals);
      widget.gameState.loadOwnedItems(ownedItems);
      _showSnack('Game state reloaded from storage');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _grantAllItems() async {
    setState(() => _busy = true);
    try {
      for (final item in GAME_ITEMS) {
        if (!await ItemDatabaseService.isItemOwned(item.id)) {
          await ItemDatabaseService.addOwnedItem(item);
        }
      }
      widget.gameState
          .loadOwnedItems(await ItemDatabaseService.getOwnedItems());
      _showSnack('All shop items granted');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreStarterItems() async {
    setState(() => _busy = true);
    try {
      await ItemDatabaseService.ensureStarterBrokenItemsOwned(GAME_ITEMS);
      await ItemDatabaseService.ensureStarterDecorItemsOwned(GAME_ITEMS);
      await RoomComponentDatabaseService.ensureDefaultComponentsOwned();
      await RoomComponentDatabaseService.ensureStarterRuinedFloorsOwned();
      widget.gameState
          .loadOwnedItems(await ItemDatabaseService.getOwnedItems());
      _showSnack('Starter inventory restored');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearOwnedItems() async {
    final confirmed = await _confirm(
      title: 'Clear owned items?',
      message:
          'This removes owned shop items from local storage. Starter room components are not affected.',
      action: 'Clear items',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await ItemDatabaseService.clearAllOwnedItems();
      widget.gameState.clearOwnedItems();
      _showSnack('Owned items cleared');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _grantAllRoomComponents() async {
    setState(() => _busy = true);
    try {
      for (final component in ROOM_COMPONENTS) {
        await RoomComponentDatabaseService.addOwnedComponent(component);
      }
      _showSnack('All room components granted');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearRoomComponents() async {
    final confirmed = await _confirm(
      title: 'Clear room components?',
      message:
          'This removes owned wall and floor components. Restore starters before leaving the dashboard if the room needs defaults.',
      action: 'Clear components',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await RoomComponentDatabaseService.clearAllOwnedComponents();
      _showSnack('Room components cleared');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addSampleGoal() async {
    final now = DateTime.now();
    final goal = Goal(
      id: 'debug-goal-${now.millisecondsSinceEpoch}',
      title: 'Debug savings goal',
      description: 'Generated from the developer dashboard.',
      challengeScore: 55,
      rewardCoins: 150,
      targetMoney: 250,
      dueDate: now.add(const Duration(days: 30)),
    );
    final created = await GoalDatabaseService.createGoal(goal);
    if (created) {
      widget.gameState.addGoal(goal);
      _showSnack('Sample goal added');
    } else {
      _showSnack('Could not add sample goal');
    }
  }

  Future<void> _completeFirstOpenGoal() async {
    Goal? openGoal;
    for (final goal in widget.gameState.goals) {
      if (!goal.isCompleted) {
        openGoal = goal;
        break;
      }
    }
    if (openGoal == null) {
      _showSnack('No open goals to complete');
      return;
    }
    await GoalDatabaseService.completeGoal(openGoal.id);
    widget.gameState.completeGoal(openGoal.id);
    _showSnack('Completed goal: ${openGoal.title}');
  }

  Future<void> _clearGoals() async {
    final confirmed = await _confirm(
      title: 'Clear goals?',
      message: 'This deletes all local goals and goal progress.',
      action: 'Clear goals',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await GoalDatabaseService.clearAllGoals();
      final ids = widget.gameState.goals.map((goal) => goal.id).toList();
      for (final id in ids) {
        widget.gameState.removeGoal(id);
      }
      _showSnack('Goals cleared');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetOnboardingAndPrivacy() async {
    final confirmed = await _confirm(
      title: 'Reset onboarding and privacy?',
      message:
          'This clears the profile, onboarding, tutorial progress, and privacy consent so the startup flow can be tested again.',
      action: 'Reset flow',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await OnboardingService.resetAllOnboardingAndTutorialData();
      await context.read<TutorialProvider>().restartTutorial();
      _showSnack('Onboarding and privacy flow reset');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _acceptPrivacyConsent() async {
    await OnboardingService.setPrivacyConsentGiven();
    if (!mounted) return;
    setState(() {});
    _showSnack('Privacy consent marked accepted');
  }

  Future<void> _resetPrivacyConsentOnly() async {
    await OnboardingService.resetPrivacyConsent();
    if (!mounted) return;
    setState(() {});
    _showSnack('Privacy consent reset');
  }

  Future<void> _resetTutorialOnly() async {
    await context.read<TutorialProvider>().restartTutorial();
    if (!mounted) return;
    setState(() {});
    _showSnack('Tutorial restarted');
  }

  Future<void> _clearDeveloperToken() async {
    await _settingsService.clearGithubToken();
    if (!mounted) return;
    setState(() => _hasToken = false);
    _showSnack('GitHub token cleared');
  }

  Future<void> _copyDiagnostics() async {
    final profile = await OnboardingService.getUserProfile();
    final hasPrivacyConsent = await OnboardingService.hasPrivacyConsent();
    final acceptedPolicyVersion =
        await OnboardingService.getAcceptedPrivacyPolicyVersion();
    final text = '''
Developer diagnostics
App: ${_packageInfo?.appName ?? 'Unknown'}
Package: ${_packageInfo?.packageName ?? 'Unknown'}
Version: ${_packageInfo?.version ?? 'Unknown'}+${_packageInfo?.buildNumber ?? '0'}
Coins: ${widget.gameState.coins}
Money: ${widget.gameState.money.toStringAsFixed(2)}
Streak: ${widget.gameState.currentStreak}
Goals: ${widget.gameState.goals.length}
Owned items: ${widget.gameState.ownedItems.length}
Rooms: ${widget.gameState.rooms.length}
Profile saved: ${profile != null}
Privacy consent: $hasPrivacyConsent
Privacy policy version: $acceptedPolicyVersion/${OnboardingService.getCurrentPrivacyPolicyVersion()}
GitHub token saved: $_hasToken
Captured logs: ${DeveloperLogService.entries.value.length}
''';
    await Clipboard.setData(ClipboardData(text: text.trim()));
    _showSnack('Diagnostics copied');
  }

  Future<void> _copyVisibleLogs(List<DeveloperLogEntry> entries) async {
    final text = _filteredLogs(entries)
        .toList()
        .reversed
        .take(120)
        .map((entry) => entry.line)
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    _showSnack('Visible logs copied');
  }

  Iterable<DeveloperLogEntry> _filteredLogs(List<DeveloperLogEntry> entries) {
    return _logFilter == 'ALL'
        ? entries
        : entries.where((entry) => entry.level == _logFilter);
  }

  Future<void> _setAutoCheck(bool value) async {
    await _settingsService.setAutoCheckOnStartup(value);
    await _load();
  }

  Future<void> _setAutoDownload(bool value) async {
    await _settingsService.setAutoDownload(value);
    await _load();
  }

  Future<void> _setAllowForcedUpdates(bool value) async {
    await _settingsService.setAllowForcedUpdates(value);
    await _load();
  }

  Future<void> _checkForUpdates() async {
    setState(() => _busy = true);
    try {
      final result = await UpdateService.instance.checkForUpdates(manual: true);
      if (!mounted) return;
      await _load();
      if (result.hasUpdate) {
        await showUpdateDialog(
          context: context,
          result: result,
          settings: _settings ?? await _settingsService.loadSettings(),
          updateService: UpdateService.instance,
        );
      } else {
        _showSnack(_messageForResult(result));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _switchBuild() async {
    setState(() => _busy = true);
    try {
      final builds = await UpdateService.instance.listSwitchableBuilds();
      if (!mounted) return;
      setState(() => _busy = false);
      final selected = await showDialog<UpdateManifest>(
        context: context,
        builder: (context) => _BuildSwitcherDialog(builds: builds),
      );
      if (selected == null || !mounted) return;
      await showDownloadProgressDialog(
        context: context,
        manifest: selected,
        updateService: UpdateService.instance,
      );
    } catch (error) {
      if (!mounted) return;
      _showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetDatabases() async {
    final confirmed = await _confirm(
      title: 'Reset database data?',
      message:
          'This clears local game progress, inventory, goals, room layouts, lessons, quizzes, coins, money, and streaks. Developer settings stay intact.',
      action: 'Reset databases',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await _resetService.resetDatabases(
        gameState: widget.gameState,
        tutorialProvider: context.read<TutorialProvider>(),
      );
      _showSnack('Database data reset');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fullReset() async {
    final confirmed = await _confirm(
      title: 'Full app reset?',
      message:
          'This clears user data, onboarding, privacy consent, developer settings, GitHub token, and logs. The app will close so it can restart cleanly.',
      action: 'Full reset',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    await _resetService.fullAppReset(
      gameState: widget.gameState,
      tutorialProvider: context.read<TutorialProvider>(),
    );
    await DeveloperLogService.clear();
    if (!mounted) return;
    _showSnack('Full reset complete. Reopen the app.');
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await SystemNavigator.pop();
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(action),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _messageForResult(UpdateCheckResult result) {
    switch (result.status) {
      case UpdateCheckStatus.upToDate:
        return 'Already on latest developer release';
      case UpdateCheckStatus.disabled:
      case UpdateCheckStatus.missingToken:
      case UpdateCheckStatus.unsupportedPlatform:
      case UpdateCheckStatus.error:
        return result.message ?? 'Update check did not complete';
      case UpdateCheckStatus.updateAvailable:
        return 'Update available';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Dashboard'),
        backgroundColor: scheme.surface,
        leading: widget.onClose == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onClose,
              ),
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatusCard(settings),
                    const SizedBox(height: 12),
                    _buildUpdaterCard(settings),
                    const SizedBox(height: 12),
                    _buildEconomyCard(),
                    const SizedBox(height: 12),
                    _buildInventoryCard(),
                    const SizedBox(height: 12),
                    _buildGoalToolsCard(),
                    const SizedBox(height: 12),
                    _buildFlowToolsCard(),
                    const SizedBox(height: 12),
                    _buildResetCard(),
                    const SizedBox(height: 12),
                    _buildLogsCard(),
                    const SizedBox(height: 24),
                  ],
                ),
                if (_busy)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.08),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatusCard(DeveloperSettings settings) {
    return _DashboardSection(
      title: 'Status',
      icon: Icons.admin_panel_settings,
      children: [
        _InfoLine(
          label: 'App version',
          value: _packageInfo == null
              ? 'Loading'
              : '${_packageInfo!.version}+${_packageInfo!.buildNumber}',
        ),
        _InfoLine(
          label: 'Package',
          value: _packageInfo?.packageName ?? 'Loading',
        ),
        _InfoLine(
          label: 'Dashboard',
          value: 'Internal updater branch',
        ),
        _InfoLine(
            label: 'GitHub token', value: _hasToken ? 'Saved' : 'Missing'),
        _InfoLine(
          label: 'Last update check',
          value: settings.lastCheckAt?.toLocal().toString() ?? 'Never',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _copyDiagnostics,
              icon: const Icon(Icons.content_copy),
              label: const Text('Copy diagnostics'),
            ),
            OutlinedButton.icon(
              onPressed: _hasToken ? _clearDeveloperToken : null,
              icon: const Icon(Icons.key_off),
              label: const Text('Clear token'),
            ),
          ],
        ),
        if (settings.lastError != null)
          _InfoLine(label: 'Last error', value: settings.lastError!),
      ],
    );
  }

  Widget _buildUpdaterCard(DeveloperSettings settings) {
    return _DashboardSection(
      title: 'Internal GitHub APK Updater',
      icon: Icons.system_update,
      children: [
        _InfoLine(
          label: 'Repository',
          value:
              '${_packageInfo?.packageName ?? 'Money Mansion'} release assets',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Check on startup'),
          subtitle: const Text('Checks private GitHub release metadata'),
          value: settings.autoCheckOnStartup,
          onChanged: _busy ? null : _setAutoCheck,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-download updates'),
          subtitle: const Text('Downloads and verifies APKs automatically'),
          value: settings.autoDownload,
          onChanged: _busy ? null : _setAutoDownload,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Honor forced updates'),
          subtitle: const Text('Off by default so updates remain optional'),
          value: settings.allowForcedUpdates,
          onChanged: _busy ? null : _setAllowForcedUpdates,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: !_busy ? _checkForUpdates : null,
              icon: const Icon(Icons.cloud_sync),
              label: const Text('Check now'),
            ),
            OutlinedButton.icon(
              onPressed: !_busy ? _switchBuild : null,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Install another build'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEconomyCard() {
    return _DashboardSection(
      title: 'Economy Tools',
      icon: Icons.payments,
      children: [
        AnimatedBuilder(
          animation: widget.gameState,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoLine(label: 'Coins', value: '${widget.gameState.coins}'),
              _InfoLine(
                label: 'Money',
                value: '\$${widget.gameState.money.toStringAsFixed(2)}',
              ),
              _InfoLine(
                label: 'Streak',
                value: '${widget.gameState.currentStreak}',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : () => _addCoins(100),
                    icon: const Icon(Icons.add),
                    label: const Text('100 coins'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : () => _addCoins(1000),
                    icon: const Icon(Icons.add),
                    label: const Text('1000 coins'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _setCoins(0),
                    icon: const Icon(Icons.exposure_zero),
                    label: const Text('Zero coins'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : () => _addMoney(100),
                    icon: const Icon(Icons.add),
                    label: const Text('\$100'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : () => _addMoney(1000),
                    icon: const Icon(Icons.add),
                    label: const Text('\$1000'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _setMoney(0),
                    icon: const Icon(Icons.money_off),
                    label: const Text('Zero money'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _markQuizCompleted,
                    icon: const Icon(Icons.local_fire_department),
                    label: const Text('Quiz today'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _reloadGameStateFromStorage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reload storage'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard() {
    return _DashboardSection(
      title: 'Inventory Tools',
      icon: Icons.inventory_2,
      children: [
        AnimatedBuilder(
          animation: widget.gameState,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoLine(
                label: 'Owned items',
                value:
                    '${widget.gameState.ownedItems.length}/${GAME_ITEMS.length}',
              ),
              FutureBuilder<int>(
                future: RoomComponentDatabaseService.getOwnedComponents()
                    .then((components) => components.length),
                builder: (context, snapshot) => _InfoLine(
                  label: 'Room components',
                  value: '${snapshot.data ?? 0}/${ROOM_COMPONENTS.length}',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : _grantAllItems,
                    icon: const Icon(Icons.add_home_work),
                    label: const Text('Grant all items'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : _grantAllRoomComponents,
                    icon: const Icon(Icons.wallpaper),
                    label: const Text('Grant walls/floors'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _restoreStarterItems,
                    icon: const Icon(Icons.home_repair_service),
                    label: const Text('Restore starters'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _clearOwnedItems,
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Clear items'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _clearRoomComponents,
                    icon: const Icon(Icons.layers_clear),
                    label: const Text('Clear walls/floors'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalToolsCard() {
    return _DashboardSection(
      title: 'Goal Tools',
      icon: Icons.flag,
      children: [
        AnimatedBuilder(
          animation: widget.gameState,
          builder: (context, _) {
            final openGoals = widget.gameState.goals
                .where((goal) => !goal.isCompleted)
                .length;
            final completedGoals = widget.gameState.goals.length - openGoals;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(label: 'Open goals', value: '$openGoals'),
                _InfoLine(label: 'Completed goals', value: '$completedGoals'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _busy ? null : _addSampleGoal,
                      icon: const Icon(Icons.add),
                      label: const Text('Add sample goal'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _completeFirstOpenGoal,
                      icon: const Icon(Icons.task_alt),
                      label: const Text('Complete first'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _clearGoals,
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Clear goals'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFlowToolsCard() {
    return _DashboardSection(
      title: 'Flow Tools',
      icon: Icons.route,
      children: [
        FutureBuilder<UserProfile?>(
          future: OnboardingService.getUserProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(
                  label: 'Profile',
                  value: profile == null
                      ? 'Missing'
                      : '${profile.username}, age ${profile.age}',
                ),
                FutureBuilder<bool>(
                  future: OnboardingService.hasPrivacyConsent(),
                  builder: (context, consentSnapshot) => _InfoLine(
                    label: 'Privacy consent',
                    value: consentSnapshot.data == true ? 'Accepted' : 'Needed',
                  ),
                ),
                FutureBuilder<int>(
                  future: OnboardingService.getAcceptedPrivacyPolicyVersion(),
                  builder: (context, versionSnapshot) => _InfoLine(
                    label: 'Policy version',
                    value:
                        '${versionSnapshot.data ?? 0}/${OnboardingService.getCurrentPrivacyPolicyVersion()}',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _resetOnboardingAndPrivacy,
                      icon: const Icon(Icons.replay),
                      label: const Text('Reset startup flow'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _acceptPrivacyConsent,
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Accept privacy'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _resetPrivacyConsentOnly,
                      icon: const Icon(Icons.privacy_tip_outlined),
                      label: const Text('Reset privacy'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _resetTutorialOnly,
                      icon: const Icon(Icons.school),
                      label: const Text('Restart tutorial'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildResetCard() {
    return _DashboardSection(
      title: 'Reset Tools',
      icon: Icons.restart_alt,
      children: [
        FilledButton.icon(
          onPressed: _busy ? null : _resetDatabases,
          icon: const Icon(Icons.storage),
          label: const Text('Reset databases'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _busy ? null : _fullReset,
          icon: const Icon(Icons.delete_forever),
          label: const Text('Full app reset'),
        ),
      ],
    );
  }

  Widget _buildLogsCard() {
    return _DashboardSection(
      title: 'Logs',
      icon: Icons.article,
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: () async {
                final text = await DeveloperLogService.exportText();
                await Clipboard.setData(ClipboardData(text: text));
                _showSnack('Logs copied');
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                await DeveloperLogService.clear();
                _showSnack('Logs cleared');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'ALL', label: Text('All')),
            ButtonSegment(value: 'INFO', label: Text('Info')),
            ButtonSegment(value: 'WARN', label: Text('Warn')),
            ButtonSegment(value: 'ERROR', label: Text('Error')),
          ],
          selected: {_logFilter},
          onSelectionChanged: (selection) {
            setState(() => _logFilter = selection.first);
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<DeveloperLogEntry>>(
          valueListenable: DeveloperLogService.entries,
          builder: (context, entries, _) {
            final filtered = _filteredLogs(entries);
            final visible = filtered.toList().reversed.take(120).toList();
            if (visible.isEmpty) {
              return const Text('No logs captured yet.');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${visible.length} visible of ${entries.length} captured'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _copyVisibleLogs(entries),
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Copy visible'),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 360),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = visible[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          entry.line,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DashboardSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _BuildSwitcherDialog extends StatelessWidget {
  final List<UpdateManifest> builds;

  const _BuildSwitcherDialog({required this.builds});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Switch internal build'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: builds.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final build = builds[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: Text(
                build.friendlyTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${build.friendlySource}\n'
                'Built ${_formatBuildDate(build.buildDate)}\n'
                '${build.friendlyChanges}',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              trailing: Icon(Icons.install_mobile, color: scheme.primary),
              onTap: () => Navigator.of(context).pop(build),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

String _formatBuildDate(DateTime? value) {
  if (value == null) return 'unknown date';
  final local = value.toLocal();
  final date =
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
