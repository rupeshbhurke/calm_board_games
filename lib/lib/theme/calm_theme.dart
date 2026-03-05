import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'palette.dart';
import 'spacing.dart';

class CalmTheme {
  final ThemeData light;
  final ThemeData dark;

  const CalmTheme({required this.light, required this.dark});

  static CalmTheme build() {
    return CalmTheme(
      light: _buildTheme(Brightness.light),
      dark: _buildTheme(Brightness.dark),
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CalmPalette.primary,
        brightness: brightness,
        surface: CalmPalette.surface,
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F1216) : CalmPalette.bg,
    );

    final textColor = isDark ? Colors.white : CalmPalette.text;
    final cardColor = isDark ? const Color(0xFF1C2025) : CalmPalette.surface;
    final appBarColor = isDark ? const Color(0xFF15191D) : CalmPalette.bg;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : CalmPalette.stroke;

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.r24),
          side: BorderSide(color: borderColor),
        ),
        margin: const EdgeInsets.only(bottom: Spacing.s21),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor:
              isDark ? CalmPalette.accent : CalmPalette.primary,
          foregroundColor: isDark ? Colors.black : CalmPalette.text,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.r16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.s21,
            vertical: Spacing.s13,
          ),
          animationDuration: const Duration(milliseconds: Spacing.ms220),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      dividerColor: borderColor,
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.r16),
        ),
        tileColor: cardColor,
        textColor: textColor,
      ),
    );
  }
}

final calmThemeProvider = Provider<CalmTheme>((ref) => CalmTheme.build());
