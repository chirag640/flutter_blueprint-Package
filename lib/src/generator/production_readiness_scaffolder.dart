import '../config/blueprint_config.dart';

/// Builds production-readiness artifacts for generated projects.
class ProductionReadinessScaffolder {
  static Map<String, String> buildFiles(BlueprintConfig config) {
    final files = <String, String>{
      'docs/release/secure-builds.md': _secureBuildsDoc(config),
      'docs/release/symbolication-workflow.md': _symbolicationWorkflowDoc(),
      'docs/engineering/reproducible-builds.md': _reproducibleBuildsDoc(),
      'scripts/release/pre_release_checks.sh': _preReleaseChecksSh,
      'scripts/release/pre_release_checks.ps1': _preReleaseChecksPs1,
    };

    if (config.hasPlatform(TargetPlatform.mobile)) {
      files.addAll({
        'docs/release/android-release-profile.md': _androidReleaseProfileDoc,
        'docs/release/ios-release-profile.md': _iosReleaseProfileDoc,
        'scripts/release/build_secure_android.sh': _buildSecureAndroidSh,
        'scripts/release/build_secure_android.ps1': _buildSecureAndroidPs1,
        'scripts/release/build_secure_ios.sh': _buildSecureIosSh,
      });
    }

    if (config.includeAnalytics &&
        config.analyticsProvider == AnalyticsProvider.sentry) {
      files.addAll({
        'docs/observability/sentry-baseline.md': _sentryBaselineDoc(config),
        '.env.sentry.example': _sentryEnvExample,
        'lib/core/analytics/sentry_release_context.dart':
            _sentryReleaseContextDart,
      });
    }

    if (config.ciProvider == CIProvider.github) {
      files.addAll({
        '.github/dependabot.yml': _dependabotConfig,
        '.github/workflows/dependency-drift.yml': _dependencyDriftWorkflow,
      });
    }

    return files;
  }

  static String _secureBuildsDoc(BlueprintConfig config) =>
      '''# Secure Release Preset

This project was generated with the production build-security preset enabled.

## Goals

- Obfuscate release binaries.
- Export split debug symbols for crash symbolication.
- Keep deterministic pre-release checks before publishing.

## Standard Android Release Command

```bash
flutter build appbundle --release \\
  --obfuscate \\
  --split-debug-info=build/symbols/android \\
  --dart-define=APP_ENV=production \\
  --dart-define=APP_RELEASE=1.0.0+1
```

## Standard iOS Release Command

```bash
flutter build ipa --release \\
  --obfuscate \\
  --split-debug-info=build/symbols/ios \\
  --dart-define=APP_ENV=production \\
  --dart-define=APP_RELEASE=1.0.0+1
```

## Pre-release Checks

Run one of:

- `bash scripts/release/pre_release_checks.sh`
- `pwsh scripts/release/pre_release_checks.ps1`

## Notes

- Keep symbol bundles private and retained for every published build.
- `APP_RELEASE` should match your store version/build identifier.
- `APP_ENV` should be `production` for publishable builds.
''';

  static String _symbolicationWorkflowDoc() => '''# Symbolication Workflow

Use this workflow to triage obfuscated stack traces in production.

## 1) Build with split debug info

Store symbol output from:

- `build/symbols/android`
- `build/symbols/ios`

## 2) Archive symbols per release

Recommended archive key format:

- `<app-name>/<platform>/<version+build>/symbols.zip`

## 3) Symbolicate stack traces

```bash
flutter symbolize \\
  --input=crash_stacktrace.txt \\
  --debug-info=build/symbols/android/app.android-arm64.symbols
```

## 4) Incident checklist

- Confirm incoming crash metadata has platform + app release.
- Pull matching symbol archive.
- Symbolicate and attach decoded trace to incident ticket.
- Add remediation notes and regression test references.
''';

  static String _reproducibleBuildsDoc() =>
      '''# Reproducible Builds and Dependency Hygiene

This project includes defaults intended to reduce dependency drift and improve reproducibility.

## Baseline

- Commit `pubspec.lock` for application repositories.
- Run `dart pub get` in CI before analysis/tests.
- Keep SDK constraints explicit in `pubspec.yaml`.

## Update Workflow

1. Run `dart pub outdated`.
2. Upgrade intentionally (small batches preferred).
3. Run analyzer/tests and smoke-build release artifacts.
4. Commit lockfile updates with changelog notes.

## Guardrails

- CI can fail when dependency drift is detected.
- Dependabot should manage both Dart packages and GitHub actions references.

## Recommended cadence

- Weekly: review Dependabot PRs.
- Monthly: run major version review and risk assessment.
''';
}

const _androidReleaseProfileDoc = '''# Android Release Profile (Secure Defaults)

## Build command

```bash
bash scripts/release/build_secure_android.sh
```

## Default hardening flags

- `--release`
- `--obfuscate`
- `--split-debug-info=build/symbols/android`

## Pre-release checklist

- [ ] `flutter test` passes.
- [ ] `flutter analyze` passes.
- [ ] `bash scripts/release/pre_release_checks.sh` passes.
- [ ] Symbol bundle archived with release metadata.
- [ ] Store changelog includes notable migration notes.
''';

const _iosReleaseProfileDoc = '''# iOS Release Profile (Secure Defaults)

## Build command

```bash
bash scripts/release/build_secure_ios.sh
```

## Default hardening flags

- `--release`
- `--obfuscate`
- `--split-debug-info=build/symbols/ios`

## Pre-release checklist

- [ ] `flutter test` passes.
- [ ] `flutter analyze` passes.
- [ ] `bash scripts/release/pre_release_checks.sh` passes.
- [ ] Symbol bundle archived with release metadata.
- [ ] Signing/codesign credentials validated in CI.
''';

const _buildSecureAndroidSh = r'''#!/usr/bin/env bash
set -euo pipefail

APP_ENV="${APP_ENV:-production}"
APP_RELEASE="${APP_RELEASE:-1.0.0+1}"

mkdir -p build/symbols/android

flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/symbols/android \
  --dart-define=APP_ENV=${APP_ENV} \
  --dart-define=APP_RELEASE=${APP_RELEASE}

echo "Secure Android build completed with APP_ENV=${APP_ENV} APP_RELEASE=${APP_RELEASE}"
''';

const _buildSecureAndroidPs1 = r'''$ErrorActionPreference = 'Stop'

if (-not $env:APP_ENV) {
  $env:APP_ENV = 'production'
}
if (-not $env:APP_RELEASE) {
  $env:APP_RELEASE = '1.0.0+1'
}

New-Item -ItemType Directory -Path 'build/symbols/android' -Force | Out-Null

flutter build appbundle --release `
  --obfuscate `
  --split-debug-info=build/symbols/android `
  --dart-define=APP_ENV=$env:APP_ENV `
  --dart-define=APP_RELEASE=$env:APP_RELEASE

Write-Output "Secure Android build completed with APP_ENV=$env:APP_ENV APP_RELEASE=$env:APP_RELEASE"
''';

const _buildSecureIosSh = r'''#!/usr/bin/env bash
set -euo pipefail

APP_ENV="${APP_ENV:-production}"
APP_RELEASE="${APP_RELEASE:-1.0.0+1}"

mkdir -p build/symbols/ios

flutter build ipa --release \
  --obfuscate \
  --split-debug-info=build/symbols/ios \
  --dart-define=APP_ENV=${APP_ENV} \
  --dart-define=APP_RELEASE=${APP_RELEASE}

echo "Secure iOS build completed with APP_ENV=${APP_ENV} APP_RELEASE=${APP_RELEASE}"
''';

const _preReleaseChecksSh = r'''#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Getting dependencies"
dart pub get

echo "[2/4] Static analysis"
dart analyze

echo "[3/4] Tests"
flutter test

echo "[4/4] Doctor checks"
flutter_blueprint doctor --strict

echo "Pre-release checks passed."
''';

const _preReleaseChecksPs1 = r'''$ErrorActionPreference = 'Stop'

Write-Output '[1/4] Getting dependencies'
dart pub get

Write-Output '[2/4] Static analysis'
dart analyze

Write-Output '[3/4] Tests'
flutter test

Write-Output '[4/4] Doctor checks'
flutter_blueprint doctor --strict

Write-Output 'Pre-release checks passed.'
''';

String _sentryBaselineDoc(BlueprintConfig config) =>
    '''# Sentry Baseline Observability

This project was generated with Sentry observability scaffolding.

## Bootstrapping

1. Add DSN and release metadata via dart-define or environment injection.
2. Initialize `SentryFlutter.init` in app bootstrap.
3. Register release/environment tags using `SentryReleaseContext.apply()`.

## Required runtime defines

- `SENTRY_DSN`
- `APP_ENV` (for example: `development`, `staging`, `production`)
- `APP_RELEASE` (version + build)

## Minimum tagging standard

- `environment`: app environment.
- `release`: app release identifier.
- `build_flavor`: optional flavor discriminator.

## Privacy baseline

- Do not attach raw PII in events or breadcrumbs.
- Scrub auth tokens, passwords, and private payloads before capture.
''';

const _sentryEnvExample =
    '''SENTRY_DSN=https://examplePublicKey@o0.ingest.sentry.io/0
APP_ENV=development
APP_RELEASE=0.1.0+1
''';

const _sentryReleaseContextDart =
    '''import 'package:sentry_flutter/sentry_flutter.dart';

/// Adds release/environment tags to Sentry scope from compile-time defines.
class SentryReleaseContext {
  static const String _environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const String _release =
      String.fromEnvironment('APP_RELEASE', defaultValue: 'dev-local');

  static Future<void> apply() async {
    await Sentry.configureScope((scope) {
      scope.environment = _environment;
      scope.setTag('release', _release);
      scope.setTag('build_flavor', _environment);
    });
  }
}
''';

const _dependabotConfig = '''version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
''';

const _dependencyDriftWorkflow = r'''name: Dependency Drift Guard

on:
  pull_request:
    branches: [main, develop]
  schedule:
    - cron: '0 5 * * 1'

permissions:
  contents: read

jobs:
  outdated-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Dart
        uses: dart-lang/setup-dart@v1

      - name: Get dependencies
        run: dart pub get

      - name: Check dependency drift
        shell: bash
        run: |
          set -euo pipefail
          OUTPUT=$(dart pub outdated)
          echo "$OUTPUT"
          if echo "$OUTPUT" | grep -qi "No dependencies are outdated"; then
            echo "No dependency drift detected."
            exit 0
          fi
          echo "::error::Dependency drift detected. Review and update dependencies."
          exit 1
''';
