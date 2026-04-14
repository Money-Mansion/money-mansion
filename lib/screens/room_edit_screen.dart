import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../services/app_localizations_provider.dart';
import '../services/room_layout_database_service.dart';
import '../services/tutorial_provider.dart';
import '../widgets/room_viewer.dart';
import '../widgets/room_components_sheet.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/tutorial_target.dart';
import '../widgets/zoom_slider.dart';
import '../games/room_world.dart';

// App colour constants
const _purple      = Color(0xFF6B5B8C);
const _purpleLight = Color(0xFFB8A8D8);
const _purpleBg    = Color(0xFFE8D4F0);
const _cream       = Color(0xFFFFFBF5);

class RoomEditScreen extends StatefulWidget {
  final Room? room;
  final GameState? gameState;

  const RoomEditScreen({
    super.key,
    this.room,
    this.gameState,
  });

  @override
  State<RoomEditScreen> createState() => _RoomEditScreenState();
}

class _RoomEditScreenState extends State<RoomEditScreen> {
  RoomWorld? roomWorld;
  bool _hasSelectedItem = false;

  bool get _showDesktopZoomSlider {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  @override
  void dispose() {
    if (roomWorld != null) {
      roomWorld!.onSelectionChanged = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final language = l10n.currentLanguage;
    final sk = language == 'sk';

    // Get safe area insets to keep UI overlays within visible bounds
    final mediaQuery = MediaQuery.of(context);
    final safeAreaPadding = mediaQuery.padding;
    final topSafeArea = safeAreaPadding.top;
    final bottomSafeArea = safeAreaPadding.bottom;
    final leftSafeArea = safeAreaPadding.left;
    final rightSafeArea = safeAreaPadding.right;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Flame canvas ──────────────────────────────────────────────────
          RoomViewer(
            room: widget.room,
            language: language,
            gameState: widget.gameState,
            onEditPressed: null,
            onRoomWorldReady: (RoomWorld world) {
              setState(() {
                roomWorld = world;
                roomWorld!.onSelectionChanged = () {
                  setState(() {
                    _hasSelectedItem = roomWorld!.getSelectedItem() != null;
                  });
                };
              });
            },
          ),
          // Top-left button (Checkmark only)
          Positioned(
            top: topSafeArea + 20,
            left: leftSafeArea + 20,
            child: TutorialTarget(
              id: 'room_edit_save',
              child: FloatingActionButton(
                mini: true,
                heroTag: null,
                backgroundColor: Colors.purple.shade300,
                onPressed: _onConfirmPressed,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ),
          ),
          // Top-right button (X close)
          Positioned(
            top: topSafeArea + 20,
            right: rightSafeArea + 20,
            child: TutorialTarget(
              id: 'close_room_edit',
              child: FloatingActionButton(
                mini: true,
                heroTag: null,
                backgroundColor: Colors.pink.shade300,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),

          // ── Bottom-left: room components + inventory ──────────────────────
          Positioned(
            bottom: bottomSafeArea + 24,
            left: leftSafeArea + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TutorialTarget(
                  id: 'room_edit_components',
                  child: _BottomFab(
                    icon: Icons.home_work_rounded,
                    color: Colors.amber.shade400,
                    tooltip: sk ? 'Komponenty izby' : 'Room components',
                    onTap: () => _showRoomComponentsSheet(context),
                  ),
                ),
                const SizedBox(height: 10),
                TutorialTarget(
                  id: 'room_edit_inventory',
                  child: _BottomFab(
                    icon: Icons.inventory_2_rounded,
                    color: _purpleLight,
                    tooltip: sk ? 'Inventár' : 'Inventory',
                    onTap: () => _showInventorySheet(context, l10n),
                  ),
                ),
              ],
            ),
          ),
          // Bottom-right item control buttons (appears when item is selected)
          if (_hasSelectedItem)
            Positioned(
              bottom: bottomSafeArea + 20,
              right: rightSafeArea + 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Move to front button (arrow up)
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.green[400],
                    onPressed: _onMoveToFront,
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                    tooltip: 'Move to front',
                  ),
                  const SizedBox(height: 10),
                  // Flip button
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.blue[400],
                    onPressed: _onFlipItem,
                    child: const Icon(Icons.flip, color: Colors.white),
                    tooltip: 'Flip horizontally',
                  ),
                  const SizedBox(height: 10),
                  // Move to back button (arrow down)
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.orange[400],
                    onPressed: _onMoveToBack,
                    child: const Icon(Icons.arrow_downward, color: Colors.white),
                    tooltip: 'Move to back',
                  ),
                  const SizedBox(height: 10),
                  // Delete button
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.red[400],
                    onPressed: _onDeleteSelectedItem,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ],
              ),
            ),
          // Right-side zoom slider
          if (roomWorld != null && _showDesktopZoomSlider)
            TutorialTarget(
              id: 'room_edit_zoom_slider',
              child: ZoomSlider(
                gameWorld: roomWorld!,
                safeAreaPadding: safeAreaPadding,
              ),
            ),
          TutorialOverlay(currentScreenId: 'room_edit'),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _onConfirmPressed() async {
    if (roomWorld == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final placements = roomWorld!.getCurrentLayout(
      RoomLayoutDatabaseService.defaultRoomId,
    );
    await RoomLayoutDatabaseService.saveRoomLayout(
      RoomLayoutDatabaseService.defaultRoomId,
      placements,
    );
    if (!mounted) return;
    await context.read<TutorialProvider>().registerAction('room_edit_confirm');
    if (!mounted) return;
    // Advance tutorial overlay before pop so post-frame callbacks use a valid context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  void _onDeleteSelectedItem() => roomWorld?.removeSelectedItem();
  void _onMoveToFront() => roomWorld?.moveSelectedItemToFront();
  void _onMoveToBack() => roomWorld?.moveSelectedItemToBack();

  void _onFlipItem() {
    if (roomWorld == null) return;
    roomWorld!.flipSelectedItem();
  }

  void _showRoomComponentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomComponentsSheet(
        onComponentsChanged: () {
          if (roomWorld != null) {
            setState(() => roomWorld!.reloadComponents());
          }
        },
      ),
    );
  }

  // ── Inventory draggable sheet ─────────────────────────────────────────────

  void _showInventorySheet(
      BuildContext context, AppLocalizationsProvider l10n) {
    context
        .read<TutorialProvider>()
        .registerAction('room_edit_open_inventory');
    final placedItemIds = roomWorld?.getPlacedItemIds() ?? {};
    final sk = l10n.currentLanguage == 'sk';
    final items = widget.gameState?.ownedItems ?? [];
    final screenH = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,        // lets us control height freely
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,         // ~60% of screen — room still visible
        minChildSize: 0.18,             // pull down → almost hidden
        maxChildSize: 0.82,             // pull up → nearly full screen
        snap: true,
        snapSizes: const [0.18, 0.42, 0.82],
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: _cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Drag handle ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_rounded,
                          color: _purple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        sk ? 'Inventár' : 'Inventory',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _purple,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: _purple),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(color: _purpleLight, height: 1),

                // ── Grid or empty state ───────────────────────────────────
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 48,
                                  color: _purpleLight),
                              const SizedBox(height: 12),
                              Text(
                                sk
                                    ? 'Zatiaľ žiadne predmety'
                                    : 'No items yet',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isPlaced =
                                placedItemIds.contains(item.id);
                            return _buildItemCard(
                                context, item, isPlaced, l10n);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item, bool isPlaced,
      AppLocalizationsProvider l10n) {
    final sk = l10n.currentLanguage == 'sk';

    return GestureDetector(
      onTap: isPlaced
          ? null
          : () {
              if (roomWorld != null) {
                context
                    .read<TutorialProvider>()
                    .registerAction('place_item_in_room');
                roomWorld!.addItemToRoom(item);
                Navigator.pop(context);
              }
            },
      child: Container(
        decoration: BoxDecoration(
          color: isPlaced ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaced ? Colors.grey.shade300 : _purpleLight,
            width: 1.5,
          ),
          boxShadow: isPlaced
              ? []
              : [
                  BoxShadow(
                    color: _purpleLight.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Opacity(
                      opacity: isPlaced ? 0.45 : 1.0,
                      child: item.texture.isNotEmpty
                          ? Image.asset(item.texture, fit: BoxFit.contain)
                          : Icon(Icons.image_not_supported,
                              size: 28, color: Colors.grey[400]),
                    ),
                  ),
                ),
                // Name
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                  child: Text(
                    item.localizedName(l10n.currentLanguage),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isPlaced ? Colors.grey[500] : _purple,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Type chip
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPlaced
                          ? Colors.grey[300]
                          : _purpleBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.type.toDisplayString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        color: isPlaced ? Colors.grey[600] : _purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // "Placed" overlay
            if (isPlaced)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sk ? 'Umiestnené' : 'Placed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Small helper widgets ────────────────────────────────────────────────────

class _TopButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _BottomFab extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _BottomFab({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
