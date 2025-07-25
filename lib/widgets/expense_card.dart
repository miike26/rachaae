import 'package:flutter/material.dart';
import '../utils/color_helper.dart';

class ExpenseCard extends StatefulWidget {
  final String description;
  final String amount;
  final String sharedBy;
  final String? paidBy;
  final bool countsForSettlement;
  final List<String> participantsInitials;
  final List<String> sharedWithFullNames;
  final double numericAmount;
  final VoidCallback onEditPressed;
  // NOVO PARÂMETRO: A lista completa de participantes do racha.
  final List<String> allRachaParticipants;

  const ExpenseCard({
    super.key,
    required this.description,
    required this.amount,
    required this.sharedBy,
    this.paidBy,
    required this.countsForSettlement,
    required this.participantsInitials,
    required this.sharedWithFullNames,
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
                          ...widget.sharedWithFullNames.map((name) {
                            final amountPerPerson = widget.numericAmount / widget.sharedWithFullNames.length;
                            return ListTile(
                              title: Text(name, style: const TextStyle(fontSize: 15)),
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
    final itemsToShow = widget.participantsInitials.length > maxAvatars
        ? maxAvatars
        : widget.participantsInitials.length;

    final containerWidth = itemsToShow > 0 ? 28.0 + (18.0 * (itemsToShow - 1)) : 0.0;

    return SizedBox(
      width: containerWidth,
      height: 28,
      child: Stack(
        children: List.generate(
          itemsToShow,
          (index) {
            final initial = widget.participantsInitials[index];
            final name = widget.sharedWithFullNames[index];
            final reversedIndex = itemsToShow - 1 - index;
            
            // **LÓGICA DE COR CONSISTENTE**
            final color = ColorHelper.getColorForName(name);

            return Positioned(
              right: (reversedIndex * 18).toDouble(),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: color,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
