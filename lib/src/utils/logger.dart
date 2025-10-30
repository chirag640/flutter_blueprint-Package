import 'dart:io';

/// Lightweight console logger tailored for CLI output.
class Logger {
  void info(String message) => _write(message);

  void success(String message) => _write(message);

  void warn(String message) => _write('WARNING: $message');

  void warning(String message) => _write('WARNING: $message');

  void error(String message) => _write('ERROR: $message');

  void _write(String message) {
    stdout.writeln(message);
  }
}
