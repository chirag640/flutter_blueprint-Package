/// Update command - checks and applies CLI updates.
///
/// Refactored to use unified Command interface.
library;

import 'dart:io';

import 'package:args/args.dart';

import '../command_interface.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../../utils/update_checker.dart';
import '../../utils/version_reader.dart';

/// Handles 'update' command: updates the CLI to the latest pub.dev version.
class UpdateCommandV2 extends BaseCommand {
  @override
  String get name => 'update';

  @override
  String get description =>
      'Update flutter_blueprint to the latest version from pub.dev';

  @override
  String get usage => 'flutter_blueprint update\n\n'
      '  Equivalent to running: dart pub global activate flutter_blueprint';

  @override
  void configureArgs(ArgParser parser) {
    // No additional args needed.
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    try {
      context.logger.info('');
      context.logger.info('🔄 Checking for updates...');
      context.logger.info('');

      final updateChecker = UpdateChecker();
      final updateInfo = await updateChecker.checkForUpdates();
      final currentVersion = await VersionReader.getVersion();

      if (updateInfo == null) {
        context.logger.success(
          '✅ You are already running the latest version ($currentVersion)',
        );
        return const Result.success(CommandResult.ok('Already up to date'));
      }

      context.logger.info('📦 Current version: ${updateInfo.currentVersion}');
      context.logger.info('🚀 Latest version:  ${updateInfo.latestVersion}');
      context.logger.info('');
      context.logger.info('⬆️  Updating flutter_blueprint...');
      context.logger.info('');

      final result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', 'flutter_blueprint'],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        context.logger.success(
          '✅ Successfully updated to ${updateInfo.latestVersion}!',
        );
        context.logger.info('');
        context.logger.info('📋 What\'s new:');
        context.logger.info(
          '   https://github.com/chirag640/flutter_blueprint-Package/blob/main/CHANGELOG.md',
        );
        context.logger.info('');
        return Result.success(
          CommandResult.ok('Updated to ${updateInfo.latestVersion}'),
        );
      } else {
        context.logger
            .error('❌ Update failed with exit code ${result.exitCode}');
        if (result.stderr.toString().isNotEmpty) {
          context.logger.error(result.stderr.toString());
        }
        _printManualUpdateHint(context);
        return Result.success(
          CommandResult(
            success: false,
            message: 'Update failed',
            exitCode: result.exitCode,
          ),
        );
      }
    } on ProcessException catch (e) {
      context.logger.error('❌ Failed to run update command: ${e.message}');
      _printManualUpdateHint(context);
      return Result.failure(
        CommandError('Process error: ${e.message}', command: name, cause: e),
      );
    } catch (e) {
      context.logger.error('❌ Unexpected error during update: $e');
      _printManualUpdateHint(context);
      return Result.failure(
        CommandError('Update failed: $e', command: name, cause: e),
      );
    }
  }

  void _printManualUpdateHint(CommandContext context) {
    context.logger.info('');
    context.logger.info('💡 Try updating manually:');
    context.logger.info('   dart pub global activate flutter_blueprint');
  }
}
