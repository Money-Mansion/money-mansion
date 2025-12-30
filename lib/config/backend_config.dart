/// Backend Configuration (DEPRECATED - App now uses local SQLite database)
/// This file is kept for reference only and is no longer used.

class BackendConfig {
  // ==============================================
  // NOTE: Backend URLs below are no longer used
  // The app now uses local SQLite database
  // ==============================================
  
  // Option 1: Android Emulator (most common)
  // static const String backendUrl = 'http://10.0.2.2:5000';
  
  // Option 2: Physical device on same WiFi
  // Get your PC's IP: Windows cmd > ipconfig
  // Then use: static const String backendUrl = 'http://192.168.X.X:5000';
  
  // Option 3: iOS Simulator
  // static const String backendUrl = 'http://localhost:5000';
  
  // Option 4: Windows Desktop
  static const String backendUrl = 'http://localhost:5000';
  
  // API endpoint (DEPRECATED)
  static const String apiTasksEndpoint = '$backendUrl/api/tasks';
  static const String apiGameStateEndpoint = '$backendUrl/api/game/state';
}
