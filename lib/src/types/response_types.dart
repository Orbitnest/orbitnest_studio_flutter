/// Common response types used across the package
library;

/// Pagination information
class PaginationInfo {
  const PaginationInfo({
    this.page,
    this.limit,
    this.offset,
    this.totalCount,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  final int? page;
  final int? limit;
  final int? offset;
  final int? totalCount;
  final bool? hasNextPage;
  final bool? hasPreviousPage;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
      totalCount: json['totalCount'] as int?,
      hasNextPage: json['hasNextPage'] as bool?,
      hasPreviousPage: json['hasPreviousPage'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
      if (totalCount != null) 'totalCount': totalCount,
      if (hasNextPage != null) 'hasNextPage': hasNextPage,
      if (hasPreviousPage != null) 'hasPreviousPage': hasPreviousPage,
    };
  }
}

/// Success response with optional data
class SuccessResponse<T> {
  const SuccessResponse({
    this.data,
    this.message,
    this.statusCode = 200,
  });

  final T? data;
  final String? message;
  final int statusCode;

  factory SuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return SuccessResponse<T>(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int? ?? 200,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      if (data != null)
        'data': toJsonT != null ? toJsonT(data as T) : data,
      if (message != null) 'message': message,
      'statusCode': statusCode,
    };
  }
}

/// Health check response
class HealthCheckResponse {
  const HealthCheckResponse({
    required this.status,
    this.timestamp,
    this.version,
    this.uptime,
    this.services,
  });

  final String status;
  final DateTime? timestamp;
  final String? version;
  final Duration? uptime;
  final Map<String, String>? services;

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) {
    return HealthCheckResponse(
      status: json['status'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      version: json['version'] as String?,
      uptime: json['uptime'] != null
          ? Duration(seconds: json['uptime'] as int)
          : null,
      services: json['services'] != null
          ? Map<String, String>.from(json['services'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      if (version != null) 'version': version,
      if (uptime != null) 'uptime': uptime!.inSeconds,
      if (services != null) 'services': services,
    };
  }
}

/// Generic operation result
enum OperationStatus { success, error, pending, cancelled }

class OperationResult<T> {
  const OperationResult({
    required this.status,
    this.data,
    this.error,
    this.message,
  });

  final OperationStatus status;
  final T? data;
  final Exception? error;
  final String? message;

  bool get isSuccess => status == OperationStatus.success;
  bool get isError => status == OperationStatus.error;
  bool get isPending => status == OperationStatus.pending;
  bool get isCancelled => status == OperationStatus.cancelled;

  factory OperationResult.success(T data, [String? message]) {
    return OperationResult(
      status: OperationStatus.success,
      data: data,
      message: message,
    );
  }

  factory OperationResult.error(Exception error, [String? message]) {
    return OperationResult(
      status: OperationStatus.error,
      error: error,
      message: message,
    );
  }

  factory OperationResult.pending([String? message]) {
    return OperationResult(
      status: OperationStatus.pending,
      message: message,
    );
  }

  factory OperationResult.cancelled([String? message]) {
    return OperationResult(
      status: OperationStatus.cancelled,
      message: message,
    );
  }
}