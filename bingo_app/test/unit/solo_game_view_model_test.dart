import 'package:bingo_app/features/solo/solo_game_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SoloGameViewModel', () {
    test('sortear move um número para a lista de sorteados', () {
      final vm = SoloGameViewModel();

      vm.drawNextNumber();
      vm.drawNextNumber();

      expect(vm.drawnNumbers, hasLength(2));
      expect(vm.drawnNumbers.toSet(), hasLength(2));
    });

    test('marcar alterna a casa', () {
      final vm = SoloGameViewModel();
      final number = vm.bingoCard.matrix.first;

      vm.markNumber(number);
      expect(vm.markedNumbers, contains(number));

      vm.markNumber(number);
      expect(vm.markedNumbers, isNot(contains(number)));
    });

    test('ignora número que não está na cartela', () {
      final vm = SoloGameViewModel();
      final ausente = List<int>.generate(
        75,
        (i) => i + 1,
      ).firstWhere((n) => !vm.bingoCard.matrix.contains(n));

      vm.markNumber(ausente);

      expect(vm.markedNumbers, isEmpty);
      expect(vm.isGameOver, isFalse);
    });

    test('uma linha inteira marcada encerra o jogo', () {
      final vm = SoloGameViewModel();
      final linha = vm.bingoCard.matrix.take(5).toList();

      for (final number in linha) {
        vm.markNumber(number);
      }

      expect(vm.isGameOver, isTrue);
    });

    // Regressão: a vitória exigia `_markedNumbers.length >= 25`, ou seja as
    // 25 casas da cartela. Quatro de uma linha não podem ganhar, mas as cinco
    // precisam — e antes nem isso bastava.
    test('linha incompleta não encerra o jogo', () {
      final vm = SoloGameViewModel();
      final quaseLinha = vm.bingoCard.matrix.take(4).toList();

      for (final number in quaseLinha) {
        vm.markNumber(number);
      }

      expect(vm.isGameOver, isFalse);
    });

    test('uma coluna inteira marcada também encerra o jogo', () {
      final vm = SoloGameViewModel();
      final coluna = <int>[
        for (var row = 0; row < 5; row++) vm.bingoCard.matrix[row * 5],
      ];

      for (final number in coluna) {
        vm.markNumber(number);
      }

      expect(vm.isGameOver, isTrue);
    });

    test('reset limpa marcados, sorteados e o fim de jogo', () {
      final vm = SoloGameViewModel();
      vm.drawNextNumber();
      for (final number in vm.bingoCard.matrix.take(5)) {
        vm.markNumber(number);
      }
      expect(vm.isGameOver, isTrue);
      expect(vm.drawnNumbers, hasLength(1));

      vm.reset();

      expect(vm.markedNumbers, isEmpty);
      expect(vm.drawnNumbers, isEmpty);
      expect(vm.isGameOver, isFalse);
    });

    test('não sorteia mais depois do fim de jogo', () {
      final vm = SoloGameViewModel();
      for (final number in vm.bingoCard.matrix.take(5)) {
        vm.markNumber(number);
      }

      vm.drawNextNumber();

      expect(vm.drawnNumbers, isEmpty);
    });
  });
}
