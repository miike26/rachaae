import 'package:flutter/material.dart';
import '../models/racha_model.dart';
import '../services/storage_service.dart'; // Importa o storage

class CreateRachaScreen extends StatefulWidget {
  const CreateRachaScreen({super.key});

  @override
  State<CreateRachaScreen> createState() => _CreateRachaScreenState();
}

class _CreateRachaScreenState extends State<CreateRachaScreen> {
  final _titleController = TextEditingController();
  final _participantController = TextEditingController();

  List<String> _participants = [];
  String _selectedDateOption = 'Hoje';
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Carrega o nome do usuário para usar como o primeiro participante.
  Future<void> _loadUserName() async {
    final userName = await _storageService.loadUserName();
    setState(() {
      _participants = [userName];
    });
  }

  void _addParticipant() {
    if (_participantController.text.isNotEmpty) {
      setState(() {
        _participants.add(_participantController.text);
        _participantController.clear();
      });
    }
  }

  void _createRacha() {
    if (_titleController.text.isEmpty) return;

    final newRacha = Racha(
      title: _titleController.text,
      date: _selectedDateOption,
      participants: List.from(_participants),
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
                ChoiceChip(
                  label: const Text('Hoje'),
                  selected: _selectedDateOption == 'Hoje',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDateOption = 'Hoje');
                  },
                ),
                ChoiceChip(
                  label: const Text('Amanhã'),
                  selected: _selectedDateOption == 'Amanhã',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDateOption = 'Amanhã');
                  },
                ),
                ChoiceChip(
                  label: const Text('Recorrente'),
                  selected: _selectedDateOption == 'Recorrente',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDateOption = 'Recorrente');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Participantes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
              child: Wrap(
                spacing: 8.0, runSpacing: 8.0,
                children: _participants.map((name) => Chip(
                          label: Text(name),
                          onDeleted: name == _participants.first ? null : () => setState(() => _participants.remove(name)),
                        )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Adicionar da lista de amigos'),
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _participantController,
                    decoration: InputDecoration(hintText: 'Ou adicione manualmente...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFFFF6347), size: 32),
                  onPressed: _addParticipant,
                ),
              ],
            ),
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
}
