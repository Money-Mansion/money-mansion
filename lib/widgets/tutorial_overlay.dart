import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_localizations_provider.dart';
import '../services/onboarding_service.dart';
import '../services/tutorial_provider.dart';
import '../services/tutorial_target_registry.dart';

class TutorialOverlay extends StatefulWidget {
  final String currentScreenId;
  const TutorialOverlay({super.key, required this.currentScreenId});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  String? _username;
  DateTime? _lastBlockedMessage;
  static const Set<String> _exitTargetIds = {
    'nav_shop',
    'nav_financial',
    'nav_goals',
    'nav_inventory',
    'nav_back',
    'open_settings',
    'open_calendar',
    'open_lessons',
    'open_room_edit',
    'room_edit_save',
    'room_edit_components',
    'room_edit_inventory',
    'close_lessons',
    'close_shop',
    'close_financial',
    'close_goals',
    'close_settings',
    'close_calendar',
    'close_room_edit',
  };

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final profile = await OnboardingService.getUserProfile();
    if (!mounted) return;
    final name = profile?.username.trim();
    setState(() {
      _username = (name != null && name.isNotEmpty) ? name : null;
    });
  }

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
        // Get safe area padding to keep overlays within visible bounds
        final safeAreaPadding = MediaQuery.of(context).padding;

        // ── Resolve target rect ──────────────────────────────────────────
        // Prefer the root overlay for consistent coordinate space across
        // routes; fall back to this widget's box if overlay isn't ready.
        final overlayBox =
            Overlay.of(context)?.context.findRenderObject() as RenderBox?;
        final fallbackBox = context.findRenderObject() as RenderBox?;
        final box = overlayBox ?? fallbackBox;
        Rect? toLocalRect(String targetId) {
          final rect = TutorialTargetRegistry.instance.getTarget(targetId);
          if (rect == null || box == null) return null;
          // Targets are tracked in overlay coordinates when available.
          if (overlayBox != null && identical(box, overlayBox)) {
            return rect;
          }
          final origin = box.localToGlobal(Offset.zero);
          return rect.shift(-origin);
        }

        final targetRectLocal =
            step.targetId != null ? toLocalRect(step.targetId!) : null;
        final List<Rect> alwaysAllowedRects = [];
        if (targetRectLocal != null) {
          alwaysAllowedRects.add(targetRectLocal);
        }
        if (step.id == 'room_edit_open_inventory' ||
            step.id == 'room_edit_place_item') {
          final inventoryRect = toLocalRect('room_edit_inventory');
          if (inventoryRect != null) {
            alwaysAllowedRects.add(inventoryRect);
          }
        }
        if (step.screenId == 'room_edit') {
          final zoomSliderRect = toLocalRect('room_edit_zoom_slider');
          if (zoomSliderRect != null) {
            alwaysAllowedRects.add(zoomSliderRect);
          }
        }
        if (step.id == 'lessons_return') {
          final quizzesTabRect = toLocalRect('tab_quizes');
          final lessonsTabRect = toLocalRect('tab_lessons');
          if (quizzesTabRect != null) alwaysAllowedRects.add(quizzesTabRect);
          if (lessonsTabRect != null) alwaysAllowedRects.add(lessonsTabRect);
        }
        final blockedExitRects = _exitTargetIds
            .where((id) {
              if (id == step.targetId) return false;
              // Keep inventory button usable while user is expected to place
              // items, so they can reopen inventory multiple times.
              if (id == 'room_edit_inventory' &&
                  (step.id == 'room_edit_open_inventory' ||
                      step.id == 'room_edit_place_item')) {
                return false;
              }
              return true;
            })
            .map(toLocalRect)
            .whereType<Rect>()
            .where(
              (rect) => !alwaysAllowedRects.any(rect.overlaps),
            )
            .toList(growable: false);

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
          hint = l10n.translate(
            'tutorialNavigateHint',
            replacements: {'name': _username ?? ''},
          );
        } else if (step.requiredActionId != null && !satisfied) {
          hint = l10n.translate(
            'tutorialDoAction',
            replacements: {'name': _username ?? ''},
          );
        }

        // Tapping the bubble advances when no action is required (passive steps).
        final canTapToContinue = isFinish || step.requiredActionId == null;

        return Positioned.fill(
          child: Stack(
            children: [
              for (final rect in blockedExitRects)
                _RectInputBlocker(
                  blockedRect: rect,
                  onBlockedTap: () {
                    final now = DateTime.now();
                    if (_lastBlockedMessage != null &&
                        now.difference(_lastBlockedMessage!) <
                            const Duration(seconds: 1)) {
                      return;
                    }
                    _lastBlockedMessage = now;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(l10n.translate('tutorialTapHere')),
                          duration: const Duration(milliseconds: 900),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },
                ),
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
                            border:
                                Border.all(color: Colors.deepOrange, width: 3),
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
              Positioned(
                left: safeAreaPadding.left,
                right: safeAreaPadding.right,
                top: dialogueAtTop ? safeAreaPadding.top : null,
                bottom: dialogueAtTop ? null : safeAreaPadding.bottom,
                child: _ChrumkoDialogue(
                  imagePath: _chrumkoImage(step.id),
                  dialogueAtTop: dialogueAtTop,
                  message: l10n.translate(
                    step.messageKey,
                    replacements: {'name': _username ?? ''},
                  ),
                  hint: hint,
                  isFinish: isFinish,
                  canTapToContinue: canTapToContinue,
                  onContinue: () => context.read<TutorialProvider>().nextStep(),
                  onSkip: () => context.read<TutorialProvider>().skipTutorial(),
                  skipLabel: l10n.translate('tutorialSkip'),
                  tapToContinueLabel: l10n.translate('tutorialTapToContinue'),
                  tapToFinishLabel: l10n.translate('tutorialTapToFinish'),
                  speakerName: l10n.translate('tutorialSpeakerName'),
                  showSpeakerName: step.id != 'chrumko_intro',
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
  final bool showSpeakerName;

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
    required this.showSpeakerName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          dialogueAtTop ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // ── Chrumko character image ─────────────────────────────────────
        IgnorePointer(
          child: SizedBox(
            width: 100,
            height: 150,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              alignment:
                  dialogueAtTop ? Alignment.topCenter : Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── Speech bubble ──────────────────────────────────────────────
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
                          if (showSpeakerName || canTapToContinue || isFinish)
                            Row(
                              children: [
                                if (showSpeakerName) ...[
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
                                ],
                                const Spacer(),
                                // Tappable skip button in the header — very subtle
                                if (!isFinish)
                                  TextButton(
                                    onPressed: onSkip,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey[400],
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      skipLabel,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                      ),
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
                          if (showSpeakerName || canTapToContinue || isFinish)
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

                          // Continue button only — skip is now in the header
                          if (!isFinish && canTapToContinue) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.deepOrange,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: onContinue,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.deepOrange,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      tapToContinueLabel,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

/// Blocks input only inside a specific rectangle.
class _RectInputBlocker extends StatelessWidget {
  final Rect blockedRect;
  final VoidCallback? onBlockedTap;

  const _RectInputBlocker({
    required this.blockedRect,
    this.onBlockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: blockedRect.left,
      top: blockedRect.top,
      width: blockedRect.width,
      height: blockedRect.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBlockedTap,
      ),
    );
  }
}