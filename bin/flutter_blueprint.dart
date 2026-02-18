#!/usr/bin/env dart

// Use the refactored CLI runner (CommandRegistry-based).
// The legacy CliRunner is kept for backward compatibility but no longer used
// as the primary entry point.
import 'package:flutter_blueprint/src/cli/cli_runner_v2.dart';

Future<void> main(List<String> arguments) async {
  final runner = CliRunnerV2();
  await runner.run(arguments);
}
