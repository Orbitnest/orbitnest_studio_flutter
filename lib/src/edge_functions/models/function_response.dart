
/// Response from edge function invocation
class FunctionResponse {
  const FunctionResponse({
    required this.data,
    required this.status,
    required this.statusText,
    required this.headers,
    this.executionTimeMs,
    this.error,
    this.errorDetails,
  });

  final dynamic data;
  final int status;
  final String statusText;
  final Map<String, String> headers;
  final int? executionTimeMs;
  final String? error;
  final String? errorDetails;

  factory FunctionResponse.fromJson(Map<String, dynamic> json) {
    return FunctionResponse(
      data: json['data'],
      status: json['status'] as int,
      statusText: json['status_text'] as String,
      headers: Map<String, String>.from(json['headers'] as Map),
      executionTimeMs: json['execution_time_ms'] as int?,
      error: json['error'] as String?,
      errorDetails: json['error_details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'status': status,
      'status_text': statusText,
      'headers': headers,
      if (executionTimeMs != null) 'execution_time_ms': executionTimeMs,
      if (error != null) 'error': error,
      if (errorDetails != null) 'error_details': errorDetails,
    };
  }

  /// Check if the response is successful
  bool get isSuccess => status >= 200 && status < 300 && error == null;

  /// Check if the response has an error
  bool get hasError => status >= 400 || error != null;
}

/// Edge function definition
class EdgeFunction {
  const EdgeFunction({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.sourceCode,
    this.environmentVariables,
    this.executionConfig,
    required this.createdAt,
    required this.updatedAt,
    this.lastExecutionAt,
    this.executionCount,
    this.errorCount,
  });

  final String id;
  final String name;
  final String? description;
  final String status;
  final String? sourceCode;
  final Map<String, String>? environmentVariables;
  final Map<String, dynamic>? executionConfig;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastExecutionAt;
  final int? executionCount;
  final int? errorCount;

  factory EdgeFunction.fromJson(Map<String, dynamic> json) {
    return EdgeFunction(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      sourceCode: json['source_code'] as String?,
      environmentVariables: json['environment_variables'] != null
          ? Map<String, String>.from(json['environment_variables'] as Map)
          : null,
      executionConfig: json['execution_config'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastExecutionAt: json['last_execution_at'] != null
          ? DateTime.parse(json['last_execution_at'] as String)
          : null,
      executionCount: json['execution_count'] as int?,
      errorCount: json['error_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'status': status,
      if (sourceCode != null) 'source_code': sourceCode,
      if (environmentVariables != null) 'environment_variables': environmentVariables,
      if (executionConfig != null) 'execution_config': executionConfig,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (lastExecutionAt != null) 'last_execution_at': lastExecutionAt!.toIso8601String(),
      if (executionCount != null) 'execution_count': executionCount,
      if (errorCount != null) 'error_count': errorCount,
    };
  }
}

/// Function execution result
class FunctionExecutionResult {
  const FunctionExecutionResult({
    required this.id,
    required this.functionName,
    required this.status,
    required this.executionTimeMs,
    this.memoryUsedMb,
    required this.startedAt,
    this.finishedAt,
    this.error,
    this.errorDetails,
    this.consoleLogs,
  });

  final String id;
  final String functionName;
  final String status;
  final int executionTimeMs;
  final double? memoryUsedMb;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? error;
  final String? errorDetails;
  final List<String>? consoleLogs;

  factory FunctionExecutionResult.fromJson(Map<String, dynamic> json) {
    return FunctionExecutionResult(
      id: json['id'] as String,
      functionName: json['function_name'] as String,
      status: json['status'] as String,
      executionTimeMs: json['execution_time_ms'] as int,
      memoryUsedMb: json['memory_used_mb'] as double?,
      startedAt: DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'] as String)
          : null,
      error: json['error'] as String?,
      errorDetails: json['error_details'] as String?,
      consoleLogs: json['console_logs'] != null
          ? List<String>.from(json['console_logs'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'function_name': functionName,
      'status': status,
      'execution_time_ms': executionTimeMs,
      if (memoryUsedMb != null) 'memory_used_mb': memoryUsedMb,
      'started_at': startedAt.toIso8601String(),
      if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
      if (error != null) 'error': error,
      if (errorDetails != null) 'error_details': errorDetails,
      if (consoleLogs != null) 'console_logs': consoleLogs,
    };
  }
}

/// Environment variable
class EnvironmentVariable {
  const EnvironmentVariable({
    required this.name,
    required this.value,
    this.description,
    this.isSecret,
    required this.createdAt,
    required this.updatedAt,
  });

  final String name;
  final String value;
  final String? description;
  final bool? isSecret;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory EnvironmentVariable.fromJson(Map<String, dynamic> json) {
    return EnvironmentVariable(
      name: json['name'] as String,
      value: json['value'] as String,
      description: json['description'] as String?,
      isSecret: json['is_secret'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      if (description != null) 'description': description,
      if (isSecret != null) 'is_secret': isSecret,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Function logs entry
class FunctionLogEntry {
  const FunctionLogEntry({
    required this.id,
    required this.functionName,
    required this.executionId,
    required this.level,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  final String id;
  final String functionName;
  final String executionId;
  final String level;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  factory FunctionLogEntry.fromJson(Map<String, dynamic> json) {
    return FunctionLogEntry(
      id: json['id'] as String,
      functionName: json['function_name'] as String,
      executionId: json['execution_id'] as String,
      level: json['level'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'function_name': functionName,
      'execution_id': executionId,
      'level': level,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}