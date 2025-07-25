import 'package:flutter/material.dart';

// Uma classe simples para gerar cores consistentes para os participantes.
class ColorHelper {
  // **NOVA PALETA DE CORES VIBRANTE E COM ALTO CONTRASTE**
  static const List<Color> avatarColors = [
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF795548), // Brown
  ];

  // Gera uma cor baseada no nome da pessoa.
  // O mesmo nome sempre resultará na mesma cor.
  static Color getColorForName(String name) {
    // Usa o hashCode do nome para escolher uma cor da lista de forma determinística.
    final index = name.hashCode % avatarColors.length;
    return avatarColors[index];
  }
}
