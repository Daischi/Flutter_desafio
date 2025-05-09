import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData get lightTheme {
  final base = ThemeData.light();
  final colorScheme = ColorScheme.light(
    primary: const Color(0xFFFF6F00), // Laranja vibrante
    secondary: const Color(0xFFFFA040), // Laranja claro
    tertiary: const Color(0xFFFFC107), // Amarelo/laranja
    surface: const Color(0xFFFFF8F1), // Bege claro
    background: const Color(0xFFFFF3E0), // Laranja muito claro
    error: const Color(0xFFD32F2F),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onTertiary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    outline: const Color(0xFFB0BEC5),
  );

  return base.copyWith(
    useMaterial3: true,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: colorScheme.onSurface),
      hintStyle: TextStyle(color: colorScheme.outline),
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData get darkTheme {
  final base = ThemeData.dark();
  final colorScheme = ColorScheme.dark(
    primary: const Color(0xFFFFA040), // Laranja mais suave no dark
    secondary: const Color(0xFFFF6F00), // Laranja forte
    tertiary: const Color(0xFFFFC107), // Amarelo/laranja
    surface: const Color(0xFF1C1C1E),
    background: const Color(0xFF121212),
    error: const Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.white,
    onTertiary: Colors.black,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.black,
    outline: const Color(0xFF37474F),
  );

  return base.copyWith(
    useMaterial3: true,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: colorScheme.onSurface),
      hintStyle: TextStyle(color: colorScheme.outline),
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
