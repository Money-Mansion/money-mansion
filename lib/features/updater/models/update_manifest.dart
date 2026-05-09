import '../domain/update_exception.dart';

class UpdateManifest {
  final String version;
  final int build;
  final String changelog;
  final bool forceUpdate;
  final String? releaseTag;
  final String? releaseHtmlUrl;
  final String? versionAssetApiUrl;
  final String? playStoreUrl;

  const UpdateManifest({
    required this.version,
    required this.build,
    required this.changelog,
    required this.forceUpdate,
    this.releaseTag,
    this.releaseHtmlUrl,
    this.versionAssetApiUrl,
    this.playStoreUrl,
  });

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as String?;
    final build = json['build'];
    if (version == null || version.trim().isEmpty) {
      throw const UpdateException('version.json is missing version');
    }
    if (build is! num) {
      throw const UpdateException('version.json is missing numeric build');
    }

    return UpdateManifest(
      version: version.trim(),
      build: build.toInt(),
      changelog: (json['changelog'] as String?)?.trim() ?? '',
      forceUpdate: json['force_update'] == true,
      playStoreUrl: (json['play_store_url'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'build': build,
      'changelog': changelog,
      'force_update': forceUpdate,
      'play_store_url': playStoreUrl,
    };
  }

  UpdateManifest copyWith({
    String? releaseTag,
    String? releaseHtmlUrl,
    String? versionAssetApiUrl,
    String? playStoreUrl,
  }) {
    return UpdateManifest(
      version: version,
      build: build,
      changelog: changelog,
      forceUpdate: forceUpdate,
      releaseTag: releaseTag ?? this.releaseTag,
      releaseHtmlUrl: releaseHtmlUrl ?? this.releaseHtmlUrl,
      versionAssetApiUrl: versionAssetApiUrl ?? this.versionAssetApiUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
    );
  }
}
