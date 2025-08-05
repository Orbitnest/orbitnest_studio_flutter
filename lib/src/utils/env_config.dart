import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
/// Loads configuration from .env file or environment variables
class EnvConfig {
  static bool _initialized = false;

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

  /// Get OrbitNest Studio base URL
  static String get baseUrl {
    _ensureInitialized();
    return dotenv.env['ORBITNEST_BASE_URL'] ?? 'http://localhost:3001';
  }

  /// Get project slug
  static String get projectSlug {
    _ensureInitialized();
    final slug = dotenv.env['ORBITNEST_PROJECT_SLUG'];
    if (slug == null || slug.isEmpty) {
      throw Exception('ORBITNEST_PROJECT_SLUG is required in .env file');
    }
    return slug;
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

  /// Get project ID (defaults to project slug if not specified)
  static String get projectId {
    _ensureInitialized();
    return dotenv.env['ORBITNEST_PROJECT_ID'] ?? projectSlug;
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
