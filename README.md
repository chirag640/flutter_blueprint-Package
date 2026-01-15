# 🎯 flutter_blueprint

**Enterprise-grade Flutter app scaffolding CLI** — generates production-ready Flutter projects with **43+ professional files**, complete architecture, and best practices.

[![Pub Version](https://img.shields.io/pub/v/flutter_blueprint)](https://pub.dev/packages/flutter_blueprint)
[![Pub Points](https://img.shields.io/pub/points/flutter_blueprint)](https://pub.dev/packages/flutter_blueprint/score)
[![Pub Likes](https://img.shields.io/pub/likes/flutter_blueprint)](https://pub.dev/packages/flutter_blueprint)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter 3.38+](https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart 3.5+](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart)](https://dart.dev)

> **📱 Note:** CLI runs on desktop (Windows/Linux/macOS) to **generate** Flutter projects that support **all platforms** (Android, iOS, Web, Desktop).

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

| Category | Features |
|----------|----------|
| **Architecture** | Clean architecture, 43+ files, feature-based structure |
| **State Management** | Provider, Riverpod, or Bloc |
| **API Layer** | Dio + Auth/Retry/Logger interceptors, Universal API Configurator |
| **Storage** | LocalStorage + SecureStorage + optional Hive caching |
| **UI Components** | Theme system, reusable widgets, Material 3 |
| **DevOps** | GitHub Actions, GitLab CI, Azure Pipelines |
| **Extras** | Pagination, Analytics, Security utilities, i18n |

## 🛠️ CLI Commands

### `init` - Create New Project

```bash
flutter_blueprint init <app_name> [options]
```

| Flag | Description |
|------|-------------|
| `--state <choice>` | State management: `provider`, `riverpod`, `bloc` |
| `--platforms <list>` | Target: `mobile`, `web`, `desktop`, `all` |
| `--ci <provider>` | CI/CD: `github`, `gitlab`, `azure` |
| `--api` | Include API client (prompts for backend type) |
| `--theme` | Include theme system |
| `--env` | Include environment config |
| `--tests` | Include test scaffolding |
| `--hive` | Include Hive offline caching |
| `--pagination` | Include pagination support |
| `--analytics <provider>` | Analytics: `firebase`, `sentry` |
| `--security <level>` | Security: `basic`, `standard`, `enterprise` |

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

## 🤝 Team Collaboration

Share configurations across your team:

```bash
# Import team config
flutter_blueprint share import ./company_standard.yaml

# Create project from config
flutter_blueprint init my_app --from-config company_standard
```

## 📚 Documentation

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
