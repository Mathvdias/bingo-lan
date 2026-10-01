import 'dart:convert';

/// Convite de sala: a única fonte de verdade para o payload do QR Code.
///
/// Formato (v2): JSON `{"v":2,"t":"wifi","h":ip,"p":port,"token":jwt,"n":room}`
/// codificado em Base64 dentro do deep link `bingo://join?data=<base64>`.
///
/// Host, jogador e testes devem serializar e interpretar convites apenas por
/// esta classe ([toDeepLink] / [parse]).
class BingoInvite {
  static const int currentVersion = 2;
  static const String typeWifi = 'wifi';
  static const String scheme = 'bingo';
  static const String host = 'join';
  static const String dataParam = 'data';

  /// Prefixo do deep link gerado por [toDeepLink].
  static const String deepLinkPrefix = '$scheme://$host?$dataParam=';

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
    this.version = currentVersion,
    this.type = typeWifi,
  });

  factory BingoInvite.fromJson(Map<String, dynamic> json) {
    final version = json['v'];
    if (version != currentVersion) {
      throw FormatException('Unsupported invite version: $version');
    }
    final ip = json['h'];
    final port = json['p'];
    final token = json['token'];
    final roomName = json['n'];
    if (ip is! String || port is! int || token is! String) {
      throw const FormatException('Invite is missing required fields');
    }
    return BingoInvite(
      ip: ip,
      port: port,
      token: token,
      roomName: roomName is String ? roomName : '',
      version: version as int,
      type: (json['t'] as String?) ?? typeWifi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'v': version,
      't': type,
      'h': ip,
      'p': port,
      'token': token,
      'n': roomName,
    };
  }

  /// URI do WebSocket do host, com o JWT na query string.
  String get webSocketUri => 'ws://$ip:$port/?token=$token';

  /// Interpreta a string lida do QR Code ou do deep link.
  ///
  /// Aceita o deep link `bingo://join?data=...`, um link http(s) com o mesmo
  /// parâmetro `data`, ou o Base64 puro. Retorna `null` quando inválido.
  static BingoInvite? parse(String data) {
    try {
      final raw = data.trim();
      String payloadToDecode = raw;
      final uri = Uri.tryParse(raw);
      if (uri != null &&
          (uri.scheme == scheme ||
              uri.scheme == 'http' ||
              uri.scheme == 'https')) {
        final param = uri.queryParameters[dataParam];
        if (param == null) return null;
        payloadToDecode = param;
      }

      // `+` vira espaço quando o link passa por decodificação de URL; base64
      // nunca contém espaços, então a troca é segura. normalize() aceita os
      // alfabetos padrão e URL-safe e completa o padding.
      final String decodedJson = utf8.decode(
        base64Decode(base64.normalize(payloadToDecode.replaceAll(' ', '+'))),
      );
      final decoded = jsonDecode(decodedJson);
      if (decoded is! Map<String, dynamic>) return null;
      return BingoInvite.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Payload Base64 URL-safe (sem o prefixo do deep link), para sobreviver a
  /// apps de mensagem e à decodificação de query string.
  String toBase64() {
    final String jsonPayload = jsonEncode(toJson());
    return base64Url.encode(utf8.encode(jsonPayload));
  }

  /// Deep link completo: `bingo://join?data=<base64>`.
  String toDeepLink() => '$deepLinkPrefix${toBase64()}';
}
