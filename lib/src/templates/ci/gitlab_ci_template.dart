/// GitLab CI/CD pipeline template for Flutter projects.
class GitLabCITemplate {
  /// Generates a comprehensive GitLab CI/CD configuration file.
  ///
  /// Includes:
  /// - Flutter analyze stage
  /// - Unit test stage with coverage
  /// - Build iOS/Android stages
  /// - Code coverage reporting
  static String generate({
    required String appName,
    required bool includeTests,
    required bool includeAndroid,
    required bool includeIOS,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('# GitLab CI/CD Pipeline for $appName');
    buffer.writeln();
    buffer.writeln('image: cirrusci/flutter:3.24.0');
    buffer.writeln();
    buffer.writeln('stages:');
    buffer.writeln('  - analyze');
    if (includeTests) buffer.writeln('  - test');
    if (includeAndroid || includeIOS) buffer.writeln('  - build');
    buffer.writeln();
    buffer.writeln('cache:');
    buffer.writeln('  paths:');
    buffer.writeln('    - .pub-cache/');
    buffer.writeln('    - .flutter/');
    buffer.writeln();
    buffer.writeln('before_script:');
    buffer.writeln('  - flutter --version');
    buffer.writeln('  - flutter pub get');
    buffer.writeln();

    // Analyze job
    buffer.writeln('analyze:');
    buffer.writeln('  stage: analyze');
    buffer.writeln('  script:');
    buffer.writeln('    - flutter analyze');
    buffer.writeln('    - dart format --output=none --set-exit-if-changed .');
    buffer.writeln('  only:');
    buffer.writeln('    - main');
    buffer.writeln('    - develop');
    buffer.writeln('    - merge_requests');
    buffer.writeln();

    // Test job
    if (includeTests) {
      buffer.writeln('test:');
      buffer.writeln('  stage: test');
      buffer.writeln('  script:');
      buffer.writeln('    - flutter test --coverage');
      buffer.writeln(r'''  coverage: '/lines[\s\S]*?: ([\d\.]+%)$/' ''');
      buffer.writeln('  artifacts:');
      buffer.writeln('    paths:');
      buffer.writeln('      - coverage/');
      buffer.writeln('    reports:');
      buffer.writeln('      coverage_report:');
      buffer.writeln('        coverage_format: cobertura');
      buffer.writeln('        path: coverage/lcov.info');
      buffer.writeln('  only:');
      buffer.writeln('    - main');
      buffer.writeln('    - develop');
      buffer.writeln('    - merge_requests');
      buffer.writeln();
    }

    // Android build job
    if (includeAndroid) {
      buffer.writeln('build:android:');
      buffer.writeln('  stage: build');
      buffer.writeln('  image: cirrusci/flutter:3.24.0');
      buffer.writeln('  script:');
      buffer.writeln('    - flutter build apk --release');
      buffer.writeln('  artifacts:');
      buffer.writeln('    paths:');
      buffer.writeln('      - build/app/outputs/flutter-apk/app-release.apk');
      buffer.writeln('    expire_in: 7 days');
      buffer.writeln('  only:');
      buffer.writeln('    - main');
      buffer.writeln('    - tags');
      buffer.writeln();
    }

    // iOS build job
    if (includeIOS) {
      buffer.writeln('build:ios:');
      buffer.writeln('  stage: build');
      buffer.writeln('  tags:');
      buffer.writeln('    - macos  # Requires macOS runner');
      buffer.writeln('  script:');
      buffer.writeln('    - flutter build ios --release --no-codesign');
      buffer.writeln('  artifacts:');
      buffer.writeln('    paths:');
      buffer.writeln('      - build/ios/iphoneos/');
      buffer.writeln('    expire_in: 7 days');
      buffer.writeln('  only:');
      buffer.writeln('    - main');
      buffer.writeln('    - tags');
      buffer.writeln();
      buffer.writeln('  # For signed builds, add:');
      buffer.writeln('  # before_script:');
      buffer.writeln('  #   - echo "\$IOS_CERTIFICATE" | base64 -d > cert.p12');
      buffer
          .writeln('  #   - security import cert.p12 -P "\$IOS_CERT_PASSWORD"');
      buffer.writeln('  # script:');
      buffer.writeln('  #   - flutter build ipa --release');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Generates a deployment job for Firebase App Distribution.
  static String generateFirebaseDeployment({
    required String appName,
    required String projectId,
  }) {
    final buffer = StringBuffer();

    buffer.writeln();
    buffer.writeln('deploy:firebase:');
    buffer.writeln('  stage: deploy');
    buffer.writeln('  image: cirrusci/flutter:3.24.0');
    buffer.writeln('  dependencies:');
    buffer.writeln('    - build:android');
    buffer.writeln('  script:');
    buffer.writeln('    - apt-get update && apt-get install -y curl');
    buffer.writeln('    - curl -sL https://firebase.tools | bash');
    buffer.writeln(
        '    - firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \\');
    buffer.writeln('        --app \$FIREBASE_APP_ID \\');
    buffer.writeln('        --groups "testers" \\');
    buffer.writeln('        --token \$FIREBASE_TOKEN');
    buffer.writeln('  only:');
    buffer.writeln('    - main');
    buffer.writeln('    - tags');
    buffer.writeln();

    return buffer.toString();
  }
}
