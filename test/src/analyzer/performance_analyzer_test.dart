import 'package:flutter_blueprint/src/analyzer/performance_analyzer.dart';
import 'package:flutter_blueprint/src/config/performance_config.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('PerformanceAnalyzer', () {
    late Directory tempDir;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('flutter_blueprint_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('records performance metrics when enabled', () {
      final config = PerformanceConfig.allEnabled();
      final analyzer = PerformanceAnalyzer(
        config: config,
        projectPath: tempDir.path,
      );

      final metric = PerformanceMetric(
        name: 'screen_load_time',
        value: 250.0,
        timestamp: DateTime.now(),
      );

      analyzer.recordMetric(metric);

      expect(analyzer.metrics, hasLength(1));
      expect(analyzer.metrics.first.name, equals('screen_load_time'));
      expect(analyzer.metrics.first.value, equals(250.0));
    });

    test('does not record metrics when disabled', () {
      final config = PerformanceConfig.disabled();
      final analyzer = PerformanceAnalyzer(
        config: config,
        projectPath: tempDir.path,
      );

      final metric = PerformanceMetric(
        name: 'screen_load_time',
        value: 250.0,
        timestamp: DateTime.now(),
      );

      analyzer.recordMetric(metric);

      expect(analyzer.metrics, isEmpty);
    });

    test('generates performance report', () {
      final config = PerformanceConfig.allEnabled();
      final analyzer = PerformanceAnalyzer(
        config: config,
        projectPath: tempDir.path,
      );

      analyzer.recordMetric(PerformanceMetric(
        name: 'screen_load_time',
        value: 250.0,
        timestamp: DateTime.now(),
      ));

      analyzer.recordMetric(PerformanceMetric(
        name: 'screen_load_time',
        value: 350.0,
        timestamp: DateTime.now(),
      ));

      final report = analyzer.generateReport();

      expect(report.metrics, hasLength(2));
      expect(report.getAverageValue('screen_load_time'), equals(300.0));
      expect(report.getMaxValue('screen_load_time'), equals(350.0));
      expect(report.getMinValue('screen_load_time'), equals(250.0));
    });

    test('clears metrics', () {
      final config = PerformanceConfig.allEnabled();
      final analyzer = PerformanceAnalyzer(
        config: config,
        projectPath: tempDir.path,
      );

      analyzer.recordMetric(PerformanceMetric(
        name: 'screen_load_time',
        value: 250.0,
        timestamp: DateTime.now(),
      ));

      expect(analyzer.metrics, hasLength(1));

      analyzer.clearMetrics();

      expect(analyzer.metrics, isEmpty);
    });

    test('generates performance setup code', () async {
      final config = PerformanceConfig.allEnabled();
      final analyzer = PerformanceAnalyzer(
        config: config,
        projectPath: tempDir.path,
      );

      final code = await analyzer.generatePerformanceSetupCode();

      expect(code, contains('class PerformanceTracker'));
      expect(code, contains('markAppStart'));
      expect(code, contains('markScreenLoadStart'));
      expect(code, contains('recordApiResponse'));
      expect(code, contains('recordFrameTime'));
    });

    test('generates disabled code when performance monitoring is off',
        () async {
      final config = PerformanceConfig.disabled();
      final analyzer = PerformanceAnalyzer(
        config: config,
        projectPath: tempDir.path,
      );

      final code = await analyzer.generatePerformanceSetupCode();

      expect(code, contains('Performance monitoring is disabled'));
    });
  });

  group('PerformanceReport', () {
    test('calculates statistics correctly', () {
      final metrics = [
        PerformanceMetric(name: 'test', value: 100, timestamp: DateTime.now()),
        PerformanceMetric(name: 'test', value: 200, timestamp: DateTime.now()),
        PerformanceMetric(name: 'test', value: 300, timestamp: DateTime.now()),
      ];

      final report = PerformanceReport(
        metrics: metrics,
        config: PerformanceConfig.allEnabled(),
      );

      expect(report.getAverageValue('test'), equals(200.0));
      expect(report.getMaxValue('test'), equals(300.0));
      expect(report.getMinValue('test'), equals(100.0));
    });

    test('returns null for non-existent metrics', () {
      final report = PerformanceReport(
        metrics: const [],
        config: PerformanceConfig.allEnabled(),
      );

      expect(report.getAverageValue('non_existent'), isNull);
      expect(report.getMaxValue('non_existent'), isNull);
      expect(report.getMinValue('non_existent'), isNull);
    });

    test('formats report as string', () {
      final metrics = [
        PerformanceMetric(name: 'test', value: 100, timestamp: DateTime.now()),
        PerformanceMetric(name: 'test', value: 200, timestamp: DateTime.now()),
      ];

      final report = PerformanceReport(
        metrics: metrics,
        config: PerformanceConfig.allEnabled(),
      );

      final formatted = report.toFormattedString();

      expect(formatted, contains('Performance Report'));
      expect(formatted, contains('test:'));
      expect(formatted, contains('Count:   2'));
      expect(formatted, contains('Average:'));
    });
  });

  group('PerformanceMetric', () {
    test('formats metric correctly', () {
      final metric = PerformanceMetric(
        name: 'test_metric',
        value: 123.45,
        timestamp: DateTime.now(),
      );

      expect(metric.format(), equals('test_metric: 123.45ms'));
    });

    test('includes metadata in format', () {
      final metric = PerformanceMetric(
        name: 'api_call',
        value: 250.0,
        timestamp: DateTime.now(),
        metadata: {'endpoint': '/users'},
      );

      final formatted = metric.format();
      expect(formatted, contains('api_call'));
      expect(formatted, contains('250.00ms'));
    });

    test('converts to and from JSON', () {
      final original = PerformanceMetric(
        name: 'test',
        value: 100.5,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        metadata: {'key': 'value'},
      );

      final json = original.toJson();
      final restored = PerformanceMetric.fromJson(json);

      expect(restored.name, equals(original.name));
      expect(restored.value, equals(original.value));
      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.metadata, equals(original.metadata));
    });
  });
}
