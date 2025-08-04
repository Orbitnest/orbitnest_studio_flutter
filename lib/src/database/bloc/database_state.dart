import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/postgrest_response.dart';

part 'database_state.freezed.dart';

/// Database states for CRUD operations only
@freezed
class DatabaseState with _$DatabaseState {
  const factory DatabaseState.initial() = DatabaseInitialState;

  const factory DatabaseState.loading() = DatabaseLoadingState;

  const factory DatabaseState.sqlExecuted({
    required List<Map<String, dynamic>> result,
    int? rowsAffected,
  }) = DatabaseSqlExecutedState;

  // CRUD operation results
  const factory DatabaseState.dataSelected({
    required String table,
    required PostgrestResponse<Map<String, dynamic>> response,
  }) = DatabaseDataSelectedState;

  const factory DatabaseState.dataInserted({
    required String table,
    required PostgrestResponse<Map<String, dynamic>> response,
  }) = DatabaseDataInsertedState;

  const factory DatabaseState.dataUpdated({
    required String table,
    required PostgrestResponse<Map<String, dynamic>> response,
  }) = DatabaseDataUpdatedState;

  const factory DatabaseState.dataDeleted({
    required String table,
    required PostgrestResponse<Map<String, dynamic>> response,
  }) = DatabaseDataDeletedState;

  // Bulk operation results
  const factory DatabaseState.bulkInserted({
    required String table,
    required int count,
  }) = DatabaseBulkInsertedState;

  const factory DatabaseState.bulkUpdated({
    required String table,
    required int count,
  }) = DatabaseBulkUpdatedState;

  const factory DatabaseState.bulkDeleted({
    required String table,
    required int count,
  }) = DatabaseBulkDeletedState;

  const factory DatabaseState.error({
    required String message,
    String? code,
    String? table,
    String? query,
    String? hint,
    String? details,
  }) = DatabaseErrorState;
}

/// Extension for DatabaseState to add convenience methods
extension DatabaseStateX on DatabaseState {
  bool get isLoading => this is DatabaseLoadingState;
  bool get isError => this is DatabaseErrorState;
  bool get hasData => this is DatabaseDataSelectedState;

  String? get error => whenOrNull(
        error: (message, code, table, query, hint, details) => message,
      );

  String? get errorCode => whenOrNull(
        error: (message, code, table, query, hint, details) => code,
      );

  PostgrestResponse<Map<String, dynamic>>? get data => whenOrNull(
        dataSelected: (table, response) => response,
        dataInserted: (table, response) => response,
        dataUpdated: (table, response) => response,
        dataDeleted: (table, response) => response,
      );
}
