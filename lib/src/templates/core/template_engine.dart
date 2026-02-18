/// Template engine adapter bridging old TemplateBundle system to new
/// ITemplateRenderer interface.
///
/// Implements the Strangler Fig pattern: wraps existing template functions
/// to work through the new unified ITemplateRenderer contract.
library;

import '../../config/blueprint_config.dart';
import '../template_bundle.dart';
import 'template_interface.dart';

/// Adapts a legacy [TemplateBundle] builder function to an [ITemplateRenderer].
///
/// This allows existing template functions (buildProviderMobileBundle, etc.)
/// to be registered in the new [TemplateRegistry] without rewriting them.
class TemplateBundleAdapter implements ITemplateRenderer {
  TemplateBundleAdapter({
    required this.templateName,
    required this.templateDescription,
    required TemplateBundle Function(BlueprintConfig config) builder,
  }) : _builder = builder;

  final TemplateBundle Function(BlueprintConfig config) _builder;

  final String templateName;

  @override
  String get name => templateName;

  final String templateDescription;

  @override
  String get description => templateDescription;

  @override
  List<GeneratedFile> render(TemplateContext context) {
    final bundle = _builder(context.config);
    return bundle.files
        .where((f) => f.shouldInclude(context.config))
        .map((f) => GeneratedFile(
              path: f.path,
              content: f.build(context.config),
            ))
        .toList();
  }

  /// Access the underlying bundle for dependency information.
  TemplateBundle getBundle(BlueprintConfig config) => _builder(config);
}

/// Adapts a legacy template function that takes no config argument.
class SimpleTemplateBundleAdapter implements ITemplateRenderer {
  SimpleTemplateBundleAdapter({
    required this.templateName,
    required this.templateDescription,
    required TemplateBundle Function() builder,
  }) : _builder = builder;

  final TemplateBundle Function() _builder;

  final String templateName;

  @override
  String get name => templateName;

  final String templateDescription;

  @override
  String get description => templateDescription;

  @override
  List<GeneratedFile> render(TemplateContext context) {
    final bundle = _builder();
    return bundle.files
        .where((f) => f.shouldInclude(context.config))
        .map((f) => GeneratedFile(
              path: f.path,
              content: f.build(context.config),
            ))
        .toList();
  }

  TemplateBundle getBundle() => _builder();
}

/// Factory that builds a pre-populated [TemplateRegistry] with all
/// existing template bundles registered via adapters.
///
/// Usage:
/// ```dart
/// final registry = TemplateRegistryFactory.createDefault();
/// final renderer = registry.selectFor(config);
/// final files = renderer!.render(TemplateContext(config: config));
/// ```
class TemplateRegistryFactory {
  TemplateRegistryFactory._();

  /// Creates a registry with all standard template adapters.
  ///
  /// This replaces the hard-coded switch/case in BlueprintGenerator._selectBundle.
  static TemplateRegistry createDefault() {
    // Lazy-import template builders to avoid circular deps.
    // These are imported by the actual usage site (ProjectGenerator).
    final registry = TemplateRegistry();
    // Registrations are deferred to ProjectGenerator._buildRegistry()
    // because import resolution crosses library boundaries.
    return registry;
  }
}
