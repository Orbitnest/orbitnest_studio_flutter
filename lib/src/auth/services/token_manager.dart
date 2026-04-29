import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/session.dart';
import '../../constants/constants.dart';
import '../../utils/logger.dart';

/// Manages authentication tokens and session persistence
class TokenManager {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  final String? _projectSlug;
  final String? _apiKey;
  static const int _maxTokenAge = 24; // hours
  static const int _refreshThresholdMinutes = 5;
  // Cache tokens in memory for faster access
  String? _cachedAccessToken;
  String? _cachedRefreshToken;


  TokenManager({String? projectSlug, String? apiKey})
    : _projectSlug = projectSlug,
      _apiKey = apiKey;

  /// Store session securely with additional validation
  Future<void> storeSession(Session session) async {
    try {
      // Validate session before storing
      if (!_isValidSession(session)) {
        throw Exception('Invalid session data');
      }

      // Add session timestamp for tracking
      final sessionWithTimestamp = session.copyWith(
        // Store when this session was saved locally
      );

      final sessionJson = json.encode(sessionWithTimestamp.toJson());

      // Generate a session checksum for integrity verification
      final checksum = _generateChecksum(sessionJson);

      await Future.wait([
        _secureStorage.write(
          key: OrbitNestConstants.sessionKey,
          value: sessionJson,
        ),
        _secureStorage.write(
          key: '${OrbitNestConstants.sessionKey}_checksum',
          value: checksum,
        ),
        _secureStorage.write(
          key: OrbitNestConstants.accessTokenKey,
          value: session.accessToken,
        ),
        _secureStorage.write(
          key: OrbitNestConstants.refreshTokenKey,
          value: session.refreshToken,
        ),
      ]);
      
      // Cache tokens in memory for faster access
      _cachedAccessToken = session.accessToken;
      _cachedRefreshToken = session.refreshToken;
    } catch (e) {
      OrbitNestLogger.error('Failed to store session', e);
      throw Exception('Failed to store session: $e');
    }
  }

  /// Retrieve stored session with integrity verification.
  /// Returns the session (even with an expired access token) so the caller can
  /// attempt a server-side refresh. Only returns null when there is genuinely
  /// no session to restore (never-signed-in, explicit sign-out, or a truly
  /// unrecoverable storage state).
  Future<Session?> getStoredSession() async {
    try {
      final sessionJson = await _secureStorage.read(
        key: OrbitNestConstants.sessionKey,
      );

      if (sessionJson == null) return null;

      // Integrity check — a mismatch most likely means storage corruption, not
      // tampering. Log a warning but continue so the server can validate the
      // refresh token via /auth/refresh. Wiping here would silently log users
      // out on any secure-storage write anomaly.
      final storedChecksum = await _secureStorage.read(
        key: '${OrbitNestConstants.sessionKey}_checksum',
      );
      if (storedChecksum != null) {
        final currentChecksum = _generateChecksum(sessionJson);
        if (storedChecksum != currentChecksum) {
          OrbitNestLogger.error(
            'getStoredSession: checksum mismatch — storage may be corrupt; '
            'proceeding to allow server-side refresh',
            null,
          );
          // Do NOT wipe — let /auth/refresh be the authority.
        }
      }

      final sessionMap = json.decode(sessionJson) as Map<String, dynamic>;
      final session = Session.fromJson(sessionMap);

      // Cache tokens in memory for faster access during this session
      _cachedAccessToken = session.accessToken;
      _cachedRefreshToken = session.refreshToken;

      // Without a refresh token there is nothing to recover with.
      if (session.refreshToken.isEmpty) {
        OrbitNestLogger.error('getStoredSession: empty refresh token — clearing session', null);
        await clearSession();
        return null;
      }

      // Do NOT check refresh-token expiry client-side. The exp claim in a JWT
      // is a hint, not a contract: clock skew, token rotation policies, and
      // server-side session extension can all make a locally-"expired" token
      // still valid. Let the server reject /auth/refresh if the token is truly
      // dead — only then should the session be cleared.

      return session;
    } catch (e) {
      // Transient errors (e.g. iOS secure storage initialising, disk pressure)
      // should not permanently log the user out. Log and return null so the
      // next attempt can succeed.
      OrbitNestLogger.error('getStoredSession: failed to read/decode session', e);
      return null;
    }
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    try {
      // Return cached token if available
      if (_cachedAccessToken != null) {
        return _cachedAccessToken;
      }
      // Otherwise read from secure storage and cache it
      final token = await _secureStorage.read(key: OrbitNestConstants.accessTokenKey);
      if (token != null) {
        _cachedAccessToken = token;
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Get current refresh token
  Future<String?> getRefreshToken() async {
    try {
      // Return cached token if available
      if (_cachedRefreshToken != null) {
        return _cachedRefreshToken;
      }
      // Otherwise read from secure storage and cache it
      final token = await _secureStorage.read(key: OrbitNestConstants.refreshTokenKey);
      if (token != null) {
        _cachedRefreshToken = token;
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Get API key
  Future<String?> getApiKey() async {
    if (_apiKey != null) return _apiKey;

    try {
      return await _secureStorage.read(key: OrbitNestConstants.apiKeyKey);
    } catch (e) {
      return null;
    }
  }

  /// Store API key
  Future<void> storeApiKey(String apiKey) async {
    try {
      await _secureStorage.write(
        key: OrbitNestConstants.apiKeyKey,
        value: apiKey,
      );
    } catch (e) {
      throw Exception('Failed to store API key: $e');
    }
  }

  /// Clear all stored authentication data
  Future<void> clearSession() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: OrbitNestConstants.sessionKey),
        _secureStorage.delete(key: OrbitNestConstants.accessTokenKey),
        _secureStorage.delete(key: OrbitNestConstants.refreshTokenKey),
      ]);
      
      // Clear cached tokens
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
    } catch (e) {
      // Ignore errors when clearing
    }
  }

  /// Check if token is expired
  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      // If we can't decode the token, consider it expired
      return true;
    }
  }

  /// Check if token will expire within the given duration
  bool isTokenExpiringWithin(String token, Duration duration) {
    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final timeUntilExpiration = expirationDate.difference(now);
      return timeUntilExpiration <= duration;
    } catch (e) {
      // If we can't decode the token, consider it expiring
      return true;
    }
  }

  /// Get token expiration time
  DateTime? getTokenExpirationTime(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }

  /// Decode token payload
  Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  /// Extract user ID from token
  String? getUserIdFromToken(String token) {
    try {
      final payload = JwtDecoder.decode(token);
      return payload['sub'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Extract user email from token
  String? getUserEmailFromToken(String token) {
    try {
      final payload = JwtDecoder.decode(token);
      return payload['email'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Check if session needs refresh
  Future<bool> shouldRefreshSession() async {
    final session = await getStoredSession();
    if (session == null) return false;

    // Check if session is expired or expiring within threshold
    return session.isExpired ||
        session.isExpiringWithin(const Duration(minutes: 5));
  }

  /// Refresh session callback - should be set by AuthBloc
  Future<bool> Function()? _refreshCallback;

  /// In-flight refresh – deduplicate concurrent callers so only one HTTP
  /// request to /auth/refresh is made at a time.
  Future<bool>? _pendingRefresh;

  /// Set the refresh callback (called by AuthBloc during initialization)
  void setRefreshCallback(Future<bool> Function() callback) {
    _refreshCallback = callback;
  }

  /// Refresh session using the registered callback.
  /// If a refresh is already in progress, the caller awaits the same Future
  /// instead of firing a second HTTP request.
  Future<bool> refreshSession() async {
    if (_refreshCallback == null) {
      return false;
    }

    if (_pendingRefresh != null) {
      return _pendingRefresh!;
    }

    _pendingRefresh = _refreshCallback!();
    try {
      final result = await _pendingRefresh!;
      return result;
    } catch (e) {
      OrbitNestLogger.error('Token refresh failed', e);
      return false;
    } finally {
      _pendingRefresh = null;
    }
  }

  /// Store project slug
  Future<void> storeProjectInfo({String? projectSlug}) async {
    try {
      if (projectSlug != null) {
        await _secureStorage.write(
          key: OrbitNestConstants.projectSlugKey,
          value: projectSlug,
        );
      }
    } catch (e) {
      throw Exception('Failed to store project info: $e');
    }
  }

  /// Get stored project slug
  Future<String?> getProjectSlug() async {
    if (_projectSlug != null) return _projectSlug;

    try {
      return await _secureStorage.read(key: OrbitNestConstants.projectSlugKey);
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();

      // Clear cached tokens
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
    } catch (e) {
      // Ignore errors when clearing all
    }
  }

  /// Generate checksum for data integrity verification
  String _generateChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate that a freshly-received session (from sign-in or token refresh)
  /// is safe to persist. Only the access token is checked — the refresh token
  /// expiry is the server's concern, not the client's.
  bool _isValidSession(Session session) {
    try {
      if (session.accessToken.isEmpty) return false;
      if (isTokenExpired(session.accessToken)) return false;

      final tokenAge = _getTokenAge(session.accessToken);
      if (tokenAge != null && tokenAge.inHours > _maxTokenAge) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get token age from issued time
  Duration? _getTokenAge(String token) {
    try {
      final payload = JwtDecoder.decode(token);
      final iat = payload['iat'] as int?;
      if (iat == null) return null;

      final issuedAt = DateTime.fromMillisecondsSinceEpoch(iat * 1000);
      return DateTime.now().difference(issuedAt);
    } catch (e) {
      return null;
    }
  }

  /// Check if token is about to expire and needs refresh
  bool needsRefresh(String token) {
    return isTokenExpiringWithin(
      token,
      const Duration(minutes: _refreshThresholdMinutes),
    );
  }

  /// Validate API key format
  bool isValidApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) return false;

    // Basic API key validation - should be at least 32 characters
    if (apiKey.length < 32) return false;

    // Should contain only alphanumeric characters and some special chars
    final validChars = RegExp(r'^[a-zA-Z0-9\-_.]+$');
    return validChars.hasMatch(apiKey);
  }
}
