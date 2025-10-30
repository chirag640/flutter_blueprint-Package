/// GitHub Actions CI/CD workflow template for Flutter projects.
class GitHubActionsTemplate {
  /// Generates a comprehensive GitHub Actions workflow file.
  ///
  /// Includes:
  /// - Flutter analyze job
  /// - Unit test job with coverage
  /// - Build iOS/Android jobs
  /// - Code coverage reporting
  static String generate({
    required String appName,
    required bool includeTests,
    required bool includeAndroid,
    required bool includeIOS,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('name: CI/CD Pipeline');
    buffer.writeln();
    buffer.writeln('on:');
    buffer.writeln('  push:');
    buffer.writeln('    branches: [ main, develop ]');
    buffer.writeln('  pull_request:');
    buffer.writeln('    branches: [ main, develop ]');
    buffer.writeln();
    buffer.writeln('jobs:');

    // Analyze job
    buffer.writeln('  analyze:');
    buffer.writeln('    name: Analyze & Format Check');
    buffer.writeln('    runs-on: ubuntu-latest');
    buffer.writeln('    steps:');
    buffer.writeln('      - uses: actions/checkout@v4');
    buffer.writeln();
    buffer.writeln('      - name: Setup Flutter');
    buffer.writeln('        uses: subosito/flutter-action@v2');
    buffer.writeln('        with:');
    buffer.writeln('          flutter-version: \'3.24.0\'');
    buffer.writeln('          channel: \'stable\'');
    buffer.writeln('          cache: true');
    buffer.writeln();
    buffer.writeln('      - name: Get dependencies');
    buffer.writeln('        run: flutter pub get');
    buffer.writeln();
    buffer.writeln('      - name: Verify formatting');
    buffer.writeln(
        '        run: dart format --output=none --set-exit-if-changed .');
    buffer.writeln();
    buffer.writeln('      - name: Analyze project');
    buffer.writeln('        run: flutter analyze');
    buffer.writeln();

    // Test job
    if (includeTests) {
      buffer.writeln('  test:');
      buffer.writeln('    name: Run Tests');
      buffer.writeln('    runs-on: ubuntu-latest');
      buffer.writeln('    needs: analyze');
      buffer.writeln('    steps:');
      buffer.writeln('      - uses: actions/checkout@v4');
      buffer.writeln();
      buffer.writeln('      - name: Setup Flutter');
      buffer.writeln('        uses: subosito/flutter-action@v2');
      buffer.writeln('        with:');
      buffer.writeln('          flutter-version: \'3.24.0\'');
      buffer.writeln('          channel: \'stable\'');
      buffer.writeln('          cache: true');
      buffer.writeln();
      buffer.writeln('      - name: Get dependencies');
      buffer.writeln('        run: flutter pub get');
      buffer.writeln();
      buffer.writeln('      - name: Run tests with coverage');
      buffer.writeln('        run: flutter test --coverage');
      buffer.writeln();
      buffer.writeln('      - name: Upload coverage to Codecov');
      buffer.writeln('        uses: codecov/codecov-action@v4');
      buffer.writeln('        with:');
      buffer.writeln('          file: ./coverage/lcov.info');
      buffer.writeln('          fail_ci_if_error: false');
      buffer.writeln('          token: \${{ secrets.CODECOV_TOKEN }}');
      buffer.writeln();
    }

    // Android build job
    if (includeAndroid) {
      buffer.writeln('  build-android:');
      buffer.writeln('    name: Build Android APK');
      buffer.writeln('    runs-on: ubuntu-latest');
      buffer.writeln('    needs: ${includeTests ? 'test' : 'analyze'}');
      buffer.writeln('    steps:');
      buffer.writeln('      - uses: actions/checkout@v4');
      buffer.writeln();
      buffer.writeln('      - name: Setup Java');
      buffer.writeln('        uses: actions/setup-java@v4');
      buffer.writeln('        with:');
      buffer.writeln('          distribution: \'zulu\'');
      buffer.writeln('          java-version: \'17\'');
      buffer.writeln('          cache: \'gradle\'');
      buffer.writeln();
      buffer.writeln('      - name: Setup Flutter');
      buffer.writeln('        uses: subosito/flutter-action@v2');
      buffer.writeln('        with:');
      buffer.writeln('          flutter-version: \'3.24.0\'');
      buffer.writeln('          channel: \'stable\'');
      buffer.writeln('          cache: true');
      buffer.writeln();
      buffer.writeln('      - name: Get dependencies');
      buffer.writeln('        run: flutter pub get');
      buffer.writeln();
      buffer.writeln('      - name: Build APK');
      buffer.writeln('        run: flutter build apk --release');
      buffer.writeln();
      buffer.writeln('      - name: Upload APK artifact');
      buffer.writeln('        uses: actions/upload-artifact@v4');
      buffer.writeln('        with:');
      buffer.writeln('          name: android-apk');
      buffer.writeln(
          '          path: build/app/outputs/flutter-apk/app-release.apk');
      buffer.writeln('          retention-days: 7');
      buffer.writeln();
    }

    // iOS build job
    if (includeIOS) {
      buffer.writeln('  build-ios:');
      buffer.writeln('    name: Build iOS IPA');
      buffer.writeln('    runs-on: macos-latest');
      buffer.writeln('    needs: ${includeTests ? 'test' : 'analyze'}');
      buffer.writeln('    steps:');
      buffer.writeln('      - uses: actions/checkout@v4');
      buffer.writeln();
      buffer.writeln('      - name: Setup Flutter');
      buffer.writeln('        uses: subosito/flutter-action@v2');
      buffer.writeln('        with:');
      buffer.writeln('          flutter-version: \'3.24.0\'');
      buffer.writeln('          channel: \'stable\'');
      buffer.writeln('          cache: true');
      buffer.writeln();
      buffer.writeln('      - name: Get dependencies');
      buffer.writeln('        run: flutter pub get');
      buffer.writeln();
      buffer.writeln('      - name: Build iOS (no codesign)');
      buffer.writeln('        run: flutter build ios --release --no-codesign');
      buffer.writeln();
      buffer.writeln('      # For signed builds, uncomment and configure:');
      buffer.writeln('      # - name: Import certificates');
      buffer.writeln('      #   uses: apple-actions/import-codesign-certs@v2');
      buffer.writeln('      #   with:');
      buffer.writeln(
          '      #     p12-file-base64: \${{ secrets.IOS_P12_BASE64 }}');
      buffer.writeln(
          '      #     p12-password: \${{ secrets.IOS_P12_PASSWORD }}');
      buffer.writeln('      #');
      buffer.writeln('      # - name: Build & upload to TestFlight');
      buffer.writeln('      #   run: |');
      buffer.writeln('      #     flutter build ipa --release');
      buffer.writeln(
          '      #     xcrun altool --upload-app -f build/ios/ipa/*.ipa \\');
      buffer.writeln('      #       -u \${{ secrets.APPLE_ID }} \\');
      buffer.writeln('      #       -p \${{ secrets.APPLE_APP_PASSWORD }}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Generates a deployment workflow for Firebase App Distribution.
  static String generateFirebaseDeployment({
    required String appName,
    required String projectId,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('name: Deploy to Firebase');
    buffer.writeln();
    buffer.writeln('on:');
    buffer.writeln('  push:');
    buffer.writeln('    branches: [ main ]');
    buffer.writeln('    tags:');
    buffer.writeln('      - \'v*\'');
    buffer.writeln();
    buffer.writeln('jobs:');
    buffer.writeln('  deploy-android:');
    buffer.writeln('    name: Deploy Android to Firebase');
    buffer.writeln('    runs-on: ubuntu-latest');
    buffer.writeln('    steps:');
    buffer.writeln('      - uses: actions/checkout@v4');
    buffer.writeln();
    buffer.writeln('      - name: Setup Java');
    buffer.writeln('        uses: actions/setup-java@v4');
    buffer.writeln('        with:');
    buffer.writeln('          distribution: \'zulu\'');
    buffer.writeln('          java-version: \'17\'');
    buffer.writeln();
    buffer.writeln('      - name: Setup Flutter');
    buffer.writeln('        uses: subosito/flutter-action@v2');
    buffer.writeln('        with:');
    buffer.writeln('          flutter-version: \'3.24.0\'');
    buffer.writeln('          channel: \'stable\'');
    buffer.writeln();
    buffer.writeln('      - name: Get dependencies');
    buffer.writeln('        run: flutter pub get');
    buffer.writeln();
    buffer.writeln('      - name: Build APK');
    buffer.writeln('        run: flutter build apk --release');
    buffer.writeln();
    buffer.writeln('      - name: Deploy to Firebase App Distribution');
    buffer
        .writeln('        uses: wzieba/Firebase-Distribution-Github-Action@v1');
    buffer.writeln('        with:');
    buffer.writeln('          appId: \${{ secrets.FIREBASE_APP_ID_ANDROID }}');
    buffer.writeln(
        '          serviceCredentialsFileContent: \${{ secrets.FIREBASE_SERVICE_CREDENTIALS }}');
    buffer.writeln('          groups: testers');
    buffer.writeln(
        '          file: build/app/outputs/flutter-apk/app-release.apk');
    buffer.writeln();

    return buffer.toString();
  }
}
