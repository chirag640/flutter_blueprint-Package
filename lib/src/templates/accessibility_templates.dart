/// Accessibility (a11y) template generators for Flutter Blueprint.
///
/// This module provides production-ready accessibility utilities including
/// Semantics helpers, contrast checking, focus management, and testing utilities.
/// Generates WCAG 2.1 compliant accessibility scaffolding.
library;

/// Generates the SemanticsHelper utility class.
///
/// Provides convenient widget wrappers for proper semantic annotations,
/// making widgets accessible to screen readers (TalkBack/VoiceOver).
String generateSemanticsHelper() {
  return r'''
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Helper class for adding semantic annotations to widgets.
///
/// Use these wrappers to ensure proper screen reader support across iOS/Android.
/// All interactive elements should have meaningful labels and hints.
///
/// Example:
/// ```dart
/// SemanticsHelper.button(
///   label: 'Add to cart',
///   hint: 'Double tap to add this item to your shopping cart',
///   child: IconButton(
///     icon: Icon(Icons.add_shopping_cart),
///     onPressed: () => addToCart(),
///   ),
/// )
/// ```
class SemanticsHelper {
  const SemanticsHelper._();

  /// Minimum touch target size for Android (48x48 dp).
  static const double minTouchTargetAndroid = 48.0;
  
  /// Minimum touch target size for iOS (44x44 pt).
  static const double minTouchTargetIOS = 44.0;

  /// Wraps a button with proper semantics.
  ///
  /// [label] is read by screen readers to describe the button.
  /// [hint] provides additional context about what happens when activated.
  static Widget button({
    required String label,
    String? hint,
    required Widget child,
    bool isEnabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      hint: hint,
      child: child,
    );
  }

  /// Wraps an image with proper semantics.
  ///
  /// [description] should describe the image content for screen readers.
  /// Use [isDecorative] for images that don't convey information.
  static Widget image({
    required String description,
    required Widget child,
    bool isDecorative = false,
  }) {
    if (isDecorative) {
      return ExcludeSemantics(child: child);
    }
    return Semantics(
      image: true,
      label: description,
      child: child,
    );
  }

  /// Wraps a text field with proper semantics.
  ///
  /// [label] describes what information the field expects.
  /// [hint] provides input guidance.
  /// [errorText] announces validation errors to screen readers.
  static Widget textField({
    required String label,
    String? hint,
    String? errorText,
    required Widget child,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      value: errorText,
      child: child,
    );
  }

  /// Wraps a header/title with proper semantics.
  ///
  /// Screen readers will announce this as a heading.
  static Widget header({
    required String text,
    required Widget child,
  }) {
    return Semantics(
      header: true,
      label: text,
      child: child,
    );
  }

  /// Wraps a link with proper semantics.
  static Widget link({
    required String label,
    String? hint,
    required Widget child,
  }) {
    return Semantics(
      link: true,
      label: label,
      hint: hint ?? 'Double tap to open link',
      child: child,
    );
  }

  /// Wraps content that should be announced as a live region.
  ///
  /// Use for dynamic content that should be announced when it changes.
  /// [politeness] controls interrupt behavior.
  static Widget liveRegion({
    required Widget child,
    bool isPolite = true,
  }) {
    return Semantics(
      liveRegion: true,
      child: child,
    );
  }

  /// Groups related widgets into a single semantic node.
  ///
  /// Use to combine label + value pairs or related controls.
  static Widget group({
    required String label,
    required List<Widget> children,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  /// Excludes decorative elements from the accessibility tree.
  ///
  /// Use for purely visual elements that don't convey information.
  static Widget decorative({
    required Widget child,
  }) {
    return ExcludeSemantics(child: child);
  }

  /// Ensures widget meets minimum touch target size.
  ///
  /// Wraps small interactive elements to meet accessibility guidelines.
  static Widget ensureMinTouchTarget({
    required Widget child,
    double minSize = minTouchTargetAndroid,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  /// Announces a message to screen reader users.
  ///
  /// Use for important status updates or confirmations.
  static Future<void> announce(String message, {TextDirection? textDirection}) async {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return;
    return SemanticsService.sendAnnouncement(
      view,
      message,
      textDirection ?? TextDirection.ltr,
    );
  }
}
''';
}

/// Generates the ContrastChecker utility class.
///
/// Provides WCAG 2.1 compliant contrast ratio checking for text and UI elements.
String generateContrastChecker() {
  return r'''
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility for checking WCAG 2.1 color contrast compliance.
///
/// Provides methods to calculate contrast ratios and verify compliance
/// with accessibility standards.
///
/// WCAG 2.1 Requirements:
/// - Regular text: minimum 4.5:1 contrast ratio
/// - Large text (18pt+ or 14pt+ bold): minimum 3:1 contrast ratio
/// - UI components and graphics: minimum 3:1 contrast ratio
class ContrastChecker {
  const ContrastChecker._();

  /// Minimum contrast ratio for regular text (WCAG AA).
  static const double minContrastText = 4.5;
  
  /// Minimum contrast ratio for large text (18pt+) (WCAG AA).
  static const double minContrastLargeText = 3.0;
  
  /// Minimum contrast ratio for UI components (WCAG AA).
  static const double minContrastUI = 3.0;
  
  /// Enhanced contrast ratio for regular text (WCAG AAA).
  static const double enhancedContrastText = 7.0;
  
  /// Enhanced contrast ratio for large text (WCAG AAA).
  static const double enhancedContrastLargeText = 4.5;

  /// Calculates the relative luminance of a color.
  ///
  /// Returns a value between 0 (darkest) and 1 (lightest).
  static double relativeLuminance(Color color) {
    double r = _linearize(color.r);
    double g = _linearize(color.g);
    double b = _linearize(color.b);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Calculates the contrast ratio between two colors.
  ///
  /// Returns a ratio from 1:1 (no contrast) to 21:1 (maximum contrast).
  static double contrastRatio(Color foreground, Color background) {
    final lum1 = relativeLuminance(foreground);
    final lum2 = relativeLuminance(background);
    
    final lighter = math.max(lum1, lum2);
    final darker = math.min(lum1, lum2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if colors meet WCAG AA standard for regular text.
  static bool meetsAAForText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastText;
  }

  /// Checks if colors meet WCAG AA standard for large text.
  static bool meetsAAForLargeText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastLargeText;
  }

  /// Checks if colors meet WCAG AA standard for UI components.
  static bool meetsAAForUI(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastUI;
  }

  /// Checks if colors meet WCAG AAA standard for regular text.
  static bool meetsAAAForText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= enhancedContrastText;
  }

  /// Returns a detailed contrast report for the color pair.
  static ContrastReport analyzeContrast(Color foreground, Color background) {
    final ratio = contrastRatio(foreground, background);
    return ContrastReport(
      foreground: foreground,
      background: background,
      ratio: ratio,
      passesAAText: ratio >= minContrastText,
      passesAALargeText: ratio >= minContrastLargeText,
      passesAAUI: ratio >= minContrastUI,
      passesAAAText: ratio >= enhancedContrastText,
      passesAAALargeText: ratio >= enhancedContrastLargeText,
    );
  }

  /// Suggests an accessible foreground color for the given background.
  ///
  /// Returns either black or white based on which provides better contrast.
  static Color suggestForeground(Color background) {
    final luminance = relativeLuminance(background);
    return luminance > 0.179 ? Colors.black : Colors.white;
  }
}

/// Report containing contrast analysis results.
class ContrastReport {
  const ContrastReport({
    required this.foreground,
    required this.background,
    required this.ratio,
    required this.passesAAText,
    required this.passesAALargeText,
    required this.passesAAUI,
    required this.passesAAAText,
    required this.passesAAALargeText,
  });

  final Color foreground;
  final Color background;
  final double ratio;
  final bool passesAAText;
  final bool passesAALargeText;
  final bool passesAAUI;
  final bool passesAAAText;
  final bool passesAAALargeText;

  /// Overall WCAG AA compliance for text.
  bool get isWCAGAACompliant => passesAAText;

  /// Overall WCAG AAA compliance for text.
  bool get isWCAGAAACompliant => passesAAAText;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('ContrastReport:');
    buffer.writeln('  Ratio: ${ratio.toStringAsFixed(2)}:1');
    buffer.writeln('  WCAG AA Text: ${passesAAText ? "✓" : "✗"}');
    buffer.writeln('  WCAG AA Large Text: ${passesAALargeText ? "✓" : "✗"}');
    buffer.writeln('  WCAG AA UI: ${passesAAUI ? "✓" : "✗"}');
    buffer.writeln('  WCAG AAA Text: ${passesAAAText ? "✓" : "✗"}');
    buffer.writeln('  WCAG AAA Large Text: ${passesAAALargeText ? "✓" : "✗"}');
    return buffer.toString();
  }
}
''';
}

/// Generates the FocusManager utility class.
///
/// Provides utilities for managing keyboard focus and navigation order.
String generateFocusManager() {
  return r'''
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Utility class for managing keyboard focus and navigation.
///
/// Provides helpers for implementing proper tab order and focus management
/// for web and desktop accessibility.
///
/// Example:
/// ```dart
/// FocusManager.createFocusTraversalGroup(
///   children: [
///     TextField(focusNode: FocusManager.createNode('email')),
///     TextField(focusNode: FocusManager.createNode('password')),
///     ElevatedButton(onPressed: login, child: Text('Login')),
///   ],
/// )
/// ```
class A11yFocusManager {
  A11yFocusManager._();

  /// Map of named focus nodes for easy reference.
  static final Map<String, FocusNode> _namedNodes = {};

  /// Creates a named focus node that can be retrieved later.
  static FocusNode createNode(String name) {
    _namedNodes[name] ??= FocusNode(debugLabel: name);
    return _namedNodes[name]!;
  }

  /// Gets an existing named focus node.
  static FocusNode? getNode(String name) => _namedNodes[name];

  /// Requests focus on a named node.
  static void focusOn(String name) {
    final node = _namedNodes[name];
    if (node != null && node.canRequestFocus) {
      node.requestFocus();
    }
  }

  /// Removes focus from the currently focused element.
  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Disposes a named focus node.
  static void disposeNode(String name) {
    _namedNodes[name]?.dispose();
    _namedNodes.remove(name);
  }

  /// Disposes all named focus nodes.
  static void disposeAll() {
    for (final node in _namedNodes.values) {
      node.dispose();
    }
    _namedNodes.clear();
  }

  /// Creates a focus traversal group with ordered tab navigation.
  static Widget createFocusTraversalGroup({
    required List<Widget> children,
    Axis direction = Axis.vertical,
    FocusTraversalPolicy? policy,
  }) {
    return FocusTraversalGroup(
      policy: policy ?? OrderedTraversalPolicy(),
      child: direction == Axis.vertical
          ? Column(mainAxisSize: MainAxisSize.min, children: children)
          : Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  /// Wraps a widget with focus order annotation.
  static Widget withOrder(int order, Widget child) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(order.toDouble()),
      child: child,
    );
  }

  /// Creates a keyboard shortcut handler.
  static Widget withKeyboardShortcuts({
    required Widget child,
    required Map<LogicalKeySet, VoidCallback> shortcuts,
  }) {
    return Focus(
      autofocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          for (final entry in shortcuts.entries) {
            if (_matchesKeySet(entry.key, event)) {
              entry.value();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  static bool _matchesKeySet(LogicalKeySet keySet, KeyEvent event) {
    final pressedKeys = HardwareKeyboard.instance.logicalKeysPressed;
    return keySet.keys.every((key) => pressedKeys.contains(key) || 
        event.logicalKey == key);
  }

  /// Wraps widget with skip-to-content functionality.
  ///
  /// Provides a hidden link at the top for keyboard users to skip navigation.
  static Widget withSkipToContent({
    required Widget child,
    required FocusNode mainContentNode,
    String skipLabel = 'Skip to main content',
  }) {
    return Column(
      children: [
        Focus(
          child: Builder(
            builder: (context) {
              return Semantics(
                link: true,
                label: skipLabel,
                child: InkWell(
                  onTap: () => mainContentNode.requestFocus(),
                  child: Container(
                    // Visually hidden but accessible
                    width: 1,
                    height: 1,
                    color: Colors.transparent,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// A widget that announces focus changes to screen readers.
class FocusAnnouncer extends StatefulWidget {
  const FocusAnnouncer({
    super.key,
    required this.child,
    required this.focusNode,
    this.announcementOnFocus,
  });

  final Widget child;
  final FocusNode focusNode;
  final String? announcementOnFocus;

  @override
  State<FocusAnnouncer> createState() => _FocusAnnouncerState();
}

class _FocusAnnouncerState extends State<FocusAnnouncer> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus && widget.announcementOnFocus != null) {
      final view = WidgetsBinding.instance.platformDispatcher.implicitView;
      if (view != null) {
        SemanticsService.sendAnnouncement(
          view,
          widget.announcementOnFocus!,
          TextDirection.ltr,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
''';
}

/// Generates the AccessibilityConfig class.
///
/// Provides app-wide accessibility settings and preferences.
String generateAccessibilityConfig() {
  return r'''
import 'package:flutter/material.dart';

/// App-wide accessibility configuration and preferences.
///
/// Provides utilities for checking system accessibility settings
/// and applying accessibility-conscious defaults.
///
/// Example:
/// ```dart
/// if (AccessibilityConfig.isReduceMotionEnabled(context)) {
///   // Use simpler animations
/// }
/// ```
class AccessibilityConfig {
  const AccessibilityConfig._();

  /// Checks if reduce motion is enabled in system settings.
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Checks if bold text is enabled in system settings.
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Checks if high contrast mode is enabled.
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Checks if inverted colors are enabled.
  static bool isInvertColorsEnabled(BuildContext context) {
    return MediaQuery.of(context).invertColors;
  }

  /// Gets the current text scale factor.
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Checks if screen reader is likely active.
  ///
  /// This is a heuristic based on accessibility features being enabled.
  static bool isScreenReaderLikelyActive(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Returns appropriate animation duration based on reduce motion setting.
  static Duration getAnimationDuration(
    BuildContext context, {
    Duration normal = const Duration(milliseconds: 300),
    Duration reduced = Duration.zero,
  }) {
    return isReduceMotionEnabled(context) ? reduced : normal;
  }

  /// Returns appropriate animation curve based on reduce motion setting.
  static Curve getAnimationCurve(
    BuildContext context, {
    Curve normal = Curves.easeInOut,
  }) {
    return isReduceMotionEnabled(context) ? Curves.linear : normal;
  }

  /// Applies minimum text scale to prevent text from being too small.
  static TextScaler getConstrainedTextScaler(
    BuildContext context, {
    double minScale = 1.0,
    double maxScale = 2.0,
  }) {
    final scale = MediaQuery.of(context).textScaler.scale(1.0);
    final clampedScale = scale.clamp(minScale, maxScale);
    return TextScaler.linear(clampedScale);
  }
}

/// Widget that adapts to accessibility settings.
///
/// Provides different content based on user's accessibility preferences.
class AccessibilityAware extends StatelessWidget {
  const AccessibilityAware({
    super.key,
    required this.child,
    this.reducedMotionChild,
    this.highContrastChild,
    this.screenReaderChild,
  });

  final Widget child;
  final Widget? reducedMotionChild;
  final Widget? highContrastChild;
  final Widget? screenReaderChild;

  @override
  Widget build(BuildContext context) {
    if (screenReaderChild != null && 
        AccessibilityConfig.isScreenReaderLikelyActive(context)) {
      return screenReaderChild!;
    }
    
    if (highContrastChild != null && 
        AccessibilityConfig.isHighContrastEnabled(context)) {
      return highContrastChild!;
    }
    
    if (reducedMotionChild != null && 
        AccessibilityConfig.isReduceMotionEnabled(context)) {
      return reducedMotionChild!;
    }
    
    return child;
  }
}

/// Extension on BuildContext for quick accessibility checks.
extension AccessibilityContextExtension on BuildContext {
  /// Whether reduce motion is enabled.
  bool get reduceMotion => AccessibilityConfig.isReduceMotionEnabled(this);
  
  /// Whether bold text is enabled.
  bool get boldText => AccessibilityConfig.isBoldTextEnabled(this);
  
  /// Whether high contrast is enabled.
  bool get highContrast => AccessibilityConfig.isHighContrastEnabled(this);
  
  /// Current text scale factor.
  double get textScale => AccessibilityConfig.getTextScaleFactor(this);
  
  /// Whether screen reader is likely active.
  bool get screenReaderActive => AccessibilityConfig.isScreenReaderLikelyActive(this);
}
''';
}

/// Generates accessibility testing utilities.
///
/// Provides helpers for automated accessibility testing in widget tests.
String generateAccessibilityTestUtils() {
  return r'''
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Accessibility testing utilities for widget tests.
///
/// Provides matchers and helpers for verifying WCAG compliance
/// and proper semantic annotations.
///
/// Example:
/// ```dart
/// testWidgets('button is accessible', (tester) async {
///   await tester.pumpWidget(MyButton());
///   
///   A11yTestUtils.expectSemanticLabel(find.byType(IconButton), 'Add item');
///   A11yTestUtils.expectMinTouchTarget(find.byType(IconButton));
/// });
/// ```
class A11yTestUtils {
  const A11yTestUtils._();

  /// Minimum touch target size for accessibility compliance.
  static const double minTouchTarget = 48.0;

  /// Verifies that a widget has a semantic label.
  static void expectSemanticLabel(Finder finder, String expectedLabel) {
    final semantics = _getSemanticsNode(finder);
    expect(
      semantics?.label,
      expectedLabel,
      reason: 'Expected semantic label "$expectedLabel"',
    );
  }

  /// Verifies that a widget has a semantic hint.
  static void expectSemanticHint(Finder finder, String expectedHint) {
    final semantics = _getSemanticsNode(finder);
    expect(
      semantics?.hint,
      expectedHint,
      reason: 'Expected semantic hint "$expectedHint"',
    );
  }

  /// Verifies that a widget is marked as a button.
  static void expectIsButton(Finder finder) {
    final semantics = _getSemanticsNode(finder);
    expect(
      semantics?.flagsCollection.isButton,
      isTrue,
      reason: 'Expected widget to be marked as a button',
    );
  }

  /// Verifies that a widget is marked as a header.
  static void expectIsHeader(Finder finder) {
    final semantics = _getSemanticsNode(finder);
    expect(
      semantics?.flagsCollection.isHeader,
      isTrue,
      reason: 'Expected widget to be marked as a header',
    );
  }

  /// Verifies that a widget is excluded from semantics (decorative).
  static void expectExcludedFromSemantics(Finder finder) {
    final element = finder.evaluate().first;
    // Check if any ancestor excludes semantics
    bool excluded = false;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is ExcludeSemantics) {
        excluded = true;
        return false;
      }
      return true;
    });
    
    expect(
      excluded,
      isTrue,
      reason: 'Expected widget to be excluded from semantics tree',
    );
  }

  /// Verifies that a widget meets minimum touch target size.
  static void expectMinTouchTarget(
    Finder finder, {
    double minSize = minTouchTarget,
  }) {
    final element = finder.evaluate().first;
    final renderBox = element.renderObject as RenderBox;
    final size = renderBox.size;

    expect(
      size.width >= minSize && size.height >= minSize,
      isTrue,
      reason: 'Expected minimum touch target of ${minSize}x$minSize, '
          'but got ${size.width}x${size.height}',
    );
  }

  /// Verifies contrast ratio meets WCAG AA for text.
  static void expectContrastAAText(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    expect(
      ratio >= 4.5,
      isTrue,
      reason: 'Expected contrast ratio >= 4.5:1 for WCAG AA text, '
          'but got ${ratio.toStringAsFixed(2)}:1',
    );
  }

  /// Verifies contrast ratio meets WCAG AA for large text.
  static void expectContrastAALargeText(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    expect(
      ratio >= 3.0,
      isTrue,
      reason: 'Expected contrast ratio >= 3.0:1 for WCAG AA large text, '
          'but got ${ratio.toStringAsFixed(2)}:1',
    );
  }

  /// Runs all standard accessibility checks on a widget tree.
  static Future<void> runAccessibilityAudit(WidgetTester tester) async {
    // Check for missing semantic labels on buttons
    final buttons = find.byWidgetPredicate((widget) {
      return widget is IconButton || 
             widget is ElevatedButton || 
             widget is TextButton ||
             widget is OutlinedButton;
    });

    for (final finder in [buttons]) {
      for (final element in finder.evaluate()) {
        final semantics = _getSemanticsNodeFromElement(element);
        if (semantics != null && semantics.flagsCollection.isButton) {
          expect(
            semantics.label.isNotEmpty,
            isTrue,
            reason: 'Button at ${element.widget.runtimeType} missing semantic label',
          );
        }
      }
    }

    // Check for images without descriptions
    final images = find.byType(Image);
    for (final element in images.evaluate()) {
      final semantics = _getSemanticsNodeFromElement(element);
      final hasLabel = semantics != null && semantics.label.isNotEmpty;
      final isExcluded = _isExcludedFromSemantics(element);
      
      expect(
        hasLabel || isExcluded,
        isTrue,
        reason: 'Image missing semantic description or ExcludeSemantics wrapper',
      );
    }
  }

  static SemanticsNode? _getSemanticsNode(Finder finder) {
    final element = finder.evaluate().first;
    return _getSemanticsNodeFromElement(element);
  }

  static SemanticsNode? _getSemanticsNodeFromElement(Element element) {
    SemanticsNode? semantics;
    element.visitChildren((child) {
      final renderObject = child.renderObject;
      if (renderObject?.debugSemantics != null) {
        semantics = renderObject!.debugSemantics;
      }
    });
    return semantics;
  }

  static bool _isExcludedFromSemantics(Element element) {
    bool excluded = false;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is ExcludeSemantics) {
        excluded = true;
        return false;
      }
      return true;
    });
    return excluded;
  }

  static double _calculateContrastRatio(Color fg, Color bg) {
    double luminance(Color c) {
      double linearize(double v) => 
          v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055).toDouble();
      
      final r = linearize(c.r);
      final g = linearize(c.g);
      final b = linearize(c.b);
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    final l1 = luminance(fg);
    final l2 = luminance(bg);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

/// Test matcher for semantic properties.
class HasSemanticLabel extends Matcher {
  const HasSemanticLabel(this.expectedLabel);

  final String expectedLabel;

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Finder) return false;
    final element = item.evaluate().first;
    element.visitChildren((child) {
      final semantics = child.renderObject?.debugSemantics;
      if (semantics?.label == expectedLabel) {
        matchState['found'] = true;
      }
    });
    return matchState['found'] == true;
  }

  @override
  Description describe(Description description) {
    return description.add('has semantic label "$expectedLabel"');
  }
}
''';
}
