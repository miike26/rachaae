import 'package:flutter/material.dart';
import '../models/racha_model.dart';
import '../models/participant_model.dart'; // Importa o modelo
import 'participant_selector.dart';

class EditFeesBottomSheet extends StatefulWidget {
  final double initialFeeValue;
  final FeeType initialFeeType;
  final List<String> initialParticipants;
  // --- MUDANÇA AQUI ---
  final List<ParticipantModel> allParticipants;

  const EditFeesBottomSheet({
    super.key,
    required this.initialFeeValue,
    required this.initialFeeType,
    required this.initialParticipants,
    required this.allParticipants,
  });

  @override
  State<EditFeesBottomSheet> createState() => _EditFeesBottomSheetState();
}

class _EditFeesBottomSheetState extends State<EditFeesBottomSheet> {
  late TextEditingController _feeController;
  late FeeType _selectedFeeType;
  late List<String> _selectedParticipants;

  @override
  void initState() {
    super.initState();
    _feeController = TextEditingController(text: widget.initialFeeValue.toString());
    _selectedFeeType = widget.initialFeeType;
    _selectedParticipants = List.from(widget.initialParticipants);
  }

  void _saveFees() {
    final newFeeValue = double.tryParse(_feeController.text.replaceAll(',', '.')) ?? 0.0;
    
    final result = {
      'value': newFeeValue,
      'type': _selectedFeeType,
      'participants': _selectedParticipants,
    };
    Navigator.of(context).pop(result);
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
            const Text('Editar Taxa de Serviço', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('% Porcentagem'),
                  selected: _selectedFeeType == FeeType.percentage,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFeeType = FeeType.percentage);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('R\$ Valor Fixo'),
                  selected: _selectedFeeType == FeeType.fixed,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFeeType = FeeType.fixed);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _feeController,
              decoration: InputDecoration(
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            const Text('Dividir taxa com:', style: TextStyle(fontWeight: FontWeight.w600)),
            
            // --- MUDANÇA AQUI ---
            ParticipantSelector(
              allParticipants: widget.allParticipants, // Passa a lista de modelos
              initialSelection: _selectedParticipants,
              onSelectionChanged: (newSelection) {
                _selectedParticipants = newSelection;
              },
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveFees,
              child: const Text('Salvar Taxas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
