import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/logging/developer_log_service.dart';
import '../../../models/game_state.dart';
import '../../../services/tutorial_provider.dart';
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
  bool _hasToken = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _settingsService.loadSettings();
    final token = await _settingsService.loadGithubToken();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _hasToken = token != null;
    });
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
          label: 'Dashboard',
          value: 'Unlocked by GitHub token',
        ),
        _InfoLine(
            label: 'GitHub token', value: _hasToken ? 'Saved' : 'Missing'),
        if (settings.lastError != null)
          _InfoLine(label: 'Last error', value: settings.lastError!),
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
        ValueListenableBuilder<List<DeveloperLogEntry>>(
          valueListenable: DeveloperLogService.entries,
          builder: (context, entries, _) {
            final visible = entries.reversed.take(120).toList();
            if (visible.isEmpty) {
              return const Text('No logs captured yet.');
            }
            return Container(
              constraints: const BoxConstraints(maxHeight: 360),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  );
                },
              ),
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
