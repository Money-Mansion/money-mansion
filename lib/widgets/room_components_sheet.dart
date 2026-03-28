import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _RoomComponentsSheetState extends State<RoomComponentsSheet> {
  List<RoomComponent> _wallComponents = [];
  List<RoomComponent> _floorComponents = [];
  RoomComponent? _selectedWall;
  RoomComponent? _selectedFloor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    try {
      final wallComponents = await RoomComponentService.getOwnedWallComponents();
      final floorComponents = await RoomComponentService.getOwnedFloorComponents();
      final selectedWall = await RoomComponentService.getCurrentComponentForRole('wall');
      final selectedFloor = await RoomComponentService.getCurrentComponentForRole('floor');

      setState(() {
        _wallComponents = wallComponents;
        _floorComponents = floorComponents;
        _selectedWall = selectedWall;
        _selectedFloor = selectedFloor;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading room components: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectWall(RoomComponent component) async {
    final success = await RoomComponentService.selectComponentForRole('wall', component.id);
    if (success) {
      setState(() {
        _selectedWall = component;
      });
      widget.onComponentsChanged();
    }
  }

  Future<void> _selectFloor(RoomComponent component) async {
    final success = await RoomComponentService.selectComponentForRole('floor', component.id);
    if (success) {
      setState(() {
        _selectedFloor = component;
      });
      widget.onComponentsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<AppLocalizationsProvider>();
    final language = l10n.currentLanguage;

    if (_isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language == 'sk' ? 'Komponenty miestnosti' : 'Room Components',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Walls Section
                    Text(
                      language == 'sk' ? 'Steny' : 'Walls',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_wallComponents.isEmpty)
                      Text(
                        language == 'sk'
                            ? 'Vlastníš žiadne stenové komponenty'
                            : 'You own no wall components',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _wallComponents.length,
                        itemBuilder: (context, index) {
                          final component = _wallComponents[index];
                          final isSelected =
                              _selectedWall?.id == component.id;
                          return _buildComponentCard(
                            component,
                            isSelected,
                            () => _selectWall(component),
                            language,
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    // Floors Section
                    Text(
                      language == 'sk' ? 'Podlahy' : 'Floors',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_floorComponents.isEmpty)
                      Text(
                        language == 'sk'
                            ? 'Vlastníš žiadne podlahové komponenty'
                            : 'You own no floor components',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _floorComponents.length,
                        itemBuilder: (context, index) {
                          final component = _floorComponents[index];
                          final isSelected =
                              _selectedFloor?.id == component.id;
                          return _buildComponentCard(
                            component,
                            isSelected,
                            () => _selectFloor(component),
                            language,
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard(
    RoomComponent component,
    bool isSelected,
    VoidCallback onTap,
    String language,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? const BorderSide(color: Colors.deepPurple, width: 3)
              : BorderSide.none,
        ),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.deepPurple.withOpacity(0.05),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image area
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      component.texture,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.localizedName(language),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          language == 'sk' ? 'Vybrané' : 'Selected',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
