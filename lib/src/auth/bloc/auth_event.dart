/// Authentication events
sealed class AuthEvent {
  const AuthEvent();
}

// Email-first OTP-based authentication
class AuthSignUpWithEmailEvent extends AuthEvent {
  const AuthSignUpWithEmailEvent({
    required this.email,
    this.data,
  });

  final String email;
  final Map<String, dynamic>? data;
}

class AuthVerifySignUpEvent extends AuthEvent {
  const AuthVerifySignUpEvent({
    required this.email,
    required this.token,
    this.password,
  });

  final String email;
  final String token;
  final String? password;
}

class AuthSignInWithEmailEvent extends AuthEvent {
  const AuthSignInWithEmailEvent({
    required this.email,
  });

  final String email;
}

class AuthVerifySignInEvent extends AuthEvent {
  const AuthVerifySignInEvent({
    required this.email,
    required this.token,
  });

  final String email;
  final String token;
}

// Traditional email/password authentication
class AuthSignUpEvent extends AuthEvent {
  const AuthSignUpEvent({
    required this.email,
    required this.password,
    this.data,
  });

  final String email;
  final String password;
  final Map<String, dynamic>? data;
}

class AuthSignInWithPasswordEvent extends AuthEvent {
  const AuthSignInWithPasswordEvent({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

// Session management
class AuthSignOutEvent extends AuthEvent {
  const AuthSignOutEvent();
}

class AuthRefreshSessionEvent extends AuthEvent {
  const AuthRefreshSessionEvent({
    this.refreshToken,
  });

  final String? refreshToken;
}

// User management
class AuthUpdateUserEvent extends AuthEvent {
  const AuthUpdateUserEvent({
    this.email,
    this.password,
    this.data,
  });

  final String? email;
  final String? password;
  final Map<String, dynamic>? data;
}

class AuthGetUserEvent extends AuthEvent {
  const AuthGetUserEvent();
}

// Password recovery
class AuthResetPasswordForEmailEvent extends AuthEvent {
  const AuthResetPasswordForEmailEvent({
    required this.email,
  });

  final String email;
}

class AuthUpdatePasswordEvent extends AuthEvent {
  const AuthUpdatePasswordEvent({
    required this.email,
    required this.token,
    required this.password,
  });

  final String email;
  final String token;
  final String password;
}

// Session initialization
class AuthInitializeEvent extends AuthEvent {
  const AuthInitializeEvent();
}

// Clear error state
class AuthClearErrorEvent extends AuthEvent {
  const AuthClearErrorEvent();
}