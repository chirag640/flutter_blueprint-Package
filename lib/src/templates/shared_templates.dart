import '../config/blueprint_config.dart';

/// Shared template utilities used across all state management templates
/// This reduces code duplication and ensures consistency

// ============================================================================
// API CONFIGURATION GENERATOR
// ============================================================================

/// Generates the api_config.dart file with user's configuration
String generateApiConfig(BlueprintConfig config) {
  final api = config.apiConfig;

  return """/// API Configuration for this project.
/// 
/// This file is generated based on your backend settings.
/// Modify these values to match your API's response structure.

/// Where to extract the authentication token from
enum TokenSource {
  /// Token is in the response body (e.g., { "data": { "accessToken": "..." } })
  body,
  
  /// Token is in a response header (e.g., header 'token: xyz123')
  header,
}

/// Configuration for API communication
class ApiConfig {
  const ApiConfig({
    this.successKey = '${api.successKey}',
    this.successValue = ${api.successValue is String ? "'${api.successValue}'" : api.successValue},
    this.dataKey = '${api.dataKey}',
    this.nestedDataPath = ${api.nestedDataPath != null ? "'${api.nestedDataPath}'" : 'null'},
    this.errorMessagePath = '${api.errorMessagePath}',
    this.errorCodePath = '${api.errorCodePath}',
    this.tokenSource = TokenSource.${api.tokenSource.name},
    this.accessTokenPath = '${api.accessTokenPath}',
    this.refreshTokenPath = ${api.refreshTokenPath != null ? "'${api.refreshTokenPath}'" : 'null'},
    this.authHeaderName = '${api.authHeaderName}',
    this.authHeaderPrefix = '${api.authHeaderPrefix}',
  });

  // ===== Response Parsing =====
  final String successKey;
  final dynamic successValue;
  final String dataKey;
  final String? nestedDataPath;

  // ===== Error Handling =====
  final String errorMessagePath;
  final String errorCodePath;

  // ===== Token Extraction =====
  final TokenSource tokenSource;
  final String accessTokenPath;
  final String? refreshTokenPath;

  // ===== Token Sending =====
  final String authHeaderName;
  final String authHeaderPrefix;

  /// Extract value from a nested path like 'data.user.token'
  dynamic extractPath(Map<String, dynamic> json, String path) {
    if (path.isEmpty) return json;
    
    final keys = path.split('.');
    dynamic current = json;
    
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  /// Check if response indicates success
  bool isSuccess(Map<String, dynamic> response) {
    if (successKey.isEmpty) return true; // No success key = always success
    final value = extractPath(response, successKey);
    return value == successValue;
  }

  /// Extract the data payload from response
  dynamic getData(Map<String, dynamic> response) {
    final path = nestedDataPath ?? dataKey;
    if (path.isEmpty) return response;
    return extractPath(response, path);
  }

  /// Extract error message from response
  String? getErrorMessage(Map<String, dynamic> response) {
    return extractPath(response, errorMessagePath)?.toString();
  }

  /// Extract error code from response
  String? getErrorCode(Map<String, dynamic> response) {
    return extractPath(response, errorCodePath)?.toString();
  }
}

/// Default configuration instance
const apiConfig = ApiConfig();
""";
}

// ============================================================================
// UNIFIED RESPONSE INTERCEPTOR
// ============================================================================

/// Generates the unified_response_interceptor.dart file
String generateUnifiedResponseInterceptor(BlueprintConfig config) {
  return """import 'package:dio/dio.dart';
import '../api_config.dart';

/// API Error to be thrown when business logic fails
class ApiError implements Exception {
  const ApiError({required this.message, this.code});
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'ApiError: \$message (code: \$code)';
}

/// Unified response interceptor that normalizes API responses.
/// 
/// This interceptor:
/// 1. Checks for business logic success using configured keys
/// 2. Extracts the data payload from configured path
/// 3. Converts business errors to DioException for consistent handling
class UnifiedResponseInterceptor extends Interceptor {
  UnifiedResponseInterceptor(this._config);
  
  final ApiConfig _config;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only handle JSON responses
    if (response.data is! Map<String, dynamic>) {
      return handler.next(response);
    }
    
    final data = response.data as Map<String, dynamic>;
    
    // Check business logic success
    if (_config.isSuccess(data)) {
      // Flatten data: Repository will receive the actual payload directly
      response.data = _config.getData(data);
      handler.next(response);
    } else {
      // Convert business error to DioException so it's caught by repositories
      final message = _config.getErrorMessage(data) ?? 'Operation failed';
      final code = _config.getErrorCode(data);
      
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: ApiError(message: message, code: code),
        ),
      );
    }
  }
}
""";
}

// ============================================================================
// IMPROVED RETRY INTERCEPTOR WITH EXPONENTIAL BACKOFF + JITTER
// ============================================================================

String generateImprovedRetryInterceptor(BlueprintConfig config) {
  return """import 'dart:math' as math;
import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Enhanced retry interceptor with exponential backoff and jitter
/// Implements industry-standard retry logic to prevent retry storms
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  
  // Track retries per request to avoid global state issues
  final Map<RequestOptions, int> _retryMap = {};
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final retryCount = _retryMap[requestOptions] ?? 0;
    
    if (_shouldRetry(err) && retryCount < maxRetries) {
      _retryMap[requestOptions] = retryCount + 1;
      
      AppLogger.warning(
        'Retrying request: \${requestOptions.path} (attempt \${retryCount + 1}/\$maxRetries)',
        'RetryInterceptor',
      );
      
      try {
        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(retryCount);
        await Future.delayed(delay);
        
        // Attempt the request again
        final response = await Dio().fetch(requestOptions);
        
        // Success - clean up tracking and resolve
        _retryMap.remove(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If this was the last retry, clean up and pass the error
        if (retryCount + 1 >= maxRetries) {
          _retryMap.remove(requestOptions);
        }
        return handler.next(err);
      }
    }
    
    // No retry needed or max retries exceeded
    _retryMap.remove(requestOptions);
    return handler.next(err);
  }
  
  /// Calculate delay using exponential backoff with jitter
  /// Formula: min(maxDelay, baseDelay * (2 ^ retryCount)) + randomJitter
  Duration _calculateDelay(int retryCount) {
    final exponentialDelay = baseDelay.inMilliseconds * math.pow(2, retryCount);
    final cappedDelay = math.min(exponentialDelay.toDouble(), maxDelay.inMilliseconds.toDouble());
    
    // Add jitter: random value between 0 and 20% of the delay
    final jitter = math.Random().nextDouble() * 0.2 * cappedDelay;
    
    return Duration(milliseconds: (cappedDelay + jitter).toInt());
  }
  
  /// Determine if the error should trigger a retry
  bool _shouldRetry(DioException err) {
    // Retry on timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    
    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return true;
    }
    
    // Retry on 5xx server errors (transient issues)
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }
    
    // Retry on specific 429 (rate limit) with proper backoff
    if (statusCode == 429) {
      return true;
    }
    
    // Don't retry 4xx client errors (except 429)
    return false;
  }
  
  /// Clean up tracking for a specific request
  void clearRetryTracking(RequestOptions options) {
    _retryMap.remove(options);
  }
  
  /// Clear all retry tracking (useful for testing)
  void clearAllRetryTracking() {
    _retryMap.clear();
  }
}
""";
}

// ============================================================================
// ENHANCED AUTH INTERCEPTOR WITH TOKEN REFRESH
// ============================================================================

String generateEnhancedAuthInterceptor(BlueprintConfig config) {
  return """import 'dart:async';
import 'package:dio/dio.dart';

import '../../storage/local_storage.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';

/// Authentication interceptor with token refresh capability.
/// 
/// Automatically attaches JWT tokens to requests and handles
/// 401 responses by refreshing the token and retrying.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  
  final LocalStorage _storage;
  // Queue to hold requests during token refresh
  final List<_RequestQueueItem> _requestQueue = [];
  bool _isRefreshing = false;
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for refresh token endpoint
    if (options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }
    
    final token = _storage.getString(AppConstants.keyAccessToken);
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer \$token';
      AppLogger.debug('Added auth token to request: \${options.path}', 'AuthInterceptor');
    }
    
    handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Unauthorized error - attempting token refresh', 'AuthInterceptor');
      
      // If already refreshing, queue this request
      if (_isRefreshing) {
        final completer = Completer<Response>();
        _requestQueue.add(_RequestQueueItem(err.requestOptions, completer));
        
        try {
          final response = await completer.future;
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
      
      _isRefreshing = true;
      
      try {
        final newToken = await _refreshToken();
        
        if (newToken != null) {
          // Retry with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer \$newToken';
          
          final response = await Dio().fetch(options);
          _processQueuedRequests(newToken);
          
          return handler.resolve(response);
        } else {
          _rejectQueuedRequests(err);
          return handler.next(err);
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', e, null, 'AuthInterceptor');
        _rejectQueuedRequests(err);
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }
    
    handler.next(err);
  }
  
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = _storage.getString(AppConstants.keyRefreshToken);
      
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.warning('No refresh token available', 'AuthInterceptor');
        return null;
      }
      
      final dio = Dio();
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>?;
        final newAccessToken = data?['access_token']?.toString();
        final newRefreshToken = data?['refresh_token']?.toString();
        
        if (newAccessToken != null) {
          await _storage.setString(AppConstants.keyAccessToken, newAccessToken);
          
          if (newRefreshToken != null) {
            await _storage.setString(AppConstants.keyRefreshToken, newRefreshToken);
          }
          
          AppLogger.info('Token refreshed successfully', 'AuthInterceptor');
          return newAccessToken;
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Token refresh error', e, null, 'AuthInterceptor');
      
      await _storage.remove(AppConstants.keyAccessToken);
      await _storage.remove(AppConstants.keyRefreshToken);
      
      return null;
    }
  }
  
  void _processQueuedRequests(String newToken) async {
    for (final item in _requestQueue) {
      try {
        item.options.headers['Authorization'] = 'Bearer \$newToken';
        final response = await Dio().fetch(item.options);
        item.completer.complete(response);
      } catch (e) {
        item.completer.completeError(e);
      }
    }
    _requestQueue.clear();
  }
  
  void _rejectQueuedRequests(DioException error) {
    for (final item in _requestQueue) {
      item.completer.completeError(error);
    }
    _requestQueue.clear();
  }
}

class _RequestQueueItem {
  _RequestQueueItem(this.options, this.completer);
  
  final RequestOptions options;
  final Completer<Response> completer;
}
""";
}

// ============================================================================
// RESULT/EITHER PATTERN FOR TYPE-SAFE ERROR HANDLING
// ============================================================================

String generateResultPattern(BlueprintConfig config) {
  return """/// Type-safe result pattern for error handling
/// Inspired by functional programming's Either type
sealed class Result<T> {
  const Result();
  
  /// Transform the success value
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Success(transform(v)),
      Failure(error: final e) => Failure(e),
    };
  }
  
  /// Transform the error
  Result<T> mapError(Exception Function(Exception error) transform) {
    return switch (this) {
      Success(value: final v) => Success(v),
      Failure(error: final e) => Failure(transform(e)),
    };
  }
  
  /// Fold the result into a single value
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception error) onFailure,
  }) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(error: final e) => onFailure(e),
    };
  }
  
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is failure
  bool get isFailure => this is Failure<T>;
  
  /// Get value or null
  T? get valueOrNull => switch (this) {
    Success(value: final v) => v,
    Failure() => null,
  };
  
  /// Get error or null
  Exception? get errorOrNull => switch (this) {
    Success() => null,
    Failure(error: final e) => e,
  };
}

/// Success result
final class Success<T> extends Result<T> {
  const Success(this.value);
  
  final T value;
  
  @override
  String toString() => 'Success(\$value)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && value == other.value;
  
  @override
  int get hashCode => value.hashCode;
}

/// Failure result
final class Failure<T> extends Result<T> {
  const Failure(this.error);
  
  final Exception error;
  
  @override
  String toString() => 'Failure(\$error)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> && error == other.error;
  
  @override
  int get hashCode => error.hashCode;
}
""";
}

// ============================================================================
// ENHANCED EXCEPTION TYPES
// ============================================================================

String generateEnhancedExceptions(BlueprintConfig config) {
  return """/// Base exception for all app exceptions
abstract class AppException implements Exception {
  const AppException(this.message, [this.stackTrace]);
  
  final String message;
  final StackTrace? stackTrace;
  
  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
  
  factory NetworkException.noConnection() =>
      const NetworkException('No internet connection');
  
  factory NetworkException.timeout() =>
      const NetworkException('Request timed out');
  
  factory NetworkException.serverError(int statusCode) =>
      NetworkException('Server error: \$statusCode');
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.stackTrace]);
  
  factory AuthException.unauthorized() =>
      const AuthException('Unauthorized - please login again');
  
  factory AuthException.tokenExpired() =>
      const AuthException('Session expired - please login again');
  
  factory AuthException.invalidCredentials() =>
      const AuthException('Invalid credentials');
}

/// Data parsing exceptions
class DataException extends AppException {
  const DataException(super.message, [super.stackTrace]);
  
  factory DataException.parsing(String field) =>
      DataException('Failed to parse: \$field');
  
  factory DataException.validation(String field, String reason) =>
      DataException('Validation failed for \$field: \$reason');
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message, [super.stackTrace]);
  
  factory StorageException.read(String key) =>
      StorageException('Failed to read from storage: \$key');
  
  factory StorageException.write(String key) =>
      StorageException('Failed to write to storage: \$key');
}

/// Business logic exceptions
class BusinessException extends AppException {
  const BusinessException(super.message, [super.stackTrace]);
}
""";
}

// ============================================================================
// GETIT DEPENDENCY INJECTION SETUP
// ============================================================================

String generateGetItSetup(BlueprintConfig config) {
  return """import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../config/app_config.dart';

/// Global service locator
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupDependencies() async {
  // ========== Core Services (Singletons) ==========
  
  // Storage
  final localStorage = await LocalStorage.getInstance();
  getIt.registerSingleton<LocalStorage>(localStorage);
  
  getIt.registerSingleton<SecureStorage>(SecureStorage.instance);
  
  // Configuration
  final config = AppConfig.load();
  getIt.registerSingleton<AppConfig>(config);
  
  // ========== Network Services ==========
  
  // Dio instance
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    // Configure dio...
    return dio;
  });
  
  // API Client
  getIt.registerLazySingleton<ApiClient>(() {
    return ApiClient(getIt<AppConfig>());
  });
  
  // ========== Repositories (Singletons) ==========
  // Register your repositories here
  // Example:
  // getIt.registerLazySingleton<UserRepository>(
  //   () => UserRepository(getIt<ApiClient>()),
  // );
  
  // ========== Use Cases (Factories) ==========
  // Register use cases as factories (new instance each time)
  // Example:
  // getIt.registerFactory<LoginUseCase>(
  //   () => LoginUseCase(getIt<AuthRepository>()),
  // );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
""";
}

// ============================================================================
// STORAGE ENHANCEMENTS
// ============================================================================

String generateEnhancedLocalStorage(BlueprintConfig config) {
  return """import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced local storage with JSON serialization support
class LocalStorage {
  LocalStorage._();
  
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;
  
  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // ========== String operations ==========
  
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs!.getString(key);
  }
  
  // ========== JSON operations ==========
  
  /// Save any JSON-serializable object
  Future<bool> setJson<T>(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      return await setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  /// Read and parse JSON object
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// Save list of JSON objects
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = json.encode(value);
      return await setString(key, jsonString);
    } catch (e) {
      return false;
    }
  }
  
  /// Read list of JSON objects
  List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final decoded = json.decode(jsonString);
      return (decoded as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }
  
  // ========== Int operations ==========
  
  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs!.getInt(key);
  }
  
  // ========== Bool operations ==========
  
  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }
  
  // ========== Double operations ==========
  
  Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }
  
  double? getDouble(String key) {
    return _prefs!.getDouble(key);
  }
  
  // ========== List operations ==========
  
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }
  
  List<String>? getStringList(String key) {
    return _prefs!.getStringList(key);
  }
  
  // ========== Utility operations ==========
  
  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }
  
  Future<bool> clear() async {
    return await _prefs!.clear();
  }
  
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }
  
  Set<String> getKeys() {
    return _prefs!.getKeys();
  }
  
  /// Get approximate storage size in bytes (rough estimate)
  int getApproximateSize() {
    int totalSize = 0;
    for (final key in getKeys()) {
      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length * 2; // UTF-16 encoding
      } else if (value is int) {
        totalSize += 8;
      } else if (value is double) {
        totalSize += 8;
      } else if (value is bool) {
        totalSize += 1;
      } else if (value is List<String>) {
        for (final item in value) {
          totalSize += item.length * 2;
        }
      }
    }
    return totalSize;
  }
  
  /// Clean up old entries based on timestamp keys
  Future<void> cleanupOldEntries({
    required String prefix,
    required Duration maxAge,
  }) async {
    final now = DateTime.now();
    final keys = getKeys().where((k) => k.startsWith(prefix));
    
    for (final key in keys) {
      final timestamp = getInt('\${key}_timestamp');
      if (timestamp != null) {
        final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (now.difference(savedTime) > maxAge) {
          await remove(key);
          await remove('\${key}_timestamp');
        }
      }
    }
  }
}
""";
}
