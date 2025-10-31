/// Types of refactoring operations supported.
enum RefactoringType {
  addCaching,
  addOfflineSupport,
  migrateToRiverpod,
  migrateToBloc,
  addErrorHandling,
  addLogging,
  optimizePerformance,
  addTesting;

  String get label => switch (this) {
        RefactoringType.addCaching => 'Add Caching Layer',
        RefactoringType.addOfflineSupport => 'Add Offline Support',
        RefactoringType.migrateToRiverpod => 'Migrate to Riverpod',
        RefactoringType.migrateToBloc => 'Migrate to Bloc',
        RefactoringType.addErrorHandling => 'Add Error Handling',
        RefactoringType.addLogging => 'Add Logging',
        RefactoringType.optimizePerformance => 'Optimize Performance',
        RefactoringType.addTesting => 'Add Testing Infrastructure',
      };

  String get description => switch (this) {
        RefactoringType.addCaching =>
          'Add caching layer with automatic cache invalidation',
        RefactoringType.addOfflineSupport =>
          'Add offline support with local database sync',
        RefactoringType.migrateToRiverpod =>
          'Migrate state management from Provider to Riverpod',
        RefactoringType.migrateToBloc =>
          'Migrate state management to BLoC pattern',
        RefactoringType.addErrorHandling =>
          'Add comprehensive error handling throughout the app',
        RefactoringType.addLogging => 'Add structured logging and analytics',
        RefactoringType.optimizePerformance =>
          'Apply performance optimizations (const, lazy loading, etc)',
        RefactoringType.addTesting => 'Add unit and widget test infrastructure',
      };
}

/// Result of a refactoring operation.
class RefactoringResult {
  const RefactoringResult({
    required this.success,
    required this.filesModified,
    required this.filesCreated,
    required this.changes,
    this.error,
    this.warnings = const [],
  });

  final bool success;
  final List<String> filesModified;
  final List<String> filesCreated;
  final List<RefactoringChange> changes;
  final String? error;
  final List<String> warnings;

  int get totalFiles => filesModified.length + filesCreated.length;

  String get summary {
    if (!success) {
      return '❌ Refactoring failed: $error';
    }

    final buffer = StringBuffer();
    buffer.writeln('✅ Refactoring completed successfully!');
    buffer.writeln('');
    buffer.writeln('Summary:');
    buffer.writeln('  📝 Files modified: ${filesModified.length}');
    buffer.writeln('  ➕ Files created: ${filesCreated.length}');
    buffer.writeln('  🔧 Changes applied: ${changes.length}');

    if (warnings.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('⚠️  Warnings:');
      for (final warning in warnings) {
        buffer.writeln('  • $warning');
      }
    }

    return buffer.toString();
  }
}

/// Represents a single change made during refactoring.
class RefactoringChange {
  const RefactoringChange({
    required this.type,
    required this.description,
    required this.filePath,
    this.lineNumber,
  });

  final String type;
  final String description;
  final String filePath;
  final int? lineNumber;

  @override
  String toString() {
    final location = lineNumber != null ? ':$lineNumber' : '';
    return '  $type in $filePath$location\n    $description';
  }
}

/// Configuration for refactoring operations.
class RefactoringConfig {
  const RefactoringConfig({
    this.dryRun = false,
    this.preserveComments = true,
    this.createBackup = true,
    this.runTests = true,
    this.formatCode = true,
  });

  /// If true, only show what would be changed without modifying files.
  final bool dryRun;

  /// Preserve existing comments during refactoring.
  final bool preserveComments;

  /// Create backup files before modifying.
  final bool createBackup;

  /// Run tests after refactoring to verify nothing broke.
  final bool runTests;

  /// Format code after refactoring.
  final bool formatCode;
}
