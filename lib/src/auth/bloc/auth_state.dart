import '../models/user.dart';
import '../models/session.dart';

/// Authentication states
sealed class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthAuthenticatedState extends AuthState {
  const AuthAuthenticatedState({
    required this.user,
    required this.session,
  });

  final User user;
  final Session session;
}

class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

class AuthOtpSentState extends AuthState {
  const AuthOtpSentState({
    required this.email,
    required this.message,
    this.type,
  });

  final String email;
  final String message;
  final String? type; // 'signup' or 'signin'
}

class AuthPasswordResetSentState extends AuthState {
  const AuthPasswordResetSentState({
    required this.email,
    required this.message,
  });

  final String email;
  final String message;
}

class AuthUserUpdatedState extends AuthState {
  const AuthUserUpdatedState({
    required this.user,
    this.message,
  });

  final User user;
  final String? message;
}

class AuthErrorState extends AuthState {
  const AuthErrorState({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;
}

/// Extension for AuthState to add convenience methods
extension AuthStateX on AuthState {
  bool get isAuthenticated => this is AuthAuthenticatedState;
  bool get isLoading => this is AuthLoadingState;
  bool get isError => this is AuthErrorState;
  bool get isUnauthenticated => this is AuthUnauthenticatedState;
  bool get isOtpSent => this is AuthOtpSentState;
  
  User? get user {
    return switch (this) {
      AuthAuthenticatedState(:final user) => user,
      AuthUserUpdatedState(:final user) => user,
      _ => null,
    };
  }
  
  Session? get session {
    return switch (this) {
      AuthAuthenticatedState(:final session) => session,
      _ => null,
    };
  }
  
  String? get error {
    return switch (this) {
      AuthErrorState(:final message) => message,
      _ => null,
    };
  }
  
  String? get errorCode {
    return switch (this) {
      AuthErrorState(:final code) => code,
      _ => null,
    };
  }
}