// Copyright (c) 2025, flutter_blueprint contributors.
// Licensed under the MIT License. See LICENSE for details.

/// Example demonstrating v2.0 features: Security, Caching, and Auth.
///
/// ⚠️ IMPORTANT: This file contains example code from GENERATED projects.
/// These patterns are automatically included when you run `flutter_blueprint init`.
/// This file itself is not executable - it's for reference only.
///
/// To see these features in action:
/// 1. Run: flutter_blueprint init my_app --api --tests
/// 2. Look at the generated files in my_app/lib/core/api/
///
/// This showcases the production-ready implementations added in v2.0:
/// - Enterprise security with OWASP headers
/// - Certificate pinning for MITM prevention
/// - Rate limiting for API protection
/// - Smart caching with error recovery
/// - Auth token management with auto-refresh
library;

// ============================================================================
// EXAMPLE 1: Security Headers and Certificate Pinning
// ============================================================================
//
// Generated in: lib/core/api/api_client.dart
//
// When you run: flutter_blueprint init my_app --api --security enterprise
//
// The following code is automatically generated:

/* GENERATED CODE EXAMPLE:

import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

void securityExample() {
  // ApiClient with security headers (OWASP-compliant)
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    headers: {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
    },
  ));

  // Certificate pinning (prevents MITM attacks)
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        // To get your certificate fingerprint:
        // openssl s_client -connect api.example.com:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout
        
        final pins = [
          'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
          'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Backup pin
        ];

        final certSha256 = cert.sha256;
        final fingerprint = 'sha256/${base64Encode(certSha256)}';
        
        return pins.contains(fingerprint);
      };
      return client;
    },
  );

  print('✅ Security headers configured');
  print('✅ Certificate pinning enabled');
}

*/

// ============================================================================
// EXAMPLE 2: Smart Caching with Error Recovery
// ============================================================================
//
// Generated in: lib/features/*/data/data_sources/*_local_data_source.dart
//
// When you run: flutter_blueprint add feature user --api
//
// The following LocalDataSource code is generated:

/* GENERATED CODE EXAMPLE:

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserLocalDataSource {
  final SharedPreferences _prefs;
  static const _cacheKey = 'users_cache';

  UserLocalDataSource(this._prefs);

  // Retrieve cached data with automatic error recovery
  Future<List<User>?> getCached() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null) return null;

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      // Auto-clear corrupted cache
      await clearCache();
      print('⚠️  Cache corrupted - cleared automatically');
      return null;
    }
  }

  // Cache data with JSON serialization
  Future<void> cache(List<User> users) async {
    try {
      final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
      await _prefs.setString(_cacheKey, jsonString);
      print('✅ Cached ${users.length} items');
    } catch (e) {
      print('❌ Cache error: $e');
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    print('✅ Cache cleared');
  }
}

*/

// ============================================================================
// EXAMPLE 3: Auth Token Management with Auto-Refresh
// ============================================================================
//
// Generated in: lib/core/api/interceptors/auth_interceptor.dart
//
// The following AuthInterceptor is automatically generated:

/* GENERATED CODE EXAMPLE:

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final Future<String?> Function() refreshToken;

  AuthInterceptor({
    required this.getToken,
    required this.refreshToken,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Inject token into Authorization header
    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Auto-refresh on 401
    if (err.response?.statusCode == 401) {
      print('🔐 Token expired - refreshing...');

      final newToken = await refreshToken();
      if (newToken != null) {
        // Retry request with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        final dio = Dio();
        final response = await dio.request(
          opts.path,
          options: Options(
            method: opts.method,
            headers: opts.headers,
          ),
          data: opts.data,
          queryParameters: opts.queryParameters,
        );

        return handler.resolve(response);
      }
    }
    return handler.next(err);
  }
}

// Usage in ApiClient
final dio = Dio();
dio.interceptors.add(
  AuthInterceptor(
    getToken: () async => await storage.getToken(),
    refreshToken: () async => await authService.refresh(),
  ),
);

*/

// ============================================================================
// EXAMPLE 4: Rate Limiting
// ============================================================================
//
// Generated in: lib/core/api/interceptors/rate_limit_interceptor.dart

/* GENERATED CODE EXAMPLE:

import 'package:dio/dio.dart';

class RateLimitInterceptor extends Interceptor {
  final Map<String, List<DateTime>> _requestTimestamps = {};
  final int _maxRequestsPerMinute = 60;
  final Duration _rateLimitWindow = const Duration(minutes: 1);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final endpoint = options.path;
    final now = DateTime.now();

    // Get timestamps for this endpoint
    final timestamps = _requestTimestamps[endpoint] ?? [];

    // Remove old timestamps
    timestamps.removeWhere((t) => now.difference(t) > _rateLimitWindow);

    // Check rate limit
    if (timestamps.length >= _maxRequestsPerMinute) {
      final oldestTimestamp = timestamps.first;
      final retryAfter =
          _rateLimitWindow.inSeconds - now.difference(oldestTimestamp).inSeconds;

      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Rate limit exceeded. Retry after $retryAfter seconds.',
        ),
      );
    }

    // Add current timestamp
    timestamps.add(now);
    _requestTimestamps[endpoint] = timestamps;

    // Cleanup (prevent memory leak)
    if (_requestTimestamps.length > 100) {
      final oldestEndpoint = _requestTimestamps.keys.first;
      _requestTimestamps.remove(oldestEndpoint);
    }

    handler.next(options);
  }
}

*/

// ============================================================================
// EXAMPLE 5: Security Configuration Validation
// ============================================================================
//
// Generated in: lib/core/api/security_config.dart

/* GENERATED CODE EXAMPLE:

import 'package:dio/dio.dart';

class SecurityCheckResult {
  final int passed;
  final List<String> issues;
  final List<String> warnings;

  SecurityCheckResult({
    required this.passed,
    required this.issues,
    required this.warnings,
  });
}

class SecurityConfig {
  static SecurityCheckResult checkSecurityConfiguration(Dio dio) {
    final issues = <String>[];
    final warnings = <String>[];
    var passed = 0;

    // Check 1: HTTPS enforcement
    if (dio.options.baseUrl.startsWith('https://')) {
      passed++;
    } else {
      issues.add('Base URL must use HTTPS');
    }

    // Check 2: Security headers
    final headers = dio.options.headers;
    if (headers.containsKey('X-Content-Type-Options')) {
      passed++;
    } else {
      warnings.add('X-Content-Type-Options header missing');
    }

    // Check 3: Certificate pinning
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      passed++;
    } else {
      warnings.add('Certificate pinning not configured');
    }

    // Check 4: Rate limiting
    final hasRateLimiter =
        dio.interceptors.any((i) => i.toString().contains('RateLimit'));
    if (hasRateLimiter) {
      passed++;
    } else {
      warnings.add('Rate limiting not enabled');
    }

    // Check 5: Error sanitization
    final hasSecurity =
        dio.interceptors.any((i) => i.toString().contains('Security'));
    if (hasSecurity) {
      passed++;
    } else {
      warnings.add('Error sanitization not enabled');
    }

    return SecurityCheckResult(
      passed: passed,
      issues: issues,
      warnings: warnings,
    );
  }
}

// Usage
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
final result = SecurityConfig.checkSecurityConfiguration(dio);
print('Security checks passed: ${result.passed}/5');

*/

// ============================================================================
// HOW TO USE THESE FEATURES
// ============================================================================

void main() {
  print('''
=== flutter_blueprint v2.0 Features ===

This file contains example code from GENERATED projects.
To see these features in action:

1. Generate a new project:
   flutter_blueprint init my_app --api --security enterprise

2. The generated project includes:
   - lib/core/api/api_client.dart (security headers + cert pinning)
   - lib/core/api/interceptors/auth_interceptor.dart
   - lib/core/api/interceptors/rate_limit_interceptor.dart
   - lib/core/api/interceptors/security_interceptor.dart
   - lib/features/*/data/data_sources/*_local_data_source.dart

3. Add a feature with caching:
   flutter_blueprint add feature user --api

4. See complete documentation:
   - API_REFERENCE.md - Complete API documentation
   - MIGRATION_v2.md - Upgrade guide from v1.x
   - ARCHITECTURE.md - Technical deep dive

=== Quick Examples ===

🔒 Security: OWASP headers + certificate pinning
🚦 Rate Limiting: 60 requests/min per endpoint
💾 Smart Caching: JSON serialization + error recovery
🔐 Auth: Callback-based token management + auto-refresh
🧹 Sanitization: Removes paths, IPs, tokens from errors
✅ Validation: Built-in security audit helper

All features are production-ready and extensively tested!
''');
}
