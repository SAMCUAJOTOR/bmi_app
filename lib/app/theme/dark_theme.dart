import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Fitness-app palette (dark): near-black canvas, volt-green accent,
// coral for alerts/highlights — same energy as light mode, inverted.
const Color _volt = Color(0xFFC6FF4E);
const Color _bg = Color(0xFF0C0E10);
const Color _surface = Color(0xFF17191C);
const Color _coral = Color(0xFFFF6A52);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _volt,
    brightness: Brightness.dark,
    primary: _volt,
    onPrimary: _bg,
    secondary: _coral,
    surface: _surface,
  ),
  scaffoldBackgroundColor: _bg,
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1, color: Colors.white),
    headlineLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white),
    headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white),
    titleLarge: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
    titleMedium: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
    labelLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.white),
    bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFE4E6E1)),
    bodyMedium: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFE4E6E1)),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: _surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFF23262A)),
    ),
    margin: EdgeInsets.zero,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2A2D31)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2A2D31)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _volt, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _volt,
      foregroundColor: _bg,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _volt,
      side: const BorderSide(color: _volt, width: 2),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _volt,
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _volt,
    foregroundColor: _bg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1D2024),
    selectedColor: _volt,
    labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    side: BorderSide.none,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 68,
    backgroundColor: _surface,
    indicatorColor: _volt,
    elevation: 0,
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _volt,
    linearTrackColor: Color(0xFF23262A),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFF23262A), thickness: 1),
);
