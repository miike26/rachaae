import '../models/racha_model.dart';

/// Define o contrato para todas as fontes de dados de "Rachas".
/// Qualquer classe que queira fornecer dados para o app (seja local ou nuvem)
/// deve implementar estes métodos.
abstract class RachaRepository {
  /// Retorna uma lista com todos os rachas.
  Future<List<Racha>> getRachas();

  /// Salva um novo racha.
  Future<void> saveRacha(Racha racha);

  /// Atualiza um racha existente.
  Future<void> updateRacha(Racha racha);

  /// Deleta um racha pelo seu ID.
  Future<void> deleteRacha(String rachaId);

  /// Limpa todos os rachas da fonte de dados.
  Future<void> clearAllRachas();

  // Métodos para o nome do usuário, mantendo a consistência.
  Future<void> saveUserName(String name);
  Future<String> loadUserName();
}
