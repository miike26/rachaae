import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para rastrear o estado de um pedido de amizade.
enum FriendRequestStatus { pending, accepted, declined }

class FriendRequestModel {
  final String id; // ID do documento (será o UID do remetente)
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final FriendRequestStatus status;
  final Timestamp timestamp;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhotoUrl,
    required this.status,
    required this.timestamp,
  });

  /// Constrói um modelo a partir de um documento do Firestore.
  factory FriendRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FriendRequestModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'] ?? '',
      // Converte a string do status para o enum correspondente.
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  /// Converte o objeto para um mapa JSON para ser salvo no Firestore.
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'status': status.name, // Salva o nome do enum como string
      'timestamp': timestamp,
    };
  }
}
