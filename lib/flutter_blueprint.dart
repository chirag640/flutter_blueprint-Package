library flutter_blueprint;

// Note: CLI runner is NOT exported here to avoid platform conflicts.
// The CLI (which uses dart_console via interact package) only supports
// desktop platforms (Windows, Linux, macOS) and is accessed via the
// executable in bin/flutter_blueprint.dart
//
// This library exports only the programmatic APIs that can be used
// on all platforms if needed.

export 'src/analyzer/code_quality_analyzer.dart';
export 'src/analyzer/quality_issue.dart';
export 'src/analyzer/performance_analyzer.dart';
export 'src/analyzer/bundle_size_analyzer.dart';
export 'src/config/blueprint_config.dart';
export 'src/config/blueprint_manifest.dart';
export 'src/config/performance_config.dart';
export 'src/config/shared_config.dart';
export 'src/config/config_repository.dart';
export 'src/generator/blueprint_generator.dart';
export 'src/refactoring/auto_refactoring_tool.dart';
export 'src/refactoring/refactoring_types.dart';
export 'src/templates/template_library.dart';
export 'src/templates/performance_setup_template.dart';
export 'src/utils/dependency_manager.dart';
export 'src/utils/project_preview.dart';
