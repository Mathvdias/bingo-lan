import 'package:bingo_core/src/drivers/network_info_driver.dart';
import 'package:flutter_test/flutter_test.dart';

/// O caso que motivou o fallback: o anfitrião liga o hotspot do celular
/// porque a rede da casa/hotel bloqueia a conversa entre aparelhos, e o
/// `network_info_plus` deixa de devolver IP — ele lê a interface de cliente
/// Wi-Fi, e um aparelho que virou ponto de acesso não é cliente de ninguém.
/// Antes disso, `createRoom()` morria em `HostSetupError.noWifi` e a saída
/// recomendada ao jogador era justamente a que não funcionava.
void main() {
  group('pickLocalIpv4', () {
    test('escolhe o gateway do hotspot Android na frente da LAN', () {
      final ip = NetworkInfoDriver.pickLocalIpv4([
        (interface: 'wlan0', ip: '192.168.0.42'),
        (interface: 'ap0', ip: '192.168.43.1'),
      ]);

      expect(ip, '192.168.43.1');
    });

    test('escolhe o gateway do hotspot iOS', () {
      final ip = NetworkInfoDriver.pickLocalIpv4([
        (interface: 'en0', ip: '10.0.0.7'),
        (interface: 'bridge100', ip: '172.20.10.1'),
      ]);

      expect(ip, '172.20.10.1');
    });

    test('descarta loopback, link-local e endereço público', () {
      final ip = NetworkInfoDriver.pickLocalIpv4([
        (interface: 'lo', ip: '127.0.0.1'),
        (interface: 'wlan0', ip: '169.254.3.4'),
        (interface: 'rmnet0', ip: '100.82.17.9'),
        (interface: 'swlan0', ip: '192.168.1.5'),
      ]);

      expect(ip, '192.168.1.5');
    });

    test('prefere Wi-Fi aos dados móveis com IP privado', () {
      // Alguns operadores entregam 10.x no rádio. Escolher esse endereço seria
      // pior que não achar nenhum: a sala subiria com um IP que ninguém na
      // festa alcança, e o QR Code pareceria válido.
      final ip = NetworkInfoDriver.pickLocalIpv4([
        (interface: 'rmnet_data0', ip: '10.173.44.8'),
        (interface: 'wlan0', ip: '192.168.1.30'),
      ]);

      expect(ip, '192.168.1.30');
    });

    test('dados móveis sozinhos não são escolhidos', () {
      for (final name in ['rmnet0', 'ccmni0', 'pdp_ip0', 'seth_w0']) {
        expect(
          NetworkInfoDriver.pickLocalIpv4([
            (interface: name, ip: '10.173.44.8'),
          ]),
          isNull,
          reason: '$name é rádio, não rede local',
        );
      }
    });

    test('prefere Wi-Fi a VPN: um convidado não alcança a ponta do túnel', () {
      final ip = NetworkInfoDriver.pickLocalIpv4([
        (interface: 'utun3', ip: '10.9.9.9'),
        (interface: 'wlan0', ip: '192.168.15.20'),
      ]);

      expect(ip, '192.168.15.20');
    });

    test('prefere Wi-Fi a tethering por USB', () {
      final ip = NetworkInfoDriver.pickLocalIpv4([
        (interface: 'rndis0', ip: '192.168.42.1'),
        (interface: 'wlan1', ip: '192.168.15.20'),
      ]);

      expect(ip, '192.168.15.20');
    });

    test('na mesma interface, prefere o .1 do gateway', () {
      final ip = NetworkInfoDriver.pickLocalIpv4([
        (interface: 'wlan0', ip: '192.168.1.77'),
        (interface: 'wlan0', ip: '192.168.1.1'),
      ]);

      expect(ip, '192.168.1.1');
    });

    test('empate mantém o primeiro, para o QR não mudar entre chamadas', () {
      const addresses = <InterfaceAddress>[
        (interface: 'wlan0', ip: '192.168.1.20'),
        (interface: 'wlan1', ip: '192.168.1.30'),
      ];

      expect(NetworkInfoDriver.pickLocalIpv4(addresses), '192.168.1.20');
      // Duas vezes de propósito: a escolha tem de ser determinística.
      expect(NetworkInfoDriver.pickLocalIpv4(addresses), '192.168.1.20');
    });

    test('aceita as três faixas privadas da RFC 1918', () {
      for (final ip in ['10.1.2.3', '172.16.4.5', '192.168.9.9']) {
        expect(
          NetworkInfoDriver.pickLocalIpv4([(interface: 'wlan0', ip: ip)]),
          ip,
          reason: '$ip é privado e deveria servir',
        );
      }
      // 172.32.x está fora da faixa 172.16–172.31.
      expect(
        NetworkInfoDriver.pickLocalIpv4([
          (interface: 'wlan0', ip: '172.32.0.1'),
        ]),
        isNull,
      );
    });

    test('lista vazia ou sem endereço utilizável devolve nulo', () {
      expect(NetworkInfoDriver.pickLocalIpv4([]), isNull);
      expect(
        NetworkInfoDriver.pickLocalIpv4([
          (interface: 'lo', ip: '127.0.0.1'),
          (interface: 'wlan0', ip: '0.0.0.0'),
          (interface: 'wlan0', ip: 'nem-ip-é'),
        ]),
        isNull,
      );
    });
  });

  group('NetworkInfoDriver.getWifiIP', () {
    test('usa o IP do Wi-Fi e nem lista as interfaces', () async {
      var listed = false;
      final driver = NetworkInfoDriver(
        readWifiIp: () async => '192.168.1.50',
        listInterfaceAddresses: () async {
          listed = true;
          return const [];
        },
      );

      expect(await driver.getWifiIP(), '192.168.1.50');
      expect(listed, isFalse, reason: 'fallback é só para quando falta IP');
    });

    test('cai nas interfaces quando o plugin não devolve IP', () async {
      final driver = NetworkInfoDriver(
        readWifiIp: () async => null,
        listInterfaceAddresses: () async => const [
          (interface: 'ap0', ip: '192.168.43.1'),
        ],
      );

      expect(await driver.getWifiIP(), '192.168.43.1');
    });

    test('trata 0.0.0.0 como ausência de IP', () async {
      final driver = NetworkInfoDriver(
        readWifiIp: () async => '0.0.0.0',
        listInterfaceAddresses: () async => const [
          (interface: 'ap0', ip: '192.168.43.1'),
        ],
      );

      expect(await driver.getWifiIP(), '192.168.43.1');
    });

    test('cai nas interfaces quando o plugin lança', () async {
      final driver = NetworkInfoDriver(
        readWifiIp: () async => throw StateError('sem canal de plataforma'),
        listInterfaceAddresses: () async => const [
          (interface: 'wlan0', ip: '192.168.1.9'),
        ],
      );

      expect(await driver.getWifiIP(), '192.168.1.9');
    });

    test('falha ao listar interfaces devolve nulo, não exceção', () async {
      final driver = NetworkInfoDriver(
        readWifiIp: () async => null,
        listInterfaceAddresses: () async => throw StateError('sem permissão'),
      );

      expect(await driver.getWifiIP(), isNull);
    });

    test('sem Wi-Fi e sem interface utilizável, devolve nulo', () async {
      final driver = NetworkInfoDriver(
        readWifiIp: () async => null,
        listInterfaceAddresses: () async => const [
          (interface: 'lo', ip: '127.0.0.1'),
        ],
      );

      expect(await driver.getWifiIP(), isNull);
    });
  });

  group('NetworkInfoDriver.getWifiSubnetMask', () {
    test('devolve a máscara informada', () async {
      final driver = NetworkInfoDriver(
        readWifiSubnetMask: () async => '255.255.255.0',
      );

      expect(await driver.getWifiSubnetMask(), '255.255.255.0');
    });

    test('0.0.0.0 e vazio viram nulo, e o LanSubnet assume o /24', () async {
      expect(
        await NetworkInfoDriver(
          readWifiSubnetMask: () async => '0.0.0.0',
        ).getWifiSubnetMask(),
        isNull,
      );
      expect(
        await NetworkInfoDriver(
          readWifiSubnetMask: () async => '',
        ).getWifiSubnetMask(),
        isNull,
      );
    });

    test('exceção do plugin não escapa', () async {
      final driver = NetworkInfoDriver(
        readWifiSubnetMask: () async =>
            throw StateError('sem canal de plataforma'),
      );

      expect(await driver.getWifiSubnetMask(), isNull);
    });
  });
}

