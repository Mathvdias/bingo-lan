import 'dart:convert';

class BingoInvite {
  final String ip;
  final int port;
  final String token;
  final String roomName;
  final int version;
  final String type;

  const BingoInvite({
    required this.ip,
    required this.port,
    required this.token,
    required this.roomName,
    required this.version,
    required this.type,
  });

  factory BingoInvite.fromJson(Map<String, dynamic> json) {
    return BingoInvite(
      ip: json['h'] as String,
      port: json['p'] as int,
      token: json['s'] as String,
      roomName: json['n'] as String,
      version: json['v'] as int,
      type: json['t'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'v': version,
      't': type,
      'h': ip,
      'p': port,
      's': token,
      'n': roomName,
    };
  }

  /// Parses a raw QR string (Base64 or Deep Link) into a BingoInvite
  static BingoInvite? parse(String data) {
    try {
      String payloadToDecode = data;
      if (data.startsWith('bingolucca://') || data.startsWith('http')) {
        final uri = Uri.tryParse(data);
        if (uri != null && uri.queryParameters.containsKey('data')) {
          payloadToDecode = uri.queryParameters['data']!;
        }
      }

      final String decodedJson = utf8.decode(base64Decode(payloadToDecode));
      final Map<String, dynamic> json = jsonDecode(decodedJson);

      return BingoInvite.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  String toDeepLink() {
    final String jsonPayload = jsonEncode(toJson());
    final String base64Payload = base64Encode(utf8.encode(jsonPayload));
    return 'bingolucca://join?data=$base64Payload';
  }
}
