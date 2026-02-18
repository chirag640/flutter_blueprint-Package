# Architecture Refactoring — Summary

## What Changed

The flutter_blueprint CLI package underwent a comprehensive architectural refactoring
following the **Strangler Fig** pattern—new abstractions were built alongside the legacy
code, then wired in as the primary code path. The old code remains available for
reference but is no longer the active entry point.

---

## New Core Abstractions (`lib/src/core/`)

| File                   | Purpose                                                                                                                                                                       |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `errors.dart`          | Domain error hierarchy: `BlueprintException` → `CommandError`, `ConfigurationError`, `ProjectGenerationError`, `TemplateRenderError`, `ValidationError`, `FileOperationError` |
| `result.dart`          | `sealed class Result<T, E>` with `Success` and `Failure` variants. Provides `when()`, `map()`, `flatMap()`, `getOrElse()`, `valueOrThrow`.                                    |
| `service_locator.dart` | Lightweight DI container: `register()` (lazy singleton), `registerFactory()`, `registerInstance()`, `get<T>()`, `tryGet<T>()`.                                                |

## New CLI Architecture (`lib/src/cli/`)

| File                     | Purpose                                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------------------- |
| `command_interface.dart` | `Command` (abstract), `BaseCommand`, `CommandResult`, `CommandContext`                                        |
| `command_registry.dart`  | Maps command names → `Command` instances, dispatches execution, returns `Result<CommandResult, CommandError>` |
| `cli_runner_v2.dart`     | **New entry point** (~220 lines vs. 1,803). Parses global flags, dispatches to `CommandRegistry`.             |

### Refactored Commands (`lib/src/cli/commands/`)

| Command       | File                          | Notes                                                |
| ------------- | ----------------------------- | ---------------------------------------------------- |
| `init`        | `init_command.dart`           | Full wizard mode extracted from CliRunner            |
| `analyze`     | `analyze_command_v2.dart`     | Unified code quality / bundle / performance analysis |
| `optimize`    | `optimize_command_v2.dart`    | Tree-shaking and asset optimization                  |
| `refactor`    | `refactor_command.dart`       | All 8 refactoring types with dry-run                 |
| `share`       | `share_command_v2.dart`       | Team configuration management                        |
| `update`      | `update_command_v2.dart`      | CLI self-update                                      |
| `add-feature` | `add_feature_command_v2.dart` | Feature scaffolding                                  |

All commands implement `BaseCommand` with a unified signature:

```dart
Future<Result<CommandResult, CommandError>> execute(ArgResults args, CommandContext context)
```

## New Template System (`lib/src/templates/core/`)

| File                      | Purpose                                                                                                                            |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `template_interface.dart` | `ITemplateRenderer` interface, `TemplateRegistry`, `TemplateContext`, `GeneratedFile`, `SharedComponents` (reusable code snippets) |
| `template_engine.dart`    | `TemplateBundleAdapter` / `SimpleTemplateBundleAdapter` — bridges old TemplateBundle callbacks to new ITemplateRenderer interface  |

## New Generator (`lib/src/generator/`)

| File                     | Purpose                                                                                                                                              |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `project_generator.dart` | `ProjectGenerator` uses `TemplateRegistry` for template selection (no more switch/case). Returns `Result<GenerationResult, ProjectGenerationError>`. |

---

## Issues Addressed

1. **God Class** — CliRunner reduced from 1,803 lines to ~220 lines
2. **No Template Abstraction** — `ITemplateRenderer` + `TemplateRegistry` introduced
3. **5 Different Command Signatures** — Unified to single `Command` interface
4. **No Error Type Hierarchy** — Domain error hierarchy with typed codes
5. **try/catch Everywhere** — Replaced with `Result<T, E>` sealed type
6. **No DI Container** — `ServiceLocator` provides testable dependency injection
7. **Shared Components Duplicated** — `SharedComponents` class centralizes reusable code
8. **Config Chaos** — Cleaner config flow through `CommandContext`
9. **Hard-coded Template Selection** — Registry-based lookup replaces switch/case
10. **Zero Test Coverage** — 307 tests now pass (including new core abstraction tests)

## Files Created

```
lib/src/core/
  ├── errors.dart
  ├── result.dart
  └── service_locator.dart
lib/src/cli/
  ├── cli_runner_v2.dart
  ├── command_interface.dart
  ├── command_registry.dart
  └── commands/
      ├── init_command.dart
      ├── analyze_command_v2.dart
      ├── optimize_command_v2.dart
      ├── refactor_command.dart
      ├── share_command_v2.dart
      ├── update_command_v2.dart
      └── add_feature_command_v2.dart
lib/src/templates/core/
  ├── template_interface.dart
  └── template_engine.dart
lib/src/generator/
  └── project_generator.dart
test/core/
  ├── result_and_errors_test.dart
  └── service_locator_test.dart
test/cli/
  └── command_registry_test.dart
test/templates/
  └── template_system_test.dart
```

## Files Modified

| File                         | Change                                |
| ---------------------------- | ------------------------------------- |
| `bin/flutter_blueprint.dart` | Entry point switched to `CliRunnerV2` |
| `lib/flutter_blueprint.dart` | New exports added for all v2 modules  |

## Legacy Files (Unchanged, Kept for Reference)

- `lib/src/cli/cli_runner.dart` — Original 1,803-line god class
- `lib/src/commands/` — Original command files with inconsistent signatures
- `lib/src/generator/blueprint_generator.dart` — Original generator

---

## Phase 5: Feature Completion & Code Quality

Following the architectural refactoring, all TODO placeholders were replaced with production-ready implementations:

### Cache Implementation (data_layer_template.dart)

- **SharedPreferences-based cache** with JSON serialization
- `getCached()`: Decodes JSON with error recovery (auto-clears corrupted cache)
- `cache()`: Encodes List<T> to JSON string and persists
- `clearCache()`: Removes cached data
- Constructor injection: `LocalDataSourceImpl(this._prefs)` for testability

### Auth Token Management (template_interface.dart)

- **AuthInterceptor** with callback-based token provider:
  - `getToken()` callback for injecting Authorization header
  - `refreshToken()` callback for 401 handling
  - Request retry after token refresh
- ApiClient constructor accepts `getToken` and `refreshToken` callbacks
- Supports any auth strategy (OAuth, JWT, custom)

### Navigation Examples (presentation_layer_template.dart)

- **MaterialPageRoute examples** for all 3 state management patterns
- Consistent pattern: button → `Navigator.push()` → detail screen
- Named route patterns documented in comments
- Covers Provider, Riverpod, and Bloc architectures

### Dependency Injection Documentation (presentation_layer_template.dart)

- **Riverpod provider examples** with full DI chain
- Pattern: Repository → Use Case → Notifier
- Constructor injection with `ref.watch()` for reactive updates
- Comprehensive code examples in documentation comments

### Offline Sync API Integration (hive_templates.dart)

- **Dio-based API calls** in SyncManager:
  - POST for create operations
  - PUT for update operations
  - DELETE for delete operations
- Response validation and status logging
- Optional Dio injection for testability

---

## Phase 6: Security & Validation Enhancements

Enterprise-grade security features added across the template system:

### Security Headers (template_interface.dart)

Six OWASP-recommended headers added to ApiClient:

- `X-Content-Type-Options: nosniff` — Prevents MIME-sniffing
- `X-Frame-Options: DENY` — Prevents clickjacking
- `X-XSS-Protection: 1; mode=block` — Legacy XSS protection
- `Strict-Transport-Security` — Forces HTTPS (1 year + subdomains)
- `Cache-Control: no-cache, no-store` — Prevents sensitive data caching
- `Pragma: no-cache` — HTTP/1.0 cache prevention

### Error Message Sanitization (template_interface.dart)

**SecurityInterceptor** sanitizes error responses:

- Removes Windows/Unix file paths (`C:\`, `/usr/local/`)
- Masks IP addresses (IPv4 and IPv6)
- Redacts long tokens (32+ characters)
- X-Request-ID header for audit trails

### Rate Limiting (template_interface.dart)

**RateLimitInterceptor** provides client-side protection:

- 60 requests per minute per endpoint
- 1-minute rolling window
- Automatic timestamp cleanup
- Retry-after header calculation
- Prevents API abuse from client

### Certificate Pinning (template_interface.dart)

**SecurityConfig.applyCertificatePinning()**:

- SHA-256 fingerprint validation
- MITM attack prevention
- Supports multiple pins for rotation
- OpenSSL command examples in documentation

### SSRF Prevention (template_interface.dart)

SecurityInterceptor validates URLs:

- Blocks localhost requests in production
- Prevents internal network access
- Environment-aware (dev mode allows localhost)

### Security Validation (template_interface.dart)

**SecurityConfig.checkSecurityConfiguration()** audits:

- HTTPS enforcement check
- Certificate pinning validation
- Security headers verification
- Rate limiting configuration
- Error sanitization check
- Returns `SecurityCheckResult` with passed/issues/warnings

---

## Verification

```bash
$ dart analyze
Analyzing flutter_blueprint... No issues found!

$ dart test
00:00 +334: All tests passed!
```

**Coverage**: 62.88% (24 files covered)

**Modernization Progress**: 21/28 tasks complete (75%)

- Phase 1: Architecture Refactoring ✅
- Phase 2: Legacy Code Removal ✅
- Phase 3: Testing Infrastructure ✅
- Phase 4: Performance Optimization ✅
- Phase 5: Feature Completion ✅
- Phase 6: Security & Validation ✅
- Phase 7: Documentation Polish (in progress)
- Phase 8: Release Preparation (pending v2.0.0)
