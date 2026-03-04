---
description: Analyze a Flutter game module for compliance
---

# Skill: Analyze Flutter Module

**Purpose:** Check if a game module follows project conventions.

---

## Usage

When asked to analyze or review a game module, follow these steps.

---

## Step 1: Check module structure

Verify the folder structure:

```
lib/lib/games/<game_id>/
├── <game_id>_module.dart      ✓ Required
├── <game_id>_screen.dart      ✓ Required
└── logic/
    └── <game_id>.dart         ✓ Required (if game has rules)
```

**Report:** List missing files.

---

## Step 2: Check GameModule implementation

In `<game_id>_module.dart`, verify:

- [ ] Implements `GameModule` interface
- [ ] Has `const` constructor
- [ ] `metadata` returns `GameMetadata` with:
  - `id`: snake_case
  - `title`: Display name
  - `tagline`: Short description
  - `category`: Valid `GameCategory`
- [ ] `buildGameScreen()` returns widget

---

## Step 3: Check logic separation

In `logic/` files, verify:

- [ ] NO `package:flutter` imports
- [ ] NO `dart:ui` imports
- [ ] State classes are immutable
- [ ] Logic methods return new state

---

## Step 4: Check design token usage

In screen files, verify:

- [ ] Imports `design/tokens.dart`
- [ ] Uses `Spacing.*` for spacing
- [ ] Uses `CalmPalette.*` for colors
- [ ] Uses `Spacing.r*` for radii
- [ ] No hardcoded numeric values for spacing

---

## Step 5: Check registration

In `lib/lib/games/registry/game_registry.dart`:

- [ ] Module is imported
- [ ] Module is in `modules` list

---

## Step 6: Check tests

In `test/`:

- [ ] Test file exists: `<game_id>_logic_test.dart`
- [ ] Tests cover core rules
- [ ] Tests use deterministic RNG (if applicable)

---

## Output Format

```markdown
## Module Analysis: <game_id>

### Structure
- [x] Module file exists
- [x] Screen file exists
- [ ] Logic folder exists ← Missing

### GameModule Implementation
- [x] Implements interface
- [x] Has const constructor
- [x] Valid metadata

### Logic Separation
- [x] No Flutter imports
- [x] Immutable state

### Design Tokens
- [x] Uses Spacing
- [ ] Hardcoded color found ← Line 45

### Registration
- [x] Registered in GameRegistry

### Tests
- [x] Test file exists
- [x] Core rules tested

### Summary
2 issues found. See details above.
```
