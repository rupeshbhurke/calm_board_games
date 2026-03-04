---
description: UI design tokens and styling rules
---

# UI Design Rules

## Design Tokens

### Required Usage

All UI code MUST use design tokens for:
- Spacing (padding, margin, gaps)
- Border radii
- Animation durations
- Colors

### Import Pattern

```dart
import '../../design/tokens.dart';
// Exports: Spacing, CalmPalette
```

### Spacing Scale

Use ONLY these spacing values:

| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.s8` | 8px | Tight spacing |
| `Spacing.s13` | 13px | Default spacing |
| `Spacing.s21` | 21px | Comfortable spacing |
| `Spacing.s34` | 34px | Section spacing |

### Border Radii

| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.r12` | 12px | Small elements |
| `Spacing.r16` | 16px | Buttons, tiles |
| `Spacing.r24` | 24px | Cards, containers |

### Animation Durations

| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.ms180` | 180ms | Quick transitions |
| `Spacing.ms220` | 220ms | Standard transitions |
| `Spacing.ms260` | 260ms | Smooth transitions |

---

## Color Palette

### Available Colors

```dart
CalmPalette.bg        // Background (#F7F7F9)
CalmPalette.surface   // Cards (#FFFFFF)
CalmPalette.text      // Primary text (#2E2E33)
CalmPalette.subtext   // Secondary text (#5C5C66)
CalmPalette.primary   // Soft teal (#A8DADC)
CalmPalette.secondary // Mint (#B8E0D2)
CalmPalette.accent    // Peach (#FFD6A5)
CalmPalette.stroke    // Borders (#E8E8EE)
```

### DO NOT

- Hardcode hex colors in widgets
- Create new color constants per game
- Use Material colors directly (prefer palette)

---

## UI Patterns

### Card Style

```dart
Card(
  margin: EdgeInsets.zero,
  child: Padding(
    padding: const EdgeInsets.all(Spacing.s21),
    child: // content
  ),
)
```

### Button Style

Use `FilledButton` for primary actions:

```dart
FilledButton(
  onPressed: onAction,
  child: const Text('Action'),
)
```

### Dialogs

```dart
AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Spacing.r16),
  ),
  title: Text(title),
  content: Text(message),
  actions: [
    TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
    FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
  ],
)
```

---

## Accessibility

### Text Scaling

- Use `Theme.of(context).textTheme` for text styles
- Avoid fixed font sizes when possible

### Touch Targets

- Minimum touch target: 48x48 pixels
- Use padding to achieve minimum size

### Color Contrast

- Text on surface: Use `CalmPalette.text`
- Text on colored backgrounds: Ensure sufficient contrast

---

## Responsive Design

### Layout Approach

- Use `LayoutBuilder` for responsive layouts
- Prefer `Expanded` and `Flexible` over fixed sizes
- Use `AspectRatio` for game boards

### Breakpoints

- Mobile: < 600px
- Tablet: 600-1200px
- Desktop: > 1200px

---

## DO NOT

- Use magic numbers for spacing
- Create inline color definitions
- Skip design tokens
- Use deprecated Flutter widgets
- Ignore text scaling
