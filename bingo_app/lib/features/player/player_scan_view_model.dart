import 'dart:convert';
import 'dart:math';
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:flutter/foundation.dart';

class PlayerScanViewModel extends BaseViewModel {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Called when a QR code is detected by the scanner.
  /// Decodes the data, simulates a connection, and returns a random cardId on success.
  Future<int?> onQrCodeScanned(String rawData) async {
    setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Decode Base64
      final String decodedJson = utf8.decode(base64Decode(rawData));

      // 2. Parse JSON
      final Map<String, dynamic> payload = jsonDecode(decodedJson);

      // 3. Validate Payload (basic validation)
      if (payload['v'] != 1 ||
          payload['t'] == null ||
          payload['h'] == null ||
          payload['p'] == null ||
          payload['s'] == null) {
        throw const FormatException('QR Code inválido ou corrompido.');
      }

      final String host = payload['h'];
      final int port = payload['p'];
      final String token = payload['s'];

      debugPrint('QR Decoded: Host=$host, Port=$port, Token=$token');

      // TODO: Connect to the host using the extracted data
      // For now, just simulate a successful connection.
      await Future.delayed(const Duration(seconds: 1));

      // 4. Generate a random seed for the bingo card
      final cardId = Random().nextInt(999999);
      return cardId;

    } on FormatException catch(e) {
      debugPrint('Error decoding QR code: $e');
      _errorMessage = 'QR Code inválido. Tente novamente.';
      notifyListeners();
      return null;
    }
    catch (e) {
      debugPrint('An unexpected error occurred: $e');
      _errorMessage = 'Ocorreu um erro inesperado.';
      notifyListeners();
      return null;
    } finally {
      setLoading(false);
    }
  }
}
