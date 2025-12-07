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

  /// Safely extracts a string value from JSON, handling various types
  static String? _parseStringField(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) return value.isNotEmpty ? value.first?.toString() : null;
    return value.toString();
  }

  /// Safely extracts a Map from JSON, handling various types
  static Map<String, dynamic>? _parseMapField(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      emailConfirmedAt: json['email_confirmed_at'] != null
          ? DateTime.tryParse(json['email_confirmed_at'].toString())
          : null,
      phoneConfirmedAt: json['phone_confirmed_at'] != null
          ? DateTime.tryParse(json['phone_confirmed_at'].toString())
          : null,
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.tryParse(json['last_sign_in_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      userMetadata: _parseMapField(json['user_metadata']),
      appMetadata: _parseMapField(json['app_metadata']),
      phone: _parseStringField(json['phone']),
      role: _parseStringField(json['role']),
      confirmationSentAt: json['confirmation_sent_at'] != null
          ? DateTime.tryParse(json['confirmation_sent_at'].toString())
          : null,
      recoverySentAt: json['recovery_sent_at'] != null
          ? DateTime.tryParse(json['recovery_sent_at'].toString())
          : null,
      emailChangeSentAt: json['email_change_sent_at'] != null
          ? DateTime.tryParse(json['email_change_sent_at'].toString())
          : null,
      newEmail: _parseStringField(json['new_email']),
      invitedAt: json['invited_at'] != null
          ? DateTime.tryParse(json['invited_at'].toString())
          : null,
      actionLink: _parseStringField(json['action_link']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (emailConfirmedAt != null)
        'email_confirmed_at': emailConfirmedAt!.toIso8601String(),
      if (phoneConfirmedAt != null)
        'phone_confirmed_at': phoneConfirmedAt!.toIso8601String(),
      if (lastSignInAt != null)
        'last_sign_in_at': lastSignInAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (userMetadata != null) 'user_metadata': userMetadata,
      if (appMetadata != null) 'app_metadata': appMetadata,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (confirmationSentAt != null)
        'confirmation_sent_at': confirmationSentAt!.toIso8601String(),
      if (recoverySentAt != null)
        'recovery_sent_at': recoverySentAt!.toIso8601String(),
      if (emailChangeSentAt != null)
        'email_change_sent_at': emailChangeSentAt!.toIso8601String(),
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
          ? DateTime.tryParse(json['email_confirmed_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.tryParse(json['last_sign_in_at'].toString())
          : null,
      userMetadata: User._parseMapField(json['user_metadata']),
      appMetadata: User._parseMapField(json['app_metadata']),
      role: User._parseStringField(json['role']),
      banned: json['banned'] is bool ? json['banned'] as bool : null,
      banDuration: json['ban_duration'] != null && json['ban_duration'] is int
          ? Duration(seconds: json['ban_duration'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (emailConfirmedAt != null)
        'email_confirmed_at': emailConfirmedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (lastSignInAt != null)
        'last_sign_in_at': lastSignInAt!.toIso8601String(),
      if (userMetadata != null) 'user_metadata': userMetadata,
      if (appMetadata != null) 'app_metadata': appMetadata,
      if (role != null) 'role': role,
      if (banned != null) 'banned': banned,
      if (banDuration != null) 'ban_duration': banDuration!.inSeconds,
    };
  }
}
