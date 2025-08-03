import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum para definir os estilos de card disponíveis
enum CardStyle { colorful, detailed }

class SettingsService with ChangeNotifier {
  static const _cardStyleKey = 'card_style';

  // O estilo padrão será o colorido
  CardStyle _cardStyle = CardStyle.colorful;
  CardStyle get cardStyle => _cardStyle;

  SettingsService() {
    loadCardStyle();
  }

  /// Carrega a preferência de estilo salva no dispositivo.
  Future<void> loadCardStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final styleString = prefs.getString(_cardStyleKey) ?? CardStyle.colorful.name;
    _cardStyle = CardStyle.values.firstWhere((e) => e.name == styleString, orElse: () => CardStyle.colorful);
    notifyListeners();
  }

  /// Salva a preferência de estilo no dispositivo.
  Future<void> saveCardStyle(CardStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardStyleKey, style.name);
    _cardStyle = style;
    notifyListeners();
  }

  /// Alterna entre os estilos de card.
  Future<void> toggleCardStyle() async {
    final newStyle = _cardStyle == CardStyle.colorful ? CardStyle.detailed : CardStyle.colorful;
    await saveCardStyle(newStyle);
  }
}
