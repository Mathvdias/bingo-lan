import 'dart:async';

import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

class HostInviteViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;

  List<String> _connectedPlayers = const [];
  List<String> get connectedPlayers => _connectedPlayers;

  String _qrData = '';
  BingoInvite? _invite;
  StreamSubscription<List<String>>? _playersSub;

  /// Deep link exibido no QR e compartilhado.
  String get qrData => _qrData;

  /// Nome real da sala, ou `null` se o convite não pôde ser interpretado
  /// (a tela mostra um nome padrão traduzido).
  String? get roomName {
    final name = _invite?.roomName;
    return (name == null || name.isEmpty) ? null : name;
  }

  HostInviteViewModel({required IGameConnection gameConnection})
    : _gameConnection = gameConnection {
    // Mesma fonte da sala do host: valor atual + mudanças.
    _connectedPlayers = _gameConnection.connectedPlayers;
    _playersSub = _gameConnection.connectedPlayersStream.listen((players) {
      _connectedPlayers = players;
      notifyListeners();
    });
  }

  void setInviteData(String qrData) {
    _qrData = qrData;
    _invite = BingoInvite.parse(qrData);
    notifyListeners();
  }

  /// O host voltou da tela de convite: derruba o servidor para que uma nova
  /// sala possa ser criada.
  Future<void> leaveRoom() => _gameConnection.disconnect();

  @override
  void dispose() {
    _playersSub?.cancel();
    super.dispose();
  }
}
