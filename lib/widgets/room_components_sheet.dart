import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/room_component.dart';
import '../services/room_component_service.dart';
import '../services/app_localizations_provider.dart';

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
      final walls  = await RoomComponentService.getOwnedWallComponents();
      final floors = await RoomComponentService.getOwnedFloorComponents();
      final selWall  = await RoomComponentService.getCurrentComponentForRole('wall');
      final selFloor = await RoomComponentService.getCurrentComponentForRole('floor');
      setState(() {
        _wallComponents  = walls;
        _floorComponents = floors;
        _selectedWall    = selWall;
        _selectedFloor   = selFloor;
        _isLoading       = false;
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
    final l10n     = context.watch<AppLocalizationsProvider>();
    final colors   = context.appColors;
    final language = l10n.currentLanguage;
    final sk       = language == 'sk';

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.18,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: const [0.18, 0.52, 0.82],
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
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
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Icon(Icons.home_work_rounded,
                      color: colors.icon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      sk ? 'Komponenty miestnosti' : 'Room Components',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.icon),
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
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: colors.onSurface,
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
                            Text(sk ? 'Steny' : 'Walls'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.layers_rounded, size: 15),
                            const SizedBox(width: 5),
                            Text(sk ? 'Podlahy' : 'Floors'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Divider(color: colors.border, height: 1),

              // ── Content ──────────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: colors.primary))
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
                            sk
                                ? 'Žiadne stenové komponenty'
                                : 'No wall components owned',
                          ),
                          _buildGrid(
                            context,
                            scrollController,
                            _floorComponents,
                            _selectedFloor,
                            _selectFloor,
                            language,
                            sk
                                ? 'Žiadne podlahové komponenty'
                                : 'No floor components owned',
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
    String emptyText,
  ) {
    if (components.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded,
                size: 48, color: context.appColors.border),
            const SizedBox(height: 12),
            Text(emptyText,
                style:
                    TextStyle(fontSize: 14, color: Colors.grey[500])),
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
        return _buildCard(c, isSelected, () => onSelect(c), language);
      },
    );
  }

  Widget _buildCard(
    RoomComponent component,
    bool isSelected,
    VoidCallback onTap,
    String language,
  ) {
    final sk = language == 'sk';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: isSelected
              ? context.appColors.primarySoft
              : context.appColors.itemSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
              ? context.appColors.primary
              : context.appColors.border,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.appColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: context.appColors.border.withOpacity(0.2),
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
                  color: context.appColors.itemSurfaceMuted,
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
                        color: isSelected
                          ? context.appColors.primary
                          : context.appColors.onSurface,
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
                        color: context.appColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        sk ? 'Vybrané' : 'Selected',
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