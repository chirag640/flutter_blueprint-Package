import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/bloc_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/provider_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/riverpod_mobile_template.dart';
import 'package:test/test.dart';

void main() {
  group('Pagination Integration Tests', () {
    late BlueprintConfig configWithPagination;
    late BlueprintConfig configWithoutPagination;

    setUp(() {
      configWithPagination = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includePagination: true,
        includeApi: true,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeTests: true,
      );

      configWithoutPagination = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includePagination: false,
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: false,
      );
    });

    group('BlueprintConfig Pagination Flag', () {
      test('includes Pagination flag in serialization', () {
        final map = configWithPagination.toMap();
        expect(map['features']['pagination'], isTrue);
      });

      test('reads Pagination flag from map', () {
        final map = {
          'appName': 'test_app',
          'stateManagement': 'provider',
          'platforms': ['mobile'],
          'features': {'pagination': true},
        };
        final config = BlueprintConfig.fromMap(map);
        expect(config.includePagination, isTrue);
      });

      test('defaults to false when Pagination flag is missing', () {
        final map = {
          'appName': 'test_app',
          'stateManagement': 'provider',
          'platforms': ['mobile'],
          'features': {},
        };
        final config = BlueprintConfig.fromMap(map);
        expect(config.includePagination, isFalse);
      });

      test('copyWith updates Pagination flag', () {
        final updated =
            configWithoutPagination.copyWith(includePagination: true);
        expect(updated.includePagination, isTrue);
        expect(configWithoutPagination.includePagination, isFalse);
      });
    });

    group('Provider Template Pagination Files', () {
      test('generates Pagination files when includePagination is true', () {
        final bundle = buildProviderMobileBundle();
        final paginationFiles = bundle.files.where((file) {
          return file.path.contains('pagination_controller.dart') ||
              file.path.contains('paginated_list_view.dart') ||
              file.path.contains('skeleton_loader.dart');
        }).toList();

        expect(paginationFiles, hasLength(3));

        for (final file in paginationFiles) {
          final shouldGenerateWith =
              file.shouldGenerate?.call(configWithPagination);
          final shouldGenerateWithout =
              file.shouldGenerate?.call(configWithoutPagination);
          expect(shouldGenerateWith, isTrue);
          expect(shouldGenerateWithout, isFalse);
        }
      });

      test('PaginationController contains expected classes and methods', () {
        final bundle = buildProviderMobileBundle();
        final controllerFile = bundle.files.firstWhere(
          (file) => file.path.contains('pagination_controller.dart'),
        );

        final content = controllerFile.build(configWithPagination);
        expect(content, contains('class PaginationController<T>'));
        expect(content, contains('enum PaginationStatus'));
        expect(content, contains('Future<void> loadFirstPage()'));
        expect(content, contains('Future<void> loadNextPage()'));
        expect(content, contains('Future<void> retry()'));
      });

      test('PaginatedListView contains expected features', () {
        final bundle = buildProviderMobileBundle();
        final listViewFile = bundle.files.firstWhere(
          (file) => file.path.contains('paginated_list_view.dart'),
        );

        final content = listViewFile.build(configWithPagination);
        expect(content, contains('class PaginatedListView<T>'));
        expect(content, contains('RefreshIndicator'));
        expect(content, contains('ScrollController'));
        expect(content, contains('emptyBuilder'));
        expect(content, contains('errorBuilder'));
      });

      test('SkeletonLoader contains animation support', () {
        final bundle = buildProviderMobileBundle();
        final skeletonFile = bundle.files.firstWhere(
          (file) => file.path.contains('skeleton_loader.dart'),
        );

        final content = skeletonFile.build(configWithPagination);
        expect(content, contains('class SkeletonLoader'));
        expect(content, contains('class SkeletonListTile'));
        expect(content, contains('AnimationController'));
        expect(content, contains('SingleTickerProviderStateMixin'));
      });
    });

    group('Riverpod Template Pagination Files', () {
      test('generates Pagination files when includePagination is true', () {
        final config = configWithPagination.copyWith(
          stateManagement: StateManagement.riverpod,
        );
        final bundle = buildRiverpodMobileBundle();
        final paginationFiles = bundle.files.where((file) {
          return file.path.contains('pagination_controller.dart') ||
              file.path.contains('paginated_list_view.dart') ||
              file.path.contains('skeleton_loader.dart');
        }).toList();

        expect(paginationFiles, hasLength(3));

        for (final file in paginationFiles) {
          final shouldGenerate = file.shouldGenerate?.call(config);
          expect(shouldGenerate, isTrue);
        }
      });
    });

    group('Bloc Template Pagination Files', () {
      test('generates Pagination files when includePagination is true', () {
        final config = configWithPagination.copyWith(
          stateManagement: StateManagement.bloc,
        );
        final bundle = buildBlocMobileBundle();
        final paginationFiles = bundle.files.where((file) {
          return file.path.contains('pagination_controller.dart') ||
              file.path.contains('paginated_list_view.dart') ||
              file.path.contains('skeleton_loader.dart');
        }).toList();

        expect(paginationFiles, hasLength(3));

        for (final file in paginationFiles) {
          final shouldGenerate = file.shouldGenerate?.call(config);
          expect(shouldGenerate, isTrue);
        }
      });
    });
  });
}
