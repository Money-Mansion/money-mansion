import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../screens/category.dart';
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
const _purple = Color(0xFF6B5B8C);
const _purpleLight = Color(0xFFB8A8D8);
const _purpleBg = Color(0xFFE8D4F0);
const _cream = Color(0xFFFFFBF5);

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
          if (_hasSelectedItem)
            Positioned(
              bottom: bottomSafeArea + 20,
              right: rightSafeArea + 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.green[400],
                    onPressed: _onMoveToFront,
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                    tooltip: 'Move to front',
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.blue[400],
                    onPressed: _onFlipItem,
                    child: const Icon(Icons.flip, color: Colors.white),
                    tooltip: 'Flip horizontally',
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.orange[400],
                    onPressed: _onMoveToBack,
                    child:
                        const Icon(Icons.arrow_downward, color: Colors.white),
                    tooltip: 'Move to back',
                  ),
                  const SizedBox(height: 10),
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

  // ── Inventory draggable sheet with category tabs ──────────────────────────

  void _showInventorySheet(
      BuildContext context, AppLocalizationsProvider l10n) {
    context.read<TutorialProvider>().registerAction('room_edit_open_inventory');

    final placedItemCounts =
        roomWorld?.getPlacedItemCounts() ?? <String, int>{};
    final items = widget.gameState?.ownedItems ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InventorySheet(
        items: items,
        placedItemCounts: placedItemCounts,
        l10n: l10n,
        onItemTap: (Item item) {
          if (roomWorld != null) {
            context
                .read<TutorialProvider>()
                .registerAction('place_item_in_room');
            roomWorld!.addItemToRoom(item);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

// ── Inventory sheet with full tab bar ────────────────────────────────────────

class _InventorySheet extends StatefulWidget {
  final List<Item> items;
  final Map<String, int> placedItemCounts;
  final AppLocalizationsProvider l10n;
  final void Function(Item) onItemTap;

  const _InventorySheet({
    required this.items,
    required this.placedItemCounts,
    required this.l10n,
    required this.onItemTap,
  });

  @override
  State<_InventorySheet> createState() => _InventorySheetState();
}

class _InventorySheetState extends State<_InventorySheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Category> _categories = [
    Category(labelKey: 'all'),
    Category(labelKey: 'beds', itemSubtype: ItemSubtype.beds),
    Category(labelKey: 'seating', itemSubtype: ItemSubtype.seating),
    Category(labelKey: 'tables', itemSubtype: ItemSubtype.tables),
    Category(labelKey: 'storage', itemSubtype: ItemSubtype.storage),
    Category(labelKey: 'carpets', itemSubtype: ItemSubtype.carpets),
    Category(labelKey: 'wallDecor', itemSubtype: ItemSubtype.wallDecor),
    Category(labelKey: 'plants', itemSubtype: ItemSubtype.plants),
    Category(labelKey: 'lighting', itemSubtype: ItemSubtype.lighting),
    Category(labelKey: 'doors', itemType: ItemType.door),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _matchesSubtype(Item item, ItemSubtype subtype) {
    final id = item.id;
    switch (subtype) {
      case ItemSubtype.beds:
        return id.startsWith('postel_') ||
            id.startsWith('posteľ_') ||
            id == 'postel_znicena';
      case ItemSubtype.seating:
        return id.startsWith('gauc_');
      case ItemSubtype.tables:
        return id.startsWith('stol_');
      case ItemSubtype.storage:
        return id.startsWith('polica') ||
            id.startsWith('police') ||
            id.startsWith('skriňa') ||
            id.startsWith('skrina') ||
            id == 'polica_kniznica_cierna';
      case ItemSubtype.carpets:
        return id.startsWith('koberec_');
      case ItemSubtype.wallDecor:
        return id.startsWith('obraz_') ||
            id.startsWith('okno_') ||
            id == 'okno_zrkadlo';
      case ItemSubtype.plants:
        return id.startsWith('kvietok_');
      case ItemSubtype.lighting:
        return id.startsWith('lampa_') || id.startsWith('svetlo_');
    }
  }

  List<Item> _itemsForCategory(Category category) {
    if (category.labelKey == 'all') return widget.items;

    if (category.itemSubtype != null) {
      return widget.items
          .where((i) => _matchesSubtype(i, category.itemSubtype!))
          .toList();
    }

    if (category.itemType != null) {
      return widget.items.where((i) => i.type == category.itemType).toList();
    }

    return [];
  }

  IconData _categoryIcon(String labelKey) {
    switch (labelKey) {
      case 'all':
        return Icons.grid_view;
      case 'beds':
        return Icons.bed;
      case 'seating':
        return Icons.chair;
      case 'tables':
        return Icons.table_restaurant;
      case 'storage':
        return Icons.shelves;
      case 'carpets':
        return Icons.square_foot;
      case 'wallDecor':
        return Icons.image;
      case 'plants':
        return Icons.local_florist;
      case 'lighting':
        return Icons.lightbulb_outline;
      case 'doors':
        return Icons.door_front_door;
      default:
        return Icons.grid_view;
    }
  }

  String _categoryLabel(String key) {
    final isSk = widget.l10n.currentLanguage == 'sk';
    switch (key) {
      case 'all':
        return isSk ? 'Všetko' : 'All';
      case 'beds':
        return isSk ? 'Postele' : 'Beds';
      case 'seating':
        return isSk ? 'Posedenie' : 'Seating';
      case 'tables':
        return isSk ? 'Stoly' : 'Tables';
      case 'storage':
        return isSk ? 'Úložný priestor' : 'Storage';
      case 'carpets':
        return isSk ? 'Koberce' : 'Carpets';
      case 'wallDecor':
        return isSk ? 'Steny' : 'Wall Decor';
      case 'plants':
        return isSk ? 'Rastliny' : 'Plants';
      case 'lighting':
        return isSk ? 'Svetlá' : 'Lighting';
      case 'doors':
        return isSk ? 'Dvere' : 'Doors';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sk = widget.l10n.currentLanguage == 'sk';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.18,
      maxChildSize: 0.82,
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
              // ── Drag handle ────────────────────────────────────────
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

              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
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
                      icon: const Icon(Icons.close_rounded, color: _purple),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ── Tab bar with scroll arrows ─────────────────────────
              _SheetTabBar(
                tabController: _tabController,
                categories: _categories,
                itemsForCategory: _itemsForCategory,
                categoryIcon: _categoryIcon,
                categoryLabel: _categoryLabel,
                sheetColor: _cream,
                accentColor: _purple,
                accentLight: _purpleLight,
              ),

              const Divider(color: _purpleLight, height: 1),

              // ── Tab content ────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _categories.map((cat) {
                    final items = _itemsForCategory(cat);
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 40, color: _purpleLight),
                            const SizedBox(height: 10),
                            Text(
                              sk ? 'Zatiaľ žiadne predmety' : 'No items yet',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
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
                        final placedCount =
                            widget.placedItemCounts[item.id] ?? 0;
                        return _buildItemCard(item, placedCount);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(Item item, int placedCount) {
    final sk = widget.l10n.currentLanguage == 'sk';
    final maxCount = item.quantity > 0 ? item.quantity : 1;
    final shownPlacedCount = placedCount > maxCount ? maxCount : placedCount;
    final isFullyPlaced = shownPlacedCount >= maxCount;

    return GestureDetector(
      onTap: isFullyPlaced ? null : () => widget.onItemTap(item),
      child: Container(
        decoration: BoxDecoration(
          color: isFullyPlaced ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFullyPlaced ? Colors.grey.shade300 : _purpleLight,
            width: 1.5,
          ),
          boxShadow: isFullyPlaced
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Opacity(
                      opacity: isFullyPlaced ? 0.45 : 1.0,
                      child: item.texture.isNotEmpty
                          ? Image.asset(item.texture, fit: BoxFit.contain)
                          : Icon(Icons.image_not_supported,
                              size: 28, color: Colors.grey[400]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
                  child: Text(
                    item.localizedName(widget.l10n.currentLanguage),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isFullyPlaced ? Colors.grey[500] : _purple,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFullyPlaced ? Colors.grey[300] : _purpleBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.type.toLocalizedDisplayString(widget.l10n.currentLanguage),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        color: isFullyPlaced ? Colors.grey[600] : _purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: Text(
                    '${widget.l10n.translate('placed')}: $shownPlacedCount/$maxCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: isFullyPlaced ? Colors.grey[600] : _purple,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isFullyPlaced ? Colors.grey[500] : _purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'x$maxCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isFullyPlaced)
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

// ── Sheet tab bar with scroll arrows ─────────────────────────────────────────

class _SheetTabBar extends StatefulWidget {
  const _SheetTabBar({
    required this.tabController,
    required this.categories,
    required this.itemsForCategory,
    required this.categoryIcon,
    required this.categoryLabel,
    required this.sheetColor,
    required this.accentColor,
    required this.accentLight,
  });

  final TabController tabController;
  final List<Category> categories;
  final List<Item> Function(Category) itemsForCategory;
  final IconData Function(String) categoryIcon;
  final String Function(String) categoryLabel;
  final Color sheetColor;
  final Color accentColor;
  final Color accentLight;

  @override
  State<_SheetTabBar> createState() => _SheetTabBarState();
}

class _SheetTabBarState extends State<_SheetTabBar> {
  late final ScrollController _sc;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
    _sc.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _onScroll();
      });
    });
  }

  @override
  void dispose() {
    _sc.removeListener(_onScroll);
    _sc.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_sc.hasClients) return;
    final pos = _sc.position;
    final left = pos.pixels > 2;
    final right = pos.pixels < pos.maxScrollExtent - 2;
    if (left != _canScrollLeft || right != _canScrollRight) {
      if (mounted) {
        setState(() {
          _canScrollLeft = left;
          _canScrollRight = right;
        });
      }
    }
  }

  void _scroll(double delta) {
    if (!_sc.hasClients) return;
    _sc.animateTo(
      (_sc.offset + delta).clamp(
        _sc.position.minScrollExtent,
        _sc.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Stack(
        children: [
          PrimaryScrollController(
            controller: _sc,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollUpdateNotification ||
                    n is ScrollEndNotification) {
                  final m = n.metrics;
                  final left = m.pixels > 2;
                  final right = m.pixels < m.maxScrollExtent - 2;
                  if (left != _canScrollLeft || right != _canScrollRight) {
                    if (mounted) {
                      setState(() {
                        _canScrollLeft = left;
                        _canScrollRight = right;
                      });
                    }
                  }
                }
                return false;
              },
              child: TabBar(
                controller: widget.tabController,
                isScrollable: true,
                labelColor: widget.accentColor,
                unselectedLabelColor: Colors.grey[500],
                indicatorColor: widget.accentColor,
                indicatorWeight: 2,
                dividerColor: widget.accentLight,
                tabs: widget.categories.map((cat) {
                  final count = widget.itemsForCategory(cat).length;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.categoryIcon(cat.labelKey), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.categoryLabel(cat.labelKey),
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: widget.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Left arrow — always visible, dims when at the start
          _SheetEdgeButton(
            isLeft: true,
            bg: widget.sheetColor,
            color: _canScrollLeft
                ? widget.accentColor
                : widget.accentColor.withOpacity(0.25),
            onTap: () => _scroll(-160),
          ),

          // Right arrow — always visible, dims when at the end
          _SheetEdgeButton(
            isLeft: false,
            bg: widget.sheetColor,
            color: _canScrollRight
                ? widget.accentColor
                : widget.accentColor.withOpacity(0.25),
            onTap: () => _scroll(160),
          ),
        ],
      ),
    );
  }
}

class _SheetEdgeButton extends StatelessWidget {
  const _SheetEdgeButton({
    required this.isLeft,
    required this.bg,
    required this.color,
    required this.onTap,
  });

  final bool isLeft;
  final Color bg;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [bg, bg.withOpacity(0.0)],
              stops: const [0.55, 1.0],
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────────

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