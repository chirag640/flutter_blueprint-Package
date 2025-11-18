import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import 'analytics_templates.dart';
import 'hive_templates.dart';
import 'pagination_templates.dart';
import 'template_bundle.dart';

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
  buffer.writeln('  flutter_riverpod: ^2.5.1');
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
    ..writeln('class App extends ConsumerWidget {')
    ..writeln('  const App({super.key});')
    ..writeln('')
    ..writeln('  @override')
    ..writeln('  Widget build(BuildContext context, WidgetRef ref) {')
    ..writeln('    final router = AppRouter();')
    ..writeln('    return MaterialApp(')
    ..writeln("        title: '$title',");
  if (config.includeTheme) {
    buffer
      ..writeln('        theme: AppTheme.light(),')
      ..writeln('        darkTheme: AppTheme.dark(),')
      ..writeln('        themeMode: ThemeMode.system,');
  }
  buffer
    ..writeln('        initialRoute: AppRouter.home,')
    ..writeln('        onGenerateRoute: router.onGenerateRoute,');
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
  final buffer = StringBuffer()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln("import '../../features/home/presentation/pages/home_page.dart';")
    ..writeln("import 'route_guard.dart';")
    ..writeln()
    ..writeln('class AppRouter {')
    ..writeln("  static const home = '/';")
    ..writeln()
    ..writeln('  Route<dynamic>? onGenerateRoute(RouteSettings settings) {')
    ..writeln('    switch (settings.name) {')
    ..writeln('      case home:')
    ..writeln(
        '        return MaterialPageRoute(builder: (_) => const HomePage());')
    ..writeln('      default:')
    ..writeln(
        '        return MaterialPageRoute(builder: (_) => const HomePage());')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln()
    ..writeln('  Route<dynamic> guarded({')
    ..writeln('    required RouteSettings settings,')
    ..writeln('    required RouteGuard guard,')
    ..writeln('    required WidgetBuilder builder,')
    ..writeln('  }) {')
    ..writeln('    return MaterialPageRoute(')
    ..writeln('      settings: settings,')
    ..writeln('      builder: (context) {')
    ..writeln('        if (!guard.canActivate(settings)) {')
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
  return """import 'package:dio/dio.dart';

import '../../storage/local_storage.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';

/// Adds authentication token to requests
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  
  final LocalStorage _storage;
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _storage.getString(AppConstants.keyAccessToken);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer \$token';
      AppLogger.debug('Added auth token to request', 'AuthInterceptor');
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Unauthorized - token might be expired', 'AuthInterceptor');
      // TODO: Implement token refresh logic here
    }
    
    handler.next(err);
  }
}
""";
}

String _retryInterceptor(BlueprintConfig config) {
  return """import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';
import '../../utils/logger.dart';

/// Automatically retries failed requests
class RetryInterceptor extends Interceptor {
  int _retryCount = 0;
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err) && _retryCount < AppConstants.maxRetries) {
      _retryCount++;
      AppLogger.warning(
        'Retrying request (attempt \$_retryCount/\${AppConstants.maxRetries})',
        'RetryInterceptor',
      );
      
      try {
        // Wait before retrying with exponential backoff
        await Future.delayed(Duration(seconds: _retryCount));
        
        final response = await Dio().fetch(err.requestOptions);
        _retryCount = 0; // Reset on success
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    
    _retryCount = 0; // Reset counter
    return handler.next(err);
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.unknown;
  }
}
""";
}

String _localStorage(BlueprintConfig config) {
  return """import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around SharedPreferences for type-safe storage
class LocalStorage {
  LocalStorage._();
  
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;
  
  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs!.getString(key);
  }
  
  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs!.getInt(key);
  }
  
  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }
  
  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }
  
  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }
  
  // List operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }
  
  List<String>? getStringList(String key) {
    return _prefs!.getStringList(key);
  }
  
  // Remove operation
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }
  
  // Clear all
  Future<bool> clear() async {
    return await _prefs!.clear();
  }
  
  // Check if key exists
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }
}
""";
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

  return buffer.toString();
}

String _homeProvider(BlueprintConfig config) {
  return """import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home screen state
class HomeState {
  const HomeState({
    this.isLoading = false,
    this.error,
    this.counter = 0,
  });

  final bool isLoading;
  final String? error;
  final int counter;

  HomeState copyWith({
    bool? isLoading,
    String? error,
    int? counter,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      counter: counter ?? this.counter,
    );
  }
}

/// Home screen state notifier using Riverpod's StateNotifier
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void incrementCounter() {
    state = state.copyWith(counter: state.counter + 1);
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // Process data here

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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

/// Home screen content widget using ConsumerWidget for Riverpod
class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    if (homeState.isLoading) {
      return const LoadingIndicator(message: 'Loading...');
    }

    if (homeState.error != null) {
      return ErrorView(
        message: homeState.error!,
        onRetry: () => ref.read(homeProvider.notifier).loadData(),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Counter: \${homeState.counter}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(homeProvider.notifier).incrementCounter(),
            child: const Text('Increment'),
          ),
        ],
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
