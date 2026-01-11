import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

class HostInviteViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;

  List<String> _connectedPlayers = [];
  List<String> get connectedPlayers => _connectedPlayers;

  HostInviteViewModel({required IGameConnection gameConnection})
    : _gameConnection = gameConnection {
    _listenToConnections();
  }

  void _listenToConnections() {
    _gameConnection.connectedPlayersStream.listen((players) {
      _connectedPlayers = players;
      notifyListeners();
    });
  }
}
