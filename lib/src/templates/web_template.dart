import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import 'template_bundle.dart';

/// Builds a web-optimized Flutter template with BLoC architecture
TemplateBundle buildWebTemplate(StateManagement stateManagement) {
  switch (stateManagement) {
    case StateManagement.bloc:
      return _buildBlocWebBundle();
    case StateManagement.provider:
      return _buildProviderWebBundle();
    case StateManagement.riverpod:
      return _buildRiverpodWebBundle();
  }
}

TemplateBundle _buildBlocWebBundle() {
  return TemplateBundle(
    files: [
      // Base config files
      TemplateFile(path: 'analysis_options.yaml', build: _analysisOptions),
      TemplateFile(path: 'pubspec.yaml', build: _pubspecBloc),
      TemplateFile(path: '.gitignore', build: _gitignore),
      TemplateFile(path: 'README.md', build: _readme),

      // Web-specific files
      TemplateFile(path: 'web/index.html', build: _indexHtml),
      TemplateFile(path: 'web/manifest.json', build: _manifestJson),
      TemplateFile(path: 'web/favicon.png', build: _faviconPlaceholder),
      TemplateFile(path: 'web/icons/Icon-192.png', build: _iconPlaceholder),
      TemplateFile(path: 'web/icons/Icon-512.png', build: _iconPlaceholder),

      // Main app with URL strategy
      TemplateFile(path: 'lib/main.dart', build: _mainDartBloc),
      TemplateFile(path: p.join('lib', 'app', 'app.dart'), build: _appDartBloc),

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
          path: p.join('lib', 'core', 'utils', 'responsive_helper.dart'),
          build: _responsiveHelper),

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

      // Core: Widgets
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'loading_indicator.dart'),
          build: _loadingIndicator),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'error_view.dart'),
          build: _errorView),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'responsive_layout.dart'),
          build: _responsiveLayout),

      // Core: API
      TemplateFile(
          path: p.join('lib', 'core', 'api', 'api_client.dart'),
          build: _apiClient,
          shouldGenerate: (config) => config.includeApi),

      // Core: Storage
      TemplateFile(
          path: p.join('lib', 'core', 'storage', 'local_storage.dart'),
          build: _localStorage),

      // Features: Home
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'pages',
              'home_page.dart'),
          build: _homePage),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'bloc',
              'home_event.dart'),
          build: _homeEvent),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'bloc',
              'home_state.dart'),
          build: _homeState),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'bloc',
              'home_bloc.dart'),
          build: _homeBloc),
      TemplateFile(
          path: p.join('lib', 'features', 'home', 'presentation', 'widgets',
              'home_content.dart'),
          build: _homeContent),

      // Localization
      TemplateFile(
          path: p.join('assets', 'l10n', 'en.arb'),
          build: _enLocalization,
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
    ],
  );
}

TemplateBundle _buildProviderWebBundle() {
  // Similar to BLoC but with Provider state management
  return _buildBlocWebBundle(); // Placeholder - implement full provider version
}

TemplateBundle _buildRiverpodWebBundle() {
  // Similar to BLoC but with Riverpod state management
  return _buildBlocWebBundle(); // Placeholder - implement full riverpod version
}

// ============================================================================
// TEMPLATE BUILDERS
// ============================================================================

String _analysisOptions(BlueprintConfig config) {
  return 'include: package:flutter_lints/flutter.yaml';
}

String _pubspecBloc(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln('name: ${config.appName}')
    ..writeln(
        'description: "A Flutter web app scaffolded by flutter_blueprint with BLoC."')
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

  buffer
    ..writeln('  flutter_bloc: ^8.1.5')
    ..writeln('  bloc: ^8.1.4');
  buffer.writeln('  shared_preferences: ^2.2.3');
  buffer.writeln('  equatable: ^2.0.5');
  buffer.writeln('  url_strategy: ^0.3.0'); // For web URL strategies

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
      ..writeln('  connectivity_plus: ^6.0.5');
  }

  buffer
    ..writeln('')
    ..writeln('dev_dependencies:')
    ..writeln('  flutter_test:')
    ..writeln('    sdk: flutter')
    ..writeln('  flutter_lints: ^5.0.0');
  if (config.includeTests) {
    buffer
      ..writeln('  mocktail: ^1.0.3')
      ..writeln('  bloc_test: ^9.1.7');
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
  return '''
# Flutter generated files
.dart_tool/
.packages
build/
.env

# Web specific
web/*.g.dart
web/*.min.js
''';
}

String _readme(BlueprintConfig config) {
  return '''
# ${_titleCase(config.appName)}

Generated with flutter_blueprint for **Web** using **BLoC** pattern.

## Getting Started

```bash
flutter pub get
flutter run -d chrome
```

## Build for Production

```bash
flutter build web --release
```

The output will be in `build/web/` directory.

## Features

- ✅ Web-optimized responsive design
- ✅ URL-based routing with clean URLs
- ✅ BLoC state management
- ✅ Progressive Web App (PWA) ready
- ✅ Platform: ${config.platform.label}
- ✅ State management: ${config.stateManagement.label}
''';
}

String _indexHtml(BlueprintConfig config) {
  return '''
<!DOCTYPE html>
<html>
<head>
  <base href="\$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="${_titleCase(config.appName)} - A Flutter web application">
  
  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="${config.appName}">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>
  
  <title>${_titleCase(config.appName)}</title>
  <link rel="manifest" href="manifest.json">
  
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  
  <style>
    body {
      margin: 0;
      background-color: #fafafa;
    }
    .loading {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
    }
    .spinner {
      border: 4px solid #f3f3f3;
      border-top: 4px solid #3498db;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div class="loading">
    <div class="spinner"></div>
  </div>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
''';
}

String _manifestJson(BlueprintConfig config) {
  return '''
{
  "name": "${_titleCase(config.appName)}",
  "short_name": "${config.appName}",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#0066FF",
  "description": "${_titleCase(config.appName)} - A Flutter web application",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
''';
}

String _faviconPlaceholder(BlueprintConfig config) {
  return ''; // Placeholder - should be binary but we'll note in README
}

String _iconPlaceholder(BlueprintConfig config) {
  return ''; // Placeholder - should be binary but we'll note in README
}

String _mainDartBloc(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:url_strategy/url_strategy.dart';")
    ..writeln("import 'app/app.dart';");
  if (config.includeEnv) {
    buffer.writeln("import 'core/config/env_loader.dart';");
  }
  buffer
    ..writeln('')
    ..writeln('Future<void> main() async {')
    ..writeln('  WidgetsFlutterBinding.ensureInitialized();')
    ..writeln('  ')
    ..writeln('  // Use clean URLs without # in web')
    ..writeln('  setPathUrlStrategy();')
    ..writeln('  ');
  if (config.includeEnv) {
    buffer.writeln("  await EnvLoader.load();");
  }
  buffer
    ..writeln('  runApp(const App());')
    ..writeln('}');
  return buffer.toString();
}

String _appDartBloc(BlueprintConfig config) {
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/routing/app_router.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
${config.includeTheme ? "import '../core/theme/app_theme.dart';" : ''}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeBloc()),
      ],
      child: MaterialApp(
        title: '${_titleCase(config.appName)}',
        ${config.includeTheme ? '''theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,''' : ''}
        initialRoute: AppRouter.home,
        onGenerateRoute: router.onGenerateRoute,
      ),
    );
  }
}
''';
}

String _responsiveHelper(BlueprintConfig config) {
  return '''
import 'package:flutter/material.dart';

/// Responsive breakpoints and helper utilities for web
class ResponsiveHelper {
  ResponsiveHelper._();
  
  // Breakpoints
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static const double desktopMin = 1025;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMax;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width < desktopMin;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMin;
  }
  
  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}
''';
}

String _responsiveLayout(BlueprintConfig config) {
  return '''
import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Responsive layout builder for web
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isDesktop(context) && desktop != null) {
          return desktop!;
        }
        if (ResponsiveHelper.isTablet(context) && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
''';
}

// Reuse most templates from mobile (they work on web too)
String _appConfig(BlueprintConfig config) => '''
class AppConfig {
  const AppConfig({
    required this.appTitle,
    required this.environment,
    required this.apiBaseUrl,
  });

  final String appTitle;
  final String environment;
  final String apiBaseUrl;

  static AppConfig load() {
    return AppConfig(
      appTitle: '${_titleCase(config.appName)}',
      environment: 'production',
      apiBaseUrl: ${config.includeApi ? "'https://api.example.com'" : "''"},
    );
  }
}
''';

String _envLoader(BlueprintConfig config) => '''
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { dev, stage, prod }

class EnvLoader {
  static AppEnvironment currentEnvironment = AppEnvironment.dev;

  static Future<void> load({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? 'https://api.example.com';
}
''';

String _appConstants(BlueprintConfig config) => '''
class AppConstants {
  AppConstants._();
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  static const String keyAccessToken = 'access_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
}
''';

String _apiEndpoints(BlueprintConfig config) => '''
class ApiEndpoints {
  ApiEndpoints._();
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';
}
''';

String _exceptions(BlueprintConfig config) => '''
class AppException implements Exception {
  AppException(this.message, [this.prefix = 'Error']);
  
  final String message;
  final String prefix;

  @override
  String toString() => '\$prefix: \$message';
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 'No Internet Connection');
}

class ServerException extends AppException {
  ServerException(String message) : super(message, 'Server Error');
}
''';

String _failures(BlueprintConfig config) => '''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = 'An error occurred']);
  
  final String message;
  
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet']);
}
''';

String _networkInfo(BlueprintConfig config) => '''
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  NetworkInfo(this._connectivity);
  
  final Connectivity _connectivity;
  
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
''';

String _logger(BlueprintConfig config) => '''
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();
  
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('🐛 \${tag ?? ''} \$message');
    }
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ \$message');
      if (error != null) debugPrint('Error: \$error');
    }
  }
}
''';

String _validators(BlueprintConfig config) => '''
class Validators {
  Validators._();
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$');
    if (!emailRegex.hasMatch(value)) return 'Invalid email';
    return null;
  }
  
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '\$fieldName is required';
    return null;
  }
}
''';

String _extensions(BlueprintConfig config) => '''
import 'package:flutter/material.dart';

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get width => screenSize.width;
  double get height => screenSize.height;
}
''';

String _appRouter(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'route_guard.dart';

class AppRouter {
  static const home = '/';

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
''';

String _routeGuard(BlueprintConfig config) => '''
import 'package:flutter/material.dart';

abstract class RouteGuard {
  const RouteGuard();
  bool canActivate(RouteSettings settings);
  Widget fallback({required BuildContext context});
}
''';

String _routeNames(BlueprintConfig config) => '''
class RouteNames {
  RouteNames._();
  
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
}
''';

String _appTheme(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import 'typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066FF)),
      brightness: Brightness.light,
      textTheme: buildTextTheme(),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF66AAFF),
        brightness: Brightness.dark,
      ),
      textTheme: buildTextTheme(),
    );
  }
}
''';

String _typography(BlueprintConfig config) => '''
import 'package:flutter/material.dart';

TextTheme buildTextTheme() {
  return const TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
  );
}
''';

String _loadingIndicator(BlueprintConfig config) => '''
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});
  
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
''';

String _errorView(BlueprintConfig config) => '''
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}
''';

String _apiClient(BlueprintConfig config) => '''
import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient(this.config) {
    dio = Dio(BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  final AppConfig config;
  late final Dio dio;
  
  Future<Response> get(String path) => dio.get(path);
  Future<Response> post(String path, {dynamic data}) => dio.post(path, data: data);
}
''';

String _localStorage(BlueprintConfig config) => '''
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();
  
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;
  
  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  Future<bool> setString(String key, String value) => _prefs!.setString(key, value);
  String? getString(String key) => _prefs!.getString(key);
  Future<bool> remove(String key) => _prefs!.remove(key);
}
''';

String _homePage(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../widgets/home_content.dart';
import '../../../../core/widgets/responsive_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: ResponsiveLayout(
        mobile: const HomeContent(),
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: const HomeContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<HomeBloc>().add(const IncrementCounterEvent());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';

String _homeEvent(BlueprintConfig config) => '''
import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class IncrementCounterEvent extends HomeEvent {
  const IncrementCounterEvent();
}
''';

String _homeState(BlueprintConfig config) => '''
import 'package:equatable/equatable.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadedState extends HomeState {
  const HomeLoadedState({this.counter = 0});
  final int counter;
  
  @override
  List<Object?> get props => [counter];
  
  HomeLoadedState copyWith({int? counter}) {
    return HomeLoadedState(counter: counter ?? this.counter);
  }
}
''';

String _homeBloc(BlueprintConfig config) => '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitialState()) {
    on<IncrementCounterEvent>(_onIncrementCounter);
  }

  Future<void> _onIncrementCounter(
    IncrementCounterEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      emit(currentState.copyWith(counter: currentState.counter + 1));
    } else {
      emit(const HomeLoadedState(counter: 1));
    }
  }
}
''';

String _homeContent(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoadedState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Counter: \${state.counter}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const Text('Web Platform - BLoC Pattern'),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
''';

String _enLocalization(BlueprintConfig config) => '''
{
  "@@locale": "en",
  "appTitle": "${_titleCase(config.appName)}"
}
''';

String _envExample(BlueprintConfig config) => '''
APP_ENV=dev
API_BASE_URL=https://api.example.com
''';

String _widgetTest(BlueprintConfig config) => '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:${config.appName}/app/app.dart';

void main() {
  testWidgets('App renders without issues', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
''';

String _titleCase(String input) {
  if (input.isEmpty) return input;
  final segments = input.split(RegExp(r'[_\- ]+')).where((e) => e.isNotEmpty);
  return segments.map((segment) {
    final lower = segment.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }).join(' ');
}
