import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum para definir os estilos de card disponíveis
enum CardStyle { colorful, detailed }

class SettingsService with ChangeNotifier {
  static const _cardStyleKey = 'card_style';
  static const _themeModeKey = 'theme_mode'; // Chave para o tema
  static const _coloredIconsKey = 'colored_icons_detailed'; // Nova chave para o toggle

  // O estilo padrão será o colorido
  CardStyle _cardStyle = CardStyle.colorful;
  CardStyle get cardStyle => _cardStyle;

  // O tema padrão será o escuro
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  // O padrão será usar ícones coloridos
  bool _useColoredIcons = true;
  bool get useColoredIcons => _useColoredIcons;

  SettingsService() {
    loadSettings();
  }

  /// Carrega todas as configurações salvas no dispositivo.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Carrega estilo do card
    final styleString = prefs.getString(_cardStyleKey) ?? CardStyle.colorful.name;
    _cardStyle = CardStyle.values.firstWhere((e) => e.name == styleString, orElse: () => CardStyle.colorful);

    // Carrega tema
    final themeString = prefs.getString(_themeModeKey) ?? ThemeMode.dark.name;
    _themeMode = ThemeMode.values.firstWhere((e) => e.name == themeString, orElse: () => ThemeMode.dark);

    // Carrega preferência de ícones coloridos
    _useColoredIcons = prefs.getBool(_coloredIconsKey) ?? true; // Padrão é true

    notifyListeners();
  }

  /// Salva a preferência de estilo no dispositivo.
  Future<void> saveCardStyle(CardStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardStyleKey, style.name);
    _cardStyle = style;
    notifyListeners();
  }

  /// Salva a preferência de tema no dispositivo.
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    _themeMode = mode;
    notifyListeners();
  }

  // Salva a preferência de ícones coloridos
  Future<void> saveColoredIcons(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_coloredIconsKey, value);
    _useColoredIcons = value;
    notifyListeners();
  }

  /// Alterna entre os estilos de card.
  Future<void> toggleCardStyle() async {
    final newStyle = _cardStyle == CardStyle.colorful ? CardStyle.detailed : CardStyle.colorful;
    await saveCardStyle(newStyle);
  }

  /// Alterna entre os temas claro e escuro.
  Future<void> toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await saveThemeMode(newTheme);
  }

  // Alterna a preferência de ícones coloridos
  Future<void> toggleColoredIcons() async {
    await saveColoredIcons(!_useColoredIcons);
  }
}
