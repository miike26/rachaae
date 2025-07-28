import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/racha_model.dart';
import '../models/expense_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/color_helper.dart';

class EditRachaScreen extends StatefulWidget {
  final Racha racha;
  const EditRachaScreen({super.key, required this.racha});

  @override
  State<EditRachaScreen> createState() => _EditRachaScreenState();
}

class _EditRachaScreenState extends State<EditRachaScreen> {
  late TextEditingController _titleController;
  late TextEditingController _participantController;
  late String _selectedDateOption;

  // Usamos um mapa para armazenar os participantes.
  Map<String, UserModel?> _participants = {};

  // Estados para a busca inteligente
  late final UserService _userService;
  List<UserModel> _friends = [];
  List<UserModel> _filteredFriends = [];
  bool _isLoadingFriends = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.racha.title);
    _participantController = TextEditingController();
    _selectedDateOption = widget.racha.date;

    // Inicializa os participantes existentes como manuais.
    // Uma melhoria futura seria buscar os UserModels correspondentes se estiver online.
    _participants = {for (var p in widget.racha.participants) p: null};

    final authService = Provider.of<AuthService>(context, listen: false);
    _userService = Provider.of<UserService>(context, listen: false);
    _isUserLoggedIn = authService.user != null;

    _loadFriends();
    _participantController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
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

  void _addManualParticipant(String name) {
    if (name.isNotEmpty && !_participants.containsKey(name)) {
      setState(() {
        _participants[name] = null;
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

  void _saveChanges() {
    if (_titleController.text.isEmpty) return;

    final updatedParticipantsList = _participants.keys.toList();

    // Limpa as despesas de participantes que foram removidos
    final updatedExpenses = <Expense>[];
    for (var oldExpense in widget.racha.expenses) {
      final newSharedWith = oldExpense.sharedWith.where((p) => updatedParticipantsList.contains(p)).toList();
      
      if (newSharedWith.isNotEmpty) {
        updatedExpenses.add(Expense(
          id: oldExpense.id,
          description: oldExpense.description,
          amount: oldExpense.amount,
          sharedWith: newSharedWith,
          paidBy: updatedParticipantsList.contains(oldExpense.paidBy) ? oldExpense.paidBy : null,
          countsForSettlement: oldExpense.countsForSettlement,
        ));
      }
    }

    final updatedRacha = Racha(
      id: widget.racha.id,
      title: _titleController.text,
      date: _selectedDateOption,
      participants: updatedParticipantsList,
      expenses: updatedExpenses,
      isFinished: widget.racha.isFinished,
      serviceFeeValue: widget.racha.serviceFeeValue,
      serviceFeeType: widget.racha.serviceFeeType,
      serviceFeeParticipants: widget.racha.serviceFeeParticipants.where((p) => updatedParticipantsList.contains(p)).toList(),
    );

    Navigator.of(context).pop(updatedRacha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Racha', style: TextStyle(fontWeight: FontWeight.bold)),
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
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
                children: _participants.entries.map((entry) {
                  final name = entry.key;
                  final user = entry.value;
                  
                  CircleAvatar avatar;
                  if (user != null && user.photoURL.isNotEmpty) {
                    avatar = CircleAvatar(backgroundImage: NetworkImage(user.photoURL));
                  } else {
                    avatar = CircleAvatar(
                      backgroundColor: ColorHelper.getColorForName(name),
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                    );
                  }

                  return Chip(
                    avatar: avatar,
                    label: Text(name),
                    onDeleted: () => setState(() => _participants.remove(name)),
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
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Salvar Alterações', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildParticipantSuggestions() {
    if (!_isUserLoggedIn) {
      return const SizedBox.shrink();
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
        onTap: () => _addManualParticipant(_participantController.text),
      );
    }
    return _buildFriendsList(_filteredFriends);
  }

  Widget _buildFriendsList(List<UserModel> friends) {
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
              onPressed: () => _addFriendParticipant(friend),
            ),
          );
        },
      ),
    );
  }
}
