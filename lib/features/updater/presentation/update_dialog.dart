import 'package:flutter/material.dart';

import '../domain/update_service.dart';
import '../models/update_check_result.dart';

Future<void> showUpdateDialog({
  required BuildContext context,
  required UpdateCheckResult result,
  required UpdateService updateService,
}) async {
  final manifest = result.manifest;
  if (manifest == null) return;

  final important = manifest.important;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
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
                'Version ${manifest.version}+${manifest.build}',
                style: Theme.of(dialogContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                manifest.changelog.isEmpty
                    ? 'No changelog was provided for this release.'
                    : manifest.changelog,
              ),
              if (important) ...[
                const SizedBox(height: 12),
                Text(
                  'This release is marked important in the developer manifest.',
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
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Later'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Google Play'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await updateService.openPlayStore(manifest);
            },
          ),
        ],
      );
    },
  );
}
