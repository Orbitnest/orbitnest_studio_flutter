import 'package:freezed_annotation/freezed_annotation.dart';

part 'function_response.freezed.dart';
part 'function_response.g.dart';

/// Response from edge function invocation
@freezed
class FunctionResponse with _$FunctionResponse {
  const factory FunctionResponse({
    required dynamic data,
    required int status,
    @JsonKey(name: 'status_text') required String statusText,
    required Map<String, String> headers,
    @JsonKey(name: 'execution_time_ms') int? executionTimeMs,
    String? error,
    @JsonKey(name: 'error_details') String? errorDetails,
  }) = _FunctionResponse;

  const FunctionResponse._();

  factory FunctionResponse.fromJson(Map<String, dynamic> json) => 
      _$FunctionResponseFromJson(json);

  /// Check if the response is successful
  bool get isSuccess => status >= 200 && status < 300 && error == null;

  /// Check if the response has an error
  bool get hasError => status >= 400 || error != null;
}

/// Edge function definition
@freezed
class EdgeFunction with _$EdgeFunction {
  const factory EdgeFunction({
    required String id,
    required String name,
    String? description,
    required String status,
    @JsonKey(name: 'source_code') String? sourceCode,
    @JsonKey(name: 'environment_variables') Map<String, String>? environmentVariables,
    @JsonKey(name: 'execution_config') Map<String, dynamic>? executionConfig,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'last_execution_at') DateTime? lastExecutionAt,
    @JsonKey(name: 'execution_count') int? executionCount,
    @JsonKey(name: 'error_count') int? errorCount,
  }) = _EdgeFunction;

  factory EdgeFunction.fromJson(Map<String, dynamic> json) => 
      _$EdgeFunctionFromJson(json);
}

/// Function execution result
@freezed
class FunctionExecutionResult with _$FunctionExecutionResult {
  const factory FunctionExecutionResult({
    required String id,
    @JsonKey(name: 'function_name') required String functionName,
    required String status,
    @JsonKey(name: 'execution_time_ms') required int executionTimeMs,
    @JsonKey(name: 'memory_used_mb') double? memoryUsedMb,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'finished_at') DateTime? finishedAt,
    String? error,
    @JsonKey(name: 'error_details') String? errorDetails,
    @JsonKey(name: 'console_logs') List<String>? consoleLogs,
  }) = _FunctionExecutionResult;

  factory FunctionExecutionResult.fromJson(Map<String, dynamic> json) => 
      _$FunctionExecutionResultFromJson(json);
}

/// Environment variable
@freezed
class EnvironmentVariable with _$EnvironmentVariable {
  const factory EnvironmentVariable({
    required String name,
    required String value,
    String? description,
    @JsonKey(name: 'is_secret') bool? isSecret,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _EnvironmentVariable;

  factory EnvironmentVariable.fromJson(Map<String, dynamic> json) => 
      _$EnvironmentVariableFromJson(json);
}

/// Function logs entry
@freezed
class FunctionLogEntry with _$FunctionLogEntry {
  const factory FunctionLogEntry({
    required String id,
    @JsonKey(name: 'function_name') required String functionName,
    @JsonKey(name: 'execution_id') required String executionId,
    required String level,
    required String message,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  }) = _FunctionLogEntry;

  factory FunctionLogEntry.fromJson(Map<String, dynamic> json) => 
      _$FunctionLogEntryFromJson(json);
}