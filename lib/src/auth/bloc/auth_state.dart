import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user.dart';
import '../models/session.dart';

part 'auth_state.freezed.dart';

/// Authentication states
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitialState;
  
  const factory AuthState.loading() = AuthLoadingState;
  
  const factory AuthState.authenticated({
    required User user,
    required Session session,
  }) = AuthAuthenticatedState;
  
  const factory AuthState.unauthenticated() = AuthUnauthenticatedState;
  
  const factory AuthState.otpSent({
    required String email,
    required String message,
    String? type, // 'signup' or 'signin'
  }) = AuthOtpSentState;
  
  const factory AuthState.passwordResetSent({
    required String email,
    required String message,
  }) = AuthPasswordResetSentState;
  
  const factory AuthState.userUpdated({
    required User user,
    String? message,
  }) = AuthUserUpdatedState;
  
  const factory AuthState.error({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) = AuthErrorState;
}

/// Extension for AuthState to add convenience methods
extension AuthStateX on AuthState {
  bool get isAuthenticated => this is AuthAuthenticatedState;
  bool get isLoading => this is AuthLoadingState;
  bool get isError => this is AuthErrorState;
  bool get isUnauthenticated => this is AuthUnauthenticatedState;
  bool get isOtpSent => this is AuthOtpSentState;
  
  User? get user => whenOrNull(
    authenticated: (user, session) => user,
    userUpdated: (user, message) => user,
  );
  
  Session? get session => whenOrNull(
    authenticated: (user, session) => session,
  );
  
  String? get error => whenOrNull(
    error: (message, code, details) => message,
  );
  
  String? get errorCode => whenOrNull(
    error: (message, code, details) => code,
  );
}