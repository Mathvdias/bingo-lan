import 'dart:convert';
import 'package:bingo_app/shared/services/analytics_service.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

class HostSetupViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;
  final INetworkInfoDriver _networkInfoDriver;

  String _roomName = '';
  String? errorMessage;

  String get roomName => _roomName;

  HostSetupViewModel({
    required IGameConnection gameConnection,
    required INetworkInfoDriver networkInfoDriver,
  }) : _gameConnection = gameConnection,
       _networkInfoDriver = networkInfoDriver;

  void onRoomNameChanged(String value) {
    _roomName = value;
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
      final deepLink = await _createLocalRoom();
      if (deepLink != null) {
        AnalyticsService.trackCreateRoom(roomName.trim());
      }
      return deepLink;
    } finally {
      setLoading(false);
    }
  }

  Future<String?> _createLocalRoom() async {
    // 1. Get Local IP Address
    final String? ip = await _networkInfoDriver.getWifiIP();
    if (ip == null) {
      errorMessage =
          "Não foi possível obter o IP. Verifique sua conexão Wi-Fi.";
      notifyListeners();
      return null;
    }

    // 2. Generate Secret for JWT signing
    final String jwtSecret = JwtService.generateSecret();

    // 3. Define Port
    const int port = 8080; // As per sec.md

    // 4. Host the room (pass JWT secret)
    await _gameConnection.hostRoom(roomName.trim(), jwtSecret, ip, port);

    // 5. Generate JWT token for this room
    final String jwtToken = JwtService.generateRoomToken(
      roomId: roomName.trim(),
      role: 'player',
      secret: jwtSecret,
    );

    // 6. Construct QR Code Payload (JSON) with JWT
    final payload = {
      "v": 2, // Version 2 - now using JWT
      "t": "wifi",
      "h": ip,
      "p": port,
      "token": jwtToken, // JWT token instead of simple secret
      "n": roomName.trim(),
    };

    // 7. Encode to Base64
    final String jsonPayload = jsonEncode(payload);
    final String base64Payload = base64Encode(utf8.encode(jsonPayload));

    // 8. Construct Deep Link
    final String deepLink = 'bingo://join?data=$base64Payload';

    return deepLink;
  }
}
