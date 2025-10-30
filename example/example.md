# flutter_blueprint Example

This example demonstrates how to use the `flutter_blueprint` CLI tool to generate a production-ready Flutter project.

## Basic Usage

### Installation

First, activate the package globally:

```bash
dart pub global activate flutter_blueprint
```

### Create a Simple Project

Generate a basic Flutter project with Provider state management:

```bash
flutter_blueprint init my_app
```

This launches an interactive wizard that guides you through the configuration.

### Create a Multi-Platform Project

Generate a project that supports mobile, web, and desktop:

```bash
flutter_blueprint init my_awesome_app \
  --state provider \
  --platforms all \
  --theme \
  --localization \
  --env \
  --api \
  --tests \
  --ci github
```

### Create with Riverpod State Management

```bash
flutter_blueprint init my_riverpod_app \
  --state riverpod \
  --platforms mobile,web \
  --theme \
  --api \
  --tests
```

### Add a New Feature

After creating a project, add new features incrementally:

```bash
cd my_app
flutter_blueprint add feature authentication --api
```

## Generated Project Structure

```
my_app/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   └── app.dart
│   ├── core/
│   │   ├── api/
│   │   ├── config/
│   │   ├── routing/
│   │   ├── theme/
│   │   └── utils/
│   └── features/
│       └── home/
├── test/
├── assets/
└── pubspec.yaml
```

## Running the Generated Project

```bash
cd my_app
flutter pub get
flutter run
```

For web:

```bash
flutter run -d chrome
```

For desktop:

```bash
flutter run -d windows  # or macos, linux
```

## Running Tests

```bash
cd my_app
flutter test
```

## More Examples

See [EXAMPLES.md](../EXAMPLES.md) for comprehensive examples including:

- E-commerce mobile apps
- Multi-platform SaaS applications
- Desktop dashboards
- Progressive Web Apps (PWA)
- CI/CD integration examples
