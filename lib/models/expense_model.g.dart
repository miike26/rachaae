// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  sharedWith: (json['sharedWith'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  paidBy: json['paidBy'] as String?,
  countsForSettlement: json['countsForSettlement'] as bool? ?? true,
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'description': instance.description,
  'amount': instance.amount,
  'sharedWith': instance.sharedWith,
  'paidBy': instance.paidBy,
  'countsForSettlement': instance.countsForSettlement,
};
