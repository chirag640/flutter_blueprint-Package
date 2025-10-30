import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import 'template_bundle.dart';

/// Builds a desktop-optimized Flutter template (macOS/Windows/Linux) with BLoC architecture
TemplateBundle buildDesktopTemplate(StateManagement stateManagement) {
  switch (stateManagement) {
    case StateManagement.bloc:
      return _buildBlocDesktopBundle();
    case StateManagement.provider:
      return _buildProviderDesktopBundle();
    case StateManagement.riverpod:
      return _buildRiverpodDesktopBundle();
  }
}

TemplateBundle _buildBlocDesktopBundle() {
  return TemplateBundle(
    files: [
      // Base config files
      TemplateFile(path: 'analysis_options.yaml', build: _analysisOptions),
      TemplateFile(path: 'pubspec.yaml', build: _pubspecBloc),
      TemplateFile(path: '.gitignore', build: _gitignore),
      TemplateFile(path: 'README.md', build: _readme),

      // Main app with desktop window configuration
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
      TemplateFile(
          path: p.join('lib', 'core', 'config', 'window_config.dart'),
          build: _windowConfig),

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
          path: p.join('lib', 'core', 'utils', 'desktop_helper.dart'),
          build: _desktopHelper),

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
          path: p.join('lib', 'core', 'widgets', 'desktop_layout.dart'),
          build: _desktopLayout),
      TemplateFile(
          path: p.join('lib', 'core', 'widgets', 'title_bar.dart'),
          build: _titleBar),

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

TemplateBundle _buildProviderDesktopBundle() {
  return _buildBlocDesktopBundle(); // Placeholder
}

TemplateBundle _buildRiverpodDesktopBundle() {
  return _buildBlocDesktopBundle(); // Placeholder
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
        'description: "A Flutter desktop app scaffolded by flutter_blueprint with BLoC."')
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
  buffer.writeln('  window_manager: ^0.4.3'); // Desktop window management
  buffer.writeln('  path_provider: ^2.1.5'); // Desktop file paths

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

# Desktop specific
*.swp
*.swo
*~
.DS_Store

# Windows
windows/flutter/ephemeral/

# macOS
macos/Flutter/ephemeral/
.fvm/

# Linux
linux/flutter/ephemeral/
''';
}

String _readme(BlueprintConfig config) {
  return '''
# ${_titleCase(config.appName)}

Generated with flutter_blueprint for **Desktop** (macOS/Windows/Linux) using **BLoC** pattern.

## Getting Started

### Development

```bash
flutter pub get

# Run on specific desktop platform
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

### Build for Production

```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## Features

- ✅ Desktop-optimized UI with native window controls
- ✅ Window management (resize, minimize, maximize)
- ✅ BLoC state management
- ✅ File system integration
- ✅ Platform: ${config.platforms.map((p) => p.label).join(", ")}
- ✅ State management: ${config.stateManagement.label}

## Desktop Requirements

### macOS
- Xcode 14.0 or later
- macOS 10.15 (Catalina) or later

### Windows
- Visual Studio 2022 with C++ development tools
- Windows 10 version 1809 or later

### Linux
- GTK 3.0 development libraries
- CMake 3.10 or later
''';
}

String _mainDartBloc(BlueprintConfig config) {
  final buffer = StringBuffer()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:window_manager/window_manager.dart';")
    ..writeln("import 'app/app.dart';")
    ..writeln("import 'core/config/window_config.dart';");
  if (config.includeEnv) {
    buffer.writeln("import 'core/config/env_loader.dart';");
  }
  buffer
    ..writeln('')
    ..writeln('Future<void> main() async {')
    ..writeln('  WidgetsFlutterBinding.ensureInitialized();')
    ..writeln('  ')
    ..writeln('  // Configure desktop window')
    ..writeln('  await windowManager.ensureInitialized();')
    ..writeln('  await WindowConfig.configure();')
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
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
''';
}

String _windowConfig(BlueprintConfig config) {
  return '''
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

/// Desktop window configuration
class WindowConfig {
  WindowConfig._();

  static Future<void> configure() async {
    if (!_isDesktop) return;

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Color(0xFFFFFFFF),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: '${_titleCase(config.appName)}',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static bool get _isDesktop {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }
  
  /// Show/hide window
  static Future<void> show() => windowManager.show();
  static Future<void> hide() => windowManager.hide();
  
  /// Window state
  static Future<void> minimize() => windowManager.minimize();
  static Future<void> maximize() => windowManager.maximize();
  static Future<void> restore() => windowManager.restore();
  static Future<void> close() => windowManager.close();
  
  /// Fullscreen
  static Future<void> setFullScreen(bool isFullScreen) =>
      windowManager.setFullScreen(isFullScreen);
  
  /// Window size
  static Future<void> setSize(Size size) => windowManager.setSize(size);
  static Future<Size> getSize() => windowManager.getSize();
}
''';
}

String _desktopHelper(BlueprintConfig config) {
  return '''
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Desktop platform helper utilities
class DesktopHelper {
  DesktopHelper._();
  
  static bool get isDesktop {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }
  
  static bool get isMacOS => Platform.isMacOS;
  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  
  static String get platformName {
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
  
  /// Get appropriate keyboard shortcuts for platform
  static String get closeShortcut {
    if (Platform.isMacOS) return 'Cmd+Q';
    return 'Alt+F4';
  }
  
  static String get copyShortcut {
    if (Platform.isMacOS) return 'Cmd+C';
    return 'Ctrl+C';
  }
}
''';
}

String _desktopLayout(BlueprintConfig config) {
  return '''
import 'package:flutter/material.dart';
import 'title_bar.dart';

/// Desktop layout with optional custom title bar
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
    super.key,
    required this.child,
    this.showCustomTitleBar = false,
  });
  
  final Widget child;
  final bool showCustomTitleBar;

  @override
  Widget build(BuildContext context) {
    if (showCustomTitleBar) {
      return Column(
        children: [
          const CustomTitleBar(),
          Expanded(child: child),
        ],
      );
    }
    return child;
  }
}
''';
}

String _titleBar(BlueprintConfig config) {
  return '''
import 'package:flutter/material.dart';
import '../config/window_config.dart';

/// Custom title bar for desktop apps
class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            '${_titleCase(config.appName)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () => WindowConfig.minimize(),
            iconSize: 18,
          ),
          IconButton(
            icon: const Icon(Icons.crop_square),
            onPressed: () => WindowConfig.maximize(),
            iconSize: 18,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => WindowConfig.close(),
            iconSize: 18,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
''';
}

// Reuse templates from mobile/web (they work on desktop too)
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
  static const String settings = '/settings';
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
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF66AAFF),
        brightness: Brightness.dark,
      ),
      textTheme: buildTextTheme(),
      useMaterial3: true,
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
import '../../../../core/widgets/desktop_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: DesktopLayout(
        child: Center(
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
import '../../../../core/utils/desktop_helper.dart';

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
                Text(
                  'Desktop Platform: \${DesktopHelper.platformName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                const Text('BLoC Pattern - Desktop Optimized'),
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
