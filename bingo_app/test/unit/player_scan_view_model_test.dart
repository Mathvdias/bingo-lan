import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_drivers.dart';
import 'fake_game_connection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const invite = BingoInvite(
    ip: '192.168.0.7',
    port: 51234,
    token: 'jwt',
    roomName: 'Festa',
  );

  late FakeGameConnection connection;
  late FakeNetworkInfoDriver network;
  late FakeHostReachability reachability;
  late PlayerScanViewModel vm;

  setUp(() {
    connection = FakeGameConnection(
      initialState: GameConnectionState.disconnected,
    );
    network = FakeNetworkInfoDriver(ip: '192.168.0.20');
    reachability = FakeHostReachability();
    vm = PlayerScanViewModel(
      gameConnection: connection,
      networkInfo: network,
      reachability: reachability,
      joinTimeout: const Duration(milliseconds: 100),
    );
  });

  tearDown(() async {
    vm.dispose();
    await connection.dispose();
  });

  group('PlayerScanViewModel', () {
    test('código inválido não conecta nem sonda a rede', () async {
      final result = await vm.onQrCodeScanned('nada a ver');
      expect(result, isNull);
      expect(vm.error, PlayerScanError.invalidCode);
      expect(connection.joinedUris, isEmpty);
      expect(reachability.probes, isEmpty);
      expect(vm.isLoading, isFalse);
    });

    test('convite v1 legado é inválido', () async {
      final result = await vm.onQrCodeScanned(
        'bingo://join?data=eyJ2IjoxLCJ0Ijoid2lmaSIsImgiOiIxMC4wLjAuMSIsInAiOjgwODAsInMiOiJzZWdyZWRvIn0=',
      );
      expect(result, isNull);
      expect(vm.error, PlayerScanError.invalidCode);
    });

    test(
      'deep link válido conecta na URI do convite e devolve o JOINED',
      () async {
        connection.onJoin = () => connection.emit(
          JoinedEvent(
            playerId: 'p-1',
            cardId: 4321,
            drawnNumbers: const [9],
            roomName: 'Festa',
          ),
        );

        final joined = await vm.onQrCodeScanned(invite.toDeepLink());

        expect(joined, isNotNull);
        expect(joined!.cardId, 4321);
        expect(joined.playerId, 'p-1');
        expect(reachability.probes.single, ('192.168.0.7', 51234));
        expect(connection.joinedUris.single, invite.webSocketUri);
        expect(vm.error, isNull);
        expect(vm.invite?.roomName, 'Festa');

        final args = PlayerGameArgs.fromJoined(joined, playerName: 'Ana');
        expect(args.cardId, 4321);
        expect(args.playerId, 'p-1');
        expect(args.initialDrawnNumbers, [9]);
        expect(args.roomName, 'Festa');
      },
    );

    test('base64 puro (código manual) também funciona', () async {
      connection.onJoin = () => connection.emit(
        JoinedEvent(
          playerId: 'p-1',
          cardId: 1,
          drawnNumbers: const [],
          roomName: 'Festa',
        ),
      );
      final joined = await vm.onQrCodeScanned(invite.toBase64());
      expect(joined?.cardId, 1);
    });

    test('host recusa a conexão', () async {
      connection.joinError = Exception('403');
      final result = await vm.onQrCodeScanned(invite.toDeepLink());
      expect(result, isNull);
      expect(vm.error, PlayerScanError.rejected);
    });

    test('sem JOINED a tempo dá timeout e desconecta', () async {
      final result = await vm.onQrCodeScanned(invite.toDeepLink());
      expect(result, isNull);
      expect(vm.error, PlayerScanError.timeout);
      expect(connection.disconnectCalls, 1);
    });

    test('cancelJoin desconecta', () async {
      await vm.cancelJoin();
      expect(connection.disconnectCalls, 1);
    });

    group('diagnóstico de rede quando o host não responde', () {
      setUp(() => reachability.result = HostProbeResult.unreachable);

      test('sem Wi-Fi: notOnWifi e não tenta conectar', () async {
        network.ip = null;
        final result = await vm.onQrCodeScanned(invite.toDeepLink());
        expect(result, isNull);
        expect(vm.error, PlayerScanError.notOnWifi);
        expect(vm.wifiIp, isNull);
        expect(vm.networkChecked, isTrue);
        expect(connection.joinedUris, isEmpty);
      });

      test('erro ao ler o IP conta como sem Wi-Fi', () async {
        network.ipError = Exception('plugin');
        await vm.onQrCodeScanned(invite.toDeepLink());
        expect(vm.error, PlayerScanError.notOnWifi);
      });

      test('outra sub-rede (/24 padrão): differentNetwork', () async {
        network.ip = '10.0.0.5';
        await vm.onQrCodeScanned(invite.toDeepLink());
        expect(vm.error, PlayerScanError.differentNetwork);
        expect(vm.wifiIp, '10.0.0.5');
        expect(vm.invite?.ip, '192.168.0.7');
      });

      test('mesma sub-rede: hostUnreachable (isolamento de clientes)', () async {
        network.ip = '192.168.0.20';
        await vm.onQrCodeScanned(invite.toDeepLink());
        expect(vm.error, PlayerScanError.hostUnreachable);
      });

      test('máscara do sistema prevalece sobre o /24 padrão', () async {
        // 192.168.1.20 e 192.168.0.7 são a mesma rede num /16.
        network.ip = '192.168.1.20';
        network.mask = '255.255.0.0';
        await vm.onQrCodeScanned(invite.toDeepLink());
        expect(vm.error, PlayerScanError.hostUnreachable);
      });

      test('conexão recusada: roomClosed sem olhar a rede', () async {
        reachability.result = HostProbeResult.refused;
        network.ip = null;
        await vm.onQrCodeScanned(invite.toDeepLink());
        expect(vm.error, PlayerScanError.roomClosed);
        expect(network.ipReads, 0);
      });
    });

    test('host alcançável entra mesmo com IP local estranho', () async {
      // Ex.: hotspot em que o plugin não devolve IP: se responde, segue.
      network.ip = null;
      connection.onJoin = () => connection.emit(
        JoinedEvent(
          playerId: 'p-9',
          cardId: 7,
          drawnNumbers: const [],
          roomName: 'Festa',
        ),
      );
      final joined = await vm.onQrCodeScanned(invite.toDeepLink());
      expect(joined?.cardId, 7);
      expect(vm.error, isNull);
    });

    test('refreshNetwork expõe o IP do Wi-Fi para o aviso da tela', () async {
      expect(vm.networkChecked, isFalse);
      await vm.refreshNetwork();
      expect(vm.networkChecked, isTrue);
      expect(vm.wifiIp, '192.168.0.20');

      network.ip = null;
      await vm.refreshNetwork();
      expect(vm.wifiIp, isNull);
    });
  });
}
