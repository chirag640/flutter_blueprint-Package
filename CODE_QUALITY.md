# Code Quality & Maintainability Features

This guide covers the code quality analysis and automatic refactoring capabilities built into flutter_blueprint.

## Table of Contents

1. [Code Quality Analysis](#code-quality-analysis)
2. [Automatic Refactoring](#automatic-refactoring)
3. [API Reference](#api-reference)
4. [Best Practices](#best-practices)
5. [Troubleshooting](#troubleshooting)

---

## Code Quality Analysis

The built-in code quality analyzer helps you maintain high code standards by detecting common issues and anti-patterns in your Flutter code.

### Basic Usage

#### Analyze Current Project

```bash
flutter_blueprint analyze
```

#### Analyze Specific Project

```bash
flutter_blueprint analyze ./my_project
```

### Analysis Modes

#### 1. Standard Mode (Default)

Basic analysis with warnings for common issues:

```bash
flutter_blueprint analyze
```

**Checks:**

- ✅ Magic numbers (hardcoded numeric literals)
- ✅ Missing error handling in async functions
- ✅ Undocumented public APIs (info level)

#### 2. Strict Mode

All checks become errors, requiring zero issues to pass:

```bash
flutter_blueprint analyze --strict
```

**Additional behavior:**

- Undocumented APIs are errors (not info)
- State management anti-patterns checked
- Potential memory leaks detected
- Stricter enforcement of all rules

#### 3. Performance Mode

Includes performance-related checks:

```bash
flutter_blueprint analyze --performance
```

**Additional checks:**

- ✅ Missing const constructors
- ✅ Inefficient build methods
- ✅ Object creation in build methods
- ✅ Non-const lists/maps

#### 4. Accessibility Mode

Includes accessibility checks:

```bash
flutter_blueprint analyze --accessibility
```

**Additional checks:**

- ✅ Images without semanticLabel
- ✅ IconButtons without tooltip
- ✅ Interactive elements without labels

#### 5. All Checks

Combine all modes for comprehensive analysis:

```bash
flutter_blueprint analyze --strict --performance --accessibility
```

### What Gets Analyzed

The analyzer checks all Dart files in your `lib/` directory, excluding:

- Generated files (_.g.dart, _.freezed.dart)
- Files in `test/` directory

### Issue Types

#### 1. Magic Numbers

**What:** Hardcoded numeric literals in code
**Why:** Makes code harder to understand and maintain
**Severity:** Warning

```dart
// ❌ Bad - Magic number
final padding = 16.0;
if (items.length > 10) { ... }

// ✅ Good - Named constants
const defaultPadding = 16.0;
const maxItemsToShow = 10;
```

**Acceptable numbers:** 0, 1, 2, 10, 100, 0.0, 1.0

#### 2. Missing Error Handling

**What:** Async functions without try-catch blocks
**Why:** Unhandled exceptions crash the app
**Severity:** Warning

```dart
// ❌ Bad - No error handling
Future<void> loadData() async {
  final data = await api.fetchData();
  setState(() => _data = data);
}

// ✅ Good - Proper error handling
Future<void> loadData() async {
  try {
    final data = await api.fetchData();
    setState(() => _data = data);
  } catch (e) {
    _logger.error('Failed to load data', e);
    _showError('Could not load data');
  }
}
```

#### 3. Undocumented Public APIs

**What:** Public classes/methods without documentation comments
**Why:** Makes code harder to understand for other developers
**Severity:** Info (Error in strict mode)

```dart
// ❌ Bad - No documentation
class UserRepository {
  Future<User> getUser(String id) async { ... }
}

// ✅ Good - Well documented
/// Repository for managing user data.
class UserRepository {
  /// Fetches a user by their unique ID.
  ///
  /// Returns the [User] object if found, throws [UserNotFoundException]
  /// if the user doesn't exist.
  Future<User> getUser(String id) async { ... }
}
```

#### 4. Missing Const Constructors

**What:** Widgets that could be const but aren't
**Why:** Hurts performance (unnecessary rebuilds)
**Severity:** Info (Performance mode only)

```dart
// ❌ Bad - Missing const
return Text('Hello World');
return Icon(Icons.home);

// ✅ Good - Using const
return const Text('Hello World');
return const Icon(Icons.home);
```

#### 5. Inefficient Build Methods

**What:** Creating objects inside build methods
**Why:** Objects recreated on every rebuild
**Severity:** Warning (Performance mode only)

```dart
// ❌ Bad - List created on every build
Widget build(BuildContext context) {
  return ListView(
    children: [
      Text('Item 1'),
      Text('Item 2'),
    ],
  );
}

// ✅ Good - Const list
Widget build(BuildContext context) {
  return ListView(
    children: const [
      Text('Item 1'),
      Text('Item 2'),
    ],
  );
}
```

#### 6. Missing Semantic Labels

**What:** Images/IconButtons without accessibility labels
**Why:** Screen readers can't describe the element
**Severity:** Warning (Accessibility mode only)

```dart
// ❌ Bad - No semantic label
Image.network('https://example.com/logo.png')
IconButton(icon: Icon(Icons.settings), onPressed: _openSettings)

// ✅ Good - With semantic labels
Image.network(
  'https://example.com/logo.png',
  semanticLabel: 'Company logo',
)
IconButton(
  icon: Icon(Icons.settings),
  onPressed: _openSettings,
  tooltip: 'Open settings',
)
```

#### 7. State Management Anti-Patterns

**What:** Calling setState incorrectly
**Why:** Causes infinite loops or unexpected behavior
**Severity:** Error (Strict mode only)

```dart
// ❌ Bad - setState in initState
@override
void initState() {
  super.initState();
  setState(() {
    _counter = 0;  // DON'T DO THIS
  });
}

// ✅ Good - Direct assignment in initState
@override
void initState() {
  super.initState();
  _counter = 0;  // Direct assignment
}

// ❌ Bad - setState in build
@override
Widget build(BuildContext context) {
  setState(() { ... });  // NEVER DO THIS
  return Container();
}
```

#### 8. Potential Memory Leaks

**What:** StreamControllers not closed in dispose
**Why:** Memory leaks and potential crashes
**Severity:** Error (Strict mode only)

```dart
// ❌ Bad - StreamController not disposed
class MyWidget extends StatefulWidget {
  final _controller = StreamController<int>();

  @override
  Widget build(BuildContext context) { ... }
  // Missing dispose!
}

// ✅ Good - Properly disposed
class MyWidget extends StatefulWidget {
  final _controller = StreamController<int>();

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { ... }
}
```

### Understanding the Report

After analysis completes, you'll see a report like this:

```
📊 Analysis Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Files analyzed: 42
Analysis time: 1234ms

Issues found:
  ❌ Errors: 0
  ⚠️  Warnings: 5
  ℹ️  Info: 12
  Total: 17

📋 Issues by type:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Magic Number: 3
⚠️  lib/src/widgets/custom_button.dart:45
   Magic Number: Magic number 16.0 found. Consider using a named constant.
   💡 Suggestion: Create a const variable: const myValue = 16.0;

⚠️  lib/src/screens/home_screen.dart:78
   Magic Number: Magic number 24.0 found. Consider using a named constant.
   💡 Suggestion: Create a const variable: const myValue = 24.0;

   ... and 1 more

Undocumented API: 12
ℹ️  lib/src/services/api_service.dart:23
   Undocumented API: Public method/function lacks documentation.
   💡 Suggestion: Add a doc comment describing the function.

   ... and 11 more

✅ All checks passed! Your code looks great.
```

### Exit Codes

- **0:** Analysis passed (no errors based on mode)
- **1:** Analysis found issues that need attention

### CI/CD Integration

Use analysis in your CI/CD pipeline:

```yaml
# GitHub Actions
- name: Code Quality Analysis
  run: flutter_blueprint analyze --strict --performance --accessibility
```

```yaml
# GitLab CI
code_quality:
  script:
    - flutter_blueprint analyze --strict
```

---

## Automatic Refactoring

Automatically evolve your codebase with safe, reversible refactorings.

### Available Refactorings

#### 1. Add Caching Layer

Add automatic caching with TTL support:

```bash
flutter_blueprint refactor --add-caching
```

**What it does:**

- Creates `CacheService` with TTL support
- Creates `CacheEntry` model
- Updates repositories to use caching
- Adds `shared_preferences` dependency

**Files created:**

- `lib/core/cache/cache_service.dart`
- `lib/core/cache/cache_entry.dart`

**Files modified:**

- All repository files in `lib/data/repositories/`
- `pubspec.yaml`

#### 2. Add Offline Support

Enable offline-first functionality:

```bash
flutter_blueprint refactor --add-offline-support
```

**What it does:**

- Creates local SQLite database
- Adds sync service for online/offline sync
- Adds connectivity checker
- Adds required dependencies

**Files created:**

- `lib/core/database/app_database.dart`
- `lib/core/sync/sync_service.dart`
- `lib/core/network/connectivity_checker.dart`

**Dependencies added:**

- `sqflite: ^2.3.0`
- `connectivity_plus: ^5.0.0`
- `path_provider: ^2.1.0`

**⚠️ Warning:** Remember to handle data conflicts during sync!

#### 3. Migrate to Riverpod

Convert from Provider to Riverpod:

```bash
flutter_blueprint refactor --migrate-to-riverpod
```

**What it does:**

- Converts ChangeNotifier providers to Riverpod
- Removes `provider` dependency
- Adds `flutter_riverpod` and `riverpod_annotation`
- Updates all provider files

**Next steps:**

```bash
# Generate Riverpod code
dart run build_runner build

# Update main.dart
# Replace MultiProvider with ProviderScope
```

#### 4. Migrate to BLoC

Add BLoC pattern infrastructure:

```bash
flutter_blueprint refactor --migrate-to-bloc
```

**What it does:**

- Creates BLoC directory structure
- Adds sample BLoC with events/states
- Adds `flutter_bloc` and `equatable` dependencies

**Files created:**

- `lib/presentation/bloc/sample_bloc.dart`

**Note:** Manually convert existing state management to use BLoC pattern.

#### 5. Add Error Handling

Add comprehensive error handling infrastructure:

```bash
flutter_blueprint refactor --add-error-handling
```

**What it does:**

- Creates centralized error handler
- Creates custom exception types
- Provides error handling patterns

**Files created:**

- `lib/core/error/error_handler.dart`
- `lib/core/error/exceptions.dart`

#### 6. Add Logging

Add structured logging system:

```bash
flutter_blueprint refactor --add-logging
```

**What it does:**

- Creates application logger
- Provides logging utilities
- Ready for analytics integration

**Files created:**

- `lib/core/logging/app_logger.dart`

#### 7. Optimize Performance

Apply performance optimizations:

```bash
flutter_blueprint refactor --optimize-performance
```

**What it does:**

- Adds const keywords where possible
- Adds lazy loading patterns
- Optimizes widget rebuilds

**Files modified:**

- All Dart files in `lib/`

#### 8. Add Testing Infrastructure

Set up testing utilities:

```bash
flutter_blueprint refactor --add-testing
```

**What it does:**

- Creates test helpers
- Creates mock data utilities
- Sets up test infrastructure

**Files created:**

- `test/helpers/test_helpers.dart`
- `test/mocks/mock_data.dart`

### Refactoring Options

#### Dry Run (Preview Changes)

See what would be changed without modifying files:

```bash
flutter_blueprint refactor --add-caching --dry-run
```

**Use cases:**

- Preview changes before applying
- Understand what will be modified
- Verify refactoring scope

#### Skip Backup

Don't create backup files (faster but riskier):

```bash
flutter_blueprint refactor --add-caching --no-backup
```

**⚠️ Warning:** Only use when you have version control!

#### Skip Tests

Don't run tests after refactoring:

```bash
flutter_blueprint refactor --add-caching --no-run-tests
```

**Use case:** When you want to review changes before testing

#### Skip Formatting

Don't format code after refactoring:

```bash
flutter_blueprint refactor --add-caching --no-format
```

### Refactoring Workflow

Recommended workflow for safe refactoring:

1. **Preview changes:**

   ```bash
   flutter_blueprint refactor --add-caching --dry-run
   ```

2. **Commit current state:**

   ```bash
   git add .
   git commit -m "Before adding caching layer"
   ```

3. **Apply refactoring:**

   ```bash
   flutter_blueprint refactor --add-caching
   ```

4. **Review changes:**

   ```bash
   git diff
   ```

5. **Install dependencies:**

   ```bash
   flutter pub get
   ```

6. **Run tests:**

   ```bash
   flutter test
   ```

7. **Commit refactoring:**
   ```bash
   git add .
   git commit -m "Add caching layer"
   ```

### Understanding Refactoring Results

After refactoring completes, you'll see a report:

```
✅ Refactoring completed successfully!

Summary:
  📝 Files modified: 8
  ➕ Files created: 2
  🔧 Changes applied: 10

📝 Modified files:
  • lib/data/repositories/user_repository.dart
  • lib/data/repositories/product_repository.dart
  • pubspec.yaml
  ...

➕ Created files:
  • lib/core/cache/cache_service.dart
  • lib/core/cache/cache_entry.dart

🔧 Changes applied:
  Create in lib/core/cache/cache_service.dart
    Added CacheService with TTL support

  Create in lib/core/cache/cache_entry.dart
    Added CacheEntry model

  Modify in lib/data/repositories/user_repository.dart
    Added caching to repository methods
  ...

💡 Next steps:
  1. Review the changes
  2. Run: flutter pub get
  3. Run: flutter test
  4. Commit the changes
```

---

## API Reference

### Programmatic Usage

You can use the code quality and refactoring tools programmatically in your Dart code:

#### Code Quality Analyzer

```dart
import 'package:flutter_blueprint/flutter_blueprint.dart';

Future<void> analyzeMyProject() async {
  final analyzer = CodeQualityAnalyzer(
    strictMode: true,
    checkPerformance: true,
    checkAccessibility: true,
  );

  final report = await analyzer.analyze('./my_project');

  print(report.summary);

  // Check specific issues
  final magicNumbers = report.getByType(IssueType.magicNumber);
  print('Found ${magicNumbers.length} magic numbers');

  // Check by file
  final fileIssues = report.getByFile('lib/main.dart');
  print('Issues in main.dart: ${fileIssues.length}');

  // Check if passed
  if (report.passed(maxSeverity: IssueSeverity.warning)) {
    print('All checks passed!');
  }
}
```

#### Auto Refactoring Tool

```dart
import 'package:flutter_blueprint/flutter_blueprint.dart';

Future<void> refactorMyProject() async {
  final config = RefactoringConfig(
    dryRun: false,
    createBackup: true,
    runTests: true,
    formatCode: true,
  );

  final tool = AutoRefactoringTool(config: config);

  final result = await tool.refactor(
    './my_project',
    RefactoringType.addCaching,
  );

  if (result.success) {
    print('Refactoring successful!');
    print('Modified ${result.filesModified.length} files');
    print('Created ${result.filesCreated.length} files');
  } else {
    print('Refactoring failed: ${result.error}');
  }
}
```

### Classes

#### `CodeQualityAnalyzer`

Analyzes Flutter/Dart code for quality issues.

**Constructor:**

```dart
CodeQualityAnalyzer({
  Logger? logger,
  bool strictMode = false,
  bool checkPerformance = false,
  bool checkAccessibility = false,
})
```

**Methods:**

- `Future<AnalysisReport> analyze(String projectPath)` - Analyzes the project

#### `AnalysisReport`

Contains analysis results.

**Properties:**

- `List<QualityIssue> issues` - All found issues
- `int filesAnalyzed` - Number of files analyzed
- `int analysisTimeMs` - Analysis duration in milliseconds
- `List<QualityIssue> errors` - Error-level issues
- `List<QualityIssue> warnings` - Warning-level issues
- `List<QualityIssue> infos` - Info-level issues
- `String summary` - Human-readable summary

**Methods:**

- `List<QualityIssue> getByType(IssueType type)` - Get issues by type
- `List<QualityIssue> getByFile(String filePath)` - Get issues for a file
- `bool passed({IssueSeverity maxSeverity})` - Check if analysis passed

#### `QualityIssue`

Represents a single code quality issue.

**Properties:**

- `IssueType type` - Type of issue
- `IssueSeverity severity` - How severe the issue is
- `String message` - Description of the issue
- `String filePath` - File where issue was found
- `int line` - Line number
- `int? column` - Optional column number
- `String? suggestion` - Optional fix suggestion

#### `AutoRefactoringTool`

Handles automatic refactoring of Flutter projects.

**Constructor:**

```dart
AutoRefactoringTool({
  Logger? logger,
  RefactoringConfig config = const RefactoringConfig(),
})
```

**Methods:**

- `Future<RefactoringResult> refactor(String projectPath, RefactoringType type)` - Performs refactoring

#### `RefactoringResult`

Contains refactoring results.

**Properties:**

- `bool success` - Whether refactoring succeeded
- `List<String> filesModified` - List of modified files
- `List<String> filesCreated` - List of created files
- `List<RefactoringChange> changes` - List of changes made
- `String? error` - Error message if failed
- `List<String> warnings` - Warning messages
- `int totalFiles` - Total files affected
- `String summary` - Human-readable summary

#### `RefactoringConfig`

Configuration for refactoring operations.

**Properties:**

- `bool dryRun` - Preview changes without modifying (default: false)
- `bool preserveComments` - Keep existing comments (default: true)
- `bool createBackup` - Create backup files (default: true)
- `bool runTests` - Run tests after refactoring (default: true)
- `bool formatCode` - Format code after refactoring (default: true)

### Enums

#### `IssueType`

- `magicNumber` - Hardcoded numeric literal
- `missingErrorHandling` - Async function without try-catch
- `undocumentedApi` - Public API without documentation
- `missingConst` - Widget that could be const
- `noSemanticLabel` - Missing accessibility label
- `inefficientBuild` - Inefficient build method
- `stateManagementAntiPattern` - Incorrect setState usage
- `securityVulnerability` - Security issue
- `memoryLeak` - Potential memory leak
- `deprecatedApi` - Using deprecated API

#### `IssueSeverity`

- `error` - Must be fixed
- `warning` - Should be fixed
- `info` - Nice to fix

#### `RefactoringType`

- `addCaching` - Add caching layer
- `addOfflineSupport` - Add offline support
- `migrateToRiverpod` - Migrate to Riverpod
- `migrateToBloc` - Migrate to BLoC
- `addErrorHandling` - Add error handling
- `addLogging` - Add logging
- `optimizePerformance` - Optimize performance
- `addTesting` - Add testing infrastructure

---

## Best Practices

### Analysis Best Practices

1. **Run analysis regularly:**

   - Before committing code
   - In CI/CD pipeline
   - After major refactoring

2. **Start with standard mode:**

   - Fix errors and warnings first
   - Then enable strict mode
   - Add performance/accessibility checks gradually

3. **Use in development:**

   - Catch issues early
   - Learn best practices
   - Maintain code quality

4. **Integrate with CI/CD:**

   ```yaml
   # Fail build on errors
   - run: flutter_blueprint analyze --strict

   # Or just report issues
   - run: flutter_blueprint analyze || true
   ```

### Refactoring Best Practices

1. **Always use version control:**

   - Commit before refactoring
   - Review changes after
   - Easy to revert if needed

2. **Start with dry-run:**

   - Preview changes first
   - Understand the scope
   - Verify it's what you want

3. **One refactoring at a time:**

   - Easier to review
   - Easier to debug
   - Easier to revert

4. **Test after refactoring:**

   - Run all tests
   - Manual testing for critical flows
   - Check for regressions

5. **Review generated code:**
   - Understand what changed
   - Customize as needed
   - Learn the patterns

---

## Troubleshooting

### Analysis Issues

#### "No Dart files found"

**Problem:** Project path is incorrect or no lib/ directory

**Solution:**

```bash
# Specify correct path
flutter_blueprint analyze ./path/to/project

# Or run from project root
cd my_project
flutter_blueprint analyze
```

#### "Too many issues found"

**Problem:** Legacy codebase with many issues

**Solution:**

1. Start with standard mode (not strict)
2. Fix errors first, then warnings
3. Gradually enable strict mode
4. Use `|| true` in CI to not fail build initially

#### "False positives for magic numbers"

**Problem:** Legitimate numbers flagged as magic

**Solution:**

- Numbers like 0, 1, 2, 10, 100 are automatically excluded
- For others, use const variables:
  ```dart
  const itemsPerPage = 20;
  const maxRetries = 3;
  ```

### Refactoring Issues

#### "Tests failed after refactoring"

**Problem:** Refactoring broke existing functionality

**Solution:**

1. Review git diff to see changes
2. Manually fix broken tests
3. Or revert: `git checkout .`

#### "Dependencies conflict"

**Problem:** New dependencies incompatible with existing ones

**Solution:**

```bash
# Update dependencies
flutter pub upgrade

# Or resolve conflicts manually in pubspec.yaml
```

#### "Generated code doesn't compile"

**Problem:** Refactoring created invalid code

**Solution:**

1. Check for syntax errors: `dart analyze`
2. Review the generated files
3. Manually fix issues
4. Report bug if reproducible

#### "Refactoring incomplete"

**Problem:** Not all files were updated

**Solution:**

- Some refactorings are partial (add infrastructure)
- Review the warnings in the output
- Manually complete the migration
- This is by design for complex migrations

### Common Questions

**Q: Can I customize what the analyzer checks for?**
A: Currently no, but this is planned. Use --strict, --performance, --accessibility flags for now.

**Q: Can I undo a refactoring?**
A: Yes! If you used version control:

```bash
git checkout .  # Discard all changes
# or
git revert HEAD  # Revert last commit
```

**Q: Are refactorings safe?**
A: They are designed to be safe, but:

- Always use version control
- Review changes before committing
- Run tests after refactoring
- Use --dry-run first

**Q: Can I run multiple refactorings at once?**
A: No, run one at a time for safety and clarity.

**Q: How do I disable a specific check?**
A: Currently not supported. File an issue if you need this feature.

---

## Examples

### Example 1: Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running code quality analysis..."
flutter_blueprint analyze --performance --accessibility

if [ $? -ne 0 ]; then
  echo "Code quality checks failed! Fix issues before committing."
  exit 1
fi

echo "Code quality checks passed!"
```

### Example 2: CI/CD Pipeline

```yaml
# .github/workflows/quality.yml
name: Code Quality

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Install dependencies
        run: flutter pub get

      - name: Code Quality Analysis
        run: flutter_blueprint analyze --strict --performance --accessibility
```

### Example 3: Gradual Refactoring

```bash
# Week 1: Add caching
flutter_blueprint refactor --add-caching
git add . && git commit -m "Add caching layer"

# Week 2: Add offline support
flutter_blueprint refactor --add-offline-support
git add . && git commit -m "Add offline support"

# Week 3: Add error handling
flutter_blueprint refactor --add-error-handling
git add . && git commit -m "Add error handling"

# Week 4: Optimize performance
flutter_blueprint refactor --optimize-performance
git add . && git commit -m "Optimize performance"
```

---

## Next Steps

- Explore [DX Features](DX_FEATURES.md) for development workflow improvements
- Check [EXAMPLES.md](EXAMPLES.md) for complete project examples
- Read [CONTRIBUTING.md](CONTRIBUTING.md) to add new checks or refactorings

---

**Need help?** Open an issue on GitHub or check the documentation.
