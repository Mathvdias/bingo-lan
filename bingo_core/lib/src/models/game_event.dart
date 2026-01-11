import 'game_events.dart';

/// A base class for events sent from the Host to Players.
abstract class GameEvent {
  Map<String, dynamic> toJson();

  static GameEvent fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'NUMBER_DRAWN':
        return NumberDrawnEvent.fromJson(json);
      case 'GAME_OVER':
        return GameOverEvent.fromJson(json);
      case 'REJECT_CLAIM':
        return RejectClaimEvent.fromJson(json);
      default:
        throw Exception('Unknown GameEvent type: ${json['type']}');
    }
  }
}
