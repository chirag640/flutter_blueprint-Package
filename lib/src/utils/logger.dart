import 'dart:io';

/// Log levels for the logger
enum LogLevel {
  debug(0),
  info(1),
  success(2),
  warn(3),
  error(4);

  const LogLevel(this.value);
  final int value;
}

/// Production-grade console logger with structured logging capabilities.
///
/// This class provides comprehensive logging with:
/// - Multiple log levels (debug, info, success, warn, error)
/// - Timestamps for all messages
/// - Color-coded output for terminals
/// - Configurable minimum log level
/// - Proper error handling for all operations
class Logger {
  /// Creates a new logger instance.
  ///
  /// [minLevel] determines the minimum log level that will be output.
  /// [includeTimestamp] controls whether timestamps are added to messages.
  /// [colorEnabled] controls ANSI color codes (auto-detected by default).
  Logger({
    this.minLevel = LogLevel.info,
    this.includeTimestamp = false,
    bool? colorEnabled,
    IOSink? output,
    IOSink? errorOutput,
  })  : _colorEnabled = colorEnabled ?? stdout.supportsAnsiEscapes,
        _output = output ?? stdout,
        _errorOutput = errorOutput ?? stderr;

  final LogLevel minLevel;
  final bool includeTimestamp;
  final bool _colorEnabled;
  final IOSink _output;
  final IOSink _errorOutput;

  /// ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _gray = '\x1B[90m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';

  /// Logs a debug message (lowest priority).
  ///
  /// Used for detailed diagnostic information useful during development.
  void debug(String message) {
    if (minLevel.value <= LogLevel.debug.value) {
      _writeToOutput(message, LogLevel.debug, _gray);
    }
  }

  /// Logs an informational message.
  ///
  /// Used for general informational messages about program execution.
  void info(String message) {
    if (minLevel.value <= LogLevel.info.value) {
      _writeToOutput(message, LogLevel.info);
    }
  }

  /// Logs a success message.
  ///
  /// Used to indicate successful completion of operations.
  void success(String message) {
    if (minLevel.value <= LogLevel.success.value) {
      _writeToOutput(message, LogLevel.success, _green);
    }
  }

  /// Logs a warning message.
  ///
  /// Used for potentially problematic situations that don't prevent execution.
  void warn(String message) {
    if (minLevel.value <= LogLevel.warn.value) {
      _writeToOutput('WARNING: $message', LogLevel.warn, _yellow);
    }
  }

  /// Alias for [warn] to support both naming conventions.
  void warning(String message) => warn(message);

  /// Logs an error message (highest priority).
  ///
  /// Used for error conditions that prevent normal operation.
  /// Error messages are written to stderr instead of stdout.
  void error(String message) {
    if (minLevel.value <= LogLevel.error.value) {
      _writeToError('ERROR: $message', LogLevel.error, _red);
    }
  }

  /// Logs an exception with stack trace.
  ///
  /// Use this for logging caught exceptions with their full context.
  void exception(String message, Object error, [StackTrace? stackTrace]) {
    if (minLevel.value <= LogLevel.error.value) {
      _writeToError('ERROR: $message', LogLevel.error, _red);
      _writeToError('  Exception: $error', LogLevel.error, _red);
      if (stackTrace != null) {
        _writeToError('  Stack trace:\n$stackTrace', LogLevel.error, _red);
      }
    }
  }

  /// Internal method to write formatted messages to stdout.
  void _writeToOutput(String message, LogLevel level, [String? color]) {
    try {
      final formatted = _formatMessage(message, level, color);
      _output.writeln(formatted);
    } catch (e) {
      // Fallback: If formatting fails, write plain message
      try {
        _output.writeln(message);
      } catch (_) {
        // If even basic write fails, ignore silently to prevent cascade failures
      }
    }
  }

  /// Internal method to write formatted error messages to stderr.
  void _writeToError(String message, LogLevel level, [String? color]) {
    try {
      final formatted = _formatMessage(message, level, color);
      _errorOutput.writeln(formatted);
    } catch (e) {
      // Fallback: If formatting fails, write plain message
      try {
        _errorOutput.writeln(message);
      } catch (_) {
        // If even basic write fails, ignore silently
      }
    }
  }

  /// Formats a message with optional timestamp and color.
  String _formatMessage(String message, LogLevel level, [String? color]) {
    final buffer = StringBuffer();

    // Add timestamp if enabled
    if (includeTimestamp) {
      final now = DateTime.now();
      final timestamp = '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
          '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';
      buffer.write('[$timestamp] ');
    }

    // Add color if enabled and provided
    if (_colorEnabled && color != null) {
      buffer.write(color);
    }

    // Add message
    buffer.write(message);

    // Reset color if enabled
    if (_colorEnabled && color != null) {
      buffer.write(_reset);
    }

    return buffer.toString();
  }

  /// Pads a number to 2 digits with leading zero if needed.
  String _pad(int number) => number.toString().padLeft(2, '0');

  /// Flushes any buffered output.
  ///
  /// Call this before program termination to ensure all logs are written.
  Future<void> flush() async {
    try {
      await _output.flush();
      await _errorOutput.flush();
    } catch (_) {
      // Ignore flush errors
    }
  }
}
