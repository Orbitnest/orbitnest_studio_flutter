import 'user.dart';

/// Session model representing an authenticated session
class Session {
  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.expiresAt,
    required this.tokenType,
    required this.user,
    this.providerToken,
    this.providerRefreshToken,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int? expiresAt;
  final String tokenType;
  final User user;
  final String? providerToken;
  final String? providerRefreshToken;

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      expiresAt: json['expires_at'] as int?,
      tokenType: json['token_type'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      providerToken: json['provider_token'] as String?,
      providerRefreshToken: json['provider_refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      if (expiresAt != null) 'expires_at': expiresAt,
      'token_type': tokenType,
      'user': user.toJson(),
      if (providerToken != null) 'provider_token': providerToken,
      if (providerRefreshToken != null)
        'provider_refresh_token': providerRefreshToken,
    };
  }

  /// Create a copy of this session with some fields replaced
  Session copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    int? expiresAt,
    String? tokenType,
    User? user,
    String? providerToken,
    String? providerRefreshToken,
  }) {
    return Session(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
      providerToken: providerToken ?? this.providerToken,
      providerRefreshToken: providerRefreshToken ?? this.providerRefreshToken,
    );
  }

  /// Check if the session is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiresAt!;
  }

  /// Check if the session is about to expire (within threshold)
  bool isExpiringWithin(Duration threshold) {
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final thresholdSeconds = threshold.inSeconds;
    return (expiresAt! - now) <= thresholdSeconds;
  }

  /// Get expiration time as DateTime
  DateTime? get expirationTime {
    if (expiresAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000);
  }

  /// Get remaining time until expiration
  Duration? get remainingTime {
    final expTime = expirationTime;
    if (expTime == null) return null;
    final remaining = expTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
