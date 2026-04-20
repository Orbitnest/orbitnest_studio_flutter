import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'realtime_events.dart';

// Filter operators for Postgres subscriptions.
class RealtimeFilter {
  final String column;
  final String op; // eq, neq, in, gt, lt, like
  final dynamic value;

  const RealtimeFilter({
    required this.column,
    required this.op,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        column: {op: value},
      };
}

// Internal handler registration.
class _Handler {
  final String type; // 'postgres_changes' | 'broadcast'
  final PgEvent? pgEvent;
  final String? table;
  final String? schema;
  final String? broadcastEvent;
  final RealtimeFilter? filter;
  final Function callback;

  const _Handler({
    required this.type,
    this.pgEvent,
    this.table,
    this.schema,
    this.broadcastEvent,
    this.filter,
    required this.callback,
  });
}

enum ChannelStatus { idle, connecting, connected, disconnected, error }

/// A realtime channel that aggregates DB-change and broadcast subscriptions.
///
/// Usage:
/// ```dart
/// final ch = client.channel('orders')
///   ..onPostgresChanges(
///       event: PgEvent.insert,
///       table: 'orders',
///       callback: (e) => print(e.newRow))
///   ..subscribe();
///
/// // Listen to the stream directly
/// ch.events.listen((e) { ... });
/// ```
class RealtimeChannel {
  final String name;
  final RealtimeChannelManager _manager;

  final List<_Handler> _handlers = [];
  final StreamController<RealtimeEvent> _eventController =
      StreamController<RealtimeEvent>.broadcast();

  ChannelStatus _status = ChannelStatus.idle;
  ChannelStatus get status => _status;

  // ─── Presence state ──────────────────────────────────────────────────────────
  final Map<String, List<dynamic>> _presenceState = {};
  final List<void Function(Map<String, List<dynamic>>)> _presenceSyncCallbacks = [];
  final List<void Function(String key, List<dynamic> presences)> _presenceJoinCallbacks = [];
  final List<void Function(String key, List<dynamic> presences)> _presenceLeaveCallbacks = [];

  RealtimeChannel(this.name, this._manager);

  /// Stream of all events on this channel.
  Stream<RealtimeEvent> get events => _eventController.stream;

  // ─── Handler registration ────────────────────────────────────────────────────

  RealtimeChannel onPostgresChanges({
    required PgEvent event,
    required String table,
    String schema = 'public',
    RealtimeFilter? filter,
    required void Function(PgChangesPayload) callback,
  }) {
    _handlers.add(_Handler(
      type: 'postgres_changes',
      pgEvent: event,
      table: table,
      schema: schema,
      filter: filter,
      callback: callback,
    ));
    return this;
  }

  RealtimeChannel onBroadcast({
    required String event,
    required void Function(BroadcastPayload) callback,
  }) {
    _handlers.add(_Handler(
      type: 'broadcast',
      broadcastEvent: event,
      callback: callback,
    ));
    return this;
  }

  // ─── Presence ────────────────────────────────────────────────────────────────

  /// Called whenever the server sends a full presence roster snapshot.
  RealtimeChannel onPresenceSync(
      void Function(Map<String, List<dynamic>> state) callback) {
    _presenceSyncCallbacks.add(callback);
    return this;
  }

  /// Called when a new socket appears in the presence roster.
  RealtimeChannel onPresenceJoin(
      void Function(String key, List<dynamic> presences) callback) {
    _presenceJoinCallbacks.add(callback);
    return this;
  }

  /// Called when a socket disappears from the presence roster.
  RealtimeChannel onPresenceLeave(
      void Function(String key, List<dynamic> presences) callback) {
    _presenceLeaveCallbacks.add(callback);
    return this;
  }

  /// Returns a read-only copy of the last-known presence roster.
  Map<String, List<dynamic>> getPresenceState() =>
      Map.unmodifiable(_presenceState);

  /// Track presence with the given [state] on this channel.
  /// Other subscribers will receive a `presence.state` update.
  Future<void> track(Map<String, dynamic> state) =>
      _manager._trackPresence(name, state);

  /// Stop tracking presence on this channel.
  Future<void> untrack() => _manager._untrackPresence(name);

  // ─── Subscribe / unsubscribe ─────────────────────────────────────────────────

  Future<void> subscribe() async {
    _status = ChannelStatus.connecting;
    await _manager._subscribe(this);
  }

  Future<void> unsubscribe() async {
    await _manager._unsubscribe(this);
    _status = ChannelStatus.disconnected;
  }

  // ─── Broadcast ───────────────────────────────────────────────────────────────

  Future<void> send({required String event, required dynamic payload}) async {
    await _manager._sendBroadcast(name, event, payload);
  }

  // ─── Internal ────────────────────────────────────────────────────────────────

  void _activate() {
    _status = ChannelStatus.connected;
    for (final h in _handlers) {
      final id = '${name}_${h.type}_${DateTime.now().millisecondsSinceEpoch}';
      if (h.type == 'postgres_changes') {
        final schema = h.schema ?? 'public';
        final events = _pgEventsToStrings(h.pgEvent ?? PgEvent.all);
        final msg = {
          'id': id,
          'type': 'subscribe',
          'channel': 'table:$schema.${h.table}',
          'events': events,
          if (h.filter != null) 'filter': h.filter!.toJson(),
        };
        _manager._send(msg);
      } else if (h.type == 'broadcast') {
        _manager._send({
          'id': id,
          'type': 'subscribe',
          'channel': 'broadcast:$name',
        });
      }
    }
  }

  void _dispatch(Map<String, dynamic> msg) {
    if (msg['type'] == 'db_event') {
      final payload = PgChangesPayload.fromJson(msg);
      final event = RealtimeDbEvent(payload);
      _eventController.add(event);

      for (final h in _handlers) {
        if (h.type != 'postgres_changes') continue;
        final ops = _pgEventsToStrings(h.pgEvent ?? PgEvent.all);
        if (!ops.contains(msg['op']) && !ops.contains('*')) continue;
        if (h.table != null && h.table != msg['table']) continue;
        if (h.schema != null && h.schema != msg['schema']) continue;
        (h.callback as void Function(PgChangesPayload))(payload);
      }
    } else if (msg['type'] == 'broadcast') {
      final payload = BroadcastPayload.fromJson(msg);
      _eventController.add(RealtimeBroadcastEvent(payload));

      for (final h in _handlers) {
        if (h.type != 'broadcast') continue;
        if (h.broadcastEvent != '*' && h.broadcastEvent != msg['event']) continue;
        (h.callback as void Function(BroadcastPayload))(payload);
      }
    } else if (msg['type'] == 'presence.state') {
      final raw = msg['presences'] as Map<String, dynamic>? ?? {};
      final newPresences = raw.map((k, v) =>
          MapEntry(k, v is List ? List<dynamic>.from(v) : <dynamic>[v]));

      // Detect joins
      for (final entry in newPresences.entries) {
        if (!_presenceState.containsKey(entry.key)) {
          for (final cb in _presenceJoinCallbacks) {
            cb(entry.key, entry.value);
          }
        }
      }
      // Detect leaves
      for (final entry in _presenceState.entries) {
        if (!newPresences.containsKey(entry.key)) {
          for (final cb in _presenceLeaveCallbacks) {
            cb(entry.key, entry.value);
          }
        }
      }

      _presenceState
        ..clear()
        ..addAll(newPresences);

      final snapshot = Map<String, List<dynamic>>.unmodifiable(_presenceState);
      _eventController.add(RealtimePresenceEvent(channel: name, presences: snapshot));
      for (final cb in _presenceSyncCallbacks) {
        cb(snapshot);
      }
    } else if (msg['type'] == 'system') {
      _eventController.add(RealtimeSystemEvent(
        event: msg['event'] as String? ?? '',
        message: msg['message'] as String?,
      ));
    } else if (msg['type'] == 'error') {
      _eventController.add(RealtimeErrorEvent(
        code: msg['code'] as String? ?? 'unknown',
        message: msg['message'] as String? ?? 'Unknown error',
      ));
    }
  }

  void _setStatus(ChannelStatus s) {
    _status = s;
  }

  void dispose() {
    _eventController.close();
  }
}

// ─── RealtimeChannelManager ───────────────────────────────────────────────────

/// Manages the WebSocket connection and all channels. Used internally by
/// [OrbitNestRealtime].
class RealtimeChannelManager {
  final String wsUrl;
  final String? userJwt;

  WebSocketChannel? _ws;
  StreamSubscription? _sub;
  final Map<String, RealtimeChannel> _channels = {};
  bool _shouldReconnect = true;
  int _reconnectDelayMs = 500;
  Timer? _reconnectTimer;

  RealtimeChannelManager({required this.wsUrl, this.userJwt});

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  Future<void> _ensureConnected() async {
    if (_ws != null) return;

    final uri = Uri.parse(wsUrl);
    final protocols = ['orbitnest-realtime-v1'];
    if (userJwt != null) protocols.add('orbitnest.user-jwt.$userJwt');

    _ws = WebSocketChannel.connect(uri, protocols: protocols);

    _sub = _ws!.stream.listen(
      (data) {
        try {
          final msg = jsonDecode(data as String) as Map<String, dynamic>;
          _route(msg);
        } catch (_) {}
      },
      onDone: () {
        _ws = null;
        _sub = null;
        for (final ch in _channels.values) {
          ch._setStatus(ChannelStatus.disconnected);
        }
        if (_shouldReconnect && _channels.isNotEmpty) {
          _scheduleReconnect();
        }
      },
      onError: (_) {
        _ws = null;
        _sub = null;
        if (_shouldReconnect && _channels.isNotEmpty) {
          _scheduleReconnect();
        }
      },
      cancelOnError: false,
    );

    // Activate all pending channels once the stream is open.
    // WebSocketChannel connects synchronously; activation is also synchronous.
    for (final ch in _channels.values) {
      ch._activate();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: _reconnectDelayMs), () {
      _reconnectDelayMs = (_reconnectDelayMs * 2).clamp(0, 30000);
      _ensureConnected().then((_) {
        _reconnectDelayMs = 500; // reset on success
      }).catchError((_) {
        _scheduleReconnect();
      });
    });
  }

  void _send(Map<String, dynamic> msg) {
    _ws?.sink.add(jsonEncode(msg));
  }

  // ─── Channel management ───────────────────────────────────────────────────────

  Future<void> _subscribe(RealtimeChannel ch) async {
    _channels[ch.name] = ch;
    await _ensureConnected();
    ch._activate();
  }

  Future<void> _unsubscribe(RealtimeChannel ch) async {
    _channels.remove(ch.name);
    _send({
      'id': 'unsub_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'unsubscribe',
      'channel': ch.name,
    });
    if (_channels.isEmpty) {
      _shouldReconnect = false;
      await _ws?.sink.close();
      _ws = null;
    }
  }

  Future<void> _sendBroadcast(
      String channelName, String event, dynamic payload) async {
    await _ensureConnected();
    _send({
      'id': 'bc_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'broadcast',
      'channel': 'broadcast:$channelName',
      'event': event,
      'payload': payload,
    });
  }

  // ─── Message routing ─────────────────────────────────────────────────────────

  void _route(Map<String, dynamic> msg) {
    final msgChannel = msg['channel'] as String?;
    if (msg['type'] == 'db_event' && msgChannel != null) {
      // channel is "table:schema.table" — find matching channel registrations
      for (final ch in _channels.values) {
        ch._dispatch(msg);
      }
    } else if (msg['type'] == 'broadcast' && msgChannel != null) {
      final channelName = msgChannel.replaceFirst('broadcast:', '');
      final target = _channels[channelName];
      if (target != null) target._dispatch(msg);
    } else if (msg['type'] == 'presence.state' && msgChannel != null) {
      final channelName = msgChannel.replaceFirst('broadcast:', '');
      final target = _channels[channelName];
      if (target != null) target._dispatch(msg);
    } else if (msg['type'] == 'system') {
      for (final ch in _channels.values) {
        ch._dispatch(msg);
      }
    }
  }

  Future<void> _trackPresence(
      String channelName, Map<String, dynamic> state) async {
    await _ensureConnected();
    _send({
      'id': 'pt_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'presence.track',
      'channel': 'broadcast:$channelName',
      'state': state,
    });
  }

  Future<void> _untrackPresence(String channelName) async {
    _send({
      'id': 'pu_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'unsubscribe',
      'channel': 'broadcast:$channelName',
    });
  }

  Future<void> dispose() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    await _sub?.cancel();
    await _ws?.sink.close();
    for (final ch in _channels.values) {
      ch.dispose();
    }
    _channels.clear();
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

List<String> _pgEventsToStrings(PgEvent event) {
  switch (event) {
    case PgEvent.insert:
      return ['INSERT'];
    case PgEvent.update:
      return ['UPDATE'];
    case PgEvent.delete:
      return ['DELETE'];
    case PgEvent.all:
      return ['INSERT', 'UPDATE', 'DELETE'];
  }
}
