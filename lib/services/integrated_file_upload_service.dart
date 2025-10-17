import 'dart:typed_data';
import 'backend_api_service.dart';
import 'gemini_csv_service.dart';
import 'excel_analysis_service.dart';
import 'pdf_analysis_service.dart';
import 'file_storage_service.dart';

/// Integrated file upload service that can use either:
/// - Direct Gemini API (current implementation)
/// - Backend API (FastAPI with OEE Agent)
class IntegratedFileUploadService {
  static final IntegratedFileUploadService _instance = IntegratedFileUploadService._internal();
  factory IntegratedFileUploadService() => _instance;
  IntegratedFileUploadService._internal();

  final BackendApiService _backendApi = BackendApiService();
  final GeminiCsvService _csvService = GeminiCsvService();
  final ExcelAnalysisService _excelService = ExcelAnalysisService();
  final PdfAnalysisService _pdfService = PdfAnalysisService();
  final FileStorageService _fileStorage = FileStorageService();

  bool _useBackend = false;  // Toggle this to switch between direct and backend
  bool _isBackendAvailable = false;

  /// Check if backend is available
  Future<bool> checkBackendAvailability() async {
    _isBackendAvailable = await _backendApi.isBackendAvailable();
    print('[IntegratedUpload] Backend available: $_isBackendAvailable');
    return _isBackendAvailable;
  }

  /// Enable or disable backend usage
  void setUseBackend(bool use) {
    _useBackend = use && _isBackendAvailable;
    print('[IntegratedUpload] Using backend: $_useBackend');
  }

  /// Get current mode
  String getCurrentMode() {
    return _useBackend ? 'Backend API' : 'Direct Gemini API';
  }

  bool get isUsingBackend => _useBackend;

  /// Upload and analyze CSV file
  Future<Map<String, dynamic>?> uploadAndAnalyzeCsv({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      if (_useBackend && _isBackendAvailable) {
        print('[IntegratedUpload] Using BACKEND for CSV upload');
        
        // Upload to backend
        final backendResult = await _backendApi.uploadFile(
          fileBytes: fileBytes,
          fileName: fileName,
          customer: 'cognecto',
        );

        if (backendResult != null) {
          // Also store locally
          final metadata = await _fileStorage.saveFile(
            fileBytes: fileBytes,
            fileName: fileName,
            fileType: 'csv',
          );

          return {
            'success': true,
            'fileId': metadata.id,
            'summary': backendResult['message'] ?? 'File uploaded to backend',
            'rowCount': backendResult['rows_ingested'],
            'columnCount': backendResult['columns']?.length ?? 0,
            'columns': backendResult['columns'],
            'source': 'backend',
          };
        }

        // Fallback to direct Gemini if backend fails
        print('[IntegratedUpload] Backend upload failed, falling back to Gemini');
      }

      // Use direct Gemini API
      print('[IntegratedUpload] Using DIRECT GEMINI API for CSV upload');
      final result = await _csvService.uploadAndAnalyzeCsv(
        fileBytes: fileBytes,
        fileName: fileName,
      );

      if (result != null) {
        result['source'] = 'gemini';
      }

      return result;
    } catch (e) {
      print('[IntegratedUpload] CSV upload error: $e');
      return null;
    }
  }

  /// Upload and analyze Excel file
  Future<Map<String, dynamic>?> uploadAndAnalyzeExcel({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      if (_useBackend && _isBackendAvailable) {
        print('[IntegratedUpload] Using BACKEND for Excel upload');
        
        final backendResult = await _backendApi.uploadFile(
          fileBytes: fileBytes,
          fileName: fileName,
          customer: 'cognecto',
        );

        if (backendResult != null) {
          final metadata = await _fileStorage.saveFile(
            fileBytes: fileBytes,
            fileName: fileName,
            fileType: 'excel',
          );

          return {
            'success': true,
            'fileId': metadata.id,
            'summary': backendResult['message'] ?? 'File uploaded to backend',
            'sheetCount': backendResult['sheets']?.length ?? 0,
            'sheetNames': backendResult['sheets'],
            'source': 'backend',
          };
        }

        print('[IntegratedUpload] Backend upload failed, falling back to Gemini');
      }

      print('[IntegratedUpload] Using DIRECT GEMINI API for Excel upload');
      final result = await _excelService.uploadAndAnalyzeExcel(
        fileBytes: fileBytes,
        fileName: fileName,
      );

      if (result != null) {
        result['source'] = 'gemini';
      }

      return result;
    } catch (e) {
      print('[IntegratedUpload] Excel upload error: $e');
      return null;
    }
  }

  /// Upload and analyze PDF file
  Future<Map<String, dynamic>?> uploadAndAnalyzePdf({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      if (_useBackend && _isBackendAvailable) {
        print('[IntegratedUpload] Using BACKEND for PDF upload');
        
        final backendResult = await _backendApi.uploadFile(
          fileBytes: fileBytes,
          fileName: fileName,
          customer: 'cognecto',
        );

        if (backendResult != null) {
          final metadata = await _fileStorage.saveFile(
            fileBytes: fileBytes,
            fileName: fileName,
            fileType: 'pdf',
          );

          return {
            'success': true,
            'fileId': metadata.id,
            'summary': backendResult['message'] ?? 'File uploaded to backend',
            'pageCount': backendResult['pages'],
            'source': 'backend',
          };
        }

        print('[IntegratedUpload] Backend upload failed, falling back to Gemini');
      }

      print('[IntegratedUpload] Using DIRECT GEMINI API for PDF upload');
      final result = await _pdfService.uploadAndAnalyzePdf(
        fileBytes: fileBytes,
        fileName: fileName,
      );

      if (result != null) {
        result['source'] = 'gemini';
      }

      return result;
    } catch (e) {
      print('[IntegratedUpload] PDF upload error: $e');
      return null;
    }
  }

  /// Send chat message (uses backend if available)
  Future<String?> sendChatMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      if (_useBackend && _isBackendAvailable) {
        print('[IntegratedUpload] Using BACKEND for chat');
        
        final result = await _backendApi.sendChatMessage(
          message: message,
          sessionId: sessionId,
          customer: 'cognecto',
        );

        if (result != null) {
          return result['response'] ?? result['message'];
        }

        print('[IntegratedUpload] Backend chat failed');
      }

      // For direct Gemini, use the existing chat implementation
      return null;  // Let existing chat handle it
    } catch (e) {
      print('[IntegratedUpload] Chat error: $e');
      return null;
    }
  }

  /// Get database statistics (backend only)
  Future<Map<String, dynamic>?> getDatabaseStats() async {
    if (_useBackend && _isBackendAvailable) {
      return await _backendApi.getDatabaseStats(customer: 'cognecto');
    }
    return null;
  }

  /// Get suggested prompts (backend only)
  Future<List<Map<String, dynamic>>?> getSuggestedPrompts() async {
    if (_useBackend && _isBackendAvailable) {
      return await _backendApi.getSuggestedPrompts();
    }
    return null;
  }

  /// Get dataset information (backend only)
  Future<Map<String, dynamic>?> getDatasetInfo() async {
    if (_useBackend && _isBackendAvailable) {
      return await _backendApi.getDatasetInfo(customer: 'cognecto');
    }
    return null;
  }
}
