import 'package:freezed_annotation/freezed_annotation.dart';

part 'postgrest_response.freezed.dart';
part 'postgrest_response.g.dart';

/// Response from PostgreSQL operations (Supabase-compatible)
@Freezed(genericArgumentFactories: true)
class PostgrestResponse<T> with _$PostgrestResponse<T> {
  const factory PostgrestResponse({
    required List<T> data,
    int? count,
    String? error,
    String? hint,
    String? details,
    String? code,
    int? status,
    @JsonKey(name: 'status_code') int? statusCode,
    @JsonKey(name: 'error_description') String? errorDescription,
  }) = _PostgrestResponse<T>;

  const PostgrestResponse._();

  factory PostgrestResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PostgrestResponseFromJson(json, fromJsonT);

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
@Freezed(genericArgumentFactories: true)
class PostgrestSingleResponse<T> with _$PostgrestSingleResponse<T> {
  const factory PostgrestSingleResponse({
    T? data,
    String? error,
    String? hint,
    String? details,
    String? code,
    int? status,
    @JsonKey(name: 'status_code') int? statusCode,
    @JsonKey(name: 'error_description') String? errorDescription,
  }) = _PostgrestSingleResponse<T>;

  const PostgrestSingleResponse._();

  factory PostgrestSingleResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PostgrestSingleResponseFromJson(json, fromJsonT);

  /// Check if the response is successful
  bool get isSuccess => error == null && (status == null || status! < 400);

  /// Check if the response has an error
  bool get hasError => error != null || (status != null && status! >= 400);
}

/// Response for count-only operations
@freezed
class PostgrestCountResponse with _$PostgrestCountResponse {
  const factory PostgrestCountResponse({
    required int count,
    String? error,
    String? hint,
    String? details,
    String? code,
    int? status,
    @JsonKey(name: 'status_code') int? statusCode,
    @JsonKey(name: 'error_description') String? errorDescription,
  }) = _PostgrestCountResponse;

  const PostgrestCountResponse._();

  factory PostgrestCountResponse.fromJson(Map<String, dynamic> json) =>
      _$PostgrestCountResponseFromJson(json);

  /// Check if the response is successful
  bool get isSuccess => error == null && (status == null || status! < 400);

  /// Check if the response has an error
  bool get hasError => error != null || (status != null && status! >= 400);
}