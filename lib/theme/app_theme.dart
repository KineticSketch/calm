import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Colors.lightBlue; // Fresh, light color

  static ThemeData light(ColorScheme? dynamicColorScheme) {
    final scheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }

  static ThemeData dark(ColorScheme? dynamicColorScheme) {
    final baseScheme =
        dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        );

    final scheme = baseScheme.copyWith(
      surface: const Color(0xFF1E1E1E),
      surfaceContainerHighest: const Color(0xFF2D2D2D),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardColor: const Color(0xFF2D2D2D),
    );
  }
}
