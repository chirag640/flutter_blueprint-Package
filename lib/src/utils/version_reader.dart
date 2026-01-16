import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Utility class for reading the package version from pubspec.yaml
/// Works for both development (local pubspec) and production (pub cache).
class VersionReader {
  static String? _cachedVersion;

  /// Current version - UPDATE THIS WHEN RELEASING A NEW VERSION
  /// This is the fallback when pubspec.yaml cannot be read (common in pub global)
  static const String _currentVersion = '1.7.5';

  /// Get the current package version
  /// Priority: 1) Cached value 2) Local pubspec 3) Pub cache 4) Fallback constant
  static Future<String> getVersion() async {
    // Return cached version if available
    if (_cachedVersion != null) {
      return _cachedVersion!;
    }

    // Try to read from pubspec.yaml (development mode)
    final localVersion = await _readLocalPubspec();
    if (localVersion != null) {
      _cachedVersion = localVersion;
      return localVersion;
    }

    // Try to read from pub cache (global activation mode)
    final cacheVersion = await _readFromPubCache();
    if (cacheVersion != null) {
      _cachedVersion = cacheVersion;
      return cacheVersion;
    }

    // Fallback to hardcoded version (must be kept in sync with pubspec.yaml)
    _cachedVersion = _currentVersion;
    return _currentVersion;
  }

  /// Read version from local pubspec.yaml (development mode)
  static Future<String?> _readLocalPubspec() async {
    try {
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
            return version;
          }
        }
      }
    } catch (_) {
      // Continue to next method
    }
    return null;
  }

  /// Read version from pub cache (global activation mode)
  /// The package is installed at: ~/.pub-cache/hosted/pub.dev/flutter_blueprint-X.Y.Z/
  static Future<String?> _readFromPubCache() async {
    try {
      // Get pub cache directory
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '';

      if (home.isEmpty) return null;

      // Standard pub cache locations
      final cacheLocations = [
        path.join(home, '.pub-cache', 'hosted', 'pub.dev'),
        path.join(home, '.pub-cache', 'hosted', 'pub.dartlang.org'),
        path.join(
            home, 'AppData', 'Local', 'Pub', 'Cache', 'hosted', 'pub.dev'),
        path.join(home, 'AppData', 'Local', 'Pub', 'Cache', 'hosted',
            'pub.dartlang.org'),
      ];

      for (final cacheDir in cacheLocations) {
        final dir = Directory(cacheDir);
        if (!await dir.exists()) continue;

        // Find flutter_blueprint packages
        await for (final entity in dir.list()) {
          if (entity is Directory) {
            final name = path.basename(entity.path);
            if (name.startsWith('flutter_blueprint-')) {
              // Extract version from directory name
              final version = name.replaceFirst('flutter_blueprint-', '');
              if (version.isNotEmpty && _isValidVersion(version)) {
                // Verify by reading pubspec
                final pubspecPath = path.join(entity.path, 'pubspec.yaml');
                final pubspecFile = File(pubspecPath);
                if (await pubspecFile.exists()) {
                  final content = await pubspecFile.readAsString();
                  final yaml = loadYaml(content) as Map;
                  final pubspecVersion = yaml['version'] as String?;
                  if (pubspecVersion != null) {
                    return pubspecVersion;
                  }
                }
                return version; // Fallback to directory name version
              }
            }
          }
        }
      }
    } catch (_) {
      // Fail silently
    }
    return null;
  }

  /// Validate version string format
  static bool _isValidVersion(String version) {
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+');
    return versionRegex.hasMatch(version);
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

  /// Force a specific version (useful for testing)
  static void setVersionForTesting(String version) {
    _cachedVersion = version;
  }
}
