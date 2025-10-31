/// Shared blueprint configurations for team-wide project templates
library;

import 'blueprint_config.dart';

/// Represents a shared blueprint configuration that can be used across teams
class SharedBlueprintConfig {
  /// Name of the shared configuration
  final String name;

  /// Version of the configuration
  final String version;

  /// Author or team that created the configuration
  final String author;

  /// Description of what this configuration provides
  final String description;

  /// Default configuration values
  final SharedConfigDefaults defaults;

  /// Required packages that must be included
  final List<String> requiredPackages;

  /// Code style preferences
  final CodeStyleConfig codeStyle;

  /// Architecture preferences
  final ArchitectureConfig architecture;

  /// Optional custom metadata
  final Map<String, dynamic>? metadata;

  const SharedBlueprintConfig({
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.defaults,
    this.requiredPackages = const [],
    required this.codeStyle,
    required this.architecture,
    this.metadata,
  });

  /// Creates a shared configuration from a YAML map
  factory SharedBlueprintConfig.fromYaml(Map<String, dynamic> yaml) {
    return SharedBlueprintConfig(
      name: yaml['name'] as String? ?? 'Unnamed Configuration',
      version: yaml['version'] as String? ?? '1.0.0',
      author: yaml['author'] as String? ?? 'Unknown',
      description: yaml['description'] as String? ?? '',
      defaults: SharedConfigDefaults.fromYaml(
        yaml['defaults'] as Map<String, dynamic>? ?? {},
      ),
      requiredPackages: (yaml['required_packages'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      codeStyle: CodeStyleConfig.fromYaml(
        yaml['code_style'] as Map<String, dynamic>? ?? {},
      ),
      architecture: ArchitectureConfig.fromYaml(
        yaml['architecture'] as Map<String, dynamic>? ?? {},
      ),
      metadata: yaml['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts the configuration to a YAML map
  Map<String, dynamic> toYaml() {
    return {
      'name': name,
      'version': version,
      'author': author,
      'description': description,
      'defaults': defaults.toYaml(),
      'required_packages': requiredPackages,
      'code_style': codeStyle.toYaml(),
      'architecture': architecture.toYaml(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Converts this shared config to a BlueprintConfig for project generation
  BlueprintConfig toBlueprintConfig(String appName) {
    return BlueprintConfig(
      appName: appName,
      platforms: defaults.platforms,
      stateManagement: defaults.stateManagement,
      ciProvider: defaults.ciProvider,
      includeTheme: defaults.includeTheme,
      includeLocalization: defaults.includeLocalization,
      includeEnv: defaults.includeEnv,
      includeApi: defaults.includeApi,
      includeTests: defaults.includeTests,
    );
  }

  /// Creates a default shared configuration
  factory SharedBlueprintConfig.defaultConfig() {
    return SharedBlueprintConfig(
      name: 'Default Configuration',
      version: '1.0.0',
      author: 'flutter_blueprint',
      description: 'Default Flutter project configuration',
      defaults: SharedConfigDefaults.standard(),
      requiredPackages: const [],
      codeStyle: CodeStyleConfig.defaults(),
      architecture: ArchitectureConfig.defaults(),
    );
  }

  @override
  String toString() {
    return 'SharedBlueprintConfig(name: $name, version: $version, author: $author)';
  }
}

/// Default configuration values for shared blueprints
class SharedConfigDefaults {
  final StateManagement stateManagement;
  final List<TargetPlatform> platforms;
  final bool includeTheme;
  final bool includeApi;
  final bool includeTests;
  final bool includeLocalization;
  final bool includeEnv;
  final CIProvider ciProvider;

  const SharedConfigDefaults({
    required this.stateManagement,
    required this.platforms,
    required this.includeTheme,
    required this.includeApi,
    required this.includeTests,
    this.includeLocalization = false,
    this.includeEnv = true,
    this.ciProvider = CIProvider.none,
  });

  factory SharedConfigDefaults.fromYaml(Map<String, dynamic> yaml) {
    final platformsList = yaml['platforms'] as List<dynamic>? ?? ['mobile'];
    final platforms =
        platformsList.map((p) => TargetPlatform.parse(p.toString())).toList();

    return SharedConfigDefaults(
      stateManagement: StateManagement.parse(
        yaml['state_management'] as String? ?? 'provider',
      ),
      platforms: platforms,
      includeTheme: yaml['include_theme'] as bool? ?? true,
      includeApi: yaml['include_api'] as bool? ?? true,
      includeTests: yaml['include_tests'] as bool? ?? true,
      includeLocalization: yaml['include_localization'] as bool? ?? false,
      includeEnv: yaml['include_env'] as bool? ?? true,
      ciProvider: CIProvider.parse(
        yaml['ci_provider'] as String? ?? 'none',
      ),
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'state_management': stateManagement.label,
      'platforms': platforms.map((p) => p.label).toList(),
      'include_theme': includeTheme,
      'include_api': includeApi,
      'include_tests': includeTests,
      'include_localization': includeLocalization,
      'include_env': includeEnv,
      'ci_provider': ciProvider.label,
    };
  }

  factory SharedConfigDefaults.standard() {
    return const SharedConfigDefaults(
      stateManagement: StateManagement.provider,
      platforms: [TargetPlatform.mobile],
      includeTheme: true,
      includeApi: true,
      includeTests: true,
      includeLocalization: false,
      includeEnv: true,
      ciProvider: CIProvider.none,
    );
  }
}

/// Code style configuration for shared blueprints
class CodeStyleConfig {
  final int lineLength;
  final bool preferConst;
  final bool requireDocumentation;
  final bool sortImports;
  final bool avoidPrint;
  final bool preferFinalFields;
  final Map<String, dynamic>? customRules;

  const CodeStyleConfig({
    this.lineLength = 80,
    this.preferConst = true,
    this.requireDocumentation = false,
    this.sortImports = true,
    this.avoidPrint = true,
    this.preferFinalFields = true,
    this.customRules,
  });

  factory CodeStyleConfig.fromYaml(Map<String, dynamic> yaml) {
    return CodeStyleConfig(
      lineLength: yaml['line_length'] as int? ?? 80,
      preferConst: yaml['prefer_const'] as bool? ?? true,
      requireDocumentation: yaml['require_documentation'] as bool? ?? false,
      sortImports: yaml['sort_imports'] as bool? ?? true,
      avoidPrint: yaml['avoid_print'] as bool? ?? true,
      preferFinalFields: yaml['prefer_final_fields'] as bool? ?? true,
      customRules: yaml['custom_rules'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'line_length': lineLength,
      'prefer_const': preferConst,
      'require_documentation': requireDocumentation,
      'sort_imports': sortImports,
      'avoid_print': avoidPrint,
      'prefer_final_fields': preferFinalFields,
      if (customRules != null) 'custom_rules': customRules,
    };
  }

  factory CodeStyleConfig.defaults() {
    return const CodeStyleConfig();
  }

  /// Generates analysis_options.yaml content based on this configuration
  String generateAnalysisOptions() {
    final buffer = StringBuffer();
    buffer.writeln('# Generated by flutter_blueprint');
    buffer.writeln('# Code style configuration');
    buffer.writeln();
    buffer.writeln('analyzer:');
    buffer.writeln('  strong-mode:');
    buffer.writeln('    implicit-casts: false');
    buffer.writeln('    implicit-dynamic: false');
    buffer.writeln('  errors:');
    buffer.writeln('    missing_required_param: error');
    buffer.writeln('    missing_return: error');
    if (requireDocumentation) {
      buffer.writeln('    public_member_api_docs: error');
    }
    buffer.writeln();
    buffer.writeln('linter:');
    buffer.writeln('  rules:');
    if (preferConst) {
      buffer.writeln('    - prefer_const_constructors');
      buffer.writeln('    - prefer_const_declarations');
      buffer.writeln('    - prefer_const_literals_to_create_immutables');
    }
    if (sortImports) {
      buffer.writeln('    - directives_ordering');
    }
    if (avoidPrint) {
      buffer.writeln('    - avoid_print');
    }
    if (preferFinalFields) {
      buffer.writeln('    - prefer_final_fields');
      buffer.writeln('    - prefer_final_locals');
    }
    buffer.writeln('    - always_declare_return_types');
    buffer.writeln('    - always_require_non_null_named_parameters');
    buffer.writeln('    - annotate_overrides');
    buffer.writeln('    - avoid_empty_else');
    buffer.writeln('    - avoid_returning_null_for_future');
    buffer.writeln('    - camel_case_types');
    buffer.writeln('    - prefer_single_quotes');
    buffer.writeln('    - use_key_in_widget_constructors');

    if (customRules != null) {
      buffer.writeln();
      buffer.writeln('    # Custom rules');
      for (final rule in customRules!.keys) {
        buffer.writeln('    - $rule');
      }
    }

    return buffer.toString();
  }
}

/// Architecture configuration for shared blueprints
class ArchitectureConfig {
  final FeatureStructure featureStructure;
  final NamingConvention namingConvention;
  final bool enforceLayerSeparation;
  final bool requireTests;
  final List<String>? customLayers;

  const ArchitectureConfig({
    this.featureStructure = FeatureStructure.cleanArchitecture,
    this.namingConvention = NamingConvention.snakeCase,
    this.enforceLayerSeparation = true,
    this.requireTests = true,
    this.customLayers,
  });

  factory ArchitectureConfig.fromYaml(Map<String, dynamic> yaml) {
    return ArchitectureConfig(
      featureStructure: FeatureStructure.parse(
        yaml['feature_structure'] as String? ?? 'clean_architecture',
      ),
      namingConvention: NamingConvention.parse(
        yaml['naming_convention'] as String? ?? 'snake_case',
      ),
      enforceLayerSeparation: yaml['enforce_layer_separation'] as bool? ?? true,
      requireTests: yaml['require_tests'] as bool? ?? true,
      customLayers: (yaml['custom_layers'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'feature_structure': featureStructure.label,
      'naming_convention': namingConvention.label,
      'enforce_layer_separation': enforceLayerSeparation,
      'require_tests': requireTests,
      if (customLayers != null) 'custom_layers': customLayers,
    };
  }

  factory ArchitectureConfig.defaults() {
    return const ArchitectureConfig();
  }
}

/// Feature structure options
enum FeatureStructure {
  cleanArchitecture,
  mvc,
  mvvm,
  simpleLayered;

  String get label {
    switch (this) {
      case FeatureStructure.cleanArchitecture:
        return 'clean_architecture';
      case FeatureStructure.mvc:
        return 'mvc';
      case FeatureStructure.mvvm:
        return 'mvvm';
      case FeatureStructure.simpleLayered:
        return 'simple_layered';
    }
  }

  static FeatureStructure parse(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'clean_architecture':
      case 'clean':
        return FeatureStructure.cleanArchitecture;
      case 'mvc':
        return FeatureStructure.mvc;
      case 'mvvm':
        return FeatureStructure.mvvm;
      case 'simple_layered':
      case 'layered':
        return FeatureStructure.simpleLayered;
      default:
        throw ArgumentError('Unknown feature structure: $value');
    }
  }
}

/// Naming convention options
enum NamingConvention {
  snakeCase,
  camelCase,
  pascalCase;

  String get label {
    switch (this) {
      case NamingConvention.snakeCase:
        return 'snake_case';
      case NamingConvention.camelCase:
        return 'camelCase';
      case NamingConvention.pascalCase:
        return 'PascalCase';
    }
  }

  static NamingConvention parse(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'snake_case':
      case 'snake':
        return NamingConvention.snakeCase;
      case 'camelcase':
      case 'camel':
        return NamingConvention.camelCase;
      case 'pascalcase':
      case 'pascal':
        return NamingConvention.pascalCase;
      default:
        throw ArgumentError('Unknown naming convention: $value');
    }
  }

  /// Converts a string to this naming convention
  String convert(String input) {
    // Split by underscores, spaces, or capital letters
    final words = input
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .split(RegExp(r'[\s_-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.toLowerCase())
        .toList();

    switch (this) {
      case NamingConvention.snakeCase:
        return words.join('_');
      case NamingConvention.camelCase:
        if (words.isEmpty) return '';
        return words.first +
            words
                .skip(1)
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join('');
      case NamingConvention.pascalCase:
        return words.map((w) => w[0].toUpperCase() + w.substring(1)).join('');
    }
  }
}
