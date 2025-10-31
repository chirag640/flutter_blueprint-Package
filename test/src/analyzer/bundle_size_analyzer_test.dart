import 'package:flutter_blueprint/src/analyzer/bundle_size_analyzer.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('BundleSizeAnalyzer', () {
    late Directory tempDir;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('flutter_blueprint_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('throws exception when build directory does not exist', () async {
      final analyzer = BundleSizeAnalyzer(projectPath: tempDir.path);

      expect(
        () => analyzer.analyze(),
        throwsA(isA<Exception>()),
      );
    });

    test('analyzes bundle size when build directory exists', () async {
      // Create mock project structure
      final libDir = Directory('${tempDir.path}/lib');
      await libDir.create(recursive: true);

      final mainFile = File('${tempDir.path}/lib/main.dart');
      await mainFile.writeAsString('''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Demo')),
      ),
    );
  }
}
''');

      // Create build directory
      final buildDir = Directory('${tempDir.path}/build');
      await buildDir.create(recursive: true);

      final analyzer = BundleSizeAnalyzer(projectPath: tempDir.path);
      final report = await analyzer.analyze();

      expect(report, isNotNull);
      expect(report.totalSize, greaterThanOrEqualTo(0));
    });

    test('analyzes code size correctly', () async {
      // Create mock lib directory
      final libDir = Directory('${tempDir.path}/lib');
      await libDir.create(recursive: true);

      final file1 = File('${tempDir.path}/lib/file1.dart');
      await file1.writeAsString('void main() {}');

      final file2 = File('${tempDir.path}/lib/file2.dart');
      await file2.writeAsString('class MyClass {}');

      final buildDir = Directory('${tempDir.path}/build');
      await buildDir.create();

      final analyzer = BundleSizeAnalyzer(projectPath: tempDir.path);
      final report = await analyzer.analyze();

      expect(report.codeSize.items, hasLength(2));
      expect(report.codeSize.totalBytes, greaterThan(0));
    });

    test('analyzes assets correctly', () async {
      // Create mock assets directory
      final assetsDir = Directory('${tempDir.path}/assets');
      await assetsDir.create(recursive: true);

      final imageDir = Directory('${tempDir.path}/assets/images');
      await imageDir.create();

      final imageFile = File('${tempDir.path}/assets/images/logo.png');
      await imageFile.writeAsBytes(List.filled(1024, 0)); // 1KB image

      final buildDir = Directory('${tempDir.path}/build');
      await buildDir.create();

      final libDir = Directory('${tempDir.path}/lib');
      await libDir.create();

      final analyzer = BundleSizeAnalyzer(projectPath: tempDir.path);
      final report = await analyzer.analyze();

      expect(report.assetsSize.items, hasLength(1));
      expect(report.assetsSize.totalBytes, equals(1024));
    });

    test('detects unused assets', () async {
      // Create assets that are not referenced in code
      final assetsDir = Directory('${tempDir.path}/assets');
      await assetsDir.create(recursive: true);

      final unusedImage = File('${tempDir.path}/assets/unused.png');
      await unusedImage.writeAsBytes(List.filled(500 * 1024, 0)); // 500KB

      // Create lib with no references to the asset
      final libDir = Directory('${tempDir.path}/lib');
      await libDir.create();

      final mainFile = File('${tempDir.path}/lib/main.dart');
      await mainFile.writeAsString('void main() {}');

      final buildDir = Directory('${tempDir.path}/build');
      await buildDir.create();

      final analyzer = BundleSizeAnalyzer(projectPath: tempDir.path);
      final report = await analyzer.analyze();

      // Should have a suggestion about unused assets
      final unusedSuggestions =
          report.suggestions.where((s) => s.title.contains('unused')).toList();

      expect(unusedSuggestions, isNotEmpty);
    });
  });

  group('BundleSizeReport', () {
    test('formats size correctly', () {
      final report = BundleSizeReport(
        totalSize: 8 * 1024 * 1024, // 8MB
        codeSize: BundleComponent(
            name: 'Code', totalBytes: 2 * 1024 * 1024, items: []),
        assetsSize: BundleComponent(
            name: 'Assets', totalBytes: 4 * 1024 * 1024, items: []),
        packagesSize: BundleComponent(
            name: 'Packages', totalBytes: 2 * 1024 * 1024, items: []),
        suggestions: [],
      );

      final formatted = report.toFormattedString();

      expect(formatted, contains('Bundle Size Analysis'));
      expect(formatted, contains('8.0 MB'));
      expect(formatted, contains('Code:'));
      expect(formatted, contains('Assets:'));
      expect(formatted, contains('Packages:'));
    });

    test('calculates percentages correctly', () {
      final report = BundleSizeReport(
        totalSize: 1000,
        codeSize: BundleComponent(name: 'Code', totalBytes: 250, items: []),
        assetsSize: BundleComponent(name: 'Assets', totalBytes: 500, items: []),
        packagesSize:
            BundleComponent(name: 'Packages', totalBytes: 250, items: []),
        suggestions: [],
      );

      final formatted = report.toFormattedString();

      expect(formatted, contains('(25%)'));
      expect(formatted, contains('(50%)'));
    });

    test('includes optimization suggestions', () {
      final suggestions = [
        OptimizationSuggestion(
          severity: SuggestionSeverity.warning,
          title: 'Test suggestion',
          description: 'Test description',
          potentialSavings: 1024,
        ),
      ];

      final report = BundleSizeReport(
        totalSize: 10000,
        codeSize: BundleComponent(name: 'Code', totalBytes: 5000, items: []),
        assetsSize:
            BundleComponent(name: 'Assets', totalBytes: 3000, items: []),
        packagesSize:
            BundleComponent(name: 'Packages', totalBytes: 2000, items: []),
        suggestions: suggestions,
      );

      final formatted = report.toFormattedString();

      expect(formatted, contains('Optimization Suggestions'));
      expect(formatted, contains('Test suggestion'));
      expect(formatted, contains('Potential savings'));
    });

    test('calculates total potential savings', () {
      final suggestions = [
        OptimizationSuggestion(
          severity: SuggestionSeverity.warning,
          title: 'Suggestion 1',
          description: 'Description 1',
          potentialSavings: 1000,
        ),
        OptimizationSuggestion(
          severity: SuggestionSeverity.warning,
          title: 'Suggestion 2',
          description: 'Description 2',
          potentialSavings: 2000,
        ),
      ];

      final report = BundleSizeReport(
        totalSize: 10000,
        codeSize: BundleComponent(name: 'Code', totalBytes: 5000, items: []),
        assetsSize:
            BundleComponent(name: 'Assets', totalBytes: 3000, items: []),
        packagesSize:
            BundleComponent(name: 'Packages', totalBytes: 2000, items: []),
        suggestions: suggestions,
      );

      expect(report.potentialSavings, equals(3000));
    });
  });

  group('OptimizationSuggestion', () {
    test('has correct severity icons', () {
      final error = OptimizationSuggestion(
        severity: SuggestionSeverity.error,
        title: 'Error',
        description: 'Desc',
        potentialSavings: 0,
      );

      final warning = OptimizationSuggestion(
        severity: SuggestionSeverity.warning,
        title: 'Warning',
        description: 'Desc',
        potentialSavings: 0,
      );

      final info = OptimizationSuggestion(
        severity: SuggestionSeverity.info,
        title: 'Info',
        description: 'Desc',
        potentialSavings: 0,
      );

      expect(error.severityIcon, equals('❌'));
      expect(warning.severityIcon, equals('⚠️'));
      expect(info.severityIcon, equals('✅'));
    });

    test('includes items list', () {
      final suggestion = OptimizationSuggestion(
        severity: SuggestionSeverity.warning,
        title: 'Test',
        description: 'Desc',
        potentialSavings: 1000,
        items: ['item1', 'item2', 'item3'],
      );

      expect(suggestion.items, hasLength(3));
      expect(suggestion.items, contains('item1'));
    });
  });
}
