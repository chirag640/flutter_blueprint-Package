import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import 'accessibility_templates.dart';
import 'analytics_templates.dart';
import 'hive_templates.dart';
import 'pagination_templates.dart';
import 'template_bundle.dart';
import 'shared_templates.dart';
import 'ui_kit_templates.dart';

/// Builds a Riverpod-based mobile template with professional architecture
TemplateBundle buildRiverpodMobileBundle() {
  return TemplateBundle(
    files: [
      // Base config files
      TemplateFile(path: 'analysis_options.yaml', build: _analysisOptions),
      TemplateFile(path: 'pubspec.yaml', build: _pubspec),
      TemplateFile(path: '.gitignore', build: _gitignore),
      TemplateFile(path: 'README.md', build: _readme),

      // Main app
      TemplateFile(path: 'lib/main.dart', build: _mainDart),
      TemplateFile(path: p.join('lib', 'app', 'app.dart'), build: _appDart),

      // Core: Config
      TemplateFile(
          path: p.join('lib', 'core', 'config', 'app_config.dart'),
          build: _appConfig),
      TemplateFile(
          path: p.join('lib', 'core', 'config', 'env_loader.dart'),
          build: _envLoader,
          shouldGenerate: (config) => config.includeEnv),

      // Core: Constants
      TemplateFile(
          path: p.join('lib', 'core', 'constants', 'app_constants.dart'),
          build: _appConstants),
      TemplateFile(
          path: p.join('lib', 'core', 'constants', 'api_endpoints.dart'),
          build: _apiEndpoints,
          shouldGenerate: (config) => config.includeApi),

      // Core: Errors
      TemplateFile(
          path: p.join('lib', 'core', 'errors', 'exceptions.dart'),
          build: _exceptions),
      TemplateFile(
          path: p.join('lib', 'core', 'errors', 'failures.dart'),
          build: _failures),

      // Core: Network
      TemplateFile(
          path: p.join('lib', 'core', 'network', 'network_info.dart'),
          build: _networkInfo,
          shouldGenerate: (config) => config.includeApi),

      // Core: Utils
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'logger.dart'), build: _logger),
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'validators.dart'),
          build: _validators),
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'extensions.dart'),
          build: _extensions),
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'dialog_utils.dart'),
          build: _dialogUtils),
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'snackbar_utils.dart'),
          build: _snackbarUtils),
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'network_settings.dart'),
          build: _networkSettings,
          shouldGenerate: (config) => config.includeApi),

      // Core: Routing
      TemplateFile(
          path: p.join('lib', 'core', 'routing', 'app_router.dart'),
          build: _appRouter),
      TemplateFile(
          path: p.join('lib', 'core', 'routing', 'route_guard.dart'),
          build: _routeGuard),
      TemplateFile(
          path: p.join('lib', 'core', 'routing', 'route_names.dart'),
          build: _routeNames),

      // Core: Theme
      TemplateFile(
          path: p.join('lib', 'core', 'theme', 'app_theme.dart'),
          build: _appTheme,
          shouldGenerate: (config) => config.includeTheme),
      TemplateFile(
          path: p.join('lib', 'core', 'theme', 'typography.dart'),
          build: _typography,
          shouldGenerate: (config) => config.includeTheme),
      TemplateFile(
          path: p.join('lib', 'core', 'theme', 'app_colors.dart'),
          build: _appColors,
          shouldGenerate: (config) => config.includeTheme),

      // Core: Widgets (Common/Reusable)
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'loading_indicator.dart'),
          build: _loadingIndicator),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'error_view.dart'),
          build: _errorView),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'empty_state.dart'),
          build: _emptyState),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'custom_button.dart'),
          build: _customButton),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'custom_text_field.dart'),
          build: _customTextField),
      // UI Kit — always generated, zero extra deps
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'app_responsive.dart'),
          build: (c) => generateAppResponsive(c)),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'validation_ack_scope.dart'),
          build: (c) => generateValidationAckScope(c)),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'widgets', 'app_text_field_with_label.dart'),
          build: (c) => generateAppTextFieldWithLabel(c)),
      TemplateFile(
          path:
              p.join('lib', 'core', 'widgets', 'app_dropdown_form_field.dart'),
          build: (c) => generateAppDropdownFormField(c)),

      // Core: API
      TemplateFile(
          path: p.join('lib', 'core', 'api', 'api_client.dart'),
          build: _apiClient,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'core', 'api', 'api_response.dart'),
          build: _apiResponse,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'api', 'interceptors', 'auth_interceptor.dart'),
          build: _authInterceptor,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'api', 'interceptors', 'logger_interceptor.dart'),
          build: _loggerInterceptor,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'api', 'interceptors', 'retry_interceptor.dart'),
          build: _retryInterceptor,
          shouldGenerate: (config) => config.includeApi),

      // Core: Storage
      TemplateFile(
          path: p.join('lib', 'core', 'storage', 'local_storage.dart'),
          build: _localStorage),
      TemplateFile(
          path: p.join('lib', 'core', 'storage', 'secure_storage.dart'),
          build: _secureStorage),
      TemplateFile(
          path: p.join('lib', 'core', 'database', 'hive_database.dart'),
          build: _hiveDatabase,
          shouldGenerate: (config) => config.includeHive),
      TemplateFile(
          path: p.join('lib', 'core', 'database', 'cache_manager.dart'),
          build: _cacheManager,
          shouldGenerate: (config) => config.includeHive),
      TemplateFile(
          path: p.join('lib', 'core', 'database', 'sync_manager.dart'),
          build: _syncManager,
          shouldGenerate: (config) => config.includeHive),

      // Core: Pagination
      TemplateFile(
          path:
              p.join('lib', 'core', 'pagination', 'pagination_controller.dart'),
          build: _paginationController,
          shouldGenerate: (config) => config.includePagination),
      TemplateFile(
          path: p.join('lib', 'core', 'pagination', 'paginated_list_view.dart'),
          build: _paginatedListView,
          shouldGenerate: (config) => config.includePagination),
      TemplateFile(
          path: p.join('lib', 'core', 'pagination', 'skeleton_loader.dart'),
          build: _skeletonLoader,
          shouldGenerate: (config) => config.includePagination),

      // Core: Analytics
      TemplateFile(
          path: p.join('lib', 'core', 'analytics', 'analytics_service.dart'),
          build: _analyticsService,
          shouldGenerate: (config) => config.includeAnalytics),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'analytics', 'firebase_analytics_service.dart'),
          build: _firebaseAnalyticsService,
          shouldGenerate: (config) =>
              config.includeAnalytics &&
              config.analyticsProvider == AnalyticsProvider.firebase),
      TemplateFile(
          path: p.join('lib', 'core', 'analytics', 'sentry_service.dart'),
          build: _sentryService,
          shouldGenerate: (config) =>
              config.includeAnalytics &&
              config.analyticsProvider == AnalyticsProvider.sentry),
      TemplateFile(
          path: p.join('lib', 'core', 'analytics', 'analytics_events.dart'),
          build: _analyticsEvents,
          shouldGenerate: (config) => config.includeAnalytics),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'error_boundary.dart'),
          build: _errorBoundary,
          shouldGenerate: (config) => config.includeAnalytics),

      // Core: Accessibility
      TemplateFile(
          path: p.join('lib', 'core', 'accessibility', 'semantics_helper.dart'),
          build: _semanticsHelper,
          shouldGenerate: (config) => config.includeAccessibility),
      TemplateFile(
          path: p.join('lib', 'core', 'accessibility', 'contrast_checker.dart'),
          build: _contrastChecker,
          shouldGenerate: (config) => config.includeAccessibility),
      TemplateFile(
          path: p.join('lib', 'core', 'accessibility', 'focus_manager.dart'),
          build: _focusManager,
          shouldGenerate: (config) => config.includeAccessibility),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'accessibility', 'accessibility_config.dart'),
          build: _accessibilityConfig,
          shouldGenerate: (config) => config.includeAccessibility),
      TemplateFile(
          path: p.join('test', 'accessibility', 'a11y_test_utils.dart'),
          build: _accessibilityTestUtils,
          shouldGenerate: (config) =>
              config.includeAccessibility && config.includeTests),

      // Core: Providers (Global Riverpod providers)
      TemplateFile(
          path: p.join('lib', 'core', 'providers', 'app_providers.dart'),
          build: _appProviders),

      // Features: Home
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'pages',
              'home_page.dart'),
          build: _homePage),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'providers',
              'home_provider.dart'),
          build: _homeProvider),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'widgets',
              'home_content.dart'),
          build: _homeContent),

      // Features: Auth (Login, Register, Token Management)
      // Domain Layer
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'domain', 'entities',
              'user_entity.dart'),
          build: _authUserEntity,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'domain', 'repositories',
              'auth_repository.dart'),
          build: _authRepository,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'domain', 'usecases',
              'login_usecase.dart'),
          build: _authLoginUsecase,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'domain', 'usecases',
              'register_usecase.dart'),
          build: _authRegisterUsecase,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'domain', 'usecases',
              'logout_usecase.dart'),
          build: _authLogoutUsecase,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'domain', 'usecases',
              'get_current_user_usecase.dart'),
          build: _authGetCurrentUserUsecase,
          shouldGenerate: (config) => config.includeApi),

      // Data Layer
      TemplateFile(
          path: p.join(
              'lib', 'features', 'auth', 'data', 'models', 'user_model.dart'),
          build: _authUserModel,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'data', 'models',
              'auth_response_model.dart'),
          build: _authResponseModel,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'data', 'datasources',
              'auth_remote_data_source.dart'),
          build: _authRemoteDataSource,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'data', 'datasources',
              'auth_local_data_source.dart'),
          build: _authLocalDataSource,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'data', 'repositories',
              'auth_repository_impl.dart'),
          build: _authRepositoryImpl,
          shouldGenerate: (config) => config.includeApi),

      // Presentation Layer
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'pages',
              'login_page.dart'),
          build: _authLoginPage,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'pages',
              'register_page.dart'),
          build: _authRegisterPage,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'widgets',
              'auth_text_field.dart'),
          build: _authTextField,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'widgets',
              'auth_button.dart'),
          build: _authButton,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'providers',
              'auth_provider.dart'),
          build: _authProvider,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'providers',
              'login_form_provider.dart'),
          build: _authLoginFormProvider,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'providers',
              'register_form_provider.dart'),
          build: _authRegisterFormProvider,
          shouldGenerate: (config) => config.includeApi),

      // Features: Profile (View, Edit, Avatar Upload)
      // Data Layer
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'data', 'models',
              'profile_model.dart'),
          build: _profileModel,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'data', 'datasources',
              'profile_remote_data_source.dart'),
          build: _profileRemoteDataSource,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'data', 'datasources',
              'profile_local_data_source.dart'),
          build: _profileLocalDataSource,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'data', 'repositories',
              'profile_repository_impl.dart'),
          build: _profileRepositoryImpl,
          shouldGenerate: (config) => config.includeApi),

      // Domain Layer
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'domain', 'repositories',
              'profile_repository.dart'),
          build: _profileRepository,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'domain', 'usecases',
              'get_profile_usecase.dart'),
          build: _profileGetUsecase,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'domain', 'usecases',
              'update_profile_usecase.dart'),
          build: _profileUpdateUsecase,
          shouldGenerate: (config) => config.includeApi),

      // Presentation Layer
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'presentation', 'pages',
              'profile_page.dart'),
          build: _profilePage,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'presentation', 'pages',
              'edit_profile_page.dart'),
          build: _editProfilePage,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'presentation',
              'providers', 'profile_provider.dart'),
          build: _profileProvider,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'presentation',
              'providers', 'profile_form_provider.dart'),
          build: _profileFormProvider,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'presentation', 'widgets',
              'profile_avatar.dart'),
          build: _profileAvatar,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'presentation', 'widgets',
              'profile_info_tile.dart'),
          build: _profileInfoTile,
          shouldGenerate: (config) => config.includeApi),

      // Features: Settings (App preferences, Theme, Notifications, etc.)
      // Presentation Layer (settings don't need full domain/data layers)
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation', 'pages',
              'settings_page.dart'),
          build: _settingsPage,
          shouldGenerate: (config) => true), // Always generate settings
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation',
              'providers', 'settings_provider.dart'),
          build: _settingsProvider,
          shouldGenerate: (config) => true),
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation', 'widgets',
              'settings_tile.dart'),
          build: _settingsTile,
          shouldGenerate: (config) => true),
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation', 'widgets',
              'settings_section.dart'),
          build: _settingsSection,
          shouldGenerate: (config) => true),

      // Localization
      TemplateFile(
          path: p.join('assets', 'l10n', 'en.arb'),
          build: _enLocalization,
          shouldGenerate: (config) => config.includeLocalization),
      TemplateFile(
          path: p.join('assets', 'l10n', 'hi.arb'),
          build: _hiLocalization,
          shouldGenerate: (config) => config.includeLocalization),

      // Environment
      TemplateFile(
          path: '.env.example',
          build: _envExample,
          shouldGenerate: (config) => config.includeEnv),

      // Tests
      TemplateFile(
          path: 'test/widget_test.dart',
          build: _widgetTest,
          shouldGenerate: (config) => config.includeTests),
      TemplateFile(
          path: 'test/core/utils/validators_test.dart',
          build: _validatorsTest,
          shouldGenerate: (config) => config.includeTests),
      TemplateFile(
          path: 'test/helpers/test_helpers.dart',
          build: _testHelpers,
          shouldGenerate: (config) => config.includeTests),
    ],
  );
}

String _analysisOptions(BlueprintConfig config) {
  return 'include: package:flutter_lints/flutter.yaml';
}

String _pubspec(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln('name: ${config.appName}')
    ..writeln(
        'description: "A Flutter app scaffolded by flutter_blueprint with Riverpod."')
    ..writeln('publish_to: "none"')
    ..writeln('')
    ..writeln('version: 0.1.0+1')
    ..writeln('')
    ..writeln('environment:')
    ..writeln('  sdk: ">=3.3.0 <4.0.0"')
    ..writeln('  flutter: ">=3.24.0"')
    ..writeln('')
    ..writeln('dependencies:')
    ..writeln('  flutter:')
    ..writeln('    sdk: flutter');

  // Use Riverpod instead of Provider
  buffer.writeln('  flutter_riverpod: ^2.6.1');
  buffer.writeln('  shared_preferences: ^2.2.3');
  buffer.writeln('  flutter_secure_storage: ^9.2.2');
  buffer.writeln('  equatable: ^2.0.5');

  if (config.includeLocalization) {
    buffer
      ..writeln('  flutter_localizations:')
      ..writeln('    sdk: flutter')
      ..writeln('  intl: ^0.20.2');
  }
  if (config.includeEnv) {
    buffer.writeln('  flutter_dotenv: ^5.1.0');
  }
  if (config.includeApi) {
    buffer
      ..writeln('  dio: ^5.5.0')
      ..writeln('  connectivity_plus: ^6.0.5')
      ..writeln('  pretty_dio_logger: ^1.4.0');
  }
  if (config.includeHive) {
    buffer
      ..writeln('  hive: ^2.2.3')
      ..writeln('  hive_flutter: ^1.1.0')
      ..writeln('  path_provider: ^2.1.5');
  }
  if (config.includeAnalytics) {
    if (config.analyticsProvider == AnalyticsProvider.sentry) {
      buffer.writeln('  sentry_flutter: ^8.9.0');
    } else if (config.analyticsProvider == AnalyticsProvider.firebase) {
      buffer
        ..writeln('  firebase_core: ^3.6.0')
        ..writeln('  firebase_analytics: ^11.3.3')
        ..writeln('  firebase_crashlytics: ^4.1.3')
        ..writeln('  firebase_performance: ^0.10.0+8');
    }
  }

  buffer
    ..writeln('')
    ..writeln('dev_dependencies:')
    ..writeln('  flutter_test:')
    ..writeln('    sdk: flutter')
    ..writeln('  flutter_lints: ^5.0.0');
  if (config.includeTests) {
    buffer.writeln('  mocktail: ^1.0.3');
  }

  buffer
    ..writeln('')
    ..writeln('flutter:')
    ..writeln('  uses-material-design: true');
  if (config.includeLocalization) {
    buffer
      ..writeln('  assets:')
      ..writeln('    - assets/l10n/');
  }
  return buffer.toString().trimRight();
}

String _gitignore(BlueprintConfig config) {
  return '# Flutter generated files\n.dart_tool/\n.packages\nbuild/\n.env\n';
}

String _readme(BlueprintConfig config) {
  return '# ${_titleCase(config.appName)}\n\nGenerated with flutter_blueprint using **Riverpod** state management.\n\n## Getting Started\n\n```bash\nflutter pub get\nflutter run\n```\n\n- State management: ${config.stateManagement.label}\n- Platform target: ${config.platforms.map((p) => p.label).join(", ")}\n\n## Riverpod Features\n\n- ✅ Compile-time safety\n- ✅ Better testability (no BuildContext required)\n- ✅ StateNotifier pattern for complex state\n- ✅ Automatic disposal and memory management\n';
}

String _mainDart(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:flutter_riverpod/flutter_riverpod.dart';")
    ..writeln("import 'app/app.dart';");
  if (config.includeEnv) {
    buffer.writeln("import 'core/config/env_loader.dart';");
  }
  if (config.includeHive) {
    buffer.writeln("import 'core/database/hive_database.dart';");
  }
  // LocalStorage always needs async init
  buffer
    ..writeln("import 'core/storage/local_storage.dart';")
    ..writeln("import 'core/providers/app_providers.dart';");
  buffer
    ..writeln('')
    ..writeln('Future<void> main() async {')
    ..writeln('  WidgetsFlutterBinding.ensureInitialized();');
  if (config.includeEnv) {
    buffer.writeln("  await EnvLoader.load();");
  }
  if (config.includeHive) {
    buffer.writeln("  await HiveDatabase.instance.init();");
  }
  buffer
    ..writeln('  final localStorage = await LocalStorage.getInstance();')
    ..writeln('  runApp(')
    ..writeln('    ProviderScope(')
    ..writeln('      overrides: [')
    ..writeln('        localStorageProvider.overrideWithValue(localStorage),')
    ..writeln('      ],')
    ..writeln('      child: const App(),')
    ..writeln('    ),')
    ..writeln('  );')
    ..writeln('}');
  return buffer.toString();
}

String _appDart(BlueprintConfig config) {
  final title = _titleCase(config.appName);
  final buffer = StringBuffer()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:flutter_riverpod/flutter_riverpod.dart';")
    ..writeln("import '../core/routing/app_router.dart';");
  if (config.includeTheme) {
    buffer.writeln("import '../core/theme/app_theme.dart';");
  }
  if (config.includeLocalization) {
    buffer.writeln(
        "import 'package:flutter_localizations/flutter_localizations.dart';");
  }
  if (config.includeApi) {
    buffer.writeln(
        "import '../features/auth/presentation/providers/auth_provider.dart';");
  }
  if (config.includeApi) {
    buffer.writeln("import '../core/theme/app_theme.dart' show AppTheme;");
  }

  buffer
    ..writeln('')
    ..writeln('class App extends ConsumerWidget {')
    ..writeln('  const App({super.key});')
    ..writeln('')
    ..writeln('  @override')
    ..writeln('  Widget build(BuildContext context, WidgetRef ref) {');

  if (config.includeApi) {
    buffer
      ..writeln('    final authState = ref.watch(authProvider);')
      ..writeln('    final router = AppRouter();')
      ..writeln('')
      ..writeln('    // Determine initial route based on auth status')
      ..writeln('    String initialRoute;')
      ..writeln('    if (authState.isLoading) {')
      ..writeln('      // Show loading screen while checking auth status')
      ..writeln('      return MaterialApp(')
      ..writeln("        title: '$title',");
    if (config.includeTheme) {
      buffer
        ..writeln('        theme: AppTheme.light(),')
        ..writeln('        darkTheme: AppTheme.dark(),')
        ..writeln('        themeMode: ThemeMode.system,');
    }
    buffer
      ..writeln('        home: const Scaffold(')
      ..writeln('          body: Center(')
      ..writeln('            child: CircularProgressIndicator(),')
      ..writeln('          ),')
      ..writeln('        ),')
      ..writeln('      );')
      ..writeln('    } else if (authState.isAuthenticated) {')
      ..writeln('      initialRoute = AppRouter.home;')
      ..writeln('    } else {')
      ..writeln('      initialRoute = AppRouter.login;')
      ..writeln('    }')
      ..writeln('')
      ..writeln('    return MaterialApp(')
      ..writeln("        title: '$title',");
  } else {
    buffer
      ..writeln('    final router = AppRouter();')
      ..writeln('    return MaterialApp(')
      ..writeln("        title: '$title',");
  }

  if (config.includeTheme) {
    buffer
      ..writeln('        theme: AppTheme.light(),')
      ..writeln('        darkTheme: AppTheme.dark(),')
      ..writeln('        themeMode: ThemeMode.system,');
  }

  if (config.includeApi) {
    buffer.writeln('        initialRoute: initialRoute,');
  } else {
    buffer.writeln('        initialRoute: AppRouter.home,');
  }

  buffer.writeln('        onGenerateRoute: router.onGenerateRoute,');
  if (config.includeLocalization) {
    buffer
      ..writeln('        localizationsDelegates: const [')
      ..writeln('          GlobalMaterialLocalizations.delegate,')
      ..writeln('          GlobalWidgetsLocalizations.delegate,')
      ..writeln('          GlobalCupertinoLocalizations.delegate,')
      ..writeln('        ],')
      ..writeln('        supportedLocales: const [')
      ..writeln("          Locale('en'),")
      ..writeln("          Locale('hi'),")
      ..writeln('        ],');
  }
  buffer
    ..writeln('      );')
    ..writeln('  }')
    ..writeln('}');
  return buffer.toString();
}

String _appConfig(BlueprintConfig config) {
  final buffer = StringBuffer();
  if (config.includeEnv) {
    buffer.writeln("import 'env_loader.dart';");
    buffer.writeln('');
  }

  buffer
    ..writeln('class AppConfig {')
    ..writeln('  const AppConfig({')
    ..writeln('    required this.appTitle,')
    ..writeln('    required this.environment,')
    ..writeln('    required this.apiBaseUrl,')
    ..writeln('  });')
    ..writeln('')
    ..writeln('  final String appTitle;')
    ..writeln('  final String environment;')
    ..writeln('  final String apiBaseUrl;')
    ..writeln('')
    ..writeln('  static AppConfig load() {')
    ..writeln("    return AppConfig(")
    ..writeln("      appTitle: '${_titleCase(config.appName)}',");
  if (config.includeEnv) {
    buffer.writeln('      environment: EnvLoader.currentEnvironment.name,');
  } else {
    buffer.writeln("      environment: 'production',");
  }
  if (config.includeApi) {
    if (config.includeEnv) {
      buffer.writeln('      apiBaseUrl: EnvLoader.apiBaseUrl,');
    } else {
      buffer
          .writeln("      apiBaseUrl: 'https://jsonplaceholder.typicode.com',");
    }
  } else {
    buffer.writeln("      apiBaseUrl: '',");
  }
  buffer
    ..writeln('    );')
    ..writeln('  }')
    ..writeln('}');
  return buffer.toString();
}

String _envLoader(BlueprintConfig config) {
  return """import 'package:flutter_dotenv/flutter_dotenv.dart';\n\nenum AppEnvironment { dev, stage, prod }\n\nclass EnvLoader {\n  static AppEnvironment currentEnvironment = AppEnvironment.dev;\n\n  static Future<void> load({String fileName = '.env'}) async {\n    await dotenv.load(fileName: fileName, mergeWith: {});\n    final envName = dotenv.maybeGet('APP_ENV') ?? 'dev';\n    currentEnvironment = AppEnvironment.values.firstWhere(\n      (element) => element.name == envName,\n      orElse: () => AppEnvironment.dev,\n    );\n  }\n\n  static String get apiBaseUrl =>\n      dotenv.maybeGet('API_BASE_URL') ?? 'https://api.example.com';\n}\n""";
}

String _appRouter(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln("import '../../features/home/presentation/pages/home_page.dart';")
    ..writeln(
        "import '../../features/settings/presentation/pages/settings_page.dart';");

  // Add auth imports if API is enabled
  if (config.includeApi) {
    buffer
      ..writeln(
          "import '../../features/auth/presentation/pages/login_page.dart';")
      ..writeln(
          "import '../../features/auth/presentation/pages/register_page.dart';")
      ..writeln(
          "import '../../features/profile/presentation/pages/profile_page.dart';")
      ..writeln(
          "import '../../features/profile/presentation/pages/edit_profile_page.dart';");
  }

  buffer
    ..writeln("import 'route_guard.dart';")
    ..writeln()
    ..writeln('class AppRouter {')
    ..writeln("  static const home = '/';")
    ..writeln("  static const settings = '/settings';");

  // Add auth routes if API is enabled
  if (config.includeApi) {
    buffer
      ..writeln("  static const login = '/login';")
      ..writeln("  static const register = '/register';")
      ..writeln("  static const profile = '/profile';")
      ..writeln("  static const editProfile = '/edit-profile';");
  }

  buffer
    ..writeln()
    ..writeln(
        '  Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {')
    ..writeln('    switch (routeSettings.name) {')
    ..writeln('      case home:')
    ..writeln(
        '        return MaterialPageRoute(builder: (_) => const HomePage());')
    ..writeln('      case settings:')
    ..writeln(
        '        return MaterialPageRoute(builder: (_) => const SettingsPage());');

  // Add auth route cases if API is enabled
  if (config.includeApi) {
    buffer
      ..writeln('      case login:')
      ..writeln(
          '        return MaterialPageRoute(builder: (_) => const LoginPage());')
      ..writeln('      case register:')
      ..writeln(
          '        return MaterialPageRoute(builder: (_) => const RegisterPage());')
      ..writeln('      case profile:')
      ..writeln(
          '        return MaterialPageRoute(builder: (_) => const ProfilePage());')
      ..writeln('      case editProfile:')
      ..writeln(
          '        return MaterialPageRoute(builder: (_) => const EditProfilePage());');
  }

  buffer
    ..writeln('      default:')
    ..writeln(
        '        return MaterialPageRoute(builder: (_) => const HomePage());')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln()
    ..writeln('  Route<dynamic> guarded({')
    ..writeln('    required RouteSettings routeSettings,')
    ..writeln('    required RouteGuard guard,')
    ..writeln('    required WidgetBuilder builder,')
    ..writeln('  }) {')
    ..writeln('    return MaterialPageRoute(')
    ..writeln('      settings: routeSettings,')
    ..writeln('      builder: (context) {')
    ..writeln('        if (!guard.canActivate(routeSettings)) {')
    ..writeln('          return guard.fallback(context: context);')
    ..writeln('        }')
    ..writeln('        return builder(context);')
    ..writeln('      },')
    ..writeln('    );')
    ..writeln('  }')
    ..writeln('}');
  return buffer.toString();
}

String _routeGuard(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';\n\nabstract class RouteGuard {\n  const RouteGuard();\n\n  bool canActivate(RouteSettings settings);\n\n  Widget fallback({required BuildContext context});\n}\n""";
}

String _appTheme(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';\n\nimport 'typography.dart';\n\nclass AppTheme {\n  const AppTheme._();\n\n  static ThemeData light() {\n    return ThemeData(\n      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066FF)),\n      brightness: Brightness.light,\n      textTheme: buildTextTheme(),\n      appBarTheme: const AppBarTheme(centerTitle: true),\n    );\n  }\n\n  static ThemeData dark() {\n    return ThemeData(\n      colorScheme: ColorScheme.fromSeed(\n        seedColor: const Color(0xFF66AAFF),\n        brightness: Brightness.dark,\n      ),\n      textTheme: buildTextTheme(),\n    );\n  }\n}\n""";
}

String _typography(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';\n\nTextTheme buildTextTheme() {\n  return const TextTheme(\n    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),\n    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),\n    bodyLarge: TextStyle(fontSize: 16),\n    bodyMedium: TextStyle(fontSize: 14),\n    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),\n  );\n}\n""";
}

String _apiClient(BlueprintConfig config) {
  return """import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class ApiClient {
  ApiClient(this.config) {
    _initializeDio();
  }

  final AppConfig config;
  late final Dio dio;
  
  void _initializeDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors in order
    LocalStorage.getInstance().then((storage) {
      dio.interceptors.addAll([
        AuthInterceptor(storage),
        RetryInterceptor(),
        LoggerInterceptor(),
      ]);
    });
  }
  
  /// Generic GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Generic POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Generic PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Generic DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
""";
}

String _loggerInterceptor(BlueprintConfig config) =>
    generateLoggerInterceptor(config);

String _homePage(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/home_content.dart';
import '../providers/home_provider.dart';

/// Home page - state is managed by homeProvider
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${_titleCase(config.appName)}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(homeProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: const HomeContent(),
    );
  }
}
""";
}

String _enLocalization(BlueprintConfig config) {
  return '{\n  "@@locale": "en",\n  "appTitle": "${_titleCase(config.appName)}"\n}';
}

String _hiLocalization(BlueprintConfig config) {
  return '{\n  "@@locale": "hi",\n  "appTitle": "${_titleCase(config.appName)}"\n}';
}

String _envExample(BlueprintConfig config) {
  return 'APP_ENV=dev\nAPI_BASE_URL=https://api.example.com';
}

String _widgetTest(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';\nimport 'package:flutter_test/flutter_test.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:${config.appName}/app/app.dart';\n\nvoid main() {\n  testWidgets('App renders without issues', (tester) async {\n    await tester.pumpWidget(const ProviderScope(child: App()));\n    expect(find.byType(MaterialApp), findsOneWidget);\n  });\n}\n""";
}

// ============================================================================
// NEW PROFESSIONAL TEMPLATES
// ============================================================================

String _appConstants(BlueprintConfig config) {
  return """/// Application-wide constants
class AppConstants {
  AppConstants._();
  
  // API
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  static const int maxRetries = 3;
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
""";
}

String _apiEndpoints(BlueprintConfig config) {
  return """/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  
  // Example endpoints - replace with your actual API
  static const String posts = '/posts';
  static String postDetail(int id) => '/posts/\$id';
}
""";
}

String _exceptions(BlueprintConfig config) {
  return """/// Custom exception classes for better error handling
class AppException implements Exception {
  AppException(this.message, [this.prefix = 'Error']);
  
  final String message;
  final String prefix;

  @override
  String toString() => '\$prefix: \$message';
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, 'Error During Communication');
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, 'Invalid Request');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, 'Unauthorized');
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 'Not Found');
}

class InvalidInputException extends AppException {
  InvalidInputException(String message) : super(message, 'Invalid Input');
}

class ServerException extends AppException {
  ServerException(String message) : super(message, 'Internal Server Error');
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 'No Internet Connection');
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super(message, 'Request Timeout');
}

class CacheException extends AppException {
  CacheException(String message) : super(message, 'Cache Error');
}
""";
}

String _failures(BlueprintConfig config) {
  return """import 'package:equatable/equatable.dart';

/// Failures for clean architecture
abstract class Failure extends Equatable {
  const Failure([this.message = 'An error occurred']);
  
  final String message;
  
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}
""";
}

String _networkInfo(BlueprintConfig config) {
  return """import 'package:connectivity_plus/connectivity_plus.dart';

/// Check network connectivity status
class NetworkInfo {
  NetworkInfo(this._connectivity);
  
  final Connectivity _connectivity;
  
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
  
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return !results.contains(ConnectivityResult.none);
    });
  }
}
""";
}

String _logger(BlueprintConfig config) {
  return """import 'package:flutter/foundation.dart';

/// Professional logging utility with different log levels
class AppLogger {
  AppLogger._();
  
  static const String _prefix = '🚀 [${_titleCase(config.appName)}]';
  
  /// Log debug messages (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[\$tag]' : '';
      debugPrint('\$_prefix 🐛 \$tagText \$message');
    }
  }
  
  /// Log info messages
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[\$tag]' : '';
      debugPrint('\$_prefix ℹ️ \$tagText \$message');
    }
  }
  
  /// Log warning messages
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[\$tag]' : '';
      debugPrint('\$_prefix ⚠️ \$tagText \$message');
    }
  }
  
  /// Log error messages
  static void error(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[\$tag]' : '';
      debugPrint('\$_prefix ❌ \$tagText \$message');
      if (error != null) debugPrint('Error: \$error');
      if (stackTrace != null) debugPrint('StackTrace: \$stackTrace');
    }
  }
  
  /// Log success messages
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final tagText = tag != null ? '[\$tag]' : '';
      debugPrint('\$_prefix ✅ \$tagText \$message');
    }
  }
}
""";
}

String _validators(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln('/// Input validation utilities')
    ..writeln('class Validators {')
    ..writeln('  Validators._();')
    ..writeln('  ')
    ..writeln('  /// Email validation')
    ..writeln('  static String? email(String? value) {')
    ..writeln('    if (value == null || value.isEmpty) {')
    ..writeln("      return 'Email is required';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    final emailRegex = RegExp(')
    ..writeln("      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\$',")
    ..writeln('    );')
    ..writeln('    ')
    ..writeln('    if (!emailRegex.hasMatch(value)) {')
    ..writeln("      return 'Please enter a valid email';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln(
        '  /// Password validation (minimum 8 characters, at least one letter and one number)')
    ..writeln('  static String? password(String? value) {')
    ..writeln('    if (value == null || value.isEmpty) {')
    ..writeln("      return 'Password is required';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    if (value.length < 8) {')
    ..writeln("      return 'Password must be at least 8 characters';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln("    if (!value.contains(RegExp(r'[A-Za-z]'))) {")
    ..writeln("      return 'Password must contain at least one letter';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln("    if (!value.contains(RegExp(r'[0-9]'))) {")
    ..writeln("      return 'Password must contain at least one number';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln("  /// Required field validation")
    ..writeln(
        "  static String? required(String? value, [String fieldName = 'This field']) {")
    ..writeln('    if (value == null || value.trim().isEmpty) {')
    ..writeln("      return '\$fieldName is required';")
    ..writeln('    }')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln('  /// Phone number validation')
    ..writeln('  static String? phone(String? value) {')
    ..writeln('    if (value == null || value.isEmpty) {')
    ..writeln("      return 'Phone number is required';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln("    final phoneRegex = RegExp(r'^[+]?[0-9]{10,}\$');")
    ..writeln('    ')
    ..writeln(
        "    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\\s-]'), ''))) {")
    ..writeln("      return 'Please enter a valid phone number';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln('  /// Minimum length validation')
    ..writeln(
        '  static String? minLength(String? value, int minLength, [String? fieldName]) {')
    ..writeln('    if (value == null || value.isEmpty) {')
    ..writeln("      return '\${fieldName ?? 'This field'} is required';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    if (value.length < minLength) {')
    ..writeln(
        "      return '\${fieldName ?? 'This field'} must be at least \$minLength characters';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln('  /// Maximum length validation')
    ..writeln(
        '  static String? maxLength(String? value, int maxLength, [String? fieldName]) {')
    ..writeln('    if (value != null && value.length > maxLength) {')
    ..writeln(
        "      return '\${fieldName ?? 'This field'} must not exceed \$maxLength characters';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln('  /// Numeric validation')
    ..writeln('  static String? numeric(String? value, [String? fieldName]) {')
    ..writeln('    if (value == null || value.isEmpty) {')
    ..writeln("      return '\${fieldName ?? 'This field'} is required';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    if (double.tryParse(value) == null) {')
    ..writeln("      return '\${fieldName ?? 'This field'} must be a number';")
    ..writeln('    }')
    ..writeln('    ')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('}');
  return buffer.toString();
}

String _extensions(BlueprintConfig config) {
  return """// BuildContext responsive/theme extensions are in app_responsive.dart (ResponsiveContext).
// Re-export so any file that imports extensions.dart also gets context helpers.
export 'app_responsive.dart' show ResponsiveContext, AppResponsive, AppDeviceType;

/// String extensions for common operations
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }
  
  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\$',
    );
    return emailRegex.hasMatch(this);
  }
  
  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\\s+'), '');
  
  /// Check if string is empty or contains only whitespace
  bool get isBlank => trim().isEmpty;
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as "Jan 1, 2024"
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '\${months[month - 1]} \$day, \$year';
  }
  
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }
}

/// BuildContext extensions are provided by app_responsive.dart (ResponsiveContext).
/// See core/utils/app_responsive.dart for all context helpers: rs(), rFont(), rVSpace() etc.
""";
}

String _routeNames(BlueprintConfig config) {
  return """/// Centralized route name constants
class RouteNames {
  RouteNames._();
  
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Add your route names here
}
""";
}

String _appColors(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

/// Custom color palette for the app
class AppColors {
  AppColors._();
  
  // Primary colors
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFF66AAFF);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryDark = Color(0xFFCC5529);
  static const Color secondaryLight = Color(0xFFFF9C7F);
  
  // Neutral colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF757575);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF424242);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
}
""";
}

String _loadingIndicator(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

import '../utils/app_responsive.dart';

/// Reusable loading indicator widget
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.message,
  });
  
  final double size;
  final Color? color;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final scaledSize = context.rs(size);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: scaledSize,
            height: scaledSize,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            context.rVSpace(16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
""";
}

String _errorView(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

import '../utils/app_responsive.dart';

/// Reusable error view widget
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.rPaddingAll(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: context.rIcon(64),
              color: Theme.of(context).colorScheme.error,
            ),
            context.rVSpace(16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: context.rFont(20),
              ),
              textAlign: TextAlign.center,
            ),
            context.rVSpace(8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              context.rVSpace(24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
""";
}

String _emptyState(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

import '../utils/app_responsive.dart';

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.actionLabel,
  });
  
  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.rPaddingAll(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.rIcon(64),
              color: Theme.of(context).colorScheme.secondary,
            ),
            context.rVSpace(16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              context.rVSpace(24),
              ElevatedButton(
                onPressed: action,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
""";
}

String _customButton(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

import '../utils/app_responsive.dart';

/// Custom button with loading state
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });
  
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context),
      );
    }
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(context),
    );
  }
  
  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: context.rs(20),
        width: context.rs(20),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.rIcon(20)),
          context.rHSpace(8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}
""";
}

String _customTextField(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

/// Custom text field with consistent styling
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });
  
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines;
  final bool enabled;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscured = true;
  
  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.obscureText && _obscured,
      keyboardType: widget.keyboardType,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
""";
}

String _apiResponse(BlueprintConfig config) {
  return """/// Generic API response wrapper
class ApiResponse<T> {
  ApiResponse.success(this.data) : error = null;
  ApiResponse.error(this.error) : data = null;
  
  final T? data;
  final String? error;
  
  bool get isSuccess => data != null;
  bool get isError => error != null;
}
""";
}

String _authInterceptor(BlueprintConfig config) {
  return generateEnhancedAuthInterceptor(config);
}

String _retryInterceptor(BlueprintConfig config) {
  return generateImprovedRetryInterceptor(config);
}

String _localStorage(BlueprintConfig config) {
  return generateEnhancedLocalStorage(config);
}

String _secureStorage(BlueprintConfig config) {
  return """import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';

/// Secure storage for sensitive data like tokens
class SecureStorage {
  SecureStorage._();
  
  static final SecureStorage _instance = SecureStorage._();
  static SecureStorage get instance => _instance;
  
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  
  /// Write data to secure storage
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('Written to secure storage: \$key', 'SecureStorage');
    } catch (e) {
      AppLogger.error('Failed to write to secure storage', e, null, 'SecureStorage');
    }
  }
  
  /// Read data from secure storage
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('Failed to read from secure storage', e, null, 'SecureStorage');
      return null;
    }
  }
  
  /// Delete data from secure storage
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('Deleted from secure storage: \$key', 'SecureStorage');
    } catch (e) {
      AppLogger.error('Failed to delete from secure storage', e, null, 'SecureStorage');
    }
  }
  
  /// Clear all data from secure storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.debug('Cleared all secure storage', 'SecureStorage');
    } catch (e) {
      AppLogger.error('Failed to clear secure storage', e, null, 'SecureStorage');
    }
  }
  
  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      AppLogger.error('Failed to check key in secure storage', e, null, 'SecureStorage');
      return false;
    }
  }
}
""";
}

String _appProviders(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln("import 'package:flutter_riverpod/flutter_riverpod.dart';")
    ..writeln("import '../config/app_config.dart';");

  if (config.includeApi) {
    buffer.writeln("import '../api/api_client.dart';");
  }

  // LocalStorage is always needed (auth, profile, settings are core features)
  buffer.writeln("import '../storage/local_storage.dart';");

  // Import CacheManager if Hive is included
  if (config.includeHive) {
    buffer.writeln("import '../database/cache_manager.dart';");
  }

  buffer
    ..writeln('')
    ..writeln('/// Global provider for app configuration')
    ..writeln('final appConfigProvider = Provider<AppConfig>((ref) {')
    ..writeln('  return AppConfig.load();')
    ..writeln('});');

  if (config.includeApi) {
    buffer
      ..writeln('')
      ..writeln('/// Global provider for API client')
      ..writeln('final apiClientProvider = Provider<ApiClient>((ref) {')
      ..writeln('  final config = ref.watch(appConfigProvider);')
      ..writeln('  return ApiClient(config);')
      ..writeln('});');
  }

  // LocalStorage provider is always included (initialized asynchronously in main())
  buffer
    ..writeln('')
    ..writeln('/// Global provider for LocalStorage')
    ..writeln('/// Must be overridden with an initialized instance in main()')
    ..writeln('final localStorageProvider = Provider<LocalStorage>((ref) {')
    ..writeln(
        "  throw UnimplementedError('localStorageProvider must be overridden in main()');")
    ..writeln('});');

  if (config.includeHive) {
    buffer
      ..writeln('')
      ..writeln('/// Cache manager provider for home items')
      ..writeln(
          "final homeCacheManagerProvider = Provider<CacheManager<List>>((ref) {")
      ..writeln("  return CacheManager<List>(boxName: 'home_cache');")
      ..writeln('});');
  }

  return buffer.toString();
}

String _homeProvider(BlueprintConfig config) {
  if (config.includeApi) {
    return _generateApiConnectedHomeProvider(config);
  } else {
    return _generateSimpleHomeProvider(config);
  }
}

String _generateApiConnectedHomeProvider(BlueprintConfig config) {
  final includeHive = config.includeHive;
  final cacheImport = includeHive
      ? "import '../../../../core/database/cache_manager.dart';"
      : '';

  return """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/providers/app_providers.dart';
${includeHive ? cacheImport : ''}

/// Simple item model for demonstration
class HomeItem {
  const HomeItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? json['body']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

/// Home screen state
class HomeState {
  const HomeState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  final List<HomeItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool hasMore;
  final int currentPage;

  HomeState copyWith({
    List<HomeItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return HomeState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Home screen state notifier with API integration
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this._apiClient${includeHive ? ', this._cacheManager' : ''}) : super(const HomeState()) {
    loadItems();
  }

  final ApiClient _apiClient;
  ${includeHive ? 'final CacheManager<List> _cacheManager;' : ''}

  /// Load items from API (or cache if offline)
  Future<void> loadItems({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      ${includeHive ? '''
      // Try to load from cache first
      final cachedData = _cacheManager.get('home_items');
      if (cachedData != null && !refresh) {
        final cachedItems = cachedData
            .map((json) => HomeItem.fromJson(json as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          items: cachedItems,
          isLoading: false,
          isRefreshing: false,
        );
      }
      ''' : ''}

      // Fetch from API - using JSONPlaceholder as example
      // Replace with your actual API endpoint
      final response = await _apiClient.get('/posts?_page=1&_limit=10');
      
      final List<HomeItem> items;
      if (response.data is List) {
        items = (response.data as List)
            .map((json) => HomeItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        items = [];
      }

      ${includeHive ? '''
      // Cache the results
      await _cacheManager.put(
        'home_items',
        items.map((item) => item.toJson()).toList(),
        ttl: const Duration(hours: 1),
      );
      ''' : ''}

      state = state.copyWith(
        items: items,
        isLoading: false,
        isRefreshing: false,
        currentPage: 1,
        hasMore: items.length >= 10,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  /// Load more items for pagination
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _apiClient.get('/posts?_page=\$nextPage&_limit=10');
      
      final List<HomeItem> newItems;
      if (response.data is List) {
        newItems = (response.data as List)
            .map((json) => HomeItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        newItems = [];
      }

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        currentPage: nextPage,
        hasMore: newItems.length >= 10,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh items
  Future<void> refresh() async {
    await loadItems(refresh: true);
  }
}

/// Provider for home screen state
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  ${includeHive ? 'final cacheManager = ref.watch(homeCacheManagerProvider);' : ''}
  return HomeNotifier(apiClient${includeHive ? ', cacheManager' : ''});
});
""";
}

String _generateSimpleHomeProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple item model for demonstration
class HomeItem {
  const HomeItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

/// Home screen state
class HomeState {
  const HomeState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<HomeItem> items;
  final bool isLoading;
  final String? error;

  HomeState copyWith({
    List<HomeItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Home screen state notifier
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState()) {
    _loadSampleData();
  }

  void _loadSampleData() {
    // Load sample data for demonstration
    final sampleItems = List.generate(
      10,
      (index) => HomeItem(
        id: '\$index',
        title: 'Item \${index + 1}',
        description: 'This is a sample item to demonstrate the app structure.',
      ),
    );

    state = state.copyWith(items: sampleItems);
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));
      
      _loadSampleData();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadItems();
  }
}

/// Provider for home screen state
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
""";
}

String _homeContent(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_provider.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/app_responsive.dart';

/// Home screen content widget using ConsumerWidget for Riverpod
class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    // Initial loading state
    if (homeState.isLoading && homeState.items.isEmpty) {
      return const LoadingIndicator(message: 'Loading items...');
    }

    // Error state (when no items are loaded yet)
    if (homeState.error != null && homeState.items.isEmpty) {
      return ErrorView(
        message: homeState.error!,
        onRetry: () => ref.read(homeProvider.notifier).loadItems(),
      );
    }

    // Empty state
    if (homeState.items.isEmpty) {
      return EmptyState(
        message: 'No items found',
        action: () => ref.read(homeProvider.notifier).loadItems(),
        actionLabel: 'Retry',
      );
    }

    // List with pull-to-refresh
    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: homeState.items.length + (homeState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator for pagination
          if (index == homeState.items.length) {
            if (homeState.isLoading) {
              return Padding(
                padding: context.rPaddingAll(16),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }

          final item = homeState.items[index];

          // Load more when reaching the end
          if (index == homeState.items.length - 2 && homeState.hasMore && !homeState.isLoading) {
            Future.microtask(() => ref.read(homeProvider.notifier).loadMore());
          }

          return Card(
            margin: context.rPaddingSymmetric(h: 16, v: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('\${index + 1}'),
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.rFont(16),
                ),
              ),
              subtitle: Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: context.rFont(14)),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to detail page (implement as needed)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped on \${item.title}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
""";
}

String _validatorsTest(BlueprintConfig config) {
  return """import 'package:flutter_test/flutter_test.dart';
import 'package:${config.appName}/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns error when email is empty', () {
        expect(Validators.email(''), 'Email is required');
        expect(Validators.email(null), 'Email is required');
      });

      test('returns error for invalid email', () {
        expect(Validators.email('invalid'), 'Please enter a valid email');
        expect(Validators.email('test@'), 'Please enter a valid email');
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), null);
      });
    });

    group('password', () {
      test('returns error when password is empty', () {
        expect(Validators.password(''), 'Password is required');
      });

      test('returns error when password is too short', () {
        expect(Validators.password('short'), contains('at least 8 characters'));
      });

      test('returns error when password has no letter', () {
        expect(Validators.password('12345678'), contains('at least one letter'));
      });

      test('returns error when password has no number', () {
        expect(Validators.password('password'), contains('at least one number'));
      });

      test('returns null for valid password', () {
        expect(Validators.password('password123'), null);
      });
    });
  });
}
""";
}

String _testHelpers(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helpers for widget testing
class TestHelpers {
  TestHelpers._();
  
  /// Wrap widget with MaterialApp for testing
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
  
  /// Pump widget with delays for animations
  static Future<void> pumpWithSettles(
    WidgetTester tester,
    Widget widget, [
    Duration duration = const Duration(seconds: 1),
  ]) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration);
  }
}
""";
}

// Import utility functions - same as bloc template
String _dialogUtils(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Global dialog utilities for success/failure messages
class DialogUtils {
  DialogUtils._();

  static Future<void> showSuccess(BuildContext context, {required String title, required String message, String buttonText = 'OK', VoidCallback? onPressed}) {
    return showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 32)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)))]), content: Text(message), actions: [TextButton(onPressed: () { Navigator.of(context).pop(); onPressed?.call(); }, child: Text(buttonText))]));
  }

  static Future<void> showError(BuildContext context, {required String title, required String message, String buttonText = 'OK', VoidCallback? onPressed}) {
    return showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.error_outline, color: AppColors.error, size: 32)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)))]), content: Text(message), actions: [TextButton(onPressed: () { Navigator.of(context).pop(); onPressed?.call(); }, child: Text(buttonText))]));
  }

  static Future<bool?> showConfirmation(BuildContext context, {required String title, required String message, String confirmText = 'Confirm', String cancelText = 'Cancel'}) {
    return showDialog<bool>(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text(title), content: Text(message), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelText)), ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(confirmText))]));
  }

  static void showLoading(BuildContext context, {String message = 'Loading...'}) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => PopScope(canPop: false, child: AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), content: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(message)]))));
  }

  static void dismissLoading(BuildContext context) => Navigator.of(context, rootNavigator: true).pop();
}
""";
}

String _snackbarUtils(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Global snackbar utilities
class SnackbarUtils {
  SnackbarUtils._();

  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: Colors.white)))]), backgroundColor: AppColors.success, duration: duration, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.error, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: Colors.white)))]), backgroundColor: AppColors.error, duration: duration, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  static void showInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.info, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: Colors.white)))]), backgroundColor: AppColors.info, duration: duration, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  static void showWarning(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.warning, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: Colors.white)))]), backgroundColor: AppColors.warning, duration: duration, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}
""";
}

String _networkSettings(BlueprintConfig config) {
  return """import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';

/// Network settings and connectivity management
class NetworkSettings {
  NetworkSettings._();
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      AppLogger.error('Error checking connectivity', e, null, 'NetworkSettings');
      return false;
    }
  }

  static Future<ConnectivityResult> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.first;
    } catch (e) {
      AppLogger.error('Error getting connection type', e, null, 'NetworkSettings');
      return ConnectivityResult.none;
    }
  }

  static Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  static String getConnectionTypeString(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi: return 'WiFi';
      case ConnectivityResult.mobile: return 'Mobile Data';
      case ConnectivityResult.ethernet: return 'Ethernet';
      case ConnectivityResult.vpn: return 'VPN';
      case ConnectivityResult.bluetooth: return 'Bluetooth';
      case ConnectivityResult.other: return 'Other';
      case ConnectivityResult.none: return 'No Connection';
    }
  }

  static void showNetworkError(BuildContext context) {
    showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: const Row(children: [Icon(Icons.wifi_off, color: Colors.red), SizedBox(width: 12), Text('No Internet Connection')]), content: const Text('Please check your internet connection and try again.'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))]));
  }

  static Future<T?> executeWithNetworkCheck<T>(BuildContext context, Future<T> Function() function, {bool showError = true}) async {
    if (!await isConnected()) {
      if (showError && context.mounted) showNetworkError(context);
      return null;
    }
    return await function();
  }
}
""";
}

String _titleCase(String input) {
  if (input.isEmpty) {
    return input;
  }
  final segments = input.split(RegExp(r'[_\- ]+')).where((e) => e.isNotEmpty);
  return segments.map((segment) {
    final lower = segment.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }).join(' ');
}

// Hive template wrappers
String _hiveDatabase(BlueprintConfig config) => generateHiveDatabase(config);
String _cacheManager(BlueprintConfig config) => generateCacheManager(config);
String _syncManager(BlueprintConfig config) => generateSyncManager(config);

// Pagination template wrappers
String _paginationController(BlueprintConfig config) =>
    generatePaginationController(config);
String _paginatedListView(BlueprintConfig config) =>
    generatePaginatedListView(config);
String _skeletonLoader(BlueprintConfig config) =>
    generateSkeletonLoader(config);

// Analytics template wrappers
String _analyticsService(BlueprintConfig config) => generateAnalyticsService();
String _firebaseAnalyticsService(BlueprintConfig config) =>
    generateFirebaseAnalyticsService();
String _sentryService(BlueprintConfig config) => generateSentryService();
String _analyticsEvents(BlueprintConfig config) => generateAnalyticsEvents();
String _errorBoundary(BlueprintConfig config) => generateErrorBoundary();

// Accessibility template wrappers
String _semanticsHelper(BlueprintConfig config) => generateSemanticsHelper();
String _contrastChecker(BlueprintConfig config) => generateContrastChecker();
String _focusManager(BlueprintConfig config) => generateFocusManager();
String _accessibilityConfig(BlueprintConfig config) =>
    generateAccessibilityConfig();
String _accessibilityTestUtils(BlueprintConfig config) =>
    generateAccessibilityTestUtils();
// ============================================================================
// AUTH FEATURE TEMPLATE FUNCTIONS (Domain Layer)
// ============================================================================

String _authUserEntity(BlueprintConfig config) {
  return """import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
  });

  final String id;
  final String email;
  final String? name;
  final String? avatar;

  @override
  List<Object?> get props => [id, email, name, avatar];
}
""";
}

String _authRepository(BlueprintConfig config) {
  return """import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logout the current user
  Future<void> logout();

  /// Get the currently logged in user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh authentication token
  Future<bool> refreshToken();
}
""";
}

String _authLoginUsecase(BlueprintConfig config) {
  return """import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUsecase {
  LoginUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute login
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(
      email: email,
      password: password,
    );
  }
}
""";
}

String _authRegisterUsecase(BlueprintConfig config) {
  return """import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUsecase {
  RegisterUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute registration
  Future<UserEntity> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}
""";
}

String _authLogoutUsecase(BlueprintConfig config) {
  return """import '../repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUsecase {
  LogoutUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute logout
  Future<void> call() async {
    await _repository.logout();
  }
}
""";
}

String _authGetCurrentUserUsecase(BlueprintConfig config) {
  return """import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case to get current authenticated user
class GetCurrentUserUsecase {
  GetCurrentUserUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute get current user
  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}
""";
}

// ============================================================================
// AUTH FEATURE TEMPLATE FUNCTIONS (Data Layer)
// ============================================================================

String _authUserModel(BlueprintConfig config) {
  return """import '../../domain/entities/user_entity.dart';

/// User data model
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.avatar,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
    };
  }

  /// Create copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }
}
""";
}

String _authResponseModel(BlueprintConfig config) {
  return """import 'user_model.dart';

/// Authentication response model from API
class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  final UserModel user;
  final String accessToken;
  final String? refreshToken;

  /// Create from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken']?.toString() ?? json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}
""";
}

String _authRemoteDataSource(BlueprintConfig config) {
  return """import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(String email, String password, String name);
  Future<UserModel> getCurrentUser();
  Future<bool> refreshToken(String refreshToken);
}

/// Implementation of authentication remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Login failed', e, e.stackTrace, 'AuthRemoteDataSource');
      throw Exception('Login failed: \${e.message}');
    }
  }

  @override
  Future<AuthResponseModel> register(String email, String password, String name) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Registration failed', e, e.stackTrace, 'AuthRemoteDataSource');
      throw Exception('Registration failed: \${e.message}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Get user failed', e, e.stackTrace, 'AuthRemoteDataSource');
      throw Exception('Failed to get user: \${e.message}');
    }
  }

  @override
  Future<bool> refreshToken(String refreshToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return true;
    } on DioException catch (e) {
      AppLogger.error('Token refresh failed', e, e.stackTrace, 'AuthRemoteDataSource');
      return false;
    }
  }
}
""";
}

String _authLocalDataSource(BlueprintConfig config) {
  return """import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';
import 'dart:convert';

/// Local data source for authentication (caching tokens and user data)
abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String? refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

/// Implementation of authentication local data source
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required this.localStorage,
    required this.secureStorage,
  });

  final LocalStorage localStorage;
  final SecureStorage secureStorage;

  @override
  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await secureStorage.write(AppConstants.keyAccessToken, accessToken);
    if (refreshToken != null) {
      await secureStorage.write(AppConstants.keyRefreshToken, refreshToken);
    }
    AppLogger.debug('Tokens saved', 'AuthLocalDataSource');
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(AppConstants.keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(AppConstants.keyAccessToken);
    await secureStorage.delete(AppConstants.keyRefreshToken);
    AppLogger.debug('Tokens cleared', 'AuthLocalDataSource');
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await localStorage.setString('cached_user', jsonEncode(user.toJson()));
    AppLogger.debug('User cached locally', 'AuthLocalDataSource');
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = localStorage.getString('cached_user');
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Failed to parse cached user', e, null, 'AuthLocalDataSource');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await localStorage.remove('cached_user');
    AppLogger.debug('Cached user cleared', 'AuthLocalDataSource');
  }
}
""";
}

String _authRepositoryImpl(BlueprintConfig config) {
  return """import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login via API
      final authResponse = await remoteDataSource.login(email, password);

      // Save tokens and user data locally
      await localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      await localDataSource.saveUser(authResponse.user);

      AppLogger.success('Login successful', 'AuthRepository');
      return authResponse.user;
    } catch (e) {
      AppLogger.error('Login failed in repository', e, null, 'AuthRepository');
      rethrow;
    }
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Register via API
      final authResponse =
          await remoteDataSource.register(email, password, name);

      // Save tokens and user data locally
      await localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      await localDataSource.saveUser(authResponse.user);

      AppLogger.success('Registration successful', 'AuthRepository');
      return authResponse.user;
    } catch (e) {
      AppLogger.error('Registration failed in repository', e, null, 'AuthRepository');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear local data
      await localDataSource.clearTokens();
      await localDataSource.clearUser();

      AppLogger.success('Logout successful', 'AuthRepository');
    } catch (e) {
      AppLogger.error('Logout failed', e, null, 'AuthRepository');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }

      // If not in cache, fetch from API
      final token = await localDataSource.getAccessToken();
      if (token == null) {
        return null;
      }

      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);

      return user;
    } catch (e) {
      AppLogger.error('Failed to get current user', e, null, 'AuthRepository');
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final success = await remoteDataSource.refreshToken(refreshToken);
      return success;
    } catch (e) {
      AppLogger.error('Token refresh failed', e, null, 'AuthRepository');
      return false;
    }
  }
}
""";
}

// ============================================================================
// AUTH FEATURE TEMPLATE FUNCTIONS (Presentation Layer)
// ============================================================================

String _authProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// ========== DATA SOURCES ==========

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    localStorage: ref.watch(localStorageProvider),
    secureStorage: SecureStorage.instance,
  );
});

// ========== REPOSITORY ==========

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// ========== USE CASES ==========

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.watch(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(ref.watch(authRepositoryProvider));
});

// ========== AUTH STATE ==========

/// Authentication state
class AuthState {
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  final UserEntity? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    UserEntity? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ========== AUTH NOTIFIER ==========

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  final Ref _ref;

  /// Check if user is authenticated on app start
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final usecase = _ref.read(getCurrentUserUsecaseProvider);
      final user = await usecase();

      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final usecase = _ref.read(loginUsecaseProvider);
      final user = await usecase(email: email, password: password);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Register new user
  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final usecase = _ref.read(registerUsecaseProvider);
      final user = await usecase(
        email: email,
        password: password,
        name: name,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final usecase = _ref.read(logoutUsecaseProvider);
      await usecase();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
""";
}

String _authLoginFormProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login form state
class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.obscurePassword = true,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;

  LoginFormState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? obscurePassword,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;
}

/// Login form notifier
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  bool validate() {
    String? emailError;
    String? passwordError;

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(state.email)) {
      emailError = 'Invalid email format';
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
    } else if (state.password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
    );

    return emailError == null && passwordError == null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$').hasMatch(email);
  }

  void reset() {
    state = const LoginFormState();
  }
}

/// Provider for login form state
final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  return LoginFormNotifier();
});
""";
}

String _authRegisterFormProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Register form state
class RegisterFormState {
  const RegisterFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  RegisterFormState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) {
    return RegisterFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }

  bool get isValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      nameError == null &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null;
}

/// Register form notifier
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  RegisterFormNotifier() : super(const RegisterFormState());

  void setName(String name) {
    state = state.copyWith(name: name, nameError: null);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(
        confirmPassword: confirmPassword, confirmPasswordError: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state =
        state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  bool validate() {
    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmPasswordError;

    if (state.name.isEmpty) {
      nameError = 'Name is required';
    }

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(state.email)) {
      emailError = 'Invalid email format';
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
    } else if (state.password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    if (state.confirmPassword.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
    } else if (state.password != state.confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    state = state.copyWith(
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$').hasMatch(email);
  }

  void reset() {
    state = const RegisterFormState();
  }
}

/// Provider for register form state
final registerFormProvider = StateNotifierProvider.autoDispose<
    RegisterFormNotifier, RegisterFormState>((ref) {
  return RegisterFormNotifier();
});
""";
}

String _authLoginPage(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/login_form_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

/// Login page
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final formState = ref.watch(loginFormProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Title
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Email field
                AuthTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  value: formState.email,
                  errorText: formState.emailError,
                  onChanged: (value) {
                    ref.read(loginFormProvider.notifier).setEmail(value);
                  },
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Password field
                AuthTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  value: formState.password,
                  errorText: formState.passwordError,
                  obscureText: formState.obscurePassword,
                  onChanged: (value) {
                    ref.read(loginFormProvider.notifier).setPassword(value);
                  },
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: formState.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    ref
                        .read(loginFormProvider.notifier)
                        .togglePasswordVisibility();
                  },
                ),
                const SizedBox(height: 24),

                // Error message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Login button
                AuthButton(
                  label: 'Login',
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    // Validate form
                    if (!ref.read(loginFormProvider.notifier).validate()) {
                      return;
                    }

                    // Perform login
                    final success = await ref.read(authProvider.notifier).login(
                          formState.email,
                          formState.password,
                        );

                    if (success && context.mounted) {
                      // Navigate to home on success
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/register');
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
""";
}

String _authRegisterPage(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/register_form_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

/// Register page
class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final formState = ref.watch(registerFormProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Title
                Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Name field
                AuthTextField(
                  label: 'Full Name',
                  hintText: 'Enter your name',
                  value: formState.name,
                  errorText: formState.nameError,
                  onChanged: (value) {
                    ref.read(registerFormProvider.notifier).setName(value);
                  },
                  prefixIcon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),

                // Email field
                AuthTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  value: formState.email,
                  errorText: formState.emailError,
                  onChanged: (value) {
                    ref.read(registerFormProvider.notifier).setEmail(value);
                  },
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Password field
                AuthTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  value: formState.password,
                  errorText: formState.passwordError,
                  obscureText: formState.obscurePassword,
                  onChanged: (value) {
                    ref.read(registerFormProvider.notifier).setPassword(value);
                  },
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: formState.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    ref
                        .read(registerFormProvider.notifier)
                        .togglePasswordVisibility();
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                AuthTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  value: formState.confirmPassword,
                  errorText: formState.confirmPasswordError,
                  obscureText: formState.obscureConfirmPassword,
                  onChanged: (value) {
                    ref
                        .read(registerFormProvider.notifier)
                        .setConfirmPassword(value);
                  },
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: formState.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    ref
                        .read(registerFormProvider.notifier)
                        .toggleConfirmPasswordVisibility();
                  },
                ),
                const SizedBox(height: 24),

                // Error message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Register button
                AuthButton(
                  label: 'Register',
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    // Validate form
                    if (!ref.read(registerFormProvider.notifier).validate()) {
                      return;
                    }

                    // Perform registration
                    final success =
                        await ref.read(authProvider.notifier).register(
                              formState.email,
                              formState.password,
                              formState.name,
                            );

                    if (success && context.mounted) {
                      // Navigate to home on success
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
""";
}

String _authTextField(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

/// Custom text field for authentication forms
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
  });

  final String label;
  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconTap,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}
""";
}

String _authButton(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

/// Custom button for authentication forms
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
""";
}

// ============================================================================
// PROFILE FEATURE TEMPLATE FUNCTIONS
// ============================================================================

// ----------------------------------------------------------------------------
// Data Layer
// ----------------------------------------------------------------------------

String _profileModel(BlueprintConfig config) {
  return """import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/storage/local_storage.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.bio,
    this.phone,
    this.location,
    this.joinedDate,
  });

  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String? bio;
  final String? phone;
  final String? location;
  final DateTime? joinedDate;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      bio: json['bio']?.toString(),
      phone: json['phone']?.toString(),
      location: json['location']?.toString(),
      joinedDate: json['joinedDate'] != null
          ? DateTime.tryParse(json['joinedDate'].toString())
          : null,
    );
  }

  factory ProfileModel.fromUserEntity(UserEntity user) {
    return ProfileModel(
      id: user.id,
      email: user.email,
      name: user.name ?? '',
      avatar: user.avatar,
      bio: null,
      phone: null,
      location: null,
      joinedDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'phone': phone,
      'location': location,
      'joinedDate': joinedDate?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    String? bio,
    String? phone,
    String? location,
    DateTime? joinedDate,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  Future<void> saveToCache(LocalStorage storage) async {
    await storage.setJson('cached_profile', toJson());
  }

  static Future<ProfileModel?> loadFromCache(LocalStorage storage) async {
    final data = storage.getJson('cached_profile');
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }
}
""";
}

String _profileRemoteDataSource(BlueprintConfig config) {
  return """import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({
    String? name,
    String? bio,
    String? phone,
    String? location,
  });
  Future<String> uploadAvatar(String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({
    required this.apiClient,
  });

  final ApiClient apiClient;

  @override
  Future<ProfileModel> getProfile() async {
    try {
      AppLogger.debug('Fetching user profile from API');
      final response = await apiClient.get(ApiEndpoints.profile);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch profile', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? name,
    String? bio,
    String? phone,
    String? location,
  }) async {
    try {
      AppLogger.debug('Updating user profile');
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (bio != null) data['bio'] = bio;
      if (phone != null) data['phone'] = phone;
      if (location != null) data['location'] = location;

      final response = await apiClient.put(
        ApiEndpoints.profile,
        data: data,
      );
      AppLogger.info('Profile updated successfully');
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update profile', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      AppLogger.debug('Uploading avatar image');
      // In a real app, you would use FormData to upload the file
      // For demo purposes, we'll simulate by returning a mock URL
      await Future.delayed(const Duration(seconds: 2));
      final avatarUrl = 'https://i.pravatar.cc/150?img=\${DateTime.now().millisecondsSinceEpoch % 70}';
      AppLogger.info('Avatar uploaded successfully');
      return avatarUrl;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to upload avatar', e, stackTrace);
      rethrow;
    }
  }
}
""";
}

String _profileLocalDataSource(BlueprintConfig config) {
  return """import '../../../../core/utils/logger.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel?> getCachedProfile();
  Future<void> cacheProfile(ProfileModel profile);
  Future<void> clearCachedProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  const ProfileLocalDataSourceImpl({
    required this.localStorage,
  });

  final LocalStorage localStorage;

  static const String _profileKey = 'cached_profile';
  static const String _profileTimestampKey = 'cached_profile_timestamp';

  @override
  Future<ProfileModel?> getCachedProfile() async {
    try {
      final timestamp = localStorage.getString(_profileTimestampKey);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
        final now = DateTime.now();
        final difference = now.difference(cacheTime);
        
        // Cache expires after 1 hour
        if (difference.inHours >= 1) {
          AppLogger.debug('Profile cache expired');
          await clearCachedProfile();
          return null;
        }
      }

      final profileData = localStorage.getJson(_profileKey);
      if (profileData == null) {
        AppLogger.debug('No cached profile found');
        return null;
      }

      AppLogger.debug('Retrieved cached profile');
      return ProfileModel.fromJson(profileData);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get cached profile', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    try {
      await localStorage.setJson(_profileKey, profile.toJson());
      await localStorage.setString(_profileTimestampKey, DateTime.now().millisecondsSinceEpoch.toString());
      AppLogger.debug('Profile cached successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cache profile', e, stackTrace);
    }
  }

  @override
  Future<void> clearCachedProfile() async {
    try {
      await localStorage.remove(_profileKey);
      await localStorage.remove(_profileTimestampKey);
      AppLogger.debug('Cached profile cleared');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear cached profile', e, stackTrace);
    }
  }
}
""";
}

String _profileRepositoryImpl(BlueprintConfig config) {
  return """import '../../../../core/utils/logger.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  @override
  Future<ProfileModel> getProfile({bool forceRefresh = false}) async {
    try {
      // Try cache first unless force refresh
      if (!forceRefresh) {
        final cachedProfile = await localDataSource.getCachedProfile();
        if (cachedProfile != null) {
          AppLogger.debug('Returning cached profile');
          return cachedProfile;
        }
      }

      // Fetch from API
      AppLogger.debug('Fetching profile from API');
      final profile = await remoteDataSource.getProfile();
      
      // Cache the result
      await localDataSource.cacheProfile(profile);
      
      return profile;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get profile', e, stackTrace);
      
      // Try to return cached data as fallback
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        AppLogger.debug('Returning cached profile as fallback');
        return cachedProfile;
      }
      
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? name,
    String? bio,
    String? phone,
    String? location,
  }) async {
    try {
      final updatedProfile = await remoteDataSource.updateProfile(
        name: name,
        bio: bio,
        phone: phone,
        location: location,
      );
      
      // Update cache
      await localDataSource.cacheProfile(updatedProfile);
      
      return updatedProfile;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update profile', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      return await remoteDataSource.uploadAvatar(filePath);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to upload avatar', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCachedProfile();
  }
}
""";
}

// ----------------------------------------------------------------------------
// Domain Layer
// ----------------------------------------------------------------------------

String _profileRepository(BlueprintConfig config) {
  return """import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile({bool forceRefresh = false});
  Future<ProfileModel> updateProfile({
    String? name,
    String? bio,
    String? phone,
    String? location,
  });
  Future<String> uploadAvatar(String filePath);
  Future<void> clearCache();
}
""";
}

String _profileGetUsecase(BlueprintConfig config) {
  return """import '../repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';

class GetProfileUsecase {
  const GetProfileUsecase(this.repository);

  final ProfileRepository repository;

  Future<ProfileModel> call({bool forceRefresh = false}) {
    return repository.getProfile(forceRefresh: forceRefresh);
  }
}
""";
}

String _profileUpdateUsecase(BlueprintConfig config) {
  return """import '../repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';

class UpdateProfileUsecase {
  const UpdateProfileUsecase(this.repository);

  final ProfileRepository repository;

  Future<ProfileModel> call({
    String? name,
    String? bio,
    String? phone,
    String? location,
  }) {
    return repository.updateProfile(
      name: name,
      bio: bio,
      phone: phone,
      location: location,
    );
  }
}
""";
}

// ----------------------------------------------------------------------------
// Presentation Layer
// ----------------------------------------------------------------------------

String _profileProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

// Data Sources
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSourceImpl(
    localStorage: ref.watch(localStorageProvider),
  );
});

// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    localDataSource: ref.watch(profileLocalDataSourceProvider),
  );
});

// Use Cases
final getProfileUsecaseProvider = Provider<GetProfileUsecase>((ref) {
  return GetProfileUsecase(ref.watch(profileRepositoryProvider));
});

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  return UpdateProfileUsecase(ref.watch(profileRepositoryProvider));
});

// Profile State
class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  final ProfileModel? profile;
  final bool isLoading;
  final String? error;

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(const ProfileState()) {
    _loadProfile();
  }

  final Ref ref;

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final usecase = ref.read(getProfileUsecaseProvider);
      final profile = await usecase();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshProfile() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final usecase = ref.read(getProfileUsecaseProvider);
      final profile = await usecase(forceRefresh: true);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? phone,
    String? location,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final usecase = ref.read(updateProfileUsecaseProvider);
      final updatedProfile = await usecase(
        name: name,
        bio: bio,
        phone: phone,
        location: location,
      );
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final repository = ref.read(profileRepositoryProvider);
      final avatarUrl = await repository.uploadAvatar(filePath);
      
      // Update profile with new avatar
      final updatedProfile = state.profile?.copyWith(avatar: avatarUrl);
      if (updatedProfile != null) {
        final localDataSource = ref.read(profileLocalDataSourceProvider);
        await localDataSource.cacheProfile(updatedProfile);
      }
      
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});
""";
}

String _profileFormProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileFormState {
  const ProfileFormState({
    this.name = '',
    this.bio = '',
    this.phone = '',
    this.location = '',
    this.errors = const {},
  });

  final String name;
  final String bio;
  final String phone;
  final String location;
  final Map<String, String> errors;

  ProfileFormState copyWith({
    String? name,
    String? bio,
    String? phone,
    String? location,
    Map<String, String>? errors,
  }) {
    return ProfileFormState(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      errors: errors ?? this.errors,
    );
  }
}

class ProfileFormNotifier extends StateNotifier<ProfileFormState> {
  ProfileFormNotifier() : super(const ProfileFormState());

  void setName(String name) {
    state = state.copyWith(
      name: name,
      errors: {...state.errors}..remove('name'),
    );
  }

  void setBio(String bio) {
    state = state.copyWith(bio: bio);
  }

  void setPhone(String phone) {
    state = state.copyWith(
      phone: phone,
      errors: {...state.errors}..remove('phone'),
    );
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  void initialize({
    required String name,
    String? bio,
    String? phone,
    String? location,
  }) {
    state = ProfileFormState(
      name: name,
      bio: bio ?? '',
      phone: phone ?? '',
      location: location ?? '',
    );
  }

  bool validate() {
    final errors = <String, String>{};

    if (state.name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    } else if (state.name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }

    if (state.phone.isNotEmpty && !_isValidPhone(state.phone)) {
      errors['phone'] = 'Invalid phone number';
    }

    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return false;
    }

    return true;
  }

  bool _isValidPhone(String phone) {
    // Basic phone validation - allow digits, spaces, dashes, parentheses, and plus
    final phoneRegex = RegExp(r'^[\\d\\s\\-()\\+]+\$');
    return phoneRegex.hasMatch(phone) && phone.replaceAll(RegExp(r'[^\\d]'), '').length >= 10;
  }

  void reset() {
    state = const ProfileFormState();
  }
}

final profileFormProvider = StateNotifierProvider.autoDispose<ProfileFormNotifier, ProfileFormState>((ref) {
  return ProfileFormNotifier();
});
""";
}

String _profilePage(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_tile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.editProfile);
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // In a real app, you would call the logout functionality here
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileProvider.notifier).refreshProfile();
        },
        child: profileState.isLoading && profile == null
            ? const Center(child: CircularProgressIndicator())
            : profileState.error != null && profile == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: \${profileState.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(profileProvider.notifier).refreshProfile();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        ProfileAvatar(
                          avatarUrl: profile?.avatar,
                          size: 120,
                          onTap: () {
                            // In a real app, this would open image picker
                            _showAvatarOptions(context, ref);
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          profile?.name ?? 'Unknown User',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 32),
                        Card(
                          child: Column(
                            children: [
                              ProfileInfoTile(
                                icon: Icons.info_outline,
                                label: 'Bio',
                                value: profile?.bio ?? 'No bio yet',
                              ),
                              const Divider(height: 1),
                              ProfileInfoTile(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: profile?.phone ?? 'Not set',
                              ),
                              const Divider(height: 1),
                              ProfileInfoTile(
                                icon: Icons.location_on_outlined,
                                label: 'Location',
                                value: profile?.location ?? 'Not set',
                              ),
                              const Divider(height: 1),
                              ProfileInfoTile(
                                icon: Icons.calendar_today_outlined,
                                label: 'Joined',
                                value: profile?.joinedDate != null
                                    ? _formatDate(profile!.joinedDate!)
                                    : 'Unknown',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // In a real app, open camera
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera not implemented in demo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // In a real app, open gallery
                ref.read(profileProvider.notifier).uploadAvatar('demo_path');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '\${months[date.month - 1]} \${date.day}, \${date.year}';
  }
}
""";
}

String _editProfilePage(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_form_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider).profile;
      if (profile != null) {
        ref.read(profileFormProvider.notifier).initialize(
              name: profile.name,
              bio: profile.bio,
              phone: profile.phone,
              location: profile.location,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final formState = ref.watch(profileFormProvider);
    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: profileState.isLoading ? null : () => _saveProfile(),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      ProfileAvatar(
                        avatarUrl: profile?.avatar,
                        size: 120,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 20),
                            color: Colors.white,
                            onPressed: () {
                              _showAvatarOptions();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      errorText: formState.errors['name'],
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(text: formState.name)
                      ..selection = TextSelection.collapsed(
                        offset: formState.name.length,
                      ),
                    onChanged: (value) {
                      ref.read(profileFormProvider.notifier).setName(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself',
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(text: formState.bio)
                      ..selection = TextSelection.collapsed(
                        offset: formState.bio.length,
                      ),
                    onChanged: (value) {
                      ref.read(profileFormProvider.notifier).setBio(value);
                    },
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter your phone number',
                      errorText: formState.errors['phone'],
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(text: formState.phone)
                      ..selection = TextSelection.collapsed(
                        offset: formState.phone.length,
                      ),
                    onChanged: (value) {
                      ref.read(profileFormProvider.notifier).setPhone(value);
                    },
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'Enter your location',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(text: formState.location)
                      ..selection = TextSelection.collapsed(
                        offset: formState.location.length,
                      ),
                    onChanged: (value) {
                      ref.read(profileFormProvider.notifier).setLocation(value);
                    },
                  ),
                  if (profileState.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profileState.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _saveProfile() async {
    final formNotifier = ref.read(profileFormProvider.notifier);
    
    if (!formNotifier.validate()) {
      return;
    }

    final formState = ref.read(profileFormProvider);
    await ref.read(profileProvider.notifier).updateProfile(
          name: formState.name.isNotEmpty ? formState.name : null,
          bio: formState.bio.isNotEmpty ? formState.bio : null,
          phone: formState.phone.isNotEmpty ? formState.phone : null,
          location: formState.location.isNotEmpty ? formState.location : null,
        );

    final profileState = ref.read(profileProvider);
    if (!mounted) return;

    if (profileState.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera not implemented in demo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ref.read(profileProvider.notifier).uploadAvatar('demo_path');
              },
            ),
          ],
        ),
      ),
    );
  }
}
""";
}

String _profileAvatar(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.size = 80,
    this.onTap,
  });

  final String? avatarUrl;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(context);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholder(context);
                  },
                )
              : _buildPlaceholder(context),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
""";
}

String _profileInfoTile(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
""";
}

// ============================================================================
// SETTINGS FEATURE TEMPLATE FUNCTIONS
// ============================================================================

String _settingsProvider(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/storage/local_storage.dart';

// Settings State
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.biometricsEnabled = false,
    this.language = 'en',
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool biometricsEnabled;
  final String language;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? biometricsEnabled,
    String? language,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'notificationsEnabled': notificationsEnabled,
      'biometricsEnabled': biometricsEnabled,
      'language': language,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      biometricsEnabled: json['biometricsEnabled'] as bool? ?? false,
      language: json['language'] as String? ?? 'en',
    );
  }
}

// Settings Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this.localStorage) : super(const SettingsState()) {
    _loadSettings();
  }

  final LocalStorage localStorage;
  static const String _settingsKey = 'app_settings';

  Future<void> _loadSettings() async {
    try {
      final data = localStorage.getJson(_settingsKey);
      if (data != null) {
        state = SettingsState.fromJson(data);
      }
    } catch (e) {
      // If loading fails, keep default settings
    }
  }

  Future<void> _saveSettings() async {
    try {
      await localStorage.setJson(_settingsKey, state.toJson());
    } catch (e) {
      // Handle save error
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    state = state.copyWith(biometricsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  Future<void> clearAllData() async {
    // Clear all app data (cache, settings, etc.)
    await localStorage.clear();
    state = const SettingsState();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(localStorageProvider));
});
""";
}

String _settingsPage(BlueprintConfig config) {
  final buffer = StringBuffer();

  buffer.write("""import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
""");

  if (config.includeApi) {
    buffer.writeln(
        "import '../../../auth/presentation/providers/auth_provider.dart';");
  }

  buffer.write("""
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: _getThemeName(settingsState.themeMode),
                onTap: () => _showThemeDialog(context, ref),
              ),
            ],
          ),
          SettingsSection(
            title: 'Notifications',
            children: [
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: settingsState.notificationsEnabled
                    ? 'Enabled'
                    : 'Disabled',
                trailing: Switch(
                  value: settingsState.notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .setNotificationsEnabled(value);
                  },
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Security',
            children: [
              SettingsTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: settingsState.biometricsEnabled
                    ? 'Enabled'
                    : 'Disabled',
                trailing: Switch(
                  value: settingsState.biometricsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .setBiometricsEnabled(value);
                  },
                ),
              ),
            ],
          ),""");

  if (config.includeApi) {
    buffer.write("""
          SettingsSection(
            title: 'Account',
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'View and edit your profile',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.profile);
                },
              ),
              SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),""");
  }

  buffer.write("""
          SettingsSection(
            title: 'About',
            children: [
              SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {
                  // Navigate to terms
                },
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Danger Zone',
            children: [
              SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear All Data',
                subtitle: 'Remove all cached data',
                titleColor: Colors.red,
                onTap: () => _showClearDataDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(settingsProvider).themeMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: currentTheme,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will remove all cached data and reset the app to its initial state. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }""");

  if (config.includeApi) {
    buffer.write("""

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.login,
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }""");
  }

  buffer.writeln("}");

  return buffer.toString();
}

String _settingsTile(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right)
              : null),
      onTap: onTap,
    );
  }
}
""";
}

String _settingsSection(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
""";
}
