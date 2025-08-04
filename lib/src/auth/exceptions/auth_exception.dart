import '../../client/interceptors/error_interceptor.dart';

/// Authentication-specific exception
class AuthException extends OrbitNestException {
  const AuthException(
    super.message, {
    super.code,
    super.statusCode,
    this.user,
  });

  final Map<String, dynamic>? user;

  factory AuthException.fromException(dynamic error) {
    if (error is AuthException) {
      return error;
    }

    if (error is OrbitNestException) {
      return AuthException(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
      );
    }

    return AuthException(
      error.toString(),
      code: 'UNKNOWN_AUTH_ERROR',
    );
  }

  factory AuthException.invalidCredentials([String? message]) {
    return AuthException(
      message ?? 'Invalid email or password',
      code: 'INVALID_CREDENTIALS',
      statusCode: 401,
    );
  }

  factory AuthException.userNotFound([String? message]) {
    return AuthException(
      message ?? 'User not found',
      code: 'USER_NOT_FOUND',
      statusCode: 404,
    );
  }

  factory AuthException.emailNotConfirmed([String? message]) {
    return AuthException(
      message ?? 'Email not confirmed',
      code: 'EMAIL_NOT_CONFIRMED',
      statusCode: 401,
    );
  }

  factory AuthException.weakPassword([String? message]) {
    return AuthException(
      message ?? 'Password is too weak',
      code: 'WEAK_PASSWORD',
      statusCode: 400,
    );
  }

  factory AuthException.emailAlreadyExists([String? message]) {
    return AuthException(
      message ?? 'Email already registered',
      code: 'EMAIL_ALREADY_EXISTS',
      statusCode: 409,
    );
  }

  factory AuthException.invalidToken([String? message]) {
    return AuthException(
      message ?? 'Invalid or expired token',
      code: 'INVALID_TOKEN',
      statusCode: 401,
    );
  }

  factory AuthException.tokenExpired([String? message]) {
    return AuthException(
      message ?? 'Token has expired',
      code: 'TOKEN_EXPIRED',
      statusCode: 401,
    );
  }

  factory AuthException.signupDisabled([String? message]) {
    return AuthException(
      message ?? 'User signup is disabled',
      code: 'SIGNUP_DISABLED',
      statusCode: 403,
    );
  }

  factory AuthException.signinDisabled([String? message]) {
    return AuthException(
      message ?? 'User signin is disabled',
      code: 'SIGNIN_DISABLED',
      statusCode: 403,
    );
  }

  factory AuthException.unauthorized([String? message]) {
    return AuthException(
      message ?? 'Unauthorized access',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  factory AuthException.forbidden([String? message]) {
    return AuthException(
      message ?? 'Access forbidden',
      code: 'FORBIDDEN',
      statusCode: 403,
    );
  }

  @override
  String toString() {
    if (code != null) {
      return 'AuthException($code): $message';
    }
    return 'AuthException: $message';
  }
}