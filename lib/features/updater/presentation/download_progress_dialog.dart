import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/logging/developer_log_service.dart';
import '../domain/update_service.dart';
import '../models/update_manifest.dart';

Future<void> showDownloadProgressDialog({
  required BuildContext context,
  required UpdateManifest manifest,
  required UpdateService updateService,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DownloadProgressDialog(
      manifest: manifest,
      updateService: updateService,
    ),
  );
}

class _DownloadProgressDialog extends StatefulWidget {
  final UpdateManifest manifest;
  final UpdateService updateService;

  const _DownloadProgressDialog({
    required this.manifest,
    required this.updateService,
  });

  @override
  State<_DownloadProgressDialog> createState() =>
      _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double? _progress;
  String _status = 'Preparing download...';
  File? _apkFile;
  bool _busy = true;
  bool _installed = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Downloading APK...';
      _progress = null;
      _apkFile = null;
    });

    try {
      final file = await widget.updateService.downloadUpdate(
        manifest: widget.manifest,
        onProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() {
            _progress = received / total;
            _status =
                'Downloading ${(_progress! * 100).clamp(0, 100).toStringAsFixed(0)}%';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _apkFile = file;
        _busy = false;
        _status = 'APK verified and ready to install.';
      });
    } catch (error, stackTrace) {
      DeveloperLogService.error(
        'Update download failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error;
        _status = 'Download failed.';
      });
    }
  }

  Future<void> _install() async {
    final apk = _apkFile;
    if (apk == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Opening Android package installer...';
    });
    try {
      await widget.updateService.installApk(apk);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _installed = true;
        _status = 'Installer opened. Complete the Android prompt to update.';
      });
    } catch (error, stackTrace) {
      DeveloperLogService.error(
        'APK install failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error;
        _status = 'Install failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: scheme.surface,
      title: const Text('Internal GitHub update'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${widget.manifest.version}+${widget.manifest.build}'),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 12),
            Text(_status),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error.toString(),
                style: TextStyle(color: scheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_busy)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_installed ? 'Close' : 'Cancel'),
          ),
        if (!_busy && _error != null)
          TextButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        if (!_busy && _apkFile != null && !_installed)
          FilledButton.icon(
            onPressed: _install,
            icon: const Icon(Icons.install_mobile),
            label: const Text('Install'),
          ),
      ],
    );
  }
}
