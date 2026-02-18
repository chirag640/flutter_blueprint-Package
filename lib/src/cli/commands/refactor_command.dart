/// Refactor command - applies automatic refactoring to a Flutter project.
///
/// Refactored to use unified Command interface.
library;

import 'dart:io';

import 'package:args/args.dart';

import '../command_interface.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../../refactoring/auto_refactoring_tool.dart';
import '../../refactoring/refactoring_types.dart';

/// Applies automatic refactoring improvements to a Flutter project.
class RefactorCommand extends BaseCommand {
  @override
  String get name => 'refactor';

  @override
  String get description => 'Refactor project with automatic improvements';

  @override
  String get usage => 'flutter_blueprint refactor [path] [--add-caching] ...';

  @override
  void configureArgs(ArgParser parser) {
    parser
      ..addFlag('add-caching', help: 'Add caching layer', negatable: false)
      ..addFlag('add-offline-support',
          help: 'Add offline support', negatable: false)
      ..addFlag('migrate-to-riverpod',
          help: 'Migrate to Riverpod', negatable: false)
      ..addFlag('migrate-to-bloc', help: 'Migrate to BLoC', negatable: false)
      ..addFlag('add-error-handling',
          help: 'Add error handling', negatable: false)
      ..addFlag('add-logging', help: 'Add logging', negatable: false)
      ..addFlag('optimize-performance',
          help: 'Optimize performance', negatable: false)
      ..addFlag('add-testing',
          help: 'Add testing infrastructure', negatable: false)
      ..addFlag('dry-run',
          help: 'Preview changes without modifying', defaultsTo: false)
      ..addFlag('backup',
          help: 'Create backup before refactoring', defaultsTo: true)
      ..addFlag('run-tests',
          help: 'Run tests after refactoring', defaultsTo: true)
      ..addFlag('format',
          help: 'Format code after refactoring', defaultsTo: true);
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    try {
      context.logger.info('🔧 Running refactoring...\n');

      final projectPath =
          args.rest.isNotEmpty ? args.rest.first : Directory.current.path;

      if (!await Directory(projectPath).exists()) {
        return Result.failure(
          CommandError(
            'Project directory does not exist: $projectPath',
            command: name,
          ),
        );
      }

      // Determine refactoring type
      final refactoringType = _determineRefactoringType(args);

      if (refactoringType == null) {
        return Result.failure(
          CommandError(
            'No refactoring type specified. Use --add-caching, --migrate-to-riverpod, etc.',
            command: name,
          ),
        );
      }

      final config = RefactoringConfig(
        dryRun: args['dry-run'] as bool? ?? false,
        createBackup: args['backup'] as bool? ?? true,
        runTests: args['run-tests'] as bool? ?? true,
        formatCode: args['format'] as bool? ?? true,
      );

      context.logger.info('Refactoring: ${refactoringType.label}');
      context.logger.info('Description: ${refactoringType.description}\n');

      if (config.dryRun) {
        context.logger
            .info('🔍 Running in DRY RUN mode - no files will be modified\n');
      }

      final tool = AutoRefactoringTool(
        logger: context.logger,
        config: config,
      );

      final result = await tool.refactor(projectPath, refactoringType);

      context.logger.info('');
      context.logger.info(result.summary);

      if (result.success) {
        _printResults(result, config, context);
        return const Result.success(
          CommandResult.ok('Refactoring completed'),
        );
      } else {
        return Result.success(
          CommandResult(
            success: false,
            message: result.error ?? 'Refactoring failed',
            exitCode: 1,
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        CommandError('Refactoring failed: $e', command: name, cause: e),
      );
    }
  }

  RefactoringType? _determineRefactoringType(ArgResults args) {
    if (args['add-caching'] as bool? ?? false) {
      return RefactoringType.addCaching;
    }
    if (args['add-offline-support'] as bool? ?? false) {
      return RefactoringType.addOfflineSupport;
    }
    if (args['migrate-to-riverpod'] as bool? ?? false) {
      return RefactoringType.migrateToRiverpod;
    }
    if (args['migrate-to-bloc'] as bool? ?? false) {
      return RefactoringType.migrateToBloc;
    }
    if (args['add-error-handling'] as bool? ?? false) {
      return RefactoringType.addErrorHandling;
    }
    if (args['add-logging'] as bool? ?? false) {
      return RefactoringType.addLogging;
    }
    if (args['optimize-performance'] as bool? ?? false) {
      return RefactoringType.optimizePerformance;
    }
    if (args['add-testing'] as bool? ?? false) {
      return RefactoringType.addTesting;
    }
    return null;
  }

  void _printResults(
    RefactoringResult result,
    RefactoringConfig config,
    CommandContext context,
  ) {
    if (result.filesModified.isNotEmpty) {
      context.logger.info('');
      context.logger.info('📝 Modified files:');
      for (final file in result.filesModified) {
        context.logger.info('  • $file');
      }
    }
    if (result.filesCreated.isNotEmpty) {
      context.logger.info('');
      context.logger.info('➕ Created files:');
      for (final file in result.filesCreated) {
        context.logger.info('  • $file');
      }
    }
    if (result.changes.isNotEmpty) {
      context.logger.info('');
      context.logger.info('🔧 Changes applied:');
      for (final change in result.changes.take(10)) {
        context.logger.info(change.toString());
      }
      if (result.changes.length > 10) {
        context.logger
            .info('  ... and ${result.changes.length - 10} more changes');
      }
    }
    if (!config.dryRun) {
      context.logger.info('');
      context.logger.info('💡 Next steps:');
      context.logger.info('  1. Review the changes');
      context.logger.info('  2. Run: flutter pub get');
      context.logger.info('  3. Run: flutter test');
      context.logger.info('  4. Commit the changes');
    }
  }
}
