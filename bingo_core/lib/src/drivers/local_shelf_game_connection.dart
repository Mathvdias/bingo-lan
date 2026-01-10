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
  String? _secretToken; // The token for the current hosted room
  final Map<String, WebSocketChannel> _connectedPlayers =
      {}; // {clientId: channel}

  final _gameEventController = StreamController<GameEvent>.broadcast();
  final _playerEventController = StreamController<PlayerEvent>.broadcast();

  @override
  Stream<GameEvent> get eventStream => _gameEventController.stream;

  // Player Methods (not implemented for host side)
  @override
  Future<void> joinRoom(String connectionId) async {
    throw UnimplementedError(
      'joinRoom is for players, not hosts in LocalShelfGameConnection',
    );
  }

  @override
  Future<void> sendPlayerEvent(PlayerEvent event) async {
    _playerEventController.add(event); // Add player event to the stream
  }

  // Host Methods
  @override
  Future<void> hostRoom(
    String roomName,
    String secretToken,
    String hostIp,
    int port,
  ) async {
    if (_server != null) {
      throw StateError('Server is not running.');
    }

    _secretToken = secretToken;

    // Create a pipeline that routes all requests to the WebSocket handler
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(
          webSocketHandler((
            WebSocketChannel webSocketChannel,
            String? protocol,
          ) {
            // Secure Handshake: Validate the secret token
            String? clientToken;
            webSocketChannel.stream.listen(
              (message) {
                if (clientToken == null) {
                  // First message should be the token or part of the handshake
                  if (message is String && message == _secretToken) {
                    clientToken = message;
                    final clientId =
                        'player_${_connectedPlayers.length + 1}'; // Simple ID for now
                    _connectedPlayers[clientId] = webSocketChannel;
                    log('Player $clientId connected to room $roomName');
                    // Optionally send a welcome message or initial state
                    webSocketChannel.sink.add(
                      jsonEncode({'type': 'CONNECTED', 'clientId': clientId}),
                    );
                  } else {
                    log(
                      'Invalid token received from client: $message. Closing connection.',
                    );
                    webSocketChannel.sink.close(
                      WebSocketStatus.protocolError,
                      'Invalid token',
                    );
                  }
                } else {
                  // After handshake, process regular player events
                  try {
                    final Map<String, dynamic> json = jsonDecode(message);
                    // TODO: Convert JSON to PlayerEvent and add to _playerEventController
                    log('Received player event: $json');
                  } catch (e) {
                    log('Error processing player message: $e');
                  }
                }
              },
              onDone: () {
                _connectedPlayers.removeWhere(
                  (key, value) => value == webSocketChannel,
                );
                log(
                  'Player disconnected. Remaining players: ${_connectedPlayers.length}',
                );
              },
              onError: (error) {
                log('WebSocket error: $error');
                _connectedPlayers.removeWhere(
                  (key, value) => value == webSocketChannel,
                );
              },
            );
          }),
        );

    // Start the HTTP server
    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

    log(
      'Local server started on ws://$hostIp:$port for room "$roomName" with token "$secretToken"',
    );
  }

  @override
  Future<void> broadcastEvent(GameEvent event) async {
    if (_server == null) {
      throw StateError('Server is not running.');
    }

    final jsonEvent = _gameEventToJson(event); // Serialize GameEvent to JSON
    final message = jsonEncode(jsonEvent);

    for (final channel in _connectedPlayers.values) {
      channel.sink.add(message);
    }
    log('Broadcasted event: $message to ${_connectedPlayers.length} players');
  }

  @override
  Future<void> disconnect() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _secretToken = null;
      for (final channel in _connectedPlayers.values) {
        await channel.sink.close();
      }
      _connectedPlayers.clear();
      log('Local server stopped.');
    }
  }

  // Helper to convert GameEvent to JSON
  Map<String, dynamic> _gameEventToJson(GameEvent event) {
    // TODO: Implement actual serialization based on GameEvent types
    // This is a placeholder
    return {'type': 'UNKNOWN_EVENT', 'data': event.toString()};
  }
}
