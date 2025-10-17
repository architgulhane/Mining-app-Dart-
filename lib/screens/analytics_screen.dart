import 'package:flutter/material.dart';
import 'package:cogni_sarthi/screens/analytics_detail_screen.dart';

class AnalyticsShortcut {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String query;
  final String analyticsType;
  
  AnalyticsShortcut({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.query,
    required this.analyticsType,
  });
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final List<AnalyticsShortcut> _shortcuts = [
    AnalyticsShortcut(
      title: 'Downtime Pareto Chart',
      description: 'View ranked causes of downtime',
      icon: Icons.bar_chart,
      color: const Color(0xFFEF4444),
      query: 'Show me the downtime pareto chart',
      analyticsType: 'downtime_pareto',
    ),
    AnalyticsShortcut(
      title: 'Shift A vs B Analysis',
      description: 'Compare performance between shifts',
      icon: Icons.compare_arrows,
      color: const Color(0xFF3B82F6),
      query: 'Compare Shift A and Shift B performance',
      analyticsType: 'shift_comparison',
    ),
    AnalyticsShortcut(
      title: 'OEE Summary Report',
      description: 'Overall equipment effectiveness overview',
      icon: Icons.analytics,
      color: const Color(0xFF10B981),
      query: 'Generate OEE summary report',
      analyticsType: 'oee_summary',
    ),
    AnalyticsShortcut(
      title: 'MTBF Analysis',
      description: 'Mean time between failures per machine',
      icon: Icons.timer,
      color: const Color(0xFFF59E0B),
      query: 'Show MTBF for all machines',
      analyticsType: 'mtbf_analysis',
    ),
    AnalyticsShortcut(
      title: 'Production Trends',
      description: 'View production over time',
      icon: Icons.trending_up,
      color: const Color(0xFF8B5CF6),
      query: 'Show production trends for last 30 days',
      analyticsType: 'production_trends',
    ),
    AnalyticsShortcut(
      title: 'Quality Metrics',
      description: 'Product quality analysis',
      icon: Icons.verified,
      color: const Color(0xFF06B6D4),
      query: 'Show quality metrics and defect rates',
      analyticsType: 'quality_metrics',
    ),
    AnalyticsShortcut(
      title: 'Short Stops Report',
      description: 'Brief production interruptions',
      icon: Icons.pause_circle,
      color: const Color(0xFFEC4899),
      query: 'Analyze short stops and micro stoppages',
      analyticsType: 'short_stops',
    ),
    AnalyticsShortcut(
      title: 'Machine Comparison',
      description: 'Compare all machine metrics',
      icon: Icons.compare,
      color: const Color(0xFF14B8A6),
      query: 'Compare performance across all machines',
      analyticsType: 'machine_comparison',
    ),
    AnalyticsShortcut(
      title: 'Availability Analysis',
      description: 'Active vs inactive time',
      icon: Icons.schedule,
      color: const Color(0xFF6366F1),
      query: 'Show active vs inactive hours analysis',
      analyticsType: 'availability',
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
          'Analytics Shortcuts',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            const Text(
              'Quick Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'One-tap access to prebuilt analytics queries',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _shortcuts.length,
              itemBuilder: (context, index) {
                return _ShortcutCard(
                  shortcut: _shortcuts[index],
                  onTap: () => _executeShortcut(_shortcuts[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _executeShortcut(AnalyticsShortcut shortcut) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalyticsDetailScreen(
          title: shortcut.title,
          description: shortcut.description,
          color: shortcut.color,
          analyticsType: shortcut.analyticsType,
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final AnalyticsShortcut shortcut;
  final VoidCallback onTap;
  
  const _ShortcutCard({
    required this.shortcut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: shortcut.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      shortcut.icon,
                      size: 24,
                      color: shortcut.color,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: shortcut.color,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortcut.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortcut.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
