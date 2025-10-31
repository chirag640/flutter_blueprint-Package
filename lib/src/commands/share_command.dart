/// Command for sharing blueprint configurations
library;

import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../config/shared_config.dart';
import '../config/config_repository.dart';
import '../config/blueprint_manifest.dart';
import '../utils/logger.dart';

/// Handles the 'share' command for managing shared configurations
class ShareCommand extends Command<void> {
  final Logger _logger;
  final ConfigRepository _repository;

  ShareCommand({
    Logger? logger,
    ConfigRepository? repository,
  })  : _logger = logger ?? Logger(),
        _repository = repository ?? ConfigRepository() {
    // Subcommands
    argParser
      ..addCommand('list')
      ..addCommand('config')
      ..addCommand('export')
      ..addCommand('import')
      ..addCommand('delete')
      ..addCommand('validate');

    // Global flags
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show detailed output',
      negatable: false,
    );
  }

  @override
  String get name => 'share';

  @override
  String get description => 'Manage shared blueprint configurations for teams';

  @override
  String get invocation => 'flutter_blueprint share <subcommand> [arguments]';

  @override
  Future<void> run() async {
    final subcommand = argResults?.command?.name;

    if (subcommand == null) {
      printUsage();
      return;
    }

    try {
      switch (subcommand) {
        case 'list':
          await _handleList();
          break;
        case 'config':
          await _handleConfig();
          break;
        case 'export':
          await _handleExport();
          break;
        case 'import':
          await _handleImport();
          break;
        case 'delete':
          await _handleDelete();
          break;
        case 'validate':
          await _handleValidate();
          break;
        default:
          _logger.error('Unknown subcommand: $subcommand');
          printUsage();
      }
    } catch (e) {
      _logger.error('❌ Error: $e');
      exit(1);
    }
  }

  /// Lists all available shared configurations
  Future<void> _handleList() async {
    _logger.info('📋 Available configurations:\n');

    final configs = await _repository.listConfigs();

    if (configs.isEmpty) {
      _logger.info('No configurations found.');
      _logger.info(
        '\nCreate a configuration with: flutter_blueprint share config <name>',
      );
      return;
    }

    for (final info in configs) {
      _logger.info('  • ${info.name}');
      _logger.info('    Version: ${info.config.version}');
      _logger.info('    Author: ${info.config.author}');
      _logger.info('    Description: ${info.config.description}');
      _logger.info('    Path: ${info.filePath}');
      _logger.info('');
    }

    _logger.info(
      'Use with: flutter_blueprint init my_app --from-config <name>',
    );
  }

  /// Creates a new shared configuration from current project
  Future<void> _handleConfig() async {
    final args = argResults!.command!.rest;

    if (args.isEmpty) {
      _logger.error('Usage: flutter_blueprint share config <name>');
      exit(1);
    }

    final configName = args[0];

    // Check if blueprint_manifest.yaml exists in current directory
    final manifestPath = path.join(
      Directory.current.path,
      'blueprint_manifest.yaml',
    );

    if (!await File(manifestPath).exists()) {
      _logger.error(
        '❌ No blueprint_manifest.yaml found in current directory.',
      );
      _logger.info(
        'Run this command from a project created with flutter_blueprint.',
      );
      exit(1);
    }

    // Load the current blueprint configuration
    final store = BlueprintManifestStore();
    final manifest = await store.read(File(manifestPath));
    final config = manifest.config;

    // Prompt for additional information
    _logger.info('Creating shared configuration: $configName\n');

    stdout.write('Enter version (default: 1.0.0): ');
    final version = stdin.readLineSync()?.trim();

    stdout.write('Enter author name: ');
    final author = stdin.readLineSync()?.trim() ?? 'Unknown';

    stdout.write('Enter description: ');
    final description = stdin.readLineSync()?.trim() ?? '';

    // Create shared configuration from manifest
    final sharedConfig = SharedBlueprintConfig(
      name: configName,
      version: version?.isNotEmpty == true ? version! : '1.0.0',
      author: author,
      description: description,
      defaults: SharedConfigDefaults(
        stateManagement: config.stateManagement,
        platforms: config.platforms,
        ciProvider: config.ciProvider,
        includeTheme: config.includeTheme,
        includeLocalization: config.includeLocalization,
        includeEnv: config.includeEnv,
        includeApi: config.includeApi,
        includeTests: config.includeTests,
      ),
      codeStyle: CodeStyleConfig(
        lineLength: 80,
        preferConst: true,
      ),
      architecture: ArchitectureConfig(
        namingConvention: NamingConvention.snakeCase,
      ),
    );

    // Save the configuration
    await _repository.save(sharedConfig, configName);

    _logger.success('\n✅ Configuration saved successfully!');
    _logger.info(
      '\nShare with your team: ${path.join(_repository.defaultConfigDirectory, "$configName.yaml")}',
    );
    _logger.info(
      'Use with: flutter_blueprint init my_app --from-config $configName',
    );
  }

  /// Exports a configuration to a file
  Future<void> _handleExport() async {
    final args = argResults!.command!.rest;

    if (args.length < 2) {
      _logger.error(
        'Usage: flutter_blueprint share export <config-name> <output-path>',
      );
      exit(1);
    }

    final configName = args[0];
    final outputPath = args[1];

    await _repository.export(configName, outputPath);

    _logger.success('✅ Configuration exported successfully!');
  }

  /// Imports a configuration from a file
  Future<void> _handleImport() async {
    final args = argResults!.command!.rest;

    if (args.isEmpty) {
      _logger.error(
        'Usage: flutter_blueprint share import <file-path> [config-name]',
      );
      exit(1);
    }

    final filePath = args[0];
    final configName = args.length > 1 ? args[1] : null;

    // Validate before importing
    final validation = await _repository.validate(filePath);

    if (!validation.isValid) {
      _logger.error('❌ Configuration file is invalid:\n');
      _logger.error(validation.format());
      exit(1);
    }

    if (validation.hasWarnings) {
      _logger.warning('\n⚠️  Warnings:\n');
      _logger.warning(validation.format());
    }

    await _repository.import(filePath, configName);

    _logger.success('✅ Configuration imported successfully!');
  }

  /// Deletes a configuration
  Future<void> _handleDelete() async {
    final args = argResults!.command!.rest;

    if (args.isEmpty) {
      _logger.error('Usage: flutter_blueprint share delete <config-name>');
      exit(1);
    }

    final configName = args[0];

    // Confirm deletion
    stdout.write('Delete configuration "$configName"? (y/N): ');
    final confirm = stdin.readLineSync()?.trim().toLowerCase();

    if (confirm != 'y' && confirm != 'yes') {
      _logger.info('Cancelled.');
      return;
    }

    await _repository.delete(configName);
  }

  /// Validates a configuration file
  Future<void> _handleValidate() async {
    final args = argResults!.command!.rest;

    if (args.isEmpty) {
      _logger.error('Usage: flutter_blueprint share validate <file-path>');
      exit(1);
    }

    final filePath = args[0];

    _logger.info('🔍 Validating configuration...\n');

    final validation = await _repository.validate(filePath);

    _logger.info(validation.format());

    if (!validation.isValid) {
      exit(1);
    }
  }

  void printUsage() {
    _logger.info('''
Manage shared blueprint configurations for teams.

Usage:
  flutter_blueprint share <subcommand> [arguments]

Subcommands:
  list                    List all available configurations
  config <name>           Create a shared configuration from current project
  export <name> <path>    Export a configuration to a file
  import <file> [name]    Import a configuration from a file
  delete <name>           Delete a configuration
  validate <file>         Validate a configuration file

Examples:
  # List available configurations
  flutter_blueprint share list

  # Create a configuration from current project
  flutter_blueprint share config company_standard

  # Export a configuration
  flutter_blueprint share export company_standard ./configs/standard.yaml

  # Import a configuration
  flutter_blueprint share import ./configs/standard.yaml my_config

  # Validate a configuration file
  flutter_blueprint share validate company_standard.yaml

  # Use a shared configuration
  flutter_blueprint init my_app --from-config company_standard

For more information, see the documentation.
''');
  }
}
