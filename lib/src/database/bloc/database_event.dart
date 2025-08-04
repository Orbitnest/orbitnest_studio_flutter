import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_event.freezed.dart';

/// Database events
@freezed
class DatabaseEvent with _$DatabaseEvent {
  // SQL execution
  const factory DatabaseEvent.executeSql({
    required String sql,
    List<dynamic>? parameters,
  }) = DatabaseExecuteSqlEvent;

  // Table operations
  const factory DatabaseEvent.createTable({
    required String tableName,
    required Map<String, String> columns,
    List<String>? primaryKeys,
    bool? enableRls,
  }) = DatabaseCreateTableEvent;

  const factory DatabaseEvent.listTables() = DatabaseListTablesEvent;

  const factory DatabaseEvent.getTableSchema({
    required String tableName,
  }) = DatabaseGetTableSchemaEvent;

  // RLS operations
  const factory DatabaseEvent.enableRls({
    required String tableName,
  }) = DatabaseEnableRlsEvent;

  const factory DatabaseEvent.disableRls({
    required String tableName,
  }) = DatabaseDisableRlsEvent;

  // Policy operations
  const factory DatabaseEvent.createPolicy({
    required String tableName,
    required String policyName,
    required String command,
    String? role,
    String? using,
    String? withCheck,
  }) = DatabaseCreatePolicyEvent;

  const factory DatabaseEvent.listPolicies({
    required String tableName,
  }) = DatabaseListPoliciesEvent;

  const factory DatabaseEvent.deletePolicy({
    required String tableName,
    required String policyName,
  }) = DatabaseDeletePolicyEvent;

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