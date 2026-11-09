import 'dart:developer';
import 'dart:io';

import 'package:bingo_core/src/drivers/i_network_info_driver.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Um IPv4 encontrado numa interface do aparelho.
///
/// Existe para manter a escolha do endereço separada de `dart:io`: a regra é
/// pura e testável, e só a enumeração das interfaces toca a plataforma.
typedef InterfaceAddress = ({String interface, String ip});

/// Lista os IPv4 das interfaces do aparelho. Substituído nos testes.
typedef InterfaceAddressLister = Future<List<InterfaceAddress>> Function();

/// Lê um valor de rede do `network_info_plus` (IP ou máscara).
///
/// A costura é esta, e não o próprio `NetworkInfo`: ele é um singleton de
/// construtor privado, então não há como substituí-lo por uma subclasse.
typedef WifiValueReader = Future<String?> Function();

class NetworkInfoDriver implements INetworkInfoDriver {
  NetworkInfoDriver({
    WifiValueReader? readWifiIp,
    WifiValueReader? readWifiSubnetMask,
    InterfaceAddressLister? listInterfaceAddresses,
  }) : _readWifiIpValue = readWifiIp ?? _pluginWifiIp,
       _readWifiSubnetMaskValue = readWifiSubnetMask ?? _pluginSubnetMask,
       _listInterfaceAddresses =
           listInterfaceAddresses ?? _listFromNetworkInterface;

  final WifiValueReader _readWifiIpValue;
  final WifiValueReader _readWifiSubnetMaskValue;
  final InterfaceAddressLister _listInterfaceAddresses;

  // Indireto de propósito: assim um teste que passa as suas próprias funções
  // nunca chega a instanciar o plugin.
  static Future<String?> _pluginWifiIp() => NetworkInfo().getWifiIP();

  static Future<String?> _pluginSubnetMask() => NetworkInfo().getWifiSubmask();

  /// IPv4 do aparelho na rede local.
  ///
  /// Tenta primeiro o `network_info_plus`, que lê a interface de **cliente**
  /// Wi-Fi. Isso cobre o caso comum — anfitrião conectado a um roteador — mas
  /// devolve nada quando o próprio celular é o ponto de acesso: aí o aparelho
  /// não está associado a nenhum AP, e o endereço dele vive numa interface de
  /// AP (`ap0`/`swlan0` no Android, `bridge100` no iOS), que o plugin não
  /// enxerga.
  ///
  /// Esse caso não é exótico: é a saída que o app recomenda ao jogador quando
  /// a rede bloqueia a conversa entre aparelhos (rede de convidados, hotel,
  /// condomínio), e é o que a ficha da loja promete. Sem o fallback abaixo,
  /// ligar o hotspot fazia o anfitrião perder a criação de sala com
  /// "não foi possível obter o endereço do Wi-Fi" — ou seja, a alternativa
  /// recomendada era justamente a que não funcionava.
  @override
  Future<String?> getWifiIP() async {
    final String? wifiIp = _sanitize(await _readWifiIp());
    if (wifiIp != null) return wifiIp;

    try {
      final ip = pickLocalIpv4(await _listInterfaceAddresses());
      if (ip != null) {
        log('NetworkInfoDriver: sem IP de cliente Wi-Fi; usando $ip');
      }
      return ip;
    } catch (e) {
      log('NetworkInfoDriver: falha ao listar interfaces: $e');
      return null;
    }
  }

  @override
  Future<String?> getWifiSubnetMask() async {
    try {
      return _sanitize(await _readWifiSubnetMaskValue());
    } catch (_) {
      return null;
    }
  }

  Future<String?> _readWifiIp() async {
    try {
      return await _readWifiIpValue();
    } catch (e) {
      log('NetworkInfoDriver: falha ao ler o IP do Wi-Fi: $e');
      return null;
    }
  }

  /// Android devolve `0.0.0.0` sem Wi-Fi em alguns aparelhos.
  static String? _sanitize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '0.0.0.0') return null;
    return trimmed;
  }

  /// Escolhe, entre os [addresses] do aparelho, o IPv4 com mais chance de ser
  /// alcançável por um convidado na mesma rede.
  ///
  /// A ordem é por pontuação, e o desempate é estável (primeiro a aparecer),
  /// para que duas chamadas seguidas gerem o mesmo QR Code.
  ///
  /// Prioridades, da mais forte para a mais fraca:
  ///
  /// 1. Faixa de gateway de hotspot conhecida — `192.168.43.x` (Android) e
  ///    `172.20.10.x` (iOS). Quando o celular é o AP, é aqui que ele está.
  /// 2. Nome de interface de AP ou Wi-Fi (`ap0`, `swlan0`, `wlan1`,
  ///    `bridge100`, `en0`...), à frente de tethering por USB (`rndis`, `usb`)
  ///    e bem à frente de VPN (`tun`, `utun`, `ppp`, `tap`) e de dados móveis
  ///    (`rmnet`, `ccmni`, `pdp_ip`, `seth`), que um convidado não alcança.
  /// 3. Terminar em `.1`: o aparelho que serve de AP costuma ser o gateway.
  ///
  /// Loopback, link-local (`169.254.x`, do APIPA quando o DHCP falha) e
  /// qualquer endereço fora das faixas privadas da RFC 1918 são descartados:
  /// nenhum serve para um convidado na rede local.
  @visibleForTesting
  static String? pickLocalIpv4(List<InterfaceAddress> addresses) {
    InterfaceAddress? best;
    int bestScore = -1;

    for (final address in addresses) {
      final ip = _sanitize(address.ip);
      if (ip == null || !_isUsableLocalIpv4(ip)) continue;

      final score = _score(address.interface, ip);
      // `>` e não `>=`: o primeiro de uma pontuação empatada vence, o que
      // mantém a escolha estável entre chamadas.
      if (score > bestScore) {
        bestScore = score;
        best = (interface: address.interface, ip: ip);
      }
    }

    return best?.ip;
  }

  static int _score(String interfaceName, String ip) {
    var score = 0;
    if (_isKnownHotspotGateway(ip)) score += 100;

    final name = interfaceName.toLowerCase();
    if (_isTunnelInterface(name) || _isCellularInterface(name)) {
      score -= 50;
    } else if (_isUsbTetherInterface(name)) {
      score += 5;
    } else if (_isWirelessInterface(name)) {
      score += 20;
    }

    if (ip.endsWith('.1')) score += 10;
    return score;
  }

  /// Faixas em que o celular aparece como gateway do próprio hotspot.
  static bool _isKnownHotspotGateway(String ip) =>
      ip.startsWith('192.168.43.') || ip.startsWith('172.20.10.');

  static bool _isWirelessInterface(String name) =>
      name.startsWith('wlan') ||
      name.startsWith('ap') ||
      name.startsWith('swlan') ||
      name.startsWith('bridge') ||
      name.startsWith('en') ||
      name.startsWith('eth');

  static bool _isUsbTetherInterface(String name) =>
      name.startsWith('rndis') || name.startsWith('usb');

  /// Dados móveis. Alguns operadores entregam IP de faixa privada (10.x) no
  /// rádio, e sem isto o fallback escolheria um endereço que nenhum convidado
  /// na rede local alcança — pior que não achar endereço nenhum, porque a
  /// sala subiria com um IP inútil dentro do QR Code.
  static bool _isCellularInterface(String name) =>
      name.startsWith('rmnet') ||
      name.startsWith('ccmni') ||
      name.startsWith('pdp_ip') ||
      name.startsWith('seth');

  static bool _isTunnelInterface(String name) =>
      name.startsWith('tun') ||
      name.startsWith('utun') ||
      name.startsWith('tap') ||
      name.startsWith('ppp');

  /// IPv4 privado (RFC 1918) que não seja loopback nem link-local.
  static bool _isUsableLocalIpv4(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    final octets = <int>[];
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
      octets.add(n);
    }

    final [a, b, _, _] = octets;
    if (a == 127) return false; // loopback
    if (a == 169 && b == 254) return false; // link-local (APIPA)

    if (a == 10) return true;
    if (a == 192 && b == 168) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    return false;
  }

  static Future<List<InterfaceAddress>> _listFromNetworkInterface() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );
    return [
      for (final interface in interfaces)
        for (final address in interface.addresses)
          (interface: interface.name, ip: address.address),
    ];
  }
}
