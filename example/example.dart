// Copyright (c) 2025, flutter_blueprint contributors.
// Licensed under the MIT License. See LICENSE for details.

/// Example demonstrating the programmatic usage of flutter_blueprint.
///
/// This package is primarily a CLI tool, but can also be used programmatically
/// to generate Flutter project scaffolding.
library;

import 'package:flutter_blueprint/flutter_blueprint.dart';

void main() async {
  // Example 1: Create a simple mobile app configuration
  final simpleConfig = BlueprintConfig(
    appName: 'my_app',
    platforms: [TargetPlatform.mobile],
    stateManagement: StateManagement.provider,
    includeTheme: true,
    includeLocalization: false,
    includeEnv: true,
    includeApi: true,
    includeTests: true,
  );

  print('Simple Config: ${simpleConfig.appName}');
  print('Platforms: ${simpleConfig.platforms.map((p) => p.label).join(', ')}');

  // Example 2: Create a full-featured multi-platform configuration
  final fullConfig = BlueprintConfig(
    appName: 'enterprise_app',
    platforms: [
      TargetPlatform.mobile,
      TargetPlatform.web,
      TargetPlatform.desktop
    ],
    stateManagement: StateManagement.riverpod,
    includeTheme: true,
    includeLocalization: true,
    includeEnv: true,
    includeApi: true,
    includeTests: true,
    ciProvider: CIProvider.github,
    includeHive: true,
    includePagination: true,
    includeAnalytics: true,
    analyticsProvider: AnalyticsProvider.firebase,
  );

  print('\nEnterprise Config: ${fullConfig.appName}');
  print('Is Multi-Platform: ${fullConfig.isMultiPlatform}');
  print('Is Universal: ${fullConfig.isUniversal}');
  print('CI Provider: ${fullConfig.ciProvider.label}');

  // Example 3: Validate configuration
  final errors = fullConfig.validate();
  if (errors.isEmpty) {
    print('\n✅ Configuration is valid!');
  } else {
    print('\n❌ Configuration errors:');
    for (final error in errors) {
      print('  - $error');
    }
  }

  // Example 4: Serialize configuration to Map (for YAML export)
  final configMap = simpleConfig.toMap();
  print('\nSerialized config:');
  print('  App Name: ${configMap['app_name']}');
  print('  State Management: ${configMap['state_management']}');

  // Example 5: Use the generator programmatically
  // Note: Actual generation requires a file system and output directory
  print('\n--- Generator Usage ---');
  print('To generate a project, use:');
  print('  final generator = BlueprintGenerator();');
  print('  await generator.generate(config, outputPath);');
}
