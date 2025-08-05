import '../models/function_response.dart';

/// Edge functions states for invocation only
sealed class FunctionsState {
  const FunctionsState();
}

class FunctionsInitialState extends FunctionsState {
  const FunctionsInitialState();
}

class FunctionsLoadingState extends FunctionsState {
  const FunctionsLoadingState();
}

class FunctionsInvokedState extends FunctionsState {
  const FunctionsInvokedState({
    required this.functionName,
    required this.response,
  });

  final String functionName;
  final FunctionResponse response;
}

class FunctionsErrorState extends FunctionsState {
  const FunctionsErrorState({
    required this.message,
    this.code,
    this.functionName,
  });

  final String message;
  final String? code;
  final String? functionName;
}

/// Extension for FunctionsState to add convenience methods
extension FunctionsStateX on FunctionsState {
  bool get isLoading => this is FunctionsLoadingState;
  bool get isError => this is FunctionsErrorState;
  bool get hasInvokedResult => this is FunctionsInvokedState;

  String? get error => switch (this) {
    FunctionsErrorState(message: final message) => message,
    _ => null,
  };

  String? get errorCode => switch (this) {
    FunctionsErrorState(code: final code) => code,
    _ => null,
  };

  FunctionResponse? get invokeResult => switch (this) {
    FunctionsInvokedState(response: final response) => response,
    _ => null,
  };
}
