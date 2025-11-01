import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import '../config/blueprint_manifest.dart';
import '../templates/provider_mobile_template.dart';
import '../templates/riverpod_mobile_template.dart';
import '../templates/bloc_mobile_template.dart';
import '../templates/web_template.dart';
import '../templates/desktop_template.dart';
import '../templates/universal_template.dart';
import '../templates/template_bundle.dart';
import '../templates/ci/github_actions_template.dart';
import '../templates/ci/gitlab_ci_template.dart';
import '../templates/ci/azure_pipelines_template.dart';
import '../utils/io_utils.dart';
import '../utils/logger.dart';
import '../utils/input_validator.dart';

/// Orchestrates generation of a new Flutter project from a blueprint config.
///
/// This class is responsible for:
/// - Selecting the appropriate template bundle based on configuration
/// - Generating all project files from templates
/// - Creating CI/CD configuration files
/// - Writing the blueprint.yaml manifest
/// - Running flutter pub get automatically after generation
class BlueprintGenerator {
  /// Creates a new generator with optional dependencies for testing.
  BlueprintGenerator({
    IoUtils? ioUtils,
    Logger? logger,
  })  : _ioUtils = ioUtils ?? const IoUtils(),
        _logger = logger ?? Logger();

  final IoUtils _ioUtils;
  final Logger _logger;

  /// Generates a complete Flutter project at [targetPath] using [config].
  ///
  /// This method will:
  /// 1. Validate all inputs for security
  /// 2. Create the target directory structure
  /// 3. Generate all template files
  /// 4. Create CI/CD configuration if specified
  /// 5. Write blueprint.yaml manifest
  /// 6. Attempt to run `flutter create .` and `flutter pub get` automatically
  Future<void> generate(BlueprintConfig config, String targetPath) async {
    // Validate target path first for security
    final validatedPath = InputValidator.validateTargetDirectory(targetPath);

    _logger.info('🚀 Generating project structure...');

    // Prepare target directory
    await _ioUtils.prepareTargetDirectory(validatedPath);

    // Select template bundle based on config
    final bundle = _selectBundle(config);

    // Generate all files
    var fileCount = 0;
    for (final templateFile in bundle.files) {
      if (!templateFile.shouldInclude(config)) {
        continue;
      }

      final content = templateFile.build(config);
      await _ioUtils.writeFile(validatedPath, templateFile.path, content);
      fileCount++;
    }

    // Generate CI/CD configuration if specified
    if (config.ciProvider != CIProvider.none) {
      await _generateCIConfig(config, validatedPath);
      fileCount++; // Count the CI config file
    }

    // Write blueprint manifest
    final manifest = BlueprintManifest(config: config);
    final manifestFile = File(p.join(validatedPath, 'blueprint.yaml'));
    await BlueprintManifestStore().save(manifestFile, manifest);

    _logger.success('✅ Generated $fileCount files successfully!');
    if (config.ciProvider != CIProvider.none) {
      _logger.info('');
      _logger.info('🚀 CI/CD configured for ${config.ciProvider.label}');
      _printCISetupInstructions(config.ciProvider);
    }

    // Auto-run flutter create (secure execution with timeout)
    _logger.info('');
    _logger.info('🎯 Initializing Flutter project...');
    try {
      // Use 'flutter.bat' on Windows for better compatibility
      final flutterCmd = Platform.isWindows ? 'flutter.bat' : 'flutter';
      final createResult = await Process.run(
        flutterCmd,
        ['create', '.'],
        workingDirectory: validatedPath,
        runInShell: true, // Required on Windows to find flutter in PATH
      ).timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          throw TimeoutException(
            'Flutter create timed out after 3 minutes',
          );
        },
      );

      if (createResult.exitCode == 0) {
        _logger.success('✅ Flutter project initialized successfully!');
      } else {
        _logger.warning(
          '⚠️  Failed to initialize Flutter project. Exit code: ${createResult.exitCode}',
        );
        if (createResult.stderr.toString().isNotEmpty) {
          _logger.debug('stderr: ${createResult.stderr}');
        }
      }
    } on TimeoutException catch (e) {
      _logger.warning('⚠️  ${e.message}');
      _logger.warning('   Please run "flutter create ." manually.');
    } on ProcessException catch (e) {
      _logger.warning('⚠️  Failed to run flutter create: ${e.message}');
      _logger.warning('   Please ensure Flutter is installed and in PATH.');
    } catch (e, stack) {
      _logger.warning('⚠️  Unexpected error during flutter create: $e');
      _logger.debug('Stack trace: $stack');
    }

    // Auto-install dependencies (secure execution with timeout)
    _logger.info('');
    _logger.info('📦 Installing dependencies...');
    try {
      // Use 'flutter.bat' on Windows for better compatibility
      final flutterCmd = Platform.isWindows ? 'flutter.bat' : 'flutter';
      final pubGetResult = await Process.run(
        flutterCmd,
        ['pub', 'get'],
        workingDirectory: validatedPath,
        runInShell: true, // Required on Windows to find flutter in PATH
      ).timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException(
            'Dependency installation timed out after 5 minutes',
          );
        },
      );

      if (pubGetResult.exitCode == 0) {
        _logger.success('✅ Dependencies installed successfully!');
      } else {
        _logger.warning(
          '⚠️  Failed to install dependencies. Exit code: ${pubGetResult.exitCode}',
        );
        if (pubGetResult.stderr.toString().isNotEmpty) {
          _logger.debug('stderr: ${pubGetResult.stderr}');
        }
        _logger.warning('   Please run "flutter pub get" manually.');
      }
    } on TimeoutException catch (e) {
      _logger.warning('⚠️  ${e.message}');
      _logger.warning('   Please run "flutter pub get" manually.');
    } on ProcessException catch (e) {
      _logger.warning('⚠️  Failed to run flutter pub get: ${e.message}');
      _logger.warning('   Please ensure Flutter is installed and in PATH.');
    } catch (e, stack) {
      _logger
          .warning('⚠️  Unexpected error during dependency installation: $e');
      _logger.debug('Stack trace: $stack');
    }

    _logger.info('');
    _logger.success('🎉 Project created successfully!');
    _logger.info('');
    _logger.info('📍 Next steps:');
    _logger.info('  cd ${config.appName}');
    _logger.info('  flutter run');
    _logger.info('');
    _logger.info('💡 Tips:');
    _logger.info('  • Run "flutter doctor" to verify your setup');
    _logger.info('  • Check README.md for project structure details');
    _logger
        .info('  • Use "flutter_blueprint add feature <name>" to add features');
  }

  Future<void> _generateCIConfig(
    BlueprintConfig config,
    String targetPath,
  ) async {
    final includeAndroid = config.hasPlatform(TargetPlatform.mobile);
    final includeIOS = config.hasPlatform(TargetPlatform.mobile);
    final includeWeb = config.hasPlatform(TargetPlatform.web);
    final includeDesktop = config.hasPlatform(TargetPlatform.desktop);

    switch (config.ciProvider) {
      case CIProvider.github:
        final content = GitHubActionsTemplate.generate(
          appName: config.appName,
          includeTests: config.includeTests,
          includeAndroid: includeAndroid,
          includeIOS: includeIOS,
          includeWeb: includeWeb,
          includeDesktop: includeDesktop,
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
          includeWeb: includeWeb,
          includeDesktop: includeDesktop,
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
          includeWeb: includeWeb,
          includeDesktop: includeDesktop,
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
    // Multi-platform project
    if (config.isMultiPlatform) {
      return _buildUniversalTemplate(config);
    }

    // Single platform project
    final platform = config.platforms.first;
    switch (platform) {
      case TargetPlatform.mobile:
        return _selectMobileBundle(config.stateManagement);
      case TargetPlatform.web:
        return _selectWebBundle(config.stateManagement);
      case TargetPlatform.desktop:
        return _selectDesktopBundle(config.stateManagement);
    }
  }

  TemplateBundle _buildUniversalTemplate(BlueprintConfig config) {
    // Import the universal template builder
    final universalTemplate = buildUniversalTemplate(config);
    return universalTemplate;
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
