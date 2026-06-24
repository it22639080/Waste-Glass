class ApiConstants {
  ApiConstants._();

  // Android emulator local backend:
  // static const String baseUrl = 'http://10.0.2.2:5000';
  //
  // Physical device on same Wi-Fi:
  // static const String baseUrl = 'http://YOUR_PC_IP:5000';
  //
  // Hosted deployment:
  // static const String baseUrl = 'https://your-waste-glass-api.onrender.com';
  static const String baseUrl = 'http://192.168.8.197:5000';

  static const String todayTrip = '/api/trips/today';
  static const String suppliers = '/api/suppliers';
  static const String collections = '/api/collections';
  static const String syncCollections = '/api/collections/sync';

  static String tripReport(int tripId) => '/api/trips/$tripId/report';
}
