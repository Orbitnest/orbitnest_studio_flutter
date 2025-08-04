import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'session.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Response from authentication operations
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    User? user,
    Session? session,
    @JsonKey(name: 'otp_sent') bool? otpSent,
    String? email,
    String? message,
    @JsonKey(name: 'email_otp') String? emailOtp,
    @JsonKey(name: 'sms_otp') String? smsOtp,
    @JsonKey(name: 'action_link') String? actionLink,
  }) = _AuthResponse;

  const AuthResponse._();

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  /// Check if the response indicates successful authentication
  bool get isAuthenticated => user != null && session != null;

  /// Check if OTP was sent
  bool get isOtpSent => otpSent == true;

  /// Check if the response has an error
  bool get hasError => !isAuthenticated && !isOtpSent && message != null;
}

/// Response for password reset operations
@freezed
class PasswordResetResponse with _$PasswordResetResponse {
  const factory PasswordResetResponse({
    required String message,
    @JsonKey(name: 'reset_sent') bool? resetSent,
    String? email,
  }) = _PasswordResetResponse;

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) => 
      _$PasswordResetResponseFromJson(json);
}

/// Response for user update operations
@freezed
class UserUpdateResponse with _$UserUpdateResponse {
  const factory UserUpdateResponse({
    required User user,
    String? message,
    @JsonKey(name: 'email_change_sent') bool? emailChangeSent,
  }) = _UserUpdateResponse;

  factory UserUpdateResponse.fromJson(Map<String, dynamic> json) => 
      _$UserUpdateResponseFromJson(json);
}

/// Generic auth operation result
@freezed
class AuthOperationResult with _$AuthOperationResult {
  const factory AuthOperationResult.success({
    User? user,
    Session? session,
    String? message,
  }) = AuthOperationSuccess;

  const factory AuthOperationResult.otpSent({
    required String email,
    required String message,
  }) = AuthOperationOtpSent;

  const factory AuthOperationResult.error({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) = AuthOperationError;

  const factory AuthOperationResult.loading() = AuthOperationLoading;
}