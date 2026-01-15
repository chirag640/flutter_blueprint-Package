import 'package:path/path.dart' as p;
import '../config/blueprint_config.dart';

/// Generates Social Authentication templates for Google, Apple, and Facebook.
class SocialAuthTemplates {
  /// Generates all social auth-related files
  static Map<String, String> generate(BlueprintConfig config) {
    final files = <String, String>{};
    final appName = config.appName;

    files[p.join('lib', 'core', 'auth', 'social', 'google_auth_service.dart')] =
        _googleAuthService(appName);
    files[p.join('lib', 'core', 'auth', 'social', 'apple_auth_service.dart')] =
        _appleAuthService(appName);
    files[p.join(
            'lib', 'core', 'auth', 'social', 'facebook_auth_service.dart')] =
        _facebookAuthService(appName);
    files[p.join('lib', 'core', 'auth', 'social', 'social_auth_service.dart')] =
        _socialAuthService(appName);
    files[p.join('lib', 'core', 'auth', 'social', 'social_user.dart')] =
        _socialUser(appName);

    return files;
  }

  /// Returns the dependencies required for social auth
  static Map<String, String> getDependencies() {
    return {
      'google_sign_in': '^6.2.1',
      'sign_in_with_apple': '^6.1.1',
      'flutter_facebook_auth': '^7.0.1',
    };
  }

  static String _googleAuthService(String appName) => '''
import 'package:google_sign_in/google_sign_in.dart';
import 'social_user.dart';

/// Service for Google Sign-In authentication.
class GoogleAuthService {
  GoogleAuthService({
    List<String>? scopes,
  }) : _googleSignIn = GoogleSignIn(
          scopes: scopes ?? ['email', 'profile'],
        );

  final GoogleSignIn _googleSignIn;

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get currently signed in user (if any)
  Future<SocialUser?> getCurrentUser() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    return _toSocialUser(account);
  }

  /// Sign in with Google
  Future<SocialUser?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      return _toSocialUser(account);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in silently (for returning users)
  Future<SocialUser?> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return null;
      return _toSocialUser(account);
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Disconnect (revoke access)
  Future<void> disconnect() async {
    await _googleSignIn.disconnect();
  }

  /// Get authentication tokens
  Future<GoogleAuthTokens?> getTokens() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;

    final auth = await account.authentication;
    return GoogleAuthTokens(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
  }

  SocialUser _toSocialUser(GoogleSignInAccount account) {
    return SocialUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
      provider: SocialAuthProvider.google,
    );
  }
}

/// Google authentication tokens
class GoogleAuthTokens {
  const GoogleAuthTokens({
    this.idToken,
    this.accessToken,
  });

  final String? idToken;
  final String? accessToken;
}
''';

  static String _appleAuthService(String appName) => '''
import 'dart:io';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'social_user.dart';

/// Service for Apple Sign-In authentication.
class AppleAuthService {
  /// Check if Apple Sign-In is available
  Future<bool> isAvailable() async {
    return Platform.isIOS && await SignInWithApple.isAvailable();
  }

  /// Sign in with Apple
  Future<SocialUser?> signIn({
    List<AppleIDAuthorizationScopes>? scopes,
  }) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: scopes ??
            [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
      );

      return SocialUser(
        id: credential.userIdentifier ?? '',
        email: credential.email,
        displayName: _getDisplayName(credential),
        provider: SocialAuthProvider.apple,
        authorizationCode: credential.authorizationCode,
        identityToken: credential.identityToken,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null; // User cancelled
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  String? _getDisplayName(AuthorizationCredentialAppleID credential) {
    final givenName = credential.givenName;
    final familyName = credential.familyName;

    if (givenName == null && familyName == null) return null;

    return [givenName, familyName]
        .where((name) => name != null && name.isNotEmpty)
        .join(' ');
  }
}
''';

  static String _facebookAuthService(String appName) => '''
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'social_user.dart';

/// Service for Facebook Login authentication.
class FacebookAuthService {
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    final accessToken = await _facebookAuth.accessToken;
    return accessToken != null && !accessToken.isExpired;
  }

  /// Get currently signed in user (if any)
  Future<SocialUser?> getCurrentUser() async {
    final isLoggedIn = await isSignedIn();
    if (!isLoggedIn) return null;

    try {
      final userData = await _facebookAuth.getUserData();
      return _toSocialUser(userData);
    } catch (e) {
      return null;
    }
  }

  /// Sign in with Facebook
  Future<SocialUser?> signIn({
    List<String>? permissions,
  }) async {
    try {
      final result = await _facebookAuth.login(
        permissions: permissions ?? ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        return null;
      }

      final userData = await _facebookAuth.getUserData();
      return _toSocialUser(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _facebookAuth.logOut();
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final token = await _facebookAuth.accessToken;
    return token?.tokenString;
  }

  SocialUser _toSocialUser(Map<String, dynamic> userData) {
    return SocialUser(
      id: userData['id'] as String? ?? '',
      email: userData['email'] as String?,
      displayName: userData['name'] as String?,
      photoUrl: userData['picture']?['data']?['url'] as String?,
      provider: SocialAuthProvider.facebook,
    );
  }
}
''';

  static String _socialAuthService(String appName) => '''
import 'social_user.dart';
import 'google_auth_service.dart';
import 'apple_auth_service.dart';
import 'facebook_auth_service.dart';

/// Unified service for social authentication.
class SocialAuthService {
  SocialAuthService({
    GoogleAuthService? googleAuth,
    AppleAuthService? appleAuth,
    FacebookAuthService? facebookAuth,
  })  : _googleAuth = googleAuth ?? GoogleAuthService(),
        _appleAuth = appleAuth ?? AppleAuthService(),
        _facebookAuth = facebookAuth ?? FacebookAuthService();

  final GoogleAuthService _googleAuth;
  final AppleAuthService _appleAuth;
  final FacebookAuthService _facebookAuth;

  /// Get the Google auth service
  GoogleAuthService get google => _googleAuth;

  /// Get the Apple auth service
  AppleAuthService get apple => _appleAuth;

  /// Get the Facebook auth service
  FacebookAuthService get facebook => _facebookAuth;

  /// Sign in with a specific provider
  Future<SocialUser?> signIn(SocialAuthProvider provider) async {
    switch (provider) {
      case SocialAuthProvider.google:
        return await _googleAuth.signIn();
      case SocialAuthProvider.apple:
        return await _appleAuth.signIn();
      case SocialAuthProvider.facebook:
        return await _facebookAuth.signIn();
    }
  }

  /// Sign out from a specific provider
  Future<void> signOut(SocialAuthProvider provider) async {
    switch (provider) {
      case SocialAuthProvider.google:
        await _googleAuth.signOut();
        break;
      case SocialAuthProvider.apple:
        // Apple doesn't have a sign out method
        break;
      case SocialAuthProvider.facebook:
        await _facebookAuth.signOut();
        break;
    }
  }

  /// Sign out from all providers
  Future<void> signOutAll() async {
    await _googleAuth.signOut();
    await _facebookAuth.signOut();
  }

  /// Check if signed in with any provider
  Future<SocialAuthProvider?> getSignedInProvider() async {
    if (await _googleAuth.isSignedIn()) {
      return SocialAuthProvider.google;
    }
    if (await _facebookAuth.isSignedIn()) {
      return SocialAuthProvider.facebook;
    }
    return null;
  }

  /// Get current user from any signed-in provider
  Future<SocialUser?> getCurrentUser() async {
    var user = await _googleAuth.getCurrentUser();
    if (user != null) return user;

    user = await _facebookAuth.getCurrentUser();
    if (user != null) return user;

    return null;
  }

  /// Try silent sign in with Google
  Future<SocialUser?> trySilentSignIn() async {
    return await _googleAuth.signInSilently();
  }
}
''';

  static String _socialUser(String appName) => '''
/// User model for social authentication.
class SocialUser {
  const SocialUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    this.authorizationCode,
    this.identityToken,
  });

  /// Unique identifier from the provider
  final String id;

  /// User's email address
  final String? email;

  /// User's display name
  final String? displayName;

  /// URL to user's profile photo
  final String? photoUrl;

  /// The authentication provider
  final SocialAuthProvider provider;

  /// Authorization code (Apple Sign-In)
  final String? authorizationCode;

  /// Identity token (Apple Sign-In)
  final String? identityToken;

  /// Get first name (if display name is available)
  String? get firstName {
    if (displayName == null) return null;
    final parts = displayName!.split(' ');
    return parts.isNotEmpty ? parts.first : null;
  }

  /// Get last name (if display name is available)
  String? get lastName {
    if (displayName == null) return null;
    final parts = displayName!.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : null;
  }

  /// Get initials from display name
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email?.substring(0, 1).toUpperCase() ?? '?';
    }
    final parts = displayName!.split(' ');
    if (parts.length >= 2) {
      return '\${parts.first[0]}\${parts.last[0]}'.toUpperCase();
    }
    return displayName![0].toUpperCase();
  }

  /// Copy with different values
  SocialUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    SocialAuthProvider? provider,
    String? authorizationCode,
    String? identityToken,
  }) {
    return SocialUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      identityToken: identityToken ?? this.identityToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider.name,
    };
  }

  factory SocialUser.fromJson(Map<String, dynamic> json) {
    return SocialUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: SocialAuthProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => SocialAuthProvider.google,
      ),
    );
  }

  @override
  String toString() {
    return 'SocialUser(id: \$id, email: \$email, displayName: \$displayName, provider: \$provider)';
  }
}

/// Social authentication providers
enum SocialAuthProvider {
  google,
  apple,
  facebook,
}
''';
}
