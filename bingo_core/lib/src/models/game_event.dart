import 'game_events.dart';

/// Lançada quando uma mensagem traz um `type` que este cliente não conhece.
///
/// O transporte captura esta exceção, registra em log e ignora a mensagem,
/// mantendo o isolamento por mensagem.
class UnknownEventException implements Exception {
  final String? type;
  UnknownEventException(this.type);

  @override
  String toString() => 'UnknownEventException: $type';
}

/// A base class for events sent from the Host to Players.
abstract class GameEvent {
  /// Versão do protocolo de mensagens. Vai em toda mensagem como `"v"`.
  static const int protocolVersion = 1;

  Map<String, dynamic> toJson();

  /// Envelope comum a todas as mensagens: `{"v":1,"type":...,"payload":{...}}`.
  static Map<String, dynamic> envelope(
    String type,
    Map<String, dynamic> payload,
  ) {
    return {'v': protocolVersion, 'type': type, 'payload': payload};
  }

  static GameEvent fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'NUMBER_DRAWN':
        return NumberDrawnEvent.fromJson(json);
      case 'GAME_OVER':
        return GameOverEvent.fromJson(json);
      case 'REJECT_CLAIM':
        return RejectClaimEvent.fromJson(json);
      case 'JOINED':
        return JoinedEvent.fromJson(json);
      case 'STATE_SYNC':
        return StateSyncEvent.fromJson(json);
      case 'ROOM_CLOSED':
        return RoomClosedEvent.fromJson(json);
      default:
        throw UnknownEventException(json['type']?.toString());
    }
  }
}
