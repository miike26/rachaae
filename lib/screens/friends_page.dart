import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend_request_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/color_helper.dart';

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
          child: Text('Faça login para ver e adicionar amigos.', textAlign: TextAlign.center),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.0, widget.topPadding, 16.0, widget.bottomPadding),
      children: [
        _buildFriendRequestsSection(),
        const SizedBox(height: 24),
        _buildFriendsListSection(),
      ],
    );
  }

  Widget _buildFriendRequestsSection() {
    return StreamBuilder<List<FriendRequestModel>>(
      stream: _userService.getFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final requests = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PEDIDOS DE AMIZADE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...requests.map((request) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(request.senderPhotoUrl),
                    ),
                    title: Text(request.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: () =>
                              _userService.acceptFriendRequest(request.senderId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _userService
                              .declineFriendRequest(request.senderId),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildFriendsListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MEUS AMIGOS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
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
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
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
                    title: Text(friend.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(friend.username ?? friend.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove_outlined,
                          color: Colors.redAccent),
                      onPressed: () => _confirmRemoveFriend(friend),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
