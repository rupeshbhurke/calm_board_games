---
description: Code review checklist for pull requests
---

# /review-pr

**Objective:** Systematically review code changes for quality and consistency.

---

## Review Process

### Step 1: Understand the change

1. Read PR description
2. Identify files changed
3. Understand the purpose

### Step 2: Check architecture compliance

- [ ] Game modules in correct location (`lib/lib/games/<game_id>/`)
- [ ] Logic separated from UI (no Flutter in `logic/` dirs)
- [ ] Module implements `GameModule` interface
- [ ] Registration in `GameRegistry` only

### Step 3: Check design system usage

- [ ] Uses `Spacing.*` for all spacing values
- [ ] Uses `CalmPalette.*` for all colors
- [ ] Uses `Spacing.r*` for border radii
- [ ] Uses `Spacing.ms*` for animation durations
- [ ] Imports from `design/tokens.dart`

### Step 4: Check code quality

- [ ] No code duplication
- [ ] Immutable state classes
- [ ] No side effects in logic
- [ ] Proper error handling
- [ ] Clear naming conventions

### Step 5: Check tests

- [ ] Tests exist for new logic
- [ ] Tests cover edge cases
- [ ] Tests use deterministic RNG
- [ ] All tests pass

### Step 6: Run verification

// turbo
```bash
flutter analyze
```

// turbo
```bash
flutter test
```

---

## Common Issues

### Architecture Violations

**Problem:** Flutter imports in logic files
```dart
// BAD
import 'package:flutter/material.dart';
```

**Fix:** Remove Flutter imports, use pure Dart

---

**Problem:** Game not registered
```dart
// Missing in game_registry.dart
modules: const [
  // MyGameModule() not here
],
```

**Fix:** Add module to registry

---

### Design System Violations

**Problem:** Hardcoded values
```dart
// BAD
padding: EdgeInsets.all(16),
color: Color(0xFF123456),
```

**Fix:** Use tokens
```dart
// GOOD
padding: EdgeInsets.all(Spacing.s13),
color: CalmPalette.primary,
```

---

### Testing Issues

**Problem:** Non-deterministic tests
```dart
// BAD
final logic = GameLogic(); // Uses real RNG
```

**Fix:** Inject fake RNG
```dart
// GOOD
final logic = GameLogic(rng: _FakeRng(ints: [0, 1]));
```

---

## Review Feedback Template

### Approval

```
✅ LGTM

- Architecture: Correct
- Design tokens: Used consistently
- Tests: Passing
- Analysis: Clean
```

### Request Changes

```
⚠️ Changes requested

**Architecture:**
- [ ] Issue 1

**Design System:**
- [ ] Issue 2

**Tests:**
- [ ] Issue 3

Please address and re-request review.
```

---

## Verification Commands

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
