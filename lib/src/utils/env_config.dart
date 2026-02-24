import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
/// Loads configuration from .env file or environment variables
class EnvConfig {
  static bool _initialized = false;

  /// The hardcoded OrbitNest API base URL — always the same for all projects
  static const String kBaseUrl = 'https://api.orbitnest.io';

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

  /// Get OrbitNest Studio base URL — hardcoded, never changes
  static String get baseUrl => kBaseUrl;

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
