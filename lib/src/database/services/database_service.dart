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
        Endpoints.projectDatabaseTables(_projectSlug),
        queryParameters: {'table': tableName},
      );
      final List<dynamic> items =
          response.data is List ? response.data as List : [response.data];
      if (items.isEmpty) {
        throw DatabaseException('Table not found: $tableName');
      }
      return TableSchema.fromJson(items.first as Map<String, dynamic>);
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

  /// Update data.
  /// Routes through the bulk-update endpoint (`PUT /rows/bulk`) because the
  /// single-row endpoint requires an explicit row ID that isn't available here.
  /// Filters like ['id=123', 'status=active'] are parsed into a `where` map.
  Future<PostgrestResponse<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> values,
    List<String>? filters,
  }) async {
    try {
      final whereMap = _parseFiltersToMap(filters);
      final response = await _httpClient.put(
        Endpoints.projectDatabaseTableBulkUpdate(_projectSlug, table),
        data: [
          {'where': whereMap, 'data': values}
        ],
      );
      final List<dynamic> resultList =
          response.data is List ? response.data as List : [];
      return PostgrestResponse<Map<String, dynamic>>(
        data: resultList.whereType<Map<String, dynamic>>().toList(),
        status: response.statusCode,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Delete data.
  /// Routes through the bulk-delete endpoint (`DELETE /rows/bulk`) because the
  /// single-row endpoint requires an explicit row ID that isn't available here.
  Future<PostgrestResponse<Map<String, dynamic>>> delete({
    required String table,
    List<String>? filters,
  }) async {
    try {
      final conditions = _parseFiltersToMap(filters);
      final response = await _httpClient.delete(
        Endpoints.projectDatabaseTableBulkDelete(_projectSlug, table),
        data: [conditions],
      );
      return PostgrestResponse<Map<String, dynamic>>(
        data: [],
        status: response.statusCode,
      );
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Bulk insert.
  /// Sends the rows array directly — the backend expects `Record<string,any>[]`,
  /// not the previously wrapped `{ rows: [...] }` shape.
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
        data: values,
        queryParameters: {
          if (upsert) 'upsert': 'true',
          if (onConflict != null) 'on_conflict': onConflict,
          if (ignoreDuplicates) 'ignore_duplicates': 'true',
        },
      );
      final dynamic count = response.data is Map ? response.data['count'] : null;
      return (count as int?) ?? values.length;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Bulk update.
  /// Converts `(values, matchColumn)` into the `[{where, data}]` shape the
  /// backend expects. Each row's `matchColumn` key becomes the `where` filter
  /// and the remaining keys become `data`.
  Future<int> bulkUpdate({
    required String table,
    required List<Map<String, dynamic>> values,
    required String matchColumn,
  }) async {
    try {
      final updates = values.map((row) {
        final data = Map<String, dynamic>.from(row)..remove(matchColumn);
        return {'where': {matchColumn: row[matchColumn]}, 'data': data};
      }).toList();

      final response = await _httpClient.put(
        Endpoints.projectDatabaseTableBulkUpdate(_projectSlug, table),
        data: updates,
      );
      final dynamic count = response.data is Map ? response.data['count'] : null;
      return (count as int?) ?? values.length;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Bulk delete.
  /// Converts `(ids, idColumn)` into the `[{idColumn: id}, ...]` conditions
  /// array the backend expects (previously sent `{ids, id_column}` object).
  Future<int> bulkDelete({
    required String table,
    required List<dynamic> ids,
    String idColumn = 'id',
  }) async {
    try {
      final conditions = ids.map((id) => {idColumn: id}).toList();
      final response = await _httpClient.delete(
        Endpoints.projectDatabaseTableBulkDelete(_projectSlug, table),
        data: conditions,
      );
      final dynamic count = response.data is Map ? response.data['count'] : null;
      return (count as int?) ?? ids.length;
    } catch (e) {
      throw DatabaseException.fromException(e);
    }
  }

  /// Parses PostgREST-style filter strings (`['col=val', ...]`) into a map
  /// suitable for use as a `where` condition body.
  Map<String, dynamic> _parseFiltersToMap(List<String>? filters) {
    if (filters == null || filters.isEmpty) return {};
    final result = <String, dynamic>{};
    for (final f in filters) {
      final idx = f.indexOf('=');
      if (idx > 0) {
        result[f.substring(0, idx)] = f.substring(idx + 1);
      }
    }
    return result;
  }
}