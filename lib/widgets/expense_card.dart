import 'package:flutter/material.dart';
import '../models/participant_model.dart'; // Importa o modelo de participante
import '../utils/color_helper.dart';

class ExpenseCard extends StatefulWidget {
  final String description;
  final String amount;
  final String sharedBy;
  final String? paidBy;
  final bool countsForSettlement;
  // --- MUDANÇA AQUI ---
  // Recebe a lista completa de modelos de participante
  final List<ParticipantModel> sharedWithParticipants;
  final double numericAmount;
  final VoidCallback onEditPressed;
  final List<String> allRachaParticipants;

  const ExpenseCard({
    super.key,
    required this.description,
    required this.amount,
    required this.sharedBy,
    this.paidBy,
    required this.countsForSettlement,
    required this.sharedWithParticipants,
    required this.numericAmount,
    required this.onEditPressed,
    required this.allRachaParticipants,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // A lógica do build principal permanece a mesma
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (código do cabeçalho do card, sem alterações)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF2D3748),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          color: Colors.grey[500],
                          padding: const EdgeInsets.all(8.0),
                          constraints: const BoxConstraints(),
                          onPressed: widget.onEditPressed,
                          tooltip: 'Editar Despesa',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Text(
                        widget.amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sharedBy,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF718096),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.paidBy != null && widget.countsForSettlement) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Pago por: ${widget.paidBy}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  _buildParticipantAvatars(),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                  );
                },
                child: _isExpanded
                    ? Column(
                        key: const ValueKey('expanded_content'),
                        children: [
                          const Divider(height: 24),
                          // --- MUDANÇA AQUI ---
                          ...widget.sharedWithParticipants.map((participant) {
                            final amountPerPerson = widget.numericAmount / widget.sharedWithParticipants.length;
                            return ListTile(
                              title: Text(participant.displayName, style: const TextStyle(fontSize: 15)),
                              trailing: Text(
                                'R\$ ${amountPerPerson.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              dense: true,
                            );
                          }).toList(),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('collapsed_content')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantAvatars() {
    const maxAvatars = 5;
    final itemsToShow = widget.sharedWithParticipants.length > maxAvatars
        ? maxAvatars
        : widget.sharedWithParticipants.length;

    final containerWidth = itemsToShow > 0 ? 28.0 + (18.0 * (itemsToShow - 1)) : 0.0;

    return SizedBox(
      width: containerWidth,
      height: 28,
      child: Stack(
        children: List.generate(
          itemsToShow,
          (index) {
            // --- MUDANÇA AQUI ---
            final participant = widget.sharedWithParticipants[index];
            final name = participant.displayName;
            final photoURL = participant.photoURL;
            final reversedIndex = itemsToShow - 1 - index;
            
            final color = ColorHelper.getColorForName(name);

            return Positioned(
              right: (reversedIndex * 18).toDouble(),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: color,
                backgroundImage: (photoURL != null && photoURL.isNotEmpty) ? NetworkImage(photoURL) : null,
                child: (photoURL == null || photoURL.isEmpty)
                  ? Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
