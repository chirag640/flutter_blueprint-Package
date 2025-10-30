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

| Feature                     | Description                                     | Generated Files                 |
| --------------------------- | ----------------------------------------------- | ------------------------------- |
| ⚡ **One-command setup**    | `flutter_blueprint init my_app`                 | 42-43 files in seconds          |
| 🧱 **Clean architecture**   | Separation of concerns (core/, features/, app/) | Professional folder structure   |
| 🎯 **State management**     | **Provider OR Riverpod** (Bloc coming soon)     | Choose your preferred pattern   |
| 🎨 **Theming system**       | Material 3 with custom colors & typography      | AppTheme, AppColors, Typography |
| 🌐 **Internationalization** | ARB files + intl config ready                   | en.arb, hi.arb, localization    |
| 🛠️ **Environment config**   | Dev/Stage/Prod with .env support                | EnvLoader + .env.example        |
| 🧭 **Professional routing** | Route names, guards, centralized navigation     | AppRouter, RouteGuard, Routes   |

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
  --tests
  --no-localization
```

### Hybrid Mode (Mix Both)

```bash
flutter_blueprint init my_app --state riverpod
# Prompts for remaining options
```

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

| Flag               | Description                               | Default            |
| ------------------ | ----------------------------------------- | ------------------ |
| `--state <choice>` | State management (provider/riverpod/bloc) | Interactive prompt |
| `--theme`          | Include theme scaffolding                 | Interactive prompt |
| `--localization`   | Include l10n setup                        | Interactive prompt |
| `--env`            | Include environment config                | Interactive prompt |
| `--api`            | Include API client                        | Interactive prompt |
| `--tests`          | Include test scaffolding                  | Interactive prompt |
| `-h, --help`       | Show help                                 | -                  |
| `-v, --version`    | Show version                              | -                  |

---

## 📋 blueprint.yaml

Every generated project includes a `blueprint.yaml` manifest:

```yaml
version: 1
app_name: my_app
platform: mobile
state_management: provider
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

### Phase 1: MVP ✅ (Current)

- [x] CLI tool setup
- [x] Basic project generator
- [x] Provider template
- [x] Theme + routing boilerplate

### Phase 2: Multi-Template Support

- [ ] Riverpod template
- [ ] Bloc template
- [ ] Localization integration
- [ ] API client scaffolding

### Phase 3: Feature Generation

- [ ] `flutter_blueprint add feature <name>`
- [ ] Interactive upgrades via `blueprint.yaml`
- [ ] Unit + widget test templates

### Phase 4: Advanced Features

- [ ] Plugin ecosystem (auth, firebase, analytics)
- [ ] GitHub Actions CI scaffold
- [ ] Web/desktop platform support
- [ ] Blueprint dashboard (web-based config UI)

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
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/flutter_blueprint/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/flutter_blueprint/discussions)

---

## 🌟 Show Your Support

If this project helped you, please ⭐ the repository and share it with others!

---

**Made with ❤️ for the Flutter community**
