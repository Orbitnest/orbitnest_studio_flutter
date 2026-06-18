import 'package:flutter/foundation.dart';

import 'models/migration_models.dart';
import 'services/migration_service.dart';

/// A small [ChangeNotifier] that backs a migration UI: it triggers runs, fetches
/// status, and accumulates human-readable log lines a widget can render.
///
/// ```dart
/// final controller = MigrationLogController(client.migrations);
///
/// // In a widget:
/// AnimatedBuilder(
///   animation: controller,
///   builder: (_, __) => Column(children: [
///     for (final line in controller.logs) Text(line),
///     ElevatedButton(
///       onPressed: controller.isRunning ? null : controller.runMigrations,
///       child: const Text('Run migrations'),
///     ),
///   ]),
/// );
/// ```
class MigrationLogController extends ChangeNotifier {
  final MigrationService _service;

  MigrationLogController(this._service);

  final List<String> _logs = [];
  List<MigrationStatusEntry> _migrations = const [];
  bool _isRunning = false;
  String? _error;

  /// Accumulated log lines, oldest first.
  List<String> get logs => List.unmodifiable(_logs);

  /// Latest fetched per-migration status.
  List<MigrationStatusEntry> get migrations => List.unmodifiable(_migrations);

  /// True while a run is in flight (use to disable the run button).
  bool get isRunning => _isRunning;

  /// Last error message, if any.
  String? get error => _error;

  void _append(String line) {
    _logs.add(line);
    notifyListeners();
  }

  /// Clear logs and the error state.
  void clear() {
    _logs.clear();
    _error = null;
    notifyListeners();
  }

  /// Fetch and cache the current migration status.
  Future<void> refreshStatus() async {
    try {
      _migrations = await _service.status();
      final applied = _migrations.where((m) => m.applied).length;
      _append('Status: $applied/${_migrations.length} applied');
    } catch (e) {
      _error = e.toString();
      _append('✗ $_error');
    }
  }

  /// Trigger a migration run on the server and stream its log lines. Pass
  /// [migrationId] to run a single migration. No-op while already running.
  Future<MigrationRunResult?> runMigrations({String? migrationId}) async {
    if (_isRunning) return null;
    _isRunning = true;
    _error = null;
    notifyListeners();

    _append(migrationId != null
        ? 'Running migration $migrationId…'
        : 'Running all pending migrations…');

    try {
      final result = await _service.run(migrationId: migrationId);
      for (final line in result.logs) {
        _append(line);
      }
      await refreshStatus();
      return result;
    } catch (e) {
      _error = e.toString();
      _append('✗ $_error');
      return null;
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }
}
