import '../models/postgrest_response.dart';

/// Database states for CRUD operations only
sealed class DatabaseState {
  const DatabaseState();
}

class DatabaseInitialState extends DatabaseState {
  const DatabaseInitialState();
}

class DatabaseLoadingState extends DatabaseState {
  const DatabaseLoadingState();
}

class DatabaseSqlExecutedState extends DatabaseState {
  const DatabaseSqlExecutedState({
    required this.result,
    this.rowsAffected,
  });

  final List<Map<String, dynamic>> result;
  final int? rowsAffected;
}

// CRUD operation results
class DatabaseDataSelectedState extends DatabaseState {
  const DatabaseDataSelectedState({
    required this.table,
    required this.response,
  });

  final String table;
  final PostgrestResponse<Map<String, dynamic>> response;
}

class DatabaseDataInsertedState extends DatabaseState {
  const DatabaseDataInsertedState({
    required this.table,
    required this.response,
  });

  final String table;
  final PostgrestResponse<Map<String, dynamic>> response;
}

class DatabaseDataUpdatedState extends DatabaseState {
  const DatabaseDataUpdatedState({
    required this.table,
    required this.response,
  });

  final String table;
  final PostgrestResponse<Map<String, dynamic>> response;
}

class DatabaseDataDeletedState extends DatabaseState {
  const DatabaseDataDeletedState({
    required this.table,
    required this.response,
  });

  final String table;
  final PostgrestResponse<Map<String, dynamic>> response;
}

// Bulk operation results
class DatabaseBulkInsertedState extends DatabaseState {
  const DatabaseBulkInsertedState({
    required this.table,
    required this.count,
  });

  final String table;
  final int count;
}

class DatabaseBulkUpdatedState extends DatabaseState {
  const DatabaseBulkUpdatedState({
    required this.table,
    required this.count,
  });

  final String table;
  final int count;
}

class DatabaseBulkDeletedState extends DatabaseState {
  const DatabaseBulkDeletedState({
    required this.table,
    required this.count,
  });

  final String table;
  final int count;
}

class DatabaseErrorState extends DatabaseState {
  const DatabaseErrorState({
    required this.message,
    this.code,
    this.table,
    this.query,
    this.hint,
    this.details,
  });

  final String message;
  final String? code;
  final String? table;
  final String? query;
  final String? hint;
  final String? details;
}

/// Extension for DatabaseState to add convenience methods
extension DatabaseStateX on DatabaseState {
  bool get isLoading => this is DatabaseLoadingState;
  bool get isError => this is DatabaseErrorState;
  bool get hasData => this is DatabaseDataSelectedState;

  String? get error => switch (this) {
    DatabaseErrorState(message: final message) => message,
    _ => null,
  };

  String? get errorCode => switch (this) {
    DatabaseErrorState(code: final code) => code,
    _ => null,
  };

  PostgrestResponse<Map<String, dynamic>>? get data => switch (this) {
    DatabaseDataSelectedState(response: final response) => response,
    DatabaseDataInsertedState(response: final response) => response,
    DatabaseDataUpdatedState(response: final response) => response,
    DatabaseDataDeletedState(response: final response) => response,
    _ => null,
  };
}
