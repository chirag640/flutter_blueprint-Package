#!/usr/bin/env dart

// Direct import of CLI runner (not exported in main library to avoid platform conflicts)
import 'package:flutter_blueprint/src/cli/cli_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = CliRunner();
  await runner.run(arguments);
}
