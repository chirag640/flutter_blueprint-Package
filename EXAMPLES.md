# Example Usage

This document provides practical examples of using flutter_blueprint in different scenarios.

## Basic Usage

### Create a Simple App

```bash
flutter_blueprint init my_app
```

Follow the interactive prompts to configure your project.

### Create with All Features Enabled

```bash
flutter_blueprint init my_app \
  --state provider \
  --theme \
  --localization \
  --env \
  --api \
  --tests
```

### Create Minimal App

```bash
flutter_blueprint init my_app \
  --state provider \
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
  --theme \
  --localization \
  --env \
  --api \
  --tests

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

### Internal Business Tool

```bash
flutter_blueprint init internal_tool \
  --state provider \
  --theme \
  --no-localization \
  --env \
  --api \
  --tests
```

**What you get:**

- Simple Provider state management
- API integration for internal services
- Environment switching (dev/prod)
- No localization overhead
- Testing infrastructure

### MVP Prototype

```bash
flutter_blueprint init mvp_prototype \
  --state provider \
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

# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
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
