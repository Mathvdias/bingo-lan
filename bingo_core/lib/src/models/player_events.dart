import 'player_event.dart';

class ShoutBingoEvent extends PlayerEvent {
  final int cardId;
  final String playerName;
  ShoutBingoEvent({required this.cardId, required this.playerName});

  factory ShoutBingoEvent.fromJson(Map<String, dynamic> json) {
    return ShoutBingoEvent(
      cardId: json['payload']['card_id'] as int,
      playerName: json['payload']['player_name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'SHOUT_BINGO',
      'payload': {'card_id': cardId, 'player_name': playerName},
    };
  }
}

// TODO: Add other PlayerEvent types
