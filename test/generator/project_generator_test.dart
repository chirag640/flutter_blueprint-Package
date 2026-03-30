import 'dart:async';
import 'dart:io';

import 'package:flutter_blueprint/src/generator/project_generator.dart';
import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ProjectGenerator', () {
    late ProjectGenerator generator;
    late Directory tempDir;

    setUp(() async {
      generator = ProjectGenerator(runFlutterBootstrap: false);
      tempDir = await Directory.systemTemp.createTemp('project_gen_test_');
    });

    tearDown(() async {
      await _deleteDirectoryWithRetry(tempDir);
    });

    test('creates instance with default dependencies', () {
      expect(generator, isNotNull);
    });

    test('generates mobile project with riverpod', () async {
      final config = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'test_app');
      final result = await generator.generate(config, targetPath);

      if (result.isFailure) {
        print('Generation failed: ${result.errorOrNull}');
      }
      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.filesGenerated, greaterThan(0));
      expect(p.normalize(value.targetPath), equals(p.normalize(targetPath)));
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('generates mobile project with provider', () async {
      final config = BlueprintConfig(
        appName: 'provider_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'provider_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.filesGenerated, greaterThan(0));
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('generates mobile project with bloc', () async {
      final config = BlueprintConfig(
        appName: 'bloc_app',
        stateManagement: StateManagement.bloc,
        platforms: [TargetPlatform.mobile],
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'bloc_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.filesGenerated, greaterThan(0));
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('generates web project', () async {
      final config = BlueprintConfig(
        appName: 'web_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.web],
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'web_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.filesGenerated, greaterThan(0));
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('generates desktop project', () async {
      final config = BlueprintConfig(
        appName: 'desktop_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.desktop],
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'desktop_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.filesGenerated, greaterThan(0));
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('generates multi-platform project', () async {
      final config = BlueprintConfig(
        appName: 'multi_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile, TargetPlatform.web],
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'multi_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.filesGenerated, greaterThan(0));
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('generates project with GitHub CI', () async {
      final config = BlueprintConfig(
        appName: 'ci_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
        ciProvider: CIProvider.github,
      );

      final targetPath = p.join(tempDir.path, 'ci_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.ciConfigGenerated, isTrue);
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('generates project with API configuration', () async {
      final config = BlueprintConfig(
        appName: 'api_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'api_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      final value = result.valueOrThrow;
      expect(value.filesGenerated, greaterThan(0));
      expect(Directory(targetPath).existsSync(), isTrue);
    });

    test('scaffolds AI governance files when enabled', () async {
      final config = BlueprintConfig(
        appName: 'gov_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
        includeAiGovernance: true,
        aiGovernanceLevel: AIGovernanceLevel.full,
        aiOwner: '@example-owner',
      );

      final targetPath = p.join(tempDir.path, 'gov_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      expect(
          File(p.join(
                  targetPath, '.github', 'ai', 'flutter-enterprise-policy.md'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(targetPath, '.cursor', 'rules', 'flutter-enterprise.mdc'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(targetPath, '.github', 'workflows',
                  'ai-policy-sync-check.yml'))
              .existsSync(),
          isTrue);
    });

    test('applies selected ai ci mode to generated governance assets',
        () async {
      final config = BlueprintConfig(
        appName: 'gov_ci_mode_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: true,
        includeApi: false,
        includeTests: true,
        includeAiGovernance: true,
        aiGovernanceLevel: AIGovernanceLevel.full,
        aiCiMode: AICiMode.blocking,
      );

      final targetPath = p.join(tempDir.path, 'gov_ci_mode_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);

      final policy = File(
        p.join(targetPath, '.github', 'ai', 'flutter-enterprise-policy.md'),
      ).readAsStringSync();
      final syncScript =
          File(p.join(targetPath, 'scripts', 'sync_ai_rules.ps1'))
              .readAsStringSync();
      final guardrailsWorkflow = File(
        p.join(
          targetPath,
          '.github',
          'workflows',
          'engineering-guardrails.yml',
        ),
      ).readAsStringSync();

      expect(policy, contains('CI policy mode: blocking'));
      expect(policy, contains('Active mode in this project: blocking.'));
      expect(syncScript, contains('CI mode for this template: blocking.'));
      expect(syncScript, contains('Current CI mode: blocking.'));
      expect(guardrailsWorkflow, contains('MODE="blocking"'));
    });

    test('generates stack-specific policy snippet and MASVS checklist',
        () async {
      final config = BlueprintConfig(
        appName: 'gov_provider_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
        includeHive: true,
        includePushNotifications: true,
        includeAiGovernance: true,
        aiGovernanceLevel: AIGovernanceLevel.standard,
      );

      final targetPath = p.join(tempDir.path, 'gov_provider_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);

      final policy = File(
        p.join(targetPath, '.github', 'ai', 'flutter-enterprise-policy.md'),
      ).readAsStringSync();
      final masvsChecklist =
          File(p.join(targetPath, 'docs', 'engineering', 'masvs-checklist.md'))
              .readAsStringSync();

      expect(policy, contains('Provider implementation baseline:'));
      expect(policy, isNot(contains('Riverpod implementation baseline:')));
      expect(masvsChecklist, contains('MASVS / MASWE Traceability Checklist'));
      expect(masvsChecklist, contains('NETWORK'));
      expect(masvsChecklist,
          contains('Insecure at-rest storage and key management'));
      expect(masvsChecklist,
          contains('Unsafe platform channel/deep-link handling'));
    });

    test('scaffolds production release security and reproducibility assets',
        () async {
      final config = BlueprintConfig(
        appName: 'release_ready_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, 'release_ready_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      expect(
        File(p.join(targetPath, 'docs', 'release', 'secure-builds.md'))
            .existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(targetPath, 'docs', 'engineering', 'reproducible-builds.md'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(targetPath, 'scripts', 'release', 'build_secure_android.sh'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(targetPath, 'docs', 'release', 'symbolication-workflow.md'),
        ).existsSync(),
        isTrue,
      );
    });

    test('scaffolds sentry observability tagging helper when sentry is enabled',
        () async {
      final config = BlueprintConfig(
        appName: 'sentry_obs_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: true,
        includeApi: false,
        includeTests: true,
        includeAnalytics: true,
        analyticsProvider: AnalyticsProvider.sentry,
      );

      final targetPath = p.join(tempDir.path, 'sentry_obs_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);

      final sentryHelper = File(
        p.join(
          targetPath,
          'lib',
          'core',
          'analytics',
          'sentry_release_context.dart',
        ),
      );
      expect(sentryHelper.existsSync(), isTrue);
      expect(
        sentryHelper.readAsStringSync(),
        contains("String.fromEnvironment('APP_RELEASE'"),
      );
    });

    test('adds github dependency drift and dependabot guardrails', () async {
      final config = BlueprintConfig(
        appName: 'github_guardrails_app',
        stateManagement: StateManagement.provider,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
        ciProvider: CIProvider.github,
      );

      final targetPath = p.join(tempDir.path, 'github_guardrails_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      expect(
        File(p.join(targetPath, '.github', 'dependabot.yml')).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(targetPath, '.github', 'workflows', 'dependency-drift.yml'),
        ).existsSync(),
        isTrue,
      );
    });

    test('runs matrix regression on high-risk feature combinations', () async {
      final scenarios = <BlueprintConfig>[
        BlueprintConfig(
          appName: 'matrix_getx_gql_ferry_guardrails',
          stateManagement: StateManagement.getx,
          platforms: [TargetPlatform.mobile, TargetPlatform.web],
          includeTheme: true,
          includeLocalization: true,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
          includeHive: true,
          includeAnalytics: true,
          analyticsProvider: AnalyticsProvider.sentry,
          includeWebSocket: true,
          includeAiGovernance: true,
          aiGovernanceLevel: AIGovernanceLevel.standard,
          graphqlClient: GraphqlClient.ferry,
          ciProvider: CIProvider.github,
        ),
        BlueprintConfig(
          appName: 'matrix_bloc_push_maps',
          stateManagement: StateManagement.bloc,
          platforms: [TargetPlatform.mobile],
          includeTheme: true,
          includeLocalization: false,
          includeEnv: true,
          includeApi: true,
          includeTests: true,
          includePushNotifications: true,
          includeMedia: true,
          includeMaps: true,
          includeAiGovernance: true,
          aiGovernanceLevel: AIGovernanceLevel.full,
          ciProvider: CIProvider.github,
        ),
      ];

      for (final scenario in scenarios) {
        final targetPath = p.join(tempDir.path, scenario.appName);
        final result = await generator.generate(scenario, targetPath);
        expect(result.isSuccess, isTrue,
            reason: 'Scenario failed: ${scenario.appName}');
        expect(Directory(targetPath).existsSync(), isTrue);

        // Guardrails introduced by production readiness scaffolder.
        expect(
          File(
            p.join(targetPath, 'docs', 'release', 'secure-builds.md'),
          ).existsSync(),
          isTrue,
          reason: 'Missing secure build docs for ${scenario.appName}',
        );

        if (scenario.ciProvider == CIProvider.github) {
          expect(
            File(
              p.join(targetPath, '.github', 'dependabot.yml'),
            ).existsSync(),
            isTrue,
            reason: 'Missing Dependabot guardrail for ${scenario.appName}',
          );
        }

        if (scenario.includeAnalytics &&
            scenario.analyticsProvider == AnalyticsProvider.sentry) {
          expect(
            File(
              p.join(
                targetPath,
                'lib',
                'core',
                'analytics',
                'sentry_release_context.dart',
              ),
            ).existsSync(),
            isTrue,
            reason: 'Missing Sentry release context for ${scenario.appName}',
          );
        }
      }
    });

    test('does not scaffold AI governance files when disabled', () async {
      final config = BlueprintConfig(
        appName: 'no_gov_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
        includeAiGovernance: false,
      );

      final targetPath = p.join(tempDir.path, 'no_gov_app');
      final result = await generator.generate(config, targetPath);

      expect(result.isSuccess, isTrue);
      expect(
          File(p.join(
                  targetPath, '.github', 'ai', 'flutter-enterprise-policy.md'))
              .existsSync(),
          isFalse);
      expect(
          File(p.join(targetPath, '.cursor', 'rules', 'flutter-enterprise.mdc'))
              .existsSync(),
          isFalse);
    });

    test('fails with invalid app name', () async {
      final config = BlueprintConfig(
        appName: '123invalid',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: false,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      final targetPath = p.join(tempDir.path, '123invalid');
      final result = await generator.generate(config, targetPath);

      expect(result.isFailure, isTrue);
    });

    test('validates app name format', () {
      final config = BlueprintConfig(
        appName: 'test_app',
        stateManagement: StateManagement.riverpod,
        platforms: [TargetPlatform.mobile],
        includeTheme: true,
        includeLocalization: false,
        includeEnv: false,
        includeApi: false,
        includeTests: true,
      );

      expect(config.appName, equals('test_app'));
      expect(config.stateManagement, equals(StateManagement.riverpod));
    });
  }, timeout: const Timeout(Duration(minutes: 8)));

  group('GenerationResult', () {
    test('creates result with file count', () {
      final result = GenerationResult(
        filesGenerated: 50,
        targetPath: '/path/to/project',
      );

      expect(result.filesGenerated, equals(50));
      expect(result.targetPath, equals('/path/to/project'));
    });

    test('includes CI configuration flag', () {
      final result = GenerationResult(
        filesGenerated: 55,
        targetPath: '/path/to/project',
        ciConfigGenerated: true,
      );

      expect(result.ciConfigGenerated, isTrue);
    });

    test('toString provides useful info', () {
      final result = GenerationResult(
        filesGenerated: 42,
        targetPath: '/test/path',
      );

      expect(result.toString(), contains('42 files'));
      expect(result.toString(), contains('/test/path'));
    });
  });
}

Future<void> _deleteDirectoryWithRetry(Directory directory) async {
  const maxAttempts = 8;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    if (!await directory.exists()) {
      return;
    }

    try {
      await directory.delete(recursive: true);
      return;
    } on FileSystemException {
      if (attempt == maxAttempts) {
        // Non-fatal in tests: Windows file handles from spawned processes
        // can linger briefly and cause transient cleanup failures.
        return;
      }
      await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
    }
  }
}
