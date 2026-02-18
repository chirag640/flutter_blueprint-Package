/// Simple service locator for dependency injection.
///
/// Provides a lightweight DI container that replaces hard-coded
/// constructor dependencies throughout the codebase. Services are
/// lazily instantiated and shared as singletons.
///
/// Usage:
/// ```dart
/// // Register during app startup
/// ServiceLocator.instance
///   ..register<Logger>(() => Logger())
///   ..register<InteractivePrompter>(() => InteractivePrompter());
///
/// // Resolve anywhere
/// final logger = ServiceLocator.instance.get<Logger>();
/// ```
library;

/// A minimal service locator for managing shared dependencies.
///
/// Thread-safe, supports lazy singletons and factory registrations.
class ServiceLocator {
  ServiceLocator._();

  /// The global singleton instance.
  static final ServiceLocator instance = ServiceLocator._();

  /// Factory for creating a fresh instance (primarily for testing).
  factory ServiceLocator.forTesting() => ServiceLocator._();

  final Map<Type, _Registration> _registrations = {};

  /// Registers a lazy singleton. The factory is called once on first access.
  void register<T extends Object>(T Function() factory) {
    _registrations[T] = _Registration.lazySingleton(factory);
  }

  /// Registers a pre-built instance as a singleton.
  void registerInstance<T extends Object>(T instance) {
    _registrations[T] = _Registration.instance(instance);
  }

  /// Registers a factory that creates a new instance on every access.
  void registerFactory<T extends Object>(T Function() factory) {
    _registrations[T] = _Registration.factory(factory);
  }

  /// Resolves a service by type. Throws if not registered.
  T get<T extends Object>() {
    final registration = _registrations[T];
    if (registration == null) {
      throw StateError(
        'Service $T is not registered. '
        'Call ServiceLocator.instance.register<$T>(...) first.',
      );
    }
    return registration.resolve() as T;
  }

  /// Resolves a service by type, or returns null if not registered.
  T? tryGet<T extends Object>() {
    final registration = _registrations[T];
    return registration?.resolve() as T?;
  }

  /// Whether a service of type [T] is registered.
  bool isRegistered<T extends Object>() => _registrations.containsKey(T);

  /// Unregisters a service. Useful for testing.
  void unregister<T extends Object>() {
    _registrations.remove(T);
  }

  /// Clears all registrations. Useful for testing.
  void reset() {
    _registrations.clear();
  }
}

/// Internal registration holder supporting multiple lifecycle types.
class _Registration {
  _Registration.lazySingleton(this._factory) : _type = _RegType.lazySingleton;
  _Registration.instance(Object instance)
      : _factory = (() => instance),
        _type = _RegType.instance,
        _instance = instance;
  _Registration.factory(this._factory) : _type = _RegType.factory;

  final Object Function() _factory;
  final _RegType _type;
  Object? _instance;

  Object resolve() {
    switch (_type) {
      case _RegType.instance:
        return _instance!;
      case _RegType.lazySingleton:
        return _instance ??= _factory();
      case _RegType.factory:
        return _factory();
    }
  }
}

enum _RegType { instance, lazySingleton, factory }
