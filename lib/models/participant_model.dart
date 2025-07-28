import 'package:json_annotation/json_annotation.dart';
part 'participant_model.g.dart';

/// Representa um participante dentro de um Racha.
/// Pode ser um usuário registrado (com uid) ou um convidado manual (sem uid).
@JsonSerializable()
class ParticipantModel {
  final String? uid; // Nulo para participantes manuais
  final String displayName;
  final String? photoURL; // Nulo se não houver foto

  ParticipantModel({
    this.uid,
    required this.displayName,
    this.photoURL,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantModelToJson(this);
}
