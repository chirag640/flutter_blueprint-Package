## 1.2.0 (2025-11-18) - Security Best Practices

### 🔒 NEW: Security Best Practices

- ✅ Added `securityLevel` enum to `BlueprintConfig` with four levels: `none`, `basic`, `standard`, `enterprise`.
- ✅ Comprehensive security template generators:
  - **CertificatePinner**: SSL/TLS certificate pinning for HTTPS (enterprise)
  - **DeviceSecurityChecker**: Root/jailbreak detection (standard+)
  - **BiometricAuth**: Biometric authentication wrapper (standard+)
  - **ApiKeyManager**: API key obfuscation and secure storage (enterprise)
  - **EncryptedStorage**: Enhanced encrypted storage with AES (all levels)
  - **ScreenshotProtection**: Prevent screenshots on sensitive screens (enterprise)
  - **NetworkSecurityConfig**: HTTPS validation and domain allowlisting (all levels)
  - **SecurityInterceptor**: Security headers for HTTP requests (all levels)
  - **SecureHttpClient**: Secure Dio client with certificate pinning (enterprise)
- ✅ Added `--security <level>` CLI option (none, basic, standard, enterprise).
- ✅ Integrated into interactive wizard with security level selection.
- ✅ Conditional dependency management based on security level.
- ✅ Integration across all mobile templates (Provider, Riverpod, Bloc).
- ✅ Comprehensive test suite with 36 passing tests (374 total tests passing).

**Usage Examples:**

```bash
# Basic security (encrypted storage + network security)
flutter_blueprint init my_app --security basic

# Standard security (+ biometric auth + root detection)
flutter_blueprint init my_app --security standard

# Enterprise security (all features + certificate pinning)
flutter_blueprint init my_app --security enterprise --state bloc

# Interactive wizard (includes security option)
flutter_blueprint init
```

**Generated Structure:**

```
lib/core/security/
├── certificate_pinner.dart             # SSL pinning (enterprise)
├── device_security_checker.dart        # Root/jailbreak detection (standard+)
├── biometric_auth.dart                 # Biometric auth (standard+)
├── api_key_manager.dart                # API key obfuscation (enterprise)
├── encrypted_storage.dart              # AES encryption (all levels)
├── screenshot_protection.dart          # Screenshot prevention (enterprise)
├── network_security_config.dart        # HTTPS validation (all levels)
├── security_interceptor.dart           # Security headers (all levels)
└── secure_http_client.dart             # Secure HTTP client (enterprise)
```

**Security Levels:**

| Feature                  | Basic | Standard | Enterprise |
| ------------------------ | ----- | -------- | ---------- |
| Encrypted Storage        | ✅    | ✅       | ✅         |
| Network Security Config  | ✅    | ✅       | ✅         |
| Security Headers         | ✅    | ✅       | ✅         |
| Root/Jailbreak Detection | ❌    | ✅       | ✅         |
| Biometric Authentication | ❌    | ✅       | ✅         |
| Certificate Pinning      | ❌    | ❌       | ✅         |
| API Key Obfuscation      | ❌    | ❌       | ✅         |
| Screenshot Protection    | ❌    | ❌       | ✅         |

**Dependencies Added:**

- Basic+: `flutter_secure_storage`, `flutter_jailbreak_detection`, `device_info_plus`
- Standard+: `local_auth`
- Enterprise: `encrypt`, `crypto`, `pointycastle`, `flutter_windowmanager`

---

## 1.1.0 (2025-11-18) - Analytics & Crash Reporting

### ✨ NEW: Analytics & Crash Reporting Support

- ✅ Added `includeAnalytics` boolean and `analyticsProvider` enum to `BlueprintConfig` for analytics integration.
- ✅ New `AnalyticsProvider` enum supporting: `firebase`, `sentry`, and `none`.
- ✅ Comprehensive analytics template generators:
  - **AnalyticsService**: Abstract interface with unified API for all providers
  - **FirebaseAnalyticsService**: Complete Firebase Analytics + Crashlytics + Performance implementation
  - **SentryAnalyticsService**: Full Sentry integration with breadcrumbs and transactions
  - **AnalyticsEvents**: Pre-defined event constants for consistency
  - **ErrorBoundary**: Widget wrapper for automatic error reporting
- ✅ Added `--analytics <provider>` CLI option (firebase, sentry, none).
- ✅ Integrated into interactive wizard with provider selection.
- ✅ Automatic dependency management for Firebase and Sentry packages.
- ✅ Integration across all mobile templates (Provider, Riverpod, Bloc).
- ✅ Comprehensive test suite with 23 passing tests.

**Usage Examples:**

```bash
# Firebase Analytics
flutter_blueprint init my_app --analytics firebase --state bloc

# Sentry
flutter_blueprint init my_app --analytics sentry --state riverpod

# Interactive wizard (includes analytics option)
flutter_blueprint init
```

**Generated Structure:**

```
lib/core/analytics/
├── analytics_service.dart              # Abstract interface
├── firebase_analytics_service.dart     # Firebase implementation
├── sentry_service.dart                 # Sentry implementation
└── analytics_events.dart               # Event constants

lib/core/widgets/
└── error_boundary.dart                 # Error catching widget
```

**Key Features:**

- **Provider flexibility**: Choose between Firebase or Sentry
- **Unified API**: Same interface regardless of provider
- **Auto error tracking**: ErrorBoundary widget catches and reports errors
- **Performance monitoring**: Built-in trace support
- **Event tracking**: Pre-defined constants for common events
- **User identification**: Set user ID and properties
- **Crash reporting**: Automatic crash detection and reporting

**Dependencies Added:**

- Firebase: `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`, `package_info_plus`
- Sentry: `sentry_flutter`, `package_info_plus`

---

## 1.0.5 (2025-11-18) - Pagination Feature

### ✨ NEW: Pagination Support

- ✅ Added `includePagination` boolean to `BlueprintConfig` to toggle pagination support when generating projects.
- ✅ New pagination template generators: `PaginationController`, `PaginatedListView`, and `SkeletonLoader` (generated into `lib/core/pagination/`).
  - **PaginationController**: Generic controller with multiple states (initial, loading, loadingMore, success, failure, empty), automatic pagination logic, error handling with retry, and pull-to-refresh support.
  - **PaginatedListView**: Production-ready widget with infinite scroll detection, pull-to-refresh, customizable builders (empty, error, loading, loadingMore, separator), and scroll threshold configuration.
  - **SkeletonLoader**: Animated skeleton screens with shimmer effects, pre-built list tiles, and automatic theme adaptation (light/dark mode).
- ✅ Added `--pagination` CLI flag for easy enablement via command line.
- ✅ Integrated into interactive wizard with "Pagination support (infinite scroll + skeleton loaders)" multi-select option.
- ✅ Integrated pagination templates across Provider, Riverpod, and Bloc mobile templates with conditional generation.
- ✅ Added comprehensive tests (`test/src/templates/pagination_integration_test.dart`) covering config serialization, template generation, and content verification.
- ✅ Updated documentation with usage examples and implementation details.

**Usage Examples:**

```bash
# Generate project with pagination support
flutter_blueprint init my_app --state riverpod --api --pagination

# Interactive wizard mode (select from features list)
flutter_blueprint init

# Programmatic configuration
BlueprintConfig(
  appName: 'my_app',
  stateManagement: StateManagement.provider,
  includePagination: true,
)
```

**Generated Structure:**

```
lib/core/pagination/
├── pagination_controller.dart    # Generic pagination state management
├── paginated_list_view.dart      # Infinite scroll widget with pull-to-refresh
└── skeleton_loader.dart           # Animated loading skeletons
```

**Key Features:**

- **Type-safe pagination**: Generic `PaginationController<T>` works with any data type
- **Automatic infinite scroll**: Triggers at 90% scroll position by default (configurable)
- **Pull-to-refresh**: Built-in `RefreshIndicator` support
- **Comprehensive error handling**: Retry logic for both initial load and load more
- **Customizable UI**: All builders are optional and can be overridden
- **Production-ready**: Includes loading states, empty states, error states, and skeleton loaders
- **Smooth animations**: Shimmer effect for skeleton loaders with theme support

**Benefits:**

- **Save hours** of pagination implementation time
- **Consistent UX** across all list screens
- **Professional loading states** with animated skeletons
- **Built-in best practices** for infinite scroll and error handling
- **Zero boilerplate** - ready to use with your API

**Impact:**

- **Tests**: 305 → **315 tests** (+10 pagination tests, all passing)
- **Generated files**: Up to 3 additional files when pagination is enabled
- **Production-ready**: Tested with all three state management options

See the generated `pagination_controller.dart`, `paginated_list_view.dart`, and `skeleton_loader.dart` files for complete implementation details and usage examples.

---

## 0.9.4 (2025-11-03) - Quality of Life Improvements

### ✨ NEW: Hive Offline Caching

- ✅ Added `includeHive` boolean to `BlueprintConfig` to toggle Hive support when generating projects.
- ✅ New Hive template generators: `HiveDatabase`, `CacheManager`, and `SyncManager` (generated into `lib/core/storage/`) to provide offline persistence, configurable cache strategies (TTL/LRU/size), and an offline sync queue with retry logic.
- ✅ Integrated Hive templates across Provider, Riverpod, and Bloc starter templates; pubspec dependencies and `main.dart` initialization are added conditionally when `includeHive: true`.
- ✅ Added comprehensive tests (`test/src/templates/hive_integration_test.dart`) and a helper script `tools/create_with_hive.dart` which generates a sample app (`generated_hive_app`) to verify outputs.
- ✅ Documentation added: `HIVE_IMPLEMENTATION.md` (full implementation notes, usage examples, and architecture benefits).
- ⚠️ Note: The CLI `--hive` flag is planned (not added to the public CLI flags yet). Use programmatic `BlueprintConfig(includeHive: true)` or the generation script to enable Hive for now.

See `HIVE_IMPLEMENTATION.md` at the repo root for complete implementation details and examples.

### ✨ NEW: Automated Windows Installer

- ✅ Introduced `install.ps1` script for Windows users to automate installation and PATH setup.
- ✅ Streamlined installation process from multiple manual steps to a single PowerShell command.
- ✅ Automatically adds the Dart pub cache `bin` directory to the user's PATH environment variable.
- ✅ Updated `README.md` to guide Windows users to the new automated installation method.

### 🚀 NEW: Automatic Update Checker

- ✅ Added a non-intrusive, automatic update checker to the CLI.
- ✅ Notifies users when a new version of `flutter_blueprint` is available on pub.dev.
- ✅ Caches the check for 24 hours to ensure minimal performance impact.
- ✅ Displays a clear, actionable message with the command to update.

## 0.8.3 (2025-11-01) - Bug Fixes & Improvements

### 🐛 FIX: Windows Compatibility

- ✅ Fixed issues with Windows compatibility for Flutter commands
- ✅ Improved handling of file paths and environment variables on Windows
- ✅ Ensured `flutter pub get` and `flutter create` commands run correctly on Windows

### 🛠️ IMPROVEMENT: Asset Configuration

- ✅ Improved asset configuration handling for multi-platform projects
- ✅ Streamlined asset paths and folder structures

## 0.8.0 (2025-11-01) - Collaboration & Team Features + Performance Optimization

### 🤝 NEW: Collaboration & Team Features

**Shared Blueprint Configurations - Share Standards Across Your Team!**

- ✅ **Shared configuration system** - Create and share team-wide project templates
- ✅ **Configuration repository** - Centralized management of shared configs
- ✅ **Share command** - Complete CLI for managing shared configurations
- ✅ **Import/Export** - Share configs via files or repository
- ✅ **Validation** - Ensure configurations meet requirements before use
- ✅ **Version control** - Track configuration changes over time

**Share Command Features:**

```bash
# List available configurations
flutter_blueprint share list

# Import a configuration
flutter_blueprint share import ./company_standard.yaml

# Export a configuration
flutter_blueprint share export company_standard ./exported.yaml

# Validate a configuration file
flutter_blueprint share validate ./config.yaml

# Use a shared configuration
flutter_blueprint init my_app --from-config company_standard
```

**Configuration Structure:**

- **Team Standards**: Define state management, platforms, CI/CD provider
- **Code Style**: Line length, naming conventions, quote preferences
- **Architecture**: Pattern enforcement, feature structure, layer separation
- **Required Packages**: Ensure critical dependencies are included
- **Custom Metadata**: Add team-specific information

**Example Configurations Included:**

- `company_standard.yaml` - Enterprise best practices with Bloc + full stack
- `startup_template.yaml` - Lightweight MVP config with Provider
- `enterprise_template.yaml` - Full-featured config for large-scale apps

**Benefits:**

- **Instant consistency** across all team projects
- **Faster onboarding** with pre-configured templates
- **Enforce standards** at project creation time
- **Share best practices** through configuration
- **Reduce setup time** from hours to seconds

**Validation:**

- ✅ 62 tests for collaboration features
- ✅ All tests passing (266 total)
- ✅ Full end-to-end testing with example configs
- ✅ Configuration validation working correctly

### ⚡ NEW: Performance & Optimization Features

**Performance Profiling & Optimization Tools!**

- ✅ **Performance monitoring setup** - Track app metrics automatically
- ✅ **Bundle size analyzer** - Understand what's adding to app size
- ✅ **Asset optimization** - Find unused and large assets
- ✅ **Tree-shaking analysis** - Get code size reduction recommendations
- ✅ **Performance config** - Configure monitoring in blueprint.yaml
- ✅ **Automated tracking** - App startup, screen loads, API calls, frames

**Performance Analyzer:**

```bash
# Analyze performance setup
flutter_blueprint analyze --performance

# Analyze bundle size
flutter_blueprint analyze --size

# Optimize assets
flutter_blueprint optimize --assets

# Tree-shaking analysis
flutter_blueprint optimize --tree-shake
```

**Performance Tracking Features:**

- **App Startup Time**: Measure time to first frame
- **Screen Load Time**: Track navigation performance
- **API Response Time**: Monitor network requests
- **Frame Render Time**: Detect frame drops and jank
- **Custom Metrics**: Add your own performance markers

**Bundle Size Analysis:**

- Code size breakdown by package
- Asset size analysis
- Recommendations for optimization
- Tree-shaking opportunities

**Benefits:**

- **Catch regressions early** with automated monitoring
- **Optimize bundle size** for faster downloads
- **Improve user experience** with performance insights
- **CI/CD integration** for performance testing

**Validation:**

- ✅ Performance analyzer with comprehensive tests
- ✅ Bundle size analysis working
- ✅ Asset optimization detection
- ✅ Tree-shaking recommendations

### 🔧 NEW: Auto-Refactoring Tool

**Automated Code Improvements & Migrations!**

- ✅ **Auto-refactoring command** - Apply code improvements automatically
- ✅ **Add caching layer** - Inject caching with one command
- ✅ **Add offline support** - Enable offline functionality
- ✅ **State management migration** - Migrate between Provider/Riverpod/Bloc
- ✅ **Error handling** - Add comprehensive error handling
- ✅ **Logging infrastructure** - Add professional logging
- ✅ **Performance optimization** - Apply performance best practices
- ✅ **Testing infrastructure** - Add test scaffolding
- ✅ **Dry-run mode** - Preview changes before applying
- ✅ **Backup creation** - Automatic backups before refactoring

**Refactor Command:**

```bash
# Add caching layer
flutter_blueprint refactor --add-caching

# Add offline support
flutter_blueprint refactor --add-offline-support

# Migrate state management
flutter_blueprint refactor --migrate-to-riverpod
flutter_blueprint refactor --migrate-to-bloc

# Add error handling
flutter_blueprint refactor --add-error-handling

# Add logging
flutter_blueprint refactor --add-logging

# Optimize performance
flutter_blueprint refactor --optimize-performance

# Add testing infrastructure
flutter_blueprint refactor --add-testing

# Preview changes (dry-run)
flutter_blueprint refactor --add-caching --dry-run
```

**Refactoring Types:**

1. **Add Caching** - Repository pattern with cache layer
2. **Add Offline Support** - Local persistence + sync logic
3. **Migrate to Riverpod** - Convert Provider → Riverpod
4. **Migrate to Bloc** - Convert Provider/Riverpod → Bloc
5. **Add Error Handling** - Comprehensive try-catch patterns
6. **Add Logging** - Professional logger integration
7. **Optimize Performance** - Performance best practices
8. **Add Testing** - Test scaffolding and examples

**Benefits:**

- **Save hours** of manual refactoring
- **Reduce errors** with automated changes
- **Maintain consistency** across the codebase
- **Easy migrations** between patterns

**Validation:**

- ✅ Refactoring tool with comprehensive logic
- ✅ Dry-run mode working
- ✅ Backup creation functional
- ✅ All refactoring types implemented

### 🎨 NEW: Project Templates

**Pre-configured Templates for Common App Types!**

- ✅ **E-commerce template** - Product catalog, cart, checkout
- ✅ **Social media template** - Feed, profiles, messaging
- ✅ **Fitness tracker template** - Workouts, progress tracking
- ✅ **Finance app template** - Transactions, budgets, reports
- ✅ **Food delivery template** - Menu, orders, delivery tracking
- ✅ **Chat app template** - Real-time messaging, groups

**Usage:**

```bash
flutter_blueprint init my_store --template ecommerce
flutter_blueprint init my_social --template social-media
flutter_blueprint init my_fitness --template fitness-tracker
flutter_blueprint init my_budget --template finance-app
flutter_blueprint init my_food --template food-delivery
flutter_blueprint init my_chat --template chat-app
```

### 📦 NEW: Dependency Management Utilities

**Smart Package Management!**

- ✅ **Dependency manager** - Fetch latest versions from pub.dev
- ✅ **Version resolution** - Automatic version compatibility checks
- ✅ **Update notifications** - Alert when packages are outdated
- ✅ **Latest deps flag** - Use `--latest-deps` for newest versions

**Usage:**

```bash
flutter_blueprint init my_app --latest-deps
```

### ✅ NEW: Input Validation Utilities

**Professional Form Validation!**

- ✅ **Comprehensive validators** - Email, phone, URL, credit card
- ✅ **Custom validators** - Easy to extend
- ✅ **Error messages** - User-friendly validation messages
- ✅ **100% test coverage** - All validators thoroughly tested

**Generated Validators:**

- Required field validation
- Email validation (RFC 5322 compliant)
- Phone number validation (international formats)
- URL validation
- Min/max length validation
- Numeric validation
- Custom regex patterns
- Credit card validation

### 📊 Impact

**Code Generation:**

- **Generated files**: 43 → **60+** (with all features)
- **Test coverage**: 204 tests → **266 tests** (+30%)
- **New commands**: 3 new major commands (share, optimize, refactor)
- **Example configs**: 3 production-ready templates included

**Developer Productivity:**

- **Configuration sharing**: Instant team standardization
- **Performance insights**: Built-in monitoring and analysis
- **Automated refactoring**: Hours → Minutes
- **Template library**: Start with proven patterns

**Quality Improvements:**

- **100% test pass rate**: All 266 tests passing
- **Zero analyzer errors**: Clean codebase
- **Documentation**: 4 new comprehensive docs
- **Production-ready**: Enterprise-grade features

---

## 0.6.1 (2025-10-31) - Platform Support & Auto-Publish Fixes

## 0.7.0 (2025-10-31)

### 🔄 Auto-generated Release

**Changes:**

- Automatic minor version bump
- Triggered by: feat: Update CHANGELOG, README, and pubspec.yaml for platform support and auto-publishing improvements
- Commit: c12fa177ca25ab9afa038400463870f7bfd47f17

### 🔧 Bug Fixes

**Platform Support Declaration:**

- ✅ Fixed incorrect platform support warnings by explicitly declaring CLI platforms (Windows, Linux, macOS)
- ✅ Removed `CliRunner` export from main library to prevent mobile platform conflicts
- ✅ Updated package description to clarify this is a CLI tool that **generates** apps for all platforms
- ✅ Added clear documentation that CLI runs on desktop, but generated projects support Android/iOS/Web/Desktop

**Auto-Publishing Reliability:**

- ✅ Fixed auto-publish workflow not triggering by using PAT instead of GITHUB_TOKEN
- ✅ Added `persist-credentials: false` to checkout step
- ✅ Added configurable `REPO_PAT` secret support with graceful fallback
- ✅ Updated README with setup instructions for reliable auto-publishing

### 📝 Documentation

- ✅ Added prominent note in README clarifying CLI vs generated project platforms
- ✅ Added PAT setup guide for GitHub Actions publishing
- ✅ Updated pubspec.yaml description for better clarity

## 0.6.0 (2025-10-30)

### 🔄 Auto-generated Release

**Changes:**

- Automatic minor version bump
- Triggered by: feat: Implement fully automated CI/CD with version bumping, publishing, and quality checks
- Commit: d0f2de8cb067a561ddaeeedc35ccc62f2ffb5979

### 🤖 Fully Automated Release Pipeline

**GitHub Actions Workflows:**

- ✅ **Auto-versioning workflow** - Automatically bumps version based on commit messages
  - `feat:` → minor bump (0.5.1 → 0.6.0)
  - `fix:` or other → patch bump (0.5.1 → 0.5.2)
  - `feat!:` or `BREAKING CHANGE:` → major bump (0.5.1 → 1.0.0)
  - Automatically updates `pubspec.yaml` and `CHANGELOG.md`
  - Creates and pushes git tags
  - Skip with `[skip-version]` in commit message
- ✅ **Publish workflow** - Publishes to pub.dev when tags are pushed
  - Uses GitHub OIDC for secure authentication (no secrets needed!)
  - Verifies version matches tag
  - Runs tests and analysis before publishing
  - Creates GitHub Release with auto-generated notes
- ✅ **Quality checks workflow** - Runs on every PR and push
  - Code analysis with `dart analyze --fatal-infos`
  - Format checking
  - Full test suite with coverage
  - Publish dry-run validation

**Documentation:**

- ✅ **Added comprehensive automation guide** - `docs/AUTOMATED_PUBLISHING.md`
  - Complete setup instructions for pub.dev OIDC
  - GitHub Actions configuration guide
  - Usage examples with conventional commits
  - Troubleshooting section
- ✅ **Updated README** - Added automation section with badges
  - Workflow status badges
  - Quick start guide for automated releases
  - Setup instructions

**Benefits:**

- **Zero-touch releases** - Push to main and everything happens automatically
- **No manual version management** - Smart commit-based versioning
- **No secrets to manage** - Uses GitHub OIDC tokens
- **Full audit trail** - All releases tracked in GitHub Actions
- **Quality guaranteed** - Tests must pass before publish

**Impact:**

- **Release time:** Manual 10 minutes → Automated 30 seconds
- **Human error:** Eliminated version mismatches and forgotten changelog updates
- **Security:** No long-lived credentials, temporary OIDC tokens only
- **Developer experience:** Simple `git push` triggers entire pipeline

---

## 0.5.2 (2025-10-30)

### Email Support Update

- Updated email support to use the new support email address: chaudharychirag640@gmail.com

## 0.5.1 (2025-10-30) - Pub.dev Quality Improvements

### 🎯 Pub.dev Score Improvements (140 → 160 points expected)

**Code Quality Fixes:**

- ✅ **Fixed all 90 analyzer issues** - Package now has zero lints, warnings, or errors
  - Added curly braces to if statements for better code safety
  - Converted string concatenation to interpolation
  - Removed unnecessary braces in string interpolations (86 fixes)
  - Removed unnecessary string escapes (42 fixes)
- ✅ **Added comprehensive API documentation** - 30%+ public API coverage
  - Added dartdoc comments to `BlueprintConfig` class and all public members
  - Documented `BlueprintManifest` and `BlueprintManifestStore` APIs
  - Added detailed documentation to `BlueprintGenerator` class
  - Included parameter descriptions and usage examples

**Package Structure:**

- ✅ **Added example directory** - Created `example/example.md` with comprehensive usage examples
  - Basic CLI usage examples
  - Multi-platform project generation
  - Feature addition workflow
  - Generated project structure overview
  - Running and testing instructions

**Publishing Ready:**

- ✅ **Added publishing scripts** - `scripts/publish.ps1` and `scripts/publish.sh`
- ✅ **Updated README** - Added "Publishing to pub.dev" section with step-by-step instructions
- ✅ **Clean pubspec.yaml** - Removed incorrect plugin block, bumped version to 0.5.0

**Impact:**

- **Pub points:** 140/160 → 160/160 (expected)
- **Analyzer issues:** 90 → 0
- **API documentation:** 30.6% → 40%+ coverage
- **Package score:** Production-ready for pub.dev

---

## Unreleased (2025-10-30)

### 📝 Documentation updates

- Updated documentation files to reflect recent generator and template changes:
  - `EXAMPLES.md`: clarified CLI usage for `--platforms`, documented that the generator now attempts to run `flutter pub get` automatically after generation (with a manual fallback), and added multi-platform usage examples.
  - `README.md`: replaced older responsive library recommendations with `flutter_screenutil` (example dependency), added notes that generated responsive utilities use `flutter_screenutil` + `LayoutBuilder`, and clarified CI multi-platform behavior in the CI section.
- CI Templates: noted in docs that generated CI configs now include web and desktop jobs where relevant.
- Verification: unit tests were run locally and passed after doc updates.

---

## 0.5.0 (Current)

### � NEW: Multi-Platform Support - Build Once, Run Everywhere!

**What's New:**

- ✅ **Multi-platform project generation** - Mobile, Web, AND Desktop in one codebase
- ✅ **Universal templates** - Automatically adapts to selected platforms
- ✅ **Responsive layouts** - Breakpoints utility for mobile/tablet/desktop
- ✅ **Adaptive navigation** - Bottom nav (mobile) → Rail (tablet) → Drawer (desktop)
- ✅ **Platform-specific entry points** - main_mobile.dart, main_web.dart, main_desktop.dart
- ✅ **Smart dependency management** - Only includes packages needed for selected platforms
- ✅ **Interactive multi-select** - Checkbox UI in wizard for platform selection
- ✅ **Platform detection utilities** - PlatformInfo helper class

**Usage:**

```bash
# Mobile + Web (multi-platform)
flutter_blueprint init my_app --platforms mobile,web --state bloc

# All platforms (universal app)
flutter_blueprint init my_app --platforms all --state riverpod

# Desktop only
flutter_blueprint init my_desktop_app --platforms desktop --state provider

# Interactive mode (wizard includes platform multi-select)
flutter_blueprint init
```

**Platform Options:**

| Flag                     | Description                            |
| ------------------------ | -------------------------------------- |
| `--platforms mobile`     | iOS & Android only (default)           |
| `--platforms web`        | Web application only                   |
| `--platforms desktop`    | Windows, macOS, Linux                  |
| `--platforms mobile,web` | Multi-platform (mobile + web)          |
| `--platforms all`        | Universal app (mobile + web + desktop) |

**Generated Structure (Multi-Platform):**

```
lib/
├── main.dart                   # Universal entry point (routes by platform)
├── main_mobile.dart            # Mobile-specific initialization
├── main_web.dart               # Web initialization (URL strategy)
├── main_desktop.dart           # Desktop initialization (window manager)
├── core/
│   ├── responsive/
│   │   ├── breakpoints.dart           # Mobile/Tablet/Desktop breakpoints
│   │   ├── responsive_layout.dart     # Responsive widget
│   │   ├── adaptive_scaffold.dart     # Adaptive navigation
│   │   └── responsive_spacing.dart    # Responsive padding/spacing
│   └── utils/
│       └── platform_info.dart         # Platform detection utilities
├── web/
│   ├── index.html                     # PWA-ready HTML
│   └── manifest.json                  # Web app manifest
└── windows/macos/linux/               # Desktop platform folders
```

**Responsive Features:**

- **Breakpoints**: `Breakpoints.isMobile()`, `isTablet()`, `isDesktop()`
- **ResponsiveLayout**: Adapts UI to screen size automatically
- **AdaptiveScaffold**: Navigation adapts (bottom nav → rail → drawer)
- **ResponsiveSpacing**: Responsive padding and grid columns

**Platform-Specific Dependencies:**

- **Web**: `url_strategy` (clean URLs), PWA support
- **Desktop**: `window_manager` (window control), `path_provider`
- **All**: `flutter_adaptive_scaffold`, `responsive_framework`

**Benefits:**

- **Single codebase** for all platforms
- **Responsive by default** with adaptive layouts
- **Clean separation** with platform-specific entry points
- **Smart dependencies** - no bloat
- **PWA-ready** web apps
- **Professional window management** for desktop

**Impact:**

- **10x faster** multi-platform development
- **Consistent UI** across all platforms with responsive design
- **Production-ready** responsive components included
- **Easy maintenance** with shared business logic

**Validation:**

- ✅ 40 tests passing (including multi-platform tests)
- ✅ 0 compile errors
- ✅ Tested on mobile, web, and desktop platforms
- ✅ Responsive layouts validated on all screen sizes

---

## 0.5.0-ci

### 🚀 CI/CD Scaffold Generation - Production-Ready from Day One!

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
