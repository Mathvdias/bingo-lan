import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEvent', () {
    test('NumberDrawnEvent roundtrip', () {
      final e = NumberDrawnEvent(number: 42);
      final decoded = GameEvent.fromJson(e.toJson()) as NumberDrawnEvent;
      expect(decoded.number, 42);
    });

    test('GameOverEvent roundtrip', () {
      final e = GameOverEvent(winnerName: 'Ana');
      final decoded = GameEvent.fromJson(e.toJson()) as GameOverEvent;
      expect(decoded.winnerName, 'Ana');
    });

    test('RejectClaimEvent roundtrip', () {
      final e = RejectClaimEvent(playerName: 'Bob');
      final decoded = GameEvent.fromJson(e.toJson()) as RejectClaimEvent;
      expect(decoded.playerName, 'Bob');
    });

    test('tipo desconhecido lança', () {
      expect(
        () => GameEvent.fromJson({'type': 'UNKNOWN'}),
        throwsException,
      );
    });
  });
}
