import 'package:flutter/material.dart';

/// Temporary colors. Change them all here later, nothing else needs editing.
class AppColors {
  static const purple = Color(0xFF6C5CE7);
  static const pink = Color(0xFFFF8FB1);
  static const sun = Color(0xFFFFD27D);
  static const lavender = Color(0xFFF3EEFF);
  static const peach = Color(0xFFFFF1E6);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.purple);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lavender,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
