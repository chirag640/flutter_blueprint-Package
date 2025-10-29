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

/// Configuration produced by the CLI and persisted to `blueprint.yaml`.
class BlueprintConfig {
  const BlueprintConfig({
    required this.appName,
    required this.platform,
    required this.stateManagement,
    required this.includeTheme,
    required this.includeLocalization,
    required this.includeEnv,
    required this.includeApi,
    required this.includeTests,
  });

  final String appName;
  final String platform;
  final StateManagement stateManagement;
  final bool includeTheme;
  final bool includeLocalization;
  final bool includeEnv;
  final bool includeApi;
  final bool includeTests;

  BlueprintConfig copyWith({
    String? appName,
    String? platform,
    StateManagement? stateManagement,
    bool? includeTheme,
    bool? includeLocalization,
    bool? includeEnv,
    bool? includeApi,
    bool? includeTests,
  }) {
    return BlueprintConfig(
      appName: appName ?? this.appName,
      platform: platform ?? this.platform,
      stateManagement: stateManagement ?? this.stateManagement,
      includeTheme: includeTheme ?? this.includeTheme,
      includeLocalization: includeLocalization ?? this.includeLocalization,
      includeEnv: includeEnv ?? this.includeEnv,
      includeApi: includeApi ?? this.includeApi,
      includeTests: includeTests ?? this.includeTests,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'app_name': appName,
      'platform': platform,
      'state_management': stateManagement.label,
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
    return BlueprintConfig(
      appName: (map['app_name'] ?? '') as String,
      platform: (map['platform'] ?? 'mobile') as String,
      stateManagement: StateManagement.parse(
        (map['state_management'] ?? 'provider') as String,
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
