import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/utils/project_preview.dart';
import 'package:flutter_blueprint/src/utils/logger.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectPreview', () {
    late ProjectPreview previewer;
    late _TestLogger logger;

    setUp(() {
      logger = _TestLogger();
      previewer = ProjectPreview(logger: logger);
    });

    test('shows basic project structure for blank template', () {
      final config = const BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      previewer.show(config);

      expect(logger.output, contains('test_app/'));
      expect(logger.output, contains('lib/'));
      expect(logger.output, contains('main.dart'));
      expect(logger.output, contains('Project Statistics:'));
      expect(logger.output, contains('Total files:'));
      expect(logger.output, contains('Configuration:'));
    });

    test('shows multi-platform structure', () {
      final config = const BlueprintConfig(
        appName: 'multi_app',
        platforms: [
          TargetPlatform.mobile,
          TargetPlatform.web,
          TargetPlatform.desktop
        ],
        stateManagement: StateManagement.riverpod,
        includeTheme: true,
        includeLocalization: true,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      previewer.show(config);

      expect(logger.output, contains('multi_app/'));
      expect(logger.output, contains('web/'));
      expect(logger.output, contains('windows/'));
      expect(logger.output, contains('Multi-platform notes:'));
    });

    test('shows state management specific files', () {
      // Test Provider
      final providerConfig = const BlueprintConfig(
        appName: 'provider_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
      );

      logger.clear();
      previewer.show(providerConfig);
      expect(logger.output, contains('home_provider.dart'));

      // Test Riverpod
      final riverpodConfig = const BlueprintConfig(
        appName: 'riverpod_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.riverpod,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
      );

      logger.clear();
      previewer.show(riverpodConfig);
      expect(logger.output, contains('home_provider.dart'));
      expect(logger.output, contains('home_state.dart'));

      // Test Bloc
      final blocConfig = const BlueprintConfig(
        appName: 'bloc_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.bloc,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
      );

      logger.clear();
      previewer.show(blocConfig);
      expect(logger.output, contains('home_bloc.dart'));
      expect(logger.output, contains('home_event.dart'));
      expect(logger.output, contains('home_state.dart'));
    });

    test('shows optional features when included', () {
      final config = const BlueprintConfig(
        appName: 'full_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: true,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      previewer.show(config);

      expect(logger.output, contains('theme/'));
      expect(logger.output, contains('l10n/'));
      expect(logger.output, contains('network/'));
      expect(logger.output, contains('config/'));
      expect(logger.output, contains('test/'));
    });

    test('shows CI/CD configuration when specified', () {
      final githubConfig = const BlueprintConfig(
        appName: 'github_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
        ciProvider: CIProvider.github,
      );

      logger.clear();
      previewer.show(githubConfig);
      expect(logger.output, contains('.github/'));
      expect(logger.output, contains('ci.yml'));
    });

    test('calculates accurate file counts', () {
      final minimalConfig = const BlueprintConfig(
        appName: 'minimal_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
      );

      logger.clear();
      previewer.show(minimalConfig);

      // Should show statistics
      expect(logger.output, contains('Total files:'));
      expect(logger.output, contains('Dart files:'));
      expect(logger.output, contains('Config files:'));
    });
  });
}

/// Test logger that captures output to a string buffer
class _TestLogger extends Logger {
  final StringBuffer _buffer = StringBuffer();

  String get output => _buffer.toString();

  void clear() => _buffer.clear();

  @override
  void debug(String message) {
    _buffer.writeln(message);
  }

  @override
  void info(String message) {
    _buffer.writeln(message);
  }

  @override
  void success(String message) {
    _buffer.writeln(message);
  }

  @override
  void warning(String message) {
    _buffer.writeln(message);
  }

  @override
  void error(String message) {
    _buffer.writeln(message);
  }
}
