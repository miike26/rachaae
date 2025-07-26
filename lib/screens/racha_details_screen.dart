import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/racha_model.dart';
import '../models/expense_model.dart';
import '../widgets/expense_card.dart';
import '../widgets/edit_fees_bottom_sheet.dart';
import '../widgets/add_expense_bottom_sheet.dart';
import '../widgets/edit_expense_bottom_sheet.dart';
import '../widgets/individual_expense_card.dart';
import 'edit_racha_screen.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/participant_balance_card.dart';

// Enum para controlar a view selecionada (Despesas ou Resumo)
enum RachaView { despesas, resumo }

class RachaDetailsScreen extends StatefulWidget {
  final Racha racha;
  const RachaDetailsScreen({super.key, required this.racha});

  @override
  State<RachaDetailsScreen> createState() => _RachaDetailsScreenState();
}

class _RachaDetailsScreenState extends State<RachaDetailsScreen> with SingleTickerProviderStateMixin {
  late Racha _currentRacha;
  List<String> _filteredParticipants = [];
  late TabController _tabController;
  RachaView _selectedView = RachaView.despesas;

  @override
  void initState() {
    super.initState();
    _currentRacha = widget.racha;
    _tabController = TabController(length: 2, vsync: this, initialIndex: _selectedView.index);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _selectedView = RachaView.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSegmentChanged(Set<RachaView> newSelection) {
    final view = newSelection.first;
    setState(() {
      _selectedView = view;
      _tabController.animateTo(view.index);
    });
  }

  // --- Seus métodos existentes (show sheets, cálculos, etc) continuam iguais ---
  void _showFilterSheet() async {
    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        allParticipants: _currentRacha.participants,
        initiallySelected: _filteredParticipants,
      ),
    );

    if (selected != null) {
      setState(() {
        _filteredParticipants = selected;
      });
    }
  }

  void _showEditFeesSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => EditFeesBottomSheet(
        initialFeeValue: _currentRacha.serviceFeeValue,
        initialFeeType: _currentRacha.serviceFeeType,
        initialParticipants: _currentRacha.serviceFeeParticipants,
        allParticipants: _currentRacha.participants,
      ),
    );

    if (result != null) {
      setState(() {
        _currentRacha.serviceFeeValue = result['value'];
        _currentRacha.serviceFeeType = result['type'];
        _currentRacha.serviceFeeParticipants = result['participants'];
      });
    }
  }

  void _showAddExpenseSheet() async {
    final newExpense = await showModalBottomSheet<Expense>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => AddExpenseBottomSheet(participants: _currentRacha.participants),
    );

    if (newExpense != null) {
      setState(() {
        _currentRacha.expenses.add(newExpense);
      });
    }
  }

  void _showEditExpenseSheet(Expense expenseToEdit, int index) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => EditExpenseBottomSheet(
        expense: expenseToEdit,
        participants: _currentRacha.participants,
      ),
    );

    if (result != null) {
      setState(() {
        if (result['action'] == 'update') {
          _currentRacha.expenses[index] = result['data'];
        } else if (result['action'] == 'delete') {
          _currentRacha.expenses.removeAt(index);
        }
      });
    }
  }
  
  void _navigateToEditRacha() async {
    final updatedRacha = await Navigator.push<Racha>(
      context,
      MaterialPageRoute(
        builder: (context) => EditRachaScreen(racha: _currentRacha),
      ),
    );

    if (updatedRacha != null) {
      setState(() {
        _currentRacha = updatedRacha;
      });
    }
  }

  double _calculateSubtotal() {
    return _currentRacha.expenses.fold(0.0, (sum, item) => sum + item.amount);
  }
  
  double _getServiceFeeAmount() {
    final feeValue = _currentRacha.serviceFeeValue;
    if (feeValue <= 0) return 0.0;

    if (_currentRacha.serviceFeeType == FeeType.percentage) {
      return _calculateSubtotal() * (feeValue / 100.0);
    }
    return feeValue;
  }

  double _getTotalAmount() {
    return _calculateSubtotal() + _getServiceFeeAmount();
  }

  Map<String, double> _calculateTotalPerParticipant() {
    Map<String, double> totals = { for (var p in _currentRacha.participants) p : 0.0 };
    
    for (var expense in _currentRacha.expenses) {
      if (expense.sharedWith.isNotEmpty) {
        final amountPerPerson = expense.amount / expense.sharedWith.length;
        for (var participant in expense.sharedWith) {
          totals[participant] = (totals[participant] ?? 0) + amountPerPerson;
        }
      }
    }

    final serviceFeeAmount = _getServiceFeeAmount();
    if (serviceFeeAmount > 0 && _currentRacha.serviceFeeParticipants.isNotEmpty) {
      final feePerPerson = serviceFeeAmount / _currentRacha.serviceFeeParticipants.length;
      for (var participant in _currentRacha.serviceFeeParticipants) {
        totals[participant] = (totals[participant] ?? 0) + feePerPerson;
      }
    }

    return totals;
  }
  
  Map<String, double> _calculateCashierTotalPerParticipant() {
    Map<String, double> cashierTotals = { for (var p in _currentRacha.participants) p : 0.0 };
    final serviceFeeAmount = _getServiceFeeAmount();

    for (var expense in _currentRacha.expenses) {
      if (expense.paidBy != null && !expense.countsForSettlement) {
        cashierTotals[expense.paidBy!] = (cashierTotals[expense.paidBy!] ?? 0) + expense.amount;
      } 
      else if (expense.paidBy == null) {
        if (expense.sharedWith.isNotEmpty) {
          final amountPerPerson = expense.amount / expense.sharedWith.length;
          for (var participant in expense.sharedWith) {
            cashierTotals[participant] = (cashierTotals[participant] ?? 0) + amountPerPerson;
          }
        }
      }
      else {
        cashierTotals[expense.paidBy!] = (cashierTotals[expense.paidBy!] ?? 0) + expense.amount;
      }
    }

    if (serviceFeeAmount > 0 && _currentRacha.serviceFeeParticipants.isNotEmpty) {
      final feePerPerson = serviceFeeAmount / _currentRacha.serviceFeeParticipants.length;
      for (var participant in _currentRacha.serviceFeeParticipants) {
        cashierTotals[participant] = (cashierTotals[participant] ?? 0) + feePerPerson;
      }
    }

    return cashierTotals;
  }

  Map<String, double> _calculateSettlement() {
    Map<String, double> balances = { for (var p in _currentRacha.participants) p : 0.0 };

    for (var expense in _currentRacha.expenses.where((e) => e.paidBy != null && e.countsForSettlement)) {
      balances[expense.paidBy!] = (balances[expense.paidBy!] ?? 0) + expense.amount;

      if (expense.sharedWith.isNotEmpty) {
        final amountPerPerson = expense.amount / expense.sharedWith.length;
        for (var participant in expense.sharedWith) {
          balances[participant] = (balances[participant] ?? 0) - amountPerPerson;
        }
      }
    }
    
    return balances;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 30, color:  Color(0xFF484848)),
                    onPressed: () => Navigator.of(context).pop(_currentRacha),
                  ),
                  Expanded(
                    child: Text(
                      _currentRacha.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inriaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        height: 1.2,
                        color: const Color(0xFF484848),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 30, color:  Color(0xFF484848)),
                    offset: const Offset(0, 55),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        Navigator.of(context).pop('delete');
                      } else if (value == 'edit') {
                        _navigateToEditRacha();
                      } else if (value == 'finish') {
                        setState(() {
                          _currentRacha.isFinished = !_currentRacha.isFinished;
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'finish',
                        child: Text(_currentRacha.isFinished ? 'Reabrir Racha' : 'Finalizar Racha'),
                      ),
                      const PopupMenuItem<String>(value: 'edit', child: Text('Editar Racha')),
                      const PopupMenuDivider(color: Color.fromARGB(255, 224, 224, 224)),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Excluir Racha', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: SegmentedButton<RachaView>(
                  segments: const <ButtonSegment<RachaView>>[
                    ButtonSegment<RachaView>(value: RachaView.despesas, label: Text('Despesas')),
                    ButtonSegment<RachaView>(value: RachaView.resumo, label: Text('Resumo')),
                  ],
                  selected: {_selectedView},
                  onSelectionChanged: _onSegmentChanged,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpensesList(),
                  _buildSummaryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: _showAddExpenseSheet,
              label: const Text('Incluir Despesa'),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: _showFilterSheet,
              heroTag: 'filter_fab',
              child: Icon(
                _filteredParticipants.isEmpty ? Icons.filter_alt_outlined : Icons.filter_alt,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildExpensesList() {
    final filteredExpenses = _filteredParticipants.isEmpty
        ? _currentRacha.expenses
        : _currentRacha.expenses.where((expense) {
            return expense.sharedWith.any((participant) => _filteredParticipants.contains(participant));
          }).toList();

    if (filteredExpenses.isEmpty) {
      return Center(
        child: Text(
          _filteredParticipants.isEmpty ? 'Nenhuma despesa adicionada ainda.' : 'Nenhuma despesa encontrada para este filtro.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final sharedExpenses = filteredExpenses.where((e) => e.sharedWith.length > 1).toList();
    final individualExpenses = filteredExpenses.where((e) => e.sharedWith.length == 1).toList();

    final groupedIndividualExpenses = <String, List<Expense>>{};
    for (var expense in individualExpenses) {
      final participant = expense.sharedWith.first;
      if (groupedIndividualExpenses.containsKey(participant)) {
        groupedIndividualExpenses[participant]!.add(expense);
      } else {
        groupedIndividualExpenses[participant] = [expense];
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (sharedExpenses.isNotEmpty) ...[
          const Text('ITENS COMPARTILHADOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ...sharedExpenses.map((expense) {
            final index = _currentRacha.expenses.indexOf(expense);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ExpenseCard(
                description: expense.description,
                amount: 'R\$ ${expense.amount.toStringAsFixed(2)}',
                sharedBy: 'Dividido por ${expense.sharedWith.length}',
                paidBy: expense.paidBy,
                countsForSettlement: expense.countsForSettlement,
                participantsInitials: expense.sharedWith.map((p) => p.isNotEmpty ? p[0] : '?').toList(),
                sharedWithFullNames: expense.sharedWith,
                numericAmount: expense.amount,
                onEditPressed: () => _showEditExpenseSheet(expense, index),
                allRachaParticipants: _currentRacha.participants,
              ),
            );
          }),
        ],
        
        if (sharedExpenses.isNotEmpty && groupedIndividualExpenses.isNotEmpty) const SizedBox(height: 24),

        if (groupedIndividualExpenses.isNotEmpty) ...[
          const Text('CONSUMO INDIVIDUAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          ...groupedIndividualExpenses.entries.map((entry) {
            final participantName = entry.key;
            final expenses = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: IndividualExpenseCard(
                participantName: participantName,
                expenses: expenses,
                onTap: (expense) {
                  final index = _currentRacha.expenses.indexOf(expense);
                  _showEditExpenseSheet(expense, index);
                },
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSummaryTab() {
    final subtotal = _calculateSubtotal();
    final serviceFee = _getServiceFeeAmount();
    final totalAmount = _getTotalAmount();
    final totalPerParticipant = _calculateTotalPerParticipant();
    final cashierTotalPerParticipant = _calculateCashierTotalPerParticipant();
    final settlements = _calculateSettlement();

    final debtors = settlements.entries.where((e) => e.value < -0.01).toList();
    final creditors = settlements.entries.where((e) => e.value > 0.01).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumo da Conta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), Text('R\$ ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500))]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Taxa de Serviço (${_currentRacha.serviceFeeValue}${_currentRacha.serviceFeeType == FeeType.percentage ? '%' : ' R\$'})'), Text('R\$ ${serviceFee.toStringAsFixed(2)}')]),
                  const Divider(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('R\$ ${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: _showEditFeesSheet, child: const Text('Editar Taxas'))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Balanço por Participante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  ..._currentRacha.participants.map((participantName) {
                    final serviceFeePerPerson = _currentRacha.serviceFeeParticipants.contains(participantName) && _currentRacha.serviceFeeParticipants.isNotEmpty
                        ? serviceFee / _currentRacha.serviceFeeParticipants.length
                        : 0.0;
                    
                    final balance = settlements[participantName] ?? 0.0;
                    final isPayingFee = _currentRacha.serviceFeeParticipants.contains(participantName);

                    return ParticipantBalanceCard(
                      participantName: participantName,
                      allExpenses: _currentRacha.expenses,
                      totalConsumed: totalPerParticipant[participantName] ?? 0.0,
                      cashierTotal: cashierTotalPerParticipant[participantName] ?? 0.0,
                      serviceFeePerPerson: serviceFeePerPerson,
                      balance: balance,
                      isPayingFee: isPayingFee,
                    );
                  }).toList(),
                ],
               ),
             ),
          ),
          const SizedBox(height: 16),
          if (debtors.isNotEmpty && creditors.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Acerto de Contas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...debtors.map((debtor) {
                      if (creditors.isEmpty) return const SizedBox.shrink();
                      final creditor = creditors.first;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${debtor.key} deve R\$ ${(-debtor.value).toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), Text('para ${creditor.key}', style: const TextStyle(fontSize: 12))]),
                      );
                    }),
                    if (debtors.isNotEmpty && creditors.isNotEmpty) const SizedBox(height: 8),
                    ...creditors.map((creditor) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${creditor.key} recebe R\$ ${(creditor.value).toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
