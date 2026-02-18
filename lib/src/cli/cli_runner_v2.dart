/// Refactored CLI entry point using CommandRegistry.
///
/// Replaces the 1,800-line god class with a ~250-line dispatcher that
/// delegates all business logic to individual Command implementations.
library;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'command_interface.dart';
import 'command_registry.dart';
import 'commands/init_command.dart';
import 'commands/analyze_command_v2.dart';
import 'commands/optimize_command_v2.dart';
import 'commands/refactor_command.dart';
import 'commands/share_command_v2.dart';
import 'commands/update_command_v2.dart';
import 'commands/add_feature_command_v2.dart';
import '../prompts/interactive_prompter.dart';
import '../utils/logger.dart';
import '../utils/update_checker.dart';
import '../utils/version_reader.dart';

/// Slim CLI runner that parses global flags and dispatches to commands.
///
/// Responsibilities (and nothing else):
/// 1. Parse global flags (--help, --version).
/// 2. Detect the command name from argv.
/// 3. Dispatch to [CommandRegistry].
/// 4. Show update notifications.
class CliRunnerV2 {
  CliRunnerV2({
    Logger? logger,
    InteractivePrompter? prompter,
    CommandRegistry? registry,
  })  : _logger = logger ?? Logger(),
        _prompter = prompter ?? InteractivePrompter(),
        _registry = registry ?? _buildDefaultRegistry(logger, prompter);

  final Logger _logger;
  final InteractivePrompter _prompter;
  final CommandRegistry _registry;

  // ── Public entry point ──────────────────────────────────────

  /// Parses [arguments] and runs the appropriate command.
  Future<void> run(List<String> arguments) async {
    // Determine command early so we can suppress the banner on 'update'.
    final commandName = _extractCommandName(arguments);
    final isUpdateCommand = commandName == 'update';

    // Kick off the update check in the background — never block the user.
    // We capture it in a Completer so we can await it right before printing.
    final updateCompleter = Completer<UpdateInfo?>();
    unawaited(
      UpdateChecker()
          .clearCacheIfStale() // evict stale cache if user just upgraded
          .then((_) => UpdateChecker().checkForUpdates())
          .then(updateCompleter.complete)
          .catchError((_) => updateCompleter.complete(null)),
    );

    try {
      // Handle the special "add" subcommand early.
      if (arguments.isNotEmpty && arguments.first == 'add') {
        await _handleAdd(arguments.skip(1).toList());
        return;
      }

      final parser = _buildGlobalParser();
      final results = parser.parse(arguments);

      // Global flags
      if (results['help'] as bool) {
        _printUsage();
        return;
      }

      if (results['version'] as bool) {
        final version = await VersionReader.getVersion();
        _logger.info('flutter_blueprint version $version');
        return;
      }

      if (commandName.isEmpty) {
        _printUsage();
        return;
      }

      // Get the command to configure its specific arguments
      final command = _registry.getCommand(commandName);
      if (command == null) {
        _logger.error('❌ Unknown command: $commandName');
        _printUsage();
        exitCode = 1;
        return;
      }

      // Build command-specific parser
      final commandParser = ArgParser(allowTrailingOptions: true);
      command.configureArgs(commandParser);

      // Parse command-specific arguments (skip the command name itself)
      final commandArgs = arguments.where((arg) => arg != commandName).toList();
      final ArgResults commandResults;
      try {
        commandResults = commandParser.parse(commandArgs);
      } on FormatException catch (e) {
        _logger.error('❌ ${e.message}');
        _logger.info(
            'Run "flutter_blueprint $commandName --help" for usage information.');
        exitCode = 1;
        return;
      }

      // Build a context
      final context = CommandContext(
        logger: _logger,
        prompter: _prompter,
        workingDirectory: Directory.current.path,
      );

      // Dispatch with properly parsed arguments
      final result =
          await _registry.dispatch(commandName, commandResults, context);

      result.when(
        success: (commandResult) {
          if (!commandResult.success) {
            exitCode = commandResult.exitCode;
          }
        },
        failure: (error) {
          _logger.error('❌ ${error.message}');
          exitCode = 1;
        },
      );
    } on FormatException catch (e) {
      _logger.error(e.message);
      _printUsage();
      exitCode = 1;
    } catch (e) {
      _logger.error('Unexpected error: $e');
      exitCode = 1;
    } finally {
      // Never show the "update available" banner when the user is already
      // running the update command — it's redundant and confusing.
      if (!isUpdateCommand) {
        // Wait briefly for the background check (already in-flight), then show.
        final updateInfo = await updateCompleter.future
            .timeout(const Duration(seconds: 1), onTimeout: () => null)
            .catchError((_) => null);
        _showUpdateNotification(updateInfo);
      }
    }
  }

  /// Extract the command name from raw arguments without full parsing.
  String _extractCommandName(List<String> arguments) {
    for (final arg in arguments) {
      if (!arg.startsWith('-')) return arg;
    }
    return '';
  }

  // ── Special "add" dispatch ──────────────────────────────────

  Future<void> _handleAdd(List<String> args) async {
    if (args.isEmpty) {
      _logger.error('Error: Subcommand required for "add"');
      _logger.info('Usage: flutter_blueprint add <subcommand> [arguments]');
      _logger.info('Available subcommands:');
      _logger.info('  feature <name>    Add a new feature to the project');
      exitCode = 1;
      return;
    }

    final subcommand = args.first;

    switch (subcommand) {
      case 'feature':
        final featureCmd = AddFeatureCommandV2();
        final parser = ArgParser();
        featureCmd.configureArgs(parser);

        final featureArgs = parser.parse(args.skip(1).toList());
        final context = CommandContext(
          logger: _logger,
          prompter: _prompter,
          workingDirectory: Directory.current.path,
        );

        final result = await featureCmd.execute(featureArgs, context);
        result.when(
          success: (r) {
            if (!r.success) exitCode = r.exitCode;
          },
          failure: (e) {
            _logger.error('❌ ${e.message}');
            exitCode = 1;
          },
        );
      default:
        _logger.error('Error: Unknown subcommand "$subcommand"');
        _logger.info('Available subcommands:');
        _logger.info('  feature <name>    Add a new feature to the project');
        exitCode = 1;
    }
  }

  // ── Usage / help ────────────────────────────────────────────

  void _printUsage() {
    _logger.info('flutter_blueprint - Smart Flutter scaffolding CLI\n');
    _logger.info('Usage: flutter_blueprint <command> [arguments]\n');
    _registry.printHelp();
    _logger.info('');
    _logger.info(
        'Run "flutter_blueprint <command> --help" for command-specific help.');
  }

  // ── Global parser (minimal) ─────────────────────────────────

  ArgParser _buildGlobalParser() {
    return ArgParser(allowTrailingOptions: false)
      ..addFlag('help',
          abbr: 'h', negatable: false, help: 'Show usage information')
      ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version');
  }

  // ── Update notification ─────────────────────────────────────

  void _showUpdateNotification(UpdateInfo? info) {
    if (info == null) return;

    // Box is 56 chars wide (between the outer │ │).
    const int innerWidth = 54;
    const String border =
        '┌──────────────────────────────────────────────────────┐';
    const String divider =
        '├──────────────────────────────────────────────────────┤';
    const String footer =
        '└──────────────────────────────────────────────────────┘';

    String row(String content) {
      // Pad content to fill the inner width exactly.
      final padded = content.length < innerWidth
          ? content + ' ' * (innerWidth - content.length)
          : content.substring(0, innerWidth);
      return '│ $padded │';
    }

    _logger.info('');
    _logger.info(border);
    _logger.info(row('           🚀 Update Available!           '));
    _logger.info(divider);
    _logger.info(row(''));
    _logger.info(row('  Current version : ${info.currentVersion}'));
    _logger.info(row('  Latest version  : ${info.latestVersion}'));
    _logger.info(row(''));
    _logger.info(row('  Run to update:'));
    _logger.info(row('  dart pub global activate flutter_blueprint'));
    _logger.info(row(''));
    _logger.info(row(
      '  Changelog: pub.dev/packages/flutter_blueprint/changelog',
    ));
    _logger.info(row(''));
    _logger.info(footer);
  }

  // ── Default registry ────────────────────────────────────────

  static CommandRegistry _buildDefaultRegistry(
    Logger? logger,
    InteractivePrompter? prompter,
  ) {
    final registry = CommandRegistry();

    registry.registerAll([
      InitCommand(),
      AnalyzeCommandV2(),
      OptimizeCommandV2(),
      RefactorCommand(),
      ShareCommandV2(),
      UpdateCommandV2(),
    ]);

    return registry;
  }
}
