// Grid manipulation utilities for board-based games.
// Pure Dart - no Flutter imports.

class GridUtils {
  GridUtils._();

  /// Creates a deep clone of a 2D list.
  static List<List<T>> clone<T>(List<List<T>> grid) {
    return [for (final row in grid) List<T>.from(row)];
  }

  /// Creates an unmodifiable view of a 2D list.
  static List<List<T>> freeze<T>(List<List<T>> grid) {
    return List<List<T>>.unmodifiable(
      grid.map((row) => List<T>.unmodifiable(row)),
    );
  }

  /// Creates a grid filled with a value.
  static List<List<T>> filled<T>(int rows, int cols, T value) {
    return List.generate(rows, (_) => List.filled(cols, value));
  }

  /// Checks if coordinates are within grid bounds.
  static bool inBounds<T>(List<List<T>> grid, int row, int col) {
    if (row < 0 || row >= grid.length) return false;
    if (grid.isEmpty) return false;
    return col >= 0 && col < grid[row].length;
  }

  /// Counts occurrences of a value in the grid.
  static int count<T>(List<List<T>> grid, T value) {
    var total = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell == value) total++;
      }
    }
    return total;
  }

  /// Finds all positions matching a predicate.
  static List<(int, int)> findAll<T>(
    List<List<T>> grid,
    bool Function(T) predicate,
  ) {
    final results = <(int, int)>[];
    for (var r = 0; r < grid.length; r++) {
      for (var c = 0; c < grid[r].length; c++) {
        if (predicate(grid[r][c])) {
          results.add((r, c));
        }
      }
    }
    return results;
  }
}
