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

  FunctionsState _currentState = const FunctionsState.initial();
  final Map<String, Completer<dynamic>> _pendingOperations = {};
  int _operationCounter = 0;

  OrbitNestFunctions(this._functionsBloc) {
    _stateSubscription = _functionsBloc.stream.listen(_handleStateChange);
    _currentState = _functionsBloc.state;
  }

  void _handleStateChange(FunctionsState state) {
    _currentState = state;
    notifyListeners();

    // Complete pending operations based on state changes
    state.when(
      invoked: (functionName, response) {
        _completePendingOperation('invoked', response);
      },
      error: (message, code, functionName) {
        _completePendingOperationWithError('functions_error',
            FunctionException(message, code: code, functionName: functionName));
      },
      initial: () {},
      loading: () {},
    );
  }

  void _completePendingOperation(String key, dynamic result) {
    // Complete the most recent pending operation of this type
    final completers = Map<String, Completer<dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final completer in completers.values) {
      if (!completer.isCompleted) {
        completer.complete(result);
        break; // Only complete the first one
      }
    }
  }

  void _completePendingOperationWithError(String key, Object error) {
    // Complete all pending operations with error
    final completers = Map<String, Completer<dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final completer in completers.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
  }

  String _generateOperationKey() {
    return 'op_${++_operationCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<T> _executeWithCompleter<T>(FunctionsEvent event) async {
    final completer = Completer<T>();
    final operationKey = _generateOperationKey();
    _pendingOperations[operationKey] = completer;

    _functionsBloc.add(event);

    // Add timeout
    Timer(const Duration(seconds: 60), () {
      // Longer timeout for functions
      if (!completer.isCompleted) {
        _pendingOperations.remove(operationKey);
        completer.completeError(TimeoutException(
          'Function invocation timed out',
          const Duration(seconds: 60),
        ));
      }
    });

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
  }) async {
    return await _executeWithCompleter<FunctionResponse>(
      FunctionsEvent.invoke(
        functionName: functionName,
        method: method,
        body: body,
        headers: headers,
      ),
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
  }) async {
    return invoke(
      functionName,
      method: 'GET',
      headers: headers,
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
