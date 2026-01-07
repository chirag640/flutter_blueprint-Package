/// API configuration for customizable backend communication.
///
/// This class allows developers to define how their backend API communicates,
/// including response parsing, token extraction, and authentication patterns.
class ApiConfig {
  const ApiConfig({
    // Response parsing
    this.successKey = 'success',
    this.successValue = true,
    this.dataKey = 'data',
    this.nestedDataPath,

    // Error handling
    this.errorMessagePath = 'message',
    this.errorCodePath = 'error_code',

    // Token extraction (from login response)
    this.tokenSource = TokenSource.body,
    this.accessTokenPath = 'data.accessToken',
    this.refreshTokenPath = 'data.refreshToken',

    // Token sending (for authenticated requests)
    this.authHeaderName = 'Authorization',
    this.authHeaderPrefix = 'Bearer ',
  });

  // ===== Response Parsing =====

  /// Key to check for success/failure (e.g., 'success', 'response_code')
  final String successKey;

  /// Value that indicates success (e.g., true, '200')
  final dynamic successValue;

  /// Key where the data payload is located (e.g., 'data', 'obj')
  /// Set to empty string if data is at root level
  final String dataKey;

  /// Optional nested path for data extraction (e.g., 'data.user.profile')
  final String? nestedDataPath;

  // ===== Error Handling =====

  /// Path to extract error message (e.g., 'error.message', 'obj')
  final String errorMessagePath;

  /// Path to extract error code (e.g., 'error.code', 'response_code')
  final String errorCodePath;

  // ===== Token Extraction =====

  /// Where to find the token in login response
  final TokenSource tokenSource;

  /// Path to access token (body: 'data.accessToken', header: 'token')
  final String accessTokenPath;

  /// Path to refresh token (body: 'data.refreshToken', header: 'refresh-token')
  final String? refreshTokenPath;

  // ===== Token Sending =====

  /// Header name for sending auth token (e.g., 'Authorization', 'token', 'X-Auth-Token')
  final String authHeaderName;

  /// Prefix before the token value (e.g., 'Bearer ', '' for no prefix)
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

  // ===== Presets =====

  /// Modern REST API pattern
  /// - Success: { "success": true, "data": {...} }
  /// - Error: { "success": false, "error": { "message": "...", "code": "..." } }
  /// - Token: Bearer in Authorization header
  static const modern = ApiConfig();

  /// Legacy .NET API pattern
  /// - Success: { "response_code": "200", "obj": "..." }
  /// - Error: { "response_code": "215", "obj": "Error message" }
  /// - Token: In response header, sent as custom header
  static const legacyDotNet = ApiConfig(
    successKey: 'response_code',
    successValue: '200',
    dataKey: 'obj',
    errorMessagePath: 'obj',
    errorCodePath: 'response_code',
    tokenSource: TokenSource.header,
    accessTokenPath: 'token',
    refreshTokenPath: null,
    authHeaderName: 'token',
    authHeaderPrefix: '',
  );

  /// Laravel/PHP API pattern
  /// - Success: { "status": "success", "data": {...} }
  /// - Error: { "status": "error", "message": "..." }
  static const laravel = ApiConfig(
    successKey: 'status',
    successValue: 'success',
    dataKey: 'data',
    errorMessagePath: 'message',
    errorCodePath: 'code',
  );

  /// Django REST Framework pattern
  /// - Success: Direct data (no wrapper)
  /// - Error: { "detail": "Error message" }
  static const django = ApiConfig(
    successKey: '',
    successValue: null,
    dataKey: '',
    errorMessagePath: 'detail',
    errorCodePath: 'code',
  );

  /// Converts to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'success_key': successKey,
      'success_value': successValue,
      'data_key': dataKey,
      'nested_data_path': nestedDataPath,
      'error_message_path': errorMessagePath,
      'error_code_path': errorCodePath,
      'token_source': tokenSource.name,
      'access_token_path': accessTokenPath,
      'refresh_token_path': refreshTokenPath,
      'auth_header_name': authHeaderName,
      'auth_header_prefix': authHeaderPrefix,
    };
  }

  /// Creates from map (for loading from config file)
  static ApiConfig fromMap(Map<String, dynamic> map) {
    return ApiConfig(
      successKey: map['success_key'] as String? ?? 'success',
      successValue: map['success_value'] ?? true,
      dataKey: map['data_key'] as String? ?? 'data',
      nestedDataPath: map['nested_data_path'] as String?,
      errorMessagePath: map['error_message_path'] as String? ?? 'message',
      errorCodePath: map['error_code_path'] as String? ?? 'error_code',
      tokenSource: TokenSource.values.firstWhere(
        (e) => e.name == (map['token_source'] ?? 'body'),
        orElse: () => TokenSource.body,
      ),
      accessTokenPath:
          map['access_token_path'] as String? ?? 'data.accessToken',
      refreshTokenPath: map['refresh_token_path'] as String?,
      authHeaderName: map['auth_header_name'] as String? ?? 'Authorization',
      authHeaderPrefix: map['auth_header_prefix'] as String? ?? 'Bearer ',
    );
  }

  /// Creates a copy with updated values
  ApiConfig copyWith({
    String? successKey,
    dynamic successValue,
    String? dataKey,
    String? nestedDataPath,
    String? errorMessagePath,
    String? errorCodePath,
    TokenSource? tokenSource,
    String? accessTokenPath,
    String? refreshTokenPath,
    String? authHeaderName,
    String? authHeaderPrefix,
  }) {
    return ApiConfig(
      successKey: successKey ?? this.successKey,
      successValue: successValue ?? this.successValue,
      dataKey: dataKey ?? this.dataKey,
      nestedDataPath: nestedDataPath ?? this.nestedDataPath,
      errorMessagePath: errorMessagePath ?? this.errorMessagePath,
      errorCodePath: errorCodePath ?? this.errorCodePath,
      tokenSource: tokenSource ?? this.tokenSource,
      accessTokenPath: accessTokenPath ?? this.accessTokenPath,
      refreshTokenPath: refreshTokenPath ?? this.refreshTokenPath,
      authHeaderName: authHeaderName ?? this.authHeaderName,
      authHeaderPrefix: authHeaderPrefix ?? this.authHeaderPrefix,
    );
  }
}

/// Where to extract the authentication token from
enum TokenSource {
  /// Token is in the response body (e.g., { "data": { "accessToken": "..." } })
  body,

  /// Token is in a response header (e.g., header 'token: xyz123')
  header,
}
