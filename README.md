# 🎯 flutter_blueprint

**Enterprise-grade Flutter app scaffolding CLI** — generates production-ready Flutter projects with **43+ professional files**, complete architecture, and best practices.

[![Pub Version](https://img.shields.io/pub/v/flutter_blueprint)](https://pub.dev/packages/flutter_blueprint)
[![Pub Points](https://img.shields.io/pub/points/flutter_blueprint)](https://pub.dev/packages/flutter_blueprint/score)
[![Pub Likes](https://img.shields.io/pub/likes/flutter_blueprint)](https://pub.dev/packages/flutter_blueprint)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter 3.38+](https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart 3.5+](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart)](https://dart.dev)

> **📱 Note:** CLI runs on desktop (Windows/Linux/macOS) to **generate** Flutter projects that support **all platforms** (Android, iOS, Web, Desktop).

## 🎉 What's New in v2.0

**Major architectural improvements and production-ready features:**

| Enhancement                  | Description                                                   |
| ---------------------------- | ------------------------------------------------------------- |
| 🔥 **Complete Features**     | Auth, Profile, Settings with full UI - zero placeholders      |
| 🏠 **Smart Home Screen**     | API-connected with pagination, caching, pull-to-refresh       |
| 🔐 **Full Authentication**   | Login, Register, Token management, Auto-login, Secure storage |
| 👤 **Profile Management**    | View, Edit profile, Avatar upload, Offline-first caching      |
| ⚙️ **Settings System**       | Theme switcher, Notifications, Biometrics, Account management |
| 🔒 **Enterprise Security**   | OWASP-compliant headers, certificate pinning, SSRF prevention |
| 🚦 **Rate Limiting**         | Client-side protection (60 req/min per endpoint)              |
| 💾 **Smart Caching**         | SharedPreferences + JSON serialization with error recovery    |
| 🏗️ **Architecture Refactor** | Result types, command pattern, DI container                   |
| ✅ **Testing**               | 334 tests passing, 62.88% coverage                            |

See [CHANGELOG.md](./CHANGELOG.md) for complete details.

## 🚀 Quick Start

### Installation

```bash
# Windows (PowerShell)
iex (irm 'https://raw.githubusercontent.com/chirag640/flutter_blueprint-Package/main/scripts/install.ps1')

# macOS / Linux
dart pub global activate flutter_blueprint
```

### Create a Project

```bash
# Interactive wizard (recommended)
flutter_blueprint init

# Quick mode with options
flutter_blueprint init my_app --state riverpod --api --theme --tests
```

## ✨ Key Features

| Category              | Features                                                                                    |
| --------------------- | ------------------------------------------------------------------------------------------- |
| **Architecture**      | Clean architecture, 60+ files, feature-based structure                                      |
| **Complete Features** | Home (API + pagination), Auth (login/register), Profile (view/edit), Settings (theme/prefs) |
| **State Management**  | Provider, Riverpod, BLoC, or GetX                                                           |
| **GraphQL**           | Optional GraphQL layer — graphql_flutter or Ferry client                                    |
| **API Layer**         | Dio + Auth/Retry/Logger/Security/RateLimit interceptors, Universal API Configurator         |
| **Storage**           | LocalStorage + SecureStorage + Hive caching with JSON serialization                         |
| **Security**          | OWASP headers, error sanitization, SSRF prevention, certificate pinning, rate limiting      |
| **UI Components**     | Theme system, reusable widgets, Material 3                                                  |
| **DevOps**            | GitHub Actions, GitLab CI, Azure Pipelines                                                  |
| **Extras**            | Pagination, Analytics, Security utilities, i18n                                             |

## 🎯 Production-Ready Features

When you generate a project with `--api` flag, you get **complete working features** with zero placeholders:

### 🏠 Home Feature

- **API Integration**: Real data from JSONPlaceholder demo API
- **Pagination**: Load more with infinite scroll
- **Caching**: 1-hour TTL with offline-first pattern
- **UI**: Pull-to-refresh, loading states, error handling

### 🔐 Authentication Feature (with `--api`)

- **Login & Register**: Complete forms with validation
- **Token Management**: JWT access + refresh tokens, secure storage
- **Auto-login**: Checks auth status on app startup
- **UI**: Beautiful login/register pages, error messages, loading states

### 👤 Profile Feature (with `--api`)

- **View Profile**: Display user info with avatar
- **Edit Profile**: Update name, bio, phone, location
- **Avatar Upload**: Image picker integration (demo mode)
- **Caching**: Offline-first with 1-hour TTL

### ⚙️ Settings Feature (always included)

- **Theme Switcher**: Light, Dark, System modes
- **Notifications**: Toggle push notifications
- **Biometrics**: Enable/disable biometric login
- **Account**: Profile link, Logout (if auth enabled)
- **About**: Version, Terms, Privacy Policy
- **Data Management**: Clear all cached data

## 🔒 Security Features (v2.0+)

flutter_blueprint generates enterprise-grade security out of the box:

### 🛡️ Security Headers

- **X-Content-Type-Options**: Prevents MIME-sniffing attacks
- **X-Frame-Options**: Clickjacking protection (DENY)
- **X-XSS-Protection**: Legacy XSS protection layer
- **Strict-Transport-Security**: Forces HTTPS (1 year + subdomains)
- **Cache-Control**: Prevents sensitive data caching

### 🔐 Certificate Pinning

Prevent MITM attacks with SHA-256 fingerprint validation:

```dart
final dio = ApiClient(
  baseUrl: 'https://api.example.com',
  certificatePins: ['sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='],
).dio;
```

### 🚦 Rate Limiting

Client-side protection with 60 requests/minute per endpoint:

- Automatic retry-after calculation
- Rolling window tracking
- Prevents API abuse

### 🧹 Error Sanitization

Security interceptor automatically removes:

- File paths (Windows/Unix)
- IP addresses (IPv4/IPv6)
- Long tokens (32+ characters)
- SSRF prevention (blocks localhost in production)

### ✅ Security Validation

Built-in security audit helper:

```dart
final result = SecurityConfig.checkSecurityConfiguration(dio);
print('Security checks: ${result.passed} passed, ${result.issues.length} issues');
```

## 🛠️ CLI Commands

### `init` - Create New Project

```bash
flutter_blueprint init <app_name> [options]
```

| Flag                     | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `--state <choice>`       | State management: `provider`, `riverpod`, `bloc`, `getx`     |
| `--graphql-client`       | GraphQL client: `none` (default), `graphql_flutter`, `ferry` |
| `--platforms <list>`     | Target: `mobile`, `web`, `desktop`, `all`                    |
| `--ci <provider>`        | CI/CD: `github`, `gitlab`, `azure`                           |
| `--api`                  | Include API client (prompts for backend type)                |
| `--theme`                | Include theme system                                         |
| `--env`                  | Include environment config                                   |
| `--tests`                | Include test scaffolding                                     |
| `--hive`                 | Include Hive offline caching                                 |
| `--pagination`           | Include pagination support                                   |
| `--analytics <provider>` | Analytics: `firebase`, `sentry`                              |
| `--security <level>`     | Security: `basic`, `standard`, `enterprise`                  |

### 🔌 API Backend Presets

When `--api` is enabled, choose from built-in presets:

- **Modern REST** - HTTP 200 + JSON data
- **Legacy .NET** - success: true/false pattern
- **Laravel** - data wrapper, message field
- **Django REST** - results array, detail errors
- **Custom** - manual configuration

### `add feature` - Add Features to Existing Project

```bash
flutter_blueprint add feature <name> [--api] [--no-data] [--no-domain]
```

## 📁 Generated Structure

```
my_app/
├── lib/
│   ├── main.dart
│   ├── app/app.dart
│   ├── core/
│   │   ├── api/          # API client + interceptors
│   │   ├── config/       # App config + env loader
│   │   ├── errors/       # Exceptions + failures
│   │   ├── routing/      # Router + guards
│   │   ├── storage/      # Local + secure storage
│   │   ├── theme/        # Colors, typography, themes
│   │   ├── utils/        # Logger, validators, extensions
│   │   └── widgets/      # Reusable UI components
│   └── features/         # Feature modules
├── test/                 # Test scaffolding
└── pubspec.yaml
```

## 💾 Data Layer Features (v2.0+)

### Smart Caching

Production-ready cache implementation with SharedPreferences:

```dart
// Auto-generated cache methods
final items = await localDataSource.getCached();  // Returns List<T> or null
await localDataSource.cache(items);              // JSON serialization
await localDataSource.clearCache();              // Clear cache
```

- Automatic JSON serialization/deserialization
- Error recovery (auto-clears corrupted cache)
- Type-safe operations

### Auth Token Management

Flexible token handling with callback-based interceptors:

```dart
final dio = ApiClient(
  baseUrl: 'https://api.example.com',
  getToken: () async => await storage.getToken(),
  refreshToken: () async => await authService.refresh(),
).dio;
```

- Automatic 401 handling with token refresh
- Request retry after refresh
- Works with any auth strategy (OAuth, JWT, custom)

### Offline Sync

Hive-based offline support with API synchronization:

- Queue changes while offline
- Auto-sync when connection restored
- Conflict resolution strategies

## 🤝 Team Collaboration

Share configurations across your team:

```bash
# Import team config
flutter_blueprint share import ./company_standard.yaml

# Create project from config
flutter_blueprint init my_app --from-config company_standard
```

## 📚 Documentation

- [Architecture Guide](./ARCHITECTURE.md) - Deep dive into v2.0 architecture
- [Example Usage](./example/example.dart) - Programmatic API examples
- [Contributing Guide](./CONTRIBUTING.md) - How to contribute
- [Changelog](./CHANGELOG.md) - Version history

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 💬 Support

- 📧 Email: chaudharychirag640@gmail.com
- 🐛 [GitHub Issues](https://github.com/chirag640/flutter_blueprint-Package/issues)
- 💬 [Discussions](https://github.com/chirag640/flutter_blueprint-Package/discussions)

---

**Made with ❤️ for the Flutter community** ⭐
