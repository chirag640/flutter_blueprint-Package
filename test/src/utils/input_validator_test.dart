import 'package:test/test.dart';
import 'package:flutter_blueprint/src/utils/input_validator.dart';

void main() {
  group('InputValidator.validatePackageName', () {
    group('accepts valid names', () {
      test('simple lowercase name', () {
        expect(
          InputValidator.validatePackageName('myapp'),
          equals('myapp'),
        );
      });

      test('name with underscores', () {
        expect(
          InputValidator.validatePackageName('my_app'),
          equals('my_app'),
        );
      });

      test('name with numbers', () {
        expect(
          InputValidator.validatePackageName('app2023'),
          equals('app2023'),
        );
      });

      test('name with underscores and numbers', () {
        expect(
          InputValidator.validatePackageName('my_app_v2'),
          equals('my_app_v2'),
        );
      });

      test('single character name', () {
        expect(
          InputValidator.validatePackageName('a'),
          equals('a'),
        );
      });

      test('maximum length name', () {
        final maxName = 'a' * InputValidator.maxAppNameLength;
        expect(
          InputValidator.validatePackageName(maxName),
          equals(maxName),
        );
      });
    });

    group('rejects invalid names', () {
      test('empty string', () {
        expect(
          () => InputValidator.validatePackageName(''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot be empty'),
            ),
          ),
        );
      });

      test('name starting with uppercase', () {
        expect(
          () => InputValidator.validatePackageName('MyApp'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must start with a lowercase letter'),
            ),
          ),
        );
      });

      test('name starting with number', () {
        expect(
          () => InputValidator.validatePackageName('2myapp'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('name starting with underscore', () {
        expect(
          () => InputValidator.validatePackageName('_myapp'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must start with a lowercase letter'),
            ),
          ),
        );
      });

      test('name ending with underscore', () {
        expect(
          () => InputValidator.validatePackageName('myapp_'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot end with an underscore'),
            ),
          ),
        );
      });

      test('name with consecutive underscores', () {
        expect(
          () => InputValidator.validatePackageName('my__app'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot contain consecutive underscores'),
            ),
          ),
        );
      });

      test('name with special characters', () {
        expect(
          () => InputValidator.validatePackageName('my-app'),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => InputValidator.validatePackageName('my.app'),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => InputValidator.validatePackageName('my app'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('name exceeding maximum length', () {
        final tooLongName = 'a' * (InputValidator.maxAppNameLength + 1);
        expect(
          () => InputValidator.validatePackageName(tooLongName),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be ${InputValidator.maxAppNameLength}'),
            ),
          ),
        );
      });
    });

    group('rejects Dart reserved words', () {
      test('class', () {
        expect(
          () => InputValidator.validatePackageName('class'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('reserved word'),
            ),
          ),
        );
      });

      test('void', () {
        expect(
          () => InputValidator.validatePackageName('void'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('if', () {
        expect(
          () => InputValidator.validatePackageName('if'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('async', () {
        expect(
          () => InputValidator.validatePackageName('async'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('rejects Dart built-in types', () {
      test('int', () {
        expect(
          () => InputValidator.validatePackageName('int'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('built-in type'),
            ),
          ),
        );
      });

      test('string (case insensitive)', () {
        expect(
          () => InputValidator.validatePackageName('string'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('list', () {
        expect(
          () => InputValidator.validatePackageName('list'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('custom field name in error message', () {
      expect(
        () => InputValidator.validatePackageName(
          'class',
          fieldName: 'feature name',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('feature name'),
          ),
        ),
      );
    });

    test('custom max length', () {
      expect(
        () => InputValidator.validatePackageName(
          'verylongname',
          maxLength: 5,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must be 5 characters'),
          ),
        ),
      );
    });
  });

  group('InputValidator.validateFilePath', () {
    group('accepts valid paths', () {
      test('simple relative path', () {
        expect(
          InputValidator.validateFilePath('lib/main.dart'),
          equals('lib/main.dart'),
        );
      });

      test('nested path', () {
        expect(
          InputValidator.validateFilePath('lib/src/utils/logger.dart'),
          equals('lib/src/utils/logger.dart'),
        );
      });

      test('path with dots in filename', () {
        expect(
          InputValidator.validateFilePath('lib/my.file.dart'),
          equals('lib/my.file.dart'),
        );
      });

      test('normalizes path with ./', () {
        final result = InputValidator.validateFilePath('lib/./main.dart');
        expect(result, equals('lib/main.dart'));
      });
    });

    group('rejects dangerous paths', () {
      test('path traversal with ../', () {
        expect(
          () => InputValidator.validateFilePath('../etc/passwd'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('path traversal'),
            ),
          ),
        );
      });

      test('path traversal in middle', () {
        expect(
          () => InputValidator.validateFilePath('lib/../../main.dart'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('null byte injection', () {
        expect(
          () => InputValidator.validateFilePath('lib/main\x00.dart'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('null byte'),
            ),
          ),
        );
      });

      test('control characters', () {
        expect(
          () => InputValidator.validateFilePath('lib/main\n.dart'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('control characters'),
            ),
          ),
        );
      });

      test('empty path', () {
        expect(
          () => InputValidator.validateFilePath(''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot be empty'),
            ),
          ),
        );
      });

      test('path exceeding maximum length', () {
        // Create a path longer than maxPathLength (4096 chars)
        final tooLong = 'a/' * (InputValidator.maxPathLength ~/ 2) + 'x';
        expect(
          () => InputValidator.validateFilePath(tooLong),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('maximum length'),
            ),
          ),
        );
      });
    });

    group('absolute path handling', () {
      test('rejects absolute path by default', () {
        expect(
          () => InputValidator.validateFilePath('/usr/bin/app'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be a relative path'),
            ),
          ),
        );
      });

      test('accepts absolute path when allowed', () {
        final result = InputValidator.validateFilePath(
          '/tmp/myproject',
          allowAbsolute: true,
        );
        expect(result, isNotEmpty);
      });
    });
  });

  group('InputValidator.validateTargetDirectory', () {
    test('accepts valid target directory', () {
      final result = InputValidator.validateTargetDirectory('/tmp/myproject');
      expect(result, isNotEmpty);
    });

    test('rejects root directory', () {
      expect(
        () => InputValidator.validateTargetDirectory('/'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('root directory'),
          ),
        ),
      );
    });

    group('rejects system directories', () {
      test('/etc directory', () {
        expect(
          () => InputValidator.validateTargetDirectory('/etc/myapp'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('system directory'),
            ),
          ),
        );
      });

      test('/usr/bin directory', () {
        expect(
          () => InputValidator.validateTargetDirectory('/usr/bin/myapp'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('/sys directory', () {
        expect(
          () => InputValidator.validateTargetDirectory('/sys/myapp'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('rejects path traversal', () {
      expect(
        () => InputValidator.validateTargetDirectory('../../../etc'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('InputValidator.validateCommand', () {
    group('accepts safe commands', () {
      test('simple command', () {
        expect(
          InputValidator.validateCommand('flutter'),
          equals('flutter'),
        );
      });

      test('command with hyphens', () {
        expect(
          InputValidator.validateCommand('dart-analyze'),
          equals('dart-analyze'),
        );
      });

      test('command with underscores', () {
        expect(
          InputValidator.validateCommand('my_command'),
          equals('my_command'),
        );
      });
    });

    group('rejects dangerous commands', () {
      test('command with semicolon', () {
        expect(
          () => InputValidator.validateCommand('flutter; rm -rf /'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('dangerous character'),
            ),
          ),
        );
      });

      test('command with pipe', () {
        expect(
          () => InputValidator.validateCommand('cat file | bash'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('command with ampersand', () {
        expect(
          () => InputValidator.validateCommand('flutter && whoami'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('command with redirect', () {
        expect(
          () => InputValidator.validateCommand('echo > /etc/passwd'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('command with backtick', () {
        expect(
          () => InputValidator.validateCommand('flutter `whoami`'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('command with dollar sign', () {
        expect(
          () => InputValidator.validateCommand('flutter \$USER'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('empty command', () {
        expect(
          () => InputValidator.validateCommand(''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot be empty'),
            ),
          ),
        );
      });
    });
  });

  group('InputValidator.validateYamlKey', () {
    test('accepts valid YAML keys', () {
      expect(
        InputValidator.validateYamlKey('app_name'),
        equals('app_name'),
      );
      expect(
        InputValidator.validateYamlKey('version'),
        equals('version'),
      );
      expect(
        InputValidator.validateYamlKey('_private'),
        equals('_private'),
      );
    });

    test('rejects YAML special characters', () {
      expect(
        () => InputValidator.validateYamlKey('key:value'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => InputValidator.validateYamlKey('key[0]'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => InputValidator.validateYamlKey('key{a}'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects key not starting with letter/underscore', () {
      expect(
        () => InputValidator.validateYamlKey('123key'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must start with letter or underscore'),
          ),
        ),
      );
    });

    test('rejects empty key', () {
      expect(
        () => InputValidator.validateYamlKey(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects key exceeding max length', () {
      final tooLong = 'a' * 257;
      expect(
        () => InputValidator.validateYamlKey(tooLong),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('too long'),
          ),
        ),
      );
    });
  });

  group('InputValidator.validateEnumValue', () {
    test('accepts valid enum value from config', () {
      // Using real enum from the codebase
      final result = InputValidator.validateEnumValue(
        'provider',
        <_MockEnum>[_MockEnum.provider, _MockEnum.riverpod, _MockEnum.bloc],
        'StateManagement',
      );
      expect(result, equals(_MockEnum.provider));
    });

    test('is case insensitive', () {
      final result = InputValidator.validateEnumValue(
        'RIVERPOD',
        <_MockEnum>[_MockEnum.provider, _MockEnum.riverpod, _MockEnum.bloc],
        'StateManagement',
      );
      expect(result, equals(_MockEnum.riverpod));
    });

    test('trims whitespace', () {
      final result = InputValidator.validateEnumValue(
        '  bloc  ',
        <_MockEnum>[_MockEnum.provider, _MockEnum.riverpod, _MockEnum.bloc],
        'StateManagement',
      );
      expect(result, equals(_MockEnum.bloc));
    });

    test('rejects invalid enum value', () {
      expect(
        () => InputValidator.validateEnumValue(
          'invalid',
          <_MockEnum>[_MockEnum.provider, _MockEnum.riverpod, _MockEnum.bloc],
          'StateManagement',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('Invalid StateManagement'),
              contains('Valid values are'),
            ),
          ),
        ),
      );
    });

    test('rejects empty string', () {
      expect(
        () => InputValidator.validateEnumValue(
          '',
          <_MockEnum>[_MockEnum.provider],
          'StateManagement',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('cannot be empty'),
          ),
        ),
      );
    });

    test('rejects value exceeding max length', () {
      final tooLong = 'a' * 65;
      expect(
        () => InputValidator.validateEnumValue(
          tooLong,
          <_MockEnum>[_MockEnum.provider],
          'StateManagement',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('too long'),
          ),
        ),
      );
    });
  });
}

// Mock enum for testing
enum _MockEnum {
  provider,
  riverpod,
  bloc,
}
