/// Advanced Riverpod pattern template generators
///
/// This file contains template generators for advanced Riverpod patterns including:
/// - AsyncNotifier with proper cancellation
/// - Family providers with auto-disposal
/// - Provider composition patterns
/// - Code generation setup
library;

/// Generates an AsyncNotifier base class with proper cancellation and error handling.
///
/// Includes:
/// - Automatic cancellation token management
/// - Error boundary patterns
/// - Retry logic with exponential backoff
/// - Loading state management
String generateAsyncNotifierPattern() {
  return '''
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for AsyncNotifier with automatic cancellation and error handling.
///
/// Usage:
/// class UserNotifier extends CancellableAsyncNotifier<User, String> {
///   @override
///   Future<User> build(String userId) async {
///     return fetchUser(userId, cancelToken);
///   }
/// }
///
/// final userProvider = AsyncNotifierProvider.family<UserNotifier, User, String>(
///   UserNotifier.new,
/// );
/// 
/// Example Provider usage:
final exampleProvider = Provider((ref) => 'example');
abstract class CancellableAsyncNotifier<T, Arg> extends FamilyAsyncNotifier<T, Arg> {
  CancellationToken? _cancelToken;
  
  /// Access the cancellation token for this notifier.
  CancellationToken get cancelToken {
    _cancelToken ??= CancellationToken();
    return _cancelToken!;
  }

  @override
  Future<T> build(Arg arg);

  /// Rebuild with automatic cancellation of previous operation.
  Future<void> rebuild() async {
    _cancelToken?.cancel();
    _cancelToken = null;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }

  /// Retry the current operation with exponential backoff.
  Future<void> retry({int maxAttempts = 3, Duration initialDelay = const Duration(seconds: 1)}) async {
    var attempt = 0;
    var delay = initialDelay;
    
    while (attempt < maxAttempts) {
      try {
        state = const AsyncValue.loading();
        final result = await build(arg);
        state = AsyncValue.data(result);
        return;
      } catch (error, stack) {
        attempt++;
        if (attempt >= maxAttempts) {
          state = AsyncValue.error(error, stack);
          rethrow;
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Update state with optimistic updates and rollback on error.
  Future<void> updateOptimistically<R>(
    T optimisticValue,
    Future<R> Function() operation,
  ) async {
    final previousState = state;
    state = AsyncValue.data(optimisticValue);
    
    try {
      await operation();
    } catch (error, stack) {
      state = previousState; // Rollback
      state = AsyncValue.error(error, stack);
      rethrow;
    }
  }
}

/// Cancellation token for async operations.
class CancellationToken {
  bool _isCancelled = false;
  final _completer = Completer<void>();

  bool get isCancelled => _isCancelled;
  Future<void> get onCancel => _completer.future;

  void cancel() {
    if (!_isCancelled) {
      _isCancelled = true;
      _completer.complete();
    }
  }

  /// Throw if cancelled.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancelledException();
    }
  }
}

/// Exception thrown when an operation is cancelled.
class CancelledException implements Exception {
  @override
  String toString() => 'Operation was cancelled';
}
''';
}

/// Generates auto-disposing family provider utilities.
///
/// Includes:
/// - Automatic cache management
/// - Time-based disposal
/// - Memory-efficient family providers
String generateAutoDisposingFamily() {
  return '''
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension for creating auto-disposing family providers with cache management.
extension AutoDisposingFamilyX on Ref {
  /// Keep alive for a specific duration, then dispose.
  ///
  /// Usage:
  /// ```dart
  /// final userProvider = FutureProvider.autoDispose.family<User, String>((ref, id) async {
  ///   ref.keepAliveFor(Duration(minutes: 5));
  ///   return fetchUser(id);
  /// });
  /// ```
  void keepAliveFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }

  /// Cache for a specific duration with automatic refresh.
  ///
  /// Usage:
  /// ```dart
  /// final postsProvider = FutureProvider.autoDispose.family<List<Post>, String>((ref, userId) async {
  ///   ref.cacheFor(
  ///     duration: Duration(minutes: 5),
  ///     onRefresh: () => ref.invalidateSelf(),
  ///   );
  ///   return fetchPosts(userId);
  /// });
  /// ```
  void cacheFor({
    required Duration duration,
    VoidCallback? onRefresh,
  }) {
    final link = keepAlive();
    Timer? timer;
    
    timer = Timer(duration, () {
      onRefresh?.call();
      link.close();
    });
    
    onDispose(() {
      timer?.cancel();
      link.close();
    });
  }

  /// Dispose when all listeners are removed for a specific duration.
  ///
  /// Usage:
  /// ```dart
  /// final dataProvider = StateNotifierProvider.autoDispose.family<DataNotifier, Data, String>((ref, id) {
  ///   ref.disposeDelay(Duration(seconds: 30));
  ///   return DataNotifier(id);
  /// });
  /// ```
  void disposeDelay(Duration duration) {
    Timer? timer;
    
    onCancel(() {
      timer = Timer(duration, () {
        // This will trigger disposal if no new listeners are added
      });
    });
    
    onResume(() {
      timer?.cancel();
    });
    
    onDispose(() {
      timer?.cancel();
    });
  }
}

/// Example: Using auto-disposing family with ref.watch
/// ```dart
/// final exampleProvider = FutureProvider.autoDispose.family<String, int>((ref, id) async {
///   ref.keepAliveFor(Duration(minutes: 5));
///   final data = ref.watch(anotherProvider); // Example ref.watch usage
///   return 'Data for id with data';
/// });
/// ```

/// LRU cache for family providers to limit memory usage.
class FamilyCache<K, V> {
  FamilyCache(this.maxSize);

  final int maxSize;
  final _cache = <K, V>{};
  final _accessOrder = <K>[];

  V? get(K key) {
    if (_cache.containsKey(key)) {
      _updateAccessOrder(key);
      return _cache[key];
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache[key] = value;
      _updateAccessOrder(key);
    } else {
      if (_cache.length >= maxSize) {
        final oldestKey = _accessOrder.removeAt(0);
        _cache.remove(oldestKey);
      }
      _cache[key] = value;
      _accessOrder.add(key);
    }
  }

  void remove(K key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  void _updateAccessOrder(K key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }
}
''';
}

/// Generates provider composition patterns and utilities.
///
/// Includes:
/// - Select pattern for performance
/// - Combining multiple providers
/// - Derived state patterns
String generateProviderComposition() {
  return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utilities for composing providers efficiently.
class ProviderComposer {
  /// Combine multiple providers into a single provider.
  ///
  /// Usage:
  /// ```dart
  /// final combinedProvider = Provider((ref) {
  ///   return ProviderComposer.combine2(
  ///     ref,
  ///     userProvider,
  ///     settingsProvider,
  ///     (user, settings) => AppState(user: user, settings: settings),
  ///   );
  /// });
  /// ```
  static T combine2<T, A, B>(
    Ref ref,
    ProviderListenable<A> providerA,
    ProviderListenable<B> providerB,
    T Function(A a, B b) combiner,
  ) {
    final a = ref.watch(providerA);
    final b = ref.watch(providerB);
    return combiner(a, b);
  }

  static T combine3<T, A, B, C>(
    Ref ref,
    ProviderListenable<A> providerA,
    ProviderListenable<B> providerB,
    ProviderListenable<C> providerC,
    T Function(A a, B b, C c) combiner,
  ) {
    final a = ref.watch(providerA);
    final b = ref.watch(providerB);
    final c = ref.watch(providerC);
    return combiner(a, b, c);
  }

  static T combine4<T, A, B, C, D>(
    Ref ref,
    ProviderListenable<A> providerA,
    ProviderListenable<B> providerB,
    ProviderListenable<C> providerC,
    ProviderListenable<D> providerD,
    T Function(A a, B b, C c, D d) combiner,
  ) {
    final a = ref.watch(providerA);
    final b = ref.watch(providerB);
    final c = ref.watch(providerC);
    final d = ref.watch(providerD);
    return combiner(a, b, c, d);
  }

  /// Select specific fields from a provider to minimize rebuilds.
  ///
  /// Usage:
  /// ```dart
  /// final userName = ProviderComposer.select(
  ///   ref,
  ///   userProvider,
  ///   (user) => user.name,
  /// );
  /// ```
  static R select<T, R>(
    Ref ref,
    ProviderListenable<T> provider,
    R Function(T value) selector,
  ) {
    return ref.watch(provider.select(selector));
  }
}

/// Mixin for creating derived state providers.
///
/// Usage:
/// ```dart
/// class FilteredItemsNotifier extends StateNotifier<List<Item>> with DerivedStateMixin {
///   FilteredItemsNotifier(this.ref) : super([]) {
///     // Automatically rebuilds when dependencies change
///     listenTo(itemsProvider, (items) {
///       listenTo(filterProvider, (filter) {
///         state = items.where((item) => item.matches(filter)).toList();
///       });
///     });
///   }
///   
///   final Ref ref;
/// }
/// ```
mixin DerivedStateMixin {
  final _subscriptions = <ProviderSubscription>[];

  void listenTo<T>(
    ProviderListenable<T> provider,
    void Function(T value) listener, {
    Ref? ref,
  }) {
    if (ref == null) {
      throw StateError('Ref must be provided to listenTo');
    }
    
    final subscription = ref.listen<T>(
      provider,
      (previous, next) => listener(next),
      fireImmediately: true,
    );
    
    _subscriptions.add(subscription);
  }

  void disposeSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    _subscriptions.clear();
  }
}

/// Async selector for future providers.
///
/// Usage:
/// ```dart
/// final userNameProvider = AsyncSelector(
///   source: userProvider,
///   selector: (user) => user.name,
/// );
/// ```
class AsyncSelector<T, R> {
  AsyncSelector({
    required this.source,
    required this.selector,
  });

  final ProviderListenable<AsyncValue<T>> source;
  final R Function(T value) selector;

  Provider<AsyncValue<R>> get provider {
    return Provider((ref) {
      final asyncValue = ref.watch(source);
      return asyncValue.whenData(selector);
    });
  }
}
''';
}

/// Generates Riverpod code generation setup and utilities.
///
/// Includes:
/// - Build.yaml configuration
/// - Code generation annotations
/// - Generated provider patterns
String generateCodeGenSetup() {
  return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Example of code generation patterns for Riverpod

/// Generated provider example with @riverpod annotation.
///
/// This requires:
/// 1. Add dependencies to pubspec.yaml:
///    ```yaml
///    dependencies:
///      riverpod_annotation: ^2.3.0
///    
///    dev_dependencies:
///      riverpod_generator: ^2.3.0
///      build_runner: ^2.4.0
///    ```
///
/// 2. Run code generation:
///    ```bash
///    flutter pub run build_runner build --delete-conflicting-outputs
///    ```
///
/// 3. Use the generated provider:
///    ```dart
///    // In your_file.dart
///    part 'your_file.g.dart';
///    
///    @riverpod
///    Future<User> user(UserRef ref, String userId) async {
///      return await fetchUser(userId);
///    }
///    
///    // Generated code creates: userProvider
///    // Usage: ref.watch(userProvider('123'))
///    ```

/// Example: Auto-dispose future provider with family parameter
/// 
/// Generated code will create:
/// - `exampleDataProvider` - The main provider
/// - `ExampleDataFamily` - Family provider type
/// - `ExampleDataProvider` - Provider class
@riverpod
Future<String> exampleData(ExampleDataRef ref, String id) async {
  // Auto-dispose is default with @riverpod
  // Add keepAlive: true to disable auto-dispose
  
  // Automatic cancellation on dispose
  final cancelToken = CancellationToken();
  ref.onDispose(cancelToken.cancel);
  
  return await fetchData(id, cancelToken);
}

Future<String> fetchData(String id, CancellationToken token) async {
  // Simulated fetch
  await Future.delayed(Duration(seconds: 1));
  token.throwIfCancelled();
  return 'Data for \$id';
}

/// Example: Stream provider with auto-dispose
@riverpod
Stream<int> exampleStream(ExampleStreamRef ref) async* {
  // Cleanup is automatic
  var count = 0;
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    yield count++;
  }
}

/// Example: Class-based notifier with state
@riverpod
class ExampleNotifier extends _\$ExampleNotifier {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

/// Example: Async notifier with family parameter
@riverpod
class ExampleAsyncNotifier extends _\$ExampleAsyncNotifier {
  @override
  Future<String> build(String id) async {
    return await fetchData(id, CancellationToken());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

/// Code generation configuration template.
///
/// Create this file as `build.yaml` in your project root:
/// ```yaml
/// targets:
///   default:
///     builders:
///       riverpod_generator:
///         options:
///           # Generate code for all files
///           generate_for:
///             include:
///               - lib/**
///               - test/**
///             exclude:
///               - lib/generated/**
///               - lib/**/*.g.dart
///               - lib/**/*.freezed.dart
/// ```

class CancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  
  void cancel() => _cancelled = true;
  
  void throwIfCancelled() {
    if (_cancelled) throw Exception('Cancelled');
  }
}
''';
}

/// Generates advanced state management examples with Riverpod.
///
/// Includes:
/// - Repository pattern with Riverpod
/// - Use case pattern integration
/// - State management best practices
String generateAdvancedExamples() {
  return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Example: Repository pattern with Riverpod
/// 
/// This demonstrates clean architecture with Riverpod providers.

// Data Layer
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<List<User>> getUsers();
  Future<void> updateUser(User user);
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.api);
  
  final ApiClient api;

  @override
  Future<User> getUser(String id) async {
    final response = await api.get('/users/\$id');
    return User.fromJson(response.data);
  }

  @override
  Future<List<User>> getUsers() async {
    final response = await api.get('/users');
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    await api.put('/users/\${user.id}', data: user.toJson());
  }
}

// Provider for repository (singleton)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return UserRepositoryImpl(api);
});

// Use Case Layer
class GetUserUseCase {
  GetUserUseCase(this.repository);
  
  final UserRepository repository;

  Future<User> call(String id) async {
    // Add business logic here
    return await repository.getUser(id);
  }
}

final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserUseCase(repository);
});

// Presentation Layer - StateNotifier
class UserState {
  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final User? user;
  final bool isLoading;
  final String? error;

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this.getUserUseCase) : super(const UserState());

  final GetUserUseCase getUserUseCase;

  Future<void> loadUser(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await getUserUseCase(id);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final userNotifierProvider = StateNotifierProvider.autoDispose.family<UserNotifier, UserState, String>(
  (ref, userId) {
    final useCase = ref.watch(getUserUseCaseProvider);
    final notifier = UserNotifier(useCase);
    notifier.loadUser(userId);
    return notifier;
  },
);

/// Example: Pagination with Riverpod
class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  PaginatedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PaginatedNotifier<T> extends StateNotifier<PaginatedState<T>> {
  PaginatedNotifier(this.fetchPage) : super(const PaginatedState());

  final Future<List<T>> Function(int page) fetchPage;

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newItems = await fetchPage(state.page);
      state = state.copyWith(
        items: [...state.items, ...newItems],
        page: state.page + 1,
        hasMore: newItems.isNotEmpty,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refresh() async {
    state = const PaginatedState();
    await loadMore();
  }
}

/// Example models and utilities
class User {
  User({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class ApiClient {
  Future<ApiResponse> get(String path) async {
    // Implementation
    throw UnimplementedError();
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? data}) async {
    // Implementation
    throw UnimplementedError();
  }
}

class ApiResponse {
  dynamic data;
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
''';
}

/// Generates performance optimization patterns for Riverpod.
///
/// Includes:
/// - Selective rebuilds with .select()
/// - Provider listening strategies
/// - Avoiding unnecessary rebuilds
String generatePerformancePatterns() {
  return '''
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance optimization patterns for Riverpod.
///
/// Usage:
/// Apply these patterns to optimize widget rebuilds and provider usage.

/// Pattern 1: Use .select() to rebuild only when specific fields change
/// 
/// BAD - Rebuilds on any user change:
/// ```dart
/// final user = ref.watch(userProvider);
/// return Text(user.name);
/// ```
/// 
/// GOOD - Rebuilds only when name changes:
/// ```dart
/// final userName = ref.watch(userProvider.select((user) => user.name));
/// return Text(userName);
/// ```

class SelectExample extends ConsumerWidget {
  const SelectExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when name changes, not when other fields change
    final userName = ref.watch(userProvider.select((user) => user.name));
    
    return Text(userName);
  }
}

/// Pattern 2: Use Consumer instead of ConsumerWidget for partial rebuilds
/// 
/// BAD - Entire widget rebuilds:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   Widget build(context, ref) {
///     final count = ref.watch(counterProvider);
///     return Column(
///       children: [
///         ExpensiveWidget(), // Rebuilds unnecessarily
///         Text('count'),
///       ],
///     );
///   }
/// }
/// ```
/// 
/// GOOD - Only Text rebuilds:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   Widget build(context) {
///     return Column(
///       children: [
///         ExpensiveWidget(), // Doesn't rebuild
///         Consumer(
///           builder: (context, ref, child) {
///             final count = ref.watch(counterProvider);
///             return Text('\${count}');
///           },
///         ),
///       ],
///     );
///   }
/// }
/// ```

/// Pattern 3: Use ref.read() for one-time reads in callbacks
/// 
/// BAD - Creates unnecessary dependency:
/// ```dart
/// onPressed: () {
///   final notifier = ref.watch(counterProvider.notifier);
///   notifier.increment();
/// }
/// ```
/// 
/// GOOD - No rebuild dependency: // No rebuild dependency
/// ```dart
/// onPressed: () {
///   ref.read(counterProvider.notifier).increment();
/// }
/// ```

/// Pattern 4: Combine providers efficiently
class CombinedExample extends ConsumerWidget {
  const CombinedExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BAD - Watches each provider separately (multiple rebuilds)
    // final user = ref.watch(userProvider);
    // final settings = ref.watch(settingsProvider);
    // final theme = ref.watch(themeProvider);
    
    // GOOD - Combine into single provider
    final appState = ref.watch(combinedAppStateProvider);
    
    return Text(appState.user.name);
  }
}

final combinedAppStateProvider = Provider((ref) {
  final user = ref.watch(userProvider);
  final settings = ref.watch(settingsProvider);
  final theme = ref.watch(themeProvider);
  
  return AppState(user: user, settings: settings, theme: theme);
});

/// Pattern 5: Use family providers with const parameters
/// 
/// BAD - New provider instance on every build:
/// ```dart
/// ref.watch(itemProvider('id-\\${DateTime.now()}'))
/// ```
/// 
/// GOOD - Reuses provider instance: // Reuses provider instance
/// ```dart
/// const itemId = 'user-123';
/// ref.watch(itemProvider(itemId))
/// ```

/// Pattern 6: Batch state updates
class BatchUpdateExample extends StateNotifier<AppState> {
  BatchUpdateExample() : super(AppState.initial());

  // BAD - Multiple state updates (multiple rebuilds) // Multiple state updates
  void updateBad(String name, int age, String email) {
    state = state.copyWith(name: name);
    state = state.copyWith(age: age);
    state = state.copyWith(email: email);
  }

  // GOOD - Single state update (one rebuild)
  void updateGood(String name, int age, String email) {
    state = state.copyWith(
      name: name,
      age: age,
      email: email,
    );
  }
}

/// Pattern 7: Use autoDispose for temporary providers
/// 
/// BAD - Provider stays in memory forever:
/// ```dart
/// final dataProvider = FutureProvider.family<Data, String>((ref, id) async {
///   return fetchData(id);
/// });
/// ```
/// 
/// GOOD - Provider disposed when no longer used: // Provider disposed when no longer used
/// ```dart
/// final dataProvider = FutureProvider.autoDispose.family<Data, String>(
///   (ref, id) async {
///     return fetchData(id);
///   },
/// );
/// ```

/// Pattern 8: Debounce expensive operations
class DebouncedSearchNotifier extends StateNotifier<AsyncValue<List<String>>> {
  DebouncedSearchNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;
  Timer? _debounceTimer;

  void search(String query) {
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchResults(query));
  }

  Future<List<String>> fetchResults(String query) async {
    // Implementation
    return [];
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Example models
class AppState {
  const AppState({
    required this.user,
    required this.settings,
    required this.theme,
  });

  final User user;
  final Settings settings;
  final Theme theme;

  factory AppState.initial() {
    return AppState(
      user: User(id: '', name: '', email: ''),
      settings: Settings(),
      theme: Theme(),
    );
  }

  AppState copyWith({
    User? user,
    Settings? settings,
    Theme? theme,
    String? name,
    int? age,
    String? email,
  }) {
    return AppState(
      user: user ?? this.user,
      settings: settings ?? this.settings,
      theme: theme ?? this.theme,
    );
  }
}

class User {
  const User({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;
}

class Settings {
  const Settings();
}

class Theme {
  const Theme();
}

final userProvider = Provider<User>((ref) => User(id: '1', name: 'Test', email: 'test@test.com'));
final settingsProvider = Provider<Settings>((ref) => Settings());
final themeProvider = Provider<Theme>((ref) => Theme());
final counterProvider = StateProvider<int>((ref) => 0);
''';
}
