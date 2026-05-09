import 'package:package_info_plus/package_info_plus.dart';

import '../models/update_manifest.dart';
import 'semantic_version.dart';

class VersionChecker {
  Future<InstalledVersion> getInstalledVersion() async {
    final info = await PackageInfo.fromPlatform();
    return InstalledVersion(
      version: info.version,
      build: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  bool isNewer(UpdateManifest remote, InstalledVersion current) {
    final remoteVersion = SemanticVersion.parse(remote.version);
    final currentVersion = SemanticVersion.parse(current.version);
    final versionCompare = remoteVersion.compareTo(currentVersion);
    if (versionCompare != 0) return versionCompare > 0;
    return remote.build > current.build;
  }
}

class InstalledVersion {
  final String version;
  final int build;

  const InstalledVersion({
    required this.version,
    required this.build,
  });
}
