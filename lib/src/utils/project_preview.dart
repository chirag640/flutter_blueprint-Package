import '../config/blueprint_config.dart';
import 'logger.dart';

/// Displays a visual preview of the project structure before generation.
///
/// This class generates an ASCII tree representation showing exactly what
/// files and folders will be created, helping developers understand the
/// architecture before committing to generation.
class ProjectPreview {
  ProjectPreview({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Shows a complete preview of the project structure based on configuration.
  ///
  /// Displays:
  /// - Full directory tree with emojis for visibility
  /// - Estimated file count
  /// - Estimated generation time
  /// - Platform-specific notes
  void show(BlueprintConfig config) {
    _logger.info('');
    _logger.info('📋 Project Structure Preview');
    _logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.info('');

    final tree = _buildProjectTree(config);
    _logger.info(tree);

    _logger.info('');
    _logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.info('');

    // Statistics
    final stats = _calculateStatistics(config);
    _logger.info('📊 Project Statistics:');
    _logger.info('   • Total files: ${stats.totalFiles}');
    _logger.info('   • Dart files: ${stats.dartFiles}');
    _logger.info('   • Config files: ${stats.configFiles}');
    _logger.info('   • Test files: ${stats.testFiles}');
    _logger.info('   • Estimated size: ~${stats.estimatedSizeMB} MB');
    _logger.info('   • Generation time: ~${stats.estimationTimeSeconds}s');
    _logger.info('');

    // Configuration summary
    _logger.info('⚙️  Configuration:');
    _logger.info('   • App name: ${config.appName}');
    _logger.info(
        '   • Platforms: ${config.platforms.map((p) => p.label).join(', ')}');
    _logger.info('   • State management: ${config.stateManagement.label}');
    if (config.ciProvider != CIProvider.none) {
      _logger.info('   • CI/CD: ${config.ciProvider.label}');
    }
    _logger.info('');

    // Features included
    _logger.info('✨ Features included:');
    if (config.includeTheme) {
      _logger.info('   ✅ Theme system (Light/Dark modes)');
    }
    if (config.includeLocalization) {
      _logger.info('   ✅ Localization (i18n support)');
    }
    if (config.includeEnv) {
      _logger.info('   ✅ Environment configuration');
    }
    if (config.includeApi) {
      _logger.info('   ✅ API client (Dio + interceptors)');
    }
    if (config.includeTests) {
      _logger.info('   ✅ Test scaffolding');
    }
    _logger.info('');

    // Platform-specific notes
    if (config.isMultiPlatform) {
      _logger.info('📱 Multi-platform notes:');
      if (config.hasPlatform(TargetPlatform.web)) {
        _logger.info(
            '   • Web: Includes responsive layouts and web-specific assets');
      }
      if (config.hasPlatform(TargetPlatform.desktop)) {
        _logger.info(
            '   • Desktop: Includes window management and desktop-specific UI');
      }
      _logger.info('');
    }
  }

  /// Builds an ASCII tree representation of the project structure.
  String _buildProjectTree(BlueprintConfig config) {
    final buffer = StringBuffer();
    final appName = config.appName;

    buffer.writeln('📁 $appName/');
    buffer.writeln('├── 📁 lib/');
    buffer.writeln('│   ├── 📄 main.dart');
    buffer.writeln('│   ├── 📁 features/');
    buffer.writeln('│   │   └── 📁 home/');
    buffer.writeln('│   │       ├── 📁 data/');
    buffer.writeln('│   │       │   ├── 📄 home_repository.dart');
    buffer.writeln('│   │       │   └── 📄 home_model.dart');
    buffer.writeln('│   │       ├── 📁 domain/');
    buffer.writeln('│   │       │   ├── 📄 home_entity.dart');
    buffer.writeln('│   │       │   └── 📄 home_usecase.dart');
    buffer.writeln('│   │       └── 📁 presentation/');
    buffer.writeln('│   │           ├── 📄 home_page.dart');

    // State management specific files
    switch (config.stateManagement) {
      case StateManagement.provider:
        buffer.writeln('│   │           ├── 📄 home_provider.dart');
        break;
      case StateManagement.riverpod:
        buffer.writeln('│   │           ├── 📄 home_provider.dart');
        buffer.writeln('│   │           └── 📄 home_state.dart');
        break;
      case StateManagement.bloc:
        buffer.writeln('│   │           ├── 📄 home_bloc.dart');
        buffer.writeln('│   │           ├── 📄 home_event.dart');
        buffer.writeln('│   │           └── 📄 home_state.dart');
        break;
    }

    buffer.writeln('│   ├── 📁 core/');
    buffer.writeln('│   │   ├── 📁 routing/');
    buffer.writeln('│   │   │   └── 📄 app_router.dart');

    if (config.includeTheme) {
      buffer.writeln('│   │   ├── 📁 theme/');
      buffer.writeln('│   │   │   ├── 📄 app_theme.dart');
      buffer.writeln('│   │   │   ├── 📄 color_schemes.dart');
      buffer.writeln('│   │   │   └── 📄 text_styles.dart');
    }

    if (config.includeApi) {
      buffer.writeln('│   │   ├── 📁 network/');
      buffer.writeln('│   │   │   ├── 📄 api_client.dart');
      buffer.writeln('│   │   │   └── 📄 interceptors.dart');
    }

    buffer.writeln('│   │   ├── 📁 utils/');
    buffer.writeln('│   │   │   ├── 📄 constants.dart');
    buffer.writeln('│   │   │   └── 📄 extensions.dart');

    if (config.includeEnv) {
      buffer.writeln('│   │   └── 📁 config/');
      buffer.writeln('│   │       └── 📄 env_config.dart');
    }

    if (config.includeLocalization) {
      buffer.writeln('│   └── 📁 l10n/');
      buffer.writeln('│       ├── 📄 app_en.arb');
      buffer.writeln('│       └── 📄 app_es.arb');
    }

    // Platform-specific files
    if (config.hasPlatform(TargetPlatform.web)) {
      buffer.writeln('├── 📁 web/');
      buffer.writeln('│   ├── 📄 index.html');
      buffer.writeln('│   └── 📄 manifest.json');
    }

    if (config.hasPlatform(TargetPlatform.desktop)) {
      buffer.writeln('├── 📁 windows/');
      buffer.writeln('├── 📁 macos/');
      buffer.writeln('└── 📁 linux/');
    }

    // Test files
    if (config.includeTests) {
      buffer.writeln('├── 📁 test/');
      buffer.writeln('│   ├── 📁 features/');
      buffer.writeln('│   │   └── 📁 home/');
      buffer.writeln('│   │       ├── 📄 home_repository_test.dart');
      buffer.writeln('│   │       └── 📄 home_usecase_test.dart');
      buffer.writeln('│   └── 📄 widget_test.dart');
    }

    // CI/CD files
    if (config.ciProvider != CIProvider.none) {
      switch (config.ciProvider) {
        case CIProvider.github:
          buffer.writeln('├── 📁 .github/');
          buffer.writeln('│   └── 📁 workflows/');
          buffer.writeln('│       └── 📄 ci.yml');
          break;
        case CIProvider.gitlab:
          buffer.writeln('├── 📄 .gitlab-ci.yml');
          break;
        case CIProvider.azure:
          buffer.writeln('├── 📄 azure-pipelines.yml');
          break;
        case CIProvider.none:
          break;
      }
    }

    // Root files
    buffer.writeln('├── 📄 pubspec.yaml');
    buffer.writeln('├── 📄 analysis_options.yaml');
    buffer.writeln('├── 📄 README.md');
    buffer.writeln('├── 📄 blueprint.yaml');

    if (config.includeEnv) {
      buffer.writeln('├── 📄 .env.example');
      buffer.writeln('└── 📄 .gitignore');
    } else {
      buffer.writeln('└── 📄 .gitignore');
    }

    return buffer.toString();
  }

  /// Calculates project statistics for the preview.
  ProjectStatistics _calculateStatistics(BlueprintConfig config) {
    var dartFiles = 15; // Base files
    var configFiles = 4; // pubspec, analysis_options, README, blueprint.yaml
    var testFiles = 0;

    // State management adds files
    switch (config.stateManagement) {
      case StateManagement.provider:
        dartFiles += 1;
        break;
      case StateManagement.riverpod:
        dartFiles += 2;
        break;
      case StateManagement.bloc:
        dartFiles += 3;
        break;
    }

    // Features add files
    if (config.includeTheme) {
      dartFiles += 3;
    }
    if (config.includeApi) {
      dartFiles += 2;
    }
    if (config.includeLocalization) {
      configFiles += 2; // .arb files
    }
    if (config.includeEnv) {
      dartFiles += 1;
      configFiles += 1; // .env.example
    }
    if (config.includeTests) {
      testFiles = 3 + (config.includeApi ? 2 : 0);
    }

    // CI/CD adds files
    if (config.ciProvider != CIProvider.none) {
      configFiles += 1;
    }

    // Platform-specific files
    if (config.hasPlatform(TargetPlatform.web)) {
      configFiles += 2;
    }
    if (config.hasPlatform(TargetPlatform.desktop)) {
      configFiles += 10; // Desktop platform folders have multiple files
    }

    final totalFiles = dartFiles + configFiles + testFiles;

    // Estimate generation time (1 file = ~0.15s)
    final estimationTimeSeconds = (totalFiles * 0.15 + 5).round();

    // Estimate size (rough approximation)
    final estimatedSizeMB =
        ((dartFiles * 2) + (configFiles * 1) + (testFiles * 1.5)) / 100;

    return ProjectStatistics(
      totalFiles: totalFiles,
      dartFiles: dartFiles,
      configFiles: configFiles,
      testFiles: testFiles,
      estimationTimeSeconds: estimationTimeSeconds,
      estimatedSizeMB: estimatedSizeMB.toStringAsFixed(1),
    );
  }
}

/// Statistics about the project to be generated.
class ProjectStatistics {
  const ProjectStatistics({
    required this.totalFiles,
    required this.dartFiles,
    required this.configFiles,
    required this.testFiles,
    required this.estimationTimeSeconds,
    required this.estimatedSizeMB,
  });

  final int totalFiles;
  final int dartFiles;
  final int configFiles;
  final int testFiles;
  final int estimationTimeSeconds;
  final String estimatedSizeMB;
}
