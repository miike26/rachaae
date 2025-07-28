import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/participant_model.dart'; // Importa o modelo
import 'participant_selector.dart';

class EditExpenseBottomSheet extends StatefulWidget {
  final Expense expense;
  // --- MUDANÇA AQUI ---
  final List<ParticipantModel> participants;

  const EditExpenseBottomSheet({
    super.key,
    required this.expense,
    required this.participants,
  });

  @override
  State<EditExpenseBottomSheet> createState() => _EditExpenseBottomSheetState();
}

class _EditExpenseBottomSheetState extends State<EditExpenseBottomSheet> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late List<String> _selectedParticipants;
  String? _selectedPayer;
  late bool _countsForSettlement;

  // Helper para obter apenas os nomes
  List<String> get _participantNames => widget.participants.map((p) => p.displayName).toList();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    _selectedParticipants = List.from(widget.expense.sharedWith);
    _selectedPayer = widget.expense.paidBy;
    _countsForSettlement = widget.expense.countsForSettlement;
  }

  void _saveChanges() {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));

    if (description.isEmpty || amount == null || _selectedParticipants.isEmpty) {
      return;
    }

    final updatedExpense = Expense(
      id: widget.expense.id,
      description: description,
      amount: amount,
      sharedWith: _selectedParticipants,
      paidBy: _selectedPayer,
      countsForSettlement: _selectedPayer == null ? true : _countsForSettlement,
    );

    Navigator.of(context).pop({'action': 'update', 'data': updatedExpense});
  }

  void _deleteExpense() {
    Navigator.of(context).pop({'action': 'delete'});
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
            const Text('Editar Despesa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            const Text('Pago por:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _selectedPayer,
              hint: const Text('Todos (dividir igualmente)'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos (dividir igualmente)'),
                ),
                ..._participantNames.map((name) { // Usa a lista de nomes
                  return DropdownMenuItem(value: name, child: Text(name));
                })
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPayer = value;
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),

            if (_selectedPayer != null)
              SwitchListTile(
                title: const Text("Incluir no acerto de contas"),
                value: _countsForSettlement,
                onChanged: (newValue) {
                  setState(() {
                    _countsForSettlement = newValue;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 16),

            const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(controller: _descriptionController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),

            const Text('Valor (R\$)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _deleteExpense,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Excluir'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
