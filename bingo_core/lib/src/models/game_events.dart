import 'game_event.dart';

class NumberDrawnEvent extends GameEvent {
  final int number;
  NumberDrawnEvent({required this.number});
}

// TODO: Add other GameEvent types
