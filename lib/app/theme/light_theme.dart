import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Fitness-app palette: high-contrast near-black + volt green accent,
// with a hot-coral secondary for warnings/highlights.
const Color _volt = Color(0xFFB6FF3C);
const Color _ink = Color(0xFF14171A);
const Color _coral = Color(0xFFFF5A45);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _volt,
    brightness: Brightness.light,
    primary: _ink,
    onPrimary: _volt,
    secondary: _coral,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF4F5F2),
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1),
    headlineLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
    headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
    titleLarge: TextStyle(fontWeight: FontWeight.w800),
    titleMedium: TextStyle(fontWeight: FontWeight.w700),
    labelLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
    bodyLarge: TextStyle(fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontWeight: FontWeight.w500),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFE9EBE6)),
    ),
    margin: EdgeInsets.zero,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: _ink,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: TextStyle(
      color: _ink,
      fontSize: 22,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE0E2DC)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE0E2DC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _ink, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _ink,
      foregroundColor: _volt,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _ink,
      side: const BorderSide(color: _ink, width: 2),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _ink,
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _volt,
    foregroundColor: _ink,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFEFF1EA),
    selectedColor: _volt,
    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 68,
    backgroundColor: Colors.white,
    indicatorColor: _volt,
    elevation: 0,
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _volt,
    linearTrackColor: Color(0xFFE9EBE6),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFE9EBE6), thickness: 1),
);
