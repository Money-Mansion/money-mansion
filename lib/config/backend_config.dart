/// Backend Configuration
/// Change this based on your setup

class BackendConfig {
  // ==============================================
  // CONFIGURE YOUR BACKEND URL HERE
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
  
  // Currently using - CHANGE THIS TO YOUR SETUP
  // static const String backendUrl = 'http://10.0.2.2:5000';
  
  // API endpoint
  static const String apiTasksEndpoint = '$backendUrl/api/tasks';
  static const String apiGameStateEndpoint = '$backendUrl/api/game/state';
}
