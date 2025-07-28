import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/racha_model.dart';
import 'racha_repository.dart';

/// Implementação do [RachaRepository] que usa SharedPreferences para
/// salvar os dados localmente no dispositivo.
class LocalStorageRepository implements RachaRepository {
  static const _rachasKey = 'rachas_list';
  static const _userNameKey = 'user_name';

  /// Salva a lista completa de rachas no armazenamento.
  /// Este é um método privado, pois a interface agora lida com operações individuais.
  Future<void> _saveAllRachas(List<Racha> rachas) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> rachasJson =
        rachas.map((racha) => racha.toJson()).toList();
    final String encodedData = jsonEncode(rachasJson);
    await prefs.setString(_rachasKey, encodedData);
  }

  @override
  Future<List<Racha>> getRachas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_rachasKey);

    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData
          .map((json) => Racha.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<void> saveRacha(Racha racha) async {
    final rachas = await getRachas();
    // Adiciona o novo racha no início da lista
    rachas.insert(0, racha);
    await _saveAllRachas(rachas);
  }

  @override
  Future<void> updateRacha(Racha racha) async {
    final rachas = await getRachas();
    final index = rachas.indexWhere((r) => r.id == racha.id);
    if (index != -1) {
      rachas[index] = racha;
      await _saveAllRachas(rachas);
    }
  }
  
  @override
  Future<void> deleteRacha(String rachaId) async {
    final rachas = await getRachas();
    rachas.removeWhere((r) => r.id == rachaId);
    await _saveAllRachas(rachas);
  }

  @override
  Future<void> clearAllRachas() async {
    // Salva uma lista vazia para limpar os dados.
    await _saveAllRachas([]);
  }

  @override
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  @override
  Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Você';
  }
}
