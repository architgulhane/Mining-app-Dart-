class ApiConfig {
  static const String baseUrl = 'http://10.72.0.58:8000';
  static const String apiPrefix = '/api';
  static const Duration timeout = Duration(seconds: 30);
  
  // Endpoints
  static const String healthEndpoint = '/health';
  static const String chatEndpoint = '/chat';
  static const String sessionEndpoint = '/session';
  static const String sessionsEndpoint = '/sessions';
  static const String suggestionsEndpoint = '/suggestions';
  static const String uploadEndpoint = '/upload';
  
  // Customer ID
  static const String defaultCustomer = 'cognecto';
}
