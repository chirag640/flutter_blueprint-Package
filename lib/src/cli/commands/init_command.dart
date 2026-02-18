/// Init command - creates a new Flutter project with blueprint architecture.
///
/// Extracted from the monolithic CliRunner._runInit method.
library;

import 'dart:io';

import 'package:args/args.dart';

import '../command_interface.dart';
import '../../core/errors.dart';
import '../../core/result.dart';
import '../../config/blueprint_config.dart';
import '../../config/api_config.dart';
import '../../config/config_repository.dart';
import '../../generator/project_generator.dart';
import '../../generator/feature_generator.dart';
import '../../templates/template_library.dart';
import '../../utils/input_validator.dart';
import '../../utils/project_preview.dart';
import '../../utils/logger.dart';
import '../../utils/dependency_manager.dart';

/// Creates a new Flutter project with blueprint architecture.
///
/// Supports both interactive wizard mode (no arguments) and
/// non-interactive mode (with CLI flags).
class InitCommand extends BaseCommand {
  InitCommand({
    ProjectGenerator? generator,
  }) : _generator = generator ?? ProjectGenerator();

  final ProjectGenerator _generator;

  @override
  String get name => 'init';

  @override
  String get description => 'Create a new Flutter project';

  @override
  String get usage => 'flutter_blueprint init [app_name] [options]';

  @override
  void configureArgs(ArgParser parser) {
    parser
      ..addOption('state',
          abbr: 's',
          help: 'State management (provider, riverpod, bloc)',
          allowed: ['provider', 'riverpod', 'bloc'])
      ..addOption('platforms',
          abbr: 'p',
          help: 'Target platforms (comma-separated: mobile,web,desktop)')
      ..addOption('ci',
          help: 'CI/CD provider', allowed: ['github', 'gitlab', 'azure'])
      ..addOption('template', abbr: 't', help: 'Project template', allowed: [
        'blank',
        'ecommerce',
        'social-media',
        'fitness-tracker',
        'finance-app',
        'food-delivery',
        'chat-app'
      ])
      ..addOption('from-config',
          help: 'Load project settings from a shared configuration')
      ..addFlag('preview',
          help: 'Show project structure preview', defaultsTo: null)
      ..addFlag('latest-deps',
          help: 'Fetch latest versions from pub.dev', defaultsTo: null)
      ..addFlag('theme', help: 'Include theme', defaultsTo: null)
      ..addFlag('localization', help: 'Include localization', defaultsTo: null)
      ..addFlag('env', help: 'Include environment config', defaultsTo: null)
      ..addFlag('api', help: 'Include API client', defaultsTo: null)
      ..addFlag('tests', help: 'Include test scaffolding', defaultsTo: null)
      ..addFlag('hive', help: 'Include Hive caching', defaultsTo: null)
      ..addFlag('pagination', help: 'Include pagination', defaultsTo: null)
      ..addOption('analytics',
          help: 'Analytics provider', allowed: ['firebase', 'sentry', 'none'])
      ..addFlag('websocket', help: 'Include WebSocket', defaultsTo: null)
      ..addFlag('push-notifications',
          help: 'Include push notifications', defaultsTo: null)
      ..addFlag('media', help: 'Include image/camera', defaultsTo: null)
      ..addFlag('maps', help: 'Include Google Maps', defaultsTo: null)
      ..addFlag('social-auth', help: 'Include social auth', defaultsTo: null)
      ..addFlag('theme-mode', help: 'Include dark/light mode', defaultsTo: null)
      ..addFlag('a11y', help: 'Include accessibility', defaultsTo: null);
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    try {
      String appName = args.rest.isNotEmpty ? args.rest.first : '';

      // Validate app name if provided
      if (appName.isNotEmpty) {
        try {
          appName = InputValidator.validatePackageName(
            appName,
            fieldName: 'app name',
          );
        } on ArgumentError catch (e) {
          return Result.failure(
            CommandError('Invalid app name: ${e.message}', command: name),
          );
        }
      }

      // If no app name and interactive, launch wizard
      if (appName.isEmpty && context.prompter.isInteractive) {
        return _runWizardMode(context);
      }

      // Gather config from flags
      final config = await _gatherConfig(args, appName, context);

      // Parse template
      final templateArg = args['template'] as String?;
      final template = templateArg != null
          ? ProjectTemplate.parse(templateArg)
          : ProjectTemplate.blank;

      // Show template info
      if (template != ProjectTemplate.blank) {
        _showTemplateInfo(context.logger, template);
      }

      // Show preview if requested
      final showPreview = args['preview'] as bool? ?? false;
      if (showPreview) {
        final previewer = ProjectPreview(logger: context.logger);
        previewer.show(config);

        final confirmed = await context.prompter.confirm(
          '🚀 Proceed with generation?',
          defaultValue: true,
        );
        if (!confirmed) {
          return const Result.success(
            CommandResult.ok('Cancelled. No files were created.'),
          );
        }
      }

      // Fetch latest deps if requested
      final fetchLatestDeps = args['latest-deps'] as bool? ?? false;
      if (fetchLatestDeps) {
        await _fetchLatestDeps(config, context.logger);
      }

      // Validate config
      final validationErrors = config.validate();
      if (validationErrors.isNotEmpty) {
        return Result.failure(
          CommandError(
            'Configuration validation failed:\n${validationErrors.join('\n')}',
            command: name,
          ),
        );
      }

      // Generate project
      final targetPath =
          Directory.current.path + Platform.pathSeparator + config.appName;

      final genResult = await _generator.generate(config, targetPath);
      if (genResult.isFailure) {
        return Result.failure(
          CommandError(
            'Project generation failed: ${genResult.errorOrNull}',
            command: name,
            cause: genResult.errorOrNull,
          ),
        );
      }

      context.logger.success(
        '✅ Generated ${genResult.valueOrNull!.filesGenerated} files',
      );

      // Template features
      if (template != ProjectTemplate.blank) {
        final templateBundle = TemplateLibrary.getTemplate(template, config);
        if (templateBundle.requiredFeatures.isNotEmpty) {
          context.logger.info('');
          context.logger.info('🎯 Generating template features...');

          final featureGen = FeatureGenerator(logger: context.logger);
          for (final featureName in templateBundle.requiredFeatures) {
            context.logger.info('   • $featureName');
            await featureGen.generate(
              featureName: featureName,
              config: config,
              targetPath: targetPath,
              includeData: true,
              includeDomain: true,
              includePresentation: true,
              includeApi: config.includeApi,
              updateRouter: true,
            );
          }

          context.logger.success('✅ Template features generated successfully!');
        }
      }

      return const Result.success(CommandResult.ok('Project created'));
    } catch (e) {
      return Result.failure(
        CommandError('Failed to create project: $e', command: name, cause: e),
      );
    }
  }

  /// Interactive wizard mode - guides user through all configuration options.
  Future<Result<CommandResult, CommandError>> _runWizardMode(
    CommandContext context,
  ) async {
    final logger = context.logger;
    final prompter = context.prompter;

    logger.info('');
    logger.info('🎯 Welcome to flutter_blueprint!');
    logger.info(
      '   Let\'s create your Flutter app with professional architecture.',
    );
    logger.info('');

    // Template selection
    final templateChoice = await prompter.choose(
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

    if (template != ProjectTemplate.blank) {
      _showTemplateInfo(logger, template);
    }

    // App name with validation
    String appName;
    while (true) {
      appName = await prompter.prompt('📱 App name', defaultValue: 'my_app');
      try {
        appName = InputValidator.validatePackageName(
          appName,
          fieldName: 'app name',
        );
        break;
      } on ArgumentError catch (e) {
        logger.error('❌ ${e.message}');
        logger.info('💡 Example: my_app, user_profile, shopping_cart');
        continue;
      }
    }

    // Platforms
    logger.info('');
    final platformSelections = await prompter.multiSelect(
      '💻 Choose target platforms',
      ['Mobile (iOS & Android)', 'Web', 'Desktop (Windows, macOS, Linux)'],
      defaultValues: ['Mobile (iOS & Android)'],
    );
    final targetPlatforms = _parsePlatformSelections(platformSelections);

    // State management
    logger.info('');
    final stateChoice = await prompter.choose(
      '🎯 Choose state management',
      ['provider', 'riverpod', 'bloc'],
      defaultValue: 'provider',
    );
    final stateMgmt = StateManagement.parse(stateChoice);

    // CI/CD
    logger.info('');
    final ciChoice = await prompter.choose(
      '🚀 Choose CI/CD provider (optional)',
      ['none', 'github', 'gitlab', 'azure'],
      defaultValue: 'none',
    );
    final ciProvider = CIProvider.parse(ciChoice);

    // Features
    logger.info('');
    final selectedFeatures = await prompter.multiSelect(
      '✨ Select features to include',
      [
        'Theme system (Light/Dark modes)',
        'Localization (i18n support)',
        'Environment config (.env)',
        'API client (Dio + interceptors)',
        'Test scaffolding',
        'Hive offline caching',
        'Pagination support',
        'Analytics & Crash Reporting',
        'WebSocket',
        'Push Notifications',
        'Image Picker/Camera',
        'Maps Integration',
        'Social Auth',
        'Dark/Light Mode Detection',
        'Accessibility',
      ],
      defaultValues: [
        'Theme system (Light/Dark modes)',
        'API client (Dio + interceptors)',
      ],
    );

    final features = _parseFeatureSelections(selectedFeatures);

    // Analytics provider
    AnalyticsProvider analyticsProvider = AnalyticsProvider.none;
    if (features['analytics']!) {
      logger.info('');
      final providerChoice = await prompter.choose(
        '📊 Choose analytics provider',
        ['firebase', 'sentry'],
        defaultValue: 'firebase',
      );
      analyticsProvider = AnalyticsProvider.parse(providerChoice);
    }

    // API config
    ApiConfig apiConfig = ApiConfig.modern;
    if (features['api']!) {
      logger.info('');
      final apiChoice = await prompter.choose(
        '🔌 Choose your backend type',
        [
          'Modern REST (HTTP 200 + JSON data)',
          'Legacy .NET (success: true/false)',
          'Laravel (data wrapper)',
          'Django REST (results array)',
          'Custom (configure manually)',
        ],
        defaultValue: 'Modern REST (HTTP 200 + JSON data)',
      );
      apiConfig = _parseApiChoice(apiChoice);
      if (apiChoice.startsWith('Custom')) {
        apiConfig = await _promptForCustomApiConfig(prompter, logger);
      }
    }

    // Build config
    final config = BlueprintConfig(
      appName: appName,
      stateManagement: stateMgmt,
      platforms: targetPlatforms,
      ciProvider: ciProvider,
      includeTheme: features['theme']!,
      includeLocalization: features['localization']!,
      includeEnv: features['env']!,
      includeApi: features['api']!,
      includeTests: features['tests']!,
      includeHive: features['hive']!,
      includePagination: features['pagination']!,
      includeAnalytics: features['analytics']!,
      analyticsProvider: analyticsProvider,
      apiConfig: apiConfig,
      includeWebSocket: features['websocket']!,
      includePushNotifications: features['push_notifications']!,
      includeMedia: features['media']!,
      includeMaps: features['maps']!,
      includeSocialAuth: features['social_auth']!,
      includeThemeMode: features['theme_mode']!,
      includeAccessibility: features['accessibility']!,
    );

    // Summary
    _printConfigSummary(logger, config, template);

    // Preview
    final wantPreview = await prompter.confirm(
      '🏗️  Show project structure preview?',
      defaultValue: true,
    );
    if (wantPreview) {
      ProjectPreview(logger: logger).show(config);
    }

    // Latest deps
    final fetchLatest = await prompter.confirm(
      '🔍 Fetch latest dependency versions?',
      defaultValue: false,
    );
    if (fetchLatest) {
      await _fetchLatestDeps(config, logger);
    }

    // Validate
    final validationErrors = config.validate();
    if (validationErrors.isNotEmpty) {
      return Result.failure(
        CommandError(
          'Validation failed:\n${validationErrors.join('\n')}',
          command: name,
        ),
      );
    }

    // Confirm
    logger.info('');
    final confirmed = await prompter.confirm(
      '🚀 Ready to generate your app?',
      defaultValue: true,
    );
    if (!confirmed) {
      return const Result.success(
        CommandResult.ok('Cancelled. No files were created.'),
      );
    }

    // Generate
    final targetPath =
        Directory.current.path + Platform.pathSeparator + config.appName;
    await _generator.generate(config, targetPath);

    if (template != ProjectTemplate.blank) {
      final templateBundle = TemplateLibrary.getTemplate(template, config);
      if (templateBundle.requiredFeatures.isNotEmpty) {
        logger.info('');
        logger.info('🎯 Generating template features...');
        logger.info(
          '   Note: Template feature generation will be available in a future update',
        );
      }
    }

    return const Result.success(CommandResult.ok('Project created'));
  }

  Future<BlueprintConfig> _gatherConfig(
    ArgResults results,
    String appName,
    CommandContext context,
  ) async {
    final fromConfig = results['from-config'] as String?;
    if (fromConfig != null) {
      final repository = ConfigRepository(logger: context.logger);
      final sharedConfig = await repository.load(fromConfig);
      context.logger.info('✅ Loaded configuration: ${sharedConfig.name}');
      return sharedConfig.toBlueprintConfig(appName);
    }

    if (appName.isEmpty) {
      while (true) {
        appName = await context.prompter.prompt(
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
          context.logger.error('❌ ${e.message}');
        }
      }
    }

    final stateArg = results['state'] as String?;
    final stateMgmt = stateArg != null
        ? StateManagement.parse(stateArg)
        : StateManagement.provider;

    final ciArg = results['ci'] as String?;
    final ciProvider =
        ciArg != null ? CIProvider.parse(ciArg) : CIProvider.none;

    final platformsArg = results['platforms'] as String?;
    final targetPlatforms = platformsArg != null
        ? TargetPlatform.parseMultiple(platformsArg)
        : [TargetPlatform.mobile];

    final analyticsArg = results['analytics'] as String?;
    final bool includeAnalytics;
    final AnalyticsProvider analyticsProvider;
    if (analyticsArg != null && analyticsArg != 'none') {
      includeAnalytics = true;
      analyticsProvider = AnalyticsProvider.parse(analyticsArg);
    } else {
      includeAnalytics = false;
      analyticsProvider = AnalyticsProvider.none;
    }

    return BlueprintConfig(
      appName: appName,
      platforms: targetPlatforms,
      stateManagement: stateMgmt,
      ciProvider: ciProvider,
      includeTheme: _resolveBool(results, 'theme', true),
      includeLocalization: _resolveBool(results, 'localization', false),
      includeEnv: _resolveBool(results, 'env', true),
      includeApi: _resolveBool(results, 'api', true),
      includeTests: _resolveBool(results, 'tests', true),
      includeHive: _resolveBool(results, 'hive', false),
      includePagination: _resolveBool(results, 'pagination', false),
      includeAnalytics: includeAnalytics,
      analyticsProvider: analyticsProvider,
      includeWebSocket: _resolveBool(results, 'websocket', false),
      includePushNotifications:
          _resolveBool(results, 'push-notifications', false),
      includeMedia: _resolveBool(results, 'media', false),
      includeMaps: _resolveBool(results, 'maps', false),
      includeSocialAuth: _resolveBool(results, 'social-auth', false),
      includeThemeMode: _resolveBool(results, 'theme-mode', false),
      includeAccessibility: _resolveBool(results, 'a11y', false),
    );
  }

  bool _resolveBool(ArgResults results, String flagName, bool defaultValue) {
    final value = results[flagName] as bool?;
    return value ?? defaultValue;
  }

  void _showTemplateInfo(Logger logger, ProjectTemplate template) {
    logger.info('');
    logger.info('📦 Using template: ${template.label}');
    logger.info('   ${template.description}');
    logger.info('');
    logger.info('   Features included:');
    for (final feature in template.features.take(5)) {
      logger.info('     • $feature');
    }
    if (template.features.length > 5) {
      logger.info('     ... and ${template.features.length - 5} more');
    }
    logger.info('');
  }

  void _printConfigSummary(
    Logger logger,
    BlueprintConfig config,
    ProjectTemplate template,
  ) {
    logger.info('');
    logger.info('📋 Configuration Summary:');
    if (template != ProjectTemplate.blank) {
      logger.info('   Template: ${template.label}');
    }
    logger.info('   App name: ${config.appName}');
    logger.info(
      '   Platforms: ${config.platforms.map((p) => p.label).join(', ')}',
    );
    logger.info('   State management: ${config.stateManagement.label}');
    logger.info('   CI/CD: ${config.ciProvider.label}');
    _printFeatureFlag(logger, 'Theme', config.includeTheme);
    _printFeatureFlag(logger, 'Localization', config.includeLocalization);
    _printFeatureFlag(logger, 'Environment', config.includeEnv);
    _printFeatureFlag(logger, 'API client', config.includeApi);
    _printFeatureFlag(logger, 'Tests', config.includeTests);
    _printFeatureFlag(logger, 'Hive caching', config.includeHive);
    _printFeatureFlag(logger, 'Pagination', config.includePagination);
    if (config.includeAnalytics) {
      logger.info(
        '   Analytics: ✅ (${config.analyticsProvider.label})',
      );
    } else {
      _printFeatureFlag(logger, 'Analytics', false);
    }
    _printFeatureFlag(logger, 'WebSocket', config.includeWebSocket);
    _printFeatureFlag(
      logger,
      'Push Notifications',
      config.includePushNotifications,
    );
    _printFeatureFlag(logger, 'Image Picker/Camera', config.includeMedia);
    _printFeatureFlag(logger, 'Maps', config.includeMaps);
    _printFeatureFlag(logger, 'Social Auth', config.includeSocialAuth);
    _printFeatureFlag(logger, 'Theme Mode Detection', config.includeThemeMode);
    _printFeatureFlag(logger, 'Accessibility', config.includeAccessibility);
    logger.info('');
  }

  void _printFeatureFlag(Logger logger, String name, bool enabled) {
    logger.info('   $name: ${enabled ? '✅' : '❌'}');
  }

  ProjectTemplate _parseTemplateChoice(String choice) {
    if (choice.startsWith('Blank')) return ProjectTemplate.blank;
    if (choice.startsWith('E-Commerce')) return ProjectTemplate.ecommerce;
    if (choice.startsWith('Social Media')) return ProjectTemplate.socialMedia;
    if (choice.startsWith('Fitness Tracker')) {
      return ProjectTemplate.fitnessTracker;
    }
    if (choice.startsWith('Finance App')) return ProjectTemplate.financeApp;
    if (choice.startsWith('Food Delivery')) return ProjectTemplate.foodDelivery;
    if (choice.startsWith('Chat App')) return ProjectTemplate.chatApp;
    return ProjectTemplate.blank;
  }

  List<TargetPlatform> _parsePlatformSelections(List<String> selections) {
    final platforms = <TargetPlatform>[];
    if (selections.any((s) => s.contains('Mobile'))) {
      platforms.add(TargetPlatform.mobile);
    }
    if (selections.any((s) => s.contains('Web'))) {
      platforms.add(TargetPlatform.web);
    }
    if (selections.any((s) => s.contains('Desktop'))) {
      platforms.add(TargetPlatform.desktop);
    }
    if (platforms.isEmpty) platforms.add(TargetPlatform.mobile);
    return platforms;
  }

  Map<String, bool> _parseFeatureSelections(List<String> selections) {
    return {
      'theme': selections.any((f) => f.contains('Theme system')),
      'localization': selections.any((f) => f.contains('Localization')),
      'env': selections.any((f) => f.contains('Environment')),
      'api': selections.any((f) => f.contains('API')),
      'tests': selections.any((f) => f.contains('Test')),
      'hive': selections.any((f) => f.contains('Hive')),
      'pagination': selections.any((f) => f.contains('Pagination')),
      'analytics': selections.any((f) => f.contains('Analytics')),
      'websocket': selections.any((f) => f.contains('WebSocket')),
      'push_notifications':
          selections.any((f) => f.contains('Push Notifications')),
      'media': selections.any((f) => f.contains('Image Picker')),
      'maps': selections.any((f) => f.contains('Maps Integration')),
      'social_auth': selections.any((f) => f.contains('Social Auth')),
      'theme_mode': selections.any((f) => f.contains('Dark/Light Mode')),
      'accessibility': selections.any((f) => f.contains('Accessibility')),
    };
  }

  ApiConfig _parseApiChoice(String choice) {
    if (choice.startsWith('Modern')) return ApiConfig.modern;
    if (choice.startsWith('Legacy .NET')) return ApiConfig.legacyDotNet;
    if (choice.startsWith('Laravel')) return ApiConfig.laravel;
    if (choice.startsWith('Django')) return ApiConfig.django;
    return ApiConfig.modern;
  }

  Future<ApiConfig> _promptForCustomApiConfig(
    dynamic prompter,
    Logger logger,
  ) async {
    logger.info('');
    logger.info('📝 Custom API Configuration:');
    logger.info('');

    final successKey = await prompter.prompt(
      'Success key (leave empty for none)',
      defaultValue: '',
    ) as String;

    dynamic successValue = true;
    if (successKey.isNotEmpty) {
      final successValueStr = await prompter.prompt(
        'Success value (e.g., "true", "200")',
        defaultValue: 'true',
      ) as String;
      if (successValueStr == 'true') {
        successValue = true;
      } else if (successValueStr == 'false') {
        successValue = false;
      } else if (int.tryParse(successValueStr) != null) {
        successValue = int.parse(successValueStr);
      } else {
        successValue = successValueStr;
      }
    }

    final dataKey = await prompter.prompt(
      'Data key',
      defaultValue: 'data',
    ) as String;
    final nestedDataPath = await prompter.prompt(
      'Nested data path (leave empty if none)',
      defaultValue: '',
    ) as String;
    final errorMessagePath = await prompter.prompt(
      'Error message path',
      defaultValue: 'message',
    ) as String;
    final errorCodePath = await prompter.prompt(
      'Error code path',
      defaultValue: 'code',
    ) as String;

    final tokenSourceChoice = await prompter.choose(
      'Where are auth tokens returned?',
      ['Response body', 'Response headers'],
      defaultValue: 'Response body',
    ) as String;
    final tokenSource = tokenSourceChoice.contains('body')
        ? TokenSource.body
        : TokenSource.header;

    final accessTokenPath = await prompter.prompt(
      'Access token path',
      defaultValue: 'data.accessToken',
    ) as String;
    final refreshTokenPath = await prompter.prompt(
      'Refresh token path (leave empty if none)',
      defaultValue: 'data.refreshToken',
    ) as String;
    final authHeaderName = await prompter.prompt(
      'Auth header name',
      defaultValue: 'Authorization',
    ) as String;
    final authHeaderPrefix = await prompter.prompt(
      'Auth header prefix',
      defaultValue: 'Bearer ',
    ) as String;

    return ApiConfig(
      successKey: successKey,
      successValue: successValue,
      dataKey: dataKey,
      nestedDataPath: nestedDataPath.isEmpty ? null : nestedDataPath,
      errorMessagePath: errorMessagePath,
      errorCodePath: errorCodePath,
      tokenSource: tokenSource,
      accessTokenPath: accessTokenPath,
      refreshTokenPath: refreshTokenPath.isEmpty ? null : refreshTokenPath,
      authHeaderName: authHeaderName,
      authHeaderPrefix: authHeaderPrefix,
    );
  }

  Future<void> _fetchLatestDeps(BlueprintConfig config, Logger logger) async {
    logger.info('');
    final depManager = DependencyManager(logger: logger);
    try {
      await depManager.getRecommendedDependencies(
        stateManagement: config.stateManagement.label,
        includeApi: config.includeApi,
        includeLocalization: config.includeLocalization,
        includeHive: config.includeHive,
        includeAnalytics: config.includeAnalytics,
        analyticsProvider: config.analyticsProvider.label,
      );
    } finally {
      depManager.close();
    }
  }
}
