import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_component.dart';
import '../services/room_component_service.dart';
import '../services/app_localizations_provider.dart';

// App colour constants — same as room_edit_screen.dart
const _purple = Color(0xFF6B5B8C);
const _purpleLight = Color(0xFFB8A8D8);
const _purpleBg = Color(0xFFE8D4F0);
const _cream = Color(0xFFFFFBF5);

class RoomComponentsSheet extends StatefulWidget {
  final VoidCallback onComponentsChanged;

  const RoomComponentsSheet({
    super.key,
    required this.onComponentsChanged,
  });

  @override
  State<RoomComponentsSheet> createState() => _RoomComponentsSheetState();
}

class _RoomComponentsSheetState extends State<RoomComponentsSheet>
    with SingleTickerProviderStateMixin {
  List<RoomComponent> _wallComponents = [];
  List<RoomComponent> _floorComponents = [];
  RoomComponent? _selectedWall;
  RoomComponent? _selectedFloor;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadComponents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadComponents() async {
    try {
      final walls = await RoomComponentService.getOwnedWallComponents();
      final floors = await RoomComponentService.getOwnedFloorComponents();
      final selWall =
          await RoomComponentService.getCurrentComponentForRole('wall');
      final selFloor =
          await RoomComponentService.getCurrentComponentForRole('floor');
      setState(() {
        _wallComponents = walls;
        _floorComponents = floors;
        _selectedWall = selWall;
        _selectedFloor = selFloor;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading room components: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectWall(RoomComponent c) async {
    final ok = await RoomComponentService.selectComponentForRole('wall', c.id);
    if (ok) {
      setState(() => _selectedWall = c);
      widget.onComponentsChanged();
    }
  }

  Future<void> _selectFloor(RoomComponent c) async {
    final ok = await RoomComponentService.selectComponentForRole('floor', c.id);
    if (ok) {
      setState(() => _selectedFloor = c);
      widget.onComponentsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final language = l10n.currentLanguage;

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.18,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: const [0.18, 0.52, 0.82],
      expand: false,
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
              // ── Drag handle ──────────────────────────────────────────────
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

              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    const Icon(Icons.home_work_rounded,
                        color: _purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('roomComponents'),
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

              // ── Tab bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: _purpleBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: _purple,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.format_paint_rounded, size: 15),
                            const SizedBox(width: 5),
                            Text(l10n.translate('wallsCategory')),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.layers_rounded, size: 15),
                            const SizedBox(width: 5),
                            Text(l10n.translate('floorsCategory')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(color: _purpleLight, height: 1),

              // ── Content ──────────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _purple))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGrid(
                            context,
                            scrollController,
                            _wallComponents,
                            _selectedWall,
                            _selectWall,
                            language,
                            l10n,
                            l10n.translate('noWallComponentsOwned'),
                          ),
                          _buildGrid(
                            context,
                            scrollController,
                            _floorComponents,
                            _selectedFloor,
                            _selectFloor,
                            language,
                            l10n,
                            l10n.translate('noFloorComponentsOwned'),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    ScrollController scrollController,
    List<RoomComponent> components,
    RoomComponent? selected,
    Future<void> Function(RoomComponent) onSelect,
    String language,
    AppLocalizationsProvider l10n,
    String emptyText,
  ) {
    if (components.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded,
                size: 48, color: _purpleLight),
            const SizedBox(height: 12),
            Text(emptyText,
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    final crossAxisCount =
        (MediaQuery.of(context).size.width / 130).floor().clamp(3, 6);

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemCount: components.length,
      itemBuilder: (context, index) {
        final c = components[index];
        final isSelected = selected?.id == c.id;
        return _buildCard(c, isSelected, () => onSelect(c), language, l10n);
      },
    );
  }

  Widget _buildCard(
    RoomComponent component,
    bool isSelected,
    VoidCallback onTap,
    String language,
    AppLocalizationsProvider l10n,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _purpleBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _purple : _purpleLight,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _purple.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: _purpleLight.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    component.texture,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            // Name + badge
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 4, 5, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    component.localizedName(language),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _purple : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: _purple,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        l10n.translate('selected'),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
