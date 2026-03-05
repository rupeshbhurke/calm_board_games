import '../../../engine/rng.dart';
import 'connect4_game.dart';

class Connect4Ai {
  final Rng rng;
  final Connect4Logic logic;

  Connect4Ai({Rng? rng})
      : rng = rng ?? RandomRng(),
        logic = Connect4Logic();

  int? chooseColumn(Connect4State state) {
    final validColumns = logic.getValidColumns(state);
    if (validColumns.isEmpty) return null;

    // Check for immediate win
    for (final col in validColumns) {
      final result = logic.dropDisc(state, col);
      if (result.valid && result.state.result == GameResult.yellowWins) {
        return col;
      }
    }

    // Block opponent's winning move - simulate as if red is playing
    for (final col in validColumns) {
      final testState = _simulateRedMove(state, col);
      if (testState != null && testState.result == GameResult.redWins) {
        return col;
      }
    }

    // Prefer center columns
    final centerCols = validColumns.where((c) => c >= 2 && c <= 4).toList();
    if (centerCols.isNotEmpty) {
      return centerCols[rng.nextInt(centerCols.length)];
    }

    // Random valid column
    return validColumns[rng.nextInt(validColumns.length)];
  }

  Connect4State? _simulateRedMove(Connect4State state, int column) {
    // Simulate what would happen if red played in this column
    final board = [for (final row in state.board) List<Player>.from(row)];
    
    // Find lowest empty row
    int? row;
    for (var r = connect4Rows - 1; r >= 0; r--) {
      if (board[r][column] == Player.none) {
        row = r;
        break;
      }
    }
    if (row == null) return null;

    board[row][column] = Player.red;
    return Connect4State.fromBoard(board: board, currentPlayer: Player.yellow);
  }
}
