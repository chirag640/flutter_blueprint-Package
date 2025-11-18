import '../config/blueprint_config.dart';

/// Generates Hive database initialization code
String generateHiveDatabase(BlueprintConfig config) {
  return """import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger.dart';

/// Hive database manager for offline-first architecture
class HiveDatabase {
  HiveDatabase._();
  
  static final HiveDatabase _instance = HiveDatabase._();
  static HiveDatabase get instance => _instance;
  
  bool _initialized = false;
  
  /// Initialize Hive database
  /// Call this before runApp() in main.dart
  Future<void> init() async {
    if (_initialized) {
      AppLogger.warning('Hive already initialized', 'HiveDatabase');
      return;
    }
    
    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();
      
      // For production: use app documents directory
      // final appDir = await getApplicationDocumentsDirectory();
      // Hive.init(appDir.path);
      
      // Register adapters here
      // Example: Hive.registerAdapter(UserModelAdapter());
      
      _initialized = true;
      AppLogger.success('Hive database initialized', 'HiveDatabase');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Hive', e, stackTrace, 'HiveDatabase');
      rethrow;
    }
  }
  
  /// Open a box (cache)
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!_initialized) {
      throw StateError('Hive not initialized. Call HiveDatabase.instance.init() first.');
    }
    
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }
      
      final box = await Hive.openBox<T>(boxName);
      AppLogger.debug('Opened box: \$boxName', 'HiveDatabase');
      return box;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to open box: \$boxName', e, stackTrace, 'HiveDatabase');
      rethrow;
    }
  }
  
  /// Open a lazy box (loads data on-demand)
  Future<LazyBox<T>> openLazyBox<T>(String boxName) async {
    if (!_initialized) {
      throw StateError('Hive not initialized. Call HiveDatabase.instance.init() first.');
    }
    
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.lazyBox<T>(boxName);
      }
      
      final box = await Hive.openLazyBox<T>(boxName);
      AppLogger.debug('Opened lazy box: \$boxName', 'HiveDatabase');
      return box;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to open lazy box: \$boxName', e, stackTrace, 'HiveDatabase');
      rethrow;
    }
  }
  
  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
        AppLogger.debug('Closed box: \$boxName', 'HiveDatabase');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to close box: \$boxName', e, stackTrace, 'HiveDatabase');
    }
  }
  
  /// Close all boxes
  Future<void> closeAll() async {
    try {
      await Hive.close();
      _initialized = false;
      AppLogger.info('Closed all Hive boxes', 'HiveDatabase');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to close Hive boxes', e, stackTrace, 'HiveDatabase');
    }
  }
  
  /// Delete a box (clears all data)
  Future<void> deleteBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      AppLogger.info('Deleted box: \$boxName', 'HiveDatabase');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete box: \$boxName', e, stackTrace, 'HiveDatabase');
    }
  }
  
  /// Check if a box exists
  bool boxExists(String boxName) {
    return Hive.isBoxOpen(boxName);
  }
  
  /// Get box size in bytes
  int getBoxSize(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      return 0;
    }
    
    try {
      final box = Hive.box(boxName);
      // Estimate: each entry ~= 100 bytes (rough estimate)
      return box.length * 100;
    } catch (e) {
      return 0;
    }
  }
  
  /// Clear all data from all boxes
  Future<void> clearAllData() async {
    try {
      await Hive.deleteFromDisk();
      _initialized = false;
      AppLogger.warning('Cleared all Hive data', 'HiveDatabase');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear Hive data', e, stackTrace, 'HiveDatabase');
    }
  }
}
""";
}

/// Generates Hive cache manager with TTL and strategies
String generateCacheManager(BlueprintConfig config) {
  return """import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger.dart';
import 'hive_database.dart';

/// Cache strategies for managing data
enum CacheStrategy {
  /// Time-To-Live: data expires after specified duration
  ttl,
  
  /// Least Recently Used: removes least recently used items
  lru,
  
  /// Size-based: removes items when cache exceeds size limit
  sizeBased,
  
  /// No eviction: data persists until manually cleared
  noEviction,
}

/// Cache entry with metadata
class CacheEntry<T> {
  const CacheEntry({
    required this.data,
    required this.timestamp,
    this.ttl,
  });
  
  final T data;
  final DateTime timestamp;
  final Duration? ttl;
  
  /// Check if cache entry is expired
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }
  
  /// Time remaining until expiration
  Duration? get timeRemaining {
    if (ttl == null) return null;
    final elapsed = DateTime.now().difference(timestamp);
    final remaining = ttl! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'ttl': ttl?.inSeconds,
  };
  
  factory CacheEntry.fromJson(Map<String, dynamic> json, T data) {
    return CacheEntry(
      data: data,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: json['ttl'] != null ? Duration(seconds: json['ttl'] as int) : null,
    );
  }
}

/// Manages caching with various strategies
class CacheManager<T> {
  CacheManager({
    required this.boxName,
    this.strategy = CacheStrategy.ttl,
    this.defaultTTL = const Duration(hours: 24),
    this.maxSize = 1000,
  });
  
  final String boxName;
  final CacheStrategy strategy;
  final Duration defaultTTL;
  final int maxSize;
  
  Box<Map>? _box;
  
  /// Initialize cache
  Future<void> init() async {
    _box = await HiveDatabase.instance.openBox<Map>(boxName);
    AppLogger.debug('Cache initialized: \$boxName', 'CacheManager');
    
    // Clean expired entries on init
    if (strategy == CacheStrategy.ttl) {
      await _cleanExpiredEntries();
    }
  }
  
  /// Store data in cache
  Future<void> put(
    String key,
    T data, {
    Duration? ttl,
  }) async {
    _ensureInitialized();
    
    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? (strategy == CacheStrategy.ttl ? defaultTTL : null),
    );
    
    await _box!.put(key, entry.toJson());
    AppLogger.debug('Cached: \$key', 'CacheManager');
    
    // Apply cache strategy
    await _applyCacheStrategy();
  }
  
  /// Get data from cache
  T? get(String key) {
    _ensureInitialized();
    
    final json = _box!.get(key) as Map<String, dynamic>?;
    if (json == null) return null;
    
    final entry = CacheEntry.fromJson(json, json['data'] as T);
    
    // Check if expired
    if (entry.isExpired) {
      _box!.delete(key);
      AppLogger.debug('Cache expired: \$key', 'CacheManager');
      return null;
    }
    
    // Update access time for LRU
    if (strategy == CacheStrategy.lru) {
      _updateAccessTime(key);
    }
    
    return entry.data;
  }
  
  /// Check if key exists and is not expired
  bool has(String key) {
    return get(key) != null;
  }
  
  /// Remove item from cache
  Future<void> remove(String key) async {
    _ensureInitialized();
    await _box!.delete(key);
    AppLogger.debug('Removed from cache: \$key', 'CacheManager');
  }
  
  /// Clear all cache
  Future<void> clear() async {
    _ensureInitialized();
    await _box!.clear();
    AppLogger.info('Cache cleared: \$boxName', 'CacheManager');
  }
  
  /// Get all cached keys
  List<String> get keys {
    _ensureInitialized();
    return _box!.keys.cast<String>().toList();
  }
  
  /// Get cache size
  int get size {
    _ensureInitialized();
    return _box!.length;
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStats() {
    _ensureInitialized();
    
    int expiredCount = 0;
    int validCount = 0;
    
    for (final key in _box!.keys) {
      final json = _box!.get(key) as Map<String, dynamic>?;
      if (json == null) continue;
      
      final entry = CacheEntry.fromJson(json, json['data']);
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }
    
    return {
      'boxName': boxName,
      'strategy': strategy.name,
      'totalEntries': _box!.length,
      'validEntries': validCount,
      'expiredEntries': expiredCount,
      'maxSize': maxSize,
      'defaultTTL': defaultTTL.inSeconds,
    };
  }
  
  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      throw StateError('Cache not initialized. Call init() first.');
    }
  }
  
  Future<void> _cleanExpiredEntries() async {
    final keysToRemove = <String>[];
    
    for (final key in _box!.keys) {
      final json = _box!.get(key) as Map<String, dynamic>?;
      if (json == null) continue;
      
      final entry = CacheEntry.fromJson(json, json['data']);
      if (entry.isExpired) {
        keysToRemove.add(key.toString());
      }
    }
    
    for (final key in keysToRemove) {
      await _box!.delete(key);
    }
    
    if (keysToRemove.isNotEmpty) {
      AppLogger.info(
        'Cleaned \${keysToRemove.length} expired entries',
        'CacheManager',
      );
    }
  }
  
  Future<void> _applyCacheStrategy() async {
    switch (strategy) {
      case CacheStrategy.ttl:
        await _cleanExpiredEntries();
        break;
      case CacheStrategy.lru:
        await _evictLRU();
        break;
      case CacheStrategy.sizeBased:
        await _evictBySize();
        break;
      case CacheStrategy.noEviction:
        // Do nothing
        break;
    }
  }
  
  Future<void> _evictLRU() async {
    if (_box!.length <= maxSize) return;
    
    final entries = <String, DateTime>{};
    
    for (final key in _box!.keys) {
      final json = _box!.get(key) as Map<String, dynamic>?;
      if (json == null) continue;
      
      final entry = CacheEntry.fromJson(json, json['data']);
      entries[key.toString()] = entry.timestamp;
    }
    
    // Sort by timestamp (oldest first)
    final sorted = entries.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // Remove oldest entries
    final toRemove = sorted.take(_box!.length - maxSize);
    for (final entry in toRemove) {
      await _box!.delete(entry.key);
    }
    
    AppLogger.debug('Evicted \${toRemove.length} LRU entries', 'CacheManager');
  }
  
  Future<void> _evictBySize() async {
    if (_box!.length <= maxSize) return;
    
    // Remove random entries until we're under the limit
    final keysToRemove = _box!.keys.take(_box!.length - maxSize).toList();
    for (final key in keysToRemove) {
      await _box!.delete(key);
    }
    
    AppLogger.debug('Evicted \${keysToRemove.length} entries by size', 'CacheManager');
  }
  
  void _updateAccessTime(String key) {
    final json = _box!.get(key) as Map<String, dynamic>?;
    if (json == null) return;
    
    final entry = CacheEntry.fromJson(json, json['data']);
    final updated = CacheEntry<T>(
      data: entry.data,
      timestamp: DateTime.now(),
      ttl: entry.ttl,
    );
    
    _box!.put(key, updated.toJson());
  }
}
""";
}

/// Generates sync manager for offline-to-online sync
String generateSyncManager(BlueprintConfig config) {
  return """import 'dart:collection';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger.dart';
import 'hive_database.dart';

/// Sync operation types
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Pending sync operation
class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.endpoint,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });
  
  final String id;
  final SyncOperationType type;
  final String endpoint;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'endpoint': endpoint,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };
  
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.byName(json['type'] as String),
      endpoint: json['endpoint'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
  
  SyncOperation copyWith({int? retryCount}) {
    return SyncOperation(
      id: id,
      type: type,
      endpoint: endpoint,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Manages offline-to-online data synchronization
class SyncManager {
  SyncManager({this.maxRetries = 3});
  
  final int maxRetries;
  
  Box<Map>? _syncBox;
  final Queue<SyncOperation> _syncQueue = Queue<SyncOperation>();
  bool _isSyncing = false;
  
  /// Initialize sync manager
  Future<void> init() async {
    _syncBox = await HiveDatabase.instance.openBox<Map>('sync_queue');
    await _loadPendingSyncs();
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        sync();
      }
    });
    
    AppLogger.info('Sync manager initialized', 'SyncManager');
  }
  
  /// Add operation to sync queue
  Future<void> addToQueue(SyncOperation operation) async {
    _ensureInitialized();
    
    await _syncBox!.put(operation.id, operation.toJson());
    _syncQueue.add(operation);
    
    AppLogger.debug(
      'Added to sync queue: \${operation.type.name} \${operation.endpoint}',
      'SyncManager',
    );
    
    // Try to sync immediately if online
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      await sync();
    }
  }
  
  /// Process sync queue
  Future<void> sync() async {
    _ensureInitialized();
    
    if (_isSyncing) {
      AppLogger.debug('Sync already in progress', 'SyncManager');
      return;
    }
    
    if (_syncQueue.isEmpty) {
      AppLogger.debug('Sync queue is empty', 'SyncManager');
      return;
    }
    
    _isSyncing = true;
    AppLogger.info('Starting sync (\${_syncQueue.length} operations)', 'SyncManager');
    
    final failedOperations = <SyncOperation>[];
    
    while (_syncQueue.isNotEmpty) {
      final operation = _syncQueue.removeFirst();
      
      try {
        // TODO: Implement actual API calls based on operation type
        // For now, we'll simulate success
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Remove from persistent storage
        await _syncBox!.delete(operation.id);
        
        AppLogger.success(
          'Synced: \${operation.type.name} \${operation.endpoint}',
          'SyncManager',
        );
      } catch (e, stackTrace) {
        AppLogger.error(
          'Sync failed: \${operation.endpoint}',
          e,
          stackTrace,
          'SyncManager',
        );
        
        // Retry logic
        if (operation.retryCount < maxRetries) {
          final retried = operation.copyWith(retryCount: operation.retryCount + 1);
          failedOperations.add(retried);
          await _syncBox!.put(retried.id, retried.toJson());
        } else {
          AppLogger.error(
            'Max retries reached for: \${operation.endpoint}',
            e,
            stackTrace,
            'SyncManager',
          );
          // Could move to dead letter queue here
        }
      }
    }
    
    // Re-add failed operations to queue
    _syncQueue.addAll(failedOperations);
    
    _isSyncing = false;
    AppLogger.info('Sync completed', 'SyncManager');
  }
  
  /// Get pending sync count
  int get pendingCount => _syncQueue.length;
  
  /// Check if there are pending syncs
  bool get hasPendingSyncs => _syncQueue.isNotEmpty;
  
  /// Clear all pending syncs
  Future<void> clearQueue() async {
    _ensureInitialized();
    
    await _syncBox!.clear();
    _syncQueue.clear();
    AppLogger.warning('Sync queue cleared', 'SyncManager');
  }
  
  void _ensureInitialized() {
    if (_syncBox == null || !_syncBox!.isOpen) {
      throw StateError('SyncManager not initialized. Call init() first.');
    }
  }
  
  Future<void> _loadPendingSyncs() async {
    for (final key in _syncBox!.keys) {
      final json = _syncBox!.get(key) as Map<String, dynamic>?;
      if (json == null) continue;
      
      try {
        final operation = SyncOperation.fromJson(json);
        _syncQueue.add(operation);
      } catch (e) {
        AppLogger.error('Failed to load sync operation', e, null, 'SyncManager');
      }
    }
    
    AppLogger.info(
      'Loaded \${_syncQueue.length} pending syncs',
      'SyncManager',
    );
  }
}
""";
}
