import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/foundation.dart';

/// Argumentos da rota `/player/game`, passados via `extra`.
///
/// Contrato único entre a tela de scan e a tela de jogo: a identidade vem do
/// `JOINED` enviado pelo host (nunca escolhida pelo cliente).
@immutable
class PlayerGameArgs {
  final int cardId;
  final String playerName;
  final String playerId;
  final String roomName;

  /// Números já sorteados no momento da entrada (entrantes tardios).
  final List<int> initialDrawnNumbers;

  const PlayerGameArgs({
    required this.cardId,
    required this.playerName,
    required this.playerId,
    this.roomName = '',
    this.initialDrawnNumbers = const [],
  });

  factory PlayerGameArgs.fromJoined(
    JoinedEvent joined, {
    required String playerName,
  }) {
    return PlayerGameArgs(
      cardId: joined.cardId,
      playerName: playerName,
      playerId: joined.playerId,
      roomName: joined.roomName,
      initialDrawnNumbers: List<int>.unmodifiable(joined.drawnNumbers),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerGameArgs &&
        other.cardId == cardId &&
        other.playerName == playerName &&
        other.playerId == playerId &&
        other.roomName == roomName &&
        listEquals(other.initialDrawnNumbers, initialDrawnNumbers);
  }

  @override
  int get hashCode => Object.hash(
    cardId,
    playerName,
    playerId,
    roomName,
    Object.hashAll(initialDrawnNumbers),
  );

  @override
  String toString() =>
      'PlayerGameArgs(cardId: $cardId, playerName: $playerName, '
      'playerId: $playerId, roomName: $roomName, '
      'drawn: ${initialDrawnNumbers.length})';
}
