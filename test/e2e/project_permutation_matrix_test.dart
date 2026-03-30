import 'dart:io';

import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/generator/project_generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Project permutation matrix', () {
    late ProjectGenerator generator;
    late Directory tempRoot;

    setUp(() async {
      generator = ProjectGenerator(runFlutterBootstrap: false);
      tempRoot = await Directory.systemTemp.createTemp('project_matrix_test_');
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test(
      'core matrix: state x platform-set x graphql x ci',
      () async {
        final failures = <String>[];
        var total = 0;

        final platformSets = <List<TargetPlatform>>[
          [TargetPlatform.mobile],
          [TargetPlatform.web],
          [TargetPlatform.desktop],
          [TargetPlatform.mobile, TargetPlatform.web],
          [TargetPlatform.mobile, TargetPlatform.desktop],
          [TargetPlatform.web, TargetPlatform.desktop],
          [TargetPlatform.mobile, TargetPlatform.web, TargetPlatform.desktop],
        ];

        for (final state in StateManagement.values) {
          for (final platforms in platformSets) {
            for (final graphql in GraphqlClient.values) {
              for (final ci in CIProvider.values) {
                total++;
                final name = _buildAppName(
                  prefix: 'm$coreLabel',
                  state: state,
                  platforms: platforms,
                  graphql: graphql,
                  ci: ci,
                  sequence: total,
                );

                final config = BlueprintConfig(
                  appName: name,
                  stateManagement: state,
                  platforms: platforms,
                  graphqlClient: graphql,
                  ciProvider: ci,
                  includeTheme: true,
                  includeLocalization: false,
                  includeEnv: false,
                  includeApi: false,
                  includeTests: true,
                );

                final projectPath = p.join(tempRoot.path, name);
                final result = await generator.generate(config, projectPath);
                if (result.isFailure) {
                  failures.add('[core][$name] ${result.errorOrNull}');
                  continue;
                }

                if (!await Directory(projectPath).exists()) {
                  failures.add('[core][$name] target directory missing');
                }

                final manifestPath = p.join(projectPath, 'blueprint.yaml');
                if (!await File(manifestPath).exists()) {
                  failures.add('[core][$name] blueprint.yaml missing');
                }

                await _deleteIfExists(projectPath);
              }
            }
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Core matrix had ${failures.length} failures:\n${failures.join('\n')}',
        );
      },
      timeout: const Timeout(Duration(minutes: 20)),
    );

    test(
      'feature matrix: all boolean combinations on stable baseline',
      () async {
        final failures = <String>[];
        var total = 0;

        for (var mask = 0; mask < 256; mask++) {
          total++;

          final includeTheme = _bit(mask, 0);
          final includeLocalization = _bit(mask, 1);
          final includeEnv = _bit(mask, 2);
          final includeApi = _bit(mask, 3);
          final includeTests = _bit(mask, 4);
          final includeHive = _bit(mask, 5);
          final includePagination = _bit(mask, 6);
          final includeAccessibility = _bit(mask, 7);

          final appName = _shortName('f', total);

          final config = BlueprintConfig(
            appName: appName,
            stateManagement: StateManagement.riverpod,
            platforms: const [TargetPlatform.mobile],
            graphqlClient:
                includeApi ? GraphqlClient.graphqlFlutter : GraphqlClient.none,
            ciProvider: CIProvider.none,
            includeTheme: includeTheme,
            includeLocalization: includeLocalization,
            includeEnv: includeEnv,
            includeApi: includeApi,
            includeTests: includeTests,
            includeHive: includeHive,
            includePagination: includePagination,
            includeAccessibility: includeAccessibility,
            includeAnalytics: false,
            analyticsProvider: AnalyticsProvider.none,
          );

          final projectPath = p.join(tempRoot.path, appName);
          final result = await generator.generate(config, projectPath);
          if (result.isFailure) {
            failures
                .add('[feature][$appName mask=$mask] ${result.errorOrNull}');
            continue;
          }

          if (!await Directory(projectPath).exists()) {
            failures
                .add('[feature][$appName mask=$mask] target directory missing');
          }

          final manifestPath = p.join(projectPath, 'blueprint.yaml');
          if (!await File(manifestPath).exists()) {
            failures
                .add('[feature][$appName mask=$mask] blueprint.yaml missing');
          }

          await _deleteIfExists(projectPath);
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Feature matrix had ${failures.length} failures:\n${failures.join('\n')}',
        );
      },
      timeout: const Timeout(Duration(minutes: 25)),
    );
  });
}

const coreLabel = 'x';

bool _bit(int mask, int position) => (mask & (1 << position)) != 0;

String _shortName(String prefix, int sequence) => '${prefix}_$sequence';

String _buildAppName({
  required String prefix,
  required StateManagement state,
  required List<TargetPlatform> platforms,
  required GraphqlClient graphql,
  required CIProvider ci,
  required int sequence,
}) {
  final pCode = platforms.map((p) => p.name[0]).join();
  return '${prefix}_${state.name}_${pCode}_${graphql.label}_${ci.name}_$sequence';
}

Future<void> _deleteIfExists(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}
