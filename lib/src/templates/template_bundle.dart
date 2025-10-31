import '../config/blueprint_config.dart';

typedef ContentBuilder = String Function(BlueprintConfig config);

typedef GenerationPredicate = bool Function(BlueprintConfig config);

class TemplateFile {
  const TemplateFile({
    required this.path,
    required this.build,
    this.shouldGenerate,
  });

  final String path;
  final ContentBuilder build;
  final GenerationPredicate? shouldGenerate;

  bool shouldInclude(BlueprintConfig config) {
    return shouldGenerate == null || shouldGenerate!(config);
  }
}

class TemplateBundle {
  const TemplateBundle({
    required this.files,
    this.additionalDependencies = const {},
    this.additionalDevDependencies = const {},
    this.requiredFeatures = const [],
  });

  final List<TemplateFile> files;

  /// Additional dependencies to add to pubspec.yaml
  final Map<String, String> additionalDependencies;

  /// Additional dev dependencies to add to pubspec.yaml
  final Map<String, String> additionalDevDependencies;

  /// List of feature names that should be generated for this template
  final List<String> requiredFeatures;
}
