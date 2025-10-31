/// Command for optimizing Flutter bundle
library;

import 'dart:io';
import 'package:args/args.dart';
import '../analyzer/bundle_size_analyzer.dart';
import '../utils/logger.dart';
import 'package:path/path.dart' as path;

/// Command to optimize the Flutter project bundle
class OptimizeCommand {
  final Logger _logger;

  OptimizeCommand({Logger? logger}) : _logger = logger ?? Logger();

  /// Configures the optimize command arguments
  void configureArgs(ArgParser parser) {
    parser.addFlag(
      'tree-shake',
      abbr: 't',
      help: 'Analyze and suggest tree-shaking optimizations',
      negatable: false,
    );

    parser.addFlag(
      'assets',
      abbr: 'a',
      help: 'Optimize assets (compress images, remove unused)',
      negatable: false,
    );

    parser.addFlag(
      'all',
      help: 'Run all optimizations',
      negatable: false,
    );

    parser.addOption(
      'path',
      help: 'Path to the Flutter project (defaults to current directory)',
      defaultsTo: '.',
    );

    parser.addFlag(
      'dry-run',
      help: 'Show what would be optimized without making changes',
      negatable: false,
    );

    parser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show detailed optimization information',
      negatable: false,
    );
  }

  /// Executes the optimize command
  Future<void> execute(ArgResults args) async {
    final projectPath = args['path'] as String;
    final treeShake = args['tree-shake'] as bool;
    final optimizeAssets = args['assets'] as bool;
    final optimizeAll = args['all'] as bool;
    final dryRun = args['dry-run'] as bool;
    final verbose = args['verbose'] as bool;

    // Validate project path
    final projectDir = Directory(projectPath);
    if (!await projectDir.exists()) {
      _logger.error('Project directory not found: $projectPath');
      exit(1);
    }

    // Check if it's a Flutter project
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      _logger.error('Not a Flutter project: pubspec.yaml not found');
      exit(1);
    }

    // Determine what to optimize
    final shouldTreeShake = treeShake || optimizeAll;
    final shouldOptimizeAssets = optimizeAssets || optimizeAll;

    if (!shouldTreeShake && !shouldOptimizeAssets) {
      _logger.error(
          'No optimization type specified. Use --tree-shake, --assets, or --all');
      exit(1);
    }

    if (dryRun) {
      _logger.info('🔍 Running in dry-run mode (no changes will be made)');
      _logger.info('');
    }

    try {
      int totalSavings = 0;

      // Run tree-shaking analysis
      if (shouldTreeShake) {
        final savings = await _analyzeTreeShaking(projectPath, dryRun, verbose);
        totalSavings += savings;
      }

      // Run asset optimization
      if (shouldOptimizeAssets) {
        final savings = await _optimizeAssets(projectPath, dryRun, verbose);
        totalSavings += savings;
      }

      // Summary
      _logger.info('');
      _logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      if (dryRun) {
        _logger.success('✅ Optimization analysis complete!');
        _logger.info('   Potential savings: ${_formatSize(totalSavings)}');
        _logger.info('');
        _logger.info('   Run without --dry-run to apply optimizations');
      } else {
        _logger.success('✅ Optimization complete!');
        _logger.info('   Total savings: ${_formatSize(totalSavings)}');
      }
    } catch (e) {
      _logger.error('Optimization failed: $e');
      exit(1);
    }
  }

  /// Analyzes tree-shaking opportunities
  Future<int> _analyzeTreeShaking(
    String projectPath,
    bool dryRun,
    bool verbose,
  ) async {
    _logger.info('🌲 Analyzing tree-shaking opportunities...');
    _logger.info('');

    final analyzer = BundleSizeAnalyzer(
      projectPath: projectPath,
      logger: _logger,
    );

    try {
      final report = await analyzer.analyze();

      // Check packages that could benefit from tree-shaking
      final suggestions = report.suggestions
          .where(
              (s) => s.title.contains('packages') || s.title.contains('lazy'))
          .toList();

      if (suggestions.isEmpty) {
        _logger.success('✅ All packages are already tree-shaken');
        _logger.info('   Flutter automatically tree-shakes unused code');
        _logger.info('');
        return 0;
      }

      _logger.info('💡 Tree-shaking suggestions:');
      for (var i = 0; i < suggestions.length; i++) {
        final suggestion = suggestions[i];
        _logger.info('  ${i + 1}. ${suggestion.title}');
        _logger.info('     ${suggestion.description}');
        if (suggestion.items != null && suggestion.items!.isNotEmpty) {
          for (final item in suggestion.items!.take(3)) {
            _logger.info('       - $item');
          }
        }
        _logger.info('');
      }

      // Provide guidance
      _logger.info('📝 Recommendations:');
      _logger.info('  • Use import directives to import only what you need');
      _logger.info('  • Consider lazy-loading large packages');
      _logger.info('  • Use const constructors where possible');
      _logger.info('  • Remove unused dependencies from pubspec.yaml');
      _logger.info('');

      return 0; // Tree-shaking is automatic in Flutter
    } catch (e) {
      _logger.warning('⚠️  Could not analyze tree-shaking: $e');
      return 0;
    }
  }

  /// Optimizes assets
  Future<int> _optimizeAssets(
    String projectPath,
    bool dryRun,
    bool verbose,
  ) async {
    _logger.info('🎨 Optimizing assets...');
    _logger.info('');

    final analyzer = BundleSizeAnalyzer(
      projectPath: projectPath,
      logger: _logger,
    );

    try {
      final report = await analyzer.analyze();

      // Find optimization opportunities
      final assetSuggestions = report.suggestions
          .where(
              (s) => s.title.contains('assets') || s.title.contains('images'))
          .toList();

      if (assetSuggestions.isEmpty) {
        _logger.success('✅ No asset optimizations needed');
        _logger.info('');
        return 0;
      }

      int totalSavings = 0;

      for (final suggestion in assetSuggestions) {
        _logger.info('${suggestion.severityIcon} ${suggestion.title}');
        _logger.info('   ${suggestion.description}');

        if (suggestion.potentialSavings > 0) {
          totalSavings += suggestion.potentialSavings;
          _logger.info(
              '   Potential savings: ${_formatSize(suggestion.potentialSavings)}');
        }

        if (!dryRun &&
            suggestion.items != null &&
            suggestion.items!.isNotEmpty) {
          // Handle unused assets
          if (suggestion.title.contains('unused')) {
            await _removeUnusedAssets(projectPath, suggestion.items!, dryRun);
          }

          // Handle large images
          if (suggestion.title.contains('large images')) {
            await _suggestImageOptimization(suggestion.items!);
          }
        }

        _logger.info('');
      }

      if (dryRun) {
        _logger.info('💡 To apply these optimizations, run without --dry-run');
      }

      return totalSavings;
    } catch (e) {
      _logger.warning('⚠️  Could not optimize assets: $e');
      return 0;
    }
  }

  /// Removes unused assets
  Future<void> _removeUnusedAssets(
    String projectPath,
    List<String> unusedAssets,
    bool dryRun,
  ) async {
    _logger.info('');
    _logger.info('📋 Unused assets to remove:');

    for (final assetPath in unusedAssets) {
      final fullPath = path.join(projectPath, assetPath);
      final file = File(fullPath);

      if (await file.exists()) {
        final size = await file.length();
        _logger.info('   • $assetPath (${_formatSize(size)})');

        if (!dryRun) {
          try {
            await file.delete();
            _logger.success('     ✓ Removed');
          } catch (e) {
            _logger.warning('     ✗ Failed to remove: $e');
          }
        }
      }
    }
  }

  /// Suggests image optimization tools
  Future<void> _suggestImageOptimization(List<String> largeImages) async {
    _logger.info('');
    _logger.info('💡 Consider optimizing these images:');

    for (final imagePath in largeImages.take(5)) {
      _logger.info('   • $imagePath');
    }

    if (largeImages.length > 5) {
      _logger.info('   ... and ${largeImages.length - 5} more');
    }

    _logger.info('');
    _logger.info('🛠️  Recommended tools:');
    _logger.info('   • ImageMagick: convert input.png -quality 85 output.webp');
    _logger.info('   • TinyPNG: https://tinypng.com/');
    _logger.info('   • Squoosh: https://squoosh.app/');
    _logger.info('   • flutter_launcher_icons package for app icons');
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
