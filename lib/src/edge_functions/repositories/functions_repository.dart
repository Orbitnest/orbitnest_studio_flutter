import '../services/functions_service.dart';
import '../models/function_response.dart';
import '../exceptions/function_exception.dart';

/// Repository for edge functions operations
/// Provides a layer of abstraction between the BLoC and the service
class FunctionsRepository {
  final FunctionsService _functionsService;

  FunctionsRepository({
    required FunctionsService functionsService,
  }) : _functionsService = functionsService;

  /// Invoke an edge function
  Future<FunctionResponse> invoke(
    String functionName, {
    String method = 'POST',
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _functionsService.invoke(
        functionName,
        method: method,
        body: body,
        headers: headers,
        queryParameters: queryParameters,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Create a new edge function (admin only)
  Future<EdgeFunction> create({
    required String name,
    String? description,
    required String sourceCode,
    Map<String, String>? environmentVariables,
    Map<String, dynamic>? executionConfig,
  }) async {
    try {
      return await _functionsService.create(
        name: name,
        description: description,
        sourceCode: sourceCode,
        environmentVariables: environmentVariables,
        executionConfig: executionConfig,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// List all edge functions (admin only)
  Future<List<EdgeFunction>> list() async {
    try {
      return await _functionsService.list();
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Get a specific edge function (admin only)
  Future<EdgeFunction> get(String name) async {
    try {
      return await _functionsService.get(name);
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Update an edge function (admin only)
  Future<EdgeFunction> update({
    required String name,
    String? description,
    String? sourceCode,
    Map<String, String>? environmentVariables,
    Map<String, dynamic>? executionConfig,
  }) async {
    try {
      return await _functionsService.update(
        name: name,
        description: description,
        sourceCode: sourceCode,
        environmentVariables: environmentVariables,
        executionConfig: executionConfig,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Delete an edge function (admin only)
  Future<void> delete(String name) async {
    try {
      await _functionsService.delete(name);
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Get function logs (admin only)
  Future<List<FunctionLogEntry>> getLogs({
    required String name,
    int? limit,
    int? offset,
  }) async {
    try {
      return await _functionsService.getLogs(
        name: name,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// List environment variables (admin only)
  Future<List<EnvironmentVariable>> listEnvironmentVariables() async {
    try {
      return await _functionsService.listEnvironmentVariables();
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Set environment variable (admin only)
  Future<EnvironmentVariable> setEnvironmentVariable({
    required String name,
    required String value,
    String? description,
    bool isSecret = false,
  }) async {
    try {
      return await _functionsService.setEnvironmentVariable(
        name: name,
        value: value,
        description: description,
        isSecret: isSecret,
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Delete environment variable (admin only)
  Future<void> deleteEnvironmentVariable(String name) async {
    try {
      await _functionsService.deleteEnvironmentVariable(name);
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Set multiple environment variables (admin only)
  Future<int> setBulkEnvironmentVariables(Map<String, String> variables) async {
    try {
      return await _functionsService.setBulkEnvironmentVariables(variables);
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }
}