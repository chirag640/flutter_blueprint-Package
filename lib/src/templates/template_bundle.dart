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
  const TemplateBundle({required this.files});

  final List<TemplateFile> files;
}
