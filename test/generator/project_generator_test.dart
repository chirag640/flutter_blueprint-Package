import 'dart:io';

import 'package:flutter_blueprint/src/generator/project_generator.dart';
import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ProjectGenerator', () {
    late ProjectGenerator generator;
    late Directory tempDir;

    setUp(() {
      generator = ProjectGenerator();
      tempDir = Directory.systemTemp.createTempSync('project_gen_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
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
  });

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
