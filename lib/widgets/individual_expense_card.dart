import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/participant_model.dart'; // Importa o modelo
import '../utils/color_helper.dart';

class IndividualExpenseCard extends StatefulWidget {
  // --- MUDANÇA AQUI ---
  final ParticipantModel participant;
  final List<Expense> expenses;
  final Function(Expense) onTap;

  const IndividualExpenseCard({
    super.key,
    required this.participant,
    required this.expenses,
    required this.onTap,
  });

  @override
  State<IndividualExpenseCard> createState() => _IndividualExpenseCardState();
}

class _IndividualExpenseCardState extends State<IndividualExpenseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.expenses.fold(0.0, (sum, item) => sum + item.amount);
    
    // --- MUDANÇA AQUI ---
    final name = widget.participant.displayName;
    final photoURL = widget.participant.photoURL;
    final avatarColor = ColorHelper.getColorForName(name);

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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: avatarColor,
                        // --- MUDANÇA AQUI ---
                        backgroundImage: (photoURL != null && photoURL.isNotEmpty) ? NetworkImage(photoURL) : null,
                        child: (photoURL == null || photoURL.isEmpty)
                            ? Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'R\$ ${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
                          ...widget.expenses.map((expense) {
                            return ListTile(
                              leading: const Icon(Icons.edit, size: 18, color: Colors.grey),
                              title: Text(
                                expense.description,
                                style: const TextStyle(fontSize: 15),
                              ),
                              trailing: Text(
                                'R\$ ${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              onTap: () => widget.onTap(expense),
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
}
