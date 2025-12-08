import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../config/backend_config.dart';

class TaskApiService {
  // Backend URL from configuration
  static const String tasksEndpoint = BackendConfig.apiTasksEndpoint;
  
  /// Get all tasks from the backend
  static Future<List<Task>> getAllTasks() async {
    try {
      final response = await http.get(
        Uri.parse(tasksEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((task) => _parseTask(task)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  /// Create a new task on the backend
  static Future<bool> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse(tasksEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'rewardCoins': task.rewardCoins,
          'dueDate': task.dueDate.millisecondsSinceEpoch / 1000.0,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Failed to create task: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  /// Complete a task on the backend
  static Future<bool> completeTask(String taskId) async {
    try {
      final response = await http.put(
        Uri.parse('$tasksEndpoint/$taskId/complete'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to complete task: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }

  /// Delete a task from the backend
  static Future<bool> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$tasksEndpoint/$taskId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete task: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  /// Update a task on the backend
  static Future<bool> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$tasksEndpoint/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'rewardCoins': task.rewardCoins,
          'dueDate': task.dueDate.millisecondsSinceEpoch / 1000.0,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update task: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  /// Parse task from JSON response
  static Task _parseTask(dynamic json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rewardCoins: json['rewardCoins'] ?? 0,
      dueDate: _parseDateFromTimestamp(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  /// Convert Unix timestamp (seconds) to DateTime
  static DateTime _parseDateFromTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) {
        return DateTime.now();
      }
      final double seconds = double.parse(timestamp.toString());
      return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).toInt());
    } catch (e) {
      return DateTime.now();
    }
  }
}
