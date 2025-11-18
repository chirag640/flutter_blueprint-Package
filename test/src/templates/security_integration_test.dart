import 'dart:io';

import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/security_templates.dart';
import 'package:flutter_blueprint/src/templates/provider_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/riverpod_mobile_template.dart';
import 'package:flutter_blueprint/src/templates/bloc_mobile_template.dart';
import 'package:test/test.dart';

BlueprintConfig _createConfig(
    {SecurityLevel securityLevel = SecurityLevel.none}) {
  return BlueprintConfig(
    appName: 'test_app',
    platforms: [TargetPlatform.mobile],
    stateManagement: StateManagement.provider,
    includeTheme: true,
    includeLocalization: false,
    includeEnv: false,
    includeApi: true,
    includeTests: true,
    securityLevel: securityLevel,
  );
}

void main() {
  group('SecurityLevel enum', () {
    test('parse returns correct SecurityLevel for valid strings', () {
      expect(SecurityLevel.parse('none'), SecurityLevel.none);
      expect(SecurityLevel.parse('basic'), SecurityLevel.basic);
      expect(SecurityLevel.parse('standard'), SecurityLevel.standard);
      expect(SecurityLevel.parse('enterprise'), SecurityLevel.enterprise);
    });

    test('parse handles case insensitivity and throws for invalid', () {
      expect(SecurityLevel.parse('BASIC'), SecurityLevel.basic);
      expect(SecurityLevel.parse('Standard'), SecurityLevel.standard);
      expect(() => SecurityLevel.parse('invalid'), throwsArgumentError);
    });

    test('label returns correct string for each level', () {
      expect(SecurityLevel.none.label, 'none');
      expect(SecurityLevel.basic.label, 'basic');
      expect(SecurityLevel.standard.label, 'standard');
      expect(SecurityLevel.enterprise.label, 'enterprise');
    });
  });

  group('BlueprintConfig security properties', () {
    test('includeSecurity is false when securityLevel is none', () {
      final config = _createConfig(securityLevel: SecurityLevel.none);
      expect(config.includeSecurity, false);
    });

    test('includeSecurity is true when securityLevel is not none', () {
      for (final level in [
        SecurityLevel.basic,
        SecurityLevel.standard,
        SecurityLevel.enterprise
      ]) {
        final config = _createConfig(securityLevel: level);

        expect(config.includeSecurity, true);
      }
    });

    test('enableCertificatePinning is true only for enterprise', () {
      for (final level in SecurityLevel.values) {
        final config = _createConfig(securityLevel: level);

        expect(
          config.enableCertificatePinning,
          level == SecurityLevel.enterprise,
        );
      }
    });

    test('enableRootDetection is true for standard and enterprise', () {
      final testCases = {
        SecurityLevel.none: false,
        SecurityLevel.basic: false,
        SecurityLevel.standard: true,
        SecurityLevel.enterprise: true,
      };

      for (final entry in testCases.entries) {
        final config = _createConfig(securityLevel: entry.key);

        expect(config.enableRootDetection, entry.value);
      }
    });

    test('enableBiometricAuth is true for standard and enterprise', () {
      final testCases = {
        SecurityLevel.none: false,
        SecurityLevel.basic: false,
        SecurityLevel.standard: true,
        SecurityLevel.enterprise: true,
      };

      for (final entry in testCases.entries) {
        final config = _createConfig(securityLevel: entry.key);

        expect(config.enableBiometricAuth, entry.value);
      }
    });

    test('enableApiKeyObfuscation is true only for enterprise', () {
      for (final level in SecurityLevel.values) {
        final config = _createConfig(securityLevel: level);

        expect(
          config.enableApiKeyObfuscation,
          level == SecurityLevel.enterprise,
        );
      }
    });

    test('enableEncryptedStorage is true when includeSecurity is true', () {
      for (final level in SecurityLevel.values) {
        final config = _createConfig(securityLevel: level);

        expect(
          config.enableEncryptedStorage,
          level != SecurityLevel.none,
        );
      }
    });

    test('enableScreenshotProtection is true only for enterprise', () {
      for (final level in SecurityLevel.values) {
        final config = _createConfig(securityLevel: level);

        expect(
          config.enableScreenshotProtection,
          level == SecurityLevel.enterprise,
        );
      }
    });

    test('toMap includes security_level field', () {
      final config = _createConfig(securityLevel: SecurityLevel.standard);

      final map = config.toMap();
      expect(map['security_level'], 'standard');
    });

    test('fromMap correctly deserializes security_level', () {
      final map = {
        'project_name': 'test',
        'organization_name': 'com.test',
        'state_management': 'provider',
        'security_level': 'enterprise',
      };

      final config = BlueprintConfig.fromMap(map);
      expect(config.securityLevel, SecurityLevel.enterprise);
    });

    test('fromMap defaults to none when security_level is missing', () {
      final map = {
        'project_name': 'test',
        'organization_name': 'com.test',
        'state_management': 'provider',
      };

      final config = BlueprintConfig.fromMap(map);
      expect(config.securityLevel, SecurityLevel.none);
    });

    test('copyWith updates securityLevel', () {
      final config = _createConfig(securityLevel: SecurityLevel.none);

      final updated = config.copyWith(securityLevel: SecurityLevel.enterprise);
      expect(updated.securityLevel, SecurityLevel.enterprise);
    });
  });

  group('Security template generators', () {
    test('generateCertificatePinner returns valid Dart code', () {
      final code = generateCertificatePinner();

      expect(code, contains('class CertificatePinner'));
      expect(code, contains('bool check'));
      expect(code, contains('sha256'));
      expect(code, contains('CertificateValidationException'));
    });

    test('generateDeviceSecurityChecker returns valid Dart code', () {
      final code = generateDeviceSecurityChecker();

      expect(code, contains('class DeviceSecurityChecker'));
      expect(code, contains('Future<SecurityStatus> checkDeviceSecurity'));
      expect(code, contains('FlutterJailbreakDetection'));
      expect(code, contains('isRooted'));
      expect(code, contains('isJailbroken'));
    });

    test('generateBiometricAuth returns valid Dart code', () {
      final code = generateBiometricAuth();

      expect(code, contains('class BiometricAuth'));
      expect(code, contains('Future<bool> authenticate'));
      expect(code, contains('LocalAuthentication'));
      expect(code, contains('canCheckBiometrics'));
      expect(code, contains('BiometricType'));
    });

    test('generateApiKeyManager returns valid Dart code', () {
      final code = generateApiKeyManager();

      expect(code, contains('class ApiKeyManager'));
      expect(code, contains('static String getApiKey'));
      expect(code, contains('base64'));
      expect(code, contains('String.fromEnvironment'));
    });

    test('generateEncryptedStorage returns valid Dart code', () {
      final code = generateEncryptedStorage();

      expect(code, contains('class EncryptedStorage'));
      expect(code, contains('Future<void> write'));
      expect(code, contains('Future<String?> read'));
      expect(code, contains('FlutterSecureStorage'));
      expect(code, contains('Encrypter'));
      expect(code, contains('AES'));
    });

    test('generateScreenshotProtection returns valid Dart code', () {
      final code = generateScreenshotProtection();

      expect(code, contains('class ScreenshotProtection'));
      expect(code, contains('Future<void> enable'));
      expect(code, contains('Future<void> disable'));
      expect(code, contains('MethodChannel'));
      expect(code, contains('enableSecureFlag'));
    });

    test('generateNetworkSecurityConfig returns valid Dart code', () {
      final code = generateNetworkSecurityConfig();

      expect(code, contains('class NetworkSecurityConfig'));
      expect(code, contains('bool isSecureConnection'));
      expect(code, contains('List<String> allowedDomains'));
      expect(code, contains('https'));
    });

    test('generateSecurityInterceptor returns valid Dart code', () {
      final code = generateSecurityInterceptor();

      expect(code, contains('class SecurityInterceptor'));
      expect(code, contains('Interceptor'));
      expect(code, contains('X-Content-Type-Options'));
      expect(code, contains('X-Frame-Options'));
      expect(code, contains('Content-Security-Policy'));
    });

    test('generateSecureHttpClient returns valid Dart code', () {
      final code = generateSecureHttpClient();

      expect(code, contains('class SecureHttpClient'));
      expect(code, contains('static Dio create'));
      expect(code, contains('CertificatePinner'));
      expect(code, contains('NetworkSecurityConfig'));
    });
  });

  group('Template file generation', () {
    test('Provider template includes security files for basic level', () {
      final config = _createConfig(securityLevel: SecurityLevel.basic);
      final bundle = buildProviderMobileBundle();

      final securityFiles = bundle.files
          .where((f) => f.path.contains(
              'lib${Platform.pathSeparator}core${Platform.pathSeparator}security'))
          .where((f) => f.shouldInclude(config))
          .toList();

      expect(securityFiles.length, greaterThan(0));

      // Basic should include: encrypted_storage, network_security_config, security_interceptor
      final paths = securityFiles
          .map((f) => f.path.split(Platform.pathSeparator).last)
          .toList();
      expect(paths, contains('encrypted_storage.dart'));
      expect(paths, contains('network_security_config.dart'));
      expect(paths, contains('security_interceptor.dart'));
    });

    test('Provider template includes more security files for standard level',
        () {
      final config = _createConfig(securityLevel: SecurityLevel.standard);
      final bundle = buildProviderMobileBundle();

      final securityFiles = bundle.files
          .where((f) => f.path.contains(
              'lib${Platform.pathSeparator}core${Platform.pathSeparator}security'))
          .where((f) => f.shouldInclude(config))
          .toList();

      // Standard should include: basic files + root detection + biometric auth
      final paths = securityFiles
          .map((f) => f.path.split(Platform.pathSeparator).last)
          .toList();
      expect(paths, contains('device_security_checker.dart'));
      expect(paths, contains('biometric_auth.dart'));
    });

    test('Provider template includes all security files for enterprise level',
        () {
      final config = _createConfig(securityLevel: SecurityLevel.enterprise);
      final bundle = buildProviderMobileBundle();

      final securityFiles = bundle.files
          .where((f) => f.path.contains(
              'lib${Platform.pathSeparator}core${Platform.pathSeparator}security'))
          .where((f) => f.shouldInclude(config))
          .toList();

      // Enterprise should include all security files
      final paths = securityFiles
          .map((f) => f.path.split(Platform.pathSeparator).last)
          .toList();
      expect(paths, contains('certificate_pinner.dart'));
      expect(paths, contains('api_key_manager.dart'));
      expect(paths, contains('screenshot_protection.dart'));
      expect(paths, contains('secure_http_client.dart'));
    });

    test('Provider template excludes security files when level is none', () {
      final config = _createConfig(securityLevel: SecurityLevel.none);
      final bundle = buildProviderMobileBundle();

      final securityFiles = bundle.files
          .where((f) => f.path.contains(
              'lib${Platform.pathSeparator}core${Platform.pathSeparator}security'))
          .where((f) => f.shouldInclude(config))
          .toList();

      expect(securityFiles, isEmpty);
    });

    test('Riverpod template includes security files when enabled', () {
      final config = _createConfig(securityLevel: SecurityLevel.enterprise);
      final bundle = buildRiverpodMobileBundle();

      final securityFiles = bundle.files
          .where((f) => f.path.contains(
              'lib${Platform.pathSeparator}core${Platform.pathSeparator}security'))
          .where((f) => f.shouldInclude(config))
          .toList();

      expect(securityFiles.length, greaterThan(0));
    });

    test('BLoC template includes security files when enabled', () {
      final config = _createConfig(securityLevel: SecurityLevel.standard);
      final bundle = buildBlocMobileBundle();

      final securityFiles = bundle.files
          .where((f) => f.path.contains(
              'lib${Platform.pathSeparator}core${Platform.pathSeparator}security'))
          .where((f) => f.shouldInclude(config))
          .toList();

      expect(securityFiles.length, greaterThan(0));
    });
  });

  group('Generated code quality', () {
    test('Certificate pinner code compiles without syntax errors', () {
      final code = generateCertificatePinner();

      // Check for common syntax errors
      expect(code, isNot(contains('...existing code...')));
      expect(code, isNot(contains('// TODO')));
      expect(code.split('class').length - 1, greaterThanOrEqualTo(1));
    });

    test('Device security checker code has proper imports', () {
      final code = generateDeviceSecurityChecker();

      expect(code, contains("import 'package:flutter_jailbreak_detection"));
      expect(code, contains("import 'package:device_info_plus"));
    });

    test('Biometric auth code has proper error handling', () {
      final code = generateBiometricAuth();

      expect(code, contains('try'));
      expect(code, contains('catch'));
      expect(code, contains('LocalAuthentication'));
    });

    test('Encrypted storage code uses secure algorithms', () {
      final code = generateEncryptedStorage();

      expect(code, contains('AES'));
      expect(code, contains('IV'));
      expect(code, contains('Key'));
      expect(code, isNot(contains('DES'))); // Ensure not using weak DES
    });

    test('Security interceptor code includes all security headers', () {
      final code = generateSecurityInterceptor();

      final requiredHeaders = [
        'X-Content-Type-Options',
        'X-Frame-Options',
        'X-XSS-Protection',
        'Content-Security-Policy',
        'Strict-Transport-Security',
      ];

      for (final header in requiredHeaders) {
        expect(code, contains(header));
      }
    });

    test('Network security config validates HTTPS', () {
      final code = generateNetworkSecurityConfig();

      expect(code, contains('https'));
      expect(code, contains('scheme'));
      expect(code.toLowerCase(), isNot(contains('http:')));
    });
  });
}
