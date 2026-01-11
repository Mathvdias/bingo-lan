import 'game_event.dart';

class NumberDrawnEvent extends GameEvent {
  final int number;
  NumberDrawnEvent({required this.number});

  factory NumberDrawnEvent.fromJson(Map<String, dynamic> json) {
    return NumberDrawnEvent(number: json['payload']['number'] as int);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'NUMBER_DRAWN',
      'payload': {'number': number},
    };
  }
}

class GameOverEvent extends GameEvent {
  final String winnerName;
  GameOverEvent({required this.winnerName});

  factory GameOverEvent.fromJson(Map<String, dynamic> json) {
    return GameOverEvent(winnerName: json['payload']['winner_name']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'GAME_OVER',
      'payload': {'winner_name': winnerName},
    };
  }
}

class RejectClaimEvent extends GameEvent {
  final String playerName;
  RejectClaimEvent({required this.playerName});

  factory RejectClaimEvent.fromJson(Map<String, dynamic> json) {
    return RejectClaimEvent(playerName: json['payload']['player_name']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'REJECT_CLAIM',
      'payload': {'player_name': playerName},
    };
  }
}
