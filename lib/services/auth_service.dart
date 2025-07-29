import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Importa o UserModel
import '../services/user_service.dart'; // Importa o UserService

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService(); // Instancia o UserService

  User? _user;
  User? get user => _user;

  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    await reloadUserProfile(); // Agora também recarrega o perfil aqui
  }

  // --- NOVO MÉTODO ---
  /// Busca os dados do perfil do usuário no Firestore e notifica os ouvintes.
  Future<void> reloadUserProfile() async {
    if (_user != null) {
      _userProfile = await _userService.getUserProfile(_user!.uid);
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        final userDoc = _firestore.collection('users').doc(_user!.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': _user!.uid,
            'displayName': _user!.displayName,
            'email': _user!.email,
            'photoURL': _user!.photoURL,
            'username': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      // _onAuthStateChanged será chamado automaticamente, que por sua vez
      // chamará reloadUserProfile.
      return _user;
    } catch (e) {
      debugPrint("Erro durante o login com Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Erro durante o logout: $e");
    }
  }
}
