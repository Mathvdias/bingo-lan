import 'dart:math';

/// Represents a bingo card.
///
/// The card's 5x5 matrix is generated deterministically from a given [id] (seed).
/// This is a crucial optimization: instead of sending the entire matrix over the network,
/// only the seed is transmitted. The client and server can then generate the exact same
/// card independently, saving bandwidth and preventing cheating.
class BingoCard {
  final int id; // The seed for the card generation.

  BingoCard({required this.id});

  /// Generates the 5x5 bingo matrix from the [id] seed.
  /// The center spot (index 12) is always free (represented by 0).
  List<int> get matrix => _generateMatrix(id);

  /// Generates a deterministic list of 25 numbers for a bingo card
  /// based on a given [seed].
  static List<int> _generateMatrix(int seed) {
    final random = Random(seed);
    final List<int> matrix = List<int>.filled(25, 0);

    // B column: 1-15
    _fillColumn(matrix, 0, 1, 15, random);
    // I column: 16-30
    _fillColumn(matrix, 1, 16, 30, random);
    // N column: 31-45
    _fillColumn(matrix, 2, 31, 45, random);
    // G column: 46-60
    _fillColumn(matrix, 3, 46, 60, random);
    // O column: 61-75
    _fillColumn(matrix, 4, 61, 75, random);

    // Center square is free
    matrix[12] = 0;

    return matrix;
  }

  /// Helper function to fill a column with unique random numbers within a range.
  static void _fillColumn(
    List<int> matrix,
    int colIndex,
    int min,
    int max,
    Random random,
  ) {
    final Set<int> numbers = {};
    while (numbers.length < 5) {
      numbers.add(random.nextInt(max - min + 1) + min);
    }

    final List<int> sortedNumbers = numbers.toList()..sort();
    for (int i = 0; i < 5; i++) {
      // The N column has a free space in the middle, so we only need 4 numbers.
      // However, to keep the logic consistent, we generate 5 and just overwrite
      // the center one later.
      matrix[i * 5 + colIndex] = sortedNumbers[i];
    }
  }

  /// Checks if this card has a bingo given the list of [drawnNumbers].
  /// A bingo is achieved if any row, column, or diagonal is fully covered by the drawn numbers.
  bool hasBingo(List<int> drawnNumbers) {
    final List<int> cardMatrix = matrix;
    final Set<int> drawnSet = drawnNumbers.toSet()..add(0); // 0 is free space

    // 1. Check Rows
    for (int row = 0; row < 5; row++) {
      bool isBingo = true;
      for (int col = 0; col < 5; col++) {
        if (!drawnSet.contains(cardMatrix[row * 5 + col])) {
          isBingo = false;
          break;
        }
      }
      if (isBingo) return true;
    }

    // 2. Check Columns
    for (int col = 0; col < 5; col++) {
      bool isBingo = true;
      for (int row = 0; row < 5; row++) {
        if (!drawnSet.contains(cardMatrix[row * 5 + col])) {
          isBingo = false;
          break;
        }
      }
      if (isBingo) return true;
    }

    // 3. Check Main Diagonal (Top-Left to Bottom-Right)
    bool isMainDiagBingo = true;
    for (int i = 0; i < 5; i++) {
      if (!drawnSet.contains(cardMatrix[i * 5 + i])) {
        isMainDiagBingo = false;
        break;
      }
    }
    if (isMainDiagBingo) return true;

    // 4. Check Anti-Diagonal (Top-Right to Bottom-Left)
    bool isAntiDiagBingo = true;
    for (int i = 0; i < 5; i++) {
      if (!drawnSet.contains(cardMatrix[i * 5 + (4 - i)])) {
        isAntiDiagBingo = false;
        break;
      }
    }
    if (isAntiDiagBingo) return true;

    return false;
  }
}
