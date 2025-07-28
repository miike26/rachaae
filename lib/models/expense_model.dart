import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'expense_model.g.dart';

var _uuid = Uuid();

// Nome da classe original mantido: "Expense"
@JsonSerializable(explicitToJson: true)
class Expense {
  // NOVO CAMPO: ID único, gerado automaticamente.
  final String id;

  // Campos originais mantidos com nomes e tipos exatos.
  final String description;
  final double amount;
  final List<String> sharedWith;
  final String? paidBy;
  final bool countsForSettlement;

  Expense({
    String? id, // ID é opcional na criação
    required this.description,
    required this.amount,
    required this.sharedWith,
    this.paidBy,
    this.countsForSettlement = true,
  }) : this.id = id ?? _uuid.v4(); // Gera um ID se nenhum for passado

  // Métodos de serialização JSON
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
