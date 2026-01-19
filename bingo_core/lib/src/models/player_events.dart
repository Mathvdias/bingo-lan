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

class PlayerNameEvent extends PlayerEvent {
  final String name;
  PlayerNameEvent({required this.name});

  factory PlayerNameEvent.fromJson(Map<String, dynamic> json) {
    return PlayerNameEvent(name: json['payload']['name'] as String);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'PLAYER_NAME',
      'payload': {'name': name},
    };
  }
}
