# Performance & Optimization Features

This document describes the Performance & Optimization features added to flutter_blueprint.

## Overview

The Performance & Optimization features help you:

1. **Monitor Performance**: Track app startup, screen loads, API calls, and frame rendering
2. **Analyze Bundle Size**: Understand what's contributing to your app's size
3. **Optimize Assets**: Find unused assets and large images that need optimization
4. **Tree-Shaking Analysis**: Get recommendations for reducing code size

## Features

### 4.1 Performance Profiling Built-in

Automatic performance monitoring setup that can be configured in your `blueprint.yaml`:

```yaml
performance:
  enabled: true
  tracking:
    - app_start_time
    - screen_load_time
    - api_response_time
    - frame_render_time
  alerts:
    slow_screen_threshold: 500ms
    slow_api_threshold: 2s
    slow_startup_threshold: 1s
    frame_drop_threshold: 16ms
```

#### Benefits:

- ✅ Catch performance issues early
- ✅ Track performance metrics over time
- ✅ Automated performance testing in CI/CD
- ✅ Real-time alerts for regressions

#### Usage:

**Analyze performance configuration:**

```bash
flutter_blueprint analyze --performance
```

**Setup performance monitoring in existing project:**

```dart
import 'package:flutter_blueprint/flutter_blueprint.dart';

void main() async {
  final config = PerformanceConfig.allEnabled();
  final analyzer = PerformanceAnalyzer(
    config: config,
    projectPath: './my_project',
  );

  await analyzer.injectPerformanceMonitoring();
}
```

**Generated code usage:**

```dart
import 'core/performance_tracker.dart';

void main() {
  // Track app startup
  PerformanceTracker().markAppStart();

  runApp(const MyApp());

  // Record startup completion
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PerformanceTracker().recordAppStartComplete();
  });

  // Start frame monitoring
  PerformanceTracker().startFrameMonitoring();
}

// In your screens:
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    PerformanceTracker().markScreenLoadStart('MyScreen');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceTracker().recordScreenLoadComplete('MyScreen');
  }
}

// Track API calls:
Future<void> fetchData() async {
  final stopwatch = Stopwatch()..start();
  try {
    final response = await api.get('/endpoint');
    return response;
  } finally {
    stopwatch.stop();
    PerformanceTracker().recordApiResponse(
      '/endpoint',
      stopwatch.elapsedMilliseconds,
    );
  }
}
```

### 4.2 Bundle Size Optimization

Analyze and optimize your app's bundle size:

```bash
# Analyze bundle size
flutter_blueprint analyze --size

# Analyze with detailed breakdown
flutter_blueprint analyze --size --verbose

# Optimize bundle
flutter_blueprint optimize --tree-shake
flutter_blueprint optimize --assets
flutter_blueprint optimize --all

# Dry run (preview without making changes)
flutter_blueprint optimize --assets --dry-run
```

#### Example Output:

```
📊 Bundle Size Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 8.2 MB

Breakdown:
  - Code:      2.1 MB (25%)
  - Assets:    4.5 MB (55%)
  - Packages:  1.6 MB (20%)

💡 Optimization Suggestions:
  1. ⚠️  5 unused assets found (1.2 MB)
     Remove unused assets to reduce bundle size
       - assets/images/old_logo.png
       - assets/images/unused_icon.png
       - assets/fonts/old_font.ttf
       ... and 2 more

  2. ⚠️  3 large images not optimized (0.8 MB)
     Compress images or use WebP format
       - assets/images/banner.png (500 KB)
       - assets/images/background.jpg (300 KB)

  3. ✅  All packages tree-shaken
     Flutter automatically tree-shakes packages

  4. 💡 Consider lazy-loading 'analytics' package
     Defer loading of non-critical packages
       - analytics
       - firebase_crashlytics

Potential savings: 2.0 MB (24%)
```

#### Programmatic Usage:

```dart
import 'package:flutter_blueprint/flutter_blueprint.dart';

void main() async {
  final analyzer = BundleSizeAnalyzer(projectPath: './my_project');
  final report = await analyzer.analyze();

  print(report.toFormattedString());

  // Access specific data
  print('Total size: ${report.totalSize} bytes');
  print('Code size: ${report.codeSize.totalBytes} bytes');
  print('Potential savings: ${report.potentialSavings} bytes');

  // Check suggestions
  for (final suggestion in report.suggestions) {
    print('${suggestion.severityIcon} ${suggestion.title}');
    print('   ${suggestion.description}');
  }
}
```

## CLI Commands

### Analyze Command

```bash
# Bundle size analysis
flutter_blueprint analyze --size
flutter_blueprint analyze --size --verbose
flutter_blueprint analyze --size --json

# Performance analysis
flutter_blueprint analyze --performance

# All analyses
flutter_blueprint analyze --all

# Specify project path
flutter_blueprint analyze --size --path ./my_project
```

### Optimize Command

```bash
# Tree-shaking analysis
flutter_blueprint optimize --tree-shake

# Asset optimization
flutter_blueprint optimize --assets

# All optimizations
flutter_blueprint optimize --all

# Dry run (preview changes)
flutter_blueprint optimize --assets --dry-run

# Specify project path
flutter_blueprint optimize --all --path ./my_project
```

## Configuration

### Performance Configuration in blueprint.yaml

```yaml
# Enable performance monitoring
performance:
  enabled: true

  # Select which metrics to track
  tracking:
    - app_start_time # Track app startup time
    - screen_load_time # Track screen load times
    - api_response_time # Track API response times
    - frame_render_time # Track frame rendering

  # Configure alert thresholds
  alerts:
    slow_screen_threshold: 500ms # Alert if screen loads > 500ms
    slow_api_threshold: 2s # Alert if API calls > 2 seconds
    slow_startup_threshold: 1s # Alert if startup > 1 second
    frame_drop_threshold: 16ms # Alert if frame time > 16ms (60fps)
```

## Testing

Run tests for the performance and optimization features:

```bash
# Run all tests
dart test

# Run specific test files
dart test test/src/analyzer/performance_analyzer_test.dart
dart test test/src/analyzer/bundle_size_analyzer_test.dart
dart test test/src/config/performance_config_test.dart
```

## API Reference

### PerformanceConfig

Configuration class for performance monitoring:

```dart
// Create disabled config
final config = PerformanceConfig.disabled();

// Create with all tracking enabled
final config = PerformanceConfig.allEnabled();

// Create from YAML
final config = PerformanceConfig.fromYaml(yamlMap);

// Custom configuration
final config = PerformanceConfig(
  enabled: true,
  tracking: PerformanceTracking(
    appStartTime: true,
    screenLoadTime: true,
    apiResponseTime: false,
    frameRenderTime: false,
  ),
  alerts: PerformanceAlerts(
    slowScreenThreshold: 500,
    slowApiThreshold: 2000,
  ),
);
```

### PerformanceAnalyzer

Analyzer for monitoring and tracking performance metrics:

```dart
final analyzer = PerformanceAnalyzer(
  config: config,
  projectPath: './my_project',
);

// Record a metric
analyzer.recordMetric(PerformanceMetric(
  name: 'screen_load_time',
  value: 250.0,
  timestamp: DateTime.now(),
));

// Generate report
final report = analyzer.generateReport();
print(report.toFormattedString());

// Inject performance monitoring into project
await analyzer.injectPerformanceMonitoring();
```

### BundleSizeAnalyzer

Analyzer for bundle size optimization:

```dart
final analyzer = BundleSizeAnalyzer(projectPath: './my_project');
final report = await analyzer.analyze();

// Access components
print('Code: ${report.codeSize.totalBytes}');
print('Assets: ${report.assetsSize.totalBytes}');
print('Packages: ${report.packagesSize.totalBytes}');

// Get suggestions
for (final suggestion in report.suggestions) {
  print(suggestion.title);
}

// Format as string
print(report.toFormattedString());
```

## Best Practices

1. **Enable performance monitoring in development**:

   - Set up performance tracking early in development
   - Monitor metrics regularly to catch regressions

2. **Build before analyzing size**:

   - Always build your app before running bundle size analysis
   - Use release builds for accurate size measurements

3. **Regular optimization**:

   - Run `flutter_blueprint analyze --size` regularly
   - Remove unused assets as suggested
   - Optimize large images

4. **CI/CD Integration**:
   - Add performance checks to your CI/CD pipeline
   - Set up alerts for bundle size increases
   - Track performance metrics over time

## Troubleshooting

### Bundle size analysis fails

**Problem**: "Build directory not found"

**Solution**: Build your app first:

```bash
flutter build apk  # for Android
flutter build ios  # for iOS
flutter build web  # for Web
```

### Performance tracking not working

**Problem**: Performance metrics not being recorded

**Solution**: Ensure performance monitoring is enabled:

1. Check `blueprint.yaml` has `performance.enabled: true`
2. Verify `performance_tracker.dart` exists in `lib/core/`
3. Ensure you're calling the tracking methods correctly

## Examples

See the `example/` directory for complete examples:

- `example/performance_monitoring/` - Complete performance monitoring setup
- `example/bundle_optimization/` - Bundle size optimization workflow

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](../LICENSE) for details.
