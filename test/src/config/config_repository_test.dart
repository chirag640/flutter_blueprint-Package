import 'dart:io';
import 'package:flutter_blueprint/flutter_blueprint.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late ConfigRepository repository;

  setUp(() async {
    // Create a temporary directory for testing
    tempDir = await Directory.systemTemp.createTemp('config_repo_test_');
    repository = ConfigRepository(customConfigPath: tempDir.path);
  });

  tearDown(() async {
    // Clean up temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ConfigRepository', () {
    test('defaultConfigDirectory returns correct path', () {
      final repo = ConfigRepository(customConfigPath: '/custom/path');
      expect(repo.defaultConfigDirectory, '/custom/path');
    });

    test('save creates config file', () async {
      final config = SharedBlueprintConfig(
        name: 'test_config',
        version: '1.0.0',
        author: 'Test Author',
        description: 'Test description',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.provider,
          platforms: [TargetPlatform.mobile],
          ciProvider: CIProvider.github,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        ),
        codeStyle: CodeStyleConfig(
          lineLength: 80,
          preferConst: true,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.snakeCase,
        ),
      );

      await repository.save(config, 'test_config');

      final configFile = File(path.join(tempDir.path, 'test_config.yaml'));
      expect(await configFile.exists(), isTrue);

      final content = await configFile.readAsString();
      expect(content, contains('name: test_config'));
      expect(content, contains('version: 1.0.0'));
      expect(content, contains('author: Test Author'));
    });

    test('load reads config file correctly', () async {
      final config = SharedBlueprintConfig(
        name: 'load_test',
        version: '2.0.0',
        author: 'Load Test Author',
        description: 'Load test description',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.riverpod,
          platforms: [TargetPlatform.mobile, TargetPlatform.web],
          ciProvider: CIProvider.gitlab,
          includeTheme: true,
          includeLocalization: true,
          includeEnv: false,
          includeApi: true,
          includeTests: false,
        ),
        requiredPackages: ['dio', 'shared_preferences'],
        codeStyle: CodeStyleConfig(
          lineLength: 100,
          preferConst: false,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.camelCase,
        ),
      );

      await repository.save(config, 'load_test');
      final loadedConfig = await repository.load('load_test');

      expect(loadedConfig.name, 'load_test');
      expect(loadedConfig.version, '2.0.0');
      expect(loadedConfig.author, 'Load Test Author');
      expect(loadedConfig.description, 'Load test description');
      expect(loadedConfig.defaults.stateManagement, StateManagement.riverpod);
      expect(loadedConfig.defaults.platforms,
          [TargetPlatform.mobile, TargetPlatform.web]);
      expect(loadedConfig.defaults.ciProvider, CIProvider.gitlab);
      expect(loadedConfig.requiredPackages, ['dio', 'shared_preferences']);
      expect(loadedConfig.codeStyle.lineLength, 100);
      expect(loadedConfig.codeStyle.preferConst, false);
      expect(loadedConfig.architecture.namingConvention,
          NamingConvention.camelCase);
    });

    test('load with .yaml extension', () async {
      final config = SharedBlueprintConfig.defaultConfig();
      await repository.save(config, 'with_ext');

      final loadedConfig = await repository.load('with_ext.yaml');
      expect(loadedConfig.name, 'Default Configuration');
    });

    test('load throws exception for non-existent config', () async {
      expect(
        () => repository.load('non_existent'),
        throwsException,
      );
    });

    test('listConfigs returns all saved configs', () async {
      final config1 = SharedBlueprintConfig(
        name: 'config1',
        version: '1.0.0',
        author: 'Author 1',
        description: 'First config',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.provider,
          platforms: [TargetPlatform.mobile],
          ciProvider: CIProvider.github,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        ),
        codeStyle: CodeStyleConfig(
          lineLength: 80,
          preferConst: true,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.snakeCase,
        ),
      );

      final config2 = SharedBlueprintConfig(
        name: 'config2',
        version: '2.0.0',
        author: 'Author 2',
        description: 'Second config',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.bloc,
          platforms: [TargetPlatform.web],
          ciProvider: CIProvider.azure,
          includeTheme: false,
          includeLocalization: true,
          includeEnv: false,
          includeApi: false,
          includeTests: true,
        ),
        codeStyle: CodeStyleConfig(
          lineLength: 120,
          preferConst: false,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.camelCase,
        ),
      );

      await repository.save(config1, 'config1');
      await repository.save(config2, 'config2');

      final configs = await repository.listConfigs();

      expect(configs.length, 2);
      expect(configs.map((c) => c.name), containsAll(['config1', 'config2']));
      expect(configs.map((c) => c.config.name),
          containsAll(['config1', 'config2']));
    });

    test('listConfigs returns empty list for empty directory', () async {
      final configs = await repository.listConfigs();
      expect(configs, isEmpty);
    });

    test('delete removes config file', () async {
      final config = SharedBlueprintConfig.defaultConfig();
      await repository.save(config, 'to_delete');

      final configFile = File(path.join(tempDir.path, 'to_delete.yaml'));
      expect(await configFile.exists(), isTrue);

      await repository.delete('to_delete');
      expect(await configFile.exists(), isFalse);
    });

    test('delete throws exception for non-existent config', () async {
      expect(
        () => repository.delete('non_existent'),
        throwsException,
      );
    });

    test('export creates file at target path', () async {
      final config = SharedBlueprintConfig.defaultConfig();
      await repository.save(config, 'to_export');

      final exportDir = await Directory.systemTemp.createTemp('export_test_');
      final exportPath = path.join(exportDir.path, 'exported.yaml');

      try {
        await repository.export('to_export', exportPath);

        final exportedFile = File(exportPath);
        expect(await exportedFile.exists(), isTrue);

        final content = await exportedFile.readAsString();
        expect(content, contains('name: Default Configuration'));
      } finally {
        await exportDir.delete(recursive: true);
      }
    });

    test('import loads config from file', () async {
      final sourceDir = await Directory.systemTemp.createTemp('import_test_');

      try {
        final config = SharedBlueprintConfig(
          name: 'imported_config',
          version: '3.0.0',
          author: 'Import Author',
          description: 'Imported configuration',
          defaults: SharedConfigDefaults(
            stateManagement: StateManagement.bloc,
            platforms: [TargetPlatform.desktop],
            ciProvider: CIProvider.azure,
            includeTheme: true,
            includeLocalization: true,
            includeEnv: true,
            includeApi: true,
            includeTests: true,
          ),
          codeStyle: CodeStyleConfig(
            lineLength: 90,
            preferConst: true,
          ),
          architecture: ArchitectureConfig(
            namingConvention: NamingConvention.pascalCase,
          ),
        );

        // Create source file
        final sourceFile = File(path.join(sourceDir.path, 'source.yaml'));
        final yaml = _toYamlString(config.toYaml());
        await sourceFile.writeAsString(yaml);

        // Import
        await repository.import(sourceFile.path, 'imported');

        // Verify
        final loadedConfig = await repository.load('imported');
        expect(loadedConfig.name, 'imported_config');
        expect(loadedConfig.version, '3.0.0');
        expect(loadedConfig.author, 'Import Author');
      } finally {
        await sourceDir.delete(recursive: true);
      }
    });

    test('import auto-detects name from filename', () async {
      final sourceDir = await Directory.systemTemp.createTemp('import_test_');

      try {
        final config = SharedBlueprintConfig.defaultConfig();

        final sourceFile = File(path.join(sourceDir.path, 'autoname.yaml'));
        final yaml = _toYamlString(config.toYaml());
        await sourceFile.writeAsString(yaml);

        await repository.import(sourceFile.path, null);

        final loadedConfig = await repository.load('autoname');
        expect(loadedConfig.name, 'Default Configuration');
      } finally {
        await sourceDir.delete(recursive: true);
      }
    });

    test('validate returns valid for correct config', () async {
      final config = SharedBlueprintConfig.defaultConfig();
      await repository.save(config, 'valid_config');

      final configPath = path.join(tempDir.path, 'valid_config.yaml');
      final result = await repository.validate(configPath);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('validate returns errors for missing required fields', () async {
      final invalidYaml = '''
description: Missing name field
defaults:
  state_management: provider
  platforms:
    - mobile
  ci_provider: github
  include_theme: true
  include_localization: false
  include_env: true
  include_api: true
  include_tests: true
''';

      final configFile = File(path.join(tempDir.path, 'invalid.yaml'));
      await configFile.writeAsString(invalidYaml);

      final result = await repository.validate(configFile.path);

      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);
      expect(result.errors.first, contains('name'));
    });

    test('validate returns warnings for missing recommended fields', () async {
      final yamlWithWarnings = '''
name: test_config
description: Missing version and author
defaults:
  state_management: provider
  platforms:
    - mobile
  ci_provider: github
  include_theme: true
  include_localization: false
  include_env: true
  include_api: true
  include_tests: true
''';

      final configFile = File(path.join(tempDir.path, 'warnings.yaml'));
      await configFile.writeAsString(yamlWithWarnings);

      final result = await repository.validate(configFile.path);

      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isTrue);
      expect(result.warnings, isNotEmpty);
    });

    test('validate returns error for non-existent file', () async {
      final result = await repository.validate('/non/existent/file.yaml');

      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);
      expect(result.errors.first, contains('does not exist'));
    });
  });

  group('ConfigInfo', () {
    test('toString returns formatted string', () {
      final config = SharedBlueprintConfig(
        name: 'test_config',
        version: '1.0.0',
        author: 'Test Author',
        description: 'Test description',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.provider,
          platforms: [TargetPlatform.mobile],
          ciProvider: CIProvider.github,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        ),
        codeStyle: CodeStyleConfig(
          lineLength: 80,
          preferConst: true,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.snakeCase,
        ),
      );

      final info = ConfigInfo(
        name: 'my_config',
        filePath: '/path/to/config.yaml',
        config: config,
      );

      final str = info.toString();
      expect(str, contains('my_config'));
      expect(str, contains('v1.0.0'));
      expect(str, contains('Test description'));
    });
  });

  group('ValidationResult', () {
    test('format shows valid message for valid config', () {
      final result = ValidationResult(
        isValid: true,
        errors: [],
        warnings: [],
      );

      final formatted = result.format();
      expect(formatted, contains('✅'));
      expect(formatted, contains('valid'));
    });

    test('format shows errors for invalid config', () {
      final result = ValidationResult(
        isValid: false,
        errors: ['Missing name field', 'Invalid structure'],
        warnings: [],
      );

      final formatted = result.format();
      expect(formatted, contains('❌'));
      expect(formatted, contains('invalid'));
      expect(formatted, contains('Missing name field'));
      expect(formatted, contains('Invalid structure'));
    });

    test('format shows warnings', () {
      final result = ValidationResult(
        isValid: true,
        errors: [],
        warnings: ['Missing version', 'Missing author'],
      );

      final formatted = result.format();
      expect(formatted, contains('⚠️'));
      expect(formatted, contains('Missing version'));
      expect(formatted, contains('Missing author'));
    });

    test('hasWarnings returns true when warnings exist', () {
      final result = ValidationResult(
        isValid: true,
        errors: [],
        warnings: ['Warning 1'],
      );

      expect(result.hasWarnings, isTrue);
    });

    test('hasWarnings returns false when no warnings', () {
      final result = ValidationResult(
        isValid: true,
        errors: [],
        warnings: [],
      );

      expect(result.hasWarnings, isFalse);
    });
  });
}

/// Helper function to convert map to YAML string
String _toYamlString(Map<String, dynamic> data, [int indent = 0]) {
  final buffer = StringBuffer();
  final indentStr = '  ' * indent;

  data.forEach((key, value) {
    if (value == null) {
      return;
    }

    if (value is Map) {
      buffer.writeln('$indentStr$key:');
      buffer.write(_toYamlString(
        Map<String, dynamic>.from(value),
        indent + 1,
      ));
    } else if (value is List) {
      buffer.writeln('$indentStr$key:');
      for (final item in value) {
        if (item is Map) {
          buffer.writeln('$indentStr  -');
          buffer.write(_toYamlString(
            Map<String, dynamic>.from(item),
            indent + 2,
          ));
        } else {
          buffer.writeln('$indentStr  - $item');
        }
      }
    } else if (value is String) {
      final needsQuotes = value.contains(':') ||
          value.contains('#') ||
          value.contains('[') ||
          value.contains(']') ||
          value.contains('{') ||
          value.contains('}');
      if (needsQuotes) {
        buffer.writeln('$indentStr$key: "$value"');
      } else {
        buffer.writeln('$indentStr$key: $value');
      }
    } else {
      buffer.writeln('$indentStr$key: $value');
    }
  });

  return buffer.toString();
}
