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
      List<int> matrix, int colIndex, int min, int max, Random random) {
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
}
