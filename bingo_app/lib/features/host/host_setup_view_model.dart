import 'dart:convert';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart'; // Import IGameConnection, INetworkInfoDriver, IUUIDDriver

enum GameType { local, online }

class HostSetupViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;
  final INetworkInfoDriver _networkInfoDriver;
  final IUUIDDriver _uuidDriver;

  String _roomName = '';
  GameType _gameType = GameType.local;
  String? errorMessage;

  String get roomName => _roomName;
  GameType get gameType => _gameType;

  HostSetupViewModel({
    required IGameConnection gameConnection,
    required INetworkInfoDriver networkInfoDriver,
    required IUUIDDriver uuidDriver,
  })  : _gameConnection = gameConnection,
        _networkInfoDriver = networkInfoDriver,
        _uuidDriver = uuidDriver;

  void onRoomNameChanged(String value) {
    _roomName = value;
  }

  void onGameTypeChanged(GameType? value) {
    if (value != null && _gameType != value) {
      _gameType = value;
      notifyListeners();
    }
  }

  /// Creates a game room and returns the data for the QR code.
  /// Returns null if there was an error.
  Future<String?> createRoom() async {
    if (roomName.trim().isEmpty) {
      errorMessage = "O nome da sala não pode ser vazio!";
      notifyListeners();
      return null;
    }
    errorMessage = null;
    setLoading(true);

    try {
      if (gameType == GameType.local) {
        return await _createLocalRoom();
      } else {
        // TODO: Implement online room creation
        return null;
      }
    } finally {
      setLoading(false);
    }
  }

  Future<String?> _createLocalRoom() async {
    // 1. Get Local IP Address
    final String? ip = await _networkInfoDriver.getWifiIP();
    if (ip == null) {
      errorMessage = "Não foi possível obter o IP. Verifique sua conexão Wi-Fi.";
      notifyListeners();
      return null;
    }

    // 2. Generate Secret Token
    final String secretToken = _uuidDriver.v4().substring(0, 8);

    // 3. Define Port
    const int port = 8080; // As per sec.md

    // 4. Host the room
    await _gameConnection.hostRoom(roomName.trim(), secretToken, ip, port);

    // 5. Construct QR Code Payload (JSON)
    final payload = {
      "v": 1,
      "t": "wifi",
      "h": ip,
      "p": port,
      "s": secretToken,
      "n": roomName.trim(),
    };

    // 6. Encode to Base64
    final String jsonPayload = jsonEncode(payload);
    final String base64Payload = base64Encode(utf8.encode(jsonPayload));

    return base64Payload;
  }
}

