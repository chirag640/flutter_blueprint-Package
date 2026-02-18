/// Template caching layer for improved performance.
///
/// Caches rendered template files to avoid recomputation when generating
/// multiple projects or features with the same configuration.
library;

import 'dart:convert';

import '../../config/blueprint_config.dart';
import 'template_interface.dart';

/// A wrapper around [ITemplateRenderer] that caches rendered files.
///
/// Caches are stored in-memory for the duration of the process.
/// Cache key is derived from the template configuration hash.
///
/// Expected performance improvement: 20-30% for repeat operations.
class CachedTemplateRenderer implements ITemplateRenderer {
  CachedTemplateRenderer({
    required ITemplateRenderer delegate,
    Duration cacheDuration = const Duration(minutes: 30),
  })  : _delegate = delegate,
        _cacheDuration = cacheDuration;

  final ITemplateRenderer _delegate;
  final Duration _cacheDuration;

  /// Access the underlying delegate renderer.
  ITemplateRenderer get delegate => _delegate;

  /// In-memory cache: config hash -> (generatedFiles, timestamp)
  static final Map<String, _CacheEntry> _cache = {};

  /// Stats tracking for observability
  static int _hits = 0;
  static int _misses = 0;

  @override
  String get name => _delegate.name;

  @override
  String get description => _delegate.description;

  @override
  List<GeneratedFile> render(TemplateContext context) {
    final cacheKey = _computeCacheKey(context.config);

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;

      // Check if cache entry is still valid
      if (DateTime.now().difference(entry.timestamp) < _cacheDuration) {
        _hits++;
        return List<GeneratedFile>.from(entry.files);
      } else {
        // Cache expired, remove it
        _cache.remove(cacheKey);
      }
    }

    // Cache miss - render and store
    _misses++;
    final files = _delegate.render(context);

    _cache[cacheKey] = _CacheEntry(
      files: files,
      timestamp: DateTime.now(),
    );

    return files;
  }

  /// Computes a cache key from the configuration.
  ///
  /// The key is a hash of the relevant configuration properties
  /// that affect template rendering.
  String _computeCacheKey(BlueprintConfig config) {
    final keyData = {
      'appName': config.appName,
      'platforms': config.platforms.map((p) => p.name).toList()..sort(),
      'stateManagement': config.stateManagement.name,
      'includeTheme': config.includeTheme,
      'includeLocalization': config.includeLocalization,
      'includeEnv': config.includeEnv,
      'includeApi': config.includeApi,
      'includeTests': config.includeTests,
      'ciProvider': config.ciProvider.name,
      'includeHive': config.includeHive,
      'includePagination': config.includePagination,
      'includeAnalytics': config.includeAnalytics,
      'analyticsProvider': config.analyticsProvider.name,
      'includeWebSocket': config.includeWebSocket,
      'includePushNotifications': config.includePushNotifications,
      'includeMedia': config.includeMedia,
      'includeMaps': config.includeMaps,
      'includeSocialAuth': config.includeSocialAuth,
      'includeThemeMode': config.includeThemeMode,
      'includeAccessibility': config.includeAccessibility,
      // ApiConfig is complex, so we hash its key fields
      'apiConfig': {
        'successKey': config.apiConfig.successKey,
        'dataKey': config.apiConfig.dataKey,
        'tokenSource': config.apiConfig.tokenSource.name,
        'authHeaderName': config.apiConfig.authHeaderName,
      },
    };

    // Create a stable JSON representation and hash it
    final jsonString = jsonEncode(keyData);
    return jsonString.hashCode.toString();
  }

  /// Clears the entire cache.
  static void clearCache() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
  }

  /// Clears cache entries older than the specified duration.
  static void clearExpiredEntries(Duration maxAge) {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) {
      return now.difference(entry.timestamp) > maxAge;
    });
  }

  /// Gets cache statistics for observability.
  static CacheStats getStats() {
    return CacheStats(
      hits: _hits,
      misses: _misses,
      hitRate: _hits + _misses > 0 ? _hits / (_hits + _misses) : 0.0,
      size: _cache.length,
    );
  }
}

/// Internal cache entry storing rendered files and timestamp.
class _CacheEntry {
  _CacheEntry({
    required this.files,
    required this.timestamp,
  });

  final List<GeneratedFile> files;
  final DateTime timestamp;
}

/// Cache statistics for monitoring performance.
class CacheStats {
  const CacheStats({
    required this.hits,
    required this.misses,
    required this.hitRate,
    required this.size,
  });

  /// Number of cache hits
  final int hits;

  /// Number of cache misses
  final int misses;

  /// Hit rate (0.0 to 1.0)
  final double hitRate;

  /// Current number of entries in cache
  final int size;

  @override
  String toString() {
    return 'CacheStats(hits: $hits, misses: $misses, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, size: $size)';
  }
}
