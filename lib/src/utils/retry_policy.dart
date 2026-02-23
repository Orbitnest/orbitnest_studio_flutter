import 'dart:math';
import 'package:dio/dio.dart';
import 'logger.dart';

/// Retry policy for network requests with exponential backoff
class RetryPolicy {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool retryOnTimeout;
  final bool retryOnConnectionError;
  final List<int> retryableStatusCodes;

  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.backoffMultiplier = 2.0,
    this.retryOnTimeout = true,
    this.retryOnConnectionError = true,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
  });

  /// Execute a function with retry logic
  Future<T> execute<T>(Future<T> Function() fn) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempt++;
        OrbitNestLogger.debug('Retry attempt $attempt/$maxRetries');
        return await fn();
      } catch (e) {
        // Check if we should retry
        if (!_shouldRetry(e, attempt)) {
          OrbitNestLogger.debug('Not retrying: ${e.toString()}');
          rethrow;
        }

        // Calculate delay with exponential backoff and jitter
        final nextDelay = _calculateDelay(delay, attempt);
        OrbitNestLogger.debug(
          'Retry $attempt/$maxRetries failed, waiting ${nextDelay.inMilliseconds}ms before next attempt',
        );

        await Future.delayed(nextDelay);
        delay = _nextDelay(delay);
      }
    }
  }

  /// Check if the error is retryable
  bool _shouldRetry(dynamic error, int attempt) {
    // Don't retry if max attempts reached
    if (attempt >= maxRetries) {
      return false;
    }

    if (error is DioException) {
      // Retry on timeout errors
      if (retryOnTimeout &&
          (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout)) {
        return true;
      }

      // Retry on connection errors
      if (retryOnConnectionError &&
          (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.unknown)) {
        return true;
      }

      // Retry on specific status codes
      final statusCode = error.response?.statusCode;
      if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
        return true;
      }

      // Don't retry on 4xx errors (except 408 and 429)
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return false;
      }
    }

    return false;
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(Duration currentDelay, int attempt) {
    final delayMs = currentDelay.inMilliseconds;
    final maxDelayMs = maxDelay.inMilliseconds;

    // Calculate exponential backoff
    final exponentialDelay =
        (delayMs * pow(backoffMultiplier, attempt - 1)).toInt();

    // Add jitter (random value between 0 and exponentialDelay * 0.1)
    final jitter = Random().nextInt((exponentialDelay * 0.1).toInt() + 1);

    // Cap at maxDelay
    final totalDelay = min(exponentialDelay + jitter, maxDelayMs);

    return Duration(milliseconds: totalDelay);
  }

  /// Calculate next delay duration
  Duration _nextDelay(Duration currentDelay) {
    final nextMs = min(
      (currentDelay.inMilliseconds * backoffMultiplier).toInt(),
      maxDelay.inMilliseconds,
    );
    return Duration(milliseconds: nextMs);
  }

  /// Predefined retry policies
  static const RetryPolicy aggressive = RetryPolicy(
    maxRetries: 5,
    initialDelay: Duration(milliseconds: 200),
    maxDelay: Duration(seconds: 5),
    backoffMultiplier: 1.5,
  );

  static const RetryPolicy standard = RetryPolicy(
    maxRetries: 3,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
    backoffMultiplier: 2.0,
  );

  static const RetryPolicy conservative = RetryPolicy(
    maxRetries: 2,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 15),
    backoffMultiplier: 2.5,
  );

  /// No retry policy
  static const RetryPolicy none = RetryPolicy(
    maxRetries: 0,
  );
}
