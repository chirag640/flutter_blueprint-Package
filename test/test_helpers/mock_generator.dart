import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/core/errors.dart';
import 'package:flutter_blueprint/src/core/result.dart';
import 'package:flutter_blueprint/src/generator/project_generator.dart';

/// Mock implementation of ProjectGenerator for testing
class MockProjectGenerator extends ProjectGenerator {
  int generateCallCount = 0;
  BlueprintConfig? lastConfig;
  String? lastTargetPath;

  Result<GenerationResult, ProjectGenerationError>? mockGenerateResult;

  @override
  Future<Result<GenerationResult, ProjectGenerationError>> generate(
    BlueprintConfig config,
    String targetPath,
  ) async {
    generateCallCount++;
    lastConfig = config;
    lastTargetPath = targetPath;

    if (mockGenerateResult != null) {
      return mockGenerateResult!;
    }

    // Default success response
    return Result.success(
      GenerationResult(
        filesGenerated: 50,
        targetPath: targetPath,
        ciConfigGenerated: false,
      ),
    );
  }

  void reset() {
    generateCallCount = 0;
    lastConfig = null;
    lastTargetPath = null;
    mockGenerateResult = null;
  }
}
