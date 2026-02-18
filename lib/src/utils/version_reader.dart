import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Utility class for reading the package version from pubspec.yaml
/// Works for both development (local pubspec) and production (pub cache).
class VersionReader {
  static String? _cachedVersion;

  /// Current version - UPDATE THIS WHEN RELEASING A NEW VERSION
  /// This is the fallback when pubspec.yaml cannot be read (common in pub global)
  static const String _currentVersion = '2.0.2';

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

  /// Read version from pub cache (global activation mode).
  /// The package is installed at: ~/.pub-cache/hosted/pub.dev/flutter_blueprint-X.Y.Z/
  ///
  /// Collects ALL matching flutter_blueprint-* directories and returns the
  /// **highest semver** among them. This prevents an old directory (e.g.
  /// flutter_blueprint-0.2.0-dev.2) from being returned ahead of 2.0.1 simply
  /// because directory.list() happens to yield it first.
  static Future<String?> _readFromPubCache() async {
    try {
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

      // Collect every flutter_blueprint version found across all cache dirs.
      final candidates = <String>[];

      for (final cacheDir in cacheLocations) {
        final dir = Directory(cacheDir);
        if (!await dir.exists()) continue;

        await for (final entity in dir.list()) {
          if (entity is! Directory) continue;
          final name = path.basename(entity.path);
          if (!name.startsWith('flutter_blueprint-')) continue;

          final version = name.replaceFirst('flutter_blueprint-', '');
          if (version.isEmpty || !_isValidVersion(version)) continue;

          // Prefer the version string from the pubspec inside the directory.
          try {
            final pubspecFile =
                File(path.join(entity.path, 'pubspec.yaml'));
            if (await pubspecFile.exists()) {
              final content = await pubspecFile.readAsString();
              final yaml = loadYaml(content) as Map;
              final pubspecVersion = yaml['version'] as String?;
              if (pubspecVersion != null && pubspecVersion.isNotEmpty) {
                candidates.add(pubspecVersion);
                continue;
              }
            }
          } catch (_) {}

          candidates.add(version);
        }
      }

      if (candidates.isEmpty) return null;

      // Return the highest semver among all candidates.
      candidates.sort(_compareVersions);
      return candidates.last;
    } catch (_) {
      // Fail silently
    }
    return null;
  }

  /// Compare two dotted-version strings (e.g. "2.0.1" vs "0.2.0-dev.2").
  /// Pre-release suffixes (anything after `-`) sort lower than the release.
  static int _compareVersions(String a, String b) {
    // Strip pre-release suffix for numeric comparison, but keep track of it.
    String stripPre(String v) => v.split('-').first;
    bool hasPre(String v) => v.contains('-');

    final aParts = stripPre(a).split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final bParts = stripPre(b).split('.').map((s) => int.tryParse(s) ?? 0).toList();

    final len = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < len; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }

    // Equal numeric parts: release > pre-release
    if (hasPre(a) && !hasPre(b)) return -1;
    if (!hasPre(a) && hasPre(b)) return 1;
    return a.compareTo(b);
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
