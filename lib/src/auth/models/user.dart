import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User model representing an authenticated user
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    @JsonKey(name: 'email_confirmed_at') DateTime? emailConfirmedAt,
    @JsonKey(name: 'phone_confirmed_at') DateTime? phoneConfirmedAt,
    @JsonKey(name: 'last_sign_in_at') DateTime? lastSignInAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'user_metadata') Map<String, dynamic>? userMetadata,
    @JsonKey(name: 'app_metadata') Map<String, dynamic>? appMetadata,
    String? phone,
    String? role,
    @JsonKey(name: 'confirmation_sent_at') DateTime? confirmationSentAt,
    @JsonKey(name: 'recovery_sent_at') DateTime? recoverySentAt,
    @JsonKey(name: 'email_change_sent_at') DateTime? emailChangeSentAt,
    @JsonKey(name: 'new_email') String? newEmail,
    @JsonKey(name: 'invited_at') DateTime? invitedAt,
    @JsonKey(name: 'action_link') String? actionLink,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Admin user model for project management
@freezed
class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String id,
    required String email,
    @JsonKey(name: 'email_confirmed_at') DateTime? emailConfirmedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'last_sign_in_at') DateTime? lastSignInAt,
    @JsonKey(name: 'user_metadata') Map<String, dynamic>? userMetadata,
    @JsonKey(name: 'app_metadata') Map<String, dynamic>? appMetadata,
    String? role,
    bool? banned,
    @JsonKey(name: 'ban_duration') Duration? banDuration,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);
}