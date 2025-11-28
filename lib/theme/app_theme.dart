import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Colors.lightBlue; // Fresh, light color

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: _seedColor,
            brightness: Brightness.dark,
          ).copyWith(
            surface: const Color(0xFF1E1E1E),
            surfaceContainerHighest: const Color(0xFF2D2D2D),
          ),
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardColor: const Color(0xFF2D2D2D),
    );
  }
}
