import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/functions_repository.dart';
import '../exceptions/function_exception.dart';
import 'functions_event.dart';
import 'functions_state.dart';

/// BLoC for managing edge functions state
class FunctionsBloc extends Bloc<FunctionsEvent, FunctionsState> {
  final FunctionsRepository _functionsRepository;

  FunctionsBloc({
    required FunctionsRepository functionsRepository,
  }) : _functionsRepository = functionsRepository,
       super(const FunctionsState.initial()) {
    
    // Register event handlers
    on<FunctionsInvokeEvent>(_onInvoke);
    on<FunctionsCreateEvent>(_onCreate);
    on<FunctionsListEvent>(_onList);
    on<FunctionsGetEvent>(_onGet);
    on<FunctionsUpdateEvent>(_onUpdate);
    on<FunctionsDeleteEvent>(_onDelete);
    on<FunctionsGetLogsEvent>(_onGetLogs);
    on<FunctionsListEnvironmentVariablesEvent>(_onListEnvironmentVariables);
    on<FunctionsSetEnvironmentVariableEvent>(_onSetEnvironmentVariable);
    on<FunctionsDeleteEnvironmentVariableEvent>(_onDeleteEnvironmentVariable);
    on<FunctionsSetBulkEnvironmentVariablesEvent>(_onSetBulkEnvironmentVariables);
  }

  Future<void> _onInvoke(
    FunctionsInvokeEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final response = await _functionsRepository.invoke(
        event.functionName,
        method: event.method,
        body: event.body,
        headers: event.headers,
      );

      emit(FunctionsState.invoked(
        functionName: event.functionName,
        response: response,
      ));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        functionName: event.functionName,
      ));
    }
  }

  Future<void> _onCreate(
    FunctionsCreateEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final function = await _functionsRepository.create(
        name: event.name,
        description: event.description,
        sourceCode: event.sourceCode,
        environmentVariables: event.environmentVariables,
        executionConfig: event.executionConfig,
      );

      emit(FunctionsState.created(function: function));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        functionName: event.name,
      ));
    }
  }

  Future<void> _onList(
    FunctionsListEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final functions = await _functionsRepository.list();
      emit(FunctionsState.listed(functions: functions));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onGet(
    FunctionsGetEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final function = await _functionsRepository.get(event.name);
      emit(FunctionsState.loaded(function: function));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        functionName: event.name,
      ));
    }
  }

  Future<void> _onUpdate(
    FunctionsUpdateEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final function = await _functionsRepository.update(
        name: event.name,
        description: event.description,
        sourceCode: event.sourceCode,
        environmentVariables: event.environmentVariables,
        executionConfig: event.executionConfig,
      );

      emit(FunctionsState.updated(function: function));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        functionName: event.name,
      ));
    }
  }

  Future<void> _onDelete(
    FunctionsDeleteEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      await _functionsRepository.delete(event.name);
      emit(FunctionsState.deleted(functionName: event.name));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        functionName: event.name,
      ));
    }
  }

  Future<void> _onGetLogs(
    FunctionsGetLogsEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final logs = await _functionsRepository.getLogs(
        name: event.name,
        limit: event.limit,
        offset: event.offset,
      );

      emit(FunctionsState.logsLoaded(
        functionName: event.name,
        logs: logs,
      ));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        functionName: event.name,
      ));
    }
  }

  Future<void> _onListEnvironmentVariables(
    FunctionsListEnvironmentVariablesEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final variables = await _functionsRepository.listEnvironmentVariables();
      emit(FunctionsState.environmentVariablesListed(variables: variables));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onSetEnvironmentVariable(
    FunctionsSetEnvironmentVariableEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      await _functionsRepository.setEnvironmentVariable(
        name: event.name,
        value: event.value,
        description: event.description,
        isSecret: event.isSecret,
      );

      emit(FunctionsState.environmentVariableSet(
        name: event.name,
        value: event.value,
      ));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onDeleteEnvironmentVariable(
    FunctionsDeleteEnvironmentVariableEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      await _functionsRepository.deleteEnvironmentVariable(event.name);
      emit(FunctionsState.environmentVariableDeleted(name: event.name));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  Future<void> _onSetBulkEnvironmentVariables(
    FunctionsSetBulkEnvironmentVariablesEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsState.loading());
    
    try {
      final count = await _functionsRepository.setBulkEnvironmentVariables(event.variables);
      emit(FunctionsState.bulkEnvironmentVariablesSet(count: count));
    } catch (e) {
      emit(FunctionsState.error(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
      ));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FunctionException) {
      return error.message;
    }
    return error.toString();
  }

  String? _getErrorCode(dynamic error) {
    if (error is FunctionException) {
      return error.code;
    }
    return null;
  }
}