import 'package:flutter_test/flutter_test.dart';
import 'package:money_mansion/features/updater/domain/semantic_version.dart';
import 'package:money_mansion/features/updater/domain/version_checker.dart';
import 'package:money_mansion/features/updater/models/update_manifest.dart';

void main() {
  group('SemanticVersion', () {
    test('compares major minor and patch values', () {
      expect(
        SemanticVersion.parse('1.2.1')
            .compareTo(SemanticVersion.parse('1.2.0')),
        greaterThan(0),
      );
      expect(
        SemanticVersion.parse('2.0.0')
            .compareTo(SemanticVersion.parse('1.9.9')),
        greaterThan(0),
      );
    });

    test('treats release versions as newer than prereleases', () {
      expect(
        SemanticVersion.parse('1.2.0')
            .compareTo(SemanticVersion.parse('1.2.0-beta.1')),
        greaterThan(0),
      );
    });

    test('ignores v prefix and build metadata', () {
      expect(
        SemanticVersion.parse('v1.2.0+7')
            .compareTo(SemanticVersion.parse('1.2.0')),
        0,
      );
    });
  });

  group('VersionChecker', () {
    const current = InstalledVersion(version: '1.1.3', build: 6);

    test('uses semantic version first', () {
      final manifest = _manifest(version: '1.2.0', build: 1);
      expect(VersionChecker().isNewer(manifest, current), isTrue);
    });

    test('uses build number as same-version tie breaker', () {
      final manifest = _manifest(version: '1.1.3', build: 7);
      expect(VersionChecker().isNewer(manifest, current), isTrue);
    });

    test('does not downgrade to lower build', () {
      final manifest = _manifest(version: '1.1.3', build: 5);
      expect(VersionChecker().isNewer(manifest, current), isFalse);
    });
  });
}

UpdateManifest _manifest({required String version, required int build}) {
  return UpdateManifest(
    version: version,
    build: build,
    changelog: 'Test',
    important: false,
    forceUpdate: false,
    sha256: '0000000000000000000000000000000000000000000000000000000000000000',
    playStoreUrl:
        'https://play.google.com/store/apps/details?id=com.moneymansion.app',
  );
}
