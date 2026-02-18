/// Add-feature command - scaffolds new features into existing projects.
///
/// Refactored to use unified Command interface.
library;

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import '../command_interface.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../../config/blueprint_manifest.dart';
import '../../generator/feature_generator.dart';

/// Adds new feature modules to an existing flutter_blueprint project.
class AddFeatureCommandV2 extends BaseCommand {
  final FeatureGenerator? _injectedGenerator;

  AddFeatureCommandV2({FeatureGenerator? generator})
      : _injectedGenerator = generator;

  @override
  String get name => 'add-feature';

  @override
  String get description =>
      'Add a new feature to your flutter_blueprint project';

  @override
  String get usage =>
      'flutter_blueprint add feature <feature_name> [options]\n\n'
      '  Options:\n'
      '    --data / --no-data            Data layer (default: on)\n'
      '    --domain / --no-domain        Domain layer (default: on)\n'
      '    --presentation / --no-presentation  Presentation layer (default: on)\n'
      '    --api                         Include API integration\n'
      '    --router / --no-router        Update app_router.dart (default: on)';

  @override
  void configureArgs(ArgParser parser) {
    parser
      ..addFlag('data',
          help: 'Generate data layer (repositories, models)', defaultsTo: null)
      ..addFlag('domain',
          help: 'Generate domain layer (entities, use cases)', defaultsTo: null)
      ..addFlag('presentation',
          help: 'Generate presentation layer (pages, widgets, state)',
          defaultsTo: null)
      ..addFlag('api',
          help: 'Include API integration (remote data source)',
          defaultsTo: false)
      ..addFlag('router',
          help: 'Update app_router.dart with new route', defaultsTo: null);
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    try {
      // Feature name is required as the first rest argument
      if (args.rest.isEmpty) {
        printHelp(context.logger);
        return Result.failure(
          CommandError('Feature name is required', command: name),
        );
      }

      final featureName = args.rest.first;

      if (!_isValidFeatureName(featureName)) {
        return Result.failure(
          CommandError(
            'Feature name must be lowercase with underscores (e.g., user_profile)',
            command: name,
          ),
        );
      }

      // Load blueprint.yaml from current/working directory
      final workDir = context.workingDirectory;
      final manifestFile = File(p.join(workDir, 'blueprint.yaml'));

      if (!await manifestFile.exists()) {
        return Result.failure(
          CommandError(
            'blueprint.yaml not found. Are you in a flutter_blueprint project?\n'
            'Run this command from the root of your project directory.',
            command: name,
          ),
        );
      }

      final manifest = await BlueprintManifestStore().read(manifestFile);
      final config = manifest.config;

      // Determine which layers to generate
      final includeData = args['data'] as bool? ?? true;
      final includeDomain = args['domain'] as bool? ?? true;
      final includePresentation = args['presentation'] as bool? ?? true;
      final includeApi = args['api'] as bool? ?? false;
      final updateRouter = args['router'] as bool? ?? true;

      // Show plan
      context.logger.info('');
      context.logger.info('🎯 Generating feature: $featureName');
      context.logger
          .info('   State management: ${config.stateManagement.label}');
      context.logger.info('   Layers:');
      if (includeData) {
        context.logger.info('     ✅ Data layer (repositories, models)');
      }
      if (includeDomain) {
        context.logger.info('     ✅ Domain layer (entities, use cases)');
      }
      if (includePresentation) {
        context.logger
            .info('     ✅ Presentation layer (pages, widgets, state)');
      }
      if (includeApi) {
        context.logger.info('     ✅ API integration');
      }
      context.logger.info('');

      // Generate
      final generator = _injectedGenerator ?? FeatureGenerator();
      await generator.generate(
        featureName: featureName,
        config: config,
        targetPath: workDir,
        includeData: includeData,
        includeDomain: includeDomain,
        includePresentation: includePresentation,
        includeApi: includeApi,
        updateRouter: updateRouter,
      );

      context.logger
          .success('✅ Feature "$featureName" generated successfully!');
      context.logger.info('');
      context.logger.info('Next steps:');
      context.logger
          .info('  1. Review generated files in lib/features/$featureName/');
      context.logger.info('  2. Update app_router.dart with your new routes');
      context.logger.info('  3. Implement your business logic');
      context.logger.info(
        '  4. Run: flutter pub get (if new dependencies were added)',
      );

      return Result.success(
        CommandResult.ok('Feature "$featureName" generated'),
      );
    } on FormatException catch (e) {
      return Result.failure(
        CommandError('Invalid arguments: ${e.message}',
            command: name, cause: e),
      );
    } catch (e) {
      return Result.failure(
        CommandError('Failed to add feature: $e', command: name, cause: e),
      );
    }
  }

  bool _isValidFeatureName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }
}
