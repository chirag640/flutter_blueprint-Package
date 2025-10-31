/// Configuration for performance monitoring and profiling
library;

/// Represents the performance configuration from blueprint.yaml
class PerformanceConfig {
  /// Whether performance monitoring is enabled
  final bool enabled;

  /// List of performance metrics to track
  final PerformanceTracking tracking;

  /// Alert thresholds for performance issues
  final PerformanceAlerts alerts;

  const PerformanceConfig({
    required this.enabled,
    required this.tracking,
    required this.alerts,
  });

  /// Creates a [PerformanceConfig] from a YAML map
  factory PerformanceConfig.fromYaml(Map<String, dynamic> yaml) {
    final enabled = yaml['enabled'] as bool? ?? false;
    final trackingYaml = yaml['tracking'] as List? ?? [];
    final alertsYaml = yaml['alerts'] as Map<String, dynamic>? ?? {};

    return PerformanceConfig(
      enabled: enabled,
      tracking: PerformanceTracking.fromList(
        trackingYaml.cast<String>(),
      ),
      alerts: PerformanceAlerts.fromYaml(alertsYaml),
    );
  }

  /// Creates a default configuration with performance monitoring disabled
  factory PerformanceConfig.disabled() {
    return PerformanceConfig(
      enabled: false,
      tracking: PerformanceTracking.none(),
      alerts: PerformanceAlerts.defaults(),
    );
  }

  /// Creates a default configuration with all tracking enabled
  factory PerformanceConfig.allEnabled() {
    return PerformanceConfig(
      enabled: true,
      tracking: PerformanceTracking.all(),
      alerts: PerformanceAlerts.defaults(),
    );
  }

  /// Converts the configuration to a YAML map
  Map<String, dynamic> toYaml() {
    return {
      'enabled': enabled,
      'tracking': tracking.toList(),
      'alerts': alerts.toYaml(),
    };
  }

  @override
  String toString() {
    return 'PerformanceConfig(enabled: $enabled, tracking: $tracking, alerts: $alerts)';
  }
}

/// Represents which performance metrics should be tracked
class PerformanceTracking {
  /// Track app startup time
  final bool appStartTime;

  /// Track screen load time
  final bool screenLoadTime;

  /// Track API response time
  final bool apiResponseTime;

  /// Track frame render time
  final bool frameRenderTime;

  const PerformanceTracking({
    this.appStartTime = false,
    this.screenLoadTime = false,
    this.apiResponseTime = false,
    this.frameRenderTime = false,
  });

  /// Creates tracking configuration from a list of metric names
  factory PerformanceTracking.fromList(List<String> metrics) {
    return PerformanceTracking(
      appStartTime: metrics.contains('app_start_time'),
      screenLoadTime: metrics.contains('screen_load_time'),
      apiResponseTime: metrics.contains('api_response_time'),
      frameRenderTime: metrics.contains('frame_render_time'),
    );
  }

  /// Creates a configuration with no tracking enabled
  factory PerformanceTracking.none() {
    return const PerformanceTracking();
  }

  /// Creates a configuration with all tracking enabled
  factory PerformanceTracking.all() {
    return const PerformanceTracking(
      appStartTime: true,
      screenLoadTime: true,
      apiResponseTime: true,
      frameRenderTime: true,
    );
  }

  /// Converts to a list of metric names
  List<String> toList() {
    final metrics = <String>[];
    if (appStartTime) metrics.add('app_start_time');
    if (screenLoadTime) metrics.add('screen_load_time');
    if (apiResponseTime) metrics.add('api_response_time');
    if (frameRenderTime) metrics.add('frame_render_time');
    return metrics;
  }

  /// Returns true if any tracking is enabled
  bool get hasAnyEnabled =>
      appStartTime || screenLoadTime || apiResponseTime || frameRenderTime;

  @override
  String toString() {
    return 'PerformanceTracking(${toList().join(', ')})';
  }
}

/// Alert thresholds for performance issues
class PerformanceAlerts {
  /// Threshold for slow screen loads (in milliseconds)
  final int slowScreenThreshold;

  /// Threshold for slow API responses (in milliseconds)
  final int slowApiThreshold;

  /// Threshold for slow app startup (in milliseconds)
  final int slowStartupThreshold;

  /// Threshold for frame drops
  final int frameDropThreshold;

  const PerformanceAlerts({
    this.slowScreenThreshold = 500,
    this.slowApiThreshold = 2000,
    this.slowStartupThreshold = 1000,
    this.frameDropThreshold = 16,
  });

  /// Creates alerts from a YAML map
  factory PerformanceAlerts.fromYaml(Map<String, dynamic> yaml) {
    return PerformanceAlerts(
      slowScreenThreshold: _parseThreshold(
        yaml['slow_screen_threshold'],
        500,
      ),
      slowApiThreshold: _parseThreshold(
        yaml['slow_api_threshold'],
        2000,
      ),
      slowStartupThreshold: _parseThreshold(
        yaml['slow_startup_threshold'],
        1000,
      ),
      frameDropThreshold: _parseThreshold(
        yaml['frame_drop_threshold'],
        16,
      ),
    );
  }

  /// Creates default alert thresholds
  factory PerformanceAlerts.defaults() {
    return const PerformanceAlerts();
  }

  /// Parses a threshold value from various formats (e.g., "500ms", "2s", 1000)
  static int _parseThreshold(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;

    if (value is int) return value;

    if (value is String) {
      // Remove spaces
      final cleaned = value.replaceAll(' ', '').toLowerCase();

      // Parse milliseconds
      if (cleaned.endsWith('ms')) {
        final number = cleaned.substring(0, cleaned.length - 2);
        return int.tryParse(number) ?? defaultValue;
      }

      // Parse seconds
      if (cleaned.endsWith('s')) {
        final number = cleaned.substring(0, cleaned.length - 1);
        final seconds = int.tryParse(number);
        return seconds != null ? seconds * 1000 : defaultValue;
      }

      // Parse as plain number
      return int.tryParse(cleaned) ?? defaultValue;
    }

    return defaultValue;
  }

  /// Converts thresholds to a YAML map
  Map<String, dynamic> toYaml() {
    return {
      'slow_screen_threshold': '${slowScreenThreshold}ms',
      'slow_api_threshold': '${slowApiThreshold}ms',
      'slow_startup_threshold': '${slowStartupThreshold}ms',
      'frame_drop_threshold': '${frameDropThreshold}ms',
    };
  }

  @override
  String toString() {
    return 'PerformanceAlerts('
        'screen: ${slowScreenThreshold}ms, '
        'api: ${slowApiThreshold}ms, '
        'startup: ${slowStartupThreshold}ms, '
        'frame: ${frameDropThreshold}ms)';
  }
}

/// Represents a performance metric measurement
class PerformanceMetric {
  /// Name of the metric
  final String name;

  /// Value of the metric (typically in milliseconds)
  final double value;

  /// Unit of measurement
  final String unit;

  /// Timestamp when the metric was recorded
  final DateTime timestamp;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.name,
    required this.value,
    this.unit = 'ms',
    required this.timestamp,
    this.metadata,
  });

  /// Creates a metric from a JSON map
  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'ms',
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts the metric to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Returns a formatted string representation
  String format() {
    return '$name: ${value.toStringAsFixed(2)}$unit';
  }

  @override
  String toString() {
    return 'PerformanceMetric(${format()})';
  }
}
