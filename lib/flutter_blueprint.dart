library flutter_blueprint;

// Note: CLI runner is NOT exported here to avoid platform conflicts.
// The CLI (which uses dart_console via interact package) only supports
// desktop platforms (Windows, Linux, macOS) and is accessed via the
// executable in bin/flutter_blueprint.dart
//
// This library exports only the programmatic APIs that can be used
// on all platforms if needed.

// ── Core abstractions (v2) ────────────────────────────────────
export 'src/core/errors.dart';
export 'src/core/result.dart';
export 'src/core/service_locator.dart';

// ── CLI command interface (v2) ────────────────────────────────
export 'src/cli/command_interface.dart';
export 'src/cli/command_registry.dart';

// ── Template system (v2) ─────────────────────────────────────
export 'src/templates/core/template_interface.dart';
export 'src/templates/core/template_engine.dart';

// ── Generator (v2) ───────────────────────────────────────────
export 'src/generator/project_generator.dart';

// ── Analyzers ────────────────────────────────────────────────
export 'src/analyzer/code_quality_analyzer.dart';
export 'src/analyzer/quality_issue.dart';
export 'src/analyzer/performance_analyzer.dart';
export 'src/analyzer/bundle_size_analyzer.dart';

// ── Configuration ────────────────────────────────────────────
export 'src/config/blueprint_config.dart';
export 'src/config/blueprint_manifest.dart';
export 'src/config/performance_config.dart';
export 'src/config/shared_config.dart';
export 'src/config/config_repository.dart';

// ── Refactoring ──────────────────────────────────────────────
export 'src/refactoring/auto_refactoring_tool.dart';
export 'src/refactoring/refactoring_types.dart';

// ── Templates ────────────────────────────────────────────────
export 'src/templates/template_library.dart';
export 'src/templates/performance_setup_template.dart';

// ── Utilities ────────────────────────────────────────────────
export 'src/utils/dependency_manager.dart';
export 'src/utils/project_preview.dart';
