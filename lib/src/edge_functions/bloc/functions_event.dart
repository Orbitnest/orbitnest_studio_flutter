import 'package:freezed_annotation/freezed_annotation.dart';

part 'functions_event.freezed.dart';

/// Edge functions events for invocation only
@freezed
class FunctionsEvent with _$FunctionsEvent {
  // Function invocation (the only operation supported)
  const factory FunctionsEvent.invoke({
    required String functionName,
    @Default('POST') String method,
    dynamic body,
    Map<String, String>? headers,
  }) = FunctionsInvokeEvent;
}
