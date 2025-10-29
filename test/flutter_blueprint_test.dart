import 'package:test/test.dart';
import 'package:flutter_blueprint/src/config/blueprint_config.dart';

void main() {
  group('BlueprintConfig', () {
    test('creates config with all parameters', () {
      final config = BlueprintConfig(
        appName: 'test_app',
        platform: 'mobile',
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      expect(config.appName, 'test_app');
      expect(config.platform, 'mobile');
      expect(config.stateManagement, StateManagement.provider);
      expect(config.includeTheme, true);
      expect(config.includeLocalization, false);
    });

    test('converts to and from map correctly', () {
      final config = BlueprintConfig(
        appName: 'test_app',
        platform: 'mobile',
        stateManagement: StateManagement.riverpod,
        includeTheme: true,
        includeLocalization: true,
        includeEnv: true,
        includeApi: false,
        includeTests: true,
      );

      final map = config.toMap();
      final restored = BlueprintConfig.fromMap(map);

      expect(restored.appName, config.appName);
      expect(restored.stateManagement, config.stateManagement);
      expect(restored.includeApi, config.includeApi);
    });

    test('parses state management from string', () {
      expect(StateManagement.parse('provider'), StateManagement.provider);
      expect(StateManagement.parse('riverpod'), StateManagement.riverpod);
      expect(StateManagement.parse('bloc'), StateManagement.bloc);
    });

    test('throws on invalid state management', () {
      expect(
        () => StateManagement.parse('invalid'),
        throwsArgumentError,
      );
    });
  });
}
