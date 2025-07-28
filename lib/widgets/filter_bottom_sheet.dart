import 'package:flutter/material.dart';
import '../models/participant_model.dart'; // Importa o modelo
import 'participant_selector.dart';

class FilterBottomSheet extends StatefulWidget {
  // --- MUDANÇA AQUI ---
  final List<ParticipantModel> allParticipants;
  final List<String> initiallySelected;

  const FilterBottomSheet({
    super.key,
    required this.allParticipants,
    required this.initiallySelected,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedParticipants;

  @override
  void initState() {
    super.initState();
    _selectedParticipants = List.from(widget.initiallySelected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por Participante',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // --- MUDANÇA AQUI ---
          ParticipantSelector(
            allParticipants: widget.allParticipants, // Passa a lista de modelos
            initialSelection: _selectedParticipants,
            onSelectionChanged: (newSelection) {
              _selectedParticipants = newSelection;
            },
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(<String>[]);
                  },
                  child: const Text('Limpar Filtro'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedParticipants);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
