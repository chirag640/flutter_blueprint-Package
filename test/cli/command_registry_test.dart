import 'package:args/args.dart';
import 'package:test/test.dart';
import 'package:flutter_blueprint/src/cli/command_interface.dart';
import 'package:flutter_blueprint/src/cli/command_registry.dart';
import 'package:flutter_blueprint/src/core/errors.dart';
import 'package:flutter_blueprint/src/core/result.dart';
import 'package:flutter_blueprint/src/utils/logger.dart';
import 'package:flutter_blueprint/src/prompts/interactive_prompter.dart';

/// Minimal test command for registry tests.
class _TestCommand extends BaseCommand {
  _TestCommand({this.testName = 'test', this.testDescription = 'A test cmd'});

  final String testName;
  final String testDescription;

  @override
  String get name => testName;

  @override
  String get description => testDescription;

  @override
  String get usage => '$testName usage';

  @override
  void configureArgs(ArgParser parser) {}

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    return const Result.success(CommandResult.ok('done'));
  }
}

class _FailingCommand extends BaseCommand {
  @override
  String get name => 'fail';

  @override
  String get description => 'always fails';

  @override
  String get usage => 'fail';

  @override
  void configureArgs(ArgParser parser) {}

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    throw const ConfigurationError('boom');
  }
}

void main() {
  group('CommandResult', () {
    test('ok() creates success result', () {
      const result = CommandResult.ok('done');
      expect(result.success, isTrue);
      expect(result.message, 'done');
      expect(result.exitCode, 0);
    });

    test('error() creates failure result', () {
      const result = CommandResult.error('bad', exitCode: 2);
      expect(result.success, isFalse);
      expect(result.message, 'bad');
      expect(result.exitCode, 2);
    });
  });

  group('CommandContext', () {
    test('holds logger and prompter', () {
      final context = CommandContext(
        logger: Logger(),
        prompter: InteractivePrompter(),
        workingDirectory: '/tmp',
      );
      expect(context.workingDirectory, '/tmp');
    });
  });

  group('CommandRegistry', () {
    late CommandRegistry registry;
    late CommandContext context;

    setUp(() {
      registry = CommandRegistry();
      context = CommandContext(
        logger: Logger(),
        prompter: InteractivePrompter(),
        workingDirectory: '/tmp',
      );
    });

    test('registers and retrieves commands', () {
      final cmd = _TestCommand();
      registry.register(cmd);
      expect(registry.getCommand('test'), same(cmd));
    });

    test('registerAll registers multiple commands', () {
      registry.registerAll([
        _TestCommand(testName: 'a'),
        _TestCommand(testName: 'b'),
      ]);
      expect(registry.commandNames, containsAll(['a', 'b']));
    });

    test('commandNames returns sorted names', () {
      registry.registerAll([
        _TestCommand(testName: 'z'),
        _TestCommand(testName: 'a'),
        _TestCommand(testName: 'm'),
      ]);
      expect(registry.commandNames, ['a', 'm', 'z']);
    });

    test('dispatch calls registered command', () async {
      registry.register(_TestCommand());

      final parser = ArgParser();
      final args = parser.parse([]);

      final result = await registry.dispatch('test', args, context);
      expect(result.valueOrNull?.message, 'done');
    });

    test('dispatch returns failure for unknown command', () async {
      final parser = ArgParser();
      final args = parser.parse([]);

      final result = await registry.dispatch('unknown', args, context);
      expect(result.errorOrNull?.message, contains('Unknown command'));
    });

    test('dispatch catches BlueprintException from command', () async {
      registry.register(_FailingCommand());

      final parser = ArgParser();
      final args = parser.parse([]);

      final result = await registry.dispatch('fail', args, context);
      expect(result.errorOrNull?.message, contains('boom'));
    });
  });
}
