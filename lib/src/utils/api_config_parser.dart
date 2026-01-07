import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';
import '../utils/logger.dart';

/// Parses sample JSON responses to auto-detect API configuration.
class ApiConfigParser {
  ApiConfigParser(this._logger);

  final Logger _logger;

  /// Attempts to parse a JSON sample and detect configuration
  ApiConfig? parseFromSample(String jsonSample) {
    try {
      final decoded = jsonDecode(jsonSample);
      if (decoded is! Map<String, dynamic>) {
        _logger.warning('Sample is not a JSON object');
        return null;
      }

      return _detectFromMap(decoded);
    } catch (e) {
      _logger.error('Failed to parse JSON sample: $e');
      return null;
    }
  }

  /// Load and parse a JSON file
  Future<ApiConfig?> parseFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.error('File not found: $filePath');
        return null;
      }

      final contents = await file.readAsString();
      return parseFromSample(contents);
    } catch (e) {
      _logger.error('Failed to read file: $e');
      return null;
    }
  }

  /// Detect configuration from a parsed JSON map
  ApiConfig _detectFromMap(Map<String, dynamic> json) {
    // === Detect success key ===
    String successKey = '';
    dynamic successValue = true;

    // Common success key patterns
    final successPatterns = [
      'success',
      'status',
      'ok',
      'isSuccess',
      'succeeded',
      'code',
    ];

    for (final pattern in successPatterns) {
      if (json.containsKey(pattern)) {
        successKey = pattern;
        final value = json[pattern];
        if (value is bool) {
          successValue = value;
        } else if (value is int) {
          // Codes like 200, 0, 1
          successValue = value;
        } else if (value is String) {
          successValue =
              value.toLowerCase() == 'success' || value.toLowerCase() == 'ok'
                  ? value
                  : value;
        }
        _logger.info('   Detected success key: "$successKey" = $successValue');
        break;
      }
    }

    // === Detect data key ===
    String dataKey = 'data';
    String? nestedDataPath;

    final dataPatterns = [
      'data',
      'result',
      'results',
      'payload',
      'body',
      'response'
    ];

    for (final pattern in dataPatterns) {
      if (json.containsKey(pattern)) {
        dataKey = pattern;
        _logger.info('   Detected data key: "$dataKey"');

        // Check if data is nested
        final dataValue = json[pattern];
        if (dataValue is Map<String, dynamic>) {
          // Check for common nested patterns
          if (dataValue.containsKey('items')) {
            nestedDataPath = '$dataKey.items';
          } else if (dataValue.containsKey('list')) {
            nestedDataPath = '$dataKey.list';
          } else if (dataValue.containsKey('records')) {
            nestedDataPath = '$dataKey.records';
          }

          if (nestedDataPath != null) {
            _logger.info('   Detected nested data path: "$nestedDataPath"');
          }
        }
        break;
      }
    }

    // === Detect error message path ===
    String errorMessagePath = 'message';

    final errorPatterns = [
      'message',
      'error',
      'error_message',
      'errorMessage',
      'msg',
      'errors',
    ];

    for (final pattern in errorPatterns) {
      if (json.containsKey(pattern)) {
        final value = json[pattern];
        if (value is String ||
            (value is List && value.isNotEmpty) ||
            (value is Map)) {
          errorMessagePath = pattern;
          _logger.info('   Detected error message path: "$errorMessagePath"');
          break;
        }
      }
    }

    // === Detect error code path ===
    String errorCodePath = 'code';

    final codePatterns = ['code', 'error_code', 'errorCode', 'statusCode'];

    for (final pattern in codePatterns) {
      if (json.containsKey(pattern) && pattern != successKey) {
        errorCodePath = pattern;
        _logger.info('   Detected error code path: "$errorCodePath"');
        break;
      }
    }

    // === Detect token paths (if present) ===
    String accessTokenPath = 'data.accessToken';
    String? refreshTokenPath = 'data.refreshToken';

    final tokenPatterns = [
      'token',
      'accessToken',
      'access_token',
      'jwt',
      'auth_token',
    ];

    // Check top level
    for (final pattern in tokenPatterns) {
      if (json.containsKey(pattern)) {
        accessTokenPath = pattern;
        _logger.info('   Detected access token path: "$accessTokenPath"');
        break;
      }
    }

    // Check nested in data
    if (json.containsKey(dataKey) && json[dataKey] is Map<String, dynamic>) {
      final dataMap = json[dataKey] as Map<String, dynamic>;
      for (final pattern in tokenPatterns) {
        if (dataMap.containsKey(pattern)) {
          accessTokenPath = '$dataKey.$pattern';
          _logger.info('   Detected access token path: "$accessTokenPath"');
          break;
        }
      }

      // Check for refresh token
      final refreshPatterns = [
        'refreshToken',
        'refresh_token',
        'refresh',
      ];
      for (final pattern in refreshPatterns) {
        if (dataMap.containsKey(pattern)) {
          refreshTokenPath = '$dataKey.$pattern';
          _logger.info('   Detected refresh token path: "$refreshTokenPath"');
          break;
        }
      }
    }

    return ApiConfig(
      successKey: successKey,
      successValue: successValue,
      dataKey: dataKey,
      nestedDataPath: nestedDataPath,
      errorMessagePath: errorMessagePath,
      errorCodePath: errorCodePath,
      tokenSource: TokenSource.body,
      accessTokenPath: accessTokenPath,
      refreshTokenPath: refreshTokenPath,
    );
  }

  /// Returns a preset name if the detected config matches a known pattern
  String? identifyPreset(ApiConfig config) {
    // Check for Modern REST pattern
    if (config.successKey.isEmpty &&
        config.dataKey == 'data' &&
        config.authHeaderPrefix == 'Bearer ') {
      return 'modern';
    }

    // Check for Legacy .NET pattern
    if ((config.successKey == 'success' || config.successKey == 'IsSuccess') &&
        config.successValue == true &&
        config.dataKey == 'Result') {
      return 'legacyDotNet';
    }

    // Check for Laravel pattern
    if (config.successKey.isEmpty &&
        config.dataKey == 'data' &&
        config.errorMessagePath == 'message') {
      return 'laravel';
    }

    // Check for Django pattern
    if (config.dataKey == 'results' && config.errorMessagePath == 'detail') {
      return 'django';
    }

    return null;
  }
}
