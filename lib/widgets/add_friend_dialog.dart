import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/color_helper.dart';
import '../utils/app_theme.dart';

class AddFriendDialog extends StatefulWidget {
  final Set<String> friendIds;
  final Set<String> sentRequestIds;

  const AddFriendDialog({
    super.key,
    required this.friendIds,
    required this.sentRequestIds,
  });

  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final TextEditingController _searchController = TextEditingController();
  late final UserService _userService;

  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  late Set<String> _sentRequests;

  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
    _sentRequests = widget.sentRequestIds;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch();
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    final results = await _userService.searchUsers(_searchController.text.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendRequest(String recipientId) async {
    try {
      await _userService.sendFriendRequest(recipientId);
      setState(() {
        _sentRequests.add(recipientId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pedido de amizade enviado!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao enviar pedido: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final dialogBgColor = isLightTheme ? Colors.white : const Color(0xFF2D313E);
    final containerColor = isLightTheme
        ? const Color(0xFFFFFFFF).withOpacity(0.95)
        : const Color(0xFF323645);
    final textColor = isLightTheme ? AppTheme.lightTextColor : AppTheme.darkTextColor;
    
    // Parâmetros de fonte
    const double titleFontSize = 16.0;
    const double subtitleFontSize = 14.0;

    return Dialog(
      backgroundColor: dialogBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Adicionar Amigo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar por e-mail ou @username',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: isLightTheme ? Colors.grey[200] : const Color(0xFF323645),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Digite para buscar um amigo.'
                                : 'Nenhum usuário encontrado.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => const Divider(height: 15, thickness: 0, color: Colors.transparent),
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              final isFriend = widget.friendIds.contains(user.uid);
                              final isRequestSent = _sentRequests.contains(user.uid);

                              Widget trailingWidget;
                              if (isFriend) {
                                trailingWidget = const Icon(Icons.check_circle,
                                    color: Colors.blue, semanticLabel: 'Amigo');
                              } else if (isRequestSent) {
                                trailingWidget = const Icon(Icons.hourglass_top,
                                    color: Colors.orange,
                                    semanticLabel: 'Pedido enviado');
                              } else {
                                trailingWidget = IconButton(
                                  icon: const Icon(Icons.person_add_alt_1_outlined,
                                      color: Colors.deepPurple),
                                  onPressed: () => _sendRequest(user.uid),
                                );
                              }

                              return Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: ColorHelper.getColorForName(user.displayName),
                                    backgroundImage: user.photoURL.isNotEmpty ? NetworkImage(user.photoURL) : null,
                                    child: user.photoURL.isEmpty
                                        ? Text( user.displayName.isNotEmpty ? user.displayName[0] : 'U', style: const TextStyle(color: Colors.white))
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.displayName,
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            fontSize: titleFontSize,
                                          ),
                                        ),
                                        Text(
                                          user.username ?? user.email,
                                          style: GoogleFonts.roboto(
                                            color: textColor,
                                            fontSize: subtitleFontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailingWidget,
                                ],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
