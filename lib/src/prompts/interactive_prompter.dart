import 'dart:io';

class InteractivePrompter {
  InteractivePrompter({
    Stdin? input,
    Stdout? output,
  })  : input = input ?? stdin,
        output = output ?? stdout;

  final Stdin input;
  final Stdout output;

  bool get isInteractive => input.hasTerminal;

  Future<bool> confirm(String question, {bool defaultValue = true}) async {
    if (!isInteractive) {
      return defaultValue;
    }
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
    return confirm(question, defaultValue: defaultValue);
  }

  Future<String> choose(String question, List<String> options,
      {String? defaultValue}) async {
    if (!isInteractive) {
      return defaultValue ?? options.first;
    }
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
    return choose(question, options, defaultValue: defaultValue);
  }

  Future<String> prompt(String question, {String? defaultValue}) async {
    if (!isInteractive) {
      return defaultValue ?? '';
    }
    final suffix = defaultValue == null ? ': ' : ' ($defaultValue): ';
    output.write('$question$suffix');
    final response = input.readLineSync();
    if (response == null || response.isEmpty) {
      return defaultValue ?? '';
    }
    return response.trim();
  }
}
