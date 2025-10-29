# Contributing to flutter_blueprint

First off, thank you for considering contributing to flutter_blueprint! 🎉

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this standard.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and expected**
- **Include screenshots if applicable**
- **Include your environment details** (OS, Dart/Flutter version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List examples of how the enhancement would work**

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the existing code style** - run `dart analyze` and `dart format`
3. **Write clear commit messages** following conventional commits format
4. **Add tests** if you're adding new functionality
5. **Update documentation** (README.md, CHANGELOG.md) if needed
6. **Ensure all tests pass** before submitting

#### Development Setup

```bash
# Clone your fork
git clone https://github.com/chirag640/flutter_blueprint.git
cd flutter_blueprint

# Install dependencies
dart pub get

# Run tests
dart test

# Run analyzer
dart analyze

# Format code
dart format .
```

#### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**

```
feat(cli): add riverpod template support
fix(generator): handle special characters in app names
docs(readme): update installation instructions
```

### Adding New Templates

When adding a new state management template:

1. Create a new file in `lib/src/templates/` (e.g., `riverpod_mobile_template.dart`)
2. Implement the `TemplateBundle buildRiverpodMobileBundle()` function
3. Update `BlueprintGenerator._selectBundle()` to handle the new template
4. Add tests in `test/templates/`
5. Update documentation

### Code Style Guidelines

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused
- Use `const` constructors where possible
- Avoid deeply nested code

### Testing Guidelines

- Write unit tests for all new functionality
- Aim for high test coverage
- Test edge cases and error conditions
- Use descriptive test names

```dart
test('should generate project with custom app name', () {
  // Arrange
  final config = BlueprintConfig(appName: 'my_custom_app', ...);

  // Act
  final result = await generator.generate(config, '/tmp/test');

  // Assert
  expect(result.success, isTrue);
});
```

## Project Structure

```
flutter_blueprint/
├── bin/
│   └── flutter_blueprint.dart       # CLI entry point
├── lib/
│   ├── flutter_blueprint.dart       # Public API
│   └── src/
│       ├── cli/                     # CLI argument parsing
│       ├── config/                  # Configuration models
│       ├── generator/               # Project generation logic
│       ├── prompts/                 # Interactive prompts
│       ├── templates/               # Code templates
│       └── utils/                   # Utilities
└── test/                            # Tests mirror lib/ structure
```

## Release Process

Releases are managed by maintainers:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with release notes
3. Create a git tag: `git tag v0.1.0`
4. Push tag: `git push origin v0.1.0`
5. Publish to pub.dev: `dart pub publish`

## Questions?

Feel free to ask questions by:

- Opening a [GitHub Discussion](https://github.com/chirag640/flutter_blueprint/discussions)
- Opening an issue with the `question` label

Thank you for contributing! 🚀
