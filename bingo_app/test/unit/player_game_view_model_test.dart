import 'package:bingo_app/features/player/player_game_args.dart';
import 'package:bingo_app/features/player/player_game_view_model.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_game_connection.dart';

void main() {
  const args = PlayerGameArgs(
    cardId: 123,
    playerName: 'Ana',
    playerId: 'me',
    roomName: 'Sala',
    initialDrawnNumbers: [5, 17],
  );

  late FakeGameConnection connection;
  late DateTime now;
  late PlayerGameViewModel vm;

  setUp(() {
    connection = FakeGameConnection();
    now = DateTime(2026, 1, 1, 12);
    vm = PlayerGameViewModel(
      args: args,
      gameConnection: connection,
      clock: () => now,
    );
  });

  tearDown(() async {
    vm.dispose();
    await connection.dispose();
  });

  group('PlayerGameViewModel', () {
    test('começa com os números do JOINED e a cartela do id atribuído', () {
      expect(vm.cardId, 123);
      expect(vm.bingoCard.matrix, BingoCard(id: 123).matrix);
      expect(vm.drawnNumbers, [5, 17]);
      expect(vm.lastNumber, 17);
      expect(vm.calledNumbers, {5, 17});
      expect(vm.phase, PlayerGamePhase.playing);
      expect(vm.isConnected, isTrue);
      expect(vm.canShout, isTrue);
    });

    test('announceName envia PLAYER_NAME', () async {
      await vm.announceName();
      expect(connection.sent.single, isA<PlayerNameEvent>());
      expect((connection.sent.single as PlayerNameEvent).name, 'Ana');
    });

    test('NUMBER_DRAWN acumula, atualiza lastNumber e ignora repetidos',
        () async {
      var notifications = 0;
      vm.addListener(() => notifications++);

      connection.emit(NumberDrawnEvent(number: 42));
      connection.emit(NumberDrawnEvent(number: 42));
      await pumpEventQueue();

      expect(vm.drawnNumbers, [5, 17, 42]);
      expect(vm.lastNumber, 42);
      expect(vm.calledNumbers, contains(42));
      expect(notifications, 2);
    });

    test('markNumber alterna só números da cartela', () {
      final number = vm.bingoCard.matrix.firstWhere((n) => n != 0);
      vm.markNumber(number);
      expect(vm.markedNumbers, {number});
      vm.markNumber(number);
      expect(vm.markedNumbers, isEmpty);
      vm.markNumber(0);
      expect(vm.markedNumbers, isEmpty);
    });

    test('GAME_OVER comigo como vencedor', () async {
      connection.emit(GameOverEvent(winnerName: 'Ana', winnerId: 'me'));
      await pumpEventQueue();

      expect(vm.phase, PlayerGamePhase.over);
      expect(vm.isGameOver, isTrue);
      expect(vm.isWinner, isTrue);
      expect(vm.winnerName, 'Ana');
      expect(vm.canShout, isFalse);

      // Marcar e gritar ficam bloqueados.
      final number = vm.bingoCard.matrix.firstWhere((n) => n != 0);
      vm.markNumber(number);
      expect(vm.markedNumbers, isEmpty);
      expect(await vm.shoutBingo(), isFalse);
      expect(connection.sent, isEmpty);
    });

    test('GAME_OVER de outro jogador (por id, mesmo com nome igual)', () async {
      connection.emit(GameOverEvent(winnerName: 'Ana', winnerId: 'other'));
      await pumpEventQueue();
      expect(vm.isGameOver, isTrue);
      expect(vm.isWinner, isFalse);
      expect(vm.winnerName, 'Ana');
    });

    test('GAME_OVER sem winner_id cai no nome', () async {
      connection.emit(GameOverEvent(winnerName: 'Ana'));
      await pumpEventQueue();
      expect(vm.isWinner, isTrue);
    });

    test('STATE_SYNC vazio depois do fim começa nova rodada', () async {
      final number = vm.bingoCard.matrix.firstWhere((n) => n != 0);
      vm.markNumber(number);
      connection.emit(GameOverEvent(winnerName: 'Bob', winnerId: 'other'));
      await pumpEventQueue();
      expect(vm.isGameOver, isTrue);

      connection.emit(StateSyncEvent(drawnNumbers: const []));
      await pumpEventQueue();

      expect(vm.phase, PlayerGamePhase.playing);
      expect(vm.winnerName, isNull);
      expect(vm.isWinner, isFalse);
      expect(vm.drawnNumbers, isEmpty);
      expect(vm.lastNumber, isNull);
      expect(vm.markedNumbers, isEmpty);
      expect(vm.canShout, isTrue);
    });

    test('STATE_SYNC na reconexão substitui os sorteados', () async {
      connection.emit(
        StateSyncEvent(drawnNumbers: const [1, 2, 3], playerId: 'me'),
      );
      await pumpEventQueue();
      expect(vm.drawnNumbers, [1, 2, 3]);
      expect(vm.lastNumber, 3);
      expect(vm.phase, PlayerGamePhase.playing);
    });

    test('REJECT_CLAIM só para mim vira ação', () async {
      final actions = <PlayerGameAction>[];
      vm.actionStream.listen(actions.add);

      connection.emit(RejectClaimEvent(playerName: 'Bob', playerId: 'other'));
      connection.emit(RejectClaimEvent(playerName: 'Ana', playerId: 'me'));
      connection.emit(RejectClaimEvent(playerName: 'Ana'));
      await pumpEventQueue();

      expect(actions.length, 2);
      expect(actions.every((a) => a is ClaimRejected), isTrue);
    });

    test('ROOM_CLOSED bloqueia a tela', () async {
      connection.emit(RoomClosedEvent());
      connection.setState(GameConnectionState.roomClosed);
      await pumpEventQueue();

      expect(vm.roomClosed, isTrue);
      expect(vm.connectionState, GameConnectionState.roomClosed);
      expect(vm.canShout, isFalse);
    });

    test('shoutBingo envia sem identidade e respeita o cooldown de 5 s',
        () async {
      expect(await vm.shoutBingo(), isTrue);
      final shout = connection.sent.single as ShoutBingoEvent;
      expect(shout.playerId, isNull);
      expect(shout.cardId, isNull);

      expect(vm.isShoutOnCooldown, isTrue);
      expect(vm.shoutCooldownRemaining, const Duration(seconds: 5));
      expect(await vm.shoutBingo(), isFalse);
      expect(connection.sent.length, 1);

      now = now.add(const Duration(seconds: 4, milliseconds: 999));
      expect(vm.canShout, isFalse);

      now = now.add(const Duration(milliseconds: 1));
      expect(vm.isShoutOnCooldown, isFalse);
      expect(vm.canShout, isTrue);
      expect(await vm.shoutBingo(), isTrue);
      expect(connection.sent.length, 2);
    });

    test('estado da conexão bloqueia o grito e retry chama reconnect',
        () async {
      connection.setState(GameConnectionState.reconnecting);
      await pumpEventQueue();
      expect(vm.isConnected, isFalse);
      expect(vm.canShout, isFalse);

      connection.setState(GameConnectionState.disconnected);
      await pumpEventQueue();
      await vm.retryConnection();
      expect(connection.reconnectCalls, 1);
      await pumpEventQueue();
      expect(vm.isConnected, isTrue);
    });

    test('leaveRoom desconecta', () async {
      await vm.leaveRoom();
      expect(connection.disconnectCalls, 1);
    });

    test('dispose cancela assinaturas e derruba a conexão ativa', () async {
      final local = FakeGameConnection();
      final localVm = PlayerGameViewModel(args: args, gameConnection: local);
      expect(local.hasEventListeners, isTrue);
      expect(local.hasStateListeners, isTrue);

      localVm.dispose();
      await pumpEventQueue();

      expect(local.hasEventListeners, isFalse);
      expect(local.hasStateListeners, isFalse);
      expect(local.disconnectCalls, 1);
      await local.dispose();
    });
  });
}
