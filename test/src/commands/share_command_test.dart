import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_blueprint/src/commands/share_command.dart';
import 'package:flutter_blueprint/src/config/config_repository.dart';
import 'package:flutter_blueprint/src/config/shared_config.dart';

void main() {
  group('ShareCommand', () {
    late Directory tempDir;
    late ShareCommand command;
    late ConfigRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('share_command_test_');
      command = ShareCommand();
      repository = ConfigRepository(customConfigPath: tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('command setup', () {
      test('has correct name', () {
        expect(command.name, 'share');
      });

      test('has description', () {
        expect(command.description, isNotEmpty);
        expect(command.description, contains('shared'));
      });

      test('has verbose flag', () {
        expect(command.argParser.options, contains('verbose'));
        final verboseOption = command.argParser.options['verbose']!;
        expect(verboseOption.negatable, isFalse);
      });
    });

    group('ConfigRepository export', () {
      test('export command integration', () async {
        // Save a test config
        final config = SharedBlueprintConfig.defaultConfig();
        await repository.save(config, 'test-export');

        // Create export file path
        final exportPath = p.join(tempDir.path, 'exported.yaml');

        // Export config
        await repository.export('test-export', exportPath);

        // Verify exported file exists
        final exportedFile = File(exportPath);
        expect(await exportedFile.exists(), isTrue);

        // Verify content
        final content = await exportedFile.readAsString();
        expect(content, contains('name: Default Configuration'));
      });
    });

    group('ConfigRepository import', () {
      test('import command integration', () async {
        // Create a test config file
        final sourceFile = File(p.join(tempDir.path, 'source.yaml'));
        final config = SharedBlueprintConfig.defaultConfig();
        final yamlMap = config.toYaml();
        // Convert map to YAML string manually
        final yamlContent = '''
name: ${yamlMap['name']}
version: ${yamlMap['version']}
author: ${yamlMap['author']}
description: ${yamlMap['description']}
defaults:
  state_management: ${yamlMap['defaults']['state_management']}
  platforms: ${yamlMap['defaults']['platforms']}
  include_theme: ${yamlMap['defaults']['include_theme']}
  include_api: ${yamlMap['defaults']['include_api']}
  include_tests: ${yamlMap['defaults']['include_tests']}
  include_localization: ${yamlMap['defaults']['include_localization']}
  include_env: ${yamlMap['defaults']['include_env']}
  ci_provider: ${yamlMap['defaults']['ci_provider']}
required_packages: ${yamlMap['required_packages']}
code_style:
  line_length: ${yamlMap['code_style']['line_length']}
  use_trailing_commas: ${yamlMap['code_style']['use_trailing_commas']}
  sort_imports: ${yamlMap['code_style']['sort_imports']}
  naming_convention: ${yamlMap['code_style']['naming_convention']}
  preferred_quotes: ${yamlMap['code_style']['preferred_quotes']}
architecture:
  pattern: ${yamlMap['architecture']['pattern']}
  feature_structure: ${yamlMap['architecture']['feature_structure']}
  use_clean_architecture: ${yamlMap['architecture']['use_clean_architecture']}
  layer_separation: ${yamlMap['architecture']['layer_separation']}
''';
        await sourceFile.writeAsString(yamlContent);

        // Import config
        await repository.import(sourceFile.path, 'imported-config');

        // Verify imported config
        final loadedConfig = await repository.load('imported-config');
        expect(loadedConfig.name, config.name);
        expect(loadedConfig.description, config.description);
      });
    });

    group('ConfigRepository delete', () {
      test('delete command integration', () async {
        // Save a test config
        final config = SharedBlueprintConfig.defaultConfig();
        await repository.save(config, 'test-delete');

        // Verify config exists
        final configs = await repository.listConfigs();
        expect(configs.any((c) => c.name == 'test-delete'), isTrue);

        // Delete config
        await repository.delete('test-delete');

        // Verify config is deleted
        final configsAfter = await repository.listConfigs();
        expect(configsAfter.any((c) => c.name == 'test-delete'), isFalse);
      });
    });

    group('ConfigRepository validate', () {
      test('validate command integration - valid config', () async {
        final config = SharedBlueprintConfig(
          name: 'valid-config',
          author: 'Test Author',
          description: 'A valid configuration',
          version: '1.0.0',
          defaults: SharedConfigDefaults.standard(),
          codeStyle: CodeStyleConfig.defaults(),
          architecture: ArchitectureConfig.defaults(),
        );
        await repository.save(config, 'valid-config');

        // Get the config file path (no 'configs' subdirectory when using customConfigPath)
        final configPath = p.join(
          tempDir.path,
          'valid-config.yaml',
        );

        // Validate config - verify file exists first
        expect(await File(configPath).exists(), isTrue,
            reason: 'Config file should exist at $configPath');

        // Validate config
        final result = await repository.validate(configPath);

        // Print errors if any
        if (!result.isValid) {
          print('Validation errors: ${result.errors}');
          print('Validation warnings: ${result.warnings}');
        }

        expect(result.isValid, isTrue, reason: 'Config should be valid');
        expect(result.errors, isEmpty);
      });

      test('validate command integration - config with warnings', () async {
        // Create a config file with warnings
        final configPath = p.join(
          tempDir.path,
          'config-with-warnings.yaml',
        );

        // Write config missing some optional fields
        await File(configPath).writeAsString('''
name: test-config
# missing version and author
defaults:
  state_management: provider
  platforms: [mobile]
  include_theme: true
  include_api: true
  include_tests: true
code_style:
  line_length: 80
architecture:
  pattern: clean
''');

        // Validate config
        final result = await repository.validate(configPath);
        expect(result.isValid, isTrue); // Valid but has warnings
        expect(result.warnings,
            isNotEmpty); // Should have warnings for missing version/author
      });
    });

    group('ConfigRepository integration', () {
      test('save and load config', () async {
        final config = SharedBlueprintConfig(
          name: 'integration-test',
          author: 'Test Author',
          description: 'Integration test config',
          version: '1.0.0',
          defaults: SharedConfigDefaults.standard(),
          codeStyle: CodeStyleConfig.defaults(),
          architecture: ArchitectureConfig.defaults(),
        );

        // Save
        await repository.save(config, 'integration-test');

        // Load
        final loadedConfig = await repository.load('integration-test');
        expect(loadedConfig.name, config.name);
        expect(loadedConfig.description, config.description);
        expect(loadedConfig.version, config.version);
      });

      test('list multiple configs', () async {
        // Save multiple configs
        for (var i = 1; i <= 3; i++) {
          final config = SharedBlueprintConfig(
            name: 'config-$i',
            author: 'Test Author',
            description: 'Configuration $i',
            version: '1.0.0',
            defaults: SharedConfigDefaults.standard(),
            codeStyle: CodeStyleConfig.defaults(),
            architecture: ArchitectureConfig.defaults(),
          );
          await repository.save(config, 'config-$i');
        }

        // List configs
        final configs = await repository.listConfigs();
        expect(configs.length, 3);
        expect(configs.any((c) => c.name == 'config-1'), isTrue);
        expect(configs.any((c) => c.name == 'config-2'), isTrue);
        expect(configs.any((c) => c.name == 'config-3'), isTrue);
      });

      test('export and import round trip', () async {
        final original = SharedBlueprintConfig(
          name: 'roundtrip-test',
          author: 'Test Author',
          description: 'Round trip test',
          version: '1.0.0',
          defaults: SharedConfigDefaults.standard(),
          codeStyle: CodeStyleConfig.defaults(),
          architecture: ArchitectureConfig.defaults(),
        );

        // Save original
        await repository.save(original, 'original');

        // Export
        final exportPath = p.join(tempDir.path, 'exported.yaml');
        await repository.export('original', exportPath);

        // Import with new name
        await repository.import(exportPath, 'imported');

        // Load imported
        final imported = await repository.load('imported');
        expect(imported.name, original.name);
        expect(imported.description, original.description);
        expect(imported.version, original.version);
      });

      test('delete non-existent config throws', () async {
        expect(
          () => repository.delete('non-existent'),
          throwsA(isA<Exception>()),
        );
      });

      test('load non-existent config throws', () async {
        expect(
          () => repository.load('non-existent'),
          throwsA(isA<Exception>()),
        );
      });

      test('validate non-existent config returns invalid result', () async {
        final nonExistentPath = p.join(tempDir.path, 'non-existent.yaml');
        final result = await repository.validate(nonExistentPath);
        expect(result.isValid, isFalse);
        expect(result.errors, isNotEmpty);
      });
    });
  });
}
