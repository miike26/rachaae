import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/racha_model.dart';
import 'racha_repository.dart';

/// Implementação do [RachaRepository] que usa o Cloud Firestore para
/// salvar e carregar os dados na nuvem.
class FirestoreRepository implements RachaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna a coleção de rachas do usuário atualmente logado.
  CollectionReference<Racha> _getUserRachasCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      // Lança uma exceção se não houver usuário logado.
      // Isso garante que não tentemos acessar a nuvem sem autenticação.
      throw Exception('Utilizador não autenticado.');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('rachas')
        .withConverter<Racha>(
          fromFirestore: (snapshots, _) => Racha.fromJson(snapshots.data()!),
          toFirestore: (racha, _) => racha.toJson(),
        );
  }

  @override
  Future<List<Racha>> getRachas() async {
    try {
      final snapshot = await _getUserRachasCollection()
          .orderBy('date', descending: true) // Ordena os mais recentes primeiro
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // Em caso de erro (ex: offline), retorna uma lista vazia.
      print("Erro ao carregar rachas do Firestore: $e");
      return [];
    }
  }

  @override
  Future<void> saveRacha(Racha racha) async {
    // Usamos o ID do próprio objeto racha como ID do documento.
    await _getUserRachasCollection().doc(racha.id).set(racha);
  }

  @override
  Future<void> updateRacha(Racha racha) async {
    await _getUserRachasCollection().doc(racha.id).update(racha.toJson());
  }

  @override
  Future<void> deleteRacha(String rachaId) async {
    await _getUserRachasCollection().doc(rachaId).delete();
  }

  @override
  Future<void> clearAllRachas() async {
    // Este método irá deletar todos os rachas do usuário na nuvem.
    final collection = _getUserRachasCollection();
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- Métodos de Nome de Usuário para Firestore ---

  @override
  Future<String> loadUserName() async {
    // O nome do usuário na nuvem é o nome da conta Google.
    return _auth.currentUser?.displayName ?? 'Usuário';
  }

  @override
  Future<void> saveUserName(String name) async {
    // Esta função atualiza o perfil do usuário no Firebase Auth.
    // Pode ser expandida no futuro para salvar mais dados no documento do usuário.
    await _auth.currentUser?.updateDisplayName(name);
  }
}
