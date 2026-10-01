import '../models/game_event.dart';
import '../models/player_event.dart';

/// Estado da conexão do jogador com o host.
///
/// Nomeado `GameConnectionState` para não colidir com `ConnectionState` do
/// Flutter (`FutureBuilder`/`StreamBuilder`) nas telas que importam ambos.
enum GameConnectionState {
  /// Primeira tentativa de conexão em andamento.
  connecting,

  /// Socket aberto e `JOINED`/`STATE_SYNC` já pode chegar.
  connected,

  /// Caiu a conexão; tentando de novo com backoff exponencial.
  reconnecting,

  /// Sem conexão. Ou desistimos de reconectar ou o jogador saiu.
  disconnected,

  /// O host encerrou a sala (`ROOM_CLOSED`). Não há reconexão.
  roomClosed,
}

/// Falha ao subir o servidor do host (porta ocupada, sem permissão, etc.).
class HostStartException implements Exception {
  final String message;
  final Object? cause;
  HostStartException(this.message, [this.cause]);

  @override
  String toString() => 'HostStartException: $message';
}

/// Defines a polymorphic contract for game connectivity.
/// This interface will be implemented for both local (Wi-Fi) and remote (Cloud) connections.
abstract class IGameConnection {
  // Host Methods

  /// Starts a new game room as the host.
  ///
  /// [roomName] is a user-friendly name for the session. [port] `0` binds a
  /// dynamic port; any other value is tried first and, if busy, the next ones
  /// in a small range. Returns the port actually bound. Throws
  /// [HostStartException] when no port could be bound. Calling it while a
  /// server is running restarts the server instead of throwing.
  Future<int> hostRoom(
    String roomName,
    String secretToken,
    String hostIp,
    int port,
  );

  /// Broadcasts a [GameEvent] to all connected players.
  Future<void> broadcastEvent(GameEvent event);

  // Player Methods

  /// Joins an existing game room using a [connectionId].
  ///
  /// The [connectionId] is the WebSocket URI for local games. Completes once
  /// the socket is open; throws if the host refuses or is unreachable.
  Future<void> joinRoom(String connectionId);

  /// Tenta reconectar ao último host, reiniciando o contador de tentativas.
  /// Só faz sentido no estado [GameConnectionState.disconnected].
  Future<void> reconnect();

  /// Sends a [PlayerEvent] from a player to the host.
  Future<void> sendPlayerEvent(PlayerEvent event);

  // Common

  /// A stream of [GameEvent]s from the host that players listen to.
  Stream<GameEvent> get eventStream;

  /// Estado atual da conexão do jogador e stream de mudanças.
  GameConnectionState get connectionState;
  Stream<GameConnectionState> get connectionStateStream;

  /// Lista atual de jogadores conectados (nomes), na mesma ordem em que
  /// [connectedPlayersStream] a emitiu pela última vez. Vazia fora do papel
  /// de host. Quem começa a ouvir o stream depois de uma entrada usa este
  /// valor como ponto de partida: o stream só emite mudanças.
  List<String> get connectedPlayers;

  /// A stream of the list of connected player names (or IDs).
  /// Required for the Host to know who is in the room. Emite a cada
  /// entrada/saída/renomeação; não repete o valor atual para novos ouvintes
  /// (veja [connectedPlayers]).
  Stream<List<String>> get connectedPlayersStream;

  /// A stream of system error messages (e.g. 'PAYWALL_TRIGGERED') intended for the Host.
  Stream<String> get errorStream;

  /// Disconnects from the game room.
  ///
  /// As host, broadcasts `ROOM_CLOSED` and stops the server. As player,
  /// closes the socket without trying to reconnect.
  Future<void> disconnect();
}
