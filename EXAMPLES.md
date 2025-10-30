# Example Usage

This document provides practical examples of using flutter_blueprint in different scenarios.

## Basic Usage

### Create a Simple App

```bash
flutter_blueprint init my_app
```

Follow the interactive prompts to configure your project, including multi-platform selection.

### Create Multi-Platform App

```bash
# All platforms (mobile, web, desktop)
flutter_blueprint init my_app --platforms all

# Specific platforms (comma-separated)
flutter_blueprint init my_app --platforms mobile,web

# Web and Desktop only
flutter_blueprint init my_app --platforms web,desktop
```

### Create with All Features Enabled

```bash
flutter_blueprint init my_app \
  --state provider \
  --platforms mobile,web \
  --theme \
  --localization \
  --env \
  --api \
  --tests \
  --ci github
```

### Create Minimal App

```bash
flutter_blueprint init my_app \
  --state provider \
  --platforms mobile \
  --no-theme \
  --no-localization \
  --no-env \
  --no-api \
  --no-tests
```

## Real-World Scenarios

### E-Commerce Mobile App

```bash
flutter_blueprint init shop_app \
  --state riverpod \
  --platforms mobile \
  --theme \
  --localization \
  --env \
  --api \
  --tests \
  --ci github

cd shop_app
flutter pub get
flutter run
```

**What you get:**

- Multi-language support for international markets
- Environment configs for dev/staging/production
- API client ready for backend integration
- Theme system for brand consistency
- Test scaffolding for quality assurance
- CI/CD pipeline with GitHub Actions

### Multi-Platform SaaS Application

```bash
flutter_blueprint init saas_platform \
  --state bloc \
  --platforms mobile,web,desktop \
  --theme \
  --localization \
  --env \
  --api \
  --tests \
  --ci gitlab

cd saas_platform
flutter pub get

# Run on different platforms
flutter run -d chrome          # Web
flutter run -d windows         # Desktop
flutter run -d <device-id>     # Mobile
```

**What you get:**

- Universal app running on all platforms
- Responsive layouts that adapt to screen size
- Adaptive navigation (bottom nav → rail → drawer)
- Platform-specific optimizations
- Single codebase for all platforms
- CI/CD for all platforms

### Internal Dashboard (Desktop + Web)

```bash
flutter_blueprint init admin_dashboard \
  --state riverpod \
  --platforms web,desktop \
  --theme \
  --no-localization \
  --env \
  --api \
  --tests
```

**What you get:**

- Desktop app for power users
- Web app for remote access
- Shared business logic
- Professional window management
- API integration for backend
- No mobile overhead

### Progressive Web App (PWA)

```bash
flutter_blueprint init pwa_app \
  --state provider \
  --platforms web \
  --theme \
  --localization \
  --env \
  --api \
  --tests
```

**What you get:**

- Web-optimized project
- PWA-ready with manifest.json
- Clean URLs with url_strategy
- Responsive web layouts
- Installable web app

### MVP Prototype

```bash
flutter_blueprint init mvp_prototype \
  --state provider \
  --platforms mobile \
  --theme \
  --no-localization \
  --no-env \
  --no-api \
  --no-tests
```

**What you get:**

- Fast setup with minimal complexity
- Theme system for polished UI
- Focus on quick iteration
- Can add features later via blueprint.yaml

## Working with Generated Projects

### After Generation

```bash
cd my_app

# Dependencies are installed automatically by the generator.
# If automatic installation fails, run the following manually:
flutter pub get

# Run the app (mobile)
flutter run

# Run on specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Desktop
flutter run -d macos           # macOS
flutter run -d linux           # Linux

# Build for release
flutter build apk              # Android
flutter build ios              # iOS
flutter build web              # Web
flutter build windows          # Windows
flutter build macos            # macOS
flutter build linux            # Linux

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Multi-Platform Project Structure

For projects created with `--platforms all` or multiple platforms:

```
lib/
├── main.dart                 # Routes to platform-specific main
├── main_mobile.dart          # Mobile entry point
├── main_web.dart             # Web entry point (with URL strategy)
├── main_desktop.dart         # Desktop entry point (with window setup)
├── core/
│   ├── config/
│   │   └── responsive_config.dart  # Breakpoints & layouts (generated with flutter_screenutil helpers)
│   └── utils/
│       └── platform_info.dart      # Runtime platform detection
└── features/
    └── home/
        └── presentation/
            ├── pages/
            │   └── home_page.dart  # Uses responsive layouts
            └── widgets/
                └── responsive_layout.dart
```

## Multi-Platform Development

### Using Responsive Layouts

For multi-platform projects, use the generated responsive utilities:

```dart
import 'package:my_app/core/config/responsive_config.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobilePage(),        // Width < 768
      tablet: TabletPage(),        // 768 <= Width < 1280
      desktop: DesktopPage(),      // Width >= 1280
    );
  }
}
```

### Adaptive Navigation

Generated multi-platform projects include adaptive navigation:

```dart
import 'package:my_app/core/config/responsive_config.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      body: _currentPage,
    );
    // Mobile: Bottom Navigation Bar
    // Tablet: Navigation Rail
    // Desktop: Navigation Drawer
  }
}
```

### Platform Detection

Detect platform at runtime:

```dart
import 'package:my_app/core/utils/platform_info.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isDesktop) {
      return DesktopWidget();
    } else if (PlatformInfo.isWeb) {
      return WebWidget();
    } else {
      return MobileWidget();
    }
  }
}
```

### Responsive Padding

Use responsive spacing utilities:

```dart
import 'package:my_app/core/config/responsive_config.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsivePadding.all(context),
      // Mobile: 16px, Tablet: 24px, Desktop: 32px
      child: Text('Responsive Padding'),
    );
  }
}
```

### Customizing the Generated Project

1. **Update Theme Colors**

Edit `lib/core/theme/app_theme.dart`:

```dart
static ThemeData light() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF5722), // Your brand color
    ),
    // ...
  );
}
```

2. **Add New Routes**

Edit `lib/core/routing/app_router.dart`:

```dart
class AppRouter {
  static const home = '/';
  static const profile = '/profile'; // Add new route

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile: // Handle new route
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      // ...
    }
  }
}
```

3. **Configure Environment Variables**

Edit `.env` (copy from `.env.example`):

```env
APP_ENV=dev
API_BASE_URL=https://api.myapp.com
API_KEY=your_api_key_here
```

4. **Add Localization Strings**

Edit `assets/l10n/en.arb`:

```json
{
  "@@locale": "en",
  "appTitle": "My App",
  "welcomeMessage": "Welcome to My App!",
  "loginButton": "Login"
}
```

### Adding a New Feature

Currently manual, but future versions will support:

```bash
# Coming in v0.2.0
flutter_blueprint add feature authentication
```

For now, create manually:

```
lib/features/
└── authentication/
    ├── data/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   └── entities/
    └── presentation/
        ├── pages/
        ├── widgets/
        └── providers/ (or blocs/)
```

## CI/CD Integration

### GitHub Actions Example

`.github/workflows/test.yml`:

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.0"
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

## Tips and Best Practices

### 1. Start with Provider

If you're new to Flutter state management, start with Provider. You can always refactor to Riverpod or Bloc later.

### 2. Use Environment Variables

Always use environment variables for:

- API URLs
- API keys
- Feature flags
- Environment-specific configs

### 3. Follow the Architecture

The generated structure follows clean architecture:

- Keep business logic in `features/`
- Keep shared code in `core/`
- Don't mix presentation and data layers

### 4. Write Tests Early

The test scaffolding is there for a reason. Write tests as you build features.

### 5. Commit blueprint.yaml

Keep `blueprint.yaml` in version control. It documents your project's configuration and enables future tooling.

## Troubleshooting

### Command Not Found

If `flutter_blueprint` command is not found:

```bash
# Make sure global pub packages are in PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Or use dart run
dart pub global run flutter_blueprint:flutter_blueprint init my_app
```

### Generation Fails

Check that:

1. You have write permissions in the target directory
2. The app name is valid (lowercase, underscores, no spaces)
3. You have internet connection for dependency resolution

### Generated Project Won't Build

```bash
cd my_app
flutter clean
flutter pub get
flutter run
```

If issues persist, check:

- Flutter version: `flutter --version` (should be >=3.24.0)
- Dart version: `dart --version` (should be >=3.3.0)

## Getting Help

- 📖 Read the [README](README.md)
- 🐛 Report issues on [GitHub](https://github.com/chirag640/flutter_blueprint-Package/issues)
- 💬 Ask questions in [Discussions](https://github.com/chirag640/flutter_blueprint-Package/discussions)
