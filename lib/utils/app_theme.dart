import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores do Tema Dark
  static const Color darkBackground = Color(0xFF222531);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkNavBar = Color(0xFF3C4052);
  static const Color darkSelectedNavItemBg = Color(0xFFF6F6F6);
  // CORREÇÃO: Cor do ícone/texto selecionado alterada para a que você pediu.
  static const Color darkSelectedNavItemFg = Color(0xFF3C4052); // Foreground (icon/text)
  static const Color darkUnselectedNavItemFg = Color(0xFFFFFFFF);

  // Define o tema escuro completo
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      background: darkBackground,
      primary: darkTextColor, // Cor primária para ícones e elementos ativos
      onBackground: darkTextColor,
      surface: darkNavBar, // Usada para o fundo da navbar
    ),
    textTheme: GoogleFonts.robotoCondensedTextTheme(
      ThemeData.dark().textTheme.copyWith(
            // Estilo para o título principal do cabeçalho
            displayLarge: const TextStyle(
              fontSize: 55, // Ajustado conforme seu feedback
              fontWeight: FontWeight.w500,
              letterSpacing: -2.12,
              color: darkTextColor,
            ),
            // Novo estilo para o texto da navbar
            labelMedium: const TextStyle(
              fontFamily: 'Roboto', // Garante a fonte correta
              fontSize: 17, // Equivalente a 48.93px em uma tela ~3x
              fontWeight: FontWeight.w600, // Medium
              letterSpacing: 0.33,
            ),
          ),
    ),
  );

  // Placeholder para o tema claro (podemos configurar depois)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // ... configurações do tema claro virão aqui
  );
}
