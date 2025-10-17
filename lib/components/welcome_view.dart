import 'package:flutter/material.dart';
import 'quick_prompts_grid.dart';
import '../utils/responsive_helper.dart';

class WelcomeView extends StatelessWidget {
  final Function(String) onPromptSelected;
  
  const WelcomeView({
    super.key,
    required this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final iconSize = ResponsiveHelper.getIconSize(context);
    final titleSize = ResponsiveHelper.getTitleFontSize(context);
    final subtitleSize = ResponsiveHelper.getSubtitleFontSize(context);
    final verticalSpacing = ResponsiveHelper.getVerticalSpacing(context);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: horizontalPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isMobile ? 40 : verticalSpacing),
                // Welcome Icon
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  ),
                  child: Icon(
                    Icons.precision_manufacturing_outlined,
                    size: iconSize * 0.5,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                // Welcome Heading
                Text(
                  'Mining Operations Co-Pilot',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 8 : 12),
                // Welcome Subheading
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  child: Text(
                    'Ask questions about your mining operations and get instant insights',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isMobile ? 32 : 48),
                // Quick Prompts Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick Prompts',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                QuickPromptsGrid(onPromptSelected: onPromptSelected),
                SizedBox(height: isMobile ? 24 : 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
