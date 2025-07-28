import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/friend_request_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserUid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilizador não autenticado.');
    return user.uid;
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final lowerCaseQuery = query.toLowerCase();

    try {
      final emailQuery = _firestore.collection('users').where('email', isEqualTo: lowerCaseQuery).get();
      final usernameQuery = _firestore.collection('users').where('username', isEqualTo: lowerCaseQuery).get();
      final results = await Future.wait([emailQuery, usernameQuery]);

      final Map<String, UserModel> usersMap = {};
      for (var doc in [...results[0].docs, ...results[1].docs]) {
        if (doc.id != _currentUserUid) {
          usersMap[doc.id] = UserModel.fromFirestore(doc);
        }
      }
      return usersMap.values.toList();
    } catch (e) {
      print("Erro ao buscar usuários: $e");
      return [];
    }
  }

  Future<void> sendFriendRequest(String recipientId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();

    final requestDoc = _firestore.collection('users').doc(recipientId).collection('friend_requests').doc(_currentUserUid);
    batch.set(requestDoc, {
      'senderId': _currentUserUid,
      'senderName': currentUser.displayName ?? 'Usuário Anônimo',
      'senderPhotoUrl': currentUser.photoURL ?? '',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    final sentRequestDoc = _firestore.collection('users').doc(_currentUserUid).collection('sent_requests').doc(recipientId);
    batch.set(sentRequestDoc, {'recipientId': recipientId, 'timestamp': FieldValue.serverTimestamp()});
    
    await batch.commit();
  }

  Future<void> acceptFriendRequest(String senderId) async {
    final batch = _firestore.batch();

    final currentUserFriendDoc = _firestore.collection('users').doc(_currentUserUid).collection('friends').doc(senderId);
    final senderDoc = await _firestore.collection('users').doc(senderId).get();
    if (senderDoc.exists) {
      batch.set(currentUserFriendDoc, senderDoc.data()!);
    }
    
    final senderFriendDoc = _firestore.collection('users').doc(senderId).collection('friends').doc(_currentUserUid);
    final currentUserDoc = await _firestore.collection('users').doc(_currentUserUid).get();
     if (currentUserDoc.exists) {
      batch.set(senderFriendDoc, currentUserDoc.data()!);
    }

    final requestDoc = _firestore.collection('users').doc(_currentUserUid).collection('friend_requests').doc(senderId);
    batch.delete(requestDoc);

    final sentRequestDoc = _firestore.collection('users').doc(senderId).collection('sent_requests').doc(_currentUserUid);
    batch.delete(sentRequestDoc);

    await batch.commit();
  }

  Future<void> declineFriendRequest(String senderId) async {
    final batch = _firestore.batch();

    final requestDoc = _firestore.collection('users').doc(_currentUserUid).collection('friend_requests').doc(senderId);
    batch.delete(requestDoc);

    final sentRequestDoc = _firestore.collection('users').doc(senderId).collection('sent_requests').doc(_currentUserUid);
    batch.delete(sentRequestDoc);

    await batch.commit();
  }

  /// Remove uma amizade.
  Future<void> removeFriend(String friendId) async {
    // --- LÓGICA CORRIGIDA ---
    // Agora, a remoção é unilateral. Apenas o amigo é removido
    // da lista do usuário atual. A outra pessoa continuará vendo
    // o usuário atual como amigo até que ela também o remova.
    final currentUserFriendDoc = _firestore
        .collection('users')
        .doc(_currentUserUid)
        .collection('friends')
        .doc(friendId);
        
    await currentUserFriendDoc.delete();
  }

  Stream<List<FriendRequestModel>> getFriendRequests() {
    return _firestore
        .collection('users')
        .doc(_currentUserUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FriendRequestModel.fromFirestore(doc)).toList());
  }

  Stream<List<UserModel>> getFriends() {
    return _firestore
        .collection('users')
        .doc(_currentUserUid)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Stream<Set<String>> getSentRequestIds() {
    return _firestore
        .collection('users')
        .doc(_currentUserUid)
        .collection('sent_requests')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }
}
