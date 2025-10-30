import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import '../config/blueprint_manifest.dart';
import '../templates/provider_mobile_template.dart';
import '../templates/riverpod_mobile_template.dart';
import '../templates/bloc_mobile_template.dart';
import '../templates/template_bundle.dart';
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

    // Write blueprint manifest
    final manifest = BlueprintManifest(config: config);
    final manifestFile = File(p.join(targetPath, 'blueprint.yaml'));
    await BlueprintManifestStore().save(manifestFile, manifest);

    _logger.success('✅ Generated $fileCount files successfully!');
    _logger.info('');
    _logger.info('Next steps:');
    _logger.info('  cd ${config.appName}');
    _logger.info('  flutter pub get');
    _logger.info('  flutter run');
  }

  TemplateBundle _selectBundle(BlueprintConfig config) {
    // Select template based on state management and platform
    switch (config.stateManagement) {
      case StateManagement.provider:
        return buildProviderMobileBundle();
      case StateManagement.riverpod:
        return buildRiverpodMobileBundle();
      case StateManagement.bloc:
        return buildBlocMobileBundle();
    }
  }
}
