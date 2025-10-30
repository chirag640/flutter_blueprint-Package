import 'package:flutter_blueprint/src/templates/ci/github_actions_template.dart';
import 'package:flutter_blueprint/src/templates/ci/gitlab_ci_template.dart';
import 'package:flutter_blueprint/src/templates/ci/azure_pipelines_template.dart';
import 'package:test/test.dart';

void main() {
  group('GitHubActionsTemplate -', () {
    test('generates basic workflow with analyze job', () {
      final content = GitHubActionsTemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: false,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('name: CI/CD Pipeline'));
      expect(content, contains('on:'));
      expect(content, contains('push:'));
      expect(content, contains('branches: [ main, develop ]'));
      expect(content, contains('analyze:'));
      expect(content, contains('flutter analyze'));
      expect(content, contains('dart format'));
    });

    test('includes test job when includeTests is true', () {
      final content = GitHubActionsTemplate.generate(
        appName: 'test_app',
        includeTests: true,
        includeAndroid: false,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('test:'));
      expect(content, contains('name: Run Tests'));
      expect(content, contains('flutter test --coverage'));
      expect(content, contains('codecov/codecov-action'));
      expect(content, contains('needs: analyze'));
    });

    test('includes Android build job when includeAndroid is true', () {
      final content = GitHubActionsTemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: true,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('build-android:'));
      expect(content, contains('name: Build Android APK'));
      expect(content, contains('Setup Java'));
      expect(content, contains('flutter build apk --release'));
      expect(content, contains('upload-artifact'));
      expect(content, contains('android-apk'));
    });

    test('includes iOS build job when includeIOS is true', () {
      final content = GitHubActionsTemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: false,
        includeIOS: true,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('build-ios:'));
      expect(content, contains('name: Build iOS IPA'));
      expect(content, contains('macos-latest'));
      expect(content, contains('flutter build ios --release --no-codesign'));
    });

    test('generates complete workflow with all features', () {
      final content = GitHubActionsTemplate.generate(
        appName: 'test_app',
        includeTests: true,
        includeAndroid: true,
        includeIOS: true,
        includeWeb: true,
        includeDesktop: true,
      );

      expect(content, contains('analyze:'));
      expect(content, contains('test:'));
      expect(content, contains('build-android:'));
      expect(content, contains('build-ios:'));
      expect(content, contains('build-web:'));
      expect(content, contains('build-windows:'));
      expect(content, contains('build-macos:'));
      expect(content, contains('build-linux:'));
      expect(content, contains('needs: test'));
    });

    test('generates Firebase deployment workflow', () {
      final content = GitHubActionsTemplate.generateFirebaseDeployment(
        appName: 'test_app',
        projectId: 'my-project',
      );

      expect(content, contains('name: Deploy to Firebase'));
      expect(content, contains('deploy-android:'));
      expect(content, contains('Firebase-Distribution-Github-Action'));
      expect(content, contains('FIREBASE_APP_ID_ANDROID'));
      expect(content, contains('FIREBASE_SERVICE_CREDENTIALS'));
    });
  });

  group('GitLabCITemplate -', () {
    test('generates basic pipeline with analyze stage', () {
      final content = GitLabCITemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: false,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('image: cirrusci/flutter'));
      expect(content, contains('stages:'));
      expect(content, contains('- analyze'));
      expect(content, contains('analyze:'));
      expect(content, contains('flutter analyze'));
      expect(content, contains('dart format'));
    });

    test('includes test stage when includeTests is true', () {
      final content = GitLabCITemplate.generate(
        appName: 'test_app',
        includeTests: true,
        includeAndroid: false,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('- test'));
      expect(content, contains('test:'));
      expect(content, contains('flutter test --coverage'));
      expect(content, contains('coverage:'));
      expect(content, contains('coverage/lcov.info'));
    });

    test('includes Android build stage when includeAndroid is true', () {
      final content = GitLabCITemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: true,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('- build'));
      expect(content, contains('build:android:'));
      expect(content, contains('flutter build apk --release'));
      expect(content, contains('artifacts:'));
    });

    test('includes iOS build stage when includeIOS is true', () {
      final content = GitLabCITemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: false,
        includeIOS: true,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('build:ios:'));
      expect(content, contains('tags:'));
      expect(content, contains('- macos'));
      expect(content, contains('flutter build ios --release --no-codesign'));
    });

    test('generates Firebase deployment job', () {
      final content = GitLabCITemplate.generateFirebaseDeployment(
        appName: 'test_app',
        projectId: 'my-project',
      );

      expect(content, contains('deploy:firebase:'));
      expect(content, contains('firebase appdistribution:distribute'));
      expect(content, contains('FIREBASE_APP_ID'));
      expect(content, contains('FIREBASE_TOKEN'));
    });
  });

  group('AzurePipelinesTemplate -', () {
    test('generates basic pipeline with analyze stage', () {
      final content = AzurePipelinesTemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: false,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('# Azure Pipelines for test_app'));
      expect(content, contains('trigger:'));
      expect(content, contains('branches:'));
      expect(content, contains('- main'));
      expect(content, contains('- stage: Analyze'));
      expect(content, contains('AnalyzeCode'));
      expect(content, contains('flutter analyze'));
    });

    test('includes test stage when includeTests is true', () {
      final content = AzurePipelinesTemplate.generate(
        appName: 'test_app',
        includeTests: true,
        includeAndroid: false,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('- stage: Test'));
      expect(content, contains('dependsOn: Analyze'));
      expect(content, contains('RunTests'));
      expect(content, contains('flutter test --coverage'));
      expect(content, contains('PublishCodeCoverageResults'));
      expect(content, contains('PublishTestResults'));
    });

    test('includes Android build stage when includeAndroid is true', () {
      final content = AzurePipelinesTemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: true,
        includeIOS: false,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('- stage: Build'));
      expect(content, contains('BuildAndroid'));
      expect(content, contains('JavaToolInstaller'));
      expect(content, contains('flutter build apk --release'));
      expect(content, contains('PublishBuildArtifacts'));
    });

    test('includes iOS build stage when includeIOS is true', () {
      final content = AzurePipelinesTemplate.generate(
        appName: 'test_app',
        includeTests: false,
        includeAndroid: false,
        includeIOS: true,
        includeWeb: false,
        includeDesktop: false,
      );

      expect(content, contains('BuildIOS'));
      expect(content, contains('vmImage: \'macOS-latest\''));
      expect(content, contains('flutter build ios --release --no-codesign'));
    });

    test('generates complete pipeline with all stages', () {
      final content = AzurePipelinesTemplate.generate(
        appName: 'test_app',
        includeTests: true,
        includeAndroid: true,
        includeIOS: true,
        includeWeb: true,
        includeDesktop: true,
      );

      expect(content, contains('- stage: Analyze'));
      expect(content, contains('- stage: Test'));
      expect(content, contains('- stage: Build'));
      expect(content, contains('BuildAndroid'));
      expect(content, contains('BuildIOS'));
      expect(content, contains('BuildWeb'));
      expect(content, contains('BuildWindows'));
      expect(content, contains('BuildMacOS'));
      expect(content, contains('BuildLinux'));
      expect(content, contains('dependsOn: Test'));
    });

    test('generates Firebase deployment stage', () {
      final content = AzurePipelinesTemplate.generateFirebaseDeployment(
        appName: 'test_app',
        projectId: 'my-project',
      );

      expect(content, contains('- stage: Deploy'));
      expect(content, contains('dependsOn: Build'));
      expect(content, contains('DeployToFirebase'));
      expect(content, contains('firebase appdistribution:distribute'));
      expect(content, contains('FIREBASE_APP_ID'));
    });
  });
}
