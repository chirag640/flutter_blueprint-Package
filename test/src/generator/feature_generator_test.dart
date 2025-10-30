import 'dart:io';

import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/generator/feature_generator.dart';
import 'package:flutter_blueprint/src/utils/io_utils.dart';
import 'package:flutter_blueprint/src/utils/logger.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late FeatureGenerator generator;

  setUp(() async {
    // Create temporary directory for tests
    tempDir = await Directory.systemTemp.createTemp('feature_gen_test_');
    generator = FeatureGenerator(
      ioUtils: const IoUtils(),
      logger: Logger(),
    );
  });

  tearDown(() async {
    // Clean up temp directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FeatureGenerator -', () {
    test('generates all layers with Provider state management', () async {
      // Arrange
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      // Act
      await generator.generate(
        featureName: 'auth',
        config: config,
        targetPath: tempDir.path,
        includeData: true,
        includeDomain: true,
        includePresentation: true,
        includeApi: false,
        updateRouter: false, // Skip router for this test
      );

      // Assert - Check data layer files
      expect(
        File('${tempDir.path}/lib/features/auth/data/models/auth_model.dart')
            .existsSync(),
        isTrue,
        reason: 'Auth model should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/auth/data/datasources/auth_local_data_source.dart')
            .existsSync(),
        isTrue,
        reason: 'Local data source should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/auth/data/repositories/auth_repository_impl.dart')
            .existsSync(),
        isTrue,
        reason: 'Repository implementation should be generated',
      );

      // Assert - Check domain layer files
      expect(
        File('${tempDir.path}/lib/features/auth/domain/entities/auth_entity.dart')
            .existsSync(),
        isTrue,
        reason: 'Auth entity should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/auth/domain/repositories/auth_repository.dart')
            .existsSync(),
        isTrue,
        reason: 'Repository contract should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/auth/domain/usecases/get_auth_list.dart')
            .existsSync(),
        isTrue,
        reason: 'Use cases should be generated',
      );

      // Assert - Check presentation layer files
      expect(
        File('${tempDir.path}/lib/features/auth/presentation/pages/auth_page.dart')
            .existsSync(),
        isTrue,
        reason: 'Auth page should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/auth/presentation/widgets/auth_list_item.dart')
            .existsSync(),
        isTrue,
        reason: 'List item widget should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/auth/presentation/provider/auth_provider.dart')
            .existsSync(),
        isTrue,
        reason:
            'Provider file should be generated for Provider state management',
      );
    });

    test('generates Riverpod state management files', () async {
      // Arrange
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.riverpod,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      // Act
      await generator.generate(
        featureName: 'profile',
        config: config,
        targetPath: tempDir.path,
        includeData: false,
        includeDomain: false,
        includePresentation: true,
        includeApi: false,
        updateRouter: false,
      );

      // Assert
      final providerFile = File(
        '${tempDir.path}/lib/features/profile/presentation/provider/profile_provider.dart',
      );

      expect(
        providerFile.existsSync(),
        isTrue,
        reason: 'Riverpod provider file should be generated',
      );

      // Check content has Riverpod-specific code
      final content = await providerFile.readAsString();
      expect(content.contains('StateNotifier'), isTrue);
      expect(content.contains('StateNotifierProvider'), isTrue);
      expect(content.contains('sealed class'), isTrue);
    });

    test('generates Bloc state management files', () async {
      // Arrange
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.bloc,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      // Act
      await generator.generate(
        featureName: 'products',
        config: config,
        targetPath: tempDir.path,
        includeData: false,
        includeDomain: false,
        includePresentation: true,
        includeApi: false,
        updateRouter: false,
      );

      // Assert - Check all three Bloc files
      expect(
        File('${tempDir.path}/lib/features/products/presentation/bloc/products_event.dart')
            .existsSync(),
        isTrue,
        reason: 'Bloc event file should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/products/presentation/bloc/products_state.dart')
            .existsSync(),
        isTrue,
        reason: 'Bloc state file should be generated',
      );

      expect(
        File('${tempDir.path}/lib/features/products/presentation/bloc/products_bloc.dart')
            .existsSync(),
        isTrue,
        reason: 'Bloc file should be generated',
      );
    });

    test('generates remote data source when --api flag is used', () async {
      // Arrange
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      // Act
      await generator.generate(
        featureName: 'orders',
        config: config,
        targetPath: tempDir.path,
        includeData: true,
        includeDomain: false,
        includePresentation: false,
        includeApi: true, // Enable API
        updateRouter: false,
      );

      // Assert
      expect(
        File('${tempDir.path}/lib/features/orders/data/datasources/orders_remote_data_source.dart')
            .existsSync(),
        isTrue,
        reason:
            'Remote data source should be generated when API flag is enabled',
      );

      // Check content has Dio imports
      final remoteFile = File(
        '${tempDir.path}/lib/features/orders/data/datasources/orders_remote_data_source.dart',
      );
      final content = await remoteFile.readAsString();
      expect(content.contains('import \'package:dio/dio.dart\';'), isTrue);
    });

    test('skips layers based on flags', () async {
      // Arrange
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      // Act - Only generate presentation layer
      await generator.generate(
        featureName: 'settings',
        config: config,
        targetPath: tempDir.path,
        includeData: false,
        includeDomain: false,
        includePresentation: true,
        includeApi: false,
        updateRouter: false,
      );

      // Assert - Data layer should NOT exist
      expect(
        Directory('${tempDir.path}/lib/features/settings/data').existsSync(),
        isFalse,
        reason: 'Data layer should not be generated when includeData is false',
      );

      // Assert - Domain layer should NOT exist
      expect(
        Directory('${tempDir.path}/lib/features/settings/domain').existsSync(),
        isFalse,
        reason:
            'Domain layer should not be generated when includeDomain is false',
      );

      // Assert - Presentation layer SHOULD exist
      expect(
        Directory('${tempDir.path}/lib/features/settings/presentation')
            .existsSync(),
        isTrue,
        reason:
            'Presentation layer should be generated when includePresentation is true',
      );
    });

    test('router update adds route to existing router file', () async {
      // Arrange
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      // Create mock router file
      final routerDir = Directory('${tempDir.path}/lib/core/routing');
      await routerDir.create(recursive: true);
      final routerFile = File('${routerDir.path}/app_router.dart');
      await routerFile.writeAsString('''
import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';

class RouteNames {
  static const String home = '/';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
''');

      // Act
      await generator.generate(
        featureName: 'dashboard',
        config: config,
        targetPath: tempDir.path,
        includeData: false,
        includeDomain: false,
        includePresentation: true,
        includeApi: false,
        updateRouter: true, // Enable router update
      );

      // Assert
      final updatedContent = await routerFile.readAsString();

      expect(
        updatedContent.contains(
            "import '../../features/dashboard/presentation/pages/dashboard_page.dart';"),
        isTrue,
        reason: 'Router should include import for new page',
      );

      expect(
        updatedContent
            .contains("static const String dashboard = '/dashboard';"),
        isTrue,
        reason: 'Router should include route constant',
      );

      expect(
        updatedContent.contains('case RouteNames.dashboard:'),
        isTrue,
        reason: 'Router should include case for new route',
      );

      expect(
        updatedContent.contains('const DashboardPage()'),
        isTrue,
        reason: 'Router should instantiate the new page',
      );
    });

    test('skips router update when updateRouter is false', () async {
      // Arrange
      final config = BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      // Create mock router file
      final routerDir = Directory('${tempDir.path}/lib/core/routing');
      await routerDir.create(recursive: true);
      final routerFile = File('${routerDir.path}/app_router.dart');
      final originalContent = '''
import 'package:flutter/material.dart';

class RouteNames {
  static const String home = '/';
}
''';
      await routerFile.writeAsString(originalContent);

      // Act
      await generator.generate(
        featureName: 'admin',
        config: config,
        targetPath: tempDir.path,
        includeData: false,
        includeDomain: false,
        includePresentation: true,
        includeApi: false,
        updateRouter: false, // Disable router update
      );

      // Assert
      final updatedContent = await routerFile.readAsString();

      expect(
        updatedContent,
        equals(originalContent),
        reason: 'Router should not be modified when updateRouter is false',
      );

      expect(
        updatedContent.contains('admin'),
        isFalse,
        reason: 'Router should not contain any reference to the new feature',
      );
    });
  });
}
