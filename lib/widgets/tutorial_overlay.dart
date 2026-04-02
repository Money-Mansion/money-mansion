import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../services/tutorial_provider.dart';
import '../services/tutorial_target_registry.dart';

class TutorialOverlay extends StatelessWidget {
  final String currentScreenId;

  const TutorialOverlay({super.key, required this.currentScreenId});

  @override
  Widget build(BuildContext context) {
    final tutorial = context.watch<TutorialProvider>();
    final l10n = context.watch<AppLocalizationsProvider>();
    final step = tutorial.currentStep;

    if (!tutorial.isActive || step == null) return const SizedBox.shrink();
    if (step.id == 'finish') return const SizedBox.shrink();

    final isForThisScreen = step.screenId == currentScreenId;
    final satisfied = tutorial.isCurrentStepSatisfied;

    Alignment bubbleAlignment = Alignment.topRight;
    EdgeInsets bubblePadding = const EdgeInsets.fromLTRB(12, 110, 12, 0);
    if (step.targetId == 'open_lessons') {
      bubbleAlignment = Alignment.bottomLeft;
      bubblePadding = const EdgeInsets.fromLTRB(12, 0, 12, 80);
    }

    return ValueListenableBuilder<int>(
      valueListenable: TutorialTargetRegistry.instance.version,
      builder: (context, _, __) {
        Rect? targetRectLocal;
        if (step.targetId != null) {
          final rect =
              TutorialTargetRegistry.instance.getTarget(step.targetId!);
          final box = context.findRenderObject() as RenderBox?;
          if (rect != null && box != null) {
            final origin = box.localToGlobal(Offset.zero);
            targetRectLocal = rect.shift(-origin);
          }
        }

        final bool allowForTarget = targetRectLocal != null;

        return Positioned.fill(
          child: Stack(
            children: [
              if (targetRectLocal != null && allowForTarget)
                IgnorePointer(
                  ignoring: true,
                  child: Stack(
                    children: [
                      Positioned(
                        left: targetRectLocal.left - 4,
                        top: targetRectLocal.top - 4,
                        width: targetRectLocal.width + 8,
                        height: targetRectLocal.height + 8,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.deepOrange, width: 3),
                            color: Colors.deepOrange.withOpacity(0.10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.35),
                                blurRadius: 16,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: targetRectLocal.center.dx - 36,
                        top: targetRectLocal.bottom + 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.35),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: const Text(
                            'Tap here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (targetRectLocal == null && step.targetAlignment != null)
                IgnorePointer(
                  ignoring: true,
                  child: Align(
                    alignment: step.targetAlignment!,
                    child: Container(
                      width: 110,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepOrange, width: 3),
                        color: Colors.deepOrange.withOpacity(0.08),
                      ),
                      child: const Icon(Icons.arrow_downward,
                          color: Colors.deepOrange, size: 26),
                    ),
                  ),
                ),
              if (targetRectLocal == null && step.targetAlignment == null)
                const SizedBox.shrink(),
              Align(
                alignment: bubbleAlignment,
                child: Padding(
                  padding: bubblePadding,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Material(
                      color: Colors.white,
                      elevation: 6,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline,
                                    size: 18, color: Colors.deepOrange),
                                const SizedBox(width: 6),
                                Text(
                                  'Chrumko',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.translate(step.messageKey),
                              style:
                                  const TextStyle(fontSize: 14, height: 1.35),
                            ),
                            if (!isForThisScreen)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  l10n.translate('tutorialNavigateHint'),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            if (step.requiredActionId != null && !satisfied)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  l10n.translate('tutorialDoAction'),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.deepOrange),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => context
                                      .read<TutorialProvider>()
                                      .skipTutorial(),
                                  child: Text(l10n.translate('tutorialSkip')),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: satisfied
                                      ? () => context
                                          .read<TutorialProvider>()
                                          .nextStep()
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(l10n.translate('tutorialNext')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
