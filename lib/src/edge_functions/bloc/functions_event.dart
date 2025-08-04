import 'package:freezed_annotation/freezed_annotation.dart';

part 'functions_event.freezed.dart';

/// Edge functions events
@freezed
class FunctionsEvent with _$FunctionsEvent {
  // Function invocation
  const factory FunctionsEvent.invoke({
    required String functionName,
    @Default('POST') String method,
    dynamic body,
    Map<String, String>? headers,
  }) = FunctionsInvokeEvent;

  // Function management (admin operations)
  const factory FunctionsEvent.create({
    required String name,
    String? description,
    required String sourceCode,
    Map<String, String>? environmentVariables,
    Map<String, dynamic>? executionConfig,
  }) = FunctionsCreateEvent;

  const factory FunctionsEvent.list() = FunctionsListEvent;

  const factory FunctionsEvent.get({
    required String name,
  }) = FunctionsGetEvent;

  const factory FunctionsEvent.update({
    required String name,
    String? description,
    String? sourceCode,
    Map<String, String>? environmentVariables,
    Map<String, dynamic>? executionConfig,
  }) = FunctionsUpdateEvent;

  const factory FunctionsEvent.delete({
    required String name,
  }) = FunctionsDeleteEvent;

  // Function logs
  const factory FunctionsEvent.getLogs({
    required String name,
    int? limit,
    int? offset,
  }) = FunctionsGetLogsEvent;

  // Environment variables
  const factory FunctionsEvent.listEnvironmentVariables() = FunctionsListEnvironmentVariablesEvent;

  const factory FunctionsEvent.setEnvironmentVariable({
    required String name,
    required String value,
    String? description,
    @Default(false) bool isSecret,
  }) = FunctionsSetEnvironmentVariableEvent;

  const factory FunctionsEvent.deleteEnvironmentVariable({
    required String name,
  }) = FunctionsDeleteEnvironmentVariableEvent;

  const factory FunctionsEvent.setBulkEnvironmentVariables({
    required Map<String, String> variables,
  }) = FunctionsSetBulkEnvironmentVariablesEvent;
}