import 'package:flutter/foundation.dart';

class DeveloperConfig {
  DeveloperConfig._();

  static const githubOwner =
      String.fromEnvironment('GITHUB_OWNER', defaultValue: 'Money-Mansion');
  static const githubRepo =
      String.fromEnvironment('GITHUB_REPO', defaultValue: 'money-mansion');
  static const playStorePackage = String.fromEnvironment(
    'PLAY_STORE_PACKAGE',
    defaultValue: 'com.moneymansion.app',
  );

  // Android Studio installs are debug builds by default. Google Play builds are
  // release builds, so the dashboard cannot be enabled in the Play artifact.
  static const dashboardEnabled = kDebugMode;
}
