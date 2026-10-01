import 'game_event.dart';
import 'player_event.dart';

/// Reivindicação de bingo.
///
/// O cliente envia a mensagem sem identidade (payload vazio). O host preenche
/// [playerId], [cardId] e [playerName] a partir da sessão do socket antes de
/// repassar ao ViewModel, ignorando qualquer valor vindo do cliente.
class ShoutBingoEvent extends PlayerEvent {
  final String? playerId;
  final int? cardId;
  final String? playerName;

  ShoutBingoEvent({this.playerId, this.cardId, this.playerName});

  factory ShoutBingoEvent.fromJson(Map<String, dynamic> json) {
    final payload = (json['payload'] as Map?)?.cast<String, dynamic>();
    return ShoutBingoEvent(
      playerId: payload?['player_id'] as String?,
      cardId: payload?['card_id'] as int?,
      playerName: payload?['player_name'] as String?,
    );
  }

  /// Cópia com a identidade atribuída pelo servidor.
  ShoutBingoEvent withIdentity({
    required String playerId,
    required int cardId,
    required String playerName,
  }) {
    return ShoutBingoEvent(
      playerId: playerId,
      cardId: cardId,
      playerName: playerName,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('SHOUT_BINGO', {
      if (playerId != null) 'player_id': playerId,
      if (cardId != null) 'card_id': cardId,
      if (playerName != null) 'player_name': playerName,
    });
  }
}

class PlayerNameEvent extends PlayerEvent {
  final String name;
  PlayerNameEvent({required this.name});

  factory PlayerNameEvent.fromJson(Map<String, dynamic> json) {
    final payload = (json['payload'] as Map?)?.cast<String, dynamic>();
    return PlayerNameEvent(name: payload?['name'] as String? ?? '');
  }

  @override
  Map<String, dynamic> toJson() {
    return GameEvent.envelope('PLAYER_NAME', {'name': name});
  }
}
