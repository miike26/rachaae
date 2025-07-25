import 'package:json_annotation/json_annotation.dart';

// Esta linha conecta este arquivo a um arquivo gerado automaticamente.
part 'expense_model.g.dart';

// A anotação @JsonSerializable diz à ferramenta para criar o código de tradução.
@JsonSerializable()
class Expense {
  final String description;
  final double amount;
  final List<String> sharedWith;
  final String? paidBy;
  final bool countsForSettlement;

  Expense({
    required this.description,
    required this.amount,
    required this.sharedWith,
    this.paidBy,
    this.countsForSettlement = true,
  });

  // Construtor que cria um Expense a partir de um mapa JSON.
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  // Método que converte um Expense para um mapa JSON.
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
