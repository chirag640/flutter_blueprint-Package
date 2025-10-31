library flutter_blueprint;

// Note: CLI runner is NOT exported here to avoid platform conflicts.
// The CLI (which uses dart_console via interact package) only supports
// desktop platforms (Windows, Linux, macOS) and is accessed via the
// executable in bin/flutter_blueprint.dart
//
// This library exports only the programmatic APIs that can be used
// on all platforms if needed.

export 'src/config/blueprint_config.dart';
export 'src/config/blueprint_manifest.dart';
export 'src/generator/blueprint_generator.dart';
