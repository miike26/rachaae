import 'package:flutter/material.dart';
import 'participant_selector.dart'; // Importa o seletor de avatares

class FilterBottomSheet extends StatefulWidget {
  final List<String> allParticipants;
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
          
          // **USA O NOVO SELETOR AQUI**
          ParticipantSelector(
            allParticipants: widget.allParticipants,
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
                  child: const Text('Limpar Filtr'),
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
