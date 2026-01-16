/// Command for updating the CLI to the latest version
library;

import 'dart:io';

import '../utils/logger.dart';
import '../utils/update_checker.dart';
import '../utils/version_reader.dart';

/// Handles the 'update' command for updating the CLI to the latest version
class UpdateCommand {
  final Logger _logger;

  UpdateCommand({Logger? logger}) : _logger = logger ?? Logger();

  /// Execute the update command
  Future<void> execute() async {
    _logger.info('');
    _logger.info('🔄 Checking for updates...');
    _logger.info('');

    try {
      // Check if an update is available
      final updateChecker = UpdateChecker();
      final updateInfo = await updateChecker.checkForUpdates();
      final currentVersion = await VersionReader.getVersion();

      if (updateInfo == null) {
        _logger.success(
            '✅ You are already running the latest version ($currentVersion)');
        return;
      }

      _logger.info('📦 Current version: ${updateInfo.currentVersion}');
      _logger.info('🚀 Latest version:  ${updateInfo.latestVersion}');
      _logger.info('');
      _logger.info('⬆️  Updating flutter_blueprint...');
      _logger.info('');

      // Run dart pub global activate to update
      final result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', 'flutter_blueprint'],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        _logger
            .success('✅ Successfully updated to ${updateInfo.latestVersion}!');
        _logger.info('');
        _logger.info('📋 What\'s new:');
        _logger.info(
            '   https://github.com/chirag640/flutter_blueprint-Package/blob/main/CHANGELOG.md');
        _logger.info('');
      } else {
        _logger.error('❌ Update failed with exit code ${result.exitCode}');
        if (result.stderr.toString().isNotEmpty) {
          _logger.error(result.stderr.toString());
        }
        _logger.info('');
        _logger.info('💡 Try updating manually:');
        _logger.info('   dart pub global activate flutter_blueprint');
        exit(1);
      }
    } on ProcessException catch (e) {
      _logger.error('❌ Failed to run update command: ${e.message}');
      _logger.info('');
      _logger.info('💡 Try updating manually:');
      _logger.info('   dart pub global activate flutter_blueprint');
      exit(1);
    } catch (e) {
      _logger.error('❌ Unexpected error during update: $e');
      _logger.info('');
      _logger.info('💡 Try updating manually:');
      _logger.info('   dart pub global activate flutter_blueprint');
      exit(1);
    }
  }

  /// Print usage information
  void printUsage() {
    _logger.info('''
Updates flutter_blueprint to the latest version from pub.dev.

Usage:
  flutter_blueprint update

Examples:
  # Update to the latest version
  flutter_blueprint update

This command is equivalent to running:
  dart pub global activate flutter_blueprint
''');
  }
}
