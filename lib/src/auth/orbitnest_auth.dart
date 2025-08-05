import 'dart:async';
import 'package:flutter/foundation.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'models/user.dart';
import 'models/session.dart';
import 'exceptions/auth_exception.dart';

/// Simplified Auth API that wraps the BLoC pattern
/// Provides direct async methods like Supabase
class OrbitNestAuth extends ChangeNotifier {
  final AuthBloc _authBloc;
  late final StreamSubscription _stateSubscription;

  AuthState _currentState = const AuthInitialState();
  final Map<String, Completer<dynamic>> _pendingOperations = {};

  OrbitNestAuth(this._authBloc) {
    _stateSubscription = _authBloc.stream.listen(_handleStateChange);
    _currentState = _authBloc.state;
  }

  void _handleStateChange(AuthState state) {
    _currentState = state;
    notifyListeners();

    // Complete pending operations based on state changes
    switch (state) {
      case AuthAuthenticatedState(:final user, :final session):
        _completePendingOperation(
            'auth_success', {'user': user, 'session': session});
        break;
      case AuthOtpSentState(:final email, :final message, :final type):
        _completePendingOperation(
            'otp_sent', {'email': email, 'message': message, 'type': type});
        break;
      case AuthPasswordResetSentState(:final email, :final message):
        _completePendingOperation(
            'password_reset_sent', {'email': email, 'message': message});
        break;
      case AuthUserUpdatedState(:final user, :final message):
        _completePendingOperation(
            'user_updated', {'user': user, 'message': message});
        break;
      case AuthUnauthenticatedState():
        _completePendingOperation('unauthenticated', null);
        break;
      case AuthErrorState(:final message, :final code):
        // Complete all pending operations with the error
        final error = AuthException(message, code: code);
        final pendingKeys = List<String>.from(_pendingOperations.keys);
        for (final key in pendingKeys) {
          _completePendingOperationWithError(key, error);
        }
        break;
      case AuthInitialState():
        break;
      case AuthLoadingState():
        break;
    }
  }

  void _completePendingOperation(String key, dynamic result) {
    final completer = _pendingOperations.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  void _completePendingOperationWithError(String key, Object error) {
    final completer = _pendingOperations.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error);
    }
  }

  Future<T> _executeWithCompleter<T>(
      String operationKey, AuthEvent event) async {
    final completer = Completer<T>();
    _pendingOperations[operationKey] = completer;

    _authBloc.add(event);

    // No manual timeout - rely only on Dio client timeout
    return completer.future;
  }

  /// Get current user (null if not authenticated)
  User? get currentUser {
    return switch (_currentState) {
      AuthAuthenticatedState(:final user) => user,
      _ => null,
    };
  }

  /// Get current session (null if not authenticated)
  Session? get currentSession {
    return switch (_currentState) {
      AuthAuthenticatedState(:final session) => session,
      _ => null,
    };
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated {
    return switch (_currentState) {
      AuthAuthenticatedState() => true,
      _ => false,
    };
  }

  /// Get current auth state for UI reactivity
  AuthState get state => _currentState;

  /// Stream of auth state changes for listening to auth events
  Stream<AuthState> get onAuthStateChange => _authBloc.stream;

  /// Sign up with email (OTP-based flow)
  /// Returns a map with email and message when OTP is sent
  Future<Map<String, dynamic>> signUpWithEmail(String email,
      {Map<String, dynamic>? metadata}) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'otp_sent',
      AuthSignUpWithEmailEvent(email: email, data: metadata),
    );
  }

  /// Verify email signup with OTP
  /// Returns user and session when successful
  Future<Map<String, dynamic>> verifySignUp({
    required String email,
    required String otp,
    String? password,
  }) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'auth_success',
      AuthVerifySignUpEvent(email: email, token: otp, password: password),
    );
  }

  /// Sign in with email (OTP-based flow)
  /// Returns a map with email and message when OTP is sent
  Future<Map<String, dynamic>> signInWithEmail(String email) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'otp_sent',
      AuthSignInWithEmailEvent(email: email),
    );
  }

  /// Verify email signin with OTP
  /// Returns user and session when successful
  Future<Map<String, dynamic>> verifySignIn({
    required String email,
    required String otp,
  }) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'auth_success',
      AuthVerifySignInEvent(email: email, token: otp),
    );
  }

  /// Traditional signup with email and password
  /// Returns user and session when successful
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'auth_success',
      AuthSignUpEvent(email: email, password: password, data: metadata),
    );
  }

  /// Traditional signin with email and password
  /// Returns user and session when successful
  Future<Map<String, dynamic>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'auth_success',
      AuthSignInWithPasswordEvent(email: email, password: password),
    );
  }

  /// Send password recovery email
  /// Returns a map with email and message when email is sent
  Future<Map<String, dynamic>> resetPasswordForEmail(String email) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'password_reset_sent',
      AuthResetPasswordForEmailEvent(email: email),
    );
  }

  /// Reset password with token from email
  /// Returns user and session when successful
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'auth_success',
      AuthUpdatePasswordEvent(
          email: email, token: token, password: newPassword),
    );
  }

  /// Update current user profile
  /// Returns updated user when successful
  Future<Map<String, dynamic>> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? metadata,
  }) async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'user_updated',
      AuthUpdateUserEvent(email: email, password: password, data: metadata),
    );
  }

  /// Refresh current session
  /// Returns user and session when successful
  Future<Map<String, dynamic>> refreshSession() async {
    return await _executeWithCompleter<Map<String, dynamic>>(
      'auth_success',
      const AuthRefreshSessionEvent(),
    );
  }

  /// Sign out current user
  /// Returns when signout is complete
  Future<void> signOut() async {
    await _executeWithCompleter<void>(
      'unauthenticated',
      const AuthSignOutEvent(),
    );
  }

  /// Get current user profile
  /// Returns user when successful, throws if not authenticated
  Future<User> getUser() async {
    if (currentUser != null) {
      return currentUser!;
    }

    // Trigger getUser event and wait for result
    final result = await _executeWithCompleter<Map<String, dynamic>>(
      'auth_success',
      const AuthGetUserEvent(),
    );

    return result['user'] as User;
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }
}
