import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../logic/access_control_service.dart';
import '../models/game_event.dart';
import '../models/game_events.dart';
import '../models/player_event.dart';
import '../models/player_events.dart';
import '../services/jwt_service.dart';
import 'i_config_driver.dart';
import 'i_game_connection.dart';
import 'i_uuid_driver.dart';

/// Sessão de um jogador no host. Sobrevive à queda do socket para permitir
/// reconexão com a mesma identidade (`playerId`, `cardId`, nome).
class _PlayerSession {
  final String playerId;
  final int cardId;
  String name;
  String ip;
  WebSocketChannel? channel;

  _PlayerSession({
    required this.playerId,
    required this.cardId,
    required this.name,
    required this.ip,
    required this.channel,
  });
}

/// Conexão de jogo em rede local: o host sobe um servidor WebSocket (shelf) e
/// os jogadores conectam com um JWT na query string.
///
/// A mesma instância atua como host (`hostRoom`) ou jogador (`joinRoom`).
class LocalShelfGameConnection implements IGameConnection {
  /// Nome provisório até o cliente enviar `PLAYER_NAME`.
  static const String defaultPlayerName = 'Player';

  /// Tamanho máximo do nome exibido.
  static const int maxNameLength = 24;

  /// Portas tentadas a partir da pedida quando ela não for `0`.
  static const int portRange = 20;

  static const String _pidParam = 'pid';
  static const String _tokenParam = 'token';

  final AccessControlService _accessControl;
  final IConfigDriver _configDriver;
  final IUUIDDriver _uuid;
  final Random _random;

  /// Intervalo de ping/pong nos dois lados.
  final Duration heartbeatInterval;

  /// Backoff exponencial: base, base*2, base*4, base*8 (teto em 8x).
  final Duration reconnectBaseDelay;
  final int maxReconnectAttempts;

  /// Máximo de sockets simultâneos por endereço IP.
  final int maxSocketsPerIp;

  final Duration connectTimeout;

  LocalShelfGameConnection({
    required AccessControlService accessControl,
    required IConfigDriver configDriver,
    required IUUIDDriver uuidDriver,
    Random? random,
    this.heartbeatInterval = const Duration(seconds: 15),
    this.reconnectBaseDelay = const Duration(seconds: 1),
    this.maxReconnectAttempts = 5,
    this.maxSocketsPerIp = 3,
    this.connectTimeout = const Duration(seconds: 10),
  }) : _accessControl = accessControl,
       _configDriver = configDriver,
       _uuid = uuidDriver,
       _random = random ?? Random();

  // ---------------------------------------------------------------- HOST state
  HttpServer? _server;
  String? _secretToken;
  String? _roomName;
  final Map<String, _PlayerSession> _sessions = {};
  final Map<WebSocketChannel, _PlayerSession> _attached = {};
  final Set<int> _usedCardIds = {};
  List<int> _drawnNumbers = [];

  // -------------------------------------------------------------- PLAYER state
  Uri? _joinUri;
  String? _assignedPlayerId;
  WebSocketChannel? _clientChannel;
  StreamSubscription? _clientSubscription;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _intentionalClose = false;
  GameConnectionState _state = GameConnectionState.disconnected;

  final _gameEventController = StreamController<GameEvent>.broadcast();
  final _connectedPlayersController =
      StreamController<List<String>>.broadcast();
  List<String> _connectedPlayers = const [];
  final _errorController = StreamController<String>.broadcast();
  final _stateController = StreamController<GameConnectionState>.broadcast();

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Stream<GameEvent> get eventStream => _gameEventController.stream;

  @override
  List<String> get connectedPlayers => _connectedPlayers;

  @override
  Stream<List<String>> get connectedPlayersStream =>
      _connectedPlayersController.stream;

  @override
  GameConnectionState get connectionState => _state;

  @override
  Stream<GameConnectionState> get connectionStateStream =>
      _stateController.stream;

  /// Porta em uso pelo servidor do host, ou `null` se não estiver servindo.
  int? get boundPort => _server?.port;

  /// Id atribuído pelo host a este jogador (após `JOINED`).
  String? get assignedPlayerId => _assignedPlayerId;

  // ============================================================ PLAYER METHODS

  @override
  Future<void> joinRoom(String connectionId) async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _closeClientSocket();

    _joinUri = Uri.parse(connectionId);
    _assignedPlayerId = null;
    _reconnectAttempt = 0;
    _intentionalClose = false;

    await _openClientSocket(first: true);
  }

  @override
  Future<void> reconnect() async {
    if (_joinUri == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _intentionalClose = false;
    _reconnectAttempt = 0;
    await _closeClientSocket();
    await _openClientSocket(first: false);
  }

  Future<void> _openClientSocket({required bool first}) async {
    if (_intentionalClose) return;
    _setState(
      first ? GameConnectionState.connecting : GameConnectionState.reconnecting,
    );

    final base = _joinUri!;
    final pid = _assignedPlayerId;
    final uri = pid == null
        ? base
        : base.replace(
            queryParameters: {...base.queryParameters, _pidParam: pid},
          );

    final channel = IOWebSocketChannel.connect(
      uri,
      pingInterval: heartbeatInterval,
      connectTimeout: connectTimeout,
    );

    try {
      await channel.ready;
    } catch (e) {
      // Não loga a URI: ela contém o JWT.
      log('Could not reach the host: ${e.runtimeType}');
      if (first) {
        _setState(GameConnectionState.disconnected);
        rethrow;
      }
      _scheduleReconnect();
      return;
    }

    if (_intentionalClose) {
      await channel.sink.close();
      return;
    }

    _clientChannel = channel;
    _reconnectAttempt = 0;
    _setState(GameConnectionState.connected);

    _clientSubscription = channel.stream.listen(
      _onHostMessage,
      onError: (Object error) {
        log('Client WebSocket error: ${error.runtimeType}');
      },
      onDone: () => _onClientDone(channel),
      cancelOnError: false,
    );
  }

  void _onHostMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String);
      if (json is! Map<String, dynamic>) return;
      final event = GameEvent.fromJson(json);

      if (event is JoinedEvent) {
        _assignedPlayerId = event.playerId;
      } else if (event is StateSyncEvent && event.playerId != null) {
        _assignedPlayerId = event.playerId;
      } else if (event is RoomClosedEvent) {
        _intentionalClose = true;
        _setState(GameConnectionState.roomClosed);
      }

      _gameEventController.add(event);
    } on UnknownEventException catch (e) {
      log('Ignoring unknown host event: ${e.type}');
    } catch (e) {
      log('Error parsing message from host: $e');
    }
  }

  void _onClientDone(WebSocketChannel channel) {
    if (!identical(_clientChannel, channel)) return;
    _clientChannel = null;
    _clientSubscription = null;

    if (_intentionalClose) {
      if (_state != GameConnectionState.roomClosed) {
        _setState(GameConnectionState.disconnected);
      }
      return;
    }
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalClose) return;
    if (_reconnectAttempt >= maxReconnectAttempts) {
      log('Giving up after $_reconnectAttempt reconnect attempts.');
      _setState(GameConnectionState.disconnected);
      return;
    }
    final factor = min(1 << _reconnectAttempt, 8);
    final delay = reconnectBaseDelay * factor;
    _reconnectAttempt++;
    _setState(GameConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      _openClientSocket(first: false);
    });
  }

  Future<void> _closeClientSocket() async {
    final channel = _clientChannel;
    _clientChannel = null;
    await _clientSubscription?.cancel();
    _clientSubscription = null;
    if (channel != null) {
      try {
        await channel.sink.close(1000, 'Client left');
      } catch (e) {
        log('Error closing client socket: $e');
      }
    }
  }

  @override
  Future<void> sendPlayerEvent(PlayerEvent event) async {
    final channel = _clientChannel;
    if (channel == null) {
      log('Cannot send PlayerEvent: no active connection.');
      return;
    }
    channel.sink.add(jsonEncode(event.toJson()));
  }

  void _setState(GameConnectionState next) {
    if (_state == next) return;
    _state = next;
    _stateController.add(next);
  }

  // ============================================================== HOST METHODS

  @override
  Future<int> hostRoom(
    String roomName,
    String secretToken,
    String hostIp,
    int port,
  ) async {
    if (_server != null) {
      log('hostRoom called with a server running; restarting it.');
      await _stopServer();
    }

    _secretToken = secretToken;
    _roomName = roomName;
    _drawnNumbers = [];
    _sessions.clear();
    _attached.clear();
    _usedCardIds.clear();

    final handler = const Pipeline().addHandler(_handleRequest);
    _server = await _bind(handler, port);
    log('Local server started on port ${_server!.port}');
    return _server!.port;
  }

  Future<HttpServer> _bind(Handler handler, int port) async {
    if (port == 0) {
      try {
        return await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
      } on SocketException catch (e) {
        throw HostStartException('Could not bind a dynamic port', e);
      }
    }

    SocketException? last;
    for (var candidate = port; candidate < port + portRange; candidate++) {
      try {
        return await shelf_io.serve(handler, InternetAddress.anyIPv4, candidate);
      } on SocketException catch (e) {
        last = e;
      }
    }
    throw HostStartException(
      'No free port between $port and ${port + portRange - 1}',
      last,
    );
  }

  Future<Response> _handleRequest(Request request) async {
    final token = request.url.queryParameters[_tokenParam];
    if (token == null) {
      return Response.forbidden('Missing token');
    }

    final isValid = JwtService.validateRoomToken(
      token: token,
      secret: _secretToken!,
      expectedRoomId: _roomName!,
      expectedRole: 'player',
    );
    if (!isValid) {
      return Response.forbidden('Invalid token');
    }

    final ip = _remoteIp(request);
    final pid = request.url.queryParameters[_pidParam];
    final resumed = pid == null ? null : _sessions[pid];

    if (resumed != null && resumed.channel != null) {
      // O celular voltou antes de o ping detectar o socket morto: troca o
      // socket antigo pelo novo em vez de abrir uma segunda sessão.
      final stale = resumed.channel!;
      _attached.remove(stale);
      resumed.channel = null;
      unawaited(
        stale.sink.close(1000, 'Replaced by reconnection').catchError((_) {}),
      );
    }

    if (resumed == null) {
      final fromSameIp = _attached.values.where((s) => s.ip == ip).length;
      if (fromSameIp >= maxSocketsPerIp) {
        log('Connection rejected: too many sockets from one address.');
        return Response.forbidden('Too many connections from this address');
      }

      if (await _isRoomFull()) {
        _errorController.add('PAYWALL_TRIGGERED');
        log('Connection rejected: room capacity limit reached.');
        return Response.forbidden('Room full');
      }
    }

    return webSocketHandler((WebSocketChannel channel, String? protocol) {
      _onPlayerSocket(channel, ip, resumed);
    }, pingInterval: heartbeatInterval)(request);
  }

  /// Caminho A (paywall do host): limite de jogadores grátis do Remote Config.
  Future<bool> _isRoomFull() async {
    final revenueModel = _configDriver.getString('revenue_model');
    if (revenueModel != 'paywall_host' && revenueModel != 'variant_a') {
      return false;
    }
    final maxPlayers = _configDriver.getInt('max_free_players_path_a');
    final limit = maxPlayers > 0 ? maxPlayers : 10;
    if (_attached.length < limit) return false;
    final isPremium = await _accessControl.canAccess('is_host_premium');
    return !isPremium;
  }

  String _remoteIp(Request request) {
    final info = request.context['shelf.io.connection_info'];
    if (info is HttpConnectionInfo) return info.remoteAddress.address;
    return 'unknown';
  }

  void _onPlayerSocket(
    WebSocketChannel channel,
    String ip,
    _PlayerSession? resumed,
  ) {
    final _PlayerSession session;
    final GameEvent hello;

    if (resumed != null) {
      session = resumed
        ..channel = channel
        ..ip = ip;
      hello = StateSyncEvent(
        drawnNumbers: List<int>.of(_drawnNumbers),
        playerId: session.playerId,
        cardId: session.cardId,
        roomName: _roomName,
      );
    } else {
      session = _PlayerSession(
        playerId: _uuid.v4(),
        cardId: _newCardId(),
        name: _uniqueName(defaultPlayerName),
        ip: ip,
        channel: channel,
      );
      _sessions[session.playerId] = session;
      hello = JoinedEvent(
        playerId: session.playerId,
        cardId: session.cardId,
        drawnNumbers: List<int>.of(_drawnNumbers),
        roomName: _roomName ?? '',
      );
    }

    _attached[channel] = session;
    channel.sink.add(jsonEncode(hello.toJson()));
    _emitPlayers();

    channel.stream.listen(
      (message) => _onPlayerMessage(session, message),
      onError: (Object error) {
        log('Player socket error: ${error.runtimeType}');
      },
      onDone: () => _detach(channel),
      cancelOnError: false,
    );
  }

  void _onPlayerMessage(_PlayerSession session, dynamic message) {
    try {
      final json = jsonDecode(message as String);
      if (json is! Map<String, dynamic>) return;
      final event = PlayerEvent.fromJson(json);

      if (event is PlayerNameEvent) {
        session.name = _uniqueName(_sanitizeName(event.name), exclude: session);
        _emitPlayers();
      } else if (event is ShoutBingoEvent) {
        // Identidade vem sempre da sessão do socket, nunca do payload.
        _gameEventController.add(
          event.withIdentity(
            playerId: session.playerId,
            cardId: session.cardId,
            playerName: session.name,
          ),
        );
      }
    } on UnknownEventException catch (e) {
      log('Ignoring unknown player event: ${e.type}');
    } catch (e) {
      log('Error processing player message: $e');
    }
  }

  void _detach(WebSocketChannel channel) {
    final session = _attached.remove(channel);
    if (session != null && identical(session.channel, channel)) {
      session.channel = null;
    }
    _emitPlayers();
  }

  /// Atualiza a lista atual e avisa quem já está ouvindo. A lista fica em
  /// [connectedPlayers] para quem assinar depois (ex.: a tela da sala, criada
  /// depois que os jogadores entraram pela tela de convite).
  void _emitPlayers() {
    _connectedPlayers = _attached.values
        .map((s) => s.name)
        .toList(growable: false);
    if (_connectedPlayersController.isClosed) return;
    _connectedPlayersController.add(_connectedPlayers);
  }

  int _newCardId() {
    for (var i = 0; i < 1000; i++) {
      final candidate = 1 + _random.nextInt(999999);
      if (_usedCardIds.add(candidate)) return candidate;
    }
    throw StateError('Could not allocate a unique card id');
  }

  static String _sanitizeName(String raw) {
    var name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.length > maxNameLength) name = name.substring(0, maxNameLength);
    return name.isEmpty ? defaultPlayerName : name;
  }

  /// `Ana`, `Ana (2)`, `Ana (3)`… considerando todas as sessões da sala.
  String _uniqueName(String base, {_PlayerSession? exclude}) {
    final taken = _sessions.values
        .where((s) => !identical(s, exclude))
        .map((s) => s.name.toLowerCase())
        .toSet();
    if (!taken.contains(base.toLowerCase())) return base;
    for (var n = 2; ; n++) {
      final candidate = '$base ($n)';
      if (!taken.contains(candidate.toLowerCase())) return candidate;
    }
  }

  @override
  Future<void> broadcastEvent(GameEvent event) async {
    if (_server == null) return;

    if (event is NumberDrawnEvent) {
      _drawnNumbers.add(event.number);
    } else if (event is StateSyncEvent) {
      _drawnNumbers = List<int>.of(event.drawnNumbers);
    }

    final json = jsonEncode(event.toJson());
    for (final channel in List<WebSocketChannel>.of(_attached.keys)) {
      try {
        channel.sink.add(json);
      } catch (e) {
        log('Error sending to player: $e');
      }
    }
  }

  /// Fecha o socket de um jogador sem avisar, simulando queda de rede.
  @visibleForTesting
  Future<void> debugDropPlayer(String playerId) async {
    final channel = _sessions[playerId]?.channel;
    if (channel == null) return;
    await channel.sink.close(4000, 'dropped');
  }

  Future<void> _stopServer() async {
    final server = _server;
    if (server == null) return;
    _server = null;

    final channels = List<WebSocketChannel>.of(_attached.keys);
    if (channels.isNotEmpty) {
      final json = jsonEncode(RoomClosedEvent().toJson());
      for (final channel in channels) {
        try {
          channel.sink.add(json);
        } catch (_) {}
      }
      // Dá tempo de o frame ROOM_CLOSED sair antes de fechar os sockets.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await Future.wait(
        channels.map(
          (c) => c.sink
              .close(1000, 'Room closed')
              .timeout(const Duration(seconds: 1))
              .catchError((_) {}),
        ),
      );
    }

    await server.close(force: true);
    _attached.clear();
    _sessions.clear();
    _usedCardIds.clear();
    _drawnNumbers = [];
    _emitPlayers();
    log('Local server stopped.');
  }

  // ===================================================================== COMMON

  @override
  Future<void> disconnect() async {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _stopServer();

    final hadClient = _clientChannel != null;
    await _closeClientSocket();
    if (hadClient || _state == GameConnectionState.reconnecting) {
      if (_state != GameConnectionState.roomClosed) {
        _setState(GameConnectionState.disconnected);
      }
    }
  }
}
