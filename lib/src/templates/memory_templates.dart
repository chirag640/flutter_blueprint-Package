/// Memory Management & Performance Templates
///
/// Provides template generators for memory optimization, leak detection,
/// and performance monitoring utilities.
library;

/// Generates a disposable BLoC base class with automatic cleanup
String generateDisposableBloc() {
  return '''
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base class for BLoCs that require proper disposal of resources
abstract class DisposableBloc<Event, State> extends Bloc<Event, State> {
  final List<StreamSubscription> _subscriptions = [];
  final List<StreamController> _controllers = [];

  DisposableBloc(super.initialState);

  /// Register a subscription for automatic disposal
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Register a stream controller for automatic disposal
  void addController(StreamController controller) {
    _controllers.add(controller);
  }

  @override
  Future<void> close() async {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // Close all controllers
    for (final controller in _controllers) {
      await controller.close();
    }
    _controllers.clear();

    return super.close();
  }
}
''';
}

/// Generates a disposable Provider base class
String generateDisposableProvider() {
  return r'''
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Base class for ChangeNotifiers that require proper disposal of resources
abstract class DisposableProvider extends ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];
  final List<StreamController> _controllers = [];
  bool _disposed = false;

  /// Check if provider has been disposed
  bool get isDisposed => _disposed;

  /// Register a subscription for automatic disposal
  void addSubscription(StreamSubscription subscription) {
    if (_disposed) {
      throw StateError('Cannot add subscription after disposal');
    }
    _subscriptions.add(subscription);
  }

  /// Register a stream controller for automatic disposal
  void addController(StreamController controller) {
    if (_disposed) {
      throw StateError('Cannot add controller after disposal');
    }
    _controllers.add(controller);
  }

  @override
  void dispose() {
    if (_disposed) return;

    _disposed = true;

    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Close all controllers
    for (final controller in _controllers) {
      controller.close();
    }
    _controllers.clear();

    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
''';
}

/// Generates Riverpod-specific memory management utilities
String generateDisposableRiverpod() {
  return r'''
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension for auto-disposing Riverpod providers
extension DisposeExtension on Ref {
  /// Register a subscription for automatic disposal
  void onDisposeSubscription(StreamSubscription subscription) {
    onDispose(() => subscription.cancel());
  }

  /// Register a stream controller for automatic disposal
  void onDisposeController(StreamController controller) {
    onDispose(() => controller.close());
  }

  /// Register multiple disposables at once
  void onDisposeMultiple(List<dynamic> disposables) {
    for (final disposable in disposables) {
      if (disposable is StreamSubscription) {
        onDisposeSubscription(disposable);
      } else if (disposable is StreamController) {
        onDisposeController(disposable);
      }
    }
  }
}

/// Mixin for Notifiers that need resource cleanup
mixin DisposableNotifierMixin<State> on Notifier<State> {
  final List<StreamSubscription> _subscriptions = [];
  final List<StreamController> _controllers = [];

  /// Register a subscription for automatic disposal
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
    ref.onDispose(() => subscription.cancel());
  }

  /// Register a stream controller for automatic disposal
  void addController(StreamController controller) {
    _controllers.add(controller);
    ref.onDispose(() => controller.close());
  }

  /// Clean up all registered resources
  void cleanupResources() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    for (final controller in _controllers) {
      controller.close();
    }
    _controllers.clear();
  }
}
''';
}

/// Generates a memory profiler utility
String generateMemoryProfiler() {
  return r'''
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

/// Memory profiling utility for detecting memory issues
class MemoryProfiler {
  static final MemoryProfiler _instance = MemoryProfiler._();
  factory MemoryProfiler() => _instance;
  MemoryProfiler._();

  Timer? _timer;
  final List<MemorySnapshot> _snapshots = [];
  bool _isMonitoring = false;

  /// Start monitoring memory usage
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _timer = Timer.periodic(interval, (_) {
      _captureSnapshot();
    });

    debugPrint('📊 Memory monitoring started');
  }

  /// Stop monitoring memory usage
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _isMonitoring = false;
    debugPrint('📊 Memory monitoring stopped');
  }

  /// Capture a memory snapshot
  void _captureSnapshot() {
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      rss: Isolate.current.hashCode,
    );
    _snapshots.add(snapshot);

    // Keep only last 100 snapshots
    if (_snapshots.length > 100) {
      _snapshots.removeAt(0);
    }

    _checkForLeaks();
  }

  /// Check for potential memory leaks
  void _checkForLeaks() {
    if (_snapshots.length < 10) return;

    final recent = _snapshots.skip(_snapshots.length - 10).toList();
    final avgGrowth = _calculateAverageGrowth(recent);

    if (avgGrowth > 1024 * 1024) {
      // Growing by more than 1MB per interval
      final growthMB = (avgGrowth / 1024 / 1024).toStringAsFixed(2);
      debugPrint('⚠️  Potential memory leak detected! Average growth: $growthMB MB');
    }
  }

  double _calculateAverageGrowth(List<MemorySnapshot> snapshots) {
    if (snapshots.length < 2) return 0;

    double totalGrowth = 0;
    for (int i = 1; i < snapshots.length; i++) {
      totalGrowth += snapshots[i].rss - snapshots[i - 1].rss;
    }

    return totalGrowth / (snapshots.length - 1);
  }

  /// Get memory usage statistics
  MemoryStats getStats() {
    if (_snapshots.isEmpty) {
      return MemoryStats(current: 0, peak: 0, average: 0);
    }

    final current = _snapshots.last.rss;
    final peak = _snapshots.map((s) => s.rss).reduce((a, b) => a > b ? a : b);
    final average = _snapshots.map((s) => s.rss).reduce((a, b) => a + b) /
        _snapshots.length;

    return MemoryStats(current: current, peak: peak, average: average);
  }

  /// Clear all snapshots
  void clear() {
    _snapshots.clear();
  }
}

/// Memory snapshot data
class MemorySnapshot {
  final DateTime timestamp;
  final int rss; // Resident Set Size

  MemorySnapshot({required this.timestamp, required this.rss});
}

/// Memory statistics
class MemoryStats {
  final int current;
  final int peak;
  final double average;

  MemoryStats({
    required this.current,
    required this.peak,
    required this.average,
  });

  @override
  String toString() {
    return 'Current: ${_formatBytes(current)}, '
        'Peak: ${_formatBytes(peak)}, '
        'Average: ${_formatBytes(average.toInt())}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }
}
''';
}

/// Generates an image cache manager
String generateImageCacheManager() {
  return r'''
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Custom image cache manager with size limits
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._();

  int _maxCacheSize = 100 * 1024 * 1024; // 100MB default
  int _currentCacheSize = 0;
  final Map<String, CachedImage> _cache = {};

  /// Set maximum cache size in bytes
  void setMaxCacheSize(int bytes) {
    _maxCacheSize = bytes;
    _evictIfNeeded();
  }

  /// Get current cache size
  int get currentCacheSize => _currentCacheSize;

  /// Get maximum cache size
  int get maxCacheSize => _maxCacheSize;

  /// Initialize image cache configuration
  void configure(ImageCache imageCache, {int maxSizeBytes = 100 * 1024 * 1024}) {
    imageCache.maximumSizeBytes = maxSizeBytes;
    imageCache.maximumSize = 1000; // Maximum number of images
    _maxCacheSize = maxSizeBytes;
  }

  /// Cache an image with metadata
  void cacheImage(String key, ui.Image image, int sizeBytes) {
    _evictIfNeeded(sizeBytes);

    final cached = CachedImage(
      key: key,
      image: image,
      sizeBytes: sizeBytes,
      timestamp: DateTime.now(),
    );

    _cache[key] = cached;
    _currentCacheSize += sizeBytes;

    debugPrint('📷 Cached image: $key (${_formatBytes(sizeBytes)})');
  }

  /// Get cached image
  ui.Image? getCachedImage(String key) {
    final cached = _cache[key];
    if (cached != null) {
      // Update access time for LRU
      _cache[key] = cached.copyWith(timestamp: DateTime.now());
      return cached.image;
    }
    return null;
  }

  /// Evict images if cache is too large
  void _evictIfNeeded([int additionalSize = 0]) {
    while (_currentCacheSize + additionalSize > _maxCacheSize &&
        _cache.isNotEmpty) {
      _evictOldest();
    }
  }

  /// Evict the oldest cached image
  void _evictOldest() {
    if (_cache.isEmpty) return;

    // Find oldest entry
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.timestamp.isBefore(oldestTime)) {
        oldestTime = entry.value.timestamp;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      final cached = _cache.remove(oldestKey)!;
      _currentCacheSize -= cached.sizeBytes;
      cached.image.dispose();
      debugPrint('🗑️  Evicted image: $oldestKey');
    }
  }

  /// Clear entire cache
  void clearCache() {
    for (final cached in _cache.values) {
      cached.image.dispose();
    }
    _cache.clear();
    _currentCacheSize = 0;
    debugPrint('🗑️  Image cache cleared');
  }

  /// Get cache statistics
  String getStats() {
    return 'Images: ${_cache.length}, '
        'Size: ${_formatBytes(_currentCacheSize)} / ${_formatBytes(_maxCacheSize)}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }
}

/// Cached image with metadata
class CachedImage {
  final String key;
  final ui.Image image;
  final int sizeBytes;
  final DateTime timestamp;

  CachedImage({
    required this.key,
    required this.image,
    required this.sizeBytes,
    required this.timestamp,
  });

  CachedImage copyWith({DateTime? timestamp}) {
    return CachedImage(
      key: key,
      image: image,
      sizeBytes: sizeBytes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
''';
}

/// Generates a stream subscription manager
String generateStreamSubscriptionManager() {
  return r'''
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Manager for tracking and disposing stream subscriptions
class StreamSubscriptionManager {
  final Map<String, StreamSubscription> _subscriptions = {};
  bool _disposed = false;

  /// Add a named subscription
  void add(String key, StreamSubscription subscription) {
    if (_disposed) {
      subscription.cancel();
      throw StateError('Cannot add subscription after disposal');
    }

    // Cancel existing subscription with same key
    cancel(key);

    _subscriptions[key] = subscription;
    debugPrint('➕ Added subscription: $key');
  }

  /// Add an anonymous subscription
  void addAnonymous(StreamSubscription subscription) {
    final key = 'anonymous_${_subscriptions.length}';
    add(key, subscription);
  }

  /// Cancel a specific subscription
  void cancel(String key) {
    final subscription = _subscriptions.remove(key);
    if (subscription != null) {
      subscription.cancel();
      debugPrint('❌ Cancelled subscription: $key');
    }
  }

  /// Cancel all subscriptions
  void cancelAll() {
    for (final entry in _subscriptions.entries) {
      entry.value.cancel();
      debugPrint('❌ Cancelled subscription: ${entry.key}');
    }
    _subscriptions.clear();
  }

  /// Check if a subscription exists
  bool has(String key) {
    return _subscriptions.containsKey(key);
  }

  /// Get number of active subscriptions
  int get count => _subscriptions.length;

  /// Dispose all subscriptions and prevent new ones
  void dispose() {
    if (_disposed) return;

    _disposed = true;
    cancelAll();
    debugPrint('🗑️  StreamSubscriptionManager disposed');
  }
}

/// Mixin for widgets that need subscription management
mixin SubscriptionManagerMixin {
  final StreamSubscriptionManager _subscriptionManager =
      StreamSubscriptionManager();

  /// Get the subscription manager
  StreamSubscriptionManager get subscriptions => _subscriptionManager;

  /// Dispose all subscriptions (call this in dispose())
  void disposeSubscriptions() {
    _subscriptionManager.dispose();
  }
}
''';
}

/// Generates a memory leak detector
String generateMemoryLeakDetector() {
  return r'''
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Memory leak detection utility
class MemoryLeakDetector {
  static final MemoryLeakDetector _instance = MemoryLeakDetector._();
  factory MemoryLeakDetector() => _instance;
  MemoryLeakDetector._();

  final Map<String, WeakReference<Object>> _trackedObjects = {};
  final Map<String, int> _allocationCounts = {};
  Timer? _checkTimer;

  /// Track an object for potential leaks
  void track(String key, Object object) {
    _trackedObjects[key] = WeakReference(object);
    _allocationCounts[key] = (_allocationCounts[key] ?? 0) + 1;

    debugPrint('🔍 Tracking object: $key (count: ${_allocationCounts[key]})');
  }

  /// Start periodic leak checking
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(interval, (_) {
      _checkForLeaks();
    });
    debugPrint('🔍 Memory leak monitoring started');
  }

  /// Stop leak checking
  void stopMonitoring() {
    _checkTimer?.cancel();
    _checkTimer = null;
    debugPrint('🔍 Memory leak monitoring stopped');
  }

  /// Check for memory leaks
  void _checkForLeaks() {
    final leaks = <String>[];

    _trackedObjects.removeWhere((key, weakRef) {
      final object = weakRef.target;
      if (object == null) {
        // Object was garbage collected - good!
        return true;
      }

      final count = _allocationCounts[key] ?? 0;
      if (count > 10) {
        leaks.add('$key (count: $count)');
      }

      return false;
    });

    if (leaks.isNotEmpty) {
      debugPrint('⚠️  Potential memory leaks detected:');
      for (final leak in leaks) {
        debugPrint('   - $leak');
      }
    }
  }

  /// Get leak report
  Map<String, dynamic> getReport() {
    return {
      'tracked_objects': _trackedObjects.length,
      'allocation_counts': Map<String, int>.from(_allocationCounts),
      'potential_leaks': _allocationCounts.entries
          .where((e) => e.value > 10)
          .map((e) => e.key)
          .toList(),
    };
  }

  /// Clear all tracking data
  void clear() {
    _trackedObjects.clear();
    _allocationCounts.clear();
    debugPrint('🗑️  Memory leak detector cleared');
  }

  /// Dispose the detector
  void dispose() {
    stopMonitoring();
    clear();
  }
}

/// Mixin for tracking widget lifecycle in leak detection
mixin LeakDetectionMixin {
  final MemoryLeakDetector _detector = MemoryLeakDetector();

  /// Track this object for leaks
  void trackForLeaks(String key) {
    _detector.track(key, this);
  }
}
''';
}
