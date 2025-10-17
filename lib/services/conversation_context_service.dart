import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing conversation context and history
/// Stores conversation history and handles contextual responses
class ConversationContextService {
  // Singleton pattern
  static final ConversationContextService _instance = ConversationContextService._internal();
  factory ConversationContextService() => _instance;
  ConversationContextService._internal();

  // Current session context
  final List<ConversationMessage> _conversationHistory = [];
  String? _currentSessionId;
  
  // Greeting patterns
  static const List<String> _greetingPatterns = [
    'hi', 'hello', 'hey', 'greetings', 'good morning', 'good afternoon', 
    'good evening', 'howdy', 'hiya', 'sup', 'what\'s up', 'whats up'
  ];

  /// Check if message is a greeting
  bool isGreeting(String message) {
    final lowerMessage = message.toLowerCase().trim();
    return _greetingPatterns.any((pattern) => 
      lowerMessage == pattern || 
      lowerMessage.startsWith('$pattern ') ||
      lowerMessage.startsWith('$pattern,')
    );
  }

  /// Get greeting response
  String getGreetingResponse() {
    return '''Hello! 👋 I'm CogniSarthi, your intelligent mining assistant.

I'm here to help you with:
• 📊 Equipment performance analysis
• ⏱️ Downtime tracking and prevention
• 📈 OEE (Overall Equipment Effectiveness) monitoring
• 🔧 Maintenance scheduling insights
• 📉 Production efficiency trends
• 💡 Data-driven recommendations

To get started, you can:
1. Upload your mining data (CSV, PDF, Excel files)
2. Ask me questions about your equipment and operations
3. Request specific analyses or reports

What would you like to know about your mining operations today?''';
  }

  /// Add message to conversation history
  void addMessage(String message, {required bool isUser, String? sessionId}) {
    final conversationMessage = ConversationMessage(
      content: message,
      isUser: isUser,
      timestamp: DateTime.now(),
      sessionId: sessionId ?? _currentSessionId,
    );
    
    _conversationHistory.add(conversationMessage);
    
    // Keep only last 50 messages to manage memory
    if (_conversationHistory.length > 50) {
      _conversationHistory.removeAt(0);
    }
    
    // Save to persistent storage
    _saveHistory();
  }

  /// Get conversation history
  List<ConversationMessage> getHistory({String? sessionId}) {
    if (sessionId != null) {
      return _conversationHistory
          .where((msg) => msg.sessionId == sessionId)
          .toList();
    }
    return List.from(_conversationHistory);
  }

  /// Get context for current conversation
  String getConversationContext({int lastNMessages = 5}) {
    if (_conversationHistory.isEmpty) {
      return 'No previous conversation history.';
    }

    final recentMessages = _conversationHistory
        .take(_conversationHistory.length)
        .toList()
        .reversed
        .take(lastNMessages)
        .toList()
        .reversed;

    final contextLines = recentMessages.map((msg) {
      final role = msg.isUser ? 'User' : 'CogniSarthi';
      return '$role: ${msg.content}';
    }).join('\n');

    return 'Previous conversation:\n$contextLines';
  }

  /// Get specific question by number (1st, 2nd, etc.)
  ConversationMessage? getQuestionByNumber(int questionNumber) {
    final userMessages = _conversationHistory
        .where((msg) => msg.isUser)
        .toList();

    if (questionNumber > 0 && questionNumber <= userMessages.length) {
      return userMessages[questionNumber - 1];
    }

    return null;
  }

  /// Handle contextual references like "first question", "previous question"
  String? resolveContextualReference(String message) {
    final lowerMessage = message.toLowerCase();

    // Check for ordinal references (1st, 2nd, first, second, etc.)
    final ordinalPatterns = {
      r'(first|1st)': 1,
      r'(second|2nd)': 2,
      r'(third|3rd)': 3,
      r'(fourth|4th)': 4,
      r'(fifth|5th)': 5,
    };

    for (var pattern in ordinalPatterns.entries) {
      final regex = RegExp(pattern.key);
      if (regex.hasMatch(lowerMessage) && 
          (lowerMessage.contains('question') || lowerMessage.contains('asked'))) {
        final question = getQuestionByNumber(pattern.value);
        if (question != null) {
          return '''You asked this as your ${_getOrdinalName(pattern.value)} question:
"${question.content}"

Asked at: ${_formatTimestamp(question.timestamp)}

Would you like me to elaborate on this question or provide additional information?''';
        } else {
          return 'I don\'t have a record of your ${_getOrdinalName(pattern.value)} question yet.';
        }
      }
    }

    // Check for "previous question"
    if (lowerMessage.contains('previous question') || 
        lowerMessage.contains('last question')) {
      final userMessages = _conversationHistory
          .where((msg) => msg.isUser)
          .toList();
      
      if (userMessages.length >= 2) {
        final previousQuestion = userMessages[userMessages.length - 2];
        return '''Your previous question was:
"${previousQuestion.content}"

Asked at: ${_formatTimestamp(previousQuestion.timestamp)}

Would you like me to revisit this topic?''';
      } else {
        return 'This is your first question, so there\'s no previous question to reference.';
      }
    }

    return null;
  }

  /// Build context-aware prompt for API
  String buildContextualPrompt(String userMessage) {
    if (_conversationHistory.length <= 1) {
      return userMessage; // No context needed for first message
    }

    final context = getConversationContext(lastNMessages: 5);
    
    return '''$context

Current question: $userMessage

Please provide a response that takes into account the conversation history above.''';
  }

  /// Start new session
  void startNewSession() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _conversationHistory.clear();
  }

  /// Clear all history
  void clearHistory() {
    _conversationHistory.clear();
    _saveHistory();
  }

  /// Get total questions asked
  int getTotalQuestionsAsked() {
    return _conversationHistory.where((msg) => msg.isUser).length;
  }

  /// Get conversation summary
  Map<String, dynamic> getConversationSummary() {
    final userMessages = _conversationHistory.where((msg) => msg.isUser).length;
    final aiMessages = _conversationHistory.where((msg) => !msg.isUser).length;
    
    return {
      'totalMessages': _conversationHistory.length,
      'userQuestions': userMessages,
      'aiResponses': aiMessages,
      'sessionId': _currentSessionId,
      'duration': _conversationHistory.isNotEmpty
          ? DateTime.now().difference(_conversationHistory.first.timestamp).inMinutes
          : 0,
    };
  }

  // Helper methods
  String _getOrdinalName(int number) {
    switch (number) {
      case 1: return 'first';
      case 2: return 'second';
      case 3: return 'third';
      case 4: return 'fourth';
      case 5: return 'fifth';
      default: return '${number}th';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  // Persistent storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _conversationHistory
          .map((msg) => msg.toJson())
          .toList();
      await prefs.setString('conversation_history', json.encode(historyJson));
    } catch (e) {
      print('Error saving conversation history: $e');
    }
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('conversation_history');
      
      if (historyString != null) {
        final List<dynamic> historyJson = json.decode(historyString);
        _conversationHistory.clear();
        _conversationHistory.addAll(
          historyJson.map((json) => ConversationMessage.fromJson(json))
        );
      }
    } catch (e) {
      print('Error loading conversation history: $e');
    }
  }

  /// Export conversation history
  String exportHistory() {
    final buffer = StringBuffer();
    buffer.writeln('CogniSarthi Conversation History');
    buffer.writeln('=================================');
    buffer.writeln('Exported: ${DateTime.now()}');
    buffer.writeln('');

    for (var msg in _conversationHistory) {
      buffer.writeln('${msg.isUser ? "User" : "CogniSarthi"} [${_formatTimestamp(msg.timestamp)}]:');
      buffer.writeln(msg.content);
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// Model for conversation message
class ConversationMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? sessionId;

  ConversationMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
    };
  }

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['sessionId'],
    );
  }
}
