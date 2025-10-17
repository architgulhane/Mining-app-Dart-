
import 'package:flutter/material.dart';
import 'package:cogni_sarthi/screens/data_source_management_screen.dart' as screens;

class DataSourceManagementScreen extends StatelessWidget {
  const DataSourceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const screens.DataSourceManagementScreen();
  }
}

// Old implementation kept for reference
class _OldDataSourceManagementScreen extends StatelessWidget {
  const _OldDataSourceManagementScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Data Sources'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Existing Connections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.storage, color: Colors.green),
                title: const Text('Mine Operations Database'),
                subtitle: const Text('Connected', style: TextStyle(color: Colors.green)),
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    _showDataSourceOptions(context, 'Mine Operations Database', true);
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.layers, color: Colors.red),
                title: const Text('Geological Survey Data'),
                subtitle: const Text('Disconnected', style: TextStyle(color: Colors.red)),
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    _showDataSourceOptions(context, 'Geological Survey Data', false);
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_queue, color: Colors.green),
                title: const Text('Environmental Monitoring'),
                subtitle: const Text('Connected', style: TextStyle(color: Colors.green)),
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    _showDataSourceOptions(context, 'Environmental Monitoring', true);
                  },
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add New Data Source'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Source Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Connection String',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data source added successfully')),
                          );
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Add New Source'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDataSourceOptions(BuildContext context, String sourceName, bool isConnected) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sourceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(isConnected ? Icons.link_off : Icons.link),
              title: Text(isConnected ? 'Disconnect' : 'Connect'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isConnected ? 'Disconnected from $sourceName' : 'Connected to $sourceName')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit functionality coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Data Source'),
                    content: Text('Are you sure you want to delete $sourceName?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$sourceName deleted')),
                          );
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
