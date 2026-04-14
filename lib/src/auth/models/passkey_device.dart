/// A registered WebAuthn / passkey credential bound to the current user.
class PasskeyDevice {
  const PasskeyDevice({
    required this.id,
    this.deviceName,
    this.transports = const [],
    this.backupEligible = false,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Server-side credential row id (used for rename/revoke).
  final String id;

  /// User-friendly label (e.g. "iPhone 15").
  final String? deviceName;

  /// Authenticator transports (`internal`, `usb`, `hybrid`, …).
  final List<String> transports;

  /// True if this credential is multi-device (e.g. iCloud Keychain / Google
  /// Password Manager synced).
  final bool backupEligible;

  final DateTime createdAt;
  final DateTime? lastUsedAt;

  factory PasskeyDevice.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) =>
        v is String ? DateTime.parse(v) : DateTime.fromMillisecondsSinceEpoch(0);
    DateTime? parseDateOrNull(dynamic v) =>
        v is String ? DateTime.tryParse(v) : null;

    return PasskeyDevice(
      id: json['id'] as String,
      deviceName: json['device_name'] as String?,
      transports: ((json['transports'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      backupEligible: json['backup_eligible'] as bool? ?? false,
      createdAt: parseDate(json['created_at']),
      lastUsedAt: parseDateOrNull(json['last_used_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (deviceName != null) 'device_name': deviceName,
        'transports': transports,
        'backup_eligible': backupEligible,
        'created_at': createdAt.toIso8601String(),
        if (lastUsedAt != null) 'last_used_at': lastUsedAt!.toIso8601String(),
      };
}
