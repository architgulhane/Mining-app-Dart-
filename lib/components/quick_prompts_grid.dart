import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class PromptSuggestion {
  final String title;
  final String description;
  final IconData icon;
  
  PromptSuggestion({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class PromptSuggestionWidget extends StatelessWidget {
  final PromptSuggestion suggestion;
  final VoidCallback onTap;
  
  const PromptSuggestionWidget({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    suggestion.icon,
                    size: isMobile ? 18 : 16,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 6),
            Text(
              suggestion.description,
              style: TextStyle(
                fontSize: isMobile ? 13 : 11,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickPromptsGrid extends StatelessWidget {
  final Function(String) onPromptSelected;
  
  const QuickPromptsGrid({
    super.key,
    required this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final gridColumns = ResponsiveHelper.getGridColumns(context);
    
    final prompts = [
      PromptSuggestion(
        title: 'OEE Summary',
        description: 'Get overall equipment effectiveness metrics',
        icon: Icons.analytics_outlined,
      ),
      PromptSuggestion(
        title: 'Top Breakdown Reasons',
        description: 'View most common machine breakdowns',
        icon: Icons.warning_amber_outlined,
      ),
      PromptSuggestion(
        title: 'Downtime Pareto',
        description: 'Analyze downtime distribution',
        icon: Icons.bar_chart_outlined,
      ),
      PromptSuggestion(
        title: 'Active vs Inactive Hours',
        description: 'Compare operational hours',
        icon: Icons.access_time_outlined,
      ),
      PromptSuggestion(
        title: 'MTBF per Machine',
        description: 'Mean time between failures analysis',
        icon: Icons.precision_manufacturing_outlined,
      ),
      PromptSuggestion(
        title: 'Shift Analysis',
        description: 'Compare performance across shifts',
        icon: Icons.schedule_outlined,
      ),
      PromptSuggestion(
        title: 'Short Stops',
        description: 'Identify brief production interruptions',
        icon: Icons.pause_circle_outline,
      ),
      PromptSuggestion(
        title: 'Machine Comparison',
        description: 'Compare metrics across machines',
        icon: Icons.compare_arrows_outlined,
      ),
      PromptSuggestion(
        title: 'Data Gaps',
        description: 'Detect missing data points',
        icon: Icons.error_outline,
      ),
      PromptSuggestion(
        title: 'Export Downtime',
        description: 'Download downtime reports',
        icon: Icons.download_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        childAspectRatio: isMobile ? 3.0 : 2.0, // Wider cards on mobile
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
      ),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        return PromptSuggestionWidget(
          suggestion: prompts[index],
          onTap: () => onPromptSelected(prompts[index].title),
        );
      },
    );
  }
}
