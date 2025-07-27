import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _userDisplayName;
  String? _userEmail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _userDisplayName = user?.displayName;
          _userEmail = user?.email;
          _errorMessage = null; // Clear error on auth state change
        });
      }
    });
  }

  // Função para fazer login com o Google
  Future<void> _signInWithGoogle() async {
    try {
      // Inicia o fluxo de login do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // O usuário cancelou o login
        return;
      }

      // Obtém as credenciais de autenticação do Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz login no Firebase com as credenciais do Google
      await _auth.signInWithCredential(credential);
      setState(() {
        _errorMessage = null;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = 'Erro de autenticação: ${e.message}';
      });
      print('FirebaseAuthException: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro inesperado: $e';
      });
      print('Erro inesperado: $e');
    }
  }

  // Função para fazer logout
  Future<void> _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Desconecta também do Google
    setState(() {
      _userDisplayName = null;
      _userEmail = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Autenticação',
          style: GoogleFonts.inriaSans(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: const Color(0xFF484848),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_userDisplayName != null) ...[
                Text(
                  'Bem-vindo, ${_userDisplayName!}!',
                  style: GoogleFonts.inriaSans(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _userEmail ?? '',
                  style: GoogleFonts.inriaSans(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: Text(
                    'Sair',
                    style: GoogleFonts.inriaSans(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ] else ...[
                Text(
                  'Faça login para sincronizar seus dados e usar recursos colaborativos!',
                  style: GoogleFonts.inriaSans(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata), // Fallback
                  ),
                  label: Text(
                    'Entrar com Google',
                    style: GoogleFonts.inriaSans(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Placeholder para Apple Sign-In
                ElevatedButton.icon(
                  onPressed: () {
                    // Implementação do Apple Sign-In aqui
                    // Nota: Apple Sign-In requer configuração específica no Xcode e no Apple Developer Account.
                    // Para mais detalhes, consulte a documentação oficial do Firebase e do pacote sign_in_with_apple.
                    setState(() {
                      _errorMessage = 'Apple Sign-In requer configuração adicional específica da plataforma.';
                    });
                  },
                  icon: const Icon(Icons.apple, size: 24),
                  label: Text(
                    'Entrar com Apple',
                    style: GoogleFonts.inriaSans(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.inriaSans(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
