/// Responsive breakpoints for the application
/// Based on common device sizes and web standards

class ResponsiveBreakpoints {
  // Private constructor to prevent instantiation
  ResponsiveBreakpoints._();

  /// Mobile devices (phones)
  /// - iPhone SE: 375px
  /// - iPhone 12/13: 390px
  /// - Most Android phones: 360-420px
  static const double mobile = 768;

  /// Tablet devices
  /// - iPad Mini: 768px
  /// - iPad: 810px
  /// - Android tablets: 800-900px
  static const double tablet = 1024;

  /// Desktop/Laptop screens
  /// - Small laptops: 1024px+
  /// - Standard monitors: 1366px+
  /// - Large monitors: 1920px+
  static const double desktop = 1024;

  /// Large desktop screens
  /// - Full HD: 1920px
  /// - 2K/QHD: 2560px
  /// - 4K: 3840px
  static const double largeDesktop = 1920;

  // Helper methods
  static bool isMobileWidth(double width) => width < mobile;
  static bool isTabletWidth(double width) => width >= mobile && width < desktop;
  static bool isDesktopWidth(double width) => width >= desktop;
  static bool isLargeDesktopWidth(double width) => width >= largeDesktop;

  /// Get responsive value based on screen width
  static T getResponsiveValue<T>({
    required double width,
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (width < ResponsiveBreakpoints.mobile) {
      return mobile;
    } else if (width < ResponsiveBreakpoints.desktop) {
      return tablet;
    } else {
      return desktop;
    }
  }
}
