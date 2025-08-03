import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'expense_model.dart';
import 'participant_model.dart'; // Importa o novo modelo

part 'racha_model.g.dart';

var _uuid = Uuid();

@JsonEnum()
enum FeeType { percentage, fixed }

// Enum para as categorias dos rachas, com a lista reduzida.
@JsonEnum()
enum RachaCategory {
  comidaEBebida,
  casaEContas,
  lazerEEventos,
  transporte,
  viagens,
  outros,
}


@JsonSerializable(explicitToJson: true)
class Racha {
  final String id;
  final String title;
  final String date;
  
  // CORREÇÃO: Adiciona um valor padrão para o JSON.
  // Isso garante que rachas antigos sem categoria sejam carregados corretamente.
  @JsonKey(defaultValue: RachaCategory.outros)
  final RachaCategory category;

  final List<ParticipantModel> participants;
  
  final List<Expense> expenses;
  
  double serviceFeeValue;
  FeeType serviceFeeType;
  List<String> serviceFeeParticipants; 
  bool isFinished;

  @JsonKey(ignore: true)
  double get totalAmount => expenses.fold(0.0, (sum, item) => sum + item.amount);

  Racha({
    String? id,
    required this.title,
    required this.date,
    required this.participants,
    this.category = RachaCategory.outros, // Valor padrão para a categoria
    List<Expense>? expenses,
    this.serviceFeeValue = 0.0,
    this.serviceFeeType = FeeType.percentage,
    List<String>? serviceFeeParticipants,
    this.isFinished = false,
  })  : this.id = id ?? _uuid.v4(),
        this.expenses = expenses ?? [],
        this.serviceFeeParticipants = serviceFeeParticipants ?? participants.map((p) => p.displayName).toList();

  factory Racha.fromJson(Map<String, dynamic> json) => _$RachaFromJson(json);
  Map<String, dynamic> toJson() => _$RachaToJson(this);
}
