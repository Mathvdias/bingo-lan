import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';
import 'package:flutter/foundation.dart';

class PlayerGameViewModel extends BaseViewModel {
  final int cardId;
  late final BingoCard bingoCard;
  final Set<int> _markedNumbers = {};

  Set<int> get markedNumbers => _markedNumbers;

  PlayerGameViewModel({required this.cardId}) {
    bingoCard = BingoCard(id: cardId);
    // For debugging, print the generated matrix
    debugPrint('Player Card ID: $cardId, Matrix: ${bingoCard.matrix}');
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

  void shoutBingo() {
    setLoading(true);
    // TODO: Implement logic to send a "SHOUT_BINGO" event to the host.
    // This will involve:
    // 1. Checking if the current marked numbers actually form a bingo.
    // 2. Sending the claim to the host.
    // 3. Handling the host's response (valid/invalid).
    debugPrint('Player shouted BINGO with card ID: $cardId');
    setLoading(false);
  }
}
