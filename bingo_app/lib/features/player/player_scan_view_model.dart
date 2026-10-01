import 'dart:async';
import 'dart:developer';

import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

/// Por que a entrada na sala falhou. A tela traduz para o idioma do usuário.
enum PlayerScanError {
  /// O QR/código não é um convite válido (ou é de uma versão antiga).
  invalidCode,

  /// O aparelho não está em nenhuma rede Wi-Fi (dados móveis ou Wi-Fi off).
  notOnWifi,

  /// O jogador está numa sub-rede diferente da do anfitrião: outra rede
  /// Wi-Fi, ou um roteador que separa as bandas 2,4/5 GHz em redes distintas.
  differentNetwork,

  /// Mesma sub-rede, mas o host não respondeu: isolamento de clientes
  /// (rede de convidados, hotel, condomínio) ou anfitrião fora do Wi-Fi.
  hostUnreachable,

  /// O aparelho do anfitrião respondeu, mas a sala não está mais aberta.
  roomClosed,

  /// O host recusou (token, sala cheia, limite por IP).
  rejected,

  /// Conectou mas o host não enviou `JOINED` a tempo.
  timeout,

  unexpected,
}

class PlayerScanViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;
  final INetworkInfoDriver _networkInfo;
  final IHostReachability _reachability;
  final Duration joinTimeout;
  final Duration probeTimeout;

  PlayerScanError? _error;
  PlayerScanError? get error => _error;

  BingoInvite? _invite;
  BingoInvite? get invite => _invite;

  String? _wifiIp;

  /// IPv4 do aparelho no Wi-Fi na última leitura, ou `null` quando fora do
  /// Wi-Fi. Alimenta o aviso de rede da tela de leitura.
  String? get wifiIp => _wifiIp;

  bool _networkChecked = false;

  /// `true` depois da primeira leitura do IP (evita piscar o aviso).
  bool get networkChecked => _networkChecked;

  PlayerScanViewModel({
    required IGameConnection gameConnection,
    required INetworkInfoDriver networkInfo,
    required IHostReachability reachability,
    this.joinTimeout = const Duration(seconds: 10),
    this.probeTimeout = const Duration(seconds: 3),
  }) : _gameConnection = gameConnection,
       _networkInfo = networkInfo,
       _reachability = reachability;

  /// Relê o IP do Wi-Fi (ao abrir a tela e ao voltar das configurações).
  Future<void> refreshNetwork() async {
    _wifiIp = await _readWifiIp();
    _networkChecked = true;
    notifyListeners();
  }

  /// Interpreta o convite, confere se o host responde, conecta e espera o
  /// `JOINED` com a identidade atribuída pelo servidor. Retorna `null` em
  /// caso de erro (ver [error]).
  Future<JoinedEvent?> onQrCodeScanned(String rawData) async {
    if (isLoading) return null;
    setLoading(true, notify: false);
    _error = null;
    notifyListeners();

    try {
      final invite = BingoInvite.parse(rawData);
      if (invite == null) {
        return _fail(PlayerScanError.invalidCode);
      }
      _invite = invite;

      // Sonda TCP antes do WebSocket: separa "não alcancei" de "recusou" e
      // dá uma explicação útil quando a rede está errada. Se o host
      // responde, segue mesmo que o diagnóstico local pareça estranho.
      final probe = await _reachability.probe(
        invite.ip,
        invite.port,
        timeout: probeTimeout,
      );
      if (probe != HostProbeResult.reachable) {
        return _fail(await _diagnose(probe, invite));
      }

      // Assina antes de conectar para não perder o JOINED; nunca rejeita.
      final joined = _gameConnection.eventStream
          .firstWhere((e) => e is JoinedEvent)
          .timeout(joinTimeout)
          .then<JoinedEvent?>((e) => e as JoinedEvent, onError: (_) => null);

      try {
        await _gameConnection.joinRoom(invite.webSocketUri);
      } catch (e) {
        // Não loga a URI: contém o JWT.
        log('Join refused: ${e.runtimeType}');
        return _fail(PlayerScanError.rejected);
      }

      final event = await joined;
      if (event == null) {
        await _gameConnection.disconnect();
        return _fail(PlayerScanError.timeout);
      }

      unawaited(
        AnalyticsService.trackJoinRoom(
          invite.roomName.isNotEmpty ? invite.roomName : invite.ip,
        ),
      );
      return event;
    } catch (e) {
      log('Unexpected error while joining: $e');
      return _fail(PlayerScanError.unexpected);
    } finally {
      setLoading(false);
    }
  }

  /// O usuário desistiu depois de conectar (ex.: cancelou o nome).
  Future<void> cancelJoin() => _gameConnection.disconnect();

  Future<PlayerScanError> _diagnose(
    HostProbeResult probe,
    BingoInvite invite,
  ) async {
    if (probe == HostProbeResult.refused) return PlayerScanError.roomClosed;

    _wifiIp = await _readWifiIp();
    _networkChecked = true;
    if (_wifiIp == null) return PlayerScanError.notOnWifi;

    String? mask;
    try {
      mask = await _networkInfo.getWifiSubnetMask();
    } catch (_) {
      mask = null;
    }
    final same = LanSubnet.sameSubnet(_wifiIp, invite.ip, mask: mask);
    if (same == false) return PlayerScanError.differentNetwork;
    return PlayerScanError.hostUnreachable;
  }

  Future<String?> _readWifiIp() async {
    try {
      final ip = await _networkInfo.getWifiIP();
      if (ip == null || ip.isEmpty) return null;
      return ip;
    } catch (e) {
      log('Could not read Wi-Fi IP: ${e.runtimeType}');
      return null;
    }
  }

  JoinedEvent? _fail(PlayerScanError error) {
    _error = error;
    notifyListeners();
    return null;
  }
}
