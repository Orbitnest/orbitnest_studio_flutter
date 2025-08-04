import '../models/postgrest_response.dart';
import 'database_service.dart';
import '../bloc/database_bloc.dart';

/// Supabase-compatible PostgreSQL query builder
class PostgrestQueryBuilder<T> {
  final DatabaseService? _databaseService;
  // ignore: unused_field
  final DatabaseBloc? _databaseBloc;
  final String _table;
  // ignore: unused_field
  final String? _projectId;
  String? _select;
  final List<String> _filters = [];
  final List<String> _orders = [];
  int? _limit;
  int? _offset;

  // Legacy constructor for direct service use
  PostgrestQueryBuilder(this._databaseService, this._table)
      : _databaseBloc = null,
        _projectId = null;

  // New constructor for BLoC-based use
  PostgrestQueryBuilder.withBloc({
    required DatabaseBloc databaseBloc,
    required String table,
    required String projectId,
  })  : _databaseBloc = databaseBloc,
        _table = table,
        _projectId = projectId,
        _databaseService = null;

  /// Select columns
  PostgrestQueryBuilder<T> select([String? columns]) {
    _select = columns ?? '*';
    return this;
  }

  /// Equal filter
  PostgrestQueryBuilder<T> eq(String column, dynamic value) {
    _filters.add('$column=eq.$value');
    return this;
  }

  /// Not equal filter
  PostgrestQueryBuilder<T> neq(String column, dynamic value) {
    _filters.add('$column=neq.$value');
    return this;
  }

  /// Greater than filter
  PostgrestQueryBuilder<T> gt(String column, dynamic value) {
    _filters.add('$column=gt.$value');
    return this;
  }

  /// Greater than or equal filter
  PostgrestQueryBuilder<T> gte(String column, dynamic value) {
    _filters.add('$column=gte.$value');
    return this;
  }

  /// Less than filter
  PostgrestQueryBuilder<T> lt(String column, dynamic value) {
    _filters.add('$column=lt.$value');
    return this;
  }

  /// Less than or equal filter
  PostgrestQueryBuilder<T> lte(String column, dynamic value) {
    _filters.add('$column=lte.$value');
    return this;
  }

  /// Like filter (case sensitive)
  PostgrestQueryBuilder<T> like(String column, String pattern) {
    _filters.add('$column=like.$pattern');
    return this;
  }

  /// iLike filter (case insensitive)
  PostgrestQueryBuilder<T> ilike(String column, String pattern) {
    _filters.add('$column=ilike.$pattern');
    return this;
  }

  /// Is filter (for null, true, false)
  PostgrestQueryBuilder<T> isFilter(String column, dynamic value) {
    _filters.add('$column=is.$value');
    return this;
  }

  /// In filter
  PostgrestQueryBuilder<T> inFilter(String column, List<dynamic> values) {
    _filters.add('$column=in.(${values.join(',')})');
    return this;
  }

  /// Contains filter (for arrays and jsonb)
  PostgrestQueryBuilder<T> contains(String column, dynamic value) {
    _filters.add('$column=cs.$value');
    return this;
  }

  /// Contained by filter (for arrays and jsonb)
  PostgrestQueryBuilder<T> containedBy(String column, dynamic value) {
    _filters.add('$column=cd.$value');
    return this;
  }

  /// Range less than filter
  PostgrestQueryBuilder<T> rangeLt(String column, String range) {
    _filters.add('$column=sl.$range');
    return this;
  }

  /// Range greater than filter
  PostgrestQueryBuilder<T> rangeGt(String column, String range) {
    _filters.add('$column=sr.$range');
    return this;
  }

  /// Range greater than or equal filter
  PostgrestQueryBuilder<T> rangeGte(String column, String range) {
    _filters.add('$column=nxl.$range');
    return this;
  }

  /// Range less than or equal filter
  PostgrestQueryBuilder<T> rangeLte(String column, String range) {
    _filters.add('$column=nxr.$range');
    return this;
  }

  /// Range adjacent filter
  PostgrestQueryBuilder<T> rangeAdjacent(String column, String range) {
    _filters.add('$column=adj.$range');
    return this;
  }

  /// Overlaps filter (for arrays and ranges)
  PostgrestQueryBuilder<T> overlaps(String column, dynamic value) {
    _filters.add('$column=ov.$value');
    return this;
  }

  /// Full text search filter
  PostgrestQueryBuilder<T> textSearch(
    String column,
    String query, {
    String? config,
    String? type,
  }) {
    var filter = '$column=';
    if (type != null) {
      filter += '${type}fts';
    } else {
      filter += 'fts';
    }
    if (config != null) {
      filter += '($config).';
    } else {
      filter += '.';
    }
    filter += query;
    _filters.add(filter);
    return this;
  }

  /// Match multiple columns (AND)
  PostgrestQueryBuilder<T> match(Map<String, dynamic> query) {
    for (final entry in query.entries) {
      _filters.add('${entry.key}=eq.${entry.value}');
    }
    return this;
  }

  /// Not filter
  PostgrestQueryBuilder<T> not(String column, String operator, dynamic value) {
    _filters.add('$column=not.$operator.$value');
    return this;
  }

  /// Or filter
  PostgrestQueryBuilder<T> or(String filters) {
    _filters.add('or=($filters)');
    return this;
  }

  /// And filter
  PostgrestQueryBuilder<T> and(String filters) {
    _filters.add('and=($filters)');
    return this;
  }

  /// Order by
  PostgrestQueryBuilder<T> order(
    String column, {
    bool ascending = true,
    bool nullsFirst = false,
  }) {
    var orderStr = column;
    if (!ascending) orderStr += '.desc';
    if (nullsFirst) {
      orderStr += '.nullsfirst';
    } else {
      orderStr += '.nullslast';
    }
    _orders.add(orderStr);
    return this;
  }

  /// Limit the number of rows
  PostgrestQueryBuilder<T> limit(int count, {int? foreignTable}) {
    _limit = count;
    return this;
  }

  /// Range of rows (pagination)
  PostgrestQueryBuilder<T> range(int from, int to, {int? foreignTable}) {
    _offset = from;
    _limit = to - from + 1;
    return this;
  }

  /// Single row (limit 1)
  PostgrestQueryBuilder<T> single() {
    _limit = 1;
    return this;
  }

  /// Maybe single row (limit 1, but doesn't throw if no results)
  PostgrestQueryBuilder<T> maybeSingle() {
    _limit = 1;
    return this;
  }

  /// Execute the query
  Future<PostgrestResponse<Map<String, dynamic>>> execute() async {
    if (_databaseService != null) {
      return await _databaseService!.executeQuery(
        table: _table,
        select: _select ?? '*',
        filters: _filters.isNotEmpty ? _filters : null,
        orders: _orders.isNotEmpty ? _orders : null,
        limit: _limit,
        offset: _offset,
      );
    } else {
      throw UnsupportedError(
          'Query execution via BLoC not yet implemented. Use OrbitNestDatabase methods instead.');
    }
  }

  /// Insert data
  Future<PostgrestResponse<Map<String, dynamic>>> insert(
    dynamic values, {
    bool upsert = false,
    String? onConflict,
    bool ignoreDuplicates = false,
  }) async {
    Map<String, dynamic> data;
    if (values is Map<String, dynamic>) {
      data = values;
    } else if (values is List) {
      // For bulk insert, take the first item for single insert
      if (values.isNotEmpty && values.first is Map<String, dynamic>) {
        data = values.first;
      } else {
        throw ArgumentError('Invalid insert data format');
      }
    } else {
      throw ArgumentError('Insert values must be Map<String, dynamic> or List');
    }

    if (_databaseService != null) {
      return await _databaseService!.insert(
        table: _table,
        values: data,
        upsert: upsert,
        onConflict: onConflict,
        ignoreDuplicates: ignoreDuplicates,
      );
    } else {
      throw UnsupportedError(
          'Insert via BLoC not yet implemented. Use OrbitNestDatabase methods instead.');
    }
  }

  /// Update data
  Future<PostgrestResponse<Map<String, dynamic>>> update(
    Map<String, dynamic> values,
  ) async {
    if (_databaseService != null) {
      return await _databaseService!.update(
        table: _table,
        values: values,
        filters: _filters.isNotEmpty ? _filters : null,
      );
    } else {
      throw UnsupportedError(
          'Update via BLoC not yet implemented. Use OrbitNestDatabase methods instead.');
    }
  }

  /// Upsert data (insert or update)
  Future<PostgrestResponse<Map<String, dynamic>>> upsert(
    dynamic values, {
    String? onConflict,
    bool ignoreDuplicates = false,
  }) async {
    return await insert(
      values,
      upsert: true,
      onConflict: onConflict,
      ignoreDuplicates: ignoreDuplicates,
    );
  }

  /// Delete data
  Future<PostgrestResponse<Map<String, dynamic>>> delete() async {
    if (_databaseService != null) {
      return await _databaseService!.delete(
        table: _table,
        filters: _filters.isNotEmpty ? _filters : null,
      );
    } else {
      throw UnsupportedError(
          'Delete via BLoC not yet implemented. Use OrbitNestDatabase methods instead.');
    }
  }
}

/// Extension to add convenient methods
extension PostgrestQueryBuilderX<T> on PostgrestQueryBuilder<T> {
  /// Alias for isFilter with null
  PostgrestQueryBuilder<T> isNull(String column) {
    return isFilter(column, 'null');
  }

  /// Alias for not null
  PostgrestQueryBuilder<T> isNotNull(String column) {
    return not(column, 'is', 'null');
  }
}
