/// Command for analyzing bundle size and performance
library;

import 'dart:io';
import 'package:args/args.dart';
import '../analyzer/bundle_size_analyzer.dart';
import '../config/performance_config.dart';
import '../utils/logger.dart';

/// Command to analyze various aspects of the Flutter project
class AnalyzeCommand {
  final Logger _logger;

  AnalyzeCommand({Logger? logger}) : _logger = logger ?? Logger();

  /// Configures the analyze command arguments
  void configureArgs(ArgParser parser) {
    parser.addFlag(
      'size',
      abbr: 's',
      help: 'Analyze bundle size and provide optimization suggestions',
      negatable: false,
    );

    parser.addFlag(
      'performance',
      abbr: 'p',
      help: 'Analyze performance metrics',
      negatable: false,
    );

    parser.addFlag(
      'all',
      abbr: 'a',
      help: 'Run all analyses',
      negatable: false,
    );

    parser.addOption(
      'path',
      help: 'Path to the Flutter project (defaults to current directory)',
      defaultsTo: '.',
    );

    parser.addFlag(
      'json',
      help: 'Output results in JSON format',
      negatable: false,
    );

    parser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show detailed analysis information',
      negatable: false,
    );
  }

  /// Executes the analyze command
  Future<void> execute(ArgResults args) async {
    final projectPath = args['path'] as String;
    final analyzeSize = args['size'] as bool;
    final analyzePerformance = args['performance'] as bool;
    final analyzeAll = args['all'] as bool;
    final jsonOutput = args['json'] as bool;
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

    // Determine what to analyze
    final shouldAnalyzeSize = analyzeSize || analyzeAll;
    final shouldAnalyzePerformance = analyzePerformance || analyzeAll;

    if (!shouldAnalyzeSize && !shouldAnalyzePerformance) {
      _logger.error(
          'No analysis type specified. Use --size, --performance, or --all');
      exit(1);
    }

    try {
      // Run size analysis
      if (shouldAnalyzeSize) {
        await _analyzeBundleSize(projectPath, jsonOutput, verbose);
      }

      // Run performance analysis
      if (shouldAnalyzePerformance) {
        await _analyzePerformance(projectPath, jsonOutput, verbose);
      }
    } catch (e) {
      _logger.error('Analysis failed: $e');
      exit(1);
    }
  }

  /// Analyzes bundle size
  Future<void> _analyzeBundleSize(
    String projectPath,
    bool jsonOutput,
    bool verbose,
  ) async {
    if (!jsonOutput) {
      _logger.info('🔍 Analyzing bundle size...');
      _logger.info('');
    }

    final analyzer = BundleSizeAnalyzer(
      projectPath: projectPath,
      logger: _logger,
    );

    try {
      final report = await analyzer.analyze();

      if (jsonOutput) {
        _outputJsonReport(report);
      } else {
        _logger.info(report.toFormattedString());

        if (verbose) {
          _outputDetailedSizeBreakdown(report);
        }
      }
    } catch (e) {
      if (e.toString().contains('Build directory not found')) {
        _logger.warning('⚠️  Build directory not found.');
        _logger.info('');
        _logger.info('To analyze bundle size, first build your app:');
        _logger.info('  • flutter build apk (for Android)');
        _logger.info('  • flutter build ios (for iOS)');
        _logger.info('  • flutter build web (for Web)');
        _logger.info('');
      } else {
        rethrow;
      }
    }
  }

  /// Analyzes performance
  Future<void> _analyzePerformance(
    String projectPath,
    bool jsonOutput,
    bool verbose,
  ) async {
    if (!jsonOutput) {
      _logger.info('\n📊 Code Quality Report for: $projectPath\n');
      _logger.info('');
    }

    // Try to load blueprint config from blueprint.yaml
    final blueprintFile = File('$projectPath/blueprint.yaml');

    PerformanceConfig performanceConfig;
    if (await blueprintFile.exists()) {
      try {
        final content = await blueprintFile.readAsString();
        // Simple YAML parsing for performance config
        // For a full implementation, you'd use a YAML parser package
        if (content.contains('performance:')) {
          // Assume performance is configured
          performanceConfig = PerformanceConfig.allEnabled();
        } else {
          performanceConfig = PerformanceConfig.disabled();
        }
      } catch (e) {
        performanceConfig = PerformanceConfig.disabled();
      }
    } else {
      performanceConfig = PerformanceConfig.disabled();
    }

    if (!performanceConfig.enabled) {
      _logger.warning(
          '⚠️  Performance monitoring is not enabled in blueprint.yaml');
      _logger.info('');
      _logger.info(
          'To enable performance monitoring, add to your blueprint.yaml:');
      _logger.info('');
      _logger.info('performance:');
      _logger.info('  enabled: true');
      _logger.info('  tracking:');
      _logger.info('    - app_start_time');
      _logger.info('    - screen_load_time');
      _logger.info('    - api_response_time');
      _logger.info('    - frame_render_time');
      _logger.info('  alerts:');
      _logger.info('    slow_screen_threshold: 500ms');
      _logger.info('    slow_api_threshold: 2s');
      _logger.info('');
      return;
    }

    _logger.success('✅ Performance monitoring is enabled');
    _logger.info('');
    _logger.info('Tracked metrics:');
    for (final metric in performanceConfig.tracking.toList()) {
      _logger.info('  • $metric');
    }
    _logger.info('');
    _logger.info('Alert thresholds:');
    _logger.info(
        '  • Screen load: ${performanceConfig.alerts.slowScreenThreshold}ms');
    _logger.info(
        '  • API response: ${performanceConfig.alerts.slowApiThreshold}ms');
    _logger.info(
        '  • App startup: ${performanceConfig.alerts.slowStartupThreshold}ms');
    _logger.info(
        '  • Frame drop: ${performanceConfig.alerts.frameDropThreshold}ms');
    _logger.info('');

    // Check if performance tracking is set up in the project
    final performanceFile =
        File('$projectPath/lib/core/performance_tracker.dart');
    if (await performanceFile.exists()) {
      _logger.success('✅ Performance tracking is set up in the project');
    } else {
      _logger.warning('⚠️  Performance tracking not found in project');
      _logger.info('   Run: flutter_blueprint setup performance');
    }
  }

  /// Outputs detailed size breakdown
  void _outputDetailedSizeBreakdown(BundleSizeReport report) {
    _logger.info('');
    _logger.info('📋 Detailed Breakdown:');
    _logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Top code files
    if (report.codeSize.items.isNotEmpty) {
      _logger.info('');
      _logger.info('Largest Code Files:');
      final topCode = report.codeSize.items.take(5);
      for (final item in topCode) {
        _logger.info('  ${_formatSize(item.bytes).padLeft(10)} - ${item.name}');
      }
    }

    // Top assets
    if (report.assetsSize.items.isNotEmpty) {
      _logger.info('');
      _logger.info('Largest Assets:');
      final topAssets = report.assetsSize.items.take(5);
      for (final item in topAssets) {
        _logger.info('  ${_formatSize(item.bytes).padLeft(10)} - ${item.name}');
      }
    }

    // Top packages
    if (report.packagesSize.items.isNotEmpty) {
      _logger.info('');
      _logger.info('Largest Packages:');
      final topPackages = report.packagesSize.items.take(5);
      for (final item in topPackages) {
        _logger.info('  ${_formatSize(item.bytes).padLeft(10)} - ${item.name}');
      }
    }
  }

  /// Outputs report in JSON format
  void _outputJsonReport(BundleSizeReport report) {
    final json = {
      'totalSize': report.totalSize,
      'breakdown': {
        'code': {
          'bytes': report.codeSize.totalBytes,
          'percentage':
              _percentage(report.codeSize.totalBytes, report.totalSize),
        },
        'assets': {
          'bytes': report.assetsSize.totalBytes,
          'percentage':
              _percentage(report.assetsSize.totalBytes, report.totalSize),
        },
        'packages': {
          'bytes': report.packagesSize.totalBytes,
          'percentage':
              _percentage(report.packagesSize.totalBytes, report.totalSize),
        },
      },
      'suggestions': report.suggestions
          .map((s) => {
                'severity': s.severity.name,
                'title': s.title,
                'description': s.description,
                'potentialSavings': s.potentialSavings,
                if (s.items != null) 'items': s.items,
              })
          .toList(),
      'potentialSavings': report.potentialSavings,
    };

    _logger.info(json.toString());
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int _percentage(int part, int total) {
    if (total == 0) return 0;
    return ((part / total) * 100).round();
  }
}
