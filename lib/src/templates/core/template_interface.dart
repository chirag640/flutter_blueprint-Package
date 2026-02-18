/// Core template abstractions for the code generation system.
///
/// Replaces the unstructured template system (23 files with no interface)
/// with a composable, testable template architecture.
library;

import '../../config/blueprint_config.dart';

/// A generated file with path and content.
///
/// Replaces the old [TemplateFile] with a cleaner, immutable value type.
class GeneratedFile {
  const GeneratedFile({
    required this.path,
    required this.content,
    this.overwrite = true,
  });

  /// Relative path from the project root (e.g., 'lib/core/api_client.dart').
  final String path;

  /// The full file content.
  final String content;

  /// Whether to overwrite if the file already exists.
  final bool overwrite;

  @override
  String toString() => 'GeneratedFile($path, ${content.length} chars)';
}

/// Context passed to template renderers containing all generation parameters.
///
/// This replaces passing raw [BlueprintConfig] to every template method,
/// allowing templates to access only what they need.
class TemplateContext {
  const TemplateContext({
    required this.config,
    this.featureName,
    this.projectPath,
  });

  /// The full project configuration.
  final BlueprintConfig config;

  /// Name of the feature being generated (for feature templates).
  final String? featureName;

  /// Target project path.
  final String? projectPath;

  /// Convenience: The app name from config.
  String get appName => config.appName;

  /// Convenience: The state management from config.
  StateManagement get stateManagement => config.stateManagement;

  /// Convenience: Whether API is included.
  bool get includeApi => config.includeApi;
}

/// Interface for template renderers.
///
/// All templates implement this interface, providing a uniform contract
/// for rendering template files from a given context. This replaces the
/// inconsistent static method / instance method mix in the old templates.
///
/// ## Implementation Guidelines:
/// - Templates MUST be stateless - all inputs come from [TemplateContext].
/// - Templates SHOULD use [SharedComponents] for common code patterns.
/// - Templates MUST return deterministic output for the same input.
abstract class ITemplateRenderer {
  /// A human-readable name for this template (e.g., 'Provider Mobile').
  String get name;

  /// Short description of what this template generates.
  String get description;

  /// Renders all files for this template given the context.
  ///
  /// Returns a list of [GeneratedFile] instances ready to be written.
  List<GeneratedFile> render(TemplateContext context);
}

/// Registry for template renderers with factory lookup.
///
/// Enables discovering and instantiating templates by name or criteria,
/// replacing the hard-coded switch/case in BlueprintGenerator._selectBundle.
class TemplateRegistry {
  TemplateRegistry();

  final Map<String, ITemplateRenderer> _renderers = {};

  /// Registers a template renderer by name.
  void register(ITemplateRenderer renderer) {
    _renderers[renderer.name] = renderer;
  }

  /// Registers multiple renderers.
  void registerAll(List<ITemplateRenderer> renderers) {
    for (final renderer in renderers) {
      register(renderer);
    }
  }

  /// Looks up a renderer by name. Returns null if not found.
  ITemplateRenderer? get(String name) => _renderers[name];

  /// Returns all registered renderer names.
  List<String> get names => _renderers.keys.toList()..sort();

  /// Returns all registered renderers.
  Iterable<ITemplateRenderer> get all => _renderers.values;

  /// Selects the appropriate renderer based on configuration.
  ///
  /// Uses the platform and state management from config to determine
  /// which template to use.
  ITemplateRenderer? selectFor(BlueprintConfig config) {
    // Multi-platform gets universal template
    if (config.isMultiPlatform) {
      return _renderers['universal'];
    }

    // Single platform - compose key from platform + state management
    final platform = config.platforms.first.label;
    final state = config.stateManagement.label;
    final key = '${platform}_$state';

    return _renderers[key] ?? _renderers[platform];
  }
}

/// Library of shared template components.
///
/// Contains reusable code snippets that were previously duplicated
/// across 5+ template files (provider, riverpod, bloc, web, desktop).
class SharedComponents {
  const SharedComponents._();

  /// Generates the standard API service/client code.
  ///
  /// Previously duplicated in provider_mobile_template.dart,
  /// riverpod_mobile_template.dart, bloc_mobile_template.dart,
  /// web_template.dart, and desktop_template.dart.
  static String apiService(BlueprintConfig config) {
    final apiConfig = config.apiConfig;
    return '''
import 'package:dio/dio.dart';

/// API client for making HTTP requests.
///
/// Configured for: ${_apiPresetName(config)}
/// 
/// Usage:
/// ```dart
/// final client = ApiClient(
///   baseUrl: 'https://api.example.com',
///   getToken: () => secureStorage.read(key: 'auth_token'),
///   refreshToken: () => authService.refreshToken(),
/// );
/// ```
class ApiClient {
  ApiClient({
    String? baseUrl,
    Future<String?> Function()? getToken,
    Future<String?> Function()? refreshToken,
    bool enableSecurityHeaders = true,
  })  : _getToken = getToken ?? (() async => null),
        _refreshToken = refreshToken,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? const String.fromEnvironment('API_BASE_URL'),
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            // Security headers
            if (enableSecurityHeaders) ..._securityHeaders,
          },
        )) {
    _dio.interceptors.addAll([
      _SecurityInterceptor(),
      if (getToken != null) _AuthInterceptor(_getToken, _refreshToken),
      _RateLimitInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  final Dio _dio;
  final Future<String?> Function() _getToken;
  final Future<String?> Function()? _refreshToken;

  /// Security headers to prevent common attacks
  static const Map<String, String> _securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Cache-Control': 'no-store, no-cache, must-revalidate',
    'Pragma': 'no-cache',
  };

  Dio get dio => _dio;

  /// GET request with typed response parsing.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    final data = _extractData(response.data);
    return parser != null ? parser(data) : data as T;
  }

  /// POST request with typed response parsing.
  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    final response = await _dio.post(path, data: data);
    final responseData = _extractData(response.data);
    return parser != null ? parser(responseData) : responseData as T;
  }

  /// PUT request with typed response parsing.
  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    final response = await _dio.put(path, data: data);
    final responseData = _extractData(response.data);
    return parser != null ? parser(responseData) : responseData as T;
  }

  /// DELETE request.
  Future<void> delete(String path) async {
    await _dio.delete(path);
  }

  /// Extracts data payload from response based on API config.
  dynamic _extractData(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return responseData;
    ${_generateDataExtraction(apiConfig)}
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._getToken, this._refreshToken);

  final Future<String?> Function() _getToken;
  final Future<String?> Function()? _refreshToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer \$token';
      }
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to get auth token: \$e',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401 Unauthorized
    if (err.response?.statusCode == 401 && _refreshToken != null) {
      try {
        final newToken = await _refreshToken!();
        if (newToken != null && newToken.isNotEmpty) {
          // Retry the failed request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer \$newToken';
          
          final dio = Dio();
          final response = await dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (refreshErr) {
        // Refresh failed, pass through original error
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}

/// Security interceptor for additional security checks and headers
class _SecurityInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Add request ID for tracking
    options.headers['X-Request-ID'] = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Validate URL to prevent SSRF (Server-Side Request Forgery)
    final uri = Uri.parse(options.baseUrl + options.path);
    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      // Allow localhost only in development
      if (const bool.fromEnvironment('PRODUCTION', defaultValue: false)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Localhost requests blocked in production',
          ),
        );
      }
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Sanitize error messages to prevent information disclosure
    final sanitizedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: _sanitizeErrorMessage(err.error?.toString() ?? 'Request failed'),
    );
    handler.next(sanitizedError);
  }

  /// Sanitize error messages to prevent sensitive information leakage
  String _sanitizeErrorMessage(String message) {
    // Remove file paths
    message = message.replaceAll(RegExp(r'[A-Z]:\\\\[^\\s]+'), '[PATH]');
    message = message.replaceAll(RegExp(r'/[^\\s]+'), '[PATH]');
    
    // Remove IP addresses
    message = message.replaceAll(
      RegExp(r'\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b'),
      '[IP]',
    );
    
    // Remove potential tokens or keys
    message = message.replaceAll(
      RegExp('["\x27]?[a-zA-Z0-9]{32,}["\x27]?'),
      '[REDACTED]',
    );
    
    return message;
  }
}

/// Rate limiting interceptor to prevent API abuse
class _RateLimitInterceptor extends Interceptor {
  final Map<String, List<DateTime>> _requestTimestamps = {};
  final int _maxRequestsPerMinute = 60;
  final Duration _rateLimitWindow = const Duration(minutes: 1);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final endpoint = options.path;
    final now = DateTime.now();
    
    // Clean old timestamps
    _requestTimestamps[endpoint]?.removeWhere(
      (timestamp) => now.difference(timestamp) > _rateLimitWindow,
    );
    
    // Check rate limit
    final timestamps = _requestTimestamps[endpoint] ?? [];
    if (timestamps.length >= _maxRequestsPerMinute) {
      final oldestRequest = timestamps.first;
      final waitTime = _rateLimitWindow - now.difference(oldestRequest);
      
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Rate limit exceeded. Retry after \${waitTime.inSeconds}s',
        ),
      );
    }
    
    // Record this request
    _requestTimestamps[endpoint] = [...timestamps, now];
    
    handler.next(options);
  }
}
''';
  }

  /// Generates security configuration helper with certificate pinning support.
  ///
  /// Certificate pinning helps prevent man-in-the-middle attacks by validating
  /// the server's SSL certificate against known good certificates.
  static String securityConfig(BlueprintConfig config) {
    return '''
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Security configuration for API requests including certificate pinning.
///
/// Usage:
/// ```dart
/// final apiClient = ApiClient(baseUrl: 'https://api.example.com');
/// SecurityConfig.applyCertificatePinning(
///   apiClient.dio,
///   allowedSHA256Fingerprints: [
///     'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF',
///   ],
/// );
/// ```
class SecurityConfig {
  SecurityConfig._();

  /// Apply certificate pinning to a Dio instance.
  ///
  /// [allowedSHA256Fingerprints] - List of SHA-256 certificate fingerprints
  /// to accept. You can get these by running:
  /// ```bash
  /// openssl s_client -connect api.example.com:443 < /dev/null \\
  ///   | openssl x509 -fingerprint -sha256 -noout
  /// ```
  static void applyCertificatePinning(
    Dio dio, {
    required List<String> allowedSHA256Fingerprints,
  }) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = 
        (HttpClient client) {
      client.badCertificateCallback = 
          (X509Certificate cert, String host, int port) {
        // Get the certificate's SHA-256 fingerprint
        final certFingerprint = cert.sha256.toUpperCase();
        
        // Check if it matches any allowed fingerprint
        for (final allowed in allowedSHA256Fingerprints) {
          if (certFingerprint == allowed.replaceAll(':', '').toUpperCase()) {
            return true;
          }
        }
        
        // Certificate not in pinned list
        print('Certificate pinning failed for \$host');
        print('Expected one of: \$allowedSHA256Fingerprints');
        print('Got: \$certFingerprint');
        return false;
      };
      return client;
    };
  }

  /// Validates that all security best practices are enabled.
  static SecurityCheckResult checkSecurityConfiguration({
    required bool hasSecureStorage,
    required bool hasHttpsOnly,
    required bool hasCertificatePinning,
    required bool hasRateLimiting,
    required bool hasInputValidation,
  }) {
    final issues = <String>[];
    final warnings = <String>[];

    if (!hasSecureStorage) {
      issues.add('No secure storage implementation found');
    }
    if (!hasHttpsOnly) {
      issues.add('HTTP connections allowed (use HTTPS only)');
    }
    if (!hasCertificatePinning) {
      warnings.add('Certificate pinning not enabled (recommended for production)');
    }
    if (!hasRateLimiting) {
      warnings.add('Rate limiting not configured');
    }
    if (!hasInputValidation) {
      issues.add('Input validation not implemented');
    }

    return SecurityCheckResult(
      passed: issues.isEmpty,
      issues: issues,
      warnings: warnings,
    );
  }
}

/// Result of a security configuration check.
class SecurityCheckResult {
  const SecurityCheckResult({
    required this.passed,
    required this.issues,
    required this.warnings,
  });

  final bool passed;
  final List<String> issues;
  final List<String> warnings;

  @override
  String toString() {
    final buffer = StringBuffer('Security Check: ');
    buffer.writeln(passed ? 'PASSED' : 'FAILED');
    
    if (issues.isNotEmpty) {
      buffer.writeln('\\nIssues:');
      for (final issue in issues) {
        buffer.writeln('  ❌ \$issue');
      }
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('\\nWarnings:');
      for (final warning in warnings) {
        buffer.writeln('  ⚠️  \$warning');
      }
    }
    
    return buffer.toString();
  }
}
''';
  }

  /// Generates the standard environment configuration loader.
  static String envConfig(BlueprintConfig config) {
    return '''
/// Environment configuration loaded from .env files.
///
/// Usage:
/// ```dart
/// final apiUrl = EnvConfig.apiBaseUrl;
/// ```
class EnvConfig {
  const EnvConfig._();

  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  static const String appName =
      String.fromEnvironment('APP_NAME', defaultValue: '${config.appName}');

  static const bool isProduction =
      bool.fromEnvironment('PRODUCTION', defaultValue: false);

  static const String sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');
}
''';
  }

  /// Generates common model base class.
  static String modelBase() {
    return '''
/// Base class for all data models, providing JSON serialization contract.
abstract class Model {
  const Model();

  /// Serializes this model to a JSON-compatible map.
  Map<String, dynamic> toJson();

  @override
  String toString() => '\$runtimeType(\${toJson()})';
}
''';
  }

  static String _apiPresetName(BlueprintConfig config) {
    final apiConfig = config.apiConfig;
    if (apiConfig.successKey == 'success' && apiConfig.dataKey == 'data') {
      return 'Modern REST API';
    }
    if (apiConfig.successKey == 'response_code') return 'Legacy .NET API';
    if (apiConfig.successKey == 'status') return 'Laravel API';
    if (apiConfig.successKey.isEmpty) return 'Django REST API';
    return 'Custom API';
  }

  static String _generateDataExtraction(dynamic apiConfig) {
    return '''
    final map = responseData;
    final dataKey = '${(apiConfig as dynamic).dataKey}';
    if (dataKey.isEmpty) return map;
    return map[dataKey] ?? map;''';
  }
}
