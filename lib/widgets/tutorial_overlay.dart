import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../services/tutorial_provider.dart';
import '../services/tutorial_target_registry.dart';

class TutorialOverlay extends StatefulWidget {
  final String currentScreenId;
  const TutorialOverlay({super.key, required this.currentScreenId});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  String _chrumkoImage(String stepId) {
    switch (stepId) {
      case 'home_intro':
      case 'topbar_explain':
        return 'assets/images/chrumko_ukazuje.png';
      case 'financial_nav':
      case 'financial_intro':
      case 'financial_add':
      case 'financial_tabs':
        return 'assets/images/chrumko_za_stolom.png';
      case 'shop_nav':
      case 'shop_action':
      case 'shop_categories':
        return 'assets/images/chrumko_like.png';
      case 'goals_nav':
      case 'goals_intro':
      case 'goal_add':
      case 'goals_assign':
      case 'goals_reassign':
      case 'goals_complete':
        return 'assets/images/chrumko_nápad.png';
      case 'lessons_action':
      case 'lessons_return':
        return 'assets/images/chrumko_nápad.png';
      case 'room_explain':
      case 'room_edit_action':
      case 'room_edit_intro':
      case 'room_edit_open_inventory':
      case 'room_edit_place_item':
      case 'room_edit_save':
        return 'assets/images/chrumko_ukazuje.png';
      case 'calendar_action':
        return 'assets/images/chrumko_ukazuje.png';
      case 'settings_action':
      case 'settings_info':
        return 'assets/images/chrumko_za_stolom.png';
      case 'finish':
        return 'assets/images/chrumko_like.png';
      default:
        return 'assets/images/chrumko.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = context.watch<TutorialProvider>();
    final l10n = context.watch<AppLocalizationsProvider>();
    final step = tutorial.currentStep;

    if (!tutorial.isActive || step == null) return const SizedBox.shrink();

    final isFinish = step.id == 'finish';
    final isForThisScreen = step.screenId == widget.currentScreenId;
    final satisfied = tutorial.isCurrentStepSatisfied;

    // Auto-advance as soon as the required action is satisfied.
    if (satisfied && step.requiredActionId != null) {
      context.read<TutorialProvider>().scheduleAutoAdvanceWhenSatisfied();
    }

    return ValueListenableBuilder<int>(
      valueListenable: TutorialTargetRegistry.instance.version,
      builder: (context, _, __) {
        // ── Resolve target rect ──────────────────────────────────────────
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

        final screenHeight = MediaQuery.of(context).size.height;
        final targetIsLow = targetRectLocal != null &&
            targetRectLocal.center.dy > screenHeight * 0.5;
        // Keep dialogue above the learning overlay bottom bar (tabs + Return).
        // Room edit: keep the bubble high so bottom inventory FABs stay tappable.
        final dialogueAtTop = targetIsLow ||
            step.id == 'lessons_return' ||
            step.id == 'room_edit_intro' ||
            step.id == 'room_edit_place_item';

        // Build hint message
        String? hint;
        if (!isForThisScreen) {
          hint = l10n.translate('tutorialNavigateHint');
        } else if (step.requiredActionId != null && !satisfied) {
          hint = l10n.translate('tutorialDoAction');
        }

        // Tapping the bubble advances when no action is required (passive steps).
        final canTapToContinue =
            isFinish || step.requiredActionId == null;

        return Positioned.fill(
          child: Stack(
            children: [
              // ── Target highlight (pointer-transparent, purely visual) ───
              if (targetRectLocal != null)
                IgnorePointer(
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
                            border: Border.all(
                                color: Colors.deepOrange, width: 3),
                            color: Colors.deepOrange.withOpacity(0.12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.4),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // "Tap here" label — only show when the step requires action
                      if (step.requiredActionId != null && !satisfied)
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
                                  color: Colors.deepOrange.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              l10n.translate('tutorialTapHere'),
                              style: const TextStyle(
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

              // ── Chrumko dialogue ─────────────────────────────────────────
              // Positioned at top or bottom, sized to wrap content only.
              // The gradient backdrop is IgnorePointer so taps pass through it.
              // Only the white bubble and skip button capture touches.
              Positioned(
                left: 0,
                right: 0,
                top: dialogueAtTop ? 0 : null,
                bottom: dialogueAtTop ? null : 0,
                child: _ChrumkoDialogue(
                  imagePath: _chrumkoImage(step.id),
                  dialogueAtTop: dialogueAtTop,
                  message: l10n.translate(step.messageKey),
                  hint: hint,
                  isFinish: isFinish,
                  canTapToContinue: canTapToContinue,
                  onContinue: () =>
                      context.read<TutorialProvider>().nextStep(),
                  onSkip: () =>
                      context.read<TutorialProvider>().skipTutorial(),
                  skipLabel: l10n.translate('tutorialSkip'),
                  tapToContinueLabel: l10n.translate('tutorialTapToContinue'),
                  tapToFinishLabel: l10n.translate('tutorialTapToFinish'),
                  speakerName: l10n.translate('tutorialSpeakerName'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChrumkoDialogue extends StatelessWidget {
  final String imagePath;
  final String message;
  final String? hint;
  final bool isFinish;
  final bool canTapToContinue;
  final bool dialogueAtTop;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final String skipLabel;
  final String tapToContinueLabel;
  final String tapToFinishLabel;
  final String speakerName;

  const _ChrumkoDialogue({
    required this.imagePath,
    required this.message,
    this.hint,
    required this.isFinish,
    required this.canTapToContinue,
    required this.dialogueAtTop,
    required this.onContinue,
    required this.onSkip,
    required this.skipLabel,
    required this.tapToContinueLabel,
    required this.tapToFinishLabel,
    required this.speakerName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: dialogueAtTop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        // ── Chrumko character image ─────────────────────────────────────
        // IgnorePointer so touches pass through to the app beneath.
        IgnorePointer(
          child: SizedBox(
            width: 100,
            height: 150,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              alignment: dialogueAtTop
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── Speech bubble (the only tappable area) ──────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: dialogueAtTop ? 48 : 0,
              bottom: dialogueAtTop ? 0 : 16,
              right: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!dialogueAtTop)
                  CustomPaint(
                    size: const Size(16, 12),
                    painter: _BubbleTailPainter(pointUp: false),
                  ),

                // White bubble — tappable to continue on passive steps
                GestureDetector(
                  onTap: canTapToContinue ? onContinue : null,
                  child: Material(
                    color: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.black38,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Speaker name
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.deepOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                speakerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const Spacer(),
                              // Tap-to-continue hint on passive steps
                              if (canTapToContinue && !isFinish)
                                Text(
                                  tapToContinueLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (isFinish)
                                Text(
                                  tapToFinishLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.deepOrange,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Message
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),

                          // Hint
                          if (hint != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              hint!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.deepOrange,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],

                          // Skip button — only non-finish steps
                          if (!isFinish) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: onSkip,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[500],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  skipLabel,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                if (dialogueAtTop)
                  CustomPaint(
                    size: const Size(16, 12),
                    painter: _BubbleTailPainter(pointUp: true),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Speech bubble tail ────────────────────────────────────────────────────────
class _BubbleTailPainter extends CustomPainter {
  final bool pointUp;
  const _BubbleTailPainter({required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path();
    if (pointUp) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
