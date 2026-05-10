import 'package:flutter/material.dart';

import '../../developer/data/developer_settings_service.dart';
import '../domain/update_service.dart';
import '../models/update_check_result.dart';
import 'download_progress_dialog.dart';

Future<void> showUpdateDialog({
  required BuildContext context,
  required UpdateCheckResult result,
  required DeveloperSettings settings,
  required UpdateService updateService,
}) async {
  final manifest = result.manifest;
  if (manifest == null) return;

  final force = manifest.forceUpdate && settings.allowForcedUpdates;
  await showDialog<void>(
    context: context,
    barrierDismissible: !force,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        backgroundColor: scheme.surface,
        title: Row(
          children: [
            Icon(Icons.system_update_alt, color: scheme.primary),
            const SizedBox(width: 10),
            const Expanded(child: Text('Developer update available')),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                manifest.friendlyTitle,
                style: Theme.of(dialogContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                manifest.friendlySource,
                style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              if (manifest.buildDate != null) ...[
                _UpdateInfoRow(
                  icon: Icons.event,
                  text: 'Built ${_formatDate(manifest.buildDate!)}',
                ),
                const SizedBox(height: 8),
              ],
              Text(
                manifest.friendlyChanges,
              ),
              if (force) ...[
                const SizedBox(height: 12),
                Text(
                  'This update is marked forced and forced updates are enabled in Developer Dashboard.',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Later'),
            ),
          FilledButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download APK'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await showDownloadProgressDialog(
                context: context,
                manifest: manifest,
                updateService: updateService,
              );
            },
          ),
        ],
      );
    },
  );
}

class _UpdateInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _UpdateInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final date =
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
