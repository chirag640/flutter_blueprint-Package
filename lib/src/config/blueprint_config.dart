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
    for (final candidate in TargetPlatform.values) {
      if (candidate.name == normalized) {
        return candidate;
      }
    }
    throw ArgumentError('Unsupported platform: $value');
  }

  /// Parse comma-separated list of platforms (e.g., "mobile,web,desktop")
  /// Also supports "all" to include all platforms
  static List<TargetPlatform> parseMultiple(String value) {
    final normalized = value.trim().toLowerCase();

    // Handle "all" shorthand
    if (normalized == 'all') {
      return TargetPlatform.values;
    }

    // Handle comma-separated values
    final parts =
        normalized.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    final platforms = <TargetPlatform>[];

    for (final part in parts) {
      platforms.add(parse(part));
    }

    if (platforms.isEmpty) {
      throw ArgumentError('At least one platform must be specified');
    }

    return platforms;
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
class BlueprintConfig {
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
  });

  final String appName;
  final List<TargetPlatform> platforms;
  final StateManagement stateManagement;
  final bool includeTheme;
  final bool includeLocalization;
  final bool includeEnv;
  final bool includeApi;
  final bool includeTests;
  final CIProvider ciProvider;

  /// Check if multiple platforms are selected
  bool get isMultiPlatform => platforms.length > 1;

  /// Check if specific platform is included
  bool hasPlatform(TargetPlatform platform) => platforms.contains(platform);

  /// Check if all platforms are selected
  bool get isUniversal => platforms.length == TargetPlatform.values.length;

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
    );
  }

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
      }),
    };
  }

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
