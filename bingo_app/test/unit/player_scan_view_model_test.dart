import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_scan_view_model.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

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
  late PlayerScanViewModel vm;

  setUp(() {
    connection = FakeGameConnection(
      initialState: GameConnectionState.disconnected,
    );
    vm = PlayerScanViewModel(
      gameConnection: connection,
      joinTimeout: const Duration(milliseconds: 100),
    );
  });

  tearDown(() async {
    vm.dispose();
    await connection.dispose();
  });

  group('PlayerScanViewModel', () {
    test('código inválido não conecta', () async {
      final result = await vm.onQrCodeScanned('nada a ver');
      expect(result, isNull);
      expect(vm.error, PlayerScanError.invalidCode);
      expect(connection.joinedUris, isEmpty);
      expect(vm.isLoading, isFalse);
    });

    test('convite v1 legado é inválido', () async {
      final result = await vm.onQrCodeScanned(
        'bingo://join?data=eyJ2IjoxLCJ0Ijoid2lmaSIsImgiOiIxMC4wLjAuMSIsInAiOjgwODAsInMiOiJzZWdyZWRvIn0=',
      );
      expect(result, isNull);
      expect(vm.error, PlayerScanError.invalidCode);
    });

    test('deep link válido conecta na URI do convite e devolve o JOINED',
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
      expect(connection.joinedUris.single, invite.webSocketUri);
      expect(vm.error, isNull);
      expect(vm.invite?.roomName, 'Festa');

      final args = PlayerGameArgs.fromJoined(joined, playerName: 'Ana');
      expect(args.cardId, 4321);
      expect(args.playerId, 'p-1');
      expect(args.initialDrawnNumbers, [9]);
      expect(args.roomName, 'Festa');
    });

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
  });
}
