import 'package:dio/dio.dart';
import '../../auth/services/token_manager.dart';

/// Interceptor for handling authentication tokens
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Check if this is an auth endpoint that doesn't need tokens
      if (_isAuthEndpoint(options.path)) {
        handler.next(options);
        return;
      }

      // Get the current token
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Add API key if available and no bearer token
      if (token == null) {
        final apiKey = await _tokenManager.getApiKey();
        if (apiKey != null) {
          options.headers['apikey'] = apiKey;
          options.headers['Authorization'] = 'Bearer $apiKey';
        }
      }

      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors by attempting to refresh the token
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _tokenManager.refreshSession();
        if (refreshed) {
          // Retry the original request with the new token
          final token = await _tokenManager.getAccessToken();
          if (token != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            
            // Create a new Dio instance to avoid infinite loops
            final dio = Dio();
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
      } catch (e) {
        // Refresh failed, proceed with original error
      }
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    final authPaths = [
      '/auth/signin',
      '/auth/signup',
      '/auth/refresh',
      '/auth/verify',
      '/auth/recover',
      '/auth/reset-password',
      '/projects/',
    ];

    return authPaths.any((authPath) => path.contains(authPath));
  }
}