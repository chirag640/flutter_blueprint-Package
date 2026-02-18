/// Domain-specific error types for flutter_blueprint.
///
/// Provides a structured error hierarchy replacing scattered exception
/// handling with typed, actionable errors.
library;

/// Base exception class for all flutter_blueprint errors.
///
/// All domain errors extend this, enabling consistent catching and
/// centralized error formatting.
abstract class BlueprintException implements Exception {
  const BlueprintException(this.message, {this.cause});

  /// Human-readable error description.
  final String message;

  /// The underlying error that triggered this exception, if any.
  final Object? cause;

  /// Machine-readable error code for programmatic handling.
  String get code;

  @override
  String toString() {
    final buffer = StringBuffer('$code: $message');
    if (cause != null) {
      buffer.write('\n  Caused by: $cause');
    }
    return buffer.toString();
  }
}

/// Thrown when project generation fails.
class ProjectGenerationError extends BlueprintException {
  const ProjectGenerationError(super.message, {super.cause});

  @override
  String get code => 'PROJECT_GENERATION_ERROR';
}

/// Thrown when a template cannot be rendered.
class TemplateRenderError extends BlueprintException {
  const TemplateRenderError(
    super.message, {
    super.cause,
    this.templateName,
    this.filePath,
  });

  /// Name of the template that failed.
  final String? templateName;

  /// Target file path that was being generated.
  final String? filePath;

  @override
  String get code => 'TEMPLATE_RENDER_ERROR';

  @override
  String toString() {
    final buffer = StringBuffer('$code: $message');
    if (templateName != null) buffer.write('\n  Template: $templateName');
    if (filePath != null) buffer.write('\n  File: $filePath');
    if (cause != null) buffer.write('\n  Caused by: $cause');
    return buffer.toString();
  }
}

/// Thrown when configuration is invalid or cannot be loaded.
class ConfigurationError extends BlueprintException {
  const ConfigurationError(
    super.message, {
    super.cause,
    this.field,
    this.value,
  });

  /// The config field that has the problem.
  final String? field;

  /// The invalid value, if applicable.
  final Object? value;

  @override
  String get code => 'CONFIGURATION_ERROR';

  @override
  String toString() {
    final buffer = StringBuffer('$code: $message');
    if (field != null) buffer.write('\n  Field: $field');
    if (value != null) buffer.write('\n  Value: $value');
    if (cause != null) buffer.write('\n  Caused by: $cause');
    return buffer.toString();
  }
}

/// Thrown when a CLI command fails.
class CommandError extends BlueprintException {
  const CommandError(
    super.message, {
    super.cause,
    this.command,
    this.exitCode,
  });

  /// The command that failed.
  final String? command;

  /// The exit code, if applicable.
  final int? exitCode;

  @override
  String get code => 'COMMAND_ERROR';
}

/// Thrown when a refactoring operation fails.
class RefactoringError extends BlueprintException {
  const RefactoringError(
    super.message, {
    super.cause,
    this.filePath,
    this.lineNumber,
  });

  /// The file being refactored.
  final String? filePath;

  /// The line number where the error occurred.
  final int? lineNumber;

  @override
  String get code => 'REFACTORING_ERROR';
}

/// Thrown when file I/O operations fail.
class FileOperationError extends BlueprintException {
  const FileOperationError(
    super.message, {
    super.cause,
    this.filePath,
    this.operation,
  });

  /// The file path involved.
  final String? filePath;

  /// The operation that failed (read, write, delete, etc.).
  final String? operation;

  @override
  String get code => 'FILE_OPERATION_ERROR';
}

/// Thrown when validation of input or configuration fails.
class ValidationError extends BlueprintException {
  const ValidationError(
    super.message, {
    super.cause,
    this.errors = const [],
  });

  /// Individual validation error messages.
  final List<String> errors;

  @override
  String get code => 'VALIDATION_ERROR';

  @override
  String toString() {
    if (errors.isEmpty) return '$code: $message';
    final buffer = StringBuffer('$code: $message');
    for (final error in errors) {
      buffer.write('\n  - $error');
    }
    return buffer.toString();
  }
}
