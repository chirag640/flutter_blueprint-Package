/// Analyzer for bundle size optimization and analysis
library;

import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';

/// Analyzes Flutter app bundle size and provides optimization suggestions
class BundleSizeAnalyzer {
  final String _projectPath;
  final Logger _logger;

  BundleSizeAnalyzer({
    required String projectPath,
    Logger? logger,
  })  : _projectPath = projectPath,
        _logger = logger ?? Logger();

  /// Analyzes the bundle size and returns a detailed report
  Future<BundleSizeReport> analyze() async {
    _logger.info('🔍 Analyzing bundle size...');

    final buildDir = Directory(path.join(_projectPath, 'build'));
    if (!await buildDir.exists()) {
      throw Exception(
        'Build directory not found. Please build your app first with:\n'
        '  flutter build apk (for Android)\n'
        '  flutter build ios (for iOS)\n'
        '  flutter build web (for Web)',
      );
    }

    // Analyze different components
    final codeSize = await _analyzeCode();
    final assetsSize = await _analyzeAssets();
    final packagesSize = await _analyzePackages();

    final totalSize =
        codeSize.totalBytes + assetsSize.totalBytes + packagesSize.totalBytes;

    // Generate optimization suggestions
    final suggestions = await _generateOptimizationSuggestions(
      codeSize,
      assetsSize,
      packagesSize,
    );

    return BundleSizeReport(
      totalSize: totalSize,
      codeSize: codeSize,
      assetsSize: assetsSize,
      packagesSize: packagesSize,
      suggestions: suggestions,
    );
  }

  /// Analyzes code size
  Future<BundleComponent> _analyzeCode() async {
    final libDir = Directory(path.join(_projectPath, 'lib'));
    if (!await libDir.exists()) {
      return BundleComponent(name: 'Code', totalBytes: 0, items: []);
    }

    int totalSize = 0;
    final items = <BundleItem>[];

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final size = await entity.length();
        totalSize += size;
        items.add(BundleItem(
          name: path.relative(entity.path, from: _projectPath),
          bytes: size,
          type: 'Dart Code',
        ));
      }
    }

    // Sort by size descending
    items.sort((a, b) => b.bytes.compareTo(a.bytes));

    return BundleComponent(
      name: 'Code',
      totalBytes: totalSize,
      items: items,
    );
  }

  /// Analyzes assets size
  Future<BundleComponent> _analyzeAssets() async {
    final assetsDir = Directory(path.join(_projectPath, 'assets'));
    if (!await assetsDir.exists()) {
      return BundleComponent(name: 'Assets', totalBytes: 0, items: []);
    }

    int totalSize = 0;
    final items = <BundleItem>[];

    await for (final entity in assetsDir.list(recursive: true)) {
      if (entity is File) {
        final size = await entity.length();
        totalSize += size;
        items.add(BundleItem(
          name: path.relative(entity.path, from: _projectPath),
          bytes: size,
          type: _getAssetType(entity.path),
        ));
      }
    }

    // Sort by size descending
    items.sort((a, b) => b.bytes.compareTo(a.bytes));

    return BundleComponent(
      name: 'Assets',
      totalBytes: totalSize,
      items: items,
    );
  }

  /// Analyzes package dependencies size (approximation)
  Future<BundleComponent> _analyzePackages() async {
    final pubspecLock = File(path.join(_projectPath, 'pubspec.lock'));
    if (!await pubspecLock.exists()) {
      return BundleComponent(name: 'Packages', totalBytes: 0, items: []);
    }

    // This is an approximation based on .dart_tool/package_config.json
    final packageConfigFile = File(
      path.join(_projectPath, '.dart_tool', 'package_config.json'),
    );

    if (!await packageConfigFile.exists()) {
      return BundleComponent(name: 'Packages', totalBytes: 0, items: []);
    }

    int totalSize = 0;
    final items = <BundleItem>[];

    // Read package directories from pub cache
    final pubCacheDir = _getPubCacheDir();
    if (pubCacheDir != null && await pubCacheDir.exists()) {
      final content = await pubspecLock.readAsString();
      final packageNames = _extractPackageNames(content);

      for (final packageName in packageNames) {
        final packageSize =
            await _estimatePackageSize(pubCacheDir, packageName);
        if (packageSize > 0) {
          totalSize += packageSize;
          items.add(BundleItem(
            name: packageName,
            bytes: packageSize,
            type: 'Package',
          ));
        }
      }
    }

    // Sort by size descending
    items.sort((a, b) => b.bytes.compareTo(a.bytes));

    return BundleComponent(
      name: 'Packages',
      totalBytes: totalSize,
      items: items,
    );
  }

  /// Gets the pub cache directory
  Directory? _getPubCacheDir() {
    final pubCache = Platform.environment['PUB_CACHE'];
    if (pubCache != null) {
      return Directory(pubCache);
    }

    // Default locations
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null) {
        return Directory(path.join(appData, 'Pub', 'Cache'));
      }
    } else {
      final home = Platform.environment['HOME'];
      if (home != null) {
        return Directory(path.join(home, '.pub-cache'));
      }
    }

    return null;
  }

  /// Extracts package names from pubspec.lock content
  List<String> _extractPackageNames(String content) {
    final packages = <String>[];
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.endsWith(':') && !line.startsWith('#')) {
        final packageName = line.substring(0, line.length - 1).trim();
        if (packageName.isNotEmpty &&
            packageName != 'packages' &&
            packageName != 'sdks') {
          packages.add(packageName);
        }
      }
    }

    return packages;
  }

  /// Estimates package size (approximation based on lib folder)
  Future<int> _estimatePackageSize(
      Directory pubCache, String packageName) async {
    try {
      final hostedDir = Directory(path.join(pubCache.path, 'hosted'));
      if (!await hostedDir.exists()) return 0;

      // Search for package in hosted directory
      await for (final pubSource in hostedDir.list()) {
        if (pubSource is Directory) {
          await for (final packageDir in pubSource.list()) {
            if (packageDir is Directory &&
                path.basename(packageDir.path).startsWith(packageName)) {
              final libDir = Directory(path.join(packageDir.path, 'lib'));
              if (await libDir.exists()) {
                return await _calculateDirectorySize(libDir);
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore errors in package size estimation
    }

    return 0;
  }

  /// Calculates total size of a directory
  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        try {
          totalSize += await entity.length();
        } catch (e) {
          // Ignore files we can't access
        }
      }
    }

    return totalSize;
  }

  /// Gets asset type from file extension
  String _getAssetType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.gif':
      case '.webp':
        return 'Image';
      case '.svg':
        return 'Vector';
      case '.ttf':
      case '.otf':
        return 'Font';
      case '.json':
        return 'Data';
      case '.mp3':
      case '.wav':
      case '.ogg':
        return 'Audio';
      case '.mp4':
      case '.mov':
        return 'Video';
      default:
        return 'Other';
    }
  }

  /// Generates optimization suggestions
  Future<List<OptimizationSuggestion>> _generateOptimizationSuggestions(
    BundleComponent codeSize,
    BundleComponent assetsSize,
    BundleComponent packagesSize,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    // Check for unused assets
    final unusedAssets = await _findUnusedAssets(assetsSize);
    if (unusedAssets.isNotEmpty) {
      final totalSize =
          unusedAssets.fold<int>(0, (sum, item) => sum + item.bytes);
      suggestions.add(OptimizationSuggestion(
        severity: SuggestionSeverity.warning,
        title: '${unusedAssets.length} unused assets found',
        description: 'Remove unused assets to reduce bundle size',
        potentialSavings: totalSize,
        items: unusedAssets.map((a) => a.name).toList(),
      ));
    }

    // Check for large unoptimized images
    final largeImages = _findLargeImages(assetsSize);
    if (largeImages.isNotEmpty) {
      final totalSize =
          largeImages.fold<int>(0, (sum, item) => sum + item.bytes);
      suggestions.add(OptimizationSuggestion(
        severity: SuggestionSeverity.warning,
        title: '${largeImages.length} large images not optimized',
        description: 'Compress images or use WebP format',
        potentialSavings: (totalSize * 0.5).toInt(), // Assume 50% compression
        items: largeImages.map((i) => i.name).toList(),
      ));
    }

    // Check package tree-shaking
    if (packagesSize.totalBytes > 1024 * 1024) {
      // > 1MB
      suggestions.add(OptimizationSuggestion(
        severity: SuggestionSeverity.info,
        title: 'All packages tree-shaken',
        description: 'Flutter automatically tree-shakes packages',
        potentialSavings: 0,
      ));
    }

    // Check for large packages that could be lazy-loaded
    final largePackages =
        packagesSize.items.where((p) => p.bytes > 500 * 1024).toList();
    if (largePackages.isNotEmpty) {
      suggestions.add(OptimizationSuggestion(
        severity: SuggestionSeverity.info,
        title: 'Consider lazy-loading large packages',
        description: 'Defer loading of non-critical packages',
        potentialSavings: 0,
        items: largePackages.map((p) => p.name).toList(),
      ));
    }

    return suggestions;
  }

  /// Finds unused assets by checking references in code
  Future<List<BundleItem>> _findUnusedAssets(BundleComponent assetsSize) async {
    final unused = <BundleItem>[];

    // Read all dart files to find asset references
    final codeFiles = <String>[];
    final libDir = Directory(path.join(_projectPath, 'lib'));
    if (await libDir.exists()) {
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          codeFiles.add(await entity.readAsString());
        }
      }
    }

    final allCode = codeFiles.join('\n');

    for (final asset in assetsSize.items) {
      final assetName = path.basename(asset.name);
      // Simple check: if asset name doesn't appear in any code
      if (!allCode.contains(assetName)) {
        unused.add(asset);
      }
    }

    return unused;
  }

  /// Finds large images that could be optimized
  List<BundleItem> _findLargeImages(BundleComponent assetsSize) {
    return assetsSize.items
        .where((item) =>
            item.type == 'Image' &&
            item.bytes > 500 * 1024 && // > 500KB
            !item.name.endsWith('.webp'))
        .toList();
  }
}

/// Represents the complete bundle size analysis report
class BundleSizeReport {
  final int totalSize;
  final BundleComponent codeSize;
  final BundleComponent assetsSize;
  final BundleComponent packagesSize;
  final List<OptimizationSuggestion> suggestions;

  const BundleSizeReport({
    required this.totalSize,
    required this.codeSize,
    required this.assetsSize,
    required this.packagesSize,
    required this.suggestions,
  });

  /// Calculates potential savings from all suggestions
  int get potentialSavings {
    return suggestions.fold<int>(0, (sum, s) => sum + s.potentialSavings);
  }

  /// Formats the report as a string
  String toFormattedString() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Bundle Size Analysis');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Total: ${_formatSize(totalSize)}');
    buffer.writeln();

    buffer.writeln('Breakdown:');
    buffer.writeln(
        '  - Code:      ${_formatSize(codeSize.totalBytes)} (${_percentage(codeSize.totalBytes, totalSize)}%)');
    buffer.writeln(
        '  - Assets:    ${_formatSize(assetsSize.totalBytes)} (${_percentage(assetsSize.totalBytes, totalSize)}%)');
    buffer.writeln(
        '  - Packages:  ${_formatSize(packagesSize.totalBytes)} (${_percentage(packagesSize.totalBytes, totalSize)}%)');
    buffer.writeln();

    if (suggestions.isNotEmpty) {
      buffer.writeln('💡 Optimization Suggestions:');
      for (var i = 0; i < suggestions.length; i++) {
        final suggestion = suggestions[i];
        buffer.writeln(
            '  ${i + 1}. ${suggestion.severityIcon}  ${suggestion.title}');
        if (suggestion.items != null && suggestion.items!.isNotEmpty) {
          buffer.writeln('     ${suggestion.description}');
          final displayItems = suggestion.items!.take(3).toList();
          for (final item in displayItems) {
            buffer.writeln('       - $item');
          }
          if (suggestion.items!.length > 3) {
            buffer
                .writeln('       ... and ${suggestion.items!.length - 3} more');
          }
        } else {
          buffer.writeln('     ${suggestion.description}');
        }
      }
      buffer.writeln();

      if (potentialSavings > 0) {
        buffer.writeln(
            'Potential savings: ${_formatSize(potentialSavings)} (${_percentage(potentialSavings, totalSize)}%)');
      }
    }

    return buffer.toString();
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

/// Represents a component of the bundle
class BundleComponent {
  final String name;
  final int totalBytes;
  final List<BundleItem> items;

  const BundleComponent({
    required this.name,
    required this.totalBytes,
    required this.items,
  });
}

/// Represents an individual item in the bundle
class BundleItem {
  final String name;
  final int bytes;
  final String type;

  const BundleItem({
    required this.name,
    required this.bytes,
    required this.type,
  });
}

/// Represents an optimization suggestion
class OptimizationSuggestion {
  final SuggestionSeverity severity;
  final String title;
  final String description;
  final int potentialSavings;
  final List<String>? items;

  const OptimizationSuggestion({
    required this.severity,
    required this.title,
    required this.description,
    required this.potentialSavings,
    this.items,
  });

  String get severityIcon {
    switch (severity) {
      case SuggestionSeverity.error:
        return '❌';
      case SuggestionSeverity.warning:
        return '⚠️';
      case SuggestionSeverity.info:
        return '✅';
    }
  }
}

/// Severity levels for optimization suggestions
enum SuggestionSeverity {
  error,
  warning,
  info,
}
