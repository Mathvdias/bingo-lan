import 'game_event.dart';

Map<String, dynamic> _payloadOf(Map<String, dynamic> json) {
  return (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {};
}

List<int> _intList(Object? raw) {
  if (raw is! List) return const [];
  return raw.whereType<num>().map((n) => n.toInt()).toList();
}

class NumberDrawnEvent extends GameEvent {
  final int number;
  NumberDrawnEvent({required this.number});

  factory NumberDrawnEvent.fromJson(Map<String, dynamic> json) {
    return NumberDrawnEvent(number: _payloadOf(json)['number'] as int);
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('NUMBER_DRAWN', {'number': number});
  }
}

class GameOverEvent extends GameEvent {
  final String winnerName;

  /// Id atribuído pelo host ao vencedor. Permite ao jogador saber se "ganhei".
  final String? winnerId;

  GameOverEvent({required this.winnerName, this.winnerId});

  factory GameOverEvent.fromJson(Map<String, dynamic> json) {
    final payload = _payloadOf(json);
    return GameOverEvent(
      winnerName: payload['winner_name'] as String? ?? '',
      winnerId: payload['winner_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('GAME_OVER', {
      'winner_name': winnerName,
      if (winnerId != null) 'winner_id': winnerId,
    });
  }
}

class RejectClaimEvent extends GameEvent {
  final String playerName;

  /// Id do jogador cuja reivindicação foi negada.
  final String? playerId;

  RejectClaimEvent({required this.playerName, this.playerId});

  factory RejectClaimEvent.fromJson(Map<String, dynamic> json) {
    final payload = _payloadOf(json);
    return RejectClaimEvent(
      playerName: payload['player_name'] as String? ?? '',
      playerId: payload['player_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('REJECT_CLAIM', {
      'player_name': playerName,
      if (playerId != null) 'player_id': playerId,
    });
  }
}

/// Primeira mensagem que o host envia a um jogador recém-conectado.
///
/// Carrega a identidade atribuída pelo servidor ([playerId], [cardId]) e o
/// estado atual da rodada ([drawnNumbers]) para entrantes tardios.
class JoinedEvent extends GameEvent {
  final String playerId;
  final int cardId;
  final List<int> drawnNumbers;
  final String roomName;

  JoinedEvent({
    required this.playerId,
    required this.cardId,
    required this.drawnNumbers,
    required this.roomName,
  });

  factory JoinedEvent.fromJson(Map<String, dynamic> json) {
    final payload = _payloadOf(json);
    return JoinedEvent(
      playerId: payload['player_id'] as String,
      cardId: payload['card_id'] as int,
      drawnNumbers: _intList(payload['drawn_numbers']),
      roomName: payload['room_name'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('JOINED', {
      'player_id': playerId,
      'card_id': cardId,
      'drawn_numbers': drawnNumbers,
      'room_name': roomName,
    });
  }
}

/// Sincroniza o estado da rodada.
///
/// Em broadcast (nova rodada) só [drawnNumbers] importa. Em reconexão o host
/// envia a mensagem direcionada com [playerId] e [cardId] da sessão restaurada.
class StateSyncEvent extends GameEvent {
  final List<int> drawnNumbers;
  final String? playerId;
  final int? cardId;
  final String? roomName;

  StateSyncEvent({
    required this.drawnNumbers,
    this.playerId,
    this.cardId,
    this.roomName,
  });

  factory StateSyncEvent.fromJson(Map<String, dynamic> json) {
    final payload = _payloadOf(json);
    return StateSyncEvent(
      drawnNumbers: _intList(payload['drawn_numbers']),
      playerId: payload['player_id'] as String?,
      cardId: payload['card_id'] as int?,
      roomName: payload['room_name'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('STATE_SYNC', {
      'drawn_numbers': drawnNumbers,
      if (playerId != null) 'player_id': playerId,
      if (cardId != null) 'card_id': cardId,
      if (roomName != null) 'room_name': roomName,
    });
  }
}

/// O host encerrou a sala. Os jogadores não devem tentar reconectar.
class RoomClosedEvent extends GameEvent {
  RoomClosedEvent();

  factory RoomClosedEvent.fromJson(Map<String, dynamic> json) {
    return RoomClosedEvent();
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('ROOM_CLOSED', const {});
  }
}
