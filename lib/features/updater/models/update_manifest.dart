import '../domain/update_exception.dart';

class UpdateManifest {
  final String version;
  final int build;
  final String changelog;
  final bool important;
  final bool forceUpdate;
  final String? apkUrl;
  final String? apkAssetName;
  final String sha256;
  final String? releaseTag;
  final String? releaseHtmlUrl;
  final String? versionAssetApiUrl;
  final String? apkAssetApiUrl;
  final String? playStoreUrl;
  final String? sourceBranch;
  final String? sourceCommit;
  final String? releaseChannel;
  final DateTime? releaseCreatedAt;
  final String? displayName;
  final String? sourceCommitMessage;
  final DateTime? sourceCommitDate;
  final DateTime? generatedAt;
  final bool supportsInternalUpdater;
  final bool overlayBuild;
  final String? updaterRef;
  final String? updaterCommit;

  const UpdateManifest({
    required this.version,
    required this.build,
    required this.changelog,
    required this.important,
    required this.forceUpdate,
    required this.sha256,
    this.apkUrl,
    this.apkAssetName,
    this.releaseTag,
    this.releaseHtmlUrl,
    this.versionAssetApiUrl,
    this.apkAssetApiUrl,
    this.playStoreUrl,
    this.sourceBranch,
    this.sourceCommit,
    this.releaseChannel,
    this.releaseCreatedAt,
    this.displayName,
    this.sourceCommitMessage,
    this.sourceCommitDate,
    this.generatedAt,
    this.supportsInternalUpdater = false,
    this.overlayBuild = false,
    this.updaterRef,
    this.updaterCommit,
  });

  factory UpdateManifest.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as String?;
    final build = json['build'];
    final sha256 = json['sha256'] as String?;
    if (version == null || version.trim().isEmpty) {
      throw const UpdateException('version.json is missing version');
    }
    if (build is! num) {
      throw const UpdateException('version.json is missing numeric build');
    }
    if (sha256 == null || sha256.trim().isEmpty) {
      throw const UpdateException('version.json is missing sha256');
    }

    return UpdateManifest(
      version: version.trim(),
      build: build.toInt(),
      changelog: (json['changelog'] as String?)?.trim() ?? '',
      important: json['important'] == true,
      forceUpdate: json['force_update'] == true,
      apkUrl: (json['apk_url'] as String?)?.trim(),
      apkAssetName: (json['apk_asset_name'] as String?)?.trim(),
      sha256: sha256.trim().toLowerCase(),
      playStoreUrl: (json['play_store_url'] as String?)?.trim(),
      sourceBranch: (json['source_branch'] as String?)?.trim(),
      sourceCommit: (json['source_commit'] as String?)?.trim(),
      releaseChannel: (json['release_channel'] as String?)?.trim(),
      displayName: (json['display_name'] as String?)?.trim(),
      sourceCommitMessage: (json['source_commit_message'] as String?)?.trim(),
      sourceCommitDate: _parseDate(json['source_commit_date'] as String?),
      generatedAt: _parseDate(json['generated_at'] as String?),
      supportsInternalUpdater: json['supports_internal_updater'] == true,
      overlayBuild: json['overlay_build'] == true,
      updaterRef: (json['updater_ref'] as String?)?.trim(),
      updaterCommit: (json['updater_commit'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'build': build,
      'changelog': changelog,
      'important': important,
      'force_update': forceUpdate,
      'apk_url': apkUrl,
      'apk_asset_name': apkAssetName,
      'sha256': sha256,
      'play_store_url': playStoreUrl,
      'source_branch': sourceBranch,
      'source_commit': sourceCommit,
      'release_channel': releaseChannel,
      'display_name': displayName,
      'source_commit_message': sourceCommitMessage,
      'source_commit_date': sourceCommitDate?.toIso8601String(),
      'generated_at': generatedAt?.toIso8601String(),
      'supports_internal_updater': supportsInternalUpdater,
      'overlay_build': overlayBuild,
      'updater_ref': updaterRef,
      'updater_commit': updaterCommit,
    };
  }

  UpdateManifest copyWith({
    String? releaseTag,
    String? releaseHtmlUrl,
    String? versionAssetApiUrl,
    String? apkAssetApiUrl,
    String? apkUrl,
    String? apkAssetName,
    String? playStoreUrl,
    String? sourceBranch,
    String? sourceCommit,
    String? releaseChannel,
    DateTime? releaseCreatedAt,
    String? displayName,
    String? sourceCommitMessage,
    DateTime? sourceCommitDate,
    DateTime? generatedAt,
    bool? supportsInternalUpdater,
    bool? overlayBuild,
    String? updaterRef,
    String? updaterCommit,
  }) {
    return UpdateManifest(
      version: version,
      build: build,
      changelog: changelog,
      important: important,
      forceUpdate: forceUpdate,
      apkUrl: apkUrl ?? this.apkUrl,
      apkAssetName: apkAssetName ?? this.apkAssetName,
      sha256: sha256,
      releaseTag: releaseTag ?? this.releaseTag,
      releaseHtmlUrl: releaseHtmlUrl ?? this.releaseHtmlUrl,
      versionAssetApiUrl: versionAssetApiUrl ?? this.versionAssetApiUrl,
      apkAssetApiUrl: apkAssetApiUrl ?? this.apkAssetApiUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      sourceBranch: sourceBranch ?? this.sourceBranch,
      sourceCommit: sourceCommit ?? this.sourceCommit,
      releaseChannel: releaseChannel ?? this.releaseChannel,
      releaseCreatedAt: releaseCreatedAt ?? this.releaseCreatedAt,
      displayName: displayName ?? this.displayName,
      sourceCommitMessage: sourceCommitMessage ?? this.sourceCommitMessage,
      sourceCommitDate: sourceCommitDate ?? this.sourceCommitDate,
      generatedAt: generatedAt ?? this.generatedAt,
      supportsInternalUpdater:
          supportsInternalUpdater ?? this.supportsInternalUpdater,
      overlayBuild: overlayBuild ?? this.overlayBuild,
      updaterRef: updaterRef ?? this.updaterRef,
      updaterCommit: updaterCommit ?? this.updaterCommit,
    );
  }

  String get shortCommit {
    final commit = sourceCommit;
    if (commit == null || commit.isEmpty) return 'unknown';
    return commit.length <= 7 ? commit : commit.substring(0, 7);
  }

  String get shortUpdaterCommit {
    final commit = updaterCommit;
    if (commit == null || commit.isEmpty) return 'unknown';
    return commit.length <= 7 ? commit : commit.substring(0, 7);
  }

  String get friendlyVersion => 'Version $version';

  String get friendlyTitle {
    final title = displayName;
    if (title != null && title.isNotEmpty) return title;
    final branch = _friendlyRefName(sourceBranch);
    if (branch != null && branch.isNotEmpty) {
      return '$branch - $friendlyVersion';
    }
    return friendlyVersion;
  }

  String get friendlySource {
    final channel = _friendlyRefName(releaseChannel);
    final branch = _friendlyRefName(sourceBranch);
    final parts = <String>[
      if (channel != null && channel.isNotEmpty) channel,
      if (branch != null && branch.isNotEmpty && branch != channel) branch,
    ];
    if (parts.isEmpty) return 'Internal build';
    return parts.join(' - ');
  }

  DateTime? get buildDate =>
      generatedAt ?? releaseCreatedAt ?? sourceCommitDate;

  String get friendlyChanges {
    final message = sourceCommitMessage;
    if (message != null && message.isNotEmpty) return message;
    if (changelog.isNotEmpty) return changelog;
    return 'No build notes were provided.';
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  static String? _friendlyRefName(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value
        .trim()
        .replaceFirst('refs/heads/', '')
        .replaceFirst('refs/tags/', '')
        .replaceAll('-', ' ')
        .replaceAll('_', ' ');
    if (RegExp(r'^[0-9a-f]{7,40}$', caseSensitive: false).hasMatch(cleaned)) {
      return null;
    }
    return cleaned;
  }
}
