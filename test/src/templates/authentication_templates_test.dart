import 'package:flutter_blueprint/src/templates/authentication_templates.dart';
import 'package:test/test.dart';

void main() {
  group('generateJWTHandler', () {
    test('generates valid Dart code', () {
      final result = generateJWTHandler();
      expect(result, isNotEmpty);
      expect(result, contains('class JWTHandler'));
    });

    test('includes JWT token storage methods', () {
      final result = generateJWTHandler();
      expect(result, contains('saveTokens'));
      expect(result, contains('getAccessToken'));
      expect(result, contains('getRefreshToken'));
    });

    test('includes token validation logic', () {
      final result = generateJWTHandler();
      expect(result, contains('isTokenExpired'));
      expect(result, contains('JwtDecoder'));
    });

    test('includes automatic refresh functionality', () {
      final result = generateJWTHandler();
      expect(result, contains('getValidAccessToken'));
      expect(result, contains('onRefresh'));
    });

    test('includes token decoding methods', () {
      final result = generateJWTHandler();
      expect(result, contains('decodeToken'));
      expect(result, contains('getUserIdFromToken'));
      expect(result, contains('getUserEmailFromToken'));
    });

    test('includes clear tokens method', () {
      final result = generateJWTHandler();
      expect(result, contains('clearTokens'));
    });

    test('includes authentication check', () {
      final result = generateJWTHandler();
      expect(result, contains('isAuthenticated'));
    });

    test('uses flutter_secure_storage', () {
      final result = generateJWTHandler();
      expect(result, contains('flutter_secure_storage'));
      expect(result, contains('FlutterSecureStorage'));
    });

    test('includes token refresh interceptor', () {
      final result = generateJWTHandler();
      expect(result, contains('TokenRefreshInterceptor'));
      expect(result, contains('getAuthHeaders'));
    });

    test('includes proper documentation', () {
      final result = generateJWTHandler();
      expect(result, contains('///'));
      expect(result, contains('Usage:'));
    });
  });

  group('generateOAuthHelper', () {
    test('generates valid Dart code', () {
      final result = generateOAuthHelper();
      expect(result, isNotEmpty);
      expect(result, contains('class OAuthHelper'));
    });

    test('includes authorization URL generation', () {
      final result = generateOAuthHelper();
      expect(result, contains('getAuthorizationUrl'));
      expect(result, contains('scopes'));
    });

    test('includes PKCE support', () {
      final result = generateOAuthHelper();
      expect(result, contains('PKCE'));
      expect(result, contains('code_verifier'));
      expect(result, contains('code_challenge'));
    });

    test('includes state parameter for CSRF protection', () {
      final result = generateOAuthHelper();
      expect(result, contains('state'));
      expect(result, contains('validateState'));
    });

    test('includes token exchange method', () {
      final result = generateOAuthHelper();
      expect(result, contains('exchangeCodeForTokens'));
    });

    test('includes token refresh method', () {
      final result = generateOAuthHelper();
      expect(result, contains('refreshAccessToken'));
    });

    test('includes OAuth tokens model', () {
      final result = generateOAuthHelper();
      expect(result, contains('class OAuthTokens'));
      expect(result, contains('accessToken'));
      expect(result, contains('refreshToken'));
    });

    test('includes predefined OAuth providers', () {
      final result = generateOAuthHelper();
      expect(result, contains('class OAuthProviders'));
      expect(result, contains('google'));
      expect(result, contains('github'));
    });

    test('includes URL launcher integration', () {
      final result = generateOAuthHelper();
      expect(result, contains('launchAuthorizationUrl'));
      expect(result, contains('url_launcher'));
    });

    test('includes proper error handling', () {
      final result = generateOAuthHelper();
      expect(result, contains('throw Exception'));
    });
  });

  group('generateSessionManager', () {
    test('generates valid Dart code', () {
      final result = generateSessionManager();
      expect(result, isNotEmpty);
      expect(result, contains('class SessionManager'));
    });

    test('includes session lifecycle methods', () {
      final result = generateSessionManager();
      expect(result, contains('startSession'));
      expect(result, contains('endSession'));
    });

    test('includes activity tracking', () {
      final result = generateSessionManager();
      expect(result, contains('recordActivity'));
      expect(result, contains('_lastActivity'));
    });

    test('includes timeout functionality', () {
      final result = generateSessionManager();
      expect(result, contains('timeout'));
      expect(result, contains('_timeoutTimer'));
    });

    test('includes session validation', () {
      final result = generateSessionManager();
      expect(result, contains('isSessionValid'));
      expect(result, contains('isActive'));
    });

    test('includes time until timeout calculation', () {
      final result = generateSessionManager();
      expect(result, contains('timeUntilTimeout'));
    });

    test('includes session restoration', () {
      final result = generateSessionManager();
      expect(result, contains('restoreSession'));
    });

    test('includes warning before timeout', () {
      final result = generateSessionManager();
      expect(result, contains('warningBefore'));
      expect(result, contains('onWarning'));
    });

    test('includes activity tracker widget', () {
      final result = generateSessionManager();
      expect(result, contains('class ActivityTracker'));
      expect(result, contains('GestureDetector'));
    });

    test('extends ChangeNotifier', () {
      final result = generateSessionManager();
      expect(result, contains('extends ChangeNotifier'));
      expect(result, contains('notifyListeners'));
    });
  });

  group('generateBiometricAuth', () {
    test('generates valid Dart code', () {
      final result = generateBiometricAuth();
      expect(result, isNotEmpty);
      expect(result, contains('class BiometricAuth'));
    });

    test('includes availability check', () {
      final result = generateBiometricAuth();
      expect(result, contains('isAvailable'));
      expect(result, contains('canCheckBiometrics'));
    });

    test('includes biometric type detection', () {
      final result = generateBiometricAuth();
      expect(result, contains('getAvailableBiometrics'));
      expect(result, contains('BiometricType'));
    });

    test('includes face recognition support check', () {
      final result = generateBiometricAuth();
      expect(result, contains('supportsFaceRecognition'));
      expect(result, contains('BiometricType.face'));
    });

    test('includes fingerprint support check', () {
      final result = generateBiometricAuth();
      expect(result, contains('supportsFingerprint'));
      expect(result, contains('BiometricType.fingerprint'));
    });

    test('includes authentication method', () {
      final result = generateBiometricAuth();
      expect(result, contains('authenticate'));
      expect(result, contains('localizedReason'));
    });

    test('includes platform-specific messages', () {
      final result = generateBiometricAuth();
      expect(result, contains('AndroidAuthMessages'));
      expect(result, contains('IOSAuthMessages'));
    });

    test('includes sensitive operation authentication', () {
      final result = generateBiometricAuth();
      expect(result, contains('authenticateForSensitiveOperation'));
      expect(result, contains('biometricOnly'));
    });

    test('includes stop authentication method', () {
      final result = generateBiometricAuth();
      expect(result, contains('stopAuthentication'));
    });

    test('uses local_auth package', () {
      final result = generateBiometricAuth();
      expect(result, contains('local_auth'));
      expect(result, contains('LocalAuthentication'));
    });
  });

  group('generateSecureStorage', () {
    test('generates valid Dart code', () {
      final result = generateSecureStorage();
      expect(result, isNotEmpty);
      expect(result, contains('class SecureCredentialStorage'));
    });

    test('includes credential save method', () {
      final result = generateSecureStorage();
      expect(result, contains('saveCredentials'));
      expect(result, contains('username'));
      expect(result, contains('password'));
    });

    test('includes credential retrieval', () {
      final result = generateSecureStorage();
      expect(result, contains('getCredentials'));
    });

    test('includes email storage', () {
      final result = generateSecureStorage();
      expect(result, contains('saveEmail'));
      expect(result, contains('getEmail'));
    });

    test('includes API key storage', () {
      final result = generateSecureStorage();
      expect(result, contains('saveApiKey'));
      expect(result, contains('getApiKey'));
    });

    test('includes custom value storage', () {
      final result = generateSecureStorage();
      expect(result, contains('saveValue'));
      expect(result, contains('getValue'));
    });

    test('includes clear methods', () {
      final result = generateSecureStorage();
      expect(result, contains('clearCredentials'));
      expect(result, contains('clearAll'));
    });

    test('includes credential existence check', () {
      final result = generateSecureStorage();
      expect(result, contains('hasCredentials'));
    });

    test('includes Credentials model', () {
      final result = generateSecureStorage();
      expect(result, contains('class Credentials'));
    });

    test('uses flutter_secure_storage with platform options', () {
      final result = generateSecureStorage();
      expect(result, contains('FlutterSecureStorage'));
      expect(result, contains('AndroidOptions'));
      expect(result, contains('IOSOptions'));
    });
  });

  group('generateAuthExamples', () {
    test('generates valid Dart code', () {
      final result = generateAuthExamples();
      expect(result, isNotEmpty);
    });

    test('includes login example', () {
      final result = generateAuthExamples();
      expect(result, contains('class LoginExample'));
      expect(result, contains('_login'));
    });

    test('includes biometric login example', () {
      final result = generateAuthExamples();
      expect(result, contains('class BiometricLoginExample'));
    });

    test('includes JWT usage example', () {
      final result = generateAuthExamples();
      expect(result, contains('JWTHandler'));
    });

    test('includes session management example', () {
      final result = generateAuthExamples();
      expect(result, contains('SessionManager'));
    });

    test('includes best practices section', () {
      final result = generateAuthExamples();
      expect(result, contains('Best Practices'));
      expect(result, contains('HTTPS'));
    });

    test('includes common pitfalls section', () {
      final result = generateAuthExamples();
      expect(result, contains('Common Pitfalls'));
      expect(result, contains('SharedPreferences'));
    });

    test('includes token refresh guidance', () {
      final result = generateAuthExamples();
      expect(result, contains('token refresh'));
    });

    test('includes PKCE recommendations', () {
      final result = generateAuthExamples();
      expect(result, contains('PKCE'));
    });

    test('includes secure storage recommendations', () {
      final result = generateAuthExamples();
      expect(result, contains('secure storage'));
      expect(result, contains('flutter_secure_storage'));
    });

    test('includes biometric authentication guidance', () {
      final result = generateAuthExamples();
      expect(result, contains('biometric'));
    });
  });

  group('Code Quality', () {
    test('all generators return non-empty strings', () {
      expect(generateJWTHandler(), isNotEmpty);
      expect(generateOAuthHelper(), isNotEmpty);
      expect(generateSessionManager(), isNotEmpty);
      expect(generateBiometricAuth(), isNotEmpty);
      expect(generateSecureStorage(), isNotEmpty);
      expect(generateAuthExamples(), isNotEmpty);
    });

    test('all generators include proper imports', () {
      expect(generateJWTHandler(), contains('import'));
      expect(generateOAuthHelper(), contains('import'));
      expect(generateSessionManager(), contains('import'));
      expect(generateBiometricAuth(), contains('import'));
      expect(generateSecureStorage(), contains('import'));
    });

    test('all generators include class definitions', () {
      expect(generateJWTHandler(), contains('class'));
      expect(generateOAuthHelper(), contains('class'));
      expect(generateSessionManager(), contains('class'));
      expect(generateBiometricAuth(), contains('class'));
      expect(generateSecureStorage(), contains('class'));
    });

    test('all generators include documentation comments', () {
      expect(generateJWTHandler(), contains('///'));
      expect(generateOAuthHelper(), contains('///'));
      expect(generateSessionManager(), contains('///'));
      expect(generateBiometricAuth(), contains('///'));
      expect(generateSecureStorage(), contains('///'));
    });

    test('generators use proper Dart naming conventions', () {
      final jwt = generateJWTHandler();
      expect(jwt, contains('JWTHandler')); // PascalCase for classes
      expect(jwt, contains('saveTokens')); // camelCase for methods
    });
  });

  group('Integration Tests', () {
    test('JWT handler integrates with OAuth helper', () {
      final jwt = generateJWTHandler();
      final oauth = generateOAuthHelper();
      expect(jwt, contains('String'));
      expect(oauth, contains('OAuthTokens'));
    });

    test('session manager integrates with JWT handler', () {
      final session = generateSessionManager();
      final jwt = generateJWTHandler();
      expect(session, contains('userId'));
      expect(jwt, contains('getUserIdFromToken'));
    });

    test('biometric auth integrates with secure storage', () {
      final biometric = generateBiometricAuth();
      final storage = generateSecureStorage();
      expect(biometric, contains('authenticate'));
      expect(storage, contains('saveCredentials'));
    });

    test('examples reference all main classes', () {
      final examples = generateAuthExamples();
      expect(examples, contains('JWTHandler'));
      expect(examples, contains('SessionManager'));
      expect(examples, contains('BiometricAuth'));
    });

    test('all generators follow consistent error handling', () {
      expect(generateJWTHandler(), contains('catch'));
      expect(generateOAuthHelper(), contains('Exception'));
      expect(generateSessionManager(), contains('try'));
      expect(generateBiometricAuth(), contains('catch'));
    });
  });

  group('Feature Coverage', () {
    test('JWT handling covers complete token lifecycle', () {
      final result = generateJWTHandler();
      expect(result, contains('save')); // Save tokens
      expect(result, contains('get')); // Get tokens
      expect(result, contains('refresh')); // Refresh tokens
      expect(result, contains('clear')); // Clear tokens
      expect(result, contains('decode')); // Decode tokens
    });

    test('OAuth covers complete authorization flow', () {
      final result = generateOAuthHelper();
      expect(result, contains('authorize')); // Authorization
      expect(result, contains('exchange')); // Token exchange
      expect(result, contains('refresh')); // Token refresh
      expect(result, contains('PKCE')); // PKCE support
      expect(result, contains('state')); // CSRF protection
    });

    test('session manager covers complete session lifecycle', () {
      final result = generateSessionManager();
      expect(result, contains('start')); // Start session
      expect(result, contains('end')); // End session
      expect(result, contains('activity')); // Track activity
      expect(result, contains('timeout')); // Handle timeout
      expect(result, contains('restore')); // Restore session
    });

    test('biometric auth covers all authentication types', () {
      final result = generateBiometricAuth();
      expect(result, contains('face')); // Face recognition
      expect(result, contains('fingerprint')); // Fingerprint
      expect(result, contains('available')); // Availability check
      expect(result, contains('authenticate')); // Authentication
    });

    test('secure storage covers all credential types', () {
      final result = generateSecureStorage();
      expect(result, contains('username'));
      expect(result, contains('password'));
      expect(result, contains('email'));
      expect(result, contains('apiKey'));
      expect(result, contains('custom')); // Custom values
    });
  });

  group('Best Practices', () {
    test('generators follow Flutter async patterns', () {
      expect(generateJWTHandler(), contains('Future'));
      expect(generateOAuthHelper(), contains('async'));
      expect(generateSessionManager(), contains('await'));
    });

    test('generators use proper null safety', () {
      expect(generateJWTHandler(), contains('?'));
      expect(generateSecureStorage(), contains('null'));
    });

    test('generators include proper type annotations', () {
      final jwt = generateJWTHandler();
      expect(jwt, contains('String'));
      expect(jwt, contains('bool'));
      expect(jwt, contains('Map<String, dynamic>'));
    });

    test('generators use const constructors where appropriate', () {
      expect(generateJWTHandler(), contains('const'));
      expect(generateSecureStorage(), contains('const'));
    });

    test('generators implement proper resource disposal', () {
      expect(generateSessionManager(), contains('dispose'));
      expect(generateSessionManager(), contains('cancel'));
    });
  });
}
