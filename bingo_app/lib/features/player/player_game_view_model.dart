import 'dart:developer'; // Import for log
import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart'; // Import core classes including PlayerEvent/ShoutBingoEvent

class PlayerGameViewModel extends BaseViewModel {
  final int cardId;
  final IGameConnection _gameConnection;

  late final BingoCard bingoCard;
  final Set<int> _markedNumbers = {};

  Set<int> get markedNumbers => _markedNumbers;

  String? _gameWinner;
  String? get gameWinner => _gameWinner;

  PlayerGameViewModel({
    required this.cardId,
    required IGameConnection gameConnection,
  }) : _gameConnection = gameConnection {
    bingoCard = BingoCard(id: cardId);
    // For debugging, print the generated matrix
    log('Player Card ID: $cardId, Matrix: ${bingoCard.matrix}');
    _listenToGameEvents();
  }

  void _listenToGameEvents() {
    _gameConnection.eventStream.listen((event) {
      if (event is GameOverEvent) {
        _gameWinner = event.winnerName;
        notifyListeners();
        log('GAME OVER! Winner: ${event.winnerName}');
        // We could expose a "winnerName" property to binding
      } else if (event is RejectClaimEvent) {
        log('Bingo rejected for ${event.playerName}');
        // Show snackbar?
      }
    });
  }

  void markNumber(int number) {
    if (bingoCard.matrix.contains(number)) {
      if (_markedNumbers.contains(number)) {
        _markedNumbers.remove(number);
      } else {
        _markedNumbers.add(number);
      }
      notifyListeners();
    }
  }

  Future<void> shoutBingo() async {
    setLoading(true);

    // We assume the user name comes from somewhere, maybe stored in shared prefs or passed in
    // For now we use a placeholder or random ID
    final String playerName = 'Player_${cardId % 100}';

    try {
      await _gameConnection.sendPlayerEvent(
        ShoutBingoEvent(cardId: cardId, playerName: playerName),
      );
      log('Player shouted BINGO with card ID: $cardId');
    } catch (e) {
      log('Error shouting Bingo: $e');
      // Maybe show error in UI via errorMessage
    } finally {
      setLoading(false);
    }
  }
}
