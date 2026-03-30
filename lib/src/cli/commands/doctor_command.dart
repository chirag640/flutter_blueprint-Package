/// Doctor command - inspects project health and suggests actionable fixes.
library;

import 'dart:collection';
import 'dart:io';

import 'package:args/args.dart';

import '../command_interface.dart';
import '../../core/result.dart';
import '../../core/errors.dart';

typedef _ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments,
  String workingDirectory,
);

enum _DoctorStatus {
  pass,
  warn,
  fail,
}

class _DoctorCheckResult {
  const _DoctorCheckResult({
    required this.name,
    required this.status,
    required this.summary,
    required this.actions,
    this.details = '',
  });

  final String name;
  final _DoctorStatus status;
  final String summary;
  final String details;
  final List<String> actions;
}

/// Runs project health checks and prints an actionable report.
///
/// Checks included:
/// - Static analysis (`dart analyze`)
/// - Dependency freshness (`dart pub outdated`)
/// - Safe autofix dry-run (`dart fix --dry-run`)
class DoctorCommand extends BaseCommand {
  DoctorCommand({_ProcessRunner? processRunner})
      : _processRunner = processRunner ?? _defaultProcessRunner;

  final _ProcessRunner _processRunner;

  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Run health checks (analyze, outdated, fix dry-run) with actionable output';

  @override
  String get usage =>
      'flutter_blueprint doctor [path] [--strict] [--verbose]\n\n'
      '  path       Project directory (default: current directory)\n'
      '  --strict   Exit with non-zero if warnings are found\n'
      '  --verbose  Print detailed command output excerpts';

  @override
  void configureArgs(ArgParser parser) {
    parser
      ..addOption('path', help: 'Project path to inspect', defaultsTo: '.')
      ..addFlag('strict', help: 'Fail when warnings are present')
      ..addFlag('verbose', abbr: 'v', help: 'Show detailed check output');
  }

  @override
  Future<Result<CommandResult, CommandError>> execute(
    ArgResults args,
    CommandContext context,
  ) async {
    final projectPath =
        args.rest.isNotEmpty ? args.rest.first : (args['path'] as String);
    final strictMode = args['strict'] as bool;
    final verbose = args['verbose'] as bool;

    final projectDir = Directory(projectPath);
    if (!await projectDir.exists()) {
      return Result.failure(
        CommandError(
          'Project directory does not exist: $projectPath',
          command: name,
        ),
      );
    }

    context.logger.info('🩺 Running project doctor checks...');
    context.logger.info('   Target: ${projectDir.absolute.path}');
    context.logger.info('');

    final checks = <_DoctorCheckResult>[
      await _runAnalyzeCheck(projectDir.path),
      await _runOutdatedCheck(projectDir.path),
      await _runFixDryRunCheck(projectDir.path),
    ];

    _printReport(context, checks, verbose: verbose);

    final hasFailures = checks.any((c) => c.status == _DoctorStatus.fail);
    final hasWarnings = checks.any((c) => c.status == _DoctorStatus.warn);

    if (hasFailures || (strictMode && hasWarnings)) {
      final reason = hasFailures
          ? 'Doctor found blocking issues'
          : 'Doctor warnings treated as failures in strict mode';

      return Result.success(
        CommandResult.error(reason, exitCode: 1),
      );
    }

    return const Result.success(
      CommandResult.ok('Doctor checks completed'),
    );
  }

  Future<_DoctorCheckResult> _runAnalyzeCheck(String projectPath) async {
    final result = await _processRunner(
      'dart',
      ['analyze'],
      projectPath,
    );

    if (result.exitCode == 0) {
      return const _DoctorCheckResult(
        name: 'Static analysis',
        status: _DoctorStatus.pass,
        summary: 'No analyzer errors were reported.',
        actions: [],
      );
    }

    final output = _combinedOutput(result);
    return _DoctorCheckResult(
      name: 'Static analysis',
      status: _DoctorStatus.fail,
      summary: 'Analyzer reported issues that should be fixed before release.',
      details: output,
      actions: const [
        'Run `dart analyze` and resolve reported errors/warnings.',
        'Re-run `flutter_blueprint doctor --strict` before merging.',
      ],
    );
  }

  Future<_DoctorCheckResult> _runOutdatedCheck(String projectPath) async {
    final result = await _processRunner(
      'dart',
      ['pub', 'outdated'],
      projectPath,
    );

    if (result.exitCode != 0) {
      return _DoctorCheckResult(
        name: 'Dependency freshness',
        status: _DoctorStatus.fail,
        summary: 'Unable to evaluate dependency drift via `dart pub outdated`.',
        details: _combinedOutput(result),
        actions: const [
          'Ensure pubspec.yaml exists and run `dart pub get`.',
          'Retry `dart pub outdated` after resolving pub issues.',
        ],
      );
    }

    final output = _combinedOutput(result).toLowerCase();
    final noUpdates = output.contains('no dependencies are outdated');

    if (noUpdates) {
      return const _DoctorCheckResult(
        name: 'Dependency freshness',
        status: _DoctorStatus.pass,
        summary: 'Dependencies are up to date for current constraints.',
        actions: [],
      );
    }

    return _DoctorCheckResult(
      name: 'Dependency freshness',
      status: _DoctorStatus.warn,
      summary:
          'Outdated dependencies detected (review and upgrade intentionally).',
      details: _combinedOutput(result),
      actions: const [
        'Run `dart pub outdated` and review upgradable/resolvable columns.',
        'Apply planned updates with `dart pub upgrade` or targeted package bumps.',
        'After upgrades, run tests and `flutter_blueprint doctor --strict`.',
      ],
    );
  }

  Future<_DoctorCheckResult> _runFixDryRunCheck(String projectPath) async {
    final result = await _processRunner(
      'dart',
      ['fix', '--dry-run'],
      projectPath,
    );

    if (result.exitCode != 0) {
      return _DoctorCheckResult(
        name: 'Autofix dry-run',
        status: _DoctorStatus.fail,
        summary: 'Unable to compute automated fixes with dry-run.',
        details: _combinedOutput(result),
        actions: const [
          'Run `dart analyze` first and address parser/build issues.',
          'Retry `dart fix --dry-run` after analyzer is healthy.',
        ],
      );
    }

    final output = _combinedOutput(result);
    final outputLower = output.toLowerCase();
    final nothingToFix = outputLower.contains('nothing to fix');
    if (nothingToFix) {
      return const _DoctorCheckResult(
        name: 'Autofix dry-run',
        status: _DoctorStatus.pass,
        summary: 'No automated fixes are currently suggested.',
        actions: [],
      );
    }

    return _DoctorCheckResult(
      name: 'Autofix dry-run',
      status: _DoctorStatus.warn,
      summary: 'Automated fixes are available (review before applying).',
      details: output,
      actions: const [
        'Inspect recommendations with `dart fix --dry-run`.',
        'Apply safe fixes with `dart fix --apply` and re-run tests.',
      ],
    );
  }

  void _printReport(
    CommandContext context,
    List<_DoctorCheckResult> checks, {
    required bool verbose,
  }) {
    context.logger.info('📊 Health report');
    context.logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    for (final check in checks) {
      final icon = switch (check.status) {
        _DoctorStatus.pass => '✅',
        _DoctorStatus.warn => '⚠️',
        _DoctorStatus.fail => '❌',
      };

      context.logger.info('$icon ${check.name}: ${check.summary}');

      if (verbose && check.details.trim().isNotEmpty) {
        final excerpt = _firstNonEmptyLines(check.details, 8);
        if (excerpt.isNotEmpty) {
          context.logger.info('   Details:');
          for (final line in excerpt) {
            context.logger.info('   $line');
          }
        }
      }
    }

    final nextSteps = LinkedHashSet<String>();
    for (final check in checks) {
      nextSteps.addAll(check.actions);
    }

    if (nextSteps.isEmpty) {
      context.logger.info('');
      context.logger
          .success('🎉 Project health looks good. No action required.');
      return;
    }

    context.logger.info('');
    context.logger.info('🛠️  Suggested next steps');
    for (final action in nextSteps) {
      context.logger.info('  • $action');
    }
  }

  static Future<ProcessResult> _defaultProcessRunner(
    String executable,
    List<String> arguments,
    String workingDirectory,
  ) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
  }

  String _combinedOutput(ProcessResult result) {
    final stdout = result.stdout.toString().trim();
    final stderr = result.stderr.toString().trim();
    if (stdout.isEmpty) return stderr;
    if (stderr.isEmpty) return stdout;
    return '$stdout\n$stderr';
  }

  List<String> _firstNonEmptyLines(String text, int limit) {
    final lines = text
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.length <= limit) return lines;
    return [
      ...lines.take(limit - 1),
      '... (${lines.length - (limit - 1)} more lines)',
    ];
  }
}
