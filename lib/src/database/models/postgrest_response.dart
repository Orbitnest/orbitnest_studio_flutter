/// Response from PostgreSQL operations (Supabase-compatible)
class PostgrestResponse<T> {
  const PostgrestResponse({
    required this.data,
    this.count,
    this.error,
    this.hint,
    this.details,
    this.code,
    this.status,
    this.statusCode,
    this.errorDescription,
  });

  final List<T> data;
  final int? count;
  final String? error;
  final String? hint;
  final String? details;
  final String? code;
  final int? status;
  final int? statusCode;
  final String? errorDescription;

  factory PostgrestResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return PostgrestResponse<T>(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => fromJsonT(e))
          .toList() ?? <T>[],
      count: json['count'] as int?,
      error: json['error'] as String?,
      hint: json['hint'] as String?,
      details: json['details'] as String?,
      code: json['code'] as String?,
      status: json['status'] as int?,
      statusCode: json['status_code'] as int?,
      errorDescription: json['error_description'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'data': data.map((e) => toJsonT(e)).toList(),
      if (count != null) 'count': count,
      if (error != null) 'error': error,
      if (hint != null) 'hint': hint,
      if (details != null) 'details': details,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
      if (statusCode != null) 'status_code': statusCode,
      if (errorDescription != null) 'error_description': errorDescription,
    };
  }

  /// Check if the response is successful
  bool get isSuccess => error == null && (status == null || status! < 400);

  /// Check if the response has an error
  bool get hasError => error != null || (status != null && status! >= 400);

  /// Get the first item from data if available
  T? get firstOrNull => data.isEmpty ? null : data.first;

  /// Get the total count or fall back to data length
  int get totalCount => count ?? data.length;
}

/// Simplified response for operations that return single items
class PostgrestSingleResponse<T> {
  const PostgrestSingleResponse({
    this.data,
    this.error,
    this.hint,
    this.details,
    this.code,
    this.status,
    this.statusCode,
    this.errorDescription,
  });

  final T? data;
  final String? error;
  final String? hint;
  final String? details;
  final String? code;
  final int? status;
  final int? statusCode;
  final String? errorDescription;

  factory PostgrestSingleResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return PostgrestSingleResponse<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] as String?,
      hint: json['hint'] as String?,
      details: json['details'] as String?,
      code: json['code'] as String?,
      status: json['status'] as int?,
      statusCode: json['status_code'] as int?,
      errorDescription: json['error_description'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      if (data != null) 'data': toJsonT(data as T),
      if (error != null) 'error': error,
      if (hint != null) 'hint': hint,
      if (details != null) 'details': details,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
      if (statusCode != null) 'status_code': statusCode,
      if (errorDescription != null) 'error_description': errorDescription,
    };
  }

  /// Check if the response is successful
  bool get isSuccess => error == null && (status == null || status! < 400);

  /// Check if the response has an error
  bool get hasError => error != null || (status != null && status! >= 400);
}

/// Response for count-only operations
class PostgrestCountResponse {
  const PostgrestCountResponse({
    required this.count,
    this.error,
    this.hint,
    this.details,
    this.code,
    this.status,
    this.statusCode,
    this.errorDescription,
  });

  final int count;
  final String? error;
  final String? hint;
  final String? details;
  final String? code;
  final int? status;
  final int? statusCode;
  final String? errorDescription;

  factory PostgrestCountResponse.fromJson(Map<String, dynamic> json) {
    return PostgrestCountResponse(
      count: json['count'] as int,
      error: json['error'] as String?,
      hint: json['hint'] as String?,
      details: json['details'] as String?,
      code: json['code'] as String?,
      status: json['status'] as int?,
      statusCode: json['status_code'] as int?,
      errorDescription: json['error_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      if (error != null) 'error': error,
      if (hint != null) 'hint': hint,
      if (details != null) 'details': details,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
      if (statusCode != null) 'status_code': statusCode,
      if (errorDescription != null) 'error_description': errorDescription,
    };
  }

  /// Check if the response is successful
  bool get isSuccess => error == null && (status == null || status! < 400);

  /// Check if the response has an error
  bool get hasError => error != null || (status != null && status! >= 400);
}