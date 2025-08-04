import '../services/auth_service.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../exceptions/auth_exception.dart';

/// Repository for authentication operations
/// Provides a layer of abstraction between the BLoC and the service
class AuthRepository {
  final AuthService _authService;

  AuthRepository({
    required AuthService authService,
  }) : _authService = authService;

  /// Sign up with email (OTP-based)
  Future<AuthResponse> signUpWithEmail({
    required String email,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _authService.signUpWithEmail(
        email: email,
        data: data,
      );
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
      return await _authService.verifySignUp(
        email: email,
        token: token,
        password: password,
      );
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Sign in with email (OTP-based)
  Future<AuthResponse> signInWithEmail({
    required String email,
  }) async {
    try {
      return await _authService.signInWithEmail(email: email);
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
      return await _authService.verifySignIn(
        email: email,
        token: token,
      );
    } catch (e) {
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
      return await _authService.signUp(
        email: email,
        password: password,
        data: data,
      );
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
      return await _authService.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Refresh the current session
  Future<AuthResponse> refreshSession({
    required String refreshToken,
  }) async {
    try {
      return await _authService.refreshSession(refreshToken: refreshToken);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Get current user
  Future<User?> getUser() async {
    try {
      return await _authService.getUser();
    } catch (e) {
      // Return null if user is not authenticated
      if (e is AuthException && e.statusCode == 401) {
        return null;
      }
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
      return await _authService.updateUser(
        email: email,
        password: password,
        data: data,
      );
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Request password reset
  Future<PasswordResetResponse> resetPasswordForEmail({
    required String email,
  }) async {
    try {
      return await _authService.resetPasswordForEmail(email: email);
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
      return await _authService.updatePassword(
        email: email,
        token: token,
        password: password,
      );
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }
}