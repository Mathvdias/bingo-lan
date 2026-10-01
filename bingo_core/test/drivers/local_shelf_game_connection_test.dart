import 'dart:async';

import 'package:bingo_core/bingo_core.dart';
import 'package:bingo_core/src/drivers/local_shelf_game_connection.dart';
import 'package:flutter_test/flutter_test.dart';

class _Config implements IConfigDriver {
  final Map<String, Object> values = {};

  @override
  Future<void> fetchAndActivate() async {}

  @override
  bool getBool(String key) => values[key] as bool? ?? false;

  @override
  int getInt(String key) => values[key] as int? ?? 0;

  @override
  String getString(String key) => values[key] as String? ?? '';
}

class _Payment implements IPaymentDriver {
  bool pro = false;

  @override
  Future<bool> get isProUser async => pro;

  @override
  Future<void> init() async {}

  @override
  Future<void> purchasePro() async {}

  @override
  Future<void> restorePurchases() async {}
}

class _Uuid implements IUUIDDriver {
  int _next = 0;

  @override
  String v4() => 'p-${++_next}';
}

/// Evento com tipo desconhecido para testar o isolamento por mensagem.
class _UnknownPlayerEvent extends PlayerEvent {
  @override
  Map<String, dynamic> toJson() => GameEvent.envelope('NOPE', const {});
}

class _UnknownGameEvent extends GameEvent {
  @override
  Map<String, dynamic> toJson() => GameEvent.envelope('WHAT', const {});
}

const _roomName = 'Sala do Teste';
const _ip = '127.0.0.1';

LocalShelfGameConnection _newConnection(_Uuid uuid, {_Config? config}) {
  final cfg = config ?? _Config();
  return LocalShelfGameConnection(
    accessControl: AccessControlService(config: cfg, payment: _Payment()),
    configDriver: cfg,
    uuidDriver: uuid,
    heartbeatInterval: const Duration(seconds: 1),
    reconnectBaseDelay: const Duration(milliseconds: 40),
    connectTimeout: const Duration(seconds: 2),
  );
}

Future<T> _firstEvent<T extends GameEvent>(IGameConnection c) {
  return c.eventStream
      .firstWhere((e) => e is T)
      .timeout(const Duration(seconds: 5))
      .then((e) => e as T);
}

Future<void> _eventually(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late _Uuid uuid;
  late LocalShelfGameConnection host;
  late String secret;
  late int port;
  late List<String> players;
  late List<IGameConnection> clients;
  StreamSubscription? playersSub;

  String playerToken({String role = 'player', String? withSecret}) {
    return JwtService.generateRoomToken(
      roomId: _roomName,
      role: role,
      secret: withSecret ?? secret,
    );
  }

  String wsUri({String? token}) {
    return BingoInvite(
      ip: _ip,
      port: port,
      token: token ?? playerToken(),
      roomName: _roomName,
    ).webSocketUri;
  }

  Future<(IGameConnection, JoinedEvent)> joinNewClient({String? uri}) async {
    final client = _newConnection(uuid);
    clients.add(client);
    final joined = _firstEvent<JoinedEvent>(client);
    await client.joinRoom(uri ?? wsUri());
    return (client, await joined);
  }

  setUp(() async {
    uuid = _Uuid();
    host = _newConnection(uuid);
    secret = JwtService.generateSecret();
    players = [];
    clients = [];
    playersSub = host.connectedPlayersStream.listen((p) => players = p);
    port = await host.hostRoom(_roomName, secret, _ip, 0);
  });

  tearDown(() async {
    await playersSub?.cancel();
    for (final c in clients) {
      await c.disconnect();
    }
    await host.disconnect();
  });

  group('LocalShelfGameConnection (loopback)', () {
    test('hostRoom na porta 0 devolve uma porta dinâmica', () {
      expect(port, greaterThan(0));
      expect(host.boundPort, port);
    });

    test('connectedPlayers guarda a lista para quem assina depois', () async {
      // Ninguém ouvindo: simula a tela da sala, criada só depois que o
      // jogador entrou pela tela de convite.
      await playersSub?.cancel();
      playersSub = null;
      expect(host.connectedPlayers, isEmpty);

      final (client, _) = await joinNewClient();
      await _eventually(() => host.connectedPlayers.length == 1);
      expect(host.connectedPlayers, ['Player']);

      // Um ouvinte novo parte do valor atual e segue recebendo mudanças.
      final seen = <List<String>>[host.connectedPlayers];
      playersSub = host.connectedPlayersStream.listen(seen.add);
      await client.sendPlayerEvent(PlayerNameEvent(name: 'Ana'));
      await _eventually(() => seen.length == 2);
      expect(seen.first, ['Player']);
      expect(seen.last, ['Ana']);
      expect(host.connectedPlayers, ['Ana']);

      await client.disconnect();
      await _eventually(() => host.connectedPlayers.isEmpty);
    });

    test('token válido recebe JOINED com identidade atribuída pelo host',
        () async {
      final (client, joined) = await joinNewClient();

      expect(joined.playerId, 'p-1');
      expect(joined.cardId, inInclusiveRange(1, 999999));
      expect(joined.drawnNumbers, isEmpty);
      expect(joined.roomName, _roomName);
      expect(client.connectionState, GameConnectionState.connected);
      expect((client as LocalShelfGameConnection).assignedPlayerId, 'p-1');

      await _eventually(() => players.length == 1);
      expect(players, ['Player']);
    });

    test('token inválido é rejeitado antes do upgrade', () async {
      final client = _newConnection(uuid);
      clients.add(client);
      final states = <GameConnectionState>[];
      client.connectionStateStream.listen(states.add);

      await expectLater(
        client.joinRoom(wsUri(token: playerToken(withSecret: 'outro'))),
        throwsA(anything),
      );
      expect(client.connectionState, GameConnectionState.disconnected);
      await _eventually(() => states.length == 2);
      expect(states, [
        GameConnectionState.connecting,
        GameConnectionState.disconnected,
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(players, isEmpty);
    });

    test('token com role host é rejeitado', () async {
      final client = _newConnection(uuid);
      clients.add(client);
      await expectLater(
        client.joinRoom(wsUri(token: playerToken(role: 'host'))),
        throwsA(anything),
      );
    });

    test('sem token é rejeitado', () async {
      final client = _newConnection(uuid);
      clients.add(client);
      await expectLater(
        client.joinRoom('ws://$_ip:$port/'),
        throwsA(anything),
      );
    });

    test('entrante tardio recebe os números já sorteados no JOINED', () async {
      await host.broadcastEvent(NumberDrawnEvent(number: 5));
      await host.broadcastEvent(NumberDrawnEvent(number: 17));

      final (_, joined) = await joinNewClient();
      expect(joined.drawnNumbers, [5, 17]);
    });

    test('PLAYER_NAME é limitado a 24 caracteres e desduplicado', () async {
      final (a, _) = await joinNewClient();
      final (b, _) = await joinNewClient();
      final (c, _) = await joinNewClient();

      await a.sendPlayerEvent(PlayerNameEvent(name: '  Ana  '));
      await b.sendPlayerEvent(PlayerNameEvent(name: 'Ana'));
      await c.sendPlayerEvent(
        PlayerNameEvent(name: 'Um nome realmente comprido demais para caber'),
      );

      await _eventually(
        () =>
            players.length == 3 &&
            players.contains('Ana') &&
            players.contains('Ana (2)') &&
            players.any((n) => n.length == 24),
      );
      expect(players.where((n) => n.startsWith('Player')), isEmpty);
    });

    test('SHOUT_BINGO chega ao host com a identidade da sessão', () async {
      final (client, joined) = await joinNewClient();
      await client.sendPlayerEvent(PlayerNameEvent(name: 'Lucca'));
      await _eventually(() => players.contains('Lucca'));

      final claim = _firstEvent<ShoutBingoEvent>(host);
      // O cliente tenta forjar cartela e nome; o host ignora.
      await client.sendPlayerEvent(
        ShoutBingoEvent(playerId: 'fake', cardId: 1, playerName: 'Hacker'),
      );

      final received = await claim;
      expect(received.playerId, joined.playerId);
      expect(received.cardId, joined.cardId);
      expect(received.playerName, 'Lucca');
    });

    test('broadcast chega a todos e carrega a versão do protocolo', () async {
      final (a, _) = await joinNewClient();
      final (b, _) = await joinNewClient();

      final fa = _firstEvent<NumberDrawnEvent>(a);
      final fb = _firstEvent<NumberDrawnEvent>(b);
      await host.broadcastEvent(NumberDrawnEvent(number: 42));

      expect((await fa).number, 42);
      expect((await fb).number, 42);
      expect(NumberDrawnEvent(number: 42).toJson()['v'], 1);
    });

    test('mensagens de tipo desconhecido são ignoradas sem derrubar', () async {
      final (client, joined) = await joinNewClient();

      // Cliente -> host
      await client.sendPlayerEvent(_UnknownPlayerEvent());
      final claim = _firstEvent<ShoutBingoEvent>(host);
      await client.sendPlayerEvent(ShoutBingoEvent());
      expect((await claim).cardId, joined.cardId);

      // Host -> cliente
      await host.broadcastEvent(_UnknownGameEvent());
      final drawn = _firstEvent<NumberDrawnEvent>(client);
      await host.broadcastEvent(NumberDrawnEvent(number: 7));
      expect((await drawn).number, 7);
      expect(client.connectionState, GameConnectionState.connected);
    });

    test('desconexão do jogador atualiza a lista do host', () async {
      final (a, _) = await joinNewClient();
      final (_, _) = await joinNewClient();
      await _eventually(() => players.length == 2);

      await a.disconnect();
      expect(a.connectionState, GameConnectionState.disconnected);
      await _eventually(() => players.length == 1);
    });

    test('ROOM_CLOSED é entregue quando o host encerra', () async {
      final (client, _) = await joinNewClient();
      final closed = _firstEvent<RoomClosedEvent>(client);
      final states = <GameConnectionState>[];
      client.connectionStateStream.listen(states.add);

      await host.disconnect();

      await closed;
      await _eventually(
        () => client.connectionState == GameConnectionState.roomClosed,
      );
      // Sem tentativa de reconexão depois de ROOM_CLOSED.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(states, isNot(contains(GameConnectionState.reconnecting)));
      expect(client.connectionState, GameConnectionState.roomClosed);
    });

    test('limite de 3 sockets por IP', () async {
      await joinNewClient();
      await joinNewClient();
      await joinNewClient();
      await _eventually(() => players.length == 3);

      final fourth = _newConnection(uuid);
      clients.add(fourth);
      await expectLater(fourth.joinRoom(wsUri()), throwsA(anything));
      expect(players.length, 3);
    });

    test('limite grátis do Remote Config rejeita e avisa PAYWALL_TRIGGERED',
        () async {
      await host.disconnect();
      final cfg = _Config()
        ..values['revenue_model'] = 'paywall_host'
        ..values['max_free_players_path_a'] = 2
        ..values['is_host_premium'] = true;
      host = _newConnection(uuid, config: cfg);
      playersSub?.cancel();
      playersSub = host.connectedPlayersStream.listen((p) => players = p);
      port = await host.hostRoom(_roomName, secret, _ip, 0);
      final errors = <String>[];
      host.errorStream.listen(errors.add);

      await joinNewClient();
      await joinNewClient();
      final third = _newConnection(uuid);
      clients.add(third);
      await expectLater(third.joinRoom(wsUri()), throwsA(anything));
      expect(errors, ['PAYWALL_TRIGGERED']);
    });

    test('hostRoom de novo não lança e reinicia o servidor', () async {
      final again = await host.hostRoom(_roomName, secret, _ip, 0);
      expect(again, greaterThan(0));
      expect(host.boundPort, again);
    });

    test('porta ocupada cai para a próxima da faixa', () async {
      final other = _newConnection(uuid);
      final otherPort = await other.hostRoom('Outra', secret, _ip, port);
      try {
        expect(otherPort, isNot(port));
        expect(
          otherPort,
          inInclusiveRange(
            port + 1,
            port + LocalShelfGameConnection.portRange - 1,
          ),
        );
      } finally {
        await other.disconnect();
      }
    });

    test('queda de rede reconecta com backoff e restaura a identidade',
        () async {
      final (client, joined) = await joinNewClient();
      await client.sendPlayerEvent(PlayerNameEvent(name: 'Zé'));
      await _eventually(() => players.contains('Zé'));
      await host.broadcastEvent(NumberDrawnEvent(number: 33));

      final states = <GameConnectionState>[];
      client.connectionStateStream.listen(states.add);
      final sync = _firstEvent<StateSyncEvent>(client);

      await host.debugDropPlayer(joined.playerId);

      final restored = await sync;
      expect(restored.playerId, joined.playerId);
      expect(restored.cardId, joined.cardId);
      expect(restored.drawnNumbers, [33]);
      expect(restored.roomName, _roomName);

      await _eventually(
        () => client.connectionState == GameConnectionState.connected,
      );
      expect(
        states,
        containsAllInOrder([
          GameConnectionState.reconnecting,
          GameConnectionState.connected,
        ]),
      );
      // Mesma sessão: nome preservado, nenhum uuid novo foi gasto.
      await _eventually(() => players.length == 1 && players.first == 'Zé');
      expect((client as LocalShelfGameConnection).assignedPlayerId, 'p-1');
    });

    test('nova rodada via STATE_SYNC zera os sorteados para entrantes',
        () async {
      await host.broadcastEvent(NumberDrawnEvent(number: 9));
      await host.broadcastEvent(StateSyncEvent(drawnNumbers: const []));
      final (_, joined) = await joinNewClient();
      expect(joined.drawnNumbers, isEmpty);
    });
  });
}
