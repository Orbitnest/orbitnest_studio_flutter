import '../../client/http_client.dart';
import '../../constants/endpoints.dart';
import '../models/postgrest_response.dart';
import '../models/table_schema.dart';
import '../exceptions/database_exception.dart';

/// Service for handling database API calls
class DatabaseService {
  final OrbitNestHttpClient _httpClient;
  final String _projectSlug;

  DatabaseService({
    required OrbitNestHttpClient httpClient,
    required String projectSlug,
  }) : _httpClient = httpClient,
       _projectSlug = projectSlug;

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> executeSql({
    required String sql,
    List<dynamic>? parameters,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectDatabaseSql(_projectSlug),
        data: {
          'sql': sql,
          if (parameters != null) 'parameters': parameters,
        },
      );

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map) {
        return [Map<String, dynamic>.from(response.data)];
      }
      return [];
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Get list of tables
  Future<List<TableInfo>> listTables() async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectDatabaseTablesList(_projectSlug),
      );

      final data = response.data as List;
      return data.map((item) => TableInfo.fromJson(item)).toList();
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Get table schema
  Future<TableSchema> getTableSchema(String tableName) async {
    try {
      final response = await _httpClient.get(
        '${Endpoints.projectDatabaseTables(_projectSlug)}/$tableName/schema',
      );

      return TableSchema.fromJson(response.data);
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Enable RLS for a table
  Future<void> enableRls(String tableName) async {
    try {
      await _httpClient.post(
        Endpoints.projectDatabaseTableEnableRls(_projectSlug, tableName),
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Disable RLS for a table
  Future<void> disableRls(String tableName) async {
    try {
      await _httpClient.post(
        Endpoints.projectDatabaseTableDisableRls(_projectSlug, tableName),
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Create RLS policy
  Future<void> createPolicy({
    required String tableName,
    required String policyName,
    required String command,
    String? role,
    String? using,
    String? withCheck,
  }) async {
    try {
      await _httpClient.post(
        Endpoints.projectDatabaseTablePolicies(_projectSlug, tableName),
        data: {
          'name': policyName,
          'command': command,
          if (role != null) 'role': role,
          if (using != null) 'using': using,
          if (withCheck != null) 'with_check': withCheck,
        },
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// List RLS policies for a table
  Future<List<RlsPolicy>> listPolicies(String tableName) async {
    try {
      final response = await _httpClient.get(
        Endpoints.projectDatabaseTablePolicies(_projectSlug, tableName),
      );

      final data = response.data as List;
      return data.map((item) => RlsPolicy.fromJson(item)).toList();
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Delete RLS policy
  Future<void> deletePolicy({
    required String tableName,
    required String policyName,
  }) async {
    try {
      await _httpClient.delete(
        Endpoints.projectDatabaseTablePolicyByName(_projectSlug, tableName, policyName),
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Execute a query (used by PostgrestQueryBuilder)
  Future<PostgrestResponse<Map<String, dynamic>>> executeQuery({
    required String table,
    required String select,
    List<String>? filters,
    List<String>? orders,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'select': select,
      };

      if (filters != null && filters.isNotEmpty) {
        for (final filter in filters) {
          final parts = filter.split('=');
          if (parts.length == 2) {
            queryParams[parts[0]] = parts[1];
          }
        }
      }

      if (orders != null && orders.isNotEmpty) {
        queryParams['order'] = orders.join(',');
      }

      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }

      final response = await _httpClient.get(
        Endpoints.projectDatabaseTableData(_projectSlug, table),
        queryParameters: queryParams,
      );

      // Backend returns {success, table_name, total_rows, returned_rows, page, limit, columns, data: [...]}
      // Extract the actual data array from the response
      final dynamic responseData = response.data;
      final List<dynamic> dataArray;
      
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        // Wrapped format from backend
        dataArray = responseData['data'] as List<dynamic>;
      } else if (responseData is List) {
        // Direct array format (fallback)
        dataArray = responseData;
      } else {
        dataArray = [];
      }

      return PostgrestResponse<Map<String, dynamic>>(
        data: List<Map<String, dynamic>>.from(dataArray),
        count: responseData is Map<String, dynamic> 
            ? responseData['total_rows'] as int?
            : response.headers.map['x-total-count']?.first != null
                ? int.tryParse(response.headers.map['x-total-count']!.first)
                : null,
        status: response.statusCode,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Insert data
  Future<PostgrestResponse<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> values,
    bool upsert = false,
    String? onConflict,
    bool ignoreDuplicates = false,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectDatabaseTableRows(_projectSlug, table),
        data: values,
        queryParameters: {
          if (upsert) 'upsert': 'true',
          if (onConflict != null) 'on_conflict': onConflict,
          if (ignoreDuplicates) 'ignore_duplicates': 'true',
        },
      );

      return PostgrestResponse<Map<String, dynamic>>(
        data: [Map<String, dynamic>.from(response.data ?? {})],
        status: response.statusCode,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Update data
  Future<PostgrestResponse<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> values,
    List<String>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filters != null && filters.isNotEmpty) {
        for (final filter in filters) {
          final parts = filter.split('=');
          if (parts.length == 2) {
            queryParams[parts[0]] = parts[1];
          }
        }
      }

      final response = await _httpClient.put(
        Endpoints.projectDatabaseTableRows(_projectSlug, table),
        data: values,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PostgrestResponse<Map<String, dynamic>>(
        data: response.data is List
            ? List<Map<String, dynamic>>.from(response.data)
            : [Map<String, dynamic>.from(response.data ?? {})],
        status: response.statusCode,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Delete data
  Future<PostgrestResponse<Map<String, dynamic>>> delete({
    required String table,
    List<String>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filters != null && filters.isNotEmpty) {
        for (final filter in filters) {
          final parts = filter.split('=');
          if (parts.length == 2) {
            queryParams[parts[0]] = parts[1];
          }
        }
      }

      final response = await _httpClient.delete(
        Endpoints.projectDatabaseTableRows(_projectSlug, table),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PostgrestResponse<Map<String, dynamic>>(
        data: [],
        status: response.statusCode,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Bulk insert
  Future<int> bulkInsert({
    required String table,
    required List<Map<String, dynamic>> values,
    bool upsert = false,
    String? onConflict,
    bool ignoreDuplicates = false,
  }) async {
    try {
      final response = await _httpClient.post(
        Endpoints.projectDatabaseTableBulkInsert(_projectSlug, table),
        data: {'rows': values},
        queryParameters: {
          if (upsert) 'upsert': 'true',
          if (onConflict != null) 'on_conflict': onConflict,
          if (ignoreDuplicates) 'ignore_duplicates': 'true',
        },
      );

      return response.data['count'] ?? values.length;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Bulk update
  Future<int> bulkUpdate({
    required String table,
    required List<Map<String, dynamic>> values,
    required String matchColumn,
  }) async {
    try {
      final response = await _httpClient.put(
        Endpoints.projectDatabaseTableBulkUpdate(_projectSlug, table),
        data: {
          'rows': values,
          'match_column': matchColumn,
        },
      );

      return response.data['count'] ?? values.length;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Bulk delete
  Future<int> bulkDelete({
    required String table,
    required List<dynamic> ids,
    String idColumn = 'id',
  }) async {
    try {
      final response = await _httpClient.delete(
        Endpoints.projectDatabaseTableBulkDelete(_projectSlug, table),
        data: {
          'ids': ids,
          'id_column': idColumn,
        },
      );

      return response.data['count'] ?? ids.length;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }
}