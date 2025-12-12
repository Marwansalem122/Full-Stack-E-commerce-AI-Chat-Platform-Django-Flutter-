import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1440;

  // Device type checks with device pixel ratio compensation
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final aspectRatio = width / height;
    return (width >= mobileBreakpoint && width < desktopBreakpoint) ||
        (aspectRatio > 1.2 && aspectRatio < 1.8);
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largeDesktopBreakpoint;
  }

  // Screen size detection
  static Size getScreenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  static Orientation getOrientation(BuildContext context) =>
      MediaQuery.of(context).orientation;

  // Percentage calculations with orientation awaredness
  static double getHeightPercentage(BuildContext context, double percentage) {
    final height = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return (height - bottomInset) * (percentage / 100);
  }

  static double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  // Font size calculation with device pexel ratio awareness
  static double adaptiveFontSize(
    BuildContext context,
    double size, {
    double minSize = 12,
    double maxSize = 30,
  }) {
    final deviceWidth = MediaQuery.of(context).size.width;

    double scaleFactor;
    if (deviceWidth < mobileBreakpoint) {
      scaleFactor = 0.85 + (deviceWidth / mobileBreakpoint) * 0.15;
    } else if (deviceWidth < desktopBreakpoint) {
      scaleFactor = (deviceWidth / desktopBreakpoint) * 0.3 + 0.7;
    } else {
      scaleFactor = 1.0;
    }
    final adaptiveSize = size * scaleFactor;
    return adaptiveSize.clamp(minSize, maxSize);
  }

  static double getResponsiveWidth(
    BuildContext context, {
    required double forMobile,
    required double forTablet,
    required double forDesktop,
    double? forLargeDesktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    // Adjust values for landscape orientation on mobile/tablet
    final orientationFactor =
        (orientation == Orientation.landscape &&
            screenWidth < desktopBreakpoint)
        ? 0.8
        : 1.0;

    if (screenWidth >= largeDesktopBreakpoint && forLargeDesktop != null) {
      return forLargeDesktop * orientationFactor;
    } else if (screenWidth >= desktopBreakpoint) {
      return forDesktop * orientationFactor;
    } else if (screenWidth >= mobileBreakpoint) {
      return forTablet * orientationFactor;
    } else {
      return forMobile * orientationFactor;
    }
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double forMobile,
    required double forTablet,
    required double forDesktop,
    double? forLargeDesktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final densityFactor = devicePixelRatio > 2.5 ? 0.9 : 1.0;
    final orientationFactor = (isLandscape && screenWidth < desktopBreakpoint)
        ? 0.2
        : 1.0;

    if (screenWidth >= largeDesktopBreakpoint && forLargeDesktop != null) {
      return forLargeDesktop * densityFactor * orientationFactor;
    } else if (screenWidth >= desktopBreakpoint) {
      return forDesktop * densityFactor * orientationFactor;
    } else if (screenWidth >= mobileBreakpoint) {
      return forTablet * densityFactor * orientationFactor;
    } else {
      return forMobile * densityFactor * orientationFactor;
    }
  }

  // Grid count with orientation awareness
  static int getResponsiveGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (width >= largeDesktopBreakpoint) {
      return isLandscape ? 5 : 4;
    } else if (width >= desktopBreakpoint) {
      return isLandscape ? 4 : 3;
    } else if (width >= mobileBreakpoint) {
      return isLandscape ? 3 : 2;
    } else {
      return isLandscape ? 2 : 1;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    final width = MediaQuery.of(context).size.width;

    if (width >= desktopBreakpoint) {
      return EdgeInsets.fromLTRB(
        24.0 + safeArea.left,
        24.0 + safeArea.left,
        24.0 + safeArea.left,
        24.0 + safeArea.left,
      );
    } else if (width >= mobileBreakpoint) {
      return EdgeInsets.fromLTRB(
        16.0 + safeArea.left,
        16.0 + safeArea.left,
        16.0 + safeArea.left,
        16.0 + safeArea.left,
      );
    } else {
      return EdgeInsets.fromLTRB(
        12.0 + safeArea.left,
        12.0 + safeArea.left,
        12.0 + safeArea.left,
        12.0 + safeArea.left,
      );
    }
  }

  // Aspect ratio with orientation awareness
  static double getResponsiveAspectRatio(
    BuildContext context, {
    required double forMobile,
    required double forTablet,
    required double forDesktop,
    double? forLargeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final orientationFactor = isLandscape ? 1.2 : 1.0;

    if (width >= largeDesktopBreakpoint && forLargeDesktop != null) {
      return forLargeDesktop * orientationFactor;
    } else if (width >= desktopBreakpoint) {
      return forDesktop * orientationFactor;
    } else if (width >= mobileBreakpoint) {
      return forTablet * orientationFactor;
    } else {
      return forMobile * orientationFactor;
    }
  }

  // Responsive layout builder with smooth transitions
  static Widget buildResponsiveLayout(
    BuildContext context, {
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
    Widget? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktopBreakpoint && largeDesktop != null) {
      return largeDesktop;
    } else if (width >= desktopBreakpoint) {
      return desktop;
    } else if (width >= mobileBreakpoint) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Get safe horizontal padding for content
  static EdgeInsets getSafeHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= largeDesktopBreakpoint) {
      final horizontalPadding = max(24.0, (width - 1400) / 2);
      return EdgeInsets.symmetric(horizontal: horizontalPadding);
    } else if (width > desktopBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else if (width >= mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  // Helper function for max
  static double max(double a, double b) => a > b ? a : b;
}
