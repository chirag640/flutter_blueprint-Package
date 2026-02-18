import 'dart:io';

import 'package:flutter_blueprint/src/cli/commands/init_command.dart';
import 'package:flutter_blueprint/src/cli/command_interface.dart';
import 'package:flutter_blueprint/src/core/errors.dart';
import 'package:flutter_blueprint/src/core/result.dart';
import 'package:flutter_blueprint/src/generator/project_generator.dart';
import 'package:flutter_blueprint/src/utils/logger.dart';
import 'package:test/test.dart';
import 'package:args/args.dart';

import '../../test_helpers/mock_generator.dart';
import '../../test_helpers/mock_prompter.dart';

void main() {
  group('InitCommand', () {
    late InitCommand command;
    late MockProjectGenerator mockGenerator;
    late MockInteractivePrompter mockPrompter;
    late Logger logger;
    late String workingDir;

    setUp(() {
      mockGenerator = MockProjectGenerator();
      mockPrompter = MockInteractivePrompter();
      logger = Logger();
      workingDir = Directory.current.path;
      command = InitCommand(generator: mockGenerator);
    });

    CommandContext createContext() {
      return CommandContext(
        logger: logger,
        prompter: mockPrompter,
        workingDirectory: workingDir,
      );
    }

    group('basic configuration', () {
      test('has correct name', () {
        expect(command.name, equals('init'));
      });

      test('has description', () {
        expect(command.description, isNotEmpty);
      });
    });

    group('argument parsing', () {
      test('configures all expected arguments', () {
        final parser = ArgParser();
        command.configureArgs(parser);

        expect(parser.options.containsKey('state'), isTrue);
        expect(parser.options.containsKey('platforms'), isTrue);
        expect(parser.options.containsKey('ci'), isTrue);
        expect(parser.options.containsKey('template'), isTrue);
      });

      test('state option has valid values', () {
        final parser = ArgParser();
        command.configureArgs(parser);

        final stateOption = parser.options['state']!;
        expect(
            stateOption.allowed, containsAll(['provider', 'riverpod', 'bloc']));
      });
    });

    group('validation', () {
      test('rejects invalid app names', () async {
        final parser = ArgParser();
        command.configureArgs(parser);
        final args = parser.parse(['123invalid']);

        final result = await command.execute(args, createContext());

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull?.message, contains('Invalid'));
      });

      test('accepts valid app names', () async {
        final parser = ArgParser();
        command.configureArgs(parser);
        final args = parser.parse(['my_app', '--state=riverpod']);

        mockGenerator.mockGenerateResult = Result.success(
          GenerationResult(
            filesGenerated: 61,
            targetPath: 'my_app',
          ),
        );

        final result = await command.execute(args, createContext());

        expect(result.isSuccess, isTrue);
      });
    });

    group('project generation', () {
      test('generates project with minimal config', () async {
        final parser = ArgParser();
        command.configureArgs(parser);
        final args = parser.parse(['test_app', '--state=riverpod']);

        mockGenerator.mockGenerateResult = Result.success(
          GenerationResult(filesGenerated: 50, targetPath: 'test_app'),
        );

        final result = await command.execute(args, createContext());

        expect(result.isSuccess, isTrue);
        expect(mockGenerator.lastConfig?.appName, equals('test_app'));
      });

      test('handles generator failure gracefully', () async {
        final parser = ArgParser();
        command.configureArgs(parser);
        final args = parser.parse(['fail_app', '--state=riverpod']);

        mockGenerator.mockGenerateResult = Result.failure(
          ProjectGenerationError('Mock error'),
        );

        final result = await command.execute(args, createContext());

        expect(result.isFailure, isTrue);
      });
    });
  });
}
