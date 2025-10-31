import 'package:test/test.dart';
import 'package:flutter_blueprint/src/refactoring/refactoring_types.dart';

void main() {
  group('RefactoringType', () {
    test('has correct labels', () {
      expect(RefactoringType.addCaching.label, 'Add Caching Layer');
      expect(RefactoringType.addOfflineSupport.label, 'Add Offline Support');
      expect(RefactoringType.migrateToRiverpod.label, 'Migrate to Riverpod');
      expect(RefactoringType.migrateToBloc.label, 'Migrate to Bloc');
      expect(RefactoringType.addErrorHandling.label, 'Add Error Handling');
      expect(RefactoringType.addLogging.label, 'Add Logging');
      expect(RefactoringType.optimizePerformance.label, 'Optimize Performance');
      expect(RefactoringType.addTesting.label, 'Add Testing Infrastructure');
    });

    test('has descriptions', () {
      for (final type in RefactoringType.values) {
        expect(type.description.isNotEmpty, true);
      }
    });
  });

  group('RefactoringResult', () {
    test('creates successful result', () {
      final result = RefactoringResult(
        success: true,
        filesModified: ['/file1.dart', '/file2.dart'],
        filesCreated: ['/new_file.dart'],
        changes: const [],
      );

      expect(result.success, true);
      expect(result.filesModified.length, 2);
      expect(result.filesCreated.length, 1);
      expect(result.totalFiles, 3);
      expect(result.error, null);
    });

    test('creates failed result with error', () {
      final result = RefactoringResult(
        success: false,
        filesModified: const [],
        filesCreated: const [],
        changes: const [],
        error: 'Something went wrong',
      );

      expect(result.success, false);
      expect(result.error, 'Something went wrong');
    });

    test('summary shows success message', () {
      final result = RefactoringResult(
        success: true,
        filesModified: ['/file1.dart'],
        filesCreated: ['/new_file.dart'],
        changes: const [
          RefactoringChange(
            type: 'Create',
            description: 'Added cache service',
            filePath: '/cache.dart',
          ),
        ],
      );

      final summary = result.summary;

      expect(summary, contains('✅'));
      expect(summary, contains('Files modified: 1'));
      expect(summary, contains('Files created: 1'));
      expect(summary, contains('Changes applied: 1'));
    });

    test('summary shows error message on failure', () {
      final result = RefactoringResult(
        success: false,
        filesModified: const [],
        filesCreated: const [],
        changes: const [],
        error: 'File not found',
      );

      final summary = result.summary;

      expect(summary, contains('❌'));
      expect(summary, contains('failed'));
      expect(summary, contains('File not found'));
    });

    test('summary includes warnings if present', () {
      final result = RefactoringResult(
        success: true,
        filesModified: const [],
        filesCreated: const [],
        changes: const [],
        warnings: const ['Warning 1', 'Warning 2'],
      );

      final summary = result.summary;

      expect(summary, contains('⚠️'));
      expect(summary, contains('Warnings:'));
      expect(summary, contains('Warning 1'));
      expect(summary, contains('Warning 2'));
    });
  });

  group('RefactoringChange', () {
    test('creates change with all properties', () {
      const change = RefactoringChange(
        type: 'Create',
        description: 'Added new file',
        filePath: '/path/to/file.dart',
        lineNumber: 42,
      );

      expect(change.type, 'Create');
      expect(change.description, 'Added new file');
      expect(change.filePath, '/path/to/file.dart');
      expect(change.lineNumber, 42);
    });

    test('toString includes line number when present', () {
      const changeWithLine = RefactoringChange(
        type: 'Modify',
        description: 'Updated method',
        filePath: '/file.dart',
        lineNumber: 10,
      );

      const changeWithoutLine = RefactoringChange(
        type: 'Create',
        description: 'Added file',
        filePath: '/file.dart',
      );

      expect(changeWithLine.toString(), contains(':10'));
      expect(changeWithoutLine.toString(), isNot(contains(':')));
    });
  });

  group('RefactoringConfig', () {
    test('has sensible defaults', () {
      const config = RefactoringConfig();

      expect(config.dryRun, false);
      expect(config.preserveComments, true);
      expect(config.createBackup, true);
      expect(config.runTests, true);
      expect(config.formatCode, true);
    });

    test('can customize all options', () {
      const config = RefactoringConfig(
        dryRun: true,
        preserveComments: false,
        createBackup: false,
        runTests: false,
        formatCode: false,
      );

      expect(config.dryRun, true);
      expect(config.preserveComments, false);
      expect(config.createBackup, false);
      expect(config.runTests, false);
      expect(config.formatCode, false);
    });
  });
}
