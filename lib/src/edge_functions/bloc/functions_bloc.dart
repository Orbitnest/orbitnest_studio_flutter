import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/functions_repository.dart';
import '../exceptions/function_exception.dart';
import 'functions_event.dart';
import 'functions_state.dart';

/// BLoC for managing edge functions state
/// Handles only function invocation operations.
class FunctionsBloc extends Bloc<FunctionsEvent, FunctionsState> {
  final FunctionsRepository _functionsRepository;

  FunctionsBloc({
    required FunctionsRepository functionsRepository,
  })  : _functionsRepository = functionsRepository,
        super(const FunctionsInitialState()) {
    // Register event handlers
    on<FunctionsInvokeEvent>(_onInvoke);
  }

  Future<void> _onInvoke(
    FunctionsInvokeEvent event,
    Emitter<FunctionsState> emit,
  ) async {
    emit(const FunctionsLoadingState());

    try {
      final response = await _functionsRepository.invoke(
        event.functionName,
        method: event.method,
        body: event.body,
        headers: event.headers,
        queryParameters: event.queryParameters,
      );

      emit(FunctionsInvokedState(
        functionName: event.functionName,
        response: response,
      ));
    } catch (e) {
      emit(FunctionsErrorState(
        message: _getErrorMessage(e),
        code: _getErrorCode(e),
        functionName: event.functionName,
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
