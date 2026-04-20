import 'realtime_channel.dart';

export 'realtime_events.dart';
export 'realtime_channel.dart'
    show RealtimeChannel, RealtimeFilter, ChannelStatus;

/// Supabase-style realtime facade exposed on [OrbitNestClient].
///
/// ```dart
/// final ch = client.realtime.channel('orders')
///   ..onPostgresChanges(
///       event: PgEvent.insert,
///       table: 'orders',
///       callback: (e) => print(e.newRow))
///   ..subscribe();
/// ```
class OrbitNestRealtime {
  final RealtimeChannelManager _manager;

  OrbitNestRealtime({
    required String baseUrl,
    required String projectSlug,
    required String apiKey,
    String? userJwt,
  }) : _manager = RealtimeChannelManager(
          wsUrl: '${baseUrl.replaceFirst(RegExp(r'^http'), 'ws')}'
              '/realtime/v1/ws?project=$projectSlug&apikey=$apiKey',
          userJwt: userJwt,
        );

  /// Create or retrieve a named channel.
  ///
  /// Chain [RealtimeChannel.onPostgresChanges] / [RealtimeChannel.onBroadcast]
  /// calls, then call [RealtimeChannel.subscribe] to connect.
  RealtimeChannel channel(String name) => RealtimeChannel(name, _manager);

  /// Release all resources (closes the WebSocket).
  Future<void> dispose() => _manager.dispose();
}
