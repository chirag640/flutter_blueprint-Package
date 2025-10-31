import 'package:flutter_blueprint/flutter_blueprint.dart';
import 'package:test/test.dart';

void main() {
  group('SharedBlueprintConfig', () {
    test('creates config with required fields', () {
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

      expect(config.name, 'test_config');
      expect(config.version, '1.0.0');
      expect(config.author, 'Test Author');
      expect(config.description, 'Test description');
      expect(config.defaults.stateManagement, StateManagement.provider);
      expect(config.defaults.platforms, [TargetPlatform.mobile]);
      expect(config.codeStyle.lineLength, 80);
      expect(config.codeStyle.preferConst, true);
      expect(config.architecture.namingConvention, NamingConvention.snakeCase);
    });

    test('creates config with optional fields', () {
      final config = SharedBlueprintConfig(
        name: 'test_config',
        version: '1.0.0',
        author: 'Test Author',
        description: 'Test description',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.riverpod,
          platforms: [TargetPlatform.mobile, TargetPlatform.web],
          ciProvider: CIProvider.gitlab,
          includeTheme: true,
          includeLocalization: true,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
        ),
        requiredPackages: ['dio', 'shared_preferences', 'go_router'],
        codeStyle: CodeStyleConfig(
          lineLength: 100,
          preferConst: false,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.camelCase,
        ),
        metadata: {
          'organization': 'Test Org',
          'team': 'Mobile Team',
        },
      );

      expect(
          config.requiredPackages, ['dio', 'shared_preferences', 'go_router']);
      expect(config.metadata?['organization'], 'Test Org');
      expect(config.metadata?['team'], 'Mobile Team');
    });

    test('converts to YAML correctly', () {
      final config = SharedBlueprintConfig(
        name: 'test_config',
        version: '1.0.0',
        author: 'Test Author',
        description: 'Test description',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.bloc,
          platforms: [TargetPlatform.mobile],
          ciProvider: CIProvider.azure,
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: false,
          includeTests: true,
        ),
        requiredPackages: ['dio'],
        codeStyle: CodeStyleConfig(
          lineLength: 80,
          preferConst: true,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.snakeCase,
        ),
      );

      final yaml = config.toYaml();

      expect(yaml['name'], 'test_config');
      expect(yaml['version'], '1.0.0');
      expect(yaml['author'], 'Test Author');
      expect(yaml['description'], 'Test description');
      expect(yaml['required_packages'], ['dio']);

      final defaults = yaml['defaults'] as Map<String, dynamic>;
      expect(defaults['state_management'], 'bloc');
      expect(defaults['platforms'], ['mobile']);
      expect(defaults['ci_provider'], 'azure');
      expect(defaults['include_theme'], true);
      expect(defaults['include_localization'], false);
      expect(defaults['include_api'], false);
      expect(defaults['include_tests'], true);

      final codeStyle = yaml['code_style'] as Map<String, dynamic>;
      expect(codeStyle['line_length'], 80);
      expect(codeStyle['prefer_const'], true);

      final architecture = yaml['architecture'] as Map<String, dynamic>;
      expect(architecture['naming_convention'], 'snake_case');
    });

    test('creates from YAML correctly', () {
      final yaml = {
        'name': 'yaml_config',
        'version': '2.0.0',
        'author': 'YAML Author',
        'description': 'YAML description',
        'defaults': {
          'state_management': 'riverpod',
          'platforms': ['mobile', 'web'],
          'ci_provider': 'github',
          'include_theme': true,
          'include_localization': true,
          'include_env': false,
          'include_api': true,
          'include_tests': false,
        },
        'required_packages': ['http', 'provider'],
        'code_style': {
          'line_length': 120,
          'prefer_const': false,
        },
        'architecture': {
          'naming_convention': 'camelCase',
        },
        'metadata': {
          'key': 'value',
        },
      };

      final config = SharedBlueprintConfig.fromYaml(yaml);

      expect(config.name, 'yaml_config');
      expect(config.version, '2.0.0');
      expect(config.author, 'YAML Author');
      expect(config.description, 'YAML description');
      expect(config.defaults.stateManagement, StateManagement.riverpod);
      expect(config.defaults.platforms,
          [TargetPlatform.mobile, TargetPlatform.web]);
      expect(config.defaults.ciProvider, CIProvider.github);
      expect(config.defaults.includeTheme, true);
      expect(config.defaults.includeLocalization, true);
      expect(config.defaults.includeEnv, false);
      expect(config.defaults.includeApi, true);
      expect(config.defaults.includeTests, false);
      expect(config.requiredPackages, ['http', 'provider']);
      expect(config.codeStyle.lineLength, 120);
      expect(config.codeStyle.preferConst, false);
      expect(config.architecture.namingConvention, NamingConvention.camelCase);
      expect(config.metadata?['key'], 'value');
    });

    test('creates from YAML with defaults for missing fields', () {
      final yaml = {
        'name': 'minimal_config',
        'defaults': {
          'state_management': 'provider',
          'platforms': ['mobile'],
          'ci_provider': 'none',
          'include_theme': false,
          'include_localization': false,
          'include_env': false,
          'include_api': false,
          'include_tests': false,
        },
      };

      final config = SharedBlueprintConfig.fromYaml(yaml);

      expect(config.name, 'minimal_config');
      expect(config.version, '1.0.0'); // Default
      expect(config.author, 'Unknown'); // Default
      expect(config.description, ''); // Default
      expect(config.requiredPackages, isEmpty);
    });

    test('converts to BlueprintConfig correctly', () {
      final sharedConfig = SharedBlueprintConfig(
        name: 'test_config',
        version: '1.0.0',
        author: 'Test Author',
        description: 'Test description',
        defaults: SharedConfigDefaults(
          stateManagement: StateManagement.bloc,
          platforms: [TargetPlatform.mobile, TargetPlatform.web],
          ciProvider: CIProvider.gitlab,
          includeTheme: true,
          includeLocalization: true,
          includeEnv: false,
          includeApi: true,
          includeTests: false,
        ),
        codeStyle: CodeStyleConfig(
          lineLength: 80,
          preferConst: true,
        ),
        architecture: ArchitectureConfig(
          namingConvention: NamingConvention.snakeCase,
        ),
      );

      final blueprintConfig = sharedConfig.toBlueprintConfig('my_app');

      expect(blueprintConfig.appName, 'my_app');
      expect(blueprintConfig.stateManagement, StateManagement.bloc);
      expect(blueprintConfig.platforms,
          [TargetPlatform.mobile, TargetPlatform.web]);
      expect(blueprintConfig.ciProvider, CIProvider.gitlab);
      expect(blueprintConfig.includeTheme, true);
      expect(blueprintConfig.includeLocalization, true);
      expect(blueprintConfig.includeEnv, false);
      expect(blueprintConfig.includeApi, true);
      expect(blueprintConfig.includeTests, false);
    });

    test('creates default config', () {
      final config = SharedBlueprintConfig.defaultConfig();

      expect(config.name, 'Default Configuration');
      expect(config.version, '1.0.0');
      expect(config.author, 'flutter_blueprint');
      expect(config.description, 'Default Flutter project configuration');
      expect(config.defaults.stateManagement, StateManagement.provider);
      expect(config.defaults.platforms, [TargetPlatform.mobile]);
      expect(config.defaults.ciProvider, CIProvider.none);
      expect(config.defaults.includeTheme, true);
      expect(config.defaults.includeLocalization, false);
      expect(config.defaults.includeEnv, true);
      expect(config.defaults.includeApi, true);
      expect(config.defaults.includeTests, true);
    });
  });

  group('SharedConfigDefaults', () {
    test('converts to YAML correctly', () {
      final defaults = SharedConfigDefaults(
        stateManagement: StateManagement.riverpod,
        platforms: [
          TargetPlatform.mobile,
          TargetPlatform.web,
          TargetPlatform.desktop
        ],
        ciProvider: CIProvider.github,
        includeTheme: true,
        includeLocalization: true,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      final yaml = defaults.toYaml();

      expect(yaml['state_management'], 'riverpod');
      expect(yaml['platforms'], ['mobile', 'web', 'desktop']);
      expect(yaml['ci_provider'], 'github');
      expect(yaml['include_theme'], true);
      expect(yaml['include_localization'], true);
      expect(yaml['include_env'], true);
      expect(yaml['include_api'], true);
      expect(yaml['include_tests'], true);
    });

    test('creates from YAML correctly', () {
      final yaml = {
        'state_management': 'bloc',
        'platforms': ['web'],
        'ci_provider': 'azure',
        'include_theme': false,
        'include_localization': false,
        'include_env': false,
        'include_api': false,
        'include_tests': false,
      };

      final defaults = SharedConfigDefaults.fromYaml(yaml);

      expect(defaults.stateManagement, StateManagement.bloc);
      expect(defaults.platforms, [TargetPlatform.web]);
      expect(defaults.ciProvider, CIProvider.azure);
      expect(defaults.includeTheme, false);
      expect(defaults.includeLocalization, false);
      expect(defaults.includeEnv, false);
      expect(defaults.includeApi, false);
      expect(defaults.includeTests, false);
    });
  });

  group('CodeStyleConfig', () {
    test('converts to YAML correctly', () {
      final codeStyle = CodeStyleConfig(
        lineLength: 120,
        preferConst: false,
      );

      final yaml = codeStyle.toYaml();

      expect(yaml['line_length'], 120);
      expect(yaml['prefer_const'], false);
    });

    test('creates from YAML correctly', () {
      final yaml = {
        'line_length': 100,
        'prefer_const': true,
      };

      final codeStyle = CodeStyleConfig.fromYaml(yaml);

      expect(codeStyle.lineLength, 100);
      expect(codeStyle.preferConst, true);
    });

    test('uses defaults for missing fields', () {
      final yaml = <String, dynamic>{};

      final codeStyle = CodeStyleConfig.fromYaml(yaml);

      expect(codeStyle.lineLength, 80);
      expect(codeStyle.preferConst, true);
    });
  });

  group('ArchitectureConfig', () {
    test('converts to YAML correctly', () {
      final architecture = ArchitectureConfig(
        namingConvention: NamingConvention.pascalCase,
      );

      final yaml = architecture.toYaml();

      expect(yaml['naming_convention'], 'PascalCase');
    });

    test('creates from YAML correctly', () {
      final yaml = {
        'naming_convention': 'camelCase',
      };

      final architecture = ArchitectureConfig.fromYaml(yaml);

      expect(architecture.namingConvention, NamingConvention.camelCase);
    });

    test('uses default for missing fields', () {
      final yaml = <String, dynamic>{};

      final architecture = ArchitectureConfig.fromYaml(yaml);

      expect(architecture.namingConvention, NamingConvention.snakeCase);
    });
  });

  group('NamingConvention', () {
    test('parses snake_case correctly', () {
      expect(NamingConvention.parse('snake_case'), NamingConvention.snakeCase);
    });

    test('parses camelCase correctly', () {
      expect(NamingConvention.parse('camelCase'), NamingConvention.camelCase);
    });

    test('parses PascalCase correctly', () {
      expect(NamingConvention.parse('PascalCase'), NamingConvention.pascalCase);
    });

    test('throws for unknown values', () {
      expect(() => NamingConvention.parse('unknown'), throwsArgumentError);
      expect(() => NamingConvention.parse(''), throwsArgumentError);
    });

    test('converts to label correctly', () {
      expect(NamingConvention.snakeCase.label, 'snake_case');
      expect(NamingConvention.camelCase.label, 'camelCase');
      expect(NamingConvention.pascalCase.label, 'PascalCase');
    });
  });

  group('FeatureStructure', () {
    test('parses clean_architecture correctly', () {
      expect(FeatureStructure.parse('clean_architecture'),
          FeatureStructure.cleanArchitecture);
    });

    test('parses mvc correctly', () {
      expect(FeatureStructure.parse('mvc'), FeatureStructure.mvc);
    });

    test('parses mvvm correctly', () {
      expect(FeatureStructure.parse('mvvm'), FeatureStructure.mvvm);
    });

    test('parses simple_layered correctly', () {
      expect(FeatureStructure.parse('simple_layered'),
          FeatureStructure.simpleLayered);
    });

    test('throws for unknown values', () {
      expect(() => FeatureStructure.parse('unknown'), throwsArgumentError);
      expect(() => FeatureStructure.parse(''), throwsArgumentError);
    });

    test('converts to label correctly', () {
      expect(FeatureStructure.cleanArchitecture.label, 'clean_architecture');
      expect(FeatureStructure.mvc.label, 'mvc');
      expect(FeatureStructure.mvvm.label, 'mvvm');
      expect(FeatureStructure.simpleLayered.label, 'simple_layered');
    });
  });
}
