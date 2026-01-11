import 'dart:async';
import 'dart:convert';
import 'dart:developer'; // Import for log
import 'dart:io';

import 'package:bingo_core/bingo_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocalShelfGameConnection implements IGameConnection {
  HttpServer? _server;
  String? _secretToken;

  // HOST State
  final Map<String, WebSocketChannel> _connectedPlayers = {};

  // PLAYER State
  WebSocketChannel? _clientChannel;
  StreamSubscription? _clientSubscription;

  final _gameEventController = StreamController<GameEvent>.broadcast();
  final _connectedPlayersController =
      StreamController<List<String>>.broadcast();

  // In a real app, you might want separate streams for "Events from Host" vs "Events from Players"
  // But given standard IGameConnection uses a single eventStream for UI to listen to "Game Events" (usually from Host)
  // we will direct incoming messages to this stream.

  @override
  Stream<GameEvent> get eventStream => _gameEventController.stream;

  @override
  Stream<List<String>> get connectedPlayersStream =>
      _connectedPlayersController.stream;

  // --- PLAYER METHODS ---

  @override
  Future<void> joinRoom(String connectionId) async {
    // connectionId expected to be "ws://ip:port?token=..."
    if (_clientChannel != null) {
      await disconnect();
    }

    try {
      final uri = Uri.parse(connectionId);
      // Connect to the WebSocket
      _clientChannel = WebSocketChannel.connect(uri);

      _clientSubscription = _clientChannel!.stream.listen(
        (message) {
          log('Player received: $message');
          try {
            final json = jsonDecode(message);
            // Verify if it is a GameEvent (from Host)
            // The host sends GameEvents.
            final event = GameEvent.fromJson(json);
            _gameEventController.add(event);
          } catch (e) {
            log('Error parsing message from host: $e');
          }
        },
        onError: (error) {
          log('Client WebSocket error: $error');
        },
        onDone: () {
          log('Disconnected from host.');
        },
      );

      // Wait for connection to be potentially established?
      // WebSocketChannel.connect is synchronous in creation but async in connection.
      // We assume it works.
      log('Participando da sala: $connectionId');
    } catch (e) {
      log('Error joining room: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPlayerEvent(PlayerEvent event) async {
    if (_clientChannel != null) {
      // We are a Player sending to Host
      final json = jsonEncode(event.toJson());
      _clientChannel!.sink.add(json);
    } else {
      // We are Host, why are we sending PlayerEvent?
      // Maybe testing? Or maybe the Host is also a Player?
      // For now, ignore.
      log('Cannot send PlayerEvent: No active client connection.');
    }
  }

  // --- HOST METHODS ---

  @override
  Future<void> hostRoom(
    String roomName,
    String secretToken,
    String hostIp,
    int port,
  ) async {
    if (_server != null) {
      throw StateError('Server is already running.');
    }

    _secretToken = secretToken;

    final handler = const Pipeline().addMiddleware(logRequests()).addHandler((
      request,
    ) {
      // 1. Intercept Request to check Token
      final token = request.url.queryParameters['token'];
      if (token != _secretToken) {
        return Response.forbidden('Invalid Token');
      }

      // 2. If valid, upgrade to WebSocket
      return webSocketHandler((
        WebSocketChannel webSocketChannel,
        String? protocol,
      ) {
        final clientId = 'player_${_connectedPlayers.length + 1}';
        _connectedPlayers[clientId] = webSocketChannel;
        log('Player $clientId connected to room $roomName');

        // Notify subscribers about the new list of players
        _connectedPlayersController.add(_connectedPlayers.keys.toList());

        webSocketChannel.stream.listen(
          (message) {
            // Host receiving message from Player
            try {
              final json = jsonDecode(message);
              // Parse as PlayerEvent
              final event = PlayerEvent.fromJson(json);

              // Since PlayerEvent extends GameEvent now (we modified it), this is valid.
              _gameEventController.add(event);
            } catch (e) {
              log('Error processing player message: $e');
            }
          },
          onDone: () {
            _connectedPlayers.remove(clientId);
            // Notify subscribers about the player leaving
            _connectedPlayersController.add(_connectedPlayers.keys.toList());
          },
        );
      })(request);
    });

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    log('Local server started on ws://$hostIp:$port?token=$secretToken');
  }

  @override
  Future<void> broadcastEvent(GameEvent event) async {
    if (_server == null) {
      // throw StateError('Server is not running.');
      return;
    }

    final json = jsonEncode(event.toJson());
    for (final channel in _connectedPlayers.values) {
      channel.sink.add(json);
    }
  }

  @override
  Future<void> disconnect() async {
    // HOST cleanup
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _connectedPlayers.clear();
    }

    // PLAYER cleanup
    if (_clientChannel != null) {
      await _clientChannel!.sink.close();
      _clientChannel = null;
    }
    await _clientSubscription?.cancel();
    _clientSubscription = null;
  }
}
