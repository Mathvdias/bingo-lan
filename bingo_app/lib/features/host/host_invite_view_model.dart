import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

class HostInviteViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;

  List<String> _connectedPlayers = [];
  List<String> get connectedPlayers => _connectedPlayers;

  BingoInvite? _inviteInfo;
  String get roomName => _inviteInfo?.roomName ?? 'Sala de Bingo';
  String get roomCode => _inviteInfo?.token ?? '---';

  // We keep the original raw data string if needed, or rely on info.
  // Should we expose the raw invite link? The model helper toDeepLink can regenerate it or we can store it.

  HostInviteViewModel({required IGameConnection gameConnection})
    : _gameConnection = gameConnection {
    _listenToConnections();
  }

  void setInviteData(String qrData) {
    _inviteInfo = BingoInvite.parse(qrData);
    // If parsing fails, we could handle error, but for now we fallback to defaults.
    notifyListeners();
  }

  void _listenToConnections() {
    _gameConnection.connectedPlayersStream.listen((players) {
      _connectedPlayers = players;
      notifyListeners();
    });
  }
}
