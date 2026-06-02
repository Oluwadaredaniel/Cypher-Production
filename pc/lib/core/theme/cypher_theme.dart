import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class CypherTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: CypherColors.primary,
      scaffoldBackgroundColor: CypherColors.primaryBackground,
      cardColor: CypherColors.secondaryBackground,
      dividerColor: CypherColors.defaultBorder,

      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: CypherColors.primaryText,
            height: 1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: CypherColors.primaryText,
            height: 1.3,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CypherColors.primaryText,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: CypherColors.primaryText,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: CypherColors.secondaryText,
            height: 1.5,
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: CypherColors.tertiaryText,
            height: 1.4,
          ),
        ),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(CypherColors.tertiaryText.withOpacity(0.3)),
        trackColor: MaterialStateProperty.all(Colors.transparent),
        radius: const Radius.circular(4),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CypherColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CypherColors.primaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CypherColors.defaultBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CypherColors.defaultBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CypherColors.primary),
        ),
        hintStyle: const TextStyle(
          color: CypherColors.tertiaryText,
          fontSize: 14,
        ),
      ),
    );
  }
}
