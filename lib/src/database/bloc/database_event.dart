import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_event.freezed.dart';

/// Database events for CRUD operations only
@freezed
class DatabaseEvent with _$DatabaseEvent {
  // SQL execution
  const factory DatabaseEvent.executeSql({
    required String sql,
    List<dynamic>? parameters,
  }) = DatabaseExecuteSqlEvent;

  // CRUD operations (for query builder)
  const factory DatabaseEvent.select({
    required String table,
    String? columns,
    Map<String, String>? filters,
    List<String>? orders,
    int? limit,
    int? offset,
  }) = DatabaseSelectEvent;

  const factory DatabaseEvent.insert({
    required String table,
    required Map<String, dynamic> values,
    @Default(false) bool upsert,
    String? onConflict,
    @Default(false) bool ignoreDuplicates,
  }) = DatabaseInsertEvent;

  const factory DatabaseEvent.update({
    required String table,
    required Map<String, dynamic> values,
    Map<String, String>? filters,
  }) = DatabaseUpdateEvent;

  const factory DatabaseEvent.delete({
    required String table,
    Map<String, String>? filters,
  }) = DatabaseDeleteEvent;

  // Bulk operations
  const factory DatabaseEvent.bulkInsert({
    required String table,
    required List<Map<String, dynamic>> values,
    @Default(false) bool upsert,
    String? onConflict,
    @Default(false) bool ignoreDuplicates,
  }) = DatabaseBulkInsertEvent;

  const factory DatabaseEvent.bulkUpdate({
    required String table,
    required List<Map<String, dynamic>> values,
    required String matchColumn,
  }) = DatabaseBulkUpdateEvent;

  const factory DatabaseEvent.bulkDelete({
    required String table,
    required List<dynamic> ids,
    @Default('id') String idColumn,
  }) = DatabaseBulkDeleteEvent;
}
