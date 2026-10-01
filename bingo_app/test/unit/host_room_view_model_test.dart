import 'dart:math';

import 'package:bingo_app/features/host/host_room_view_model.dart';
import 'package:bingo_app/shared/services/subscription_service.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_game_connection.dart';

class _Config implements IConfigDriver {
  @override
  Future<void> fetchAndActivate() async {}

  @override
  bool getBool(String key) => false;

  @override
  int getInt(String key) => 0;

  @override
  String getString(String key) => '';
}

class _Payment implements IPaymentDriver {
  @override
  Future<bool> get isProUser async => false;

  @override
  Future<void> init() async {}

  @override
  Future<void> purchasePro() async {}

  @override
  Future<void> restorePurchases() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeGameConnection connection;
  late HostRoomViewModel vm;
  late List<HostRoomAction> actions;

  /// Números da primeira linha da cartela [cardId]: sorteá-los dá bingo.
  List<int> winningRow(int cardId) =>
      BingoCard(id: cardId).matrix.sublist(0, 5);

  setUp(() {
    connection = FakeGameConnection();
    final config = _Config();
    vm = HostRoomViewModel(
      gameConnection: connection,
      accessControlService: AccessControlService(
        config: config,
        payment: _Payment(),
      ),
      configDriver: config,
      random: Random(1),
    );
    actions = [];
    vm.actionStream.listen(actions.add);
  });

  tearDown(() async {
    vm.dispose();
    await connection.dispose();
  });

  group('HostRoomViewModel fases', () {
    test('começa em waiting e pode sortear', () {
      expect(vm.phase, GamePhase.waiting);
      expect(vm.canDraw, isTrue);
      expect(vm.isGameOver, isFalse);
      expect(vm.drawnNumbers, isEmpty);
      expect(vm.lastNumber, isNull);
    });

    test('primeiro sorteio passa a playing, transmite e anuncia', () async {
      await vm.drawManualNumber(12);
      await pumpEventQueue();

      expect(vm.phase, GamePhase.playing);
      expect(vm.lastNumber, 12);
      expect(vm.drawnNumbers, [12]);
      expect(connection.broadcasts.single, isA<NumberDrawnEvent>());
      expect((connection.broadcasts.single as NumberDrawnEvent).number, 12);

      final announce = actions.whereType<AnnounceNumber>().single;
      expect(announce.number, 12);
      expect(announce.phrase, isNotEmpty);
      expect(actions.whereType<ShowError>(), isEmpty);
    });

    test('número inválido ou repetido vira ShowError tipado', () async {
      await vm.drawManualNumber(0);
      await vm.drawManualNumber(76);
      await vm.drawManualNumber(7);
      await vm.drawManualNumber(7);
      await pumpEventQueue();

      final errors = actions.whereType<ShowError>().map((e) => e.error);
      expect(errors, [
        HostRoomError.invalidNumber,
        HostRoomError.invalidNumber,
        HostRoomError.alreadyDrawn,
      ]);
      expect(vm.drawnNumbers, [7]);
    });

    test(
      'drawRandomNumber nunca repete e histórico fica newest-first',
      () async {
        await vm.drawRandomNumber();
        await vm.drawRandomNumber();
        await vm.drawRandomNumber();
        expect(vm.drawnNumbers.toSet().length, 3);
        expect(vm.drawnNumbersNewestFirst, vm.drawnNumbers.reversed.toList());
      },
    );

    test(
      'SHOUT_BINGO só entra com identidade do servidor e sem duplicar',
      () async {
        connection.emit(ShoutBingoEvent(playerName: 'Sem id'));
        connection.emit(
          ShoutBingoEvent(playerId: 'p-1', cardId: 99, playerName: 'Ana'),
        );
        connection.emit(
          ShoutBingoEvent(playerId: 'p-1', cardId: 99, playerName: 'Ana'),
        );
        await pumpEventQueue();

        expect(vm.bingoClaims.length, 1);
        expect(vm.bingoClaims.single.playerId, 'p-1');
        expect(vm.bingoClaims.single.cardId, 99);
      },
    );

    test(
      'claim válido encerra a rodada com GAME_OVER e bloqueia o sorteio',
      () async {
        const cardId = 77;
        for (final n in winningRow(cardId)) {
          await vm.drawManualNumber(n);
        }
        connection.broadcasts.clear();

        connection.emit(
          ShoutBingoEvent(playerId: 'p-1', cardId: cardId, playerName: 'Ana'),
        );
        await pumpEventQueue();
        await vm.validateClaim(vm.bingoClaims.single);

        expect(vm.phase, GamePhase.over);
        expect(vm.isGameOver, isTrue);
        expect(vm.canDraw, isFalse);
        expect(vm.winnerName, 'Ana');
        expect(vm.winnerId, 'p-1');
        expect(vm.bingoClaims, isEmpty);

        final over = connection.broadcasts.single as GameOverEvent;
        expect(over.winnerName, 'Ana');
        expect(over.winnerId, 'p-1');

        // Depois do fim: sortear e novas reivindicações são ignorados.
        connection.broadcasts.clear();
        await vm.drawManualNumber(1);
        await vm.drawRandomNumber();
        connection.emit(
          ShoutBingoEvent(playerId: 'p-2', cardId: 5, playerName: 'Bob'),
        );
        await pumpEventQueue();
        expect(connection.broadcasts, isEmpty);
        expect(vm.bingoClaims, isEmpty);
        expect(vm.drawnNumbers.length, 5);
      },
    );

    test(
      'claim falso é rejeitado para o jogador certo e o jogo segue',
      () async {
        await vm.drawManualNumber(1);
        connection.broadcasts.clear();

        connection.emit(
          ShoutBingoEvent(playerId: 'p-9', cardId: 4242, playerName: 'Bob'),
        );
        await pumpEventQueue();
        await vm.validateClaim(vm.bingoClaims.single);

        expect(vm.phase, GamePhase.playing);
        expect(vm.bingoClaims, isEmpty);
        final reject = connection.broadcasts.single as RejectClaimEvent;
        expect(reject.playerName, 'Bob');
        expect(reject.playerId, 'p-9');
      },
    );

    test('newRound volta a waiting e transmite STATE_SYNC vazio', () async {
      const cardId = 3;
      for (final n in winningRow(cardId)) {
        await vm.drawManualNumber(n);
      }
      connection.emit(
        ShoutBingoEvent(playerId: 'p-1', cardId: cardId, playerName: 'Ana'),
      );
      await pumpEventQueue();
      await vm.validateClaim(vm.bingoClaims.single);
      expect(vm.isGameOver, isTrue);
      connection.broadcasts.clear();

      await vm.newRound();

      expect(vm.phase, GamePhase.waiting);
      expect(vm.canDraw, isTrue);
      expect(vm.drawnNumbers, isEmpty);
      expect(vm.lastNumber, isNull);
      expect(vm.winnerName, isNull);
      expect(vm.winnerId, isNull);
      final sync = connection.broadcasts.single as StateSyncEvent;
      expect(sync.drawnNumbers, isEmpty);

      // Os números voltam a estar disponíveis.
      await vm.drawManualNumber(winningRow(cardId).first);
      expect(vm.drawnNumbers.length, 1);
      expect(vm.phase, GamePhase.playing);
    });

    test(
      'undoLastDraw tira a última bola, devolve ao globo e sincroniza',
      () async {
        await vm.drawManualNumber(12);
        await vm.drawManualNumber(33);
        connection.broadcasts.clear();
        expect(vm.canUndo, isTrue);

        await vm.undoLastDraw();
        await pumpEventQueue();

        expect(vm.drawnNumbers, [12]);
        expect(vm.lastNumber, 12);
        expect(vm.phase, GamePhase.playing);
        final sync = connection.broadcasts.single as StateSyncEvent;
        expect(sync.drawnNumbers, [12]);
        expect(actions.whereType<AnnounceUndo>().single.number, 33);

        // O número volta a poder ser sorteado.
        await vm.drawManualNumber(33);
        expect(vm.drawnNumbers, [12, 33]);
        expect(actions.whereType<ShowError>(), isEmpty);
      },
    );

    test(
      'undoLastDraw da única bola volta a waiting; sem bolas é ignorado',
      () async {
        expect(vm.canUndo, isFalse);
        await vm.undoLastDraw();
        expect(connection.broadcasts, isEmpty);

        await vm.drawManualNumber(7);
        await vm.undoLastDraw();

        expect(vm.drawnNumbers, isEmpty);
        expect(vm.lastNumber, isNull);
        expect(vm.phase, GamePhase.waiting);
        expect(vm.canUndo, isFalse);
      },
    );

    test('undoLastDraw é bloqueado depois do bingo', () async {
      const cardId = 77;
      for (final n in winningRow(cardId)) {
        await vm.drawManualNumber(n);
      }
      connection.emit(
        ShoutBingoEvent(playerId: 'p-1', cardId: cardId, playerName: 'Ana'),
      );
      await pumpEventQueue();
      await vm.validateClaim(vm.bingoClaims.single);
      connection.broadcasts.clear();

      expect(vm.canUndo, isFalse);
      await vm.undoLastDraw();
      expect(vm.drawnNumbers.length, 5);
      expect(connection.broadcasts, isEmpty);
    });

    test('pausar e retomar o globo automático', () {
      fakeAsync((async) {
        final local = FakeGameConnection();
        final config = _Config();
        final localVm = HostRoomViewModel(
          gameConnection: local,
          accessControlService: AccessControlService(
            config: config,
            payment: _Payment(),
          ),
          configDriver: config,
          random: Random(3),
        );
        SubscriptionService.isPremium.value = true;
        addTearDown(() => SubscriptionService.isPremium.value = false);

        localVm.toggleAutoPlay();
        async.flushMicrotasks();
        expect(localVm.isAutoPlaying, isTrue);
        expect(localVm.isAutoRunning, isTrue);
        expect(localVm.canUndo, isFalse);

        async.elapse(HostRoomViewModel.autoPlayInterval * 2);
        expect(localVm.drawnNumbers.length, 2);

        localVm.pauseAutoPlay();
        expect(localVm.isAutoPlaying, isTrue);
        expect(localVm.isAutoPaused, isTrue);
        expect(localVm.isAutoRunning, isFalse);
        expect(localVm.canUndo, isTrue);

        // Pausado: o tempo passa e nada é sorteado.
        async.elapse(HostRoomViewModel.autoPlayInterval * 3);
        expect(localVm.drawnNumbers.length, 2);

        localVm.resumeAutoPlay();
        expect(localVm.isAutoRunning, isTrue);
        async.elapse(HostRoomViewModel.autoPlayInterval);
        expect(localVm.drawnNumbers.length, 3);

        // Desligar limpa a pausa.
        localVm.toggleAutoPlay();
        async.flushMicrotasks();
        expect(localVm.isAutoPlaying, isFalse);
        expect(localVm.isAutoPaused, isFalse);

        localVm.dispose();
      });
    });

    test('errorStream vira paywall ou erro de conexão', () async {
      connection.emitError('PAYWALL_TRIGGERED');
      connection.emitError('whatever');
      await pumpEventQueue();

      expect(actions.whereType<ShowPaywall>().single.source, 'room_capacity');
      expect(
        actions.whereType<ShowError>().single.error,
        HostRoomError.connection,
      );
    });

    test('jogador que entrou antes da sala abrir já conta', () async {
      // O stream não repete o valor atual: o VM parte de connectedPlayers.
      final local = FakeGameConnection(connectedPlayers: const ['Ana']);
      final config = _Config();
      final localVm = HostRoomViewModel(
        gameConnection: local,
        accessControlService: AccessControlService(
          config: config,
          payment: _Payment(),
        ),
        configDriver: config,
      );
      // LIFO: o VM (que chama disconnect) sai antes da conexão fechar.
      addTearDown(local.dispose);
      addTearDown(localVm.dispose);

      expect(localVm.players, ['Ana']);
      expect(localVm.playerCount, 1);

      // E continua acompanhando as mudanças.
      local.emitPlayers(const ['Ana', 'Bob']);
      await pumpEventQueue();
      expect(localVm.players.length, 2);
    });

    test('lista de jogadores acompanha a conexão', () async {
      connection.emitPlayers(['Ana', 'Bob']);
      await pumpEventQueue();
      expect(vm.players, ['Ana', 'Bob']);
      expect(vm.playerCount, 2);
    });

    test('stopGame e dispose derrubam a sala e cancelam assinaturas', () async {
      final local = FakeGameConnection();
      final config = _Config();
      final localVm = HostRoomViewModel(
        gameConnection: local,
        accessControlService: AccessControlService(
          config: config,
          payment: _Payment(),
        ),
        configDriver: config,
      );
      expect(local.hasEventListeners, isTrue);
      expect(local.hasPlayerListeners, isTrue);
      expect(local.hasErrorListeners, isTrue);

      await localVm.stopGame();
      expect(local.disconnectCalls, 1);

      localVm.dispose();
      await pumpEventQueue();
      expect(local.hasEventListeners, isFalse);
      expect(local.hasPlayerListeners, isFalse);
      expect(local.hasErrorListeners, isFalse);
      expect(local.disconnectCalls, 2);
      await local.dispose();
    });
  });
}
