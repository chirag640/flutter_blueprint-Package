## 0.5.0 (Current)

### 🚀 NEW: CI/CD Scaffold Generation - Production-Ready from Day One!

**What's New:**

- ✅ **Automated CI/CD configuration** - Generate GitHub Actions, GitLab CI, or Azure Pipelines workflows
- ✅ **Multi-platform builds** - Automated Android and iOS builds
- ✅ **Code quality gates** - Automatic analyze, format check, and test execution
- ✅ **Coverage reporting** - Built-in code coverage tracking and reporting
- ✅ **Deployment ready** - Firebase App Distribution integration templates
- ✅ **Interactive wizard support** - CI provider selection in wizard mode

**Usage:**

```bash
# Create project with GitHub Actions
flutter_blueprint init my_app --ci github

# Create project with GitLab CI
flutter_blueprint init my_app --state riverpod --ci gitlab

# Create project with Azure Pipelines
flutter_blueprint init my_app --state bloc --ci azure

# Interactive mode (wizard includes CI selection)
flutter_blueprint init
```

**Generated CI Configurations:**

| Provider   | File                       | Features                                      |
| ---------- | -------------------------- | --------------------------------------------- |
| **GitHub** | `.github/workflows/ci.yml` | Multi-job pipeline, coverage, artifacts       |
| **GitLab** | `.gitlab-ci.yml`           | Multi-stage pipeline, coverage reports        |
| **Azure**  | `azure-pipelines.yml`      | Multi-stage pipeline, test results, artifacts |

**Pipeline Stages:**

1. **Analyze** - `flutter analyze` + `dart format` verification
2. **Test** - Unit tests with coverage reporting
3. **Build Android** - APK generation with artifact upload
4. **Build iOS** - IPA generation (with codesign instructions)

**Benefits:**

- **Zero setup time** - CI/CD ready on first commit
- **Best practices** - Industry-standard workflows included
- **Extensible** - Easy to add deployment stages
- **Professional** - Production-grade configurations

**Impact:**

- **Immediate CI/CD** for all new projects
- **Consistent quality gates** across all features
- **Faster feedback loops** with automated testing
- **Deployment ready** with Firebase templates

---

## 0.3.0-dev.1

### 🔥 NEW: Incremental Feature Generation - The Killer Feature!

**What's New:**

- ✅ **`add feature` command** - Generate features incrementally in existing projects
- ✅ **Smart state management detection** - Automatically generates Provider/Riverpod/Bloc files based on `blueprint.yaml`
- ✅ **Clean architecture scaffolding** - Creates data/domain/presentation layers
- ✅ **Automatic router integration** - Injects routes into `app_router.dart`
- ✅ **Selective layer generation** - Choose which layers to generate with flags
- ✅ **API integration support** - Include remote data sources with `--api`
- ✅ **Router skip option** - Use `--no-router` to skip automatic router updates

**Usage:**

```bash
# Full feature with all layers
flutter_blueprint add feature auth

# Only presentation layer
flutter_blueprint add feature settings --presentation --no-data --no-domain

# With API integration
flutter_blueprint add feature products --api

# Skip router update
flutter_blueprint add feature profile --no-router
```

**Generated Structure (example: auth):**

```
lib/features/auth/
├── data/
│   ├── models/auth_model.dart
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart  # if --api
│   │   └── auth_local_data_source.dart
│   └── repositories/auth_repository_impl.dart
├── domain/
│   ├── entities/auth_entity.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/
│       ├── get_auth_list.dart
│       ├── get_auth_by_id.dart
│       ├── create_auth.dart
│       ├── update_auth.dart
│       └── delete_auth.dart
└── presentation/
    ├── pages/auth_page.dart
    ├── widgets/auth_list_item.dart
    └── [provider|riverpod|bloc]/  # Adapts to project's state management
```

**State Management Adaptation:**

| Project Type | Generated Files                                                 |
| ------------ | --------------------------------------------------------------- |
| **Provider** | `feature_provider.dart` (ChangeNotifier)                        |
| **Riverpod** | `feature_provider.dart` (StateNotifier + sealed states)         |
| **Bloc**     | `feature_event.dart`, `feature_state.dart`, `feature_bloc.dart` |

**Flags:**

- `--data` / `--no-data` - Generate/skip data layer
- `--domain` / `--no-domain` - Generate/skip domain layer
- `--presentation` / `--no-presentation` - Generate/skip presentation layer
- `--api` - Include remote data source (Dio-based)
- `--router` / `--no-router` - Update/skip app_router.dart modification

**Impact:**

- **10-20x faster** feature development
- **Perfect consistency** across all features
- **Zero boilerplate** - one command does everything
- **Production-ready** code generation

**Validation:**

- ✅ Tested with Provider, Riverpod, and Bloc templates
- ✅ Automatic router update working
- ✅ Generated 13-15 files per feature
- ✅ Clean architecture maintained

---

## 0.2.0-dev.3

### 🚀 NEW: Multi-Template State Management Support

**What's New:**

- ✅ **Riverpod Template** - Compile-time safe state management
- ✅ Multi-template architecture (Provider + Riverpod, Bloc coming soon)
- ✅ Template selection via `--state` flag
- ✅ All templates share professional core modules

**Riverpod-Specific Features:**

- **ProviderScope** wrapper in main.dart for dependency injection
- **ConsumerWidget** pattern for reactive UI
- **StateNotifier** with immutable state classes and `copyWith()`
- **Global providers** in `core/providers/app_providers.dart`
- **Compile-time safety** - catch errors before runtime
- **Better testability** - providers easily mocked with `ProviderContainer`
- **Automatic disposal** - no memory leaks

**Usage:**

```bash
# Generate Riverpod project
flutter_blueprint init my_app --state riverpod --theme --api

# Or use wizard (select Riverpod from menu)
flutter_blueprint init
```

**Template Comparison:**

| Feature                  | Provider              | Riverpod                    |
| ------------------------ | --------------------- | --------------------------- |
| **State Class**          | ChangeNotifier        | StateNotifier<State>        |
| **UI Widget**            | Consumer<T>           | ConsumerWidget + WidgetRef  |
| **State Updates**        | notifyListeners()     | state = state.copyWith(...) |
| **Dependency Injection** | MultiProvider wrapper | ProviderScope + ref.watch() |
| **Compile-Time Safety**  | ❌                    | ✅                          |
| **Generated Files**      | 43 files              | 42 files                    |

**Dependencies:**

- `flutter_riverpod: ^2.5.1` - Riverpod state management

**Validation:**

- ✅ Generated 42 files with professional architecture
- ✅ 0 analyzer errors
- ✅ 9/9 tests passing
- ✅ Same core modules as Provider (API, Logger, Storage, Validators, etc.)

**What's Next:** Bloc template coming soon!

---

## 0.2.0-dev.2

### ✨ NEW: Interactive Wizard Mode

**Beautiful CLI Experience:**

- ✅ Guided step-by-step project setup
- ✅ Arrow key navigation for state management selection
- ✅ Multi-select checkboxes for features (spacebar to toggle)
- ✅ Configuration preview before generation
- ✅ Smart validation (prevents Dart reserved words)
- ✅ Package name validation (lowercase with underscores)
- ✅ Emoji-rich, colorful UI powered by `interact` package

**Usage:**

```bash
# Launch wizard
flutter_blueprint init

# Or use quick mode
flutter_blueprint init my_app --state provider
```

**Dependencies Added:**

- `interact: ^2.2.0` - Beautiful CLI interactions

---

## 0.2.0-dev.1

### 🚀 MAJOR UPGRADE: Enterprise-Grade Professional Template

**BREAKING**: Generated projects now include **43 files** (up from 19) with production-ready patterns.

#### 🆕 New Professional Modules

**Error Handling System** 🚨

- ✅ 9 custom exception classes (FetchDataException, UnauthorizedException, etc.)
- ✅ Clean architecture Failures with Equatable
- ✅ Type-safe error handling throughout

**Production API Client** 🌐

- ✅ Enhanced Dio client with generic methods (GET/POST/PUT/DELETE)
- ✅ AuthInterceptor - auto-add JWT tokens
- ✅ RetryInterceptor - exponential backoff retry logic
- ✅ Enhanced LoggerInterceptor with structured logging
- ✅ ApiResponse<T> generic wrapper

**Professional Logger** 📝

- ✅ AppLogger with 5 levels (debug/info/warning/error/success)
- ✅ Tag-based filtering for modules
- ✅ Emoji-prefixed output for better readability
- ✅ Stack trace support for errors

**Storage Layers** 💾

- ✅ LocalStorage - SharedPreferences wrapper with type safety
- ✅ SecureStorage - FlutterSecureStorage wrapper for tokens
- ✅ Singleton pattern implementation
- ✅ Built-in error handling and logging

**Form Validators** ✅

- ✅ 7 production-ready validators (email, password, phone, required, minLength, maxLength, numeric)
- ✅ Consistent error messages
- ✅ 8 unit tests with 100% coverage
- ✅ Easy to extend for custom validators

**Reusable Widget Library** 🧩

- ✅ LoadingIndicator - customizable loading spinner
- ✅ ErrorView - error display with retry button
- ✅ EmptyState - empty list placeholders
- ✅ CustomButton - button with loading state
- ✅ CustomTextField - styled text field with validators

**Extension Methods** 🔧

- ✅ String extensions (capitalize, isValidEmail, isBlank, removeWhitespace)
- ✅ DateTime extensions (formattedDate, isToday, isYesterday)
- ✅ BuildContext extensions (theme, colors, width, showSnackBar)

**Constants & Configuration** 📋

- ✅ AppConstants - timeouts, storage keys, pagination defaults
- ✅ ApiEndpoints - centralized API route management
- ✅ RouteNames - route constants
- ✅ AppColors - custom color palette

**Network Monitoring** 📡

- ✅ NetworkInfo - connectivity status checks
- ✅ Real-time connectivity stream
- ✅ Works on all platforms

**Enhanced State Management** 🎯

- ✅ Professional Provider patterns with loading/error states
- ✅ Separated UI components (pages/widgets/providers)
- ✅ Consumer pattern with proper state handling
- ✅ Example feature with best practices

**Test Infrastructure** 🧪

- ✅ Validator unit tests (8 tests, all passing)
- ✅ Test helpers for widget testing
- ✅ MockTail integration for testing
- ✅ CI/CD ready structure

#### 📦 New Dependencies

- `shared_preferences: ^2.2.3` - Local storage
- `flutter_secure_storage: ^9.2.2` - Secure token storage
- `equatable: ^2.0.5` - Value comparison for Failures
- `connectivity_plus: ^6.0.5` - Network monitoring
- `pretty_dio_logger: ^1.4.0` - API logging

#### 📈 Metrics

- **Generated Files**: 19 → **43** (+126%)
- **Core Modules**: 5 → **10** (+100%)
- **Reusable Widgets**: 0 → **5**
- **API Interceptors**: 1 → **3** (+200%)
- **Lines of Code**: ~800 → **~2,500+** (+200%)
- **Analyzer Errors**: **0**
- **Test Coverage**: **100%** (validators)

#### 💡 Impact

**For Developers:**

- Save 2-3 days of boilerplate setup
- Professional patterns from day one
- Focus on features, not infrastructure

**For Teams:**

- Consistent codebase across projects
- Reduced onboarding time
- Faster MVP delivery

**For Enterprises:**

- Enterprise-grade architecture
- Security patterns included
- Logging and monitoring ready
- Scalable structure

---

## 0.1.0-dev.1

### Initial Development Release

**Core Features:**

- ✅ CLI-based project generation with `flutter_blueprint init`
- ✅ Interactive and flag-based configuration modes
- ✅ Provider state management template (mobile platform)
- ✅ Modular architecture with core/features folder structure
- ✅ Optional theme scaffolding (light/dark mode support)
- ✅ Optional localization setup (ARB files + intl)
- ✅ Optional environment configuration (.env support)
- ✅ Optional API client setup (Dio + interceptors)
- ✅ Optional test scaffolding (widget tests + mocktail)
- ✅ Auto-routing system with route guards
- ✅ Blueprint manifest (`blueprint.yaml`) for project tracking

**Template Structure:**

- Clean architecture with `core/`, `features/`, and `app/` layers
- Type-safe configuration management
- Production-ready folder organization
- Best-practice imports and dependency injection

**What's Next:**

- Riverpod and Bloc templates
- Feature generation command (`flutter_blueprint add feature`)
- Web and desktop platform support
- Plugin system for optional modules
- CI/CD scaffold generation
