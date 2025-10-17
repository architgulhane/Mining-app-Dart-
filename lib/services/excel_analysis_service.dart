import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'file_storage_service.dart';
import 'token_usage_guard.dart';
import 'gemini_csv_service.dart';

/// Service for handling Excel files (.xlsx, .xls)
class ExcelAnalysisService {
  final FileStorageService _storageService = FileStorageService();
  final TokenUsageGuard _tokenGuard = TokenUsageGuard();
  final GeminiCsvService _csvService = GeminiCsvService();
  
  /// Upload and analyze Excel file
  Future<Map<String, dynamic>?> uploadAndAnalyzeExcel({
    required Uint8List fileBytes,
    required String fileName,
    String? description,
  }) async {
    try {
      // Store file locally
      final metadata = await _storageService.saveFile(
        fileBytes: fileBytes,
        fileName: fileName,
        fileType: 'xlsx',
        description: description,
      );
      
      // Parse Excel file
      final excel = Excel.decodeBytes(fileBytes);
      
      if (excel.sheets.isEmpty) {
        return {
          'error': 'Excel file contains no sheets',
          'fileId': metadata.id,
          'stored': true,
        };
      }
      
      // Analyze all sheets
      final sheetsAnalysis = <Map<String, dynamic>>[];
      for (final sheetName in excel.sheets.keys) {
        final sheet = excel.sheets[sheetName]!;
        final analysis = await _analyzeSheet(sheet, sheetName, metadata.id);
        if (analysis != null) {
          sheetsAnalysis.add(analysis);
        }
      }
      
      return {
        'fileId': metadata.id,
        'stored': true,
        'sheetCount': excel.sheets.length,
        'sheetNames': excel.sheets.keys.toList(),
        'sheets': sheetsAnalysis,
      };
    } catch (e) {
      print('Error uploading and analyzing Excel: $e');
      return null;
    }
  }
  
  /// Analyze a single Excel sheet
  Future<Map<String, dynamic>?> _analyzeSheet(
    Sheet sheet,
    String sheetName,
    String fileId,
  ) async {
    try {
      final rows = sheet.rows;
      if (rows.isEmpty) {
        return {
          'sheetName': sheetName,
          'error': 'Sheet is empty',
        };
      }
      
      // Extract headers
      final headers = rows.first
          .map((cell) => cell?.value?.toString() ?? '')
          .toList();
      
      // Extract data rows
      final dataRows = <List<String>>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i]
            .map((cell) => cell?.value?.toString() ?? '')
            .toList();
        dataRows.add(row);
      }
      
      return {
        'sheetName': sheetName,
        'rowCount': dataRows.length,
        'columnCount': headers.length,
        'headers': headers,
        'sampleData': dataRows.take(5).toList(), // First 5 rows as sample
      };
    } catch (e) {
      print('Error analyzing sheet: $e');
      return null;
    }
  }
  
  /// Convert Excel sheet to CSV format
  Future<String?> convertSheetToCsv({
    required String fileId,
    required String sheetName,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final excel = Excel.decodeBytes(fileContent);
      
      final sheet = excel.sheets[sheetName];
      if (sheet == null) {
        return null;
      }
      
      final csvBuffer = StringBuffer();
      for (final row in sheet.rows) {
        final rowValues = row.map((cell) {
          final value = cell?.value?.toString() ?? '';
          // Escape commas and quotes
          if (value.contains(',') || value.contains('"')) {
            return '"${value.replaceAll('"', '""')}"';
          }
          return value;
        }).join(',');
        csvBuffer.writeln(rowValues);
      }
      
      return csvBuffer.toString();
    } catch (e) {
      print('Error converting sheet to CSV: $e');
      return null;
    }
  }
  
  /// Get all sheet names from Excel file
  Future<List<String>> getSheetNames(String fileId) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final excel = Excel.decodeBytes(fileContent);
      return excel.sheets.keys.toList();
    } catch (e) {
      print('Error getting sheet names: $e');
      return [];
    }
  }
  
  /// Query specific cell value
  Future<String?> getCellValue({
    required String fileId,
    required String sheetName,
    required int row,
    required int col,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final excel = Excel.decodeBytes(fileContent);
      
      final sheet = excel.sheets[sheetName];
      if (sheet == null) return null;
      
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      return cell.value?.toString();
    } catch (e) {
      print('Error getting cell value: $e');
      return null;
    }
  }
  
  /// Get row data
  Future<List<String>?> getRow({
    required String fileId,
    required String sheetName,
    required int rowIndex,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final excel = Excel.decodeBytes(fileContent);
      
      final sheet = excel.sheets[sheetName];
      if (sheet == null || rowIndex >= sheet.rows.length) return null;
      
      return sheet.rows[rowIndex]
          .map((cell) => cell?.value?.toString() ?? '')
          .toList();
    } catch (e) {
      print('Error getting row: $e');
      return null;
    }
  }
  
  /// Get column data
  Future<List<String>?> getColumn({
    required String fileId,
    required String sheetName,
    required int colIndex,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final excel = Excel.decodeBytes(fileContent);
      
      final sheet = excel.sheets[sheetName];
      if (sheet == null) return null;
      
      final columnData = <String>[];
      for (final row in sheet.rows) {
        if (colIndex < row.length) {
          columnData.add(row[colIndex]?.value?.toString() ?? '');
        }
      }
      
      return columnData;
    } catch (e) {
      print('Error getting column: $e');
      return null;
    }
  }
  
  /// Analyze Excel sheet using Gemini (converts to CSV first)
  Future<Map<String, dynamic>?> analyzeSheetWithAI({
    required String fileId,
    required String sheetName,
  }) async {
    try {
      // Convert sheet to CSV
      final csvContent = await convertSheetToCsv(
        fileId: fileId,
        sheetName: sheetName,
      );
      
      if (csvContent == null) {
        return {'error': 'Could not convert sheet to CSV'};
      }
      
      // Check token limits
      final estimatedTokens = _tokenGuard.estimateTokenCount(csvContent);
      final operationCheck = await _tokenGuard.checkOperationAllowed(
        estimatedTokens: estimatedTokens,
      );
      
      if (!operationCheck.allowed) {
        return {'error': operationCheck.reason};
      }
      
      // Use CSV service to analyze
      final csvBytes = utf8.encode(csvContent);
      final analysis = await _csvService.analyzeCsvFile(
        Uint8List.fromList(csvBytes),
        sheetName,
      );
      
      if (analysis != null) {
        await _tokenGuard.recordUsage(
          provider: 'gemini',
          inputTokens: estimatedTokens,
          outputTokens: estimatedTokens ~/ 4,
          operation: 'excel_sheet_analysis',
          fileId: fileId,
        );
      }
      
      return analysis;
    } catch (e) {
      print('Error analyzing sheet with AI: $e');
      return null;
    }
  }
  
  /// Search for values in Excel file
  Future<List<Map<String, dynamic>>> searchInExcel({
    required String fileId,
    required String searchTerm,
    String? sheetName,
  }) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final excel = Excel.decodeBytes(fileContent);
      
      final results = <Map<String, dynamic>>[];
      final sheetsToSearch = sheetName != null 
          ? [sheetName] 
          : excel.sheets.keys.toList();
      
      for (final sheet in sheetsToSearch) {
        final sheetData = excel.sheets[sheet];
        if (sheetData == null) continue;
        
        for (int rowIdx = 0; rowIdx < sheetData.rows.length; rowIdx++) {
          final row = sheetData.rows[rowIdx];
          for (int colIdx = 0; colIdx < row.length; colIdx++) {
            final cellValue = row[colIdx]?.value?.toString() ?? '';
            if (cellValue.toLowerCase().contains(searchTerm.toLowerCase())) {
              results.add({
                'sheet': sheet,
                'row': rowIdx,
                'column': colIdx,
                'value': cellValue,
              });
            }
          }
        }
      }
      
      return results;
    } catch (e) {
      print('Error searching in Excel: $e');
      return [];
    }
  }
  
  /// Get Excel file statistics
  Future<Map<String, dynamic>?> getExcelStats(String fileId) async {
    try {
      final fileContent = await _storageService.getFileContent(fileId);
      final excel = Excel.decodeBytes(fileContent);
      
      int totalRows = 0;
      int totalCells = 0;
      int nonEmptyCells = 0;
      
      for (final sheet in excel.sheets.values) {
        totalRows += sheet.rows.length;
        for (final row in sheet.rows) {
          totalCells += row.length;
          nonEmptyCells += row.where((cell) => 
            cell?.value != null && cell!.value.toString().isNotEmpty
          ).length;
        }
      }
      
      return {
        'sheetCount': excel.sheets.length,
        'totalRows': totalRows,
        'totalCells': totalCells,
        'nonEmptyCells': nonEmptyCells,
        'fillPercentage': totalCells > 0 
            ? (nonEmptyCells / totalCells * 100).toStringAsFixed(1) 
            : '0',
      };
    } catch (e) {
      print('Error getting Excel stats: $e');
      return null;
    }
  }
}
