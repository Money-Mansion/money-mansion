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

  // The dashboard is always compiled and reachable through the token-gated
  // Settings long-press flow. Play-safe builds must not include updater code.
  static const dashboardEnabled = true;
}
