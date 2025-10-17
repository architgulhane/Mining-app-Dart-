import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Manages CSV file context for in-memory querying
/// Stores CSV data and uses Gemini API for context-aware responses
class CsvContextManager {
  static final CsvContextManager _instance = CsvContextManager._internal();
  factory CsvContextManager() => _instance;
  CsvContextManager._internal();

  // In-memory storage for CSV data
  String? _currentFileName;
  List<List<dynamic>>? _csvData;
  List<String>? _headers;
  Map<String, dynamic>? _csvMetadata;
  bool _hasCsvContext = false;

  final http.Client _client = http.Client();
  
  String get _geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      print('[CSV Context] ⚠️ WARNING: GEMINI_API_KEY not found in environment');
    } else {
      print('[CSV Context] 🔑 API Key loaded successfully (${key.length} characters)');
    }
    return key;
  }
  
  static const String _geminiApiUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  /// Check if CSV context is available
  bool get hasCsvContext => _hasCsvContext;

  /// Get current CSV file name
  String? get currentFileName => _currentFileName;

  /// Get CSV metadata
  Map<String, dynamic>? get csvMetadata => _csvMetadata;

  /// Load CSV file and create context
  Future<Map<String, dynamic>> loadCsvFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      print('[CSV Context] 📁 Loading CSV file: $fileName');

      // Parse CSV manually
      final csvString = utf8.decode(fileBytes);
      final lines = csvString.split('\n');
      
      if (lines.isEmpty) {
        return {
          'success': false,
          'error': 'CSV file is empty',
        };
      }

      // Parse CSV data
      final csvData = <List<dynamic>>[];
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final row = _parseCsvLine(line);
        csvData.add(row);
      }

      if (csvData.isEmpty) {
        return {
          'success': false,
          'error': 'No valid data found in CSV',
        };
      }

      // Extract headers and data
      _headers = csvData.first.map((e) => e.toString()).toList();
      _csvData = csvData.sublist(1);
      _currentFileName = fileName;
      _hasCsvContext = true;

      // Generate metadata
      _csvMetadata = {
        'fileName': fileName,
        'rowCount': _csvData!.length,
        'columnCount': _headers!.length,
        'columns': _headers,
        'fileSize': fileBytes.length,
        'loadedAt': DateTime.now().toIso8601String(),
      };

      print('[CSV Context] ✅ CSV loaded successfully');
      print('[CSV Context] Rows: ${_csvData!.length}, Columns: ${_headers!.length}');

      // Generate initial summary using Gemini
      final summary = await _generateCsvSummary();

      return {
        'success': true,
        'metadata': _csvMetadata,
        'summary': summary,
        'preview': _getDataPreview(),
      };
    } catch (e) {
      print('[CSV Context] ❌ Error loading CSV: $e');
      return {
        'success': false,
        'error': 'Failed to load CSV: $e',
      };
    }
  }

  /// Parse CSV line handling quoted fields
  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    fields.add(buffer.toString().trim());
    return fields;
  }

  /// Query CSV data using natural language
  Future<Map<String, dynamic>> queryCsvData(String query) async {
    if (!_hasCsvContext) {
      return {
        'success': false,
        'error': 'No CSV file loaded. Please upload a CSV file first.',
      };
    }

    try {
      print('[CSV Context] 🔍 Querying CSV with: $query');

      // Create prompt for Gemini
      final prompt = _buildQueryPrompt(query);

      // Call Gemini API
      final response = await _callGeminiApi(prompt);

      return {
        'success': true,
        'response': response,
        'context': 'csv',
        'fileName': _currentFileName,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('[CSV Context] ❌ Query error: $e');
      return {
        'success': false,
        'error': 'Failed to query CSV: $e',
      };
    }
  }

  /// Build query prompt for Gemini
  String _buildQueryPrompt(String query) {
    return '''You are a data analysis assistant. Analyze the following CSV data and answer the user's question.

CSV File: $_currentFileName
Columns: ${_headers!.join(', ')}
Total Rows: ${_csvData!.length}

Sample Data (first 10 rows):
${_formatDataSample(10)}

User Question: $query

Instructions:
1. Analyze the CSV data based on the question
2. Provide specific answers with numbers and details
3. If asked for specific rows, columns, or calculations, provide exact results
4. Format your response clearly and concisely
5. If the question asks for data visualization, suggest the appropriate chart type
6. Include relevant statistics when applicable

Provide a clear, concise answer:''';
  }

  /// Generate CSV summary using Gemini
  Future<String> _generateCsvSummary() async {
    try {
      final prompt = '''Analyze this CSV file and provide a brief summary.

File: $_currentFileName
Columns: ${_headers!.join(', ')}
Total Rows: ${_csvData!.length}

Sample Data:
${_formatDataSample(5)}

Provide a 2-3 sentence summary of what this data represents and key insights.''';

      return await _callGeminiApi(prompt);
    } catch (e) {
      return 'CSV file loaded with ${_csvData!.length} rows and ${_headers!.length} columns.';
    }
  }

  /// Call Gemini API
  Future<String> _callGeminiApi(String prompt) async {
    if (_geminiApiKey.isEmpty) {
      throw Exception('Gemini API key not configured in .env file');
    }

    try {
      final response = await _client.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final candidates = result['candidates'] as List<dynamic>?;
        
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>;
          final parts = content['parts'] as List<dynamic>;
          final text = parts[0]['text'] as String;
          return text;
        }
        
        throw Exception('No response from Gemini API');
      } else {
        throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to call Gemini API: $e');
    }
  }

  /// Format data sample for display
  String _formatDataSample(int rowCount) {
    final buffer = StringBuffer();
    buffer.writeln(_headers!.join(' | '));
    buffer.writeln('-' * (_headers!.length * 15));
    
    final sampleSize = _csvData!.length > rowCount ? rowCount : _csvData!.length;
    for (var i = 0; i < sampleSize; i++) {
      buffer.writeln(_csvData![i].join(' | '));
    }
    
    if (_csvData!.length > rowCount) {
      buffer.writeln('... and ${_csvData!.length - rowCount} more rows');
    }
    
    return buffer.toString();
  }

  /// Get data preview for display
  Map<String, dynamic> _getDataPreview() {
    final previewSize = _csvData!.length > 10 ? 10 : _csvData!.length;
    
    return {
      'headers': _headers,
      'rows': _csvData!.sublist(0, previewSize),
      'totalRows': _csvData!.length,
      'showingRows': previewSize,
    };
  }

  /// Clear CSV context
  void clearContext() {
    _currentFileName = null;
    _csvData = null;
    _headers = null;
    _csvMetadata = null;
    _hasCsvContext = false;
    print('[CSV Context] 🗑️ Context cleared');
  }

  /// Dispose resources
  void dispose() {
    clearContext();
    _client.close();
  }
}
