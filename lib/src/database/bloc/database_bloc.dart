import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/database_repository.dart';
import '../exceptions/database_exception.dart';
import 'database_event.dart';
import 'database_state.dart';

/// BLoC for managing database operations
class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final DatabaseRepository _databaseRepository;

  DatabaseBloc({
    required DatabaseRepository databaseRepository,
  })  : _databaseRepository = databaseRepository,
        super(const DatabaseState.initial()) {
    // Register event handlers for CRUD operations only
    on<DatabaseExecuteSqlEvent>(_onExecuteSql);
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
      ));
    } catch (e) {
      emit(DatabaseState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onSelect(
    DatabaseSelectEvent event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());

    try {
      final result = await _databaseRepository.executeQuery(
        table: event.table,
        select: event.columns ?? '*',
        filters:
            event.filters?.entries.map((e) => '${e.key}=${e.value}').toList(),
        orders: event.orders,
        limit: event.limit,
        offset: event.offset,
      );

      emit(DatabaseState.dataSelected(
        table: event.table,
        response: result,
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
      final result = await _databaseRepository.insert(
        table: event.table,
        values: event.values,
        upsert: event.upsert,
        onConflict: event.onConflict,
        ignoreDuplicates: event.ignoreDuplicates,
      );

      emit(DatabaseState.dataInserted(
        table: event.table,
        response: result,
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
      final result = await _databaseRepository.update(
        table: event.table,
        values: event.values,
        filters:
            event.filters?.entries.map((e) => '${e.key}=${e.value}').toList(),
      );

      emit(DatabaseState.dataUpdated(
        table: event.table,
        response: result,
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
      final result = await _databaseRepository.delete(
        table: event.table,
        filters:
            event.filters?.entries.map((e) => '${e.key}=${e.value}').toList(),
      );

      emit(DatabaseState.dataDeleted(
        table: event.table,
        response: result,
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
