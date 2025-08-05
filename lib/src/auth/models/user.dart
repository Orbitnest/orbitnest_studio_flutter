/// User model representing an authenticated user
class User {
  const User({
    required this.id,
    required this.email,
    this.emailConfirmedAt,
    this.phoneConfirmedAt,
    this.lastSignInAt,
    required this.createdAt,
    required this.updatedAt,
    this.userMetadata,
    this.appMetadata,
    this.phone,
    this.role,
    this.confirmationSentAt,
    this.recoverySentAt,
    this.emailChangeSentAt,
    this.newEmail,
    this.invitedAt,
    this.actionLink,
  });

  final String id;
  final String email;
  final DateTime? emailConfirmedAt;
  final DateTime? phoneConfirmedAt;
  final DateTime? lastSignInAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? userMetadata;
  final Map<String, dynamic>? appMetadata;
  final String? phone;
  final String? role;
  final DateTime? confirmationSentAt;
  final DateTime? recoverySentAt;
  final DateTime? emailChangeSentAt;
  final String? newEmail;
  final DateTime? invitedAt;
  final String? actionLink;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      emailConfirmedAt: json['email_confirmed_at'] != null 
          ? DateTime.parse(json['email_confirmed_at'] as String)
          : null,
      phoneConfirmedAt: json['phone_confirmed_at'] != null 
          ? DateTime.parse(json['phone_confirmed_at'] as String)
          : null,
      lastSignInAt: json['last_sign_in_at'] != null 
          ? DateTime.parse(json['last_sign_in_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userMetadata: json['user_metadata'] as Map<String, dynamic>?,
      appMetadata: json['app_metadata'] as Map<String, dynamic>?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      confirmationSentAt: json['confirmation_sent_at'] != null 
          ? DateTime.parse(json['confirmation_sent_at'] as String)
          : null,
      recoverySentAt: json['recovery_sent_at'] != null 
          ? DateTime.parse(json['recovery_sent_at'] as String)
          : null,
      emailChangeSentAt: json['email_change_sent_at'] != null 
          ? DateTime.parse(json['email_change_sent_at'] as String)
          : null,
      newEmail: json['new_email'] as String?,
      invitedAt: json['invited_at'] != null 
          ? DateTime.parse(json['invited_at'] as String)
          : null,
      actionLink: json['action_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (emailConfirmedAt != null) 'email_confirmed_at': emailConfirmedAt!.toIso8601String(),
      if (phoneConfirmedAt != null) 'phone_confirmed_at': phoneConfirmedAt!.toIso8601String(),
      if (lastSignInAt != null) 'last_sign_in_at': lastSignInAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (userMetadata != null) 'user_metadata': userMetadata,
      if (appMetadata != null) 'app_metadata': appMetadata,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (confirmationSentAt != null) 'confirmation_sent_at': confirmationSentAt!.toIso8601String(),
      if (recoverySentAt != null) 'recovery_sent_at': recoverySentAt!.toIso8601String(),
      if (emailChangeSentAt != null) 'email_change_sent_at': emailChangeSentAt!.toIso8601String(),
      if (newEmail != null) 'new_email': newEmail,
      if (invitedAt != null) 'invited_at': invitedAt!.toIso8601String(),
      if (actionLink != null) 'action_link': actionLink,
    };
  }
}

/// Admin user model for project management
class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    this.emailConfirmedAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastSignInAt,
    this.userMetadata,
    this.appMetadata,
    this.role,
    this.banned,
    this.banDuration,
  });

  final String id;
  final String email;
  final DateTime? emailConfirmedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSignInAt;
  final Map<String, dynamic>? userMetadata;
  final Map<String, dynamic>? appMetadata;
  final String? role;
  final bool? banned;
  final Duration? banDuration;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      emailConfirmedAt: json['email_confirmed_at'] != null 
          ? DateTime.parse(json['email_confirmed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSignInAt: json['last_sign_in_at'] != null 
          ? DateTime.parse(json['last_sign_in_at'] as String)
          : null,
      userMetadata: json['user_metadata'] as Map<String, dynamic>?,
      appMetadata: json['app_metadata'] as Map<String, dynamic>?,
      role: json['role'] as String?,
      banned: json['banned'] as bool?,
      banDuration: json['ban_duration'] != null 
          ? Duration(seconds: json['ban_duration'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (emailConfirmedAt != null) 'email_confirmed_at': emailConfirmedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (lastSignInAt != null) 'last_sign_in_at': lastSignInAt!.toIso8601String(),
      if (userMetadata != null) 'user_metadata': userMetadata,
      if (appMetadata != null) 'app_metadata': appMetadata,
      if (role != null) 'role': role,
      if (banned != null) 'banned': banned,
      if (banDuration != null) 'ban_duration': banDuration!.inSeconds,
    };
  }
}