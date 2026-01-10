import '../models/game_event.dart';
import '../models/player_event.dart';

/// Defines a polymorphic contract for game connectivity.
/// This interface will be implemented for both local (Wi-Fi) and remote (Cloud) connections.
abstract class IGameConnection {
  // Host Methods
  
  /// Starts a new game room as the host.
  /// [roomName] is a user-friendly name for the session.
  Future<void> hostRoom(String roomName, String secretToken, String hostIp, int port);

  /// Broadcasts a [GameEvent] to all connected players.
  Future<void> broadcastEvent(GameEvent event);
  
  // Player Methods
  
  /// Joins an existing game room using a [connectionId].
  /// The [connectionId] can be an IP address for local games or a room code for online games.
  Future<void> joinRoom(String connectionId);
  
  /// Sends a [PlayerEvent] from a player to the host.
  Future<void> sendPlayerEvent(PlayerEvent event);
  
  // Common
  
  /// A stream of [GameEvent]s from the host that players listen to.
  Stream<GameEvent> get eventStream;
  
  /// Disconnects from the game room.
  Future<void> disconnect();
}
