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
  /// Now caches the actual update result, not just the check time.
  /// This avoids unnecessary HTTP calls and file I/O within the check interval.
  Future<UpdateInfo?> checkForUpdates() async {
    // Try to load cached update info first
    final cachedResult = await _loadCachedResult();

    if (cachedResult != null) {
      final cacheAge = DateTime.now().difference(cachedResult.timestamp);

      // If cache is still valid, return the cached update info immediately
      if (cacheAge < _checkInterval) {
        return cachedResult.updateInfo;
      }
    }

    // Cache is expired or doesn't exist - perform actual check
    try {
      final latestVersionStr = await _getLatestVersion();
      if (latestVersionStr == null) {
        // Network error - keep returning old cache if available
        return cachedResult?.updateInfo;
      }

      // Get current version from pubspec.yaml
      final currentVersionStr = await VersionReader.getVersion();
      final currentVersion = Version.parse(currentVersionStr);
      final latestVersion = Version.parse(latestVersionStr);

      UpdateInfo? updateInfo;
      if (latestVersion > currentVersion) {
        updateInfo = UpdateInfo(
          latestVersion: latestVersionStr,
          currentVersion: currentVersionStr,
        );
      }

      // Cache the result (even if null) to avoid repeated checks
      await _saveCachedResult(_CachedResult(
        updateInfo: updateInfo,
        timestamp: DateTime.now(),
      ));

      return updateInfo;
    } catch (e) {
      // Fail silently - update check shouldn't break the CLI
      // Return old cache if available
      return cachedResult?.updateInfo;
    }
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

/// Internal cached result structure
class _CachedResult {
  final UpdateInfo? updateInfo;
  final DateTime timestamp;

  _CachedResult({
    required this.updateInfo,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'updateInfo': updateInfo == null
            ? null
            : {
                'latestVersion': updateInfo!.latestVersion,
                'currentVersion': updateInfo!.currentVersion,
              },
      };

  factory _CachedResult.fromJson(Map<String, dynamic> json) {
    final updateInfoJson = json['updateInfo'] as Map<String, dynamic>?;
    return _CachedResult(
      timestamp: DateTime.parse(json['timestamp'] as String),
      updateInfo: updateInfoJson == null
          ? null
          : UpdateInfo(
              latestVersion: updateInfoJson['latestVersion'] as String,
              currentVersion: updateInfoJson['currentVersion'] as String,
            ),
    );
  }
}

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;

  UpdateInfo({required this.latestVersion, required this.currentVersion});
}
