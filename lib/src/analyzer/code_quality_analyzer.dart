import 'dart:io';

import 'package:path/path.dart' as p;

import '../utils/logger.dart';
import 'quality_issue.dart';

/// Analyzes Flutter/Dart code for quality issues.
///
/// This analyzer checks for common issues like magic numbers, missing error
/// handling, undocumented APIs, and performance problems. It provides
/// actionable suggestions for improving code quality.
class CodeQualityAnalyzer {
  CodeQualityAnalyzer({
    Logger? logger,
    this.strictMode = false,
    this.checkPerformance = false,
    this.checkAccessibility = false,
  }) : _logger = logger ?? Logger();

  final Logger _logger;
  final bool strictMode;
  final bool checkPerformance;
  final bool checkAccessibility;

  /// Analyzes the project at the given path.
  ///
  /// Returns an [AnalysisReport] containing all found issues.
  Future<AnalysisReport> analyze(String projectPath) async {
    final startTime = DateTime.now();
    _logger.info('🔍 Starting code quality analysis...');
    _logger.info('   Project: $projectPath');
    _logger.info('   Strict mode: $strictMode');
    _logger.info('   Performance checks: $checkPerformance');
    _logger.info('   Accessibility checks: $checkAccessibility');
    _logger.info('');

    final issues = <QualityIssue>[];
    var filesAnalyzed = 0;

    // Find all Dart files
    final dartFiles = await _findDartFiles(projectPath);
    _logger.info('Found ${dartFiles.length} Dart files to analyze');
    _logger.info('');

    // Analyze each file
    for (final file in dartFiles) {
      try {
        final content = await File(file).readAsString();
        final fileIssues = await _analyzeFile(file, content, projectPath);
        issues.addAll(fileIssues);
        filesAnalyzed++;

        if (fileIssues.isNotEmpty) {
          _logger.debug(
              '  ${p.relative(file, from: projectPath)}: ${fileIssues.length} issues');
        }
      } catch (e) {
        _logger.warning('Failed to analyze $file: $e');
      }
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    _logger.info('');
    _logger.success('✅ Analysis complete!');

    return AnalysisReport(
      issues: issues,
      filesAnalyzed: filesAnalyzed,
      analysisTimeMs: duration.inMilliseconds,
    );
  }

  /// Finds all Dart files in the project, excluding generated and test files.
  Future<List<String>> _findDartFiles(String projectPath) async {
    final files = <String>[];
    final libDir = Directory(p.join(projectPath, 'lib'));

    if (!await libDir.exists()) {
      return files;
    }

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        // Skip generated files
        if (entity.path.contains('.g.dart') ||
            entity.path.contains('.freezed.dart')) {
          continue;
        }
        files.add(entity.path);
      }
    }

    return files;
  }

  /// Analyzes a single file for quality issues.
  Future<List<QualityIssue>> _analyzeFile(
    String filePath,
    String content,
    String projectPath,
  ) async {
    final issues = <QualityIssue>[];
    final lines = content.split('\n');

    // Run all checks
    issues.addAll(_findMagicNumbers(filePath, lines));
    issues.addAll(_findMissingErrorHandling(filePath, lines));
    issues.addAll(_findUndocumentedPublicAPIs(filePath, lines));

    if (checkPerformance) {
      issues.addAll(_findMissingConst(filePath, lines));
      issues.addAll(_findInefficientBuilds(filePath, lines));
    }

    if (checkAccessibility) {
      issues.addAll(_findMissingSemanticLabels(filePath, lines));
    }

    if (strictMode) {
      issues.addAll(_findStateManagementAntiPatterns(filePath, lines));
      issues.addAll(_findPotentialMemoryLeaks(filePath, lines));
    }

    return issues;
  }

  /// Finds magic numbers (hardcoded numeric literals).
  List<QualityIssue> _findMagicNumbers(String filePath, List<String> lines) {
    final issues = <QualityIssue>[];
    final magicNumberPattern = RegExp(r'\b(\d+\.?\d*)\b');

    // Common acceptable numbers
    const acceptableNumbers = {'0', '1', '2', '10', '100', '0.0', '1.0'};

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip comments and strings
      if (line.trim().startsWith('//') || line.trim().startsWith('*')) {
        continue;
      }

      final matches = magicNumberPattern.allMatches(line);
      for (final match in matches) {
        final number = match.group(1)!;

        // Skip acceptable numbers and array indices
        if (acceptableNumbers.contains(number)) continue;
        if (line.contains('[$number]')) continue; // Array access
        if (line.contains('Duration(')) {
          continue; // Duration is self-documenting
        }

        // Check if number is in a const declaration (acceptable)
        if (line.contains('const') && line.contains('=')) continue;

        issues.add(QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.warning,
          message:
              'Magic number $number found. Consider using a named constant.',
          filePath: filePath,
          line: i + 1,
          column: match.start,
          suggestion: 'Create a const variable: const myValue = $number;',
        ));
      }
    }

    return issues;
  }

  /// Finds missing error handling in async functions.
  List<QualityIssue> _findMissingErrorHandling(
      String filePath, List<String> lines) {
    final issues = <QualityIssue>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Look for async functions
      if (line.contains('async') && line.contains('{')) {
        // Check if there's a try-catch in the next 20 lines
        var hasTryCatch = false;
        final endIndex = (i + 20).clamp(0, lines.length);

        for (var j = i; j < endIndex; j++) {
          if (lines[j].contains('try') || lines[j].contains('catch')) {
            hasTryCatch = true;
            break;
          }
        }

        if (!hasTryCatch && line.contains('Future')) {
          issues.add(QualityIssue(
            type: IssueType.missingErrorHandling,
            severity: IssueSeverity.warning,
            message: 'Async function lacks error handling.',
            filePath: filePath,
            line: i + 1,
            suggestion: 'Wrap async operations in try-catch blocks.',
          ));
        }
      }
    }

    return issues;
  }

  /// Finds undocumented public APIs (classes, methods, functions).
  List<QualityIssue> _findUndocumentedPublicAPIs(
      String filePath, List<String> lines) {
    final issues = <QualityIssue>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip private members (starting with _)
      if (line.startsWith('_')) continue;

      // Check for public class declarations
      if (line.startsWith('class ') && !line.startsWith('class _')) {
        // Look for doc comment in previous line
        if (i == 0 || !lines[i - 1].trim().startsWith('///')) {
          issues.add(QualityIssue(
            type: IssueType.undocumentedApi,
            severity: strictMode ? IssueSeverity.error : IssueSeverity.info,
            message: 'Public class lacks documentation.',
            filePath: filePath,
            line: i + 1,
            suggestion: 'Add a doc comment: /// Description of the class.',
          ));
        }
      }

      // Check for public methods/functions
      if ((line.contains('Future') ||
              line.contains('void') ||
              line.contains('String') ||
              line.contains('int')) &&
          line.contains('(') &&
          !line.contains('_') &&
          !line.contains('override') &&
          !line.contains('=')) {
        // Look for doc comment
        if (i == 0 || !lines[i - 1].trim().startsWith('///')) {
          issues.add(QualityIssue(
            type: IssueType.undocumentedApi,
            severity: strictMode ? IssueSeverity.error : IssueSeverity.info,
            message: 'Public method/function lacks documentation.',
            filePath: filePath,
            line: i + 1,
            suggestion: 'Add a doc comment describing the function.',
          ));
        }
      }
    }

    return issues;
  }

  /// Finds widgets that could be const but aren't.
  List<QualityIssue> _findMissingConst(String filePath, List<String> lines) {
    final issues = <QualityIssue>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Look for widget constructors without const
      if (line.contains('return ') &&
          (line.contains('Text(') ||
              line.contains('Icon(') ||
              line.contains('Padding(') ||
              line.contains('SizedBox('))) {
        if (!line.contains('const ')) {
          issues.add(QualityIssue(
            type: IssueType.missingConst,
            severity: IssueSeverity.info,
            message: 'Widget could be const for better performance.',
            filePath: filePath,
            line: i + 1,
            suggestion: 'Add const keyword before the widget constructor.',
          ));
        }
      }
    }

    return issues;
  }

  /// Finds inefficient build methods.
  List<QualityIssue> _findInefficientBuilds(
      String filePath, List<String> lines) {
    final issues = <QualityIssue>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Look for object creation in build methods
      if (line.contains('build(BuildContext context)')) {
        // Check next 30 lines for inefficiencies
        final endIndex = (i + 30).clamp(0, lines.length);

        for (var j = i; j < endIndex; j++) {
          final buildLine = lines[j];

          // Creating lists/maps in build
          if (buildLine.contains('[') &&
              buildLine.contains(']') &&
              !buildLine.contains('const [')) {
            issues.add(QualityIssue(
              type: IssueType.inefficientBuild,
              severity: IssueSeverity.warning,
              message:
                  'List created in build method. Consider making it const or moving to a variable.',
              filePath: filePath,
              line: j + 1,
              suggestion: 'Use const [] or create as a static/final variable.',
            ));
          }
        }
      }
    }

    return issues;
  }

  /// Finds widgets missing semantic labels for accessibility.
  List<QualityIssue> _findMissingSemanticLabels(
      String filePath, List<String> lines) {
    final issues = <QualityIssue>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check for Image without semanticLabel
      if (line.contains('Image.') && !line.contains('semanticLabel')) {
        // Check next few lines for semanticLabel parameter
        var hasLabel = false;
        for (var j = i; j < (i + 5).clamp(0, lines.length); j++) {
          if (lines[j].contains('semanticLabel')) {
            hasLabel = true;
            break;
          }
        }

        if (!hasLabel) {
          issues.add(QualityIssue(
            type: IssueType.noSemanticLabel,
            severity: IssueSeverity.warning,
            message: 'Image missing semanticLabel for accessibility.',
            filePath: filePath,
            line: i + 1,
            suggestion: 'Add semanticLabel parameter to describe the image.',
          ));
        }
      }

      // Check for IconButton without tooltip
      if (line.contains('IconButton(') && !line.contains('tooltip')) {
        issues.add(QualityIssue(
          type: IssueType.noSemanticLabel,
          severity: IssueSeverity.warning,
          message: 'IconButton missing tooltip for accessibility.',
          filePath: filePath,
          line: i + 1,
          suggestion: 'Add tooltip parameter to describe the button action.',
        ));
      }
    }

    return issues;
  }

  /// Finds state management anti-patterns.
  List<QualityIssue> _findStateManagementAntiPatterns(
      String filePath, List<String> lines) {
    final issues = <QualityIssue>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Calling setState in initState
      if (line.contains('initState') && i < lines.length - 10) {
        for (var j = i; j < (i + 10).clamp(0, lines.length); j++) {
          if (lines[j].contains('setState(')) {
            issues.add(QualityIssue(
              type: IssueType.stateManagementAntiPattern,
              severity: IssueSeverity.error,
              message: 'Calling setState in initState is an anti-pattern.',
              filePath: filePath,
              line: j + 1,
              suggestion: 'Set state directly in initState without setState.',
            ));
            break;
          }
        }
      }

      // Calling setState in build method
      if (line.contains('build(') && i < lines.length - 20) {
        for (var j = i; j < (i + 20).clamp(0, lines.length); j++) {
          if (lines[j].contains('setState(')) {
            issues.add(QualityIssue(
              type: IssueType.stateManagementAntiPattern,
              severity: IssueSeverity.error,
              message:
                  'Calling setState in build method causes infinite loops.',
              filePath: filePath,
              line: j + 1,
              suggestion: 'Move state updates outside the build method.',
            ));
            break;
          }
        }
      }
    }

    return issues;
  }

  /// Finds potential memory leaks (unclosed streams, controllers, etc).
  List<QualityIssue> _findPotentialMemoryLeaks(
      String filePath, List<String> lines) {
    final issues = <QualityIssue>[];

    var hasStreamController = false;
    var hasDispose = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check for StreamController declaration
      if (line.contains('StreamController') && !line.contains('//')) {
        hasStreamController = true;
      }

      // Check for dispose method
      if (line.contains('dispose()') ||
          line.contains('@override') &&
              lines.length > i + 1 &&
              lines[i + 1].contains('dispose')) {
        hasDispose = true;
      }
    }

    // If has StreamController but no dispose
    if (hasStreamController && !hasDispose) {
      issues.add(QualityIssue(
        type: IssueType.memoryLeak,
        severity: IssueSeverity.error,
        message: 'StreamController declared but dispose method not found.',
        filePath: filePath,
        line: 1,
        suggestion: 'Override dispose() and close the StreamController.',
      ));
    }

    return issues;
  }
}
