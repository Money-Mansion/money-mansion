import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../services/onboarding_service.dart';
import '../services/tutorial_provider.dart';
import 'game_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();

  String? _errorMessage;
  String? _selectedLanguage;
  bool _isSaving = false;
  FinancialExperience _experience = FinancialExperience.beginner;
  MainGoal _mainGoal = MainGoal.saving;
  IncomeType _incomeType = IncomeType.student;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _incomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleContinue() async {
    final l10n = context.read<AppLocalizationsProvider>();
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();
    final incomeText = _incomeController.text.trim().replaceAll(',', '.');
    final expensesText = _expensesController.text.trim().replaceAll(',', '.');

    if (name.isEmpty) {
      _showError(l10n.translate('onboardingNameError'));
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      _showError(l10n.translate('onboardingAgeError'));
      return;
    }

    final income = double.tryParse(incomeText);
    if (income == null || income < 0) {
      _showError(l10n.translate('onboardingIncomeError'));
      return;
    }

    double? expenses;
    if (expensesText.isNotEmpty) {
      expenses = double.tryParse(expensesText);
      if (expenses == null || expenses < 0) {
        _showError(l10n.translate('onboardingExpensesError'));
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
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

    await context.read<TutorialProvider>().restartTutorial();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final theme = Theme.of(context);
    final supportedLanguages = l10n.getSupportedLanguages();
    _selectedLanguage ??= l10n.currentLanguage;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 227, 241),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('onboardingTitle'),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('onboardingSubtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDropdown<String>(
                    label: l10n.translate('onboardingLanguageLabel'),
                    value: _selectedLanguage!,
                    items: supportedLanguages
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text(l10n.getLanguageName(code)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedLanguage = value);
                      l10n.setLanguage(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: l10n.translate('onboardingNameLabel'),
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ageController,
                    label: l10n.translate('onboardingAgeLabel'),
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _incomeController,
                    label: l10n.translate('onboardingIncomeLabel'),
                    icon: Icons.account_balance_wallet_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
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
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _experience = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
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
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _mainGoal = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
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
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _incomeType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _expensesController,
                    label: l10n.translate('onboardingExpensesLabel'),
                    icon: Icons.trending_down_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _handleContinue,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l10n.translate('onboardingContinue'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
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
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
      ),
      onSubmitted: (_) {
        if (textInputAction == TextInputAction.done) {
          _handleContinue();
        }
      },
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
          borderSide: const BorderSide(color: Colors.deepOrange),
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
