import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

/// Authentication events
@freezed
class AuthEvent with _$AuthEvent {
  // Email-first OTP-based authentication
  const factory AuthEvent.signUpWithEmail({
    required String email,
    Map<String, dynamic>? data,
  }) = AuthSignUpWithEmailEvent;

  const factory AuthEvent.verifySignUp({
    required String email,
    required String token,
    String? password,
  }) = AuthVerifySignUpEvent;

  const factory AuthEvent.signInWithEmail({
    required String email,
  }) = AuthSignInWithEmailEvent;

  const factory AuthEvent.verifySignIn({
    required String email,
    required String token,
  }) = AuthVerifySignInEvent;

  // Traditional email/password authentication
  const factory AuthEvent.signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) = AuthSignUpEvent;

  const factory AuthEvent.signInWithPassword({
    required String email,
    required String password,
  }) = AuthSignInWithPasswordEvent;

  // Session management
  const factory AuthEvent.signOut() = AuthSignOutEvent;

  const factory AuthEvent.refreshSession({
    String? refreshToken,
  }) = AuthRefreshSessionEvent;

  // User management
  const factory AuthEvent.updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) = AuthUpdateUserEvent;

  const factory AuthEvent.getUser() = AuthGetUserEvent;

  // Password recovery
  const factory AuthEvent.resetPasswordForEmail({
    required String email,
  }) = AuthResetPasswordForEmailEvent;

  const factory AuthEvent.updatePassword({
    required String email,
    required String token,
    required String password,
  }) = AuthUpdatePasswordEvent;

  // Session initialization
  const factory AuthEvent.initialize() = AuthInitializeEvent;

  // Clear error state
  const factory AuthEvent.clearError() = AuthClearErrorEvent;
}