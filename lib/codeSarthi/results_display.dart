
import 'package:flutter/material.dart';
import 'package:cogni_sarthi/screens/results_display_screen.dart' as screens;

// This file is kept for backwards compatibility
// It now uses the updated ResultsDisplayScreen from lib/screens/
class ResultsDisplayScreen extends StatelessWidget {
  final String query;
  
  const ResultsDisplayScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return screens.ResultsDisplayScreen(query: query);
  }
}

// Old implementation kept for reference
class _OldResultsDisplayScreen extends StatelessWidget {
  final String query;
  
  const _OldResultsDisplayScreen({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Query Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Query',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(query, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Average Ore Grade: 0.85%'),
            const SizedBox(height: 32),
            const Text(
              'Detailed View',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ore Grade Trend',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Text(
                          '0.85%',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_upward, color: Colors.green),
                        Text('+5%', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    const Text('Last Quarter'),
                    const SizedBox(height: 16),
                    // Bar chart
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 1.0,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const titles = ['Q1', 'Q2', 'Q3', 'Q4'];
                                  if (value.toInt() >= 0 && value.toInt() < titles.length) {
                                    return Text(titles[value.toInt()]);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0.8, color: Colors.lightBlue)]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 0.7, color: Colors.lightBlue)]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 0.75, color: Colors.lightBlue)]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 0.85, color: Colors.blue)]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
