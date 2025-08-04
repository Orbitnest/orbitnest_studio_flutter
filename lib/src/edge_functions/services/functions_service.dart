import '../../client/http_client.dart';
import '../../constants/endpoints.dart';
import '../models/function_response.dart';
import '../exceptions/function_exception.dart';
import 'package:dio/dio.dart';

/// Service for handling edge functions API calls
class FunctionsService {
  final OrbitNestHttpClient _httpClient;
  final String _projectSlug;
  final String _projectId;

  FunctionsService({
    required OrbitNestHttpClient httpClient,
    required String projectSlug,
    required String projectId,
  }) : _httpClient = httpClient,
       _projectSlug = projectSlug,
       _projectId = projectId;

  /// Invoke an edge function
  Future<FunctionResponse> invoke(
    String functionName, {
    String method = 'POST',
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _httpClient.request(
        method,
        Endpoints.invokeFunction(_projectSlug, functionName),
        data: body,
        options: Options(headers: headers),
      );

      return FunctionResponse(
        data: response.data,
        status: response.statusCode ?? 200,
        statusText: response.statusMessage ?? 'OK',
        headers: Map<String, String>.from(
          response.headers.map.map((key, value) => MapEntry(key, value.join(', '))),
        ),
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
      final response = await _httpClient.post(
        Endpoints.projectFunctions(_projectId),
        data: {
          'name': name,
          if (description != null) 'description': description,
          'source_code': sourceCode,
          if (environmentVariables != null) 'environment_variables': environmentVariables,
          if (executionConfig != null) 'execution_config': executionConfig,
        },
      );

      return EdgeFunction.fromJson(response.data);
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// List all edge functions (admin only)
  Future<List<EdgeFunction>> list() async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectFunctions(_projectId),
      );

      final data = response.data as List;
      return data.map((item) => EdgeFunction.fromJson(item)).toList();
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Get a specific edge function (admin only)
  Future<EdgeFunction> get(String name) async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectFunctionByName(_projectId, name),
      );

      return EdgeFunction.fromJson(response.data);
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
      final response = await _httpClient.put(
        Endpoints.projectFunctionByName(_projectId, name),
        data: {
          if (description != null) 'description': description,
          if (sourceCode != null) 'source_code': sourceCode,
          if (environmentVariables != null) 'environment_variables': environmentVariables,
          if (executionConfig != null) 'execution_config': executionConfig,
        },
      );

      return EdgeFunction.fromJson(response.data);
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Delete an edge function (admin only)
  Future<void> delete(String name) async {
    try {
      await _httpClient.delete(
        Endpoints.projectFunctionByName(_projectId, name),
      );
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
      final response = await _httpClient.get(
        Endpoints.projectFunctionLogs(_projectId, name),
        queryParameters: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

      final data = response.data as List;
      return data.map((item) => FunctionLogEntry.fromJson(item)).toList();
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// List environment variables (admin only)
  Future<List<EnvironmentVariable>> listEnvironmentVariables() async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectEnvironmentVariables(_projectId),
      );

      final data = response.data as List;
      return data.map((item) => EnvironmentVariable.fromJson(item)).toList();
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
      final response = await _httpClient.post(
        Endpoints.projectEnvironmentVariables(_projectId),
        data: {
          'name': name,
          'value': value,
          if (description != null) 'description': description,
          'is_secret': isSecret,
        },
      );

      return EnvironmentVariable.fromJson(response.data);
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Delete environment variable (admin only)
  Future<void> deleteEnvironmentVariable(String name) async {
    try {
      await _httpClient.delete(
        Endpoints.projectEnvironmentVariableByName(_projectId, name),
      );
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }

  /// Set multiple environment variables (admin only)
  Future<int> setBulkEnvironmentVariables(Map<String, String> variables) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectEnvironmentVariablesBulk(_projectId),
        data: {
          'variables': variables.entries.map((e) => {
            'name': e.key,
            'value': e.value,
          }).toList(),
        },
      );

      return response.data['count'] ?? variables.length;
    } catch (e) {
      throw FunctionException.fromException(e);
    }
  }
}