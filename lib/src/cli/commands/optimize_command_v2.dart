/// Optimize command - analyzes and optimizes Flutter project bundle.
///
/// Refactored to use unified Command interface.
library;

import 'dart:io';

import 'package:args/args.dart';

import '../command_interface.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../../analyzer/bundle_size_analyzer.dart';
import 'package:path/path.dart' as path;

/// Optimizes Flutter project bundle size and assets.
class OptimizeCommandV2 extends BaseCommand {
  @override
  String get name => 'optimize';

  @override
  String get description => 'Optimize bundle size and assets';

  @override
  String get usage =>
      'flutter_blueprint optimize [--tree-shake] [--assets] [--all]';

  @override
  void configureArgs(ArgParser parser) {
    parser
      ..addFlag('tree-shake',
          abbr: 't', help: 'Analyze tree-shaking', negatable: false)
      ..addFlag('assets', abbr: 'a', help: 'Optimize assets', negatable: false)
      ..addFlag('all', help: 'Run all optimizations', negatable: false)
      ..addOption('path', help: 'Project path', defaultsTo: '.')
      ..addFlag('dry-run', help: 'Preview changes only', negatable: false)
      ..addFlag('verbose',
          abbr: 'v', help: 'Show detailed output', negatable: false);
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    try {
      final projectPath = args['path'] as String;
      final treeShake = args['tree-shake'] as bool;
      final optimizeAssets = args['assets'] as bool;
      final optimizeAll = args['all'] as bool;
      final dryRun = args['dry-run'] as bool;
      final verbose = args['verbose'] as bool;

      if (!await Directory(projectPath).exists()) {
        return Result.failure(
          CommandError('Project directory not found: $projectPath',
              command: name),
        );
      }

      final shouldTreeShake = treeShake || optimizeAll;
      final shouldOptimizeAssets = optimizeAssets || optimizeAll;

      if (!shouldTreeShake && !shouldOptimizeAssets) {
        return Result.failure(
          CommandError(
            'No optimization type specified. Use --tree-shake, --assets, or --all',
            command: name,
          ),
        );
      }

      if (dryRun) {
        context.logger
            .info('🔍 Running in dry-run mode (no changes will be made)\n');
      }

      int totalSavings = 0;
      if (shouldTreeShake) {
        totalSavings +=
            await _analyzeTreeShaking(projectPath, dryRun, verbose, context);
      }
      if (shouldOptimizeAssets) {
        totalSavings +=
            await _optimizeAssets(projectPath, dryRun, verbose, context);
      }

      context.logger.info('');
      context.logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      if (dryRun) {
        context.logger.success('✅ Optimization analysis complete!');
        context.logger
            .info('   Potential savings: ${_formatSize(totalSavings)}');
        context.logger.info('   Run without --dry-run to apply optimizations');
      } else {
        context.logger.success('✅ Optimization complete!');
        context.logger.info('   Total savings: ${_formatSize(totalSavings)}');
      }

      return const Result.success(CommandResult.ok('Optimization complete'));
    } catch (e) {
      return Result.failure(
        CommandError('Optimization failed: $e', command: name, cause: e),
      );
    }
  }

  Future<int> _analyzeTreeShaking(
    String projectPath,
    bool dryRun,
    bool verbose,
    CommandContext context,
  ) async {
    context.logger.info('🌲 Analyzing tree-shaking opportunities...\n');

    final analyzer =
        BundleSizeAnalyzer(projectPath: projectPath, logger: context.logger);

    try {
      final report = await analyzer.analyze();
      final suggestions = report.suggestions
          .where(
              (s) => s.title.contains('packages') || s.title.contains('lazy'))
          .toList();

      if (suggestions.isEmpty) {
        context.logger.success('✅ All packages are already tree-shaken\n');
        return 0;
      }

      context.logger.info('💡 Tree-shaking suggestions:');
      for (var i = 0; i < suggestions.length; i++) {
        final suggestion = suggestions[i];
        context.logger.info('  ${i + 1}. ${suggestion.title}');
        context.logger.info('     ${suggestion.description}');
        context.logger.info('');
      }
      return 0;
    } catch (e) {
      context.logger.warning('⚠️  Could not analyze tree-shaking: $e');
      return 0;
    }
  }

  Future<int> _optimizeAssets(
    String projectPath,
    bool dryRun,
    bool verbose,
    CommandContext context,
  ) async {
    context.logger.info('🎨 Optimizing assets...\n');

    final analyzer =
        BundleSizeAnalyzer(projectPath: projectPath, logger: context.logger);

    try {
      final report = await analyzer.analyze();
      final assetSuggestions = report.suggestions
          .where(
              (s) => s.title.contains('assets') || s.title.contains('images'))
          .toList();

      if (assetSuggestions.isEmpty) {
        context.logger.success('✅ No asset optimizations needed\n');
        return 0;
      }

      int totalSavings = 0;
      for (final suggestion in assetSuggestions) {
        context.logger.info('${suggestion.severityIcon} ${suggestion.title}');
        context.logger.info('   ${suggestion.description}');
        if (suggestion.potentialSavings > 0) {
          totalSavings += suggestion.potentialSavings;
          context.logger.info(
            '   Potential savings: ${_formatSize(suggestion.potentialSavings)}',
          );
        }

        if (!dryRun &&
            suggestion.items != null &&
            suggestion.items!.isNotEmpty) {
          if (suggestion.title.contains('unused')) {
            await _removeUnusedAssets(projectPath, suggestion.items!, context);
          }
        }
        context.logger.info('');
      }

      return totalSavings;
    } catch (e) {
      context.logger.warning('⚠️  Could not optimize assets: $e');
      return 0;
    }
  }

  Future<void> _removeUnusedAssets(
    String projectPath,
    List<String> unusedAssets,
    CommandContext context,
  ) async {
    context.logger.info('\n📋 Removing unused assets:');
    for (final assetPath in unusedAssets) {
      final fullPath = path.join(projectPath, assetPath);
      final file = File(fullPath);
      if (await file.exists()) {
        final size = await file.length();
        context.logger.info('   • $assetPath (${_formatSize(size)})');
        try {
          await file.delete();
          context.logger.success('     ✓ Removed');
        } catch (e) {
          context.logger.warning('     ✗ Failed to remove: $e');
        }
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
