import 'dart:io';

import 'package:args/args.dart';

import '../commands/add_feature_command.dart';
import '../config/blueprint_config.dart';
import '../generator/blueprint_generator.dart';
import '../prompts/interactive_prompter.dart';
import '../templates/template_library.dart';
import '../utils/logger.dart';
import '../utils/input_validator.dart';
import '../utils/project_preview.dart';
import '../utils/dependency_manager.dart';

/// Main CLI entry point that parses arguments and delegates to commands.
class CliRunner {
  CliRunner({
    Logger? logger,
    InteractivePrompter? prompter,
    BlueprintGenerator? generator,
  })  : _logger = logger ?? Logger(),
        _prompter = prompter ?? InteractivePrompter(),
        _generator = generator ?? BlueprintGenerator();

  final Logger _logger;
  final InteractivePrompter _prompter;
  final BlueprintGenerator _generator;

  Future<void> run(List<String> arguments) async {
    // Handle add command separately to avoid flag conflicts
    if (arguments.isNotEmpty && arguments.first == 'add') {
      await _runAddDirect(arguments.skip(1).toList());
      return;
    }

    final parser = _buildParser();

    try {
      final results = parser.parse(arguments);

      if (results['help'] as bool) {
        _printUsage(parser);
        return;
      }

      if (results['version'] as bool) {
        _logger.info('flutter_blueprint version 0.1.0-dev.1');
        return;
      }

      final command = results.rest.isNotEmpty ? results.rest.first : '';

      switch (command) {
        case 'init':
          await _runInit(results);
          break;
        default:
          _logger.error('Unknown command: $command');
          _printUsage(parser);
          exit(1);
      }
    } on FormatException catch (e) {
      _logger.error(e.message);
      _printUsage(parser);
      exit(1);
    } catch (e) {
      _logger.error('Unexpected error: $e');
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
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Show version',
      )
      ..addOption(
        'state',
        abbr: 's',
        help: 'State management solution (provider, riverpod, bloc)',
        allowed: ['provider', 'riverpod', 'bloc'],
      )
      ..addOption(
        'platforms',
        abbr: 'p',
        help: 'Target platforms (comma-separated: mobile,web,desktop or "all")',
      )
      ..addOption(
        'ci',
        help: 'CI/CD provider (github, gitlab, azure)',
        allowed: ['github', 'gitlab', 'azure'],
      )
      ..addOption(
        'template',
        abbr: 't',
        help:
            'Project template (blank, ecommerce, social-media, fitness-tracker, finance-app, food-delivery, chat-app)',
        allowed: [
          'blank',
          'ecommerce',
          'social-media',
          'fitness-tracker',
          'finance-app',
          'food-delivery',
          'chat-app'
        ],
      )
      ..addFlag(
        'preview',
        help: 'Show project structure preview before generation',
        defaultsTo: null,
      )
      ..addFlag(
        'latest-deps',
        help: 'Fetch latest dependency versions from pub.dev',
        defaultsTo: null,
      )
      ..addFlag(
        'theme',
        help: 'Include theme scaffolding',
        defaultsTo: null,
      )
      ..addFlag(
        'localization',
        help: 'Include localization setup',
        defaultsTo: null,
      )
      ..addFlag(
        'env',
        help: 'Include environment config',
        defaultsTo: null,
      )
      ..addFlag(
        'api',
        help: 'Include API client setup',
        defaultsTo: null,
      )
      ..addFlag(
        'tests',
        help: 'Include test scaffolding',
        defaultsTo: null,
      );
  }

  Future<void> _runInit(ArgResults results) async {
    String appName = results.rest.length > 1 ? results.rest[1] : '';

    // Validate app name if provided
    if (appName.isNotEmpty) {
      try {
        appName = InputValidator.validatePackageName(
          appName,
          fieldName: 'app name',
        );
      } on ArgumentError catch (e) {
        _logger.error('❌ Invalid app name: ${e.message}');
        exit(1);
      }
    }

    // If no app name provided and interactive, show wizard
    if (appName.isEmpty && _prompter.isInteractive) {
      await _runWizardMode();
      return;
    }

    // Gather configuration
    final config = await _gatherConfig(results, appName);

    // Parse template if provided
    final templateArg = results['template'] as String?;
    final template = templateArg != null
        ? ProjectTemplate.parse(templateArg)
        : ProjectTemplate.blank;

    // Show template info if not blank
    if (template != ProjectTemplate.blank) {
      _logger.info('');
      _logger.info('📦 Using template: ${template.label}');
      _logger.info('   ${template.description}');
      _logger.info('');
      _logger.info('   Features included:');
      for (final feature in template.features) {
        _logger.info('     • $feature');
      }
      _logger.info('');
    }

    // Show preview if requested
    final showPreview = results['preview'] as bool? ?? false;
    if (showPreview) {
      final previewer = ProjectPreview(logger: _logger);
      previewer.show(config);

      // Ask for confirmation
      final confirmed = await _prompter.confirm(
        '🚀 Proceed with generation?',
        defaultValue: true,
      );

      if (!confirmed) {
        _logger.info('❌ Cancelled. No files were created.');
        return;
      }
      _logger.info('');
    }

    // Fetch latest dependency versions if requested
    final fetchLatestDeps = results['latest-deps'] as bool? ?? false;
    if (fetchLatestDeps) {
      final depManager = DependencyManager(logger: _logger);
      try {
        await depManager.getRecommendedDependencies(
          stateManagement: config.stateManagement.label,
          includeApi: config.includeApi,
          includeLocalization: config.includeLocalization,
        );
      } finally {
        depManager.close();
      }
      _logger.info('');
    }

    // Generate project
    final targetPath =
        Directory.current.path + Platform.pathSeparator + config.appName;
    await _generator.generate(config, targetPath);

    // Generate template-specific features if not blank
    if (template != ProjectTemplate.blank) {
      final templateBundle = TemplateLibrary.getTemplate(template, config);
      if (templateBundle.requiredFeatures.isNotEmpty) {
        _logger.info('');
        _logger.info('🎯 Generating template features...');
        // TODO: Implement feature generation for template
        // This would require integrating with FeatureGenerator
        _logger.info(
            '   Note: Template feature generation will be available in a future update');
      }
    }
  }

  Future<void> _runAddDirect(List<String> arguments) async {
    if (arguments.isEmpty) {
      _logger.error('Error: Subcommand required for "add"');
      _logger.info('Usage: flutter_blueprint add <subcommand> [arguments]');
      _logger.info('Available subcommands:');
      _logger.info('  feature <name>    Add a new feature to the project');
      exit(1);
    }

    final subcommand = arguments.first;

    switch (subcommand) {
      case 'feature':
        // Pass remaining arguments (including feature name and flags)
        final featureArgs = arguments.skip(1).toList();
        final featureCommand = AddFeatureCommand(logger: _logger);
        await featureCommand.execute(featureArgs);
        break;
      default:
        _logger.error('Error: Unknown subcommand "$subcommand"');
        _logger.info('Available subcommands:');
        _logger.info('  feature <name>    Add a new feature to the project');
        exit(1);
    }
  }

  /// Beautiful interactive wizard mode
  Future<void> _runWizardMode() async {
    _logger.info('');
    _logger.info('🎯 Welcome to flutter_blueprint!');
    _logger.info(
        '   Let\'s create your Flutter app with professional architecture.');
    _logger.info('');

    // Template selection
    _logger.info('');
    final templateChoice = await _prompter.choose(
      '📦 Choose a project template',
      [
        'Blank - Basic architecture',
        'E-Commerce - Product catalog & checkout',
        'Social Media - Posts, comments & likes',
        'Fitness Tracker - Workout logging & progress',
        'Finance App - Transaction management',
        'Food Delivery - Restaurant & order tracking',
        'Chat App - Real-time messaging',
      ],
      defaultValue: 'Blank - Basic architecture',
    );

    final template = _parseTemplateChoice(templateChoice);

    // Show template details
    if (template != ProjectTemplate.blank) {
      _logger.info('');
      _logger.info('📦 ${template.label}');
      _logger.info('   ${template.description}');
      _logger.info('');
      _logger.info('   Features included:');
      for (final feature in template.features.take(5)) {
        _logger.info('     • $feature');
      }
      if (template.features.length > 5) {
        _logger.info('     ... and ${template.features.length - 5} more');
      }
      _logger.info('');
    }

    // App name with comprehensive validation
    String appName;
    while (true) {
      appName = await _prompter.prompt(
        '📱 App name',
        defaultValue: 'my_app',
      );

      try {
        appName = InputValidator.validatePackageName(
          appName,
          fieldName: 'app name',
        );
        break; // Validation passed
      } on ArgumentError catch (e) {
        _logger.error('❌ ${e.message}');
        _logger.info('💡 Example: my_app, user_profile, shopping_cart');
        continue;
      }
    }

    // Platform selection (multi-select)
    _logger.info('');
    final platformSelections = await _prompter.multiSelect(
      '💻 Choose target platforms (space to select, enter to confirm)',
      ['Mobile (iOS & Android)', 'Web', 'Desktop (Windows, macOS, Linux)'],
      defaultValues: ['Mobile (iOS & Android)'],
    );

    // Map selections to TargetPlatform enum
    final targetPlatforms = <TargetPlatform>[];
    if (platformSelections.any((s) => s.contains('Mobile'))) {
      targetPlatforms.add(TargetPlatform.mobile);
    }
    if (platformSelections.any((s) => s.contains('Web'))) {
      targetPlatforms.add(TargetPlatform.web);
    }
    if (platformSelections.any((s) => s.contains('Desktop'))) {
      targetPlatforms.add(TargetPlatform.desktop);
    }

    // Ensure at least one platform is selected
    if (targetPlatforms.isEmpty) {
      targetPlatforms.add(TargetPlatform.mobile);
    }

    // State management with arrow key selection
    _logger.info('');
    final stateChoice = await _prompter.choose(
      '🎯 Choose state management',
      ['provider', 'riverpod', 'bloc'],
      defaultValue: 'provider',
    );
    final stateMgmt = StateManagement.parse(stateChoice);

    // CI/CD provider selection
    _logger.info('');
    final ciChoice = await _prompter.choose(
      '🚀 Choose CI/CD provider (optional)',
      ['none', 'github', 'gitlab', 'azure'],
      defaultValue: 'none',
    );
    final ciProvider = CIProvider.parse(ciChoice);

    // Multi-select for optional features
    _logger.info('');
    final selectedFeatures = await _prompter.multiSelect(
      '✨ Select features to include (use space to select, enter to confirm)',
      [
        'Theme system (Light/Dark modes)',
        'Localization (i18n support)',
        'Environment config (.env)',
        'API client (Dio + interceptors)',
        'Test scaffolding',
      ],
      defaultValues: [
        'Theme system (Light/Dark modes)',
        'API client (Dio + interceptors)',
      ],
    );

    // Map selections to boolean flags
    final includeTheme = selectedFeatures.any((f) => f.contains('Theme'));
    final includeLocalization =
        selectedFeatures.any((f) => f.contains('Localization'));
    final includeEnv = selectedFeatures.any((f) => f.contains('Environment'));
    final includeApi = selectedFeatures.any((f) => f.contains('API'));
    final includeTests = selectedFeatures.any((f) => f.contains('Test'));

    // Show summary
    _logger.info('');
    _logger.info('📋 Configuration Summary:');
    if (template != ProjectTemplate.blank) {
      _logger.info('   Template: ${template.label}');
    }
    _logger.info('   App name: $appName');
    _logger.info(
        '   Platforms: ${targetPlatforms.map((p) => p.label).join(', ')}');
    _logger.info('   State management: ${stateMgmt.label}');
    _logger.info('   CI/CD: ${ciProvider.label}');
    _logger.info('   Theme: ${includeTheme ? '✅' : '❌'}');
    _logger.info('   Localization: ${includeLocalization ? '✅' : '❌'}');
    _logger.info('   Environment: ${includeEnv ? '✅' : '❌'}');
    _logger.info('   API client: ${includeApi ? '✅' : '❌'}');
    _logger.info('   Tests: ${includeTests ? '✅' : '❌'}');
    _logger.info('');

    // Create config
    final config = BlueprintConfig(
      appName: appName,
      stateManagement: stateMgmt,
      platforms: targetPlatforms,
      ciProvider: ciProvider,
      includeTheme: includeTheme,
      includeLocalization: includeLocalization,
      includeEnv: includeEnv,
      includeApi: includeApi,
      includeTests: includeTests,
    );

    // Ask if they want to see preview
    final wantPreview = await _prompter.confirm(
      '�️  Show project structure preview?',
      defaultValue: true,
    );

    if (wantPreview) {
      final previewer = ProjectPreview(logger: _logger);
      previewer.show(config);
    }

    // Ask about fetching latest dependency versions
    final fetchLatest = await _prompter.confirm(
      '🔍 Fetch latest dependency versions from pub.dev?',
      defaultValue: false,
    );

    if (fetchLatest) {
      _logger.info('');
      final depManager = DependencyManager(logger: _logger);
      try {
        await depManager.getRecommendedDependencies(
          stateManagement: stateMgmt.label,
          includeApi: includeApi,
          includeLocalization: includeLocalization,
        );
      } finally {
        depManager.close();
      }
    }

    // Final confirm
    _logger.info('');
    final confirmed = await _prompter.confirm(
      '🚀 Ready to generate your app?',
      defaultValue: true,
    );

    if (!confirmed) {
      _logger.info('❌ Cancelled. No files were created.');
      return;
    }

    // Generate project
    final targetPath =
        Directory.current.path + Platform.pathSeparator + config.appName;
    await _generator.generate(config, targetPath);

    // Generate template-specific features if not blank
    if (template != ProjectTemplate.blank) {
      final templateBundle = TemplateLibrary.getTemplate(template, config);
      if (templateBundle.requiredFeatures.isNotEmpty) {
        _logger.info('');
        _logger.info('🎯 Generating template features...');
        // TODO: Implement feature generation for template
        _logger.info(
            '   Note: Template feature generation will be available in a future update');
      }
    }
  }

  /// Parse template choice from interactive wizard
  ProjectTemplate _parseTemplateChoice(String choice) {
    if (choice.startsWith('Blank')) {
      return ProjectTemplate.blank;
    } else if (choice.startsWith('E-Commerce')) {
      return ProjectTemplate.ecommerce;
    } else if (choice.startsWith('Social Media')) {
      return ProjectTemplate.socialMedia;
    } else if (choice.startsWith('Fitness Tracker')) {
      return ProjectTemplate.fitnessTracker;
    } else if (choice.startsWith('Finance App')) {
      return ProjectTemplate.financeApp;
    } else if (choice.startsWith('Food Delivery')) {
      return ProjectTemplate.foodDelivery;
    } else if (choice.startsWith('Chat App')) {
      return ProjectTemplate.chatApp;
    }
    return ProjectTemplate.blank;
  }

  Future<BlueprintConfig> _gatherConfig(
    ArgResults results,
    String providedAppName,
  ) async {
    // App name with validation
    String appName = providedAppName;
    if (appName.isEmpty) {
      while (true) {
        appName = await _prompter.prompt(
          'Enter app name',
          defaultValue: 'my_app',
        );

        try {
          appName = InputValidator.validatePackageName(
            appName,
            fieldName: 'app name',
          );
          break;
        } on ArgumentError catch (e) {
          _logger.error('❌ ${e.message}');
          continue;
        }
      }
    }

    // State management
    final stateArg = results['state'] as String?;
    final StateManagement stateMgmt;
    if (stateArg != null) {
      stateMgmt = StateManagement.parse(stateArg);
    } else {
      final choice = await _prompter.choose(
        'Choose state management',
        ['provider', 'riverpod', 'bloc'],
        defaultValue: 'provider',
      );
      stateMgmt = StateManagement.parse(choice);
    }

    // CI/CD provider
    final ciArg = results['ci'] as String?;
    final CIProvider ciProvider;
    if (ciArg != null) {
      ciProvider = CIProvider.parse(ciArg);
    } else {
      ciProvider = CIProvider.none;
    }

    // Feature flags
    final includeTheme = await _resolveBoolFlag(
      results,
      'theme',
      'Include theme scaffolding?',
      defaultValue: true,
    );
    final includeLocalization = await _resolveBoolFlag(
      results,
      'localization',
      'Include localization setup?',
      defaultValue: false,
    );
    final includeEnv = await _resolveBoolFlag(
      results,
      'env',
      'Include environment config?',
      defaultValue: true,
    );
    final includeApi = await _resolveBoolFlag(
      results,
      'api',
      'Include API client?',
      defaultValue: true,
    );
    final includeTests = await _resolveBoolFlag(
      results,
      'tests',
      'Include test scaffolding?',
      defaultValue: true,
    );

    // Platforms (support comma-separated values or "all")
    final platformsArg = results['platforms'] as String?;
    final List<TargetPlatform> targetPlatforms;
    if (platformsArg != null) {
      targetPlatforms = TargetPlatform.parseMultiple(platformsArg);
    } else {
      targetPlatforms = [TargetPlatform.mobile];
    }

    return BlueprintConfig(
      appName: appName,
      platforms: targetPlatforms,
      stateManagement: stateMgmt,
      ciProvider: ciProvider,
      includeTheme: includeTheme,
      includeLocalization: includeLocalization,
      includeEnv: includeEnv,
      includeApi: includeApi,
      includeTests: includeTests,
    );
  }

  Future<bool> _resolveBoolFlag(
    ArgResults results,
    String flagName,
    String promptText, {
    required bool defaultValue,
  }) async {
    final flagValue = results[flagName] as bool?;
    if (flagValue != null) {
      return flagValue;
    }
    return _prompter.confirm(promptText, defaultValue: defaultValue);
  }

  void _printUsage(ArgParser parser) {
    _logger.info('flutter_blueprint - Smart Flutter scaffolding CLI\n');
    _logger.info('Usage: flutter_blueprint <command> [arguments]\n');
    _logger.info('Commands:');
    _logger.info('  init [app_name]        Create a new Flutter project');
    _logger.info(
        '                         If app_name is omitted, launches interactive wizard');
    _logger.info(
        '  add feature <name>     Add a new feature to existing project\n');
    _logger.info('Global options:');
    _logger.info(parser.usage);
    _logger.info('\nInit Examples:');
    _logger.info('  # Interactive wizard mode (recommended for beginners)');
    _logger.info('  flutter_blueprint init');
    _logger.info('');
    _logger.info('  # Quick mode with flags');
    _logger.info('  flutter_blueprint init my_app');
    _logger.info('  flutter_blueprint init my_app --state provider --theme');
    _logger.info(
        '  flutter_blueprint init my_app --state riverpod --no-localization');
    _logger.info('');
    _logger.info('  # With project preview (see structure before generation)');
    _logger.info('  flutter_blueprint init my_app --preview');
    _logger.info('  flutter_blueprint init my_app --state bloc --preview');
    _logger.info('');
    _logger.info('  # With latest dependency versions from pub.dev');
    _logger.info('  flutter_blueprint init my_app --latest-deps');
    _logger
        .info('  flutter_blueprint init my_app --state riverpod --latest-deps');
    _logger.info('');
    _logger.info('  # Using templates for common app types');
    _logger.info('  flutter_blueprint init my_store --template ecommerce');
    _logger.info('  flutter_blueprint init my_social --template social-media');
    _logger
        .info('  flutter_blueprint init my_fitness --template fitness-tracker');
    _logger.info('  flutter_blueprint init my_budget --template finance-app');
    _logger.info('  flutter_blueprint init my_food --template food-delivery');
    _logger.info('  flutter_blueprint init my_chat --template chat-app');
    _logger.info('');
    _logger.info('  # With CI/CD configuration');
    _logger.info('  flutter_blueprint init my_app --ci github');
    _logger.info('  flutter_blueprint init my_app --state bloc --ci gitlab');
    _logger.info('  flutter_blueprint init my_app --ci azure --api --tests');
    _logger.info('');
    _logger.info('Platform Examples:');
    _logger.info('  # Single platform');
    _logger.info(
        '  flutter_blueprint init my_app --platforms mobile --state bloc');
    _logger.info('');
    _logger.info('  # Multiple platforms (multi-platform project)');
    _logger.info(
        '  flutter_blueprint init my_app --platforms mobile,web --state bloc');
    _logger.info(
        '  flutter_blueprint init my_app --platforms mobile,web,desktop --state riverpod');
    _logger.info('');
    _logger.info('  # All platforms (universal app)');
    _logger.info(
        '  flutter_blueprint init my_app --platforms all --state provider');
    _logger.info('');
    _logger.info('  # Desktop-only application');
    _logger.info(
        '  flutter_blueprint init my_desktop_app --platforms desktop --state riverpod');
    _logger.info('');
    _logger.info('  # Mobile-only application');
    _logger.info(
        '  flutter_blueprint init my_mobile_app --platforms mobile --state provider');
    _logger.info('');
    _logger.info('Add Feature Examples:');
    _logger.info('  # Generate full feature (all layers)');
    _logger.info('  flutter_blueprint add feature auth');
    _logger.info('');
    _logger.info('  # Generate with API integration');
    _logger.info('  flutter_blueprint add feature products --api');
    _logger.info('');
    _logger.info('  # Generate only presentation layer');
    _logger.info(
        '  flutter_blueprint add feature settings --presentation --no-data --no-domain');
  }
}
