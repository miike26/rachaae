import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../utils/color_helper.dart'; // Importa o gerador de cores

// Um card inteligente que mostra o balanço de um participante e pode ser expandido.
class ParticipantBalanceCard extends StatefulWidget {
  final String participantName;
  final List<Expense> allExpenses;
  final double totalConsumed;
  final double cashierTotal;
  final double serviceFeePerPerson;
  final double balance;
  final bool isPayingFee;

  const ParticipantBalanceCard({
    super.key,
    required this.participantName,
    required this.allExpenses,
    required this.totalConsumed,
    required this.cashierTotal,
    required this.serviceFeePerPerson,
    required this.balance,
    required this.isPayingFee,
  });

  @override
  State<ParticipantBalanceCard> createState() => _ParticipantBalanceCardState();
}

class _ParticipantBalanceCardState extends State<ParticipantBalanceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final participantExpenses = widget.allExpenses
        .where((e) => e.sharedWith.contains(widget.participantName))
        .toList();
    
    final bool showSimplifiedView = (widget.totalConsumed - widget.cashierTotal).abs() < 0.01 && widget.balance.abs() < 0.01;

    // **USA O GERADOR DE CORES AQUI**
    final avatarColor = ColorHelper.getColorForName(widget.participantName);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.participantName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              if (widget.isPayingFee && widget.serviceFeePerPerson > 0)
                                Icon(Icons.room_service, size: 16, color: Colors.orange.shade300),
                              if (widget.balance < -0.01) const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                              if (widget.balance > 0.01) const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'R\$ ${widget.cashierTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Total a pagar ao caixa',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (!showSimplifiedView) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Consumo total: R\$ ${widget.totalConsumed.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: avatarColor,
                          child: Text(
                            widget.participantName.isNotEmpty ? widget.participantName[0] : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                      ],
                    ),
                  ],
                ),

                if (_isExpanded) ...[
                  const Divider(height: 24),
                  ...participantExpenses.map((expense) {
                    final amountPerPerson = expense.amount / expense.sharedWith.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(expense.description),
                          Text('R\$ ${amountPerPerson.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }),
                  if (widget.serviceFeePerPerson > 0.01)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.room_service, size: 14, color: Colors.orange.shade300),
                              const SizedBox(width: 8),
                              const Text('Taxa de Serviço'),
                            ],
                          ),
                          Text('R\$ ${widget.serviceFeePerPerson.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
