/// Refactored project generator using new abstractions.
///
/// Replaces the monolithic [BlueprintGenerator] with a composable design
/// built on [ITemplateRenderer], [TemplateRegistry], and [Result] types.
library;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import '../config/blueprint_manifest.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../templates/core/template_engine.dart';
import '../templates/core/template_interface.dart';
import '../templates/core/cached_template_renderer.dart';
import '../templates/template_bundle.dart';
import '../templates/provider_mobile_template.dart';
import '../templates/riverpod_mobile_template.dart';
import '../templates/bloc_mobile_template.dart';
import '../templates/web_template.dart';
import '../templates/desktop_template.dart';
import '../templates/universal_template.dart';
import '../templates/ci/github_actions_template.dart';
import '../templates/ci/gitlab_ci_template.dart';
import '../templates/ci/azure_pipelines_template.dart';
import '../utils/io_utils.dart';
import '../utils/logger.dart';
import '../utils/input_validator.dart';

/// Generation result containing stats about what was created.
class GenerationResult {
  const GenerationResult({
    required this.filesGenerated,
    required this.targetPath,
    this.ciConfigGenerated = false,
  });

  final int filesGenerated;
  final String targetPath;
  final bool ciConfigGenerated;

  @override
  String toString() => 'GenerationResult($filesGenerated files at $targetPath)';
}

/// Orchestrates project generation using the new template abstraction layer.
///
/// Key improvements over [BlueprintGenerator]:
/// - Uses [TemplateRegistry] for template selection (no more switch/case).
/// - Returns [Result<GenerationResult, ProjectGenerationError>] instead of
///   throwing or calling exit().
/// - CI config generation extracted to helper.
/// - All dependencies injected; fully testable.
class ProjectGenerator {
  ProjectGenerator({
    IoUtils? ioUtils,
    Logger? logger,
    TemplateRegistry? registry,
  })  : _ioUtils = ioUtils ?? const IoUtils(),
        _logger = logger ?? Logger(),
        _registry = registry ?? _buildDefaultRegistry();

  final IoUtils _ioUtils;
  final Logger _logger;
  final TemplateRegistry _registry;

  /// Generates a complete Flutter project.
  ///
  /// Returns a [Result] instead of throwing exceptions or calling exit().
  Future<Result<GenerationResult, ProjectGenerationError>> generate(
    BlueprintConfig config,
    String targetPath,
  ) async {
    try {
      // Validate app name
      InputValidator.validatePackageName(config.appName, fieldName: 'App name');

      final validatedPath = InputValidator.validateTargetDirectory(targetPath);

      _logger.info('🚀 Generating project structure...');

      // Prepare directory
      await _ioUtils.prepareTargetDirectory(validatedPath);

      // Select template
      final renderer = _registry.selectFor(config);
      if (renderer == null) {
        return Result.failure(
          ProjectGenerationError(
            'No template found for configuration: '
            'platform=${config.platforms.map((p) => p.label).join(",")}, '
            'state=${config.stateManagement.label}',
          ),
        );
      }

      // Render template files
      final context = TemplateContext(
        config: config,
        projectPath: validatedPath,
      );
      final generatedFiles = renderer.render(context);

      // Handle additional deps from bundle adapter (reserved for future use)
      // ignore: unused_local_variable
      TemplateBundle? underlyingBundle;

      // Unwrap cached renderer if needed
      var actualRenderer = renderer;
      if (renderer is CachedTemplateRenderer) {
        actualRenderer = renderer.delegate;
      }

      if (actualRenderer is TemplateBundleAdapter) {
        underlyingBundle = actualRenderer.getBundle(config);
      } else if (actualRenderer is SimpleTemplateBundleAdapter) {
        underlyingBundle = actualRenderer.getBundle();
      }

      // Write files in parallel for better performance
      _logger.info('📝 Writing files...');
      final operations = generatedFiles
          .map((file) => FileWriteOperation(
                relativePath: file.path,
                content: file.content,
              ))
          .toList();

      final writeResult = await _ioUtils.writeFilesParallel(
        validatedPath,
        operations,
        concurrency: IoUtils.defaultConcurrency,
      );

      var fileCount = writeResult.successful;

      if (writeResult.failed > 0) {
        _logger.warn(
          '⚠️  Warning: ${writeResult.failed} files failed to write',
        );
      }

      // CI/CD configuration
      var ciGenerated = false;
      if (config.ciProvider != CIProvider.none) {
        await _generateCIConfig(config, validatedPath);
        ciGenerated = true;
        fileCount++;
      }

      // Write manifest
      final manifest = BlueprintManifest(config: config);
      final manifestFile = File(p.join(validatedPath, 'blueprint.yaml'));
      await BlueprintManifestStore().save(manifestFile, manifest);

      _logger.success('✅ Generated $fileCount files successfully!');

      // Log cache statistics for observability
      final cacheStats = CachedTemplateRenderer.getStats();
      if (cacheStats.hits + cacheStats.misses > 0) {
        _logger.info(
          '📊 Template cache stats: ${cacheStats.hits} hits, '
          '${cacheStats.misses} misses '
          '(${(cacheStats.hitRate * 100).toStringAsFixed(1)}% hit rate)',
        );
      }

      if (ciGenerated) {
        _logger.info('');
        _logger.info('🚀 CI/CD configured for ${config.ciProvider.label}');
        _printCISetupInstructions(config.ciProvider);
      }

      // Auto-run flutter create
      await _runFlutterCreate(validatedPath);

      // Auto-install dependencies
      await _runFlutterPubGet(validatedPath);

      // Summary
      _logger.info('');
      _logger.success('🎉 Project created successfully!');
      _logger.info('');
      _logger.info('📍 Next steps:');
      _logger.info('  cd ${config.appName}');
      _logger.info('  flutter run');

      return Result.success(
        GenerationResult(
          filesGenerated: fileCount,
          targetPath: validatedPath,
          ciConfigGenerated: ciGenerated,
        ),
      );
    } on ArgumentError catch (e) {
      return Result.failure(
        ProjectGenerationError('Invalid target path: ${e.message}'),
      );
    } catch (e) {
      return Result.failure(
        ProjectGenerationError('Generation failed: $e'),
      );
    }
  }

  // ── CI/CD generation ─────────────────────────────────────────

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
            targetPath, '.github/workflows/ci.yml', content);
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
        break;
      case CIProvider.gitlab:
        _logger.info('   • Push your code to GitLab');
        _logger.info('   • Pipeline will run automatically on push/MR');
        break;
      case CIProvider.azure:
        _logger.info('   • Push your code to Azure Repos');
        _logger.info('   • Install Flutter extension for Azure Pipelines');
        break;
      case CIProvider.none:
        break;
    }
  }

  // ── Flutter tool invocations ──────────────────────────────────

  Future<void> _runFlutterCreate(String targetPath) async {
    _logger.info('');
    _logger.info('🎯 Initializing Flutter project...');
    try {
      final cmd = Platform.isWindows ? 'flutter.bat' : 'flutter';
      final result = await Process.run(
        cmd,
        ['create', '.'],
        workingDirectory: targetPath,
        runInShell: true,
      ).timeout(const Duration(minutes: 3));

      if (result.exitCode == 0) {
        _logger.success('✅ Flutter project initialized successfully!');
      } else {
        _logger.warning('⚠️  flutter create failed (exit ${result.exitCode})');
      }
    } catch (e) {
      _logger.warning('⚠️  Could not run flutter create: $e');
      _logger.warning('   Run "flutter create ." manually.');
    }
  }

  Future<void> _runFlutterPubGet(String targetPath) async {
    _logger.info('');
    _logger.info('📦 Installing dependencies...');
    try {
      final cmd = Platform.isWindows ? 'flutter.bat' : 'flutter';
      final result = await Process.run(
        cmd,
        ['pub', 'get'],
        workingDirectory: targetPath,
        runInShell: true,
      ).timeout(const Duration(minutes: 5));

      if (result.exitCode == 0) {
        _logger.success('✅ Dependencies installed successfully!');
      } else {
        _logger.warning('⚠️  flutter pub get failed (exit ${result.exitCode})');
        _logger.warning('   Run "flutter pub get" manually.');
      }
    } catch (e) {
      _logger.warning('⚠️  Could not run flutter pub get: $e');
    }
  }

  // ── Default registry ──────────────────────────────────────────

  /// Builds a registry populated with all built-in template adapters.
  ///
  /// This replaces BlueprintGenerator._selectBundle's switch/case.
  static TemplateRegistry _buildDefaultRegistry() {
    final registry = TemplateRegistry();

    // Mobile templates keyed by state management (with caching)
    registry.register(
      CachedTemplateRenderer(
        delegate: SimpleTemplateBundleAdapter(
          templateName: 'mobile_provider',
          templateDescription:
              'Mobile template using Provider state management',
          builder: buildProviderMobileBundle,
        ),
      ),
    );
    registry.register(
      CachedTemplateRenderer(
        delegate: SimpleTemplateBundleAdapter(
          templateName: 'mobile_riverpod',
          templateDescription:
              'Mobile template using Riverpod state management',
          builder: buildRiverpodMobileBundle,
        ),
      ),
    );
    registry.register(
      CachedTemplateRenderer(
        delegate: SimpleTemplateBundleAdapter(
          templateName: 'mobile_bloc',
          templateDescription: 'Mobile template using BLoC state management',
          builder: buildBlocMobileBundle,
        ),
      ),
    );

    // Web templates (with caching)
    registry.register(
      CachedTemplateRenderer(
        delegate: TemplateBundleAdapter(
          templateName: 'web',
          templateDescription: 'Web platform template',
          builder: (config) => buildWebTemplate(config.stateManagement),
        ),
      ),
    );

    // Desktop templates (with caching)
    registry.register(
      CachedTemplateRenderer(
        delegate: TemplateBundleAdapter(
          templateName: 'desktop',
          templateDescription: 'Desktop platform template',
          builder: (config) => buildDesktopTemplate(config.stateManagement),
        ),
      ),
    );

    // Universal (multi-platform) template (with caching)
    registry.register(
      CachedTemplateRenderer(
        delegate: TemplateBundleAdapter(
          templateName: 'universal',
          templateDescription: 'Universal multi-platform template',
          builder: buildUniversalTemplate,
        ),
      ),
    );

    return registry;
  }
}
