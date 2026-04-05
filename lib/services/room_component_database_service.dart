import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../config/room_components_config.dart';
import '../models/room_component.dart';
import 'item_database_service.dart';

class RoomComponentDatabaseService {
  static const String _ownedComponentsTable = 'owned_room_components';
  static const String _selectedComponentsTable = 'room_selected_components';

  // Get database from ItemDatabaseService (shared database connection)
  static Future<Database> get database => ItemDatabaseService.database;

  // Ensures all required tables exist
  static Future<void> ensureTablesExist() async {
    try {
      final db = await database;
      await _createTables(db);
    } catch (e) {
      print('ERROR ensuring room component tables: $e');
      rethrow;
    }
  }

  static Future<void> _createTables(Database db) async {
    try {
      // Create owned_room_components table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_ownedComponentsTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          texture TEXT NOT NULL,
          cost INTEGER NOT NULL
        )
      ''');
      print('✓ Created/verified owned_room_components table');

      // Create room_selected_components table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_selectedComponentsTable (
          role TEXT PRIMARY KEY,
          selected_component_id TEXT NOT NULL,
          FOREIGN KEY(selected_component_id) REFERENCES $_ownedComponentsTable(id)
        )
      ''');
      print('✓ Created/verified room_selected_components table');

      // Initialize default selections if they don't exist
      await _ensureDefaultSelections(db);
    } catch (e) {
      print('ERROR in _createTables: $e');
      rethrow;
    }
  }

  // Ensure default selections exist (after tables are created)
  static Future<void> _ensureDefaultSelections(Database db) async {
    try {
      final wallCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_selectedComponentsTable WHERE role = ?',
        ['wall'],
      );
      
      if ((wallCount[0]['count'] as int) == 0) {
        // No default wall selected, insert placeholder
        await db.insert(
          _selectedComponentsTable,
          {'role': 'wall', 'selected_component_id': 'none'},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      final floorCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_selectedComponentsTable WHERE role = ?',
        ['floor'],
      );
      
      if ((floorCount[0]['count'] as int) == 0) {
        // No default floor selected, insert placeholder
        await db.insert(
          _selectedComponentsTable,
          {'role': 'floor', 'selected_component_id': 'none'},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (e) {
      // Ignore errors for default selections
      print('Note: Could not initialize default selections: $e');
    }
  }

  // Get all owned room components
  static Future<List<RoomComponent>> getOwnedComponents() async {
    try {
      final db = await database;
      await ensureTablesExist();
      final maps = await db.query(_ownedComponentsTable);

      return List.generate(maps.length, (i) {
        return RoomComponent(
          id: maps[i]['id'] as String,
          name: maps[i]['name'] as String,
          type: _stringToComponentType(maps[i]['type'] as String),
          texture: maps[i]['texture'] as String,
          cost: maps[i]['cost'] as int,
        );
      });
    } catch (e) {
      print('Error loading owned room components: $e');
      return [];
    }
  }

  // Get owned components of a specific type
  static Future<List<RoomComponent>> getOwnedComponentsByType(
    RoomComponentType type,
  ) async {
    try {
      final db = await database;
      await ensureTablesExist();
      final maps = await db.query(
        _ownedComponentsTable,
        where: 'type = ?',
        whereArgs: [_componentTypeToString(type)],
      );

      return List.generate(maps.length, (i) {
        return RoomComponent(
          id: maps[i]['id'] as String,
          name: maps[i]['name'] as String,
          type: type,
          texture: maps[i]['texture'] as String,
          cost: maps[i]['cost'] as int,
        );
      });
    } catch (e) {
      print('Error loading owned room components by type: $e');
      return [];
    }
  }

  // Check if component is owned
  static Future<bool> isComponentOwned(String componentId) async {
    try {
      final db = await database;
      await ensureTablesExist();
      final result = await db.query(
        _ownedComponentsTable,
        where: 'id = ?',
        whereArgs: [componentId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking component ownership: $e');
      return false;
    }
  }

  // Add component to owned components
  static Future<bool> addOwnedComponent(RoomComponent component) async {
    try {
      final db = await database;
      await ensureTablesExist();
      await db.insert(
        _ownedComponentsTable,
        {
          'id': component.id,
          'name': component.name,
          'type': _componentTypeToString(component.type),
          'texture': component.texture,
          'cost': component.cost,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✓ Added owned room component: ${component.id}');
      return true;
    } catch (e) {
      print('Error adding owned room component: $e');
      return false;
    }
  }

  // Remove component from owned components
  static Future<bool> removeOwnedComponent(String componentId) async {
    try {
      final db = await database;
      await ensureTablesExist();
      await db.delete(
        _ownedComponentsTable,
        where: 'id = ?',
        whereArgs: [componentId],
      );
      print('✓ Removed owned room component: $componentId');
      return true;
    } catch (e) {
      print('Error removing owned room component: $e');
      return false;
    }
  }

  // Get selected component for a role ('wall' or 'floor')
  static Future<String?> getSelectedComponentForRole(String role) async {
    try {
      final db = await database;
      await ensureTablesExist();
      final result = await db.query(
        _selectedComponentsTable,
        where: 'role = ?',
        whereArgs: [role],
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        final componentId = result[0]['selected_component_id'] as String;
        // Return null if it's the placeholder
        return componentId == 'none' ? null : componentId;
      }
      return null;
    } catch (e) {
      print('Error getting selected component for role $role: $e');
      return null;
    }
  }

  // Set selected component for a role
  static Future<bool> setSelectedComponentForRole(
    String role,
    String componentId,
  ) async {
    try {
      final db = await database;
      await ensureTablesExist();
      
      await db.update(
        _selectedComponentsTable,
        {'selected_component_id': componentId},
        where: 'role = ?',
        whereArgs: [role],
      );
      
      print('✓ Set selected component for role $role: $componentId');
      return true;
    } catch (e) {
      print('Error setting selected component for role $role: $e');
      return false;
    }
  }

  // Clear all owned components (for testing)
  static Future<bool> clearAllOwnedComponents() async {
    try {
      final db = await database;
      await ensureTablesExist();
      await db.delete(_ownedComponentsTable);
      print('Cleared all owned room components from database');
      return true;
    } catch (e) {
      print('Error clearing owned room components: $e');
      return false;
    }
  }

  /// Ensure default components (wall_basic, floor_basic) are always owned
  /// Call this when the app starts to guarantee defaults exist
  static Future<bool> ensureDefaultComponentsOwned() async {
    try {
      final db = await database;
      await ensureTablesExist();

      // Import default components config
      const defaultWall = 'wall_basic';
      const defaultFloor = 'floor_basic';

      // Check if wall_basic exists, if not add it
      final wallExists = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_ownedComponentsTable WHERE id = ?',
        [defaultWall],
      );

      if ((wallExists[0]['count'] as int) == 0) {
        await db.insert(
          _ownedComponentsTable,
          {
            'id': defaultWall,
            'name': 'Basic Wall',
            'type': 'wall',
            'texture': 'room/basic_right_wall.png',
            'cost': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('✓ Added default wall_basic to owned components');
      }

      // Check if floor_basic exists, if not add it
      final floorExists = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_ownedComponentsTable WHERE id = ?',
        [defaultFloor],
      );

      if ((floorExists[0]['count'] as int) == 0) {
        await db.insert(
          _ownedComponentsTable,
          {
            'id': defaultFloor,
            'name': 'Basic Floor',
            'type': 'floor',
            'texture': 'room/basic_floor.png',
            'cost': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        print('✓ Added default floor_basic to owned components');
      }

      // Ensure default selections are set
      final wallSelection = await getSelectedComponentForRole('wall');
      if (wallSelection == null || wallSelection == 'none') {
        await setSelectedComponentForRole('wall', defaultWall);
        print('✓ Set default wall selection to wall_basic');
      }

      final floorSelection = await getSelectedComponentForRole('floor');
      if (floorSelection == null || floorSelection == 'none') {
        await setSelectedComponentForRole('floor', defaultFloor);
        print('✓ Set default floor selection to floor_basic');
      }

      return true;
    } catch (e) {
      print('Error ensuring default components: $e');
      return false;
    }
  }

  /// [floor_ruined1] / [floor_ruined2] — zničená podlaha — granted like starter furniture.
  static const List<String> _starterRuinedFloorIds = [
    'floor_ruined1',
    'floor_ruined2',
  ];

  /// Ensures ruined starter floors from config are in [owned_room_components].
  static Future<void> ensureStarterRuinedFloorsOwned() async {
    try {
      await ensureTablesExist();
      for (final id in _starterRuinedFloorIds) {
        if (await isComponentOwned(id)) continue;

        RoomComponent? comp;
        try {
          comp = ROOM_COMPONENTS.firstWhere((c) => c.id == id);
        } catch (_) {
          continue;
        }

        await addOwnedComponent(comp);
      }
    } catch (e) {
      print('Error ensuring starter ruined floors: $e');
    }
  }

  // Helper methods
  static String _componentTypeToString(RoomComponentType type) {
    return type.toString().split('.').last;
  }

  static RoomComponentType _stringToComponentType(String typeString) {
    return RoomComponentType.values.firstWhere(
      (type) => type.toString().split('.').last == typeString,
      orElse: () => RoomComponentType.wall,
    );
  }
}

