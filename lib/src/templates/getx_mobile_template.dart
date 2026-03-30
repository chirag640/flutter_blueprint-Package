import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import 'accessibility_templates.dart';
import 'analytics_templates.dart';
import 'hive_templates.dart';
import 'pagination_templates.dart';
import 'template_bundle.dart';
import 'ui_kit_templates.dart';
import 'graphql_templates.dart';

/// Builds a GetX-based mobile template with professional architecture.
///
/// Uses the full GetX pattern:
/// - [GetMaterialApp] + [GetPage] + [Bindings] for routing and DI
/// - [GetxController] for state management
/// - [Obx] / [GetX] widgets for reactive UI
/// - [Get.toNamed()] for navigation
/// - [Get.snackbar()] / [Get.dialog()] for overlay UI
TemplateBundle buildGetxMobileBundle() {
  return TemplateBundle(
    files: [
      // ── Base config ──────────────────────────────────────────────────────
      TemplateFile(path: 'analysis_options.yaml', build: _analysisOptions),
      TemplateFile(path: 'pubspec.yaml', build: _pubspec),
      TemplateFile(path: '.gitignore', build: _gitignore),
      TemplateFile(path: 'README.md', build: _readme),

      // ── Main app ─────────────────────────────────────────────────────────
      TemplateFile(path: 'lib/main.dart', build: _mainDart),
      TemplateFile(path: p.join('lib', 'app', 'app.dart'), build: _appDart),

      // ── Core: Config ─────────────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'core', 'config', 'app_config.dart'),
          build: _appConfig),
      TemplateFile(
          path: p.join('lib', 'core', 'config', 'env_loader.dart'),
          build: _envLoader,
          shouldGenerate: (config) => config.includeEnv),

      // ── Core: Constants ──────────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'core', 'constants', 'app_constants.dart'),
          build: _appConstants),
      TemplateFile(
          path: p.join('lib', 'core', 'constants', 'api_endpoints.dart'),
          build: _apiEndpoints,
          shouldGenerate: (config) => config.includeApi),

      // ── Core: Errors ─────────────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'core', 'errors', 'exceptions.dart'),
          build: _exceptions),
      TemplateFile(
          path: p.join('lib', 'core', 'errors', 'failures.dart'),
          build: _failures),

      // ── Core: Network ────────────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'core', 'network', 'network_info.dart'),
          build: _networkInfo,
          shouldGenerate: (config) => config.includeApi),

      // ── Core: Utils ──────────────────────────────────────────────────────
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
      TemplateFile(
          path: p.join('lib', 'core', 'utils', 'app_responsive.dart'),
          build: (c) => generateAppResponsive(c)),

      // ── Core: Routing (GetX style) ───────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'core', 'routing', 'routes.dart'),
          build: _routes),
      TemplateFile(
          path: p.join('lib', 'core', 'routing', 'app_pages.dart'),
          build: _appPages),
      TemplateFile(
          path: p.join('lib', 'core', 'routing', 'app_middleware.dart'),
          build: _appMiddleware),

      // ── Core: Theme ──────────────────────────────────────────────────────
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

      // ── Core: Widgets ────────────────────────────────────────────────────
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

      // ── Core: API ────────────────────────────────────────────────────────
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

      // ── Core: Storage ────────────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'core', 'storage', 'local_storage.dart'),
          build: _localStorage),
      TemplateFile(
          path: p.join('lib', 'core', 'storage', 'secure_storage.dart'),
          build: _secureStorage),

      // ── Core: Hive ───────────────────────────────────────────────────────
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

      // ── Core: Pagination ─────────────────────────────────────────────────
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

      // ── Core: Analytics ──────────────────────────────────────────────────
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

      // ── Core: Accessibility ──────────────────────────────────────────────
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

      // ── Core: GraphQL ────────────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'core', 'graphql', 'graphql_client.dart'),
          build: (c) =>
              GraphqlTemplates.files(
                  c)['lib/core/graphql/graphql_client.dart'] ??
              '',
          shouldGenerate: (config) => config.includeGraphql),
      TemplateFile(
          path: p.join('lib', 'core', 'graphql', 'graphql_service.dart'),
          build: (c) =>
              GraphqlTemplates.files(
                  c)['lib/core/graphql/graphql_service.dart'] ??
              '',
          shouldGenerate: (config) => config.includeGraphql),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'graphql', 'queries', 'example_queries.dart'),
          build: (c) =>
              GraphqlTemplates.files(
                  c)['lib/core/graphql/queries/example_queries.dart'] ??
              '',
          shouldGenerate: (config) =>
              config.includeGraphql &&
              config.graphqlClient == GraphqlClient.graphqlFlutter),
      TemplateFile(
          path: p.join(
              'lib', 'core', 'graphql', 'mutations', 'example_mutations.dart'),
          build: (c) =>
              GraphqlTemplates.files(
                  c)['lib/core/graphql/mutations/example_mutations.dart'] ??
              '',
          shouldGenerate: (config) =>
              config.includeGraphql &&
              config.graphqlClient == GraphqlClient.graphqlFlutter),
      TemplateFile(
          path: p.join('lib', 'core', 'graphql', 'schema.graphql'),
          build: (c) =>
              GraphqlTemplates.files(c)['lib/core/graphql/schema.graphql'] ??
              '',
          shouldGenerate: (config) =>
              config.includeGraphql &&
              config.graphqlClient == GraphqlClient.ferry),
      TemplateFile(
          path:
              p.join('lib', 'core', 'graphql', 'operations', 'example.graphql'),
          build: (c) =>
              GraphqlTemplates.files(
                  c)['lib/core/graphql/operations/example.graphql'] ??
              '',
          shouldGenerate: (config) =>
              config.includeGraphql &&
              config.graphqlClient == GraphqlClient.ferry),
      TemplateFile(
          path: 'build.yaml',
          build: (c) => GraphqlTemplates.files(c)['build.yaml'] ?? '',
          shouldGenerate: (config) =>
              config.includeGraphql &&
              config.graphqlClient == GraphqlClient.ferry),
      TemplateFile(
          path: p.join('lib', 'core', 'controllers', 'app_controller.dart'),
          build: _appController),

      // ── Features: Home ───────────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'pages',
              'home_page.dart'),
          build: _homePage),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'controllers',
              'home_controller.dart'),
          build: _homeController),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'bindings',
              'home_binding.dart'),
          build: _homeBinding),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'widgets',
              'home_content.dart'),
          build: _homeContent),

      // ── Features: Auth ───────────────────────────────────────────────────
      // Domain
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
      // Data
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
      // Presentation
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
          path: p.join('lib', 'features', 'auth', 'presentation', 'controllers',
              'auth_controller.dart'),
          build: _authController,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'bindings',
              'auth_binding.dart'),
          build: _authBinding,
          shouldGenerate: (config) => config.includeApi),

      // ── Features: Profile ────────────────────────────────────────────────
      // Data
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
      // Domain
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'domain', 'repositories',
              'profile_repository.dart'),
          build: _profileRepository,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'domain', 'usecases',
              'get_profile_usecase.dart'),
          build: _getProfileUsecase,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'domain', 'usecases',
              'update_profile_usecase.dart'),
          build: _updateProfileUsecase,
          shouldGenerate: (config) => config.includeApi),
      // Presentation
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
              'controllers', 'profile_controller.dart'),
          build: _profileController,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'features', 'profile', 'presentation', 'bindings',
              'profile_binding.dart'),
          build: _profileBinding,
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

      // ── Features: Settings ───────────────────────────────────────────────
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation', 'pages',
              'settings_page.dart'),
          build: _settingsPage),
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation',
              'controllers', 'settings_controller.dart'),
          build: _settingsController),
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation',
              'bindings', 'settings_binding.dart'),
          build: _settingsBinding),
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation', 'widgets',
              'settings_tile.dart'),
          build: _settingsTile),
      TemplateFile(
          path: p.join('lib', 'features', 'settings', 'presentation', 'widgets',
              'settings_section.dart'),
          build: _settingsSection),

      // ── i18n ─────────────────────────────────────────────────────────────
      TemplateFile(
          path: 'assets/l10n/en.arb',
          build: _l10nEn,
          shouldGenerate: (config) => config.includeLocalization),
      TemplateFile(
          path: 'assets/l10n/hi.arb',
          build: _l10nHi,
          shouldGenerate: (config) => config.includeLocalization),

      // ── Env ──────────────────────────────────────────────────────────────
      TemplateFile(
          path: '.env.example',
          build: _envExample,
          shouldGenerate: (config) => config.includeEnv),

      // ── Tests ────────────────────────────────────────────────────────────
      TemplateFile(
          path: 'test/widget_test.dart',
          build: _widgetTest,
          shouldGenerate: (config) => config.includeTests),
      TemplateFile(
          path: p.join('test', 'core', 'utils', 'validators_test.dart'),
          build: _validatorsTest,
          shouldGenerate: (config) => config.includeTests),
      TemplateFile(
          path: p.join('test', 'helpers', 'test_helpers.dart'),
          build: _testHelpers,
          shouldGenerate: (config) => config.includeTests),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// pubspec.yaml
// ═══════════════════════════════════════════════════════════════════════════

String _pubspec(BlueprintConfig config) {
  final buffer = StringBuffer();
  buffer.writeln('name: ${config.appName}');
  buffer.writeln('description: A Flutter app using GetX state management.');
  buffer.writeln('publish_to: none');
  buffer.writeln('version: 1.0.0+1');
  buffer.writeln();
  buffer.writeln('environment:');
  buffer.writeln('  sdk: ">=3.3.0 <4.0.0"');
  buffer.writeln();
  buffer.writeln('dependencies:');
  buffer.writeln('  flutter:');
  buffer.writeln('    sdk: flutter');
  buffer.writeln();
  buffer.writeln('  # GetX — state management, routing, and DI');
  buffer.writeln('  get: ^4.6.6');
  buffer.writeln();
  buffer.writeln('  # Storage');
  buffer.writeln('  shared_preferences: ^2.2.3');
  buffer.writeln('  flutter_secure_storage: ^9.2.2');
  buffer.writeln();
  buffer.writeln('  # Utilities');
  buffer.writeln('  freezed_annotation: ^3.1.0');
  buffer.writeln('  equatable: ^2.0.5');

  if (config.includeLocalization) {
    buffer.writeln();
    buffer.writeln('  # Localization');
    buffer.writeln('  flutter_localizations:');
    buffer.writeln('    sdk: flutter');
    buffer.writeln('  intl: ^0.20.2');
  }

  if (config.includeEnv) {
    buffer.writeln();
    buffer.writeln('  # Environment');
    buffer.writeln('  flutter_dotenv: ^5.1.0');
  }

  if (config.includeApi) {
    buffer.writeln();
    buffer.writeln('  # Networking');
    buffer.writeln('  dio: ^5.5.0');
    buffer.writeln('  connectivity_plus: ^6.0.5');
    buffer.writeln('  pretty_dio_logger: ^1.4.0');
  }

  if (config.includeHive) {
    buffer.writeln();
    buffer.writeln('  # Offline caching');
    buffer.writeln('  hive: ^2.2.3');
    buffer.writeln('  hive_flutter: ^1.1.0');
    buffer.writeln('  path_provider: ^2.1.5');
  }

  if (config.includeAnalytics) {
    if (config.analyticsProvider == AnalyticsProvider.sentry) {
      buffer.writeln();
      buffer.writeln('  # Sentry');
      buffer.writeln('  sentry_flutter: ^8.9.0');
    } else if (config.analyticsProvider == AnalyticsProvider.firebase) {
      buffer.writeln();
      buffer.writeln('  # Firebase');
      buffer.writeln('  firebase_core: ^3.6.0');
      buffer.writeln('  firebase_analytics: ^11.3.3');
      buffer.writeln('  firebase_crashlytics: ^4.1.3');
      buffer.writeln('  firebase_performance: ^0.10.0+8');
    }
  }

  if (config.includeGraphql) {
    buffer.writeln();
    buffer.writeln('  # GraphQL');
    if (config.graphqlClient == GraphqlClient.graphqlFlutter) {
      buffer.writeln('  graphql_flutter: ^5.1.2');
    } else if (config.graphqlClient == GraphqlClient.ferry) {
      buffer.writeln('  ferry: ^0.16.1+2');
      buffer.writeln('  ferry_flutter: ^0.9.1+1');
      buffer.writeln('  gql_http_link: ^1.2.0');
    }
  }

  buffer.writeln();
  buffer.writeln('dev_dependencies:');
  buffer.writeln('  flutter_test:');
  buffer.writeln('    sdk: flutter');
  buffer.writeln('  flutter_lints: ^5.0.0');
  buffer.writeln('  freezed: ^3.2.2');
  buffer.writeln('  build_runner: ^2.4.8');

  if (config.includeTests) {
    buffer.writeln('  mocktail: ^1.0.3');
  }

  if (config.includeHive) {
    buffer.writeln('  hive_generator: ^2.0.1');
  }

  if (config.includeGraphql && config.graphqlClient == GraphqlClient.ferry) {
    buffer.writeln(
        '  ferry_generator: 0.12.0+3'); // resolved conflict with freezed ^3.2.2 (dart_style clash)
  }

  buffer.writeln();
  buffer.writeln('flutter:');
  buffer.writeln('  uses-material-design: true');

  if (config.includeLocalization) {
    buffer.writeln('  generate: true');
  }

  if (config.includeEnv) {
    buffer.writeln('  assets:');
    buffer.writeln('    - .env');
  }

  return buffer.toString();
}

// ═══════════════════════════════════════════════════════════════════════════
// analysis_options.yaml
// ═══════════════════════════════════════════════════════════════════════════

String _analysisOptions(BlueprintConfig _) => '''
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - use_key_in_widget_constructors
    - prefer_final_fields
    - prefer_single_quotes
''';

// ═══════════════════════════════════════════════════════════════════════════
// .gitignore
// ═══════════════════════════════════════════════════════════════════════════

String _gitignore(BlueprintConfig _) => '''
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.iml
.DS_Store
.env
*.g.dart
*.freezed.dart
''';

// ═══════════════════════════════════════════════════════════════════════════
// README.md
// ═══════════════════════════════════════════════════════════════════════════

String _readme(BlueprintConfig config) => '''
# ${config.appName}

A Flutter application built with **GetX** state management, routing, and dependency injection.

## Architecture

Clean Architecture with GetX:
- **Controllers** — business logic (`GetxController`)
- **Bindings** — dependency injection (`Bindings`)
- **Pages** — UI (`GetView<Controller>`)
- **`Get.toNamed()`** — navigation

## Getting Started

```bash
flutter pub get
flutter run
```
''';

// ═══════════════════════════════════════════════════════════════════════════
// lib/main.dart
// ═══════════════════════════════════════════════════════════════════════════

String _mainDart(BlueprintConfig config) {
  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  if (config.includeEnv) {
    buffer.writeln("import 'package:flutter_dotenv/flutter_dotenv.dart';");
  }
  if (config.includeHive) {
    buffer.writeln("import 'core/database/hive_database.dart';");
  }
  if (config.includeAnalytics &&
      config.analyticsProvider == AnalyticsProvider.sentry) {
    buffer.writeln("import 'package:sentry_flutter/sentry_flutter.dart';");
  }
  if (config.includeAnalytics &&
      config.analyticsProvider == AnalyticsProvider.firebase) {
    buffer.writeln("import 'package:firebase_core/firebase_core.dart';");
  }
  buffer.writeln("import 'app/app.dart';");
  buffer.writeln();
  buffer.writeln('Future<void> main() async {');
  buffer.writeln('  WidgetsFlutterBinding.ensureInitialized();');

  if (config.includeEnv) {
    buffer.writeln("  await dotenv.load(fileName: '.env');");
  }
  if (config.includeHive) {
    buffer.writeln('  await HiveDatabase.instance.init();');
  }
  if (config.includeAnalytics &&
      config.analyticsProvider == AnalyticsProvider.firebase) {
    buffer.writeln('  await Firebase.initializeApp();');
  }
  if (config.includeAnalytics &&
      config.analyticsProvider == AnalyticsProvider.sentry) {
    buffer.writeln('''  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
    },
    appRunner: () => runApp(const App()),
  );''');
  } else {
    buffer.writeln('  runApp(const App());');
  }

  buffer.writeln('}');
  return buffer.toString();
}

// ═══════════════════════════════════════════════════════════════════════════
// lib/app/app.dart
// ═══════════════════════════════════════════════════════════════════════════

String _appDart(BlueprintConfig config) {
  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import 'package:get/get.dart';");
  if (config.includeTheme) {
    buffer.writeln("import '../core/theme/app_theme.dart';");
  }
  buffer.writeln("import '../core/routing/app_pages.dart';");
  buffer.writeln("import '../core/routing/routes.dart';");
  if (config.includeLocalization) {
    buffer.writeln(
        "import 'package:flutter_localizations/flutter_localizations.dart';");
  }
  buffer.writeln();
  buffer.writeln('/// Root application widget using GetMaterialApp.');
  buffer.writeln('class App extends StatelessWidget {');
  buffer.writeln('  const App({super.key});');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  Widget build(BuildContext context) {');
  buffer.writeln('    return GetMaterialApp(');
  buffer.writeln('      title: \'${config.appName}\',');
  buffer.writeln('      debugShowCheckedModeBanner: false,');
  if (config.includeTheme) {
    buffer.writeln('      theme: AppTheme.lightTheme,');
    buffer.writeln('      darkTheme: AppTheme.darkTheme,');
    buffer.writeln('      themeMode: ThemeMode.system,');
  }
  if (config.includeLocalization) {
    buffer.writeln('      localizationsDelegates: const [');
    buffer.writeln('        GlobalMaterialLocalizations.delegate,');
    buffer.writeln('        GlobalWidgetsLocalizations.delegate,');
    buffer.writeln('        GlobalCupertinoLocalizations.delegate,');
    buffer.writeln('      ],');
    buffer
        .writeln("      supportedLocales: const [Locale('en'), Locale('hi')],");
  }
  buffer.writeln('      initialRoute: Routes.home,');
  buffer.writeln('      getPages: AppPages.routes,');
  buffer.writeln('      defaultTransition: Transition.cupertino,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');
  return buffer.toString();
}

// ═══════════════════════════════════════════════════════════════════════════
// Core: Routing
// ═══════════════════════════════════════════════════════════════════════════

String _routes(BlueprintConfig config) => '''
/// Centralized route name constants.
///
/// Usage:
/// ```dart
/// Get.toNamed(Routes.home);
/// Get.offAllNamed(Routes.login);
/// ```
abstract class Routes {
  Routes._();

  static const home     = '/';
  static const settings = '/settings';
${config.includeApi ? '''  static const login       = '/login';
  static const register    = '/register';
  static const profile     = '/profile';
  static const editProfile = '/profile/edit';''' : ''}
}
''';

String _appPages(BlueprintConfig config) {
  final buffer = StringBuffer();
  buffer.writeln("import 'package:get/get.dart';");
  buffer.writeln("import 'routes.dart';");
  buffer.writeln("import 'app_middleware.dart';");
  buffer.writeln(
      "import '../../features/home/presentation/pages/home_page.dart';");
  buffer.writeln(
      "import '../../features/home/presentation/bindings/home_binding.dart';");
  buffer.writeln(
      "import '../../features/settings/presentation/pages/settings_page.dart';");
  buffer.writeln(
      "import '../../features/settings/presentation/bindings/settings_binding.dart';");
  if (config.includeApi) {
    buffer.writeln(
        "import '../../features/auth/presentation/pages/login_page.dart';");
    buffer.writeln(
        "import '../../features/auth/presentation/pages/register_page.dart';");
    buffer.writeln(
        "import '../../features/auth/presentation/bindings/auth_binding.dart';");
    buffer.writeln(
        "import '../../features/profile/presentation/pages/profile_page.dart';");
    buffer.writeln(
        "import '../../features/profile/presentation/pages/edit_profile_page.dart';");
    buffer.writeln(
        "import '../../features/profile/presentation/bindings/profile_binding.dart';");
  }
  buffer.writeln();
  buffer.writeln(
      '/// Defines all routes and their bindings for GetX navigation.');
  buffer.writeln('abstract class AppPages {');
  buffer.writeln('  AppPages._();');
  buffer.writeln();
  buffer.writeln('  static final routes = [');
  buffer.writeln('    GetPage(');
  buffer.writeln('      name: Routes.home,');
  buffer.writeln('      page: () => const HomePage(),');
  buffer.writeln('      binding: HomeBinding(),');
  if (config.includeApi) {
    buffer.writeln('      middlewares: [AuthMiddleware()],');
  }
  buffer.writeln('    ),');
  buffer.writeln('    GetPage(');
  buffer.writeln('      name: Routes.settings,');
  buffer.writeln('      page: () => const SettingsPage(),');
  buffer.writeln('      binding: SettingsBinding(),');
  buffer.writeln('    ),');
  if (config.includeApi) {
    buffer.writeln('    GetPage(');
    buffer.writeln('      name: Routes.login,');
    buffer.writeln('      page: () => const LoginPage(),');
    buffer.writeln('      binding: AuthBinding(),');
    buffer.writeln('    ),');
    buffer.writeln('    GetPage(');
    buffer.writeln('      name: Routes.register,');
    buffer.writeln('      page: () => const RegisterPage(),');
    buffer.writeln('      binding: AuthBinding(),');
    buffer.writeln('    ),');
    buffer.writeln('    GetPage(');
    buffer.writeln('      name: Routes.profile,');
    buffer.writeln('      page: () => const ProfilePage(),');
    buffer.writeln('      binding: ProfileBinding(),');
    buffer.writeln('      middlewares: [AuthMiddleware()],');
    buffer.writeln('    ),');
    buffer.writeln('    GetPage(');
    buffer.writeln('      name: Routes.editProfile,');
    buffer.writeln('      page: () => const EditProfilePage(),');
    buffer.writeln('      binding: ProfileBinding(),');
    buffer.writeln('      middlewares: [AuthMiddleware()],');
    buffer.writeln('    ),');
  }
  buffer.writeln('  ];');
  buffer.writeln('}');
  return buffer.toString();
}

String _appMiddleware(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/secure_storage.dart';
import 'routes.dart';

/// Middleware that redirects unauthenticated users to the login page.
///
/// Attach to routes that require authentication in [AppPages].
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<AppSecureStorage>();
    final token = storage.getToken();
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: Routes.${config.includeApi ? 'login' : 'home'});
    }
    return null;
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: App-wide Controller
// ═══════════════════════════════════════════════════════════════════════════

String _appController(BlueprintConfig config) => '''
import 'package:get/get.dart';

import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// App-wide GetX controller for global state (theme, locale, etc.).
class AppController extends GetxController {
  static AppController get to => Get.find();

  late final AppLocalStorage _localStorage;
  late final AppSecureStorage _secureStorage;

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _localStorage = Get.find<AppLocalStorage>();
    _secureStorage = Get.find<AppSecureStorage>();
    _loadPreferences();
  }

  void _loadPreferences() {
    // Load persisted preferences
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  bool get isLoggedIn {
    final token = _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Config
// ═══════════════════════════════════════════════════════════════════════════

String _appConfig(BlueprintConfig config) => '''
/// Central application configuration.
class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl =>
      const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');

  static String get appName => '${config.appName}';

  static bool get isProduction =>
      const String.fromEnvironment('ENV', defaultValue: 'development') == 'production';
}
''';

String _envLoader(BlueprintConfig _) => '''
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper for reading environment variables safely.
class EnvLoader {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Constants
// ═══════════════════════════════════════════════════════════════════════════

String _appConstants(BlueprintConfig _) => '''
/// App-wide constants.
abstract class AppConstants {
  // Timeouts (ms)
  static const int connectTimeout  = 30000;
  static const int receiveTimeout  = 30000;
  static const int sendTimeout     = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache TTL
  static const Duration cacheTtl = Duration(hours: 1);
}
''';

String _apiEndpoints(BlueprintConfig _) => '''
/// API endpoint constants.
abstract class ApiEndpoints {
  // Auth
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
  static const String logout   = '/auth/logout';
  static const String me       = '/auth/me';

  // Profile
  static const String profile       = '/profile';
  static const String updateProfile = '/profile';

  // Home / Posts (example)
  static const String posts = '/posts';
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Errors
// ═══════════════════════════════════════════════════════════════════════════

String _exceptions(BlueprintConfig _) => '''
/// Base exception class.
class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

class NetworkException     extends AppException { const NetworkException(super.message); }
class ServerException      extends AppException { const ServerException(super.message); }
class UnauthorizedException extends AppException { const UnauthorizedException([String message = 'Unauthorized']) : super(message); }
class NotFoundException    extends AppException { const NotFoundException(super.message); }
class CacheException       extends AppException { const CacheException(super.message); }
class ValidationException  extends AppException { const ValidationException(super.message); }
''';

String _failures(BlueprintConfig _) => '''
import 'package:equatable/equatable.dart';

/// Base failure class for domain/use-case error handling.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class NetworkFailure      extends Failure { const NetworkFailure(super.message); }
class ServerFailure       extends Failure { const ServerFailure(super.message); }
class UnauthorizedFailure extends Failure { const UnauthorizedFailure([String message = 'Unauthorized']) : super(message); }
class NotFoundFailure     extends Failure { const NotFoundFailure(super.message); }
class CacheFailure        extends Failure { const CacheFailure(super.message); }
class ValidationFailure   extends Failure { const ValidationFailure(super.message); }
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Network
// ═══════════════════════════════════════════════════════════════════════════

String _networkInfo(BlueprintConfig _) => '''
import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks network connectivity.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this._connectivity);
  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Utils
// ═══════════════════════════════════════════════════════════════════════════

String _logger(BlueprintConfig _) => '''
import 'package:flutter/foundation.dart';

/// Simple logger that is suppressed in release builds.
class AppLogger {
  static void info(String msg)    { if (kDebugMode) debugPrint('[INFO]  \$msg'); }
  static void warn(String msg)    { if (kDebugMode) debugPrint('[WARN]  \$msg'); }
  static void error(String msg)   { if (kDebugMode) debugPrint('[ERROR] \$msg'); }
  static void debug(String msg)   { if (kDebugMode) debugPrint('[DEBUG] \$msg'); }
}
''';

String _validators(BlueprintConfig _) => '''
/// Common form validation helpers.
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final re = RegExp('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[.][a-zA-Z]{2,}', caseSensitive: false);
    if (!re.hasMatch(value) || !value.contains('@') || !value.contains('.')) return 'Invalid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '\$fieldName is required';
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'Field'}) {
    if (value == null || value.length < min) return '\$fieldName must be at least \$min characters';
    return null;
  }
}
''';

String _extensions(BlueprintConfig _) => '''
extension StringEx on String {
  String get capitalize => isEmpty ? this : this[0].toUpperCase() + substring(1);
  String get titleCase  => split(' ').map((w) => w.capitalize).join(' ');
  bool   get isValidEmail => RegExp('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[.][a-zA-Z]{2,}').hasMatch(this);
}

extension ContextEx on DateTime {
  String get formatted {
    return '\$year-\${month.toString().padLeft(2,'0')}-\${day.toString().padLeft(2,'0')}';
  }
}
''';

String _dialogUtils(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility wrappers around Get.dialog / Get.bottomSheet.
class DialogUtils {
  /// Shows a confirmation dialog. Returns true if confirmed.
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText  = 'Confirm',
    String cancelText   = 'Cancel',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a loading dialog.
  static void showLoading({String message = 'Loading...'}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Dismisses the loading dialog.
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}
''';

String _snackbarUtils(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility wrappers around [Get.snackbar].
class SnackbarUtils {
  static void success(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Success',
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  static void error(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Error',
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  static void info(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
''';

String _networkSettings(BlueprintConfig _) => '''
/// Network configuration constants.
abstract class NetworkSettings {
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 30);
  static const int maxRetries          = 3;
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Theme
// ═══════════════════════════════════════════════════════════════════════════

String _appTheme(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';

/// App-wide Material 3 theme configuration.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: AppTypography.textTheme,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTypography.textTheme,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}
''';

String _typography(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

/// App text styles.
abstract class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium:TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge:    TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );
}
''';

String _appColors(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

/// Centralized color palette.
abstract class AppColors {
  static const primary   = Color(0xFF6750A4);
  static const secondary = Color(0xFF625B71);
  static const error     = Color(0xFFB3261E);
  static const success   = Color(0xFF4CAF50);
  static const warning   = Color(0xFFFF9800);
  static const surface   = Color(0xFFFFFBFE);
  static const background= Color(0xFFFFFBFE);
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Widgets
// ═══════════════════════════════════════════════════════════════════════════

String _loadingIndicator(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
''';

String _errorView(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
''';

String _emptyState(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});
  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
''';

String _customButton(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label);

    if (isOutlined) {
      return OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);
    }
    return ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);
  }
}
''';

String _customTextField(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.hint,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: API
// ═══════════════════════════════════════════════════════════════════════════

String _apiClient(BlueprintConfig config) => '''
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';

/// Dio-based HTTP client with auth, retry, and logging interceptors.
class ApiClient {
  ApiClient({Dio? dio, AppSecureStorage? secureStorage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.delete<T>(path, data: data, options: options);
}
''';

String _apiResponse(BlueprintConfig _) => '''
/// Generic API response wrapper.
class ApiResponse<T> {
  const ApiResponse({required this.data, this.message, this.statusCode});
  final T? data;
  final String? message;
  final int? statusCode;

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse(
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : null,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }
}
''';

String _authInterceptor(BlueprintConfig _) => '''
import 'package:dio/dio.dart';
import 'package:get/get.dart' show Get;
import '../../storage/secure_storage.dart';

/// Injects the Bearer token into Authorization header.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final storage = Get.find<AppSecureStorage>();
      final token = storage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer \$token';
      }
    } catch (_) {}
    super.onRequest(options, handler);
  }
}
''';

String _loggerInterceptor(BlueprintConfig _) => '''
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs requests and responses in debug mode.
class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API] --> \${options.method} \${options.uri}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API] <-- \${response.statusCode} \${response.requestOptions.uri}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[API] ERR \${err.response?.statusCode}: \${err.message}');
    }
    super.onError(err, handler);
  }
}
''';

String _retryInterceptor(BlueprintConfig _) => '''
import 'package:dio/dio.dart';

/// Automatically retries failed requests up to 3 times on 5xx or network errors.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  RetryInterceptor({this.maxRetries = 3});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRetry = err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);

    final attempt = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
    if (shouldRetry && attempt < maxRetries) {
      err.requestOptions.extra['retryCount'] = attempt + 1;
      try {
        final response = await err.requestOptions
            .copyWith()
            .let((opts) => Dio().fetch(opts));
        handler.resolve(response);
        return;
      } catch (e) {
        // Fall through to original error
      }
    }
    super.onError(err, handler);
  }
}

extension _ReqEx on RequestOptions {
  RequestOptions copyWith() => RequestOptions(
    method: method, path: path, data: data,
    queryParameters: queryParameters, headers: headers,
    extra: extra, baseUrl: baseUrl,
  );
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Storage
// ═══════════════════════════════════════════════════════════════════════════

String _localStorage(BlueprintConfig _) => '''
import 'package:shared_preferences/shared_preferences.dart';

/// Key-value local storage backed by SharedPreferences.
class AppLocalStorage {
  AppLocalStorage._(this._prefs);
  final SharedPreferences _prefs;

  static Future<AppLocalStorage> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLocalStorage._(prefs);
  }

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String?      getString(String key)               => _prefs.getString(key);
  Future<bool> setBool(String key, bool value)     => _prefs.setBool(key, value);
  bool?        getBool(String key)                 => _prefs.getBool(key);
  Future<bool> remove(String key)                  => _prefs.remove(key);
  Future<bool> clear()                             => _prefs.clear();
}
''';

String _secureStorage(BlueprintConfig _) => '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for sensitive values like tokens.
class AppSecureStorage {
  const AppSecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey        = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  String? getToken() {
    // Synchronous-style: use readAll for sync patterns; prefer async in practice
    return null; // Override with async read in production
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Core: Hive (delegate to shared hive_templates.dart helpers)
// ═══════════════════════════════════════════════════════════════════════════

String _hiveDatabase(BlueprintConfig c) => generateHiveDatabase(c);
String _cacheManager(BlueprintConfig c) => generateCacheManager(c);
String _syncManager(BlueprintConfig c) => generateSyncManager(c);

// ═══════════════════════════════════════════════════════════════════════════
// Core: Pagination (delegate)
// ═══════════════════════════════════════════════════════════════════════════

String _paginationController(BlueprintConfig c) =>
    generatePaginationController(c);
String _paginatedListView(BlueprintConfig c) => generatePaginatedListView(c);
String _skeletonLoader(BlueprintConfig c) => generateSkeletonLoader(c);

// ═══════════════════════════════════════════════════════════════════════════
// Core: Analytics (delegate)
// ═══════════════════════════════════════════════════════════════════════════

String _analyticsService(BlueprintConfig c) => generateAnalyticsService();
String _firebaseAnalyticsService(BlueprintConfig c) =>
    generateFirebaseAnalyticsService();
String _sentryService(BlueprintConfig c) => generateSentryService();
String _analyticsEvents(BlueprintConfig c) => generateAnalyticsEvents();
String _errorBoundary(BlueprintConfig c) => generateErrorBoundary();

// ═══════════════════════════════════════════════════════════════════════════
// Core: Accessibility (delegate)
// ═══════════════════════════════════════════════════════════════════════════

String _semanticsHelper(BlueprintConfig c) => generateSemanticsHelper();
String _contrastChecker(BlueprintConfig c) => generateContrastChecker();
String _focusManager(BlueprintConfig c) => generateFocusManager();
String _accessibilityConfig(BlueprintConfig c) => generateAccessibilityConfig();
String _accessibilityTestUtils(BlueprintConfig c) =>
    generateAccessibilityTestUtils();

// ═══════════════════════════════════════════════════════════════════════════
// Features: Home
// ═══════════════════════════════════════════════════════════════════════════

String _homeController(BlueprintConfig config) => '''
import 'package:get/get.dart';
import '../../../../core/utils/logger.dart';
${config.includeApi ? "import '../../../../core/api/api_client.dart';" : ''}

/// Home feature GetX controller.
class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final items      = <HomeItem>[].obs;
  final isLoading  = false.obs;
  final hasError   = false.obs;
  final errorMsg   = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    isLoading.value = true;
    hasError.value  = false;
    try {
      ${config.includeApi ? '''final api = Get.find<ApiClient>();
      final response = await api.get('/posts', queryParameters: {'_limit': 10});
      final data = response.data as List;
      items.value = data
          .map((e) => HomeItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();''' : '''// Simulated data — replace with real data source
      await Future.delayed(const Duration(milliseconds: 500));
      items.value = List.generate(
        5,
        (i) => HomeItem(id: i + 1, title: 'Item \${i + 1}', body: 'Body for item \${i + 1}'),
      );'''}
    } catch (e) {
      hasError.value = true;
      errorMsg.value = e.toString();
      AppLogger.error('HomeController.loadItems: \$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadItems();
}

class HomeItem {
  const HomeItem({required this.id, required this.title, required this.body});

  final int    id;
  final String title;
  final String body;

  factory HomeItem.fromJson(Map<String, dynamic> json) => HomeItem(
    id:    json['id']    as int,
    title: json['title'] as String,
    body:  json['body']  as String,
  );
}
''';

String _homeBinding(BlueprintConfig config) => '''
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
${config.includeApi ? "import '../../../../core/api/api_client.dart';" : ''}

/// Dependency binding for the Home feature.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    ${config.includeApi ? 'Get.lazyPut<ApiClient>(() => ApiClient());' : '// No extra deps required'}
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
''';

String _homePage(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_content.dart';
import '../../../../core/routing/routes.dart';

/// Home screen — uses GetView for automatic controller access.
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMsg.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return HomeContent(items: controller.items);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.refresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
''';

String _homeContent(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Renders the list of home items reactively.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.items});
  final RxList<HomeItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text('\${item.id}')),
            title: Text(item.title),
            subtitle: Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        );
      },
    );
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Features: Auth — Domain
// ═══════════════════════════════════════════════════════════════════════════

String _authUserEntity(BlueprintConfig _) => '''
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({required this.id, required this.email, this.name, this.avatar});
  final String  id;
  final String  email;
  final String? name;
  final String? avatar;
  @override List<Object?> get props => [id, email, name, avatar];
}
''';

String _authRepository(BlueprintConfig _) => '''
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({required String name, required String email, required String password});
  Future<void>       logout();
  Future<UserEntity?> getCurrentUser();
}
''';

String _authLoginUsecase(BlueprintConfig _) => '''
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;
  Future<UserEntity> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
''';

String _authRegisterUsecase(BlueprintConfig _) => '''
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);
  final AuthRepository _repository;
  Future<UserEntity> call({required String name, required String email, required String password}) =>
      _repository.register(name: name, email: email, password: password);
}
''';

String _authLogoutUsecase(BlueprintConfig _) => '''
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;
  Future<void> call() => _repository.logout();
}
''';

String _authGetCurrentUserUsecase(BlueprintConfig _) => '''
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;
  Future<UserEntity?> call() => _repository.getCurrentUser();
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Features: Auth — Data
// ═══════════════════════════════════════════════════════════════════════════

String _authUserModel(BlueprintConfig _) => '''
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email, super.name, super.avatar});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:     json['id'].toString(),
    email:  json['email'] as String,
    name:   json['name']   as String?,
    avatar: json['avatar'] as String?,
  );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name, 'avatar': avatar};
}
''';

String _authResponseModel(BlueprintConfig _) => '''
import 'user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.user, required this.accessToken, this.refreshToken});

  final UserModel user;
  final String    accessToken;
  final String?   refreshToken;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AuthResponseModel(
      user:         UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken:  data['accessToken']  as String,
      refreshToken: data['refreshToken'] as String?,
    );
  }
}
''';

String _authRemoteDataSource(BlueprintConfig _) => '''
import '../../../../core/api/api_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({required String email, required String password});
  Future<AuthResponseModel> register({required String name, required String email, required String password});
  Future<void>              logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    final response = await _apiClient.post('/auth/login', data: {'email': email, 'password': password});
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> register({required String name, required String email, required String password}) async {
    final response = await _apiClient.post('/auth/register', data: {'name': name, 'email': email, 'password': password});
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() => _apiClient.post('/auth/logout');
}
''';

String _authLocalDataSource(BlueprintConfig _) => '''
import '../../../../core/storage/secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._storage);
  final AppSecureStorage _storage;

  @override
  Future<void> cacheToken(String token) => _storage.saveToken(token);

  @override
  Future<String?> getToken() => _storage.readToken();

  @override
  Future<void> clearToken() => _storage.clearTokens();
}
''';

String _authRepositoryImpl(BlueprintConfig _) => '''
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource  localDataSource;

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    final response = await remoteDataSource.login(email: email, password: password);
    await localDataSource.cacheToken(response.accessToken);
    return response.user;
  }

  @override
  Future<UserEntity> register({required String name, required String email, required String password}) async {
    final response = await remoteDataSource.register(name: name, email: email, password: password);
    await localDataSource.cacheToken(response.accessToken);
    return response.user;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await localDataSource.clearToken();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return null; // Load from local cache or API
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Features: Auth — Presentation
// ═══════════════════════════════════════════════════════════════════════════

String _authController(BlueprintConfig _) => '''
import 'package:get/get.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/snackbar_utils.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _login    = loginUseCase,
        _register = registerUseCase,
        _logout   = logoutUseCase;

  final LoginUseCase    _login;
  final RegisterUseCase _register;
  final LogoutUseCase   _logout;

  final isLoading = false.obs;
  final currentUser = Rxn<UserEntity>();

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final user = await _login(email: email, password: password);
      currentUser.value = user;
      Get.offAllNamed(Routes.home);
    } catch (e) {
      SnackbarUtils.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password) async {
    isLoading.value = true;
    try {
      final user = await _register(name: name, email: email, password: password);
      currentUser.value = user;
      Get.offAllNamed(Routes.home);
    } catch (e) {
      SnackbarUtils.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _logout();
      currentUser.value = null;
      Get.offAllNamed(Routes.login);
    } catch (e) {
      SnackbarUtils.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
''';

String _authBinding(BlueprintConfig _) => '''
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(Get.find<AppSecureStorage>()),
    );
    Get.lazyPut<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource:  Get.find<AuthLocalDataSource>(),
      ),
    );
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUseCase:    LoginUseCase(Get.find<AuthRepositoryImpl>()),
        registerUseCase: RegisterUseCase(Get.find<AuthRepositoryImpl>()),
        logoutUseCase:   LogoutUseCase(Get.find<AuthRepositoryImpl>()),
      ),
    );
  }
}
''';

String _authLoginPage(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/validators.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl    = TextEditingController();
    final passwordCtrl = TextEditingController();
    final formKey      = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthTextField(
                label: 'Email',
                controller: emailCtrl,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Password',
                controller: passwordCtrl,
                validator: Validators.password,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Obx(() => AuthButton(
                label: 'Login',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    controller.login(emailCtrl.text.trim(), passwordCtrl.text);
                  }
                },
              )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.toNamed(Routes.register),
                child: const Text('Don\\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';

String _authRegisterPage(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../../../core/utils/validators.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl     = TextEditingController();
    final emailCtrl    = TextEditingController();
    final passwordCtrl = TextEditingController();
    final formKey      = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthTextField(label: 'Name', controller: nameCtrl,
                  validator: (v) => Validators.required(v, fieldName: 'Name')),
              const SizedBox(height: 16),
              AuthTextField(label: 'Email', controller: emailCtrl,
                  validator: Validators.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              AuthTextField(label: 'Password', controller: passwordCtrl,
                  validator: Validators.password, obscureText: true),
              const SizedBox(height: 24),
              Obx(() => AuthButton(
                label: 'Register',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    controller.register(nameCtrl.text.trim(), emailCtrl.text.trim(), passwordCtrl.text);
                  }
                },
              )),
              const SizedBox(height: 16),
              TextButton(onPressed: Get.back, child: const Text('Already have an account? Login')),
            ],
          ),
        ),
      ),
    );
  }
}
''';

String _authTextField(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
  });
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }
}
''';

String _authButton(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.label, required this.onPressed, this.isLoading = false});
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      ),
    );
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Features: Profile — Domain
// ═══════════════════════════════════════════════════════════════════════════

String _profileRepository(BlueprintConfig _) => '''
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity>  getProfile(String userId);
  Future<UserEntity>  updateProfile({required String userId, String? name, String? avatar});
}
''';

String _getProfileUsecase(BlueprintConfig _) => '''
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);
  final ProfileRepository _repository;
  Future<UserEntity> call(String userId) => _repository.getProfile(userId);
}
''';

String _updateProfileUsecase(BlueprintConfig _) => '''
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final ProfileRepository _repository;
  Future<UserEntity> call({required String userId, String? name, String? avatar}) =>
      _repository.updateProfile(userId: userId, name: name, avatar: avatar);
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Features: Profile — Data
// ═══════════════════════════════════════════════════════════════════════════

String _profileModel(BlueprintConfig _) => '''
import '../../../auth/data/models/user_model.dart';

class ProfileModel extends UserModel {
  const ProfileModel({required super.id, required super.email, super.name, super.avatar, this.bio});
  final String? bio;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id:     json['id'].toString(),
    email:  json['email'] as String,
    name:   json['name']   as String?,
    avatar: json['avatar'] as String?,
    bio:    json['bio']    as String?,
  );
}
''';

String _profileRemoteDataSource(BlueprintConfig _) => '''
import '../../../../core/api/api_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> updateProfile({required String userId, String? name, String? avatar});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<ProfileModel> getProfile(String userId) async {
    final r = await _apiClient.get('/profile/\$userId');
    return ProfileModel.fromJson(r.data as Map<String, dynamic>);
  }

  @override
  Future<ProfileModel> updateProfile({required String userId, String? name, String? avatar}) async {
    final r = await _apiClient.put('/profile/\$userId', data: {'name': name, 'avatar': avatar});
    return ProfileModel.fromJson(r.data as Map<String, dynamic>);
  }
}
''';

String _profileLocalDataSource(BlueprintConfig _) => '''
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<void>          cacheProfile(ProfileModel profile);
  Future<ProfileModel?> getCachedProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileModel? _cached;

  @override
  Future<void>          cacheProfile(ProfileModel profile) async => _cached = profile;

  @override
  Future<ProfileModel?> getCachedProfile() async => _cached;
}
''';

String _profileRepositoryImpl(BlueprintConfig _) => '''
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource  localDataSource;

  @override
  Future<UserEntity> getProfile(String userId) async {
    final profile = await remoteDataSource.getProfile(userId);
    await localDataSource.cacheProfile(profile);
    return profile;
  }

  @override
  Future<UserEntity> updateProfile({required String userId, String? name, String? avatar}) =>
      remoteDataSource.updateProfile(userId: userId, name: name, avatar: avatar);
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Features: Profile — Presentation
// ═══════════════════════════════════════════════════════════════════════════

String _profileController(BlueprintConfig _) => '''
import 'package:get/get.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/utils/snackbar_utils.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  ProfileController({required GetProfileUseCase getProfile, required UpdateProfileUseCase updateProfile})
      : _getProfile    = getProfile,
        _updateProfile = updateProfile;

  final GetProfileUseCase    _getProfile;
  final UpdateProfileUseCase _updateProfile;

  final profile   = Rxn<UserEntity>();
  final isLoading = false.obs;

  Future<void> loadProfile(String userId) async {
    isLoading.value = true;
    try {
      profile.value = await _getProfile(userId);
    } catch (e) {
      SnackbarUtils.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({required String userId, String? name, String? avatar}) async {
    isLoading.value = true;
    try {
      profile.value = await _updateProfile(userId: userId, name: name, avatar: avatar);
      SnackbarUtils.success('Profile updated');
    } catch (e) {
      SnackbarUtils.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
''';

String _profileBinding(BlueprintConfig _) => '''
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../../core/api/api_client.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<ProfileLocalDataSource>(() => ProfileLocalDataSourceImpl());
    Get.lazyPut<ProfileRepositoryImpl>(
      () => ProfileRepositoryImpl(
        remoteDataSource: Get.find<ProfileRemoteDataSource>(),
        localDataSource:  Get.find<ProfileLocalDataSource>(),
      ),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        getProfile:    GetProfileUseCase(Get.find<ProfileRepositoryImpl>()),
        updateProfile: UpdateProfileUseCase(Get.find<ProfileRepositoryImpl>()),
      ),
    );
  }
}
''';

String _profilePage(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_tile.dart';
import '../../../../core/routing/routes.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => Get.toNamed(Routes.editProfile)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = controller.profile.value;
        if (user == null) {
          return const Center(child: Text('No profile data'));
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ProfileAvatar(avatarUrl: user.avatar),
            const SizedBox(height: 24),
            ProfileInfoTile(label: 'Name',  value: user.name  ?? '-'),
            ProfileInfoTile(label: 'Email', value: user.email),
          ],
        );
      }),
    );
  }
}
''';

String _editProfilePage(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: controller.profile.value?.name);
    final formKey  = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Name',
                controller: nameCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                label: 'Save',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final userId = controller.profile.value?.id ?? '';
                    controller.updateProfile(userId: userId, name: nameCtrl.text.trim());
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
''';

String _profileAvatar(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.avatarUrl, this.radius = 48});
  final String? avatarUrl;
  final double  radius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: radius,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null ? const Icon(Icons.person, size: 48) : null,
      ),
    );
  }
}
''';

String _profileInfoTile(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// Features: Settings
// ═══════════════════════════════════════════════════════════════════════════

String _settingsController(BlueprintConfig _) => '''
import 'package:get/get.dart';
import '../../../../core/storage/local_storage.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final isDarkMode        = false.obs;
  final notificationsOn   = true.obs;
  final selectedLanguage  = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final storage = Get.find<AppLocalStorage>();
      isDarkMode.value      = storage.getBool('dark_mode')     ?? false;
      notificationsOn.value = storage.getBool('notifications') ?? true;
      selectedLanguage.value= storage.getString('language')    ?? 'English';
    } catch (_) {}
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    final storage = Get.find<AppLocalStorage>();
    await storage.setBool('dark_mode', isDarkMode.value);
  }

  Future<void> toggleNotifications() async {
    notificationsOn.value = !notificationsOn.value;
    final storage = Get.find<AppLocalStorage>();
    await storage.setBool('notifications', notificationsOn.value);
  }

  Future<void> setLanguage(String language) async {
    selectedLanguage.value = language;
    final storage = Get.find<AppLocalStorage>();
    await storage.setString('language', language);
  }
}
''';

String _settingsBinding(BlueprintConfig _) => '''
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
''';

String _settingsPage(BlueprintConfig _) => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_section.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              Obx(() => SettingsTile(
                title: 'Dark Mode',
                subtitle: controller.isDarkMode.value ? 'On' : 'Off',
                trailing: Switch(
                  value: controller.isDarkMode.value,
                  onChanged: (_) => controller.toggleDarkMode(),
                ),
              )),
            ],
          ),
          SettingsSection(
            title: 'Notifications',
            children: [
              Obx(() => SettingsTile(
                title: 'Push Notifications',
                subtitle: controller.notificationsOn.value ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: controller.notificationsOn.value,
                  onChanged: (_) => controller.toggleNotifications(),
                ),
              )),
            ],
          ),
          SettingsSection(
            title: 'About',
            children: [
              SettingsTile(
                title: 'App Version',
                subtitle: '1.0.0',
                trailing: const Icon(Icons.info_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
''';

String _settingsTile(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });
  final String  title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:    Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading:  leading,
      trailing: trailing,
      onTap:    onTap,
    );
  }
}
''';

String _settingsSection(BlueprintConfig _) => '''
import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children});
  final String       title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// i18n
// ═══════════════════════════════════════════════════════════════════════════

String _l10nEn(BlueprintConfig config) => '''
{
  "@@locale": "en",
  "appTitle": "${config.appName}",
  "homeTitle": "Home",
  "settingsTitle": "Settings",
  "login": "Login",
  "register": "Register",
  "logout": "Logout",
  "email": "Email",
  "password": "Password",
  "save": "Save",
  "cancel": "Cancel",
  "retry": "Retry",
  "error": "Error",
  "loading": "Loading...",
  "noItems": "No items found"
}
''';

String _l10nHi(BlueprintConfig config) => '''
{
  "@@locale": "hi",
  "appTitle": "${config.appName}",
  "homeTitle": "होम",
  "settingsTitle": "सेटिंग्स",
  "login": "लॉग इन",
  "register": "पंजीकरण",
  "logout": "लॉग आउट",
  "email": "ईमेल",
  "password": "पासवर्ड",
  "save": "सहेजें",
  "cancel": "रद्द करें",
  "retry": "पुनः प्रयास",
  "error": "त्रुटि",
  "loading": "लोड हो रहा है...",
  "noItems": "कोई आइटम नहीं मिला"
}
''';

// ═══════════════════════════════════════════════════════════════════════════
// .env.example
// ═══════════════════════════════════════════════════════════════════════════

String _envExample(BlueprintConfig _) => '''
# Copy this file to .env and fill in the values.
API_BASE_URL=https://api.example.com
ENV=development
''';

// ═══════════════════════════════════════════════════════════════════════════
// Tests
// ═══════════════════════════════════════════════════════════════════════════

String _widgetTest(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:${config.appName}/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
''';

String _validatorsTest(BlueprintConfig config) => '''
import 'package:flutter_test/flutter_test.dart';
import 'package:${config.appName}/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
      });
      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
      });
      test('returns error for invalid email', () {
        expect(Validators.email('not-an-email'), isNotNull);
      });
    });

    group('password', () {
      test('returns null for valid password', () {
        expect(Validators.password('securepass'), isNull);
      });
      test('returns error for short password', () {
        expect(Validators.password('abc'), isNotNull);
      });
    });
  });
}
''';

String _testHelpers(BlueprintConfig config) => '''
import 'package:get/get.dart';

/// Helpers for widget and unit tests.
class TestHelpers {
  /// Resets the GetX controller registry between tests.
  static void resetGetx() => Get.reset();
}
''';
