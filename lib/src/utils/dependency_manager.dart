import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'logger.dart';

/// Manages dependency versions by fetching latest versions from pub.dev.
///
/// This class provides smart dependency version management by automatically
/// checking pub.dev for the latest stable versions of packages. It helps
/// developers avoid manual version hunting and ensures they're using
/// up-to-date, secure dependencies.
class DependencyManager {
  DependencyManager({
    Logger? logger,
    HttpClient? httpClient,
  })  : _logger = logger ?? Logger(),
        _httpClient = httpClient ?? HttpClient();

  final Logger _logger;
  final HttpClient _httpClient;

  /// Fetches the latest versions for a list of packages from pub.dev.
  ///
  /// Returns a map of package names to their latest version strings in
  /// caret notation (e.g., '^6.1.1'). If a package cannot be fetched,
  /// it falls back to 'latest' as a placeholder.
  ///
  /// Example:
  /// ```dart
  /// final versions = await manager.getLatestVersions(['provider', 'dio']);
  /// // Returns: {'provider': '^6.1.1', 'dio': '^5.4.0'}
  /// ```
  Future<Map<String, String>> getLatestVersions(
    List<String> packages,
  ) async {
    final versions = <String, String>{};
    final futures = <Future<void>>[];

    for (final package in packages) {
      futures.add(_fetchPackageVersion(package, versions));
    }

    // Fetch all versions in parallel for speed
    await Future.wait(futures);

    return versions;
  }

  /// Fetches a single package version from pub.dev.
  Future<void> _fetchPackageVersion(
    String package,
    Map<String, String> versions,
  ) async {
    try {
      final url = Uri.parse('https://pub.dev/api/packages/$package');
      final request = await _httpClient.getUrl(url);

      // Set timeout to avoid hanging
      request.headers.set('User-Agent', 'flutter_blueprint/0.1.0');

      final response = await request.close().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;

        final latestVersion = data['latest']?['version'] as String?;
        if (latestVersion != null) {
          versions[package] = '^$latestVersion';
          _logger.debug('✓ $package: ^$latestVersion');
        } else {
          versions[package] = 'latest';
          _logger.debug('⚠ $package: version not found, using "latest"');
        }
      } else {
        versions[package] = 'latest';
        _logger
            .debug('⚠ $package: HTTP ${response.statusCode}, using "latest"');
      }
    } catch (e) {
      _logger.debug('⚠ Failed to fetch version for $package: $e');
      versions[package] = 'latest'; // Fallback
    }
  }

  /// Gets recommended dependency versions based on state management choice.
  ///
  /// Returns a map of package names to version constraints that are
  /// compatible with each other and the specified state management solution.
  Future<Map<String, String>> getRecommendedDependencies({
    required String stateManagement,
    required bool includeApi,
    required bool includeLocalization,
  }) async {
    final packages = <String>[];

    // Core dependencies
    packages.addAll([
      'flutter_lints',
      'go_router',
    ]);

    // State management packages
    switch (stateManagement.toLowerCase()) {
      case 'provider':
        packages.add('provider');
        break;
      case 'riverpod':
        packages.addAll(['flutter_riverpod', 'riverpod_annotation']);
        break;
      case 'bloc':
        packages.addAll(['flutter_bloc', 'bloc', 'equatable']);
        break;
    }

    // Optional packages
    if (includeApi) {
      packages.addAll(['dio', 'pretty_dio_logger']);
    }

    if (includeLocalization) {
      packages.add('intl');
    }

    _logger.info('🔍 Fetching latest dependency versions from pub.dev...');
    _logger.info('');

    final versions = await getLatestVersions(packages);

    _logger.info('');
    _logger
        .success('✅ Successfully fetched ${versions.length} package versions');

    return versions;
  }

  /// Validates that dependency versions are compatible with each other.
  ///
  /// This is a placeholder for future implementation of dependency
  /// conflict detection and resolution.
  Future<List<String>> validateDependencyCompatibility(
    Map<String, String> dependencies,
  ) async {
    final warnings = <String>[];

    // Future: Implement actual compatibility checking
    // For now, this is a placeholder that could check for known conflicts

    return warnings;
  }

  /// Compares current versions with latest available versions.
  ///
  /// Useful for upgrade suggestions in existing projects.
  Future<Map<String, DependencyUpdate>> checkForUpdates(
    Map<String, String> currentDependencies,
  ) async {
    final updates = <String, DependencyUpdate>{};
    final packages = currentDependencies.keys.toList();

    _logger.info('🔍 Checking for dependency updates...');

    final latestVersions = await getLatestVersions(packages);

    for (final package in packages) {
      final current = currentDependencies[package] ?? '';
      final latest = latestVersions[package] ?? '';

      if (latest != 'latest' && current != latest) {
        final currentVersion = current.replaceAll('^', '').replaceAll('~', '');
        final latestVersion = latest.replaceAll('^', '').replaceAll('~', '');

        updates[package] = DependencyUpdate(
          package: package,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          updateAvailable: currentVersion != latestVersion,
        );
      }
    }

    return updates;
  }

  /// Closes the HTTP client to free resources.
  void close() {
    _httpClient.close();
  }
}

/// Represents a dependency update information.
class DependencyUpdate {
  const DependencyUpdate({
    required this.package,
    required this.currentVersion,
    required this.latestVersion,
    required this.updateAvailable,
  });

  final String package;
  final String currentVersion;
  final String latestVersion;
  final bool updateAvailable;

  @override
  String toString() {
    if (updateAvailable) {
      return '$package: $currentVersion → $latestVersion ⚠️ Update available';
    }
    return '$package: $currentVersion ✅ Latest';
  }
}
