import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF00796B);
const Color kPrimaryDark = Color(0xFF004D40);
const Color kAccent = Color(0xFFFFB300);
const Color kBackground = Color(0xFFF2F2F0);
const Color kCard = Color(0xFFFAFAF8);
const Color kSobraPositive = Color(0xFF388E3C);
const Color kSobraNegative = Color(0xFFD32F2F);

ThemeData buildTheme() {
  return ThemeData(
    primaryColor: kPrimary,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      accentColor: kAccent,
      backgroundColor: kBackground,
      cardColor: kCard,
    ),
    scaffoldBackgroundColor: kBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kCard,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kAccent,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF212121)),
      bodyMedium: TextStyle(color: Color(0xFF424242)),
      bodySmall: TextStyle(color: Color(0xFF757575)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
