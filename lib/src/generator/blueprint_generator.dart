import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import '../config/blueprint_manifest.dart';
import '../templates/provider_mobile_template.dart';
import '../templates/riverpod_mobile_template.dart';
import '../templates/bloc_mobile_template.dart';
import '../templates/web_template.dart';
import '../templates/desktop_template.dart';
import '../templates/template_bundle.dart';
import '../templates/ci/github_actions_template.dart';
import '../templates/ci/gitlab_ci_template.dart';
import '../templates/ci/azure_pipelines_template.dart';
import '../utils/io_utils.dart';
import '../utils/logger.dart';

/// Orchestrates generation of a new Flutter project from a blueprint config.
class BlueprintGenerator {
  BlueprintGenerator({
    IoUtils? ioUtils,
    Logger? logger,
  })  : _ioUtils = ioUtils ?? const IoUtils(),
        _logger = logger ?? Logger();

  final IoUtils _ioUtils;
  final Logger _logger;

  Future<void> generate(BlueprintConfig config, String targetPath) async {
    _logger.info('🚀 Generating project structure...');

    // Prepare target directory
    await _ioUtils.prepareTargetDirectory(targetPath);

    // Select template bundle based on config
    final bundle = _selectBundle(config);

    // Generate all files
    var fileCount = 0;
    for (final templateFile in bundle.files) {
      if (!templateFile.shouldInclude(config)) {
        continue;
      }

      final content = templateFile.build(config);
      await _ioUtils.writeFile(targetPath, templateFile.path, content);
      fileCount++;
    }

    // Generate CI/CD configuration if specified
    if (config.ciProvider != CIProvider.none) {
      await _generateCIConfig(config, targetPath);
      fileCount++; // Count the CI config file
    }

    // Write blueprint manifest
    final manifest = BlueprintManifest(config: config);
    final manifestFile = File(p.join(targetPath, 'blueprint.yaml'));
    await BlueprintManifestStore().save(manifestFile, manifest);

    _logger.success('✅ Generated $fileCount files successfully!');
    if (config.ciProvider != CIProvider.none) {
      _logger.info('');
      _logger.info('🚀 CI/CD configured for ${config.ciProvider.label}');
      _printCISetupInstructions(config.ciProvider);
    }
    _logger.info('');
    _logger.info('Next steps:');
    _logger.info('  cd ${config.appName}');
    _logger.info('  flutter pub get');
    _logger.info('  flutter run');
  }

  Future<void> _generateCIConfig(
    BlueprintConfig config,
    String targetPath,
  ) async {
    final includeAndroid = config.platform == TargetPlatform.mobile;
    final includeIOS = config.platform == TargetPlatform.mobile;

    switch (config.ciProvider) {
      case CIProvider.github:
        final content = GitHubActionsTemplate.generate(
          appName: config.appName,
          includeTests: config.includeTests,
          includeAndroid: includeAndroid,
          includeIOS: includeIOS,
        );
        await _ioUtils.writeFile(
          targetPath,
          '.github/workflows/ci.yml',
          content,
        );
        _logger.info('📋 Generated GitHub Actions workflow');
        break;

      case CIProvider.gitlab:
        final content = GitLabCITemplate.generate(
          appName: config.appName,
          includeTests: config.includeTests,
          includeAndroid: includeAndroid,
          includeIOS: includeIOS,
        );
        await _ioUtils.writeFile(targetPath, '.gitlab-ci.yml', content);
        _logger.info('📋 Generated GitLab CI configuration');
        break;

      case CIProvider.azure:
        final content = AzurePipelinesTemplate.generate(
          appName: config.appName,
          includeTests: config.includeTests,
          includeAndroid: includeAndroid,
          includeIOS: includeIOS,
        );
        await _ioUtils.writeFile(targetPath, 'azure-pipelines.yml', content);
        _logger.info('📋 Generated Azure Pipelines configuration');
        break;

      case CIProvider.none:
        break;
    }
  }

  void _printCISetupInstructions(CIProvider provider) {
    switch (provider) {
      case CIProvider.github:
        _logger.info('   • Push your code to GitHub');
        _logger.info('   • Workflow will run automatically on push/PR');
        _logger.info('   • For coverage: Add CODECOV_TOKEN secret');
        break;

      case CIProvider.gitlab:
        _logger.info('   • Push your code to GitLab');
        _logger.info('   • Pipeline will run automatically on push/MR');
        _logger.info('   • For iOS builds: Configure macOS runner');
        break;

      case CIProvider.azure:
        _logger.info('   • Push your code to Azure Repos');
        _logger.info('   • Install Flutter extension for Azure Pipelines');
        _logger.info('   • Pipeline will run automatically on push/PR');
        break;

      case CIProvider.none:
        break;
    }
  }

  TemplateBundle _selectBundle(BlueprintConfig config) {
    // Select template based on platform and state management
    switch (config.platform) {
      case TargetPlatform.mobile:
        return _selectMobileBundle(config.stateManagement);
      case TargetPlatform.web:
        return _selectWebBundle(config.stateManagement);
      case TargetPlatform.desktop:
        return _selectDesktopBundle(config.stateManagement);
    }
  }

  TemplateBundle _selectMobileBundle(StateManagement stateManagement) {
    switch (stateManagement) {
      case StateManagement.provider:
        return buildProviderMobileBundle();
      case StateManagement.riverpod:
        return buildRiverpodMobileBundle();
      case StateManagement.bloc:
        return buildBlocMobileBundle();
    }
  }

  TemplateBundle _selectWebBundle(StateManagement stateManagement) {
    return buildWebTemplate(stateManagement);
  }

  TemplateBundle _selectDesktopBundle(StateManagement stateManagement) {
    return buildDesktopTemplate(stateManagement);
  }
}
