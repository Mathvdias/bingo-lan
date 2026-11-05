import 'package:bingo_app/shared/services/sound_service.dart';
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
    SoundService.play(BingoSfx.draw);
    notifyListeners();
  }

  void markNumber(int number) {
    if (bingoCard.matrix.contains(number)) {
      if (_markedNumbers.contains(number)) {
        _markedNumbers.remove(number);
        SoundService.play(BingoSfx.unmark);
      } else {
        _markedNumbers.add(number);
        SoundService.play(BingoSfx.mark);
      }
      _checkWin();
      notifyListeners();
    }
  }

  /// Vitória é uma linha, coluna ou diagonal inteiramente marcada — a mesma
  /// regra que o modo com host aplica via [BingoCard.hasBingo].
  ///
  /// A versão anterior exigia `_markedNumbers.length >= 25`, ou seja, marcar
  /// as 25 casas da cartela: no solo a vitória praticamente nunca disparava.
  void _checkWin() {
    if (_isGameOver) return;
    if (bingoCard.hasBingo(_markedNumbers.toList())) {
      _isGameOver = true;
      SoundService.play(BingoSfx.win);
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
