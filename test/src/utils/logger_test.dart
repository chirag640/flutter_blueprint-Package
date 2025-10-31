import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:flutter_blueprint/src/utils/logger.dart';

void main() {
  group('Logger', () {
    late Logger logger;
    late _TestOutputSink outputSink;
    late _TestOutputSink errorSink;

    setUp(() {
      outputSink = _TestOutputSink();
      errorSink = _TestOutputSink();
      logger = Logger(
        minLevel: LogLevel.debug,
        output: outputSink,
        errorOutput: errorSink,
        colorEnabled: false,
        includeTimestamp: false,
      );
    });

    tearDown(() {
      outputSink.close();
      errorSink.close();
    });

    group('log levels', () {
      test('logs debug messages', () {
        logger.debug('Debug message');
        expect(outputSink.output, contains('Debug message'));
      });

      test('logs info messages', () {
        logger.info('Info message');
        expect(outputSink.output, contains('Info message'));
      });

      test('logs success messages', () {
        logger.success('Success message');
        expect(outputSink.output, contains('Success message'));
      });

      test('logs warning messages', () {
        logger.warning('Warning message');
        expect(outputSink.output, contains('WARNING:'));
        expect(outputSink.output, contains('Warning message'));
      });

      test('logs error messages', () {
        logger.error('Error message');
        expect(errorSink.output, contains('ERROR:'));
        expect(errorSink.output, contains('Error message'));
      });
    });

    group('minimum log level filtering', () {
      test('respects minimum level - info', () {
        final testOutput = _TestOutputSink();
        final infoLogger = Logger(
          minLevel: LogLevel.info,
          output: testOutput,
          colorEnabled: false,
          includeTimestamp: false,
        );

        infoLogger.debug('Debug message');
        infoLogger.info('Info message');

        expect(testOutput.output, isNot(contains('Debug message')));
        expect(testOutput.output, contains('Info message'));

        testOutput.close();
      });

      test('respects minimum level - warn', () {
        final testOutput = _TestOutputSink();
        final warnLogger = Logger(
          minLevel: LogLevel.warn,
          output: testOutput,
          colorEnabled: false,
          includeTimestamp: false,
        );

        warnLogger.debug('Debug message');
        warnLogger.info('Info message');
        warnLogger.warning('Warning message');

        expect(testOutput.output, isNot(contains('Debug message')));
        expect(testOutput.output, isNot(contains('Info message')));
        expect(testOutput.output, contains('WARNING:'));

        testOutput.close();
      });

      test('respects minimum level - error', () {
        final testOutput = _TestOutputSink();
        final testError = _TestOutputSink();
        final errorLogger = Logger(
          minLevel: LogLevel.error,
          output: testOutput,
          errorOutput: testError,
          colorEnabled: false,
          includeTimestamp: false,
        );

        errorLogger.debug('Debug');
        errorLogger.info('Info');
        errorLogger.success('Success');
        errorLogger.warning('Warning');
        errorLogger.error('Error');

        expect(testError.output, contains('ERROR:'));
        expect(testOutput.output, isNot(contains('Debug')));
        expect(testOutput.output, isNot(contains('INFO')));
        expect(testOutput.output, isNot(contains('WARNING')));

        testOutput.close();
        testError.close();
      });
    });

    group('exception logging', () {
      test('logs exception with stack trace', () {
        final exception = Exception('Test exception');
        final stackTrace = StackTrace.current;

        logger.exception('Operation failed', exception, stackTrace);

        expect(errorSink.output, contains('ERROR:'));
        expect(errorSink.output, contains('Operation failed'));
        expect(errorSink.output, contains('Test exception'));
        expect(errorSink.output, contains('Stack trace:'));
      });

      test('logs exception without stack trace', () {
        final exception = Exception('Test exception');

        logger.exception('Operation failed', exception, null);

        expect(errorSink.output, contains('ERROR:'));
        expect(errorSink.output, contains('Operation failed'));
        expect(errorSink.output, contains('Test exception'));
        expect(errorSink.output, isNot(contains('Stack trace:')));
      });
    });

    group('timestamps', () {
      test('includes timestamps when enabled', () {
        final testOutput = _TestOutputSink();
        final timestampLogger = Logger(
          minLevel: LogLevel.debug,
          output: testOutput,
          colorEnabled: false,
          includeTimestamp: true,
        );

        timestampLogger.info('Message with timestamp');

        // Should contain timestamp format like [YYYY-MM-DD HH:MM:SS]
        expect(testOutput.output,
            matches(RegExp(r'\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]')));
        expect(testOutput.output, contains('Message with timestamp'));

        testOutput.close();
      });

      test('excludes timestamps when disabled', () {
        logger.info('Message without timestamp');

        expect(outputSink.output,
            isNot(matches(RegExp(r'\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]'))));
        expect(outputSink.output, contains('Message without timestamp'));
      });
    });

    group('log level enum', () {
      test('has correct ordering', () {
        expect(LogLevel.debug.index < LogLevel.info.index, isTrue);
        expect(LogLevel.info.index < LogLevel.success.index, isTrue);
        expect(LogLevel.success.index < LogLevel.warn.index, isTrue);
        expect(LogLevel.warn.index < LogLevel.error.index, isTrue);
      });

      test('has correct names', () {
        expect(LogLevel.debug.name, equals('debug'));
        expect(LogLevel.info.name, equals('info'));
        expect(LogLevel.success.name, equals('success'));
        expect(LogLevel.warn.name, equals('warn'));
        expect(LogLevel.error.name, equals('error'));
      });
    });

    group('handles empty and null messages', () {
      test('logs empty string', () {
        logger.info('');
        expect(outputSink.output, isNotEmpty);
      });

      test('logs whitespace', () {
        logger.info('   ');
        expect(outputSink.output, contains('   '));
      });
    });

    group('handles special characters', () {
      test('logs newlines', () {
        logger.info('Line 1\nLine 2');
        expect(outputSink.output, contains('Line 1'));
        expect(outputSink.output, contains('Line 2'));
      });

      test('logs unicode characters', () {
        logger.info('🎉 Success! ✅');
        expect(outputSink.output, contains('🎉 Success! ✅'));
      });

      test('logs quotes', () {
        logger.info('Message with "quotes"');
        expect(outputSink.output, contains('Message with "quotes"'));
      });
    });
  });
}

/// Simple test sink that captures output to a string buffer
class _TestOutputSink implements IOSink {
  final StringBuffer _buffer = StringBuffer();

  String get output => _buffer.toString();

  @override
  Encoding encoding = utf8;

  @override
  void add(List<int> data) {
    _buffer.write(encoding.decode(data));
  }

  @override
  void write(Object? object) {
    _buffer.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    _buffer.writeAll(objects, separator);
  }

  @override
  void writeln([Object? object = '']) {
    _buffer.writeln(object);
  }

  @override
  void writeCharCode(int charCode) {
    _buffer.writeCharCode(charCode);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // Not needed for tests
  }

  @override
  Future addStream(Stream<List<int>> stream) async {
    await for (final data in stream) {
      add(data);
    }
  }

  @override
  Future close() async {
    // Nothing to close
  }

  @override
  Future get done => Future.value();

  @override
  Future flush() async {
    // Nothing to flush
  }
}
