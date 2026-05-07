import 'package:dio/dio.dart';
import '../../auth/services/token_manager.dart';

/// Interceptor for handling authentication tokens
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Auth endpoints don't need tokens
      if (_isAuthEndpoint(options.path)) {
        handler.next(options);
        return;
      }

      // Client/database endpoints: apikey must always be present for PostgREST,
      // regardless of whether there is an authenticated user.
      if (_isClientEndpoint(options.path)) {
        final apiKey = await _tokenManager.getApiKey();
        if (apiKey != null) {
          options.headers['apikey'] = apiKey;
        }

        final accessToken = await _tokenManager.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        } else if (apiKey != null) {
          // Unauthenticated client request: anon key serves as the bearer.
          options.headers['Authorization'] = 'Bearer $apiKey';
        }

        handler.next(options);
        return;
      }

      // Other endpoints: use user access token, fall back to API key
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        final apiKey = await _tokenManager.getApiKey();
        if (apiKey != null) {
          options.headers['apikey'] = apiKey;
          options.headers['Authorization'] = 'Bearer $apiKey';
        }
      }

      handler.next(options);
    } catch (_) {
      // Best-effort — let the request through without auth headers
      handler.next(options);
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors or invalid signature errors
    if (err.response?.statusCode == 401) {
      final errorMessage = err.response?.data?.toString() ?? '';

      // If the error is due to invalid signature, try using API key instead
      if (errorMessage.contains('invalid signature')) {
        try {
          final apiKey = await _tokenManager.getApiKey();
          if (apiKey != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $apiKey';
            err.requestOptions.headers['apikey'] = apiKey;

            // Create a new Dio instance with the same base URL to avoid infinite loops
            final dio = Dio(BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              connectTimeout: err.requestOptions.connectTimeout,
              receiveTimeout: err.requestOptions.receiveTimeout,
            ));

            final response = await dio.request(
              err.requestOptions.path,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            handler.resolve(response);
            return;
          }
        } catch (_) {
          // API key fallback failed — fall through to refresh attempt
        }
      }

      // Try to refresh the token
      try {
        final refreshed = await _tokenManager.refreshSession();
        if (refreshed) {
          // Retry the original request with the refreshed token.
          // Re-apply both Authorization and apikey so the retry is fully
          // authenticated — the apikey header must always be present for
          // PostgREST endpoints even after a token refresh.
          final token = await _tokenManager.getAccessToken();
          final apiKey = await _tokenManager.getApiKey();
          if (token != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            if (apiKey != null) {
              err.requestOptions.headers['apikey'] = apiKey;
            }

            // Create a new Dio instance with the same base URL to avoid infinite loops
            final dio = Dio(BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              connectTimeout: err.requestOptions.connectTimeout,
              receiveTimeout: err.requestOptions.receiveTimeout,
            ));

            final response = await dio.request(
              err.requestOptions.path,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            handler.resolve(response);
            return;
          }
        }
      } catch (_) {
        // Refresh failed, proceed with original error
      }
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    // Only the specific public auth operations should skip the token.
    // Broad path prefixes like '/api/projects/' must NOT appear here because
    // they would also match authenticated endpoints such as /auth/user
    // (profile update) and /auth/refresh, causing those calls to go out
    // without a token and fail with 401.
    const authPaths = [
      '/auth/signin',
      '/auth/signup',
      '/auth/verify-signup',
      '/auth/verify',
      '/auth/recover',
      '/auth/reset-password',
    ];

    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// Check if this is a client endpoint that requires authentication
  /// These are endpoints like /api/project/:slug/database/*, /api/project/:slug/functions/*, or /api/project/:slug/storage/*
  bool _isClientEndpoint(String path) {
    final isClientPath = path.contains('/api/project/') || path.contains('/api/projects/');
    final isDatabase = path.contains('/database/');
    final isFunction = path.contains('/functions/');
    final isStorage = path.contains('/storage/');

    return isClientPath && (isDatabase || isFunction || isStorage);
  }
}
