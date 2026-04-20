import 'package:shared_preferences/shared_preferences.dart';

enum FinancialExperience { beginner, intermediate }

enum MainGoal { saving, learning, tracking }

enum IncomeType { student, partTime, fullTime }

class UserProfile {
  final String username;
  final int age;
  final double monthlyIncome;
  final double? monthlyExpenses;
  final FinancialExperience experience;
  final MainGoal mainGoal;
  final IncomeType incomeType;

  const UserProfile({
    required this.username,
    required this.age,
    required this.monthlyIncome,
    required this.experience,
    required this.mainGoal,
    required this.incomeType,
    this.monthlyExpenses,
  });

  UserProfile copyWith({
    String? username,
    int? age,
    double? monthlyIncome,
    double? monthlyExpenses,
    FinancialExperience? experience,
    MainGoal? mainGoal,
    IncomeType? incomeType,
  }) {
    return UserProfile(
      username: username ?? this.username,
      age: age ?? this.age,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      experience: experience ?? this.experience,
      mainGoal: mainGoal ?? this.mainGoal,
      incomeType: incomeType ?? this.incomeType,
    );
  }
}

class OnboardingService {
  static const _firstLaunchKey = 'isFirstLaunch';
  static const _privacyConsentKey = 'privacy_policy_consent';
  static const _usernameKey = 'user_name';
  static const _ageKey = 'user_age';
  static const _monthlyIncomeKey = 'user_monthly_income';
  static const _monthlyExpensesKey = 'user_monthly_expenses';
  static const _experienceKey = 'user_experience';
  static const _goalKey = 'user_goal';
  static const _incomeTypeKey = 'user_income_type';

  static const _experienceBeginner = 'beginner';
  static const _experienceIntermediate = 'intermediate';
  static const _goalSaving = 'saving';
  static const _goalLearning = 'learning';
  static const _goalTracking = 'tracking';
  static const _incomeTypeStudent = 'student';
  static const _incomeTypePartTime = 'part_time';
  static const _incomeTypeFullTime = 'full_time';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  static Future<bool> hasPrivacyConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyConsentKey) ?? false;
  }

  static Future<void> setPrivacyConsentGiven() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyConsentKey, true);
  }

  static Future<void> resetPrivacyConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_privacyConsentKey);
  }

  static Future<void> saveUserProfile({
    required String username,
    required int age,
    required double monthlyIncome,
    double? monthlyExpenses,
    required FinancialExperience experience,
    required MainGoal mainGoal,
    required IncomeType incomeType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setInt(_ageKey, age);
    await prefs.setDouble(_monthlyIncomeKey, monthlyIncome);

    if (monthlyExpenses != null) {
      await prefs.setDouble(_monthlyExpensesKey, monthlyExpenses);
    } else {
      await prefs.remove(_monthlyExpensesKey);
    }

    await prefs.setString(_experienceKey, _experienceToString(experience));
    await prefs.setString(_goalKey, _goalToString(mainGoal));
    await prefs.setString(_incomeTypeKey, _incomeTypeToString(incomeType));
    await prefs.setBool(_firstLaunchKey, false);
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final age = prefs.getInt(_ageKey);
    final income = prefs.getDouble(_monthlyIncomeKey);

    if (username == null || age == null || income == null) {
      return null;
    }

    final expenses = prefs.getDouble(_monthlyExpensesKey);
    final experienceString = prefs.getString(_experienceKey);
    final goalString = prefs.getString(_goalKey);
    final incomeTypeString = prefs.getString(_incomeTypeKey);

    return UserProfile(
      username: username,
      age: age,
      monthlyIncome: income,
      monthlyExpenses: expenses,
      experience: _experienceFromString(experienceString),
      mainGoal: _goalFromString(goalString),
      incomeType: _incomeTypeFromString(incomeTypeString),
    );
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_ageKey);
    await prefs.remove(_monthlyIncomeKey);
    await prefs.remove(_monthlyExpensesKey);
    await prefs.remove(_experienceKey);
    await prefs.remove(_goalKey);
    await prefs.remove(_incomeTypeKey);
    await prefs.setBool(_firstLaunchKey, true);
  }

  static FinancialExperience _experienceFromString(String? value) {
    switch (value) {
      case _experienceIntermediate:
        return FinancialExperience.intermediate;
      case _experienceBeginner:
      default:
        return FinancialExperience.beginner;
    }
  }

  static String _experienceToString(FinancialExperience experience) {
    switch (experience) {
      case FinancialExperience.intermediate:
        return _experienceIntermediate;
      case FinancialExperience.beginner:
      default:
        return _experienceBeginner;
    }
  }

  static MainGoal _goalFromString(String? value) {
    switch (value) {
      case _goalLearning:
        return MainGoal.learning;
      case _goalTracking:
        return MainGoal.tracking;
      case _goalSaving:
      default:
        return MainGoal.saving;
    }
  }

  static String _goalToString(MainGoal goal) {
    switch (goal) {
      case MainGoal.learning:
        return _goalLearning;
      case MainGoal.tracking:
        return _goalTracking;
      case MainGoal.saving:
      default:
        return _goalSaving;
    }
  }

  static IncomeType _incomeTypeFromString(String? value) {
    switch (value) {
      case _incomeTypePartTime:
        return IncomeType.partTime;
      case _incomeTypeFullTime:
        return IncomeType.fullTime;
      case _incomeTypeStudent:
      default:
        return IncomeType.student;
    }
  }

  static String _incomeTypeToString(IncomeType incomeType) {
    switch (incomeType) {
      case IncomeType.partTime:
        return _incomeTypePartTime;
      case IncomeType.fullTime:
        return _incomeTypeFullTime;
      case IncomeType.student:
      default:
        return _incomeTypeStudent;
    }
  }
}
