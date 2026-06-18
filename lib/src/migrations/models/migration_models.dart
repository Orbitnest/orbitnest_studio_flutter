// Models for the migration API. The Flutter SDK never executes migrations —
// these only describe what the server-side migration runner reports back.

/// One migration's combined on-disk + registry state.
class MigrationStatusEntry {
  final String migrationId;
  final String name;
  final String status; // 'success' | 'failed' | 'pending'
  final bool applied;
  final String? executedAt;
  final bool checksumMismatch;

  const MigrationStatusEntry({
    required this.migrationId,
    required this.name,
    required this.status,
    required this.applied,
    this.executedAt,
    this.checksumMismatch = false,
  });

  factory MigrationStatusEntry.fromJson(Map<String, dynamic> json) {
    return MigrationStatusEntry(
      migrationId: (json['migrationId'] ?? json['migration_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      applied: json['applied'] == true,
      executedAt: (json['executedAt'] ?? json['executed_at'])?.toString(),
      checksumMismatch: json['checksumMismatch'] == true || json['checksum_mismatch'] == true,
    );
  }
}

/// Details of the migration that stopped a run.
class MigrationFailure {
  final String migrationId;
  final String name;
  final String error;

  const MigrationFailure({required this.migrationId, required this.name, required this.error});

  factory MigrationFailure.fromJson(Map<String, dynamic> json) {
    return MigrationFailure(
      migrationId: (json['migrationId'] ?? json['migration_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      error: (json['error'] ?? '').toString(),
    );
  }
}

/// Result of a `run` / `runOne` migration call.
class MigrationRunResult {
  final bool success;
  final List<String> ran;
  final List<String> skipped;
  final MigrationFailure? failed;

  const MigrationRunResult({
    required this.success,
    required this.ran,
    required this.skipped,
    this.failed,
  });

  factory MigrationRunResult.fromJson(Map<String, dynamic> json) {
    final failedJson = json['failed'];
    return MigrationRunResult(
      success: json['success'] != false && failedJson == null,
      ran: (json['ran'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      skipped: (json['skipped'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      failed: failedJson is Map ? MigrationFailure.fromJson(Map<String, dynamic>.from(failedJson)) : null,
    );
  }

  /// Human-readable log lines, ready to drop into a simple log view.
  List<String> get logs {
    final lines = <String>[];
    for (final id in ran) {
      lines.add('✓ applied $id');
    }
    for (final id in skipped) {
      lines.add('• skipped $id (already applied)');
    }
    if (failed != null) {
      lines.add('✗ failed ${failed!.name}: ${failed!.error}');
    }
    lines.add(success
        ? 'Done — ${ran.length} applied, ${skipped.length} skipped.'
        : 'Stopped on failure — ${ran.length} applied before the error.');
    return lines;
  }
}
