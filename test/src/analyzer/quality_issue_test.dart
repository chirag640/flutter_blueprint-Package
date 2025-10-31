import 'package:test/test.dart';
import 'package:flutter_blueprint/src/analyzer/quality_issue.dart';

void main() {
  group('QualityIssue', () {
    test('creates issue with all properties', () {
      final issue = QualityIssue(
        type: IssueType.magicNumber,
        severity: IssueSeverity.warning,
        message: 'Magic number 42 found',
        filePath: '/path/to/file.dart',
        line: 10,
        column: 5,
        suggestion: 'Use a const variable',
      );

      expect(issue.type, IssueType.magicNumber);
      expect(issue.severity, IssueSeverity.warning);
      expect(issue.message, 'Magic number 42 found');
      expect(issue.filePath, '/path/to/file.dart');
      expect(issue.line, 10);
      expect(issue.column, 5);
      expect(issue.suggestion, 'Use a const variable');
    });

    test('toString includes severity emoji', () {
      final error = QualityIssue(
        type: IssueType.missingErrorHandling,
        severity: IssueSeverity.error,
        message: 'No error handling',
        filePath: '/path/to/file.dart',
        line: 10,
      );

      final warning = QualityIssue(
        type: IssueType.magicNumber,
        severity: IssueSeverity.warning,
        message: 'Magic number',
        filePath: '/path/to/file.dart',
        line: 10,
      );

      final info = QualityIssue(
        type: IssueType.undocumentedApi,
        severity: IssueSeverity.info,
        message: 'No docs',
        filePath: '/path/to/file.dart',
        line: 10,
      );

      expect(error.toString(), contains('❌'));
      expect(warning.toString(), contains('⚠️'));
      expect(info.toString(), contains('ℹ️'));
    });

    test('toString includes suggestion when provided', () {
      final issue = QualityIssue(
        type: IssueType.magicNumber,
        severity: IssueSeverity.warning,
        message: 'Magic number',
        filePath: '/path/to/file.dart',
        line: 10,
        suggestion: 'Use const',
      );

      expect(issue.toString(), contains('💡 Suggestion:'));
      expect(issue.toString(), contains('Use const'));
    });
  });

  group('IssueType', () {
    test('has correct labels', () {
      expect(IssueType.magicNumber.label, 'Magic Number');
      expect(IssueType.missingErrorHandling.label, 'Missing Error Handling');
      expect(IssueType.undocumentedApi.label, 'Undocumented API');
      expect(IssueType.missingConst.label, 'Missing Const');
      expect(IssueType.noSemanticLabel.label, 'Missing Semantic Label');
    });
  });

  group('IssueSeverity', () {
    test('has correct labels', () {
      expect(IssueSeverity.error.label, 'Error');
      expect(IssueSeverity.warning.label, 'Warning');
      expect(IssueSeverity.info.label, 'Info');
    });
  });

  group('AnalysisReport', () {
    test('categorizes issues by severity', () {
      final issues = [
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.error,
          message: 'Error 1',
          filePath: '/file.dart',
          line: 1,
        ),
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.warning,
          message: 'Warning 1',
          filePath: '/file.dart',
          line: 2,
        ),
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.info,
          message: 'Info 1',
          filePath: '/file.dart',
          line: 3,
        ),
      ];

      final report = AnalysisReport(issues: issues);

      expect(report.errors.length, 1);
      expect(report.warnings.length, 1);
      expect(report.infos.length, 1);
    });

    test('groups issues by type', () {
      final issues = [
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.warning,
          message: 'Magic 1',
          filePath: '/file.dart',
          line: 1,
        ),
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.warning,
          message: 'Magic 2',
          filePath: '/file.dart',
          line: 2,
        ),
        QualityIssue(
          type: IssueType.undocumentedApi,
          severity: IssueSeverity.info,
          message: 'No docs',
          filePath: '/file.dart',
          line: 3,
        ),
      ];

      final report = AnalysisReport(issues: issues);

      expect(report.getByType(IssueType.magicNumber).length, 2);
      expect(report.getByType(IssueType.undocumentedApi).length, 1);
    });

    test('groups issues by file', () {
      final issues = [
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.warning,
          message: 'Issue 1',
          filePath: '/file1.dart',
          line: 1,
        ),
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.warning,
          message: 'Issue 2',
          filePath: '/file1.dart',
          line: 2,
        ),
        QualityIssue(
          type: IssueType.magicNumber,
          severity: IssueSeverity.warning,
          message: 'Issue 3',
          filePath: '/file2.dart',
          line: 1,
        ),
      ];

      final report = AnalysisReport(issues: issues);

      expect(report.getByFile('/file1.dart').length, 2);
      expect(report.getByFile('/file2.dart').length, 1);
    });

    test('passed() checks severity threshold', () {
      final errorsOnly = AnalysisReport(
        issues: [
          QualityIssue(
            type: IssueType.magicNumber,
            severity: IssueSeverity.error,
            message: 'Error',
            filePath: '/file.dart',
            line: 1,
          ),
        ],
      );

      final warningsOnly = AnalysisReport(
        issues: [
          QualityIssue(
            type: IssueType.magicNumber,
            severity: IssueSeverity.warning,
            message: 'Warning',
            filePath: '/file.dart',
            line: 1,
          ),
        ],
      );

      final infosOnly = AnalysisReport(
        issues: [
          QualityIssue(
            type: IssueType.magicNumber,
            severity: IssueSeverity.info,
            message: 'Info',
            filePath: '/file.dart',
            line: 1,
          ),
        ],
      );

      // Error threshold - only pass if no errors
      expect(errorsOnly.passed(maxSeverity: IssueSeverity.error), false);
      expect(warningsOnly.passed(maxSeverity: IssueSeverity.error), true);
      expect(infosOnly.passed(maxSeverity: IssueSeverity.error), true);

      // Warning threshold - pass if no errors or warnings
      expect(errorsOnly.passed(maxSeverity: IssueSeverity.warning), false);
      expect(warningsOnly.passed(maxSeverity: IssueSeverity.warning), false);
      expect(infosOnly.passed(maxSeverity: IssueSeverity.warning), true);

      // Info threshold - pass if no issues at all
      expect(errorsOnly.passed(maxSeverity: IssueSeverity.info), false);
      expect(warningsOnly.passed(maxSeverity: IssueSeverity.info), false);
      expect(infosOnly.passed(maxSeverity: IssueSeverity.info), false);
    });

    test('generates summary with counts', () {
      final report = AnalysisReport(
        issues: [
          QualityIssue(
            type: IssueType.magicNumber,
            severity: IssueSeverity.error,
            message: 'Error',
            filePath: '/file.dart',
            line: 1,
          ),
          QualityIssue(
            type: IssueType.magicNumber,
            severity: IssueSeverity.warning,
            message: 'Warning',
            filePath: '/file.dart',
            line: 2,
          ),
        ],
        filesAnalyzed: 5,
        analysisTimeMs: 1234,
      );

      final summary = report.summary;

      expect(summary, contains('Files analyzed: 5'));
      expect(summary, contains('Analysis time: 1234ms'));
      expect(summary, contains('Errors: 1'));
      expect(summary, contains('Warnings: 1'));
      expect(summary, contains('Total: 2'));
    });
  });
}
