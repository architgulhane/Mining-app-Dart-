import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Backend integration service for file upload and analysis
class BackendApiService {
  static final BackendApiService _instance = BackendApiService._internal();
  factory BackendApiService() => _instance;
  BackendApiService._internal();

  final http.Client _client = http.Client();

  String get _baseUrl => '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Check if backend is available
  Future<bool> isBackendAvailable() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('[Backend] Not available: $e');
      return false;
    }
  }

  /// Upload file to backend for analysis
  Future<Map<String, dynamic>?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    String customer = 'cognecto',
  }) async {
    try {
      print('[Backend] Uploading file: $fileName');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );

      request.fields['customer'] = customer;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
      );
      
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('[Backend] Upload successful: ${result['message']}');
        return result;
      } else {
        print('[Backend] Upload failed: ${response.statusCode}');
        print('[Backend] Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[Backend] Upload error: $e');
      return null;
    }
  }

  /// Send chat message to backend
  Future<Map<String, dynamic>?> sendChatMessage({
    required String message,
    String? sessionId,
    String customer = 'cognecto',
  }) async {
    try {
      print('[Backend] Sending chat message');
      
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: _headers,
            body: json.encode({
              'message': message,
              'session_id': sessionId,
              'customer': customer,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('[Backend] Chat response received');
        return result;
      } else {
        print('[Backend] Chat failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[Backend] Chat error: $e');
      return null;
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>?> getDatabaseStats({
    String customer = 'cognecto',
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/database-stats?customer=$customer'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('[Backend] Database stats error: $e');
      return null;
    }
  }

  /// Get suggested prompts
  Future<List<Map<String, dynamic>>?> getSuggestedPrompts() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/suggested-prompts'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return List<Map<String, dynamic>>.from(result['prompts'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      print('[Backend] Suggested prompts error: $e');
      return null;
    }
  }

  /// Get dataset information
  Future<Map<String, dynamic>?> getDatasetInfo({
    String customer = 'cognecto',
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/dataset-info?customer=$customer'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('[Backend] Dataset info error: $e');
      return null;
    }
  }

  /// Create a new chat session
  Future<Map<String, dynamic>?> createSession({
    String name = 'New Session',
    String customer = 'cognecto',
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/session'),
            headers: _headers,
            body: json.encode({
              'name': name,
              'customer': customer,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('[Backend] Create session error: $e');
      return null;
    }
  }

  /// Get session by ID
  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/session/$sessionId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('[Backend] Get session error: $e');
      return null;
    }
  }

  /// List all sessions
  Future<List<Map<String, dynamic>>?> listSessions({
    String customer = 'cognecto',
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/sessions?customer=$customer'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return List<Map<String, dynamic>>.from(result['sessions'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      print('[Backend] List sessions error: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
