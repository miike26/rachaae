import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:racha_ae/models/expense_model.dart';
import 'package:racha_ae/models/participant_model.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/settings_service.dart';
import '../utils/color_helper.dart';
import '../models/user_model.dart';
import '../models/racha_model.dart';
import '../widgets/racha_card.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _usernameError;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _showCreateUsernameDialog(BuildContext context) {
    // Reseta o estado de erro ao abrir o diálogo
    setState(() {
      _usernameError = null;
      _isLoading = false;
      _usernameController.clear();
    });

    showDialog(
      context: context,
      builder: (context) {
        // Usa um StatefulWidgetBuilder para que o diálogo tenha seu próprio estado
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Crie seu @username', style: GoogleFonts.roboto()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Facilite que seus amigos te encontrem! Esta ação não poderá ser desfeita.", style: GoogleFonts.roboto()),
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar', style: GoogleFonts.roboto()),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveUsername(setDialogState),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Confirmar', style: GoogleFonts.roboto()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveUsername(void Function(void Function()) setDialogState) async {
    setDialogState(() {
      _isLoading = true;
      _usernameError = null;
    });

    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setDialogState(() {
        _usernameError = 'O username não pode ser vazio.';
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      setDialogState(() {
        _usernameError = 'Use apenas letras minúsculas, números e _';
        _isLoading = false;
      });
      return;
    }

    final isAvailable = await _userService.isUsernameAvailable(username);

    if (!isAvailable) {
      setDialogState(() {
        _usernameError = 'Este @username já está em uso.';
        _isLoading = false;
      });
      return;
    }

    try {
      await _userService.setUsername(username);
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.reloadUserProfile();
      if (mounted) Navigator.of(context).pop(); // Fecha o diálogo
    } catch (e) {
      print("Erro ao salvar username: $e");
      setDialogState(() {
        _usernameError = 'Ocorreu um erro. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, SettingsService>(
      builder: (context, authService, settings, child) {
        return ListView(
          padding: EdgeInsets.fromLTRB(16.0, widget.topPadding, 16.0, widget.bottomPadding),
          children: [
            const SizedBox(height: 10),
            _buildUserInfoSection(authService),
            const SizedBox(height: 40),
            _buildAppearanceSection(settings),
          ],
        );
      },
    );
  }

  Widget _buildUserInfoSection(AuthService authService) {
    final user = authService.user;
    final userProfile = authService.userProfile;
    final bool isUserLoggedIn = user != null;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // Parâmetros de espaçamento
    const double horizontalPadding = 20.0;
    const double avatarSpacing = 30.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centraliza verticalmente
        children: [
          // Avatar
          CircleAvatar(
            radius: 75,
            backgroundImage: isUserLoggedIn && user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            backgroundColor: ColorHelper.getColorForName(isUserLoggedIn ? user.displayName ?? 'Você' : 'Você'),
            child: (isUserLoggedIn && user.photoURL != null)
                ? null
                : Text(
                    (isUserLoggedIn ? user.displayName?.substring(0, 1) : 'V') ?? 'U',
                    style: GoogleFonts.roboto(color: Colors.white, fontSize: 70),
                  ),
          ),
          const SizedBox(width: avatarSpacing),
          // Nome, Email e Container de Username/Login
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUserLoggedIn ? user.displayName ?? 'Usuário' : 'Você',
                  style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  isUserLoggedIn ? user.email! : 'Faça login para sincronizar',
                  style: GoogleFonts.roboto(color: textColor?.withOpacity(0.7)),
                ),
                const SizedBox(height: 12),
                _buildUsernameOrLoginContainer(authService, userProfile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameOrLoginContainer(AuthService authService, UserModel? userProfile) {
    final bool isUserLoggedIn = authService.user != null;
    final bool hasUsername = userProfile?.username != null;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // Caso 1: Deslogado -> Botão de Login
    if (!isUserLoggedIn) {
      return GestureDetector(
        onTap: () async => await authService.signInWithGoogle(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.google, size: 18),
              const SizedBox(width: 12),
              Text("Entrar com Google", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    // Caso 2: Logado e com username
    if (hasUsername) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.80),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.alternate_email, size: 20, color: textColor?.withOpacity(0.7)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seu @username", 
                    style: GoogleFonts.roboto(fontSize: 12, color: textColor?.withOpacity(0.7))
                  ),
                  Text(
                    userProfile!.username!, 
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: textColor)
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Caso 3: Logado e sem username
    return GestureDetector(
      onTap: () => _showCreateUsernameDialog(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            "Defina seu @username",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(SettingsService settings) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    
    // Define as cores com base no tema
    final containerColor = isLightTheme ? Colors.white.withOpacity(0.80) : const Color(0xFF323645);
    final textColor = isLightTheme ? const Color(0xFF303030) : null; // Usa a cor padrão do tema se for dark

    // Racha fake para a pré-visualização
    final fakeRacha = Racha(
      id: 'fake_racha',
      title: 'Jantar de Aniversário',
      date: 'Hoje',
      category: RachaCategory.comidaEBebida,
      participants: [
        ParticipantModel(displayName: 'M'),
        ParticipantModel(displayName: 'J'),
        ParticipantModel(displayName: 'N'),
        ParticipantModel(displayName: 'F'),
      ],
      expenses: [Expense(description: 'Comida', amount: 270.00, sharedWith: ['M', 'J', 'N', 'F'])]
    );
    
    final bool isColorfulCardActive = settings.cardStyle == CardStyle.colorful;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0), // Padding do título
          child: Text('APARÊNCIA', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 18),
        // Container do Tema Escuro
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: Text("Tema Escuro", style: GoogleFonts.roboto(color: textColor)),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) => settings.toggleTheme(),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 15),
        // Container dos Cards Coloridos com pré-visualização
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text("Cards Coloridos", style: GoogleFonts.roboto(color: textColor)),
                value: isColorfulCardActive,
                onChanged: (value) => settings.toggleCardStyle(),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 15),
              // Pré-visualização do Card
              IgnorePointer(
                child: Transform.scale(
                  scale: 0.95,
                  child: RachaCard(
                    racha: fakeRacha,
                    onTap: () {},
                    showShadow: true, // Ativa a sombra APENAS para este card
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Opção de Ícones Coloridos agora sempre visível
              Opacity(
                opacity: isColorfulCardActive ? 0.5 : 1.0,
                child: SwitchListTile(
                  title: Text("Ícones Coloridos", style: GoogleFonts.roboto(color: textColor)),
                  subtitle: Text("Exibe ícones com a cor da categoria.", style: GoogleFonts.roboto(color: textColor?.withOpacity(0.7))),
                  value: settings.useColoredIcons,
                  // Desabilita o switch se os cards coloridos estiverem ativos
                  onChanged: isColorfulCardActive
                    ? null
                    : (value) => settings.toggleColoredIcons(),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
