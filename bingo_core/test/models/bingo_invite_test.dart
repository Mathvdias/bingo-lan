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
    );

    test('toJson usa o contrato v2 com chave token', () {
      final map = invite.toJson();
      expect(map, {
        'v': 2,
        't': 'wifi',
        'h': '192.168.0.10',
        'p': 4242,
        'token': 'jwt-token',
        'n': 'Sala teste',
      });
    });

    test('toJson / fromJson preservam dados', () {
      final copy = BingoInvite.fromJson(invite.toJson());
      expect(copy.ip, invite.ip);
      expect(copy.port, invite.port);
      expect(copy.token, invite.token);
      expect(copy.roomName, invite.roomName);
      expect(copy.version, 2);
      expect(copy.type, 'wifi');
    });

    test('parse aceita o base64 puro', () {
      final parsed = BingoInvite.parse(invite.toBase64());
      expect(parsed, isNotNull);
      expect(parsed!.roomName, invite.roomName);
      expect(parsed.token, invite.token);
    });

    test('toDeepLink e parse fecham o ciclo com bingo://join?data=', () {
      final link = invite.toDeepLink();
      expect(link.startsWith('bingo://join?data='), isTrue);
      final parsed = BingoInvite.parse(link);
      expect(parsed, isNotNull);
      expect(parsed!.ip, invite.ip);
      expect(parsed.port, invite.port);
      expect(parsed.token, invite.token);
      expect(parsed.roomName, invite.roomName);
    });

    test('parse aceita link http com o parâmetro data', () {
      final parsed = BingoInvite.parse(
        'https://example.com/join?data=${invite.toBase64()}',
      );
      expect(parsed?.roomName, invite.roomName);
    });

    test('parse tolera espaços em volta', () {
      expect(BingoInvite.parse('  ${invite.toDeepLink()}\n'), isNotNull);
    });

    test('webSocketUri inclui host, porta e token', () {
      expect(invite.webSocketUri, 'ws://192.168.0.10:4242/?token=jwt-token');
    });

    test('parse inválido retorna null', () {
      expect(BingoInvite.parse('não-base64'), isNull);
      expect(BingoInvite.parse('bingo://join'), isNull);
      expect(BingoInvite.parse(''), isNull);
    });

    test('parse rejeita o formato legado v1 (chave s)', () {
      final legacy = base64Encode(
        utf8.encode(
          jsonEncode({
            'v': 1,
            't': 'wifi',
            'h': '10.0.0.1',
            'p': 8080,
            's': 'segredo',
            'n': 'Antiga',
          }),
        ),
      );
      expect(BingoInvite.parse(legacy), isNull);
    });

    test('parse rejeita v2 sem token', () {
      final broken = base64Encode(
        utf8.encode(jsonEncode({'v': 2, 'h': '10.0.0.1', 'p': 8080})),
      );
      expect(BingoInvite.parse(broken), isNull);
    });
  });
}
