/// Comprehensive combination tests for the two new features added in v2.1.0:
///   • GetX state management  (StateManagement.getx)
///   • GraphQL support        (GraphqlClient.graphqlFlutter | GraphqlClient.ferry)
///
/// Coverage matrix:
///   State ×  GraphQL  =  12 primary combinations
///   + pubspec dependency correctness across all templates
///   + generated file content quality checks
///
/// Run:  dart test test/e2e/new_features_combinations_test.dart
library;

import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/bloc_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/getx_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/provider_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/riverpod_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/template_bundle.dart';
import 'package:test/test.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────────────────

/// Returns only the files that would be written for [config] from [bundle].
List<TemplateFile> activeFiles(TemplateBundle bundle, BlueprintConfig config) =>
    bundle.files
        .where((f) => f.shouldGenerate == null || f.shouldGenerate!(config))
        .toList();

/// Returns the content of the pubspec.yaml file built with [config].
String pubspec(TemplateBundle bundle, BlueprintConfig config) =>
    bundle.files.firstWhere((f) => f.path.contains('pubspec.yaml')).build(
          config,
        );

/// Returns the built content of the named [path], or null if path not active.
String? fileContent(
    TemplateBundle bundle, BlueprintConfig config, String path) {
  final match = bundle.files.where(
    (f) => f.path.replaceAll('\\', '/').contains(path),
  );
  if (match.isEmpty) return null;
  final file = match.first;
  if (file.shouldGenerate != null && !file.shouldGenerate!(config)) return null;
  return file.build(config);
}

// ──────────────────────────────────────────────────────────────────────────────
// Convenience configs
// ──────────────────────────────────────────────────────────────────────────────

BlueprintConfig baseConfig({
  StateManagement state = StateManagement.getx,
  GraphqlClient graphql = GraphqlClient.none,
  bool api = false,
  bool theme = false,
  bool tests = false,
  bool localization = false,
  bool env = false,
}) =>
    BlueprintConfig(
      appName: '${state.name}_${graphql.name}_app',
      stateManagement: state,
      platforms: [TargetPlatform.mobile],
      includeApi: api,
      includeTheme: theme,
      includeTests: tests,
      includeLocalization: localization,
      includeEnv: env,
      graphqlClient: graphql,
    );

// ──────────────────────────────────────────────────────────────────────────────
// All 4 bundles indexed by state
// ──────────────────────────────────────────────────────────────────────────────

TemplateBundle bundleFor(StateManagement state) => switch (state) {
      StateManagement.getx => buildGetxMobileBundle(),
      StateManagement.riverpod => buildRiverpodMobileBundle(),
      StateManagement.bloc => buildBlocMobileBundle(),
      StateManagement.provider => buildProviderMobileBundle(),
    };

final allStates = StateManagement.values;

// ──────────────────────────────────────────────────────────────────────────────
// SECTION 1 — GetX state management (all 3 GraphQL options)
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  group('1. GetX state management', () {
    group('1a. getx + none (baseline)', () {
      final config = baseConfig();
      late TemplateBundle bundle;

      setUp(() => bundle = buildGetxMobileBundle());

      test('generates files', () {
        final files = activeFiles(bundle, config);
        expect(files, isNotEmpty, reason: 'GetX bundle must generate files');
      });

      test(
          'includes main.dart, pubspec.yaml, analysis_options.yaml, README, .gitignore',
          () {
        final paths = activeFiles(bundle, config).map((f) => f.path).toList();
        for (final required in [
          'main.dart',
          'pubspec.yaml',
          'analysis_options.yaml',
          'README.md',
          '.gitignore',
        ]) {
          expect(paths.any((p) => p.contains(required)), isTrue,
              reason: 'Missing: $required');
        }
      });

      test('pubspec contains get: dependency', () {
        final spec = pubspec(bundle, config);
        expect(spec, contains('get:'),
            reason: 'GetX pubspec must declare get: dependency');
      });

      test('no graphql files generated', () {
        final files = activeFiles(bundle, config);
        final graphqlFiles = files
            .where((f) =>
                f.path.toLowerCase().contains('graphql') ||
                f.path.contains('schema') ||
                f.path == 'build.yaml')
            .toList();
        expect(graphqlFiles, isEmpty,
            reason: 'No GraphQL files should exist when graphqlClient=none');
      });

      test('no graphql_flutter or ferry in pubspec', () {
        final spec = pubspec(bundle, config);
        expect(spec, isNot(contains('graphql_flutter:')));
        expect(spec, isNot(contains('ferry:')));
      });

      test('GetX content: GetxController, GetView, GetMaterialApp present', () {
        final files = activeFiles(bundle, config);
        final allContent = files.map((f) => f.build(config)).join('\n');
        expect(allContent, contains('GetxController'),
            reason: 'Missing GetxController');
        expect(allContent, contains('GetMaterialApp'),
            reason: 'Missing GetMaterialApp');
      });

      test('all active files produce non-empty content', () {
        for (final file in activeFiles(bundle, config)) {
          final content = file.build(config).trim();
          expect(content, isNotEmpty,
              reason: '${file.path} built empty content');
        }
      });
    });

    group('1b. getx + graphqlFlutter', () {
      final config = baseConfig(graphql: GraphqlClient.graphqlFlutter);
      late TemplateBundle bundle;

      setUp(() => bundle = buildGetxMobileBundle());

      test('graphql_client.dart is generated', () {
        final content = fileContent(bundle, config, 'graphql_client.dart');
        expect(content, isNotNull,
            reason: 'graphql_client.dart must be generated');
        expect(content!.trim(), isNotEmpty);
      });

      test('graphql_service.dart is generated', () {
        final content = fileContent(bundle, config, 'graphql_service.dart');
        expect(content, isNotNull,
            reason: 'graphql_service.dart must be generated');
        expect(content!.trim(), isNotEmpty);
      });

      test('example_queries.dart is generated', () {
        final content = fileContent(bundle, config, 'example_queries.dart');
        expect(content, isNotNull,
            reason: 'example_queries.dart must be generated');
        expect(content!.trim(), isNotEmpty);
      });

      test('example_mutations.dart is generated', () {
        final content = fileContent(bundle, config, 'example_mutations.dart');
        expect(content, isNotNull,
            reason: 'example_mutations.dart must be generated');
        expect(content!.trim(), isNotEmpty);
      });

      test('ferry files NOT generated for graphqlFlutter', () {
        expect(fileContent(bundle, config, 'schema.graphql'), isNull,
            reason: 'schema.graphql should not appear for graphqlFlutter');
        expect(fileContent(bundle, config, 'example.graphql'), isNull,
            reason: 'example.graphql should not appear for graphqlFlutter');
      });

      test('pubspec contains graphql_flutter dep', () {
        expect(pubspec(bundle, config), contains('graphql_flutter:'));
      });

      test('pubspec does NOT contain ferry dep', () {
        expect(pubspec(bundle, config), isNot(contains('ferry:')));
      });

      test('graphql_client.dart contains GraphQLClient setup code', () {
        final content = fileContent(bundle, config, 'graphql_client.dart')!;
        expect(content, contains('GraphQLClient'),
            reason: 'graphql_client.dart must set up GraphQLClient');
      });
    });

    group('1c. getx + ferry', () {
      final config = baseConfig(graphql: GraphqlClient.ferry);
      late TemplateBundle bundle;

      setUp(() => bundle = buildGetxMobileBundle());

      test('schema.graphql is generated', () {
        final content = fileContent(bundle, config, 'schema.graphql');
        expect(content, isNotNull,
            reason: 'schema.graphql must be generated for ferry');
        expect(content!.trim(), isNotEmpty);
      });

      test('operations/example.graphql is generated', () {
        final content = fileContent(bundle, config, 'example.graphql');
        expect(content, isNotNull,
            reason: 'example.graphql must be generated for ferry');
        expect(content!.trim(), isNotEmpty);
      });

      test('build.yaml is generated', () {
        final content = fileContent(bundle, config, 'build.yaml');
        expect(content, isNotNull,
            reason: 'build.yaml must be generated for ferry');
        expect(content!.trim(), isNotEmpty);
      });

      test('graphql_flutter files NOT generated for ferry', () {
        expect(fileContent(bundle, config, 'example_queries.dart'), isNull,
            reason: 'example_queries.dart should not appear for ferry');
        expect(fileContent(bundle, config, 'example_mutations.dart'), isNull,
            reason: 'example_mutations.dart should not appear for ferry');
      });

      test('pubspec has ferry, ferry_flutter, gql_http_link', () {
        final spec = pubspec(bundle, config);
        expect(spec, contains('ferry:'), reason: 'Missing ferry:');
        expect(spec, contains('ferry_flutter:'),
            reason: 'Missing ferry_flutter:');
        expect(spec, contains('gql_http_link:'),
            reason: 'Missing gql_http_link:');
      });

      test('pubspec does NOT contain graphql_flutter dep', () {
        expect(pubspec(bundle, config), isNot(contains('graphql_flutter:')));
      });

      test('schema.graphql has type definitions', () {
        final content = fileContent(bundle, config, 'schema.graphql')!;
        expect(content, contains('type '),
            reason: 'schema.graphql must contain type definitions');
      });

      test('build.yaml has ferry builder config', () {
        final content = fileContent(bundle, config, 'build.yaml')!;
        expect(content, contains('ferry'),
            reason: 'build.yaml must configure ferry code generation');
      });
    });

    group('1d. getx + full combo (api + theme + tests)', () {
      final config = baseConfig(
        api: true,
        theme: true,
        tests: true,
        localization: false,
        env: true,
      );
      late TemplateBundle bundle;

      setUp(() => bundle = buildGetxMobileBundle());

      test('generates more files with all features enabled', () {
        final baseCount = activeFiles(bundle, baseConfig()).length;
        final fullCount = activeFiles(bundle, config).length;
        expect(fullCount, greaterThan(baseCount),
            reason: 'Full-featured build should generate more files than base');
      });

      test('env_loader.dart generated with includeEnv', () {
        final paths = activeFiles(bundle, config).map((f) => f.path).toList();
        expect(paths.any((p) => p.contains('env_loader')), isTrue,
            reason: 'env_loader.dart must be generated when includeEnv=true');
      });

      test('all active files produce non-empty content', () {
        for (final file in activeFiles(bundle, config)) {
          final content = file.build(config).trim();
          expect(content, isNotEmpty,
              reason: '${file.path} built empty content');
        }
      });
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // SECTION 2 — GraphQL with all 4 state managers
  // ────────────────────────────────────────────────────────────────────────────

  group('2. GraphQL across all state managers', () {
    group('2a. All templates + graphqlFlutter', () {
      for (final state in allStates) {
        test('${state.name}: graphql_client.dart generated', () {
          final config =
              baseConfig(state: state, graphql: GraphqlClient.graphqlFlutter);
          final bundle = bundleFor(state);
          final content = fileContent(bundle, config, 'graphql_client.dart');
          expect(content, isNotNull,
              reason:
                  '${state.name}: graphql_client.dart must be generated with graphqlFlutter');
          expect(content!.trim(), isNotEmpty);
        });

        test('${state.name}: graphql_service.dart generated', () {
          final config =
              baseConfig(state: state, graphql: GraphqlClient.graphqlFlutter);
          final bundle = bundleFor(state);
          final content = fileContent(bundle, config, 'graphql_service.dart');
          expect(content, isNotNull,
              reason:
                  '${state.name}: graphql_service.dart must be generated with graphqlFlutter');
          expect(content!.trim(), isNotEmpty);
        });

        test('${state.name}: example_queries.dart generated', () {
          final config =
              baseConfig(state: state, graphql: GraphqlClient.graphqlFlutter);
          final bundle = bundleFor(state);
          final content = fileContent(bundle, config, 'example_queries.dart');
          expect(content, isNotNull,
              reason:
                  '${state.name}: example_queries.dart must be generated with graphqlFlutter');
          expect(content!.trim(), isNotEmpty);
        });

        test('${state.name}: example_mutations.dart generated', () {
          final config =
              baseConfig(state: state, graphql: GraphqlClient.graphqlFlutter);
          final bundle = bundleFor(state);
          final content = fileContent(bundle, config, 'example_mutations.dart');
          expect(content, isNotNull,
              reason:
                  '${state.name}: example_mutations.dart must be generated with graphqlFlutter');
          expect(content!.trim(), isNotEmpty);
        });

        test('${state.name}: pubspec has graphql_flutter dep', () {
          final config =
              baseConfig(state: state, graphql: GraphqlClient.graphqlFlutter);
          final bundle = bundleFor(state);
          expect(pubspec(bundle, config), contains('graphql_flutter:'));
        });

        test('${state.name}: no ferry files generated', () {
          final config =
              baseConfig(state: state, graphql: GraphqlClient.graphqlFlutter);
          final bundle = bundleFor(state);
          expect(fileContent(bundle, config, 'schema.graphql'), isNull);
          expect(fileContent(bundle, config, 'build.yaml'), isNull);
        });
      }
    });

    group('2b. All templates + ferry', () {
      for (final state in allStates) {
        test('${state.name}: schema.graphql generated', () {
          final config = baseConfig(state: state, graphql: GraphqlClient.ferry);
          final bundle = bundleFor(state);
          final content = fileContent(bundle, config, 'schema.graphql');
          expect(content, isNotNull,
              reason:
                  '${state.name}: schema.graphql must be generated with ferry');
          expect(content!.trim(), isNotEmpty);
        });

        test('${state.name}: operations/example.graphql generated', () {
          final config = baseConfig(state: state, graphql: GraphqlClient.ferry);
          final bundle = bundleFor(state);
          final content = fileContent(bundle, config, 'example.graphql');
          expect(content, isNotNull,
              reason:
                  '${state.name}: example.graphql must be generated with ferry');
          expect(content!.trim(), isNotEmpty);
        });

        test('${state.name}: build.yaml generated', () {
          final config = baseConfig(state: state, graphql: GraphqlClient.ferry);
          final bundle = bundleFor(state);
          final content = fileContent(bundle, config, 'build.yaml');
          expect(content, isNotNull,
              reason: '${state.name}: build.yaml must be generated with ferry');
          expect(content!.trim(), isNotEmpty);
        });

        test('${state.name}: no graphqlFlutter files generated', () {
          final config = baseConfig(state: state, graphql: GraphqlClient.ferry);
          final bundle = bundleFor(state);
          expect(fileContent(bundle, config, 'example_queries.dart'), isNull);
          expect(fileContent(bundle, config, 'example_mutations.dart'), isNull);
        });
      }
    });

    group('2c. All templates + none (no GraphQL)', () {
      for (final state in allStates) {
        test('${state.name}: zero graphql files with none', () {
          final config = baseConfig(state: state);
          final bundle = bundleFor(state);
          final active = activeFiles(bundle, config);
          final graphqlFiles = active.where((f) {
            final p = f.path.replaceAll('\\', '/').toLowerCase();
            return p.contains('graphql') ||
                p.contains('schema') ||
                p == 'build.yaml';
          }).toList();
          expect(graphqlFiles, isEmpty,
              reason:
                  '${state.name}: no graphql files when graphqlClient=none');
        });

        test('${state.name}: pubspec has no graphql/ferry deps with none', () {
          final config = baseConfig(state: state);
          final bundle = bundleFor(state);
          final spec = pubspec(bundle, config);
          expect(spec, isNot(contains('graphql_flutter:')));
          expect(spec, isNot(contains('ferry:')));
        });
      }
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // SECTION 3 — Pubspec dependency quality & consistency
  // ────────────────────────────────────────────────────────────────────────────

  group('3. Pubspec dependency correctness', () {
    group('3a. GetX: get: dependency present in all getx-state configs', () {
      for (final graphql in GraphqlClient.values) {
        test('getx + ${graphql.name}: has get: dep', () {
          final config = baseConfig(graphql: graphql);
          final bundle = buildGetxMobileBundle();
          expect(pubspec(bundle, config), contains('get:'),
              reason: 'get: dependency must always be present for GetX');
        });
      }
    });

    group('3b. Ferry version consistency (all templates → ^0.16.1+2)', () {
      for (final state in allStates) {
        test('${state.name} + ferry: uses ferry ^0.16.1+2', () {
          final config = baseConfig(state: state, graphql: GraphqlClient.ferry);
          final bundle = bundleFor(state);
          final spec = pubspec(bundle, config);
          expect(spec, contains('ferry: ^0.16.1+2'),
              reason:
                  '${state.name}: ferry version must be ^0.16.1+2 for consistency');
        });
      }
    });

    group('3c. ferry_flutter present in all ferry templates', () {
      for (final state in allStates) {
        test('${state.name} + ferry: has ferry_flutter dep', () {
          final config = baseConfig(state: state, graphql: GraphqlClient.ferry);
          final bundle = bundleFor(state);
          expect(pubspec(bundle, config), contains('ferry_flutter:'),
              reason: '${state.name}: ferry_flutter must be in pubspec');
        });
      }
    });

    group('3d. gql_http_link present in all ferry templates', () {
      for (final state in allStates) {
        test('${state.name} + ferry: has gql_http_link dep', () {
          final config = baseConfig(state: state, graphql: GraphqlClient.ferry);
          final bundle = bundleFor(state);
          expect(pubspec(bundle, config), contains('gql_http_link:'),
              reason: '${state.name}: gql_http_link must be in pubspec');
        });
      }
    });

    group('3e. graphql_flutter version consistency (all templates → ^5.1.2)',
        () {
      for (final state in allStates) {
        test('${state.name} + graphqlFlutter: uses graphql_flutter ^5.1.2', () {
          final config =
              baseConfig(state: state, graphql: GraphqlClient.graphqlFlutter);
          final bundle = bundleFor(state);
          final spec = pubspec(bundle, config);
          expect(spec, contains('graphql_flutter: ^5.1.2'),
              reason:
                  'graphql_flutter version must be ^5.1.2 across all templates');
        });
      }
    });
  });

  // ────────────────────────────────────────────────────────────────────────────
  // SECTION 4 — Content quality checks
  // ────────────────────────────────────────────────────────────────────────────

  group('4. Generated file content quality', () {
    group('4a. GetX-specific content quality', () {
      final config = baseConfig();
      final bundle = buildGetxMobileBundle();

      test('has GetxController in generated code', () {
        final allContent =
            activeFiles(bundle, config).map((f) => f.build(config)).join('\n');
        expect(allContent, contains('GetxController'));
      });

      test('has Obx or GetX widget in generated code', () {
        final allContent =
            activeFiles(bundle, config).map((f) => f.build(config)).join('\n');
        expect(allContent, anyOf(contains('Obx('), contains('GetX<')));
      });

      test('has GetMaterialApp in generated code', () {
        final allContent =
            activeFiles(bundle, config).map((f) => f.build(config)).join('\n');
        expect(allContent, contains('GetMaterialApp'));
      });

      test('Get.toNamed used for navigation', () {
        final allContent =
            activeFiles(bundle, config).map((f) => f.build(config)).join('\n');
        expect(allContent, contains('Get.toNamed'));
      });
    });

    group('4b. graphql_flutter content quality', () {
      final config = baseConfig(graphql: GraphqlClient.graphqlFlutter);

      test('graphql_client.dart sets up GraphQLClient', () {
        final content = fileContent(
            buildGetxMobileBundle(), config, 'graphql_client.dart')!;
        expect(content, contains('GraphQLClient'));
      });

      test('graphql_service.dart contains query and mutate methods', () {
        final content = fileContent(
            buildGetxMobileBundle(), config, 'graphql_service.dart')!;
        expect(content, anyOf(contains('query('), contains('mutate(')));
      });

      test('example_queries.dart has at least one query string', () {
        final content = fileContent(
            buildGetxMobileBundle(), config, 'example_queries.dart')!;
        expect(content, contains('query'));
      });
    });

    group('4c. ferry content quality', () {
      final config = baseConfig(graphql: GraphqlClient.ferry);

      test('schema.graphql has type keyword', () {
        final content =
            fileContent(buildGetxMobileBundle(), config, 'schema.graphql')!;
        expect(content, contains('type '));
      });

      test('example.graphql has query or mutation', () {
        final content =
            fileContent(buildGetxMobileBundle(), config, 'example.graphql')!;
        expect(content, anyOf(contains('query'), contains('mutation')));
      });

      test('build.yaml references ferry builder(s)', () {
        final content =
            fileContent(buildGetxMobileBundle(), config, 'build.yaml')!;
        expect(content, contains('ferry'));
      });
    });

    group('4d. Consistent structure across all state managers', () {
      const essentialFiles = [
        'main.dart',
        'pubspec.yaml',
        'analysis_options.yaml',
        'README.md',
        '.gitignore',
      ];

      for (final state in allStates) {
        test('${state.name}: has all essential files', () {
          final config = baseConfig(state: state);
          final bundle = bundleFor(state);
          final paths = activeFiles(bundle, config).map((f) => f.path).toList();
          for (final required in essentialFiles) {
            expect(paths.any((p) => p.contains(required)), isTrue,
                reason: '${state.name}: missing $required');
          }
        });
      }

      for (final state in allStates) {
        test('${state.name}: all active files non-empty', () {
          final config = baseConfig(state: state);
          final bundle = bundleFor(state);
          for (final file in activeFiles(bundle, config)) {
            expect(file.build(config).trim(), isNotEmpty,
                reason: '${state.name}: ${file.path} built empty content');
          }
        });
      }
    });
  });
}
