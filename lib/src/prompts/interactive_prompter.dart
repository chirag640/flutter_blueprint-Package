import 'dart:io';
import 'package:interact/interact.dart' as interact;

/// Interactive CLI prompter with beautiful UI using the interact package
class InteractivePrompter {
  InteractivePrompter({
    Stdin? input,
    Stdout? output,
    bool showFallbackWarnings = true,
  })  : input = input ?? stdin,
        output = output ?? stdout,
        _showFallbackWarnings = showFallbackWarnings;

  final Stdin input;
  final Stdout output;
  final bool _showFallbackWarnings;

  bool get isInteractive => input.hasTerminal;

  void _logFallback(String reason) {
    if (_showFallbackWarnings) {
      stderr.writeln('⚠️  Using simplified prompts: $reason');
    }
  }

  /// Displays a beautiful confirmation prompt with Y/n options
  Future<bool> confirm(String question, {bool defaultValue = true}) async {
    if (!isInteractive) {
      return defaultValue;
    }

    try {
      final result = interact.Confirm(
        prompt: question,
        defaultValue: defaultValue,
        waitForNewLine: true,
      ).interact();
      return result;
    } catch (e) {
      _logFallback('interactive confirm failed ($e)');
      return _fallbackConfirm(question, defaultValue);
    }
  }

  /// Displays a beautiful selection menu with arrow key navigation
  Future<String> choose(
    String question,
    List<String> options, {
    String? defaultValue,
  }) async {
    if (!isInteractive) {
      return defaultValue ?? options.first;
    }

    try {
      final defaultIndex =
          defaultValue != null ? options.indexOf(defaultValue) : 0;

      final selection = interact.Select(
        prompt: question,
        options: options,
        initialIndex: defaultIndex >= 0 ? defaultIndex : 0,
      ).interact();

      return options[selection];
    } catch (e) {
      _logFallback('interactive menu failed ($e)');
      return _fallbackChoose(question, options, defaultValue);
    }
  }

  /// Displays a beautiful text input prompt
  Future<String> prompt(String question, {String? defaultValue}) async {
    if (!isInteractive) {
      return defaultValue ?? '';
    }

    try {
      final result = interact.Input(
        prompt: question,
        defaultValue: defaultValue ?? '',
      ).interact();
      return result.trim();
    } catch (e) {
      _logFallback('interactive input failed ($e)');
      return _fallbackPrompt(question, defaultValue);
    }
  }

  /// Displays a beautiful multi-select menu with checkboxes
  Future<List<String>> multiSelect(
    String question,
    List<String> options, {
    List<String>? defaultValues,
  }) async {
    if (!isInteractive) {
      return defaultValues ?? [];
    }

    try {
      // Create defaults as List<bool> matching options length
      final defaults = options.map((option) {
        return defaultValues?.contains(option) ?? false;
      }).toList();

      final selections = interact.MultiSelect(
        prompt: question,
        options: options,
        defaults: defaults,
      ).interact();

      return selections.map((index) => options[index]).toList();
    } catch (e) {
      _logFallback('interactive multi-select failed ($e)');
      final selected = <String>[];
      for (final option in options) {
        final isDefault = defaultValues?.contains(option) ?? false;
        if (await confirm('Include $option?', defaultValue: isDefault)) {
          selected.add(option);
        }
      }
      return selected;
    }
  }

  /// Displays a spinner/loading animation
  void showSpinner(String message) {
    if (!isInteractive) {
      output.writeln(message);
      return;
    }

    try {
      // Use Spinner - the icon parameter might need a Theme or specific value
      // For now, just print the message as spinner might not work in all terminals
      output.writeln('$message...');
    } catch (e) {
      output.writeln(message);
    }
  }

  // Fallback methods for when interact package fails

  Future<bool> _fallbackConfirm(String question, bool defaultValue) async {
    final suffix = defaultValue ? ' [Y/n] ' : ' [y/N] ';
    output.write('$question$suffix');
    final response = input.readLineSync()?.trim().toLowerCase();
    if (response == null || response.isEmpty) {
      return defaultValue;
    }
    if (response == 'y' || response == 'yes') {
      return true;
    }
    if (response == 'n' || response == 'no') {
      return false;
    }
    output.writeln('Please respond with y or n.');
    return _fallbackConfirm(question, defaultValue);
  }

  Future<String> _fallbackChoose(
    String question,
    List<String> options,
    String? defaultValue,
  ) async {
    final buffer = StringBuffer('$question ');
    for (var i = 0; i < options.length; i++) {
      final option = options[i];
      if (i == 0) {
        buffer.write('[$option');
      } else {
        buffer.write('/$option');
      }
    }
    buffer.write('] ');
    output.write(buffer.toString());
    final response = input.readLineSync()?.trim().toLowerCase();
    if (response == null || response.isEmpty) {
      return defaultValue ?? options.first;
    }
    if (options.contains(response)) {
      return response;
    }
    output.writeln('Please choose one of: ${options.join(', ')}');
    return _fallbackChoose(question, options, defaultValue);
  }

  Future<String> _fallbackPrompt(String question, String? defaultValue) async {
    final suffix = defaultValue == null ? ': ' : ' ($defaultValue): ';
    output.write('$question$suffix');
    final response = input.readLineSync();
    if (response == null || response.isEmpty) {
      return defaultValue ?? '';
    }
    return response.trim();
  }
}
