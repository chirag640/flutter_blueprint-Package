/// Security templates for Flutter Blueprint
///
/// Provides enterprise-grade security patterns including:
/// - Certificate pinning for HTTPS connections
/// - Root/jailbreak detection
/// - Biometric authentication
/// - API key obfuscation
/// - Encrypted storage
/// - Screenshot protection
/// - Network security configuration
/// - Security headers and interceptors
library;

/// Generates the certificate pinner utility for SSL/TLS pinning
String generateCertificatePinner() {
  return r'''import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Certificate pinning utility to prevent man-in-the-middle attacks
///
/// Usage:
/// ```dart
/// final pinner = CertificatePinner({
///   'api.example.com': ['sha256/AAAAAAA...'],
/// });
/// if (!pinner.check('api.example.com', certificate)) {
///   throw SecurityException('Certificate validation failed');
/// }
/// ```
class CertificatePinner {
  final Map<String, List<String>> _pins;

  CertificatePinner(this._pins);

  /// Validates a certificate against the configured pins
  bool check(String hostname, X509Certificate certificate) {
    final pins = _pins[hostname];
    if (pins == null || pins.isEmpty) {
      // No pins configured for this host
      return true;
    }

    final certSha256 = _getCertificateSha256(certificate);
    final pin = 'sha256/$certSha256';

    return pins.contains(pin);
  }

  /// Extracts SHA-256 fingerprint from certificate
  String _getCertificateSha256(X509Certificate certificate) {
    final der = certificate.der;
    final digest = sha256.convert(der);
    return base64.encode(digest.bytes);
  }

  /// Validates certificate chain
  bool validateChain(String hostname, List<X509Certificate> chain) {
    if (chain.isEmpty) return false;

    // Check if any certificate in the chain matches the pin
    for (final cert in chain) {
      if (check(hostname, cert)) {
        return true;
      }
    }

    return false;
  }
}

/// Exception thrown when certificate validation fails
class CertificateValidationException implements Exception {
  final String message;
  final String hostname;

  CertificateValidationException(this.message, this.hostname);

  @override
  String toString() => 'CertificateValidationException: $message (host: $hostname)';
}
''';
}

/// Generates the device security checker for root/jailbreak detection
String generateDeviceSecurityChecker() {
  return r'''import 'dart:io';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Security status of the device
class SecurityStatus {
  final bool isDeviceSecure;
  final bool isRooted;
  final bool isJailbroken;
  final bool isDeveloperMode;
  final String deviceInfo;

  SecurityStatus({
    required this.isDeviceSecure,
    required this.isRooted,
    required this.isJailbroken,
    required this.isDeveloperMode,
    required this.deviceInfo,
  });

  @override
  String toString() {
    return 'SecurityStatus(secure: $isDeviceSecure, rooted: $isRooted, '
        'jailbroken: $isJailbroken, devMode: $isDeveloperMode)';
  }
}

/// Checks device security status (root/jailbreak detection)
///
/// Usage:
/// ```dart
/// final status = await DeviceSecurityChecker.checkDeviceSecurity();
/// if (!status.isDeviceSecure) {
///   showSecurityWarning();
/// }
/// ```
class DeviceSecurityChecker {
  static Future<SecurityStatus> checkDeviceSecurity() async {
    bool isRooted = false;
    bool isJailbroken = false;
    bool isDeveloperMode = false;
    String deviceInfo = '';

    try {
      if (Platform.isAndroid) {
        isRooted = await FlutterJailbreakDetection.jailbroken;
        isDeveloperMode = await FlutterJailbreakDetection.developerMode;
        
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo = '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        isJailbroken = await FlutterJailbreakDetection.jailbroken;
        isDeveloperMode = await FlutterJailbreakDetection.developerMode;
        
        final deviceInfoPlugin = DeviceInfoPlugin();
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo = '${iosInfo.name} ${iosInfo.model} (iOS ${iosInfo.systemVersion})';
      }
    } catch (e) {
      // If detection fails, assume device is secure but log the error
      print('Error checking device security: $e');
    }

    final isDeviceSecure = !isRooted && !isJailbroken;

    return SecurityStatus(
      isDeviceSecure: isDeviceSecure,
      isRooted: isRooted,
      isJailbroken: isJailbroken,
      isDeveloperMode: isDeveloperMode,
      deviceInfo: deviceInfo,
    );
  }

  /// Checks if device is rooted (Android)
  static Future<bool> isRooted() async {
    if (!Platform.isAndroid) return false;
    try {
      return await FlutterJailbreakDetection.jailbroken;
    } catch (e) {
      return false;
    }
  }

  /// Checks if device is jailbroken (iOS)
  static Future<bool> isJailbroken() async {
    if (!Platform.isIOS) return false;
    try {
      return await FlutterJailbreakDetection.jailbroken;
    } catch (e) {
      return false;
    }
  }

  /// Checks if developer mode is enabled
  static Future<bool> isDeveloperModeEnabled() async {
    try {
      return await FlutterJailbreakDetection.developerMode;
    } catch (e) {
      return false;
    }
  }
}
''';
}

/// Generates the biometric authentication wrapper
String generateBiometricAuth() {
  return r'''import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

/// Biometric authentication wrapper
///
/// Usage:
/// ```dart
/// final authenticated = await BiometricAuth.authenticate(
///   localizedReason: 'Please authenticate to access your account',
/// );
/// if (authenticated) {
///   // Proceed with sensitive operation
/// }
/// ```
class BiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if biometric authentication is available
  static Future<bool> canAuthenticate() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Gets available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticates using biometrics
  ///
  /// [localizedReason] - Message to show to the user
  /// [biometricOnly] - If true, only allows biometric authentication (no PIN/password fallback)
  /// [stickyAuth] - If true, authentication dialog is not dismissed on app lifecycle changes
  static Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
    bool stickyAuth = true,
  }) async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
            biometricHint: 'Verify identity',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication',
            lockOut: 'Biometric authentication is disabled',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  /// Stops authentication
  static Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  /// Checks if biometric authentication is enrolled
  static Future<bool> isBiometricEnrolled() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
''';
}

/// Generates the API key manager for secure key storage
String generateApiKeyManager() {
  return r'''import 'dart:convert';

/// Manages API keys securely using environment variables and obfuscation
///
/// Usage:
/// ```dart
/// // Set API key in .env file:
/// // API_KEY_ENCODED=base64_encoded_key
/// 
/// final apiKey = ApiKeyManager.getApiKey();
/// ```
class ApiKeyManager {
  // API key loaded from environment variable
  static const String _apiKeyBase64 = String.fromEnvironment(
    'API_KEY_ENCODED',
    defaultValue: '',
  );

  static const String _secondaryKeyBase64 = String.fromEnvironment(
    'SECONDARY_KEY_ENCODED',
    defaultValue: '',
  );

  /// Gets the primary API key
  static String getApiKey() {
    if (_apiKeyBase64.isEmpty) {
      throw SecurityException('API key not configured. Set API_KEY_ENCODED environment variable.');
    }
    return _decodeKey(_apiKeyBase64);
  }

  /// Gets the secondary API key (optional)
  static String? getSecondaryKey() {
    if (_secondaryKeyBase64.isEmpty) {
      return null;
    }
    return _decodeKey(_secondaryKeyBase64);
  }

  /// Checks if API key is configured
  static bool isConfigured() {
    return _apiKeyBase64.isNotEmpty;
  }

  /// Decodes an obfuscated API key
  static String _decodeKey(String encoded) {
    try {
      final decoded = base64.decode(encoded);
      return utf8.decode(decoded);
    } catch (e) {
      throw SecurityException('Failed to decode API key: $e');
    }
  }

  /// Encodes an API key (use this to generate encoded keys)
  static String encodeKey(String key) {
    final bytes = utf8.encode(key);
    return base64.encode(bytes);
  }
}

/// Exception thrown for security-related errors
class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
''';
}

/// Generates enhanced encrypted storage
String generateEncryptedStorage() {
  return r'''import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

/// Enhanced encrypted storage with AES encryption
///
/// Usage:
/// ```dart
/// final storage = EncryptedStorage.instance;
/// await storage.write('token', 'secret_token_value');
/// final token = await storage.read('token');
/// ```
class EncryptedStorage {
  static final EncryptedStorage _instance = EncryptedStorage._internal();
  static EncryptedStorage get instance => _instance;

  late final FlutterSecureStorage _secureStorage;
  late final encrypt.Encrypter _encrypter;
  late final encrypt.IV _iv;
  bool _initialized = false;

  EncryptedStorage._internal();

  /// Initializes the encrypted storage
  Future<void> init() async {
    if (_initialized) return;

    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );

    // Generate or retrieve encryption key
    final keyString = await _getOrCreateKey();
    final key = encrypt.Key.fromUtf8(keyString);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    
    // Generate or retrieve IV
    final ivString = await _getOrCreateIV();
    _iv = encrypt.IV.fromUtf8(ivString);

    _initialized = true;
  }

  /// Writes an encrypted value
  Future<void> write(String key, String value) async {
    await _ensureInitialized();
    
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await _secureStorage.write(
      key: key,
      value: encrypted.base64,
    );
  }

  /// Reads an encrypted value
  Future<String?> read(String key) async {
    await _ensureInitialized();
    
    final encryptedValue = await _secureStorage.read(key: key);
    if (encryptedValue == null) return null;

    try {
      final decrypted = _encrypter.decrypt64(encryptedValue, iv: _iv);
      return decrypted;
    } catch (e) {
      print('Error decrypting value for key $key: $e');
      return null;
    }
  }

  /// Deletes a value
  Future<void> delete(String key) async {
    await _ensureInitialized();
    await _secureStorage.delete(key: key);
  }

  /// Deletes all values
  Future<void> deleteAll() async {
    await _ensureInitialized();
    await _secureStorage.deleteAll();
  }

  /// Checks if a key exists
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return await _secureStorage.containsKey(key: key);
  }

  /// Writes a JSON object
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await write(key, jsonEncode(value));
  }

  /// Reads a JSON object
  Future<Map<String, dynamic>?> readJson(String key) async {
    final value = await read(key);
    if (value == null) return null;
    
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing JSON for key $key: $e');
      return null;
    }
  }

  /// Gets or creates encryption key
  Future<String> _getOrCreateKey() async {
    const keyName = '_encryption_key';
    var key = await _secureStorage.read(key: keyName);
    
    if (key == null) {
      // Generate a 32-character key
      key = _generateSecureKey(32);
      await _secureStorage.write(key: keyName, value: key);
    }
    
    return key;
  }

  /// Gets or creates IV
  Future<String> _getOrCreateIV() async {
    const ivName = '_encryption_iv';
    var iv = await _secureStorage.read(key: ivName);
    
    if (iv == null) {
      // Generate a 16-character IV
      iv = _generateSecureKey(16);
      await _secureStorage.write(key: ivName, value: iv);
    }
    
    return iv;
  }

  /// Generates a secure random key
  String _generateSecureKey(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = encrypt.SecureRandom(length);
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Ensures storage is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }
}
''';
}

/// Generates screenshot protection utility
String generateScreenshotProtection() {
  return r'''import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screenshot protection utility
///
/// Usage:
/// ```dart
/// // Enable protection
/// await ScreenshotProtection.enable();
/// 
/// // Disable protection
/// await ScreenshotProtection.disable();
/// ```
class ScreenshotProtection {
  static const MethodChannel _channel = MethodChannel('screenshot_protection');
  static bool _isEnabled = false;

  /// Enables screenshot protection (Android only)
  static Future<void> enable() async {
    if (_isEnabled) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('enableSecureFlag');
        _isEnabled = true;
      } catch (e) {
        print('Error enabling screenshot protection: $e');
      }
    }
  }

  /// Disables screenshot protection (Android only)
  static Future<void> disable() async {
    if (!_isEnabled) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('disableSecureFlag');
        _isEnabled = false;
      } catch (e) {
        print('Error disabling screenshot protection: $e');
      }
    }
  }

  /// Checks if protection is enabled
  static bool get isEnabled => _isEnabled;
}

/// Widget that prevents screenshots on its child
///
/// Usage:
/// ```dart
/// SecureScreen(
///   child: PaymentPage(),
/// )
/// ```
class SecureScreen extends StatefulWidget {
  final Widget child;

  const SecureScreen({
    super.key,
    required this.child,
  });

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  @override
  void initState() {
    super.initState();
    ScreenshotProtection.enable();
  }

  @override
  void dispose() {
    ScreenshotProtection.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
''';
}

/// Generates network security configuration
String generateNetworkSecurityConfig() {
  return r'''/// Network security configuration utilities
///
/// Usage:
/// ```dart
/// NetworkSecurityConfig.validateUrl('https://api.example.com');
/// final client = NetworkSecurityConfig.createSecureClient();
/// ```
class NetworkSecurityConfig {
  /// List of allowed domains (HTTPS only)
  static const List<String> allowedDomains = [
    'api.example.com',
    // Add your allowed domains here
  ];

  /// Validates if a URL is secure (HTTPS)
  static bool isSecureConnection(String url) {
    final uri = Uri.parse(url);
    return uri.scheme == 'https';
  }

  /// Validates if a URL uses an allowed domain
  static bool isAllowedDomain(String url) {
    final uri = Uri.parse(url);
    final host = uri.host;
    
    return allowedDomains.any((domain) => 
      host == domain || host.endsWith('.$domain')
    );
  }

  /// Validates a URL for security
  static void validateUrl(String url) {
    if (!isSecureConnection(url)) {
      throw NetworkSecurityException(
        'Insecure connection detected: $url. Only HTTPS is allowed.',
      );
    }

    if (allowedDomains.isNotEmpty && !isAllowedDomain(url)) {
      throw NetworkSecurityException(
        'Domain not allowed: $url. Check allowedDomains configuration.',
      );
    }
  }

  /// Checks if cleartext traffic should be blocked
  static bool shouldBlockCleartextTraffic() {
    // Always block cleartext in production
    return const bool.fromEnvironment('dart.vm.product', defaultValue: true);
  }
}

/// Exception thrown for network security violations
class NetworkSecurityException implements Exception {
  final String message;

  NetworkSecurityException(this.message);

  @override
  String toString() => 'NetworkSecurityException: $message';
}
''';
}

/// Generates security interceptor for Dio
String generateSecurityInterceptor() {
  return r'''import 'package:dio/dio.dart';

/// Security interceptor that adds security headers to all requests
///
/// Usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(SecurityInterceptor());
/// ```
class SecurityInterceptor extends Interceptor {
  final String? csrfToken;

  SecurityInterceptor({this.csrfToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add security headers
    options.headers['X-Frame-Options'] = 'DENY';
    options.headers['X-Content-Type-Options'] = 'nosniff';
    options.headers['X-XSS-Protection'] = '1; mode=block';
    options.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains';
    options.headers['Content-Security-Policy'] = "default-src 'self'";

    // Add CSRF token if available
    if (csrfToken != null && csrfToken!.isNotEmpty) {
      options.headers['X-CSRF-Token'] = csrfToken;
    }

    // Add request ID for tracking
    options.headers['X-Request-ID'] = _generateRequestId();

    // Validate URL is HTTPS
    if (!options.uri.scheme.startsWith('https')) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Insecure HTTP connection detected. Only HTTPS is allowed.',
          type: DioExceptionType.badRequest,
        ),
      );
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log security-related response headers
    _logSecurityHeaders(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log security errors
    if (err.response?.statusCode == 403 || err.response?.statusCode == 401) {
      print('Security error: ${err.response?.statusCode} - ${err.message}');
    }
    handler.next(err);
  }

  /// Generates a unique request ID
  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_randomString(8)}';
  }

  /// Generates a random string
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[DateTime.now().microsecond % chars.length]).join();
  }

  /// Logs security-related response headers
  void _logSecurityHeaders(Response response) {
    final securityHeaders = [
      'Strict-Transport-Security',
      'Content-Security-Policy',
      'X-Frame-Options',
      'X-Content-Type-Options',
    ];

    for (final header in securityHeaders) {
      final value = response.headers.value(header);
      if (value != null) {
        print('Security header $header: $value');
      }
    }
  }
}
''';
}

/// Generates a secure HTTP client with certificate pinning
String generateSecureHttpClient() {
  return r'''import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'certificate_pinner.dart';
import 'network_security_config.dart';

/// Secure HTTP client with certificate pinning
///
/// Usage:
/// ```dart
/// final client = SecureHttpClient.create(
///   certificatePins: {
///     'api.example.com': ['sha256/AAAA...'],
///   },
/// );
/// ```
class SecureHttpClient {
  /// Creates a secure Dio client with certificate pinning
  static Dio create({
    Map<String, List<String>>? certificatePins,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Configure certificate pinning if pins are provided
    if (certificatePins != null && certificatePins.isNotEmpty) {
      final pinner = CertificatePinner(certificatePins);
      
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        
        client.badCertificateCallback = (cert, host, port) {
          try {
            return pinner.check(host, cert);
          } catch (e) {
            print('Certificate validation failed for $host: $e');
            return false;
          }
        };
        
        return client;
      };
    }

    return dio;
  }

  /// Creates a client with default security settings
  static Dio createDefault() {
    return create();
  }

  /// Validates a URL before making a request
  static void validateRequest(String url) {
    NetworkSecurityConfig.validateUrl(url);
  }
}
''';
}

/// Generates platform-specific security configuration for Android
String generateAndroidNetworkSecurityConfig() {
  return r'''<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Block all cleartext (HTTP) traffic -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <!-- Trust system certificates -->
            <certificates src="system" />
        </trust-anchors>
    </base-config>

    <!-- Configuration for specific domains (if needed) -->
    <!-- <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2026-01-01">
            <pin digest="SHA-256">base64==</pin>
            <pin digest="SHA-256">backup-base64==</pin>
        </pin-set>
    </domain-config> -->

    <!-- Debug configuration (only for debug builds) -->
    <debug-overrides>
        <trust-anchors>
            <certificates src="user" />
            <certificates src="system" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
''';
}
