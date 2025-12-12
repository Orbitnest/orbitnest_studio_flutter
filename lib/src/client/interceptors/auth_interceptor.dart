import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../auth/services/token_manager.dart';

/// Interceptor for handling authentication tokens
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Check if this is an auth endpoint that doesn't need tokens
      if (_isAuthEndpoint(options.path)) {
        debugPrint('🔓 [AuthInterceptor] Auth endpoint, skipping token: ${options.path}');
        handler.next(options);
        return;
      }

      // Get the current token
      debugPrint('🔑 [AuthInterceptor] Getting access token for: ${options.path}');
      final token = await _tokenManager.getAccessToken();
      if (token != null) {
        final previewLength = token.length < 50 ? token.length : 50;
        debugPrint('🔑 [AuthInterceptor] Token retrieved: yes (${token.substring(0, previewLength)}...)');
        debugPrint('🔑 [AuthInterceptor] Token length: ${token.length}');
      } else {
        debugPrint('🔑 [AuthInterceptor] Token retrieved: no');
      }

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ [AuthInterceptor] Added Authorization header');
      }

      // Add API key if available and no bearer token
      if (token == null) {
        debugPrint('🔑 [AuthInterceptor] No token, trying API key...');
        final apiKey = await _tokenManager.getApiKey();
        debugPrint('🔑 [AuthInterceptor] API key retrieved: ${apiKey != null ? "yes" : "no"}');
        if (apiKey != null) {
          options.headers['apikey'] = apiKey;
          options.headers['Authorization'] = 'Bearer $apiKey';
          debugPrint('✅ [AuthInterceptor] Added API key as Authorization header');
        }
      }

      handler.next(options);
    } catch (e) {
      debugPrint('❌ [AuthInterceptor] Error: $e');
      handler.next(options);
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors by attempting to refresh the token or use API key
    if (err.response?.statusCode == 401) {
      final errorMessage = err.response?.data?.toString() ?? '';
      
      // If invalid signature, try using API key instead
      if (errorMessage.contains('invalid signature')) {
        debugPrint('🔄 [AuthInterceptor] Invalid signature, retrying with API key...');
        try {
          final apiKey = await _tokenManager.getApiKey();
          if (apiKey != null) {
            err.requestOptions.headers['apikey'] = apiKey;
            err.requestOptions.headers['Authorization'] = 'Bearer $apiKey';
            
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
            
            debugPrint('✅ [AuthInterceptor] Retry with API key successful');
            handler.resolve(response);
            return;
          }
        } catch (e) {
          debugPrint('❌ [AuthInterceptor] Retry with API key failed: $e');
        }
      }
      
      // Try refreshing the token
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
      '/api/projects/', // Only project-level auth endpoints (not database/functions)
      '/api/project/', // Client-level endpoints
    ];

    // Check if it's an auth endpoint, but NOT a database or function endpoint
    final isAuth = authPaths.any((authPath) => path.contains(authPath));
    final isDatabase = path.contains('/database/');
    final isFunction = path.contains('/functions/');
    
    return isAuth && !isDatabase && !isFunction;
  }
}