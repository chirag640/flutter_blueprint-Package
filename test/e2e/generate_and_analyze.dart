/// Generates real project files for all new-feature combinations and produces
/// a deep analysis report comparing expected vs actual output.
///
/// Run: dart test/e2e/generate_and_analyze.dart
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/generator/project_generator.dart';

// ──────────────────────────────────────────────────────────────────────────────

final generator = ProjectGenerator();
final outDir = p.join(Directory.systemTemp.path, 'fbp_analysis');
final reportLines = <String>[];
int passCount = 0;
int failCount = 0;

// ──────────────────────────────────────────────────────────────────────────────

void log(String line) {
  print(line);
  reportLines.add(line);
}

void pass(String label) {
  passCount++;
  log('  ✅  $label');
}

void fail(String label, String detail) {
  failCount++;
  log('  ❌  $label');
  log('      → $detail');
}

void section(String title) => log('\n## $title');
void sub(String title) => log('\n### $title');

// ──────────────────────────────────────────────────────────────────────────────

Future<String> generate(BlueprintConfig cfg) async {
  final target = p.join(outDir, cfg.appName);
  if (Directory(target).existsSync()) {
    Directory(target).deleteSync(recursive: true);
  }
  final result = await generator.generate(cfg, target);
  if (result.isFailure) {
    throw Exception('Generation failed: ${result.errorOrNull}');
  }
  return target;
}

// ──────────────────────────────────────────────────────────────────────────────
// Inspection helpers
// ──────────────────────────────────────────────────────────────────────────────

const _textExt = {
  '.dart',
  '.yaml',
  '.yml',
  '.json',
  '.md',
  '.txt',
  '.graphql',
  '.gradle',
  '.xml',
  '.html',
  '.css',
  '.ts',
  '.js',
  '.sh',
  '.ps1',
  '.env',
  '.gitignore',
  '.properties',
  '.kt',
  '.swift',
  '.pbxproj',
  '.plist',
  '.entitlements',
};

bool _isText(FileSystemEntity f) =>
    _textExt.contains(p.extension(f.path).toLowerCase());

List<FileSystemEntity> allFiles(String dir) =>
    Directory(dir).listSync(recursive: true).whereType<File>().toList();

String read(String path) =>
    File(path).existsSync() ? File(path).readAsStringSync() : '';

void checkFile(String projectDir, String relativePath, String label,
    {List<String> mustContain = const [],
    List<String> mustNotContain = const []}) {
  final abs = p.join(projectDir, relativePath.replaceAll('/', p.separator));
  if (!File(abs).existsSync()) {
    fail('$label — file exists: $relativePath', 'File not found');
    return;
  }
  pass('$label — file exists: $relativePath');
  final content = File(abs).readAsStringSync();
  for (final needle in mustContain) {
    if (content.contains(needle)) {
      pass('$label — contains "$needle"');
    } else {
      fail('$label — contains "$needle"',
          'Not found in ${p.basename(relativePath)}');
    }
  }
  for (final needle in mustNotContain) {
    if (!content.contains(needle)) {
      pass('$label — does NOT contain "$needle"');
    } else {
      fail('$label — does NOT contain "$needle"',
          'Found unexpected "$needle" in ${p.basename(relativePath)}');
    }
  }
}

void checkFileAbsent(String projectDir, String relativePath, String label) {
  final abs = p.join(projectDir, relativePath.replaceAll('/', p.separator));
  if (!File(abs).existsSync()) {
    pass('$label — correctly absent: $relativePath');
  } else {
    fail('$label — should be absent: $relativePath',
        'File was unexpectedly generated');
  }
}

void checkPubspec(String projectDir, String label,
    {List<String> deps = const [], List<String> noDeps = const []}) {
  final spec = read(p.join(projectDir, 'pubspec.yaml'));
  for (final dep in deps) {
    if (spec.contains(dep)) {
      pass('$label — pubspec has "$dep"');
    } else {
      fail('$label — pubspec has "$dep"', 'Not found in pubspec.yaml');
    }
  }
  for (final dep in noDeps) {
    if (!spec.contains(dep)) {
      pass('$label — pubspec does NOT have "$dep"');
    } else {
      fail('$label — pubspec does NOT have "$dep"',
          'Unexpected dependency "$dep" in pubspec.yaml');
    }
  }
}

void analyzeStructure(String projectDir, String label) {
  final allF = allFiles(projectDir);
  final count = allF.length;
  log('  📦  $label: $count files generated');

  final libFiles = allF
      .where((f) => f.path.contains('${p.separator}lib${p.separator}'))
      .length;
  final testFiles = allF
      .where((f) => f.path.contains('${p.separator}test${p.separator}'))
      .length;
  log('      lib/ files: $libFiles | test/ files: $testFiles');

  // Only inspect text files to avoid crashing on binary assets
  final textFiles = allF.where(_isText).whereType<File>().toList();

  // Check no empty text files
  final emptyFiles = textFiles
      .where((f) => f.readAsStringSync().trim().isEmpty)
      .map((f) => p.relative(f.path, from: projectDir))
      .toList();
  if (emptyFiles.isEmpty) {
    pass('$label — no empty text files');
  } else {
    fail('$label — no empty text files', 'Empty: ${emptyFiles.join(', ')}');
  }

  // Check dart files have no obvious placeholder tokens
  final dartFiles = textFiles.where((f) => f.path.endsWith('.dart'));
  final badFiles = <String>[];
  for (final f in dartFiles) {
    final c = f.readAsStringSync();
    if (c.contains('TODO: implement') ||
        c.contains('throw UnimplementedError()')) {
      badFiles.add(p.relative(f.path, from: projectDir));
    }
  }
  if (badFiles.isEmpty) {
    pass('$label — no unimplemented stubs in generated Dart files');
  } else {
    fail('$label — no unimplemented stubs', 'Found in: ${badFiles.join(', ')}');
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Combination runners
// ──────────────────────────────────────────────────────────────────────────────

Future<void> analyzeGetxNone() async {
  sub('GetX + none (baseline)');
  final cfg = BlueprintConfig(
    appName: 'getx_none',
    stateManagement: StateManagement.getx,
    platforms: [TargetPlatform.mobile],
    includeApi: false,
    includeTheme: false,
    includeTests: false,
    includeLocalization: false,
    includeEnv: false,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'getx_none');
  checkFile(dir, 'pubspec.yaml', 'getx_none',
      mustContain: ['get:'], mustNotContain: ['graphql_flutter:', 'ferry:']);
  checkFile(dir, 'lib/main.dart', 'getx_none');
  checkFile(dir, 'lib/app/app.dart', 'getx_none',
      mustContain: ['GetMaterialApp']);
  checkFileAbsent(dir, 'lib/core/graphql/graphql_client.dart', 'getx_none');
  checkFileAbsent(dir, 'build.yaml', 'getx_none');
  checkPubspec(dir, 'getx_none',
      deps: ['get:'], noDeps: ['graphql_flutter:', 'ferry:']);
}

Future<void> analyzeGetxGraphqlFlutter() async {
  sub('GetX + graphql_flutter');
  final cfg = BlueprintConfig(
    appName: 'getx_gql_flutter',
    stateManagement: StateManagement.getx,
    platforms: [TargetPlatform.mobile],
    includeApi: false,
    includeTheme: false,
    includeTests: false,
    includeLocalization: false,
    includeEnv: false,
    graphqlClient: GraphqlClient.graphqlFlutter,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'getx_gql_flutter');
  checkFile(dir, 'lib/core/graphql/graphql_client.dart', 'getx_gql_flutter',
      mustContain: ['GraphQLClient']);
  checkFile(dir, 'lib/core/graphql/graphql_service.dart', 'getx_gql_flutter');
  checkFile(
      dir, 'lib/core/graphql/queries/example_queries.dart', 'getx_gql_flutter',
      mustContain: ['query']);
  checkFile(dir, 'lib/core/graphql/mutations/example_mutations.dart',
      'getx_gql_flutter',
      mustContain: ['mutation']);
  checkFileAbsent(dir, 'lib/core/graphql/schema.graphql', 'getx_gql_flutter');
  checkFileAbsent(dir, 'build.yaml', 'getx_gql_flutter');
  checkPubspec(dir, 'getx_gql_flutter',
      deps: ['get:', 'graphql_flutter: ^5.1.2'],
      noDeps: ['ferry:', 'gql_http_link:']);
}

Future<void> analyzeGetxFerry() async {
  sub('GetX + ferry');
  final cfg = BlueprintConfig(
    appName: 'getx_ferry',
    stateManagement: StateManagement.getx,
    platforms: [TargetPlatform.mobile],
    includeApi: false,
    includeTheme: false,
    includeTests: false,
    includeLocalization: false,
    includeEnv: false,
    graphqlClient: GraphqlClient.ferry,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'getx_ferry');
  checkFile(dir, 'lib/core/graphql/graphql_client.dart', 'getx_ferry',
      mustContain: ['Client']);
  checkFile(dir, 'lib/core/graphql/graphql_service.dart', 'getx_ferry');
  checkFile(dir, 'lib/core/graphql/schema.graphql', 'getx_ferry',
      mustContain: ['type ']);
  checkFile(dir, 'lib/core/graphql/operations/example.graphql', 'getx_ferry',
      mustContain: ['query']);
  checkFile(dir, 'build.yaml', 'getx_ferry', mustContain: ['ferry']);
  checkFileAbsent(
      dir, 'lib/core/graphql/queries/example_queries.dart', 'getx_ferry');
  checkFileAbsent(
      dir, 'lib/core/graphql/mutations/example_mutations.dart', 'getx_ferry');
  checkPubspec(dir, 'getx_ferry', deps: [
    'get:',
    'ferry: ^0.16.1+2',
    'ferry_flutter: ^0.9.1+1',
    'gql_http_link: ^1.2.0'
  ], noDeps: [
    'graphql_flutter:'
  ]);
}

Future<void> analyzeRiverpodFerry() async {
  sub('Riverpod + ferry');
  final cfg = BlueprintConfig(
    appName: 'riverpod_ferry',
    stateManagement: StateManagement.riverpod,
    platforms: [TargetPlatform.mobile],
    includeApi: false,
    includeTheme: false,
    includeTests: false,
    includeLocalization: false,
    includeEnv: false,
    graphqlClient: GraphqlClient.ferry,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'riverpod_ferry');
  checkFile(dir, 'lib/core/graphql/schema.graphql', 'riverpod_ferry',
      mustContain: ['type ']);
  checkFile(
      dir, 'lib/core/graphql/operations/example.graphql', 'riverpod_ferry');
  checkFile(dir, 'build.yaml', 'riverpod_ferry', mustContain: ['ferry']);
  checkPubspec(dir, 'riverpod_ferry', deps: [
    'ferry: ^0.16.1+2',
    'ferry_flutter: ^0.9.1+1',
    'gql_http_link: ^1.2.0'
  ], noDeps: [
    'graphql_flutter:'
  ]);
}

Future<void> analyzeBlocFerry() async {
  sub('BLoC + ferry');
  final cfg = BlueprintConfig(
    appName: 'bloc_ferry',
    stateManagement: StateManagement.bloc,
    platforms: [TargetPlatform.mobile],
    includeApi: false,
    includeTheme: false,
    includeTests: false,
    includeLocalization: false,
    includeEnv: false,
    graphqlClient: GraphqlClient.ferry,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'bloc_ferry');
  checkFile(dir, 'lib/core/graphql/schema.graphql', 'bloc_ferry',
      mustContain: ['type ']);
  checkFile(dir, 'lib/core/graphql/operations/example.graphql', 'bloc_ferry');
  checkFile(dir, 'build.yaml', 'bloc_ferry', mustContain: ['ferry']);
  checkPubspec(dir, 'bloc_ferry', deps: [
    'ferry: ^0.16.1+2',
    'ferry_flutter: ^0.9.1+1',
    'gql_http_link: ^1.2.0'
  ], noDeps: [
    'graphql_flutter:'
  ]);
}

Future<void> analyzeProviderFerry() async {
  sub('Provider + ferry');
  final cfg = BlueprintConfig(
    appName: 'provider_ferry',
    stateManagement: StateManagement.provider,
    platforms: [TargetPlatform.mobile],
    includeApi: false,
    includeTheme: false,
    includeTests: false,
    includeLocalization: false,
    includeEnv: false,
    graphqlClient: GraphqlClient.ferry,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'provider_ferry');
  checkFile(dir, 'lib/core/graphql/schema.graphql', 'provider_ferry',
      mustContain: ['type ']);
  checkFile(
      dir, 'lib/core/graphql/operations/example.graphql', 'provider_ferry');
  checkFile(dir, 'build.yaml', 'provider_ferry', mustContain: ['ferry']);
  checkPubspec(dir, 'provider_ferry', deps: [
    'ferry: ^0.16.1+2',
    'ferry_flutter: ^0.9.1+1',
    'gql_http_link: ^1.2.0'
  ], noDeps: [
    'graphql_flutter:'
  ]);
}

Future<void> analyzeGetxFullFeatured() async {
  sub('GetX + graphql_flutter + ALL features');
  final cfg = BlueprintConfig(
    appName: 'getx_full',
    stateManagement: StateManagement.getx,
    platforms: [TargetPlatform.mobile],
    includeApi: true,
    includeTheme: true,
    includeTests: true,
    includeLocalization: true,
    includeEnv: true,
    includeHive: true,
    includePagination: true,
    includeAnalytics: true,
    analyticsProvider: AnalyticsProvider.firebase,
    ciProvider: CIProvider.github,
    graphqlClient: GraphqlClient.graphqlFlutter,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'getx_full');
  checkFile(dir, 'pubspec.yaml', 'getx_full', mustContain: [
    'get:',
    'graphql_flutter: ^5.1.2',
    'hive:',
    'firebase_core:'
  ]);
  checkFile(dir, 'lib/core/graphql/graphql_client.dart', 'getx_full',
      mustContain: ['GraphQLClient']);
  checkFile(dir, 'lib/core/config/env_loader.dart', 'getx_full');
  // GitHub Actions
  checkFile(dir, '.github/workflows/ci.yml', 'getx_full',
      mustContain: ['flutter']);
}

Future<void> analyzeGetxFerryFullFeatured() async {
  sub('GetX + ferry + ALL features');
  final cfg = BlueprintConfig(
    appName: 'getx_ferry_full',
    stateManagement: StateManagement.getx,
    platforms: [TargetPlatform.mobile],
    includeApi: true,
    includeTheme: true,
    includeTests: true,
    includeLocalization: false,
    includeEnv: false,
    includeHive: true,
    includePagination: false,
    graphqlClient: GraphqlClient.ferry,
  );
  final dir = await generate(cfg);
  analyzeStructure(dir, 'getx_ferry_full');
  checkFile(dir, 'pubspec.yaml', 'getx_ferry_full', mustContain: [
    'get:',
    'ferry: ^0.16.1+2',
    'ferry_flutter: ^0.9.1+1',
    'gql_http_link: ^1.2.0'
  ]);
  checkFile(dir, 'build.yaml', 'getx_ferry_full', mustContain: ['ferry']);
  // hive + ferry share build_runner — should not be duplicated
  final spec = read(p.join(dir, 'pubspec.yaml'));
  final buildRunnerCount = 'build_runner:'.allMatches(spec).length;
  if (buildRunnerCount == 1) {
    pass(
        'getx_ferry_full — build_runner declared exactly once (hive+ferry shared)');
  } else {
    fail('getx_ferry_full — build_runner declared exactly once',
        'Found $buildRunnerCount occurrences in pubspec.yaml');
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Deep pubspec version audit across all generated projects
// ──────────────────────────────────────────────────────────────────────────────

Future<void> auditVersionConsistency() async {
  section('Pubspec Version Consistency Audit');
  log('Checking that ferry versions are identical across all generated projects...\n');

  final projects = Directory(outDir).listSync().whereType<Directory>().toList();

  final ferryVersions = <String, String>{};
  final ferryFlutterVersions = <String, String>{};
  final graphqlFlutterVersions = <String, String>{};

  for (final proj in projects) {
    final spec = read(p.join(proj.path, 'pubspec.yaml'));
    final name = p.basename(proj.path);

    final ferryMatch = RegExp(r'ferry: \^(\S+)').firstMatch(spec);
    if (ferryMatch != null) ferryVersions[name] = ferryMatch.group(1)!;

    final ffMatch = RegExp(r'ferry_flutter: \^(\S+)').firstMatch(spec);
    if (ffMatch != null) ferryFlutterVersions[name] = ffMatch.group(1)!;

    final gqlMatch = RegExp(r'graphql_flutter: \^(\S+)').firstMatch(spec);
    if (gqlMatch != null) graphqlFlutterVersions[name] = gqlMatch.group(1)!;
  }

  // ferry versions
  final ferrySet = ferryVersions.values.toSet();
  if (ferrySet.length <= 1) {
    pass(
        'ferry version consistent across all projects: ${ferrySet.isEmpty ? "n/a" : "^${ferrySet.first}"}');
  } else {
    fail('ferry version consistent', 'Inconsistent versions: $ferryVersions');
  }

  // ferry_flutter versions
  final ffSet = ferryFlutterVersions.values.toSet();
  if (ffSet.length <= 1) {
    pass(
        'ferry_flutter version consistent: ${ffSet.isEmpty ? "n/a" : "^${ffSet.first}"}');
  } else {
    fail('ferry_flutter version consistent',
        'Inconsistent: $ferryFlutterVersions');
  }

  // graphql_flutter versions
  final gqlSet = graphqlFlutterVersions.values.toSet();
  if (gqlSet.length <= 1) {
    pass(
        'graphql_flutter version consistent: ${gqlSet.isEmpty ? "n/a" : "^${gqlSet.first}"}');
  } else {
    fail('graphql_flutter version consistent',
        'Inconsistent: $graphqlFlutterVersions');
  }
}

// ──────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  Directory(outDir).createSync(recursive: true);

  log('# flutter_blueprint — New Features Real-Project Analysis');
  log('Generated: ${DateTime.now()}');
  log('Output dir: $outDir');

  section('1. GetX state management combinations');
  await analyzeGetxNone();
  await analyzeGetxGraphqlFlutter();
  await analyzeGetxFerry();

  section('2. Ferry with every state manager');
  await analyzeRiverpodFerry();
  await analyzeBlocFerry();
  await analyzeProviderFerry();

  section('3. Full-featured combinations');
  await analyzeGetxFullFeatured();
  await analyzeGetxFerryFullFeatured();

  await auditVersionConsistency();

  section('Summary');
  final total = passCount + failCount;
  log('Total checks : $total');
  log('Passed       : $passCount  ✅');
  log('Failed       : $failCount  ❌');

  if (failCount == 0) {
    log('\n🎉 ALL CHECKS PASSED — generated output is correct.');
  } else {
    log('\n⚠️  $failCount check(s) failed — see details above.');
  }

  // Write report
  final reportPath = p.join(Directory.current.path, 'NEW_FEATURES_ANALYSIS.md');
  final report = StringBuffer();
  report.writeln('# flutter_blueprint — New Features Analysis Report');
  report.writeln('\nGenerated: ${DateTime.now()}\n');
  for (final line in reportLines) {
    report.writeln(line);
  }
  File(reportPath).writeAsStringSync(report.toString());
  log('\nReport written → NEW_FEATURES_ANALYSIS.md');

  if (failCount > 0) exit(1);
}
