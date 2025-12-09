import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Utility class for reading the package version from pubspec.yaml
class VersionReader {
  static String? _cachedVersion;

  /// Get the current package version from pubspec.yaml
  /// Returns a cached value after first read for performance
  static Future<String> getVersion() async {
    // Return cached version if available
    if (_cachedVersion != null) {
      return _cachedVersion!;
    }

    try {
      // Find pubspec.yaml relative to this file
      final currentFile = Platform.script.toFilePath();
      final packageRoot = _findPackageRoot(currentFile);

      if (packageRoot != null) {
        final pubspecPath = path.join(packageRoot, 'pubspec.yaml');
        final pubspecFile = File(pubspecPath);

        if (await pubspecFile.exists()) {
          final content = await pubspecFile.readAsString();
          final yaml = loadYaml(content) as Map;
          final version = yaml['version'] as String?;

          if (version != null && version.isNotEmpty) {
            _cachedVersion = version;
            return version;
          }
        }
      }
    } catch (_) {
      // Fail silently and return fallback
    }

    // Fallback version if unable to read from pubspec.yaml
    const fallbackVersion = '1.7.1';
    _cachedVersion = fallbackVersion;
    return fallbackVersion;
  }

  /// Find the package root directory by traversing upward from current file
  static String? _findPackageRoot(String currentPath) {
    var dir = Directory(path.dirname(currentPath));

    // Traverse up to 10 levels max
    for (var i = 0; i < 10; i++) {
      final pubspecPath = path.join(dir.path, 'pubspec.yaml');
      if (File(pubspecPath).existsSync()) {
        return dir.path;
      }

      final parent = dir.parent;
      if (parent.path == dir.path) {
        // Reached filesystem root
        break;
      }
      dir = parent;
    }

    return null;
  }

  /// Reset the cached version (useful for testing)
  static void resetCache() {
    _cachedVersion = null;
  }
}
