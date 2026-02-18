import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import 'version_reader.dart';

class UpdateChecker {
  static const String _pubApiUrl = 'https://pub.dev/api/packages/';
  static const String _packageName = 'flutter_blueprint';
  static const String _cacheKey = 'update_check_cache';
  static const Duration _checkInterval = Duration(days: 1);
  static const Duration _requestTimeout = Duration(seconds: 5);

  /// Check for updates, respecting the check interval to avoid excessive API calls.
  ///
  /// Caching strategy (modelled on npm's update-notifier):
  ///   • The cache stores ONLY the latest version from pub.dev + a timestamp.
  ///   • The current (running) version is NEVER stored in the cache — it is
  ///     always read fresh from the live binary at display time via
  ///     [VersionReader.getVersion()]. This prevents the classic "stale current
  ///     version" bug where the banner shows the pre-upgrade version even after
  ///     the user has already updated.
  ///   • On cache hit, we still compare against the live current version, so
  ///     if the user upgraded between two runs the banner disappears correctly.
  ///   • Suppressed on CI environments.
  Future<UpdateInfo?> checkForUpdates() async {
    // Suppress on CI — update notifications are noise in automated pipelines.
    if (_isRunningOnCi()) return null;

    // Always read the live current version from the running binary.
    final currentVersionStr = await VersionReader.getVersion();

    // Try to load cached latest version first.
    final cachedResult = await _loadCachedResult();

    if (cachedResult != null) {
      final cacheAge = DateTime.now().difference(cachedResult.timestamp);

      // Cache still valid — compare live current against cached latest.
      if (cacheAge < _checkInterval) {
        return _buildUpdateInfo(currentVersionStr, cachedResult.latestVersion);
      }
    }

    // Cache is expired or doesn't exist — fetch from pub.dev.
    try {
      final latestVersionStr = await _getLatestVersion();
      if (latestVersionStr == null) {
        // Network error — fall back to cached latest if available, still
        // comparing against the live current version (not the cached one).
        if (cachedResult != null) {
          return _buildUpdateInfo(
              currentVersionStr, cachedResult.latestVersion);
        }
        return null;
      }

      // Persist ONLY the latest version + current timestamp.
      await _saveCachedResult(_CachedResult(
        latestVersion: latestVersionStr,
        timestamp: DateTime.now(),
      ));

      return _buildUpdateInfo(currentVersionStr, latestVersionStr);
    } catch (e) {
      // Fail silently — update check is a best-effort feature.
      if (cachedResult != null) {
        return _buildUpdateInfo(currentVersionStr, cachedResult.latestVersion);
      }
      return null;
    }
  }

  /// Returns an [UpdateInfo] only when [latestVersionStr] is strictly newer
  /// than [currentVersionStr]. Returns null otherwise (up-to-date).
  UpdateInfo? _buildUpdateInfo(
      String currentVersionStr, String latestVersionStr) {
    try {
      final current = Version.parse(currentVersionStr);
      final latest = Version.parse(latestVersionStr);
      if (latest > current) {
        return UpdateInfo(
          latestVersion: latestVersionStr,
          currentVersion: currentVersionStr,
        );
      }
    } catch (_) {
      // Malformed version string — suppress banner.
    }
    return null;
  }

  /// Clears the cache file if the cached latestVersion is older than or equal
  /// to the currently-running version.
  ///
  /// Call this once at startup (before the background check is kicked off).
  /// It handles the scenario where the user just upgraded the tool: the cache
  /// still holds the old "latest" which is now behind the current binary, so
  /// we delete it to force a fresh pub.dev fetch on this (or the next) run.
  Future<void> clearCacheIfStale() async {
    try {
      final cachedResult = await _loadCachedResult();
      if (cachedResult == null) return;

      final currentVersionStr = await VersionReader.getVersion();
      final current = Version.parse(currentVersionStr);
      final cached = Version.parse(cachedResult.latestVersion);

      // Cache is stale if current >= cached latest (user has already upgraded
      // to or beyond what was reported as "latest").
      if (current >= cached) {
        final file = await _getCacheFile();
        if (await file.exists()) await file.delete();
      }
    } catch (_) {
      // Fail silently — never break the CLI over cache housekeeping.
    }
  }

  /// Matches the same env-var set used by `is-ci` (npm) and `melos`.
  bool _isRunningOnCi() {
    final env = Platform.environment;
    return env.containsKey('CI') ||
        env.containsKey('CONTINUOUS_INTEGRATION') ||
        env.containsKey('BUILD_NUMBER') || // Jenkins / TeamCity
        env.containsKey('RUN_ID') || // GitHub Actions
        env.containsKey('GITHUB_ACTIONS') ||
        env.containsKey('GITLAB_CI') ||
        env.containsKey('CIRCLECI') ||
        env.containsKey('TRAVIS') ||
        env.containsKey('TF_BUILD'); // Azure Pipelines
  }

  /// Get the latest version from pub.dev API
  Future<String?> _getLatestVersion() async {
    try {
      final response = await http
          .get(Uri.parse('$_pubApiUrl$_packageName'))
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // The pub.dev API returns the latest version in the 'latest' object
        final latest = json['latest'] as Map<String, dynamic>?;
        return latest?['version'] as String?;
      }
    } catch (e) {
      // Fail silently if there's no network or other issues
      // This includes timeout exceptions
    }
    return null;
  }

  /// Get cache directory for storing last check time
  Future<Directory> _getCacheDir() async {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    final cacheDir = Directory(path.join(home, '.flutter_blueprint'));

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// Get the file path for storing cached update result
  Future<File> _getCacheFile() async {
    final cacheDir = await _getCacheDir();
    return File(path.join(cacheDir.path, _cacheKey));
  }

  /// Load cached update result
  Future<_CachedResult?> _loadCachedResult() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return _CachedResult.fromJson(json);
      }
    } catch (e) {
      // If we can't read the cache, just return null
    }
    return null;
  }

  /// Save cached update result
  Future<void> _saveCachedResult(_CachedResult result) async {
    try {
      final file = await _getCacheFile();
      await file.writeAsString(jsonEncode(result.toJson()));
    } catch (e) {
      // If we can't write the cache, fail silently
      // Update checking is a nice-to-have feature
    }
  }
}

/// Internal cached result structure.
/// Stores ONLY the latest version from pub.dev + the check timestamp.
/// The current version is intentionally NOT cached — it is always read
/// from the live binary at display time to avoid stale-version banners.
class _CachedResult {
  final String latestVersion;
  final DateTime timestamp;

  _CachedResult({
    required this.latestVersion,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'latestVersion': latestVersion,
      };

  factory _CachedResult.fromJson(Map<String, dynamic> json) {
    // Support old cache format that stored { updateInfo: { latestVersion, currentVersion } }
    // so existing installs don't crash on the first run after upgrading.
    String? latest = json['latestVersion'] as String?;
    if (latest == null) {
      final updateInfo = json['updateInfo'] as Map<String, dynamic>?;
      latest = updateInfo?['latestVersion'] as String?;
    }
    if (latest == null) {
      throw const FormatException('Missing latestVersion in cache');
    }
    return _CachedResult(
      latestVersion: latest,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;

  UpdateInfo({required this.latestVersion, required this.currentVersion});
}
