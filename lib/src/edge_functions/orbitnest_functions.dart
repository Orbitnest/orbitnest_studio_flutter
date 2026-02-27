import 'dart:async';
import 'package:flutter/foundation.dart';
import 'bloc/functions_bloc.dart';
import 'bloc/functions_event.dart';
import 'bloc/functions_state.dart';
import 'models/function_response.dart';
import 'exceptions/function_exception.dart';

/// Simplified Edge Functions API that wraps the BLoC pattern
/// Provides direct async methods for function invocation only
class OrbitNestFunctions extends ChangeNotifier {
  final FunctionsBloc _functionsBloc;
  late final StreamSubscription _stateSubscription;

  FunctionsState _currentState = const FunctionsInitialState();
  final Map<String, Completer<dynamic>> _pendingOperations = {};
  // Tracks which operation key belongs to which function name so responses
  // are routed to the correct completer even under concurrent calls.
  final Map<String, String> _operationFunctionNames = {};
  int _operationCounter = 0;

  OrbitNestFunctions(this._functionsBloc) {
    _stateSubscription = _functionsBloc.stream.listen(_handleStateChange);
    _currentState = _functionsBloc.state;
  }

  void _handleStateChange(FunctionsState state) {
    _currentState = state;
    notifyListeners();

    // Complete pending operations based on state changes
    switch (state) {
      case FunctionsInvokedState(
          response: final response,
          functionName: final funcName
        ):
        _completePendingOperationByName(funcName, response);
        break;
      case FunctionsErrorState(
          :final message,
          :final code,
          :final functionName
        ):
        // Complete all pending operations with the error
        final error =
            FunctionException(message, code: code, functionName: functionName);
        final pendingKeys = List<String>.from(_pendingOperations.keys);
        for (final key in pendingKeys) {
          _completePendingOperationWithError(key, error);
        }
        break;
      case FunctionsInitialState():
        break;
      case FunctionsLoadingState():
        break;
    }
  }

/// Complete the first pending operation whose function name matches.
  /// Falls back to FIFO if no named match is found (defensive).
  void _completePendingOperationByName(String functionName, dynamic result) {
    if (_pendingOperations.isEmpty) return;

    // Find the oldest pending key registered for this function name.
    String? matchKey;
    for (final entry in _operationFunctionNames.entries) {
      if (entry.value == functionName &&
          _pendingOperations.containsKey(entry.key)) {
        matchKey = entry.key;
        break;
      }
    }

    // FIFO fallback – should not normally be reached.
    matchKey ??= _pendingOperations.keys.first;

    _operationFunctionNames.remove(matchKey);
    final completer = _pendingOperations.remove(matchKey);
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  void _completePendingOperationWithError(String key, Object error) {
    // Complete all pending operations with error
    final completers = Map<String, Completer<dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();
    _operationFunctionNames.clear();

    for (final completer in completers.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
  }

  String _generateOperationKey() {
    return 'op_${++_operationCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<T> _executeWithCompleter<T>(
    FunctionsEvent event, {
    String? functionName,
  }) async {
    final completer = Completer<T>();
    final operationKey = _generateOperationKey();
    _pendingOperations[operationKey] = completer;
    if (functionName != null) {
      _operationFunctionNames[operationKey] = functionName;
    }

    _functionsBloc.add(event);

    // No manual timeout - rely only on Dio client timeout
    return completer.future;
  }

  /// Get current functions state
  FunctionsState get state => _currentState;

  /// Stream of functions state changes
  Stream<FunctionsState> get onStateChange => _functionsBloc.stream;

  /// Invoke an edge function (main method for calling functions)
  Future<FunctionResponse> invoke(
    String functionName, {
    String method = 'POST',
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _executeWithCompleter<FunctionResponse>(
      FunctionsInvokeEvent(
        functionName: functionName,
        method: method,
        body: body,
        headers: headers,
        queryParameters: queryParameters,
      ),
      functionName: functionName,
    );
  }

  /// Convenience method for calling functions (alias for invoke)
  Future<FunctionResponse> call(
    String functionName, {
    dynamic params,
    Map<String, String>? headers,
  }) async {
    return invoke(
      functionName,
      method: 'POST',
      body: params,
      headers: headers,
    );
  }

  /// GET request to a function
  Future<FunctionResponse> get(
    String functionName, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return invoke(
      functionName,
      method: 'GET',
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// POST request to a function
  Future<FunctionResponse> post(
    String functionName, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return invoke(
      functionName,
      method: 'POST',
      body: body,
      headers: headers,
    );
  }

  /// PUT request to a function
  Future<FunctionResponse> put(
    String functionName, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return invoke(
      functionName,
      method: 'PUT',
      body: body,
      headers: headers,
    );
  }

  /// DELETE request to a function
  Future<FunctionResponse> delete(
    String functionName, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return invoke(
      functionName,
      method: 'DELETE',
      body: body,
      headers: headers,
    );
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }
}
