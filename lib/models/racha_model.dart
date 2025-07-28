import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'expense_model.dart';

part 'racha_model.g.dart';

var _uuid = Uuid();

// Enum original mantido
@JsonEnum()
enum FeeType { percentage, fixed }

// Nome da classe original mantido: "Racha"
@JsonSerializable(explicitToJson: true)
class Racha {
  // NOVO CAMPO: ID único, gerado automaticamente.
  final String id;

  // Campos originais mantidos com nomes e tipos exatos.
  final String title;
  final String date; // Mantido como String para compatibilidade
  final List<String> participants;
  final List<Expense> expenses;
  
  double serviceFeeValue;
  FeeType serviceFeeType;
  List<String> serviceFeeParticipants;
  bool isFinished;

  // Getter original mantido.
  @JsonKey(ignore: true)
  double get totalAmount => expenses.fold(0.0, (sum, item) => sum + item.amount);

  Racha({
    String? id, // ID é opcional na criação para não quebrar o código existente
    required this.title,
    required this.date,
    required this.participants,
    List<Expense>? expenses,
    this.serviceFeeValue = 0.0,
    this.serviceFeeType = FeeType.percentage,
    List<String>? serviceFeeParticipants,
    this.isFinished = false,
  })  : this.id = id ?? _uuid.v4(), // Gera um ID se nenhum for passado
        this.expenses = expenses ?? [],
        this.serviceFeeParticipants = serviceFeeParticipants ?? List.from(participants);

  // Métodos de serialização JSON
  factory Racha.fromJson(Map<String, dynamic> json) => _$RachaFromJson(json);
  Map<String, dynamic> toJson() => _$RachaToJson(this);
}
