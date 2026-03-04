---
description: Implement Flutter UI for a game
---

# /implement-game-ui

**Objective:** Build the game screen using Flutter widgets and design tokens.

---

## Prerequisites

- Game module exists
- Game logic implemented
- Tests passing for logic

---

## Steps

### Step 1: Set up screen state

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';
import 'logic/<game_id>.dart';
import 'logic/rng.dart';

class <GameName>Screen extends StatefulWidget {
  const <GameName>Screen({super.key});

  @override
  State<<GameName>Screen> createState() => _<GameName>ScreenState();
}

class _<GameName>ScreenState extends State<<GameName>Screen> {
  late final <GameName>Logic _logic;
  late <GameName>State _state;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _logic = <GameName>Logic(rng: RandomRng());
    _resetGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _state = _logic.newGame();
    });
  }
}
```

### Step 2: Implement input handling

**Keyboard:**
```dart
KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
  if (event is! KeyDownEvent) return KeyEventResult.ignored;
  
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowUp) {
    _handleMove(MoveDirection.up);
    return KeyEventResult.handled;
  }
  // ... other keys
  
  return KeyEventResult.ignored;
}
```

**Swipe:**
```dart
Offset? _dragStart;
Offset? _dragLatest;

void _handleSwipeGesture() {
  if (_dragStart == null || _dragLatest == null) return;
  final delta = _dragLatest! - _dragStart!;
  if (delta.distance < 20) return;
  
  if (delta.dx.abs() > delta.dy.abs()) {
    _handleMove(delta.dx > 0 ? MoveDirection.right : MoveDirection.left);
  } else {
    _handleMove(delta.dy > 0 ? MoveDirection.down : MoveDirection.up);
  }
}
```

### Step 3: Implement move handler

```dart
void _handleMove(MoveDirection direction) {
  final result = _logic.move(_state, direction);
  if (!mounted) return;
  
  setState(() {
    _state = result.state;
  });
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkGameEnd();
  });
}
```

### Step 4: Build UI structure

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('<Game Name>')),
    body: Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onPanStart: (d) => _dragStart = d.localPosition,
        onPanUpdate: (d) => _dragLatest = d.localPosition,
        onPanEnd: (_) => _handleSwipeGesture(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.s21),
            child: Column(
              children: [
                _Header(state: _state, onNewGame: _resetGame),
                const SizedBox(height: Spacing.s21),
                Expanded(child: _Board(board: _state.board)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
```

### Step 5: Create header widget

```dart
class _Header extends StatelessWidget {
  final <GameName>State state;
  final VoidCallback onNewGame;

  const _Header({required this.state, required this.onNewGame});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s21),
        child: Row(
          children: [
            Text('<Game>', style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            _ScoreChip(value: state.score),
            const SizedBox(width: Spacing.s13),
            FilledButton(onPressed: onNewGame, child: const Text('New Game')),
          ],
        ),
      ),
    );
  }
}
```

### Step 6: Create board widget

```dart
class _Board extends StatelessWidget {
  final List<List<int>> board;

  const _Board({required this.board});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(Spacing.s8),
        decoration: BoxDecoration(
          color: CalmPalette.surface,
          borderRadius: BorderRadius.circular(Spacing.r24),
        ),
        child: // Grid of tiles
      ),
    );
  }
}
```

### Step 7: Implement dialogs

```dart
void _checkGameEnd() {
  if (_state.won) {
    _showWinDialog();
  } else if (_state.lost) {
    _showLoseDialog();
  }
}

Future<void> _showWinDialog() async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.r16),
      ),
      title: const Text('You Win!'),
      content: const Text('Congratulations!'),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            _resetGame();
          },
          child: const Text('Play Again'),
        ),
      ],
    ),
  );
}
```

---

## Verification

// turbo
```bash
flutter analyze
```

// turbo
```bash
flutter test
```

```bash
flutter run -d chrome
```

Test:
- [ ] Keyboard input works
- [ ] Touch/swipe input works
- [ ] Score updates
- [ ] New game resets state
- [ ] Win dialog appears
- [ ] Lose dialog appears

---

## Commit Guidance

```
Implement <game_id> UI

- Add game screen with header and board
- Handle keyboard and swipe input
- Display score and game state
- Show win/lose dialogs
```

---

## Checklist

- [ ] Uses design tokens (Spacing, CalmPalette)
- [ ] No hardcoded colors or spacing
- [ ] Keyboard input handled
- [ ] Touch/swipe input handled
- [ ] Score displayed
- [ ] New game button works
- [ ] Win dialog shows
- [ ] Lose dialog shows
- [ ] Animations use `Spacing.ms*` durations
- [ ] `flutter analyze` passes
