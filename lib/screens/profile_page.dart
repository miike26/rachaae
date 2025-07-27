// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/auth_service.dart';
import '../utils/color_helper.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // O controller para o nome local, usado quando o usuário não está logado.
  final TextEditingController _nameController = TextEditingController(text: 'Você');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos o Consumer para ouvir as mudanças no AuthService
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.user;
        final bool isUserLoggedIn = user != null;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            title: Text(
              'Perfil',
              style: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),
              // --- SEÇÃO DE INFORMAÇÕES DO USUÁRIO ---
              Column(
                children: [
                  // O avatar muda se o usuário estiver logado
                  if (isUserLoggedIn && user.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.photoURL!),
                    )
                  else
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: ColorHelper.getColorForName(isUserLoggedIn ? user.displayName ?? '' : _nameController.text),
                      child: Text(
                        (isUserLoggedIn ? user.displayName?.substring(0, 1) : _nameController.text.substring(0, 1)) ?? 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // O campo de nome é editável apenas se não estiver logado
                  TextField(
                    controller: isUserLoggedIn ? TextEditingController(text: user.displayName) : _nameController,
                    readOnly: isUserLoggedIn, // Bloqueia a edição se estiver logado
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                  // Mostra o email se estiver logado, ou um texto padrão
                  Text(
                    isUserLoggedIn ? user.email! : 'voce_local@email.com',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // O botão de salvar só aparece se não estiver logado
              if (!isUserLoggedIn)
                ElevatedButton(
                  onPressed: () {
                    // Aqui você pode reconectar a lógica para salvar o nome localmente
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nome local salvo!')),
                    );
                  },
                  child: const Text('Salvar Nome'),
                ),
              const SizedBox(height: 30),

              // --- SEÇÃO DE CONTA (LOGIN/LOGOUT) ---
              const Text('CONTA', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                child: isUserLoggedIn
                    ? _buildLogoutTile(context, authService)
                    : _buildLoginTile(context, authService),
              ),

              const SizedBox(height: 30),

              // --- SEÇÃO DE CONFIGURAÇÕES ---
              const Text('CONFIGURAÇÕES', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Modo Escuro'),
                      trailing: Switch(value: false, onChanged: (val) {
                        // Lógica para o modo escuro
                      }),
                    ),
                    ListTile(
                      leading: const Icon(Icons.pix),
                      title: const Text('Minha Chave PIX'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Lógica para a chave PIX
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para o botão de Login
  Widget _buildLoginTile(BuildContext context, AuthService authService) {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.google, color: Colors.blueAccent),
      title: const Text('Entrar com Google'),
      subtitle: const Text('Sincronize seus dados na nuvem'),
      trailing: const Icon(Icons.login),
      onTap: () async {
        await authService.signInWithGoogle();
      },
    );
  }

  // Widget para o botão de Logout
  Widget _buildLogoutTile(BuildContext context, AuthService authService) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Sair', style: TextStyle(color: Colors.red)),
      onTap: () async {
        await authService.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você saiu da sua conta.')),
          );
        }
      },
    );
  }
}
