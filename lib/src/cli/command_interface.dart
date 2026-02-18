/// Unified command interface for all CLI commands.
///
/// Every CLI command implements [Command] providing a consistent
/// contract for execution, argument configuration, and help text.
library;

import 'package:args/args.dart';

import '../core/errors.dart';
import '../core/result.dart';
import '../utils/logger.dart';
import '../prompts/interactive_prompter.dart';

/// Result of a command execution.
class CommandResult {
  const CommandResult({
    required this.success,
    this.message,
    this.data,
    this.exitCode = 0,
  });

  /// Whether the command succeeded.
  final bool success;

  /// Human-readable message about the result.
  final String? message;

  /// Optional data payload from the command.
  final Object? data;

  /// Process exit code (0 = success).
  final int exitCode;

  /// Creates a successful result.
  const CommandResult.ok([this.message])
      : success = true,
        data = null,
        exitCode = 0;

  /// Creates a failure result.
  const CommandResult.error(String this.message, {this.exitCode = 1})
      : success = false,
        data = null;
}

/// Context provided to every command during execution.
///
/// Instead of each command constructing its own dependencies,
/// [CommandContext] provides shared resources via dependency injection.
class CommandContext {
  const CommandContext({
    required this.logger,
    required this.prompter,
    required this.workingDirectory,
  });

  /// Logger for output.
  final Logger logger;

  /// Interactive prompter for user input.
  final InteractivePrompter prompter;

  /// Current working directory path.
  final String workingDirectory;
}

/// Base interface for all CLI commands.
///
/// Provides a unified contract that replaces the inconsistent command
/// signatures found in the original codebase (different execute() signatures,
/// some using ArgResults, some using List<String>, etc.).
abstract class Command {
  /// The command name as typed by the user (e.g., 'init', 'analyze').
  String get name;

  /// Short description shown in help text.
  String get description;

  /// Detailed usage examples.
  String get usage;

  /// Configures the argument parser for this command.
  void configureArgs(ArgParser parser);

  /// Executes the command with parsed arguments and shared context.
  ///
  /// Returns a [Result] instead of throwing exceptions, making error
  /// handling explicit and testable.
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  );
}

/// Base class for commands that provides common functionality.
///
/// Extend this instead of implementing [Command] directly to get
/// default implementations of [usage] and argument validation.
abstract class BaseCommand implements Command {
  @override
  String get usage => '$name - $description';

  /// Validates that required arguments are present.
  ///
  /// Returns null if valid, or a [CommandError] if validation fails.
  CommandError? validateArgs(ArgResults args) => null;

  /// Prints formatted help text for this command.
  void printHelp(Logger logger) {
    logger.info('$name - $description');
    logger.info('');
    logger.info('Usage:');
    logger.info('  flutter_blueprint $usage');
  }
}
