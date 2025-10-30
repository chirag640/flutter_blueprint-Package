/// Responsive and adaptive UI components for multi-platform projects.
/// Uses flutter_screenutil for scalable sizing with LayoutBuilder and MediaQuery for layouts.
library;

/// Generates responsive layout utilities and adaptive widgets.
class ResponsiveComponents {
  /// Generate screen utility class with flutter_screenutil + custom breakpoints
  static String screenUtilConfig() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Screen configuration and breakpoints using flutter_screenutil
class AppScreen {
  const AppScreen._();

  /// Design size (based on mobile design)
  static const designSize = Size(375, 812); // iPhone 11 Pro size
  
  // Breakpoints for responsive layouts
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1280;
  
  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }
  
  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return DeviceType.desktop;
    if (width >= mobileBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }
  
  /// Get responsive value based on device type
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop;
}

/// Extension for easy responsive sizing
extension ResponsiveSizing on num {
  /// Responsive width (based on design width 375)
  double get w => ScreenUtil().setWidth(this);
  
  /// Responsive height (based on design height 812)
  double get h => ScreenUtil().setHeight(this);
  
  /// Responsive font size
  double get sp => ScreenUtil().setSp(this);
  
  /// Responsive radius
  double get r => ScreenUtil().radius(this);
  
  /// Screen width percentage (0.0 - 1.0)
  double get sw => ScreenUtil().screenWidth * this;
  
  /// Screen height percentage (0.0 - 1.0)
  double get sh => ScreenUtil().screenHeight * this;
}
''';
  }

  /// Generate responsive layout widget using LayoutBuilder
  static String responsiveLayoutWidget() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screen_util_config.dart';

/// A widget that builds different layouts based on screen size using LayoutBuilder
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use constraints.maxWidth for reliable breakpoint detection
        final width = constraints.maxWidth;
        
        if (width >= AppScreen.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= AppScreen.mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A widget that provides responsive values using MediaQuery + custom logic
class ResponsiveValue<T> extends StatelessWidget {
  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(BuildContext context) {
    final T value = AppScreen.responsive<T>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return builder(context, value);
  }
}

/// Responsive padding widget using flutter_screenutil
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = 16.0,
    this.tablet,
    this.desktop,
  });

  final Widget child;
  final double mobile;
  final double? tablet;
  final double? desktop;

  @override
  Widget build(BuildContext context) {
    final padding = AppScreen.responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    
    return Padding(
      padding: EdgeInsets.all(padding.w), // Use .w for responsive sizing
      child: child,
    );
  }
}
''';
  }

  /// Generate adaptive navigation scaffold using MediaQuery for breakpoints
  static String adaptiveScaffold() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screen_util_config.dart';

/// Adaptive scaffold that changes navigation based on screen size
/// Mobile: Bottom navigation bar
/// Tablet: Navigation rail
/// Desktop: Navigation drawer with rail
class AdaptiveNavigationScaffold extends StatelessWidget {
  const AdaptiveNavigationScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for reliable screen size detection
    final deviceType = AppScreen.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.desktop:
        return _buildDesktopLayout(context);
      case DeviceType.tablet:
        return _buildTabletLayout(context);
      case DeviceType.mobile:
        return _buildMobileLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: actions,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: destinations
                .map(
                  (dest) => NavigationRailDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon ?? dest.icon,
                    label: Text(dest.label),
                  ),
                )
                .toList(),
          ),
          VerticalDivider(thickness: 1.w, width: 1.w),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: actions,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: true,
            labelType: NavigationRailLabelType.none,
            destinations: destinations
                .map(
                  (dest) => NavigationRailDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon ?? dest.icon,
                    label: Text(dest.label),
                  ),
                )
                .toList(),
          ),
          VerticalDivider(thickness: 1.w, width: 1.w),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
''';
  }

  /// Generate responsive spacing helper using flutter_screenutil
  static String responsiveSpacingHelper() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screen_util_config.dart';

/// Helper class for responsive spacing using flutter_screenutil
class AppSpacing {
  const AppSpacing._();

  // Base spacing units (will be scaled by ScreenUtil)
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  /// Get responsive padding based on device type
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.all(
      AppScreen.responsive<double>(
        context,
        mobile: 16.w,
        tablet: 24.w,
        desktop: 32.w,
      ),
    );
  }

  /// Get horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: AppScreen.responsive<double>(
        context,
        mobile: 16.w,
        tablet: 32.w,
        desktop: 48.w,
      ),
    );
  }

  /// Get vertical padding
  static EdgeInsets verticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: AppScreen.responsive<double>(
        context,
        mobile: 16.w,
        tablet: 24.w,
        desktop: 32.w,
      ),
    );
  }

  /// Get responsive content width constraint
  static double getContentWidth(BuildContext context) {
    final screenWidth = ScreenUtil().screenWidth;
    return AppScreen.responsive<double>(
      context,
      mobile: screenWidth,
      tablet: screenWidth * 0.85,
      desktop: screenWidth * 0.7,
    );
  }

  /// Get responsive grid column count using MediaQuery + custom logic
  static int getGridColumns(BuildContext context) {
    return AppScreen.responsive<int>(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  /// Get responsive font size
  static double fontSize(double size) => size.sp;

  /// Get responsive border radius
  static double radius(double size) => size.r;
}

/// Common responsive sizes for consistency
class AppSizes {
  const AppSizes._();

  // Icon sizes
  static double get iconXs => 16.w;
  static double get iconSm => 20.w;
  static double get iconMd => 24.w;
  static double get iconLg => 32.w;
  static double get iconXl => 48.w;

  // Button heights
  static double get buttonHeightSm => 36.h;
  static double get buttonHeightMd => 48.h;
  static double get buttonHeightLg => 56.h;

  // Border radius
  static double get radiusXs => 4.r;
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 24.r;
  static double get radiusRound => 999.r;
}
''';
  }

  /// Generate platform detector utility
  static String platformDetector() {
    return '''
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Platform detection utility for conditional logic
class PlatformInfo {
  const PlatformInfo._();

  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile (iOS or Android)
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if running on desktop (Windows, macOS, or Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Check if running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Check if running on iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Check if running on Windows
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// Check if running on macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// Check if running on Linux
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  /// Get platform name as string
  static String get platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
''';
  }
}
