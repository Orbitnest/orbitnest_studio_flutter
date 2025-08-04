import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_schema.freezed.dart';
part 'table_schema.g.dart';

/// Database table schema information
@freezed
class TableSchema with _$TableSchema {
  const factory TableSchema({
    @JsonKey(name: 'table_name') required String tableName,
    @JsonKey(name: 'schema_name') String? schemaName,
    required List<ColumnInfo> columns,
    @JsonKey(name: 'primary_keys') List<String>? primaryKeys,
    @JsonKey(name: 'foreign_keys') List<ForeignKey>? foreignKeys,
    List<Index>? indexes,
    @JsonKey(name: 'rls_enabled') bool? rlsEnabled,
    List<RlsPolicy>? policies,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _TableSchema;

  factory TableSchema.fromJson(Map<String, dynamic> json) =>
      _$TableSchemaFromJson(json);
}

/// Column information
@freezed
class ColumnInfo with _$ColumnInfo {
  const factory ColumnInfo({
    @JsonKey(name: 'column_name') required String columnName,
    @JsonKey(name: 'data_type') required String dataType,
    @JsonKey(name: 'is_nullable') required bool isNullable,
    @JsonKey(name: 'column_default') String? columnDefault,
    @JsonKey(name: 'is_primary_key') bool? isPrimaryKey,
    @JsonKey(name: 'is_foreign_key') bool? isForeignKey,
    @JsonKey(name: 'is_unique') bool? isUnique,
    @JsonKey(name: 'character_maximum_length') int? characterMaximumLength,
    @JsonKey(name: 'numeric_precision') int? numericPrecision,
    @JsonKey(name: 'numeric_scale') int? numericScale,
    @JsonKey(name: 'ordinal_position') int? ordinalPosition,
    String? comment,
  }) = _ColumnInfo;

  factory ColumnInfo.fromJson(Map<String, dynamic> json) =>
      _$ColumnInfoFromJson(json);
}

/// Foreign key constraint information
@freezed
class ForeignKey with _$ForeignKey {
  const factory ForeignKey({
    @JsonKey(name: 'constraint_name') required String constraintName,
    @JsonKey(name: 'source_column') required String sourceColumn,
    @JsonKey(name: 'target_table') required String targetTable,
    @JsonKey(name: 'target_column') required String targetColumn,
    @JsonKey(name: 'on_delete') String? onDelete,
    @JsonKey(name: 'on_update') String? onUpdate,
  }) = _ForeignKey;

  factory ForeignKey.fromJson(Map<String, dynamic> json) =>
      _$ForeignKeyFromJson(json);
}

/// Database index information
@freezed
class Index with _$Index {
  const factory Index({
    @JsonKey(name: 'index_name') required String indexName,
    @JsonKey(name: 'column_names') required List<String> columnNames,
    @JsonKey(name: 'is_unique') required bool isUnique,
    @JsonKey(name: 'is_primary') bool? isPrimary,
    String? method,
    String? condition,
  }) = _Index;

  factory Index.fromJson(Map<String, dynamic> json) =>
      _$IndexFromJson(json);
}

/// Row Level Security policy information
@freezed
class RlsPolicy with _$RlsPolicy {
  const factory RlsPolicy({
    @JsonKey(name: 'policy_name') required String policyName,
    @JsonKey(name: 'table_name') required String tableName,
    required String command,
    String? role,
    String? using,
    @JsonKey(name: 'with_check') String? withCheck,
    bool? permissive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _RlsPolicy;

  factory RlsPolicy.fromJson(Map<String, dynamic> json) =>
      _$RlsPolicyFromJson(json);
}

/// Database table information
@freezed
class TableInfo with _$TableInfo {
  const factory TableInfo({
    @JsonKey(name: 'table_name') required String tableName,
    @JsonKey(name: 'schema_name') String? schemaName,
    @JsonKey(name: 'table_type') String? tableType,
    @JsonKey(name: 'row_count') int? rowCount,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    String? comment,
  }) = _TableInfo;

  factory TableInfo.fromJson(Map<String, dynamic> json) =>
      _$TableInfoFromJson(json);
}