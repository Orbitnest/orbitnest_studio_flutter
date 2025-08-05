import 'user.dart';
import 'session.dart';

/// Response from authentication operations
class AuthResponse {
  const AuthResponse({
    this.user,
    this.session,
    this.otpSent,
    this.email,
    this.message,
    this.emailOtp,
    this.smsOtp,
    this.actionLink,
  });

  final User? user;
  final Session? session;
  final bool? otpSent;
  final String? email;
  final String? message;
  final String? emailOtp;
  final String? smsOtp;
  final String? actionLink;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: json['user'] != null 
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      session: json['session'] != null 
          ? Session.fromJson(json['session'] as Map<String, dynamic>)
          : null,
      otpSent: json['otp_sent'] as bool?,
      email: json['email'] as String?,
      message: json['message'] as String?,
      emailOtp: json['email_otp'] as String?,
      smsOtp: json['sms_otp'] as String?,
      actionLink: json['action_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (user != null) 'user': user!.toJson(),
      if (session != null) 'session': session!.toJson(),
      if (otpSent != null) 'otp_sent': otpSent,
      if (email != null) 'email': email,
      if (message != null) 'message': message,
      if (emailOtp != null) 'email_otp': emailOtp,
      if (smsOtp != null) 'sms_otp': smsOtp,
      if (actionLink != null) 'action_link': actionLink,
    };
  }

  /// Check if the response indicates successful authentication
  bool get isAuthenticated => user != null && session != null;

  /// Check if OTP was sent
  bool get isOtpSent => otpSent == true;

  /// Check if the response has an error
  bool get hasError => !isAuthenticated && !isOtpSent && message != null;
}

/// Response for password reset operations
class PasswordResetResponse {
  const PasswordResetResponse({
    required this.message,
    this.resetSent,
    this.email,
  });

  final String message;
  final bool? resetSent;
  final String? email;

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      message: json['message'] as String,
      resetSent: json['reset_sent'] as bool?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (resetSent != null) 'reset_sent': resetSent,
      if (email != null) 'email': email,
    };
  }
}

/// Response for user update operations
class UserUpdateResponse {
  const UserUpdateResponse({
    required this.user,
    this.message,
    this.emailChangeSent,
  });

  final User user;
  final String? message;
  final bool? emailChangeSent;

  factory UserUpdateResponse.fromJson(Map<String, dynamic> json) {
    return UserUpdateResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
      emailChangeSent: json['email_change_sent'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      if (message != null) 'message': message,
      if (emailChangeSent != null) 'email_change_sent': emailChangeSent,
    };
  }
}

/// Generic auth operation result
sealed class AuthOperationResult {
  const AuthOperationResult();
}

class AuthOperationSuccess extends AuthOperationResult {
  const AuthOperationSuccess({
    this.user,
    this.session,
    this.message,
  });

  final User? user;
  final Session? session;
  final String? message;

  factory AuthOperationSuccess.fromJson(Map<String, dynamic> json) {
    return AuthOperationSuccess(
      user: json['user'] != null 
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      session: json['session'] != null 
          ? Session.fromJson(json['session'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'success',
      if (user != null) 'user': user!.toJson(),
      if (session != null) 'session': session!.toJson(),
      if (message != null) 'message': message,
    };
  }
}

class AuthOperationOtpSent extends AuthOperationResult {
  const AuthOperationOtpSent({
    required this.email,
    required this.message,
  });

  final String email;
  final String message;

  factory AuthOperationOtpSent.fromJson(Map<String, dynamic> json) {
    return AuthOperationOtpSent(
      email: json['email'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'otpSent',
      'email': email,
      'message': message,
    };
  }
}

class AuthOperationError extends AuthOperationResult {
  const AuthOperationError({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  factory AuthOperationError.fromJson(Map<String, dynamic> json) {
    return AuthOperationError(
      message: json['message'] as String,
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'error',
      'message': message,
      if (code != null) 'code': code,
      if (details != null) 'details': details,
    };
  }
}

class AuthOperationLoading extends AuthOperationResult {
  const AuthOperationLoading();

  factory AuthOperationLoading.fromJson(Map<String, dynamic> json) {
    return const AuthOperationLoading();
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'loading',
    };
  }
}