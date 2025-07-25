import 'expense_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'racha_model.g.dart';

@JsonEnum()
enum FeeType { percentage, fixed }

@JsonSerializable(explicitToJson: true)
class Racha {
  final String title;
  final String date;
  final List<String> participants;
  final List<Expense> expenses;
  
  double serviceFeeValue;
  FeeType serviceFeeType;
  List<String> serviceFeeParticipants;
  bool isFinished;

  // **NOVO GETTER** para calcular o total
  @JsonKey(ignore: true) // Diz ao tradutor JSON para ignorar este campo
  double get totalAmount => expenses.fold(0.0, (sum, item) => sum + item.amount);

  Racha({
    required this.title,
    required this.date,
    required this.participants,
    List<Expense>? expenses,
    this.serviceFeeValue = 0.0,
    this.serviceFeeType = FeeType.percentage,
    List<String>? serviceFeeParticipants,
    this.isFinished = false,
  }) : expenses = expenses ?? [],
       serviceFeeParticipants = serviceFeeParticipants ?? List.from(participants);

  factory Racha.fromJson(Map<String, dynamic> json) => _$RachaFromJson(json);

  Map<String, dynamic> toJson() => _$RachaToJson(this);
}
