---
description: Safe development practices and verification
---

# Code Safety Rules

## Verification Requirements

### After Every Change

Run these commands after modifying code:

```bash
flutter analyze
flutter test
```

### Before Adding Features

If either command fails:
1. STOP adding new features
2. Fix the failing issues
3. Re-run verification
4. Only then continue

---

## Diff Minimization

### Small Changes

- Make focused, incremental changes
- One logical change per edit
- Avoid reformatting unrelated code

### File Scope

- Touch as few files as possible
- Do not modify files unrelated to the task
- Preserve existing code style

### Import Order

When adding imports:
1. Dart SDK imports first
2. Package imports second
3. Relative imports last
4. Alphabetize within groups

---

## Testing Requirements

### Game Logic

Every game MUST have tests for:
- Core game rules (moves, merges, etc.)
- Win/loss conditions
- Edge cases

### Test Location

```
test/<game_id>_logic_test.dart
```

### Test Structure

```dart
void main() {
  group('<Game> rules', () {
    test('specific rule works', () {
      // Arrange
      // Act
      // Assert
    });
  });

  group('<Game> outcomes', () {
    test('win condition detected', () {
      // ...
    });
  });
}
```

### Deterministic Testing

For games with randomness:
- Use injectable RNG
- Create fake RNG for tests
- Test specific scenarios

---

## Error Handling

### Do Not Swallow Errors

```dart
// BAD
try {
  doSomething();
} catch (_) {}

// GOOD
try {
  doSomething();
} catch (e) {
  debugPrint('Error in doSomething: $e');
  rethrow; // or handle appropriately
}
```

### Null Safety

- Avoid `!` operator when possible
- Use null-aware operators (`?.`, `??`)
- Document when null is expected

---

## State Management

### Immutable State

Game state MUST be immutable:

```dart
class GameState {
  final List<List<int>> board;
  final int score;

  const GameState._({
    required this.board,
    required this.score,
  });

  // Factory constructors for creation
  factory GameState.initial() => // ...
}
```

### No Side Effects in Logic

Logic functions MUST NOT:
- Modify input parameters
- Access global state
- Perform I/O operations

---

## Code Review Checklist

Before completing any task, verify:

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] No new warnings introduced
- [ ] Design tokens used (no magic numbers)
- [ ] Logic separated from UI
- [ ] Tests added for new logic
- [ ] Minimal files changed
- [ ] No duplicate functionality

---

## Recovery Procedures

### Analysis Fails

1. Read error messages carefully
2. Fix one issue at a time
3. Re-run after each fix

### Tests Fail

1. Identify failing test
2. Determine if test or code is wrong
3. Fix root cause
4. Run full test suite

### App Won't Build

```bash
flutter clean
flutter pub get
flutter run
```

### Dependency Issues

```bash
flutter pub outdated
flutter pub upgrade
```
