import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/friend_request_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/color_helper.dart';
import '../utils/app_theme.dart'; // Importa o AppTheme para as cores

class FriendsPage extends StatefulWidget {
  final double topPadding;
  final double bottomPadding;

  const FriendsPage({
    super.key,
    required this.topPadding,
    required this.bottomPadding,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
  }

  void _confirmRemoveFriend(UserModel friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Amigo'),
        content: Text(
            'Tem certeza que deseja remover ${friend.displayName} da sua lista de amigos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _userService.removeFriend(friend.uid);
              Navigator.of(context).pop();
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    if (authService.user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Faça login para ver e adicionar amigos.',
              textAlign: TextAlign.center),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
          16.0, widget.topPadding, 16.0, widget.bottomPadding),
      children: [
        _buildFriendRequestsSection(),
        // O espaçamento só é adicionado se a seção de pedidos existir
        StreamBuilder<List<FriendRequestModel>>(
          stream: _userService.getFriendRequests(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return const SizedBox(height: 24);
            }
            return const SizedBox.shrink();
          },
        ),
        _buildFriendsListSection(),
      ],
    );
  }

  Widget _buildFriendRequestsSection() {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final containerColor = isLightTheme
        ? const Color(0xFFFFFFFF).withOpacity(0.0)
        : const Color(0xFF323645).withOpacity(0.0);
    final textColor = isLightTheme ? AppTheme.lightTextColor : AppTheme.darkTextColor;
    
    // Parâmetros de fonte
    const double titleFontSize = 16.0;
    const double subtitleFontSize = 13.0;

    return StreamBuilder<List<FriendRequestModel>>(
      stream: _userService.getFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final requests = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0), // Padding adicionado

              child: Text(
                'PEDIDOS DE AMIZADE',

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 18),
            // Container único para a lista de pedidos
            Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (context, index) => const Divider(height: 15, thickness: 0, color: Colors.transparent),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  // Busca o perfil do usuário para obter o email/username
                  return FutureBuilder<UserModel?>(
                    future: _userService.getUserProfile(request.senderId),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        // Mostra um placeholder enquanto carrega os dados do usuário
                        return Row(children: [
                          CircleAvatar(backgroundImage: NetworkImage(request.senderPhotoUrl)),
                          const SizedBox(width: 16),
                          const Text("Carregando..."),
                        ]);
                      }
                      final senderProfile = userSnapshot.data!;
                      // Estrutura de Row para cada pedido
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(request.senderPhotoUrl),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.senderName,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: titleFontSize,
                                  ),
                                ),
                                Text(
                                  // Mostra o username ou email
                                  senderProfile.username ?? senderProfile.email,
                                  style: GoogleFonts.roboto(
                                    color: textColor,
                                    fontSize: subtitleFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () => _userService.acceptFriendRequest(request.senderId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _userService.declineFriendRequest(request.senderId),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFriendsListSection() {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final containerColor = isLightTheme
        ? const Color(0xFFFFFFFF).withOpacity(0.95)
        : const Color(0xFF323645);
    final textColor = isLightTheme ? AppTheme.lightTextColor : AppTheme.darkTextColor;

    // Parâmetros de fonte
    const double titleFontSize = 16.0;
    const double subtitleFontSize = 13.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0), // Padding adicionado

          child: Text(
            'MEUS AMIGOS',

            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),

        const SizedBox(height: 18),
        StreamBuilder<List<UserModel>>(
          stream: _userService.getFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('Você ainda não tem amigos.')),
              );
            }
            final friends = snapshot.data!;

            return Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friends.length,
                separatorBuilder: (context, index) => const Divider(height: 15, thickness: 0, color: Colors.transparent),
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            ColorHelper.getColorForName(friend.displayName),
                        backgroundImage: friend.photoURL.isNotEmpty
                            ? NetworkImage(friend.photoURL)
                            : null,
                        child: friend.photoURL.isEmpty
                            ? Text(
                                friend.displayName.isNotEmpty
                                    ? friend.displayName[0]
                                    : 'U',
                                style: const TextStyle(color: Colors.white))
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.displayName,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: titleFontSize,
                              ),
                            ),
                            Text(
                              friend.username ?? friend.email,
                              style: GoogleFonts.roboto(
                                color: textColor,
                                fontSize: subtitleFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.person_remove_outlined,
                          color: Color(0xFFFC5252),
                        ),
                        onPressed: () => _confirmRemoveFriend(friend),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
