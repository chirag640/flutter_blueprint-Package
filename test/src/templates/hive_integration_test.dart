import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/bloc_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/provider_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/riverpod_mobile_template.dart';
import 'package:test/test.dart';

void main() {
  group('Hive Integration Tests', () {
    late BlueprintConfig configWithHive;
    late BlueprintConfig configWithoutHive;

    setUp(() {
      configWithHive = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeHive: true,
        includeApi: true,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeTests: true,
      );

      configWithoutHive = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeHive: false,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
      );
    });

    group('BlueprintConfig Hive Flag', () {
      test('includes Hive flag in serialization', () {
        final map = configWithHive.toMap();
        expect(map['features']['hive'], isTrue);
      });

      test('reads Hive flag from map', () {
        final map = {
          'appName': 'test_app',
          'stateManagement': 'provider',
          'platforms': ['mobile'],
          'features': {'hive': true},
        };
        final config = BlueprintConfig.fromMap(map);
        expect(config.includeHive, isTrue);
      });

      test('defaults to false when Hive flag is missing', () {
        final map = {
          'appName': 'test_app',
          'stateManagement': 'provider',
          'platforms': ['mobile'],
          'features': {},
        };
        final config = BlueprintConfig.fromMap(map);
        expect(config.includeHive, isFalse);
      });

      test('copyWith updates Hive flag', () {
        final updated = configWithoutHive.copyWith(includeHive: true);
        expect(updated.includeHive, isTrue);
        expect(configWithoutHive.includeHive, isFalse);
      });
    });

    group('Provider Template Hive Files', () {
      test('generates Hive files when includeHive is true', () {
        final bundle = buildProviderMobileBundle();
        final hiveFiles = bundle.files.where((file) {
          return file.path.contains('hive_database.dart') ||
              file.path.contains('cache_manager.dart') ||
              file.path.contains('sync_manager.dart');
        }).toList();

        expect(hiveFiles.length, equals(3));

        // Check that files should be generated
        for (final file in hiveFiles) {
          final shouldGenerate = file.shouldGenerate?.call(configWithHive);
          expect(shouldGenerate, isTrue);
        }
      });

      test('skips Hive files when includeHive is false', () {
        final bundle = buildProviderMobileBundle();
        final hiveFiles = bundle.files.where((file) {
          return file.path.contains('hive_database.dart') ||
              file.path.contains('cache_manager.dart') ||
              file.path.contains('sync_manager.dart');
        }).toList();

        for (final file in hiveFiles) {
          final shouldGenerate = file.shouldGenerate?.call(configWithoutHive);
          expect(shouldGenerate, isFalse);
        }
      });

      test('generates HiveDatabase with proper structure', () {
        final bundle = buildProviderMobileBundle();
        final hiveDbFile = bundle.files.firstWhere(
          (file) => file.path.contains('hive_database.dart'),
        );

        final content = hiveDbFile.build(configWithHive);

        // Check for essential HiveDatabase components
        expect(content, contains('class HiveDatabase'));
        expect(content, contains('static HiveDatabase get instance'));
        expect(content, contains('Future<void> init()'));
        expect(content, contains('await Hive.initFlutter()'));
        expect(content, contains('Future<Box<T>> openBox<T>'));
        expect(content, contains('Future<void> closeAll()'));
        expect(content, contains('Future<void> deleteBox'));
      });

      test('generates CacheManager with TTL and LRU', () {
        final bundle = buildProviderMobileBundle();
        final cacheFile = bundle.files.firstWhere(
          (file) => file.path.contains('cache_manager.dart'),
        );

        final content = cacheFile.build(configWithHive);

        // Check for CacheManager features
        expect(content, contains('class CacheManager'));
        expect(content, contains('class CacheEntry'));
        expect(content, contains('Future<void> put'));
        expect(content, contains('T? get(String key)'));
        expect(content, contains('isExpired'));
        expect(content, contains('_evictLRU()'));
        expect(content, contains('Future<void> clear()'));
        expect(content, contains('maxSize'));
        expect(content, contains('defaultTTL'));
      });

      test('generates SyncManager with offline queue', () {
        final bundle = buildProviderMobileBundle();
        final syncFile = bundle.files.firstWhere(
          (file) => file.path.contains('sync_manager.dart'),
        );

        final content = syncFile.build(configWithHive);

        // Check for SyncManager features
        expect(content, contains('class SyncManager'));
        expect(content, contains('class SyncOperation'));
        expect(content, contains('Future<void> addToQueue'));
        expect(content, contains('Future<void> sync()'));
        expect(content, contains('maxRetries'));
        expect(content, contains('retryCount'));
        expect(content, contains('enum SyncOperationType'));
      });

      test('includes Hive dependencies in pubspec when enabled', () {
        final bundle = buildProviderMobileBundle();
        final pubspecFile = bundle.files.firstWhere(
          (file) => file.path == 'pubspec.yaml',
        );

        final content = pubspecFile.build(configWithHive);

        expect(content, contains('hive: ^2.2.3'));
        expect(content, contains('hive_flutter: ^1.1.0'));
        expect(content, contains('path_provider: ^2.1.5'));
      });

      test('excludes Hive dependencies when disabled', () {
        final bundle = buildProviderMobileBundle();
        final pubspecFile = bundle.files.firstWhere(
          (file) => file.path == 'pubspec.yaml',
        );

        final content = pubspecFile.build(configWithoutHive);

        expect(content, isNot(contains('hive:')));
        expect(content, isNot(contains('hive_flutter:')));
        expect(content, isNot(contains('path_provider:')));
      });

      test('initializes Hive in main.dart when enabled', () {
        final bundle = buildProviderMobileBundle();
        final mainFile = bundle.files.firstWhere(
          (file) => file.path == 'lib/main.dart',
        );

        final content = mainFile.build(configWithHive);

        expect(content, contains("import 'core/database/hive_database.dart';"));
        expect(content, contains('await HiveDatabase.instance.init();'));
        expect(content, contains('Future<void> main() async'));
        expect(content, contains('WidgetsFlutterBinding.ensureInitialized()'));
      });

      test('skips Hive initialization when disabled', () {
        final bundle = buildProviderMobileBundle();
        final mainFile = bundle.files.firstWhere(
          (file) => file.path == 'lib/main.dart',
        );

        final content = mainFile.build(configWithoutHive);

        expect(content,
            isNot(contains("import 'core/storage/hive_database.dart';")));
        expect(content, isNot(contains('await HiveDatabase.instance.init();')));
      });
    });

    group('Riverpod Template Hive Files', () {
      test('generates Hive files when includeHive is true', () {
        final bundle = buildRiverpodMobileBundle();
        final hiveFiles = bundle.files.where((file) {
          return file.path.contains('hive_database.dart') ||
              file.path.contains('cache_manager.dart') ||
              file.path.contains('sync_manager.dart');
        }).toList();

        expect(hiveFiles.length, equals(3));

        for (final file in hiveFiles) {
          final shouldGenerate = file.shouldGenerate?.call(configWithHive);
          expect(shouldGenerate, isTrue);
        }
      });

      test('includes Hive dependencies in Riverpod pubspec', () {
        final bundle = buildRiverpodMobileBundle();
        final pubspecFile = bundle.files.firstWhere(
          (file) => file.path == 'pubspec.yaml',
        );

        final content = pubspecFile.build(configWithHive);

        expect(content, contains('hive: ^2.2.3'));
        expect(content, contains('hive_flutter: ^1.1.0'));
        expect(content, contains('flutter_riverpod:'));
      });

      test('initializes Hive in Riverpod main.dart', () {
        final bundle = buildRiverpodMobileBundle();
        final mainFile = bundle.files.firstWhere(
          (file) => file.path == 'lib/main.dart',
        );

        final content = mainFile.build(configWithHive);

        expect(content, contains("import 'core/database/hive_database.dart';"));
        expect(content, contains('await HiveDatabase.instance.init();'));
        expect(content, contains('ProviderScope'));
      });
    });

    group('Bloc Template Hive Files', () {
      test('generates Hive files when includeHive is true', () {
        final bundle = buildBlocMobileBundle();
        final hiveFiles = bundle.files.where((file) {
          return file.path.contains('hive_database.dart') ||
              file.path.contains('cache_manager.dart') ||
              file.path.contains('sync_manager.dart');
        }).toList();

        expect(hiveFiles.length, equals(3));

        for (final file in hiveFiles) {
          final shouldGenerate = file.shouldGenerate?.call(configWithHive);
          expect(shouldGenerate, isTrue);
        }
      });

      test('includes Hive dependencies in Bloc pubspec', () {
        final bundle = buildBlocMobileBundle();
        final pubspecFile = bundle.files.firstWhere(
          (file) => file.path == 'pubspec.yaml',
        );

        final content = pubspecFile.build(configWithHive);

        expect(content, contains('hive: ^2.2.3'));
        expect(content, contains('hive_flutter: ^1.1.0'));
        expect(content, contains('flutter_bloc:'));
      });

      test('initializes Hive in Bloc main.dart', () {
        final bundle = buildBlocMobileBundle();
        final mainFile = bundle.files.firstWhere(
          (file) => file.path == 'lib/main.dart',
        );

        final content = mainFile.build(configWithHive);

        expect(content, contains("import 'core/database/hive_database.dart';"));
        expect(content, contains('await HiveDatabase.instance.init();'));
      });
    });

    group('Hive Template Content Validation', () {
      test('HiveDatabase has singleton pattern', () {
        final bundle = buildProviderMobileBundle();
        final hiveDbFile = bundle.files.firstWhere(
          (file) => file.path.contains('hive_database.dart'),
        );

        final content = hiveDbFile.build(configWithHive);

        expect(content, contains('HiveDatabase._()'));
        expect(content, contains('static final HiveDatabase _instance'));
        expect(content, contains('static HiveDatabase get instance'));
      });

      test('CacheManager implements proper eviction', () {
        final bundle = buildProviderMobileBundle();
        final cacheFile = bundle.files.firstWhere(
          (file) => file.path.contains('cache_manager.dart'),
        );

        final content = cacheFile.build(configWithHive);

        expect(content, contains('_box!.length <= maxSize'));
        expect(content, contains('timestamp'));
        expect(content, contains('_box!.delete'));
      });

      test('SyncManager has retry logic', () {
        final bundle = buildProviderMobileBundle();
        final syncFile = bundle.files.firstWhere(
          (file) => file.path.contains('sync_manager.dart'),
        );

        final content = syncFile.build(configWithHive);

        expect(content, contains('operation.retryCount < maxRetries'));
        expect(content, contains('operation.retryCount + 1'));
        expect(content, contains('await Future.delayed'));
      });

      test('all Hive files have proper imports', () {
        final bundle = buildProviderMobileBundle();
        final hiveFiles = bundle.files.where((file) {
          return file.path.contains('hive_database.dart') ||
              file.path.contains('cache_manager.dart') ||
              file.path.contains('sync_manager.dart');
        });

        for (final file in hiveFiles) {
          final content = file.build(configWithHive);
          expect(content,
              contains("import 'package:hive_flutter/hive_flutter.dart';"));
        }
      });
    });

    group('Cross-Template Consistency', () {
      test('all templates generate same Hive files', () {
        final providerBundle = buildProviderMobileBundle();
        final riverpodBundle = buildRiverpodMobileBundle();
        final blocBundle = buildBlocMobileBundle();

        final providerHiveDb = providerBundle.files
            .firstWhere((f) => f.path.contains('hive_database.dart'))
            .build(configWithHive);
        final riverpodHiveDb = riverpodBundle.files
            .firstWhere((f) => f.path.contains('hive_database.dart'))
            .build(configWithHive);
        final blocHiveDb = blocBundle.files
            .firstWhere((f) => f.path.contains('hive_database.dart'))
            .build(configWithHive);

        // All templates should generate identical Hive database code
        expect(providerHiveDb, equals(riverpodHiveDb));
        expect(providerHiveDb, equals(blocHiveDb));
      });

      test('all templates use same dependency versions', () {
        final providerBundle = buildProviderMobileBundle();
        final riverpodBundle = buildRiverpodMobileBundle();
        final blocBundle = buildBlocMobileBundle();

        final providerPubspec = providerBundle.files
            .firstWhere((f) => f.path == 'pubspec.yaml')
            .build(configWithHive);
        final riverpodPubspec = riverpodBundle.files
            .firstWhere((f) => f.path == 'pubspec.yaml')
            .build(configWithHive);
        final blocPubspec = blocBundle.files
            .firstWhere((f) => f.path == 'pubspec.yaml')
            .build(configWithHive);

        // Extract Hive version lines
        final hiveVersionRegex = RegExp(r'hive: \^[\d.]+');
        final hiveFlutterVersionRegex = RegExp(r'hive_flutter: \^[\d.]+');
        final pathProviderVersionRegex = RegExp(r'path_provider: \^[\d.]+');

        expect(
          hiveVersionRegex.stringMatch(providerPubspec),
          equals(hiveVersionRegex.stringMatch(riverpodPubspec)),
        );
        expect(
          hiveVersionRegex.stringMatch(providerPubspec),
          equals(hiveVersionRegex.stringMatch(blocPubspec)),
        );

        expect(
          hiveFlutterVersionRegex.stringMatch(providerPubspec),
          equals(hiveFlutterVersionRegex.stringMatch(riverpodPubspec)),
        );
        expect(
          hiveFlutterVersionRegex.stringMatch(providerPubspec),
          equals(hiveFlutterVersionRegex.stringMatch(blocPubspec)),
        );

        expect(
          pathProviderVersionRegex.stringMatch(providerPubspec),
          equals(pathProviderVersionRegex.stringMatch(riverpodPubspec)),
        );
        expect(
          pathProviderVersionRegex.stringMatch(providerPubspec),
          equals(pathProviderVersionRegex.stringMatch(blocPubspec)),
        );
      });
    });
  });
}
