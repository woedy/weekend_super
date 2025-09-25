import 'package:flutter/material.dart';

import '../constants.dart';

ThemeData buildCookTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.light,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: brandSurface,
    appBarTheme: AppBarTheme(
      backgroundColor: brandSurface,
      elevation: 0,
      centerTitle: false,
      foregroundColor: brandTextPrimary,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: brandTextPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: brandBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: brandSurface,
      selectedColor: brandPrimary.withOpacity(0.18),
      secondarySelectedColor: brandPrimary,
      labelStyle: base.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brandPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandPrimary, width: 1.4),
      ),
    ),
    dividerTheme: const DividerThemeData(space: 32, thickness: 1),
    listTileTheme: base.listTileTheme.copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      titleTextStyle: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: base.textTheme.bodyMedium?.copyWith(color: brandTextSecondary),
    ),
  );
}
