import 'dart:collection';

/// Supported state-management approaches.
enum StateManagement {
  provider,
  riverpod,
  bloc;

  String get label => name;

  static StateManagement parse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final candidate in StateManagement.values) {
      if (candidate.name == normalized) {
        return candidate;
      }
    }
    throw ArgumentError('Unsupported state management option: $value');
  }
}

/// Supported platform targets.
enum TargetPlatform {
  mobile,
  web,
  desktop;

  String get label => name;

  static TargetPlatform parse(String value) {
    final normalized = value.trim().toLowerCase();

    // Direct match
    for (final candidate in TargetPlatform.values) {
      if (candidate.name == normalized) {
        return candidate;
      }
    }

    // Handle android/ios as mobile
    if (normalized == 'android' || normalized == 'ios') {
      return TargetPlatform.mobile;
    }

    // Handle windows/macos/linux as desktop
    if (normalized == 'windows' ||
        normalized == 'macos' ||
        normalized == 'linux') {
      return TargetPlatform.desktop;
    }

    throw ArgumentError(
        'Unsupported platform: $value. Use: mobile, web, desktop (or android, ios, windows, macos, linux)');
  }

  /// Parse comma-separated list of platforms (e.g., "mobile,web,desktop")
  /// Also supports "all" to include all platforms
  /// Accepts specific platforms like "android,ios,web" which map to "mobile,web"
  static List<TargetPlatform> parseMultiple(String value) {
    final normalized = value.trim().toLowerCase();

    // Handle "all" shorthand
    if (normalized == 'all') {
      return TargetPlatform.values;
    }

    // Handle comma-separated values
    final parts =
        normalized.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    final platforms = <TargetPlatform>{}; // Use Set to avoid duplicates

    for (final part in parts) {
      platforms.add(parse(part));
    }

    if (platforms.isEmpty) {
      throw ArgumentError('At least one platform must be specified');
    }

    return platforms.toList();
  }
}

/// Supported CI/CD providers.
enum CIProvider {
  none,
  github,
  gitlab,
  azure;

  String get label => name;

  static CIProvider parse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final candidate in CIProvider.values) {
      if (candidate.name == normalized) {
        return candidate;
      }
    }
    throw ArgumentError('Unsupported CI provider: $value');
  }
}

/// Configuration produced by the CLI and persisted to `blueprint.yaml`.
///
/// This class holds all project generation settings including app name,
/// target platforms, state management choice, and optional features.
class BlueprintConfig {
  /// Creates a new blueprint configuration.
  ///
  /// All parameters except [ciProvider] are required. The [platforms] list
  /// must contain at least one platform.
  const BlueprintConfig({
    required this.appName,
    required this.platforms,
    required this.stateManagement,
    required this.includeTheme,
    required this.includeLocalization,
    required this.includeEnv,
    required this.includeApi,
    required this.includeTests,
    this.ciProvider = CIProvider.none,
    this.includeHive = false,
  });

  /// The name of the Flutter application (must be valid Dart package name).
  final String appName;

  /// List of target platforms (mobile, web, desktop).
  final List<TargetPlatform> platforms;

  /// The state management solution to use.
  final StateManagement stateManagement;

  /// Whether to include theme scaffolding (light/dark mode).
  final bool includeTheme;

  /// Whether to include localization (i18n) setup.
  final bool includeLocalization;

  /// Whether to include environment configuration (.env support).
  final bool includeEnv;

  /// Whether to include API client with Dio and interceptors.
  final bool includeApi;

  /// Whether to include test scaffolding.
  final bool includeTests;

  /// Whether to include Hive offline caching support.
  final bool includeHive;

  /// The CI/CD provider to generate configuration for.
  final CIProvider ciProvider;

  /// Check if multiple platforms are selected
  bool get isMultiPlatform => platforms.length > 1;

  /// Check if specific platform is included
  bool hasPlatform(TargetPlatform platform) => platforms.contains(platform);

  /// Check if all platforms are selected
  bool get isUniversal => platforms.length == TargetPlatform.values.length;

  /// Creates a copy of this configuration with optionally updated values.
  ///
  /// Any parameter set to null will retain its current value.
  BlueprintConfig copyWith({
    String? appName,
    List<TargetPlatform>? platforms,
    StateManagement? stateManagement,
    bool? includeTheme,
    bool? includeLocalization,
    bool? includeEnv,
    bool? includeApi,
    bool? includeTests,
    CIProvider? ciProvider,
    bool? includeHive,
  }) {
    return BlueprintConfig(
      appName: appName ?? this.appName,
      platforms: platforms ?? this.platforms,
      stateManagement: stateManagement ?? this.stateManagement,
      includeTheme: includeTheme ?? this.includeTheme,
      includeLocalization: includeLocalization ?? this.includeLocalization,
      includeEnv: includeEnv ?? this.includeEnv,
      includeApi: includeApi ?? this.includeApi,
      includeTests: includeTests ?? this.includeTests,
      ciProvider: ciProvider ?? this.ciProvider,
      includeHive: includeHive ?? this.includeHive,
    );
  }

  /// Converts this configuration to a map for serialization to YAML.
  Map<String, dynamic> toMap() {
    return {
      'app_name': appName,
      'platforms': platforms.map((p) => p.label).toList(),
      'state_management': stateManagement.label,
      'ci_provider': ciProvider.label,
      'features': SplayTreeMap<String, dynamic>.from({
        'theme': includeTheme,
        'localization': includeLocalization,
        'env': includeEnv,
        'api': includeApi,
        'tests': includeTests,
        'hive': includeHive,
      }),
    };
  }

  /// Creates a configuration from a map loaded from YAML.
  ///
  /// Supports both old single-platform and new multi-platform formats
  /// for backwards compatibility.
  static BlueprintConfig fromMap(Map<Object?, Object?> map) {
    final features = Map<Object?, Object?>.from(
      (map['features'] as Map?) ?? <Object?, Object?>{},
    );

    // Handle both old single platform and new multiple platforms format
    List<TargetPlatform> platforms;
    if (map.containsKey('platforms')) {
      final platformsData = map['platforms'];
      if (platformsData is List) {
        platforms = platformsData
            .map((p) => TargetPlatform.parse(p.toString()))
            .toList();
      } else {
        platforms = [TargetPlatform.parse(platformsData.toString())];
      }
    } else if (map.containsKey('platform')) {
      // Backwards compatibility
      platforms = [
        TargetPlatform.parse((map['platform'] ?? 'mobile') as String)
      ];
    } else {
      platforms = [TargetPlatform.mobile];
    }

    return BlueprintConfig(
      appName: (map['app_name'] ?? '') as String,
      platforms: platforms,
      stateManagement: StateManagement.parse(
        (map['state_management'] ?? 'provider') as String,
      ),
      ciProvider: CIProvider.parse(
        (map['ci_provider'] ?? 'none') as String,
      ),
      includeTheme: _readBool(features['theme'], fallback: true),
      includeLocalization: _readBool(features['localization'], fallback: false),
      includeEnv: _readBool(features['env'], fallback: true),
      includeApi: _readBool(features['api'], fallback: true),
      includeTests: _readBool(features['tests'], fallback: true),
      includeHive: _readBool(features['hive'], fallback: false),
    );
  }

  static bool _readBool(Object? value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return value.toLowerCase() == 'true';
    }
    return fallback;
  }
}
