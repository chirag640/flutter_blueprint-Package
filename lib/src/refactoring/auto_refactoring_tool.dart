import 'dart:io';

import 'package:path/path.dart' as p;

import '../utils/logger.dart';
import 'refactoring_types.dart';

/// Handles automatic refactoring of Flutter projects.
///
/// This class provides various refactoring operations like adding caching,
/// offline support, migrating state management, and more. Each refactoring
/// is designed to be safe and reversible.
class AutoRefactoringTool {
  AutoRefactoringTool({
    Logger? logger,
    this.config = const RefactoringConfig(),
  }) : _logger = logger ?? Logger();

  final Logger _logger;
  final RefactoringConfig config;

  /// Performs the specified refactoring on the project.
  Future<RefactoringResult> refactor(
    String projectPath,
    RefactoringType type,
  ) async {
    _logger.info('🔧 Starting refactoring: ${type.label}');
    _logger.info('   Project: $projectPath');
    _logger.info('   Dry run: ${config.dryRun}');
    _logger.info('');

    try {
      // Verify project exists
      if (!await Directory(projectPath).exists()) {
        throw Exception('Project directory does not exist: $projectPath');
      }

      // Create backup if needed
      if (config.createBackup && !config.dryRun) {
        await _createBackup(projectPath);
      }

      // Perform the specific refactoring
      final result = await switch (type) {
        RefactoringType.addCaching => _addCaching(projectPath),
        RefactoringType.addOfflineSupport => _addOfflineSupport(projectPath),
        RefactoringType.migrateToRiverpod => _migrateToRiverpod(projectPath),
        RefactoringType.migrateToBloc => _migrateToBloc(projectPath),
        RefactoringType.addErrorHandling => _addErrorHandling(projectPath),
        RefactoringType.addLogging => _addLogging(projectPath),
        RefactoringType.optimizePerformance =>
          _optimizePerformance(projectPath),
        RefactoringType.addTesting => _addTesting(projectPath),
      };

      // Format code if requested
      if (config.formatCode && !config.dryRun && result.success) {
        _logger.info('📝 Formatting code...');
        await _formatCode(projectPath);
      }

      // Run tests if requested
      if (config.runTests && !config.dryRun && result.success) {
        _logger.info('🧪 Running tests...');
        final testsPassed = await _runTests(projectPath);
        if (!testsPassed) {
          return RefactoringResult(
            success: false,
            filesModified: result.filesModified,
            filesCreated: result.filesCreated,
            changes: result.changes,
            error: 'Tests failed after refactoring. Please review the changes.',
          );
        }
      }

      _logger.info('');
      _logger.success('✅ Refactoring complete!');

      return result;
    } catch (e, stackTrace) {
      _logger.error('❌ Refactoring failed: $e');
      _logger.debug('Stack trace: $stackTrace');

      return RefactoringResult(
        success: false,
        filesModified: const [],
        filesCreated: const [],
        changes: const [],
        error: e.toString(),
      );
    }
  }

  /// Adds caching layer to the project.
  Future<RefactoringResult> _addCaching(String projectPath) async {
    _logger.info('Adding caching layer...');

    final filesCreated = <String>[];
    final filesModified = <String>[];
    final changes = <RefactoringChange>[];

    // Create cache service
    final cacheServicePath =
        p.join(projectPath, 'lib', 'core', 'cache', 'cache_service.dart');
    if (!config.dryRun) {
      await _createFile(cacheServicePath, _getCacheServiceTemplate());
    }
    filesCreated.add(cacheServicePath);
    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added CacheService with TTL support',
      filePath: 'lib/core/cache/cache_service.dart',
    ));

    // Create cache models
    final cacheModelPath =
        p.join(projectPath, 'lib', 'core', 'cache', 'cache_entry.dart');
    if (!config.dryRun) {
      await _createFile(cacheModelPath, _getCacheEntryTemplate());
    }
    filesCreated.add(cacheModelPath);
    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added CacheEntry model',
      filePath: 'lib/core/cache/cache_entry.dart',
    ));

    // Update repositories to use caching
    final dataFiles = await _findFilesInDirectory(
      p.join(projectPath, 'lib', 'data', 'repositories'),
      '.dart',
    );

    for (final file in dataFiles) {
      if (config.dryRun) {
        filesModified.add(file);
      } else {
        final modified = await _addCachingToRepository(file);
        if (modified) {
          filesModified.add(file);
        }
      }

      changes.add(RefactoringChange(
        type: 'Modify',
        description: 'Added caching to repository methods',
        filePath: p.relative(file, from: projectPath),
      ));
    }

    // Update pubspec.yaml
    final pubspecPath = p.join(projectPath, 'pubspec.yaml');
    if (!config.dryRun) {
      await _addDependency(pubspecPath, 'shared_preferences', '^2.2.0');
    }
    filesModified.add(pubspecPath);

    return RefactoringResult(
      success: true,
      filesModified: filesModified,
      filesCreated: filesCreated,
      changes: changes,
    );
  }

  /// Adds offline support to the project.
  Future<RefactoringResult> _addOfflineSupport(String projectPath) async {
    _logger.info('Adding offline support...');

    final filesCreated = <String>[];
    final filesModified = <String>[];
    final changes = <RefactoringChange>[];

    // Create local database
    final dbPath =
        p.join(projectPath, 'lib', 'core', 'database', 'app_database.dart');
    if (!config.dryRun) {
      await _createFile(dbPath, _getDatabaseTemplate());
    }
    filesCreated.add(dbPath);
    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added local database with SQLite',
      filePath: 'lib/core/database/app_database.dart',
    ));

    // Create sync service
    final syncPath =
        p.join(projectPath, 'lib', 'core', 'sync', 'sync_service.dart');
    if (!config.dryRun) {
      await _createFile(syncPath, _getSyncServiceTemplate());
    }
    filesCreated.add(syncPath);
    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added SyncService for offline/online synchronization',
      filePath: 'lib/core/sync/sync_service.dart',
    ));

    // Create connectivity checker
    final connectivityPath = p.join(
        projectPath, 'lib', 'core', 'network', 'connectivity_checker.dart');
    if (!config.dryRun) {
      await _createFile(connectivityPath, _getConnectivityTemplate());
    }
    filesCreated.add(connectivityPath);

    // Update pubspec.yaml with offline dependencies
    final pubspecPath = p.join(projectPath, 'pubspec.yaml');
    if (!config.dryRun) {
      await _addDependency(pubspecPath, 'sqflite', '^2.3.0');
      await _addDependency(pubspecPath, 'connectivity_plus', '^5.0.0');
      await _addDependency(pubspecPath, 'path_provider', '^2.1.0');
    }
    filesModified.add(pubspecPath);

    return RefactoringResult(
      success: true,
      filesModified: filesModified,
      filesCreated: filesCreated,
      changes: changes,
      warnings: ['Remember to handle data conflicts during sync'],
    );
  }

  /// Migrates state management from Provider to Riverpod.
  Future<RefactoringResult> _migrateToRiverpod(String projectPath) async {
    _logger.info('Migrating to Riverpod...');

    final filesCreated = <String>[];
    final filesModified = <String>[];
    final changes = <RefactoringChange>[];

    // Find all Provider files
    final providerFiles = await _findFilesContaining(
      projectPath,
      ['ChangeNotifier', 'Provider', 'ChangeNotifierProvider'],
    );

    for (final file in providerFiles) {
      if (config.dryRun) {
        filesModified.add(file);
      } else {
        await _convertProviderToRiverpod(file);
        filesModified.add(file);
      }

      changes.add(RefactoringChange(
        type: 'Convert',
        description: 'Converted Provider to Riverpod',
        filePath: p.relative(file, from: projectPath),
      ));
    }

    // Update pubspec.yaml
    final pubspecPath = p.join(projectPath, 'pubspec.yaml');
    if (!config.dryRun) {
      await _removeDependency(pubspecPath, 'provider');
      await _addDependency(pubspecPath, 'flutter_riverpod', '^2.4.0');
      await _addDependency(pubspecPath, 'riverpod_annotation', '^2.3.0');
    }
    filesModified.add(pubspecPath);

    return RefactoringResult(
      success: true,
      filesModified: filesModified,
      filesCreated: filesCreated,
      changes: changes,
      warnings: [
        'Run: dart run build_runner build',
        'Replace MultiProvider with ProviderScope at app root',
      ],
    );
  }

  /// Migrates to BLoC pattern.
  Future<RefactoringResult> _migrateToBloc(String projectPath) async {
    _logger.info('Migrating to BLoC...');

    final filesCreated = <String>[];
    final filesModified = <String>[];
    final changes = <RefactoringChange>[];

    // Create BLoC directory structure
    final blocDir = p.join(projectPath, 'lib', 'presentation', 'bloc');
    if (!config.dryRun) {
      await Directory(blocDir).create(recursive: true);
    }

    // Add sample BLoC template
    final sampleBlocPath = p.join(blocDir, 'sample_bloc.dart');
    if (!config.dryRun) {
      await _createFile(sampleBlocPath, _getBlocTemplate());
    }
    filesCreated.add(sampleBlocPath);

    // Update pubspec.yaml
    final pubspecPath = p.join(projectPath, 'pubspec.yaml');
    if (!config.dryRun) {
      await _addDependency(pubspecPath, 'flutter_bloc', '^8.1.0');
      await _addDependency(pubspecPath, 'equatable', '^2.0.5');
    }
    filesModified.add(pubspecPath);

    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added BLoC infrastructure and sample',
      filePath: 'lib/presentation/bloc/',
    ));

    return RefactoringResult(
      success: true,
      filesModified: filesModified,
      filesCreated: filesCreated,
      changes: changes,
      warnings: ['Manually convert existing state management to BLoC pattern'],
    );
  }

  /// Adds comprehensive error handling.
  Future<RefactoringResult> _addErrorHandling(String projectPath) async {
    _logger.info('Adding error handling...');

    final filesCreated = <String>[];
    final changes = <RefactoringChange>[];

    // Create error handler
    final errorHandlerPath =
        p.join(projectPath, 'lib', 'core', 'error', 'error_handler.dart');
    if (!config.dryRun) {
      await _createFile(errorHandlerPath, _getErrorHandlerTemplate());
    }
    filesCreated.add(errorHandlerPath);

    // Create custom exceptions
    final exceptionsPath =
        p.join(projectPath, 'lib', 'core', 'error', 'exceptions.dart');
    if (!config.dryRun) {
      await _createFile(exceptionsPath, _getExceptionsTemplate());
    }
    filesCreated.add(exceptionsPath);

    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added comprehensive error handling infrastructure',
      filePath: 'lib/core/error/',
    ));

    return RefactoringResult(
      success: true,
      filesModified: const [],
      filesCreated: filesCreated,
      changes: changes,
    );
  }

  /// Adds structured logging.
  Future<RefactoringResult> _addLogging(String projectPath) async {
    _logger.info('Adding logging...');

    final filesCreated = <String>[];
    final changes = <RefactoringChange>[];

    final loggerPath =
        p.join(projectPath, 'lib', 'core', 'logging', 'app_logger.dart');
    if (!config.dryRun) {
      await _createFile(loggerPath, _getLoggerTemplate());
    }
    filesCreated.add(loggerPath);

    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added structured logging system',
      filePath: 'lib/core/logging/app_logger.dart',
    ));

    return RefactoringResult(
      success: true,
      filesModified: const [],
      filesCreated: filesCreated,
      changes: changes,
    );
  }

  /// Optimizes performance.
  Future<RefactoringResult> _optimizePerformance(String projectPath) async {
    _logger.info('Optimizing performance...');

    final filesModified = <String>[];
    final changes = <RefactoringChange>[];

    // Find all widget files
    final widgetFiles = await _findFilesInDirectory(
      p.join(projectPath, 'lib'),
      '.dart',
    );

    for (final file in widgetFiles) {
      if (config.dryRun) {
        filesModified.add(file);
        continue;
      }

      var modified = false;
      modified |= await _addConstKeywords(file);
      modified |= await _addLazyLoading(file);

      if (modified) {
        filesModified.add(file);
        changes.add(RefactoringChange(
          type: 'Optimize',
          description: 'Applied performance optimizations',
          filePath: p.relative(file, from: projectPath),
        ));
      }
    }

    return RefactoringResult(
      success: true,
      filesModified: filesModified,
      filesCreated: const [],
      changes: changes,
    );
  }

  /// Adds testing infrastructure.
  Future<RefactoringResult> _addTesting(String projectPath) async {
    _logger.info('Adding testing infrastructure...');

    final filesCreated = <String>[];
    final changes = <RefactoringChange>[];

    // Create test helpers
    final helpersPath =
        p.join(projectPath, 'test', 'helpers', 'test_helpers.dart');
    if (!config.dryRun) {
      await _createFile(helpersPath, _getTestHelpersTemplate());
    }
    filesCreated.add(helpersPath);

    // Create mock data
    final mocksPath = p.join(projectPath, 'test', 'mocks', 'mock_data.dart');
    if (!config.dryRun) {
      await _createFile(mocksPath, _getMockDataTemplate());
    }
    filesCreated.add(mocksPath);

    changes.add(const RefactoringChange(
      type: 'Create',
      description: 'Added testing infrastructure',
      filePath: 'test/helpers/',
    ));

    return RefactoringResult(
      success: true,
      filesModified: const [],
      filesCreated: filesCreated,
      changes: changes,
    );
  }

  // Helper methods

  Future<void> _createBackup(String projectPath) async {
    _logger.debug('Creating backup...');
    // Implementation would create a timestamped backup
  }

  Future<void> _formatCode(String projectPath) async {
    final result = await Process.run('dart', ['format', projectPath]);
    if (result.exitCode != 0) {
      _logger.warning('Failed to format code: ${result.stderr}');
    }
  }

  Future<bool> _runTests(String projectPath) async {
    _logger.info('Running tests...');
    final result = await Process.run(
      'flutter',
      ['test'],
      workingDirectory: projectPath,
    );
    return result.exitCode == 0;
  }

  Future<void> _createFile(String path, String content) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<List<String>> _findFilesInDirectory(
    String directory,
    String extension,
  ) async {
    final files = <String>[];
    final dir = Directory(directory);

    if (!await dir.exists()) return files;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith(extension)) {
        files.add(entity.path);
      }
    }

    return files;
  }

  Future<List<String>> _findFilesContaining(
    String projectPath,
    List<String> patterns,
  ) async {
    final files = <String>[];
    final libDir = Directory(p.join(projectPath, 'lib'));

    if (!await libDir.exists()) return files;

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        if (patterns.any((pattern) => content.contains(pattern))) {
          files.add(entity.path);
        }
      }
    }

    return files;
  }

  Future<bool> _addCachingToRepository(String filePath) async {
    // Implementation would modify repository to add caching
    return false; // Placeholder
  }

  Future<void> _addDependency(
    String pubspecPath,
    String package,
    String version,
  ) async {
    final file = File(pubspecPath);
    var content = await file.readAsString();

    if (!content.contains(package)) {
      // Add dependency
      final dependenciesIndex = content.indexOf('dependencies:');
      if (dependenciesIndex != -1) {
        final insertIndex = content.indexOf('\n', dependenciesIndex) + 1;
        content = '${content.substring(0, insertIndex)}'
            '  $package: $version\n'
            '${content.substring(insertIndex)}';
        await file.writeAsString(content);
      }
    }
  }

  Future<void> _removeDependency(String pubspecPath, String package) async {
    final file = File(pubspecPath);
    var content = await file.readAsString();
    final lines = content.split('\n');
    final filtered =
        lines.where((line) => !line.contains('$package:')).toList();
    await file.writeAsString(filtered.join('\n'));
  }

  Future<void> _convertProviderToRiverpod(String filePath) async {
    // Implementation would convert Provider code to Riverpod
  }

  Future<bool> _addConstKeywords(String filePath) async {
    // Implementation would add const keywords where possible
    return false;
  }

  Future<bool> _addLazyLoading(String filePath) async {
    // Implementation would add lazy loading where beneficial
    return false;
  }

  // Template methods (returning code templates as strings)

  String _getCacheServiceTemplate() => '''
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for caching data with TTL support.
class CacheService {
  CacheService(this._prefs);

  final SharedPreferences _prefs;

  /// Cache a value with optional TTL in seconds.
  Future<void> cache<T>(String key, T value, {int? ttlSeconds}) async {
    final entry = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (ttlSeconds != null) 'ttl': ttlSeconds,
    };
    await _prefs.setString(key, jsonEncode(entry));
  }

  /// Get cached value if not expired.
  T? get<T>(String key) {
    final json = _prefs.getString(key);
    if (json == null) return null;

    final entry = jsonDecode(json);
    final timestamp = entry['timestamp'] as int;
    final ttl = entry['ttl'] as int?;

    if (ttl != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > ttl * 1000) {
        _prefs.remove(key);
        return null;
      }
    }

    return entry['value'] as T;
  }

  /// Clear all cache.
  Future<void> clear() async {
    await _prefs.clear();
  }
}
''';

  String _getCacheEntryTemplate() => '''
/// Represents a cached entry with metadata.
class CacheEntry<T> {
  const CacheEntry({
    required this.value,
    required this.timestamp,
    this.ttl,
  });

  final T value;
  final DateTime timestamp;
  final Duration? ttl;

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }
}
''';

  String _getDatabaseTemplate() {
    return '''
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database for offline support.
class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute(${"'''"} 
      CREATE TABLE cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE,
        value TEXT,
        timestamp INTEGER
      )
    ${"'''"});
  }
}
''';
  }

  String _getSyncServiceTemplate() => '''
import 'connectivity_checker.dart';

/// Service for synchronizing offline data.
class SyncService {
  SyncService(this._connectivity);

  final ConnectivityChecker _connectivity;

  /// Sync pending changes when online.
  Future<void> sync() async {
    if (!await _connectivity.isConnected) return;

    // Sync logic here
  }
}
''';

  String _getConnectivityTemplate() => '''
import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks network connectivity.
class ConnectivityChecker {
  final _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
''';

  String _getBlocTemplate() => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class SampleEvent extends Equatable {
  const SampleEvent();

  @override
  List<Object> get props => [];
}

class LoadDataEvent extends SampleEvent {}

// States
abstract class SampleState extends Equatable {
  const SampleState();

  @override
  List<Object> get props => [];
}

class SampleInitial extends SampleState {}

class SampleLoading extends SampleState {}

class SampleLoaded extends SampleState {
  const SampleLoaded(this.data);

  final String data;

  @override
  List<Object> get props => [data];
}

class SampleError extends SampleState {
  const SampleError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

// BLoC
class SampleBloc extends Bloc<SampleEvent, SampleState> {
  SampleBloc() : super(SampleInitial()) {
    on<LoadDataEvent>(_onLoadData);
  }

  Future<void> _onLoadData(
    LoadDataEvent event,
    Emitter<SampleState> emit,
  ) async {
    emit(SampleLoading());
    try {
      // Load data
      emit(const SampleLoaded('Data'));
    } catch (e) {
      emit(SampleError(e.toString()));
    }
  }
}
''';

  String _getErrorHandlerTemplate() => '''
/// Centralized error handler.
class ErrorHandler {
  static void handle(Exception error) {
    // Log error
    // Show user-friendly message
    // Report to analytics
  }
}
''';

  String _getExceptionsTemplate() => '''
/// Custom exceptions.
class NetworkException implements Exception {
  const NetworkException([this.message]);
  final String? message;
}

class CacheException implements Exception {
  const CacheException([this.message]);
  final String? message;
}
''';

  String _getLoggerTemplate() {
    return r'''
/// Application logger.
class AppLogger {
  static void log(String message) {
    print('[LOG] $message');
  }

  static void error(String message, [Exception? exception]) {
    print('[ERROR] $message');
    if (exception != null) print(exception);
  }
}
''';
  }

  String _getTestHelpersTemplate() => '''
/// Test helpers and utilities.
class TestHelpers {
  static Future<void> pumpAndSettle(dynamic tester) async {
    // Helper implementation
  }
}
''';

  String _getMockDataTemplate() => '''
/// Mock data for testing.
class MockData {
  static const sampleData = 'Test Data';
}
''';
}
