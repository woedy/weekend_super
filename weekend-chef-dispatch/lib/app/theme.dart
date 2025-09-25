import 'package:flutter/material.dart';

ThemeData buildTheme() {
  const seedColor = Color(0xFF3C6E71);
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    chipTheme: ChipThemeData.fromDefaults(
      secondaryColor: colorScheme.primary,
      brightness: Brightness.light,
      labelStyle: const TextStyle(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
