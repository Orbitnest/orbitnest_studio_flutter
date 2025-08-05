import '../../client/http_client.dart';
import '../../constants/endpoints.dart';
import '../../constants/error_codes.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../exceptions/auth_exception.dart';

/// Service for handling authentication API calls
class AuthService {
  final OrbitNestHttpClient _httpClient;
  final String _projectId;

  AuthService({
    required OrbitNestHttpClient httpClient,
    required String projectId,
  })  : _httpClient = httpClient,
        _projectId = projectId;

  /// Sign up with email (OTP-based)
  Future<AuthResponse> signUpWithEmail({
    required String email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectSignupWithEmail(_projectId),
        data: {
          'email': email,
          if (data != null) 'data': data,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verify signup with OTP
  Future<AuthResponse> verifySignUp({
    required String email,
    required String token,
    String? password,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectVerifySignup(_projectId),
        data: {
          'email': email,
          'code': token,
          if (password != null) 'password': password,
        },
      );

      try {
        return AuthResponse.fromJson(response.data);
      } catch (e) {
        // If parsing fails, provide detailed error information
        throw AuthException(
          'Failed to parse authentication response: ${e.toString()}',
          code: ErrorCodes.responseParseError,
        );
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow; // Re-throw our custom parsing error
      }
      throw AuthException.fromException(e);
    }
  }

  /// Sign in with email (OTP-based)
  Future<AuthResponse> signInWithEmail({
    required String email,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectSigninWithEmail(_projectId),
        data: {
          'email': email,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verify signin with OTP
  Future<AuthResponse> verifySignIn({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectVerifySignin(_projectId),
        data: {
          'email': email,
          'code': token,
        },
      );

      try {
        return AuthResponse.fromJson(response.data);
      } catch (e) {
        // If parsing fails, provide detailed error information
        throw AuthException(
          'Failed to parse authentication response: ${e.toString()}',
          code: ErrorCodes.responseParseError,
        );
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow; // Re-throw our custom parsing error
      }
      throw AuthException.fromException(e);
    }
  }

  /// Traditional sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectSignup(_projectId),
        data: {
          'email': email,
          'password': password,
          if (data != null) 'data': data,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Traditional sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectSignin(_projectId),
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _httpClient.post(Endpoints.projectSignout(_projectId));
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Refresh the current session
  Future<AuthResponse> refreshSession({
    required String refreshToken,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectRefresh(_projectId),
        data: {
          'refresh_token': refreshToken,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Get current user
  Future<User> getUser() async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectUser(_projectId),
      );

      return User.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Update current user
  Future<UserUpdateResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.put(
        Endpoints.projectUser(_projectId),
        data: {
          if (email != null) 'email': email,
          if (password != null) 'password': password,
          if (data != null) 'data': data,
        },
      );

      return UserUpdateResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Request password reset
  Future<PasswordResetResponse> resetPasswordForEmail({
    required String email,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectRecover(_projectId),
        data: {
          'email': email,
        },
      );

      return PasswordResetResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Update password with reset token
  Future<AuthResponse> updatePassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectResetPassword(_projectId),
        data: {
          'email': email,
          'code': token,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }
}
