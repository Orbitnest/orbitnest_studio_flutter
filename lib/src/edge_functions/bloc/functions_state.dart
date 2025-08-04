import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/function_response.dart';

part 'functions_state.freezed.dart';

/// Edge functions states
@freezed
class FunctionsState with _$FunctionsState {
  const factory FunctionsState.initial() = FunctionsInitialState;
  
  const factory FunctionsState.loading() = FunctionsLoadingState;
  
  const factory FunctionsState.invoked({
    required String functionName,
    required FunctionResponse response,
  }) = FunctionsInvokedState;
  
  const factory FunctionsState.created({
    required EdgeFunction function,
  }) = FunctionsCreatedState;
  
  const factory FunctionsState.listed({
    required List<EdgeFunction> functions,
  }) = FunctionsListedState;
  
  const factory FunctionsState.loaded({
    required EdgeFunction function,
  }) = FunctionsLoadedState;
  
  const factory FunctionsState.updated({
    required EdgeFunction function,
  }) = FunctionsUpdatedState;
  
  const factory FunctionsState.deleted({
    required String functionName,
  }) = FunctionsDeletedState;
  
  const factory FunctionsState.logsLoaded({
    required String functionName,
    required List<FunctionLogEntry> logs,
  }) = FunctionsLogsLoadedState;
  
  const factory FunctionsState.environmentVariablesListed({
    required List<EnvironmentVariable> variables,
  }) = FunctionsEnvironmentVariablesListedState;
  
  const factory FunctionsState.environmentVariableSet({
    required String name,
    required String value,
  }) = FunctionsEnvironmentVariableSetState;
  
  const factory FunctionsState.environmentVariableDeleted({
    required String name,
  }) = FunctionsEnvironmentVariableDeletedState;
  
  const factory FunctionsState.bulkEnvironmentVariablesSet({
    required int count,
  }) = FunctionsBulkEnvironmentVariablesSetState;
  
  const factory FunctionsState.error({
    required String message,
    String? code,
    String? functionName,
  }) = FunctionsErrorState;
}

/// Extension for FunctionsState to add convenience methods
extension FunctionsStateX on FunctionsState {
  bool get isLoading => this is FunctionsLoadingState;
  bool get isError => this is FunctionsErrorState;
  bool get hasInvokedResult => this is FunctionsInvokedState;
  
  String? get error => whenOrNull(
    error: (message, code, functionName) => message,
  );
  
  String? get errorCode => whenOrNull(
    error: (message, code, functionName) => code,
  );
  
  FunctionResponse? get invokeResult => whenOrNull(
    invoked: (functionName, response) => response,
  );
}