/// Repository for managing shared blueprint configurations
library;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'shared_config.dart';
import '../utils/logger.dart';

/// Manages loading, saving, and sharing blueprint configurations
class ConfigRepository {
  final Logger _logger;
  final String? _customConfigPath;

  ConfigRepository({
    Logger? logger,
    String? customConfigPath,
  })  : _logger = logger ?? Logger(),
        _customConfigPath = customConfigPath;

  /// Gets the default configuration directory path
  String get defaultConfigDirectory {
    final customPath = _customConfigPath;
    if (customPath != null) {
      return customPath;
    }

    // Use user's home directory
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';

    if (home.isEmpty) {
      throw Exception('Could not determine home directory');
    }

    return path.join(home, '.flutter_blueprint', 'configs');
  }

  /// Loads a shared configuration from a file
  Future<SharedBlueprintConfig> load(String configName) async {
    final configPath = await _resolveConfigPath(configName);

    if (!await File(configPath).exists()) {
      throw Exception('Configuration not found: $configName');
    }

    _logger.info('📖 Loading configuration from: $configPath');

    final content = await File(configPath).readAsString();
    final yaml = loadYaml(content);

    return SharedBlueprintConfig.fromYaml(
      _convertYamlToMap(yaml),
    );
  }

  /// Recursively converts YamlMap to Map<String, dynamic>
  Map<String, dynamic> _convertYamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final map = <String, dynamic>{};
      yaml.forEach((key, value) {
        if (value is YamlMap) {
          map[key.toString()] = _convertYamlToMap(value);
        } else if (value is YamlList) {
          map[key.toString()] = _convertYamlList(value);
        } else {
          map[key.toString()] = value;
        }
      });
      return map;
    } else if (yaml is Map) {
      return Map<String, dynamic>.from(yaml);
    }
    return {};
  }

  /// Converts YamlList to List<dynamic>
  List<dynamic> _convertYamlList(YamlList yamlList) {
    return yamlList.map((item) {
      if (item is YamlMap) {
        return _convertYamlToMap(item);
      } else if (item is YamlList) {
        return _convertYamlList(item);
      }
      return item;
    }).toList();
  }

  /// Saves a shared configuration to a file
  Future<void> save(
    SharedBlueprintConfig config,
    String configName,
  ) async {
    // Ensure config directory exists
    final configDir = Directory(defaultConfigDirectory);
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }

    final configPath = path.join(
      defaultConfigDirectory,
      _ensureYamlExtension(configName),
    );

    _logger.info('💾 Saving configuration to: $configPath');

    // Convert to YAML string
    final yamlContent = _toYamlString(config.toYaml());

    await File(configPath).writeAsString(yamlContent);

    _logger.success('✅ Configuration saved successfully!');
  }

  /// Lists all available shared configurations
  Future<List<ConfigInfo>> listConfigs() async {
    final configDir = Directory(defaultConfigDirectory);

    if (!await configDir.exists()) {
      return [];
    }

    final configs = <ConfigInfo>[];

    await for (final entity in configDir.list()) {
      if (entity is File && entity.path.endsWith('.yaml')) {
        try {
          final content = await entity.readAsString();
          final yaml = loadYaml(content);
          final config = SharedBlueprintConfig.fromYaml(
            _convertYamlToMap(yaml),
          );

          configs.add(ConfigInfo(
            name: path.basenameWithoutExtension(entity.path),
            filePath: entity.path,
            config: config,
          ));
        } catch (e) {
          _logger.warning('⚠️  Could not load ${entity.path}: $e');
        }
      }
    }

    return configs;
  }

  /// Deletes a shared configuration
  Future<void> delete(String configName) async {
    final configPath = path.join(
      defaultConfigDirectory,
      _ensureYamlExtension(configName),
    );

    final file = File(configPath);
    if (!await file.exists()) {
      throw Exception('Configuration not found: $configName');
    }

    await file.delete();
    _logger.success('✅ Configuration deleted: $configName');
  }

  /// Exports a configuration to a specific path
  Future<void> export(
    String configName,
    String targetPath,
  ) async {
    final config = await load(configName);
    final yamlContent = _toYamlString(config.toYaml());

    final targetFile = File(targetPath);
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsString(yamlContent);

    _logger.success('✅ Configuration exported to: $targetPath');
  }

  /// Imports a configuration from a file
  Future<void> import(
    String sourcePath,
    String? configName,
  ) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file not found: $sourcePath');
    }

    final content = await sourceFile.readAsString();
    final yaml = loadYaml(content);
    final config = SharedBlueprintConfig.fromYaml(
      _convertYamlToMap(yaml),
    );

    final name = configName ?? path.basenameWithoutExtension(sourcePath);
    await save(config, name);
  }

  /// Validates a configuration file
  Future<ValidationResult> validate(String configPath) async {
    final errors = <String>[];
    final warnings = <String>[];

    try {
      final file = File(configPath);
      if (!await file.exists()) {
        errors.add('File does not exist: $configPath');
        return ValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
        );
      }

      final content = await file.readAsString();
      final yaml = loadYaml(content);
      final yamlMap = _convertYamlToMap(yaml);

      // Check required fields
      if (!yamlMap.containsKey('name')) {
        errors.add('Missing required field: name');
      }
      if (!yamlMap.containsKey('version')) {
        warnings.add('Missing recommended field: version');
      }
      if (!yamlMap.containsKey('author')) {
        warnings.add('Missing recommended field: author');
      }

      // Validate defaults section
      if (yamlMap.containsKey('defaults')) {
        final defaults = yamlMap['defaults'] as Map?;
        if (defaults != null) {
          if (!defaults.containsKey('state_management')) {
            warnings.add('Missing default state_management');
          }
          if (!defaults.containsKey('platforms')) {
            warnings.add('Missing default platforms');
          }
        }
      } else {
        warnings.add('Missing defaults section');
      }

      // Try to parse the configuration
      try {
        SharedBlueprintConfig.fromYaml(yamlMap);
      } catch (e) {
        errors.add('Failed to parse configuration: $e');
      }
    } catch (e) {
      errors.add('Validation error: $e');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Resolves the full path to a configuration file
  Future<String> _resolveConfigPath(String configName) async {
    // If it's already a full path, use it
    if (path.isAbsolute(configName)) {
      return configName;
    }

    // Check if it exists in current directory
    final localPath = path.join(Directory.current.path, configName);
    if (await File(localPath).exists()) {
      return localPath;
    }

    // Check with .yaml extension in current directory
    final localPathWithExt = _ensureYamlExtension(localPath);
    if (await File(localPathWithExt).exists()) {
      return localPathWithExt;
    }

    // Check in default config directory
    final defaultPath = path.join(
      defaultConfigDirectory,
      _ensureYamlExtension(configName),
    );

    return defaultPath;
  }

  /// Ensures a filename has .yaml extension
  String _ensureYamlExtension(String filename) {
    if (filename.endsWith('.yaml') || filename.endsWith('.yml')) {
      return filename;
    }
    return '$filename.yaml';
  }

  /// Converts a map to YAML string with proper formatting
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
        // Quote strings if they contain special characters
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
}

/// Information about a saved configuration
class ConfigInfo {
  final String name;
  final String filePath;
  final SharedBlueprintConfig config;

  const ConfigInfo({
    required this.name,
    required this.filePath,
    required this.config,
  });

  @override
  String toString() {
    return '$name (v${config.version}) - ${config.description}';
  }
}

/// Result of configuration validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;

  String format() {
    final buffer = StringBuffer();

    if (isValid) {
      buffer.writeln('✅ Configuration is valid');
    } else {
      buffer.writeln('❌ Configuration is invalid');
    }

    if (errors.isNotEmpty) {
      buffer.writeln('\nErrors:');
      for (final error in errors) {
        buffer.writeln('  • $error');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('\nWarnings:');
      for (final warning in warnings) {
        buffer.writeln('  ⚠️  $warning');
      }
    }

    return buffer.toString();
  }
}
