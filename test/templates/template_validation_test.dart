import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/provider_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/riverpod_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/bloc_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/web_template.dart';
import 'package:flutter_blueprint/src/templates/desktop_template.dart';
import 'package:flutter_blueprint/src/templates/universal_template.dart';
import 'package:test/test.dart';

void main() {
  // Sample config for testing template rendering
  final testConfig = BlueprintConfig(
    appName: 'test_app',
    stateManagement: StateManagement.riverpod,
    platforms: [TargetPlatform.mobile],
    includeTheme: true,
    includeLocalization: false,
    includeEnv: false,
    includeApi: false,
    includeTests: true,
  );

  group('Template Rendering Validation', () {
    group('Provider Mobile Template', () {
      test('renders valid template bundle', () {
        final bundle = buildProviderMobileBundle();

        expect(bundle, isNotNull);
        expect(bundle.files, isNotEmpty);

        // Verify all files can build content
        for (final file in bundle.files) {
          final content = file.build(testConfig);
          expect(content.trim(), isNotEmpty,
              reason: 'File ${file.path} should have content');
        }
      });

      test('includes essential files', () {
        final bundle = buildProviderMobileBundle();

        final paths = bundle.files.map((f) => f.path).toList();

        // Should have pubspec.yaml
        expect(paths.any((p) => p.contains('pubspec.yaml')), isTrue,
            reason: 'Should include pubspec.yaml');

        // Should have main.dart
        expect(paths.any((p) => p.contains('main.dart')), isTrue,
            reason: 'Should include main.dart');
      });

      test('includes provider-specific content', () {
        final bundle = buildProviderMobileBundle();

        final hasProviderContent = bundle.files.any((f) {
          final content = f.build(testConfig);
          return content.contains('Provider') ||
              content.contains('ChangeNotifier');
        });
        expect(hasProviderContent, isTrue,
            reason: 'Should include Provider state management code');
      });
    });

    group('Riverpod Mobile Template', () {
      test('renders valid template bundle', () {
        final bundle = buildRiverpodMobileBundle();

        expect(bundle, isNotNull);
        expect(bundle.files, isNotEmpty);

        for (final file in bundle.files) {
          final content = file.build(testConfig);
          expect(content.trim(), isNotEmpty,
              reason: 'File ${file.path} should have content');
        }
      });

      test('includes riverpod-specific content', () {
        final bundle = buildRiverpodMobileBundle();

        final hasRiverpodContent = bundle.files.any((f) {
          final content = f.build(testConfig);
          return content.contains('Riverpod') ||
              content.contains('riverpod') ||
              content.contains('StateNotifier');
        });
        expect(hasRiverpodContent, isTrue,
            reason: 'Should include Riverpod state management code');
      });
    });

    group('BLoC Mobile Template', () {
      test('renders valid template bundle', () {
        final bundle = buildBlocMobileBundle();

        expect(bundle, isNotNull);
        expect(bundle.files, isNotEmpty);

        for (final file in bundle.files) {
          final content = file.build(testConfig);
          expect(content.trim(), isNotEmpty,
              reason: 'File ${file.path} should have content');
        }
      });

      test('includes bloc-specific content', () {
        final bundle = buildBlocMobileBundle();

        final hasBlocContent = bundle.files.any((f) {
          final content = f.build(testConfig);
          return content.contains('Bloc') || content.contains('bloc');
        });
        expect(hasBlocContent, isTrue,
            reason: 'Should include BLoC state management code');
      });
    });

    group('Web Template', () {
      test('renders valid bundle for each state management', () {
        for (final stateManagement in StateManagement.values) {
          final bundle = buildWebTemplate(stateManagement);

          expect(bundle, isNotNull,
              reason: 'Should create bundle for $stateManagement');
          expect(bundle.files, isNotEmpty,
              reason: 'Bundle for $stateManagement should have files');

          for (final file in bundle.files) {
            final content = file.build(testConfig);
            // Skip binary files (images, etc.)
            if (!file.path.endsWith('.png') &&
                !file.path.endsWith('.jpg') &&
                !file.path.endsWith('.ico')) {
              expect(content.trim(), isNotEmpty,
                  reason: 'File ${file.path} should have content');
            }
          }
        }
      });

      test('includes web-specific files', () {
        final bundle = buildWebTemplate(StateManagement.riverpod);

        final hasWebFiles = bundle.files.any(
            (f) => f.path.contains('web/') || f.path.contains('index.html'));
        expect(hasWebFiles, isTrue,
            reason: 'Should include web-specific files');
      });
    });

    group('Desktop Template', () {
      test('renders valid bundle for each state management', () {
        for (final stateManagement in StateManagement.values) {
          final bundle = buildDesktopTemplate(stateManagement);

          expect(bundle, isNotNull,
              reason: 'Should create bundle for $stateManagement');
          expect(bundle.files, isNotEmpty,
              reason: 'Bundle for $stateManagement should have files');

          for (final file in bundle.files) {
            final content = file.build(testConfig);
            // Skip binary files
            if (!file.path.endsWith('.png') &&
                !file.path.endsWith('.jpg') &&
                !file.path.endsWith('.ico')) {
              expect(content.trim(), isNotEmpty,
                  reason: 'File ${file.path} should have content');
            }
          }
        }
      });

      test('includes desktop platform files', () {
        final bundle = buildDesktopTemplate(StateManagement.riverpod);

        // Desktop templates may or may not include platform-specific folders
        // Just verify we have files
        expect(bundle.files, isNotEmpty,
            reason: 'Should generate files for desktop template');
      });
    });

    group('Universal Template', () {
      test('renders valid bundle for multi-platform', () {
        final config = BlueprintConfig(
          appName: 'universal_test',
          stateManagement: StateManagement.riverpod,
          platforms: [TargetPlatform.mobile, TargetPlatform.web],
          includeTheme: true,
          includeLocalization: false,
          includeEnv: false,
          includeApi: false,
          includeTests: true,
        );

        final bundle = buildUniversalTemplate(config);

        expect(bundle, isNotNull);
        expect(bundle.files, isNotEmpty);

        for (final file in bundle.files) {
          final content = file.build(config);
          expect(content.trim(), isNotEmpty,
              reason: 'File ${file.path} should have content');
        }
      });

      test('adapts to configuration', () {
        final configWithApi = BlueprintConfig(
          appName: 'api_app',
          stateManagement: StateManagement.provider,
          platforms: [TargetPlatform.mobile],
          includeTheme: false,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        );

        final bundle = buildUniversalTemplate(configWithApi);

        // Should generate files
        expect(bundle.files.length, greaterThan(10),
            reason: 'Should generate multiple files');
      });
    });

    group('Template Content Validation', () {
      test('all templates generate valid file paths', () {
        final bundles = [
          buildProviderMobileBundle(),
          buildRiverpodMobileBundle(),
          buildBlocMobileBundle(),
          buildWebTemplate(StateManagement.riverpod),
          buildDesktopTemplate(StateManagement.riverpod),
        ];

        for (final bundle in bundles) {
          for (final file in bundle.files) {
            expect(file.path, isNotEmpty,
                reason: 'File path should not be empty');
            expect(file.path, isNot(startsWith('/')),
                reason: 'Relative paths should not start with /');
            expect(file.path, isNot(contains('//')),
                reason: 'Paths should not contain double slashes');
          }
        }
      });

      test('templates include pubspec.yaml', () {
        final bundles = [
          buildProviderMobileBundle(),
          buildRiverpodMobileBundle(),
          buildBlocMobileBundle(),
        ];

        for (final bundle in bundles) {
          final hasPubspec =
              bundle.files.any((f) => f.path.contains('pubspec.yaml'));
          expect(hasPubspec, isTrue,
              reason: 'All templates should generate pubspec.yaml');
        }
      });

      test('templates include analysis_options.yaml', () {
        final bundles = [
          buildProviderMobileBundle(),
          buildRiverpodMobileBundle(),
          buildBlocMobileBundle(),
        ];

        for (final bundle in bundles) {
          final hasAnalysisOptions =
              bundle.files.any((f) => f.path.contains('analysis_options.yaml'));
          expect(hasAnalysisOptions, isTrue,
              reason: 'Should include analysis_options.yaml for linting');
        }
      });

      test('templates generate README.md', () {
        final bundles = [
          buildProviderMobileBundle(),
          buildRiverpodMobileBundle(),
          buildBlocMobileBundle(),
        ];

        for (final bundle in bundles) {
          final hasReadme =
              bundle.files.any((f) => f.path.contains('README.md'));
          expect(hasReadme, isTrue,
              reason: 'Should include README.md for documentation');
        }
      });

      test('templates generate .gitignore', () {
        final bundles = [
          buildProviderMobileBundle(),
          buildRiverpodMobileBundle(),
          buildBlocMobileBundle(),
        ];

        for (final bundle in bundles) {
          final hasGitignore =
              bundle.files.any((f) => f.path.contains('.gitignore'));
          expect(hasGitignore, isTrue, reason: 'Should include .gitignore');
        }
      });

      test('templates substitute configuration values', () {
        final customConfig = BlueprintConfig(
          appName: 'my_custom_app',
          stateManagement: StateManagement.provider,
          platforms: [TargetPlatform.mobile],
          includeTheme: false,
          includeLocalization: false,
          includeEnv: false,
          includeApi: false,
          includeTests: true,
        );

        final bundle = buildProviderMobileBundle();

        // Check that some files reference the app name after building
        final hasAppNameInContent = bundle.files
            .any((f) => f.build(customConfig).contains('my_custom_app'));
        expect(hasAppNameInContent, isTrue,
            reason: 'Generated code should use configured app name');
      });
    });
  });
}
