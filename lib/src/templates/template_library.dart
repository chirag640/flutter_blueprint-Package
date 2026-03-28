import '../config/blueprint_config.dart';
import 'template_bundle.dart';

/// Project templates — only blank is supported.
/// All projects start from a clean slate so you have full architectural freedom.
enum ProjectTemplate {
  /// Blank project with clean architecture and a single home feature.
  blank;

  String get label => 'Blank Project';

  String get description =>
      'Clean architecture scaffold with a single home feature';

  List<String> get features => ['Home screen', 'Basic navigation'];

  static ProjectTemplate parse(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('-', '');
    if (normalized == 'blank') return ProjectTemplate.blank;
    throw ArgumentError(
      'Unknown template: $value. Only \'blank\' is supported — build anything from a clean start!',
    );
  }
}

/// Factory for retrieving the blank template bundle.
class TemplateLibrary {
  /// Always returns the blank template bundle.
  /// All projects begin from a clean, well-structured starting point.
  static TemplateBundle getTemplate(
    ProjectTemplate template,
    BlueprintConfig config,
  ) {
    return TemplateBundle(
      files: [],
      additionalDependencies: {},
      additionalDevDependencies: {},
      requiredFeatures: ['home'],
    );
  }
}

// The following private stubs are intentionally removed.
// Pre-built templates (ecommerce, socialMedia, fitnessTracker, financeApp,
// foodDelivery, chatApp) have been removed. Every project now starts blank.
// Use `flutter_blueprint add-feature <name>` to add domain-specific features.

// --- REMOVED TEMPLATES BELOW (kept as comment for reference) ---

/*
*/
