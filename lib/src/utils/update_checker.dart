import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

class UpdateChecker {
  static const String _pubApiUrl = 'https://pub.dev/api/packages/';
  static const String _packageName = 'flutter_blueprint';
  static const String _lastCheckKey = 'last_update_check';
  static const Duration _checkInterval = Duration(days: 1);
  static const Duration _requestTimeout = Duration(seconds: 5);

  // This should be updated with each new version
  static const String _currentVersion = '0.8.4';

  /// Check for updates, respecting the check interval to avoid excessive API calls
  Future<UpdateInfo?> checkForUpdates() async {
    // Use a simple file-based cache for CLI tool instead of shared_preferences
    final lastCheckTime = await _getLastCheckTime();

    if (lastCheckTime != null) {
      if (DateTime.now().difference(lastCheckTime) < _checkInterval) {
        return null; // Too soon to check again
      }
    }

    try {
      final latestVersionStr = await _getLatestVersion();
      if (latestVersionStr == null) return null;

      final currentVersion = Version.parse(_currentVersion);
      final latestVersion = Version.parse(latestVersionStr);

      // Save the check time
      await _saveLastCheckTime(DateTime.now());

      if (latestVersion > currentVersion) {
        return UpdateInfo(
          latestVersion: latestVersionStr,
          currentVersion: _currentVersion,
        );
      }
    } catch (e) {
      // Fail silently - update check shouldn't break the CLI
      return null;
    }

    return null;
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

  /// Get the file path for storing last check time
  Future<File> _getCacheFile() async {
    final cacheDir = await _getCacheDir();
    return File(path.join(cacheDir.path, _lastCheckKey));
  }

  /// Read the last check time from cache file
  Future<DateTime?> _getLastCheckTime() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return DateTime.parse(content.trim());
      }
    } catch (e) {
      // If we can't read the file, just return null
    }
    return null;
  }

  /// Save the last check time to cache file
  Future<void> _saveLastCheckTime(DateTime time) async {
    try {
      final file = await _getCacheFile();
      await file.writeAsString(time.toIso8601String());
    } catch (e) {
      // If we can't write the file, fail silently
      // Update checking is a nice-to-have feature
    }
  }
}

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;

  UpdateInfo({required this.latestVersion, required this.currentVersion});
}
