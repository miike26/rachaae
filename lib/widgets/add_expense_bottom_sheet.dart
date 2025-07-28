import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/participant_model.dart'; // Importa o modelo
import 'participant_selector.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  // --- MUDANÇA AQUI ---
  final List<ParticipantModel> participants;
  const AddExpenseBottomSheet({super.key, required this.participants});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  List<String> _selectedParticipants = [];

  // Helper para obter apenas os nomes
  List<String> get _participantNames => widget.participants.map((p) => p.displayName).toList();

  @override
  void initState() {
    super.initState();
    // Por padrão, todos vêm selecionados ao criar.
    _selectedParticipants = _participantNames;
  }

  void _saveExpense() {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));

    if (description.isEmpty || amount == null || _selectedParticipants.isEmpty) {
      return;
    }

    final newExpense = Expense(
      description: description,
      amount: amount,
      sharedWith: _selectedParticipants,
    );

    Navigator.of(context).pop(newExpense);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adicionar Despesa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(controller: _descriptionController, decoration: InputDecoration(hintText: 'Ex: Pizza, Gasolina...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            const Text('Valor (R\$)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(hintText: 'Ex: 78,00', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            const Text('Dividir com:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            
            // --- MUDANÇA AQUI ---
            ParticipantSelector(
              allParticipants: widget.participants, // Passa a lista de modelos
              initialSelection: _selectedParticipants,
              onSelectionChanged: (newSelection) {
                _selectedParticipants = newSelection;
              },
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Salvar Despesa', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
