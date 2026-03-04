import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'palette.dart';
import 'spacing.dart';

class CalmTheme {
  final ThemeData light;
  final ThemeData dark;

  const CalmTheme({required this.light, required this.dark});

  static CalmTheme build() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: null,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CalmPalette.primary,
        brightness: Brightness.light,
        surface: CalmPalette.surface,
      ),
      scaffoldBackgroundColor: CalmPalette.bg,
    );

    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Spacing.r24),
    );

    return CalmTheme(
      light: base.copyWith(
        textTheme: base.textTheme.apply(
          bodyColor: CalmPalette.text,
          displayColor: CalmPalette.text,
        ),
        cardTheme: CardThemeData(
          color: CalmPalette.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.r24),
            side: const BorderSide(color: CalmPalette.stroke),
          ),
          margin: const EdgeInsets.all(Spacing.s13),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: rounded,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.s21,
              vertical: Spacing.s13,
            ),
            animationDuration: const Duration(milliseconds: Spacing.ms220),
          ),
        ),
      ),
      dark: base.copyWith(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CalmPalette.primary,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

final calmThemeProvider = Provider<CalmTheme>((ref) => CalmTheme.build());
