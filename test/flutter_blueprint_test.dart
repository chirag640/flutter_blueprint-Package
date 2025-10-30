import 'package:test/test.dart';
import 'package:flutter_blueprint/src/config/blueprint_config.dart';

void main() {
  group('BlueprintConfig', () {
    test('creates config with all parameters', () {
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      expect(config.appName, 'test_app');
      expect(config.platforms, [TargetPlatform.mobile]);
      expect(config.stateManagement, StateManagement.provider);
      expect(config.includeTheme, true);
      expect(config.includeLocalization, false);
    });

    test('converts to and from map correctly', () {
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
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

    group('Multi-platform features', () {
      test('parses multiple platforms from comma-separated string', () {
        final platforms = TargetPlatform.parseMultiple('mobile,web,desktop');
        expect(platforms.length, 3);
        expect(
            platforms,
            containsAll([
              TargetPlatform.mobile,
              TargetPlatform.web,
              TargetPlatform.desktop,
            ]));
      });

      test('parses "all" to include all platforms', () {
        final platforms = TargetPlatform.parseMultiple('all');
        expect(platforms.length, 3);
        expect(platforms, TargetPlatform.values);
      });

      test('handles spaces in comma-separated list', () {
        final platforms = TargetPlatform.parseMultiple('mobile, web , desktop');
        expect(platforms.length, 3);
      });

      test('detects multi-platform configuration', () {
        final singlePlatform = BlueprintConfig(
          appName: 'test_app',
          platforms: [TargetPlatform.mobile],
          stateManagement: StateManagement.bloc,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        );
        expect(singlePlatform.isMultiPlatform, false);

        final multiPlatform = BlueprintConfig(
          appName: 'test_app',
          platforms: [TargetPlatform.mobile, TargetPlatform.web],
          stateManagement: StateManagement.bloc,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        );
        expect(multiPlatform.isMultiPlatform, true);
      });

      test('detects universal configuration', () {
        final universal = BlueprintConfig(
          appName: 'test_app',
          platforms: TargetPlatform.values,
          stateManagement: StateManagement.riverpod,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        );
        expect(universal.isUniversal, true);
        expect(universal.isMultiPlatform, true);
      });

      test('hasPlatform checks specific platform presence', () {
        final config = BlueprintConfig(
          appName: 'test_app',
          platforms: [TargetPlatform.mobile, TargetPlatform.web],
          stateManagement: StateManagement.provider,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        );
        expect(config.hasPlatform(TargetPlatform.mobile), true);
        expect(config.hasPlatform(TargetPlatform.web), true);
        expect(config.hasPlatform(TargetPlatform.desktop), false);
      });

      test('serializes and deserializes multiple platforms', () {
        final config = BlueprintConfig(
          appName: 'multi_app',
          platforms: [
            TargetPlatform.mobile,
            TargetPlatform.web,
            TargetPlatform.desktop
          ],
          stateManagement: StateManagement.bloc,
          includeTheme: true,
          includeLocalization: true,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        );

        final map = config.toMap();
        final restored = BlueprintConfig.fromMap(map);

        expect(restored.platforms.length, 3);
        expect(
            restored.platforms,
            containsAll([
              TargetPlatform.mobile,
              TargetPlatform.web,
              TargetPlatform.desktop,
            ]));
      });

      test('handles backwards compatibility with single platform', () {
        final oldFormatMap = {
          'app_name': 'legacy_app',
          'platform': 'mobile', // Old format
          'state_management': 'provider',
          'ci_provider': 'none',
          'features': {
            'theme': true,
            'localization': false,
            'env': true,
            'api': true,
            'tests': true,
          },
        };

        final config = BlueprintConfig.fromMap(oldFormatMap);
        expect(config.platforms.length, 1);
        expect(config.platforms.first, TargetPlatform.mobile);
      });

      test('throws when parsing empty platform list', () {
        expect(
          () => TargetPlatform.parseMultiple(''),
          throwsArgumentError,
        );
      });

      test('throws when parsing invalid platform in list', () {
        expect(
          () => TargetPlatform.parseMultiple('mobile,invalid,web'),
          throwsArgumentError,
        );
      });
    });
  });
}
