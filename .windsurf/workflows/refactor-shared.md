---
description: Extract shared code to common utilities
---

# /refactor-shared

**Objective:** Extract duplicated or reusable code to shared locations.

---

## When to Refactor

- Same pattern appears in 2+ games
- Code is generic (not game-specific)
- Logic could benefit other games
- UI component is reusable

---

## Steps

### Step 1: Identify the pattern

1. Find duplicated code across files
2. Determine if it's truly generic
3. Plan the shared interface

### Step 2: Determine location

| Type | Destination |
|------|-------------|
| UI Widget | `lib/lib/ui/<category>/` |
| UI Helper | `lib/lib/ui/helpers/` |
| Game Logic | `lib/lib/engine/` |
| Utilities | `lib/lib/utils/` |

### Step 3: Create shared component

**For UI:**
```dart
// lib/lib/ui/shared/score_chip.dart
import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class ScoreChip extends StatelessWidget {
  final String label;
  final int value;

  const ScoreChip({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.s13,
        vertical: Spacing.s8,
      ),
      decoration: BoxDecoration(
        color: CalmPalette.secondary,
        borderRadius: BorderRadius.circular(Spacing.r16),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
```

**For Logic:**
```dart
// lib/lib/engine/grid_utils.dart
// Pure Dart - NO Flutter

class GridUtils {
  static List<List<T>> clone<T>(List<List<T>> grid) {
    return [for (final row in grid) List<T>.from(row)];
  }

  static List<List<T>> freeze<T>(List<List<T>> grid) {
    return List.unmodifiable(
      grid.map((row) => List.unmodifiable(row)),
    );
  }

  static bool hasEmpty<T>(List<List<T>> grid, T emptyValue) {
    for (final row in grid) {
      for (final cell in row) {
        if (cell == emptyValue) return true;
      }
    }
    return false;
  }
}
```

### Step 4: Update existing usages

1. Find all files using the duplicated code
2. Replace with import to shared component
3. Remove duplicated code

```dart
// Before
class _ScoreChip extends StatelessWidget { ... }

// After
import '../../ui/shared/score_chip.dart';
// Use ScoreChip directly
```

### Step 5: Add tests for shared code

```dart
// test/engine/grid_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:calm_board_games/lib/engine/grid_utils.dart';

void main() {
  group('GridUtils', () {
    test('clone creates independent copy', () {
      final original = [[1, 2], [3, 4]];
      final cloned = GridUtils.clone(original);
      
      cloned[0][0] = 99;
      
      expect(original[0][0], 1); // Original unchanged
    });
  });
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

Verify all games still work:
```bash
flutter run -d chrome
```

---

## Commit Guidance

```
Extract <component> to shared utilities

- Create lib/lib/<location>/<component>.dart
- Update <game1> to use shared component
- Update <game2> to use shared component
- Add tests for shared component
```

---

## Checklist

- [ ] Pattern is truly generic (not game-specific)
- [ ] Shared code in correct location
- [ ] All usages updated to import shared code
- [ ] Duplicated code removed
- [ ] Tests added for shared code
- [ ] All existing tests pass
- [ ] `flutter analyze` passes
- [ ] All games still work

---

## Common Refactoring Targets

### UI Components

| Candidate | Signs of Duplication |
|-----------|---------------------|
| ScoreChip | Score display in multiple games |
| GameDialog | Win/lose dialogs similar |
| TileWidget | Grid tiles with similar styling |

### Logic Utilities

| Candidate | Signs of Duplication |
|-----------|---------------------|
| GridUtils | Board cloning, freezing |
| RNG | Random number generation |
| DirectionHelpers | Direction enums, processing |
