import '../config/room_components_config.dart';
import '../models/room_component.dart';
import 'room_component_database_service.dart';

/// Handles room component business logic including shop filtering, selection, etc.
class RoomComponentService {
  /// Get room components available for purchase (config components minus owned)
  static Future<List<RoomComponent>> getShopComponents() async {
    final ownedComponents = await RoomComponentDatabaseService.getOwnedComponents();
    final ownedIds = ownedComponents.map((comp) => comp.id).toSet();
    
    // Return config components that are NOT owned
    return ROOM_COMPONENTS.where((comp) => !ownedIds.contains(comp.id)).toList();
  }

  /// Get shop components filtered by type
  static Future<List<RoomComponent>> getShopComponentsByType(
    RoomComponentType type,
  ) async {
    final shopComponents = await getShopComponents();
    return shopComponents.where((comp) => comp.type == type).toList();
  }

  /// Get all owned components
  static Future<List<RoomComponent>> getOwnedComponents() async {
    return await RoomComponentDatabaseService.getOwnedComponents();
  }

  /// Get owned components filtered by type
  static Future<List<RoomComponent>> getOwnedComponentsByType(
    RoomComponentType type,
  ) async {
    return await RoomComponentDatabaseService.getOwnedComponentsByType(type);
  }

  /// Get room component details by ID from config
  static RoomComponent? getComponentById(String componentId) {
    try {
      return ROOM_COMPONENTS.firstWhere((comp) => comp.id == componentId);
    } catch (e) {
      return null;
    }
  }

  /// Get currently selected component for a role ('wall' or 'floor')
  static Future<RoomComponent?> getCurrentComponentForRole(String role) async {
    final componentId =
        await RoomComponentDatabaseService.getSelectedComponentForRole(role);
    
    if (componentId == null) return null;
    
    // Get from owned components
    final ownedComponents = await getOwnedComponents();
    try {
      return ownedComponents.firstWhere((comp) => comp.id == componentId);
    } catch (e) {
      return null;
    }
  }

  /// Select a component for a role ('wall' or 'floor')
  /// The component must be owned first
  static Future<bool> selectComponentForRole(
    String role,
    String componentId,
  ) async {
    // Check if component is owned
    final isOwned =
        await RoomComponentDatabaseService.isComponentOwned(componentId);
    if (!isOwned) {
      print('Cannot select non-owned component: $componentId');
      return false;
    }

    return await RoomComponentDatabaseService.setSelectedComponentForRole(
      role,
      componentId,
    );
  }

  /// Handle component purchase: add to owned components
  static Future<bool> buyComponent(String componentId) async {
    final component = getComponentById(componentId);
    if (component == null) {
      print('Component not found: $componentId');
      return false;
    }

    // Add to owned components in database
    return await RoomComponentDatabaseService.addOwnedComponent(component);
  }

  /// Get owned components of a specific type (walls or floors)
  static Future<List<RoomComponent>> getOwnedWallComponents() async {
    return await getOwnedComponentsByType(RoomComponentType.wall);
  }

  static Future<List<RoomComponent>> getOwnedFloorComponents() async {
    return await getOwnedComponentsByType(RoomComponentType.floor);
  }
}
