/// Azure Pipelines CI/CD template for Flutter projects.
class AzurePipelinesTemplate {
  /// Generates a comprehensive Azure Pipelines configuration file.
  ///
  /// Includes:
  /// - Flutter analyze job
  /// - Unit test job with coverage
  /// - Build iOS/Android jobs
  /// - Code coverage publishing
  static String generate({
    required String appName,
    required bool includeTests,
    required bool includeAndroid,
    required bool includeIOS,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('# Azure Pipelines for $appName');
    buffer.writeln();
    buffer.writeln('trigger:');
    buffer.writeln('  branches:');
    buffer.writeln('    include:');
    buffer.writeln('      - main');
    buffer.writeln('      - develop');
    buffer.writeln();
    buffer.writeln('pr:');
    buffer.writeln('  branches:');
    buffer.writeln('    include:');
    buffer.writeln('      - main');
    buffer.writeln('      - develop');
    buffer.writeln();
    buffer.writeln('pool:');
    buffer.writeln('  vmImage: \'ubuntu-latest\'');
    buffer.writeln();
    buffer.writeln('variables:');
    buffer.writeln('  flutterVersion: \'3.24.0\'');
    buffer.writeln();
    buffer.writeln('stages:');
    buffer.writeln('  - stage: Analyze');
    buffer.writeln('    jobs:');
    buffer.writeln('      - job: AnalyzeCode');
    buffer.writeln('        displayName: \'Analyze & Format Check\'');
    buffer.writeln('        steps:');
    buffer.writeln('          - task: FlutterInstall@0');
    buffer.writeln('            inputs:');
    buffer.writeln('              mode: \'auto\'');
    buffer.writeln('              channel: \'stable\'');
    buffer.writeln('              version: \'custom\'');
    buffer.writeln('              customVersion: \$(flutterVersion)');
    buffer.writeln();
    buffer.writeln('          - script: flutter pub get');
    buffer.writeln('            displayName: \'Get dependencies\'');
    buffer.writeln();
    buffer.writeln(
        '          - script: dart format --output=none --set-exit-if-changed .');
    buffer.writeln('            displayName: \'Verify formatting\'');
    buffer.writeln();
    buffer.writeln('          - script: flutter analyze');
    buffer.writeln('            displayName: \'Analyze code\'');
    buffer.writeln();

    // Test stage
    if (includeTests) {
      buffer.writeln('  - stage: Test');
      buffer.writeln('    dependsOn: Analyze');
      buffer.writeln('    jobs:');
      buffer.writeln('      - job: RunTests');
      buffer.writeln('        displayName: \'Run Unit Tests\'');
      buffer.writeln('        steps:');
      buffer.writeln('          - task: FlutterInstall@0');
      buffer.writeln('            inputs:');
      buffer.writeln('              mode: \'auto\'');
      buffer.writeln('              channel: \'stable\'');
      buffer.writeln('              version: \'custom\'');
      buffer.writeln('              customVersion: \$(flutterVersion)');
      buffer.writeln();
      buffer.writeln('          - script: flutter pub get');
      buffer.writeln('            displayName: \'Get dependencies\'');
      buffer.writeln();
      buffer.writeln('          - script: flutter test --coverage');
      buffer.writeln('            displayName: \'Run tests with coverage\'');
      buffer.writeln();
      buffer.writeln('          - task: PublishCodeCoverageResults@1');
      buffer.writeln('            inputs:');
      buffer.writeln('              codeCoverageTool: \'Cobertura\'');
      buffer
          .writeln('              summaryFileLocation: \'coverage/lcov.info\'');
      buffer.writeln();
      buffer.writeln('          - task: PublishTestResults@2');
      buffer.writeln('            inputs:');
      buffer.writeln('              testResultsFormat: \'JUnit\'');
      buffer
          .writeln('              testResultsFiles: \'**/test-results/*.xml\'');
      buffer.writeln('              failTaskOnFailedTests: true');
      buffer.writeln();
    }

    // Build stages
    if (includeAndroid || includeIOS) {
      buffer.writeln('  - stage: Build');
      buffer.writeln('    dependsOn: ${includeTests ? 'Test' : 'Analyze'}');
      buffer.writeln('    jobs:');

      // Android build
      if (includeAndroid) {
        buffer.writeln('      - job: BuildAndroid');
        buffer.writeln('        displayName: \'Build Android APK\'');
        buffer.writeln('        steps:');
        buffer.writeln('          - task: FlutterInstall@0');
        buffer.writeln('            inputs:');
        buffer.writeln('              mode: \'auto\'');
        buffer.writeln('              channel: \'stable\'');
        buffer.writeln('              version: \'custom\'');
        buffer.writeln('              customVersion: \$(flutterVersion)');
        buffer.writeln();
        buffer.writeln('          - task: JavaToolInstaller@0');
        buffer.writeln('            inputs:');
        buffer.writeln('              versionSpec: \'17\'');
        buffer.writeln('              jdkArchitectureOption: \'x64\'');
        buffer.writeln('              jdkSourceOption: \'PreInstalled\'');
        buffer.writeln();
        buffer.writeln('          - script: flutter pub get');
        buffer.writeln('            displayName: \'Get dependencies\'');
        buffer.writeln();
        buffer.writeln('          - script: flutter build apk --release');
        buffer.writeln('            displayName: \'Build APK\'');
        buffer.writeln();
        buffer.writeln('          - task: PublishBuildArtifacts@1');
        buffer.writeln('            inputs:');
        buffer.writeln(
            '              pathToPublish: \'build/app/outputs/flutter-apk/app-release.apk\'');
        buffer.writeln('              artifactName: \'android-apk\'');
        buffer.writeln();
      }

      // iOS build
      if (includeIOS) {
        buffer.writeln('      - job: BuildIOS');
        buffer.writeln('        displayName: \'Build iOS IPA\'');
        buffer.writeln('        pool:');
        buffer.writeln('          vmImage: \'macOS-latest\'');
        buffer.writeln('        steps:');
        buffer.writeln('          - task: FlutterInstall@0');
        buffer.writeln('            inputs:');
        buffer.writeln('              mode: \'auto\'');
        buffer.writeln('              channel: \'stable\'');
        buffer.writeln('              version: \'custom\'');
        buffer.writeln('              customVersion: \$(flutterVersion)');
        buffer.writeln();
        buffer.writeln('          - script: flutter pub get');
        buffer.writeln('            displayName: \'Get dependencies\'');
        buffer.writeln();
        buffer.writeln(
            '          - script: flutter build ios --release --no-codesign');
        buffer.writeln('            displayName: \'Build iOS (no codesign)\'');
        buffer.writeln();
        buffer.writeln('          # For signed builds, configure:');
        buffer.writeln('          # - task: InstallAppleCertificate@2');
        buffer.writeln('          # - task: InstallAppleProvisioningProfile@1');
        buffer.writeln('          # - script: flutter build ipa --release');
        buffer.writeln();
        buffer.writeln('          - task: PublishBuildArtifacts@1');
        buffer.writeln('            inputs:');
        buffer.writeln('              pathToPublish: \'build/ios/iphoneos/\'');
        buffer.writeln('              artifactName: \'ios-build\'');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Generates a deployment stage for Firebase App Distribution.
  static String generateFirebaseDeployment({
    required String appName,
    required String projectId,
  }) {
    final buffer = StringBuffer();

    buffer.writeln();
    buffer.writeln('  - stage: Deploy');
    buffer.writeln('    dependsOn: Build');
    buffer.writeln(
        '    condition: and(succeeded(), eq(variables[\'Build.SourceBranch\'], \'refs/heads/main\'))');
    buffer.writeln('    jobs:');
    buffer.writeln('      - job: DeployToFirebase');
    buffer.writeln(
        '        displayName: \'Deploy to Firebase App Distribution\'');
    buffer.writeln('        steps:');
    buffer.writeln('          - task: DownloadBuildArtifacts@0');
    buffer.writeln('            inputs:');
    buffer.writeln('              buildType: \'current\'');
    buffer.writeln('              downloadType: \'single\'');
    buffer.writeln('              artifactName: \'android-apk\'');
    buffer.writeln(
        '              downloadPath: \'\$(System.ArtifactsDirectory)\'');
    buffer.writeln();
    buffer.writeln('          - script: |');
    buffer.writeln('              npm install -g firebase-tools');
    buffer.writeln(
        '              firebase appdistribution:distribute \$(System.ArtifactsDirectory)/android-apk/app-release.apk \\');
    buffer.writeln('                --app \$(FIREBASE_APP_ID) \\');
    buffer.writeln('                --groups "testers" \\');
    buffer.writeln('                --token \$(FIREBASE_TOKEN)');
    buffer.writeln('            displayName: \'Deploy to Firebase\'');
    buffer.writeln();

    return buffer.toString();
  }
}
