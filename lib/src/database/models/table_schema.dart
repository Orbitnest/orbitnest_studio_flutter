/// Database table schema information
class TableSchema {
  const TableSchema({
    required this.tableName,
    this.schemaName,
    required this.columns,
    this.primaryKeys,
    this.foreignKeys,
    this.indexes,
    this.rlsEnabled,
    this.policies,
    this.createdAt,
    this.updatedAt,
  });

  final String tableName;
  final String? schemaName;
  final List<ColumnInfo> columns;
  final List<String>? primaryKeys;
  final List<ForeignKey>? foreignKeys;
  final List<Index>? indexes;
  final bool? rlsEnabled;
  final List<RlsPolicy>? policies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TableSchema.fromJson(Map<String, dynamic> json) {
    return TableSchema(
      tableName: json['table_name'] as String,
      schemaName: json['schema_name'] as String?,
      columns: (json['columns'] as List<dynamic>)
          .map((e) => ColumnInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryKeys: json['primary_keys'] != null
          ? List<String>.from(json['primary_keys'] as List)
          : null,
      foreignKeys: json['foreign_keys'] != null
          ? (json['foreign_keys'] as List<dynamic>)
              .map((e) => ForeignKey.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      indexes: json['indexes'] != null
          ? (json['indexes'] as List<dynamic>)
              .map((e) => Index.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      rlsEnabled: json['rls_enabled'] as bool?,
      policies: json['policies'] != null
          ? (json['policies'] as List<dynamic>)
              .map((e) => RlsPolicy.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_name': tableName,
      if (schemaName != null) 'schema_name': schemaName,
      'columns': columns.map((e) => e.toJson()).toList(),
      if (primaryKeys != null) 'primary_keys': primaryKeys,
      if (foreignKeys != null) 'foreign_keys': foreignKeys!.map((e) => e.toJson()).toList(),
      if (indexes != null) 'indexes': indexes!.map((e) => e.toJson()).toList(),
      if (rlsEnabled != null) 'rls_enabled': rlsEnabled,
      if (policies != null) 'policies': policies!.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

/// Column information
class ColumnInfo {
  const ColumnInfo({
    required this.columnName,
    required this.dataType,
    required this.isNullable,
    this.columnDefault,
    this.isPrimaryKey,
    this.isForeignKey,
    this.isUnique,
    this.characterMaximumLength,
    this.numericPrecision,
    this.numericScale,
    this.ordinalPosition,
    this.comment,
  });

  final String columnName;
  final String dataType;
  final bool isNullable;
  final String? columnDefault;
  final bool? isPrimaryKey;
  final bool? isForeignKey;
  final bool? isUnique;
  final int? characterMaximumLength;
  final int? numericPrecision;
  final int? numericScale;
  final int? ordinalPosition;
  final String? comment;

  factory ColumnInfo.fromJson(Map<String, dynamic> json) {
    return ColumnInfo(
      columnName: json['column_name'] as String,
      dataType: json['data_type'] as String,
      isNullable: json['is_nullable'] as bool,
      columnDefault: json['column_default'] as String?,
      isPrimaryKey: json['is_primary_key'] as bool?,
      isForeignKey: json['is_foreign_key'] as bool?,
      isUnique: json['is_unique'] as bool?,
      characterMaximumLength: json['character_maximum_length'] as int?,
      numericPrecision: json['numeric_precision'] as int?,
      numericScale: json['numeric_scale'] as int?,
      ordinalPosition: json['ordinal_position'] as int?,
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'column_name': columnName,
      'data_type': dataType,
      'is_nullable': isNullable,
      if (columnDefault != null) 'column_default': columnDefault,
      if (isPrimaryKey != null) 'is_primary_key': isPrimaryKey,
      if (isForeignKey != null) 'is_foreign_key': isForeignKey,
      if (isUnique != null) 'is_unique': isUnique,
      if (characterMaximumLength != null) 'character_maximum_length': characterMaximumLength,
      if (numericPrecision != null) 'numeric_precision': numericPrecision,
      if (numericScale != null) 'numeric_scale': numericScale,
      if (ordinalPosition != null) 'ordinal_position': ordinalPosition,
      if (comment != null) 'comment': comment,
    };
  }
}

/// Foreign key constraint information
class ForeignKey {
  const ForeignKey({
    required this.constraintName,
    required this.sourceColumn,
    required this.targetTable,
    required this.targetColumn,
    this.onDelete,
    this.onUpdate,
  });

  final String constraintName;
  final String sourceColumn;
  final String targetTable;
  final String targetColumn;
  final String? onDelete;
  final String? onUpdate;

  factory ForeignKey.fromJson(Map<String, dynamic> json) {
    return ForeignKey(
      constraintName: json['constraint_name'] as String,
      sourceColumn: json['source_column'] as String,
      targetTable: json['target_table'] as String,
      targetColumn: json['target_column'] as String,
      onDelete: json['on_delete'] as String?,
      onUpdate: json['on_update'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'constraint_name': constraintName,
      'source_column': sourceColumn,
      'target_table': targetTable,
      'target_column': targetColumn,
      if (onDelete != null) 'on_delete': onDelete,
      if (onUpdate != null) 'on_update': onUpdate,
    };
  }
}

/// Database index information
class Index {
  const Index({
    required this.indexName,
    required this.columnNames,
    required this.isUnique,
    this.isPrimary,
    this.method,
    this.condition,
  });

  final String indexName;
  final List<String> columnNames;
  final bool isUnique;
  final bool? isPrimary;
  final String? method;
  final String? condition;

  factory Index.fromJson(Map<String, dynamic> json) {
    return Index(
      indexName: json['index_name'] as String,
      columnNames: List<String>.from(json['column_names'] as List),
      isUnique: json['is_unique'] as bool,
      isPrimary: json['is_primary'] as bool?,
      method: json['method'] as String?,
      condition: json['condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index_name': indexName,
      'column_names': columnNames,
      'is_unique': isUnique,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (method != null) 'method': method,
      if (condition != null) 'condition': condition,
    };
  }
}

/// Row Level Security policy information
class RlsPolicy {
  const RlsPolicy({
    required this.policyName,
    required this.tableName,
    required this.command,
    this.role,
    this.using,
    this.withCheck,
    this.permissive,
    this.createdAt,
  });

  final String policyName;
  final String tableName;
  final String command;
  final String? role;
  final String? using;
  final String? withCheck;
  final bool? permissive;
  final DateTime? createdAt;

  factory RlsPolicy.fromJson(Map<String, dynamic> json) {
    return RlsPolicy(
      policyName: json['policy_name'] as String,
      tableName: json['table_name'] as String,
      command: json['command'] as String,
      role: json['role'] as String?,
      using: json['using'] as String?,
      withCheck: json['with_check'] as String?,
      permissive: json['permissive'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'policy_name': policyName,
      'table_name': tableName,
      'command': command,
      if (role != null) 'role': role,
      if (using != null) 'using': using,
      if (withCheck != null) 'with_check': withCheck,
      if (permissive != null) 'permissive': permissive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

/// Database table information
class TableInfo {
  const TableInfo({
    required this.tableName,
    this.schemaName,
    this.tableType,
    this.rowCount,
    this.sizeBytes,
    this.createdAt,
    this.comment,
  });

  final String tableName;
  final String? schemaName;
  final String? tableType;
  final int? rowCount;
  final int? sizeBytes;
  final DateTime? createdAt;
  final String? comment;

  factory TableInfo.fromJson(Map<String, dynamic> json) {
    return TableInfo(
      tableName: json['table_name'] as String,
      schemaName: json['schema_name'] as String?,
      tableType: json['table_type'] as String?,
      rowCount: json['row_count'] as int?,
      sizeBytes: json['size_bytes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_name': tableName,
      if (schemaName != null) 'schema_name': schemaName,
      if (tableType != null) 'table_type': tableType,
      if (rowCount != null) 'row_count': rowCount,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (comment != null) 'comment': comment,
    };
  }
}