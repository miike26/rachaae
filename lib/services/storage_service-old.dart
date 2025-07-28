import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/racha_model.dart';

class StorageService {
  static const _rachasKey = 'rachas_list';
  // Nova chave para o nome do usuário.
  static const _userNameKey = 'user_name';

  Future<void> saveRachas(List<Racha> rachas) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> rachasJson = rachas.map((racha) => racha.toJson()).toList();
    final String encodedData = jsonEncode(rachasJson);
    await prefs.setString(_rachasKey, encodedData);
  }

  Future<List<Racha>> loadRachas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_rachasKey);

    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData.map((json) => Racha.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // **NOVAS FUNÇÕES**
  // Salva o nome do usuário.
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Carrega o nome do usuário. Se não houver, retorna "Você" como padrão.
  Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Você';
  }
}
