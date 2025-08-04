import 'dart:async';
import 'package:flutter/foundation.dart';
import 'bloc/database_bloc.dart';
import 'bloc/database_event.dart';
import 'bloc/database_state.dart';
import 'models/postgrest_response.dart';
import 'services/query_builder.dart';
import 'exceptions/database_exception.dart';

/// Simplified Database API that wraps the BLoC pattern
/// Provides direct async methods and Supabase-compatible query builder
class OrbitNestDatabase extends ChangeNotifier {
  final DatabaseBloc _databaseBloc;
  final String _projectId;
  late final StreamSubscription _stateSubscription;

  DatabaseState _currentState = const DatabaseState.initial();
  final Map<String, Completer<dynamic>> _pendingOperations = {};
  int _operationCounter = 0;

  OrbitNestDatabase(this._databaseBloc, this._projectId) {
    _stateSubscription = _databaseBloc.stream.listen(_handleStateChange);
    _currentState = _databaseBloc.state;
  }

  void _handleStateChange(DatabaseState state) {
    _currentState = state;
    notifyListeners();

    // Complete pending operations based on state changes
    state.when(
      initial: () {},
      loading: () {},
      sqlExecuted: (result, rowsAffected) {
        _completePendingOperation(
            'db_success', PostgrestResponse(data: result, count: rowsAffected));
      },
      tableCreated: (tableName) {
        _completePendingOperation(
            'db_success',
            PostgrestResponse(data: [
              {'table_name': tableName}
            ]));
      },
      tablesLoaded: (tables) {
        _completePendingOperation('db_success',
            PostgrestResponse(data: tables.map((t) => t.toJson()).toList()));
      },
      schemaLoaded: (schema) {
        _completePendingOperation(
            'db_success', PostgrestResponse(data: [schema.toJson()]));
      },
      rlsUpdated: (tableName, enabled) {
        _completePendingOperation(
            'db_success',
            PostgrestResponse(data: [
              {'table_name': tableName, 'rls_enabled': enabled}
            ]));
      },
      policyCreated: (tableName, policyName) {
        _completePendingOperation(
            'db_success',
            PostgrestResponse(data: [
              {'table_name': tableName, 'policy_name': policyName}
            ]));
      },
      policiesLoaded: (tableName, policies) {
        _completePendingOperation('db_success',
            PostgrestResponse(data: policies.map((p) => p.toJson()).toList()));
      },
      policyDeleted: (tableName, policyName) {
        _completePendingOperation(
            'db_success',
            PostgrestResponse(data: [
              {'table_name': tableName, 'policy_name': policyName}
            ]));
      },
      dataSelected: (table, response) {
        _completePendingOperation('db_success', response);
      },
      dataInserted: (table, response) {
        _completePendingOperation('db_success', response);
      },
      dataUpdated: (table, response) {
        _completePendingOperation('db_success', response);
      },
      dataDeleted: (table, response) {
        _completePendingOperation('db_success', response);
      },
      bulkInserted: (table, count) {
        _completePendingOperation(
            'db_success',
            PostgrestResponse(data: [
              {'table': table, 'count': count}
            ]));
      },
      bulkUpdated: (table, count) {
        _completePendingOperation(
            'db_success',
            PostgrestResponse(data: [
              {'table': table, 'count': count}
            ]));
      },
      bulkDeleted: (table, count) {
        _completePendingOperation(
            'db_success',
            PostgrestResponse(data: [
              {'table': table, 'count': count}
            ]));
      },
      error: (message, code, table, query, hint, details) {
        _completePendingOperationWithError(
            'db_error', DatabaseException(message, code: code, table: table));
      },
    );
  }

  void _completePendingOperation(String key, dynamic result) {
    // Complete all pending operations since database operations don't have specific keys
    final completers = Map<String, Completer<dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final completer in completers.values) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }
  }

  void _completePendingOperationWithError(String key, Object error) {
    // Complete all pending operations with error
    final completers = Map<String, Completer<dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final completer in completers.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
  }

  String _generateOperationKey() {
    return 'op_${++_operationCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<T> _executeWithCompleter<T>(DatabaseEvent event) async {
    final completer = Completer<T>();
    final operationKey = _generateOperationKey();
    _pendingOperations[operationKey] = completer;

    _databaseBloc.add(event);

    // Add timeout
    Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        _pendingOperations.remove(operationKey);
        completer.completeError(const DatabaseException('Operation timeout'));
      }
    });

    return completer.future;
  }

  /// Get current database state
  DatabaseState get state => _currentState;

  /// Stream of database state changes
  Stream<DatabaseState> get onStateChange => _databaseBloc.stream;

  /// Create a query builder for a table (Supabase-compatible)
  PostgrestQueryBuilder<Map<String, dynamic>> from(String table) {
    return PostgrestQueryBuilder<Map<String, dynamic>>.withBloc(
      databaseBloc: _databaseBloc,
      table: table,
      projectId: _projectId,
    );
  }

  /// Select data from a table
  Future<PostgrestResponse<List<Map<String, dynamic>>>> select(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    final filtersMap =
        filters?.map((key, value) => MapEntry(key, value.toString()));

    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.select(
        table: table,
        columns: columns,
        filters: filtersMap,
        orders: orderBy,
        limit: limit,
        offset: offset,
      ),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Insert data into a table
  Future<PostgrestResponse<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> values, {
    bool upsert = false,
  }) async {
    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.insert(
        table: table,
        values: values,
        upsert: upsert,
      ),
    );

    return PostgrestResponse<Map<String, dynamic>>(
      data: [
        result.data.isNotEmpty
            ? Map<String, dynamic>.from(result.data.first as Map)
            : <String, dynamic>{}
      ],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Update data in a table
  Future<PostgrestResponse<List<Map<String, dynamic>>>> update(
    String table,
    Map<String, dynamic> values, {
    required Map<String, dynamic> filters,
  }) async {
    final filtersMap =
        filters.map((key, value) => MapEntry(key, value.toString()));

    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.update(
        table: table,
        values: values,
        filters: filtersMap,
      ),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Delete data from a table
  Future<PostgrestResponse<List<Map<String, dynamic>>>> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    final filtersMap =
        filters.map((key, value) => MapEntry(key, value.toString()));

    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.delete(
        table: table,
        filters: filtersMap,
      ),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Insert multiple records (bulk insert)
  Future<PostgrestResponse<List<Map<String, dynamic>>>> insertMany(
    String table,
    List<Map<String, dynamic>> values,
  ) async {
    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.bulkInsert(
        table: table,
        values: values,
      ),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Update multiple records (bulk update)
  Future<PostgrestResponse<List<Map<String, dynamic>>>> updateMany(
    String table,
    Map<String, dynamic> values, {
    required Map<String, dynamic> filters,
  }) async {
    final filtersMap =
        filters.map((key, value) => MapEntry(key, value.toString()));

    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.bulkUpdate(
        table: table,
        values: [values],
        matchColumn: filtersMap.keys.first,
      ),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Delete multiple records (bulk delete)
  Future<PostgrestResponse<List<Map<String, dynamic>>>> deleteMany(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    final ids = filters.values.toList();

    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.bulkDelete(
        table: table,
        ids: ids,
      ),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Execute raw SQL query
  Future<PostgrestResponse<List<Map<String, dynamic>>>> sql(
    String query, {
    List<dynamic>? parameters,
  }) async {
    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.executeSql(
        sql: query,
        parameters: parameters,
      ),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// Enable Row Level Security on a table
  Future<void> enableRLS(String table) async {
    await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.enableRls(tableName: table),
    );
  }

  /// Disable Row Level Security on a table
  Future<void> disableRLS(String table) async {
    await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.disableRls(tableName: table),
    );
  }

  /// Create an RLS policy
  Future<void> createPolicy({
    required String table,
    required String policyName,
    required String operation,
    required String definition,
  }) async {
    await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.createPolicy(
        tableName: table,
        policyName: policyName,
        command: operation,
        using: definition,
      ),
    );
  }

  /// Delete an RLS policy
  Future<void> deletePolicy({
    required String table,
    required String policyName,
  }) async {
    await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.deletePolicy(
        tableName: table,
        policyName: policyName,
      ),
    );
  }

  /// Get table schema information
  Future<PostgrestResponse<Map<String, dynamic>>> getTableSchema(
      String table) async {
    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      DatabaseEvent.getTableSchema(tableName: table),
    );

    return PostgrestResponse<Map<String, dynamic>>(
      data: [Map<String, dynamic>.from(result.data as Map)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  /// List all tables
  Future<PostgrestResponse<List<Map<String, dynamic>>>> listTables() async {
    final result = await _executeWithCompleter<PostgrestResponse<dynamic>>(
      const DatabaseEvent.listTables(),
    );

    return PostgrestResponse<List<Map<String, dynamic>>>(
      data: [List<Map<String, dynamic>>.from(result.data)],
      count: result.count,
      error: result.error,
      status: result.status,
    );
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }
}
