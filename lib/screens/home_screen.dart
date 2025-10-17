import 'dart:io';
import 'package:flutter/material.dart';
import '../components/new_chat_button.dart';
import '../components/app_title.dart';
import '../components/chat_history_list.dart';
import '../components/sidebar_footer.dart';
import '../components/header_icons.dart';
import '../components/welcome_view.dart';
import '../components/chat_view.dart';
import '../components/chat_input_bar.dart';
import '../services/api_service.dart';
import '../services/conversation_context_service.dart';
import '../services/gemini_csv_service.dart';
import '../services/pdf_analysis_service.dart';
import '../services/excel_analysis_service.dart';
import '../services/chart_generation_service.dart';
import '../services/token_usage_guard.dart';
import '../services/secure_key_manager.dart';
import '../services/file_storage_service.dart';
import '../services/integrated_file_upload_service.dart';
import '../services/backend_api_service.dart';
import '../services/cognisarthi_backend_service.dart';
import '../widgets/backend_status_indicator.dart';
import '../models/chat_models.dart' as models;
import 'settings_modal.dart';
import 'help_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'dataset_explorer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ConversationContextService _contextService = ConversationContextService();
  
  // NEW: Enhanced services
  final GeminiCsvService _csvService = GeminiCsvService();
  final PdfAnalysisService _pdfService = PdfAnalysisService();
  final ExcelAnalysisService _excelService = ExcelAnalysisService();
  final ChartGenerationService _chartService = ChartGenerationService();
  final TokenUsageGuard _tokenGuard = TokenUsageGuard();
  final SecureKeyManager _keyManager = SecureKeyManager();
  final FileStorageService _fileStorage = FileStorageService();
  
  // Backend integration services
  final IntegratedFileUploadService _integratedUpload = IntegratedFileUploadService();
  final BackendApiService _backendApi = BackendApiService();
  final CogniSarthiBackendService _cogniSarthiBackend = CogniSarthiBackendService();
  
  final List<ChatHistoryItem> _chatHistory = [];
  final List<ChatMessage> _currentMessages = [];
  models.ChatSession? _currentSession;
  String? _selectedChatId;
  bool _isLoading = false;
  bool _showWelcome = true;
  bool _isBackendConnected = false;
  final ScrollController _chatScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // NEW: File and chart state
  String? _currentFileId;
  Map<String, dynamic>? _fileAnalysis;
  bool _showFilePanel = false;
  List<Map<String, dynamic>> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _contextService.loadHistory();
    _initializeBackendConnection();
  }
  
  Future<void> _initializeBackendConnection() async {
    // Check CogniSarthi backend availability
    final isAvailable = await _cogniSarthiBackend.checkBackendHealth();
    
    setState(() {
      _isBackendConnected = isAvailable;
    });
    
    if (isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Connected to CogniSarthi Backend'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Load suggested prompts from backend
      _loadSuggestedPrompts();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ CogniSarthi Backend offline'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Future<void> _loadSuggestedPrompts() async {
    try {
      final prompts = await _cogniSarthiBackend.getSuggestedPrompts();
      if (prompts.isNotEmpty) {
        print('[Home] Loaded ${prompts.length} suggested prompts from backend');
      }
    } catch (e) {
      print('[Home] Error loading suggested prompts: $e');
    }
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkBackendConnection() async {
    // Try multiple times with delay
    for (int i = 0; i < 3; i++) {
      try {
        final health = await _apiService.checkHealth();
        print('Backend connection successful: $health');
        setState(() {
          _isBackendConnected = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Connected to backend'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      } catch (e) {
        print('Backend connection attempt ${i + 1} failed: $e');
        if (i < 2) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    
    // All attempts failed
    setState(() {
      _isBackendConnected = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Backend not connected. Using mock data.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _startNewChat() async {
    setState(() {
      _currentMessages.clear();
      _selectedChatId = null;
      _showWelcome = true;
    });

    // Start new conversation context
    _contextService.startNewSession();

    // Clear backend session
    if (_isBackendConnected) {
      _cogniSarthiBackend.clearSession();
      print('[Home] Started new chat, cleared backend session');
    }
  }

  void _handlePromptSelected(String prompt) {
    _handleSendMessage(prompt);
  }

  Future<void> _handleSendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Check for "clear csv" command
    if (message.toLowerCase().trim() == 'clear csv') {
      _handleClearCsvCommand();
      return;
    }

    // Check if it's a greeting
    if (_contextService.isGreeting(message)) {
      final greetingResponse = _contextService.getGreetingResponse();
      
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: greetingResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _showWelcome = false;
        _currentMessages.add(userMessage);
        _currentMessages.add(aiMessage);
      });

      // Add to context
      _contextService.addMessage(message, isUser: true, sessionId: _selectedChatId);
      _contextService.addMessage(greetingResponse, isUser: false, sessionId: _selectedChatId);
      
      _scrollToBottom();
      return;
    }

    // Check for contextual references (e.g., "first question", "previous question")
    final contextualResponse = _contextService.resolveContextualReference(message);
    if (contextualResponse != null) {
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: contextualResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _showWelcome = false;
        _currentMessages.add(userMessage);
        _currentMessages.add(aiMessage);
      });

      // Add to context
      _contextService.addMessage(message, isUser: true, sessionId: _selectedChatId);
      _contextService.addMessage(contextualResponse, isUser: false, sessionId: _selectedChatId);
      
      _scrollToBottom();
      return;
    }

    // Check for file-related queries
    if (_currentFileId != null) {
      final fileResponse = await _handleFileQuery(message);
      if (fileResponse != null) {
        final userMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: message,
          isUser: true,
          timestamp: DateTime.now(),
        );

        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: fileResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );

        setState(() {
          _showWelcome = false;
          _currentMessages.add(userMessage);
          _currentMessages.add(aiMessage);
        });

        // Add to context
        _contextService.addMessage(message, isUser: true, sessionId: _selectedChatId);
        _contextService.addMessage(fileResponse, isUser: false, sessionId: _selectedChatId);
        
        _scrollToBottom();
        return;
      }
    }

    // Add user message immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _showWelcome = false;
      _isLoading = true;
      _currentMessages.add(userMessage);

      // Save to history if it's a new chat
      if (_selectedChatId == null) {
        final historyItem = ChatHistoryItem(
          id: userMessage.id,
          title: message,
          timestamp: DateTime.now(),
        );
        _chatHistory.insert(0, historyItem);
        _selectedChatId = userMessage.id;
      }
    });

    // Add user message to context
    _contextService.addMessage(message, isUser: true, sessionId: _selectedChatId);

    // Use CogniSarthi backend (dual mode: CSV context or backend database)
    if (_isBackendConnected || _cogniSarthiBackend.hasCsvContext) {
      try {
        // Determine which mode we're in
        if (_cogniSarthiBackend.hasCsvContext) {
          print('[Home] 📊 Querying CSV context: ${_cogniSarthiBackend.currentCsvFileName}');
        } else {
          print('[Home] 🌐 Querying backend database');
        }
        
        // Send message using dual-mode method
        final backendResponse = await _cogniSarthiBackend.sendMessage(
          message: message,
          sessionId: _cogniSarthiBackend.currentSessionId,
          customer: 'cognecto',
        );

        if (backendResponse != null && backendResponse['success'] == true) {
          // Parse backend response
          final parsedResponse = _cogniSarthiBackend.parseBackendResponse(backendResponse);
          
          // Update session ID
          _selectedChatId = backendResponse['session_id'] as String?;
          
          // Create AI message from backend response
          final aiMessage = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: parsedResponse['content'] as String,
            isUser: false,
            timestamp: DateTime.parse(parsedResponse['timestamp'] as String),
            data: parsedResponse['data'] as Map<String, dynamic>?,
          );

          setState(() {
            _isLoading = false;
            _currentMessages.add(aiMessage);
          });

          // Add AI response to context
          _contextService.addMessage(
            parsedResponse['content'] as String,
            isUser: false,
            sessionId: _selectedChatId
          );
          
          if (_cogniSarthiBackend.hasCsvContext) {
            print('[Home] ✅ CSV query processed successfully');
          } else {
            print('[Home] ✅ Backend response processed successfully');
          }
        } else {
          throw Exception('Backend returned unsuccessful response');
        }
      } catch (e) {
        // Log the error for debugging
        print('[Home] ❌ Backend API Error: $e');
        
        // Show specific error message
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backend Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        
        // Fallback to mock data
        _addMockResponse(message);
      }
    } else {
      // Use mock data when backend is not connected
      print('[Home] Backend not connected, using mock data');
      await Future.delayed(const Duration(seconds: 1));
      _addMockResponse(message);
    }

    // Scroll to bottom
    _scrollToBottom();
  }

  void _addMockResponse(String message) {
    final mockContent = _generateMockResponse(message);
    
    setState(() {
      _isLoading = false;
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: mockContent,
        isUser: false,
        timestamp: DateTime.now(),
        data: _generateMockData(message),
      );
      _currentMessages.add(aiMessage);
    });

    // Add mock response to context
    _contextService.addMessage(mockContent, isUser: false, sessionId: _selectedChatId);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Upload CSV file for context-based querying (NEW - Dual Mode Feature)
  Future<void> _uploadCsvForContext() async {
    try {
      print('[Home] Starting CSV context upload...');
      
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('[Home] 📁 CSV file picked: ${file.name}, size: ${file.size} bytes');
        print('[Home] 🔍 Has bytes: ${file.bytes != null}, Has path: ${file.path != null}');
        
        // Handle both web (bytes) and mobile (path) platforms
        Uint8List? fileBytes;
        
        if (file.bytes != null) {
          // Web platform: bytes are directly available
          print('[Home] 🌐 Using bytes from web platform');
          fileBytes = file.bytes;
        } else if (file.path != null) {
          // Mobile platform: need to read from file path
          print('[Home] 📂 Reading file from path: ${file.path}');
          try {
            final fileData = await File(file.path!).readAsBytes();
            fileBytes = fileData;
            print('[Home] ✅ File read successfully: ${fileBytes.length} bytes');
          } catch (e) {
            print('[Home] ❌ Error reading file: $e');
            _showSnackBar('❌ Error reading file: $e', Colors.red);
            return;
          }
        }
        
        if (fileBytes != null) {
          print('[Home] ⏳ Starting CSV upload to context manager...');
          setState(() {
            _isLoading = true;
          });

          // Upload to CSV context manager
          print('[Home] 🚀 Calling uploadCsvFile...');
          final uploadResult = await _cogniSarthiBackend.uploadCsvFile(
            fileBytes: fileBytes,
            fileName: file.name,
          );
          print('[Home] 📥 Upload result received: ${uploadResult['success']}');

          setState(() {
            _isLoading = false;
          });

          if (uploadResult['success'] == true) {
            // Add bot message with CSV summary
            final metadata = uploadResult['metadata'] as Map<String, dynamic>;
            final summary = uploadResult['summary'] as String? ?? 'CSV file loaded successfully.';
            final preview = uploadResult['preview'] as Map<String, dynamic>?;

            final botMessage = '''📊 **CSV Context Activated: ${file.name}**

$summary

**File Details:**
• Rows: ${metadata['rowCount']}
• Columns: ${metadata['columnCount']}
• Size: ${(metadata['fileSize'] / 1024).toStringAsFixed(2)} KB

**Columns:** ${(metadata['columns'] as List).join(', ')}

💡 **Now you can ask questions like:**
• "What's the average of [column name]?"
• "Show me the first 5 rows"
• "What's the maximum value in [column name]?"
• "Summarize the data"
• "Search for [keyword]"

🔄 **Type "clear csv" to return to database queries.**

✅ **All queries will now be answered from this CSV file.**''';

            setState(() {
              _currentMessages.add(ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                content: botMessage,
                isUser: false,
                timestamp: DateTime.now(),
              ));
            });

            _scrollToBottom();
            _showSnackBar('✅ CSV loaded! Ask questions about your data.', Colors.green);
            
            print('[Home] ✅ CSV context activated: ${file.name}');
          } else {
            _showSnackBar('❌ ${uploadResult['error']}', Colors.red);
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('❌ Error uploading CSV: $e', Colors.red);
      print('[Home] ❌ CSV upload error: $e');
    }
  }

  /// Handle "clear csv" command (NEW - Dual Mode Feature)
  void _handleClearCsvCommand() {
    _cogniSarthiBackend.clearCsvContext();
    
    final botMessage = '''✅ **CSV Context Cleared**

Switched back to backend database mode.

You can now query:
• Equipment status
• Production data
• Downtime analysis
• OEE metrics

📤 **Upload a new CSV anytime to analyze different data.**''';
    
    setState(() {
      _currentMessages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: botMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
    _showSnackBar('✅ Cleared CSV context. Back to database queries.', Colors.green);
    print('[Home] 🔄 CSV context cleared');
  }

  void _showSnackBar(String message, [Color? backgroundColor]) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Map<String, dynamic>? _convertBackendData(models.ChatMessage message) {
    if (message.data == null) return null;

    // Convert backend data format to UI format
    if (message.data is List) {
      final dataList = message.data as List;
      return {
        'type': 'table',
        'headers': dataList.isNotEmpty 
            ? (dataList[0] as Map).keys.toList() 
            : [],
        'rows': dataList.map((row) {
          final rowMap = row as Map;
          return rowMap.values.map((v) => v.toString()).toList();
        }).toList(),
      };
    }

    return null;
  }

  String _generateMockResponse(String query) {
    if (query.toLowerCase().contains('oee')) {
      return 'Based on the latest data, the Overall Equipment Effectiveness (OEE) for the past week averages 78.5%. This breaks down into:\n\n• Availability: 85%\n• Performance: 92%\n• Quality: 95%\n\nThe primary factors affecting OEE are unscheduled downtime and minor stoppages.';
    } else if (query.toLowerCase().contains('downtime')) {
      return 'Here\'s the downtime analysis for the requested period:\n\nTotal downtime: 42 hours\nTop 3 causes:\n1. Mechanical failure (45%)\n2. Planned maintenance (30%)\n3. Material shortage (15%)\n\nSee the breakdown table below for detailed information.';
    } else if (query.toLowerCase().contains('shift')) {
      return 'Shift performance comparison shows:\n\nShift A: 82% OEE\nShift B: 76% OEE\nShift C: 71% OEE\n\nShift A demonstrates the highest productivity, while Shift C shows opportunities for improvement in setup time and minor stoppages.';
    }
    
    return 'I\'ve analyzed your query about "${query.length > 50 ? '${query.substring(0, 50)}...' : query}". Here are the key insights based on the available data:\n\n• Data shows positive trends\n• Performance metrics are within expected ranges\n• Recommend monitoring over the next few days\n\nWould you like more detailed information on any specific aspect?';
  }

  Map<String, dynamic>? _generateMockData(String query) {
    if (query.toLowerCase().contains('downtime') || query.toLowerCase().contains('breakdown')) {
      return {
        'type': 'table',
        'headers': ['Machine', 'Downtime (hrs)', 'Reason', 'Impact'],
        'rows': [
          ['Machine A', '12.5', 'Mechanical failure', 'High'],
          ['Machine B', '8.2', 'Maintenance', 'Medium'],
          ['Machine C', '6.1', 'Material shortage', 'Medium'],
          ['Machine D', '4.8', 'Setup time', 'Low'],
        ],
      };
    } else if (query.toLowerCase().contains('pareto') || query.toLowerCase().contains('chart')) {
      return {
        'type': 'chart',
        'title': 'Downtime Pareto Analysis',
      };
    }
    return null;
  }

  void _handleHistoryItemTap(ChatHistoryItem item) {
    setState(() {
      _selectedChatId = item.id;
      _showWelcome = false;
      // In a real app, load the conversation history here
    });
  }

  void _handleHistoryItemDelete(ChatHistoryItem item) {
    setState(() {
      _chatHistory.removeWhere((i) => i.id == item.id);
      if (_selectedChatId == item.id) {
        _startNewChat();
      }
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => const SettingsModal(),
    );
  }

  void _showHelp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  void _navigateToHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _navigateToAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
  }

  void _navigateToDatasets() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DatasetExplorerScreen()),
    );
  }

  // ============ NEW: FILE UPLOAD METHODS ============
  
  Future<void> _uploadCSV() async {
    try {
      print('[HomeScreen] Starting CSV upload...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      
      if (result != null && result.files.first.bytes != null) {
        setState(() => _isLoading = true);
        
        final bytes = result.files.first.bytes!;
        final name = result.files.first.name;
        
        print('[HomeScreen] Uploading CSV: $name (${bytes.length} bytes)');
        print('[HomeScreen] Using mode: ${_integratedUpload.getCurrentMode()}');
        
        // Use integrated upload service (handles both backend and direct Gemini)
        final analysis = await _integratedUpload.uploadAndAnalyzeCsv(
          fileBytes: bytes,
          fileName: name,
        );
        
        if (analysis != null) {
          final source = analysis['source'] ?? 'unknown';
          print('[HomeScreen] CSV uploaded successfully via $source');
          
          setState(() {
            _currentFileId = analysis['fileId'];
            _fileAnalysis = analysis;
            _uploadedFiles.add({
              'id': analysis['fileId'],
              'name': name,
              'type': 'CSV',
              'time': DateTime.now(),
              'source': source,
            });
            _showFilePanel = true;
            _isLoading = false;
            
            // Add analysis to chat with source indicator
            final sourceEmoji = source == 'backend' ? '🔗' : '☁️';
            final aiMessage = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: '$sourceEmoji **CSV File Uploaded: $name** (via $source)\n\n${analysis['summary'] ?? 'File analyzed successfully!'}\n\n💡 You can now ask questions like:\n• "Show me row 5"\n• "What are the column names?"\n• "Generate a chart of sales vs month"\n• "Calculate average for column X"${source == 'backend' ? '\n• "Get database statistics"\n• "What equipment has the highest downtime?"' : ''}',
              isUser: false,
              timestamp: DateTime.now(),
            );
            _currentMessages.add(aiMessage);
          });
          
          _showSnackBar('✅ CSV uploaded via $source!', Colors.green);
          _scrollToBottom();
        } else {
          setState(() => _isLoading = false);
          _showSnackBar('❌ Failed to analyze CSV', Colors.red);
        }
      }
    } catch (e) {
      print('[HomeScreen] CSV upload error: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }
  
  Future<void> _uploadExcel() async {
    try {
      print('[HomeScreen] Starting Excel upload...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      
      if (result != null && result.files.first.bytes != null) {
        setState(() => _isLoading = true);
        
        final bytes = result.files.first.bytes!;
        final name = result.files.first.name;
        
        print('[HomeScreen] Uploading Excel: $name (${bytes.length} bytes)');
        print('[HomeScreen] Using mode: ${_integratedUpload.getCurrentMode()}');
        
        // Use integrated upload service
        final analysis = await _integratedUpload.uploadAndAnalyzeExcel(
          fileBytes: bytes,
          fileName: name,
        );
        
        if (analysis != null) {
          final source = analysis['source'] ?? 'unknown';
          print('[HomeScreen] Excel uploaded successfully via $source');
          
          setState(() {
            _currentFileId = analysis['fileId'];
            _fileAnalysis = analysis;
            _uploadedFiles.add({
              'id': analysis['fileId'],
              'name': name,
              'type': 'Excel',
              'time': DateTime.now(),
              'source': source,
            });
            _showFilePanel = true;
            _isLoading = false;
            
            // Add analysis to chat with source indicator
            final sourceEmoji = source == 'backend' ? '🔗' : '☁️';
            final aiMessage = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: '$sourceEmoji **Excel File Uploaded: $name** (via $source)\n\n${analysis['summary'] ?? 'File analyzed successfully!'}\n\n💡 You can now ask questions like:\n• "Show me row 5"\n• "What sheets are available?"\n• "Get value from cell A1"\n• "Search for keyword in the file"${source == 'backend' ? '\n• "Analyze production efficiency"\n• "Calculate OEE metrics"' : ''}',
              isUser: false,
              timestamp: DateTime.now(),
            );
            _currentMessages.add(aiMessage);
          });
          
          _showSnackBar('✅ Excel uploaded via $source!', Colors.green);
          _scrollToBottom();
        } else {
          setState(() => _isLoading = false);
          _showSnackBar('❌ Failed to analyze Excel', Colors.red);
        }
      }
    } catch (e) {
      print('[HomeScreen] Excel upload error: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }
  
  Future<void> _uploadPDF() async {
    try {
      print('[HomeScreen] Starting PDF upload...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null && result.files.first.bytes != null) {
        setState(() => _isLoading = true);
        
        final bytes = result.files.first.bytes!;
        final name = result.files.first.name;
        
        print('[HomeScreen] Uploading PDF: $name (${bytes.length} bytes)');
        print('[HomeScreen] Using mode: ${_integratedUpload.getCurrentMode()}');
        
        // Use integrated upload service
        final analysis = await _integratedUpload.uploadAndAnalyzePdf(
          fileBytes: bytes,
          fileName: name,
        );
        
        if (analysis != null) {
          final source = analysis['source'] ?? 'unknown';
          print('[HomeScreen] PDF uploaded successfully via $source');
          
          setState(() {
            _currentFileId = analysis['fileId'];
            _fileAnalysis = analysis;
            _uploadedFiles.add({
              'id': analysis['fileId'],
              'name': name,
              'type': 'PDF',
              'time': DateTime.now(),
              'source': source,
            });
            _showFilePanel = true;
            _isLoading = false;
            
            // Add analysis to chat with source indicator
            final sourceEmoji = source == 'backend' ? '🔗' : '☁️';
            final aiMessage = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: '$sourceEmoji **PDF File Uploaded: $name** (via $source)\n\n${analysis['summary'] ?? 'File analyzed successfully!'}\n\n💡 You can now ask questions like:\n• "Summarize this PDF"\n• "Extract tables from the PDF"\n• "What is this document about?"\n• "Find information about [topic]"${source == 'backend' ? '\n• "Search similar documents"\n• "Extract key insights"' : ''}',
              isUser: false,
              timestamp: DateTime.now(),
            );
            _currentMessages.add(aiMessage);
          });
          
          _showSnackBar('✅ PDF uploaded via $source!', Colors.green);
          _scrollToBottom();
        } else {
          setState(() => _isLoading = false);
          _showSnackBar('❌ Failed to analyze PDF', Colors.red);
        }
      }
    } catch (e) {
      print('[HomeScreen] PDF upload error: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }
  
  Future<String?> _handleFileQuery(String query) async {
    if (_currentFileId == null) return null;
    
    final lowerQuery = query.toLowerCase();
    
    try {
      // Row query: "show me row 5", "get row 10", "display row 3"
      final rowMatch = RegExp(r'(?:show|get|display|fetch).*?row\s+(\d+)', caseSensitive: false).firstMatch(query);
      if (rowMatch != null) {
        final rowNum = int.parse(rowMatch.group(1)!);
        final result = await _csvService.queryRow(fileId: _currentFileId!, rowNumber: rowNum);
        if (result != null) {
          final rowData = result['data'] as Map<String, dynamic>;
          final formatted = rowData.entries.map((e) => '• **${e.key}**: ${e.value}').join('\n');
          return '📊 **Row $rowNum:**\n\n$formatted';
        }
      }
      
      // Column names query
      if (lowerQuery.contains('column') && (lowerQuery.contains('name') || lowerQuery.contains('what'))) {
        if (_fileAnalysis?['columns'] != null) {
          final columns = (_fileAnalysis!['columns'] as List).join(', ');
          return '📋 **Column Names:**\n\n$columns';
        }
      }
      
      // Statistics query: "calculate average for sales", "stats for price column"
      final statsMatch = RegExp(r'(?:calculate|stats|statistics|average|mean|sum).*?(?:for|of)?\s+(\w+)', caseSensitive: false).firstMatch(query);
      if (statsMatch != null) {
        final columnName = statsMatch.group(1)!;
        final stats = await _csvService.calculateColumnStats(fileId: _currentFileId!, columnName: columnName);
        if (stats != null && stats['statistics'] != null) {
          final s = stats['statistics'];
          return '📊 **Statistics for "$columnName":**\n\n• Count: ${s['count']}\n• Mean: ${s['mean']?.toStringAsFixed(2)}\n• Min: ${s['min']}\n• Max: ${s['max']}\n• Sum: ${s['sum']?.toStringAsFixed(2)}';
        }
      }
      
      // Chart generation: "generate chart", "create bar chart", "show pie chart"
      if (lowerQuery.contains('chart') || lowerQuery.contains('graph') || lowerQuery.contains('plot')) {
        if (_fileAnalysis?['columns'] != null) {
          final columns = _fileAnalysis!['columns'] as List;
          if (columns.length >= 2) {
            // Try to generate a simple line chart with first two numeric columns
            final xCol = columns[0].toString();
            final yCol = columns[1].toString();
            
            return '📊 **Chart Generation**\n\nI can help you generate charts! To create a chart, I need:\n\n1. **X-axis column**: e.g., "$xCol"\n2. **Y-axis column**: e.g., "$yCol"\n\nYou can say:\n• "Create a line chart with $xCol and $yCol"\n• "Generate a bar chart"\n• "Show a pie chart"\n\nNote: Full chart visualization will be displayed in the next update!';
          }
        }
      }
      
      // Filter query: "filter rows where sales > 1000"
      if (lowerQuery.contains('filter') || lowerQuery.contains('where')) {
        return '🔍 **Filtering Data**\n\nI can filter your data! Try queries like:\n\n• "Show rows where [column] > 100"\n• "Filter by [column] = value"\n• "Get rows where [column] contains text"\n\nNote: Advanced filtering will be implemented in the next update!';
      }
      
      // Summary query
      if (lowerQuery.contains('summary') || lowerQuery.contains('summarize')) {
        final summary = await _csvService.autoSummarize(fileId: _currentFileId!);
        if (summary != null) {
          return '📋 **File Summary:**\n\n$summary';
        }
      }
      
      // Token usage query
      if (lowerQuery.contains('token') && (lowerQuery.contains('usage') || lowerQuery.contains('how many'))) {
        final usage = await _tokenGuard.getTodayUsage();
        final percentage = await _tokenGuard.getDailyUsagePercentage();
        return '🎫 **Token Usage Today:**\n\n• Used: ${usage.totalTokens} tokens\n• Percentage: ${percentage.toStringAsFixed(1)}%\n• Cost: \$${usage.totalCost.toStringAsFixed(4)}\n• Requests: ${usage.requestCount}';
      }
      
      // File info query
      if (lowerQuery.contains('file') && (lowerQuery.contains('info') || lowerQuery.contains('about'))) {
        if (_fileAnalysis != null) {
          final info = '📁 **File Information:**\n\n• ID: $_currentFileId\n• Type: ${_fileAnalysis!['type']}\n• Rows: ${_fileAnalysis!['rowCount'] ?? 'N/A'}\n• Columns: ${_fileAnalysis!['columnCount'] ?? 'N/A'}';
          return info;
        }
      }
      
    } catch (e) {
      return '❌ Error processing file query: $e';
    }
    
    return null; // Not a file query, let normal message handling continue
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      // Collapsible Drawer (like ChatGPT)
      drawer: Drawer(
        width: isMobile ? screenWidth * 0.85 : 280, // 85% width on mobile
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const AppTitle(),
                NewChatButton(onPressed: () {
                  Navigator.pop(context); // Close drawer
                  _startNewChat();
                }),
                const Divider(height: 1),
                // Navigation Menu
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _NavMenuItem(
                        icon: Icons.history,
                        label: 'History',
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          _navigateToHistory();
                        },
                      ),
                      _NavMenuItem(
                        icon: Icons.analytics_outlined,
                        label: 'Analytics',
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          _navigateToAnalytics();
                        },
                      ),
                      _NavMenuItem(
                        icon: Icons.dataset_outlined,
                        label: 'Datasets',
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          _navigateToDatasets();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ChatHistoryList(
                  items: _chatHistory,
                  selectedId: _selectedChatId,
                  onItemTap: (id) {
                    Navigator.pop(context); // Close drawer
                    _handleHistoryItemTap(id);
                  },
                  onItemDelete: _handleHistoryItemDelete,
                ),
                const SidebarFooter(),
              ],
            ),
          ),
        ),
      ),
      // Main content with hamburger menu
      body: Column(
        children: [
          // Header with hamburger menu
          SafeArea(
            bottom: false,
            child: Container(
              height: isMobile ? 56 : 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Hamburger menu button
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: const Color(0xFF6B7280),
                      size: isMobile ? 24 : 24,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    tooltip: 'Open menu',
                  ),
                  const Spacer(),
                  // Backend status indicator - HIDDEN
                  // BackendStatusIndicator(
                  //   isConnected: _isBackendConnected,
                  //   isUsingBackend: _integratedUpload.isUsingBackend,
                  //   onTap: () {
                  //     showDialog(
                  //       context: context,
                  //       builder: (context) => BackendStatusDialog(
                  //         isConnected: _isBackendConnected,
                  //         isUsingBackend: _integratedUpload.isUsingBackend,
                  //         onToggleBackend: () {
                  //           setState(() {
                  //             _integratedUpload.setUseBackend(!_integratedUpload.isUsingBackend);
                  //           });
                  //           _showSnackBar(
                  //             'Switched to ${_integratedUpload.getCurrentMode()}',
                  //             Colors.blue,
                  //           );
                  //         },
                  //         onRefreshStatus: () {
                  //           _initializeBackendConnection();
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),
                  // const SizedBox(width: 8),
                  // NEW: Token usage indicator
                  FutureBuilder<double>(
                    future: _tokenGuard.getDailyUsagePercentage(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final percent = snapshot.data!;
                        final color = percent > 80 
                          ? Colors.red 
                          : percent > 50 
                            ? Colors.orange 
                            : Colors.green;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.token, size: 14, color: color),
                              const SizedBox(width: 4),
                              Text(
                                '${percent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(width: 8),
                  HeaderIcons(
                    onSettingsTap: _showSettings,
                    onRefreshTap: _startNewChat,
                    onHelpTap: _showHelp,
                  ),
                ],
              ),
            ),
          ),
          // NEW: File upload toolbar (collapsible)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // File upload buttons removed
                  // Text(
                  //   'Upload Files:',
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     color: Colors.grey[600],
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  // const SizedBox(width: 12),
                  // _FileUploadButton(
                  //   icon: Icons.table_chart,
                  //   label: 'CSV',
                  //   onPressed: _uploadCSV,
                  //   color: Colors.green,
                  // ),
                  // const SizedBox(width: 8),
                  // _FileUploadButton(
                  //   icon: Icons.description,
                  //   label: 'Excel',
                  //   onPressed: _uploadExcel,
                  //   color: Colors.blue,
                  // ),
                  // const SizedBox(width: 8),
                  // _FileUploadButton(
                  //   icon: Icons.picture_as_pdf,
                  //   label: 'PDF',
                  //   onPressed: _uploadPDF,
                  //   color: Colors.red,
                  // ),
                  const Spacer(),
                  if (_uploadedFiles.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.folder, size: 16),
                      label: Text('${_uploadedFiles.length} files'),
                      labelStyle: const TextStyle(fontSize: 12),
                      visualDensity: VisualDensity.compact,
                      onDeleted: () {
                        setState(() => _showFilePanel = !_showFilePanel);
                      },
                      deleteIcon: Icon(
                        _showFilePanel ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // NEW: File analysis panel (collapsible)
          if (_showFilePanel && _fileAnalysis != null)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'File Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _showFilePanel = false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_fileAnalysis!['summary'] != null)
                      Text(
                        _fileAnalysis!['summary'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    if (_fileAnalysis!['rowCount'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            _InfoChip('Rows: ${_fileAnalysis!['rowCount']}'),
                            if (_fileAnalysis!['columnCount'] != null)
                              _InfoChip('Columns: ${_fileAnalysis!['columnCount']}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // Main content area
          Expanded(
            child: _showWelcome
                ? WelcomeView(onPromptSelected: _handlePromptSelected)
                : ChatView(
                    messages: _currentMessages,
                    scrollController: _chatScrollController,
                  ),
          ),
          // Chat input bar
          ChatInputBar(
            onSendMessage: _handleSendMessage,
            onVoiceInput: () {
              // Implement voice input
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice input coming soon')),
              );
            },
            onCsvUpload: _uploadCsvForContext,
            isLoading: _isLoading,
            hasCsvContext: _cogniSarthiBackend.hasCsvContext,
          ),
        ],
      ),
    );
  }
}

class _NavMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _NavMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF111827),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// NEW: File upload button widget
class _FileUploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _FileUploadButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// NEW: Info chip widget
class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11),
      backgroundColor: Colors.white,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
