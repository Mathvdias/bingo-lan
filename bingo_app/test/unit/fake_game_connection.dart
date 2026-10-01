import 'dart:async';

import 'package:bingo_core/bingo_core.dart';

/// Conexão falsa para testar ViewModels sem rede.
///
/// Registra o que foi enviado/transmitido e permite injetar eventos, lista de
/// jogadores, erros e estados de conexão.
class FakeGameConnection implements IGameConnection {
  final _events = StreamController<GameEvent>.broadcast();
  final _players = StreamController<List<String>>.broadcast();
  final _errors = StreamController<String>.broadcast();
  final _states = StreamController<GameConnectionState>.broadcast();

  GameConnectionState _state;

  final List<GameEvent> broadcasts = [];
  final List<PlayerEvent> sent = [];
  final List<String> joinedUris = [];
  int hostCalls = 0;
  int disconnectCalls = 0;
  int reconnectCalls = 0;
  int hostPort = 4242;

  /// Se definido, `joinRoom` lança este erro.
  Object? joinError;

  /// Executado logo após um `joinRoom` bem-sucedido (ex.: emitir JOINED).
  void Function()? onJoin;

  FakeGameConnection({
    GameConnectionState initialState = GameConnectionState.connected,
  }) : _state = initialState;

  // ------------------------------------------------------------ test helpers
  void emit(GameEvent event) => _events.add(event);
  void emitPlayers(List<String> players) => _players.add(players);
  void emitError(String error) => _errors.add(error);

  void setState(GameConnectionState state) {
    _state = state;
    _states.add(state);
  }

  Future<void> dispose() async {
    await _events.close();
    await _players.close();
    await _errors.close();
    await _states.close();
  }

  bool get hasEventListeners => _events.hasListener;
  bool get hasStateListeners => _states.hasListener;
  bool get hasPlayerListeners => _players.hasListener;
  bool get hasErrorListeners => _errors.hasListener;

  // ------------------------------------------------------- IGameConnection
  @override
  Stream<GameEvent> get eventStream => _events.stream;

  @override
  Stream<List<String>> get connectedPlayersStream => _players.stream;

  @override
  Stream<String> get errorStream => _errors.stream;

  @override
  GameConnectionState get connectionState => _state;

  @override
  Stream<GameConnectionState> get connectionStateStream => _states.stream;

  @override
  Future<int> hostRoom(
    String roomName,
    String secretToken,
    String hostIp,
    int port,
  ) async {
    hostCalls++;
    return port == 0 ? hostPort : port;
  }

  @override
  Future<void> broadcastEvent(GameEvent event) async {
    broadcasts.add(event);
  }

  @override
  Future<void> joinRoom(String connectionId) async {
    joinedUris.add(connectionId);
    final error = joinError;
    if (error != null) {
      setState(GameConnectionState.disconnected);
      throw error;
    }
    setState(GameConnectionState.connected);
    onJoin?.call();
  }

  @override
  Future<void> reconnect() async {
    reconnectCalls++;
    setState(GameConnectionState.connected);
  }

  @override
  Future<void> sendPlayerEvent(PlayerEvent event) async {
    sent.add(event);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    if (_state != GameConnectionState.roomClosed) {
      setState(GameConnectionState.disconnected);
    }
  }
}
