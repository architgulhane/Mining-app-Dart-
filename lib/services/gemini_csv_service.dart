import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'file_storage_service.dart';
import 'token_usage_guard.dart';
import 'secure_key_manager.dart';

/// Service for analyzing CSV files using Google Gemini Flash model
class GeminiCsvService {
  final FileStorageService _storageService = FileStorageService();
  final TokenUsageGuard _tokenGuard = TokenUsageGuard();
  final SecureKeyManager _keyManager = SecureKeyManager();
  
  // Cache for parsed CSV data
  final Map<String, List<Map<String, String>>> _csvDataCache = {};
  // Gemini API configuration
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1';
  static const String _model = 'gemini-2.5-flash-lite';
  
  // Get API key from secure storage or environment
  Future<String> get _apiKey async {
    // Try secure storage first
    final secureKey = await _keyManager.getGeminiKey();
    if (secureKey != null && secureKey.isNotEmpty) {
      return secureKey;
    }
    // Fallback to .env
    return dotenv.env['AIzaSyC76zvd9KORldMPwktMUxotNxtYWysY8Qk'] ?? '';
  }

  /// Analyze a CSV file and return insights
  /// 
  /// Takes the CSV file bytes and filename, sends to Gemini for analysis
  /// Returns a map containing:
  /// - summary: Brief description of the data
  /// - rowCount: Number of rows
  /// - columnCount: Number of columns
  /// - columns: List of column names
  /// - insights: Key insights about the data
  /// - statistics: Basic statistics
  Future<Map<String, dynamic>?> analyzeCsvFile(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      // Validate API key
      final apiKey = await _apiKey;
      if (apiKey.isEmpty) {
        print('Error: GEMINI_API_KEY not found in .env file');
        return null;
      }

      // Convert CSV bytes to string
      final csvContent = utf8.decode(fileBytes);
      
      // Parse CSV to get basic info
      final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
      final rowCount = lines.length - 1; // Exclude header
      final columns = lines.isNotEmpty ? lines[0].split(',').map((e) => e.trim()).toList() : [];
      
      // Create prompt for Gemini
      final prompt = _buildAnalysisPrompt(csvContent, fileName, rowCount, columns.length);
      
      // Call Gemini API
      final response = await _callGeminiApi(prompt);
      
      if (response != null) {
        return {
          'summary': response['summary'],
          'rowCount': rowCount,
          'columnCount': columns.length,
          'columns': columns,
          'insights': response['insights'],
          'statistics': response['statistics'],
          'dataTypes': response['dataTypes'],
          'recommendations': response['recommendations'],
        };
      }
      
      return null;
    } catch (e) {
      print('Error analyzing CSV file: $e');
      return null;
    }
  }

  /// Ask a question about the uploaded CSV data
  Future<String?> askQuestionAboutCsv(
    String csvContent,
    String question,
  ) async {
    try {
      final apiKey = await _apiKey;
      if (apiKey.isEmpty) {
        print('Error: GEMINI_API_KEY not found in .env file');
        return null;
      }

      final prompt = '''
I have this CSV data:

$csvContent

User Question: $question

Please provide a clear, concise answer based on the CSV data above. 
If you need to perform calculations, show your work.
If the data doesn't contain the information needed, say so clearly.
''';

      final response = await _callGeminiApi(prompt);
      return response?['answer'];
    } catch (e) {
      print('Error asking question about CSV: $e');
      return null;
    }
  }

  /// Build a comprehensive analysis prompt for Gemini
  String _buildAnalysisPrompt(
    String csvContent,
    String fileName,
    int rowCount,
    int columnCount,
  ) {
    // Limit CSV content to first 100 rows for analysis (to avoid token limits)
    final lines = csvContent.split('\n');
    final limitedContent = lines.take(101).join('\n'); // Header + 100 rows
    
    return '''
Analyze this CSV file named "$fileName" with $rowCount rows and $columnCount columns.

CSV Data (first 100 rows):
$limitedContent

Please provide a comprehensive analysis in JSON format with the following structure:
{
  "summary": "Brief 2-3 sentence description of what this data represents",
  "insights": [
    "Key insight 1",
    "Key insight 2",
    "Key insight 3"
  ],
  "statistics": {
    "description": "Brief statistical overview"
  },
  "dataTypes": {
    "columnName": "detected data type (numeric, text, date, etc.)"
  },
  "recommendations": [
    "Suggestion 1 for using this data",
    "Suggestion 2 for analysis"
  ]
}

Focus on:
1. What kind of data this is (sales, equipment, production, etc.)
2. Interesting patterns or trends
3. Data quality (missing values, outliers)
4. Potential use cases
5. Key metrics or KPIs present

Return ONLY valid JSON, no additional text.
''';
  }

  /// Call the Gemini API
  Future<Map<String, dynamic>?> _callGeminiApi(String prompt, [String? apiKey]) async {
    try {
      final key = apiKey ?? await _apiKey;
      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$key');
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 2048,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null) {
          // Try to parse as JSON
          try {
            // Clean up the response (remove markdown code blocks if present)
            String cleanedText = text.trim();
            if (cleanedText.startsWith('```json')) {
              cleanedText = cleanedText.substring(7);
            }
            if (cleanedText.startsWith('```')) {
              cleanedText = cleanedText.substring(3);
            }
            if (cleanedText.endsWith('```')) {
              cleanedText = cleanedText.substring(0, cleanedText.length - 3);
            }
            
            return json.decode(cleanedText.trim());
          } catch (e) {
            // If not JSON, return as plain text answer
            return {'answer': text};
          }
        }
      } else {
        print('Gemini API error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('Error calling Gemini API: $e');
      return null;
    }
  }

  /// Generate a summary for multiple CSV files
  Future<String?> generateMultiFileSummary(
    List<Map<String, dynamic>> fileAnalyses,
  ) async {
    try {
      final apiKey = await _apiKey;
      if (apiKey.isEmpty) {
        return null;
      }

      final prompt = '''
I have uploaded ${fileAnalyses.length} CSV files. Here's a summary of each:

${fileAnalyses.map((analysis) => '''
File: ${analysis['fileName']}
- Rows: ${analysis['rowCount']}
- Columns: ${analysis['columnCount']}
- Summary: ${analysis['summary']}
''').join('\n')}

Please provide:
1. An overall summary of all the data
2. How these datasets might relate to each other
3. Potential analysis opportunities across these files

Keep it concise and actionable.
''';

      final response = await _callGeminiApi(prompt);
      return response?['answer'];
    } catch (e) {
      print('Error generating multi-file summary: $e');
      return null;
    }
  }

  /// Extract specific columns from CSV
  List<Map<String, String>> parseCsvToJson(String csvContent) {
    try {
      final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
      if (lines.isEmpty) return [];

      final headers = lines[0].split(',').map((e) => e.trim()).toList();
      final List<Map<String, String>> data = [];

      for (int i = 1; i < lines.length; i++) {
        final values = lines[i].split(',').map((e) => e.trim()).toList();
        if (values.length == headers.length) {
          final row = <String, String>{};
          for (int j = 0; j < headers.length; j++) {
            row[headers[j]] = values[j];
          }
          data.add(row);
        }
      }

      return data;
    } catch (e) {
      print('Error parsing CSV to JSON: $e');
      return [];
    }
  }

  /// Validate CSV structure
  Map<String, dynamic> validateCsv(String csvContent) {
    try {
      final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      if (lines.isEmpty) {
        return {
          'valid': false,
          'error': 'CSV file is empty'
        };
      }

      final headers = lines[0].split(',');
      final columnCount = headers.length;
      
      // Check for consistent column count
      for (int i = 1; i < lines.length; i++) {
        final columns = lines[i].split(',');
        if (columns.length != columnCount) {
          return {
            'valid': false,
            'error': 'Inconsistent column count at row ${i + 1}'
          };
        }
      }

      return {
        'valid': true,
        'rowCount': lines.length - 1,
        'columnCount': columnCount,
        'headers': headers.map((e) => e.trim()).toList(),
      };
    } catch (e) {
      return {
        'valid': false,
        'error': 'Error parsing CSV: $e'
      };
    }
  }
  
  // ============ ENHANCED FEATURES ============
  
  /// Upload and store CSV file locally, then analyze it
  Future<Map<String, dynamic>?> uploadAndAnalyzeCsv({
    required Uint8List fileBytes,
    required String fileName,
    String? description,
  }) async {
    try {
      // Store file locally first
      final metadata = await _storageService.saveFile(
        fileBytes: fileBytes,
        fileName: fileName,
        fileType: 'csv',
        description: description,
      );
      
      // Check token limits before analysis
      final csvContent = utf8.decode(fileBytes);
      final estimatedTokens = _tokenGuard.estimateTokenCount(csvContent);
      final operationCheck = await _tokenGuard.checkOperationAllowed(
        estimatedTokens: estimatedTokens,
      );
      
      if (!operationCheck.allowed) {
        return {
          'error': operationCheck.reason,
          'fileId': metadata.id,
          'stored': true,
        };
      }
      
      // Analyze the CSV
      final analysis = await analyzeCsvFile(fileBytes, fileName);
      
      if (analysis != null) {
        // Record token usage
        await _tokenGuard.recordUsage(
          provider: 'gemini',
          inputTokens: estimatedTokens,
          outputTokens: estimatedTokens ~/ 4, // Rough estimate
          operation: 'csv_analysis',
          fileId: metadata.id,
        );
        
        // Cache parsed data for queries
        final parsedData = parseCsvToJson(csvContent);
        _csvDataCache[metadata.id] = parsedData;
        
        return {
          ...analysis,
          'fileId': metadata.id,
          'stored': true,
          'filePath': metadata.filePath,
        };
      }
      
      return null;
    } catch (e) {
      print('Error uploading and analyzing CSV: $e');
      return null;
    }
  }
  
  /// Query specific row by number
  Future<Map<String, dynamic>?> queryRow({
    required String fileId,
    required int rowNumber,
  }) async {
    try {
      // Get cached data or load from storage
      List<Map<String, String>> data;
      if (_csvDataCache.containsKey(fileId)) {
        data = _csvDataCache[fileId]!;
      } else {
        final fileContent = await _storageService.getFileContent(fileId);
        final csvContent = utf8.decode(fileContent);
        data = parseCsvToJson(csvContent);
        _csvDataCache[fileId] = data;
      }
      
      if (rowNumber < 1 || rowNumber > data.length) {
        return {
          'error': 'Row number out of range. Valid range: 1-${data.length}'
        };
      }
      
      return {
        'rowNumber': rowNumber,
        'data': data[rowNumber - 1],
        'totalRows': data.length,
      };
    } catch (e) {
      print('Error querying row: $e');
      return null;
    }
  }
  
  /// Query rows with filter conditions
  Future<List<Map<String, String>>> queryRowsWithFilter({
    required String fileId,
    required String columnName,
    String? equals,
    double? greaterThan,
    double? lessThan,
    String? contains,
  }) async {
    try {
      // Get cached data or load from storage
      List<Map<String, String>> data;
      if (_csvDataCache.containsKey(fileId)) {
        data = _csvDataCache[fileId]!;
      } else {
        final fileContent = await _storageService.getFileContent(fileId);
        final csvContent = utf8.decode(fileContent);
        data = parseCsvToJson(csvContent);
        _csvDataCache[fileId] = data;
      }
      
      // Apply filters
      return data.where((row) {
        final value = row[columnName];
        if (value == null) return false;
        
        if (equals != null && value == equals) return true;
        if (contains != null && value.contains(contains)) return true;
        
        final numValue = double.tryParse(value);
        if (numValue != null) {
          if (greaterThan != null && numValue > greaterThan) return true;
          if (lessThan != null && numValue < lessThan) return true;
        }
        
        return false;
      }).toList();
    } catch (e) {
      print('Error querying with filter: $e');
      return [];
    }
  }
  
  /// Get all rows from a specific column
  Future<List<String>> getColumnValues({
    required String fileId,
    required String columnName,
  }) async {
    try {
      // Get cached data or load from storage
      List<Map<String, String>> data;
      if (_csvDataCache.containsKey(fileId)) {
        data = _csvDataCache[fileId]!;
      } else {
        final fileContent = await _storageService.getFileContent(fileId);
        final csvContent = utf8.decode(fileContent);
        data = parseCsvToJson(csvContent);
        _csvDataCache[fileId] = data;
      }
      
      return data
          .map((row) => row[columnName] ?? '')
          .where((value) => value.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error getting column values: $e');
      return [];
    }
  }
  
  /// Calculate statistics for a numeric column
  Future<Map<String, dynamic>?> calculateColumnStats({
    required String fileId,
    required String columnName,
  }) async {
    try {
      final values = await getColumnValues(fileId: fileId, columnName: columnName);
      final numValues = values
          .map((v) => double.tryParse(v))
          .where((n) => n != null)
          .map((n) => n!)
          .toList();
      
      if (numValues.isEmpty) {
        return {'error': 'No numeric values found in column'};
      }
      
      numValues.sort();
      final sum = numValues.reduce((a, b) => a + b);
      final mean = sum / numValues.length;
      final median = numValues.length.isOdd
          ? numValues[numValues.length ~/ 2]
          : (numValues[numValues.length ~/ 2 - 1] + numValues[numValues.length ~/ 2]) / 2;
      
      return {
        'count': numValues.length,
        'sum': sum,
        'mean': mean,
        'median': median,
        'min': numValues.first,
        'max': numValues.last,
        'range': numValues.last - numValues.first,
      };
    } catch (e) {
      print('Error calculating stats: $e');
      return null;
    }
  }
  
  /// Ask natural language query about CSV with token guard
  Future<String?> askQuestionWithGuard({
    required String fileId,
    required String question,
  }) async {
    try {
      // Load file content
      final fileContent = await _storageService.getFileContent(fileId);
      final csvContent = utf8.decode(fileContent);
      
      // Check token limits
      final estimatedTokens = _tokenGuard.estimateTokenCount(csvContent + question);
      final operationCheck = await _tokenGuard.checkOperationAllowed(
        estimatedTokens: estimatedTokens,
      );
      
      if (!operationCheck.allowed) {
        return 'Error: ${operationCheck.reason}. ${operationCheck.remainingTokens} tokens remaining today.';
      }
      
      // Ask question
      final answer = await askQuestionAboutCsv(csvContent, question);
      
      if (answer != null) {
        // Record usage
        await _tokenGuard.recordUsage(
          provider: 'gemini',
          inputTokens: estimatedTokens,
          outputTokens: _tokenGuard.estimateTokenCount(answer),
          operation: 'csv_question',
          fileId: fileId,
        );
      }
      
      return answer;
    } catch (e) {
      print('Error asking question with guard: $e');
      return null;
    }
  }
  
  /// Generate automatic summary for large CSV files
  Future<String?> autoSummarize({
    required String fileId,
    int maxRows = 1000,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final csvContent = utf8.decode(fileContent);
      final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      // For large files, sample data
      String sampleContent;
      if (lines.length > maxRows) {
        final header = lines.first;
        final sampledLines = [header];
        
        // Take evenly distributed samples
        final step = (lines.length - 1) / (maxRows - 1);
        for (int i = 1; i < maxRows; i++) {
          final index = (i * step).round().clamp(1, lines.length - 1);
          sampledLines.add(lines[index]);
        }
        
        sampleContent = sampledLines.join('\n');
      } else {
        sampleContent = csvContent;
      }
      
      final apiKey = await _apiKey;
      if (apiKey.isEmpty) {
        return 'Error: API key not configured';
      }
      
      final prompt = '''
Provide a brief 3-4 sentence summary of this CSV data:

$sampleContent

Focus on:
1. What type of data this is
2. Key metrics or patterns
3. Time range (if applicable)
4. Main insights

Keep it concise and actionable.
''';
      
      final response = await _callGeminiApi(prompt, apiKey);
      return response?['summary'] ?? response?['answer'];
    } catch (e) {
      print('Error auto-summarizing: $e');
      return null;
    }
  }
  
  /// Get chart-ready data from CSV
  Future<Map<String, dynamic>?> getChartData({
    required String fileId,
    required String xColumn,
    required String yColumn,
    int maxPoints = 100,
  }) async {
    try {
      // Get cached data
      List<Map<String, String>> data;
      if (_csvDataCache.containsKey(fileId)) {
        data = _csvDataCache[fileId]!;
      } else {
        final fileContent = await _storageService.getFileContent(fileId);
        final csvContent = utf8.decode(fileContent);
        data = parseCsvToJson(csvContent);
        _csvDataCache[fileId] = data;
      }
      
      // Sample if too many points
      if (data.length > maxPoints) {
        final step = data.length / maxPoints;
        data = List.generate(
          maxPoints,
          (i) => data[(i * step).floor()],
        );
      }
      
      final chartData = <Map<String, dynamic>>[];
      for (final row in data) {
        final xValue = row[xColumn];
        final yValue = row[yColumn];
        
        if (xValue != null && yValue != null) {
          chartData.add({
            'x': xValue,
            'y': double.tryParse(yValue) ?? 0,
          });
        }
      }
      
      return {
        'data': chartData,
        'xColumn': xColumn,
        'yColumn': yColumn,
        'pointCount': chartData.length,
      };
    } catch (e) {
      print('Error getting chart data: $e');
      return null;
    }
  }
}
