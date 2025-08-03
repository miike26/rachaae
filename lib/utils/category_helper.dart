import 'package:flutter/material.dart';
import '../models/racha_model.dart';

/// Uma classe de ajuda para centralizar a lógica de estilo das categorias.
/// Mapeia cada categoria a uma cor e um caminho de imagem específicos.
class CategoryHelper {
  /// Retorna uma cor de fundo específica baseada na categoria do racha.
  static Color getColor(RachaCategory category) {
    switch (category) {
      case RachaCategory.comidaEBebida:
        return const Color(0xFFFDD94F);
      case RachaCategory.casaEContas:
        return const Color(0xFF84E5FB);
      case RachaCategory.lazerEEventos:
        return const Color(0xFFC7A0FF);
      case RachaCategory.transporte:
        return const Color(0xFFFF9B61);
      case RachaCategory.viagens:
        return const Color(0xFFABF155);
      case RachaCategory.outros:
      default:
        return const Color(0xFFBDBDBD); // Cinza
    }
  }

  /// Retorna o caminho do asset da imagem para a categoria do racha.
  static String getImagePath(RachaCategory category) {
    // Por enquanto, usa o mesmo SVG para todas as categorias, exceto "Outros".
    // No futuro, você pode criar SVGs específicos para cada um.
    switch (category) {
      case RachaCategory.comidaEBebida:
        return 'assets/images/cat_comida.svg';
      case RachaCategory.casaEContas:
        return 'assets/images/cat_comida.svg'; // Usando o mesmo SVG
      case RachaCategory.lazerEEventos:
        return 'assets/images/cat_comida.svg'; // Usando o mesmo SVG
      case RachaCategory.transporte:
        return 'assets/images/cat_comida.svg'; // Usando o mesmo SVG
      case RachaCategory.viagens:
        return 'assets/images/cat_comida.svg'; // Usando o mesmo SVG
      case RachaCategory.outros:
      default:
        // Pode retornar um SVG genérico ou um caminho vazio se não quiser ícone para "Outros"
        return 'assets/images/cat_outros.svg';
    }
  }

  /// Retorna a cor específica para a marca d'água SVG.
  static Color getSvgColor(RachaCategory category) {
    switch (category) {
      case RachaCategory.comidaEBebida:
        return const Color(0xFFF5782C);
      case RachaCategory.casaEContas:
        return const Color(0xFF5592BF);
      case RachaCategory.lazerEEventos:
        return const Color(0xFF846AD5);
      case RachaCategory.transporte:
        return const Color(0xFFFF5F3B);
      case RachaCategory.viagens:
        return const Color(0xFF5FB92F);
      case RachaCategory.outros:
      default:
        // Retorna uma cor transparente se a categoria não tiver uma cor de SVG definida.
        return Colors.transparent;
    }
  }
}
