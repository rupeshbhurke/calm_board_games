---
description: Flutter-specific project conventions
---

# Flutter Project Rules

## Project Structure

### Entry Point

```dart
// lib/main.dart
void main() {
  runApp(const ProviderScope(child: CalmBoardApp()));
}
```

### App Shell

- `lib/lib/app/app_shell.dart` — MaterialApp wrapper
- Uses `ConsumerWidget` for Riverpod integration
- Applies theme from `calmThemeProvider`

---

## State Management

### Riverpod Providers

Use Riverpod for global state:

```dart
final myProvider = Provider<MyType>((ref) {
  return MyType();
});
```

### Local State

Use `StatefulWidget` for game screen state:

```dart
class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}
```

### State Updates

```dart
setState(() {
  _state = newState;
});
```

---

## Widget Conventions

### Const Constructors

Always use `const` when possible:

```dart
const MyWidget({super.key});
```

### Key Usage

Use keys for dynamic lists:

```dart
ListView.builder(
  itemBuilder: (context, index) => MyItem(
    key: ValueKey(items[index].id),
  ),
)
```

### Widget Extraction

Extract widgets when:
- Widget is > 50 lines
- Widget is reused
- Widget has its own state

---

## Navigation

### Current Pattern

Simple `Navigator.push`:

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => GameScreen()),
);
```

### Back Navigation

Handle back button:

```dart
Navigator.of(context).pop();
```

---

## Theme Usage

### Accessing Theme

```dart
final theme = Theme.of(context);
final textStyle = theme.textTheme.titleLarge;
final colorScheme = theme.colorScheme;
```

### Custom Theme Data

Access via provider:

```dart
final calmTheme = ref.watch(calmThemeProvider);
```

---

## Input Handling

### Keyboard

```dart
Focus(
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent) {
      // Handle key
    }
    return KeyEventResult.handled;
  },
  child: // ...
)
```

### Gestures

```dart
GestureDetector(
  onPanStart: (details) { /* ... */ },
  onPanUpdate: (details) { /* ... */ },
  onPanEnd: (details) { /* ... */ },
  child: // ...
)
```

---

## Asset Management

### Declaring Assets

In `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

### Loading Assets

```dart
Image.asset('assets/images/image.png')
```

---

## Platform Considerations

### Web

- Use semantic HTML where possible
- Test in Chrome
- Consider hover states

### Android

- Test on emulator and device
- Handle back button
- Consider different screen sizes

---

## Performance

### Build Optimization

- Use `const` widgets
- Avoid rebuilds with `select` in Riverpod
- Use `RepaintBoundary` for expensive widgets

### Animation

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: Spacing.ms180),
  // properties
)
```

---

## Debugging

### Debug Print

```dart
debugPrint('Message: $variable');
```

### DevTools

```bash
flutter run --debug
# Open DevTools from terminal output
```

---

## DO NOT

- Use `print()` in production code
- Ignore `flutter analyze` warnings
- Skip null safety
- Use deprecated widgets
- Hardcode strings (use constants)
