/// Registry for CLI commands with lookup and dispatch.
///
/// Replaces the monolithic if/else cascade in CliRunner with a
/// pluggable command registry that maps command names to [Command] instances.
library;

import 'package:args/args.dart';

import 'command_interface.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../utils/logger.dart';

/// Maps command names to their implementations and dispatches execution.
///
/// Usage:
/// ```dart
/// final registry = CommandRegistry();
/// registry.register(InitCommand());
/// registry.register(AnalyzeCommand());
///
/// final result = await registry.dispatch('init', args, context);
/// ```
class CommandRegistry {
  CommandRegistry({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;
  final Map<String, Command> _commands = {};

  /// Registers a command. Overwrites existing commands with the same name.
  void register(Command command) {
    _commands[command.name] = command;
  }

  /// Registers multiple commands at once.
  void registerAll(List<Command> commands) {
    for (final command in commands) {
      register(command);
    }
  }

  /// Looks up a command by name. Returns null if not found.
  Command? getCommand(String name) => _commands[name];

  /// Returns all registered command names, sorted alphabetically.
  List<String> get commandNames => _commands.keys.toList()..sort();

  /// Returns all registered commands.
  Iterable<Command> get commands => _commands.values;

  /// Dispatches execution to the named command.
  ///
  /// Returns a [Result] with success/failure instead of throwing.
  Future<Result<CommandResult, CommandError>> dispatch(
    String commandName,
    ArgResults args,
    CommandContext context,
  ) async {
    final command = _commands[commandName];
    if (command == null) {
      return Result.failure(
        CommandError(
          'Unknown command: $commandName',
          command: commandName,
        ),
      );
    }

    try {
      return await command.execute(args, context);
    } on BlueprintException catch (e) {
      return Result.failure(
        CommandError(
          e.message,
          command: commandName,
          cause: e,
        ),
      );
    } catch (e) {
      return Result.failure(
        CommandError(
          'Unexpected error: $e',
          command: commandName,
          cause: e,
        ),
      );
    }
  }

  /// Prints help for all registered commands.
  void printHelp() {
    _logger.info('Available commands:');
    final maxNameLen = _commands.keys
        .fold<int>(0, (max, name) => name.length > max ? name.length : max);

    for (final entry in _commands.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      final padded = entry.key.padRight(maxNameLen + 2);
      _logger.info('  $padded ${entry.value.description}');
    }
  }

  /// Prints help for a specific command.
  void printCommandHelp(String commandName) {
    final command = _commands[commandName];
    if (command == null) {
      _logger.error('Unknown command: $commandName');
      return;
    }

    _logger.info('${command.name} - ${command.description}');
    _logger.info('');
    _logger.info(command.usage);
  }
}
