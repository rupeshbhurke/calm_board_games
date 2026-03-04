import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/calm_theme.dart';
import '../games/registry/game_registry.dart';
import '../hub/home_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(calmThemeProvider);
    final registry = ref.watch(gameRegistryProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calm Board Suite',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: ThemeMode.system,
      home: HomeScreen(registry: registry),
    );
  }
}
