import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_blueprint/src/cli/command_interface.dart';
import 'package:flutter_blueprint/src/cli/commands/doctor_command.dart';
import 'package:flutter_blueprint/src/utils/logger.dart';
import 'package:test/test.dart';

import '../../test_helpers/mock_prompter.dart';

class _FakeRunner {
  _FakeRunner(this.responses);

  final Map<String, ProcessResult> responses;

  Future<ProcessResult> call(
    String executable,
    List<String> arguments,
    String workingDirectory,
  ) async {
    final key = '$executable ${arguments.join(' ')}';
    final response = responses[key];
    if (response == null) {
      return ProcessResult(0, 0, '', '');
    }
    return response;
  }
}

void main() {
  group('DoctorCommand', () {
    late DoctorCommand command;
    late MockInteractivePrompter prompter;
    late Logger logger;

    CommandContext createContext() => CommandContext(
          logger: logger,
          prompter: prompter,
          workingDirectory: Directory.current.path,
        );

    setUp(() {
      prompter = MockInteractivePrompter();
      logger = Logger();
    });

    test('exposes expected command metadata', () {
      command = DoctorCommand(
        processRunner: _FakeRunner({}).call,
      );

      expect(command.name, 'doctor');
      expect(command.description, contains('health checks'));
    });

    test('passes when analyzer/deps/fix checks are healthy', () async {
      command = DoctorCommand(
        processRunner: _FakeRunner({
          'dart analyze': ProcessResult(1, 0, 'No issues found!', ''),
          'dart pub outdated':
              ProcessResult(2, 0, 'No dependencies are outdated.', ''),
          'dart fix --dry-run': ProcessResult(3, 0, 'Nothing to fix!', ''),
        }).call,
      );

      final parser = ArgParser();
      command.configureArgs(parser);
      final args = parser.parse([]);

      final result = await command.execute(args, createContext());

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.success, isTrue);
    });

    test('fails when analyzer reports issues', () async {
      command = DoctorCommand(
        processRunner: _FakeRunner({
          'dart analyze': ProcessResult(1, 3, 'error', 'analysis failed'),
          'dart pub outdated':
              ProcessResult(2, 0, 'No dependencies are outdated.', ''),
          'dart fix --dry-run': ProcessResult(3, 0, 'Nothing to fix!', ''),
        }).call,
      );

      final parser = ArgParser();
      command.configureArgs(parser);
      final args = parser.parse([]);

      final result = await command.execute(args, createContext());

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.success, isFalse);
      expect(result.valueOrNull?.exitCode, 1);
    });

    test('strict mode treats warnings as failures', () async {
      command = DoctorCommand(
        processRunner: _FakeRunner({
          'dart analyze': ProcessResult(1, 0, 'No issues found!', ''),
          'dart pub outdated': ProcessResult(
            2,
            0,
            'Dependencies are constrained but newer resolvable versions exist.',
            '',
          ),
          'dart fix --dry-run': ProcessResult(3, 0, 'Nothing to fix!', ''),
        }).call,
      );

      final parser = ArgParser();
      command.configureArgs(parser);
      final args = parser.parse(['--strict']);

      final result = await command.execute(args, createContext());

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.success, isFalse);
      expect(result.valueOrNull?.exitCode, 1);
    });
  });
}
