import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores do Tema Dark
  static const Color darkBackground = Color(0xFF222531);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkHeaderBg = Color(0xFF222531);
  static const Color darkNavBar = Color(0xFF3C4052);
  static const Color darkSelectedNavItemBg = Color(0xFFF6F6F6);
  static const Color darkSelectedNavItemFg = Color(0xFF3C4052);
  static const Color darkUnselectedNavItemFg = Color(0xFFFFFFFF);
  static const Color darkFab1 = Color(0xFF64697D);
  static const Color darkFab2 = Color(0xFF3C4052);
  static const Color darkFabIcon = Color(0xFFFFFFFF);

  // Cores do Tema Light
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightTextColor = Color(0xFF3C4052);
  static const Color lightHeaderBg = Color(0xFFFFFFFF);
  static const Color lightNavBar = Color(0xFFFFFFFF);
  static const Color lightSelectedNavItemBg = Color(0xFF3C4052);
  static const Color lightSelectedNavItemFg = Color(0xFFFFFFFF);
  static const Color lightUnselectedNavItemFg = Color(0xFF3C4052);
  static const Color lightFab = Color(0xFFFFFFFF);
  static const Color lightFabIcon = Color(0xFF3C4052);
  static const Color lightVectorColor = Color(0xFF3C4052);
  // CORREÇÃO: Cores base para o gradiente agora são opacas.
  // A opacidade será aplicada diretamente no widget do card.
  static const Color lightDetailedCardBg1 = Color(0xFFFFFFFF);
  static const Color lightDetailedCardBg2 = Color(0xFFFFFFFF);

  // Define o tema escuro completo
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      background: darkBackground,
      primary: darkTextColor,
      onBackground: darkTextColor,
      surface: darkNavBar,
    ),
    // CORREÇÃO: Primeiro, criamos o tema de texto base com Roboto.
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
      // Em seguida, sobrescrevemos APENAS os estilos específicos que queremos diferentes.
      displayLarge: GoogleFonts.robotoCondensed(
        fontSize: 55,
        fontWeight: FontWeight.w500,
        letterSpacing: -2.12,
        color: darkTextColor,
      ),
      labelMedium: GoogleFonts.robotoCondensed(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.33,
      ),
    ),
  );

  // Define o tema claro completo
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      background: lightBackground,
      primary: lightTextColor,
      onBackground: lightTextColor,
      surface: lightNavBar,
    ),
    // CORREÇÃO: Primeiro, criamos o tema de texto base com Roboto.
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme).copyWith(
      // Em seguida, sobrescrevemos APENAS os estilos específicos que queremos diferentes.
      displayLarge: GoogleFonts.robotoCondensed(
        fontSize: 55,
        fontWeight: FontWeight.w500,
        letterSpacing: -2.12,
        color: lightTextColor,
      ),
      labelMedium: GoogleFonts.robotoCondensed(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.33,
      ),
    ),
  );
}
