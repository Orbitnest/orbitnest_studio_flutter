import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/database_repository.dart';
import '../exceptions/database_exception.dart';
import 'database_event.dart';
import 'database_state.dart';

/// BLoC for managing database state
class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final DatabaseRepository _databaseRepository;

  DatabaseBloc({
    required DatabaseRepository databaseRepository,
  }) : _databaseRepository = databaseRepository,
       super(const DatabaseState.initial()) {
    
    // Register event handlers
    on<DatabaseExecuteSqlEvent>(_onExecuteSql);
    on<DatabaseCreateTableEvent>(_onCreateTable);
    on<DatabaseListTablesEvent>(_onListTables);
    on<DatabaseGetTableSchemaEvent>(_onGetTableSchema);
    on<DatabaseEnableRlsEvent>(_onEnableRls);
    on<DatabaseDisableRlsEvent>(_onDisableRls);
    on<DatabaseCreatePolicyEvent>(_onCreatePolicy);
    on<DatabaseListPoliciesEvent>(_onListPolicies);
    on<DatabaseDeletePolicyEvent>(_onDeletePolicy);
    on<DatabaseSelectEvent>(_onSelect);
    on<DatabaseInsertEvent>(_onInsert);
    on<DatabaseUpdateEvent>(_onUpdate);
    on<DatabaseDeleteEvent>(_onDelete);
    on<DatabaseBulkInsertEvent>(_onBulkInsert);
    on<DatabaseBulkUpdateEvent>(_onBulkUpdate);
    on<DatabaseBulkDeleteEvent>(_onBulkDelete);
  }

  Future<void> _onExecuteSql(
    DatabaseExecuteSqlEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final result = await _databaseRepository.executeSql(
        sql: event.sql,
        parameters: event.parameters,
      );

      emit(DatabaseState.sqlExecuted(
        result: result,
        rowsAffected: result.length,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        query: event.sql,
      ));
    }
  }

  Future<void> _onCreateTable(
    DatabaseCreateTableEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      // Build CREATE TABLE SQL
      final columns = event.columns.entries
          .map((entry) => '${entry.key} ${entry.value}')
          .join(', ');
      
      var sql = 'CREATE TABLE ${event.tableName} ($columns';
      
      if (event.primaryKeys != null && event.primaryKeys!.isNotEmpty) {
        sql += ', PRIMARY KEY (${event.primaryKeys!.join(', ')})';
      }
      
      sql += ')';

      await _databaseRepository.executeSql(sql: sql);

      // Enable RLS if requested
      if (event.enableRls == true) {
        await _databaseRepository.enableRls(event.tableName);
      }

      emit(DatabaseState.tableCreated(tableName: event.tableName));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.tableName,
      ));
    }
  }

  Future<void> _onListTables(
    DatabaseListTablesEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final tables = await _databaseRepository.listTables();
      emit(DatabaseState.tablesLoaded(tables: tables));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onGetTableSchema(
    DatabaseGetTableSchemaEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final schema = await _databaseRepository.getTableSchema(event.tableName);
      emit(DatabaseState.schemaLoaded(schema: schema));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.tableName,
      ));
    }
  }

  Future<void> _onEnableRls(
    DatabaseEnableRlsEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      await _databaseRepository.enableRls(event.tableName);
      emit(DatabaseState.rlsUpdated(
        tableName: event.tableName,
        enabled: true,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.tableName,
      ));
    }
  }

  Future<void> _onDisableRls(
    DatabaseDisableRlsEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      await _databaseRepository.disableRls(event.tableName);
      emit(DatabaseState.rlsUpdated(
        tableName: event.tableName,
        enabled: false,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.tableName,
      ));
    }
  }

  Future<void> _onCreatePolicy(
    DatabaseCreatePolicyEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      await _databaseRepository.createPolicy(
        tableName: event.tableName,
        policyName: event.policyName,
        command: event.command,
        role: event.role,
        using: event.using,
        withCheck: event.withCheck,
      );

      emit(DatabaseState.policyCreated(
        tableName: event.tableName,
        policyName: event.policyName,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.tableName,
      ));
    }
  }

  Future<void> _onListPolicies(
    DatabaseListPoliciesEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final policies = await _databaseRepository.listPolicies(event.tableName);
      emit(DatabaseState.policiesLoaded(
        tableName: event.tableName,
        policies: policies,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.tableName,
      ));
    }
  }

  Future<void> _onDeletePolicy(
    DatabaseDeletePolicyEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      await _databaseRepository.deletePolicy(
        tableName: event.tableName,
        policyName: event.policyName,
      );

      emit(DatabaseState.policyDeleted(
        tableName: event.tableName,
        policyName: event.policyName,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.tableName,
      ));
    }
  }

  Future<void> _onSelect(
    DatabaseSelectEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final response = await _databaseRepository.executeQuery(
        table: event.table,
        select: event.columns ?? '*',
        filters: event.filters?.entries.map((e) => '${e.key}=eq.${e.value}').toList(),
        orders: event.orders,
        limit: event.limit,
        offset: event.offset,
      );

      emit(DatabaseState.dataSelected(
        table: event.table,
        response: response,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.table,
      ));
    }
  }

  Future<void> _onInsert(
    DatabaseInsertEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final response = await _databaseRepository.insert(
        table: event.table,
        values: event.values,
        upsert: event.upsert,
        onConflict: event.onConflict,
        ignoreDuplicates: event.ignoreDuplicates,
      );

      emit(DatabaseState.dataInserted(
        table: event.table,
        response: response,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.table,
      ));
    }
  }

  Future<void> _onUpdate(
    DatabaseUpdateEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final response = await _databaseRepository.update(
        table: event.table,
        values: event.values,
        filters: event.filters?.entries.map((e) => '${e.key}=eq.${e.value}').toList(),
      );

      emit(DatabaseState.dataUpdated(
        table: event.table,
        response: response,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.table,
      ));
    }
  }

  Future<void> _onDelete(
    DatabaseDeleteEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final response = await _databaseRepository.delete(
        table: event.table,
        filters: event.filters?.entries.map((e) => '${e.key}=eq.${e.value}').toList(),
      );

      emit(DatabaseState.dataDeleted(
        table: event.table,
        response: response,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.table,
      ));
    }
  }

  Future<void> _onBulkInsert(
    DatabaseBulkInsertEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final count = await _databaseRepository.bulkInsert(
        table: event.table,
        values: event.values,
        upsert: event.upsert,
        onConflict: event.onConflict,
        ignoreDuplicates: event.ignoreDuplicates,
      );

      emit(DatabaseState.bulkInserted(
        table: event.table,
        count: count,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.table,
      ));
    }
  }

  Future<void> _onBulkUpdate(
    DatabaseBulkUpdateEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final count = await _databaseRepository.bulkUpdate(
        table: event.table,
        values: event.values,
        matchColumn: event.matchColumn,
      );

      emit(DatabaseState.bulkUpdated(
        table: event.table,
        count: count,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.table,
      ));
    }
  }

  Future<void> _onBulkDelete(
    DatabaseBulkDeleteEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    
    try {
      final count = await _databaseRepository.bulkDelete(
        table: event.table,
        ids: event.ids,
        idColumn: event.idColumn,
      );

      emit(DatabaseState.bulkDeleted(
        table: event.table,
        count: count,
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        table: event.table,
      ));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is DatabaseException) {
      return error.message;
    }
    return error.toString();
  }

  String? _getErrorCode(dynamic error) {
    if (error is DatabaseException) {
      return error.code;
    }
    return null;
  }
}