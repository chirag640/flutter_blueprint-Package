import 'dart:io';
import 'package:path/path.dart' as p;

/// Comprehensive input validation to prevent security vulnerabilities.
///
/// This class provides static methods for validating all user inputs
/// including app names, file paths, and other string inputs to prevent
/// path traversal, command injection, and other security issues.
class InputValidator {
  InputValidator._(); // Private constructor to prevent instantiation

  /// Maximum allowed length for app names
  static const int maxAppNameLength = 64;

  /// Maximum allowed length for feature names
  static const int maxFeatureNameLength = 64;

  /// Maximum allowed length for file paths
  static const int maxPathLength = 4096;

  /// Dart reserved words that cannot be used as identifiers
  static const Set<String> dartReservedWords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'Function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  /// Dart built-in types that should be avoided (all lowercase for case-insensitive matching)
  static const Set<String> dartBuiltInTypes = {
    'int',
    'double',
    'num',
    'bool',
    'string',
    'list',
    'map',
    'set',
    'object',
    'dynamic',
    'void',
    'null',
    'never',
    'future',
    'stream',
  };

  /// Validates a Dart package name (app name or feature name).
  ///
  /// Rules:
  /// - Must start with a lowercase letter
  /// - Can only contain lowercase letters, numbers, and underscores
  /// - Cannot be a Dart reserved word or built-in type
  /// - Must be between 1 and [maxLength] characters
  /// - Cannot start or end with underscore
  /// - Cannot have consecutive underscores
  ///
  /// Throws [ArgumentError] with a descriptive message if validation fails.
  static String validatePackageName(
    String name, {
    int maxLength = maxAppNameLength,
    String fieldName = 'name',
  }) {
    if (name.isEmpty) {
      throw ArgumentError('$fieldName cannot be empty');
    }

    if (name.length > maxLength) {
      throw ArgumentError(
        '$fieldName must be $maxLength characters or less (got ${name.length})',
      );
    }

    // Check for reserved words (case-insensitive)
    final lowerName = name.toLowerCase();
    if (dartReservedWords.contains(lowerName)) {
      throw ArgumentError(
        '"$name" is a Dart reserved word and cannot be used as $fieldName',
      );
    }

    if (dartBuiltInTypes.contains(lowerName)) {
      throw ArgumentError(
        '"$name" is a Dart built-in type and cannot be used as $fieldName',
      );
    }

    // Must start with lowercase letter
    if (!RegExp(r'^[a-z]').hasMatch(name)) {
      throw ArgumentError(
        '$fieldName must start with a lowercase letter (a-z)',
      );
    }

    // Can only contain lowercase letters, numbers, and underscores
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      throw ArgumentError(
        '$fieldName can only contain lowercase letters, numbers, and underscores',
      );
    }

    // Cannot end with underscore
    if (name.endsWith('_')) {
      throw ArgumentError('$fieldName cannot end with an underscore');
    }

    // Cannot have consecutive underscores
    if (name.contains('__')) {
      throw ArgumentError('$fieldName cannot contain consecutive underscores');
    }

    return name;
  }

  /// Validates and sanitizes a file path to prevent path traversal attacks.
  ///
  /// This method:
  /// - Checks for path traversal patterns (../, ..\, etc.)
  /// - Validates path length
  /// - Ensures path is not absolute (unless [allowAbsolute] is true)
  /// - Normalizes the path
  /// - Checks for null bytes and other dangerous characters
  ///
  /// Throws [ArgumentError] if the path is invalid or dangerous.
  static String validateFilePath(
    String path, {
    bool allowAbsolute = false,
    String fieldName = 'path',
  }) {
    if (path.isEmpty) {
      throw ArgumentError('$fieldName cannot be empty');
    }

    if (path.length > maxPathLength) {
      throw ArgumentError(
        '$fieldName exceeds maximum length of $maxPathLength characters',
      );
    }

    // Check for null bytes
    if (path.contains('\x00')) {
      throw ArgumentError('$fieldName contains null byte');
    }

    // Normalize the path
    final normalized = p.normalize(path);

    // Check for path traversal attempts
    if (normalized.contains('..')) {
      throw ArgumentError(
        '$fieldName contains path traversal sequence (..)',
      );
    }

    // Check if absolute path when not allowed
    if (!allowAbsolute && p.isAbsolute(normalized)) {
      throw ArgumentError(
        '$fieldName must be a relative path',
      );
    }

    // Check for dangerous characters on Windows
    if (Platform.isWindows) {
      // Check for Windows reserved names
      final basename = p.basename(normalized).toLowerCase();
      const windowsReserved = {
        'con',
        'prn',
        'aux',
        'nul',
        'com1',
        'com2',
        'com3',
        'com4',
        'com5',
        'com6',
        'com7',
        'com8',
        'com9',
        'lpt1',
        'lpt2',
        'lpt3',
        'lpt4',
        'lpt5',
        'lpt6',
        'lpt7',
        'lpt8',
        'lpt9',
      };

      if (windowsReserved.contains(basename) ||
          windowsReserved.contains(basename.split('.').first)) {
        throw ArgumentError(
          '$fieldName uses a Windows reserved name: $basename',
        );
      }

      // Check for invalid Windows characters (excluding drive letter colon)
      // We need to check each path component, not the entire path,
      // since ':' is valid in drive letters (C:\)
      final pathWithoutDrive =
          normalized.replaceFirst(RegExp(r'^[A-Za-z]:'), '');
      if (RegExp(r'[<>:"|?*]').hasMatch(pathWithoutDrive)) {
        throw ArgumentError(
          '$fieldName contains invalid Windows path characters',
        );
      }
    }

    // Check for control characters
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(normalized)) {
      throw ArgumentError('$fieldName contains control characters');
    }

    // Convert to forward slashes for consistency across platforms
    return normalized.replaceAll('\\', '/');
  }

  /// Validates a target directory path for project generation.
  ///
  /// Ensures the path:
  /// - Is a valid file path
  /// - Is not the root directory
  /// - Is not a system directory
  /// - Has a valid parent directory
  ///
  /// Throws [ArgumentError] if validation fails.
  static String validateTargetDirectory(String path) {
    // First validate as a file path (allowing absolute paths for target directory)
    final validated = validateFilePath(
      path,
      allowAbsolute: true,
      fieldName: 'target directory',
    );

    // Prevent operations on root directory
    if (p.isRootRelative(validated) && p.split(validated).length == 1) {
      throw ArgumentError('Cannot create project in root directory');
    }

    // Check for system directories (basic protection)
    // Only reject if creating directly in critical system directories,
    // but allow subdirectories (e.g., /tmp/myproject is OK, but /etc/myproject is not)
    final parts = p.split(validated.toLowerCase());
    const criticalSystemDirs = {
      'windows',
      'system32',
      'program files',
      'program files (x86)',
      'etc',
      'bin',
      'sbin',
      'usr',
      'sys',
      'proc',
    };

    // Allow tmp subdirectories (common for tests), but reject critical system dirs
    for (final dir in criticalSystemDirs) {
      if (parts.contains(dir)) {
        throw ArgumentError(
          'Cannot create project in system directory: $dir',
        );
      }
    }

    return validated;
  }

  /// Validates a command string before execution.
  ///
  /// Checks for shell injection attempts by looking for:
  /// - Shell metacharacters
  /// - Command separators
  /// - Redirection operators
  ///
  /// Throws [ArgumentError] if command contains dangerous patterns.
  static String validateCommand(String command) {
    if (command.isEmpty) {
      throw ArgumentError('Command cannot be empty');
    }

    // Check for shell metacharacters and command injection attempts
    const dangerous = [
      ';',
      '|',
      '&',
      '\$',
      '`',
      '\n',
      '\r',
      '>',
      '<',
      '!',
      '*',
      '?',
      '[',
      ']',
      '{',
      '}',
      '(',
      ')',
      '~',
      '#',
    ];

    for (final char in dangerous) {
      if (command.contains(char)) {
        throw ArgumentError(
          'Command contains dangerous character: $char',
        );
      }
    }

    // Check for command separators
    if (RegExp(r'&&|\|\||;;').hasMatch(command)) {
      throw ArgumentError('Command contains command separator');
    }

    return command;
  }

  /// Validates a YAML key to prevent injection.
  ///
  /// Ensures the key is a safe string that won't cause YAML parsing issues.
  static String validateYamlKey(String key) {
    if (key.isEmpty) {
      throw ArgumentError('YAML key cannot be empty');
    }

    if (key.length > 256) {
      throw ArgumentError('YAML key is too long');
    }

    // Check for YAML special characters
    if (RegExp(r'[:\[\]{}#|>!%@&*]').hasMatch(key)) {
      throw ArgumentError('YAML key contains special characters');
    }

    // Must start with letter or underscore
    if (!RegExp(r'^[a-zA-Z_]').hasMatch(key)) {
      throw ArgumentError('YAML key must start with letter or underscore');
    }

    return key;
  }

  /// Validates enum value parsing with additional safety checks.
  ///
  /// Throws [ArgumentError] with helpful message if value is invalid.
  static T validateEnumValue<T extends Enum>(
    String value,
    List<T> values,
    String enumName,
  ) {
    if (value.isEmpty) {
      throw ArgumentError('$enumName value cannot be empty');
    }

    if (value.length > 64) {
      throw ArgumentError('$enumName value is too long');
    }

    final normalized = value.trim().toLowerCase();

    for (final enumValue in values) {
      if (enumValue.name.toLowerCase() == normalized) {
        return enumValue;
      }
    }

    final validValues = values.map((v) => v.name).join(', ');
    throw ArgumentError(
      'Invalid $enumName: "$value". Valid values are: $validValues',
    );
  }
}
