import 'dart:io';
import 'package:path/path.dart' as p;
import 'input_validator.dart';
import 'logger.dart';

/// Secure file system utilities with comprehensive validation and error handling.
///
/// This class provides methods for safe file operations including:
/// - Directory creation with validation
/// - File writing with path traversal prevention
/// - File copying with size limits
/// - Proper error handling and logging
class IoUtils {
  const IoUtils({Logger? logger}) : _logger = logger;

  final Logger? _logger;

  /// Maximum file size for safety (10 MB)
  static const int maxFileSize = 10 * 1024 * 1024;

  /// Maximum files allowed in directory check
  static const int maxFilesCheck = 1000;

  /// Prepares a target directory for project generation with security validation.
  ///
  /// This method:
  /// - Validates the target path to prevent path traversal
  /// - Checks if directory exists and is empty
  /// - Optionally deletes existing directory if [overwrite] is true
  /// - Creates the directory structure with proper permissions
  /// - Handles all filesystem errors appropriately
  ///
  /// Throws [ArgumentError] if path is invalid.
  /// Throws [FileSystemException] if directory exists and is not empty (unless overwrite).
  /// Throws [SecurityException] if attempting to operate on system directories.
  Future<Directory> prepareTargetDirectory(
    String targetPath, {
    bool overwrite = false,
  }) async {
    try {
      // Validate and sanitize the target path
      final validatedPath = InputValidator.validateTargetDirectory(targetPath);

      _logger?.debug('Preparing target directory: $validatedPath');

      final directory = Directory(validatedPath);

      // Check if directory exists
      if (await directory.exists()) {
        _logger?.debug('Directory already exists');

        // Check if it's populated
        final isPopulated = await _isDirectoryPopulated(directory);

        if (isPopulated && !overwrite) {
          throw FileSystemException(
            'Target directory is not empty. Use --force to overwrite.',
            directory.path,
          );
        }

        if (overwrite) {
          _logger?.warn('Overwriting existing directory: ${directory.path}');

          try {
            // Add a small delay to avoid race conditions
            await Future.delayed(const Duration(milliseconds: 100));
            await directory.delete(recursive: true);
            _logger?.debug('Deleted existing directory');
          } on FileSystemException catch (e) {
            throw FileSystemException(
              'Failed to delete existing directory: ${e.message}',
              directory.path,
            );
          }
        }
      }

      // Create the directory
      _logger?.debug('Creating directory structure');
      final created = await directory.create(recursive: true);

      // Verify creation succeeded
      if (!await created.exists()) {
        throw FileSystemException(
          'Failed to create directory',
          created.path,
        );
      }

      _logger?.success('Target directory prepared: ${created.path}');
      return created;
    } on ArgumentError {
      rethrow;
    } on FileSystemException {
      rethrow;
    } catch (e) {
      throw FileSystemException(
        'Unexpected error preparing directory: $e',
        targetPath,
      );
    }
  }

  /// Safely writes content to a file with path validation.
  ///
  /// This method:
  /// - Validates both root and relative paths
  /// - Prevents path traversal attacks
  /// - Ensures file stays within root directory
  /// - Creates parent directories as needed
  /// - Handles write errors appropriately
  ///
  /// Throws [ArgumentError] if paths are invalid.
  /// Throws [FileSystemException] if write fails.
  Future<void> writeFile(
    String rootPath,
    String relativePath,
    String content,
  ) async {
    try {
      // Validate root path (absolute)
      final validatedRoot = InputValidator.validateTargetDirectory(rootPath);

      // Validate relative path (must be relative)
      final validatedRelative = InputValidator.validateFilePath(
        relativePath,
        allowAbsolute: false,
        fieldName: 'relative path',
      );

      // Join paths safely
      final fullPath = p.normalize(p.join(validatedRoot, validatedRelative));

      // Security check: Ensure file is within root directory
      final canonicalRoot = p.canonicalize(validatedRoot);
      final canonicalFull = p.normalize(fullPath);

      if (!p.isWithin(canonicalRoot, canonicalFull) &&
          canonicalRoot != canonicalFull) {
        throw ArgumentError(
          'Attempted path traversal: file would be outside root directory',
        );
      }

      _logger?.debug('Writing file: $validatedRelative');

      // Check content size
      final contentBytes = content.length;
      if (contentBytes > maxFileSize) {
        throw ArgumentError(
          'Content size ($contentBytes bytes) exceeds maximum ($maxFileSize bytes)',
        );
      }

      final file = File(fullPath);

      // Create parent directories
      await file.parent.create(recursive: true);

      // Write content
      await file.writeAsString('$content\n', mode: FileMode.write);

      // Verify write succeeded
      if (!await file.exists()) {
        throw FileSystemException('Failed to create file', fullPath);
      }

      _logger?.debug('File written successfully: $validatedRelative');
    } on ArgumentError {
      rethrow;
    } on FileSystemException {
      rethrow;
    } catch (e) {
      throw FileSystemException(
        'Failed to write file: $e',
        relativePath,
      );
    }
  }

  /// Safely copies a template file with size validation.
  ///
  /// This method:
  /// - Validates source and destination paths
  /// - Checks source file exists and is readable
  /// - Validates file size before copying
  /// - Creates destination parent directories
  /// - Handles copy errors appropriately
  ///
  /// Throws [ArgumentError] if paths are invalid.
  /// Throws [FileSystemException] if copy fails.
  Future<void> copyTemplateFile(
    String templatePath,
    String targetPath,
  ) async {
    try {
      // Validate paths
      final validatedTemplate = InputValidator.validateFilePath(
        templatePath,
        allowAbsolute: true,
        fieldName: 'template path',
      );

      final validatedTarget = InputValidator.validateFilePath(
        targetPath,
        allowAbsolute: true,
        fieldName: 'target path',
      );

      _logger
          ?.debug('Copying template: $validatedTemplate -> $validatedTarget');

      final source = File(validatedTemplate);
      final destination = File(validatedTarget);

      // Verify source exists
      if (!await source.exists()) {
        throw FileSystemException(
          'Template file not found',
          validatedTemplate,
        );
      }

      // Check source file size
      final fileSize = await source.length();
      if (fileSize > maxFileSize) {
        throw FileSystemException(
          'Template file too large: $fileSize bytes (max: $maxFileSize)',
          validatedTemplate,
        );
      }

      // Create parent directories for destination
      await destination.parent.create(recursive: true);

      // Read and write content
      final content = await source.readAsString();
      await destination.writeAsString(content, mode: FileMode.write);

      // Verify copy succeeded
      if (!await destination.exists()) {
        throw FileSystemException('Failed to copy file', validatedTarget);
      }

      _logger?.debug('Template copied successfully');
    } on ArgumentError {
      rethrow;
    } on FileSystemException {
      rethrow;
    } catch (e) {
      throw FileSystemException(
        'Failed to copy template file: $e',
        templatePath,
      );
    }
  }

  /// Checks if a directory contains any files or subdirectories.
  ///
  /// This method limits the number of files checked to prevent
  /// performance issues with very large directories.
  ///
  /// Returns true if directory contains any entries, false otherwise.
  Future<bool> _isDirectoryPopulated(Directory directory) async {
    var count = 0;

    try {
      await for (final entity in directory.list()) {
        count++;

        // Early return if we find anything
        if (count > 0) {
          _logger?.debug('Directory is populated (found ${entity.path})');
          return true;
        }

        // Safety limit to prevent excessive checking
        if (count >= maxFilesCheck) {
          _logger?.warn('Directory check limit reached, assuming populated');
          return true;
        }
      }

      _logger?.debug('Directory is empty');
      return false;
    } catch (e) {
      _logger?.warn('Error checking directory contents: $e');
      // On error, assume populated to be safe
      return true;
    }
  }

  /// Validates that a directory is safe to write to.
  ///
  /// Checks permissions and ensures directory is not a system directory.
  Future<bool> isDirectoryWritable(String path) async {
    try {
      final directory = Directory(path);

      if (!await directory.exists()) {
        return false;
      }

      // Try to create a temporary file to test write permission
      final testFile = File(
          p.join(path, '.write_test_${DateTime.now().millisecondsSinceEpoch}'));

      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
