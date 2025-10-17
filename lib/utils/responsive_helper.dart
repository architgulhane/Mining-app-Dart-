import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  // Get responsive padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  // Get responsive font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 24;
    } else if (isTablet(context)) {
      return 28;
    } else {
      return 32;
    }
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 14;
    } else {
      return 16;
    }
  }

  // Get responsive icon sizes
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 60;
    } else {
      return 80;
    }
  }

  // Get responsive spacing
  static double getVerticalSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 32;
    } else if (isTablet(context)) {
      return 48;
    } else {
      return 80;
    }
  }

  // Get grid columns for prompts
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1; // Single column on mobile
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 2;
    }
  }

  // Get max width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity; // Full width on mobile
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }
}
