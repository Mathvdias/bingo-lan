import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEvent', () {
    test('toda mensagem leva a versão do protocolo', () {
      expect(NumberDrawnEvent(number: 1).toJson()['v'], 1);
      expect(GameOverEvent(winnerName: 'A').toJson()['v'], 1);
      expect(RejectClaimEvent(playerName: 'A').toJson()['v'], 1);
      expect(RoomClosedEvent().toJson()['v'], 1);
      expect(StateSyncEvent(drawnNumbers: const []).toJson()['v'], 1);
      expect(ShoutBingoEvent().toJson()['v'], 1);
      expect(PlayerNameEvent(name: 'A').toJson()['v'], 1);
    });

    test('NumberDrawnEvent roundtrip', () {
      final e = NumberDrawnEvent(number: 42);
      final decoded = GameEvent.fromJson(e.toJson()) as NumberDrawnEvent;
      expect(decoded.number, 42);
    });

    test('GameOverEvent roundtrip', () {
      final e = GameOverEvent(winnerName: 'Ana', winnerId: 'p-1');
      final decoded = GameEvent.fromJson(e.toJson()) as GameOverEvent;
      expect(decoded.winnerName, 'Ana');
      expect(decoded.winnerId, 'p-1');
    });

    test('RejectClaimEvent roundtrip', () {
      final e = RejectClaimEvent(playerName: 'Bob', playerId: 'p-2');
      final decoded = GameEvent.fromJson(e.toJson()) as RejectClaimEvent;
      expect(decoded.playerName, 'Bob');
      expect(decoded.playerId, 'p-2');
    });

    test('JoinedEvent roundtrip', () {
      final e = JoinedEvent(
        playerId: 'uuid-1',
        cardId: 123456,
        drawnNumbers: const [3, 17, 61],
        roomName: 'Sala',
      );
      final decoded = GameEvent.fromJson(e.toJson()) as JoinedEvent;
      expect(decoded.playerId, 'uuid-1');
      expect(decoded.cardId, 123456);
      expect(decoded.drawnNumbers, [3, 17, 61]);
      expect(decoded.roomName, 'Sala');
    });

    test('StateSyncEvent roundtrip (broadcast e direcionado)', () {
      final broadcast = GameEvent.fromJson(
            StateSyncEvent(drawnNumbers: const []).toJson(),
          )
          as StateSyncEvent;
      expect(broadcast.drawnNumbers, isEmpty);
      expect(broadcast.playerId, isNull);

      final targeted = GameEvent.fromJson(
            StateSyncEvent(
              drawnNumbers: const [1, 2],
              playerId: 'p',
              cardId: 9,
              roomName: 'R',
            ).toJson(),
          )
          as StateSyncEvent;
      expect(targeted.drawnNumbers, [1, 2]);
      expect(targeted.playerId, 'p');
      expect(targeted.cardId, 9);
      expect(targeted.roomName, 'R');
    });

    test('RoomClosedEvent roundtrip', () {
      expect(
        GameEvent.fromJson(RoomClosedEvent().toJson()),
        isA<RoomClosedEvent>(),
      );
    });

    test('tipo desconhecido lança UnknownEventException', () {
      expect(
        () => GameEvent.fromJson({'type': 'UNKNOWN'}),
        throwsA(isA<UnknownEventException>()),
      );
      expect(
        () => PlayerEvent.fromJson({'type': 'UNKNOWN'}),
        throwsA(isA<UnknownEventException>()),
      );
    });
  });

  group('PlayerEvent', () {
    test('ShoutBingoEvent sem identidade e withIdentity', () {
      final raw = PlayerEvent.fromJson(ShoutBingoEvent().toJson())
          as ShoutBingoEvent;
      expect(raw.playerId, isNull);
      expect(raw.cardId, isNull);

      final stamped = raw.withIdentity(
        playerId: 'p-1',
        cardId: 42,
        playerName: 'Ana',
      );
      expect(stamped.playerId, 'p-1');
      expect(stamped.cardId, 42);
      expect(stamped.playerName, 'Ana');
    });

    test('PlayerNameEvent roundtrip', () {
      final decoded = PlayerEvent.fromJson(
            PlayerNameEvent(name: 'Lucca').toJson(),
          )
          as PlayerNameEvent;
      expect(decoded.name, 'Lucca');
    });
  });

  group('BingoCard letras', () {
    test('columnLetter segue B-I-N-G-O', () {
      expect(BingoCard.columnLetter(1), 'B');
      expect(BingoCard.columnLetter(15), 'B');
      expect(BingoCard.columnLetter(16), 'I');
      expect(BingoCard.columnLetter(30), 'I');
      expect(BingoCard.columnLetter(31), 'N');
      expect(BingoCard.columnLetter(45), 'N');
      expect(BingoCard.columnLetter(46), 'G');
      expect(BingoCard.columnLetter(60), 'G');
      expect(BingoCard.columnLetter(61), 'O');
      expect(BingoCard.columnLetter(75), 'O');
      expect(BingoCard.columnLetter(0), '');
      expect(BingoCard.columnLetter(76), '');
    });

    test('label formata letra-número', () {
      expect(BingoCard.label(12), 'B-12');
      expect(BingoCard.label(75), 'O-75');
    });
  });
}
