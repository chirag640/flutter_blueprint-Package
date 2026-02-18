import 'package:test/test.dart';
import 'package:flutter_blueprint/src/core/service_locator.dart';

void main() {
  group('ServiceLocator', () {
    late ServiceLocator sl;

    setUp(() {
      sl = ServiceLocator.instance;
      sl.reset();
    });

    tearDown(() {
      sl.reset();
    });

    test('registers and retrieves a lazy singleton', () {
      var callCount = 0;
      sl.register<String>(() {
        callCount++;
        return 'hello';
      });

      expect(sl.get<String>(), 'hello');
      expect(sl.get<String>(), 'hello'); // Same instance
      expect(callCount, 1); // Factory called only once
    });

    test('registerInstance provides pre-created instance', () {
      sl.registerInstance<int>(42);
      expect(sl.get<int>(), 42);
    });

    test('registerFactory creates new instance each time', () {
      var counter = 0;
      sl.registerFactory<int>(() => ++counter);

      expect(sl.get<int>(), 1);
      expect(sl.get<int>(), 2);
      expect(sl.get<int>(), 3);
    });

    test('isRegistered returns correct status', () {
      expect(sl.isRegistered<String>(), isFalse);
      sl.registerInstance<String>('test');
      expect(sl.isRegistered<String>(), isTrue);
    });

    test('tryGet returns null for unregistered type', () {
      expect(sl.tryGet<String>(), isNull);
    });

    test('tryGet returns value for registered type', () {
      sl.registerInstance<String>('found');
      expect(sl.tryGet<String>(), 'found');
    });

    test('get throws for unregistered type', () {
      expect(() => sl.get<double>(), throwsA(isA<StateError>()));
    });

    test('reset clears all registrations', () {
      sl.registerInstance<String>('test');
      sl.registerInstance<int>(42);
      sl.reset();
      expect(sl.isRegistered<String>(), isFalse);
      expect(sl.isRegistered<int>(), isFalse);
    });
  });
}
