import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'csv_context_manager.dart';

/// Service for CogniSarthi Backend API Integration
/// Handles communication with FastAPI backend
/// Supports dual mode: CSV context queries + Backend database queries
class CogniSarthiBackendService {
  static final CogniSarthiBackendService _instance = CogniSarthiBackendService._internal();
  factory CogniSarthiBackendService() => _instance;
  CogniSarthiBackendService._internal();

  final http.Client _client = http.Client();
  
  // Read backend URL from environment variable
  String get _baseUrl {
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
    return '$apiBaseUrl/api';
  }
  
  String? _currentSessionId;
  
  // CSV Context Manager for dual-mode operation
  final CsvContextManager _csvContextManager = CsvContextManager();
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Check if backend is available
  Future<bool> checkBackendHealth() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('[CogniSarthi Backend] ✅ Backend is healthy');
        return true;
      }
      return false;
    } catch (e) {
      print('[CogniSarthi Backend] ❌ Backend not available: $e');
      return false;
    }
  }

  /// Check if CSV context is available
  bool get hasCsvContext => _csvContextManager.hasCsvContext;

  /// Get current CSV file name
  String? get currentCsvFileName => _csvContextManager.currentFileName;

  /// Upload CSV file and create context
  /// After this, all queries will be answered from CSV context
  Future<Map<String, dynamic>> uploadCsvFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    print('[CogniSarthi Backend] 📤 Uploading CSV file: $fileName');
    
    final result = await _csvContextManager.loadCsvFile(
      fileBytes: fileBytes,
      fileName: fileName,
    );

    if (result['success'] == true) {
      print('[CogniSarthi Backend] ✅ CSV context created');
      print('[CogniSarthi Backend] File: $fileName');
      print('[CogniSarthi Backend] Rows: ${result['metadata']['rowCount']}');
    }

    return result;
  }

  /// Clear CSV context and return to backend queries
  void clearCsvContext() {
    _csvContextManager.clearContext();
    print('[CogniSarthi Backend] 🔄 CSV context cleared, back to backend mode');
  }

  /// Get CSV metadata
  Map<String, dynamic>? getCsvMetadata() {
    return _csvContextManager.csvMetadata;
  }

  /// Send message - DUAL MODE: Routes to CSV context OR backend
  /// 
  /// **MODE 1: CSV Context** (if CSV uploaded)
  /// - Query CSV data using Gemini API
  /// - Data stays in memory, fast responses
  /// 
  /// **MODE 2: Backend Database** (default)
  /// - Query backend database via POST /api/chat
  /// - Returns SQL results and analysis
  Future<Map<String, dynamic>?> sendMessage({
    required String message,
    String? sessionId,
    String customer = 'cognecto',
  }) async {
    // Check if we have CSV context
    if (_csvContextManager.hasCsvContext) {
      print('[CogniSarthi Backend] 📊 Using CSV context mode');
      return await _queryCsvContext(message);
    } else {
      print('[CogniSarthi Backend] 🌐 Using backend mode');
      return await sendChatMessage(
        message: message,
        sessionId: sessionId,
        customer: customer,
      );
    }
  }

  /// Query CSV context using Gemini API
  Future<Map<String, dynamic>?> _queryCsvContext(String message) async {
    try {
      final result = await _csvContextManager.queryCsvData(message);

      if (result['success'] == true) {
        return {
          'session_id': 'csv_context_${DateTime.now().millisecondsSinceEpoch}',
          'response': {
            'role': 'assistant',
            'content': result['response'],
            'timestamp': result['timestamp'],
            'metadata': {
              'source': 'csv_context',
              'fileName': result['fileName'],
              'intent': {'type': 'csv_query'},
            }
          },
          'success': true,
          'timestamp': result['timestamp'],
        };
      }

      return result;
    } catch (e) {
      print('[CogniSarthi Backend] ❌ CSV query error: $e');
      return {
        'success': false,
        'error': 'Failed to query CSV: $e',
      };
    }
  }

  /// Send chat message to backend and get response
  /// (Original method - kept for backward compatibility)
  /// 
  /// Request format:
  /// ```json
  /// {
  ///   "message": "shift",
  ///   "customer": "cognecto"
  /// }
  /// ```
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "session_id": "...",
  ///   "response": {
  ///     "role": "assistant",
  ///     "content": "...",
  ///     "timestamp": "...",
  ///     "metadata": {
  ///       "sql_query": "...",
  ///       "chart_type": "bar",
  ///       "data": [...],
  ///       "row_count": 3,
  ///       "intent": {...}
  ///     }
  ///   },
  ///   "success": true,
  ///   "timestamp": "..."
  /// }
  /// ```
  Future<Map<String, dynamic>?> sendChatMessage({
    required String message,
    String? sessionId,
    String customer = 'cognecto',
  }) async {
    try {
      print('[CogniSarthi Backend] 📤 Sending message: $message');
      
      final requestBody = <String, dynamic>{
        'message': message,
        'customer': customer,
      };
      
      // Add session_id if available
      final effectiveSessionId = sessionId ?? _currentSessionId;
      if (effectiveSessionId != null) {
        requestBody['session_id'] = effectiveSessionId;
      }
      
      print('[CogniSarthi Backend] Request body: ${json.encode(requestBody)}');
      
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: _headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('[CogniSarthi Backend] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        
        // Store session ID for future requests
        if (result['session_id'] != null) {
          _currentSessionId = result['session_id'] as String;
        }
        
        print('[CogniSarthi Backend] ✅ Chat response received');
        print('[CogniSarthi Backend] Session ID: $_currentSessionId');
        
        return result;
      } else {
        print('[CogniSarthi Backend] ❌ Chat failed with status: ${response.statusCode}');
        print('[CogniSarthi Backend] Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[CogniSarthi Backend] ❌ Chat error: $e');
      return null;
    }
  }

  /// Get suggested prompts from backend
  Future<List<Map<String, dynamic>>> getSuggestedPrompts() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/suggested-prompts'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        final prompts = result['prompts'] as List<dynamic>?;
        
        if (prompts != null) {
          return prompts.map((p) => p as Map<String, dynamic>).toList();
        }
      }
    } catch (e) {
      print('[CogniSarthi Backend] Error getting suggested prompts: $e');
    }
    
    return [];
  }

  /// Get database statistics
  Future<Map<String, dynamic>?> getDatabaseStats({String customer = 'cognecto'}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/database-stats?customer=$customer'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('[CogniSarthi Backend] Error getting database stats: $e');
    }
    
    return null;
  }

  /// Clear current session
  void clearSession() {
    _currentSessionId = null;
    print('[CogniSarthi Backend] Session cleared');
  }

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Parse backend response into chat message format
  Map<String, dynamic> parseBackendResponse(Map<String, dynamic> backendResponse) {
    final response = backendResponse['response'] as Map<String, dynamic>?;
    
    if (response == null) {
      return {
        'content': 'Error: Invalid response format',
        'timestamp': DateTime.now().toIso8601String(),
        'data': null,
      };
    }

    final metadata = response['metadata'] as Map<String, dynamic>?;
    Map<String, dynamic>? parsedData;

    // Parse metadata for visualization
    if (metadata != null) {
      final chartType = metadata['chart_type'] as String?;
      final data = metadata['data'] as List<dynamic>?;
      
      if (data != null && data.isNotEmpty) {
        if (chartType == 'bar' || chartType == 'line' || chartType == 'pie') {
          // Convert data to table format for visualization
          final firstItem = data.first as Map<String, dynamic>;
          final headers = firstItem.keys.toList();
          final rows = data.map((item) {
            final row = item as Map<String, dynamic>;
            return headers.map((key) => row[key]?.toString() ?? '').toList();
          }).toList();

          parsedData = {
            'type': 'table',
            'headers': headers,
            'rows': rows,
            'chart_type': chartType,
            'sql_query': metadata['sql_query'],
            'row_count': metadata['row_count'],
          };
        }
      }
    }

    return {
      'content': response['content'] as String? ?? 'No response',
      'timestamp': response['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      'data': parsedData,
      'metadata': metadata,
    };
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
