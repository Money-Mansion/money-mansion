import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/app_localizations_provider.dart';
import '../services/financial_database_service.dart';
import '../services/streak_service.dart';
import '../services/onboarding_service.dart';
import '../services/tutorial_provider.dart';
import '../widgets/tutorial_target.dart';

class SettingsScreen extends StatefulWidget {
  final GameState gameState;

  const SettingsScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

const CARD_BG=Color.fromARGB(255, 215, 203, 235);


class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();

  FinancialExperience _experience = FinancialExperience.beginner;
  MainGoal _mainGoal = MainGoal.saving;
  IncomeType _incomeType = IncomeType.student;
  bool _profileLoaded = false;
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await OnboardingService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _nameController.text = profile.username;
        _ageController.text = profile.age.toString();
        _incomeController.text = profile.monthlyIncome.toStringAsFixed(2);
        _expensesController.text =
            profile.monthlyExpenses?.toStringAsFixed(2) ?? '';
        _experience = profile.experience;
        _mainGoal = profile.mainGoal;
        _incomeType = profile.incomeType;
        _profileLoaded = true;
      });
    } else if (mounted) {
      setState(() {
        _profileLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _incomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(AppLocalizationsProvider l10n) async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();
    final incomeText = _incomeController.text.trim().replaceAll(',', '.');
    final expensesText = _expensesController.text.trim().replaceAll(',', '.');

    if (name.isEmpty) {
      _showSnack(l10n.translate('onboardingNameError'));
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      _showSnack(l10n.translate('onboardingAgeError'));
      return;
    }

    final income = double.tryParse(incomeText);
    if (income == null || income < 0) {
      _showSnack(l10n.translate('onboardingIncomeError'));
      return;
    }

    double? expenses;
    if (expensesText.isNotEmpty) {
      expenses = double.tryParse(expensesText);
      if (expenses == null || expenses < 0) {
        _showSnack(l10n.translate('onboardingExpensesError'));
        return;
      }
    }

    setState(() {
      _savingProfile = true;
    });

    await OnboardingService.saveUserProfile(
      username: name,
      age: age,
      monthlyIncome: income,
      monthlyExpenses: expenses,
      experience: _experience,
      mainGoal: _mainGoal,
      incomeType: _incomeType,
    );

    if (mounted) {
      setState(() {
        _savingProfile = false;
      });
      _showSnack(l10n.translate('save'));
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLocalizationsProvider>(
      builder: (context, l10n, _) {
        final supportedLanguages = l10n.getSupportedLanguages();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.translate('settings')),
            backgroundColor: const Color.fromARGB(255, 149, 117, 205),
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: TutorialTarget(
              id: 'close_settings',
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(l10n),
                  const SizedBox(height: 24),
                  // Tutorial controls
                  Card(
                    elevation: 2,
                    color: CARD_BG,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('tutorialRestart'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await context
                                      .read<TutorialProvider>()
                                      .restartTutorial();
                                  _showSnack(l10n.translate('tutorialRestart'));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 103, 58, 183),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(l10n.translate('tutorialRestart')),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.translate('tutorialNavigateHint'),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Language Selection Card
                  Card(
                    elevation: 2,
                    color: CARD_BG,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('selectLanguage'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: supportedLanguages.map((languageCode) {
                              final isSelected =
                                  languageCode == l10n.currentLanguage;
                              final languageName =
                                  l10n.getLanguageName(languageCode);

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color.fromARGB(255, 103, 58, 183)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(languageName),
                                  leading: Radio<String>(
                                    value: languageCode,
                                    groupValue: l10n.currentLanguage,
                                    onChanged: (value) {
                                      if (value != null) {
                                        l10n.setLanguage(value);
                                      }
                                    },
                                    activeColor: const Color.fromARGB(255, 103, 58, 183),
                                  ),
                                  onTap: () {
                                    l10n.setLanguage(languageCode);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Game Preferences Section
                  Card(
                    elevation: 2,
                    color: CARD_BG,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('gamePreferences'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          // Background Music Toggle
                          AnimatedBuilder(
                            animation: widget.gameState,
                            builder: (context, _) => TutorialTarget(
                              id: 'toggle_music',
                              child: SwitchListTile(
                                title: Text(
                                  l10n.translate('backgroundMusic'),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                value: widget.gameState.isMusicEnabled(),
                                onChanged: (value) async {
                                  widget.gameState.setMusicEnabled(value);
                                  await FinancialDatabaseService
                                      .saveMusicEnabled(value);
                                  context
                                      .read<TutorialProvider>()
                                      .registerAction('toggle_music');
                                },
                                activeColor: const Color.fromARGB(255, 103, 58, 183),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Music Volume Slider
                          AnimatedBuilder(
                            animation: widget.gameState,
                            builder: (context, _) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.translate('musicVolume'),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Slider(
                                  value: widget.gameState.getMusicVolume(),
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 10,
                                  label:
                                      '${(widget.gameState.getMusicVolume() * 100).toStringAsFixed(0)}%',
                                  activeColor: const Color.fromARGB(255, 103, 58, 183),
                                  inactiveColor: Colors.grey[300],
                                  onChanged: (value) async {
                                    widget.gameState.setMusicVolume(value);
                                    await FinancialDatabaseService
                                        .saveMusicVolume(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Game Info Section
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: CARD_BG,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('gameInfo'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          // Coins
                          AnimatedBuilder(
                            animation: widget.gameState,
                            builder: (context, _) => Column(
                              children: [
                                _InfoRow(
                                  label: '${l10n.translate('coins')}:',
                                  value: '${widget.gameState.coins}',
                                  valueColor: Colors.orange,
                                ),
                                const SizedBox(height: 12),
                                // Money
                                _InfoRow(
                                  label: '${l10n.translate('money')}:',
                                  value:
                                      '\$${widget.gameState.money.toStringAsFixed(2)}',
                                  valueColor: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                // Streak
                                FutureBuilder<int>(
                                  future: StreakService.getCurrentStreak(),
                                  builder: (context, snapshot) => _InfoRow(
                                    label: 'Quiz Streak:',
                                    value: '${snapshot.data ?? 0}',
                                    valueColor:
                                        const Color.fromARGB(255, 149, 117, 205),
                                    icon: '🔥',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(AppLocalizationsProvider l10n) {
    return Card(
      elevation: 2,
      color: CARD_BG,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('onboardingTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (!_profileLoaded)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildTextField(
                controller: _nameController,
                label: l10n.translate('onboardingNameLabel'),
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ageController,
                label: l10n.translate('onboardingAgeLabel'),
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _incomeController,
                label: l10n.translate('onboardingIncomeLabel'),
                icon: Icons.account_balance_wallet_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              _buildDropdown<FinancialExperience>(
                label: l10n.translate('onboardingExperienceLabel'),
                value: _experience,
                items: [
                  DropdownMenuItem(
                    value: FinancialExperience.beginner,
                    child: Text(l10n.translate('experienceBeginner')),
                  ),
                  DropdownMenuItem(
                    value: FinancialExperience.intermediate,
                    child: Text(l10n.translate('experienceIntermediate')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _experience = v);
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown<MainGoal>(
                label: l10n.translate('onboardingGoalLabel'),
                value: _mainGoal,
                items: [
                  DropdownMenuItem(
                    value: MainGoal.saving,
                    child: Text(l10n.translate('goalSaving')),
                  ),
                  DropdownMenuItem(
                    value: MainGoal.learning,
                    child: Text(l10n.translate('goalLearning')),
                  ),
                  DropdownMenuItem(
                    value: MainGoal.tracking,
                    child: Text(l10n.translate('goalTracking')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _mainGoal = v);
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown<IncomeType>(
                label: l10n.translate('onboardingIncomeTypeLabel'),
                value: _incomeType,
                items: [
                  DropdownMenuItem(
                    value: IncomeType.student,
                    child: Text(l10n.translate('incomeTypeStudent')),
                  ),
                  DropdownMenuItem(
                    value: IncomeType.partTime,
                    child: Text(l10n.translate('incomeTypePartTime')),
                  ),
                  DropdownMenuItem(
                    value: IncomeType.fullTime,
                    child: Text(l10n.translate('incomeTypeFullTime')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _incomeType = v);
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _expensesController,
                label: l10n.translate('onboardingExpensesLabel'),
                icon: Icons.trending_down_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _savingProfile ? null : () => _saveProfile(l10n),
                  style: FilledButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 103, 58, 183),
                                  foregroundColor: Colors.white,
                                ),
                  child: _savingProfile
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.translate('save')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 103, 58, 183)),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 103, 58, 183)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
