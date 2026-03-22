import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtService', () {
    test('generateSecret produz valores distintos', () {
      final a = JwtService.generateSecret();
      final b = JwtService.generateSecret();
      expect(a, isNot(equals(b)));
      expect(a.length, greaterThan(0));
    });

    test('token assinado valida com o mesmo secret', () {
      final secret = JwtService.generateSecret();
      const roomId = 'room-1';
      final token = JwtService.generateRoomToken(
        roomId: roomId,
        role: 'host',
        secret: secret,
      );
      final payload = JwtService.validateToken(token: token, secret: secret);
      expect(payload['roomId'], roomId);
      expect(payload['role'], 'host');
    });

    test('token inválido com secret errado', () {
      final secret = JwtService.generateSecret();
      final token = JwtService.generateRoomToken(
        roomId: 'r',
        role: 'player',
        secret: secret,
      );
      expect(
        () => JwtService.validateToken(token: token, secret: 'outro-secret'),
        throwsA(isA<JWTInvalidException>()),
      );
    });

    test('validateRoomToken confere roomId', () {
      final secret = JwtService.generateSecret();
      final token = JwtService.generateRoomToken(
        roomId: 'abc',
        role: 'player',
        secret: secret,
      );
      expect(
        JwtService.validateRoomToken(
          token: token,
          secret: secret,
          expectedRoomId: 'abc',
        ),
        isTrue,
      );
      expect(
        JwtService.validateRoomToken(
          token: token,
          secret: secret,
          expectedRoomId: 'outro',
        ),
        isFalse,
      );
    });
  });
}
