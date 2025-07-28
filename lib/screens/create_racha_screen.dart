import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/racha_model.dart';
import '../repositories/racha_repository.dart';
import '../repositories/local_storage_repository.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/color_helper.dart';

class CreateRachaScreen extends StatefulWidget {
  const CreateRachaScreen({super.key});

  @override
  State<CreateRachaScreen> createState() => _CreateRachaScreenState();
}

class _CreateRachaScreenState extends State<CreateRachaScreen> {
  final _titleController = TextEditingController();
  final _participantController = TextEditingController();

  // --- MUDANÇA AQUI ---
  // Usamos um mapa para armazenar os participantes. A chave é o nome,
  // e o valor é o UserModel (se for um amigo) ou null (se for manual).
  Map<String, UserModel?> _participants = {};
  String _selectedDateOption = 'Hoje';

  // Novos estados para a busca inteligente
  late final UserService _userService;
  late final RachaRepository _rachaRepository;
  List<UserModel> _friends = [];
  List<UserModel> _filteredFriends = [];
  bool _isLoadingFriends = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _userService = Provider.of<UserService>(context, listen: false);
    _rachaRepository = LocalStorageRepository();
    _isUserLoggedIn = authService.user != null;

    _loadInitialData();
    _participantController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final userName = await _rachaRepository.loadUserName();
    setState(() {
      // Adiciona o usuário atual como participante (sem UserModel, pois pode estar offline)
      _participants[userName] = null;
    });

    if (_isUserLoggedIn) {
      setState(() { _isLoadingFriends = true; });
      try {
        final friendsList = await _userService.getFriends().first;
        setState(() {
          _friends = friendsList;
          _filteredFriends = friendsList;
          _isLoadingFriends = false;
        });
      } catch (e) {
        print("Não foi possível carregar amigos: $e");
        setState(() { _isLoadingFriends = false; });
      }
    }
  }

  void _onSearchChanged() {
    final query = _participantController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends
          .where((friend) =>
              friend.displayName.toLowerCase().contains(query) ||
              (friend.username?.toLowerCase().contains(query) ?? false))
          .toList();
    });
  }

  // --- MÉTODOS DE ADIÇÃO ATUALIZADOS ---
  void _addManualParticipant(String name) {
    if (name.isNotEmpty && !_participants.containsKey(name)) {
      setState(() {
        _participants[name] = null; // null indica que é manual
        _participantController.clear();
      });
    }
  }

  void _addFriendParticipant(UserModel friend) {
    if (!_participants.containsKey(friend.displayName)) {
      setState(() {
        _participants[friend.displayName] = friend;
        _participantController.clear();
      });
    }
  }

  void _createRacha() {
    if (_titleController.text.isEmpty) return;

    final newRacha = Racha(
      title: _titleController.text,
      date: _selectedDateOption,
      // Usamos apenas as chaves (nomes) do mapa
      participants: _participants.keys.toList(),
    );

    Navigator.of(context).pop(newRacha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Criar Novo Racha', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nome do Racha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Ex: Churrasco de Sábado', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),
            const Text('Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChoiceChip(label: const Text('Hoje'), selected: _selectedDateOption == 'Hoje', onSelected: (s) => setState(() => _selectedDateOption = 'Hoje')),
                ChoiceChip(label: const Text('Amanhã'), selected: _selectedDateOption == 'Amanhã', onSelected: (s) => setState(() => _selectedDateOption = 'Amanhã')),
                ChoiceChip(label: const Text('Recorrente'), selected: _selectedDateOption == 'Recorrente', onSelected: (s) => setState(() => _selectedDateOption = 'Recorrente')),
                IconButton(icon: const Icon(Icons.calendar_month), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text('Participantes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                // --- MUDANÇA AQUI: Lógica para criar o Chip com Avatar ---
                children: _participants.entries.map((entry) {
                  final name = entry.key;
                  final user = entry.value; // UserModel ou null
                  
                  CircleAvatar avatar;
                  if (user != null && user.photoURL.isNotEmpty) {
                    // Amigo com foto
                    avatar = CircleAvatar(backgroundImage: NetworkImage(user.photoURL));
                  } else {
                    // Amigo sem foto, participante manual ou o próprio usuário
                    avatar = CircleAvatar(
                      backgroundColor: ColorHelper.getColorForName(name),
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                    );
                  }

                  return Chip(
                    avatar: avatar,
                    label: Text(name),
                    onDeleted: name == _participants.keys.first ? null : () => setState(() => _participants.remove(name)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _participantController,
              decoration: InputDecoration(
                hintText: 'Adicionar participante...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            _buildParticipantSuggestions(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _createRacha,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Criar Racha', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildParticipantSuggestions() {
    if (!_isUserLoggedIn) {
      return const Text('Faça login para adicionar amigos rapidamente.', style: TextStyle(color: Colors.grey));
    }

    if (_isLoadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    final query = _participantController.text;
    
    if (query.isEmpty) {
      return _buildFriendsList(_friends);
    }

    if (_filteredFriends.isEmpty) {
      return ListTile(
        leading: const Icon(Icons.add_circle_outline),
        title: Text("Adicionar '${_participantController.text}' como participante"),
        // --- MUDANÇA AQUI ---
        onTap: () => _addManualParticipant(_participantController.text),
      );
    }
    
    return _buildFriendsList(_filteredFriends);
  }

  Widget _buildFriendsList(List<UserModel> friends) {
    // Filtra para não mostrar amigos que já foram adicionados
    final availableFriends = friends.where((f) => !_participants.containsKey(f.displayName)).toList();

    if (availableFriends.isEmpty) {
      if (_participantController.text.isNotEmpty) {
        return ListTile(
          leading: const Icon(Icons.add_circle_outline),
          title: Text("Adicionar '${_participantController.text}' como participante"),
          onTap: () => _addManualParticipant(_participantController.text),
        );
      }
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        itemCount: availableFriends.length,
        itemBuilder: (context, index) {
          final friend = availableFriends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: ColorHelper.getColorForName(friend.displayName),
              backgroundImage: friend.photoURL.isNotEmpty ? NetworkImage(friend.photoURL) : null,
              child: friend.photoURL.isEmpty ? Text(friend.displayName[0]) : null,
            ),
            title: Text(friend.displayName),
            subtitle: Text(friend.username ?? friend.email),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              // --- MUDANÇA AQUI ---
              onPressed: () => _addFriendParticipant(friend),
            ),
          );
        },
      ),
    );
  }
}
