import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../services/app_localizations_provider.dart';
import '../services/room_layout_database_service.dart';
import '../widgets/room_viewer.dart';
import '../widgets/room_components_sheet.dart';
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

          // ── Top-left: confirm / cancel ────────────────────────────────────
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              children: [
                _TopButton(
                  icon: Icons.check_rounded,
                  color: Colors.purple.shade300,
                  tooltip: sk ? 'Uložiť' : 'Save',
                  onTap: _onConfirmPressed,
                ),
                const SizedBox(width: 8),
                _TopButton(
                  icon: Icons.close_rounded,
                  color: Colors.pink.shade300,
                  tooltip: sk ? 'Zrušiť' : 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Bottom-left: room components + inventory ──────────────────────
          Positioned(
            bottom: 24,
            left: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BottomFab(
                  icon: Icons.home_work_rounded,
                  color: Colors.amber.shade400,
                  tooltip: sk ? 'Komponenty izby' : 'Room components',
                  onTap: () => _showRoomComponentsSheet(context),
                ),
                const SizedBox(height: 10),
                _BottomFab(
                  icon: Icons.inventory_2_rounded,
                  color: _purpleLight,
                  tooltip: sk ? 'Inventár' : 'Inventory',
                  onTap: () => _showInventorySheet(context, l10n),
                ),
              ],
            ),
          ),

          // ── Centre-bottom: item action bar (shown when item selected) ─────
          if (_hasSelectedItem)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(30),
                    border:
                        Border.all(color: _purpleLight, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _purpleLight.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.arrow_upward_rounded,
                        color: Colors.green.shade400,
                        tooltip: sk ? 'Do popredia' : 'Bring to front',
                        onTap: _onMoveToFront,
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        icon: Icons.delete_rounded,
                        color: Colors.red.shade400,
                        tooltip: sk ? 'Odstrániť' : 'Delete',
                        onTap: _onDeleteSelectedItem,
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        icon: Icons.arrow_downward_rounded,
                        color: Colors.orange.shade400,
                        tooltip: sk ? 'Do pozadia' : 'Send to back',
                        onTap: _onMoveToBack,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    if (mounted) Navigator.pop(context);
  }

  void _onDeleteSelectedItem() => roomWorld?.removeSelectedItem();
  void _onMoveToFront() => roomWorld?.moveSelectedItemToFront();
  void _onMoveToBack() => roomWorld?.moveSelectedItemToBack();

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