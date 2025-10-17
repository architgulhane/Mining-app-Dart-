import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'file_storage_service.dart';
import 'token_usage_guard.dart';
import 'secure_key_manager.dart';

/// Service for analyzing PDF files with table extraction
class PdfAnalysisService {
  final FileStorageService _storageService = FileStorageService();
  final TokenUsageGuard _tokenGuard = TokenUsageGuard();
  final SecureKeyManager _keyManager = SecureKeyManager();
  
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1';
  static const String _model = 'gemini-2.5-flash-lite';
  
  Future<String> get _apiKey async {
    final secureKey = await _keyManager.getGeminiKey();
    return secureKey ?? '';
  }
  
  /// Upload and analyze PDF file
  Future<Map<String, dynamic>?> uploadAndAnalyzePdf({
    required Uint8List fileBytes,
    required String fileName,
    String? description,
  }) async {
    try {
      // Store file locally
      final metadata = await _storageService.saveFile(
        fileBytes: fileBytes,
        fileName: fileName,
        fileType: 'pdf',
        description: description,
      );
      
      // Extract text from PDF
      final extractedText = await extractTextFromPdf(fileBytes);
      
      if (extractedText == null || extractedText.isEmpty) {
        return {
          'error': 'Could not extract text from PDF',
          'fileId': metadata.id,
          'stored': true,
        };
      }
      
      // Check token limits
      final estimatedTokens = _tokenGuard.estimateTokenCount(extractedText);
      final operationCheck = await _tokenGuard.checkOperationAllowed(
        estimatedTokens: estimatedTokens,
      );
      
      if (!operationCheck.allowed) {
        return {
          'error': operationCheck.reason,
          'fileId': metadata.id,
          'stored': true,
          'extractedText': extractedText,
        };
      }
      
      // Analyze with Gemini
      final analysis = await _analyzePdfContent(extractedText, fileName);
      
      if (analysis != null) {
        await _tokenGuard.recordUsage(
          provider: 'gemini',
          inputTokens: estimatedTokens,
          outputTokens: estimatedTokens ~/ 3,
          operation: 'pdf_analysis',
          fileId: metadata.id,
        );
        
        return {
          ...analysis,
          'fileId': metadata.id,
          'stored': true,
          'extractedText': extractedText,
        };
      }
      
      return null;
    } catch (e) {
      print('Error uploading and analyzing PDF: $e');
      return null;
    }
  }
  
  /// Extract text from PDF bytes
  Future<String?> extractTextFromPdf(Uint8List pdfBytes) async {
    try {
      // Use pdf package to extract text
      final document = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
      
      // For now, return a placeholder
      // In production, you'd use a proper PDF text extraction library
      // like pdf_text or native platform code
      return 'PDF text extraction requires native implementation';
    } catch (e) {
      print('Error extracting PDF text: $e');
      return null;
    }
  }
  
  /// Analyze PDF content with Gemini
  Future<Map<String, dynamic>?> _analyzePdfContent(
    String pdfText,
    String fileName,
  ) async {
    try {
      final apiKey = await _apiKey;
      if (apiKey.isEmpty) {
        return {'error': 'API key not configured'};
      }
      
      final prompt = '''
Analyze this PDF document titled "$fileName".

Content:
$pdfText

Provide analysis in JSON format:
{
  "summary": "Brief 2-3 sentence summary",
  "documentType": "Type of document (report, invoice, manual, etc.)",
  "keyPoints": ["Point 1", "Point 2", "Point 3"],
  "tables": [
    {
      "title": "Table name",
      "description": "What the table contains"
    }
  ],
  "insights": ["Insight 1", "Insight 2"],
  "recommendations": ["Recommendation 1", "Recommendation 2"]
}

Focus on:
1. Document structure and organization
2. Key data and metrics
3. Tables and structured data
4. Action items or conclusions

Return ONLY valid JSON.
''';
      
      return await _callGeminiApi(prompt, apiKey);
    } catch (e) {
      print('Error analyzing PDF content: $e');
      return null;
    }
  }
  
  /// Extract tables from PDF
  Future<List<Map<String, dynamic>>> extractTables({
    required String fileId,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final extractedText = await extractTextFromPdf(fileContent);
      
      if (extractedText == null) return [];
      
      final apiKey = await _apiKey;
      final prompt = '''
Extract all tables from this text and return them in JSON format:

$extractedText

Return format:
{
  "tables": [
    {
      "title": "Table name",
      "headers": ["Column 1", "Column 2"],
      "rows": [
        ["Value 1", "Value 2"],
        ["Value 3", "Value 4"]
      ]
    }
  ]
}

Return ONLY valid JSON.
''';
      
      final response = await _callGeminiApi(prompt, apiKey);
      return (response?['tables'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      print('Error extracting tables: $e');
      return [];
    }
  }
  
  /// Ask question about PDF content
  Future<String?> askQuestionAboutPdf({
    required String fileId,
    required String question,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final extractedText = await extractTextFromPdf(fileContent);
      
      if (extractedText == null) {
        return 'Error: Could not extract text from PDF';
      }
      
      // Check token limits
      final estimatedTokens = _tokenGuard.estimateTokenCount(extractedText + question);
      final operationCheck = await _tokenGuard.checkOperationAllowed(
        estimatedTokens: estimatedTokens,
      );
      
      if (!operationCheck.allowed) {
        return 'Error: ${operationCheck.reason}';
      }
      
      final apiKey = await _apiKey;
      final prompt = '''
Based on this PDF content:

$extractedText

Question: $question

Provide a clear, detailed answer based on the PDF content.
''';
      
      final response = await _callGeminiApi(prompt, apiKey);
      
      if (response != null) {
        await _tokenGuard.recordUsage(
          provider: 'gemini',
          inputTokens: estimatedTokens,
          outputTokens: _tokenGuard.estimateTokenCount(response['answer'] ?? ''),
          operation: 'pdf_question',
          fileId: fileId,
        );
      }
      
      return response?['answer'];
    } catch (e) {
      print('Error asking question about PDF: $e');
      return null;
    }
  }
  
  /// Generate summary of PDF
  Future<String?> summarizePdf({
    required String fileId,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final extractedText = await extractTextFromPdf(fileContent);
      
      if (extractedText == null) return 'Error: Could not extract text';
      
      final apiKey = await _apiKey;
      final prompt = '''
Provide a concise 3-4 sentence summary of this PDF:

$extractedText

Focus on main points, key data, and conclusions.
''';
      
      final response = await _callGeminiApi(prompt, apiKey);
      return response?['summary'] ?? response?['answer'];
    } catch (e) {
      print('Error summarizing PDF: $e');
      return null;
    }
  }
  
  /// Call Gemini API
  Future<Map<String, dynamic>?> _callGeminiApi(String prompt, String apiKey) async {
    try {
      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$apiKey');
      
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
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null) {
          try {
            return json.decode(text.replaceAll('```json', '').replaceAll('```', '').trim());
          } catch (e) {
            return {'answer': text};
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error calling Gemini API: $e');
      return null;
    }
  }
}
