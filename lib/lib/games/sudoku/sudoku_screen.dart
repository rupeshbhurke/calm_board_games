import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../shared/game_dialogs.dart';
import '../../shared/game_header.dart';
import 'logic/sudoku_board.dart';
import 'logic/sudoku_generator.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late final SudokuGenerator _generator;
  late final SudokuLogic _logic;
  late SudokuState _state;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _difficulty = 1;
  bool _solvedShown = false;

  @override
  void initState() {
    super.initState();
    _generator = SudokuGenerator();
    _logic = SudokuLogic();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _state = _generator.generate(difficulty: _difficulty);
      _selectedRow = -1;
      _selectedCol = -1;
      _solvedShown = false;
    });
  }

  void _selectCell(int row, int col) {
    if (_state.board[row][col].isGiven) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _setNumber(int number) {
    if (_selectedRow < 0 || _selectedCol < 0) return;

    final result = _logic.setCell(_state, _selectedRow, _selectedCol, number);
    if (!result.valid || !mounted) return;

    setState(() {
      _state = result.state;
    });

    if (_state.isSolved && !_solvedShown) {
      _solvedShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameDialog(
          context: context,
          title: 'Congratulations! 🎉',
          message: 'You solved the puzzle!',
          primaryLabel: 'New Game',
          onPrimary: _newGame,
        );
      });
    }
  }

  void _checkErrors() {
    setState(() {
      _state = _logic.validateBoard(_state);
    });
  }

  void _showHint() {
    final hint = _logic.getHint(_state);
    if (hint == null) return;

    final (row, col, value) = hint;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });

    showInfoDialog(
      context: context,
      title: 'Hint',
      message: 'Try putting $value in row ${row + 1}, column ${col + 1}.',
    );
  }

  void _changeDifficulty(int diff) {
    setState(() {
      _difficulty = diff;
    });
    _newGame();
  }

  @override
  Widget build(BuildContext context) {
    final difficultyText = switch (_difficulty) {
      1 => 'Easy',
      2 => 'Medium',
      _ => 'Hard',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Sudoku')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            children: [
              GameHeader(
                title: 'Progress: ${_state.filledCount}/${_state.totalCells}',
                subtitle: difficultyText,
                buttonLabel: 'New',
                onButtonPressed: _newGame,
              ),
              const SizedBox(height: Spacing.s13),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DifficultyButton(
                    label: 'Easy',
                    isSelected: _difficulty == 1,
                    onTap: () => _changeDifficulty(1),
                  ),
                  const SizedBox(width: Spacing.s8),
                  _DifficultyButton(
                    label: 'Medium',
                    isSelected: _difficulty == 2,
                    onTap: () => _changeDifficulty(2),
                  ),
                  const SizedBox(width: Spacing.s8),
                  _DifficultyButton(
                    label: 'Hard',
                    isSelected: _difficulty == 3,
                    onTap: () => _changeDifficulty(3),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: Center(
                  child: _SudokuBoard(
                    state: _state,
                    selectedRow: _selectedRow,
                    selectedCol: _selectedCol,
                    onCellTap: _selectCell,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.s21),
              _NumberPad(
                onNumber: _setNumber,
                onClear: () => _setNumber(0),
              ),
              const SizedBox(height: Spacing.s13),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _checkErrors,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Check'),
                  ),
                  const SizedBox(width: Spacing.s21),
                  TextButton.icon(
                    onPressed: _showHint,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Hint'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.s13,
          vertical: Spacing.s8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? CalmPalette.primary : CalmPalette.surface,
          borderRadius: BorderRadius.circular(Spacing.r12),
          border: Border.all(color: CalmPalette.stroke),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? CalmPalette.text : CalmPalette.subtext,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SudokuBoard extends StatelessWidget {
  final SudokuState state;
  final int selectedRow;
  final int selectedCol;
  final void Function(int row, int col) onCellTap;

  const _SudokuBoard({
    required this.state,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: CalmPalette.text,
          borderRadius: BorderRadius.circular(Spacing.r16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Spacing.r16 - 2),
          child: Column(
            children: List.generate(sudokuSize, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(sudokuSize, (col) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: (col + 1) % sudokuBoxSize == 0 && col < sudokuSize - 1
                                  ? CalmPalette.text
                                  : CalmPalette.stroke,
                              width: (col + 1) % sudokuBoxSize == 0 ? 2 : 0.5,
                            ),
                            bottom: BorderSide(
                              color: (row + 1) % sudokuBoxSize == 0 && row < sudokuSize - 1
                                  ? CalmPalette.text
                                  : CalmPalette.stroke,
                              width: (row + 1) % sudokuBoxSize == 0 ? 2 : 0.5,
                            ),
                          ),
                        ),
                        child: _SudokuCell(
                          cell: state.board[row][col],
                          isSelected: row == selectedRow && col == selectedCol,
                          isHighlighted: row == selectedRow ||
                              col == selectedCol ||
                              SudokuLogic().isInSameBox(row, col, selectedRow, selectedCol),
                          onTap: () => onCellTap(row, col),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SudokuCell extends StatelessWidget {
  final SudokuCell cell;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _SudokuCell({
    required this.cell,
    required this.isSelected,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = !cell.isEmpty;
    final bool isPlayerEntry = hasValue && !cell.isGiven;
    final bool isError = cell.hasError;

    Color bgColor = CalmPalette.surface;
    Color borderColor = CalmPalette.stroke;

    if (isHighlighted) {
      bgColor = CalmPalette.secondary.withValues(alpha: 0.18);
    }

    if (isSelected) {
      bgColor = CalmPalette.primary.withValues(alpha: 0.35);
      borderColor = CalmPalette.primary;
    }

    if (isError) {
      bgColor = Colors.red.withValues(alpha: 0.25);
      borderColor = Colors.red;
    }

    Color textColor;
    if (!hasValue) {
      textColor = CalmPalette.text;
    } else if (isError) {
      textColor = Colors.red.shade900;
    } else if (cell.isGiven) {
      textColor = CalmPalette.text;
    } else {
      textColor = CalmPalette.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(Spacing.r12 / 3),
        ),
        child: Center(
          child: !hasValue
              ? null
              : Text(
                  '${cell.value}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        cell.isGiven ? FontWeight.w700 : (isPlayerEntry ? FontWeight.w600 : FontWeight.normal),
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final ValueChanged<int> onNumber;
  final VoidCallback onClear;

  const _NumberPad({required this.onNumber, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(9, (index) {
          final number = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 32,
              height: 40,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => onNumber(number),
                child: Text('$number'),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          height: 40,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            onPressed: onClear,
            child: const Icon(Icons.backspace_outlined, size: 20),
          ),
        ),
      ],
    );
  }
}
