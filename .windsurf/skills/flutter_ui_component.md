---
description: Create a Flutter UI component using design tokens
---

# Skill: Flutter UI Component

**Purpose:** Build UI components that follow project design system.

---

## Principles

1. **Use design tokens** — Never hardcode spacing or colors
2. **Const constructors** — Maximize const usage
3. **Widget extraction** — Keep widgets small and focused
4. **Accessibility** — Consider text scaling and touch targets

---

## Import Pattern

```dart
import 'package:flutter/material.dart';
import '../../design/tokens.dart';
```

This gives access to:
- `Spacing` — Spacing values, radii, durations
- `CalmPalette` — Color values

---

## Component Template

```dart
class MyComponent extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const MyComponent({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.s21),
        decoration: BoxDecoration(
          color: CalmPalette.surface,
          borderRadius: BorderRadius.circular(Spacing.r16),
          border: Border.all(color: CalmPalette.stroke),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
```

---

## Spacing Reference

```dart
// Spacing values
Spacing.s8   // 8px  - Tight
Spacing.s13  // 13px - Default
Spacing.s21  // 21px - Comfortable
Spacing.s34  // 34px - Section

// Border radii
Spacing.r12  // 12px - Small
Spacing.r16  // 16px - Medium
Spacing.r24  // 24px - Large

// Animation durations
Spacing.ms180  // 180ms - Quick
Spacing.ms220  // 220ms - Standard
Spacing.ms260  // 260ms - Smooth
```

---

## Color Reference

```dart
CalmPalette.bg        // Background
CalmPalette.surface   // Cards, containers
CalmPalette.text      // Primary text
CalmPalette.subtext   // Secondary text
CalmPalette.primary   // Soft teal
CalmPalette.secondary // Mint
CalmPalette.accent    // Peach
CalmPalette.stroke    // Borders
```

---

## Card Component

```dart
Card(
  margin: EdgeInsets.zero,
  child: Padding(
    padding: const EdgeInsets.all(Spacing.s21),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Spacing.s8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  ),
)
```

---

## Button Patterns

**Primary action:**
```dart
FilledButton(
  onPressed: onAction,
  child: const Text('Action'),
)
```

**Secondary action:**
```dart
TextButton(
  onPressed: onAction,
  child: const Text('Cancel'),
)
```

---

## Animated Container

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: Spacing.ms180),
  padding: const EdgeInsets.all(Spacing.s13),
  decoration: BoxDecoration(
    color: isActive ? CalmPalette.primary : CalmPalette.surface,
    borderRadius: BorderRadius.circular(Spacing.r16),
  ),
  child: child,
)
```

---

## Dialog Pattern

```dart
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Spacing.r16),
  ),
  title: Text(title),
  content: Text(message),
  actions: [
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'),
    ),
    FilledButton(
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm();
      },
      child: const Text('Confirm'),
    ),
  ],
)
```

---

## Grid Layout

```dart
AspectRatio(
  aspectRatio: 1,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final tileSize = (constraints.maxWidth - Spacing.s8 * 5) / 4;
      return Container(
        padding: const EdgeInsets.all(Spacing.s8),
        decoration: BoxDecoration(
          color: CalmPalette.surface,
          borderRadius: BorderRadius.circular(Spacing.r24),
        ),
        child: Column(
          children: List.generate(4, (r) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: r < 3 ? Spacing.s8 : 0,
              ),
              child: Row(
                children: List.generate(4, (c) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: c < 3 ? Spacing.s8 : 0,
                    ),
                    child: _Tile(size: tileSize),
                  );
                }),
              ),
            );
          }),
        ),
      );
    },
  ),
)
```

---

## Checklist

- [ ] Uses `Spacing.*` for all spacing
- [ ] Uses `CalmPalette.*` for all colors
- [ ] Uses `Spacing.r*` for radii
- [ ] Uses `Spacing.ms*` for durations
- [ ] Has `const` constructor
- [ ] Uses theme text styles
- [ ] Handles null callbacks safely
- [ ] Touch target >= 48x48
