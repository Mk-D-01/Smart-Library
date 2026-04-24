class ApiConfig {
  // BASE URLs
  static const String baseUrl = 'http://172.28.192.1:3000/api';
  
  // For Android Emulator, use: http://10.0.2.2:3000/api
  // For iOS Simulator, use: http://localhost:3000/api
  // For Physical Device, use: http://172.28.192.1:3000/api
  
  // ENDPOINTS
  static const String status = '/status';
  static const String scan = '/scan';
  static const String studentsInside = '/students-inside';
  static const String scanLogs = '/scan-logs';
  static const String seats = '/seats';
  static const String reset = '/reset';
  static const String health = '/health';
  
  // SETTINGS
  static const Duration timeout = Duration(seconds: 10);
  static const Duration refreshInterval = Duration(seconds: 5);
  
  // ADMIN CREDENTIALS (Simple for demo - enhance later)
  static const String adminId = 'ADMIN';
  static const String adminPassword = 'admin123'; // Optional
}
