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
  final AccessControlService _accessControl;
  final IConfigDriver _configDriver;

  HttpServer? _server;
  String? _secretToken;

  LocalShelfGameConnection({
    required AccessControlService accessControl,
    required IConfigDriver configDriver,
  }) : _accessControl = accessControl,
       _configDriver = configDriver;

  // HOST State
  final Map<WebSocketChannel, String> _connectedPlayers = {};

  // PLAYER State
  WebSocketChannel? _clientChannel;
  StreamSubscription? _clientSubscription;

  final _gameEventController = StreamController<GameEvent>.broadcast();
  final _connectedPlayersController =
      StreamController<List<String>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Stream<GameEvent> get eventStream => _gameEventController.stream;

  @override
  Stream<List<String>> get connectedPlayersStream =>
      _connectedPlayersController.stream;

  // --- PLAYER METHODS ---

  @override
  Future<void> joinRoom(String connectionId) async {
    if (_clientChannel != null) {
      await disconnect();
    }

    try {
      final uri = Uri.parse(connectionId);
      _clientChannel = WebSocketChannel.connect(uri);

      _clientSubscription = _clientChannel!.stream.listen(
        (message) {
          log('Player received: $message');
          try {
            final json = jsonDecode(message);
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

      log('Participando da sala: $connectionId');
    } catch (e) {
      log('Error joining room: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPlayerEvent(PlayerEvent event) async {
    if (_clientChannel != null) {
      final json = jsonEncode(event.toJson());
      _clientChannel!.sink.add(json);
    } else {
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
      final token = request.url.queryParameters['token'];
      if (token == null) {
        return Response.forbidden('Missing Token');
      }

      // Validate JWT token
      try {
        final isValid = JwtService.validateRoomToken(
          token: token,
          secret: _secretToken!,
          expectedRoomId: roomName,
        );

        if (!isValid) {
          return Response.forbidden('Invalid Token or Room ID mismatch');
        }
      } catch (e) {
        log('Token validation error: $e');
        return Response.forbidden('Invalid or Expired Token');
      }

      return webSocketHandler((
        WebSocketChannel webSocketChannel,
        String? protocol,
      ) async {
        // Enforce the Paywall Room Capacity (Caminho A)
        final revenueModel = _configDriver.getString('revenue_model');
        if (revenueModel == 'paywall_host' || revenueModel == 'variant_a') {
          final maxPlayers = _configDriver.getInt('max_free_players_path_a');
          final limit = maxPlayers > 0 ? maxPlayers : 10;

          if (_connectedPlayers.length >= limit) {
            // Let's assume the Pro upgrade is tied to a feature flag checking user premium sub
            final isPremium = await _accessControl.canAccess('is_host_premium');
            if (!isPremium) {
              _errorController.add('PAYWALL_TRIGGERED');
              log('Connection rejected: Room capacity limit reached.');
              webSocketChannel.sink.close(1008, 'Room Full / Premium Required');
              return;
            }
          }
        }

        final playerName = 'Player_${_connectedPlayers.length + 1}';
        _connectedPlayers[webSocketChannel] = playerName;
        log('Player $playerName connected to room $roomName');
        _connectedPlayersController.add(_connectedPlayers.values.toList());

        webSocketChannel.stream.listen(
          (message) {
            try {
              final json = jsonDecode(message);
              final event = PlayerEvent.fromJson(json);

              if (event is PlayerNameEvent) {
                _connectedPlayers[webSocketChannel] = event.name;
                _connectedPlayersController.add(
                  _connectedPlayers.values.toList(),
                );
              } else {
                _gameEventController.add(event);
              }
            } catch (e) {
              log('Error processing player message: $e');
            }
          },
          onDone: () {
            _connectedPlayers.remove(webSocketChannel);
            _connectedPlayersController.add(_connectedPlayers.values.toList());
          },
        );
      })(request);
    });

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    log('Local server started on ws://$hostIp:$port?token=<JWT>');
  }

  @override
  Future<void> broadcastEvent(GameEvent event) async {
    if (_server == null) {
      return;
    }

    final json = jsonEncode(event.toJson());
    for (final channel in _connectedPlayers.keys) {
      channel.sink.add(json);
    }
  }

  @override
  Future<void> disconnect() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      _connectedPlayers.clear();
    }

    if (_clientChannel != null) {
      await _clientChannel!.sink.close();
      _clientChannel = null;
    }
    await _clientSubscription?.cancel();
    _clientSubscription = null;
  }
}
