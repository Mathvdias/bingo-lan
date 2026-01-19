import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';

class PlayerScanViewModel extends BaseViewModel {
  final IGameConnection _gameConnection;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PlayerScanViewModel({required IGameConnection gameConnection})
    : _gameConnection = gameConnection;

  /// Called when a QR code is detected by the scanner.
  /// Decodes the data, simulates a connection, and returns a random cardId on success.
  Future<int?> onQrCodeScanned(String rawData) async {
    setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      String payloadToDecode = rawData;

      // Handle Deep Link format: bingolucca://join?data=BASE64...
      if (rawData.startsWith('bingolucca://') || rawData.startsWith('http')) {
        final uri = Uri.tryParse(rawData);
        if (uri != null && uri.queryParameters.containsKey('data')) {
          payloadToDecode = uri.queryParameters['data']!;
        }
      }

      // 1. Decode Base64
      final String decodedJson = utf8.decode(base64Decode(payloadToDecode));

      // 2. Parse JSON
      final Map<String, dynamic> payload = jsonDecode(decodedJson);

      // 3. Validate Payload version
      final int version = payload['v'] ?? 1;

      String connectionId;

      if (version == 2) {
        // Version 2: Using JWT token
        if (payload['h'] == null ||
            payload['p'] == null ||
            payload['token'] == null) {
          throw const FormatException('QR Code inválido ou corrompido.');
        }

        final String host = payload['h'];
        final int port = payload['p'];
        final String jwtToken = payload['token'];

        log('QR Decoded (v2): Host=$host, Port=$port, Token=<JWT>');

        // Construct WebSocket URL with JWT token
        connectionId = 'ws://$host:$port?token=$jwtToken';
      } else {
        // Version 1: Legacy format (backwards compatibility)
        if (payload['t'] == null ||
            payload['h'] == null ||
            payload['p'] == null ||
            payload['s'] == null) {
          throw const FormatException('QR Code inválido ou corrompido.');
        }

        final String host = payload['h'];
        final int port = payload['p'];
        final String token = payload['s'];

        log('QR Decoded (v1): Host=$host, Port=$port, Token=$token');

        // Construct WebSocket URL with simple token
        connectionId = 'ws://$host:$port?token=$token';
      }

      // 4. Connect to the host
      await _gameConnection.joinRoom(connectionId);

      // 5. Generate a random seed for the bingo card
      final cardId = Random().nextInt(999999);
      return cardId;
    } on FormatException catch (e) {
      log('Error decoding QR code: $e');
      _errorMessage = 'QR Code inválido. Tente novamente.';
      notifyListeners();
      return null;
    } catch (e) {
      log('An unexpected error occurred: $e');
      _errorMessage = 'Ocorreu um erro inesperado: $e';
      notifyListeners();
      return null;
    } finally {
      setLoading(false);
    }
  }
}
