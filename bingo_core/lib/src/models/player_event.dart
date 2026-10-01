import 'game_event.dart';
import 'player_events.dart';

/// A base class for events sent from a Player to the Host.
abstract class PlayerEvent extends GameEvent {
  @override
  Map<String, dynamic> toJson();

  static PlayerEvent fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'SHOUT_BINGO':
        return ShoutBingoEvent.fromJson(json);
      case 'PLAYER_NAME':
        return PlayerNameEvent.fromJson(json);
      default:
        throw UnknownEventException(json['type']?.toString());
    }
  }
}
