/// Model for a background job.
class BackgroundJob {
  final String id;
  final String name;
  final String? description;
  final String? sourceCode;
  final String status; // 'active' | 'inactive'
  final String schedule; // cron expression
  final String timezone;
  final Map<String, dynamic>? executionConfig;
  final int maxConcurrentRuns;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BackgroundJob({
    required this.id,
    required this.name,
    this.description,
    this.sourceCode,
    required this.status,
    required this.schedule,
    required this.timezone,
    this.executionConfig,
    this.maxConcurrentRuns = 1,
    this.lastRunAt,
    this.nextRunAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BackgroundJob.fromJson(Map<String, dynamic> json) {
    return BackgroundJob(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sourceCode: json['sourceCode'] as String?,
      status: json['status'] as String? ?? 'active',
      schedule: json['schedule'] as String,
      timezone: json['timezone'] as String? ?? 'UTC',
      executionConfig: json['executionConfig'] as Map<String, dynamic>?,
      maxConcurrentRuns: json['maxConcurrentRuns'] as int? ?? 1,
      lastRunAt: json['lastRunAt'] != null
          ? DateTime.parse(json['lastRunAt'] as String)
          : null,
      nextRunAt: json['nextRunAt'] != null
          ? DateTime.parse(json['nextRunAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (sourceCode != null) 'sourceCode': sourceCode,
        'status': status,
        'schedule': schedule,
        'timezone': timezone,
        if (executionConfig != null) 'executionConfig': executionConfig,
        'maxConcurrentRuns': maxConcurrentRuns,
        if (lastRunAt != null) 'lastRunAt': lastRunAt!.toIso8601String(),
        if (nextRunAt != null) 'nextRunAt': nextRunAt!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  bool get isActive => status == 'active';
}

/// Model for a single execution run of a background job.
class BackgroundJobRun {
  final String id;
  final String jobId;
  final String executionId;
  final String triggerType; // 'scheduled' | 'manual'
  final String status; // 'running' | 'success' | 'error' | 'timeout' | 'skipped'
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMs;
  final String? errorMessage;
  final dynamic result;
  final DateTime createdAt;

  const BackgroundJobRun({
    required this.id,
    required this.jobId,
    required this.executionId,
    required this.triggerType,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.durationMs,
    this.errorMessage,
    this.result,
    required this.createdAt,
  });

  factory BackgroundJobRun.fromJson(Map<String, dynamic> json) {
    return BackgroundJobRun(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      executionId: json['executionId'] as String,
      triggerType: json['triggerType'] as String? ?? 'scheduled',
      status: json['status'] as String? ?? 'running',
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      durationMs: json['durationMs'] as int?,
      errorMessage: json['errorMessage'] as String?,
      result: json['result'],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error' || status == 'timeout';
  bool get isRunning => status == 'running';
}
