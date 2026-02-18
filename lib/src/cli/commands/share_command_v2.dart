/// Share command - manages shared team configurations.
///
/// Refactored to use unified Command interface.
library;

import 'dart:io';

import 'package:args/args.dart';

import '../command_interface.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../../config/config_repository.dart';

/// Manages shared blueprint configurations for teams.
class ShareCommandV2 extends BaseCommand {
  @override
  String get name => 'share';

  @override
  String get description => 'Manage shared blueprint configurations for teams';

  @override
  String get usage => 'flutter_blueprint share <subcommand> [arguments]\n\n'
      '  Subcommands:\n'
      '    list                    List available configurations\n'
      '    config <name>           Create shared configuration\n'
      '    export <name> <path>    Export configuration to file\n'
      '    import <file> [name]    Import configuration from file\n'
      '    delete <name>           Delete a configuration\n'
      '    validate <file>         Validate a configuration file';

  @override
  void configureArgs(ArgParser parser) {
    parser.addFlag('verbose',
        abbr: 'v', help: 'Show detailed output', negatable: false);
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    try {
      final subArgs = args.rest;

      if (subArgs.isEmpty) {
        printHelp(context.logger);
        return const Result.success(CommandResult.ok());
      }

      final subcommand = subArgs[0];
      final subArguments = subArgs.skip(1).toList();
      final repository = ConfigRepository(logger: context.logger);

      switch (subcommand) {
        case 'list':
          return _handleList(repository, context);
        case 'config':
          return _handleConfig(repository, subArguments, context);
        case 'export':
          return _handleExport(repository, subArguments, context);
        case 'import':
          return _handleImport(repository, subArguments, context);
        case 'delete':
          return _handleDelete(repository, subArguments, context);
        case 'validate':
          return _handleValidate(repository, subArguments, context);
        default:
          return Result.failure(
            CommandError('Unknown subcommand: $subcommand', command: name),
          );
      }
    } catch (e) {
      return Result.failure(
        CommandError('Share command failed: $e', command: name, cause: e),
      );
    }
  }

  Future<Result<CommandResult, CommandError>> _handleList(
    ConfigRepository repository,
    CommandContext context,
  ) async {
    context.logger.info('📋 Available configurations:\n');
    final configs = await repository.listConfigs();

    if (configs.isEmpty) {
      context.logger.info('No configurations found.');
      context.logger.info(
        '\nCreate one with: flutter_blueprint share config <name>',
      );
      return const Result.success(CommandResult.ok());
    }

    for (final info in configs) {
      context.logger.info('  • ${info.name}');
      context.logger.info('    Version: ${info.config.version}');
      context.logger.info('    Author: ${info.config.author}');
      context.logger.info('    Description: ${info.config.description}');
      context.logger.info('    Path: ${info.filePath}');
      context.logger.info('');
    }
    context.logger.info(
      'Use with: flutter_blueprint init my_app --from-config <name>',
    );

    return const Result.success(CommandResult.ok());
  }

  Future<Result<CommandResult, CommandError>> _handleConfig(
    ConfigRepository repository,
    List<String> args,
    CommandContext context,
  ) async {
    if (args.isEmpty) {
      return Result.failure(
        CommandError('Usage: flutter_blueprint share config <name>',
            command: name),
      );
    }

    context.logger.info(
      'This command requires a blueprint_manifest.yaml in the current directory.',
    );
    context.logger.info('Run from a project created with flutter_blueprint.');
    context.logger.error('\n❌ Not fully implemented for direct CLI use.');
    return const Result.success(CommandResult.ok());
  }

  Future<Result<CommandResult, CommandError>> _handleExport(
    ConfigRepository repository,
    List<String> args,
    CommandContext context,
  ) async {
    if (args.length < 2) {
      return Result.failure(
        CommandError(
          'Usage: flutter_blueprint share export <config-name> <output-path>',
          command: name,
        ),
      );
    }

    await repository.export(args[0], args[1]);
    context.logger.success('✅ Configuration exported successfully!');
    return const Result.success(CommandResult.ok('Exported'));
  }

  Future<Result<CommandResult, CommandError>> _handleImport(
    ConfigRepository repository,
    List<String> args,
    CommandContext context,
  ) async {
    if (args.isEmpty) {
      return Result.failure(
        CommandError(
          'Usage: flutter_blueprint share import <file-path> [config-name]',
          command: name,
        ),
      );
    }

    final filePath = args[0];
    final configName = args.length > 1 ? args[1] : null;

    final validation = await repository.validate(filePath);
    if (!validation.isValid) {
      return Result.failure(
        CommandError(
          'Configuration file is invalid:\n${validation.format()}',
          command: name,
        ),
      );
    }

    if (validation.hasWarnings) {
      context.logger.warning('\n⚠️  Warnings:\n');
      context.logger.warning(validation.format());
    }

    await repository.import(filePath, configName);
    context.logger.success('✅ Configuration imported successfully!');
    return const Result.success(CommandResult.ok('Imported'));
  }

  Future<Result<CommandResult, CommandError>> _handleDelete(
    ConfigRepository repository,
    List<String> args,
    CommandContext context,
  ) async {
    if (args.isEmpty) {
      return Result.failure(
        CommandError('Usage: flutter_blueprint share delete <config-name>',
            command: name),
      );
    }

    final configName = args[0];
    stdout.write('Delete configuration "$configName"? (y/N): ');
    final confirm = stdin.readLineSync()?.trim().toLowerCase();

    if (confirm != 'y' && confirm != 'yes') {
      context.logger.info('Cancelled.');
      return const Result.success(CommandResult.ok('Cancelled'));
    }

    await repository.delete(configName);
    return const Result.success(CommandResult.ok('Deleted'));
  }

  Future<Result<CommandResult, CommandError>> _handleValidate(
    ConfigRepository repository,
    List<String> args,
    CommandContext context,
  ) async {
    if (args.isEmpty) {
      return Result.failure(
        CommandError('Usage: flutter_blueprint share validate <file-path>',
            command: name),
      );
    }

    context.logger.info('🔍 Validating configuration...\n');
    final validation = await repository.validate(args[0]);
    context.logger.info(validation.format());

    if (!validation.isValid) {
      return Result.success(
        const CommandResult(
          success: false,
          message: 'Validation failed',
          exitCode: 1,
        ),
      );
    }

    return const Result.success(CommandResult.ok('Valid'));
  }
}
