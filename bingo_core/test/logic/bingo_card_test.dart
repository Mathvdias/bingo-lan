import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_core/bingo_core.dart';

void main() {
  group('BingoCard Tests', () {
    test('matrix generates valid deterministic bingo card', () {
      final card = BingoCard(id: 1);
      
      expect(card.id, 1);
      expect(card.matrix.length, 25);
      expect(card.matrix[12], 0); // Center is free space
      
      // B column: indices 0, 5, 10, 15, 20
      for (int i=0; i<5; i++) {
         int num = card.matrix[i * 5 + 0];
         expect(num >= 1 && num <= 15, true);
      }
      // I column: indices 1, 6, 11, 16, 21
      for (int i=0; i<5; i++) {
         int num = card.matrix[i * 5 + 1];
         expect(num >= 16 && num <= 30, true);
      }
      // N column: indices 2, 7, 12, 17, 22
      for (int i=0; i<5; i++) {
         int num = card.matrix[i * 5 + 2];
         if (num != 0) {
            expect(num >= 31 && num <= 45, true);
         }
      }
      // G column: indices 3, 8, 13, 18, 23
      for (int i=0; i<5; i++) {
         int num = card.matrix[i * 5 + 3];
         expect(num >= 46 && num <= 60, true);
      }
      // O column: indices 4, 9, 14, 19, 24
      for (int i=0; i<5; i++) {
         int num = card.matrix[i * 5 + 4];
         expect(num >= 61 && num <= 75, true);
      }
    });

    test('BingoCard detects horizontal bingo', () {
      final card = BingoCard(id: 1);
      
      // Select the first row: indices 0, 1, 2, 3, 4
      final drawnNumbers = [
        card.matrix[0],
        card.matrix[1],
        card.matrix[2],
        card.matrix[3],
        card.matrix[4],
      ];
      
      expect(card.hasBingo(drawnNumbers), true);
    });
  });
}
