import 'package:flutter/material.dart';
import '../utils/color_helper.dart';

class ParticipantSelector extends StatefulWidget {
  final List<String> allParticipants;
  final List<String> initialSelection;
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

  @override
  void initState() {
    super.initState();
    _selectedParticipants = List.from(widget.initialSelection);
    _selectAll = _selectedParticipants.length == widget.allParticipants.length;
  }

  void _toggleParticipant(String name) {
    setState(() {
      if (_selectedParticipants.contains(name)) {
        _selectedParticipants.remove(name);
      } else {
        _selectedParticipants.add(name);
      }
      _selectAll = _selectedParticipants.length == widget.allParticipants.length;
    });
    widget.onSelectionChanged(_selectedParticipants);
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedParticipants.clear();
      if (_selectAll) {
        _selectedParticipants.addAll(widget.allParticipants);
      }
    });
    widget.onSelectionChanged(_selectedParticipants);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text("Selecionar todos"),
          leading: Checkbox(
            value: _selectAll,
            onChanged: (value) => _toggleSelectAll(),
          ),
          onTap: _toggleSelectAll,
        ),
        Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
  decoration: BoxDecoration(
    color: Colors.grey.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
  ),
  child: LayoutBuilder(
    builder: (context, constraints) {
      double containerWidth = constraints.maxWidth;
      double itemWidth = 75;
      int itemsPerRow = (containerWidth / itemWidth).floor();
      double totalItemWidth = itemsPerRow * itemWidth;
      double remainingSpace = containerWidth - totalItemWidth;
      double spacing = itemsPerRow > 1
          ? remainingSpace / (itemsPerRow - 1)
          : 0;

      return Wrap(
        spacing: spacing,
        runSpacing: 12.0,
        alignment: WrapAlignment.start,
        children: widget.allParticipants.map((name) {
          final isSelected = _selectedParticipants.contains(name);
          final color = ColorHelper.getColorForName(name);

          return GestureDetector(
            onTap: () => _toggleParticipant(name),
            child: SizedBox(
              width: itemWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.all(isSelected ? 3 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.greenAccent.shade400 : Colors.transparent,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: color,
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 28)
                          : Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    },
  ),
)
      ],
    );
  }
}
