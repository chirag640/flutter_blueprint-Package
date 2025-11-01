/// Universal multi-platform template generator.
library;

import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/bloc_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/provider_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/riverpod_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/responsive_template.dart';
import 'package:flutter_blueprint/src/templates/template_bundle.dart';

/// Builds a universal multi-platform template combining multiple platforms.
TemplateBundle buildUniversalTemplate(BlueprintConfig config) {
  // Get base mobile template bundle
  final mobileBundle = _getMobileBundle(config);

  // Get all files from mobile bundle
  final files = <String, String>{};
  for (final templateFile in mobileBundle.files) {
    final shouldGenerate = templateFile.shouldGenerate;
    if (shouldGenerate == null || shouldGenerate(config)) {
      files[templateFile.path] = templateFile.build(config);
    }
  }

  // Add responsive utilities
  files.addAll(_getResponsiveFiles());

  // Add platform-specific entry points (skip main.dart from mobile, we create our own)
  files.remove('lib/main.dart');
  files.addAll(_getPlatformEntryPoints(config));

  // Add web-specific files if web is included
  if (config.hasPlatform(TargetPlatform.web)) {
    files.addAll(_getWebSpecificFiles());
  }

  // Add desktop-specific files if desktop is included
  if (config.hasPlatform(TargetPlatform.desktop)) {
    files.addAll(_getDesktopSpecificFiles());
  }

  // Override pubspec with all platform dependencies
  files['pubspec.yaml'] = _buildUniversalPubspec(config);

  // Override README with multi-platform info
  files['README.md'] = _buildUniversalReadme(config);

  // Return as TemplateBundle
  return TemplateBundle(
    files: files.entries
        .map((e) => TemplateFile(
              path: e.key,
              build: (_) => e.value,
            ))
        .toList(),
  );
}

/// Get mobile template based on state management
TemplateBundle _getMobileBundle(BlueprintConfig config) {
  switch (config.stateManagement) {
    case StateManagement.bloc:
      return buildBlocMobileBundle();
    case StateManagement.provider:
      return buildProviderMobileBundle();
    case StateManagement.riverpod:
      return buildRiverpodMobileBundle();
  }
}

/// Get responsive utility files using flutter_screenutil
Map<String, String> _getResponsiveFiles() {
  return {
    'lib/core/responsive/screen_util_config.dart':
        ResponsiveComponents.screenUtilConfig(),
    'lib/core/responsive/responsive_layout.dart':
        ResponsiveComponents.responsiveLayoutWidget(),
    'lib/core/responsive/adaptive_scaffold.dart':
        ResponsiveComponents.adaptiveScaffold(),
    'lib/core/responsive/app_spacing.dart':
        ResponsiveComponents.responsiveSpacingHelper(),
    'lib/core/utils/platform_info.dart':
        ResponsiveComponents.platformDetector(),
  };
}

/// Get platform-specific entry points
Map<String, String> _getPlatformEntryPoints(BlueprintConfig config) {
  final files = <String, String>{};

  // Universal main.dart that routes to platform-specific entry points
  files['lib/main.dart'] = _buildUniversalMain(config);

  if (config.hasPlatform(TargetPlatform.mobile)) {
    files['lib/main_mobile.dart'] = _buildMobileMain(config);
  }

  if (config.hasPlatform(TargetPlatform.web)) {
    files['lib/main_web.dart'] = _buildWebMain(config);
  }

  if (config.hasPlatform(TargetPlatform.desktop)) {
    files['lib/main_desktop.dart'] = _buildDesktopMain(config);
  }

  return files;
}

/// Build universal main.dart that routes to platform-specific mains
String _buildUniversalMain(BlueprintConfig config) {
  return '''
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

${config.hasPlatform(TargetPlatform.mobile) ? "import 'main_mobile.dart' as mobile;" : ''}
${config.hasPlatform(TargetPlatform.web) ? "import 'main_web.dart' as web;" : ''}
${config.hasPlatform(TargetPlatform.desktop) ? "import 'main_desktop.dart' as desktop;" : ''}

/// Universal entry point that routes to platform-specific initialization
void main() async {
  if (kIsWeb) {
    ${config.hasPlatform(TargetPlatform.web) ? 'web.main();' : '// Web not supported'}
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    ${config.hasPlatform(TargetPlatform.desktop) ? 'desktop.main();' : '// Desktop not supported'}
  } else {
    ${config.hasPlatform(TargetPlatform.mobile) ? 'mobile.main();' : '// Mobile not supported'}
  }
}
''';
}

/// Build mobile-specific main
String _buildMobileMain(BlueprintConfig config) {
  final stateSetup = _getStateManagementSetup(config.stateManagement);

  return '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/responsive/screen_util_config.dart';
$stateSetup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(${_getAppWrapper(config.stateManagement, 'const MyApp()')});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap app with ScreenUtilInit for responsive sizing
    return ScreenUtilInit(
      designSize: AppScreen.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: '${config.appName}',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${config.appName} - Mobile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 64.w), // Responsive icon size
            SizedBox(height: 16.h), // Responsive spacing
            Text(
              'Mobile Platform',
              style: TextStyle(
                fontSize: 24.sp, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Screen: \${ScreenUtil().screenWidth.toInt()}x\${ScreenUtil().screenHeight.toInt()}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
''';
}

/// Build web-specific main
String _buildWebMain(BlueprintConfig config) {
  final stateSetup = _getStateManagementSetup(config.stateManagement);

  return '''
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
$stateSetup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Remove the # from URLs
  setPathUrlStrategy();
  
  runApp(${_getAppWrapper(config.stateManagement, 'const MyApp()')});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${config.appName}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${config.appName} - Web'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.web, size: 64),
            SizedBox(height: 16),
            Text(
              'Web Platform',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
''';
}

/// Build desktop-specific main
String _buildDesktopMain(BlueprintConfig config) {
  final stateSetup = _getStateManagementSetup(config.stateManagement);

  return '''
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
$stateSetup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(${_getAppWrapper(config.stateManagement, 'const MyApp()')});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${config.appName}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${config.appName} - Desktop'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.desktop_windows, size: 64),
            SizedBox(height: 16),
            Text(
              'Desktop Platform',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
''';
}

String _getStateManagementSetup(StateManagement stateManagement) {
  switch (stateManagement) {
    case StateManagement.bloc:
      return "import 'package:flutter_bloc/flutter_bloc.dart';";
    case StateManagement.provider:
      return "import 'package:provider/provider.dart';";
    case StateManagement.riverpod:
      return "import 'package:flutter_riverpod/flutter_riverpod.dart';";
  }
}

String _getAppWrapper(StateManagement stateManagement, String app) {
  switch (stateManagement) {
    case StateManagement.bloc:
      return app;
    case StateManagement.provider:
      return app;
    case StateManagement.riverpod:
      return 'ProviderScope(child: $app)';
  }
}

/// Get web-specific files
Map<String, String> _getWebSpecificFiles() {
  return {
    'web/index.html': '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Flutter App</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter.js" defer></script>
</body>
</html>
''',
    'web/manifest.json': '''
{
  "name": "Flutter App",
  "short_name": "Flutter",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "A Flutter web application",
  "orientation": "portrait-primary",
  "prefer_related_applications": false
}
''',
  };
}

/// Get desktop-specific files
Map<String, String> _getDesktopSpecificFiles() {
  return {
    'windows/runner/main.cpp': '// Windows runner placeholder',
    'macos/Runner/MainFlutterWindow.swift': '// macOS runner placeholder',
    'linux/my_application.cc': '// Linux runner placeholder',
  };
}

/// Build universal pubspec.yaml
String _buildUniversalPubspec(BlueprintConfig config) {
  final dependencies = <String>[];

  // Common dependencies
  dependencies.add('  flutter:\n    sdk: flutter');

  // State management dependencies
  switch (config.stateManagement) {
    case StateManagement.bloc:
      dependencies.add('  flutter_bloc: ^8.1.5');
      dependencies.add('  bloc: ^8.1.4');
      dependencies
          .add('  equatable: ^2.0.5'); // Used with BLoC for state comparison
      break;
    case StateManagement.provider:
      dependencies.add('  provider: ^6.1.2');
      dependencies.add('  equatable: ^2.0.5'); // Used for value equality
      break;
    case StateManagement.riverpod:
      dependencies.add('  flutter_riverpod: ^2.5.1');
      dependencies.add('  riverpod_annotation: ^2.3.3');
      dependencies.add('  equatable: ^2.0.5'); // Used for value equality
      break;
  }

  // Responsive UI with flutter_screenutil
  dependencies.add('  flutter_screenutil: ^5.9.3');

  // Common utilities (used in generated core utilities)
  dependencies.add('  shared_preferences: ^2.2.3');
  dependencies.add('  flutter_secure_storage: ^9.2.2');

  // Localization (if enabled)
  if (config.includeLocalization) {
    dependencies.add('  flutter_localizations:\n    sdk: flutter');
    dependencies.add('  intl: ^0.20.2');
  }

  // Environment variables (if enabled)
  if (config.includeEnv) {
    dependencies.add('  flutter_dotenv: ^5.1.0');
  }

  // API & networking (if enabled)
  if (config.includeApi) {
    dependencies.add('  dio: ^5.5.0');
    dependencies.add('  connectivity_plus: ^6.0.5');
    dependencies.add('  pretty_dio_logger: ^1.4.0');
  }

  // Platform-specific dependencies
  if (config.hasPlatform(TargetPlatform.web)) {
    dependencies.add('  url_strategy: ^0.3.0');
  }

  if (config.hasPlatform(TargetPlatform.desktop)) {
    dependencies.add('  window_manager: ^0.4.3');
    dependencies.add('  path_provider: ^2.1.5');
  }

  // Dev dependencies
  final devDependencies = <String>[];
  devDependencies.add('  flutter_test:\n    sdk: flutter');
  devDependencies.add('  flutter_lints: ^5.0.0');

  if (config.includeTests) {
    devDependencies.add('  mocktail: ^1.0.3');
    if (config.stateManagement == StateManagement.bloc) {
      devDependencies.add('  bloc_test: ^9.1.7');
    }
  }

  // Assets configuration
  final assetsConfig = config.includeLocalization
      ? '''
  assets:
    - assets/l10n/'''
      : '';

  return '''
name: ${config.appName}
description: A multi-platform Flutter project
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"
  flutter: ">=3.24.0"

dependencies:
${dependencies.join('\n')}

dev_dependencies:
${devDependencies.join('\n')}

flutter:
  uses-material-design: true
  $assetsConfig
''';
}

/// Build universal README
String _buildUniversalReadme(BlueprintConfig config) {
  final platforms = config.platforms.map((p) => p.label).join(', ');

  return '''
# ${config.appName}

A multi-platform Flutter application supporting: **$platforms**

## Platforms

${config.hasPlatform(TargetPlatform.mobile) ? '- ✅ Mobile (iOS & Android)' : ''}
${config.hasPlatform(TargetPlatform.web) ? '- ✅ Web' : ''}
${config.hasPlatform(TargetPlatform.desktop) ? '- ✅ Desktop (Windows, macOS, Linux)' : ''}

## State Management

- **${config.stateManagement.label}**

## Project Structure

```
lib/
├── main.dart                    # Universal entry point
${config.hasPlatform(TargetPlatform.mobile) ? '├── main_mobile.dart            # Mobile-specific initialization' : ''}
${config.hasPlatform(TargetPlatform.web) ? '├── main_web.dart               # Web-specific initialization' : ''}
${config.hasPlatform(TargetPlatform.desktop) ? '├── main_desktop.dart           # Desktop-specific initialization' : ''}
├── core/
│   ├── responsive/             # Responsive layout utilities
│   └── utils/                  # Platform detection utilities
└── features/                   # Feature modules
```

## Getting Started

### Run on Mobile
```bash
flutter run -d <device-id>
```

### Run on Web
```bash
flutter run -d chrome
```

### Run on Desktop
```bash
flutter run -d windows  # or macos, linux
```

## Building for Production

### Mobile
```bash
flutter build apk        # Android
flutter build ios        # iOS
```

### Web
```bash
flutter build web
```

### Desktop
```bash
flutter build windows    # Windows
flutter build macos      # macOS
flutter build linux      # Linux
```

## Responsive Design

This project uses adaptive layouts that automatically adjust based on screen size:
- **Mobile**: Bottom navigation, single column
- **Tablet**: Navigation rail, multi-column
- **Desktop**: Side navigation, wide layouts

Generated with ❤️ by **Flutter Blueprint**
''';
}
