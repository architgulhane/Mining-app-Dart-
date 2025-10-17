
import 'package:flutter/material.dart';
import 'package:cogni_sarthi/screens/query_history_screen.dart' as screens;

// This file is kept for backwards compatibility
// It now uses the updated QueryHistoryScreen from lib/screens/
class QueryHistoryScreen extends StatelessWidget {
  const QueryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const screens.QueryHistoryScreen();
  }
}

// Old implementation kept for reference
class _OldQueryHistoryScreen extends StatelessWidget {
  const _OldQueryHistoryScreen();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> queryHistory = [
      {
        'query': 'What is the average ore grade for the last quarter?',
        'date': '2024-07-20 14:30',
      },
      {
        'query': 'Show me the production output for the last month',
        'date': '2024-07-19 10:15',
      },
      {
        'query': 'Compare the energy consumption of different sites',
        'date': '2024-07-18 16:45',
      },
      {
        'query': 'What is the current stockpile level for iron ore?',
        'date': '2024-07-17 09:30',
      },
      {
        'query': 'Analyze the safety incidents reported in Q2',
        'date': '2024-07-16 11:23',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all query history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History cleared')),
                        );
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: queryHistory.length,
        itemBuilder: (context, index) {
          final item = queryHistory[index];
          return ListTile(
            title: Text(item['query']!),
            subtitle: Text(item['date']!),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultsDisplayScreen(query: item['query']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
