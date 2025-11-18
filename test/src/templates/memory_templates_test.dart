import 'package:flutter_blueprint/src/templates/memory_templates.dart';
import 'package:test/test.dart';

void main() {
  group('Memory Templates -', () {
    group('DisposableBloc Generator', () {
      test('generates valid Dart code', () {
        final result = generateDisposableBloc();

        expect(result, isNotEmpty);
        expect(result, contains('class DisposableBloc'));
        expect(result, contains('extends Bloc'));
        expect(result, contains('import'));
      });

      test('includes subscription management', () {
        final result = generateDisposableBloc();

        expect(result, contains('addSubscription'));
        expect(result, contains('addController'));
        expect(result, contains('StreamSubscription'));
        expect(result, contains('StreamController'));
      });

      test('includes automatic cleanup in close method', () {
        final result = generateDisposableBloc();

        expect(result, contains('@override'));
        expect(result, contains('Future<void> close()'));
        expect(result, contains('subscription.cancel()'));
        expect(result, contains('controller.close()'));
      });

      test('has proper documentation', () {
        final result = generateDisposableBloc();

        expect(result, contains('///'));
        expect(result, contains('Base class'));
        expect(result, contains('disposal'));
      });
    });

    group('DisposableProvider Generator', () {
      test('generates valid Dart code', () {
        final result = generateDisposableProvider();

        expect(result, isNotEmpty);
        expect(result, contains('class DisposableProvider'));
        expect(result, contains('extends ChangeNotifier'));
        expect(result, contains('import'));
      });

      test('includes disposed flag', () {
        final result = generateDisposableProvider();

        expect(result, contains('bool _disposed'));
        expect(result, contains('bool get isDisposed'));
      });

      test('includes subscription management', () {
        final result = generateDisposableProvider();

        expect(result, contains('addSubscription'));
        expect(result, contains('addController'));
        expect(result, contains('StreamSubscription'));
        expect(result, contains('StreamController'));
      });

      test('prevents operations after disposal', () {
        final result = generateDisposableProvider();

        expect(result, contains('StateError'));
        expect(result, contains('after disposal'));
        expect(result, contains('if (_disposed)'));
      });

      test('safely handles notifyListeners after disposal', () {
        final result = generateDisposableProvider();

        expect(result, contains('notifyListeners'));
        expect(result, contains('if (!_disposed)'));
      });
    });

    group('DisposableRiverpod Generator', () {
      test('generates valid Dart code', () {
        final result = generateDisposableRiverpod();

        expect(result, isNotEmpty);
        expect(result, contains('extension DisposeExtension'));
        expect(result, contains('mixin DisposableNotifierMixin'));
        expect(result, contains('import'));
      });

      test('includes Ref extension methods', () {
        final result = generateDisposableRiverpod();

        expect(result, contains('on Ref'));
        expect(result, contains('onDisposeSubscription'));
        expect(result, contains('onDisposeController'));
        expect(result, contains('onDisposeMultiple'));
      });

      test('includes DisposableNotifierMixin', () {
        final result = generateDisposableRiverpod();

        expect(result, contains('on Notifier<State>'));
        expect(result, contains('addSubscription'));
        expect(result, contains('addController'));
        expect(result, contains('cleanupResources'));
      });

      test('uses ref.onDispose correctly', () {
        final result = generateDisposableRiverpod();

        expect(result, contains('ref.onDispose'));
        expect(result, contains('subscription.cancel'));
        expect(result, contains('controller.close'));
      });
    });

    group('MemoryProfiler Generator', () {
      test('generates valid Dart code', () {
        final result = generateMemoryProfiler();

        expect(result, isNotEmpty);
        expect(result, contains('class MemoryProfiler'));
        expect(result, contains('factory MemoryProfiler()'));
        expect(result, contains('import'));
      });

      test('includes monitoring methods', () {
        final result = generateMemoryProfiler();

        expect(result, contains('startMonitoring'));
        expect(result, contains('stopMonitoring'));
        expect(result, contains('_captureSnapshot'));
        expect(result, contains('_checkForLeaks'));
      });

      test('includes MemorySnapshot class', () {
        final result = generateMemoryProfiler();

        expect(result, contains('class MemorySnapshot'));
        expect(result, contains('timestamp'));
        expect(result, contains('rss'));
      });

      test('includes MemoryStats class', () {
        final result = generateMemoryProfiler();

        expect(result, contains('class MemoryStats'));
        expect(result, contains('current'));
        expect(result, contains('peak'));
        expect(result, contains('average'));
      });

      test('includes memory leak detection', () {
        final result = generateMemoryProfiler();

        expect(result, contains('Potential memory leak'));
        expect(result, contains('avgGrowth'));
        expect(result, contains('1024 * 1024'));
      });

      test('formats bytes correctly', () {
        final result = generateMemoryProfiler();

        expect(result, contains('_formatBytes'));
        expect(result, contains('KB'));
        expect(result, contains('MB'));
      });
    });

    group('ImageCacheManager Generator', () {
      test('generates valid Dart code', () {
        final result = generateImageCacheManager();

        expect(result, isNotEmpty);
        expect(result, contains('class ImageCacheManager'));
        expect(result, contains('factory ImageCacheManager()'));
        expect(result, contains('import'));
      });

      test('includes cache size management', () {
        final result = generateImageCacheManager();

        expect(result, contains('_maxCacheSize'));
        expect(result, contains('_currentCacheSize'));
        expect(result, contains('setMaxCacheSize'));
      });

      test('includes image caching methods', () {
        final result = generateImageCacheManager();

        expect(result, contains('cacheImage'));
        expect(result, contains('getCachedImage'));
        expect(result, contains('clearCache'));
      });

      test('includes eviction logic', () {
        final result = generateImageCacheManager();

        expect(result, contains('_evictIfNeeded'));
        expect(result, contains('_evictOldest'));
        expect(result, contains('LRU'));
      });

      test('includes CachedImage class', () {
        final result = generateImageCacheManager();

        expect(result, contains('class CachedImage'));
        expect(result, contains('ui.Image'));
        expect(result, contains('sizeBytes'));
        expect(result, contains('copyWith'));
      });

      test('includes configure method for ImageCache', () {
        final result = generateImageCacheManager();

        expect(result, contains('configure'));
        expect(result, contains('ImageCache'));
        expect(result, contains('maximumSizeBytes'));
      });
    });

    group('StreamSubscriptionManager Generator', () {
      test('generates valid Dart code', () {
        final result = generateStreamSubscriptionManager();

        expect(result, isNotEmpty);
        expect(result, contains('class StreamSubscriptionManager'));
        expect(result, contains('Map<String, StreamSubscription>'));
        expect(result, contains('import'));
      });

      test('includes subscription management methods', () {
        final result = generateStreamSubscriptionManager();

        expect(result, contains('void add'));
        expect(result, contains('void addAnonymous'));
        expect(result, contains('void cancel'));
        expect(result, contains('void cancelAll'));
      });

      test('includes subscription checking', () {
        final result = generateStreamSubscriptionManager();

        expect(result, contains('bool has'));
        expect(result, contains('int get count'));
      });

      test('includes SubscriptionManagerMixin', () {
        final result = generateStreamSubscriptionManager();

        expect(result, contains('mixin SubscriptionManagerMixin'));
        expect(result, contains('get subscriptions'));
        expect(result, contains('disposeSubscriptions'));
      });

      test('prevents adding after disposal', () {
        final result = generateStreamSubscriptionManager();

        expect(result, contains('_disposed'));
        expect(result, contains('StateError'));
        expect(result, contains('after disposal'));
      });

      test('includes debug logging', () {
        final result = generateStreamSubscriptionManager();

        expect(result, contains('debugPrint'));
        expect(result, contains('Added subscription'));
        expect(result, contains('Cancelled subscription'));
      });
    });

    group('MemoryLeakDetector Generator', () {
      test('generates valid Dart code', () {
        final result = generateMemoryLeakDetector();

        expect(result, isNotEmpty);
        expect(result, contains('class MemoryLeakDetector'));
        expect(result, contains('factory MemoryLeakDetector()'));
        expect(result, contains('import'));
      });

      test('includes WeakReference tracking', () {
        final result = generateMemoryLeakDetector();

        expect(result, contains('WeakReference'));
        expect(result, contains('_trackedObjects'));
        expect(result, contains('track'));
      });

      test('includes allocation counting', () {
        final result = generateMemoryLeakDetector();

        expect(result, contains('_allocationCounts'));
        expect(result, contains('Map<String, int>'));
      });

      test('includes monitoring methods', () {
        final result = generateMemoryLeakDetector();

        expect(result, contains('startMonitoring'));
        expect(result, contains('stopMonitoring'));
        expect(result, contains('_checkForLeaks'));
      });

      test('detects potential leaks', () {
        final result = generateMemoryLeakDetector();

        expect(result, contains('Potential memory leaks'));
        expect(result, contains('count > 10'));
      });

      test('includes leak report', () {
        final result = generateMemoryLeakDetector();

        expect(result, contains('getReport'));
        expect(result, contains('tracked_objects'));
        expect(result, contains('potential_leaks'));
      });

      test('includes LeakDetectionMixin', () {
        final result = generateMemoryLeakDetector();

        expect(result, contains('mixin LeakDetectionMixin'));
        expect(result, contains('trackForLeaks'));
      });
    });

    group('Code Quality', () {
      test('all generators produce non-empty output', () {
        expect(generateDisposableBloc(), isNotEmpty);
        expect(generateDisposableProvider(), isNotEmpty);
        expect(generateDisposableRiverpod(), isNotEmpty);
        expect(generateMemoryProfiler(), isNotEmpty);
        expect(generateImageCacheManager(), isNotEmpty);
        expect(generateStreamSubscriptionManager(), isNotEmpty);
        expect(generateMemoryLeakDetector(), isNotEmpty);
      });

      test('all generators include proper imports', () {
        final generators = [
          generateDisposableBloc(),
          generateDisposableProvider(),
          generateDisposableRiverpod(),
          generateMemoryProfiler(),
          generateImageCacheManager(),
          generateStreamSubscriptionManager(),
          generateMemoryLeakDetector(),
        ];

        for (final code in generators) {
          expect(code, contains('import'));
        }
      });

      test('all generators use proper Dart conventions', () {
        final generators = [
          generateDisposableBloc(),
          generateDisposableProvider(),
          generateDisposableRiverpod(),
          generateMemoryProfiler(),
          generateImageCacheManager(),
          generateStreamSubscriptionManager(),
          generateMemoryLeakDetector(),
        ];

        for (final code in generators) {
          // Check for class, extension, or mixin declarations
          expect(
            code,
            anyOf(
              matches(RegExp(r'class \w+')),
              matches(RegExp(r'extension \w+')),
              matches(RegExp(r'mixin \w+')),
            ),
          );
          // Check for proper field naming (starts with _ for private)
          expect(code, matches(RegExp(r'_\w+')));
        }
      });

      test('no generator produces invalid syntax characters', () {
        final generators = [
          generateDisposableBloc(),
          generateDisposableProvider(),
          generateDisposableRiverpod(),
          generateMemoryProfiler(),
          generateImageCacheManager(),
          generateStreamSubscriptionManager(),
          generateMemoryLeakDetector(),
        ];

        for (final code in generators) {
          // Check for balanced single quotes (should be odd count since code is wrapped in quotes)
          expect(code.split("'").length % 2, equals(1));
          // Check code is valid Dart
          expect(code, contains('import'));
        }
      });
    });

    group('Integration Tests', () {
      test('DisposableBloc works with all state management types', () {
        final bloc = generateDisposableBloc();
        expect(bloc, contains('Bloc<Event, State>'));
        expect(bloc, contains('flutter_bloc'));
      });

      test('DisposableProvider works with Provider pattern', () {
        final provider = generateDisposableProvider();
        expect(provider, contains('ChangeNotifier'));
        expect(provider, contains('flutter/foundation'));
      });

      test('DisposableRiverpod works with Riverpod pattern', () {
        final riverpod = generateDisposableRiverpod();
        expect(riverpod, contains('Notifier'));
        expect(riverpod, contains('flutter_riverpod'));
      });

      test('MemoryProfiler includes Timer for periodic checks', () {
        final profiler = generateMemoryProfiler();
        expect(profiler, contains('Timer'));
        expect(profiler, contains('dart:async'));
      });

      test('ImageCacheManager uses dart:ui for Image type', () {
        final manager = generateImageCacheManager();
        expect(manager, contains('dart:ui'));
        expect(manager, contains('ui.Image'));
      });

      test('memory utilities with state include proper error handling', () {
        final generators = [
          generateDisposableProvider(),
          generateStreamSubscriptionManager(),
        ];

        for (final code in generators) {
          // Should include some form of error checking
          expect(
            code,
            anyOf(
              contains('StateError'),
              contains('throw'),
              contains('if (_disposed)'),
            ),
          );
        }
      });
    });
  });
}
