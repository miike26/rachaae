// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'racha_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Racha _$RachaFromJson(Map<String, dynamic> json) => Racha(
  title: json['title'] as String,
  date: json['date'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  expenses: (json['expenses'] as List<dynamic>?)
      ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
      .toList(),
  serviceFeeValue: (json['serviceFeeValue'] as num?)?.toDouble() ?? 0.0,
  serviceFeeType:
      $enumDecodeNullable(_$FeeTypeEnumMap, json['serviceFeeType']) ??
      FeeType.percentage,
  serviceFeeParticipants: (json['serviceFeeParticipants'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isFinished: json['isFinished'] as bool? ?? false,
);

Map<String, dynamic> _$RachaToJson(Racha instance) => <String, dynamic>{
  'title': instance.title,
  'date': instance.date,
  'participants': instance.participants,
  'expenses': instance.expenses.map((e) => e.toJson()).toList(),
  'serviceFeeValue': instance.serviceFeeValue,
  'serviceFeeType': _$FeeTypeEnumMap[instance.serviceFeeType]!,
  'serviceFeeParticipants': instance.serviceFeeParticipants,
  'isFinished': instance.isFinished,
};

const _$FeeTypeEnumMap = {
  FeeType.percentage: 'percentage',
  FeeType.fixed: 'fixed',
};
