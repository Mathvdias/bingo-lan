import 'package:bingo_core/bingo_core.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' show JWT, SecretKey;
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

    test('validateRoomToken confere role quando pedido', () {
      final secret = JwtService.generateSecret();
      final hostToken = JwtService.generateRoomToken(
        roomId: 'abc',
        role: 'host',
        secret: secret,
      );
      expect(
        JwtService.validateRoomToken(
          token: hostToken,
          secret: secret,
          expectedRoomId: 'abc',
          expectedRole: 'player',
        ),
        isFalse,
      );
      final playerToken = JwtService.generateRoomToken(
        roomId: 'abc',
        role: 'player',
        secret: secret,
      );
      expect(
        JwtService.validateRoomToken(
          token: playerToken,
          secret: secret,
          expectedRoomId: 'abc',
          expectedRole: 'player',
        ),
        isTrue,
      );
    });

    test('token de outro emissor é rejeitado', () {
      final secret = JwtService.generateSecret();
      final foreign = JWT(
        {'roomId': 'abc', 'role': 'player'},
        issuer: 'outro_app',
      ).sign(SecretKey(secret));
      expect(
        () => JwtService.validateToken(token: foreign, secret: secret),
        throwsA(isA<JWTInvalidException>()),
      );
      expect(
        JwtService.validateRoomToken(
          token: foreign,
          secret: secret,
          expectedRoomId: 'abc',
        ),
        isFalse,
      );
    });
  });
}
