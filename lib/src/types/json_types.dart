/// Type definitions for JSON data
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<JsonMap>;

/// Response wrapper for API calls
class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    this.message,
    this.success = true,
    this.statusCode,
  });

  final T data;
  final String? message;
  final bool success;
  final int? statusCode;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: fromJsonT(json['data']),
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'data': toJsonT(data),
      if (message != null) 'message': message,
      'success': success,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}

/// Generic list response wrapper
class ListResponse<T> {
  const ListResponse({
    required this.data,
    this.count,
    this.totalCount,
    this.message,
    this.success = true,
    this.statusCode,
  });

  final List<T> data;
  final int? count;
  final int? totalCount;
  final String? message;
  final bool success;
  final int? statusCode;

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataList = json['data'] as List?;
    return ListResponse<T>(
      data: dataList?.map((item) => fromJsonT(item)).toList() ?? [],
      count: json['count'] as int?,
      totalCount: json['totalCount'] as int?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      if (count != null) 'count': count,
      if (totalCount != null) 'totalCount': totalCount,
      if (message != null) 'message': message,
      'success': success,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}

/// Error response structure
class ErrorResponse {
  const ErrorResponse({
    required this.message,
    this.code,
    this.details,
    this.statusCode,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  final int? statusCode;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] as String? ?? 'Unknown error',
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (code != null) 'code': code,
      if (details != null) 'details': details,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}