import 'package:bingo_core/bingo_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanSubnet.sameSubnet', () {
    test('mesma /24 sem máscara informada', () {
      expect(LanSubnet.sameSubnet('192.168.0.7', '192.168.0.200'), isTrue);
    });

    test('/24 diferente sem máscara informada', () {
      expect(LanSubnet.sameSubnet('192.168.0.7', '192.168.1.7'), isFalse);
      expect(LanSubnet.sameSubnet('192.168.0.7', '10.0.0.7'), isFalse);
    });

    test('respeita a máscara do sistema', () {
      expect(
        LanSubnet.sameSubnet('192.168.0.7', '192.168.1.7', mask: '255.255.0.0'),
        isTrue,
      );
      expect(
        LanSubnet.sameSubnet(
          '192.168.0.7',
          '192.168.0.200',
          mask: '255.255.255.128',
        ),
        isFalse,
      );
    });

    test('máscara inválida cai no /24 padrão', () {
      expect(
        LanSubnet.sameSubnet('192.168.0.7', '192.168.0.9', mask: 'lixo'),
        isTrue,
      );
    });

    test('IP inválido ou nulo devolve null', () {
      expect(LanSubnet.sameSubnet(null, '192.168.0.1'), isNull);
      expect(LanSubnet.sameSubnet('192.168.0', '192.168.0.1'), isNull);
      expect(LanSubnet.sameSubnet('192.168.0.256', '192.168.0.1'), isNull);
      expect(LanSubnet.sameSubnet('fe80::1', '192.168.0.1'), isNull);
    });
  });
}
