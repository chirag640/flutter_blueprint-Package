import 'package:flutter_blueprint/src/config/performance_config.dart';
import 'package:test/test.dart';

void main() {
  group('PerformanceConfig', () {
    test('creates disabled config', () {
      final config = PerformanceConfig.disabled();

      expect(config.enabled, isFalse);
      expect(config.tracking.hasAnyEnabled, isFalse);
    });

    test('creates all-enabled config', () {
      final config = PerformanceConfig.allEnabled();

      expect(config.enabled, isTrue);
      expect(config.tracking.appStartTime, isTrue);
      expect(config.tracking.screenLoadTime, isTrue);
      expect(config.tracking.apiResponseTime, isTrue);
      expect(config.tracking.frameRenderTime, isTrue);
    });

    test('creates config from YAML', () {
      final yaml = {
        'enabled': true,
        'tracking': ['app_start_time', 'screen_load_time'],
        'alerts': {
          'slow_screen_threshold': '500ms',
          'slow_api_threshold': '2s',
        },
      };

      final config = PerformanceConfig.fromYaml(yaml);

      expect(config.enabled, isTrue);
      expect(config.tracking.appStartTime, isTrue);
      expect(config.tracking.screenLoadTime, isTrue);
      expect(config.tracking.apiResponseTime, isFalse);
      expect(config.alerts.slowScreenThreshold, equals(500));
      expect(config.alerts.slowApiThreshold, equals(2000));
    });

    test('converts config to YAML', () {
      final config = PerformanceConfig.allEnabled();
      final yaml = config.toYaml();

      expect(yaml['enabled'], isTrue);
      expect(yaml['tracking'], isA<List>());
      expect(yaml['alerts'], isA<Map>());
    });
  });

  group('PerformanceTracking', () {
    test('creates from list of metric names', () {
      final tracking = PerformanceTracking.fromList([
        'app_start_time',
        'screen_load_time',
      ]);

      expect(tracking.appStartTime, isTrue);
      expect(tracking.screenLoadTime, isTrue);
      expect(tracking.apiResponseTime, isFalse);
      expect(tracking.frameRenderTime, isFalse);
    });

    test('creates with no tracking', () {
      final tracking = PerformanceTracking.none();

      expect(tracking.hasAnyEnabled, isFalse);
    });

    test('creates with all tracking', () {
      final tracking = PerformanceTracking.all();

      expect(tracking.appStartTime, isTrue);
      expect(tracking.screenLoadTime, isTrue);
      expect(tracking.apiResponseTime, isTrue);
      expect(tracking.frameRenderTime, isTrue);
      expect(tracking.hasAnyEnabled, isTrue);
    });

    test('converts to list', () {
      final tracking = PerformanceTracking(
        appStartTime: true,
        screenLoadTime: true,
      );

      final list = tracking.toList();

      expect(list, hasLength(2));
      expect(list, contains('app_start_time'));
      expect(list, contains('screen_load_time'));
    });
  });

  group('PerformanceAlerts', () {
    test('creates with default thresholds', () {
      final alerts = PerformanceAlerts.defaults();

      expect(alerts.slowScreenThreshold, equals(500));
      expect(alerts.slowApiThreshold, equals(2000));
      expect(alerts.slowStartupThreshold, equals(1000));
      expect(alerts.frameDropThreshold, equals(16));
    });

    test('creates from YAML with milliseconds', () {
      final yaml = {
        'slow_screen_threshold': '300ms',
        'slow_api_threshold': '1500ms',
      };

      final alerts = PerformanceAlerts.fromYaml(yaml);

      expect(alerts.slowScreenThreshold, equals(300));
      expect(alerts.slowApiThreshold, equals(1500));
    });

    test('creates from YAML with seconds', () {
      final yaml = {
        'slow_screen_threshold': '1s',
        'slow_api_threshold': '3s',
      };

      final alerts = PerformanceAlerts.fromYaml(yaml);

      expect(alerts.slowScreenThreshold, equals(1000));
      expect(alerts.slowApiThreshold, equals(3000));
    });

    test('creates from YAML with numeric values', () {
      final yaml = {
        'slow_screen_threshold': 600,
        'slow_api_threshold': 2500,
      };

      final alerts = PerformanceAlerts.fromYaml(yaml);

      expect(alerts.slowScreenThreshold, equals(600));
      expect(alerts.slowApiThreshold, equals(2500));
    });

    test('uses defaults for invalid values', () {
      final yaml = {
        'slow_screen_threshold': 'invalid',
        'slow_api_threshold': null,
      };

      final alerts = PerformanceAlerts.fromYaml(yaml);

      expect(alerts.slowScreenThreshold, equals(500)); // default
      expect(alerts.slowApiThreshold, equals(2000)); // default
    });

    test('converts to YAML', () {
      final alerts = PerformanceAlerts(
        slowScreenThreshold: 300,
        slowApiThreshold: 1500,
      );

      final yaml = alerts.toYaml();

      expect(yaml['slow_screen_threshold'], equals('300ms'));
      expect(yaml['slow_api_threshold'], equals('1500ms'));
    });
  });

  group('PerformanceMetric', () {
    test('creates metric with required fields', () {
      final timestamp = DateTime.now();
      final metric = PerformanceMetric(
        name: 'test_metric',
        value: 123.45,
        timestamp: timestamp,
      );

      expect(metric.name, equals('test_metric'));
      expect(metric.value, equals(123.45));
      expect(metric.unit, equals('ms'));
      expect(metric.timestamp, equals(timestamp));
      expect(metric.metadata, isNull);
    });

    test('creates metric with metadata', () {
      final metric = PerformanceMetric(
        name: 'api_call',
        value: 250.0,
        timestamp: DateTime.now(),
        metadata: {'endpoint': '/users', 'method': 'GET'},
      );

      expect(metric.metadata, isNotNull);
      expect(metric.metadata!['endpoint'], equals('/users'));
      expect(metric.metadata!['method'], equals('GET'));
    });

    test('formats metric correctly', () {
      final metric = PerformanceMetric(
        name: 'screen_load',
        value: 456.78,
        timestamp: DateTime.now(),
      );

      expect(metric.format(), equals('screen_load: 456.78ms'));
    });

    test('converts to JSON', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final metric = PerformanceMetric(
        name: 'test',
        value: 100.5,
        unit: 'ms',
        timestamp: timestamp,
        metadata: {'key': 'value'},
      );

      final json = metric.toJson();

      expect(json['name'], equals('test'));
      expect(json['value'], equals(100.5));
      expect(json['unit'], equals('ms'));
      expect(json['timestamp'], equals(timestamp.toIso8601String()));
      expect(json['metadata'], isNotNull);
    });

    test('creates from JSON', () {
      final json = {
        'name': 'test',
        'value': 100.5,
        'unit': 'ms',
        'timestamp': '2024-01-01T12:00:00.000',
        'metadata': {'key': 'value'},
      };

      final metric = PerformanceMetric.fromJson(json);

      expect(metric.name, equals('test'));
      expect(metric.value, equals(100.5));
      expect(metric.unit, equals('ms'));
      expect(metric.metadata, isNotNull);
      expect(metric.metadata!['key'], equals('value'));
    });

    test('round-trips through JSON', () {
      final original = PerformanceMetric(
        name: 'test',
        value: 123.45,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        metadata: {'endpoint': '/api/test'},
      );

      final json = original.toJson();
      final restored = PerformanceMetric.fromJson(json);

      expect(restored.name, equals(original.name));
      expect(restored.value, equals(original.value));
      expect(restored.unit, equals(original.unit));
      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.metadata, equals(original.metadata));
    });
  });
}
