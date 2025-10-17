import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? data; // For tables, charts, etc.
  
  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.data,
  });
}

class ChatView extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController? scrollController;
  
  const ChatView({
    super.key,
    required this.messages,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatMessageWidget(message: message);
      },
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  
  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 16 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              color: message.isUser
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              message.isUser ? Icons.person : Icons.smart_toy_outlined,
              size: isMobile ? 18 : 20,
              color: message.isUser ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.isUser ? 'You' : 'CogniSarthi',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFFEEF2FF)
                        : Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 14,
                          color: const Color(0xFF111827),
                          height: 1.5,
                        ),
                      ),
                      if (message.data != null) ...[
                        SizedBox(height: isMobile ? 12 : 16),
                        _buildDataVisualization(context, message.data!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  Widget _buildDataVisualization(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'table':
        return _buildTable(context, data);
      case 'chart':
        return _buildChartPlaceholder(context, data);
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildTable(BuildContext context, Map<String, dynamic> data) {
    final headers = data['headers'] as List<String>? ?? [];
    final rows = data['rows'] as List<List<String>>? ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
        dataRowMinHeight: isMobile ? 40 : 48,
        dataRowMaxHeight: isMobile ? 56 : 64,
        headingRowHeight: isMobile ? 44 : 56,
        columnSpacing: isMobile ? 24 : 56,
        horizontalMargin: isMobile ? 8 : 24,
        columns: headers
            .map((header) => DataColumn(
                  label: Text(
                    header,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 11 : 12,
                    ),
                  ),
                ))
            .toList(),
        rows: rows
            .map((row) => DataRow(
                  cells: row
                      .map((cell) => DataCell(
                            Text(
                              cell,
                              style: TextStyle(fontSize: isMobile ? 11 : 12),
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }
  
  Widget _buildChartPlaceholder(BuildContext context, Map<String, dynamic> data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      height: isMobile ? 180 : 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: isMobile ? 40 : 48,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              data['title'] ?? 'Chart',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
