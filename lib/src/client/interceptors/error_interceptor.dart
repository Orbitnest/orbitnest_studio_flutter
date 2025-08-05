import 'package:dio/dio.dart';
import '../../constants/error_codes.dart';

/// Interceptor for handling HTTP errors and transforming them into meaningful exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    OrbitNestException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        exception = const OrbitNestException(
          'Connection timeout',
          code: ErrorCodes.connectionTimeout,
        );
        break;
      case DioExceptionType.sendTimeout:
        exception = const OrbitNestException(
          'Send timeout',
          code: ErrorCodes.sendTimeout,
        );
        break;
      case DioExceptionType.receiveTimeout:
        exception = const OrbitNestException(
          'Receive timeout',
          code: ErrorCodes.receiveTimeout,
        );
        break;
      case DioExceptionType.badCertificate:
        exception = const OrbitNestException(
          'Bad certificate',
          code: ErrorCodes.badCertificate,
        );
        break;
      case DioExceptionType.connectionError:
        exception = OrbitNestException(
          'Connection error: ${err.message}',
          code: ErrorCodes.connectionError,
        );
        break;
      case DioExceptionType.badResponse:
        exception = _handleBadResponse(err);
        break;
      case DioExceptionType.cancel:
        exception = const OrbitNestException(
          'Request cancelled',
          code: ErrorCodes.requestCancelled,
        );
        break;
      case DioExceptionType.unknown:
        // Handle timeout and other unknown errors more gracefully
        String message = 'Unknown error';
        String code = ErrorCodes.unknownError;
        
        if (err.message?.toLowerCase().contains('timeout') == true ||
            err.error?.toString().toLowerCase().contains('timeout') == true) {
          message = 'Operation timeout';
          code = ErrorCodes.operationTimeout;
        } else if (err.message != null && err.message!.isNotEmpty) {
          message = 'Unknown error: ${err.message}';
        } else if (err.error != null) {
          message = 'Unknown error: ${err.error}';
        }
        
        exception = OrbitNestException(
          message,
          code: code,
        );
        break;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
        message: exception.message,
      ),
    );
  }

  OrbitNestException _handleBadResponse(DioException err) {
    final response = err.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'HTTP Error';
    String? code;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      code = data['code']?.toString();
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return OrbitNestException(
          message.isEmpty ? 'Bad Request' : message,
          code: code ?? ErrorCodes.badRequest,
          statusCode: statusCode,
        );
      case 401:
        return OrbitNestException(
          message.isEmpty ? 'Unauthorized' : message,
          code: code ?? ErrorCodes.unauthorized,
          statusCode: statusCode,
        );
      case 403:
        return OrbitNestException(
          message.isEmpty ? 'Forbidden' : message,
          code: code ?? ErrorCodes.forbidden,
          statusCode: statusCode,
        );
      case 404:
        return OrbitNestException(
          message.isEmpty ? 'Not Found' : message,
          code: code ?? ErrorCodes.notFound,
          statusCode: statusCode,
        );
      case 429:
        return OrbitNestException(
          message.isEmpty ? 'Too Many Requests' : message,
          code: code ?? ErrorCodes.rateLimitExceeded,
          statusCode: statusCode,
        );
      case 500:
        return OrbitNestException(
          message.isEmpty ? 'Internal Server Error' : message,
          code: code ?? ErrorCodes.internalServerError,
          statusCode: statusCode,
        );
      case 502:
        return OrbitNestException(
          message.isEmpty ? 'Bad Gateway' : message,
          code: code ?? ErrorCodes.badGateway,
          statusCode: statusCode,
        );
      case 503:
        return OrbitNestException(
          message.isEmpty ? 'Service Unavailable' : message,
          code: code ?? ErrorCodes.serviceUnavailable,
          statusCode: statusCode,
        );
      default:
        return OrbitNestException(
          message.isEmpty ? 'HTTP Error $statusCode' : message,
          code: code ?? ErrorCodes.httpError,
          statusCode: statusCode,
        );
    }
  }
}

/// Base exception class for OrbitNest errors
class OrbitNestException implements Exception {
  const OrbitNestException(
    this.message, {
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() {
    if (code != null) {
      return 'OrbitNestException($code): $message';
    }
    return 'OrbitNestException: $message';
  }
}