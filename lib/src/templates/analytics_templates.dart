/// Analytics and crash reporting template generators for Flutter Blueprint.
///
/// This module provides production-ready analytics integration with Firebase
/// Analytics, Crashlytics, and Sentry. Includes automatic error reporting,
/// custom event tracking, screen view tracking, and user properties.
library;

/// Generates the abstract AnalyticsService interface.
///
/// This service provides a unified API for analytics across different providers.
/// Supports Firebase Analytics, Sentry, or custom implementations.
String generateAnalyticsService() {
  return r'''
/// Abstract analytics service interface.
///
/// Provides a unified API for analytics and crash reporting across different
/// providers (Firebase, Sentry, etc.). All analytics operations are async
/// and fail silently to avoid disrupting the user experience.
abstract class AnalyticsService {
  /// Current analytics service instance (configured in main.dart).
  static AnalyticsService? _instance;
  
  /// Get the current analytics service instance.
  static AnalyticsService get instance {
    if (_instance == null) {
      throw StateError(
        'AnalyticsService not initialized. Call AnalyticsService.initialize() in main.dart',
      );
    }
    return _instance!;
  }
  
  /// Initialize the analytics service with a specific implementation.
  static void initialize(AnalyticsService service) {
    _instance = service;
  }
  
  /// Log a custom event with optional parameters.
  ///
  /// Example:
  /// ```dart
  /// await analyticsService.logEvent('product_purchased', parameters: {
  ///   'product_id': '12345',
  ///   'price': 29.99,
  ///   'category': 'electronics',
  /// });
  /// ```
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
  
  /// Log a screen view event.
  ///
  /// Example:
  /// ```dart
  /// await analyticsService.logScreenView('ProductDetailsScreen');
  /// ```
  Future<void> logScreenView(String screenName, {String? screenClass});
  
  /// Set user properties for analytics segmentation.
  ///
  /// Example:
  /// ```dart
  /// await analyticsService.setUserProperties({
  ///   'user_type': 'premium',
  ///   'signup_date': '2025-11-18',
  /// });
  /// ```
  Future<void> setUserProperties(Map<String, dynamic> properties);
  
  /// Set the current user ID.
  Future<void> setUserId(String? userId);
  
  /// Record a non-fatal error with optional stack trace.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   // ... some operation
  /// } catch (error, stackTrace) {
  ///   await analyticsService.recordError(
  ///     error,
  ///     stackTrace,
  ///     reason: 'API request failed',
  ///     fatal: false,
  ///   );
  /// }
  /// ```
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  });
  
  /// Start a performance trace (returns trace ID).
  ///
  /// Example:
  /// ```dart
  /// final traceId = await analyticsService.startTrace('api_fetch_products');
  /// // ... perform operation
  /// await analyticsService.stopTrace(traceId);
  /// ```
  Future<String> startTrace(String traceName);
  
  /// Stop a performance trace by trace ID.
  Future<void> stopTrace(String traceId);
  
  /// Log a login event.
  Future<void> logLogin(String method) {
    return logEvent('login', parameters: {'method': method});
  }
  
  /// Log a signup event.
  Future<void> logSignup(String method) {
    return logEvent('signup', parameters: {'method': method});
  }
  
  /// Log a purchase event.
  Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
    Map<String, dynamic>? items,
  }) {
    return logEvent('purchase', parameters: {
      'currency': currency,
      'value': value,
      if (transactionId != null) 'transaction_id': transactionId,
      if (items != null) 'items': items,
    });
  }
}
''';
}

/// Generates the Firebase Analytics implementation.
String generateFirebaseAnalyticsService() {
  return r'''
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'analytics_service.dart';

/// Firebase Analytics implementation of AnalyticsService.
///
/// Integrates Firebase Analytics, Crashlytics, and Performance Monitoring.
/// All operations fail silently to avoid disrupting user experience.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
    FirebasePerformance? performance,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _performance = performance ?? FirebasePerformance.instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final FirebasePerformance _performance;
  
  /// Active performance traces (trace name -> trace instance).
  final Map<String, Trace> _traces = {};

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Fail silently - analytics should never break the app
      print('Failed to log event: \$e');
    }
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      print('Failed to log screen view: \$e');
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    try {
      for (final entry in properties.entries) {
        await _analytics.setUserProperty(
          name: entry.key,
          value: entry.value?.toString(),
        );
      }
    } catch (e) {
      print('Failed to set user properties: \$e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId ?? '');
    } catch (e) {
      print('Failed to set user ID: \$e');
    }
  }

  @override
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
        information: context?.entries.map((e) => '\${e.key}: \${e.value}').toList() ?? [],
      );
    } catch (e) {
      print('Failed to record error: \$e');
    }
  }

  @override
  Future<String> startTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
      _traces[traceName] = trace;
      return traceName;
    } catch (e) {
      print('Failed to start trace: \$e');
      return traceName;
    }
  }

  @override
  Future<void> stopTrace(String traceId) async {
    try {
      final trace = _traces.remove(traceId);
      if (trace != null) {
        await trace.stop();
      }
    } catch (e) {
      print('Failed to stop trace: \$e');
    }
  }

  /// Get a NavigatorObserver for automatic screen tracking.
  FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
}
''';
}

/// Generates the Sentry implementation.
String generateSentryService() {
  return r'''
import 'package:sentry_flutter/sentry_flutter.dart';
import 'analytics_service.dart';

/// Sentry implementation of AnalyticsService.
///
/// Focuses on error tracking and performance monitoring using Sentry.
/// For full analytics features, consider using Firebase alongside Sentry.
class SentryAnalyticsService implements AnalyticsService {
  SentryAnalyticsService();
  
  /// Active performance transactions (transaction name -> transaction).
  final Map<String, ISentrySpan> _transactions = {};

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      // Sentry uses breadcrumbs for event tracking
      Sentry.addBreadcrumb(Breadcrumb(
        message: name,
        data: parameters,
        category: 'custom_event',
        level: SentryLevel.info,
      ));
    } catch (e) {
      print('Failed to log event: \$e');
    }
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    try {
      Sentry.addBreadcrumb(Breadcrumb(
        message: 'Screen: \$screenName',
        category: 'navigation',
        level: SentryLevel.info,
        data: screenClass != null ? {'screen_class': screenClass} : null,
      ));
    } catch (e) {
      print('Failed to log screen view: \$e');
    }
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    try {
      await Sentry.configureScope((scope) {
        for (final entry in properties.entries) {
          scope.setExtra(entry.key, entry.value);
        }
      });
    } catch (e) {
      print('Failed to set user properties: \$e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await Sentry.configureScope((scope) {
        scope.setUser(userId != null ? SentryUser(id: userId) : null);
      });
    } catch (e) {
      print('Failed to set user ID: \$e');
    }
  }

  @override
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    try {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          if (reason != null) 'reason': reason,
          'fatal': fatal,
          if (context != null) ...context,
        }),
      );
    } catch (e) {
      print('Failed to record error: \$e');
    }
  }

  @override
  Future<String> startTrace(String traceName) async {
    try {
      final transaction = Sentry.startTransaction(
        traceName,
        'task',
        bindToScope: true,
      );
      _transactions[traceName] = transaction;
      return traceName;
    } catch (e) {
      print('Failed to start trace: \$e');
      return traceName;
    }
  }

  @override
  Future<void> stopTrace(String traceId) async {
    try {
      final transaction = _transactions.remove(traceId);
      if (transaction != null) {
        await transaction.finish();
      }
    } catch (e) {
      print('Failed to stop trace: \$e');
    }
  }
}
''';
}

/// Generates analytics event constants.
String generateAnalyticsEvents() {
  return r'''
/// Pre-defined analytics event names and helpers.
///
/// Use these constants for consistency across the app.
/// Custom events should follow the naming convention: lowercase_with_underscores
class AnalyticsEvents {
  const AnalyticsEvents._();

  // Authentication events
  static const String login = 'login';
  static const String logout = 'logout';
  static const String signup = 'signup';
  static const String resetPassword = 'reset_password';

  // E-commerce events
  static const String viewItem = 'view_item';
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
  static const String beginCheckout = 'begin_checkout';
  static const String purchase = 'purchase';
  static const String refund = 'refund';

  // Engagement events
  static const String search = 'search';
  static const String share = 'share';
  static const String selectContent = 'select_content';
  static const String viewSearchResults = 'view_search_results';

  // App lifecycle events
  static const String appOpen = 'app_open';
  static const String appClosed = 'app_closed';
  static const String appBackgrounded = 'app_backgrounded';
  static const String appForegrounded = 'app_foregrounded';

  // User actions
  static const String buttonClick = 'button_click';
  static const String formSubmit = 'form_submit';
  static const String formError = 'form_error';
  static const String settingsChanged = 'settings_changed';

  // Performance events
  static const String apiRequestStarted = 'api_request_started';
  static const String apiRequestCompleted = 'api_request_completed';
  static const String apiRequestFailed = 'api_request_failed';
  static const String screenLoadTime = 'screen_load_time';
}

/// Common analytics parameter keys.
class AnalyticsParams {
  const AnalyticsParams._();

  static const String method = 'method';
  static const String itemId = 'item_id';
  static const String itemName = 'item_name';
  static const String itemCategory = 'item_category';
  static const String value = 'value';
  static const String currency = 'currency';
  static const String searchTerm = 'search_term';
  static const String contentType = 'content_type';
  static const String success = 'success';
  static const String errorMessage = 'error_message';
  static const String duration = 'duration';
  static const String url = 'url';
  static const String statusCode = 'status_code';
}
''';
}

/// Generates error boundary widget for catching and reporting errors.
String generateErrorBoundary() {
  return r'''
import 'package:flutter/material.dart';
import '../analytics/analytics_service.dart';

/// Error boundary widget that catches errors in its subtree.
///
/// Automatically reports errors to analytics and shows a fallback UI.
/// Use this to wrap features or screens that might throw errors.
///
/// Example:
/// ```dart
/// ErrorBoundary(
///   child: MyFeatureWidget(),
///   fallback: (error) => ErrorView(error: error),
/// )
/// ```
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  final Widget child;
  final Widget Function(Object error)? fallback;
  final void Function(Object error, StackTrace stackTrace)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback?.call(_error!) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _error = null),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
    }

    return ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _error = details.exception);
        
        // Report to analytics
        AnalyticsService.instance.recordError(
          details.exception,
          details.stack,
          reason: 'ErrorBoundary caught error',
          fatal: false,
          context: {'widget': widget.child.runtimeType.toString()},
        );
        
        // Call custom error handler
        widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
      });
      
      return widget.child;
    } as Widget;
  }
}
''';
}

/// Generates the analytics initialization code for main.dart.
String generateAnalyticsInitialization(String provider) {
  final buffer = StringBuffer();

  if (provider == 'firebase') {
    buffer.writeln('''
// Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Analytics
  AnalyticsService.initialize(FirebaseAnalyticsService());
  
  // Setup Crashlytics
  FlutterError.onError = (errorDetails) {
    AnalyticsService.instance.recordError(
      errorDetails.exception,
      errorDetails.stack,
      reason: 'Flutter framework error',
      fatal: true,
    );
  };
  
  // Catch errors outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    AnalyticsService.instance.recordError(
      error,
      stack,
      reason: 'Platform dispatcher error',
      fatal: true,
    );
    return true;
  };''');
  } else if (provider == 'sentry') {
    buffer.writeln('''
// Initialize Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN_HERE';
      options.tracesSampleRate = 1.0;
      options.enableAutoSessionTracking = true;
      options.attachThreads = true;
      options.attachStacktrace = true;
    },
  );
  
  // Initialize Analytics
  AnalyticsService.initialize(SentryAnalyticsService());''');
  }

  return buffer.toString();
}
