import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import 'analytics_templates.dart';
import 'hive_templates.dart';
import 'pagination_templates.dart';
import 'template_bundle.dart';
import 'shared_templates.dart';

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
          build: _routeNamesUpdated),

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
          path: p.join('lib', 'core', 'api', 'api_response_parser.dart'),
          build: _apiResponseParser,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path: p.join('lib', 'core', 'api', 'interceptors',
              'unified_response_interceptor.dart'),
          build: _unifiedResponseInterceptor,
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

      // Core: Providers (Global Riverpod providers)
      TemplateFile(
          path: p.join('lib', 'core', 'providers', 'app_providers.dart'),
          build: _appProviders),
      TemplateFile(
          path:
              p.join('lib', 'core', 'providers', 'connectivity_provider.dart'),
          build: _connectivityProvider,
          shouldGenerate: (config) => config.includeApi),
      TemplateFile(
          path:
              p.join('lib', 'core', 'providers', 'error_handler_provider.dart'),
          build: _errorHandlerProvider),

      // Core: Repository pattern
      TemplateFile(
          path: p.join('lib', 'core', 'repository', 'base_repository.dart'),
          build: _baseRepository,
          shouldGenerate: (config) => config.includeApi),

      // Features: Auth
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'data', 'repositories',
              'auth_repository.dart'),
          build: _authRepository),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'providers',
              'auth_provider.dart'),
          build: _authProvider),
      TemplateFile(
          path: p.join('lib', 'features', 'auth', 'presentation', 'pages',
              'login_page.dart'),
          build: _loginPage),

      // Features: Home
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'pages',
              'home_page.dart'),
          build: _homePageUpdated),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'providers',
              'home_provider.dart'),
          build: _homeProvider),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'widgets',
              'home_content.dart'),
          build: _homeContent),

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
  return """# Flutter analysis options with Riverpod support
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_web_libraries_in_flutter
    - cancel_subscriptions
    - close_sinks
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - require_trailing_commas
    - use_key_in_widget_constructors
""";
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

  // Modern Riverpod with code generation support
  buffer
    ..writeln('  flutter_riverpod: ^2.6.1')
    ..writeln('  riverpod_annotation: ^2.6.1')
    ..writeln('  go_router: ^14.8.1')
    ..writeln('  shared_preferences: ^2.2.3')
    ..writeln('  flutter_secure_storage: ^9.2.2')
    ..writeln('  equatable: ^2.0.5');

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

  buffer
    ..writeln('')
    ..writeln('dev_dependencies:')
    ..writeln('  flutter_test:')
    ..writeln('    sdk: flutter')
    ..writeln('  flutter_lints: ^5.0.0')
    ..writeln('  build_runner: ^2.4.15')
    ..writeln('  riverpod_generator: ^2.6.5')
    ..writeln('  riverpod_lint: ^2.6.5')
    ..writeln('  custom_lint: ^0.7.5');
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
  final title = _titleCase(config.appName);
  return '''# $title

Generated with flutter_blueprint using **Riverpod 2.x** state management.

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate Riverpod providers (run after modifying providers)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Riverpod 2.x Features

- ✅ **Notifier pattern** - Modern replacement for StateNotifier
- ✅ **AsyncNotifier** - Built-in async state with loading/error handling
- ✅ **Code generation** - Type-safe providers with @riverpod annotation
- ✅ **GoRouter integration** - Declarative, type-safe routing
- ✅ **Compile-time safety** - No runtime provider lookup errors
- ✅ **riverpod_lint** - Specialized lint rules for best practices

## Project Structure

```
lib/
├── main.dart                          # App entry point with ProviderScope
├── app/
│   └── app.dart                       # MaterialApp.router with Riverpod
├── core/
│   ├── providers/                     # Global providers
│   │   └── app_providers.dart         # App-wide providers (@Riverpod)
│   ├── routing/
│   │   └── app_router.dart            # GoRouter with Riverpod
│   └── ...                            # Theme, API, Storage, Utils
└── features/
    └── home/
        └── presentation/
            ├── providers/
            │   └── home_provider.dart  # Feature providers (@riverpod)
            ├── pages/
            └── widgets/
```

## Provider Patterns

### Sync State (Notifier)
```dart
@riverpod
class Counter extends _\$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
}
```

### Async Data (AsyncNotifier)
```dart
@riverpod
class Items extends _\$Items {
  @override
  Future<List<Item>> build() async {
    return await api.fetchItems();
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => api.fetchItems());
  }
}
```

### Family Providers (Parameterized)
```dart
@riverpod
Future<User> userDetail(UserDetailRef ref, {required String id}) async {
  return ref.read(apiClientProvider).getUser(id);
}

// Usage: ref.watch(userDetailProvider(id: '123'))
```

## Configuration

- **State Management**: ${config.stateManagement.label}
- **Platform**: ${config.platforms.map((p) => p.label).join(", ")}
''';
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
    ..writeln('  runApp(')
    ..writeln('    const ProviderScope(')
    ..writeln('      child: App(),')
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

  buffer
    ..writeln('')
    ..writeln('/// Root application widget using GoRouter with Riverpod.')
    ..writeln('class App extends ConsumerWidget {')
    ..writeln('  const App({super.key});')
    ..writeln('')
    ..writeln('  @override')
    ..writeln('  Widget build(BuildContext context, WidgetRef ref) {')
    ..writeln('    // Watch the router provider for reactive updates')
    ..writeln('    final router = ref.watch(goRouterProvider);')
    ..writeln('')
    ..writeln('    return MaterialApp.router(')
    ..writeln("      title: '$title',")
    ..writeln('      debugShowCheckedModeBanner: false,');
  if (config.includeTheme) {
    buffer
      ..writeln('      theme: AppTheme.light(),')
      ..writeln('      darkTheme: AppTheme.dark(),')
      ..writeln('      themeMode: ThemeMode.system,');
  }
  buffer.writeln('      routerConfig: router,');
  if (config.includeLocalization) {
    buffer
      ..writeln('      localizationsDelegates: const [')
      ..writeln('        GlobalMaterialLocalizations.delegate,')
      ..writeln('        GlobalWidgetsLocalizations.delegate,')
      ..writeln('        GlobalCupertinoLocalizations.delegate,')
      ..writeln('      ],')
      ..writeln('      supportedLocales: const [')
      ..writeln("        Locale('en'),")
      ..writeln("        Locale('hi'),")
      ..writeln('      ],');
  }
  buffer
    ..writeln('    );')
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
      buffer.writeln("      apiBaseUrl: 'https://api.example.com',");
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
  return """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'route_names.dart';

part 'app_router.g.dart';

/// GoRouter provider with Riverpod for type-safe, declarative routing.
/// 
/// Includes authentication redirect logic for protected routes.
/// Use `ref.watch(goRouterProvider)` in your App widget.
@riverpod
GoRouter goRouter(GoRouterRef ref) {
  // Watch auth state for reactive redirects
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    
    // Redirect logic based on auth state
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.status == AuthStatus.initial || 
                        authState.status == AuthStatus.loading;

      // Don't redirect while checking auth
      if (isLoading) return null;

      final isOnLoginPage = state.matchedLocation == RouteNames.login;
      final isOnPublicPage = _publicRoutes.contains(state.matchedLocation);

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isOnPublicPage) {
        // Preserve the original location for post-login redirect
        final from = state.matchedLocation;
        return '\${RouteNames.login}?from=\$from';
      }

      // If authenticated and on login page, redirect to home
      if (isAuthenticated && isOnLoginPage) {
        // Check if there's a redirect location
        final from = state.uri.queryParameters['from'];
        return from ?? RouteNames.home;
      }

      return null;
    },

    routes: [
      // Public routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Protected routes
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Add more routes here:
      // GoRoute(
      //   path: RouteNames.profile,
      //   name: 'profile',
      //   builder: (context, state) => const ProfilePage(),
      // ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Path: \${state.uri.path}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// List of public routes that don't require authentication
const _publicRoutes = <String>[
  RouteNames.login,
  // Add more public routes here
];

/// Extension for easy navigation from BuildContext
extension GoRouterExtension on BuildContext {
  /// Navigate to a route
  void goTo(String path) => go(path);
  
  /// Push a new route
  void pushTo(String path) => push(path);
  
  /// Pop the current route
  void goBack() => pop();
}
""";
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
import 'api_response_parser.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/unified_response_interceptor.dart';

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
        UnifiedResponseInterceptor(const DefaultApiResponseParser()),
        RetryInterceptor(),
        LoggerInterceptor(),
      ]);
    });
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

String _loggerInterceptor(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln("import 'package:dio/dio.dart';")
    ..writeln("import 'package:flutter/foundation.dart';")
    ..writeln()
    ..writeln('class LoggerInterceptor extends Interceptor {')
    ..writeln('  @override')
    ..writeln(
        '  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {')
    ..writeln('    // Basic logging for demo purposes.')
    ..writeln('    // Replace with structured logging where appropriate.')
    ..writeln('    if (kDebugMode) {')
    ..writeln("      print('Request: \${options.method} \${options.path}');")
    ..writeln('    }')
    ..writeln('    super.onRequest(options, handler);')
    ..writeln('  }')
    ..writeln()
    ..writeln('  @override')
    ..writeln(
        '  void onResponse(Response response, ResponseInterceptorHandler handler) {')
    ..writeln('    if (kDebugMode) {')
    ..writeln(
        "      print('Response: \${response.statusCode} \${response.requestOptions.path}');")
    ..writeln('    }')
    ..writeln('    super.onResponse(response, handler);')
    ..writeln('  }')
    ..writeln()
    ..writeln('  @override')
    ..writeln(
        '  void onError(DioException err, ErrorInterceptorHandler handler) {')
    ..writeln('    if (kDebugMode) {')
    ..writeln("      print('Error: \${err.message}');")
    ..writeln('    }')
    ..writeln('    super.onError(err, handler);')
    ..writeln('  }')
    ..writeln('}');
  return buffer.toString();
}

// ignore: unused_element - Template utility kept for feature generators
String _homePage(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';

import '../widgets/home_content.dart';

/// Home page - state is managed by homeProvider
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
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
  return """import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:${config.appName}/app/app.dart';
import 'package:${config.appName}/features/home/presentation/providers/home_provider.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App renders without issues', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('HomeController Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has counter = 0', () {
      final state = container.read(homeControllerProvider);
      expect(state.counter, 0);
      expect(state.items, isEmpty);
    });

    test('incrementCounter increases counter by 1', () {
      container.read(homeControllerProvider.notifier).incrementCounter();
      expect(container.read(homeControllerProvider).counter, 1);

      container.read(homeControllerProvider.notifier).incrementCounter();
      expect(container.read(homeControllerProvider).counter, 2);
    });

    test('decrementCounter decreases counter by 1', () {
      // First increment to 2
      container.read(homeControllerProvider.notifier).incrementCounter();
      container.read(homeControllerProvider.notifier).incrementCounter();
      expect(container.read(homeControllerProvider).counter, 2);

      // Then decrement
      container.read(homeControllerProvider.notifier).decrementCounter();
      expect(container.read(homeControllerProvider).counter, 1);
    });

    test('decrementCounter does not go below 0', () {
      expect(container.read(homeControllerProvider).counter, 0);
      container.read(homeControllerProvider.notifier).decrementCounter();
      expect(container.read(homeControllerProvider).counter, 0);
    });

    test('resetCounter sets counter to 0', () {
      container.read(homeControllerProvider.notifier).incrementCounter();
      container.read(homeControllerProvider.notifier).incrementCounter();
      expect(container.read(homeControllerProvider).counter, 2);

      container.read(homeControllerProvider.notifier).resetCounter();
      expect(container.read(homeControllerProvider).counter, 0);
    });

    test('addItem adds item to list', () {
      const item = SampleItem(
        id: '1',
        title: 'Test',
        description: 'Test Description',
      );

      container.read(homeControllerProvider.notifier).addItem(item);
      final state = container.read(homeControllerProvider);

      expect(state.items.length, 1);
      expect(state.items.first.id, '1');
      expect(state.lastUpdated, isNotNull);
    });

    test('removeItem removes item from list', () {
      const item = SampleItem(
        id: '1',
        title: 'Test',
        description: 'Test Description',
      );

      container.read(homeControllerProvider.notifier).addItem(item);
      expect(container.read(homeControllerProvider).items.length, 1);

      container.read(homeControllerProvider.notifier).removeItem('1');
      expect(container.read(homeControllerProvider).items, isEmpty);
    });
  });

  group('SampleItems AsyncNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is AsyncLoading', () {
      final state = container.read(sampleItemsProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('loads sample items successfully', () async {
      // Wait for the async provider to complete
      await container.read(sampleItemsProvider.future);
      
      final state = container.read(sampleItemsProvider);
      expect(state, isA<AsyncData<List<SampleItem>>>());
      expect(state.valueOrNull?.length, 4);
    });
  });
}
""";
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
  return """import 'package:flutter/material.dart';

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

/// BuildContext extensions
extension ContextExtensions on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);
  
  /// Get text theme
  TextTheme get textTheme => theme.textTheme;
  
  /// Get color scheme
  ColorScheme get colors => theme.colorScheme;
  
  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get screen size
  Size get screenSize => mediaQuery.size;
  
  /// Get screen width
  double get width => screenSize.width;
  
  /// Get screen height
  double get height => screenSize.height;
  
  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : null,
      ),
    );
  }
}
""";
}

// ignore: unused_element - Template utility kept for feature generators
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 24),
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
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
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

String _apiResponseParser(BlueprintConfig config) {
  return generateApiConfig(config);
}

String _unifiedResponseInterceptor(BlueprintConfig config) {
  return generateUnifiedResponseInterceptor(config);
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
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:flutter_riverpod/flutter_riverpod.dart';")
    ..writeln("import 'package:riverpod_annotation/riverpod_annotation.dart';")
    ..writeln("import 'package:shared_preferences/shared_preferences.dart';")
    ..writeln("import '../config/app_config.dart';");

  if (config.includeApi) {
    buffer.writeln("import '../api/api_client.dart';");
  }

  buffer
    ..writeln('')
    ..writeln("part 'app_providers.g.dart';")
    ..writeln('')
    ..writeln(
        '// ============================================================================')
    ..writeln(
        '// Core Providers using @riverpod annotation for code generation')
    ..writeln(
        '// ============================================================================')
    ..writeln('')
    ..writeln('/// App configuration provider')
    ..writeln('/// ')
    ..writeln('/// Provides the app configuration singleton.')
    ..writeln('@Riverpod(keepAlive: true)')
    ..writeln('AppConfig appConfig(AppConfigRef ref) {')
    ..writeln('  return AppConfig.load();')
    ..writeln('}')
    ..writeln('')
    ..writeln('/// SharedPreferences provider for async initialization')
    ..writeln('/// ')
    ..writeln('/// Use `ref.watch(sharedPreferencesProvider)` to access.')
    ..writeln('/// This is kept alive so it only initializes once.')
    ..writeln('@Riverpod(keepAlive: true)')
    ..writeln(
        'Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {')
    ..writeln('  return SharedPreferences.getInstance();')
    ..writeln('}')
    ..writeln('')
    ..writeln('/// Theme mode provider with persistence')
    ..writeln('/// ')
    ..writeln(
        '/// Reads initial value from SharedPreferences and persists changes.')
    ..writeln('@riverpod')
    ..writeln('class AppThemeMode extends _\$AppThemeMode {')
    ..writeln('  static const _key = \'theme_mode\';')
    ..writeln('  ')
    ..writeln('  @override')
    ..writeln('  ThemeMode build() {')
    ..writeln('    // Read initial value from storage')
    ..writeln(
        '    final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;')
    ..writeln('    final stored = prefs?.getString(_key);')
    ..writeln('    ')
    ..writeln('    switch (stored) {')
    ..writeln("      case 'light': return ThemeMode.light;")
    ..writeln("      case 'dark': return ThemeMode.dark;")
    ..writeln('      default: return ThemeMode.system;')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln('  /// Toggle between light and dark mode')
    ..writeln('  Future<void> toggle() async {')
    ..writeln(
        '    final prefs = ref.read(sharedPreferencesProvider).valueOrNull;')
    ..writeln('    if (state == ThemeMode.light) {')
    ..writeln('      state = ThemeMode.dark;')
    ..writeln("      await prefs?.setString(_key, 'dark');")
    ..writeln('    } else {')
    ..writeln('      state = ThemeMode.light;')
    ..writeln("      await prefs?.setString(_key, 'light');")
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('  ')
    ..writeln('  /// Set a specific theme mode')
    ..writeln('  Future<void> setTheme(ThemeMode mode) async {')
    ..writeln(
        '    final prefs = ref.read(sharedPreferencesProvider).valueOrNull;')
    ..writeln('    state = mode;')
    ..writeln('    await prefs?.setString(_key, mode.name);')
    ..writeln('  }')
    ..writeln('}');

  if (config.includeApi) {
    buffer
      ..writeln('')
      ..writeln('/// API client provider')
      ..writeln('/// ')
      ..writeln('/// Provides a configured API client instance.')
      ..writeln('/// Kept alive to maintain interceptor state.')
      ..writeln('@Riverpod(keepAlive: true)')
      ..writeln('ApiClient apiClient(ApiClientRef ref) {')
      ..writeln('  final config = ref.watch(appConfigProvider);')
      ..writeln('  return ApiClient(config);')
      ..writeln('}');
  }

  return buffer.toString();
}

String _homeProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_provider.g.dart';

/// Sample item model for demonstration
class SampleItem {
  const SampleItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

/// Home screen state using immutable pattern
class HomeState {
  const HomeState({
    this.counter = 0,
    this.items = const [],
    this.lastUpdated,
  });

  final int counter;
  final List<SampleItem> items;
  final DateTime? lastUpdated;

  HomeState copyWith({
    int? counter,
    List<SampleItem>? items,
    DateTime? lastUpdated,
  }) {
    return HomeState(
      counter: counter ?? this.counter,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Home controller using modern Riverpod 2.x Notifier pattern.
/// 
/// Use `ref.watch(homeControllerProvider)` to access state.
/// Use `ref.read(homeControllerProvider.notifier)` to access methods.
@riverpod
class HomeController extends _\$HomeController {
  @override
  HomeState build() {
    // Initial state - can also do async initialization here
    return const HomeState();
  }

  /// Increment the counter
  void incrementCounter() {
    state = state.copyWith(counter: state.counter + 1);
  }

  /// Decrement the counter
  void decrementCounter() {
    if (state.counter > 0) {
      state = state.copyWith(counter: state.counter - 1);
    }
  }

  /// Reset counter to zero
  void resetCounter() {
    state = state.copyWith(counter: 0);
  }

  /// Add a sample item
  void addItem(SampleItem item) {
    state = state.copyWith(
      items: [...state.items, item],
      lastUpdated: DateTime.now(),
    );
  }

  /// Remove an item by id
  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Clear all items
  void clearItems() {
    state = state.copyWith(items: [], lastUpdated: DateTime.now());
  }
}

/// Provider for async data fetching demonstration.
/// 
/// This shows the AsyncNotifier pattern for automatic loading/error states.
@riverpod
class SampleItems extends _\$SampleItems {
  @override
  Future<List<SampleItem>> build() async {
    // Auto-fetches on first access and caches the result
    return _fetchItems();
  }

  Future<List<SampleItem>> _fetchItems() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Return sample data
    return [
      const SampleItem(
        id: '1',
        title: 'Clean Architecture',
        description: 'Separation of concerns for maintainable code',
      ),
      const SampleItem(
        id: '2',
        title: 'Riverpod State Management',
        description: 'Type-safe, compile-time verified state',
      ),
      const SampleItem(
        id: '3',
        title: 'GoRouter Navigation',
        description: 'Declarative routing with deep linking',
      ),
      const SampleItem(
        id: '4',
        title: 'Code Generation',
        description: 'Auto-generated providers with @riverpod',
      ),
    ];
  }

  /// Refresh the data (pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchItems());
  }

  /// Add a new item and refresh
  Future<void> addItem(SampleItem item) async {
    // Optimistic update
    state = AsyncData([...state.valueOrNull ?? [], item]);
  }
}
""";
}

String _homeContent(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_provider.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';

/// Home screen content demonstrating Riverpod 2.x patterns.
/// 
/// Shows:
/// - ConsumerWidget usage
/// - Notifier for sync state (counter)
/// - AsyncNotifier with AsyncValue.when for async data
/// - Pull-to-refresh
class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the home controller state
    final homeState = ref.watch(homeControllerProvider);
    
    // Watch the async items provider
    final itemsAsync = ref.watch(sampleItemsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(sampleItemsProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // Counter Section
          SliverToBoxAdapter(
            child: _CounterSection(
              counter: homeState.counter,
              onIncrement: () => ref.read(homeControllerProvider.notifier).incrementCounter(),
              onDecrement: () => ref.read(homeControllerProvider.notifier).decrementCounter(),
              onReset: () => ref.read(homeControllerProvider.notifier).resetCounter(),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: Divider(height: 32),
          ),
          
          // Async Items Section Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Sample Items (AsyncNotifier)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Items List with AsyncValue.when pattern
          itemsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: LoadingIndicator(message: 'Loading items...'),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.read(sampleItemsProvider.notifier).refresh(),
                ),
              ),
            ),
            data: (items) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ItemCard(item: items[index]),
                childCount: items.length,
              ),
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}

/// Counter section widget
class _CounterSection extends StatelessWidget {
  const _CounterSection({
    required this.counter,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  final int counter;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Notifier Counter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(
            '\$counter',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: onIncrement,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Item card widget
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final SampleItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            item.title[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(item.title),
        subtitle: Text(item.description),
        trailing: const Icon(Icons.chevron_right),
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
    return showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 32)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)))]), content: Text(message), actions: [TextButton(onPressed: () { Navigator.of(context).pop(); onPressed?.call(); }, child: Text(buttonText))]));
  }

  static Future<void> showError(BuildContext context, {required String title, required String message, String buttonText = 'OK', VoidCallback? onPressed}) {
    return showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.error_outline, color: AppColors.error, size: 32)), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)))]), content: Text(message), actions: [TextButton(onPressed: () { Navigator.of(context).pop(); onPressed?.call(); }, child: Text(buttonText))]));
  }

  static Future<bool?> showConfirmation(BuildContext context, {required String title, required String message, String confirmText = 'Confirm', String cancelText = 'Cancel'}) {
    return showDialog<bool>(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text(title), content: Text(message), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelText)), ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(confirmText))]));
  }

  static void showLoading(BuildContext context, {String message = 'Loading...'}) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => WillPopScope(onWillPop: () async => false, child: AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), content: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(message)]))));
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
      AppLogger.error('Error checking connectivity', 'NetworkSettings', e);
      return false;
    }
  }

  static Future<ConnectivityResult> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.first;
    } catch (e) {
      AppLogger.error('Error getting connection type', 'NetworkSettings', e);
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
      if (showError) showNetworkError(context);
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

// ============================================================================
// CONNECTIVITY PROVIDER
// ============================================================================

String _connectivityProvider(BlueprintConfig config) {
  return """import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Connectivity status enum
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// Stream provider for real-time connectivity monitoring.
/// 
/// Usage:
/// ```dart
/// final status = ref.watch(connectivityStatusProvider);
/// status.when(
///   data: (status) => status == ConnectivityStatus.connected,
///   loading: () => true,
///   error: (_, __) => false,
/// );
/// ```
@riverpod
Stream<ConnectivityStatus> connectivityStatus(ConnectivityStatusRef ref) async* {
  final connectivity = Connectivity();
  
  // Emit initial status
  final initial = await connectivity.checkConnectivity();
  yield _mapResultToStatus(initial);
  
  // Listen for changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield _mapResultToStatus(results);
  }
}

ConnectivityStatus _mapResultToStatus(List<ConnectivityResult> results) {
  if (results.contains(ConnectivityResult.none)) {
    return ConnectivityStatus.disconnected;
  }
  if (results.isEmpty) {
    return ConnectivityStatus.unknown;
  }
  return ConnectivityStatus.connected;
}

/// Simple boolean provider for convenience
@riverpod
bool isConnected(IsConnectedRef ref) {
  final status = ref.watch(connectivityStatusProvider);
  return status.maybeWhen(
    data: (s) => s == ConnectivityStatus.connected,
    orElse: () => true, // Assume connected by default
  );
}

/// Helper class for connectivity utilities
class ConnectivityHelper {
  static Future<bool> checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
  
  static String getConnectionTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }
}
""";
}

// ============================================================================
// ERROR HANDLER PROVIDER
// ============================================================================

String _errorHandlerProvider(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/logger.dart';
import '../utils/snackbar_utils.dart';

part 'error_handler_provider.g.dart';

/// Global error state for the application
class AppError {
  const AppError({
    required this.message,
    this.error,
    this.stackTrace,
    this.timestamp,
  });

  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime? timestamp;
}

/// Global error handler provider using Notifier pattern.
/// 
/// Use ref.listen to react to errors globally:
/// ```dart
/// ref.listen(errorHandlerProvider, (previous, next) {
///   if (next != null) {
///     // Show error dialog or snackbar
///   }
/// });
/// ```
@riverpod
class ErrorHandler extends _\$ErrorHandler {
  @override
  AppError? build() => null;

  /// Report an error globally
  void reportError(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.error(message, error, stackTrace, 'ErrorHandler');
    
    state = AppError(
      message: message,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
  }

  /// Clear the current error
  void clearError() {
    state = null;
  }

  /// Handle an async operation with automatic error reporting
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      reportError(errorMessage ?? e.toString(), e, stack);
      return null;
    }
  }
}

/// Widget that listens to global errors and shows snackbars
class ErrorListener extends ConsumerWidget {
  const ErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AppError?>(errorHandlerProvider, (previous, next) {
      if (next != null && context.mounted) {
        SnackbarUtils.showError(context, next.message);
      }
    });

    return child;
  }
}

/// Mixin for widgets that need error handling
mixin ErrorHandlerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  
  /// Setup error listening in initState
  void setupErrorListener() {
    ref.listenManual<AppError?>(
      errorHandlerProvider,
      (previous, next) {
        if (next != null && mounted) {
          _showErrorSnackbar(next.message);
        }
      },
      fireImmediately: false,
    );
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ref.read(errorHandlerProvider.notifier).clearError();
            },
          ),
        ),
      );
    }
  }
}
""";
}

// ============================================================================
// BASE REPOSITORY
// ============================================================================

String _baseRepository(BlueprintConfig config) {
  return """import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Result type for repository operations
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

/// Extension methods for Result type
extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Error() => null,
  };
  
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Error(:final failure) => failure,
  };
  
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Error(:final failure) => onError(failure),
    };
  }
}

/// Base repository class with common error handling
abstract class BaseRepository {
  BaseRepository(this.apiClient);
  
  final ApiClient apiClient;
  
  /// Execute an API call with automatic error handling
  Future<Result<T>> execute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Success(result);
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } on AppException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
  
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      default:
        return ServerFailure(error.message ?? 'Unknown error');
    }
  }
  
  Failure _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final message = response?.data?['message'] ?? 'Server error';
    
    if (statusCode == 401) {
      return const UnauthorizedFailure();
    } else if (statusCode == 404) {
      return ServerFailure('Resource not found: \$message');
    } else if (statusCode >= 500) {
      return ServerFailure('Server error: \$message');
    } else {
      return ServerFailure(message);
    }
  }
}
""";
}

// ============================================================================
// AUTH REPOSITORY
// ============================================================================

String _authRepository(BlueprintConfig config) {
  return """import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

part 'auth_repository.g.dart';

/// User model for authentication
class User {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatar_url': avatarUrl,
  };
}

/// Authentication repository for managing user authentication
abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<void> refreshToken();
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  Future<User?> getCurrentUser() async {
    final userId = await _secureStorage.read(AppConstants.keyUserId);
    if (userId == null) return null;

    // In a real app, you would fetch user data from API
    final email = await _secureStorage.read('user_email');
    return User(
      id: userId,
      email: email ?? 'user@example.com',
    );
  }

  @override
  Future<User> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would call the API here
    // For demo, we'll simulate a successful login
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    // Simulate storing tokens
    await _secureStorage.write(AppConstants.keyAccessToken, 'demo_access_token');
    await _secureStorage.write(AppConstants.keyRefreshToken, 'demo_refresh_token');
    await _secureStorage.write(AppConstants.keyUserId, 'user_123');
    await _secureStorage.write('user_email', email);

    return User(id: 'user_123', email: email);
  }

  @override
  Future<User> register(String email, String password, String name) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    await _secureStorage.write(AppConstants.keyAccessToken, 'demo_access_token');
    await _secureStorage.write(AppConstants.keyRefreshToken, 'demo_refresh_token');
    await _secureStorage.write(AppConstants.keyUserId, 'user_new');
    await _secureStorage.write('user_email', email);

    return User(id: 'user_new', email: email, name: name);
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(AppConstants.keyAccessToken);
    await _secureStorage.delete(AppConstants.keyRefreshToken);
    await _secureStorage.delete(AppConstants.keyUserId);
    await _secureStorage.delete('user_email');
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(AppConstants.keyAccessToken);
    return token != null;
  }

  @override
  Future<void> refreshToken() async {
    // Implement token refresh logic
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Provider for AuthRepository
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(SecureStorage.instance);
}
""";
}

// ============================================================================
// AUTH PROVIDER
// ============================================================================

String _authProvider(BlueprintConfig config) {
  return """import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

/// Authentication state
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Authentication state class
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final User? user;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth controller using Riverpod Notifier pattern.
/// 
/// This provider manages authentication state and is used by GoRouter
/// for redirect logic.
@Riverpod(keepAlive: true)
class AuthController extends _\$AuthController {
  @override
  AuthState build() {
    // Check initial auth state
    _checkAuthStatus();
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final repo = ref.read(authRepositoryProvider);
      final isAuthenticated = await repo.isAuthenticated();
      
      if (isAuthenticated) {
        final user = await repo.getCurrentUser();
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Register a new user
  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(email, password, name);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (e) {
      debugPrint('Logout error: \$e');
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Simple provider to check if user is authenticated
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
}
""";
}

// ============================================================================
// LOGIN PAGE
// ============================================================================

String _loginPage(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';

/// Login page with form validation
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Error message
                  if (authState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) => Validators.required(value, 'Password'),
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  CustomButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    text: 'Sign In',
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Demo note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Demo: Enter any valid email and password',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
""";
}

// ============================================================================
// ROUTE NAMES
// ============================================================================

String _routeNamesUpdated(BlueprintConfig config) {
  return """class RouteNames {
  static const home = '/';
  static const login = '/login';
}
""";
}

// ============================================================================
// HOME PAGE UPDATED
// ============================================================================

String _homePageUpdated(BlueprintConfig config) {
  return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/error_handler_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../widgets/home_content.dart';

/// Home page with error boundary and logout
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Blueprint'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: const ErrorListener(
        child: HomeContent(),
      ),
    );
  }
}
""";
}
