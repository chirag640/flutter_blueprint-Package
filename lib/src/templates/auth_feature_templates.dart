import '../config/blueprint_config.dart';

/// Generates complete authentication feature with login, register, and token management
class AuthFeatureTemplates {
  /// Generate all auth feature files based on state management type
  static List<AuthTemplateFile> generate(BlueprintConfig config) {
    final files = <AuthTemplateFile>[];

    // Data layer
    files.addAll(_generateDataLayer(config));

    // Domain layer
    files.addAll(_generateDomainLayer(config));

    // Presentation layer
    files.addAll(_generatePresentationLayer(config));

    return files;
  }

  static List<AuthTemplateFile> _generateDataLayer(BlueprintConfig config) {
    return [
      AuthTemplateFile(
        path: 'lib/features/auth/data/models/user_model.dart',
        content: _userModel(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/data/models/auth_response_model.dart',
        content: _authResponseModel(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/data/datasources/auth_remote_data_source.dart',
        content: _authRemoteDataSource(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/data/datasources/auth_local_data_source.dart',
        content: _authLocalDataSource(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/data/repositories/auth_repository_impl.dart',
        content: _authRepositoryImpl(config),
      ),
    ];
  }

  static List<AuthTemplateFile> _generateDomainLayer(BlueprintConfig config) {
    return [
      AuthTemplateFile(
        path: 'lib/features/auth/domain/entities/user_entity.dart',
        content: _userEntity(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/domain/repositories/auth_repository.dart',
        content: _authRepository(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/domain/usecases/login_usecase.dart',
        content: _loginUsecase(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/domain/usecases/register_usecase.dart',
        content: _registerUsecase(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/domain/usecases/logout_usecase.dart',
        content: _logoutUsecase(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/domain/usecases/get_current_user_usecase.dart',
        content: _getCurrentUserUsecase(config),
      ),
    ];
  }

  static List<AuthTemplateFile> _generatePresentationLayer(
      BlueprintConfig config) {
    final files = <AuthTemplateFile>[
      // Login page
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/pages/login_page.dart',
        content: _loginPage(config),
      ),
      // Register page
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/pages/register_page.dart',
        content: _registerPage(config),
      ),
      // Widgets
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/widgets/auth_text_field.dart',
        content: _authTextField(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/widgets/auth_button.dart',
        content: _authButton(config),
      ),
    ];

    // State management specific files
    switch (config.stateManagement) {
      case StateManagement.riverpod:
        files.addAll(_generateRiverpodFiles(config));
        break;
      case StateManagement.provider:
        files.addAll(_generateProviderFiles(config));
        break;
      case StateManagement.bloc:
        files.addAll(_generateBlocFiles(config));
        break;
    }

    return files;
  }

  static List<AuthTemplateFile> _generateRiverpodFiles(BlueprintConfig config) {
    return [
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/providers/auth_provider.dart',
        content: _authProviderRiverpod(config),
      ),
      AuthTemplateFile(
        path:
            'lib/features/auth/presentation/providers/login_form_provider.dart',
        content: _loginFormProviderRiverpod(config),
      ),
      AuthTemplateFile(
        path:
            'lib/features/auth/presentation/providers/register_form_provider.dart',
        content: _registerFormProviderRiverpod(config),
      ),
    ];
  }

  static List<AuthTemplateFile> _generateProviderFiles(BlueprintConfig config) {
    return [
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/provider/auth_provider.dart',
        content: _authProviderProvider(config),
      ),
    ];
  }

  static List<AuthTemplateFile> _generateBlocFiles(BlueprintConfig config) {
    return [
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/bloc/auth_bloc.dart',
        content: _authBloc(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/bloc/auth_event.dart',
        content: _authEvent(config),
      ),
      AuthTemplateFile(
        path: 'lib/features/auth/presentation/bloc/auth_state.dart',
        content: _authState(config),
      ),
    ];
  }

  // ========== DOMAIN LAYER ==========

  static String _userEntity(BlueprintConfig config) {
    return """import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
  });

  final String id;
  final String email;
  final String? name;
  final String? avatar;

  @override
  List<Object?> get props => [id, email, name, avatar];
}
""";
  }

  static String _authRepository(BlueprintConfig config) {
    return """import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logout the current user
  Future<void> logout();

  /// Get the currently logged in user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Refresh authentication token
  Future<bool> refreshToken();
}
""";
  }

  static String _loginUsecase(BlueprintConfig config) {
    return """import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class LoginUsecase {
  LoginUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute login
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(
      email: email,
      password: password,
    );
  }
}
""";
  }

  static String _registerUsecase(BlueprintConfig config) {
    return """import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUsecase {
  RegisterUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute registration
  Future<UserEntity> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}
""";
  }

  static String _logoutUsecase(BlueprintConfig config) {
    return """import '../repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUsecase {
  LogoutUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute logout
  Future<void> call() async {
    await _repository.logout();
  }
}
""";
  }

  static String _getCurrentUserUsecase(BlueprintConfig config) {
    return """import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case to get current authenticated user
class GetCurrentUserUsecase {
  GetCurrentUserUsecase(this._repository);

  final AuthRepository _repository;

  /// Execute get current user
  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}
""";
  }

  // ========== DATA LAYER ==========

  static String _userModel(BlueprintConfig config) {
    return """import '../../domain/entities/user_entity.dart';

/// User data model
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.avatar,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
    };
  }

  /// Create copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }
}
""";
  }

  static String _authResponseModel(BlueprintConfig config) {
    return """import 'user_model.dart';

/// Authentication response model from API
class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  final UserModel user;
  final String accessToken;
  final String? refreshToken;

  /// Create from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken']?.toString() ?? json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}
""";
  }

  static String _authRemoteDataSource(BlueprintConfig config) {
    return """import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(String email, String password, String name);
  Future<UserModel> getCurrentUser();
  Future<bool> refreshToken(String refreshToken);
}

/// Implementation of authentication remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Login failed', e, e.stackTrace, 'AuthRemoteDataSource');
      throw Exception('Login failed: \${e.message}');
    }
  }

  @override
  Future<AuthResponseModel> register(String email, String password, String name) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Registration failed', e, e.stackTrace, 'AuthRemoteDataSource');
      throw Exception('Registration failed: \${e.message}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Get user failed', e, e.stackTrace, 'AuthRemoteDataSource');
      throw Exception('Failed to get user: \${e.message}');
    }
  }

  @override
  Future<bool> refreshToken(String refreshToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return true;
    } on DioException catch (e) {
      AppLogger.error('Token refresh failed', e, e.stackTrace, 'AuthRemoteDataSource');
      return false;
    }
  }
}
""";
  }

  static String _authLocalDataSource(BlueprintConfig config) {
    return """import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';
import 'dart:convert';

/// Local data source for authentication (caching tokens and user data)
abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String? refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

/// Implementation of authentication local data source
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required this.localStorage,
    required this.secureStorage,
  });

  final LocalStorage localStorage;
  final SecureStorage secureStorage;

  @override
  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await secureStorage.write(AppConstants.keyAccessToken, accessToken);
    if (refreshToken != null) {
      await secureStorage.write(AppConstants.keyRefreshToken, refreshToken);
    }
    AppLogger.debug('Tokens saved', 'AuthLocalDataSource');
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(AppConstants.keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(AppConstants.keyAccessToken);
    await secureStorage.delete(AppConstants.keyRefreshToken);
    AppLogger.debug('Tokens cleared', 'AuthLocalDataSource');
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await localStorage.setString('cached_user', jsonEncode(user.toJson()));
    AppLogger.debug('User cached locally', 'AuthLocalDataSource');
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = await localStorage.getString('cached_user');
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Failed to parse cached user', e, null, 'AuthLocalDataSource');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await localStorage.remove('cached_user');
    AppLogger.debug('Cached user cleared', 'AuthLocalDataSource');
  }
}
""";
  }

  static String _authRepositoryImpl(BlueprintConfig config) {
    return """import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login via API
      final authResponse = await remoteDataSource.login(email, password);

      // Save tokens and user data locally
      await localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      await localDataSource.saveUser(authResponse.user);

      AppLogger.success('Login successful', 'AuthRepository');
      return authResponse.user;
    } catch (e) {
      AppLogger.error('Login failed in repository', e, null, 'AuthRepository');
      rethrow;
    }
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Register via API
      final authResponse =
          await remoteDataSource.register(email, password, name);

      // Save tokens and user data locally
      await localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      await localDataSource.saveUser(authResponse.user);

      AppLogger.success('Registration successful', 'AuthRepository');
      return authResponse.user;
    } catch (e) {
      AppLogger.error('Registration failed in repository', e, null, 'AuthRepository');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear local data
      await localDataSource.clearTokens();
      await localDataSource.clearUser();

      AppLogger.success('Logout successful', 'AuthRepository');
    } catch (e) {
      AppLogger.error('Logout failed', e, null, 'AuthRepository');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }

      // If not in cache, fetch from API
      final token = await localDataSource.getAccessToken();
      if (token == null) {
        return null;
      }

      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);

      return user;
    } catch (e) {
      AppLogger.error('Failed to get current user', e, null, 'AuthRepository');
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final success = await remoteDataSource.refreshToken(refreshToken);
      return success;
    } catch (e) {
      AppLogger.error('Token refresh failed', e, null, 'AuthRepository');
      return false;
    }
  }
}
""";
  }

  // ========== PRESENTATION LAYER - RIVERPOD ==========

  static String _authProviderRiverpod(BlueprintConfig config) {
    return """import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// ========== DATA SOURCES ==========

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    localStorage: ref.watch(localStorageProvider),
    secureStorage: SecureStorage.instance,
  );
});

// ========== REPOSITORY ==========

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// ========== USE CASES ==========

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.watch(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(ref.watch(authRepositoryProvider));
});

// ========== AUTH STATE ==========

/// Authentication state
class AuthState {
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  final UserEntity? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    UserEntity? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ========== AUTH NOTIFIER ==========

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  final Ref _ref;

  /// Check if user is authenticated on app start
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final usecase = _ref.read(getCurrentUserUsecaseProvider);
      final user = await usecase();

      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final usecase = _ref.read(loginUsecaseProvider);
      final user = await usecase(email: email, password: password);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Register new user
  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final usecase = _ref.read(registerUsecaseProvider);
      final user = await usecase(
        email: email,
        password: password,
        name: name,
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final usecase = _ref.read(logoutUsecaseProvider);
      await usecase();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
""";
  }

  static String _loginFormProviderRiverpod(BlueprintConfig config) {
    return """import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login form state
class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.obscurePassword = true,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;

  LoginFormState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? obscurePassword,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;
}

/// Login form notifier
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  bool validate() {
    String? emailError;
    String? passwordError;

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(state.email)) {
      emailError = 'Invalid email format';
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
    } else if (state.password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
    );

    return emailError == null && passwordError == null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$').hasMatch(email);
  }

  void reset() {
    state = const LoginFormState();
  }
}

/// Provider for login form state
final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  return LoginFormNotifier();
});
""";
  }

  static String _registerFormProviderRiverpod(BlueprintConfig config) {
    return """import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Register form state
class RegisterFormState {
  const RegisterFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  RegisterFormState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) {
    return RegisterFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }

  bool get isValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      nameError == null &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null;
}

/// Register form notifier
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  RegisterFormNotifier() : super(const RegisterFormState());

  void setName(String name) {
    state = state.copyWith(name: name, nameError: null);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(
        confirmPassword: confirmPassword, confirmPasswordError: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state =
        state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  bool validate() {
    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmPasswordError;

    if (state.name.isEmpty) {
      nameError = 'Name is required';
    }

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(state.email)) {
      emailError = 'Invalid email format';
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
    } else if (state.password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    if (state.confirmPassword.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
    } else if (state.password != state.confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    state = state.copyWith(
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$').hasMatch(email);
  }

  void reset() {
    state = const RegisterFormState();
  }
}

/// Provider for register form state
final registerFormProvider = StateNotifierProvider.autoDispose<
    RegisterFormNotifier, RegisterFormState>((ref) {
  return RegisterFormNotifier();
});
""";
  }

  // ========== PRESENTATION LAYER - PROVIDER & BLOC ==========

  static String _authProviderProvider(BlueprintConfig config) {
    // Simplified for Provider pattern - will be expanded if needed
    return """// Provider pattern implementation for auth
// TODO: Implement auth provider using ChangeNotifier
""";
  }

  static String _authBloc(BlueprintConfig config) {
    // Simplified for BLoC pattern - will be expanded if needed
    return """// BLoC pattern implementation for auth
// TODO: Implement auth bloc
""";
  }

  static String _authEvent(BlueprintConfig config) {
    return """// BLoC auth events
// TODO: Implement auth events
""";
  }

  static String _authState(BlueprintConfig config) {
    return """// BLoC auth state
// TODO: Implement auth state
""";
  }

  // ========== PRESENTATION LAYER - PAGES ==========

  static String _loginPage(BlueprintConfig config) {
    return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/login_form_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

/// Login page
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final formState = ref.watch(loginFormProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Title
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Email field
                AuthTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  value: formState.email,
                  errorText: formState.emailError,
                  onChanged: (value) {
                    ref.read(loginFormProvider.notifier).setEmail(value);
                  },
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Password field
                AuthTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  value: formState.password,
                  errorText: formState.passwordError,
                  obscureText: formState.obscurePassword,
                  onChanged: (value) {
                    ref.read(loginFormProvider.notifier).setPassword(value);
                  },
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: formState.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    ref
                        .read(loginFormProvider.notifier)
                        .togglePasswordVisibility();
                  },
                ),
                const SizedBox(height: 24),

                // Error message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Login button
                AuthButton(
                  label: 'Login',
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    // Validate form
                    if (!ref.read(loginFormProvider.notifier).validate()) {
                      return;
                    }

                    // Perform login
                    final success = await ref.read(authProvider.notifier).login(
                          formState.email,
                          formState.password,
                        );

                    if (success && context.mounted) {
                      // Navigate to home on success
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/register');
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
""";
  }

  static String _registerPage(BlueprintConfig config) {
    return """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/register_form_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

/// Register page
class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final formState = ref.watch(registerFormProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Title
                Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Name field
                AuthTextField(
                  label: 'Full Name',
                  hintText: 'Enter your name',
                  value: formState.name,
                  errorText: formState.nameError,
                  onChanged: (value) {
                    ref.read(registerFormProvider.notifier).setName(value);
                  },
                  prefixIcon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),

                // Email field
                AuthTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  value: formState.email,
                  errorText: formState.emailError,
                  onChanged: (value) {
                    ref.read(registerFormProvider.notifier).setEmail(value);
                  },
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Password field
                AuthTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  value: formState.password,
                  errorText: formState.passwordError,
                  obscureText: formState.obscurePassword,
                  onChanged: (value) {
                    ref.read(registerFormProvider.notifier).setPassword(value);
                  },
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: formState.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    ref
                        .read(registerFormProvider.notifier)
                        .togglePasswordVisibility();
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                AuthTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  value: formState.confirmPassword,
                  errorText: formState.confirmPasswordError,
                  obscureText: formState.obscureConfirmPassword,
                  onChanged: (value) {
                    ref
                        .read(registerFormProvider.notifier)
                        .setConfirmPassword(value);
                  },
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: formState.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconTap: () {
                    ref
                        .read(registerFormProvider.notifier)
                        .toggleConfirmPasswordVisibility();
                  },
                ),
                const SizedBox(height: 24),

                // Error message
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Register button
                AuthButton(
                  label: 'Register',
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    // Validate form
                    if (!ref.read(registerFormProvider.notifier).validate()) {
                      return;
                    }

                    // Perform registration
                    final success =
                        await ref.read(authProvider.notifier).register(
                              formState.email,
                              formState.password,
                              formState.name,
                            );

                    if (success && context.mounted) {
                      // Navigate to home on success
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
""";
  }

  // ========== PRESENTATION LAYER - WIDGETS ==========

  static String _authTextField(BlueprintConfig config) {
    return """import 'package:flutter/material.dart';

/// Custom text field for authentication forms
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
  });

  final String label;
  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconTap,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}
""";
  }

  static String _authButton(BlueprintConfig config) {
    return """import 'package:flutter/material.dart';

/// Custom button for authentication forms
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
""";
  }
}

/// Template file model for auth feature
class AuthTemplateFile {
  const AuthTemplateFile({
    required this.path,
    required this.content,
  });

  final String path;
  final String content;
}
