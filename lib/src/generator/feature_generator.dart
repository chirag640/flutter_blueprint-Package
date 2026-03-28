import 'dart:io';

import 'package:path/path.dart' as p;

import '../config/blueprint_config.dart';
import '../generator/feature_templates/data_layer_template.dart';
import '../generator/feature_templates/domain_layer_template.dart';
import '../generator/feature_templates/presentation_layer_template.dart';
import '../utils/io_utils.dart';
import '../utils/logger.dart';
import '../utils/string_extensions.dart';

/// Generates feature scaffolding in existing blueprint projects.
class FeatureGenerator {
  FeatureGenerator({
    IoUtils? ioUtils,
    Logger? logger,
  })  : _ioUtils = ioUtils ?? const IoUtils(),
        _logger = logger ?? Logger();

  final IoUtils _ioUtils;
  final Logger _logger;

  Future<void> generate({
    required String featureName,
    required BlueprintConfig config,
    required String targetPath,
    required bool includeData,
    required bool includeDomain,
    required bool includePresentation,
    required bool includeApi,
    bool updateRouter = true,
  }) async {
    _logger.info('🔨 Generating feature structure...');

    final featurePath = p.join(targetPath, 'lib', 'features', featureName);

    var fileCount = 0;

    // Generate data layer
    if (includeData) {
      fileCount += await _generateDataLayer(
        featureName: featureName,
        featurePath: featurePath,
        config: config,
        includeApi: includeApi,
      );
    }

    // Generate domain layer
    if (includeDomain) {
      fileCount += await _generateDomainLayer(
        featureName: featureName,
        featurePath: featurePath,
        config: config,
      );
    }

    // Generate presentation layer
    if (includePresentation) {
      fileCount += await _generatePresentationLayer(
        featureName: featureName,
        featurePath: featurePath,
        config: config,
      );
    }

    _logger.success('Generated $fileCount files');

    // Update router if presentation layer was generated and updateRouter is true
    if (includePresentation && updateRouter) {
      await _updateRouter(
        featureName: featureName,
        targetPath: targetPath,
        config: config,
      );
    } else if (includePresentation && !updateRouter) {
      _logger.info('ℹ️  Router update skipped (--no-router flag)');
      _logger.info('   Manually add route to app_router.dart if needed');
    }
  }

  Future<int> _generateDataLayer({
    required String featureName,
    required String featurePath,
    required BlueprintConfig config,
    required bool includeApi,
  }) async {
    final templates = DataLayerTemplate.generate(
      featureName: featureName,
      includeApi: includeApi,
    );

    final rootPath = Directory(featurePath).parent.parent.parent.path;
    final operations = templates.map((template) {
      final relativePath = p.join(
        p.relative(featurePath, from: rootPath),
        template.relativePath,
      );
      return FileWriteOperation(
        relativePath: relativePath,
        content: template.content,
      );
    }).toList();

    final result = await _ioUtils.writeFilesParallel(rootPath, operations);
    return result.successful;
  }

  Future<int> _generateDomainLayer({
    required String featureName,
    required String featurePath,
    required BlueprintConfig config,
  }) async {
    final templates = DomainLayerTemplate.generate(
      featureName: featureName,
    );

    final rootPath = Directory(featurePath).parent.parent.parent.path;
    final operations = templates.map((template) {
      final relativePath = p.join(
        p.relative(featurePath, from: rootPath),
        template.relativePath,
      );
      return FileWriteOperation(
        relativePath: relativePath,
        content: template.content,
      );
    }).toList();

    final result = await _ioUtils.writeFilesParallel(rootPath, operations);
    return result.successful;
  }

  Future<int> _generatePresentationLayer({
    required String featureName,
    required String featurePath,
    required BlueprintConfig config,
  }) async {
    final templates = PresentationLayerTemplate.generate(
      featureName: featureName,
      stateManagement: config.stateManagement,
    );

    final rootPath = Directory(featurePath).parent.parent.parent.path;
    final operations = templates.map((template) {
      final relativePath = p.join(
        p.relative(featurePath, from: rootPath),
        template.relativePath,
      );
      return FileWriteOperation(
        relativePath: relativePath,
        content: template.content,
      );
    }).toList();

    final result = await _ioUtils.writeFilesParallel(rootPath, operations);
    return result.successful;
  }

  Future<void> _updateRouter({
    required String featureName,
    required String targetPath,
    required BlueprintConfig config,
  }) async {
    // GetX projects use app_pages.dart with GetPage entries
    if (config.stateManagement == StateManagement.getx) {
      await _updateGetxRouter(featureName: featureName, targetPath: targetPath);
    } else {
      await _updateNavigatorRouter(
          featureName: featureName, targetPath: targetPath);
    }
  }

  Future<void> _updateNavigatorRouter({
    required String featureName,
    required String targetPath,
  }) async {
    final routerPath = p.join(
      targetPath,
      'lib',
      'core',
      'routing',
      'app_router.dart',
    );

    final routerFile = File(routerPath);
    if (!await routerFile.exists()) {
      _logger.warning('⚠️  app_router.dart not found. Skipping router update.');
      _logger.info('   Please manually add your route to the router.');
      return;
    }

    final content = await routerFile.readAsString();

    // Check if route already exists
    final routeName = '${featureName.toPascalCase()}Route';
    if (content.contains(routeName)) {
      _logger.info('ℹ️  Route already exists in app_router.dart');
      return;
    }

    // Add import
    final importLine =
        "import '../../features/$featureName/presentation/pages/${featureName}_page.dart';";
    String updatedContent = content;

    // Find the last import and add after it
    final lastImportIndex = content.lastIndexOf("import '");
    if (lastImportIndex != -1) {
      final endOfImport = content.indexOf(';', lastImportIndex);
      updatedContent = '${content.substring(0, endOfImport + 1)}'
          '\n$importLine'
          '${content.substring(endOfImport + 1)}';
    }

    // Add route to RouteNames class
    final routeNameConstant =
        "  static const String ${featureName.toCamelCase()} = '/$featureName';";
    final routeNamesMatch =
        RegExp(r'class RouteNames\s*{([^}]+)}').firstMatch(updatedContent);
    if (routeNamesMatch != null) {
      final classEnd = routeNamesMatch.end - 1; // Before closing brace
      updatedContent = '${updatedContent.substring(0, classEnd)}'
          '\n$routeNameConstant\n'
          '${updatedContent.substring(classEnd)}';
    }

    // Add route to routes method
    final routeCase = '''
    case RouteNames.${featureName.toCamelCase()}:
      return MaterialPageRoute(
        builder: (_) => const ${featureName.toPascalCase()}Page(),
        settings: settings,
      );''';

    final defaultCaseIndex = updatedContent.lastIndexOf('default:');
    if (defaultCaseIndex != -1) {
      updatedContent = '${updatedContent.substring(0, defaultCaseIndex)}'
          '$routeCase\n    '
          '${updatedContent.substring(defaultCaseIndex)}';
    }

    await routerFile.writeAsString(updatedContent);
    _logger.success('✅ Updated app_router.dart with new route');
  }

  Future<void> _updateGetxRouter({
    required String featureName,
    required String targetPath,
  }) async {
    final pagesPath = p.join(
      targetPath,
      'lib',
      'core',
      'routing',
      'app_pages.dart',
    );

    final pagesFile = File(pagesPath);
    if (!await pagesFile.exists()) {
      _logger.warning(
        '⚠️  app_pages.dart not found. Skipping GetX router update.',
      );
      _logger.info(
        '   Manually add a GetPage entry for /$featureName in app_pages.dart.',
      );
      return;
    }

    final content = await pagesFile.readAsString();
    final pascalName = featureName.toPascalCase();

    // Check if route is already registered
    if (content.contains("'/$featureName'")) {
      _logger.info('ℹ️  Route /$featureName already exists in app_pages.dart');
      return;
    }

    // Add imports
    final pageImport =
        "import '../../features/$featureName/presentation/pages/${featureName}_page.dart';";
    final bindingImport =
        "import '../../features/$featureName/presentation/bindings/${featureName}_binding.dart';";

    String updatedContent = content;

    final lastImportIndex = content.lastIndexOf("import '");
    if (lastImportIndex != -1) {
      final endOfImport = content.indexOf(';', lastImportIndex);
      updatedContent = '${content.substring(0, endOfImport + 1)}'
          '\n$pageImport\n$bindingImport'
          '${content.substring(endOfImport + 1)}';
    }

    // Add static route constant to Routes class
    final routeConst =
        "  static const String ${featureName.toCamelCase()} = '/$featureName';";
    final routesClassMatch =
        RegExp(r'class Routes\s*\{([^}]+)\}').firstMatch(updatedContent);
    if (routesClassMatch != null) {
      final classEnd = routesClassMatch.end - 1;
      updatedContent = '${updatedContent.substring(0, classEnd)}'
          '\n$routeConst\n'
          '${updatedContent.substring(classEnd)}';
    }

    // Add GetPage entry
    final getPageEntry = '''
    GetPage(
      name: Routes.${featureName.toCamelCase()},
      page: () => const ${pascalName}Page(),
      binding: ${pascalName}Binding(),
    ),''';

    // Insert before the last ]; in the routes list
    final lastBracket = updatedContent.lastIndexOf('];');
    if (lastBracket != -1) {
      updatedContent = '${updatedContent.substring(0, lastBracket)}'
          '$getPageEntry\n  '
          '${updatedContent.substring(lastBracket)}';
    }

    await pagesFile.writeAsString(updatedContent);
    _logger.success('✅ Updated app_pages.dart with new GetPage route');
  }
}

/// Represents a generated file template.
class FileTemplate {
  const FileTemplate({
    required this.relativePath,
    required this.content,
  });

  final String relativePath;
  final String content;
}
