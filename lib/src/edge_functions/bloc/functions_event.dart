/// Edge functions events for invocation only
sealed class FunctionsEvent {
  const FunctionsEvent();
}

// Function invocation (the only operation supported)
class FunctionsInvokeEvent extends FunctionsEvent {
  const FunctionsInvokeEvent({
    required this.functionName,
    this.method = 'POST',
    this.body,
    this.headers,
  });

  final String functionName;
  final String method;
  final dynamic body;
  final Map<String, String>? headers;
}
