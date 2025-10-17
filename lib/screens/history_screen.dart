import 'package:flutter/material.dart';

class HistoryItem {
  final String id;
  final String query;
  final String summary;
  final DateTime timestamp;
  final String resultType; // 'text', 'table', 'chart'
  
  HistoryItem({
    required this.id,
    required this.query,
    required this.summary,
    required this.timestamp,
    required this.resultType,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      id: '1',
      query: 'What was the average OEE last week?',
      summary: 'OEE averaged 78.5% with availability at 85%, performance at 92%, and quality at 95%.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      resultType: 'text',
    ),
    HistoryItem(
      id: '2',
      query: 'Show me the downtime pareto chart',
      summary: 'Mechanical failures account for 45% of downtime, followed by planned maintenance at 30%.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      resultType: 'chart',
    ),
    HistoryItem(
      id: '3',
      query: 'Compare shift performance',
      summary: 'Shift A leads with 82% OEE, Shift B at 76%, and Shift C at 71%.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      resultType: 'table',
    ),
    HistoryItem(
      id: '4',
      query: 'Top breakdown reasons this month',
      summary: 'Top reasons: mechanical failure (42%), material shortage (28%), planned maintenance (18%).',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      resultType: 'table',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Query History',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF6B7280)),
            onPressed: () {
              // Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF6B7280)),
            onPressed: () {
              // Implement filter
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyItems.length,
        itemBuilder: (context, index) {
          return _HistoryCard(
            item: _historyItems[index],
            onTap: () {
              // Reload query in chat view
              Navigator.of(context).pop();
            },
            onExport: (format) {
              _exportItem(_historyItems[index], format);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportAll,
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.download),
        label: const Text('Export All'),
      ),
    );
  }

  void _exportItem(HistoryItem item, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting as $format...')),
    );
  }

  void _exportAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export All History'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting as CSV...')),
              );
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting as JSON...')),
              );
            },
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting as PDF...')),
              );
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onTap;
  final Function(String) onExport;
  
  const _HistoryCard({
    required this.item,
    required this.onTap,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ResultTypeIcon(type: item.resultType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.query,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: onExport,
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'CSV', child: Text('Export as CSV')),
                      const PopupMenuItem(value: 'JSON', child: Text('Export as JSON')),
                      const PopupMenuItem(value: 'PDF', child: Text('Export as PDF')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(item.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class _ResultTypeIcon extends StatelessWidget {
  final String type;
  
  const _ResultTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'table':
        icon = Icons.table_chart;
        color = const Color(0xFF10B981);
        break;
      case 'chart':
        icon = Icons.bar_chart;
        color = const Color(0xFF3B82F6);
        break;
      default:
        icon = Icons.text_snippet;
        color = const Color(0xFF8B5CF6);
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
