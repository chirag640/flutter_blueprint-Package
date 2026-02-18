/// Analyze command - runs code quality, bundle size, and performance analysis.
///
/// Extracted from CliRunner._runAnalyze with unified Command interface.
library;

import 'dart:io';

import 'package:args/args.dart';

import '../command_interface.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../../analyzer/code_quality_analyzer.dart';
import '../../analyzer/quality_issue.dart';
import '../../analyzer/bundle_size_analyzer.dart';
import '../../config/performance_config.dart';

/// Analyzes code quality, bundle size, and performance of a Flutter project.
class AnalyzeCommandV2 extends BaseCommand {
  @override
  String get name => 'analyze';

  @override
  String get description => 'Analyze code quality, bundle size, or performance';

  @override
  String get usage =>
      'flutter_blueprint analyze [path] [--size] [--performance] [--all]';

  @override
  void configureArgs(ArgParser parser) {
    parser
      ..addFlag('size',
          abbr: 's', help: 'Analyze bundle size', negatable: false)
      ..addFlag('performance',
          abbr: 'p', help: 'Analyze performance', negatable: false)
      ..addFlag('all', abbr: 'a', help: 'Run all analyses', negatable: false)
      ..addFlag('strict', help: 'Enable strict mode', defaultsTo: false)
      ..addFlag('accessibility',
          help: 'Enable accessibility checks', defaultsTo: false)
      ..addOption('path', help: 'Project path', defaultsTo: '.')
      ..addFlag('json', help: 'Output in JSON format', negatable: false)
      ..addFlag('verbose',
          abbr: 'v', help: 'Detailed output', negatable: false);
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    try {
      final projectPath =
          args.rest.isNotEmpty ? args.rest.first : args['path'] as String;
      final analyzeSize = args['size'] as bool;
      final analyzePerformance = args['performance'] as bool;
      final analyzeAll = args['all'] as bool;
      final strictMode = args['strict'] as bool;
      final checkAccessibility = args['accessibility'] as bool;
      final verbose = args['verbose'] as bool;

      // Check if project exists
      if (!await Directory(projectPath).exists()) {
        return Result.failure(
          CommandError(
            'Project directory does not exist: $projectPath',
            command: name,
          ),
        );
      }

      // Determine analysis type
      final shouldAnalyzeSize = analyzeSize || analyzeAll;
      final shouldAnalyzePerformance = analyzePerformance || analyzeAll;
      final isCodeQualityOnly =
          !shouldAnalyzeSize && !shouldAnalyzePerformance && !analyzeAll;

      if (isCodeQualityOnly) {
        // Run code quality analysis (original analyze behavior)
        return _runCodeQualityAnalysis(
          projectPath,
          strictMode,
          checkAccessibility,
          context,
        );
      }

      // New: run size/performance analysis
      if (shouldAnalyzeSize) {
        await _analyzeBundleSize(projectPath, verbose, context);
      }
      if (shouldAnalyzePerformance) {
        await _analyzePerformance(projectPath, verbose, context);
      }

      return const Result.success(CommandResult.ok('Analysis complete'));
    } catch (e) {
      return Result.failure(
        CommandError('Analysis failed: $e', command: name, cause: e),
      );
    }
  }

  Future<Result<CommandResult, CommandError>> _runCodeQualityAnalysis(
    String projectPath,
    bool strictMode,
    bool checkAccessibility,
    CommandContext context,
  ) async {
    context.logger.info('🔍 Running code quality analysis...\n');

    final analyzer = CodeQualityAnalyzer(
      logger: context.logger,
      strictMode: strictMode,
      checkAccessibility: checkAccessibility,
    );

    final report = await analyzer.analyze(projectPath);
    context.logger.info('');
    context.logger.info(report.summary);

    if (report.issues.isNotEmpty) {
      context.logger.info('');
      context.logger.info('📋 Issues by type:');
      context.logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      for (final type in IssueType.values) {
        final issuesOfType = report.getByType(type);
        if (issuesOfType.isNotEmpty) {
          context.logger.info('');
          context.logger.info('${type.label}: ${issuesOfType.length}');
          for (final issue in issuesOfType.take(3)) {
            context.logger.info(issue.toString());
          }
          if (issuesOfType.length > 3) {
            context.logger.info('   ... and ${issuesOfType.length - 3} more');
          }
        }
      }
    }

    if (!report.passed()) {
      context.logger.info('');
      context.logger.warning('⚠️  Analysis found issues.');
      return const Result.success(
        CommandResult(success: false, message: 'Issues found', exitCode: 1),
      );
    }

    context.logger.info('');
    context.logger.success('✅ All checks passed!');
    return const Result.success(CommandResult.ok('All checks passed'));
  }

  Future<void> _analyzeBundleSize(
    String projectPath,
    bool verbose,
    CommandContext context,
  ) async {
    context.logger.info('🔍 Analyzing bundle size...\n');
    final analyzer = BundleSizeAnalyzer(
      projectPath: projectPath,
      logger: context.logger,
    );

    try {
      final report = await analyzer.analyze();
      context.logger.info(report.toFormattedString());
    } catch (e) {
      if (e.toString().contains('Build directory not found')) {
        context.logger.warning('⚠️  Build directory not found.');
        context.logger.info('Build your app first: flutter build apk');
      } else {
        rethrow;
      }
    }
  }

  Future<void> _analyzePerformance(
    String projectPath,
    bool verbose,
    CommandContext context,
  ) async {
    context.logger.info('\n📊 Performance Analysis for: $projectPath\n');

    final blueprintFile = File('$projectPath/blueprint.yaml');
    PerformanceConfig performanceConfig;

    if (await blueprintFile.exists()) {
      final content = await blueprintFile.readAsString();
      performanceConfig = content.contains('performance:')
          ? PerformanceConfig.allEnabled()
          : PerformanceConfig.disabled();
    } else {
      performanceConfig = PerformanceConfig.disabled();
    }

    if (!performanceConfig.enabled) {
      context.logger.warning(
        '⚠️  Performance monitoring is not enabled in blueprint.yaml',
      );
      context.logger.info('');
      context.logger.info('Add to blueprint.yaml:');
      context.logger.info('  performance:');
      context.logger.info('    enabled: true');
      return;
    }

    context.logger.success('✅ Performance monitoring is enabled');
    context.logger.info('');
    context.logger.info('Tracked metrics:');
    for (final metric in performanceConfig.tracking.toList()) {
      context.logger.info('  • $metric');
    }
  }
}
