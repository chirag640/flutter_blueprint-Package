import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import '../config/blueprint_manifest.dart';
import '../generator/feature_generator.dart';
import '../utils/logger.dart';

/// Command to add a new feature to an existing blueprint project.
class AddFeatureCommand {
  AddFeatureCommand({
    Logger? logger,
    FeatureGenerator? generator,
  })  : _logger = logger ?? Logger(),
        _generator = generator ?? FeatureGenerator();

  final Logger _logger;
  final FeatureGenerator _generator;

  Future<void> execute(List<String> arguments) async {
    final parser = _buildParser();

    try {
      final results = parser.parse(arguments);

      if (results['help'] as bool) {
        _printUsage(parser);
        return;
      }

      // Feature name is required
      if (results.rest.isEmpty) {
        _logger.error('Error: Feature name is required');
        _printUsage(parser);
        exit(1);
      }

      final featureName = results.rest.first;

      // Validate feature name
      if (!_isValidFeatureName(featureName)) {
        _logger.error(
          'Error: Feature name must be lowercase with underscores (e.g., user_profile)',
        );
        exit(1);
      }

      // Load blueprint.yaml from current directory
      final manifestFile =
          File(p.join(Directory.current.path, 'blueprint.yaml'));
      if (!await manifestFile.exists()) {
        _logger.error(
          'Error: blueprint.yaml not found. Are you in a flutter_blueprint project?',
        );
        _logger
            .info('Run this command from the root of your project directory.');
        exit(1);
      }

      final manifest = await BlueprintManifestStore().read(manifestFile);
      final config = manifest.config;

      // Determine which layers to generate
      final includeData = results['data'] as bool? ?? true;
      final includeDomain = results['domain'] as bool? ?? true;
      final includePresentation = results['presentation'] as bool? ?? true;
      final includeApi = results['api'] as bool? ?? false;
      final updateRouter = results['router'] as bool? ?? true;

      // Show what we're generating
      _logger.info('');
      _logger.info('🎯 Generating feature: $featureName');
      _logger.info('   State management: ${config.stateManagement.label}');
      _logger.info('   Layers:');
      if (includeData) {
        _logger.info('     ✅ Data layer (repositories, models)');
      }
      if (includeDomain) {
        _logger.info('     ✅ Domain layer (entities, use cases)');
      }
      if (includePresentation) {
        _logger.info('     ✅ Presentation layer (pages, widgets, state)');
      }
      if (includeApi) {
        _logger.info('     ✅ API integration');
      }
      _logger.info('');

      // Generate the feature
      await _generator.generate(
        featureName: featureName,
        config: config,
        targetPath: Directory.current.path,
        includeData: includeData,
        includeDomain: includeDomain,
        includePresentation: includePresentation,
        includeApi: includeApi,
        updateRouter: updateRouter,
      );

      _logger.success('✅ Feature "$featureName" generated successfully!');
      _logger.info('');
      _logger.info('Next steps:');
      _logger.info('  1. Review generated files in lib/features/$featureName/');
      _logger.info('  2. Update app_router.dart with your new routes');
      _logger.info('  3. Implement your business logic');
      _logger
          .info('  4. Run: flutter pub get (if new dependencies were added)');
    } on FormatException catch (e) {
      _logger.error('Error: ${e.message}');
      _printUsage(parser);
      exit(1);
    } catch (e) {
      _logger.error('Error: $e');
      exit(1);
    }
  }

  ArgParser _buildParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show usage information',
      )
      ..addFlag(
        'data',
        help: 'Generate data layer (repositories, models)',
        defaultsTo: null,
      )
      ..addFlag(
        'domain',
        help: 'Generate domain layer (entities, use cases)',
        defaultsTo: null,
      )
      ..addFlag(
        'presentation',
        help: 'Generate presentation layer (pages, widgets, state)',
        defaultsTo: null,
      )
      ..addFlag(
        'api',
        help: 'Include API integration (remote data source)',
        defaultsTo: false,
      )
      ..addFlag(
        'router',
        help: 'Update app_router.dart with new route',
        defaultsTo: null,
      );
  }

  bool _isValidFeatureName(String name) {
    // Feature names must be lowercase with underscores
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name);
  }

  void _printUsage(ArgParser parser) {
    _logger.info('Add a new feature to your flutter_blueprint project\n');
    _logger.info(
        'Usage: flutter_blueprint add feature <feature_name> [options]\n');
    _logger.info('Options:');
    _logger.info(parser.usage);
    _logger.info('\nExamples:');
    _logger.info('  # Generate all layers');
    _logger.info('  flutter_blueprint add feature auth');
    _logger.info('');
    _logger.info('  # Generate only presentation layer');
    _logger.info(
        '  flutter_blueprint add feature settings --presentation --no-data --no-domain');
    _logger.info('');
    _logger.info('  # Generate with API integration');
    _logger.info('  flutter_blueprint add feature products --api');
    _logger.info('');
    _logger.info('  # Generate data and domain only');
    _logger.info('  flutter_blueprint add feature cart --no-presentation');
    _logger.info('');
    _logger.info('  # Generate without updating router');
    _logger.info('  flutter_blueprint add feature profile --no-router');
  }
}
