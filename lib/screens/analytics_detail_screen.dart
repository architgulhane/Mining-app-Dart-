import 'package:flutter/material.dart';

class AnalyticsDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final String analyticsType;

  const AnalyticsDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.analyticsType,
  });

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
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF111827)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing data...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF111827)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading report...')),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Render analytics based on type
            _buildAnalyticsContent(analyticsType, color),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(String type, Color color) {
    switch (type) {
      case 'downtime_pareto':
        return _buildDowntimeParetoChart(color);
      case 'shift_comparison':
        return _buildShiftComparisonChart(color);
      case 'oee_summary':
        return _buildOEESummaryChart(color);
      case 'mtbf_analysis':
        return _buildMTBFAnalysisChart(color);
      case 'production_trends':
        return _buildProductionTrendsChart(color);
      case 'quality_metrics':
        return _buildQualityMetricsChart(color);
      case 'short_stops':
        return _buildShortStopsChart(color);
      case 'machine_comparison':
        return _buildMachineComparisonChart(color);
      case 'availability':
        return _buildAvailabilityChart(color);
      default:
        return _buildGenericChart(color);
    }
  }

  Widget _buildDowntimeParetoChart(Color color) {
    final causes = [
      {'name': 'Mechanical Failure', 'hours': 42, 'percentage': 35},
      {'name': 'Material Shortage', 'hours': 28, 'percentage': 23},
      {'name': 'Changeover Time', 'hours': 21, 'percentage': 18},
      {'name': 'Maintenance', 'hours': 15, 'percentage': 12},
      {'name': 'Other', 'hours': 14, 'percentage': 12},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Downtime by Cause', 'Pareto analysis showing top contributors'),
        const SizedBox(height: 16),
        
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Total Downtime', '120 hrs', color, Icons.timer_off),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard('Top Cause', '35%', color, Icons.trending_up),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Bar Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: causes.map((cause) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cause['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '${cause['hours']} hrs (${cause['percentage']}%)',
                          style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (cause['percentage'] as int) / 100,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard('Key Insight', 'Mechanical failures account for 35% of downtime. Recommend preventive maintenance schedule review.', color),
      ],
    );
  }

  Widget _buildShiftComparisonChart(Color color) {
    final shifts = [
      {'name': 'Shift A', 'oee': 82, 'production': 4500, 'quality': 96},
      {'name': 'Shift B', 'oee': 76, 'production': 4200, 'quality': 94},
      {'name': 'Shift C', 'oee': 71, 'production': 3800, 'quality': 92},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Shift Performance Comparison', 'OEE, Production & Quality metrics'),
        const SizedBox(height: 16),
        
        ...shifts.map((shift) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift['name'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildShiftMetric('OEE', '${shift['oee']}%', color)),
                      Expanded(child: _buildShiftMetric('Production', '${shift['production']}', color)),
                      Expanded(child: _buildShiftMetric('Quality', '${shift['quality']}%', color)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        
        _buildInsightCard('Analysis', 'Shift A demonstrates the highest OEE at 82%. Shift C shows opportunities for improvement in setup time reduction.', color),
      ],
    );
  }

  Widget _buildOEESummaryChart(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Overall Equipment Effectiveness', 'Comprehensive OEE breakdown'),
        const SizedBox(height: 16),
        
        // OEE Gauge
        Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 0.76,
                      strokeWidth: 12,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '76%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text(
                        'Overall OEE',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // OEE Components
        Row(
          children: [
            Expanded(child: _buildMetricCard('Availability', '85%', color, Icons.check_circle)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Performance', '92%', color, Icons.speed)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Quality', '97%', color, Icons.verified)),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildInsightCard('Recommendation', 'Overall OEE of 76% is good. Focus on improving availability through reduced downtime to reach world-class 85%+.', color),
      ],
    );
  }

  Widget _buildMTBFAnalysisChart(Color color) {
    final machines = [
      {'name': 'Machine A', 'mtbf': 180, 'failures': 5, 'status': 'Good'},
      {'name': 'Machine B', 'mtbf': 145, 'failures': 8, 'status': 'Fair'},
      {'name': 'Machine C', 'mtbf': 210, 'failures': 3, 'status': 'Excellent'},
      {'name': 'Machine D', 'mtbf': 120, 'failures': 12, 'status': 'Needs Attention'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mean Time Between Failures', 'Reliability analysis per machine'),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: _buildMetricCard('Avg MTBF', '164 hrs', color, Icons.timer)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Total Failures', '28', color, Icons.error_outline)),
          ],
        ),
        const SizedBox(height: 24),
        
        ...machines.map((machine) {
          Color statusColor = machine['status'] == 'Excellent' 
              ? const Color(0xFF10B981)
              : machine['status'] == 'Good'
                  ? const Color(0xFF3B82F6)
                  : machine['status'] == 'Fair'
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          machine['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          machine['status'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${machine['mtbf']} hrs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const Text(
                          'MTBF',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${machine['failures']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const Text(
                          'Failures',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        
        const SizedBox(height: 16),
        _buildInsightCard('Action Required', 'Machine D shows low MTBF of 120 hours. Schedule comprehensive maintenance review and part replacement analysis.', color),
      ],
    );
  }

  Widget _buildProductionTrendsChart(Color color) {
    final months = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
    final production = [4200, 4500, 4800, 4600, 5100, 5400];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Production Over Time', 'Last 6 months trend analysis'),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: _buildMetricCard('Current', '5,400 units', color, Icons.widgets)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Growth', '+28.6%', const Color(0xFF10B981), Icons.trending_up)),
          ],
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              const Text(
                'Monthly Production Units',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(months.length, (index) {
                    final maxProduction = 6000;
                    final barHeight = (production[index] / maxProduction) * 180;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(production[index] / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [color, color.withOpacity(0.6)],
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[index],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard('Trend Analysis', 'Production showing consistent 6% monthly growth. Current trajectory exceeds Q1 targets by 12%.', color),
      ],
    );
  }

  Widget _buildQualityMetricsChart(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quality Performance', 'Defect rates and first-pass yield'),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: _buildMetricCard('First Pass Yield', '96.8%', color, Icons.check_circle)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Defect Rate', '0.32%', const Color(0xFFEF4444), Icons.error)),
          ],
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Defect Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              _buildDefectRow('Dimensional Issues', 45, color),
              _buildDefectRow('Surface Defects', 28, color),
              _buildDefectRow('Material Flaws', 18, color),
              _buildDefectRow('Assembly Errors', 9, color),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard('Quality Status', 'First-pass yield of 96.8% exceeds industry benchmark. Focus on dimensional accuracy to further reduce defects.', color),
      ],
    );
  }

  Widget _buildShortStopsChart(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Short Stops Analysis', 'Micro stoppages under 10 minutes'),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: _buildMetricCard('Total Stops', '142', color, Icons.pause_circle)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Time Lost', '18.5 hrs', color, Icons.timer)),
          ],
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _buildStopCauseRow('Minor Jams', 48, 34, color),
              _buildStopCauseRow('Sensor Triggers', 38, 27, color),
              _buildStopCauseRow('Material Feed', 32, 23, color),
              _buildStopCauseRow('Other', 24, 16, color),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard('Improvement Opportunity', '142 short stops resulted in 18.5 hours of lost production. Address minor jam root causes to recover 6+ hours monthly.', color),
      ],
    );
  }

  Widget _buildMachineComparisonChart(Color color) {
    final machines = [
      {'name': 'Machine A', 'utilization': 87, 'uptime': 94, 'output': 4500},
      {'name': 'Machine B', 'utilization': 82, 'uptime': 91, 'output': 4200},
      {'name': 'Machine C', 'utilization': 78, 'uptime': 88, 'output': 3900},
      {'name': 'Machine D', 'utilization': 85, 'uptime': 92, 'output': 4300},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Machine Performance Comparison', 'Utilization, uptime and output metrics'),
        const SizedBox(height: 16),
        
        ...machines.map((machine) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMachineMetricBar('Utilization', machine['utilization'] as int, color),
                  const SizedBox(height: 8),
                  _buildMachineMetricBar('Uptime', machine['uptime'] as int, const Color(0xFF10B981)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Output',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${machine['output']} units',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        
        _buildInsightCard('Performance Leader', 'Machine A demonstrates highest utilization at 87% with 4,500 units output. Consider its operational practices as best practice benchmark.', color),
      ],
    );
  }

  Widget _buildAvailabilityChart(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Availability Analysis', 'Active vs inactive time breakdown'),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: _buildMetricCard('Active Time', '672 hrs', color, Icons.play_circle)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Availability', '89.6%', color, Icons.schedule)),
          ],
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: 0.896,
                      strokeWidth: 20,
                      backgroundColor: const Color(0xFFEF4444).withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '89.6%',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '672 hrs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '78 hrs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard('Target Status', 'Availability at 89.6% is approaching the 90% target. Focus on reducing unplanned downtime to bridge the 0.4% gap.', color),
      ],
    );
  }

  Widget _buildGenericChart(Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.analytics, size: 64, color: color.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Analytics data loading...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color.withOpacity(0.7)),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildDefectRow(String category, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCauseRow(String cause, int count, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              cause,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              '$count stops',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineMetricBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
