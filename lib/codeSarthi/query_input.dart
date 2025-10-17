
import 'package:flutter/material.dart';
import 'package:cogni_sarthi/screens/query_input_screen.dart' as screens;

// This file is kept for backwards compatibility
// It now uses the updated QueryInputScreen from lib/screens/
class QueryInputScreen extends StatelessWidget {
  const QueryInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const screens.QueryInputScreen();
  }
}

class _QueryInputScreenState extends State<QueryInputScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mining Data Query'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Mine Insights'),
                  content: const Text('Ask questions about your mining operations in plain language and get instant, insightful answers.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                hintText: 'Enter your query...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ask questions about mining operations, such as \"Show me the average ore grade for the last quarter\".',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_queryController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultsDisplayScreen(query: _queryController.text),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a query')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataSourceManagementScreen()),
                );
              },
              icon: const Icon(Icons.storage),
              label: const Text('Manage Data Sources'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
