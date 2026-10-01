import 'dart:async';
import 'dart:developer';

import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

/// Motivo da falha ao criar a sala. A tela traduz.
enum HostSetupError { emptyName, noWifi, portUnavailable, unexpected }

class HostSetupViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;
  final INetworkInfoDriver _networkInfoDriver;

  String _roomName = '';
  HostSetupError? _error;
  BingoInvite? _invite;

  String get roomName => _roomName;
  HostSetupError? get error => _error;

  /// Convite da última sala criada com sucesso.
  BingoInvite? get invite => _invite;

  HostSetupViewModel({
    required IGameConnection gameConnection,
    required INetworkInfoDriver networkInfoDriver,
  }) : _gameConnection = gameConnection,
       _networkInfoDriver = networkInfoDriver;

  void onRoomNameChanged(String value) {
    _roomName = value;
    if (_error == HostSetupError.emptyName && value.trim().isNotEmpty) {
      _error = null;
      notifyListeners();
    }
  }

  /// Sobe o servidor e devolve o deep link do QR Code (`bingo://join?data=`).
  /// Retorna `null` em caso de erro (ver [error]).
  Future<String?> createRoom() async {
    final name = roomName.trim();
    if (name.isEmpty) {
      return _fail(HostSetupError.emptyName);
    }
    _error = null;
    setLoading(true);

    try {
      final String? ip = await _networkInfoDriver.getWifiIP();
      if (ip == null || ip.isEmpty) {
        return _fail(HostSetupError.noWifi);
      }

      final String secret = JwtService.generateSecret();

      // Porta 0: o sistema escolhe uma livre; a real vai no convite.
      final int port = await _gameConnection.hostRoom(name, secret, ip, 0);

      final String token = JwtService.generateRoomToken(
        roomId: name,
        role: 'player',
        secret: secret,
      );

      _invite = BingoInvite(ip: ip, port: port, token: token, roomName: name);
      unawaited(AnalyticsService.trackCreateRoom(name));
      // App Link https: o mesmo texto vai para o QR, "Compartilhar" e
      // "Copiar link", e fica clicável nos apps de mensagem.
      return _invite!.toWebLink();
    } on HostStartException catch (e) {
      log('Could not start the room server: $e');
      return _fail(HostSetupError.portUnavailable);
    } catch (e) {
      log('Unexpected error creating room: $e');
      return _fail(HostSetupError.unexpected);
    } finally {
      setLoading(false);
    }
  }

  String? _fail(HostSetupError error) {
    _error = error;
    notifyListeners();
    return null;
  }
}
