import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Session model representing an authenticated session
@freezed
class Session with _$Session {
  const factory Session({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') required int expiresIn,
    @JsonKey(name: 'expires_at') int? expiresAt,
    @JsonKey(name: 'token_type') required String tokenType,
    required User user,
    @JsonKey(name: 'provider_token') String? providerToken,
    @JsonKey(name: 'provider_refresh_token') String? providerRefreshToken,
  }) = _Session;

  const Session._();

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

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