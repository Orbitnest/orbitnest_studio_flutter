import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
/// Loads configuration from .env file or environment variables
class EnvConfig {
  static bool _initialized = false;

  /// The default OrbitNest API base URL — used when no override is provided
  static const String kBaseUrl = 'https://api.orbitnest.io';

  /// The Android emulator host alias — replaces localhost/127.0.0.1 so the
  /// emulator can reach the host machine's loopback interface.
  static const String kAndroidEmulatorHost = '10.0.2.2';

  /// Initialize the environment configuration
  /// Must be called before using any environment variables
  static Future<void> initialize({String? envFileName}) async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: envFileName ?? '.env');
      _initialized = true;
    } catch (e) {
      // If .env file doesn't exist, still mark as initialized
      // Environment variables will be used instead
      _initialized = true;
    }
  }

  /// Check if environment is initialized
  static bool get isInitialized => _initialized;

  /// Resolve a URL so that `localhost` / `127.0.0.1` is replaced with
  /// `10.0.2.2` when running on an Android emulator in debug mode.
  ///
  /// This is a no-op on physical devices, iOS, or release builds.
  static String resolveUrl(String url) {
    if (kDebugMode && !kIsWeb) {
      try {
        if (Platform.isAndroid) {
          return url
              .replaceAll('http://localhost', 'http://$kAndroidEmulatorHost')
              .replaceAll('https://localhost', 'https://$kAndroidEmulatorHost')
              .replaceAll('http://127.0.0.1', 'http://$kAndroidEmulatorHost')
              .replaceAll('https://127.0.0.1', 'https://$kAndroidEmulatorHost');
        }
      } catch (_) {
        // Platform check failed (e.g. web) — return url unchanged
      }
    }
    return url;
  }

  /// Get OrbitNest Studio base URL.
  ///
  /// Uses [kBaseUrl] (`https://api.orbitnest.io`) by default.
  /// Can be overridden via the `ORBITNEST_API_URL` env variable in `.env`
  /// — useful when pointing at a local development server.
  ///
  /// When running on an Android emulator in debug mode any `localhost` /
  /// `127.0.0.1` value is automatically rewritten to `10.0.2.2` so the
  /// emulator can reach the host machine.
  static String get baseUrl {
    // Allow an env-var override for local development
    final envUrl = _initialized ? dotenv.env['ORBITNEST_API_URL'] : null;
    final raw = (envUrl != null && envUrl.isNotEmpty) ? envUrl : kBaseUrl;
    return resolveUrl(raw);
  }

  /// Get anonymous key
  static String get anonKey {
    _ensureInitialized();
    final key = dotenv.env['ORBITNEST_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('ORBITNEST_ANON_KEY is required in .env file');
    }
    return key;
  }

  /// Get service role key (optional)
  static String? get serviceRoleKey {
    _ensureInitialized();
    return dotenv.env['ORBITNEST_SERVICE_ROLE_KEY'];
  }

  /// Decode and return the project slug embedded in the anon key JWT payload.
  ///
  /// The JWT anon key always contains `project_slug` in its payload, so we
  /// never need it as a separate env var.
  static String get projectSlug {
    return decodeProjectSlugFromJwt(anonKey);
  }

  /// Check if debug mode is enabled
  static bool get isDebugMode {
    _ensureInitialized();
    final debug = dotenv.env['ORBITNEST_DEBUG'];
    return debug?.toLowerCase() == 'true';
  }

  /// Get API timeout in milliseconds (3 minutes default)
  static int get apiTimeout {
    _ensureInitialized();
    final timeout = dotenv.env['ORBITNEST_API_TIMEOUT'];
    return int.tryParse(timeout ?? '180000') ?? 180000; // 3 minutes default
  }

  /// Decode the `project_slug` field from a JWT token payload.
  ///
  /// JWTs are structured as `header.payload.signature` where each section is
  /// base64url-encoded. We only need the payload — no secret required.
  static String decodeProjectSlugFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT format');
      }

      // Base64url decode the payload section
      String payload = parts[1];
      // Normalise base64url → base64 by adding padding
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      final decoded = utf8.decode(base64.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final slug = json['project_slug'] as String?;
      if (slug == null || slug.isEmpty) {
        throw Exception(
          'project_slug not found in ORBITNEST_ANON_KEY JWT payload',
        );
      }
      return slug;
    } catch (e) {
      throw Exception('Failed to decode project slug from ORBITNEST_ANON_KEY: $e');
    }
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.initialize() first.',
      );
    }
  }

  /// Get all environment variables as a map (for debugging)
  static Map<String, String> get allVars {
    _ensureInitialized();
    return Map.from(dotenv.env);
  }
}
