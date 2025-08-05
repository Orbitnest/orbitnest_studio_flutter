/// Database events for CRUD operations only
sealed class DatabaseEvent {
  const DatabaseEvent();
}

// SQL execution
class DatabaseExecuteSqlEvent extends DatabaseEvent {
  const DatabaseExecuteSqlEvent({
    required this.sql,
    this.parameters,
  });

  final String sql;
  final List<dynamic>? parameters;
}

// CRUD operations (for query builder)
class DatabaseSelectEvent extends DatabaseEvent {
  const DatabaseSelectEvent({
    required this.table,
    this.columns,
    this.filters,
    this.orders,
    this.limit,
    this.offset,
  });

  final String table;
  final String? columns;
  final Map<String, String>? filters;
  final List<String>? orders;
  final int? limit;
  final int? offset;
}

class DatabaseInsertEvent extends DatabaseEvent {
  const DatabaseInsertEvent({
    required this.table,
    required this.values,
    this.upsert = false,
    this.onConflict,
    this.ignoreDuplicates = false,
  });

  final String table;
  final Map<String, dynamic> values;
  final bool upsert;
  final String? onConflict;
  final bool ignoreDuplicates;
}

class DatabaseUpdateEvent extends DatabaseEvent {
  const DatabaseUpdateEvent({
    required this.table,
    required this.values,
    this.filters,
  });

  final String table;
  final Map<String, dynamic> values;
  final Map<String, String>? filters;
}

class DatabaseDeleteEvent extends DatabaseEvent {
  const DatabaseDeleteEvent({
    required this.table,
    this.filters,
  });

  final String table;
  final Map<String, String>? filters;
}

// Bulk operations
class DatabaseBulkInsertEvent extends DatabaseEvent {
  const DatabaseBulkInsertEvent({
    required this.table,
    required this.values,
    this.upsert = false,
    this.onConflict,
    this.ignoreDuplicates = false,
  });

  final String table;
  final List<Map<String, dynamic>> values;
  final bool upsert;
  final String? onConflict;
  final bool ignoreDuplicates;
}

class DatabaseBulkUpdateEvent extends DatabaseEvent {
  const DatabaseBulkUpdateEvent({
    required this.table,
    required this.values,
    required this.matchColumn,
  });

  final String table;
  final List<Map<String, dynamic>> values;
  final String matchColumn;
}

class DatabaseBulkDeleteEvent extends DatabaseEvent {
  const DatabaseBulkDeleteEvent({
    required this.table,
    required this.ids,
    this.idColumn = 'id',
  });

  final String table;
  final List<dynamic> ids;
  final String idColumn;
}
