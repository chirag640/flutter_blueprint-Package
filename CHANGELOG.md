## 0.2.0-dev.2 (Current)

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
