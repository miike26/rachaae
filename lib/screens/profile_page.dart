import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/settings_service.dart'; // Importa o novo serviço
import '../utils/color_helper.dart';
import '../models/user_model.dart';

class PerfilPage extends StatefulWidget {
  final double topPadding;
  final double bottomPadding;

  const PerfilPage({
    super.key,
    required this.topPadding,
    required this.bottomPadding,
  });

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController _nameController = TextEditingController(text: 'Você');
  final TextEditingController _usernameController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _usernameError;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    setState(() {
      _isLoading = true;
      _usernameError = null;
    });

    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'O username não pode ser vazio.';
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      setState(() {
        _usernameError = 'Use apenas letras minúsculas, números e _';
        _isLoading = false;
      });
      return;
    }

    final isAvailable = await _userService.isUsernameAvailable(username);

    if (!isAvailable) {
      setState(() {
        _usernameError = 'Este @username já está em uso.';
        _isLoading = false;
      });
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Username'),
        content: Text(
            "Você está prestes a definir seu username como \"@$username\".\n\nEsta ação não poderá ser desfeita. Deseja continuar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await _userService.setUsername(username);
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.reloadUserProfile();
    } catch (e) {
      print("Erro ao salvar username: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.user;
        final userProfile = authService.userProfile;
        final bool isUserLoggedIn = user != null;

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.fromLTRB(16.0, widget.topPadding, 16.0, widget.bottomPadding),
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  if (isUserLoggedIn && user.photoURL != null)
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(user.photoURL!),
                    )
                  else
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: ColorHelper.getColorForName(isUserLoggedIn
                          ? user.displayName ?? ''
                          : _nameController.text),
                      child: Text(
                        (isUserLoggedIn
                                ? user.displayName?.substring(0, 1)
                                : _nameController.text.substring(0, 1)) ??
                            'U',
                        style: const TextStyle(color: Colors.white, fontSize: 50),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    isUserLoggedIn
                        ? user.displayName ?? 'Usuário'
                        : _nameController.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isUserLoggedIn
                        ? user.email!
                        : 'Faça login para sincronizar',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (isUserLoggedIn) _buildUsernameSection(userProfile),
              
              const SizedBox(height: 20),
              const Text('APARÊNCIA', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Consumer<SettingsService>(
                builder: (context, settings, child) {
                  return Column(
                    children: [
                      Card(
                        child: SwitchListTile(
                          title: const Text("Tema Escuro"),
                          value: settings.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            settings.toggleTheme();
                          },
                        ),
                      ),
                      Card(
                        child: SwitchListTile(
                          title: const Text("Estilo de Card Detalhado"),
                          subtitle: const Text("Barra colorida em vez do fundo todo."),
                          value: settings.cardStyle == CardStyle.detailed,
                          onChanged: (value) {
                            settings.toggleCardStyle();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              const Text('CONTA', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                child: isUserLoggedIn
                    ? _buildLogoutTile(context, authService)
                    : _buildLoginTile(context, authService),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsernameSection(UserModel? userProfile) {
    if (userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProfile.username != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.alternate_email),
          title: const Text('Seu @username'),
          subtitle: Text(userProfile.username!,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crie seu @username',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Facilite que seus amigos te encontrem!',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                prefixText: '@',
                hintText: 'seu_usuario',
                border: const OutlineInputBorder(),
                errorText: _usernameError,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveUsername,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Salvar e verificar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTile(BuildContext context, AuthService authService) {
    return ListTile(
      leading:
          const FaIcon(FontAwesomeIcons.google, color: Colors.blueAccent),
      title: const Text('Entrar com Google'),
      subtitle: const Text('Sincronize seus dados na nuvem'),
      trailing: const Icon(Icons.login),
      onTap: () async {
        await authService.signInWithGoogle();
      },
    );
  }

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
