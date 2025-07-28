import 'package:flutter/material.dart';
import '../models/participant_model.dart'; // Importa o modelo de participante
import '../utils/color_helper.dart';

class ParticipantSelector extends StatefulWidget {
  // --- MUDANÇA AQUI ---
  // O seletor agora espera a lista completa de participantes.
  final List<ParticipantModel> allParticipants;
  final List<String> initialSelection; // A seleção inicial continua sendo por nome
  final Function(List<String>) onSelectionChanged;

  const ParticipantSelector({
    super.key,
    required this.allParticipants,
    required this.initialSelection,
    required this.onSelectionChanged,
  });

  @override
  State<ParticipantSelector> createState() => _ParticipantSelectorState();
}

class _ParticipantSelectorState extends State<ParticipantSelector> {
  late List<String> _selectedParticipants;
  bool _selectAll = false;
  // Nova lista para manter os participantes ordenados para exibição.
  late List<ParticipantModel> _sortedParticipants;

  @override
  void initState() {
    super.initState();
    _selectedParticipants = List.from(widget.initialSelection);
    _sortParticipants(); // Ordena a lista na inicialização
    _updateSelectAllState();
  }

  /// Ordena a lista de participantes para que os selecionados apareçam primeiro.
  void _sortParticipants() {
    _sortedParticipants = List.from(widget.allParticipants);
    _sortedParticipants.sort((a, b) {
      final aIsSelected = _selectedParticipants.contains(a.displayName);
      final bIsSelected = _selectedParticipants.contains(b.displayName);
      if (aIsSelected && !bIsSelected) return -1; // a vem primeiro
      if (!aIsSelected && bIsSelected) return 1; // b vem primeiro
      return a.displayName.compareTo(b.displayName); // Ordem alfabética
    });
  }

  void _toggleParticipant(String name) {
    setState(() {
      if (_selectedParticipants.contains(name)) {
        _selectedParticipants.remove(name);
      } else {
        _selectedParticipants.add(name);
      }
      _sortParticipants(); // Reordena a lista a cada seleção
      _updateSelectAllState();
    });
    widget.onSelectionChanged(_selectedParticipants);
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedParticipants.clear();
      if (_selectAll) {
        _selectedParticipants.addAll(widget.allParticipants.map((p) => p.displayName));
      }
      _sortParticipants(); // Reordena a lista
    });
    widget.onSelectionChanged(_selectedParticipants);
  }

  void _updateSelectAllState() {
    _selectAll = _selectedParticipants.length == widget.allParticipants.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text("Selecionar todos", style: TextStyle(fontWeight: FontWeight.w500)),
          value: _selectAll,
          onChanged: (value) => _toggleSelectAll(),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            // Usa a lista ordenada para construir a grade
            itemCount: _sortedParticipants.length,
            itemBuilder: (context, index) {
              final participant = _sortedParticipants[index];
              final isSelected = _selectedParticipants.contains(participant.displayName);
              return _ParticipantAvatar(
                participant: participant,
                isSelected: isSelected,
                onTap: () => _toggleParticipant(participant.displayName),
              );
            },
          ),
        )
      ],
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  // --- MUDANÇA AQUI ---
  // O avatar agora recebe o objeto ParticipantModel completo.
  final ParticipantModel participant;
  final bool isSelected;
  final VoidCallback onTap;

  const _ParticipantAvatar({
    required this.participant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = participant.displayName;
    final photoURL = participant.photoURL;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.7,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: ColorHelper.getColorForName(name),
                    // --- LÓGICA ATUALIZADA ---
                    // Usa a foto do perfil se ela existir.
                    backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                        ? NetworkImage(photoURL)
                        : null,
                    child: (photoURL == null || photoURL.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
