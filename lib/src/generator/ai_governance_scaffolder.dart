import '../config/blueprint_config.dart';

/// Builds AI governance scaffolding files for generated projects.
class AIGovernanceScaffolder {
  static Map<String, String> buildFiles(BlueprintConfig config) {
    if (!config.includeAiGovernance) {
      return const {};
    }

    final owner = _normalizeOwner(config.aiOwner);
    final ciMode = config.aiCiMode.label;
    final policy = _buildPolicy(config, ciMode);

    final files = <String, String>{
      '.github/ai/flutter-enterprise-policy.md': policy,
      '.github/copilot-instructions.md':
          _copilotTemplate.replaceAll('__POLICY__', policy),
      '.cursor/rules/flutter-enterprise.mdc':
          _cursorTemplate.replaceAll('__POLICY__', policy),
      'scripts/sync_ai_rules.ps1':
          _syncScriptTemplate.replaceAll('__CI_MODE__', ciMode),
      'docs/engineering/masvs-checklist.md':
          _buildMasvsChecklist(config, ciMode),
    };

    if (_isAtLeastStandard(config.aiGovernanceLevel)) {
      files.addAll({
        '.github/instructions/flutter-enterprise.instructions.md':
            _dartInstructionsTemplate
                .replaceAll('__POLICY__', policy)
                .replaceAll('__CI_MODE__', ciMode),
        '.github/instructions/repo-governance.instructions.md':
            _governanceInstructionsTemplate
                .replaceAll('__POLICY__', policy)
                .replaceAll('__CI_MODE__', ciMode),
        '.github/CODEOWNERS':
            _codeownersTemplate.replaceAll('__OWNER__', owner),
        '.github/ISSUE_TEMPLATE/ai-task-card.yml': _taskCardTemplate,
        '.github/PULL_REQUEST_TEMPLATE.md': _prTemplate,
      });
    }

    if (config.aiGovernanceLevel == AIGovernanceLevel.full) {
      files.addAll({
        '.github/workflows/ai-policy-sync-check.yml': _aiPolicySyncWorkflow,
        '.github/workflows/security-policy-guard.yml': _securityWorkflow,
        '.github/workflows/engineering-guardrails.yml':
            _guardrailsWorkflow.replaceAll('__CI_MODE__', ciMode),
        '.github/workflows/production-readiness-score.yml': _readinessWorkflow,
        '.githooks/pre-commit': _preCommitHook,
        'scripts/install_git_hooks.ps1': _installHooksScript,
        'docs/ai/instruction-files-perfect-flow.md': _instructionFlowDoc,
        'docs/ai/prompt-packs.md': _promptPacksDoc,
        'docs/engineering/accessibility-gates.md': _a11yDoc,
        'docs/engineering/api-contract-standard.md': _apiContractDoc,
        'docs/engineering/feature-scaffolding-standard.md': _scaffoldingDoc,
        'docs/engineering/global-widget-catalog.md': _widgetCatalogDoc,
        'docs/engineering/observability-acceptance.md': _observabilityDoc,
      });
    }

    return files;
  }

  static bool _isAtLeastStandard(AIGovernanceLevel level) {
    return level == AIGovernanceLevel.standard ||
        level == AIGovernanceLevel.full;
  }

  static String _normalizeOwner(String owner) {
    final trimmed = owner.trim();
    if (trimmed.isEmpty) {
      return '@your-github-handle';
    }
    return trimmed.startsWith('@') ? trimmed : '@$trimmed';
  }

  static String _buildPolicy(BlueprintConfig config, String ciMode) {
    return _policyTemplate
        .replaceAll('__APP_NAME__', config.appName)
        .replaceAll('__SECURITY_PROFILE__', 'maximum')
        .replaceAll('__CI_MODE__', ciMode)
        .replaceAll('__CI_MODE_DETAILS__', _ciModeDetails(config.aiCiMode))
        .replaceAll('__STATE_MANAGEMENT_STACK__', _stateManagementStack(config))
        .replaceAll('__STATE_POLICY_SNIPPET__', _statePolicySnippet(config))
        .replaceAll('__DI_STACK__', _diStack(config))
        .replaceAll('__API_STACK__', _apiStack(config))
        .replaceAll('__GRAPHQL_STACK__', _graphqlStack(config))
        .replaceAll('__ENV_STACK__', _envStack(config))
        .replaceAll('__LOCALIZATION_STACK__', _localizationStack(config))
        .replaceAll('__OBSERVABILITY_STACK__', _observabilityStack(config))
        .replaceAll('__HIVE_STACK__', _hiveStack(config));
  }

  static String _ciModeDetails(AICiMode mode) {
    return switch (mode) {
      AICiMode.advisory =>
        '- advisory-only: report policy violations as warnings and require remediation note in PR.\n'
            '- mixed: block critical security/compliance violations, warn on maintainability issues.\n'
            '- blocking: fail CI on policy violations, no merge until fully compliant.\n'
            '- Active mode in this project: advisory-only.',
      AICiMode.mixed =>
        '- advisory-only: report policy violations as warnings and require remediation note in PR.\n'
            '- mixed: block critical security/compliance violations, warn on maintainability issues.\n'
            '- blocking: fail CI on policy violations, no merge until fully compliant.\n'
            '- Active mode in this project: mixed.',
      AICiMode.blocking =>
        '- advisory-only: report policy violations as warnings and require remediation note in PR.\n'
            '- mixed: block critical security/compliance violations, warn on maintainability issues.\n'
            '- blocking: fail CI on policy violations, no merge until fully compliant.\n'
            '- Active mode in this project: blocking.',
    };
  }

  static String _stateManagementStack(BlueprintConfig config) {
    return switch (config.stateManagement) {
      StateManagement.riverpod =>
        'flutter_riverpod + codegen (generated by user selection)',
      StateManagement.provider =>
        'provider (generated by user selection; keep notifier boundaries explicit)',
      StateManagement.bloc =>
        'bloc/cubit (generated by user selection; event/state separation required)',
      StateManagement.getx =>
        'getx (generated by user selection; avoid global mutable anti-patterns)',
    };
  }

  static String _diStack(BlueprintConfig config) {
    if (config.stateManagement == StateManagement.riverpod) {
      return 'get_it + injectable recommended for app/domain/data wiring';
    }
    return 'Use constructor injection first; optionally use get_it/injectable for scale';
  }

  static String _apiStack(BlueprintConfig config) {
    if (!config.includeApi) {
      return 'No API client scaffolded. Add transport intentionally with contract tests.';
    }
    return 'REST via dio scaffold enabled.';
  }

  static String _graphqlStack(BlueprintConfig config) {
    return switch (config.graphqlClient) {
      GraphqlClient.none => 'none',
      GraphqlClient.graphqlFlutter => 'graphql_flutter client selected',
      GraphqlClient.ferry =>
        'ferry selected (schema-driven codegen and typed operations)',
    };
  }

  static String _envStack(BlueprintConfig config) {
    if (!config.includeEnv) {
      return 'No env scaffold selected; use runtime secrets from CI/CD and secure vaults.';
    }
    return 'Environment segregation enabled (dart-define/envied workflow).';
  }

  static String _localizationStack(BlueprintConfig config) {
    if (!config.includeLocalization) {
      return 'Localization disabled by selection; avoid hardcoded strings if later enabled.';
    }
    return 'Localization enabled; prefer typed i18n workflow (for example, slang).';
  }

  static String _observabilityStack(BlueprintConfig config) {
    if (!config.includeAnalytics ||
        config.analyticsProvider == AnalyticsProvider.none) {
      return 'No analytics provider selected; still capture structured error telemetry.';
    }
    return switch (config.analyticsProvider) {
      AnalyticsProvider.none => 'No analytics provider selected.',
      AnalyticsProvider.firebase =>
        'Firebase Analytics/Crashlytics selected (avoid PII in events and logs).',
      AnalyticsProvider.sentry =>
        'Sentry selected (DSN via dart-define; scrub sensitive attributes).',
    };
  }

  static String _hiveStack(BlueprintConfig config) {
    return config.includeHive
        ? 'Hive local storage enabled (encrypt sensitive data, avoid plaintext secrets).'
        : 'Hive not selected.';
  }

  static String _statePolicySnippet(BlueprintConfig config) {
    return switch (config.stateManagement) {
      StateManagement.riverpod => r'''Riverpod implementation baseline:

```dart
@riverpod
class UserVm extends _$UserVm {
  @override
  Future<User> build(String userId) async {
    final repo = ref.read(userRepositoryProvider);
    return repo.getUser(userId);
  }
}
```

Rule: keep domain logic in use cases/repositories and keep providers orchestration-focused.''',
      StateManagement.provider => r'''Provider implementation baseline:

```dart
class UserNotifier extends ChangeNotifier {
  UserNotifier(this._getUserUseCase);

  final GetUserUseCase _getUserUseCase;
  UserState _state = const UserState.initial();

  UserState get state => _state;

  Future<void> load(String userId) async {
    _state = const UserState.loading();
    notifyListeners();
    _state = await _getUserUseCase(userId);
    notifyListeners();
  }
}
```

Rule: keep ChangeNotifier thin and delegate business rules to use cases.''',
      StateManagement.bloc => r'''Bloc implementation baseline:

```dart
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._getUserUseCase) : super(const UserState.initial()) {
    on<UserRequested>(_onUserRequested);
  }

  final GetUserUseCase _getUserUseCase;

  Future<void> _onUserRequested(
    UserRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserState.loading());
    emit(await _getUserUseCase(event.userId));
  }
}
```

Rule: event/state contracts must stay stable and data-layer internals must not leak into events.''',
      StateManagement.getx => r'''GetX implementation baseline:

```dart
class UserController extends GetxController {
  UserController(this._getUserUseCase);

  final GetUserUseCase _getUserUseCase;
  final state = const UserState.initial().obs;

  Future<void> load(String userId) async {
    state.value = const UserState.loading();
    state.value = await _getUserUseCase(userId);
  }
}
```

Rule: avoid hidden globals; keep controller scope explicit per route/module.''',
    };
  }

  static String _buildMasvsChecklist(BlueprintConfig config, String ciMode) {
    final buffer = StringBuffer()
      ..writeln('# MASVS / MASWE Traceability Checklist')
      ..writeln()
      ..writeln('Project: ${config.appName}')
      ..writeln('CI mode: $ciMode')
      ..writeln('Security profile: maximum')
      ..writeln('MASVS profile: CONTROL-GROUP DRIVEN (no legacy level wording)')
      ..writeln(
          'Control groups: STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, PRIVACY')
      ..writeln('MASWE mapping style: weakness-oriented, category-level')
      ..writeln()
      ..writeln('This checklist is generated from selected blueprint features.')
      ..writeln('Mark each item during implementation and verification.')
      ..writeln()
      ..writeln(
          '| MASVS Control Group | MASWE-Oriented Mapping | Trigger | Control Objective | Status | Evidence |')
      ..writeln('| --- | --- | --- | --- | --- | --- |');

    void addItem(
      String controlGroup,
      String masweMapping,
      String trigger,
      String objective,
    ) {
      buffer.writeln(
        '| $controlGroup | $masweMapping | $trigger | $objective | [ ] | |',
      );
    }

    addItem(
      'PRIVACY',
      'Sensitive data exposure in logs/crash payloads',
      'always',
      'No secrets, tokens, or PII are logged in app, CI, or crash payloads.',
    );
    addItem(
      'CODE',
      'Missing verification gates and unsafe code quality drift',
      'always',
      'Static analysis and tests are mandatory for behavior-changing PRs.',
    );
    addItem(
      'CRYPTO',
      'Weak secret/configuration handling',
      config.includeEnv ? 'include_env=true' : 'include_env=false',
      'Secrets/configuration are injected securely via environment strategy.',
    );

    if (config.includeApi) {
      addItem(
        'NETWORK',
        'Insecure transport and TLS misconfiguration',
        'include_api=true',
        'HTTP transport enforces TLS and rejects insecure overrides in production.',
      );
      addItem(
        'NETWORK',
        'Unvalidated API envelopes and unsafe parsing',
        'include_api=true',
        'Request/response envelopes are validated and mapped through typed DTOs.',
      );
    }

    if (config.includeWebSocket) {
      addItem(
        'NETWORK',
        'Realtime channel auth/session weaknesses',
        'include_websocket=true',
        'Realtime channels authenticate, reconnect safely, and avoid plaintext payload leaks.',
      );
    }

    if (config.includeHive) {
      addItem(
        'STORAGE',
        'Insecure at-rest storage and key management',
        'include_hive=true',
        'Sensitive local records are encrypted and keys are not hardcoded in source.',
      );
    }

    if (config.includeSocialAuth) {
      addItem(
        'AUTH',
        'Token/session lifecycle and auth state weaknesses',
        'include_social_auth=true',
        'Auth tokens are validated, stored securely, and cleared on logout/session expiry.',
      );
    }

    if (config.includeAnalytics ||
        config.analyticsProvider != AnalyticsProvider.none) {
      addItem(
        'PRIVACY',
        'Telemetry over-collection and missing scrubbing controls',
        'include_analytics=true',
        'Analytics/crash events are scrubbed and data minimization is enforced.',
      );
    }

    if (config.includePushNotifications) {
      addItem(
        'PLATFORM',
        'Unsafe platform channel/deep-link handling',
        'include_push_notifications=true',
        'Push notification payload handling validates origin and avoids unsafe deep links.',
      );
    }

    if (config.includeMedia || config.includeMaps) {
      addItem(
        'PLATFORM',
        'Over-permissioning and runtime permission misuse',
        'include_media/maps=true',
        'Runtime permissions follow least privilege and deny-by-default behavior.',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Verification Notes')
      ..writeln()
      ..writeln(
          '- Keep evidence linked to MASVS control groups and MASWE weakness categories.')
      ..writeln('- Map test evidence to each checked item before release.')
      ..writeln(
          '- For mixed/blocking CI modes, unresolved items must include mitigation notes in PR.')
      ..writeln(
          '- Review checklist whenever feature set changes in blueprint configuration.');

    return buffer.toString();
  }
}

const _policyTemplate = '''# Enterprise-Grade Flutter Engineering Playbook

Project: __APP_NAME__

Version: 3.0
Audience: Humans + AI coding assistants
Style: Vibe-coder friendly, production-safe, fast to execute

---

## 0) Generated Engineering Profile

- Security posture: __SECURITY_PROFILE__
- CI policy mode: __CI_MODE__
- Stack is generated from blueprint user selections (not hardcoded defaults).

### Selected Stack Snapshot

- State management: __STATE_MANAGEMENT_STACK__
- Dependency injection: __DI_STACK__
- REST/API client: __API_STACK__
- GraphQL client: __GRAPHQL_STACK__
- Environment strategy: __ENV_STACK__
- Localization strategy: __LOCALIZATION_STACK__
- Observability strategy: __OBSERVABILITY_STACK__
- Offline storage: __HIVE_STACK__

---

## 1) Mission

Ship production-ready Flutter code with strict architecture boundaries, measurable quality gates,
high security posture, and strong developer velocity.

This file is the canonical policy source used to generate:
- .github/copilot-instructions.md
- .cursor/rules/flutter-enterprise.mdc
- .github/instructions/*.instructions.md

---

## 2) Non-Negotiables

### 2.1 Hard Stop Security Rules

- Never commit secrets, keys, tokens, passwords, DSNs, private endpoints.
- Never add or keep plaintext secrets in source, logs, tests, docs, or screenshots.
- Never send auth tokens or PII to logs, analytics, or crash reports.
- Never downgrade transport security or bypass TLS/certificate validation in production.

### 2.2 Architecture Rules

- Enforce layer boundaries:
  - Presentation (Flutter Widgets)
  - Application (selected state-management orchestration)
  - Domain (pure Dart entities/use-cases/interfaces)
  - Data (repository implementations, data sources)
  - Infrastructure (HTTP, storage, analytics, external SDKs)
- Domain layer cannot import Flutter UI packages.
- Repository interfaces belong in domain, implementations belong in data.
- State management and DI patterns must follow the selected stack profile.

### 2.4 Security Baseline Standard (OWASP MASVS/MASTG)

- Controls must map to MASVS domains: STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, RESILIENCE, PRIVACY.
- Security validation should use both static checks and runtime checks for critical flows.
- Mobile hardening must include anti-tamper/resilience checks for high-risk use cases.
- Threat model updates are required when introducing new external SDKs or sensitive flows.

### 2.3 Quality Rules

- No behavior-changing PR without tests.
- No merge when analyzer or tests fail.
- Keep generated code and lockfiles in sync when relevant.

---

## 3) Stack Selection and Adaptation Rules

- Never force a stack that was not selected in blueprint configuration.
- Generated templates must adapt architecture guidance to selected state-management and API options.
- If localization is disabled, keep UI string policy ready for future enablement.
- If analytics is disabled, still enforce secure error reporting and no-PII diagnostics.
- If GraphQL is selected, ensure generated code, schema, and operation contracts stay synchronized.
- If REST is selected, enforce explicit DTO mapping and stable response envelopes.

Feature flags and remote configuration guidance:
- Major risky changes should be runtime-gated.
- Remote config must never store secrets.

---

## 4) AI Operating Protocol (Important)

When AI is implementing a task, follow this sequence:

1. Read the task and summarize intent in one short block.
2. Identify impacted layers/files.
3. Implement the smallest safe change first.
4. Add or update tests for changed behavior.
5. Run analyzer and tests.
6. Return a concise change report with validation evidence.

If requirements are ambiguous, ask at most one focused question, then proceed with safe defaults.

---

## 5) Coder-Friendly Implementation Rules

### 5.1 Comment-Driven Coding

Before non-trivial functions, write a short intent comment describing:
- Inputs
- Steps
- Edge cases
- Output

### 5.2 Guard Clauses

Prefer early returns over deep nested if blocks.

### 5.3 Pure Functions First

Extract business logic into pure functions whenever possible for easier tests.

### 5.4 Explicit Types

Prefer explicit types in public APIs and important local variables to reduce ambiguity.

### 5.5 Dart 3 Patterns

Prefer switch expressions/pattern matching for enum/state routing.

---

## 6) State and DI Boundary Pattern (Stack-Aware)

Use the selected stack consistently:

- Riverpod: provider/notifier handles UI-facing state; repository contracts stay in domain.
- Provider: ChangeNotifier/ValueNotifier logic should remain orchestration-only and delegate business logic.
- Bloc: events/states should not leak data-layer implementation details.
- GetX: controller scope should be explicit; avoid hidden global shared mutable state.

DI guidance:

- Constructor injection is preferred at module boundaries.
- get_it/injectable are recommended for larger codebases, especially with Riverpod integrations.
- No service locator access from pure domain entities.

Selected state-management reference pattern:

__STATE_POLICY_SNIPPET__

---

## 7) Environment and Flavor Rules

- Separate dev, staging, production configurations.
- Keep per-flavor API bases and analytics identifiers isolated.
- Production builds must not use dev keys or debug endpoints.

---

## 8) Observability Rules

- Capture uncaught framework and platform errors.
- Track critical API latency and failure rates.
- Attach useful context to exceptions without leaking secrets.
- Distinguish expected business errors from unexpected system failures.

---

## 9) Internationalization Rules

- Do not hardcode user-visible strings in widgets.
- Add strings to translation files and use typed accessors.
- Keep placeholders and pluralization grammatically correct.

---

## 10) Feature Flags and Remote Config Rules

- Major UX/API behavior changes should be flaggable.
- New risky features should launch behind remote-config gates.
- Add sane defaults for all flags.

---

## 11) Performance Rules

- Use const constructors and const widgets where possible.
- Move expensive parsing/filtering to Isolate.run when justified.
- Prefer ListView itemExtent/prototypeItem for long lists.
- Use RepaintBoundary around frequently animating subtrees.
- Use cached image strategies for remote images.

---

## 12) API Contract Rules

### Success envelope

```json
{
  "success": true,
  "message": "string",
  "data": {},
  "meta": {}
}
```

### Error envelope

```json
{
  "success": false,
  "error": {
    "code": "string",
    "message": "string",
    "details": {}
  }
}
```

---

## 13) Testing Strategy

- Unit tests:
  - Domain use-cases and pure functions
  - Parsing/mapping logic
- Widget tests:
  - Core screens and interaction branches
- Integration tests:
  - Critical user journeys (auth, payment, checkout, profile update)

Testing principles:
- Deterministic
- Isolated
- No hidden external dependency
- Fast enough for CI

---

## 14) CI/CD Guardrails

Minimum CI steps:

1. flutter pub get
2. dart run build_runner build --delete-conflicting-outputs
3. flutter analyze
4. flutter test --coverage
5. Security scan (secret scanning)

CI mode for this generated policy: __CI_MODE__

__CI_MODE_DETAILS__

PR should include:
- Summary
- Linked task
- Validation evidence
- Known limitations if any

---

## 15) Completion Checklist

Before marking done:

- [ ] Architecture boundaries respected
- [ ] Security rules respected
- [ ] No hardcoded secrets or PII logs
- [ ] Tests updated/added for changed behavior
- [ ] Analyzer clean
- [ ] Tests passing
- [ ] If generated files changed, regenerated and committed
- [ ] Rollback/mitigation note for risky changes

---

## 16) AI Response Format for Code Reviews

When reviewing, list:

1. Findings (highest severity first)
2. Open questions/assumptions
3. Short change summary

Always include file references for findings.

---

## 17) Rule of Practicality

Prefer minimal safe changes over broad rewrites.
Prefer readability over cleverness.
Prefer testability over hidden coupling.
Prefer explicitness over magic.

This policy is optimized for high-signal, low-friction delivery.
''';

const _copilotTemplate = '''# Enterprise Flutter AI Rules (Synced)

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

__POLICY__
''';

const _cursorTemplate = '''---
description: Enterprise Flutter rules for architecture, security, testing, and quality
globs:
  - "**/*.dart"
  - "**/*.yaml"
  - "**/*.yml"
  - "**/*.md"
  - "pubspec.yaml"
  - "analysis_options.yaml"
alwaysApply: true
---

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

__POLICY__
''';

const _dartInstructionsTemplate = '''---
applyTo: "**/*.dart"
---

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

## Dart Execution Rules

- Follow clean architecture boundaries strictly.
- Use the stack selected by blueprint config; do not force alternate stacks.
- Prefer guard clauses and pure helper functions.
- Add/update tests for any behavior change.
- Keep code analyzer-clean and formatted.
- CI mode for this template: __CI_MODE__.

__POLICY__
''';

const _governanceInstructionsTemplate = '''---
applyTo: "**/*.{md,yaml,yml}"
---

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

# Repository Governance Rules

- Keep docs and workflows consistent with canonical policy.
- Avoid policy drift; sync generated files from source policy.
- Keep CI deterministic and security-safe.
- Require validation evidence in PR descriptions.
- Current CI mode: __CI_MODE__.

__POLICY__

## CI and Build Rules

- CI changes must preserve static analysis and test execution.
- Keep workflow changes deterministic and security-safe.
''';

const _syncScriptTemplate = r'''$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$policyPath = Join-Path $repoRoot '.github/ai/flutter-enterprise-policy.md'

if (-not (Test-Path $policyPath)) {
  throw "Policy source not found: $policyPath"
}

$policy = Get-Content $policyPath -Raw

$copilotPath = Join-Path $repoRoot '.github/copilot-instructions.md'
$copilotContent = @"
# Enterprise Flutter AI Rules (Synced)

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

$policy
"@
Set-Content -Path $copilotPath -Value $copilotContent -Encoding utf8

$cursorPath = Join-Path $repoRoot '.cursor/rules/flutter-enterprise.mdc'
$cursorContent = @"
---
description: Enterprise Flutter rules for architecture, security, testing, and quality
globs:
  - "**/*.dart"
  - "**/*.yaml"
  - "**/*.yml"
  - "**/*.md"
  - "pubspec.yaml"
  - "analysis_options.yaml"
alwaysApply: true
---

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

$policy
"@
Set-Content -Path $cursorPath -Value $cursorContent -Encoding utf8

$dartInstructionPath = Join-Path $repoRoot '.github/instructions/flutter-enterprise.instructions.md'
$dartInstructionContent = @"
---
applyTo: "**/*.dart"
---

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

## Dart Execution Rules

- Follow clean architecture boundaries strictly.
- Use the stack selected by blueprint config; do not force alternate stacks.
- Prefer guard clauses and pure helper functions.
- Add/update tests for any behavior change.
- Keep code analyzer-clean and formatted.
- CI mode for this template: __CI_MODE__.

$policy
"@
Set-Content -Path $dartInstructionPath -Value $dartInstructionContent -Encoding utf8

$governanceInstructionPath = Join-Path $repoRoot '.github/instructions/repo-governance.instructions.md'
$governanceInstructionContent = @"
---
applyTo: "**/*.{md,yaml,yml}"
---

This file is generated from .github/ai/flutter-enterprise-policy.md.
Do not edit manually. Run scripts/sync_ai_rules.ps1.

# Repository Governance Rules

- Keep docs and workflows consistent with canonical policy.
- Avoid policy drift; sync generated files from source policy.
- Keep CI deterministic and security-safe.
- Require validation evidence in PR descriptions.
- Current CI mode: __CI_MODE__.

$policy

## CI and Build Rules

- CI changes must preserve static analysis and test execution.
- Keep workflow changes deterministic and security-safe.
"@
Set-Content -Path $governanceInstructionPath -Value $governanceInstructionContent -Encoding utf8

Write-Output 'AI rule files synchronized from canonical policy source.'
''';

const _codeownersTemplate = '''# Default ownership
* __OWNER__

# AI governance assets
/.github/ai/flutter-enterprise-policy.md __OWNER__
/.github/copilot-instructions.md __OWNER__
/.cursor/rules/flutter-enterprise.mdc __OWNER__
/.github/instructions/flutter-enterprise.instructions.md __OWNER__
/.github/instructions/repo-governance.instructions.md __OWNER__
/scripts/sync_ai_rules.ps1 __OWNER__
/scripts/install_git_hooks.ps1 __OWNER__
/.githooks/pre-commit __OWNER__
/.github/workflows/ai-policy-sync-check.yml __OWNER__
/.github/workflows/security-policy-guard.yml __OWNER__
/.github/workflows/engineering-guardrails.yml __OWNER__
/.github/workflows/production-readiness-score.yml __OWNER__
''';

const _taskCardTemplate = '''name: AI Task Card
description: Required pre-implementation specification for substantial AI-assisted work
title: "AI Task Card: "
labels: ["ai-task-card"]
body:
  - type: textarea
    id: goal
    attributes:
      label: Goal
      description: What outcome is required?
    validations:
      required: true
  - type: textarea
    id: io
    attributes:
      label: Inputs and Outputs
      description: Define major inputs, outputs, contracts, and expected data shapes.
    validations:
      required: true
  - type: textarea
    id: edge_cases
    attributes:
      label: Edge Cases
      description: List failure modes and tricky cases.
    validations:
      required: true
  - type: textarea
    id: done_conditions
    attributes:
      label: Done Conditions
      description: Measurable acceptance criteria for completion.
    validations:
      required: true
''';

const _prTemplate = '''## Summary

- What changed:
- Why:

## AI Task Card Link

- Related issue or task card:

## Validation Evidence

- [ ] Static analysis clean
- [ ] Tests passing
- [ ] Security checks passing
- [ ] AI policy sync check passing
''';

const _aiPolicySyncWorkflow = r'''name: AI Policy Sync Check

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  rule-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run AI rule sync
        shell: pwsh
        run: ./scripts/sync_ai_rules.ps1
      - name: Verify no drift
        shell: bash
        run: |
          set -euo pipefail
          git diff --exit-code -- \
            .github/copilot-instructions.md \
            .cursor/rules/flutter-enterprise.mdc \
            .github/instructions/flutter-enterprise.instructions.md \
            .github/instructions/repo-governance.instructions.md
''';

const _securityWorkflow = r'''name: Security Policy Guard

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@v2
''';

const _guardrailsWorkflow = r'''name: Engineering Guardrails

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  guardrails:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Apply AI CI mode guardrails
        shell: bash
        run: |
          set -euo pipefail
          MODE="__CI_MODE__"
          echo "AI CI mode: $MODE"
          if [ "$MODE" = "blocking" ]; then
            if grep -R --line-number -E "TODO\((security|governance)\)" lib test; then
              echo "Blocking mode: security/governance TODO markers must be resolved."
              exit 1
            fi
            echo "Blocking mode checks passed."
          elif [ "$MODE" = "mixed" ]; then
            if grep -R --line-number -E "TODO\((security|governance)\)" lib test; then
              echo "Mixed mode: unresolved security/governance TODO markers found (warning only)."
            fi
            echo "Mixed mode checks complete."
          else
            echo "Advisory-only mode: reporting-only guardrails active."
          fi
''';

const _readinessWorkflow = r'''name: Production Readiness Score

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  readiness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - name: Install dependencies
        run: dart pub get
      - name: Run tests
        run: dart test
      - name: Run analyzer
        run: dart analyze
''';

const _preCommitHook = r'''#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoLogo -NoProfile -File scripts/sync_ai_rules.ps1
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/sync_ai_rules.ps1
else
  echo "PowerShell runtime not found."
  exit 1
fi

git diff --quiet -- \
  .github/copilot-instructions.md \
  .cursor/rules/flutter-enterprise.mdc \
  .github/instructions/flutter-enterprise.instructions.md \
  .github/instructions/repo-governance.instructions.md || {
  echo "AI rule files updated. Stage changes and commit again."
  exit 1
}
''';

const _installHooksScript = r'''$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (-not (Test-Path '.githooks')) {
  throw 'Missing .githooks directory'
}

git config core.hooksPath .githooks

if (Get-Command bash -ErrorAction SilentlyContinue) {
  bash -lc "chmod +x .githooks/pre-commit" | Out-Null
}

Write-Output "Git hooks installed."
''';

const _instructionFlowDoc = '''# Instruction File Design for Vibe Coders

Use one canonical policy source and generate tool-specific adapters.

## Why this works

- Single source of truth prevents rule conflicts.
- Tool-specific adapters optimize behavior for Copilot/Cursor/instructions.
- Fast onboarding: one playbook, many surfaces.

## Recommended Flow

1. Read task card and restate intent.
2. Identify architecture layers touched.
3. Implement minimal safe change.
4. Add tests for all behavior changes.
5. Run analyzer and tests.
6. Sync generated instruction files.
7. Publish compliance summary in PR.

## Golden Rule

If source policy changes, regenerate adapters before merge.
''';

const _promptPacksDoc = '''# AI Prompt Packs

## 1) Bug Fix Prompt

Goal: fix root cause with minimal safe change and regression test.

Template:
- Context:
- Expected behavior:
- Actual behavior:
- Reproduction steps:
- Constraints:
- Required tests:

## 2) New Feature Prompt

Goal: implement end-to-end feature using presentation/application/domain/data boundaries.

Template:
- User story:
- Inputs/outputs:
- Domain contracts:
- State transitions:
- Error cases:
- Test matrix:

## 3) Refactor Prompt

Goal: improve clarity and maintainability without behavior change.

Template:
- Current pain points:
- Keep behavior unchanged:
- Complexity hotspots:
- Extraction targets:
- Verification steps:

## 4) Performance Prompt

Goal: reduce frame drops and expensive rebuilds.

Template:
- Screen/flow:
- Current metrics:
- Suspected bottlenecks:
- Proposed optimizations:
- Validation metrics post-change:
''';

const _a11yDoc = '''# Accessibility Gates

## Required

- Semantic labels for critical interactive controls.
- Text-scale safety up to high accessibility scale.
- Contrast-safe foreground/background combinations.
- Focus order and keyboard navigation for major flows.

## Validation

- Widget tests for semantics where feasible.
- Manual pass for auth, checkout, and settings screens.
''';

const _apiContractDoc = '''# API Contract Standard

## Success Envelope

- success: true
- message: string
- data: object or array
- meta: optional object

## Error Envelope

- success: false
- error.code: string
- error.message: string
- error.details: optional object

## Rules

- Do not break envelope shape without migration plan.
- Keep code values stable for client branching.
- Use typed models and parsing tests.
''';

const _scaffoldingDoc = '''# Feature Scaffolding Standard

Every feature should include:

- domain/entities
- domain/repositories (interfaces)
- domain/usecases
- data/repositories (implementations)
- presentation/providers (@riverpod)
- presentation/pages/widgets
- tests (unit/widget/integration as needed)

Keep files focused and cohesive; avoid god classes.
''';

const _widgetCatalogDoc = '''# Global Widget Catalog

Document reusable widgets in one place and prefer reuse over local duplicates.

For each shared widget include:

- Purpose
- Inputs and defaults
- Theming behavior
- Accessibility notes
- Example usage snippet
''';

const _observabilityDoc = '''# Observability Acceptance Criteria

Critical flows must include:

- Structured logs for key state transitions
- Error capture with stack traces
- Latency measurement for network-bound operations
- Environment tagging (dev/staging/prod)

Avoid logging secrets, tokens, or personal data.
''';
