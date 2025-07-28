import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa o modelo de dados para um usuário no Firestore.
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String? username; // O @nickname, pode ser nulo inicialmente

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
    this.username,
  });

  /// Cria um UserModel a partir de um documento do Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] ?? '',
      username: data['username'],
    );
  }

  /// Converte o UserModel para um mapa que pode ser salvo no Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'username': username,
    };
  }
}
