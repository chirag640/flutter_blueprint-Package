import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/bloc_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/provider_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/riverpod_mobile_template.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Analytics Integration Tests', () {
    late BlueprintConfig configWithFirebase;
    late BlueprintConfig configWithSentry;
    late BlueprintConfig configWithoutAnalytics;

    setUp(() {
      configWithFirebase = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeAnalytics: true,
        analyticsProvider: AnalyticsProvider.firebase,
        includeApi: true,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeTests: true,
      );

      configWithSentry = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeAnalytics: true,
        analyticsProvider: AnalyticsProvider.sentry,
        includeApi: true,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeTests: true,
      );

      configWithoutAnalytics = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeAnalytics: false,
        analyticsProvider: AnalyticsProvider.none,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
      );
    });

    group('BlueprintConfig Analytics Configuration', () {
      test('includes analytics flag in serialization', () {
        final map = configWithFirebase.toMap();
        expect(map['features']['analytics'], isTrue);
        expect(map['analytics_provider'], equals('firebase'));
      });

      test('reads analytics flag and provider from map', () {
        final map = {
          'app_name': 'test_app',
          'state_management': 'provider',
          'platforms': ['mobile'],
          'analytics_provider': 'firebase',
          'features': {'analytics': true},
        };
        final config = BlueprintConfig.fromMap(map);
        expect(config.includeAnalytics, isTrue);
        expect(config.analyticsProvider, equals(AnalyticsProvider.firebase));
      });

      test('defaults to false and none when analytics flag is missing', () {
        final map = {
          'app_name': 'test_app',
          'state_management': 'provider',
          'platforms': ['mobile'],
          'features': {},
        };
        final config = BlueprintConfig.fromMap(map);
        expect(config.includeAnalytics, isFalse);
        expect(config.analyticsProvider, equals(AnalyticsProvider.none));
      });

      test('copyWith updates analytics flag and provider', () {
        final updated = configWithoutAnalytics.copyWith(
          includeAnalytics: true,
          analyticsProvider: AnalyticsProvider.sentry,
        );
        expect(updated.includeAnalytics, isTrue);
        expect(updated.analyticsProvider, equals(AnalyticsProvider.sentry));
        expect(configWithoutAnalytics.includeAnalytics, isFalse);
      });
    });

    group('AnalyticsProvider Enum', () {
      test('parses valid provider strings', () {
        expect(AnalyticsProvider.parse('firebase'),
            equals(AnalyticsProvider.firebase));
        expect(AnalyticsProvider.parse('sentry'),
            equals(AnalyticsProvider.sentry));
        expect(AnalyticsProvider.parse('none'), equals(AnalyticsProvider.none));
      });

      test('throws on invalid provider string', () {
        expect(() => AnalyticsProvider.parse('invalid'), throwsArgumentError);
      });

      test('returns correct label', () {
        expect(AnalyticsProvider.firebase.label, equals('firebase'));
        expect(AnalyticsProvider.sentry.label, equals('sentry'));
        expect(AnalyticsProvider.none.label, equals('none'));
      });
    });

    group('Provider Template Analytics Files', () {
      test('generates analytics files when includeAnalytics is true', () {
        final bundle = buildProviderMobileBundle();
        final analyticsFiles = bundle.files.where((file) {
          return file.path.contains(
                  'core${p.separator}analytics${p.separator}analytics_service.dart') ||
              file.path.contains(
                  'core${p.separator}analytics${p.separator}analytics_events.dart') ||
              file.path.contains(
                  'core${p.separator}widgets${p.separator}error_boundary.dart');
        }).toList();

        expect(analyticsFiles, hasLength(3));

        for (final file in analyticsFiles) {
          final shouldGenerateWith =
              file.shouldGenerate?.call(configWithFirebase);
          final shouldGenerateWithout =
              file.shouldGenerate?.call(configWithoutAnalytics);
          expect(shouldGenerateWith, isTrue);
          expect(shouldGenerateWithout, isFalse);
        }
      });

      test('generates Firebase-specific files only with Firebase provider', () {
        final bundle = buildProviderMobileBundle();
        final firebaseFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('firebase_analytics_service.dart'),
        );

        final shouldGenerateFirebase =
            firebaseFile.shouldGenerate?.call(configWithFirebase);
        final shouldGenerateSentry =
            firebaseFile.shouldGenerate?.call(configWithSentry);
        final shouldGenerateNone =
            firebaseFile.shouldGenerate?.call(configWithoutAnalytics);

        expect(shouldGenerateFirebase, isTrue);
        expect(shouldGenerateSentry, isFalse);
        expect(shouldGenerateNone, isFalse);
      });

      test('generates Sentry-specific files only with Sentry provider', () {
        final bundle = buildProviderMobileBundle();
        final sentryFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('sentry_service.dart'),
        );

        final shouldGenerateFirebase =
            sentryFile.shouldGenerate?.call(configWithFirebase);
        final shouldGenerateSentry =
            sentryFile.shouldGenerate?.call(configWithSentry);
        final shouldGenerateNone =
            sentryFile.shouldGenerate?.call(configWithoutAnalytics);

        expect(shouldGenerateFirebase, isFalse);
        expect(shouldGenerateSentry, isTrue);
        expect(shouldGenerateNone, isFalse);
      });

      test('AnalyticsService contains expected interface', () {
        final bundle = buildProviderMobileBundle();
        final serviceFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('analytics_service.dart') &&
              !file.path.contains('firebase') &&
              !file.path.contains('sentry'),
        );

        final content = serviceFile.build(configWithFirebase);
        expect(content, contains('abstract class AnalyticsService'));
        expect(content, contains('Future<void> logEvent('));
        expect(content, contains('Future<void> setUserId('));
        expect(content, contains('Future<void> setUserProperties('));
        expect(content, contains('Future<void> logScreenView('));
        expect(content, contains('Future<void> recordError('));
      });

      test('FirebaseAnalyticsService contains Firebase implementation', () {
        final bundle = buildProviderMobileBundle();
        final firebaseFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('firebase_analytics_service.dart'),
        );

        final content = firebaseFile.build(configWithFirebase);
        expect(content, contains('class FirebaseAnalyticsService'));
        expect(content, contains('implements AnalyticsService'));
        expect(content, contains('FirebaseAnalytics'));
        expect(content, contains('FirebaseCrashlytics'));
        expect(content, contains('FirebasePerformance'));
      });

      test('SentryService contains Sentry implementation', () {
        final bundle = buildProviderMobileBundle();
        final sentryFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('sentry_service.dart'),
        );

        final content = sentryFile.build(configWithSentry);
        expect(content, contains('class SentryAnalyticsService'));
        expect(content, contains('implements AnalyticsService'));
        expect(content, contains('Sentry.captureException'));
        expect(content, contains('Sentry.addBreadcrumb'));
      });

      test('AnalyticsEvents contains event constants', () {
        final bundle = buildProviderMobileBundle();
        final eventsFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('analytics_events.dart'),
        );

        final content = eventsFile.build(configWithFirebase);
        expect(content, contains('class AnalyticsEvents'));
        expect(content, contains('static const String'));
        expect(content, contains('login'));
        expect(content, contains('logout'));
        expect(content, contains('signup'));
      });

      test('ErrorBoundary contains error catching logic', () {
        final bundle = buildProviderMobileBundle();
        final errorBoundaryFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('widgets') &&
              file.path.contains('error_boundary.dart'),
        );

        final content = errorBoundaryFile.build(configWithFirebase);
        expect(content, contains('class ErrorBoundary'));
        expect(content, contains('StatefulWidget'));
        expect(content, contains('ErrorWidget.builder'));
        expect(content, contains('AnalyticsService'));
      });
    });

    group('Riverpod Template Analytics Files', () {
      test('generates analytics files when includeAnalytics is true', () {
        final config = configWithFirebase.copyWith(
          stateManagement: StateManagement.riverpod,
        );
        final bundle = buildRiverpodMobileBundle();
        final analyticsFiles = bundle.files.where((file) {
          return (file.path.contains('analytics') &&
                  file.path.contains('analytics_service.dart') &&
                  !file.path.contains('firebase') &&
                  !file.path.contains('sentry')) ||
              (file.path.contains('analytics') &&
                  file.path.contains('firebase_analytics_service.dart')) ||
              (file.path.contains('analytics') &&
                  file.path.contains('analytics_events.dart')) ||
              (file.path.contains('widgets') &&
                  file.path.contains('error_boundary.dart'));
        }).toList();

        expect(analyticsFiles, hasLength(4));

        for (final file in analyticsFiles) {
          final shouldGenerate = file.shouldGenerate?.call(config);
          expect(shouldGenerate, isTrue);
        }
      });

      test('generates correct provider-specific files for Sentry', () {
        final config = configWithSentry.copyWith(
          stateManagement: StateManagement.riverpod,
        );
        final bundle = buildRiverpodMobileBundle();

        final sentryFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('sentry_service.dart'),
        );
        final firebaseFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('firebase_analytics_service.dart'),
        );

        expect(sentryFile.shouldGenerate?.call(config), isTrue);
        expect(firebaseFile.shouldGenerate?.call(config), isFalse);
      });
    });

    group('Bloc Template Analytics Files', () {
      test('generates analytics files when includeAnalytics is true', () {
        final config = configWithFirebase.copyWith(
          stateManagement: StateManagement.bloc,
        );
        final bundle = buildBlocMobileBundle();
        final analyticsFiles = bundle.files.where((file) {
          return (file.path.contains('analytics') &&
                  file.path.contains('analytics_service.dart') &&
                  !file.path.contains('firebase') &&
                  !file.path.contains('sentry')) ||
              (file.path.contains('analytics') &&
                  file.path.contains('firebase_analytics_service.dart')) ||
              (file.path.contains('analytics') &&
                  file.path.contains('analytics_events.dart')) ||
              (file.path.contains('widgets') &&
                  file.path.contains('error_boundary.dart'));
        }).toList();

        expect(analyticsFiles, hasLength(4));

        for (final file in analyticsFiles) {
          final shouldGenerate = file.shouldGenerate?.call(config);
          expect(shouldGenerate, isTrue);
        }
      });

      test('does not generate analytics files when disabled', () {
        final config = configWithoutAnalytics.copyWith(
          stateManagement: StateManagement.bloc,
        );
        final bundle = buildBlocMobileBundle();
        final analyticsFiles = bundle.files.where((file) {
          return file.path.contains('analytics/');
        }).toList();

        for (final file in analyticsFiles) {
          final shouldGenerate = file.shouldGenerate?.call(config);
          expect(shouldGenerate, isFalse);
        }
      });
    });

    group('Code Quality Checks', () {
      test('generated analytics code has no syntax errors', () {
        final bundle = buildProviderMobileBundle();
        final analyticsFiles = bundle.files.where((file) {
          return file.path.contains('analytics/');
        }).toList();

        for (final file in analyticsFiles) {
          final content = file.build(configWithFirebase);

          // Basic syntax checks
          expect(content, isNotEmpty);
          expect(content, contains('class '));
          expect(content, isNot(contains('{{'))); // No template markers
          expect(content, isNot(contains('}}'))); // No template markers

          // Check for balanced braces
          final openBraces = '{'.allMatches(content).length;
          final closeBraces = '}'.allMatches(content).length;
          expect(openBraces, equals(closeBraces),
              reason: 'Unbalanced braces in ${file.path}');
        }
      });

      test('error boundary has proper import statements', () {
        final bundle = buildProviderMobileBundle();
        final errorBoundaryFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('widgets') &&
              file.path.contains('error_boundary.dart'),
        );

        final content = errorBoundaryFile.build(configWithFirebase);
        expect(content, contains("import 'package:flutter/material.dart'"));
        expect(content, contains('AnalyticsService'));
      });

      test('Firebase service has all required imports', () {
        final bundle = buildProviderMobileBundle();
        final firebaseFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('firebase_analytics_service.dart'),
        );

        final content = firebaseFile.build(configWithFirebase);
        expect(content, contains("import 'package:firebase_analytics/"));
        expect(content, contains("import 'package:firebase_crashlytics/"));
        expect(content, contains("import 'analytics_service.dart'"));
      });

      test('Sentry service has all required imports', () {
        final bundle = buildProviderMobileBundle();
        final sentryFile = bundle.files.firstWhere(
          (file) =>
              file.path.contains('analytics') &&
              file.path.contains('sentry_service.dart'),
        );

        final content = sentryFile.build(configWithSentry);
        expect(content, contains("import 'package:sentry_flutter/"));
        expect(content, contains("import 'analytics_service.dart'"));
      });
    });
  });
}
