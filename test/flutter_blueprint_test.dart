import 'package:test/test.dart';
import 'package:flutter_blueprint/src/config/blueprint_config.dart';

void main() {
  group('BlueprintConfig', () {
    test('creates config with all parameters', () {
      final config = BlueprintConfig(
        appName: 'test_app',
        platform: TargetPlatform.mobile,
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      expect(config.appName, 'test_app');
      expect(config.platform, TargetPlatform.mobile);
      expect(config.stateManagement, StateManagement.provider);
      expect(config.includeTheme, true);
      expect(config.includeLocalization, false);
    });

    test('converts to and from map correctly', () {
      final config = BlueprintConfig(
        appName: 'test_app',
        platform: TargetPlatform.mobile,
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

    test('parses target platform from string', () {
      expect(TargetPlatform.parse('mobile'), TargetPlatform.mobile);
      expect(TargetPlatform.parse('web'), TargetPlatform.web);
      expect(TargetPlatform.parse('desktop'), TargetPlatform.desktop);
    });

    test('throws on invalid state management', () {
      expect(
        () => StateManagement.parse('invalid'),
        throwsArgumentError,
      );
    });

    test('throws on invalid target platform', () {
      expect(
        () => TargetPlatform.parse('invalid'),
        throwsArgumentError,
      );
    });
  });
}
