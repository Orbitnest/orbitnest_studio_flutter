import 'package:dio/dio.dart';
import '../../client/http_client.dart';
import '../../constants/endpoints.dart';
import '../../constants/error_codes.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../exceptions/auth_exception.dart';

/// Service for handling authentication API calls
class AuthService {
  final OrbitNestHttpClient _httpClient;
  final String _projectSlug;

  AuthService({
    required OrbitNestHttpClient httpClient,
    required String projectSlug,
  })  : _httpClient = httpClient,
        _projectSlug = projectSlug;

  /// Sign up with email (OTP-based)
  Future<AuthResponse> signUpWithEmail({
    required String email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectSignupWithEmail(_projectSlug),
        data: {
          'email': email,
          if (data != null) 'user_metadata': data,
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
        Endpoints.projectVerifySignup(_projectSlug),
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
        Endpoints.projectSigninWithEmail(_projectSlug),
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
        Endpoints.projectVerifySignin(_projectSlug),
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
        Endpoints.projectSignup(_projectSlug),
        data: {
          'email': email,
          'password': password,
          if (data != null) 'user_metadata': data,
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
        Endpoints.projectSignin(_projectSlug),
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
      await _httpClient.post(Endpoints.projectSignout(_projectSlug));
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
        Endpoints.projectRefresh(_projectSlug),
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
        Endpoints.projectUser(_projectSlug),
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
        Endpoints.projectUser(_projectSlug),
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
        Endpoints.projectRecover(_projectSlug),
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
        Endpoints.projectResetPassword(_projectSlug),
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

  // ── Passkey / WebAuthn ────────────────────────────────────────────────────

  /// Request server-issued attestation options for registering a new passkey.
  /// User must already be authenticated.
  Future<Map<String, dynamic>> passkeyRegisterOptions({String? deviceName}) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectPasskeyRegisterOptions(_projectSlug),
        data: {if (deviceName != null) 'device_name': deviceName},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verify the platform attestation and persist the credential.
  Future<Map<String, dynamic>> passkeyRegisterVerify({
    required String challengeId,
    required Map<String, dynamic> attestation,
    String? deviceName,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectPasskeyRegisterVerify(_projectSlug),
        data: {
          'challenge_id': challengeId,
          'attestation': attestation,
          if (deviceName != null) 'device_name': deviceName,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Request server-issued assertion options for passkey sign-in.
  /// [identifier] may be the user email (enables `allowCredentials`) or null
  /// for a discoverable-credential flow.
  Future<Map<String, dynamic>> passkeyLoginOptions({String? identifier}) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectPasskeyLoginOptions(_projectSlug),
        data: {if (identifier != null) 'identifier': identifier},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verify the platform assertion and exchange it for a session.
  Future<AuthResponse> passkeyLoginVerify({
    required String challengeId,
    required Map<String, dynamic> assertion,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectPasskeyLoginVerify(_projectSlug),
        data: {
          'challenge_id': challengeId,
          'assertion': assertion,
        },
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// List all active passkeys for the current user.
  Future<List<Map<String, dynamic>>> listPasskeys() async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectPasskeyDevices(_projectSlug),
      );
      return (response.data as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Rename a registered passkey.
  Future<Map<String, dynamic>> renamePasskey({
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final response = await _httpClient.patch(
        Endpoints.projectPasskeyDevice(_projectSlug, deviceId),
        data: {'device_name': deviceName},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Revoke (soft-delete) a registered passkey.
  Future<void> revokePasskey({required String deviceId}) async {
    try {
      await _httpClient.delete(
        Endpoints.projectPasskeyDevice(_projectSlug, deviceId),
      );
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verify a JWT token against the server
  /// Returns a map with valid, user, and error fields
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectVerifyToken(_projectSlug),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }
}
