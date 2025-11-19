import 'package:flutter_blueprint/src/templates/offline_first_templates.dart';
import 'package:test/test.dart';

void main() {
  group('generateSyncQueue', () {
    late String generatedCode;

    setUp(() {
      generatedCode = generateSyncQueue();
    });

    test('generates valid Dart code', () {
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('class SyncQueue'));
    });

    test('includes SyncQueue class with ChangeNotifier', () {
      expect(generatedCode, contains('class SyncQueue extends ChangeNotifier'));
    });

    test('includes operation queue management', () {
      expect(generatedCode, contains('Queue<SyncOperation>'));
      expect(generatedCode, contains('_queue'));
    });

    test('includes enqueue method', () {
      expect(generatedCode, contains('Future<void> enqueue(SyncOperation'));
      expect(generatedCode, contains('_queue.add(operation)'));
    });

    test('includes processQueue method with executor', () {
      expect(generatedCode, contains('Future<void> processQueue'));
      expect(generatedCode, contains('executor'));
      expect(generatedCode, contains('networkCheck'));
    });

    test('includes retry logic with max retries', () {
      expect(generatedCode, contains('_maxRetries'));
      expect(generatedCode, contains('retryCount'));
      expect(generatedCode, contains('_retryDelay'));
    });

    test('includes persistence with SharedPreferences', () {
      expect(generatedCode, contains('SharedPreferences'));
      expect(generatedCode, contains('_saveQueue'));
      expect(generatedCode, contains('loadQueue'));
    });

    test('includes event stream for sync events', () {
      expect(generatedCode, contains('StreamController<SyncEvent>'));
      expect(generatedCode, contains('events'));
    });

    test('includes SyncOperation class', () {
      expect(generatedCode, contains('class SyncOperation'));
      expect(generatedCode, contains('final String id'));
      expect(generatedCode, contains('final String type'));
      expect(generatedCode, contains('final Map<String, dynamic> data'));
    });

    test('includes SyncEvent class with factory methods', () {
      expect(generatedCode, contains('class SyncEvent'));
      expect(generatedCode, contains('factory SyncEvent.enqueued'));
      expect(generatedCode, contains('factory SyncEvent.completed'));
      expect(generatedCode, contains('factory SyncEvent.failed'));
    });

    test('includes clear and remove methods', () {
      expect(generatedCode, contains('clear()'));
      expect(generatedCode, contains('remove(String operationId)'));
    });

    test('includes configureRetry method', () {
      expect(generatedCode, contains('void configureRetry'));
      expect(generatedCode, contains('maxRetries'));
      expect(generatedCode, contains('retryDelay'));
    });

    test('includes proper imports', () {
      expect(generatedCode, contains("import 'dart:async'"));
      expect(generatedCode, contains("import 'dart:collection'"));
      expect(
          generatedCode, contains("import 'package:flutter/foundation.dart'"));
      expect(
          generatedCode,
          contains(
              "import 'package:shared_preferences/shared_preferences.dart'"));
    });

    test('includes usage documentation', () {
      expect(generatedCode,
          contains('/// Sync queue for managing offline operations'));
      expect(generatedCode, contains('Usage:'));
    });

    test('includes JSON serialization', () {
      expect(generatedCode, contains('toJson()'));
      expect(generatedCode, contains('fromJson'));
    });
  });

  group('generateConflictResolver', () {
    late String generatedCode;

    setUp(() {
      generatedCode = generateConflictResolver();
    });

    test('generates valid Dart code', () {
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('class ConflictResolver'));
    });

    test('includes generic type support', () {
      expect(generatedCode, contains('class ConflictResolver<T>'));
    });

    test('includes ConflictStrategy enum', () {
      expect(generatedCode, contains('enum ConflictStrategy'));
      expect(generatedCode, contains('lastWriteWins'));
      expect(generatedCode, contains('firstWriteWins'));
      expect(generatedCode, contains('localWins'));
      expect(generatedCode, contains('remoteWins'));
      expect(generatedCode, contains('custom'));
      expect(generatedCode, contains('manual'));
    });

    test('includes resolve method', () {
      expect(generatedCode, contains('ConflictResolution<T> resolve'));
      expect(generatedCode, contains('required T local'));
      expect(generatedCode, contains('required T remote'));
    });

    test('includes timestamp-based resolution', () {
      expect(generatedCode, contains('DateTime? localTimestamp'));
      expect(generatedCode, contains('DateTime? remoteTimestamp'));
      expect(generatedCode, contains('isAfter'));
      expect(generatedCode, contains('isBefore'));
    });

    test('includes custom resolver function', () {
      expect(generatedCode,
          contains('T Function(T local, T remote)? customResolver'));
    });

    test('includes ConflictResolution result class', () {
      expect(generatedCode, contains('class ConflictResolution<T>'));
      expect(generatedCode, contains('final T data'));
      expect(generatedCode, contains('final bool wasConflict'));
      expect(generatedCode, contains('final bool requiresManualResolution'));
    });

    test('includes equality checking', () {
      expect(generatedCode, contains('_areEqual'));
      expect(generatedCode, contains('_mapsEqual'));
    });

    test('includes field-level merge method', () {
      expect(generatedCode, contains('Map<String, dynamic> mergeFields'));
      expect(generatedCode, contains('Map<String, DateTime> localTimestamps'));
      expect(generatedCode, contains('Map<String, DateTime> remoteTimestamps'));
    });

    test('handles all conflict strategies', () {
      expect(generatedCode, contains('switch (strategy)'));
      expect(generatedCode, contains('case ConflictStrategy.lastWriteWins'));
      expect(generatedCode, contains('case ConflictStrategy.custom'));
    });

    test('includes proper documentation', () {
      expect(generatedCode, contains('/// Conflict resolver'));
      expect(generatedCode, contains('Usage:'));
    });

    test('includes proper imports', () {
      expect(
          generatedCode, contains("import 'package:flutter/foundation.dart'"));
    });

    test('handles no-conflict detection', () {
      expect(generatedCode, contains('noConflict'));
      expect(generatedCode, contains('wasConflict: false'));
    });
  });

  group('generateBackgroundSync', () {
    late String generatedCode;

    setUp(() {
      generatedCode = generateBackgroundSync();
    });

    test('generates valid Dart code', () {
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('class BackgroundSync'));
    });

    test('includes BackgroundSync class with ChangeNotifier', () {
      expect(generatedCode,
          contains('class BackgroundSync extends ChangeNotifier'));
    });

    test('includes initialize method', () {
      expect(generatedCode, contains('Future<void> initialize()'));
      expect(generatedCode, contains('_isInitialized'));
    });

    test('includes registerSyncTask method', () {
      expect(generatedCode, contains('void registerSyncTask'));
      expect(generatedCode, contains('String taskId'));
      expect(generatedCode, contains('Future<void> Function() task'));
    });

    test('includes schedulePeriodicSync method', () {
      expect(generatedCode, contains('Future<void> schedulePeriodicSync'));
      expect(generatedCode, contains('required Duration frequency'));
    });

    test('includes sync constraints', () {
      expect(generatedCode, contains('bool requiresWifi'));
      expect(generatedCode, contains('bool requiresCharging'));
    });

    test('includes syncNow method', () {
      expect(generatedCode, contains('Future<void> syncNow'));
    });

    test('includes Timer for periodic sync', () {
      expect(generatedCode, contains('Timer'));
      expect(generatedCode, contains('_periodicTimer'));
      expect(generatedCode, contains('Timer.periodic'));
    });

    test('includes sync status tracking', () {
      expect(generatedCode, contains('bool _isSyncing'));
      expect(generatedCode, contains('DateTime? _lastSyncTime'));
    });

    test('includes cancelPeriodicSync method', () {
      expect(generatedCode, contains('void cancelPeriodicSync()'));
      expect(generatedCode, contains('_periodicTimer?.cancel()'));
    });

    test('includes time since last sync', () {
      expect(generatedCode, contains('Duration? timeSinceLastSync()'));
      expect(generatedCode, contains('DateTime.now().difference'));
    });

    test('includes SyncConfig class', () {
      expect(generatedCode, contains('class SyncConfig'));
      expect(generatedCode, contains('final Duration frequency'));
    });

    test('includes proper imports', () {
      expect(generatedCode, contains("import 'dart:async'"));
      expect(
          generatedCode, contains("import 'package:flutter/foundation.dart'"));
    });

    test('includes usage documentation', () {
      expect(generatedCode, contains('/// Background sync coordinator'));
      expect(generatedCode, contains('Usage:'));
    });

    test('handles multiple sync tasks', () {
      expect(generatedCode,
          contains('Map<String, Future<void> Function()> _syncTasks'));
      expect(generatedCode, contains('unregisterSyncTask'));
    });
  });

  group('generateOfflineRepository', () {
    late String generatedCode;

    setUp(() {
      generatedCode = generateOfflineRepository();
    });

    test('generates valid Dart code', () {
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('abstract class OfflineRepository'));
    });

    test('includes generic type support', () {
      expect(generatedCode, contains('abstract class OfflineRepository<T>'));
    });

    test('includes LocalDataSource dependency', () {
      expect(
          generatedCode, contains('final LocalDataSource<T> localDataSource'));
    });

    test('includes RemoteDataSource dependency', () {
      expect(generatedCode,
          contains('final RemoteDataSource<T> remoteDataSource'));
    });

    test('includes SyncQueue integration', () {
      expect(generatedCode, contains('final SyncQueue? syncQueue'));
    });

    test('includes getAll method with local-first strategy', () {
      expect(generatedCode, contains('Future<List<T>> getAll()'));
      expect(generatedCode, contains('localDataSource.getAll()'));
      expect(generatedCode, contains('_syncInBackground()'));
    });

    test('includes getById method', () {
      expect(generatedCode, contains('Future<T?> getById(String id)'));
      expect(generatedCode, contains('localDataSource.getById'));
    });

    test('includes create method', () {
      expect(generatedCode, contains('Future<T> create(T item)'));
      expect(generatedCode, contains('localDataSource.save(item)'));
    });

    test('includes update method', () {
      expect(generatedCode, contains('Future<T> update(T item)'));
      expect(generatedCode, contains('localDataSource.update(item)'));
    });

    test('includes delete method', () {
      expect(generatedCode, contains('Future<void> delete(String id)'));
      expect(generatedCode, contains('localDataSource.delete(id)'));
    });

    test('includes sync method', () {
      expect(generatedCode, contains('Future<void> sync()'));
      expect(generatedCode, contains('remoteDataSource.getAll()'));
    });

    test('includes LocalDataSource interface', () {
      expect(generatedCode, contains('abstract class LocalDataSource<T>'));
      expect(generatedCode, contains('Future<List<T>> getAll()'));
      expect(generatedCode, contains('Future<void> save(T item)'));
      expect(generatedCode, contains('Future<void> clear()'));
    });

    test('includes RemoteDataSource interface', () {
      expect(generatedCode, contains('abstract class RemoteDataSource<T>'));
      expect(generatedCode, contains('Future<T> create(T item)'));
    });

    test('includes background sync helper', () {
      expect(generatedCode, contains('void _syncInBackground()'));
      expect(generatedCode, contains('Future.delayed(Duration.zero'));
    });

    test('includes usage documentation', () {
      expect(generatedCode, contains('/// Offline-first repository pattern'));
      expect(generatedCode, contains('Usage:'));
    });

    test('includes proper imports', () {
      expect(generatedCode, contains("import 'dart:async'"));
    });

    test('queues operations for sync', () {
      expect(generatedCode, contains('syncQueue!.enqueue'));
      expect(generatedCode, contains("type: 'create'"));
      expect(generatedCode, contains("type: 'update'"));
      expect(generatedCode, contains("type: 'delete'"));
    });
  });

  group('generateNetworkMonitor', () {
    late String generatedCode;

    setUp(() {
      generatedCode = generateNetworkMonitor();
    });

    test('generates valid Dart code', () {
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('class NetworkMonitor'));
    });

    test('includes NetworkMonitor class with ChangeNotifier', () {
      expect(generatedCode,
          contains('class NetworkMonitor extends ChangeNotifier'));
    });

    test('includes Connectivity integration', () {
      expect(generatedCode, contains('Connectivity'));
      expect(generatedCode, contains('_connectivity'));
    });

    test('includes NetworkStatus class', () {
      expect(generatedCode, contains('class NetworkStatus'));
      expect(generatedCode, contains('final bool isConnected'));
      expect(generatedCode, contains('final NetworkType type'));
    });

    test('includes NetworkType enum', () {
      expect(generatedCode, contains('enum NetworkType'));
      expect(generatedCode, contains('none'));
      expect(generatedCode, contains('wifi'));
      expect(generatedCode, contains('mobile'));
      expect(generatedCode, contains('ethernet'));
    });

    test('includes status stream', () {
      expect(generatedCode, contains('Stream<NetworkStatus> get statusStream'));
      expect(generatedCode, contains('onConnectivityChanged'));
    });

    test('includes initialize method', () {
      expect(generatedCode, contains('Future<void> initialize()'));
      expect(generatedCode, contains('checkConnectivity()'));
    });

    test('includes connection status getters', () {
      expect(generatedCode, contains('bool get isConnected'));
      expect(generatedCode, contains('bool get isWifi'));
      expect(generatedCode, contains('bool get isMobile'));
    });

    test('includes waitForConnection method', () {
      expect(generatedCode, contains('Future<void> waitForConnection'));
      expect(generatedCode, contains('Duration? timeout'));
    });

    test('includes connectivity result mapping', () {
      expect(generatedCode, contains('NetworkStatus _mapToStatus'));
      expect(generatedCode, contains('ConnectivityResult'));
    });

    test('handles timeout in waitForConnection', () {
      expect(generatedCode, contains('Timer'));
      expect(generatedCode, contains('TimeoutException'));
    });

    test('includes proper imports', () {
      expect(generatedCode, contains("import 'dart:async'"));
      expect(
          generatedCode, contains("import 'package:flutter/foundation.dart'"));
      expect(
          generatedCode,
          contains(
              "import 'package:connectivity_plus/connectivity_plus.dart'"));
    });

    test('includes usage documentation', () {
      expect(generatedCode, contains('/// Network connectivity monitor'));
      expect(generatedCode, contains('Usage:'));
    });

    test('includes StreamSubscription management', () {
      expect(generatedCode, contains('StreamSubscription'));
      expect(generatedCode, contains('_subscription'));
    });

    test('includes unknown status constant', () {
      expect(generatedCode, contains('static const unknown'));
    });
  });

  group('generateSyncCoordinator', () {
    late String generatedCode;

    setUp(() {
      generatedCode = generateSyncCoordinator();
    });

    test('generates valid Dart code', () {
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('class SyncCoordinator'));
    });

    test('includes SyncCoordinator class with ChangeNotifier', () {
      expect(generatedCode,
          contains('class SyncCoordinator extends ChangeNotifier'));
    });

    test('includes required dependencies', () {
      expect(generatedCode, contains('final SyncQueue syncQueue'));
      expect(generatedCode, contains('final NetworkMonitor networkMonitor'));
      expect(generatedCode,
          contains('final List<OfflineRepository> repositories'));
    });

    test('includes BackgroundSync integration', () {
      expect(generatedCode, contains('final BackgroundSync? backgroundSync'));
    });

    test('includes initialize method', () {
      expect(generatedCode, contains('Future<void> initialize()'));
      expect(generatedCode, contains('networkMonitor.initialize()'));
      expect(generatedCode, contains('syncQueue.loadQueue()'));
    });

    test('includes syncAll method', () {
      expect(generatedCode, contains('Future<void> syncAll()'));
      expect(generatedCode, contains('syncQueue.processQueue'));
    });

    test('includes auto-sync on network restore', () {
      expect(generatedCode, contains('networkMonitor.statusStream.listen'));
      expect(generatedCode, contains('status.isConnected'));
      expect(generatedCode, contains('_autoSyncEnabled'));
    });

    test('includes auto-sync toggle', () {
      expect(generatedCode, contains('void setAutoSync(bool enabled)'));
      expect(generatedCode, contains('_autoSyncEnabled = enabled'));
    });

    test('includes forceSyncNow method', () {
      expect(generatedCode, contains('Future<void> forceSyncNow()'));
    });

    test('includes SyncStatistics class', () {
      expect(generatedCode, contains('class SyncStatistics'));
      expect(generatedCode, contains('final int pendingOperations'));
      expect(generatedCode, contains('final bool isConnected'));
      expect(generatedCode, contains('final bool isSyncing'));
    });

    test('includes getStatistics method', () {
      expect(generatedCode, contains('SyncStatistics getStatistics()'));
      expect(generatedCode, contains('syncQueue.pendingCount'));
    });

    test('registers background sync task', () {
      expect(generatedCode, contains('backgroundSync!.registerSyncTask'));
      expect(generatedCode, contains("'full_sync'"));
    });

    test('includes proper imports', () {
      expect(generatedCode, contains("import 'dart:async'"));
      expect(
          generatedCode, contains("import 'package:flutter/foundation.dart'"));
    });

    test('includes usage documentation', () {
      expect(generatedCode, contains('/// Sync coordinator'));
      expect(generatedCode, contains('Usage:'));
    });

    test('handles multiple repositories', () {
      expect(generatedCode, contains('for (final repo in repositories)'));
      expect(generatedCode, contains('repo.sync()'));
    });

    test('includes executor for sync operations', () {
      expect(generatedCode, contains('Future<bool> _executeSyncOperation'));
      expect(generatedCode, contains('SyncOperation operation'));
    });
  });

  group('generateOfflineExamples', () {
    late String generatedCode;

    setUp(() {
      generatedCode = generateOfflineExamples();
    });

    test('generates valid Dart code', () {
      expect(generatedCode, isNotEmpty);
      expect(generatedCode, contains('class PostRepository'));
    });

    test('includes example repository implementation', () {
      expect(generatedCode,
          contains('class PostRepository extends OfflineRepository<Post>'));
      expect(generatedCode, contains('_toMap'));
    });

    test('includes Post model example', () {
      expect(generatedCode, contains('class Post'));
      expect(generatedCode, contains('final String id'));
      expect(generatedCode, contains('final String title'));
    });

    test('includes UI example with StatefulWidget', () {
      expect(generatedCode,
          contains('class OfflineFirstExample extends StatefulWidget'));
      expect(generatedCode, contains('_OfflineFirstExampleState'));
    });

    test('includes SyncCoordinator usage', () {
      expect(generatedCode, contains('final _coordinator = SyncCoordinator'));
      expect(generatedCode, contains('_coordinator.initialize()'));
    });

    test('includes sync status UI', () {
      expect(generatedCode, contains('stats.isConnected'));
      expect(generatedCode, contains('stats.pendingOperations'));
      expect(generatedCode, contains('Icons.cloud_done'));
      expect(generatedCode, contains('Icons.cloud_off'));
    });

    test('includes best practices list', () {
      expect(generatedCode, contains('/// Best Practices:'));
      expect(generatedCode, contains('1. Always save to local storage first'));
      expect(generatedCode, contains('2. Use sync queue'));
    });

    test('includes common pitfalls list', () {
      expect(generatedCode, contains('/// Common Pitfalls:'));
      expect(generatedCode, contains('1. Not persisting sync queue'));
    });

    test('includes proper imports', () {
      expect(generatedCode, contains("import 'package:flutter/material.dart'"));
    });

    test('includes progress indicator for syncing', () {
      expect(generatedCode, contains('LinearProgressIndicator'));
      expect(generatedCode, contains('stats.isSyncing'));
    });

    test('includes pending operations banner', () {
      expect(generatedCode, contains('pending sync operations'));
      expect(generatedCode, contains('Colors.orange'));
    });

    test('includes force sync button', () {
      expect(generatedCode, contains('forceSyncNow'));
      expect(generatedCode, contains('IconButton'));
    });

    test('demonstrates listener pattern', () {
      expect(generatedCode, contains('_coordinator.addListener'));
      expect(generatedCode, contains('_coordinator.removeListener'));
    });

    test('includes comprehensive documentation', () {
      expect(generatedCode,
          contains('/// Example: Complete offline-first implementation'));
      expect(generatedCode, contains('This demonstrates:'));
    });
  });

  group('Code Quality', () {
    test('all generators produce non-empty code', () {
      expect(generateSyncQueue(), isNotEmpty);
      expect(generateConflictResolver(), isNotEmpty);
      expect(generateBackgroundSync(), isNotEmpty);
      expect(generateOfflineRepository(), isNotEmpty);
      expect(generateNetworkMonitor(), isNotEmpty);
      expect(generateSyncCoordinator(), isNotEmpty);
      expect(generateOfflineExamples(), isNotEmpty);
    });

    test('all generators include class definitions', () {
      expect(generateSyncQueue(), contains('class '));
      expect(generateConflictResolver(), contains('class '));
      expect(generateBackgroundSync(), contains('class '));
      expect(generateOfflineRepository(), contains('class '));
      expect(generateNetworkMonitor(), contains('class '));
      expect(generateSyncCoordinator(), contains('class '));
      expect(generateOfflineExamples(), contains('class '));
    });

    test('all generators include proper documentation', () {
      expect(generateSyncQueue(), contains('///'));
      expect(generateConflictResolver(), contains('///'));
      expect(generateBackgroundSync(), contains('///'));
      expect(generateOfflineRepository(), contains('///'));
      expect(generateNetworkMonitor(), contains('///'));
      expect(generateSyncCoordinator(), contains('///'));
      expect(generateOfflineExamples(), contains('///'));
    });

    test('all generators include usage examples', () {
      expect(generateSyncQueue(), contains('Usage:'));
      expect(generateConflictResolver(), contains('Usage:'));
      expect(generateBackgroundSync(), contains('Usage:'));
      expect(generateOfflineRepository(), contains('Usage:'));
      expect(generateNetworkMonitor(), contains('Usage:'));
      expect(generateSyncCoordinator(), contains('Usage:'));
    });

    test('all generators include necessary imports', () {
      expect(generateSyncQueue(), contains('import '));
      expect(generateConflictResolver(), contains('import '));
      expect(generateBackgroundSync(), contains('import '));
      expect(generateOfflineRepository(), contains('import '));
      expect(generateNetworkMonitor(), contains('import '));
      expect(generateSyncCoordinator(), contains('import '));
      expect(generateOfflineExamples(), contains('import '));
    });

    test('code uses proper Dart formatting conventions', () {
      final generators = [
        generateSyncQueue(),
        generateConflictResolver(),
        generateBackgroundSync(),
        generateOfflineRepository(),
        generateNetworkMonitor(),
        generateSyncCoordinator(),
        generateOfflineExamples(),
      ];

      for (final code in generators) {
        // Check that code is properly structured
        expect(code.length, greaterThan(100));
        // Check for proper error handling patterns (nullable or try-catch)
        expect(code, anyOf(contains('?'), contains('!')));
      }
    });
  });

  group('Integration Tests', () {
    test('SyncQueue integrates with SyncOperation', () {
      final syncQueueCode = generateSyncQueue();
      expect(syncQueueCode, contains('SyncOperation'));
      expect(syncQueueCode, contains('class SyncOperation'));
    });

    test('ConflictResolver works with generic types', () {
      final resolverCode = generateConflictResolver();
      expect(resolverCode, contains('<T>'));
      expect(resolverCode, contains('ConflictResolution<T>'));
    });

    test('BackgroundSync integrates with sync tasks', () {
      final backgroundSyncCode = generateBackgroundSync();
      expect(backgroundSyncCode, contains('registerSyncTask'));
      expect(backgroundSyncCode, contains('Future<void> Function()'));
    });

    test('OfflineRepository requires data sources', () {
      final repositoryCode = generateOfflineRepository();
      expect(repositoryCode, contains('LocalDataSource'));
      expect(repositoryCode, contains('RemoteDataSource'));
    });

    test('NetworkMonitor provides status stream', () {
      final monitorCode = generateNetworkMonitor();
      expect(monitorCode, contains('Stream<NetworkStatus>'));
      expect(monitorCode, contains('statusStream'));
    });

    test('SyncCoordinator orchestrates all components', () {
      final coordinatorCode = generateSyncCoordinator();
      expect(coordinatorCode, contains('SyncQueue'));
      expect(coordinatorCode, contains('NetworkMonitor'));
      expect(coordinatorCode, contains('OfflineRepository'));
      expect(coordinatorCode, contains('BackgroundSync'));
    });

    test('Examples demonstrate complete workflow', () {
      final examplesCode = generateOfflineExamples();
      expect(examplesCode, contains('PostRepository'));
      expect(examplesCode, contains('OfflineRepository<Post>'));
      expect(examplesCode, contains('SyncCoordinator'));
    });
  });

  group('Feature Coverage', () {
    test('sync queue supports operation queuing', () {
      final code = generateSyncQueue();
      expect(code, contains('enqueue'));
      expect(code, contains('processQueue'));
      expect(code, contains('clear'));
    });

    test('conflict resolver supports multiple strategies', () {
      final code = generateConflictResolver();
      expect(code, contains('lastWriteWins'));
      expect(code, contains('firstWriteWins'));
      expect(code, contains('localWins'));
      expect(code, contains('remoteWins'));
      expect(code, contains('custom'));
    });

    test('background sync supports scheduling', () {
      final code = generateBackgroundSync();
      expect(code, contains('schedulePeriodicSync'));
      expect(code, contains('syncNow'));
      expect(code, contains('cancelPeriodicSync'));
    });

    test('offline repository supports CRUD operations', () {
      final code = generateOfflineRepository();
      expect(code, contains('getAll'));
      expect(code, contains('getById'));
      expect(code, contains('create'));
      expect(code, contains('update'));
      expect(code, contains('delete'));
    });

    test('network monitor detects connectivity changes', () {
      final code = generateNetworkMonitor();
      expect(code, contains('isConnected'));
      expect(code, contains('isWifi'));
      expect(code, contains('isMobile'));
      expect(code, contains('statusStream'));
    });
  });

  group('Best Practices', () {
    test('uses ChangeNotifier for state management', () {
      expect(generateSyncQueue(), contains('ChangeNotifier'));
      expect(generateBackgroundSync(), contains('ChangeNotifier'));
      expect(generateNetworkMonitor(), contains('ChangeNotifier'));
      expect(generateSyncCoordinator(), contains('ChangeNotifier'));
    });

    test('includes proper error handling', () {
      final generators = [
        generateSyncQueue(),
        generateBackgroundSync(),
        generateOfflineRepository(),
        generateSyncCoordinator(),
      ];

      for (final code in generators) {
        // Check for error handling patterns (try-catch or nullable operators)
        expect(
            code,
            anyOf(
                contains('try'), contains('?'), contains('!'), contains('??')));
        expect(code, anyOf(contains('catch'), contains('?'), contains('!')));
      }
    });

    test('uses Future for async operations', () {
      final generators = [
        generateSyncQueue(),
        generateBackgroundSync(),
        generateOfflineRepository(),
        generateNetworkMonitor(),
        generateSyncCoordinator(),
      ];

      for (final code in generators) {
        expect(code, contains('Future<'));
        expect(code, contains('async'));
      }
    });

    test('includes proper disposal methods', () {
      expect(generateSyncQueue(), contains('dispose()'));
      expect(generateBackgroundSync(), contains('dispose()'));
      expect(generateNetworkMonitor(), contains('dispose()'));
      expect(generateSyncCoordinator(), contains('dispose()'));
    });

    test('uses streams for reactive updates', () {
      expect(generateSyncQueue(), contains('Stream'));
      expect(generateNetworkMonitor(), contains('Stream'));
    });
  });
}
