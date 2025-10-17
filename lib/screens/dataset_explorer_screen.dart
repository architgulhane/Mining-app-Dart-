import 'package:flutter/material.dart';

class DatasetExplorerScreen extends StatefulWidget {
  const DatasetExplorerScreen({super.key});

  @override
  State<DatasetExplorerScreen> createState() => _DatasetExplorerScreenState();
}

class _DatasetExplorerScreenState extends State<DatasetExplorerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Dataset Explorer',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF6B7280)),
            onPressed: _exportCurrentDataset,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: _refreshData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search in dataset...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF4F46E5),
                unselectedLabelColor: const Color(0xFF6B7280),
                indicatorColor: const Color(0xFF4F46E5),
                tabs: const [
                  Tab(text: 'Dataset 1 - Machines'),
                  Tab(text: 'Dataset 2 - Production'),
                  Tab(text: 'Dataset 3 - Downtime'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDatasetView(_getMachineData()),
          _buildDatasetView(_getProductionData()),
          _buildDatasetView(_getDowntimeData()),
        ],
      ),
    );
  }

  Widget _buildDatasetView(Map<String, dynamic> dataset) {
    final headers = dataset['headers'] as List<String>;
    final rows = dataset['rows'] as List<List<String>>;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dataset info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rows.length} rows × ${headers.length} columns',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: ${DateTime.now().toString().substring(0, 16)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Data table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF3F4F6)),
                columnSpacing: 40,
                horizontalMargin: 16,
                columns: headers
                    .map((header) => DataColumn(
                          label: Text(
                            header,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF111827),
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
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMachineData() {
    return {
      'headers': ['Machine ID', 'Status', 'OEE %', 'Runtime (hrs)', 'Downtime (hrs)'],
      'rows': [
        ['M-001', 'Active', '85.2', '156', '12'],
        ['M-002', 'Maintenance', '72.8', '142', '26'],
        ['M-003', 'Active', '91.5', '165', '3'],
        ['M-004', 'Active', '78.3', '149', '19'],
        ['M-005', 'Inactive', '0.0', '0', '168'],
        ['M-006', 'Active', '88.7', '160', '8'],
        ['M-007', 'Active', '82.1', '152', '16'],
        ['M-008', 'Active', '93.4', '167', '1'],
      ],
    };
  }

  Map<String, dynamic> _getProductionData() {
    return {
      'headers': ['Date', 'Shift', 'Units Produced', 'Target', 'Efficiency %'],
      'rows': [
        ['2024-10-08', 'A', '1250', '1300', '96.2'],
        ['2024-10-08', 'B', '1180', '1300', '90.8'],
        ['2024-10-08', 'C', '1100', '1300', '84.6'],
        ['2024-10-07', 'A', '1320', '1300', '101.5'],
        ['2024-10-07', 'B', '1240', '1300', '95.4'],
        ['2024-10-07', 'C', '1150', '1300', '88.5'],
        ['2024-10-06', 'A', '1280', '1300', '98.5'],
        ['2024-10-06', 'B', '1200', '1300', '92.3'],
      ],
    };
  }

  Map<String, dynamic> _getDowntimeData() {
    return {
      'headers': ['Machine', 'Start Time', 'Duration (min)', 'Reason', 'Impact'],
      'rows': [
        ['M-001', '08:15', '45', 'Mechanical Failure', 'High'],
        ['M-002', '10:30', '120', 'Planned Maintenance', 'Medium'],
        ['M-003', '14:20', '15', 'Material Shortage', 'Low'],
        ['M-004', '16:45', '60', 'Setup Change', 'Medium'],
        ['M-006', '09:00', '30', 'Minor Adjustment', 'Low'],
        ['M-007', '11:15', '90', 'Equipment Failure', 'High'],
        ['M-008', '13:40', '10', 'Short Stop', 'Low'],
      ],
    };
  }

  void _exportCurrentDataset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Dataset'),
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
                const SnackBar(content: Text('Exporting as Excel...')),
              );
            },
            child: const Text('Excel'),
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
        ],
      ),
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing data...')),
    );
  }
}
