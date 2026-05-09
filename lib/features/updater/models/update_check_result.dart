import 'update_manifest.dart';

enum UpdateCheckStatus {
  updateAvailable,
  upToDate,
  disabled,
  missingToken,
  unsupportedPlatform,
  error,
}

class UpdateCheckResult {
  final UpdateCheckStatus status;
  final UpdateManifest? manifest;
  final String currentVersion;
  final int currentBuild;
  final String? message;

  const UpdateCheckResult({
    required this.status,
    required this.currentVersion,
    required this.currentBuild,
    this.manifest,
    this.message,
  });

  bool get hasUpdate => status == UpdateCheckStatus.updateAvailable;
}
