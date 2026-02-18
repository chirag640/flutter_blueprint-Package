/// A Result type for safer error handling without exceptions.
///
/// Replaces try/catch patterns with explicit success/failure values,
/// making error states visible in method signatures.
///
/// Usage:
/// ```dart
/// Result<User, ConfigurationError> loadUser(String id) {
///   if (id.isEmpty) return Result.failure(ConfigurationError('Empty ID'));
///   return Result.success(User(id));
/// }
///
/// final result = loadUser('abc');
/// result.when(
///   success: (user) => print(user.name),
///   failure: (error) => print(error.message),
/// );
/// ```
library;

/// A discriminated union representing either a success [T] or failure [E].
///
/// This type forces callers to handle both success and failure cases,
/// eliminating unhandled exceptions and making error flows explicit.
sealed class Result<T, E> {
  const Result._();

  /// Creates a successful result containing [value].
  const factory Result.success(T value) = Success<T, E>;

  /// Creates a failed result containing [error].
  const factory Result.failure(E error) = Failure<T, E>;

  /// Whether this result is a success.
  bool get isSuccess;

  /// Whether this result is a failure.
  bool get isFailure => !isSuccess;

  /// Returns the success value or null.
  T? get valueOrNull;

  /// Returns the error or null.
  E? get errorOrNull;

  /// Returns the success value or throws the error.
  T get valueOrThrow;

  /// Pattern-matches on success or failure, returning a result of type [R].
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  });

  /// Maps the success value using [transform], leaving failures unchanged.
  Result<R, E> map<R>(R Function(T value) transform);

  /// Maps the error using [transform], leaving successes unchanged.
  Result<T, R> mapError<R>(R Function(E error) transform);

  /// Chains another operation that returns a Result.
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform);

  /// Returns the success value or computes a fallback from the error.
  T getOrElse(T Function(E error) orElse);
}

/// A successful result containing [value].
final class Success<T, E> extends Result<T, E> {
  const Success(this.value) : super._();

  /// The success value.
  final T value;

  @override
  bool get isSuccess => true;

  @override
  T? get valueOrNull => value;

  @override
  E? get errorOrNull => null;

  @override
  T get valueOrThrow => value;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) =>
      success(value);

  @override
  Result<R, E> map<R>(R Function(T value) transform) =>
      Result.success(transform(value));

  @override
  Result<T, R> mapError<R>(R Function(E error) transform) =>
      Result.success(value);

  @override
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      transform(value);

  @override
  T getOrElse(T Function(E error) orElse) => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T, E> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// A failed result containing [error].
final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error) : super._();

  /// The error value.
  final E error;

  @override
  bool get isSuccess => false;

  @override
  T? get valueOrNull => null;

  @override
  E? get errorOrNull => error;

  @override
  T get valueOrThrow => throw error is Exception
      ? error as Exception
      : Exception(error.toString());

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) =>
      failure(error);

  @override
  Result<R, E> map<R>(R Function(T value) transform) => Result.failure(error);

  @override
  Result<T, R> mapError<R>(R Function(E error) transform) =>
      Result.failure(transform(error));

  @override
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      Result.failure(error);

  @override
  T getOrElse(T Function(E error) orElse) => orElse(error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failure<T, E> && error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
