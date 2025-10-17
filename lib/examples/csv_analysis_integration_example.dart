import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/gemini_csv_service.dart';
import '../models/csv_analysis.dart';
import '../components/csv_analysis_card.dart';

/// Example: Enhanced Settings Modal Data Tab with CSV Analysis
/// 
/// This shows how to integrate Gemini CSV analysis into your existing
/// file upload functionality in the Settings Modal.
/// 
/// Copy the relevant parts into your lib/screens/settings_modal.dart file

class DataTabWithCsvAnalysis extends StatefulWidget {
  const DataTabWithCsvAnalysis({super.key});

  @override
  State<DataTabWithCsvAnalysis> createState() => _DataTabWithCsvAnalysisState();
}

class _DataTabWithCsvAnalysisState extends State<DataTabWithCsvAnalysis> {
  final GeminiCsvService _geminiService = GeminiCsvService();
  
  List<UploadedFileData> _uploadedFiles = [];
  bool _isUploading = false;

  /// Pick and upload files with automatic CSV analysis
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['csv', 'pdf', 'docx', 'doc', 'txt', 'xlsx'],
      );

      if (result != null) {
        setState(() => _isUploading = true);

        for (var file in result.files) {
          if (file.bytes != null) {
            final fileData = UploadedFileData(
              name: file.name,
              size: _formatFileSize(file.size),
              uploadedAt: DateTime.now(),
            );

            // Check if it's a CSV file
            if (file.extension?.toLowerCase() == 'csv') {
              // Analyze CSV with Gemini
              print('📊 Analyzing CSV file: ${file.name}');
              
              try {
                final analysisResult = await _geminiService.analyzeCsvFile(
                  file.bytes!,
                  file.name,
                );

                if (analysisResult != null) {
                  fileData.analysis = CsvAnalysis.fromJson(analysisResult);
                  print('✅ CSV analysis complete!');
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${file.name} analyzed successfully!'),
                        backgroundColor: const Color(0xFF10B981),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  print('⚠️ CSV analysis returned null - check API key');
                  fileData.analysisError = 'Analysis failed. Check GEMINI_API_KEY in .env';
                }
              } catch (e) {
                print('❌ Error analyzing CSV: $e');
                fileData.analysisError = 'Analysis error: $e';
              }
            }

            setState(() {
              _uploadedFiles.add(fileData);
            });
          }
        }

        setState(() => _isUploading = false);
      }
    } catch (e) {
      print('Error picking files: $e');
      setState(() => _isUploading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading files: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  /// Format file size in human-readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Remove a file from the list
  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  /// Retry analysis for a failed CSV
  Future<void> _retryAnalysis(int index) async {
    // Implementation for retry logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retrying analysis...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Upload & Analyze Files',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'CSV files will be automatically analyzed with AI',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Upload Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickFiles,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Uploaded Files List
          if (_uploadedFiles.isEmpty && !_isUploading)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No files uploaded yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Files with Analysis
          Expanded(
            child: ListView.builder(
              itemCount: _uploadedFiles.length,
              itemBuilder: (context, index) {
                final file = _uploadedFiles[index];
                
                // CSV file with analysis
                if (file.isCsv && file.hasAnalysis) {
                  return CsvAnalysisCard(
                    analysis: file.analysis!,
                    fileName: file.name,
                  );
                }
                
                // CSV file with error
                if (file.isCsv && file.hasAnalysisError) {
                  return CsvAnalysisError(
                    fileName: file.name,
                    error: file.analysisError!,
                    onRetry: () => _retryAnalysis(index),
                  );
                }
                
                // CSV file being analyzed
                if (file.isCsv && !file.hasAnalysis && _isUploading) {
                  return CsvAnalysisLoading(fileName: file.name);
                }
                
                // Regular file (non-CSV)
                return _buildRegularFileCard(file, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build card for non-CSV files
  Widget _buildRegularFileCard(UploadedFileData file, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          _getFileIcon(file.name),
          size: 32,
          color: const Color(0xFF3B82F6),
        ),
        title: Text(
          file.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${file.size} • ${_formatDate(file.uploadedAt)}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
          onPressed: () => _removeFile(index),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'docx':
      case 'doc':
        return Icons.description;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Model for uploaded file with optional CSV analysis
class UploadedFileData {
  final String name;
  final String size;
  final DateTime uploadedAt;
  CsvAnalysis? analysis;
  String? analysisError;

  UploadedFileData({
    required this.name,
    required this.size,
    required this.uploadedAt,
    this.analysis,
    this.analysisError,
  });

  bool get isCsv => name.toLowerCase().endsWith('.csv');
  bool get hasAnalysis => analysis != null;
  bool get hasAnalysisError => analysisError != null;
}

/// Example: Integration in Chat Screen
/// 
/// This shows how to use CSV analysis in the chat interface
/// where users can ask questions about uploaded CSV files

class ChatScreenWithCsvAnalysis extends StatefulWidget {
  const ChatScreenWithCsvAnalysis({super.key});

  @override
  State<ChatScreenWithCsvAnalysis> createState() => _ChatScreenWithCsvAnalysisState();
}

class _ChatScreenWithCsvAnalysisState extends State<ChatScreenWithCsvAnalysis> {
  final GeminiCsvService _geminiService = GeminiCsvService();
  
  String? _uploadedCsvContent;
  String? _uploadedCsvFileName;
  CsvAnalysis? _currentCsvAnalysis;

  /// Handle CSV file upload in chat
  Future<void> _handleCsvUploadInChat() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      final fileName = result.files.first.name;
      
      // Store CSV content for later questions
      _uploadedCsvContent = utf8.decode(bytes);
      _uploadedCsvFileName = fileName;
      
      // Analyze immediately
      final analysisResult = await _geminiService.analyzeCsvFile(bytes, fileName);
      
      if (analysisResult != null) {
        _currentCsvAnalysis = CsvAnalysis.fromJson(analysisResult);
        
        // Add analysis to chat
        _addMessageToChat(
          'I\'ve analyzed your CSV file "$fileName":\n\n'
          '📊 ${_currentCsvAnalysis!.rowCount} rows × ${_currentCsvAnalysis!.columnCount} columns\n\n'
          '${_currentCsvAnalysis!.summary}\n\n'
          'Feel free to ask me questions about this data!',
          isUser: false,
        );
      }
    }
  }

  /// Ask a question about the uploaded CSV
  Future<void> _askQuestionAboutCsv(String question) async {
    if (_uploadedCsvContent == null) {
      _addMessageToChat(
        'Please upload a CSV file first before asking questions.',
        isUser: false,
      );
      return;
    }

    // Add user question to chat
    _addMessageToChat(question, isUser: true);
    
    // Show typing indicator
    _addMessageToChat('Analyzing...', isUser: false);
    
    // Get answer from Gemini
    final answer = await _geminiService.askQuestionAboutCsv(
      _uploadedCsvContent!,
      question,
    );
    
    // Remove typing indicator and add answer
    if (answer != null) {
      _addMessageToChat(answer, isUser: false);
    } else {
      _addMessageToChat(
        'Sorry, I couldn\'t analyze that. Please try rephrasing your question.',
        isUser: false,
      );
    }
  }

  void _addMessageToChat(String message, {required bool isUser}) {
    // Implementation to add message to chat
    print('${isUser ? "User" : "AI"}: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Your chat UI here
  }
}
