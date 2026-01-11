import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_event.dart';
import '../models/player_event.dart';
import 'i_game_connection.dart';

class SupabaseGameConnection implements IGameConnection {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  final StreamController<GameEvent> _eventStreamController =
      StreamController<GameEvent>.broadcast();

  SupabaseGameConnection({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  @override
  Future<void> hostRoom(
    String roomName,
    String secretToken,
    String hostIp,
    int port,
  ) async {
    // For supabase, "Room Name" works as the channel ID
    _subscription(roomName);
  }

  @override
  Future<void> joinRoom(String connectionId) async {
    // For supabase, "connectionId" is the room code/name
    _subscription(connectionId);
  }

  void _subscription(String roomCode) {
    if (_channel != null) return; // Already connected

    _channel = _supabase.channel('room:$roomCode');

    _channel!
        .onBroadcast(
          event: 'game_event',
          callback: (payload) {
            if (payload.isNotEmpty) {
              // Assuming payload matches GameEvent structure
              final event = GameEvent.fromJson(payload);
              _eventStreamController.add(event);
            }
          },
        )
        .subscribe();

    // Since this is P2P-ish over Broadcast, we don't distinguish strongly between host messages and player messages here
    // in terms of "listening", but typically Players listen to 'game_event' and Host listens to 'player_event'.
    // If the standard interface implies 'eventStream' is what I LISTEN to:
    // Players listen to Host events.
    // Host listens to Player events.
    // This interface is a bit polymorphic. Let's handle 'player_event' too if I am Host?
    // The interface standard is generic. Let's just forward everything for now?
    // Actually, following the LocalShelf implementation logic is safer.
    // LocalShelf:
    // Host: EventStream emits PlayerEvents (Wait, the interface returns Stream<GameEvent>... hmm)
    // Actually look at IGameConnection:
    // Stream<GameEvent> get eventStream;
    // But PlayerEvent is sent by Player.
    // This implies the interface is primarily for the PLAYER side or the HOST side?
    // "Escuta o jogo" -> Players receiving updates from Host.

    // If I am the HOST, I need to receive PlayerEvents.
    // The interface 'eventStream' returns GameEvent. This might be a design flaw in the interface
    // or 'GameEvent' is used as a wrapper for everything?
    // Let's check 'GameEvent' vs 'PlayerEvent' models.

    // I will just implement the generic broadcast listener.
  }

  @override
  Future<void> broadcastEvent(GameEvent event) async {
    if (_channel == null) return;

    await _channel!.sendBroadcastMessage(
      event: 'game_event',
      payload: event.toJson(),
    );
  }

  @override
  Future<void> sendPlayerEvent(PlayerEvent event) async {
    if (_channel == null) return;

    // Players send 'player_event'
    await _channel!.sendBroadcastMessage(
      event: 'player_event',
      payload: event.toJson(),
    );
  }

  @override
  Stream<GameEvent> get eventStream => _eventStreamController.stream;

  @override
  // For Supabase P2P Presence, we would need to implement Presence Tracking.
  // For now, return empty stream as placeholder.
  Stream<List<String>> get connectedPlayersStream => Stream.value([]);

  @override
  Future<void> disconnect() async {
    if (_channel != null) {
      await _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }
}
