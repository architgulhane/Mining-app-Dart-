import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_models.dart';
import 'mock_responses_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  bool _useHardcodedResponses = true; // Toggle for instant responses

  String get _baseUrl => '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Health Check
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl${ApiConfig.healthEndpoint}'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check health: $e');
    }
  }

  // Create Session
  Future<ChatSession> createSession({
    String name = 'New Session',
    String customer = ApiConfig.defaultCustomer,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl${ApiConfig.sessionEndpoint}'),
            headers: _headers,
            body: json.encode({
              'name': name,
              'customer': customer,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatSession(
          id: data['session_id'],
          name: data['name'],
          customer: data['customer'],
          createdAt: DateTime.now(),
          messages: [],
        );
      } else {
        throw Exception('Failed to create session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  // Get Session
  Future<ChatSession> getSession(String sessionId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl${ApiConfig.sessionEndpoint}/$sessionId'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return ChatSession.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Session not found');
      } else {
        throw Exception('Failed to get session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  // List Sessions
  Future<List<ChatSession>> listSessions({
    String customer = ApiConfig.defaultCustomer,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl${ApiConfig.sessionsEndpoint}?customer=$customer'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sessions = (data['sessions'] as List)
            .map((s) => ChatSession.fromJson(s))
            .toList();
        return sessions;
      } else {
        throw Exception('Failed to list sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to list sessions: $e');
    }
  }

  // Delete Session
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl${ApiConfig.sessionEndpoint}/$sessionId'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  // Send Chat Message
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    // Check for hardcoded response first (instant reply)
    if (_useHardcodedResponses) {
      final hardcodedResponse = MockResponsesService.getHardcodedResponse(request.message);
      if (hardcodedResponse != null) {
        // Return instant response
        return ChatResponse(
          sessionId: request.sessionId ?? 'mock-session',
          message: ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: hardcodedResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
          success: true,
          timestamp: DateTime.now(),
        );
      }
    }
    
    // Fall back to API call if no hardcoded response found
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl${ApiConfig.chatEndpoint}'),
            headers: _headers,
            body: json.encode(request.toJson()),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return ChatResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Session not found');
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get Suggestions
  Future<List<String>> getSuggestions({
    String customer = ApiConfig.defaultCustomer,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl${ApiConfig.suggestionsEndpoint}?customer=$customer'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['suggestions'] ?? []);
      } else {
        // Return default suggestions if endpoint fails
        return _getDefaultSuggestions();
      }
    } catch (e) {
      // Return default suggestions on error
      return _getDefaultSuggestions();
    }
  }

  List<String> _getDefaultSuggestions() {
    return [
      'What was the average OEE last week?',
      'Show me the downtime pareto chart',
      'Compare shift performance',
      'Top breakdown reasons this month',
      'Show MTBF for all machines',
      'Analyze short stops',
      'Show active vs inactive hours',
      'Machine comparison analysis',
      'Detect data gaps',
      'Export downtime report',
    ];
  }

  // Upload File
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String filename,
    String customer = ApiConfig.defaultCustomer,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl${ApiConfig.uploadEndpoint}'),
      );

      request.fields['customer'] = customer;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse =
          await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
