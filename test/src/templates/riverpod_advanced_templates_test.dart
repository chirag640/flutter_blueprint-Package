import 'package:flutter_blueprint/src/templates/riverpod_advanced_templates.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncNotifier Pattern Generator', () {
    test('generates CancellableAsyncNotifier class', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains('class CancellableAsyncNotifier'));
      expect(result, contains('extends FamilyAsyncNotifier'));
      expect(result, contains('CancellationToken'));
    });

    test('includes cancellation token management', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains('CancellationToken get cancelToken'));
      expect(result, contains('_cancelToken?.cancel()'));
      expect(result, contains('void throwIfCancelled()'));
    });

    test('includes retry logic with exponential backoff', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains('Future<void> retry('));
      expect(result, contains('maxAttempts'));
      expect(result, contains('initialDelay'));
      expect(result, contains('delay *= 2'));
    });

    test('includes optimistic update pattern', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains('updateOptimistically'));
      expect(result, contains('optimisticValue'));
      expect(result, contains('previousState'));
      expect(result, contains('// Rollback'));
    });

    test('includes rebuild method', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains('Future<void> rebuild()'));
      expect(result, contains('AsyncValue.loading()'));
      expect(result, contains('AsyncValue.guard'));
    });

    test('includes CancelledException class', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains('class CancelledException implements Exception'));
      expect(result, contains('Operation was cancelled'));
    });

    test('includes proper imports', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains("import 'dart:async'"));
      expect(result,
          contains("import 'package:flutter_riverpod/flutter_riverpod.dart'"));
    });

    test('includes comprehensive documentation', () {
      final result = generateAsyncNotifierPattern();

      expect(result, contains('/// Base class for AsyncNotifier'));
      expect(result, contains('/// Usage:'));
      expect(result, contains('/// Access the cancellation token'));
    });
  });

  group('AutoDisposing Family Generator', () {
    test('generates Ref extension', () {
      final result = generateAutoDisposingFamily();

      expect(result, contains('extension AutoDisposingFamilyX on Ref'));
      expect(result, contains('keepAliveFor'));
      expect(result, contains('cacheFor'));
      expect(result, contains('disposeDelay'));
    });

    test('includes keepAliveFor with timer', () {
      final result = generateAutoDisposingFamily();

      expect(result, contains('void keepAliveFor(Duration duration)'));
      expect(result, contains('final link = keepAlive()'));
      expect(result, contains('final timer = Timer(duration'));
      expect(result, contains('onDispose(timer.cancel)'));
    });

    test('includes cacheFor with refresh callback', () {
      final result = generateAutoDisposingFamily();

      expect(result, contains('void cacheFor'));
      expect(result, contains('VoidCallback? onRefresh'));
      expect(result, contains('onRefresh?.call()'));
    });

    test('includes disposeDelay with timer management', () {
      final result = generateAutoDisposingFamily();

      expect(result, contains('void disposeDelay(Duration duration)'));
      expect(result, contains('onCancel(() {'));
      expect(result, contains('onResume(() {'));
    });

    test('includes FamilyCache LRU implementation', () {
      final result = generateAutoDisposingFamily();

      expect(result, contains('class FamilyCache'));
      expect(result, contains('final int maxSize'));
      expect(result, contains('V? get(K key)'));
      expect(result, contains('void put(K key, V value)'));
      expect(result, contains('_updateAccessOrder'));
    });

    test('includes proper LRU eviction', () {
      final result = generateAutoDisposingFamily();

      expect(result, contains('if (_cache.length >= maxSize)'));
      expect(result, contains('final oldestKey = _accessOrder.removeAt(0)'));
      expect(result, contains('_cache.remove(oldestKey)'));
    });

    test('includes comprehensive usage examples', () {
      final result = generateAutoDisposingFamily();

      expect(result, contains('/// Usage:'));
      expect(result, contains('ref.keepAliveFor'));
      expect(result, contains('ref.cacheFor'));
      expect(result, contains('ref.disposeDelay'));
    });
  });

  group('Provider Composition Generator', () {
    test('generates ProviderComposer class', () {
      final result = generateProviderComposition();

      expect(result, contains('class ProviderComposer'));
      expect(result, contains('combine2'));
      expect(result, contains('combine3'));
      expect(result, contains('combine4'));
    });

    test('includes combine2 for two providers', () {
      final result = generateProviderComposition();

      expect(result, contains('static T combine2'));
      expect(result, contains('ProviderListenable<A> providerA'));
      expect(result, contains('ProviderListenable<B> providerB'));
      expect(result, contains('T Function(A a, B b) combiner'));
    });

    test('includes combine3 for three providers', () {
      final result = generateProviderComposition();

      expect(result, contains('static T combine3'));
      expect(result, contains('<T, A, B, C>'));
      expect(result, contains('T Function(A a, B b, C c)'));
    });

    test('includes combine4 for four providers', () {
      final result = generateProviderComposition();

      expect(result, contains('static T combine4'));
      expect(result, contains('<T, A, B, C, D>'));
      expect(result, contains('T Function(A a, B b, C c, D d)'));
    });

    test('includes select helper for field selection', () {
      final result = generateProviderComposition();

      expect(result, contains('static R select<T, R>'));
      expect(result, contains('R Function(T value) selector'));
      expect(result, contains('provider.select(selector)'));
    });

    test('includes DerivedStateMixin', () {
      final result = generateProviderComposition();

      expect(result, contains('mixin DerivedStateMixin'));
      expect(result, contains('listenTo'));
      expect(result, contains('disposeSubscriptions'));
      expect(result, contains('_subscriptions'));
    });

    test('includes AsyncSelector class', () {
      final result = generateProviderComposition();

      expect(result, contains('class AsyncSelector'));
      expect(result, contains('ProviderListenable<AsyncValue<T>> source'));
      expect(result, contains('R Function(T value) selector'));
      expect(result, contains('asyncValue.whenData(selector)'));
    });

    test('includes usage examples', () {
      final result = generateProviderComposition();

      expect(result, contains('/// Usage:'));
      expect(result, contains('combine2'));
      expect(result, contains('select'));
    });
  });

  group('Code Generation Setup', () {
    test('includes @riverpod annotation examples', () {
      final result = generateCodeGenSetup();

      expect(result, contains('@riverpod'));
      expect(result, contains('Future<String> exampleData'));
      expect(result, contains('Stream<int> exampleStream'));
    });

    test('includes class-based notifier example', () {
      final result = generateCodeGenSetup();

      expect(result, contains('class ExampleNotifier extends'));
      expect(result, contains('int build() => 0'));
      expect(result, contains('void increment()'));
      expect(result, contains('void decrement()'));
    });

    test('includes async notifier with family', () {
      final result = generateCodeGenSetup();

      expect(result, contains('class ExampleAsyncNotifier extends'));
      expect(result, contains('Future<String> build(String id)'));
      expect(result, contains('Future<void> refresh()'));
    });

    test('includes dependency setup instructions', () {
      final result = generateCodeGenSetup();

      expect(result, contains('riverpod_annotation:'));
      expect(result, contains('riverpod_generator:'));
      expect(result, contains('build_runner:'));
    });

    test('includes build command instruction', () {
      final result = generateCodeGenSetup();

      expect(result, contains('flutter pub run build_runner build'));
      expect(result, contains('--delete-conflicting-outputs'));
    });

    test('includes build.yaml configuration', () {
      final result = generateCodeGenSetup();

      expect(result, contains('build.yaml'));
      expect(result, contains('targets:'));
      expect(result, contains('default:'));
      expect(result, contains('riverpod_generator:'));
    });

    test('includes proper annotations and comments', () {
      final result = generateCodeGenSetup();

      expect(result, contains('/// Generated provider example'));
      expect(result, contains('/// Example:'));
      expect(result, contains('part'));
    });
  });

  group('Advanced Examples Generator', () {
    test('generates repository pattern', () {
      final result = generateAdvancedExamples();

      expect(result, contains('abstract class UserRepository'));
      expect(result,
          contains('class UserRepositoryImpl implements UserRepository'));
      expect(result, contains('final userRepositoryProvider = Provider'));
    });

    test('includes use case pattern', () {
      final result = generateAdvancedExamples();

      expect(result, contains('class GetUserUseCase'));
      expect(result, contains('final getUserUseCaseProvider'));
      expect(result, contains('Future<User> call(String id)'));
    });

    test('includes StateNotifier pattern', () {
      final result = generateAdvancedExamples();

      expect(result, contains('class UserState'));
      expect(result,
          contains('class UserNotifier extends StateNotifier<UserState>'));
      expect(result,
          contains('final userNotifierProvider = StateNotifierProvider'));
    });

    test('includes pagination pattern', () {
      final result = generateAdvancedExamples();

      expect(result, contains('class PaginatedState'));
      expect(result, contains('class PaginatedNotifier'));
      expect(result, contains('Future<void> loadMore()'));
      expect(result, contains('Future<void> refresh()'));
    });

    test('includes API client pattern', () {
      final result = generateAdvancedExamples();

      expect(result, contains('class ApiClient'));
      expect(result, contains('Future<ApiResponse> get'));
      expect(result, contains('Future<ApiResponse> put'));
    });

    test('includes User model with JSON serialization', () {
      final result = generateAdvancedExamples();

      expect(result, contains('class User'));
      expect(result, contains('factory User.fromJson'));
      expect(result, contains('Map<String, dynamic> toJson()'));
    });

    test('includes proper error handling', () {
      final result = generateAdvancedExamples();

      expect(result, contains('try {'));
      expect(result, contains('catch (e) {'));
      expect(result, contains('isLoading: false'));
      expect(result, contains('error: e.toString()'));
    });
  });

  group('Performance Patterns Generator', () {
    test('includes select pattern examples', () {
      final result = generatePerformancePatterns();

      expect(result, contains('class SelectExample'));
      expect(result, contains('.select((user) => user.name)'));
      expect(result, contains('// Only rebuilds when name changes'));
    });

    test('includes Consumer pattern', () {
      final result = generatePerformancePatterns();

      expect(result, contains('Consumer'));
      expect(result, contains('builder: (context, ref, child)'));
      expect(result, contains("// Doesn't rebuild"));
    });

    test('includes ref.read() pattern', () {
      final result = generatePerformancePatterns();

      expect(result, contains('ref.read('));
      expect(result, contains('// No rebuild dependency'));
    });

    test('includes provider combination pattern', () {
      final result = generatePerformancePatterns();

      expect(result, contains('final combinedAppStateProvider'));
      expect(result, contains('class CombinedExample'));
    });

    test('includes batch update pattern', () {
      final result = generatePerformancePatterns();

      expect(result, contains('class BatchUpdateExample'));
      expect(result, contains('updateBad'));
      expect(result, contains('updateGood'));
      expect(result, contains('// Multiple state updates'));
    });

    test('includes autoDispose pattern', () {
      final result = generatePerformancePatterns();

      expect(result, contains('FutureProvider.autoDispose'));
      expect(result, contains('// Provider disposed when no longer used'));
    });

    test('includes debounce pattern', () {
      final result = generatePerformancePatterns();

      expect(result, contains('class DebouncedSearchNotifier'));
      expect(result, contains('_debounceTimer?.cancel()'));
      expect(result, contains('Duration(milliseconds: 300)'));
    });

    test('includes const parameter optimization', () {
      final result = generatePerformancePatterns();

      expect(result, contains('const itemId'));
      expect(result, contains('// Reuses provider instance'));
    });
  });

  group('Code Quality', () {
    test('all generators produce non-empty output', () {
      expect(generateAsyncNotifierPattern().trim(), isNotEmpty);
      expect(generateAutoDisposingFamily().trim(), isNotEmpty);
      expect(generateProviderComposition().trim(), isNotEmpty);
      expect(generateCodeGenSetup().trim(), isNotEmpty);
      expect(generateAdvancedExamples().trim(), isNotEmpty);
      expect(generatePerformancePatterns().trim(), isNotEmpty);
    });

    test('all generators include proper imports', () {
      final generators = [
        generateAsyncNotifierPattern(),
        generateAutoDisposingFamily(),
        generateProviderComposition(),
        generateAdvancedExamples(),
        generatePerformancePatterns(),
      ];

      for (final code in generators) {
        expect(
          code,
          contains('flutter_riverpod'),
          reason: 'Should import flutter_riverpod',
        );
      }
    });

    test('generated code has balanced braces', () {
      final generators = [
        generateAsyncNotifierPattern(),
        generateAutoDisposingFamily(),
        generateProviderComposition(),
        generateCodeGenSetup(),
        generateAdvancedExamples(),
        generatePerformancePatterns(),
      ];

      for (final code in generators) {
        final openBraces = '{'.allMatches(code).length;
        final closeBraces = '}'.allMatches(code).length;
        expect(
          openBraces,
          equals(closeBraces),
          reason: 'Braces should be balanced',
        );
      }
    });

    test('generated code has balanced parentheses', () {
      final generators = [
        generateAsyncNotifierPattern(),
        generateAutoDisposingFamily(),
        generateProviderComposition(),
        generateCodeGenSetup(),
        generateAdvancedExamples(),
        generatePerformancePatterns(),
      ];

      for (final code in generators) {
        final openParens = '('.allMatches(code).length;
        final closeParens = ')'.allMatches(code).length;
        expect(
          openParens,
          equals(closeParens),
          reason: 'Parentheses should be balanced',
        );
      }
    });

    test('no unescaped interpolation in template code', () {
      final generators = [
        generateAsyncNotifierPattern(),
        generateAutoDisposingFamily(),
        generateProviderComposition(),
        generateCodeGenSetup(),
        generateAdvancedExamples(),
        generatePerformancePatterns(),
      ];

      for (final code in generators) {
        // Should not have unescaped $ in generated code comments
        final lines = code.split('\n');
        for (final line in lines) {
          if (line.trim().startsWith('///')) {
            // Doc comments should have escaped interpolation
            final unescapedDollar = RegExp(r'[^\\]\$\w+');
            expect(
              unescapedDollar.hasMatch(line),
              isFalse,
              reason: 'Doc comments should escape \$ interpolation: $line',
            );
          }
        }
      }
    });
  });

  group('Integration Tests', () {
    test('AsyncNotifier integrates with AutoDisposingFamily', () {
      final asyncNotifier = generateAsyncNotifierPattern();
      final autoDisposing = generateAutoDisposingFamily();

      expect(asyncNotifier, contains('CancellationToken'));
      expect(autoDisposing, contains('keepAliveFor'));

      // Both support FamilyAsyncNotifier pattern
      expect(asyncNotifier, contains('FamilyAsyncNotifier'));
    });

    test('ProviderComposition works with PerformancePatterns', () {
      final composition = generateProviderComposition();
      final performance = generatePerformancePatterns();

      expect(composition, contains('select'));
      expect(performance, contains('.select('));

      // Both promote efficient provider usage
      expect(composition, contains('ProviderListenable'));
      expect(performance, contains('ref.watch'));
    });

    test('CodeGenSetup includes necessary annotations', () {
      final codeGen = generateCodeGenSetup();

      expect(codeGen, contains('@riverpod'));
      expect(codeGen, contains('riverpod_annotation'));
      expect(codeGen, contains('riverpod_generator'));
      expect(codeGen, contains('build_runner'));
    });

    test('AdvancedExamples demonstrate real-world patterns', () {
      final examples = generateAdvancedExamples();

      // Repository pattern
      expect(examples, contains('UserRepository'));

      // Use case pattern
      expect(examples, contains('GetUserUseCase'));

      // StateNotifier pattern
      expect(examples, contains('UserNotifier'));
      expect(examples, contains('StateNotifier'));

      // Pagination
      expect(examples, contains('PaginatedNotifier'));
    });

    test('all patterns follow Riverpod best practices', () {
      final generators = [
        generateAsyncNotifierPattern(),
        generateAutoDisposingFamily(),
        generateProviderComposition(),
        generateAdvancedExamples(),
        generatePerformancePatterns(),
      ];

      for (final code in generators) {
        // Should use Provider/StateNotifier correctly
        if (code.contains('Provider')) {
          expect(
            code,
            anyOf(
              contains('Provider<'),
              contains('Provider('),
              contains('FutureProvider'),
              contains('StreamProvider'),
              contains('StateNotifierProvider'),
            ),
          );
        }

        // Should include proper ref usage
        if (code.contains('ref.')) {
          expect(
            code,
            anyOf(
              contains('ref.watch'),
              contains('ref.read'),
              contains('ref.listen'),
            ),
          );
        }
      }
    });

    test('documentation is comprehensive and helpful', () {
      final generators = [
        generateAsyncNotifierPattern(),
        generateAutoDisposingFamily(),
        generateProviderComposition(),
        generateCodeGenSetup(),
        generateAdvancedExamples(),
        generatePerformancePatterns(),
      ];

      for (final code in generators) {
        // Should have doc comments
        expect(code, contains('///'));

        // Should have usage examples
        expect(
          code,
          anyOf(
            contains('/// Usage:'),
            contains('/// Example:'),
            contains('Usage:'),
            contains('Example:'),
          ),
        );
      }
    });
  });
}
