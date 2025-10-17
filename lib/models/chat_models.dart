class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': isUser ? 'user' : 'assistant',
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Helper to get data for visualization
  Map<String, dynamic>? get data => metadata?['data'];
  String? get sqlQuery => metadata?['sql_query'];
  String? get chartType => metadata?['chart_type'];
  int? get rowCount => metadata?['row_count'];
  String? get intent => metadata?['intent'];
  bool get hasContext => metadata?['has_context'] ?? false;
}

class ChatSession {
  final String id;
  final String name;
  final String customer;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.name,
    required this.customer,
    required this.createdAt,
    required this.messages,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      name: json['name'] ?? 'New Session',
      customer: json['customer'] ?? 'cognecto',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'customer': customer,
      'created_at': createdAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}

class ChatRequest {
  final String message;
  final String customer;
  final String? sessionId;

  ChatRequest({
    required this.message,
    this.customer = 'cognecto',
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'customer': customer,
      if (sessionId != null) 'session_id': sessionId,
    };
  }
}

class ChatResponse {
  final String sessionId;
  final ChatMessage message;
  final bool success;
  final DateTime timestamp;

  ChatResponse({
    required this.sessionId,
    required this.message,
    required this.success,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      sessionId: json['session_id'] ?? '',
      message: ChatMessage.fromJson(json['response'] ?? {}),
      success: json['success'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
