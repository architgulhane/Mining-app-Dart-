import 'package:flutter/material.dart';

class ChatHistoryItem {
  final String id;
  final String title;
  final DateTime timestamp;
  
  ChatHistoryItem({
    required this.id,
    required this.title,
    required this.timestamp,
  });
}

class ChatHistoryItemWidget extends StatelessWidget {
  final ChatHistoryItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  
  const ChatHistoryItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          Icons.chat_bubble_outline,
          size: 18,
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          _formatTimestamp(item.timestamp),
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA3AF),
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.close, size: 16),
                color: const Color(0xFF9CA3AF),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class ChatHistoryList extends StatelessWidget {
  final List<ChatHistoryItem> items;
  final String? selectedId;
  final Function(ChatHistoryItem) onItemTap;
  final Function(ChatHistoryItem)? onItemDelete;
  
  const ChatHistoryList({
    super.key,
    required this.items,
    this.selectedId,
    required this.onItemTap,
    this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No chat history yet.\nStart a new conversation!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ChatHistoryItemWidget(
                  item: item,
                  isSelected: item.id == selectedId,
                  onTap: () => onItemTap(item),
                  onDelete: onItemDelete != null
                      ? () => onItemDelete!(item)
                      : null,
                );
              },
            ),
    );
  }
}
