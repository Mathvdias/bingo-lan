import 'dart:convert';

import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BingoInvite', () {
    const invite = BingoInvite(
      ip: '192.168.0.10',
      port: 4242,
      token: 'jwt-token',
      roomName: 'Sala teste',
      version: 2,
      type: 'bingo',
    );

    test('toJson / fromJson preservam dados', () {
      final map = <String, dynamic>{
        'h': invite.ip,
        'p': invite.port,
        's': invite.token,
        'n': invite.roomName,
        'v': invite.version,
        't': invite.type,
      };
      final copy = BingoInvite.fromJson(map);
      expect(copy.ip, invite.ip);
      expect(copy.port, invite.port);
      expect(copy.token, invite.token);
      expect(copy.roomName, invite.roomName);
      expect(copy.version, invite.version);
      expect(copy.type, invite.type);
    });

    test('parse base64 payload', () {
      final jsonStr = jsonEncode({
        'h': invite.ip,
        'p': invite.port,
        's': invite.token,
        'n': invite.roomName,
        'v': invite.version,
        't': invite.type,
      });
      final b64 = base64Encode(utf8.encode(jsonStr));
      final parsed = BingoInvite.parse(b64);
      expect(parsed, isNotNull);
      expect(parsed!.roomName, invite.roomName);
    });

    test('toDeepLink e parse fecham o ciclo', () {
      final link = invite.toDeepLink();
      expect(link.startsWith('bingolucca://join?data='), isTrue);
      final parsed = BingoInvite.parse(link);
      expect(parsed, isNotNull);
      expect(parsed!.ip, invite.ip);
      expect(parsed.port, invite.port);
    });

    test('parse inválido retorna null', () {
      expect(BingoInvite.parse('não-base64'), isNull);
    });
  });
}
