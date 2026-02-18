import 'package:test/test.dart';
import 'package:flutter_blueprint/src/core/result.dart';
import 'package:flutter_blueprint/src/core/errors.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('creates a success result', () {
        final result = Result<int, String>.success(42);
        expect(result, isA<Success<int, String>>());
      });

      test('valueOrNull returns value', () {
        final result = Result<int, String>.success(42);
        expect(result.valueOrNull, 42);
      });

      test('errorOrNull returns null for success', () {
        final result = Result<int, String>.success(42);
        expect(result.errorOrNull, isNull);
      });

      test('valueOrThrow returns value', () {
        final result = Result<int, String>.success(42);
        expect(result.valueOrThrow, 42);
      });

      test('getOrElse returns value', () {
        final result = Result<int, String>.success(42);
        expect(result.getOrElse((_) => 0), 42);
      });

      test('when calls success branch', () {
        final result = Result<int, String>.success(42);
        final output = result.when(
          success: (v) => 'OK: $v',
          failure: (e) => 'ERR: $e',
        );
        expect(output, 'OK: 42');
      });

      test('map transforms value', () {
        final result = Result<int, String>.success(42);
        final mapped = result.map((v) => v * 2);
        expect(mapped.valueOrNull, 84);
      });

      test('flatMap chains results', () {
        final result = Result<int, String>.success(42);
        final chained = result.flatMap((v) => Result.success(v.toString()));
        expect(chained.valueOrNull, '42');
      });

      test('mapError does nothing on success', () {
        final result = Result<int, String>.success(42);
        final mapped = result.mapError((e) => 'mapped: $e');
        expect(mapped.valueOrNull, 42);
      });
    });

    group('Failure', () {
      test('creates a failure result', () {
        final result = Result<int, String>.failure('err');
        expect(result, isA<Failure<int, String>>());
      });

      test('valueOrNull returns null for failure', () {
        final result = Result<int, String>.failure('err');
        expect(result.valueOrNull, isNull);
      });

      test('errorOrNull returns error', () {
        final result = Result<int, String>.failure('err');
        expect(result.errorOrNull, 'err');
      });

      test('valueOrThrow throws Exception', () {
        final result = Result<int, String>.failure('err');
        expect(() => result.valueOrThrow, throwsA(isA<Exception>()));
      });

      test('getOrElse returns fallback', () {
        final result = Result<int, String>.failure('err');
        expect(result.getOrElse((_) => 99), 99);
      });

      test('when calls failure branch', () {
        final result = Result<int, String>.failure('err');
        final output = result.when(
          success: (v) => 'OK: $v',
          failure: (e) => 'ERR: $e',
        );
        expect(output, 'ERR: err');
      });

      test('map does nothing on failure', () {
        final result = Result<int, String>.failure('err');
        final mapped = result.map((v) => v * 2);
        expect(mapped.errorOrNull, 'err');
      });

      test('flatMap does nothing on failure', () {
        final result = Result<int, String>.failure('err');
        final chained = result.flatMap((v) => Result.success(v.toString()));
        expect(chained.errorOrNull, 'err');
      });

      test('mapError transforms error', () {
        final result = Result<int, String>.failure('err');
        final mapped = result.mapError((e) => 'mapped: $e');
        expect(mapped.errorOrNull, 'mapped: err');
      });
    });
  });

  group('Error hierarchy', () {
    test('BlueprintException has message', () {
      const error = ConfigurationError('bad config');
      expect(error.message, 'bad config');
      expect(error.toString(), contains('bad config'));
    });

    test('CommandError has command field', () {
      final error = CommandError('failed', command: 'init');
      expect(error.command, 'init');
      expect(error.code, 'COMMAND_ERROR');
    });

    test('ConfigurationError has correct code', () {
      const error = ConfigurationError('missing key');
      expect(error.code, 'CONFIGURATION_ERROR');
    });

    test('ProjectGenerationError has correct code', () {
      const error = ProjectGenerationError('gen failed');
      expect(error.code, 'PROJECT_GENERATION_ERROR');
    });

    test('TemplateRenderError has correct code', () {
      const error = TemplateRenderError('render failed');
      expect(error.code, 'TEMPLATE_RENDER_ERROR');
    });

    test('ValidationError has correct code', () {
      const error = ValidationError('invalid');
      expect(error.code, 'VALIDATION_ERROR');
    });

    test('FileOperationError has correct code', () {
      const error = FileOperationError('io failed');
      expect(error.code, 'FILE_OPERATION_ERROR');
    });

    test('all errors are subtypes of BlueprintException', () {
      const errors = <BlueprintException>[
        ConfigurationError('a'),
        ProjectGenerationError('b'),
        TemplateRenderError('c'),
        ValidationError('d'),
        FileOperationError('e'),
      ];
      for (final e in errors) {
        expect(e, isA<BlueprintException>());
      }
    });

    test('errors with cause preserve it', () {
      final cause = FormatException('bad format');
      final error = CommandError('wrap', command: 'x', cause: cause);
      expect(error.cause, same(cause));
    });
  });
}
