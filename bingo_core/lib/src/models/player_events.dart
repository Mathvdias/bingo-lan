import 'player_event.dart';

class ShoutBingoEvent extends PlayerEvent {
  final int cardId;
  final String playerName;
  ShoutBingoEvent({required this.cardId, required this.playerName});
}

// TODO: Add other PlayerEvent types
