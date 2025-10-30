# 🎯 flutter_blueprint

**Enterprise-grade Flutter app scaffolding CLI** — generates production-ready Flutter projects with **43+ professional files**, complete architecture, authentication patterns, error handling, storage layers, and reusable widgets. Stop wasting hours on boilerplate — start building features from day one.

[![Pub Version](https://img.shields.io/pub/v/flutter_blueprint)](https://pub.dev/packages/flutter_blueprint)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 🚀 Why flutter_blueprint?

| Problem                                    | Traditional Approach           | flutter_blueprint Solution                      |
| ------------------------------------------ | ------------------------------ | ----------------------------------------------- |
| `flutter create` gives bare bones          | Hours of manual setup          | **43+ files** with pro patterns instantly       |
| GitHub templates are opinionated & bloated | Copy-paste, delete unused code | Modular generation - only what you need         |
| No professional error handling             | Build it yourself              | **Custom exceptions + Failures** out of the box |
| Basic HTTP setup missing interceptors      | Add Dio, configure manually    | **Auth, Retry, Logger interceptors** included   |
| No reusable widgets                        | Create from scratch            | **Loading, Error, Empty states** ready to use   |
| Form validation boilerplate                | Write validators each time     | **Email, password, phone validators** built-in  |
| Storage layer missing                      | Mix SharedPrefs everywhere     | **LocalStorage + SecureStorage wrappers**       |
| No proper logging                          | print() statements everywhere  | **Professional Logger with levels**             |

**flutter_blueprint** is not just a template — it's a **smart code generator** that creates production-grade architecture tailored to your choices.

---

## ✨ Features

### **Core Features**

| Feature                       | Description                                     | Generated Files                 |
| ----------------------------- | ----------------------------------------------- | ------------------------------- |
| ⚡ **One-command setup**      | `flutter_blueprint init my_app`                 | 42-43 files in seconds          |
| 🧱 **Clean architecture**     | Separation of concerns (core/, features/, app/) | Professional folder structure   |
| 🎯 **State management**       | **Provider, Riverpod, OR Bloc**                 | Choose your preferred pattern   |
| 🎨 **Theming system**         | Material 3 with custom colors & typography      | AppTheme, AppColors, Typography |
| 🌐 **Internationalization**   | ARB files + intl config ready                   | en.arb, hi.arb, localization    |
| 🛠️ **Environment config**     | Dev/Stage/Prod with .env support                | EnvLoader + .env.example        |
| 🧭 **Professional routing**   | Route names, guards, centralized navigation     | AppRouter, RouteGuard, Routes   |
| 📱 **Multi-platform support** | Mobile, Web, Desktop - all in one project       | Universal or single-platform    |

### **Professional Add-ons** (What Makes It Pro)

| Feature                        | What You Get                                                                 |
| ------------------------------ | ---------------------------------------------------------------------------- |
| � **Production API Client**    | Dio + Auth/Retry/Logger interceptors + Generic methods (GET/POST/PUT/DELETE) |
| 🚨 **Error Handling System**   | 9 custom exception classes + Failures for clean architecture                 |
| 📝 **Professional Logger**     | AppLogger with debug/info/warning/error/success levels                       |
| ✅ **Form Validators**         | Email, password, phone, required, minLength, maxLength, numeric              |
| 💾 **Storage Layers**          | LocalStorage (SharedPreferences wrapper) + SecureStorage (tokens)            |
| � **Reusable Widgets**         | LoadingIndicator, ErrorView, EmptyState, CustomButton, CustomTextField       |
| 🌐 **Network Monitoring**      | NetworkInfo with connectivity checks                                         |
| � **Extensions & Utils**       | String, DateTime, Context extensions + Constants                             |
| 🧪 **Professional Tests**      | Validator tests, test helpers, widget tests                                  |
| 📁 **Smart File Organization** | Constants (endpoints, app), Errors, Network, Utils, Widgets                  |

### **DevOps Integration** (NEW in v0.5.0!)

| Feature                          | What You Get                                                          |
| -------------------------------- | --------------------------------------------------------------------- |
| 🚀 **CI/CD Scaffold Generation** | GitHub Actions, GitLab CI, or Azure Pipelines - ready on first commit |
| ✅ **Automated Quality Gates**   | Flutter analyze, dart format check, and automated tests               |
| 📊 **Coverage Reporting**        | Code coverage tracking with Codecov/built-in reports                  |
| 🏗️ **Multi-Platform Builds**     | Automated Android APK + iOS IPA generation                            |
| 🔥 **Deployment Templates**      | Firebase App Distribution integration ready to use                    |

---

## 📦 Installation

### Global Activation (Recommended)

```bash
dart pub global activate flutter_blueprint
```

Then use it anywhere:

```bash
flutter_blueprint init my_app
```

### Local Execution

```bash
dart run flutter_blueprint init my_app
```

---

## 🎬 Quick Start

### ✨ Interactive Wizard Mode (Recommended)

Just run without arguments for a beautiful guided experience:

```bash
flutter_blueprint init
```

**What happens:**

```
🎯 Welcome to flutter_blueprint!
   Let's create your Flutter app with professional architecture.

✔ 📱 App name · my_awesome_app

✔ 🎯 Choose state management · provider
   • Provider (ChangeNotifier, easy to learn)
   • Riverpod (Compile-time safe, better testability) ← NEW!
   • Bloc (Event-driven, coming soon)
   [Use ↑↓ arrow keys, Enter to select]

✔ ✨ Select features to include (use space to select, enter to confirm)
   ✓ Theme system (Light/Dark modes)
   ✓ Localization (i18n support)
   ✓ Environment config (.env)
   ✓ API client (Dio + interceptors)
   ✓ Test scaffolding

📋 Configuration Summary:
   App name: my_awesome_app
   State management: provider
   Theme: ✅
   Localization: ✅
   Environment: ✅
   API client: ✅
   Tests: ✅

✔ 🚀 Ready to generate your app? · yes

🚀 Generating project structure...
✅ Generated 43 files successfully!
```

**Features:**

- 🎨 **Beautiful UI** with emojis and colors
- ⌨️ **Arrow key navigation** for selections
- ☑️ **Multi-select checkboxes** for features (spacebar to toggle)
- ✅ **Smart validation** (prevents reserved words, invalid names)
- 📋 **Configuration preview** before generation

### ⚡ Quick Mode (For Experienced Users)

Skip the wizard by providing the app name:

```bash
flutter_blueprint init my_app
```

Add flags for full control:

```bash
# Provider template (classic ChangeNotifier pattern)
flutter_blueprint init my_app \
  --state provider \
  --theme \
  --env \
  --api \
  --tests

# Riverpod template (compile-time safe with StateNotifier)
flutter_blueprint init my_app \
  --state riverpod \
  --theme \
  --env \
  --api \
  --tests \
  --no-localization

# With CI/CD configuration
flutter_blueprint init my_app --ci github
flutter_blueprint init my_app --state riverpod --ci gitlab
flutter_blueprint init my_app --state bloc --ci azure

# Multi-platform support (NEW!)
flutter_blueprint init my_app --platforms mobile,web
flutter_blueprint init my_app --platforms all --state bloc
flutter_blueprint init my_desktop_app --platforms desktop --state riverpod
```

### Hybrid Mode (Mix Both)

```bash
flutter_blueprint init my_app --state riverpod
# Prompts for remaining options
```

---

## � Multi-Platform Support (NEW in v0.4.0!)

Build apps that run on **mobile, web, AND desktop** from a single codebase! flutter_blueprint now generates **universal multi-platform projects** with responsive layouts, adaptive navigation, and platform-specific optimizations.

### Quick Start

```bash
# Mobile + Web
flutter_blueprint init my_app --platforms mobile,web --state bloc

# All platforms (universal app)
flutter_blueprint init my_app --platforms all --state riverpod

# Desktop only
flutter_blueprint init my_desktop_app --platforms desktop --state provider
```

### Platform Options

| Option                   | Description                            | Generated Files                              |
| ------------------------ | -------------------------------------- | -------------------------------------------- |
| `--platforms mobile`     | iOS & Android only (default)           | Standard mobile project                      |
| `--platforms web`        | Web application only                   | `web/index.html`, PWA manifest, URL strategy |
| `--platforms desktop`    | Windows, macOS, Linux                  | Window management, desktop optimizations     |
| `--platforms mobile,web` | Multi-platform project (mobile + web)  | Responsive layouts, adaptive UI              |
| `--platforms all`        | Universal app (mobile + web + desktop) | Complete multi-platform solution             |

### Interactive Multi-Select

In wizard mode, select multiple platforms with checkboxes:

```
💻 Choose target platforms (space to select, enter to confirm):
[x] Mobile (iOS & Android)
[x] Web
[x] Desktop (Windows, macOS, Linux)
```

### What Gets Generated for Multi-Platform

**Universal Entry Points:**

```
lib/
├── main.dart              # Universal router (detects platform)
├── main_mobile.dart       # Mobile-specific initialization
├── main_web.dart          # Web-specific initialization (URL strategy)
└── main_desktop.dart      # Desktop-specific initialization (window manager)
```

**Responsive & Adaptive Components:**

```
lib/core/responsive/
├── breakpoints.dart           # Mobile/Tablet/Desktop breakpoints
├── responsive_layout.dart     # Responsive widget (adapts to screen size)
├── adaptive_scaffold.dart     # Adaptive navigation (bottom nav → rail → drawer)
└── responsive_spacing.dart    # Responsive padding & spacing helpers

lib/core/utils/
└── platform_info.dart         # Platform detection utilities
```

**Platform-Specific Files:**

- **Web**: `web/index.html`, `web/manifest.json` (PWA-ready)
- **Desktop**: Window configuration, title bar customization

### Smart Dependency Management

Dependencies are automatically added based on selected platforms:

```yaml
# Common (all platforms)
dependencies:
  # Responsive & sizing (recommended)
  flutter_screenutil: ^5.7.1

  # Web-specific
  url_strategy: ^0.3.0

  # Desktop-specific
  window_manager: ^0.4.3
  path_provider: ^2.1.5
```

### Responsive Features

**Breakpoints:**

```dart
// The generated responsive utilities use flutter_screenutil and LayoutBuilder.
// Example breakpoint helpers are provided in `core/config/responsive_config.dart`.
if (Breakpoints.isMobile(context)) {
  // Show mobile layout
} else if (Breakpoints.isTablet(context)) {
  // Show tablet layout
} else {
  // Show desktop layout
}
```

**Responsive Layouts:**

```dart
ResponsiveLayout(
  mobile: MobileView(),    // < 768px
  tablet: TabletView(),    // 768px - 1280px
  desktop: DesktopView(),  // >= 1280px
)
```

**Adaptive Navigation:**

- **Mobile**: Bottom navigation bar
- **Tablet**: Navigation rail
- **Desktop**: Side drawer/rail

### Platform Detection

```dart
if (PlatformInfo.isWeb) {
  // Web-specific code
} else if (PlatformInfo.isDesktop) {
  // Desktop-specific code
} else if (PlatformInfo.isMobile) {
  // Mobile-specific code
}
```

### Running Multi-Platform Projects

```bash
# Mobile
flutter run -d <device-id>

# Web
flutter run -d chrome

# Desktop
flutter run -d windows  # or macos, linux
```

### Building for Production

```bash
# Mobile
flutter build apk        # Android
flutter build ios        # iOS

# Web
flutter build web

# Desktop
flutter build windows    # Windows
flutter build macos      # macOS
flutter build linux      # Linux
```

### When to Use Multi-Platform

✅ **Use multi-platform when:**

- Building web + mobile versions of the same app
- Need desktop companion app for your mobile app
- Want to maximize code reuse across platforms
- Building internal tools that need to run everywhere

❌ **Use single-platform when:**

- Platform-specific features are critical (AR, NFC, etc.)
- Performance is absolutely critical
- Simple mobile-only app
- Heavy platform-specific UI requirements

---

## 🚀 CI/CD Integration

Generate production-ready CI/CD configurations with a single flag. Your project will be ready for automated testing and deployment from day one!

### Quick Start

```bash
# GitHub Actions
flutter_blueprint init my_app --ci github

# GitLab CI
flutter_blueprint init my_app --ci gitlab

# Azure Pipelines
flutter_blueprint init my_app --ci azure
```

### What Gets Generated

| Provider   | File                       | Pipeline Stages                                          |
| ---------- | -------------------------- | -------------------------------------------------------- |
| **GitHub** | `.github/workflows/ci.yml` | Analyze → Test → Build Android → Build iOS               |
| **GitLab** | `.gitlab-ci.yml`           | analyze → test → build:android → build:ios               |
| **Azure**  | `azure-pipelines.yml`      | Analyze Stage → Test Stage → Build Stage (Android + iOS) |

### Pipeline Features

All generated CI/CD configurations include:

- ✅ **Code Quality**: `flutter analyze` + `dart format` checks
- 🧪 **Automated Testing**: Unit tests with coverage reporting
- 📱 **Android Build**: APK generation with artifact upload
- 🍎 **iOS Build**: IPA generation (with codesigning instructions)
- 📊 **Coverage Reports**: Codecov integration (GitHub) / built-in reports
- 🔄 **Auto-retry**: Failed requests handled automatically
- 📦 **Artifact Storage**: Build outputs saved for 7 days

### Example: GitHub Actions Workflow

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter analyze
      - run: dart format --set-exit-if-changed .

  test:
    needs: analyze
    runs-on: ubuntu-latest
    steps:
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v4

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
```

### Deployment Ready

Generated workflows include commented templates for:

- 🔥 **Firebase App Distribution** - Deploy to testers instantly
- 🍎 **TestFlight** - iOS beta deployment
- ✍️ **Code Signing** - Instructions for production builds

### Setup Instructions

After generating your project with CI/CD:

**For GitHub Actions:**

1. Push your code to GitHub
2. Workflow runs automatically on push/PR
3. (Optional) Add `CODECOV_TOKEN` secret for coverage reports

**For GitLab CI:**

1. Push your code to GitLab
2. Pipeline runs automatically on push/MR
3. For iOS builds: Configure macOS runner in `.gitlab-ci.yml`

**For Azure Pipelines:**

1. Push your code to Azure Repos
2. Install Flutter extension for Azure Pipelines
3. Pipeline runs automatically on push/PR

---

## 🎯 State Management Templates

flutter_blueprint supports **multiple state management patterns** — choose the one that fits your team and project best!

### 📊 Comparison Table

| Feature                  | **Provider** 🟢                      | **Riverpod** 🟦                      | **Bloc** 🟣 (Coming Soon)         |
| ------------------------ | ------------------------------------ | ------------------------------------ | --------------------------------- |
| **Package**              | `provider: ^6.1.2`                   | `flutter_riverpod: ^2.5.1`           | `flutter_bloc: ^8.1.0`            |
| **Learning Curve**       | Easy - ChangeNotifier pattern        | Medium - New concepts                | Steep - Event-driven architecture |
| **Compile-Time Safety**  | ❌ Runtime errors possible           | ✅ Catch errors at compile time      | ✅ Strong typing                  |
| **Testability**          | Good - MockNotifier needed           | Excellent - ProviderContainer        | Excellent - Easy to mock          |
| **State Class**          | `ChangeNotifier`                     | `StateNotifier<State>`               | `Cubit<State>` or `Bloc<E, S>`    |
| **UI Update**            | `notifyListeners()`                  | `state = state.copyWith(...)`        | `emit(newState)`                  |
| **Widget Pattern**       | `Consumer<T>` / `Provider.of`        | `ConsumerWidget` + `ref.watch()`     | `BlocBuilder` / `BlocConsumer`    |
| **Dependency Injection** | `MultiProvider` wrapper              | `ProviderScope` + global providers   | `BlocProvider` tree               |
| **Automatic Disposal**   | Manual `dispose()` required          | ✅ Automatic                         | ✅ Automatic                      |
| **Generated Files**      | 43 files                             | 42 files                             | TBD                               |
| **Best For**             | Small-medium apps, rapid prototyping | Large apps, enterprise, strong teams | Complex state, event-driven logic |

### 🟢 Provider Template

**When to use:** You want simplicity, familiarity, and quick onboarding for new Flutter developers.

**Example State Management:**

```dart
// home_provider.dart
class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  int _counter = 0;

  void incrementCounter() {
    _counter++;
    notifyListeners(); // Manual notification
  }
}

// home_content.dart
Consumer<HomeProvider>(
  builder: (context, provider, child) {
    return Text('Counter: ${provider.counter}');
  },
)
```

### 🟦 Riverpod Template (NEW!)

**When to use:** You want compile-time safety, better testability, and you're building a large-scale app.

**Example State Management:**

```dart
// home_provider.dart
class HomeState {
  final bool isLoading;
  final int counter;

  HomeState({required this.isLoading, required this.counter});

  HomeState copyWith({bool? isLoading, int? counter}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      counter: counter ?? this.counter,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState(isLoading: false, counter: 0));

  void incrementCounter() {
    state = state.copyWith(counter: state.counter + 1); // Immutable update
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

// home_content.dart
class HomeContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider); // Auto-rebuild on changes
    return Column(
      children: [
        Text('Counter: ${homeState.counter}'),
        ElevatedButton(
          onPressed: () => ref.read(homeProvider.notifier).incrementCounter(),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

**Riverpod Benefits:**

- ✅ **No BuildContext needed** - access providers anywhere
- ✅ **Compile-time errors** - typos caught immediately
- ✅ **Immutable state** - easier debugging with state history
- ✅ **Auto-disposal** - no memory leaks
- ✅ **Better testing** - use `ProviderContainer` for isolated tests
- ✅ **Family & AutoDispose** modifiers for advanced use cases

### 🟣 Bloc Template (Coming Soon!)

**When to use:** You need event-driven architecture, complex business logic, or team is familiar with BLoC pattern.

Stay tuned for Bloc support!

---

## 🧩 Generated Project Structure (43+ Files!)

```
my_app/
├── lib/
│   ├── main.dart                              # App entry point
│   ├── app/
│   │   └── app.dart                           # Root app widget with providers
│   ├── core/
│   │   ├── api/                               # 🌐 Network layer
│   │   │   ├── api_client.dart                #   Dio client with GET/POST/PUT/DELETE
│   │   │   ├── api_response.dart              #   Generic response wrapper
│   │   │   └── interceptors/
│   │   │       ├── auth_interceptor.dart      #   Auto-add auth tokens
│   │   │       ├── retry_interceptor.dart     #   Auto-retry failed requests
│   │   │       └── logger_interceptor.dart    #   Log all API calls
│   │   ├── config/
│   │   │   ├── app_config.dart                # 🎛️ App configuration
│   │   │   └── env_loader.dart                #   Dev/Stage/Prod environments
│   │   ├── constants/
│   │   │   ├── app_constants.dart             # 📋 Timeouts, storage keys, pagination
│   │   │   └── api_endpoints.dart             #   Centralized API routes
│   │   ├── errors/
│   │   │   ├── exceptions.dart                # 🚨 9 custom exception types
│   │   │   └── failures.dart                  #   Clean architecture failures
│   │   ├── network/
│   │   │   └── network_info.dart              # 📡 Connectivity monitoring
│   │   ├── routing/
│   │   │   ├── app_router.dart                # 🧭 Route management
│   │   │   ├── route_guard.dart               #   Auth guards
│   │   │   └── route_names.dart               #   Centralized route constants
│   │   ├── storage/
│   │   │   ├── local_storage.dart             # 💾 SharedPreferences wrapper
│   │   │   └── secure_storage.dart            #   Secure token storage
│   │   ├── theme/
│   │   │   ├── app_theme.dart                 # 🎨 Light/Dark themes
│   │   │   ├── app_colors.dart                #   Color palette
│   │   │   └── typography.dart                #   Text styles
│   │   ├── utils/
│   │   │   ├── logger.dart                    # 📝 Pro logger (debug/info/warn/error)
│   │   │   ├── validators.dart                #   Form validators (email/phone/etc)
│   │   │   └── extensions.dart                #   String/DateTime/Context extensions
│   │   └── widgets/                           # 🧩 Reusable UI components
│   │       ├── loading_indicator.dart         #   Loading spinner
│   │       ├── error_view.dart                #   Error display with retry
│   │       ├── empty_state.dart               #   Empty list placeholder
│   │       ├── custom_button.dart             #   Button with loading state
│   │       └── custom_text_field.dart         #   Styled text input
│   └── features/
│       └── home/                              # 🏠 Sample feature (clean architecture)
│           └── presentation/
│               ├── pages/
│               │   └── home_page.dart         #   Home screen
│               ├── providers/
│               │   └── home_provider.dart     #   State management
│               └── widgets/
│                   └── home_content.dart      #   Home UI components
├── assets/
│   └── l10n/
│       ├── en.arb                             # 🌍 English translations
│       └── hi.arb                             #   Hindi translations
├── test/
│   ├── widget_test.dart                       # 🧪 Sample widget test
│   ├── core/
│   │   └── utils/
│   │       └── validators_test.dart           #   Validator unit tests
│   └── helpers/
│       └── test_helpers.dart                  #   Test utilities
├── .env.example                               # 🔐 Environment variables template
├── blueprint.yaml                             # 📘 Project metadata
└── pubspec.yaml                               # 📦 Dependencies
```

**File Count by Feature Set:**

- **Minimal** (no optional features): 19 files
- **Full Stack** (all features enabled): **43 files** 🚀

---

## 🧠 Architecture Principles

### Clean Separation of Concerns

- **`core/`**: Shared infrastructure (config, theme, routing, API)
- **`features/`**: Business logic organized by feature
- **`app/`**: Root app configuration and providers

### Dependency Injection Ready

Uses `Provider` for service location:

```dart
Provider<AppConfig>(create: (_) => AppConfig.load()),
Provider<ApiClient>(create: (context) => ApiClient(context.read<AppConfig>())),
```

### Type-Safe Configuration

```dart
class AppConfig {
  final String appTitle;
  final String environment;
  final String apiBaseUrl;
  // ...
}
```

---

## 🛠️ CLI Commands

### `init` - Create New Project

```bash
flutter_blueprint init <app_name> [options]
```

**Options:**

| Flag                 | Description                                                       | Default            |
| -------------------- | ----------------------------------------------------------------- | ------------------ |
| `--state <choice>`   | State management (provider/riverpod/bloc)                         | Interactive prompt |
| `--platforms <list>` | Target platforms (mobile/web/desktop or comma-separated or "all") | mobile             |
| `--ci <provider>`    | CI/CD provider (github/gitlab/azure)                              | none               |
| `--theme`            | Include theme scaffolding                                         | Interactive prompt |
| `--localization`     | Include l10n setup                                                | Interactive prompt |
| `--env`              | Include environment config                                        | Interactive prompt |
| `--api`              | Include API client                                                | Interactive prompt |
| `--tests`            | Include test scaffolding                                          | Interactive prompt |
| `-h, --help`         | Show help                                                         | -                  |
| `-v, --version`      | Show version                                                      | -                  |

---

### `add feature` - Incremental feature generation (killer feature)

Add a new feature to an existing project without touching the rest of your app. The command scaffolds clean-architecture folders (data/domain/presentation), generates state-management boilerplate that matches the project's `blueprint.yaml` (Provider, Riverpod or BLoC), and injects a new route into `app_router.dart`.

Usage:

```bash
# Full feature with all layers
flutter_blueprint add feature <feature_name>

# Only presentation layer
flutter_blueprint add feature settings --presentation --no-data --no-domain

# Add feature with remote API integration
flutter_blueprint add feature products --api
```

Flags:

| Flag                                   | Description                                                      |
| -------------------------------------- | ---------------------------------------------------------------- |
| `--data` / `--no-data`                 | Generate data layer (models, data sources, repository)           |
| `--domain` / `--no-domain`             | Generate domain layer (entities, repository contract, use cases) |
| `--presentation` / `--no-presentation` | Generate presentation layer (pages, widgets, state)              |
| `--api`                                | Include remote data source (Dio) in the data layer               |

Behavior & notes:

- The command must be run from the root of a previously generated flutter_blueprint project (it reads `blueprint.yaml`).
- It detects the project's state-management setting from `blueprint.yaml` and emits matching files for Provider, Riverpod, or Bloc.
- If `app_router.dart` exists, the generator will add the page import, a route constant to `RouteNames`, and a `case` in the router switch to return the new page.
- The generator is idempotent for route insertion: it will not duplicate imports or constants if they already exist.
- For Riverpod/Bloc the generated state files follow the project's Dart version (uses sealed classes / StateNotifier / Bloc patterns as appropriate).

Examples:

```bash
# Generate a full "auth" feature using the project's state-management
flutter_blueprint add feature auth

# Generate only presentation for "settings"
flutter_blueprint add feature settings --presentation --no-data --no-domain

# Generate products feature and include remote API data source
flutter_blueprint add feature products --api
```

## 📋 blueprint.yaml

Every generated project includes a `blueprint.yaml` manifest:

```yaml
version: 1
app_name: my_app
platforms:
  - mobile
  - web
state_management: provider
ci_provider: github
features:
  api: true
  env: true
  localization: false
  tests: true
  theme: true
```

**Future Use:** This enables regeneration, upgrades, and feature addition.

---

## 🎯 Target Audience

- **Junior developers**: who don't yet know how to structure a real project
- **Indie devs**: who want to spin up production-ready apps quickly
- **Small teams**: who want standardization without heavy frameworks

---

## 🚧 Roadmap

### Phase 1: MVP ✅

- [x] CLI tool setup
- [x] Basic project generator
- [x] Provider template
- [x] Theme + routing boilerplate

### Phase 2: Multi-Template Support ✅

- [x] Riverpod template
- [x] Bloc template
- [x] Localization integration
- [x] API client scaffolding

### Phase 3: Platform Expansion ✅ (v0.4.0)

- [x] Multi-platform support (mobile, web, desktop)
- [x] Responsive layout system
- [x] Adaptive navigation
- [x] Universal project generation
- [x] Platform-specific optimizations

### Phase 4: Feature Generation ✅ (v0.3.0)

- [x] `flutter_blueprint add feature <name>`
- [x] Clean architecture layers
- [x] Auto-router integration
- [x] State management detection

### Phase 5: DevOps Integration ✅ (v0.5.0)

- [x] GitHub Actions CI/CD scaffold
- [x] GitLab CI pipelines
- [x] Azure Pipelines support
- [x] Automated testing & builds
- [x] Firebase deployment templates

### Phase 6: Future Enhancements 🚀

- [ ] Interactive upgrades via `blueprint.yaml`
- [ ] Plugin ecosystem (auth, firebase, analytics)
- [ ] VSCode/IntelliJ extensions
- [ ] Blueprint dashboard (web-based config UI)
- [ ] Project migration tools
- [ ] Custom template support

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💬 Support

- 📧 Email: support@flutter-blueprint.dev
- 🐛 Issues: [GitHub Issues](https://github.com/chirag640/flutter_blueprint-Package-Package/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/chirag640/flutter_blueprint-Package-Package/discussions)

---

## 📦 Publishing to pub.dev

This project is prepared to be published to pub.dev. Below are safe, recommended steps to publish a new release. The repository includes helper scripts in `scripts/`.

Before you publish:

1. Update `CHANGELOG.md` with the release notes for the new version.
2. Bump the `version:` in `pubspec.yaml` to the new semver (e.g. `0.5.1`).
3. Commit your changes and push to the `main` branch.

Quick publish commands (dry-run first):

PowerShell (Windows):
```powershell
cd <path-to-repo>
git checkout main
git pull
dart pub get
dart pub publish --dry-run
# If dry-run is OK:
# dart pub publish
```

Bash (macOS / Linux):
```bash
cd <path-to-repo>
git checkout main
git pull
dart pub get
dart pub publish --dry-run
# If dry-run is OK:
# dart pub publish
```

Recommended scripted flow (included):

- `scripts/publish.ps1` — Powershell script that runs tests, does a `dry-run`, and prompts to continue with real publish.
- `scripts/publish.sh` — Bash counterpart for Unix-like systems.

Notes:

- You must be logged in to pub.dev (`dart pub login`) with the account that will publish the package.
- The package `pubspec.yaml` must have a unique `name:` that isn't already taken on pub.dev.
- Verify the `version:` follows semantic versioning; pub.dev rejects duplicate versions.


---

## 🌟 Show Your Support

If this project helped you, please ⭐ the repository and share it with others!

---

**Made with ❤️ for the Flutter community**
