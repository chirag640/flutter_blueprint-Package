/// Represents a code quality issue found during analysis.
class QualityIssue {
  const QualityIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.filePath,
    required this.line,
    this.column,
    this.suggestion,
  });

  /// The type/category of the issue.
  final IssueType type;

  /// How severe the issue is.
  final IssueSeverity severity;

  /// Description of the issue.
  final String message;

  /// File where the issue was found.
  final String filePath;

  /// Line number where the issue occurs.
  final int line;

  /// Optional column number.
  final int? column;

  /// Optional suggestion for fixing the issue.
  final String? suggestion;

  @override
  String toString() {
    final location = column != null ? '$line:$column' : '$line';
    final prefix = severity == IssueSeverity.error
        ? '❌'
        : severity == IssueSeverity.warning
            ? '⚠️'
            : 'ℹ️';

    final buffer = StringBuffer();
    buffer.writeln('$prefix $filePath:$location');
    buffer.writeln('   ${type.label}: $message');
    if (suggestion != null) {
      buffer.writeln('   💡 Suggestion: $suggestion');
    }

    return buffer.toString();
  }
}

/// Types of code quality issues.
enum IssueType {
  magicNumber,
  missingErrorHandling,
  undocumentedApi,
  missingConst,
  noSemanticLabel,
  inefficientBuild,
  stateManagementAntiPattern,
  securityVulnerability,
  memoryLeak,
  deprecatedApi;

  String get label => switch (this) {
        IssueType.magicNumber => 'Magic Number',
        IssueType.missingErrorHandling => 'Missing Error Handling',
        IssueType.undocumentedApi => 'Undocumented API',
        IssueType.missingConst => 'Missing Const',
        IssueType.noSemanticLabel => 'Missing Semantic Label',
        IssueType.inefficientBuild => 'Inefficient Build',
        IssueType.stateManagementAntiPattern => 'State Management Anti-Pattern',
        IssueType.securityVulnerability => 'Security Vulnerability',
        IssueType.memoryLeak => 'Potential Memory Leak',
        IssueType.deprecatedApi => 'Deprecated API',
      };
}

/// Severity levels for issues.
enum IssueSeverity {
  error,
  warning,
  info;

  String get label => switch (this) {
        IssueSeverity.error => 'Error',
        IssueSeverity.warning => 'Warning',
        IssueSeverity.info => 'Info',
      };
}

/// Report containing all found issues.
class AnalysisReport {
  const AnalysisReport({
    required this.issues,
    this.filesAnalyzed = 0,
    this.analysisTimeMs = 0,
  });

  final List<QualityIssue> issues;
  final int filesAnalyzed;
  final int analysisTimeMs;

  /// Get issues by severity.
  List<QualityIssue> get errors =>
      issues.where((i) => i.severity == IssueSeverity.error).toList();

  List<QualityIssue> get warnings =>
      issues.where((i) => i.severity == IssueSeverity.warning).toList();

  List<QualityIssue> get infos =>
      issues.where((i) => i.severity == IssueSeverity.info).toList();

  /// Get issues by type.
  List<QualityIssue> getByType(IssueType type) =>
      issues.where((i) => i.type == type).toList();

  /// Get issues for a specific file.
  List<QualityIssue> getByFile(String filePath) =>
      issues.where((i) => i.filePath == filePath).toList();

  /// Check if analysis passed based on severity threshold.
  bool passed({IssueSeverity maxSeverity = IssueSeverity.warning}) {
    return switch (maxSeverity) {
      IssueSeverity.error => errors.isEmpty,
      IssueSeverity.warning => errors.isEmpty && warnings.isEmpty,
      IssueSeverity.info => issues.isEmpty,
    };
  }

  /// Generate a summary string.
  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('📊 Analysis Report');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Files analyzed: $filesAnalyzed');
    buffer.writeln('Analysis time: ${analysisTimeMs}ms');
    buffer.writeln('');
    buffer.writeln('Issues found:');
    buffer.writeln('  ❌ Errors: ${errors.length}');
    buffer.writeln('  ⚠️  Warnings: ${warnings.length}');
    buffer.writeln('  ℹ️  Info: ${infos.length}');
    buffer.writeln('  Total: ${issues.length}');

    return buffer.toString();
  }
}
