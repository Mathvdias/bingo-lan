import 'package:bingo_app/shared/view_models/base_view_model.dart';
import 'package:bingo_core/bingo_core.dart';
import 'dart:math';

class SoloGameViewModel extends BaseViewModel {
  final BingoCard bingoCard;
  final Set<int> _markedNumbers = {};
  final List<int> _drawnNumbers = [];
  final List<int> _allNumbers = List.generate(75, (i) => i + 1)..shuffle();
  
  Set<int> get markedNumbers => _markedNumbers;
  List<int> get drawnNumbers => _drawnNumbers;
  
  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  SoloGameViewModel() : bingoCard = BingoCard(id: Random().nextInt(100000));

  void drawNextNumber() {
    if (_allNumbers.isEmpty || _isGameOver) return;
    
    final number = _allNumbers.removeLast();
    _drawnNumbers.add(number);
    notifyListeners();
  }

  void markNumber(int number) {
    if (bingoCard.matrix.contains(number)) {
      if (_markedNumbers.contains(number)) {
        _markedNumbers.remove(number);
      } else {
        _markedNumbers.add(number);
      }
      _checkWin();
      notifyListeners();
    }
  }

  void _checkWin() {
    // For now, in Solo mode, we just check if they filled any row/column locally
    // This is optional for a "v1 solo", but let's add a placeholder flag
    if (_markedNumbers.length >= 25) { // Simple for now
      _isGameOver = true;
    }
  }

  void reset() {
    _markedNumbers.clear();
    _drawnNumbers.clear();
    _allNumbers.clear();
    _allNumbers.addAll(List.generate(75, (i) => i + 1)..shuffle());
    _isGameOver = false;
    notifyListeners();
  }
}
