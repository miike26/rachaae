import 'package:flutter/material.dart';
import '../models/racha_model.dart';
import '../models/expense_model.dart'; // Importa o modelo de despesa

// Tela para editar um racha existente.
class EditRachaScreen extends StatefulWidget {
  // Recebe o racha que será editado.
  final Racha racha;
  const EditRachaScreen({super.key, required this.racha});

  @override
  State<EditRachaScreen> createState() => _EditRachaScreenState();
}

class _EditRachaScreenState extends State<EditRachaScreen> {
  late TextEditingController _titleController;
  late TextEditingController _participantController;
  late List<String> _participants;
  late String _selectedDateOption; // Para o seletor de data dinâmico

  @override
  void initState() {
    super.initState();
    // Preenche os campos com os dados do racha existente.
    _titleController = TextEditingController(text: widget.racha.title);
    _participantController = TextEditingController();
    _participants = List.from(widget.racha.participants);
    _selectedDateOption = widget.racha.date;
  }

  void _addParticipant() {
    if (_participantController.text.isNotEmpty) {
      setState(() {
        _participants.add(_participantController.text);
        _participantController.clear();
      });
    }
  }

  void _saveChanges() {
    if (_titleController.text.isEmpty) return;

    // **LÓGICA CORRIGIDA AQUI**
    // 1. Cria a nova lista de participantes.
    final updatedParticipants = List<String>.from(_participants);

    // 2. Cria uma nova lista de despesas.
    final updatedExpenses = <Expense>[];

    // 3. Itera sobre as despesas antigas para limpá-las.
    for (var oldExpense in widget.racha.expenses) {
      // Filtra a lista 'sharedWith' de cada despesa, mantendo apenas os participantes que ainda existem.
      final newSharedWith = oldExpense.sharedWith.where((participant) => updatedParticipants.contains(participant)).toList();
      
      // Cria uma nova despesa com a lista de participantes limpa.
      updatedExpenses.add(Expense(
        description: oldExpense.description,
        amount: oldExpense.amount,
        sharedWith: newSharedWith,
        paidBy: updatedParticipants.contains(oldExpense.paidBy) ? oldExpense.paidBy : null,
        countsForSettlement: oldExpense.countsForSettlement,
      ));
    }

    // Cria um novo objeto Racha com todos os dados atualizados.
    final updatedRacha = Racha(
      title: _titleController.text,
      date: _selectedDateOption,
      participants: updatedParticipants,
      expenses: updatedExpenses, // Usa a nova lista de despesas limpa.
      isFinished: widget.racha.isFinished,
      serviceFeeValue: widget.racha.serviceFeeValue,
      serviceFeeType: widget.racha.serviceFeeType,
      serviceFeeParticipants: widget.racha.serviceFeeParticipants.where((p) => updatedParticipants.contains(p)).toList(),
    );

    // Fecha a tela e envia o racha atualizado como resultado.
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
            
            // **SELETOR DE DATA DINÂMICO ADICIONADO AQUI**
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
                  onPressed: () { /* Ação para abrir o calendário virá aqui */ },
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
                spacing: 8.0,
                runSpacing: 8.0,
                children: _participants
                    .map((name) => Chip(
                          label: Text(name),
                          onDeleted: () {
                            setState(() {
                              _participants.remove(name);
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _participantController,
                    decoration: InputDecoration(hintText: 'Adicionar participante...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6347),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Salvar Alterações', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
