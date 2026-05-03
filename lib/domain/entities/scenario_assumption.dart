import 'package:equatable/equatable.dart';

import '../enums/scenario_assumption_type.dart';

class ScenarioAssumption extends Equatable {
  const ScenarioAssumption({
    required this.id,
    required this.scenarioId,
    required this.type,
    required this.summary,
    this.params = const <String, Object?>{},
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String scenarioId;
  final ScenarioAssumptionType type;
  final String summary;
  final Map<String, Object?> params;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ScenarioAssumption copyWith({
    String? id,
    String? scenarioId,
    ScenarioAssumptionType? type,
    String? summary,
    Map<String, Object?>? params,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ScenarioAssumption(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      type: type ?? this.type,
      summary: summary ?? this.summary,
      params: params ?? this.params,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    scenarioId,
    type,
    summary,
    params.toString(),
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
