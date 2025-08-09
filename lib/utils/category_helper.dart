import 'package:flutter/material.dart';
import '../models/racha_model.dart';
import '../services/settings_service.dart'; // Importado para ter acesso ao CardStyle
import '../utils/app_theme.dart'; // Importado para cores do tema

/// Uma classe de ajuda para centralizar a lógica de estilo das categorias.
/// Mapeia cada categoria a uma cor e um caminho de ícone específicos.
class CategoryHelper {
  // A variável booleana estática foi removida daqui.
  // A decisão agora é passada como um parâmetro na função getIconColor.

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

  /// Retorna o caminho do asset do ÍCONE para a categoria do racha.
  static String getImagePath(RachaCategory category) {
    switch (category) {
      case RachaCategory.comidaEBebida:
        return 'assets/images/icon_cat_comida.svg';
      case RachaCategory.casaEContas:
        return 'assets/images/icon_cat_casa.svg';
      case RachaCategory.lazerEEventos:
        return 'assets/images/icon_cat_lazer.svg';
      case RachaCategory.transporte:
        return 'assets/images/icon_cat_transporte.svg';
      case RachaCategory.viagens:
        return 'assets/images/icon_cat_viagens.svg';
      case RachaCategory.outros:
      default:
        return 'assets/images/icon_cat_outros.svg';
    }
  }

  /// Retorna a cor do ícone com base no estilo do card, no tema e na configuração do usuário.
  static Color getIconColor({
    required RachaCategory category,
    required CardStyle style,
    required bool isLightTheme,
    required bool useColoredIcons, // Parâmetro que vem do SettingsService
  }) {
    // Se o card for do estilo "colorido", o ícone sempre terá a cor do texto.
    if (style == CardStyle.colorful) {
      return isLightTheme ? const Color(0xFF303030) : const Color(0xFF222531);
    }
    // Se o card for do estilo "detalhado"...
    else {
      // ...a cor dependerá do valor do toggle passado como parâmetro.
      if (useColoredIcons) {
        // Se TRUE, usa a cor da categoria.
        return getColor(category);
      } else {
        // Se FALSE, usa a cor do texto padrão do tema.
        return isLightTheme ? AppTheme.lightTextColor : Colors.white;
      }
    }
  }

  /// Retorna o tamanho (largura e altura) do ícone para cada categoria.
  static Size getIconSize(RachaCategory category) {
    switch (category) {
      case RachaCategory.transporte:
        return const Size(32, 32); // Exemplo de um ícone um pouco maior
      case RachaCategory.viagens:
        return const Size(32, 32); // Exemplo de um ícone um pouco menor
      // Para os outros, usamos um tamanho padrão.
      case RachaCategory.comidaEBebida:
        return const Size(32, 32); // Exemplo de um ícone um pouco maior
      case RachaCategory.casaEContas:
        return const Size(32, 32); // Exemplo de um ícone um pouco maior
      case RachaCategory.lazerEEventos:
        return const Size(28, 28); // Exemplo de um ícone um pouco maior
      case RachaCategory.outros:
      default:
        return const Size(32, 32); // Tamanho padrão
    }
  }
}
